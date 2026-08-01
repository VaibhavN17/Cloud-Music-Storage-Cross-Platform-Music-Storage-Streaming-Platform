import { trackRepository, TrackRepository } from '../repositories/track.repository';
import { storageService, StorageService } from './storage.service';
import { ApiError } from '../utils/ApiError';
import { prisma } from '../config/database';
import { Visibility } from '@prisma/client';

export class StreamingService {
  constructor(
    private trackRepo: TrackRepository = trackRepository,
    private storage: StorageService = storageService
  ) {}

  async getSignedStreamUrl(trackId: string, userId: string): Promise<{ streamUrl: string; expiresAt: Date; format: string }> {
    const track = await this.trackRepo.findById(trackId);
    if (!track || track.deletedAt) {
      throw ApiError.notFound('Track not found or deleted');
    }

    if (track.visibility === Visibility.PRIVATE && track.ownerId !== userId) {
      throw ApiError.forbidden('Private track access forbidden');
    }

    const ttlSeconds = 7200; // 2 hours TTL for smooth album streaming
    const streamUrl = await this.storage.generateSignedStreamingUrl(
      track.fileKey,
      track.visibility === Visibility.PUBLIC ? 'audio-public' : 'audio-private',
      ttlSeconds
    );

    const expiresAt = new Date(Date.now() + ttlSeconds * 1000);

    // Increment play count asynchronously
    await this.trackRepo.incrementPlayCount(trackId);

    return { streamUrl, expiresAt, format: track.format };
  }

  async recordPlaybackHeartbeat(
    userId: string,
    trackId: string,
    positionSec: number,
    deviceInfo?: string
  ): Promise<{ status: string }> {
    await prisma.playbackHistory.create({
      data: {
        userId,
        trackId,
        durationSec: Math.floor(positionSec),
        deviceInfo: deviceInfo || 'Unknown Device',
      },
    });

    return { status: 'recorded' };
  }
}

export const streamingService = new StreamingService();
