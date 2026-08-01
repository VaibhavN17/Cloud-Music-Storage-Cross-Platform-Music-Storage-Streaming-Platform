import { z } from 'zod';

export const createFolderSchema = z.object({
  body: z.object({
    name: z.string().min(1, 'Folder name is required').max(100),
    parentId: z.string().nullable().optional(),
  }),
});

export const updateFolderSchema = z.object({
  body: z.object({
    name: z.string().min(1).max(100).optional(),
    parentId: z.string().nullable().optional(),
  }),
});
