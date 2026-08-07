import { prisma } from '../config/database';
import { ApiError } from '../utils/ApiError';
import { Role } from '@prisma/client';

export function normalizePhoneNumber(phone: string): string {
  const digits = phone.replace(/\D/g, '');
  if (digits.length === 10) {
    return `+91${digits}`; // Default country prefix if 10 digits
  }
  if (phone.startsWith('+')) {
    return `+${digits}`;
  }
  return `+${digits}`;
}

export class UserService {
  async getProfile(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        displayName: true,
        avatarUrl: true,
        bio: true,
        role: true,
        phoneNumber: true,
        phoneNumberNormalized: true,
        storageUsedBytes: true,
        storageQuotaBytes: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!user) {
      throw ApiError.notFound('User not found');
    }

    return user;
  }

  async updateProfile(userId: string, data: { displayName?: string; avatarUrl?: string | null; bio?: string | null; phoneNumber?: string | null }) {
    const updateData: Record<string, unknown> = {};

    if (data.displayName !== undefined) updateData.displayName = data.displayName;
    if (data.avatarUrl !== undefined) updateData.avatarUrl = data.avatarUrl;
    if (data.bio !== undefined) updateData.bio = data.bio;
    if (data.phoneNumber !== undefined) {
      updateData.phoneNumber = data.phoneNumber;
      updateData.phoneNumberNormalized = data.phoneNumber ? normalizePhoneNumber(data.phoneNumber) : null;
    }

    const updated = await prisma.user.update({
      where: { id: userId },
      data: updateData,
    });

    return updated;
  }

  async toggleArtistMode(userId: string, enable: boolean) {
    const updated = await prisma.user.update({
      where: { id: userId },
      data: {
        role: enable ? Role.ARTIST : Role.USER,
      },
    });
    return updated;
  }

  async getStorageQuota(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { storageUsedBytes: true, storageQuotaBytes: true },
    });

    if (!user) {
      throw ApiError.notFound('User not found');
    }

    const usedBytes = Number(user.storageUsedBytes);
    const quotaBytes = Number(user.storageQuotaBytes);
    const percentage = quotaBytes > 0 ? (usedBytes / quotaBytes) * 100 : 0;

    return {
      usedBytes,
      quotaBytes,
      percentage: Math.round(percentage * 100) / 100,
    };
  }

  async recalculateStorage(userId: string): Promise<number> {
    const result = await prisma.track.aggregate({
      where: { ownerId: userId, deletedAt: null },
      _sum: { fileSizeBytes: true },
    });

    const newTotal = result._sum.fileSizeBytes ?? 0n;

    await prisma.user.update({
      where: { id: userId },
      data: { storageUsedBytes: newTotal },
    });

    return Number(newTotal);
  }
}

export const userService = new UserService();
