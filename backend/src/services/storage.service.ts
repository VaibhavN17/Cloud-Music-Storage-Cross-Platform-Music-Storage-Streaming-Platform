import { PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { r2Client, R2_BUCKETS, R2_STORAGE_PATHS } from '../config/r2';
import { env } from '../config/env';

export class StorageService {
  async generatePresignedUploadUrl(
    userId: string,
    trackId: string,
    filename: string,
    _contentType: string,
    isPublic = false
  ): Promise<{ uploadUrl: string; fileKey: string; bucket: string }> {
    const extension = filename.split('.').pop()?.toLowerCase() || 'mp3';
    const bucket = isPublic ? R2_BUCKETS.PUBLIC : R2_BUCKETS.PRIVATE;
    const fileKey = isPublic
      ? R2_STORAGE_PATHS.publicAudio(userId, trackId, extension)
      : R2_STORAGE_PATHS.privateAudio(userId, trackId, extension);

    // Omit ContentType from PutObjectCommand during getSignedUrl to avoid
    // S3/R2 X-Amz-SignedHeaders signature mismatches (HTTP 403) from mobile HTTP clients.
    const command = new PutObjectCommand({
      Bucket: bucket,
      Key: fileKey,
    });

    const uploadUrl = await getSignedUrl(r2Client, command, { expiresIn: 3600 }); // 1 hour TTL

    return { uploadUrl, fileKey, bucket };
  }

  async generateSignedStreamingUrl(fileKey: string, bucketName?: string, expiresInSeconds = 7200): Promise<string> {
    const bucket = bucketName || R2_BUCKETS.PRIVATE;

    if (env.R2_CDN_DOMAIN && env.R2_CDN_DOMAIN.startsWith('http')) {
      return `${env.R2_CDN_DOMAIN}/${fileKey}`;
    }

    const command = new GetObjectCommand({
      Bucket: bucket,
      Key: fileKey,
    });

    return getSignedUrl(r2Client, command, { expiresIn: expiresInSeconds });
  }
}

export const storageService = new StorageService();
