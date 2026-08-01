import { User, Role } from '@prisma/client';
import { userRepository, UserRepository } from '../repositories/user.repository';
import { ApiError } from '../utils/ApiError';

export class UserService {
  constructor(private repo: UserRepository = userRepository) {}

  async getProfile(userId: string): Promise<Partial<User>> {
    const user = await this.repo.findById(userId);
    if (!user) {
      throw ApiError.notFound('User profile not found');
    }

    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { passwordHash, twoFactorSecret, ...publicUser } = user;
    return publicUser;
  }

  async updateProfile(userId: string, updateData: { displayName?: string; bio?: string; avatarUrl?: string }): Promise<Partial<User>> {
    const user = await this.repo.updateProfile(userId, updateData);
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { passwordHash, twoFactorSecret, ...publicUser } = user;
    return publicUser;
  }

  async toggleArtistMode(userId: string, enable: boolean): Promise<Partial<User>> {
    const user = await this.repo.updateProfile(userId, {
      role: enable ? Role.ARTIST : Role.USER,
    });
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { passwordHash, twoFactorSecret, ...publicUser } = user;
    return publicUser;
  }

  async getStorageQuota(userId: string): Promise<{ usedBytes: string; quotaBytes: string; usagePercentage: number }> {
    const { usedBytes, quotaBytes } = await this.repo.getStorageUsage(userId);
    const usedNum = Number(usedBytes);
    const quotaNum = Number(quotaBytes);
    const percentage = quotaNum > 0 ? (usedNum / quotaNum) * 100 : 0;

    return {
      usedBytes: usedBytes.toString(),
      quotaBytes: quotaBytes.toString(),
      usagePercentage: Math.round(percentage * 100) / 100,
    };
  }

  async recalculateStorage(userId: string): Promise<string> {
    const newTotal = await this.repo.recalculateStorage(userId);
    return newTotal.toString();
  }
}

export const userService = new UserService();