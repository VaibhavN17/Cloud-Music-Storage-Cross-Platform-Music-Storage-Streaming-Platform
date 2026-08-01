import { Worker, Job } from 'bullmq';
import { redisClient } from '../config/redis';
import { logger } from '../config/logger';
import { prisma } from '../config/database';
import { mailService } from '../services/mail.service';

const connection = redisClient;

// 1. Upload Processing Worker
export const uploadWorker = new Worker(
  'upload-queue',
  async (job: Job) => {
    logger.info({ jobId: job.id, data: job.data }, 'Processing upload job');
    const { trackId } = job.data;
    // Dispatch to metadata queue
    return { trackId, status: 'processed' };
  },
  { connection }
);

// 2. Metadata Extraction Worker
export const metadataWorker = new Worker(
  'metadata-queue',
  async (job: Job) => {
    logger.info({ jobId: job.id, data: job.data }, 'Extracting metadata from audio file');
    const { trackId, bitrate, durationMs, title, artist, album } = job.data;

    await prisma.track.update({
      where: { id: trackId },
      data: {
        bitrate: bitrate || 320,
        durationMs: durationMs || 180000,
        title: title || undefined,
        artist: artist || undefined,
        album: album || undefined,
      },
    });

    return { trackId, status: 'metadata_updated' };
  },
  { connection }
);

// 3. Artwork Processing Worker
export const artworkWorker = new Worker(
  'artwork-queue',
  async (job: Job) => {
    logger.info({ jobId: job.id, data: job.data }, 'Processing artwork cover image');
    const { trackId, artworkKey } = job.data;

    await prisma.track.update({
      where: { id: trackId },
      data: { artworkKey },
    });

    return { trackId, status: 'artwork_updated' };
  },
  { connection }
);

// 4. Cleanup Worker (Scheduled Trash & Soft-Delete Purge)
export const cleanupWorker = new Worker(
  'cleanup-queue',
  async (job: Job) => {
    logger.info({ jobId: job.id }, 'Executing scheduled maintenance cleanup');
    
    // Purge expired soft-deleted tracks older than 30 days
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const purged = await prisma.track.deleteMany({
      where: {
        deletedAt: { lte: thirtyDaysAgo },
      },
    });

    // Revoke expired refresh tokens
    const revokedTokens = await prisma.refreshToken.deleteMany({
      where: {
        expiresAt: { lte: new Date() },
      },
    });

    return { purgedTracks: purged.count, expiredTokensCleaned: revokedTokens.count };
  },
  { connection }
);

// 5. Notification Worker
export const notificationWorker = new Worker(
  'notification-queue',
  async (job: Job) => {
    logger.info({ jobId: job.id, data: job.data }, 'Dispatching notification');
    const { userId, type, title, message } = job.data;

    await prisma.notification.create({
      data: { userId, type, title, message },
    });

    return { status: 'sent' };
  },
  { connection }
);

// 6. Playback History Worker
export const playbackWorker = new Worker(
  'playback-queue',
  async (job: Job) => {
    logger.info({ jobId: job.id, data: job.data }, 'Logging playback history async');
    const { userId, trackId, durationSec, deviceInfo } = job.data;

    await prisma.playbackHistory.create({
      data: { userId, trackId, durationSec, deviceInfo },
    });

    return { status: 'logged' };
  },
  { connection }
);

// 7. Email Queue Worker
export const emailWorker = new Worker(
  'email-queue',
  async (job: Job) => {
    logger.info({ jobId: job.id, data: job.data }, 'Processing email dispatch job');
    const { type, email, token } = job.data;

    if (type === 'verification') {
      await mailService.sendVerificationEmail(email, token);
    } else if (type === 'reset-password') {
      await mailService.sendPasswordResetEmail(email, token);
    }

    return { email, status: 'sent' };
  },
  { connection }
);

logger.info('⚙️ All 7 BullMQ Workers initialized and listening for jobs.');
