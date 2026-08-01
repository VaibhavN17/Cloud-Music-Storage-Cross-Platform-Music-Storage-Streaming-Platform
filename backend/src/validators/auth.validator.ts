import { z } from 'zod';

export const signupSchema = z.object({
  body: z.object({
    email: z.string().email('Invalid email address'),
    password: z.string().min(8, 'Password must be at least 8 characters'),
    displayName: z.string().min(2, 'Display name must be at least 2 characters'),
  }),
});

export const loginSchema = z.object({
  body: z.object({
    email: z.string().email('Invalid email address'),
    password: z.string().min(1, 'Password is required'),
  }),
});

export const refreshTokenSchema = z.object({
  body: z.object({
    refreshToken: z.string().min(1, 'Refresh token is required'),
  }),
});

export const forgotPasswordSchema = z.object({
  body: z.object({
    email: z.string().email('Invalid email address'),
  }),
});

export const resetPasswordSchema = z.object({
  body: z.object({
    token: z.string().min(1, 'Reset token is required'),
    newPassword: z.string().min(8, 'Password must be at least 8 characters'),
  }),
});

export const oauthSchema = z.object({
  body: z.object({
    idToken: z.string().min(1, 'OAuth ID Token is required'),
    provider: z.enum(['google', 'apple']),
  }),
});

export const verify2faSchema = z.object({
  body: z.object({
    code: z.string().length(6, '2FA Code must be 6 digits'),
  }),
});
