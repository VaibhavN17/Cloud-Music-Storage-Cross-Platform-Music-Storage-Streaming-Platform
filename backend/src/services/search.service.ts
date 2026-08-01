import { prisma } from '../config/database';
import { Visibility } from '@prisma/client';

export class SearchService {
  async searchLibrary(
    userId: string,
    query: string,
    options: {
      type?: 'all' | 'tracks' | 'playlists' | 'folders';
      page?: number;
      limit?: number;
    }
  ) {
    const page = options.page || 1;
    const limit = options.limit || 20;
    const skip = (page - 1) * limit;

    const searchTerm = query.trim();

    const [tracks, playlists, folders] = await Promise.all([
      options.type === 'all' || options.type === 'tracks'
        ? prisma.track.findMany({
            where: {
              AND: [
                { deletedAt: null },
                {
                  OR: [{ ownerId: userId }, { visibility: Visibility.PUBLIC }],
                },
                {
                  OR: [
                    { title: { contains: searchTerm, mode: 'insensitive' } },
                    { artist: { contains: searchTerm, mode: 'insensitive' } },
                    { album: { contains: searchTerm, mode: 'insensitive' } },
                    { genre: { contains: searchTerm, mode: 'insensitive' } },
                  ],
                },
              ],
            },
            skip,
            take: limit,
            orderBy: { createdAt: 'desc' },
          })
        : [],

      options.type === 'all' || options.type === 'playlists'
        ? prisma.playlist.findMany({
            where: {
              AND: [
                {
                  OR: [{ ownerId: userId }, { visibility: Visibility.PUBLIC }],
                },
                {
                  OR: [
                    { name: { contains: searchTerm, mode: 'insensitive' } },
                    { description: { contains: searchTerm, mode: 'insensitive' } },
                  ],
                },
              ],
            },
            skip,
            take: limit,
          })
        : [],

      options.type === 'all' || options.type === 'folders'
        ? prisma.folder.findMany({
            where: {
              ownerId: userId,
              deletedAt: null,
              name: { contains: searchTerm, mode: 'insensitive' },
            },
            skip,
            take: limit,
          })
        : [],
    ]);

    return { tracks, playlists, folders };
  }
}

export const searchService = new SearchService();
