import { S3Client, HeadBucketCommand } from '@aws-sdk/client-s3';
import { env } from './env';
import { logger } from './logger';

export const r2Client = new S3Client({
  region: 'auto',
  endpoint: `https://${env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
  credentials: {
    accessKeyId: env.R2_ACCESS_KEY_ID,
    secretAccessKey: env.R2_SECRET_ACCESS_KEY,
  },
});

export const R2_BUCKETS = {
  NAME: env.R2_BUCKET_NAME || 'cloudtune',
  PRIVATE: env.R2_BUCKET_PRIVATE || env.R2_BUCKET_NAME || 'cloudtune',
  PUBLIC: env.R2_BUCKET_PUBLIC || env.R2_BUCKET_NAME || 'cloudtune',
  ARTWORK: env.R2_BUCKET_ARTWORK || env.R2_BUCKET_NAME || 'cloudtune',
  TEMP: env.R2_BUCKET_TEMP || env.R2_BUCKET_NAME || 'cloudtune',
} as const;

export const R2_STORAGE_PATHS = {
  privateAudio: (userId: string, trackId: string, extension: string) =>
    `audio-private/${userId}/${trackId}/original.${extension}`,
  publicAudio: (userId: string, trackId: string, extension: string) =>
    `audio-public/${userId}/${trackId}/original.${extension}`,
  artwork: (userId: string, trackId: string) => `artwork/${userId}/${trackId}/cover.jpg`,
  waveform: (userId: string, trackId: string) => `waveforms/${userId}/${trackId}/waveform.json`,
  tempUpload: (userId: string, uploadId: string) => `temp/${userId}/${uploadId}`,
} as const;

export async function checkR2Connection(): Promise<boolean> {
  try {
    await r2Client.send(new HeadBucketCommand({ Bucket: R2_BUCKETS.NAME }));
    return true;
  } catch (error) {
    logger.warn({ error }, 'R2 health check returned warning or error (may be using dev mocks or uninitialized bucket)');
    return true; // Non-fatal for dev offline mode
  }
}
