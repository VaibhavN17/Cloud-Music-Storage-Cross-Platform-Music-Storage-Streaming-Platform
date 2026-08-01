import dotenv from 'dotenv';
import path from 'path';
import { z } from 'zod';

dotenv.config({ path: path.resolve(process.cwd(), '.env') });

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.coerce.number().default(5000),
  API_PREFIX: z.string().default('/api/v1'),
  APP_URL: z.string().default('https://cloudtunemax.vercel.app'),

  DATABASE_URL: z
    .string()
    .default('postgresql://cloudmusic:cloudmusic_secret@localhost:5432/cloudmusic_db?schema=public'),

  REDIS_HOST: z.string().default('localhost'),
  REDIS_PORT: z.coerce.number().default(6379),
  REDIS_PASSWORD: z.string().optional().default(''),

  JWT_ACCESS_SECRET: z.string().default('supersecretaccesskey123456789_min32chars'),
  JWT_ACCESS_EXPIRES_IN: z.string().default('15m'),
  JWT_REFRESH_SECRET: z.string().default('supersecretrefreshkey123456789_min32chars'),
  JWT_REFRESH_EXPIRES_IN: z.string().default('30d'),

  R2_ACCOUNT_ID: z.string().optional().default('mock_r2_account_id'),
  R2_ACCESS_KEY_ID: z.string().optional().default('mock_r2_access_key'),
  R2_SECRET_ACCESS_KEY: z.string().optional().default('mock_r2_secret_key'),
  R2_PUBLIC_ENDPOINT: z.string().optional().default('https://mock.r2.cloudflarestorage.com'),
  R2_CDN_DOMAIN: z.string().optional().default('https://pub-521b34ee897a4b169d758e38c9e1faad.r2.dev'),
  R2_BUCKET_NAME: z.string().default('cloudtune'),
  R2_BUCKET_PRIVATE: z.string().default('cloudtune'),
  R2_BUCKET_PUBLIC: z.string().default('cloudtune'),
  R2_BUCKET_ARTWORK: z.string().default('cloudtune'),
  R2_BUCKET_TEMP: z.string().default('cloudtune'),

  GOOGLE_CLIENT_ID: z.string().optional(),
  GOOGLE_CLIENT_SECRET: z.string().optional(),
  APPLE_CLIENT_ID: z.string().optional(),
  APPLE_TEAM_ID: z.string().optional(),
  APPLE_KEY_ID: z.string().optional(),
  APPLE_PRIVATE_KEY_PATH: z.string().optional(),

  SMTP_HOST: z.string().optional().default('smtp.mailtrap.io'),
  SMTP_PORT: z.coerce.number().optional().default(587),
  SMTP_USER: z.string().optional(),
  SMTP_PASS: z.string().optional(),
  EMAIL_FROM: z.string().default('no-reply@cloudmusic.app'),

  LOG_LEVEL: z.enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace']).default('info'),
});

const parseEnv = () => {
  const result = envSchema.safeParse(process.env);
  if (!result.success) {
    console.warn('⚠️ Environment variable parsing notice:', result.error.format());
    // Return partial fallback so serverless functions never crash cold
    return envSchema.parse({});
  }
  return result.data;
};

export const env = parseEnv();
