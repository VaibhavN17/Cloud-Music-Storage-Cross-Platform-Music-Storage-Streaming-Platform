import { ApiError } from './ApiError';

export const ALLOWED_AUDIO_FORMATS = ['mp3', 'wav', 'flac', 'aac', 'ogg', 'm4a'] as const;
export const ALLOWED_MIME_TYPES = [
  'audio/mpeg',
  'audio/wav',
  'audio/x-wav',
  'audio/flac',
  'audio/aac',
  'audio/ogg',
  'audio/mp4',
  'audio/x-m4a',
  'image/jpeg',
  'image/png',
  'image/webp',
];

export const MAX_AUDIO_SIZE_BYTES = 500 * 1024 * 1024; // 500 MB max audio file
export const MAX_ARTWORK_SIZE_BYTES = 10 * 1024 * 1024; // 10 MB max cover image

export function validateAudioFileParams(filename: string, mimeType: string, sizeBytes: number): void {
  const extension = filename.split('.').pop()?.toLowerCase();
  
  if (!extension || !ALLOWED_AUDIO_FORMATS.includes(extension as typeof ALLOWED_AUDIO_FORMATS[number])) {
    throw ApiError.badRequest(`Unsupported audio format: .${extension}. Allowed: ${ALLOWED_AUDIO_FORMATS.join(', ')}`);
  }

  if (!ALLOWED_MIME_TYPES.includes(mimeType)) {
    throw ApiError.badRequest(`Invalid MIME type: ${mimeType}`);
  }

  if (sizeBytes <= 0) {
    throw ApiError.badRequest('File size must be greater than 0 bytes');
  }

  if (sizeBytes > MAX_AUDIO_SIZE_BYTES) {
    throw ApiError.badRequest(`File size exceeds limit of ${MAX_AUDIO_SIZE_BYTES / (1024 * 1024)} MB`);
  }
}
