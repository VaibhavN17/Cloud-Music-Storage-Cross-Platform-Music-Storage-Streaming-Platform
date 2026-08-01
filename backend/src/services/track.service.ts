import { Track, Visibility } from '@prisma/client';
import { trackRepository, TrackRepository, TrackFilterParams } from '../repositories/track.repository';
import { userRepository, UserRepository } from '../repositories/user.repository';
import { storageService, StorageService } from './storage.service';
import { validateAudioFileParams } from '../utils/fileValidator';
import { ApiError } from '../utils/ApiError';
import { randomUUID } from 'crypto';

export class TrackService {
  constructor(
    private trackRepo: TrackRepository = trackRepository,
    private userRepo: UserRepository = userRepository,
    private storage: StorageService = storageService
  ) {}

  async requestUploadUrl(
    userId: string,
    filename: string,
    mimeType: string,
    sizeBytes: number,
    isPublic = false
  ): Promise<{ trackId: string; uploadUrl: string; fileKey: string }> {
    validateAudioFileParams(filename, mimeType, sizeBytes);

    // Quota check
    const { usedBytes, quotaBytes } = await this.userRepo.getStorageUsage(userId);
    if (usedBytes + BigInt(sizeBytes) > quotaBytes) {
      throw ApiError.quotaExceeded('Upload exceeds storage quota limit');
    }

    const trackId = `trk_${randomUUID().replace(/-/g, '')}`;

    const { uploadUrl, fileKey } = await this.storage.generatePresignedUploadUrl(
      userId,
      trackId,
      filename,
      mimeType,
      isPublic
    );

    return { trackId, uploadUrl, fileKey };
  }

  async confirmUpload(
    userId: string,
    trackId: string,
    fileKey: string,
    title: string,
    fileSizeBytes: number,
    format: string,
    folderId?: string | null
  ): Promise<Track> {
    const track = await this.trackRepo.create({
      id: trackId,
      title,
      fileKey,
      fileSizeBytes: BigInt(fileSizeBytes),
      format,
      visibility: Visibility.PRIVATE,
      owner: { connect: { id: userId } },
      folder: folderId ? { connect: { id: folderId } } : undefined,
    });

    // Update user storage footprint
    await this.userRepo.recalculateStorage(userId);

    // Queue worker processing (BullMQ metadata queue dispatch done in worker trigger)
    return track;
  }

  async getTrack(trackId: string, userId: string): Promise<Track> {
    const track = await this.trackRepo.findById(trackId);
    if (!track || track.deletedAt) {
      throw ApiError.notFound('Track not found');
    }

    if (track.visibility === Visibility.PRIVATE && track.ownerId !== userId) {
      throw ApiError.forbidden('You do not have access to this private track');
    }

    return track;
  }

  async listTracks(params: TrackFilterParams): Promise<{ tracks: Track[]; total: number }> {
    return this.trackRepo.findMany(params);
  }

  async updateTrack(
    trackId: string,
    userId: string,
    data: { title?: string; artist?: string; album?: string; genre?: string; lyrics?: string; visibility?: Visibility }
  ): Promise<Track> {
    const track = await this.getTrack(trackId, userId);
    if (track.ownerId !== userId) {
      throw ApiError.forbidden('You can only update your own tracks');
    }

    return this.trackRepo.update(trackId, data);
  }

  async softDeleteTrack(trackId: string, userId: string): Promise<Track> {
    const track = await this.getTrack(trackId, userId);
    if (track.ownerId !== userId) {
      throw ApiError.forbidden('You can only delete your own tracks');
    }

    const deleted = await this.trackRepo.softDelete(trackId, userId);
    await this.userRepo.recalculateStorage(userId);
    return deleted;
  }

  async restoreTrack(trackId: string, userId: string): Promise<Track> {
    const restored = await this.trackRepo.restore(trackId, userId);
    await this.userRepo.recalculateStorage(userId);
    return restored;
  }
}

export const trackService = new TrackService();
