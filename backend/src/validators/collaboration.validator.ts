import { z } from 'zod';

export const syncContactsSchema = z.object({
  phoneNumbers: z.array(z.string()).min(1),
});

export const inviteCollaborationSchema = z.object({
  phoneNumber: z.string().optional(),
  guestId: z.string().optional(),
});

export const respondInviteSchema = z.object({
  accept: z.boolean(),
});
