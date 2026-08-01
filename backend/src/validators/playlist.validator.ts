import { z } from 'zod';

export const createPlaylistSchema = z.object({
  body: z.object({
    name: z.string().min(1, 'Playlist name is required').max(100),
    description: z.string().max(500).optional(),
    visibility: z.enum(['PRIVATE', 'PUBLIC', 'UNLISTED']).optional(),
  }),
});

export const updatePlaylistSchema = z.object({
  body: z.object({
    name: z.string().min(1).max(100).optional(),
    description: z.string().max(500).optional(),
    coverUrl: z.string().url().optional(),
    visibility: z.enum(['PRIVATE', 'PUBLIC', 'UNLISTED']).optional(),
  }),
});

export const addTrackToPlaylistSchema = z.object({
  body: z.object({
    trackId: z.string().min(1),
  }),
});

export const reorderPlaylistTracksSchema = z.object({
  body: z.object({
    trackOrder: z.array(
      z.object({
        trackId: z.string().min(1),
        position: z.number().int().nonnegative(),
      })
    ),
  }),
});
