import { z } from 'zod';

export const updateProfileSchema = z.object({
  displayName: z.string().min(1).max(100).optional(),
  avatarUrl: z.string().url().optional().nullable(),
  bio: z.string().max(500).optional().nullable(),
  phoneNumber: z.string().optional().nullable(),
});

export const toggleArtistModeSchema = z.object({
  enable: z.boolean(),
});
