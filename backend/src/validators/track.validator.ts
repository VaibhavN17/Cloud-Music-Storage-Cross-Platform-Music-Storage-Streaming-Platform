import { z } from 'zod';

export const requestUploadUrlSchema = z.object({
  body: z.object({
    filename: z.string().min(1, 'Filename is required'),
    mimeType: z.string().min(1, 'MIME type is required'),
    sizeBytes: z.number().positive('File size must be positive'),
    isPublic: z.boolean().optional().default(false),
  }),
});

export const confirmUploadSchema = z.object({
  body: z.object({
    trackId: z.string().min(1),
    fileKey: z.string().min(1),
    title: z.string().min(1),
    fileSizeBytes: z.number().positive(),
    format: z.string().min(1),
    folderId: z.string().nullable().optional(),
  }),
});

export const updateTrackSchema = z.object({
  body: z.object({
    title: z.string().min(1).optional(),
    artist: z.string().optional(),
    album: z.string().optional(),
    genre: z.string().optional(),
    lyrics: z.string().optional(),
    visibility: z.enum(['PRIVATE', 'PUBLIC', 'UNLISTED']).optional(),
  }),
});
