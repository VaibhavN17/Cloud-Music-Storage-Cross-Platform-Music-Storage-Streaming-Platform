import { Playlist, PlaylistTrack, Prisma, Visibility } from '@prisma/client';
import { prisma } from '../config/database';

export class PlaylistRepository {
  async findById(id: string, userId?: string): Promise<(Playlist & { tracks: (PlaylistTrack & { track: unknown })[] }) | null> {
    return prisma.playlist.findFirst({
      where: {
        id,
        OR: [
          { visibility: Visibility.PUBLIC },
          { ownerId: userId },
        ],
      },
      include: {
        tracks: {
          orderBy: { position: 'asc' },
          include: {
            track: true,
          },
        },
      },
    });
  }

  async listUserPlaylists(ownerId: string): Promise<Playlist[]> {
    return prisma.playlist.findMany({
      where: { ownerId },
      orderBy: { updatedAt: 'desc' },
      include: {
        _count: { select: { tracks: true } },
      },
    });
  }

  async create(data: Prisma.PlaylistCreateInput): Promise<Playlist> {
    return prisma.playlist.create({ data });
  }

  async update(id: string, ownerId: string, data: Prisma.PlaylistUpdateInput): Promise<Playlist> {
    return prisma.playlist.update({
      where: { id, ownerId },
      data,
    });
  }

  async delete(id: string, ownerId: string): Promise<Playlist> {
    return prisma.playlist.delete({
      where: { id, ownerId },
    });
  }

  async addTrack(playlistId: string, trackId: string): Promise<PlaylistTrack> {
    const count = await prisma.playlistTrack.count({ where: { playlistId } });
    return prisma.playlistTrack.create({
      data: {
        playlistId,
        trackId,
        position: count + 1,
      },
    });
  }

  async removeTrack(playlistId: string, trackId: string): Promise<Prisma.BatchPayload> {
    return prisma.playlistTrack.deleteMany({
      where: { playlistId, trackId },
    });
  }

  async reorderTracks(playlistId: string, trackOrder: { trackId: string; position: number }[]): Promise<void> {
    await prisma.$transaction(
      trackOrder.map(({ trackId, position }) =>
        prisma.playlistTrack.updateMany({
          where: { playlistId, trackId },
          data: { position },
        })
      )
    );
  }
}

export const playlistRepository = new PlaylistRepository();
