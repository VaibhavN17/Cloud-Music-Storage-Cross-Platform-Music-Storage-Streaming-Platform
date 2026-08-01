import { S3Client, PutObjectCommand, GetObjectCommand, DeleteObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { env } from '../config/env.js';
import { logger } from '../utils/logger.js';

export class R2StorageService {
  private client: S3Client;

  constructor() {
    this.client = new S3Client({
      region: 'auto',
      endpoint: `https://${env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
      credentials: {
        accessKeyId: env.R2_ACCESS_KEY_ID,
        secretAccessKey: env.R2_SECRET_ACCESS_KEY,
      },
    });
  }

  /**
   * Generate presigned URL for direct upload from Flutter client
   */
  async generatePresignedUploadUrl(
    bucket: string,
    fileKey: string,
    contentType: string,
    expiresInSeconds: number = 3600
  ): Promise<string> {
    try {
      const command = new PutObjectCommand({
        Bucket: bucket,
        Key: fileKey,
        ContentType: contentType,
      });

      return await getSignedUrl(this.client, command, { expiresIn: expiresInSeconds });
    } catch (error) {
      logger.error({ error, fileKey, bucket }, 'Failed to generate presigned upload URL');
      throw error;
    }
  }

  /**
   * Generate signed URL for streaming or downloading private audio
   */
  async generateSignedDownloadUrl(
    bucket: string,
    fileKey: string,
    expiresInSeconds: number = 900
  ): Promise<string> {
    try {
      // If CDN domain is configured, use signed CDN URL style or direct signed R2 URL
      const command = new GetObjectCommand({
        Bucket: bucket,
        Key: fileKey,
      });

      return await getSignedUrl(this.client, command, { expiresIn: expiresInSeconds });
    } catch (error) {
      logger.error({ error, fileKey, bucket }, 'Failed to generate signed download URL');
      throw error;
    }
  }

  /**
   * Delete object from R2 bucket
   */
  async deleteObject(bucket: string, fileKey: string): Promise<void> {
    try {
      const command = new DeleteObjectCommand({
        Bucket: bucket,
        Key: fileKey,
      });
      await this.client.send(command);
    } catch (error) {
      logger.error({ error, fileKey, bucket }, 'Failed to delete object from R2');
      throw error;
    }
  }
}

export const r2Storage = new R2StorageService();
