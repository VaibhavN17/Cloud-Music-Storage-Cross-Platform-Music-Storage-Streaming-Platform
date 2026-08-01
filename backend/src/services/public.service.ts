import { prisma } from '../config/database';
import { ApiError } from '../utils/ApiError';
import { ReportType, Visibility } from '@prisma/client';

export class PublicService {
  async getPublicArtistProfile(artistId: string) {
    const user = await prisma.user.findUnique({
      where: { id: artistId },
      select: {
        id: true,
        displayName: true,
        avatarUrl: true,
        bio: true,
        role: true,
        createdAt: true,
        _count: {
          select: {
            followers: true,
            tracks: { where: { visibility: Visibility.PUBLIC, deletedAt: null } },
          },
        },
      },
    });

    if (!user) {
      throw ApiError.notFound('Artist profile not found');
    }

    return user;
  }

  async followArtist(followerId: string, followingId: string) {
    if (followerId === followingId) {
      throw ApiError.badRequest('You cannot follow yourself');
    }

    return prisma.follow.upsert({
      where: {
        followerId_followingId: { followerId, followingId },
      },
      create: { followerId, followingId },
      update: {},
    });
  }

  async unfollowArtist(followerId: string, followingId: string) {
    return prisma.follow.deleteMany({
      where: { followerId, followingId },
    });
  }

  async likeTrack(userId: string, trackId: string) {
    const track = await prisma.track.findUnique({ where: { id: trackId } });
    if (!track || track.deletedAt) {
      throw ApiError.notFound('Track not found');
    }

    await prisma.$transaction([
      prisma.favorite.upsert({
        where: { userId_trackId: { userId, trackId } },
        create: { userId, trackId },
        update: {},
      }),
      prisma.track.update({
        where: { id: trackId },
        data: { likeCount: { increment: 1 } },
      }),
    ]);
  }

  async unlikeTrack(userId: string, trackId: string) {
    await prisma.$transaction([
      prisma.favorite.deleteMany({
        where: { userId, trackId },
      }),
      prisma.track.update({
        where: { id: trackId },
        data: { likeCount: { decrement: 1 } },
      }),
    ]);
  }

  async addComment(userId: string, trackId: string, body: string) {
    return prisma.comment.create({
      data: {
        authorId: userId,
        trackId,
        body,
      },
      include: {
        author: { select: { id: true, displayName: true, avatarUrl: true } },
      },
    });
  }

  async listComments(trackId: string, page = 1, limit = 20) {
    const skip = (page - 1) * limit;
    return prisma.comment.findMany({
      where: { trackId, deletedAt: null },
      skip,
      take: limit,
      orderBy: { createdAt: 'desc' },
      include: {
        author: { select: { id: true, displayName: true, avatarUrl: true } },
      },
    });
  }

  async reportAbuseOrDmca(
    reporterId: string,
    type: ReportType,
    reason: string,
    trackId?: string,
    reportedUserId?: string,
    evidenceUrl?: string
  ) {
    return prisma.report.create({
      data: {
        reporterId,
        type,
        reason,
        trackId,
        reportedUserId,
        evidenceUrl,
      },
    });
  }
}

export const publicService = new PublicService();
