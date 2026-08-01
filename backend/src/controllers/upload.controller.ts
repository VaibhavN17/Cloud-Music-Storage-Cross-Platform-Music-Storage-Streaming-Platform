import { Request, Response, NextFunction } from 'express';
import { trackService, TrackService } from '../services/track.service';
import { sendSuccess } from '../utils/response';

export class UploadController {
  constructor(private service: TrackService = trackService) {}

  requestUploadUrl = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { filename, mimeType, sizeBytes, isPublic } = req.body;
      const result = await this.service.requestUploadUrl(userId, filename, mimeType, sizeBytes, isPublic);
      sendSuccess(res, result, 'Presigned upload URL generated successfully', 200);
    } catch (error) {
      next(error);
    }
  };

  confirmUpload = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { trackId, fileKey, title, fileSizeBytes, format, folderId } = req.body;
      const track = await this.service.confirmUpload(
        userId,
        trackId,
        fileKey,
        title,
        fileSizeBytes,
        format,
        folderId
      );
      sendSuccess(res, track, 'Upload confirmed and track processing queued', 201);
    } catch (error) {
      next(error);
    }
  };
}

export const uploadController = new UploadController();
