import { prisma } from '../config/database';
import { ApiError } from '../utils/ApiError';
import { ReportStatus } from '@prisma/client';

export class AdminService {
  async getSystemStats() {
    const [totalUsers, totalTracks, totalPlaylists, totalStorageResult, openReports] = await Promise.all([
      prisma.user.count({ where: { deletedAt: null } }),
      prisma.track.count({ where: { deletedAt: null } }),
      prisma.playlist.count(),
      prisma.user.aggregate({
        _sum: { storageUsedBytes: true },
      }),
      prisma.report.count({ where: { status: ReportStatus.OPEN } }),
    ]);

    const totalStorageBytes = totalStorageResult._sum.storageUsedBytes ?? 0n;

    return {
      totalUsers,
      totalTracks,
      totalPlaylists,
      totalStorageBytes: totalStorageBytes.toString(),
      totalStorageGB: (Number(totalStorageBytes) / (1024 * 1024 * 1024)).toFixed(2),
      openReports,
    };
  }

  async listUsers(page = 1, limit = 20, search?: string) {
    const skip = (page - 1) * limit;
    const where = search
      ? {
          OR: [
            { email: { contains: search, mode: 'insensitive' as const } },
            { displayName: { contains: search, mode: 'insensitive' as const } },
          ],
        }
      : {};

    const [users, total] = await Promise.all([
      prisma.user.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          email: true,
          displayName: true,
          role: true,
          suspended: true,
          storageUsedBytes: true,
          createdAt: true,
        },
      }),
      prisma.user.count({ where }),
    ]);

    const formattedUsers = users.map((u) => ({
      ...u,
      storageUsedBytes: u.storageUsedBytes.toString(),
    }));

    return { users: formattedUsers, total };
  }

  async setUserSuspension(targetUserId: string, suspend: boolean) {
    const user = await prisma.user.findUnique({ where: { id: targetUserId } });
    if (!user) {
      throw ApiError.notFound('User not found');
    }

    return prisma.user.update({
      where: { id: targetUserId },
      data: { suspended: suspend },
      select: { id: true, email: true, suspended: true },
    });
  }

  async listReports(status?: ReportStatus, page = 1, limit = 20) {
    const skip = (page - 1) * limit;
    const where = status ? { status } : {};

    const [reports, total] = await Promise.all([
      prisma.report.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          reporter: { select: { id: true, displayName: true, email: true } },
          track: { select: { id: true, title: true, fileKey: true } },
        },
      }),
      prisma.report.count({ where }),
    ]);

    return { reports, total };
  }

  async resolveReport(reportId: string, adminId: string, status: ReportStatus, resolutionNote?: string) {
    const report = await prisma.report.findUnique({ where: { id: reportId } });
    if (!report) {
      throw ApiError.notFound('Report not found');
    }

    return prisma.report.update({
      where: { id: reportId },
      data: {
        status,
        resolutionNote,
        resolvedById: adminId,
        resolvedAt: new Date(),
      },
    });
  }
}

export const adminService = new AdminService();
