import { prisma } from '../config/database';
import { ApiError } from '../utils/ApiError';
import { normalizePhoneNumber } from './user.service';

export interface SyncedContactResult {
  phone: string;
  isRegisteredOnApp: boolean;
  user: {
    id: string;
    displayName: string;
    avatarUrl: string | null;
    phoneNumber: string | null;
  } | null;
}

export class CollaborationService {
  /**
   * Match device phone numbers against registered users on the app.
   */
  async syncContacts(userId: string, phoneNumbers: string[]): Promise<SyncedContactResult[]> {
    if (!phoneNumbers || phoneNumbers.length === 0) {
      return [];
    }

    // Build mapping from normalized phone to original input phone
    const phoneMap = new Map<string, string>();
    const normalizedList: string[] = [];

    for (const rawPhone of phoneNumbers) {
      const norm = normalizePhoneNumber(rawPhone);
      if (norm) {
        phoneMap.set(norm, rawPhone);
        // Also map stripped version without '+' for wider matching flexibility
        const digitsOnly = norm.replace(/\D/g, '');
        if (digitsOnly) {
          phoneMap.set(digitsOnly, rawPhone);
        }
        normalizedList.push(norm);
        normalizedList.push(digitsOnly);
      }
    }

    if (normalizedList.length === 0) {
      return phoneNumbers.map((phone) => ({
        phone,
        isRegisteredOnApp: false,
        user: null,
      }));
    }

    // Find users whose normalized phone number matches any in our list
    const foundUsers = await prisma.user.findMany({
      where: {
        id: { not: userId },
        OR: [
          { phoneNumberNormalized: { in: normalizedList } },
          { phoneNumber: { in: phoneNumbers } },
        ],
      },
      select: {
        id: true,
        displayName: true,
        avatarUrl: true,
        phoneNumber: true,
        phoneNumberNormalized: true,
      },
    });

    const registeredUserMap = new Map<string, typeof foundUsers[0]>();
    for (const u of foundUsers) {
      if (u.phoneNumberNormalized) {
        registeredUserMap.set(u.phoneNumberNormalized, u);
        registeredUserMap.set(u.phoneNumberNormalized.replace(/\D/g, ''), u);
      }
      if (u.phoneNumber) {
        registeredUserMap.set(u.phoneNumber, u);
      }
    }

    const results: SyncedContactResult[] = [];
    const processedPhones = new Set<string>();

    for (const rawPhone of phoneNumbers) {
      if (processedPhones.has(rawPhone)) continue;
      processedPhones.add(rawPhone);

      const norm = normalizePhoneNumber(rawPhone);
      const digits = norm.replace(/\D/g, '');

      const matchedUser = registeredUserMap.get(norm) || registeredUserMap.get(digits) || registeredUserMap.get(rawPhone);

      if (matchedUser) {
        results.push({
          phone: rawPhone,
          isRegisteredOnApp: true,
          user: {
            id: matchedUser.id,
            displayName: matchedUser.displayName,
            avatarUrl: matchedUser.avatarUrl,
            phoneNumber: matchedUser.phoneNumber,
          },
        });
      } else {
        results.push({
          phone: rawPhone,
          isRegisteredOnApp: false,
          user: null,
        });
      }
    }

    return results;
  }

  /**
   * Send a collaboration invite to a user by phone number or guestId.
   */
  async sendInvite(hostId: string, target: { phoneNumber?: string; guestId?: string }) {
    let guestUser = null;

    if (target.guestId) {
      guestUser = await prisma.user.findUnique({ where: { id: target.guestId } });
    } else if (target.phoneNumber) {
      const norm = normalizePhoneNumber(target.phoneNumber);
      const digits = norm.replace(/\D/g, '');

      guestUser = await prisma.user.findFirst({
        where: {
          OR: [
            { phoneNumberNormalized: norm },
            { phoneNumberNormalized: digits },
            { phoneNumber: target.phoneNumber },
          ],
        },
      });
    }

    if (!guestUser) {
      throw ApiError.notFound('Target contact is not registered on this app.');
    }

    if (guestUser.id === hostId) {
      throw ApiError.badRequest('You cannot send a collaboration invite to yourself.');
    }

    // Check if an existing pending or active session exists
    const existingSession = await prisma.collaborationSession.findFirst({
      where: {
        OR: [
          { hostId, guestId: guestUser.id, status: { in: ['PENDING', 'ACCEPTED'] } },
          { hostId: guestUser.id, guestId: hostId, status: { in: ['PENDING', 'ACCEPTED'] } },
        ],
      },
    });

    if (existingSession) {
      if (existingSession.status === 'ACCEPTED') {
        throw ApiError.badRequest('You already have an active collaboration session with this user.');
      }
      throw ApiError.badRequest('An invitation is already pending with this user.');
    }

    const hostUser = await prisma.user.findUnique({
      where: { id: hostId },
      select: { displayName: true },
    });

    const session = await prisma.collaborationSession.create({
      data: {
        hostId,
        guestId: guestUser.id,
        status: 'PENDING',
      },
      include: {
        host: {
          select: { id: true, displayName: true, avatarUrl: true, phoneNumber: true },
        },
        guest: {
          select: { id: true, displayName: true, avatarUrl: true, phoneNumber: true },
        },
      },
    });

    // Create Notification for Guest
    await prisma.notification.create({
      data: {
        userId: guestUser.id,
        type: 'COLLABORATION_INVITE',
        title: 'New Listening Invite',
        message: `${hostUser?.displayName || 'A user'} invited you to listen to music together!`,
        data: { sessionId: session.id, hostId },
      },
    });

    return session;
  }

  /**
   * Get user's active session and pending invitations.
   */
  async getInvitesAndSessions(userId: string) {
    const activeSession = await prisma.collaborationSession.findFirst({
      where: {
        status: 'ACCEPTED',
        OR: [{ hostId: userId }, { guestId: userId }],
      },
      include: {
        host: {
          select: { id: true, displayName: true, avatarUrl: true, phoneNumber: true },
        },
        guest: {
          select: { id: true, displayName: true, avatarUrl: true, phoneNumber: true },
        },
      },
    });

    const incomingInvites = await prisma.collaborationSession.findMany({
      where: {
        guestId: userId,
        status: 'PENDING',
      },
      include: {
        host: {
          select: { id: true, displayName: true, avatarUrl: true, phoneNumber: true },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    const outgoingInvites = await prisma.collaborationSession.findMany({
      where: {
        hostId: userId,
        status: 'PENDING',
      },
      include: {
        guest: {
          select: { id: true, displayName: true, avatarUrl: true, phoneNumber: true },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    return {
      activeSession,
      incomingInvites,
      outgoingInvites,
    };
  }

  /**
   * Respond to invitation (Accept / Decline).
   */
  async respondInvite(userId: string, sessionId: string, accept: boolean) {
    const session = await prisma.collaborationSession.findFirst({
      where: {
        id: sessionId,
        guestId: userId,
        status: 'PENDING',
      },
    });

    if (!session) {
      throw ApiError.notFound('Invitation not found or already processed.');
    }

    const updatedSession = await prisma.collaborationSession.update({
      where: { id: sessionId },
      data: {
        status: accept ? 'ACCEPTED' : 'DECLINED',
      },
      include: {
        host: {
          select: { id: true, displayName: true, avatarUrl: true, phoneNumber: true },
        },
        guest: {
          select: { id: true, displayName: true, avatarUrl: true, phoneNumber: true },
        },
      },
    });

    return updatedSession;
  }

  /**
   * Get combined track library of Host and Guest for an active session.
   */
  async getCombinedTracks(userId: string, sessionId: string) {
    const session = await prisma.collaborationSession.findUnique({
      where: { id: sessionId },
    });

    if (!session || session.status !== 'ACCEPTED') {
      throw ApiError.badRequest('Session is not active or invalid.');
    }

    if (session.hostId !== userId && session.guestId !== userId) {
      throw ApiError.forbidden('You are not a participant in this collaboration session.');
    }

    const tracks = await prisma.track.findMany({
      where: {
        ownerId: { in: [session.hostId, session.guestId] },
        deletedAt: null,
      },
      include: {
        owner: {
          select: { id: true, displayName: true, avatarUrl: true },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    return {
      sessionId,
      hostId: session.hostId,
      guestId: session.guestId,
      totalTracks: tracks.length,
      tracks,
    };
  }

  /**
   * Select a random song from the combined track pool of both users.
   */
  async playRandomSong(userId: string, sessionId: string) {
    const session = await prisma.collaborationSession.findUnique({
      where: { id: sessionId },
    });

    if (!session || session.status !== 'ACCEPTED') {
      throw ApiError.badRequest('Session is not active.');
    }

    if (session.hostId !== userId && session.guestId !== userId) {
      throw ApiError.forbidden('You are not a participant in this session.');
    }

    const tracks = await prisma.track.findMany({
      where: {
        ownerId: { in: [session.hostId, session.guestId] },
        deletedAt: null,
      },
      include: {
        owner: {
          select: { id: true, displayName: true, avatarUrl: true },
        },
      },
    });

    if (tracks.length === 0) {
      throw ApiError.badRequest('No tracks found in combined library of both users.');
    }

    const randomIndex = Math.floor(Math.random() * tracks.length);
    const selectedTrack = tracks[randomIndex];

    await prisma.collaborationSession.update({
      where: { id: sessionId },
      data: { currentTrackId: selectedTrack.id },
    });

    return {
      sessionId,
      selectedTrack,
      totalCombinedTracks: tracks.length,
    };
  }

  /**
   * End an active collaboration session.
   */
  async endSession(userId: string, sessionId: string) {
    const session = await prisma.collaborationSession.findUnique({
      where: { id: sessionId },
    });

    if (!session) {
      throw ApiError.notFound('Session not found.');
    }

    if (session.hostId !== userId && session.guestId !== userId) {
      throw ApiError.forbidden('You do not have permission to end this session.');
    }

    const endedSession = await prisma.collaborationSession.update({
      where: { id: sessionId },
      data: {
        status: 'ENDED',
        endedAt: new Date(),
      },
    });

    return endedSession;
  }
}

export const collaborationService = new CollaborationService();
