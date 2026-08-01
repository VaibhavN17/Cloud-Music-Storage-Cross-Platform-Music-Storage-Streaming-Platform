import { z } from 'zod';

export const updateProfileSchema = z.object({
  body: z.object({
    displayName: z.string().min(2).optional(),
    bio: z.string().max(500).optional(),
    avatarUrl: z.string().url().optional(),
  }),
});

export const toggleArtistModeSchema = z.object({
  body: z.object({
    enable: z.boolean(),
  }),
});
