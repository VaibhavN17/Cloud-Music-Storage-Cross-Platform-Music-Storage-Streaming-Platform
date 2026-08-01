import { Queue } from 'bullmq';
import { redisClient } from '../config/redis';

const connection = redisClient;

export const uploadQueue = new Queue('upload-queue', { connection });
export const metadataQueue = new Queue('metadata-queue', { connection });
export const artworkQueue = new Queue('artwork-queue', { connection });
export const cleanupQueue = new Queue('cleanup-queue', { connection });
export const notificationQueue = new Queue('notification-queue', { connection });
export const playbackQueue = new Queue('playback-queue', { connection });
export const emailQueue = new Queue('email-queue', { connection });

export const QUEUES = {
  UPLOAD: uploadQueue,
  METADATA: metadataQueue,
  ARTWORK: artworkQueue,
  CLEANUP: cleanupQueue,
  NOTIFICATION: notificationQueue,
  PLAYBACK: playbackQueue,
  EMAIL: emailQueue,
};
