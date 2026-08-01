import { Track, Prisma, Visibility } from '@prisma/client';
import { prisma } from '../config/database';

export interface TrackFilterParams {
  ownerId?: string;
  folderId?: string | null;
  visibility?: Visibility;
  deletedOnly?: boolean;
  search?: string;
  genre?: string;
  artist?: string;
  album?: string;
  page?: number;
  limit?: number;
  cursor?: string;
  sort?: string;
  order?: 'asc' | 'desc';
}

export class TrackRepository {
  async findById(id: string): Promise<Track | null> {
    return prisma.track.findUnique({
      where: { id },
      include: { owner: { select: { id: true, displayName: true, avatarUrl: true } } },
    });
  }

  async findMany(params: TrackFilterParams): Promise<{ tracks: Track[]; total: number }> {
    const page = params.page || 1;
    const limit = params.limit || 20;
    const skip = (page - 1) * limit;

    const where: Prisma.TrackWhereInput = {
      ...(params.ownerId ? { ownerId: params.ownerId } : {}),
      ...(params.folderId !== undefined ? { folderId: params.folderId } : {}),
      ...(params.visibility ? { visibility: params.visibility } : {}),
      deletedAt: params.deletedOnly ? { not: null } : null,
      ...(params.genre ? { genre: { equals: params.genre, mode: 'insensitive' } } : {}),
      ...(params.artist ? { artist: { contains: params.artist, mode: 'insensitive' } } : {}),
      ...(params.album ? { album: { contains: params.album, mode: 'insensitive' } } : {}),
      ...(params.search
        ? {
            OR: [
              { title: { contains: params.search, mode: 'insensitive' } },
              { artist: { contains: params.search, mode: 'insensitive' } },
              { album: { contains: params.search, mode: 'insensitive' } },
            ],
          }
        : {}),
    };

    const sortField = params.sort || 'createdAt';
    const sortOrder = params.order || 'desc';

    const [tracks, total] = await Promise.all([
      prisma.track.findMany({
        where,
        skip,
        take: limit,
        orderBy: { [sortField]: sortOrder },
      }),
      prisma.track.count({ where }),
    ]);

    return { tracks, total };
  }

  async create(data: Prisma.TrackCreateInput): Promise<Track> {
    return prisma.track.create({ data });
  }

  async update(id: string, data: Prisma.TrackUpdateInput): Promise<Track> {
    return prisma.track.update({
      where: { id },
      data,
    });
  }

  async softDelete(id: string, ownerId: string): Promise<Track> {
    return prisma.track.update({
      where: { id, ownerId },
      data: { deletedAt: new Date() },
    });
  }

  async restore(id: string, ownerId: string): Promise<Track> {
    return prisma.track.update({
      where: { id, ownerId },
      data: { deletedAt: null },
    });
  }

  async hardDelete(id: string, ownerId: string): Promise<Track> {
    return prisma.track.delete({
      where: { id, ownerId },
    });
  }

  async incrementPlayCount(id: string): Promise<Track> {
    return prisma.track.update({
      where: { id },
      data: { playCount: { increment: 1 } },
    });
  }
}

export const trackRepository = new TrackRepository();
