import { User, Prisma } from '@prisma/client';
import { prisma } from '../config/database';

export class UserRepository {
  async findById(id: string): Promise<User | null> {
    return prisma.user.findUnique({
      where: { id },
      include: {
        settings: true,
      },
    });
  }

  async updateProfile(id: string, data: Prisma.UserUpdateInput): Promise<User> {
    return prisma.user.update({
      where: { id },
      data,
      include: {
        settings: true,
      },
    });
  }

  async getStorageUsage(userId: string): Promise<{ usedBytes: bigint; quotaBytes: bigint }> {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { storageUsedBytes: true, storageQuotaBytes: true },
    });
    return {
      usedBytes: user?.storageUsedBytes ?? 0n,
      quotaBytes: user?.storageQuotaBytes ?? 5368709120n,
    };
  }

  async recalculateStorage(userId: string): Promise<bigint> {
    const aggregate = await prisma.track.aggregate({
      where: { ownerId: userId, deletedAt: null },
      _sum: { fileSizeBytes: true },
    });
    const totalBytes = aggregate._sum.fileSizeBytes ?? 0n;

    await prisma.user.update({
      where: { id: userId },
      data: { storageUsedBytes: totalBytes },
    });

    return totalBytes;
  }
}

export const userRepository = new UserRepository();
