import { Request, Response, NextFunction } from 'express';
import { trackService, TrackService } from '../services/track.service';
import { sendSuccess } from '../utils/response';

export class TrackController {
  constructor(private service: TrackService = trackService) {}

  listTracks = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { page, limit, sort, order, search, genre, artist, album, folderId, deletedOnly } = req.query;

      const { tracks, total } = await this.service.listTracks({
        ownerId: userId,
        page: page ? Number(page) : 1,
        limit: limit ? Number(limit) : 20,
        sort: sort as string,
        order: (order as 'asc' | 'desc') || 'desc',
        search: search as string,
        genre: genre as string,
        artist: artist as string,
        album: album as string,
        folderId: folderId as string,
        deletedOnly: deletedOnly === 'true',
      });

      sendSuccess(res, tracks, 'Tracks retrieved', 200, {
        page: page ? Number(page) : 1,
        limit: limit ? Number(limit) : 20,
        total,
        totalPages: Math.ceil(total / (limit ? Number(limit) : 20)),
      });
    } catch (error) {
      next(error);
    }
  };

  getTrack = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const track = await this.service.getTrack(req.params.id, userId);
      sendSuccess(res, track, 'Track retrieved');
    } catch (error) {
      next(error);
    }
  };

  updateTrack = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const updated = await this.service.updateTrack(req.params.id, userId, req.body);
      sendSuccess(res, updated, 'Track metadata updated');
    } catch (error) {
      next(error);
    }
  };

  deleteTrack = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const deleted = await this.service.softDeleteTrack(req.params.id, userId);
      sendSuccess(res, deleted, 'Track moved to trash');
    } catch (error) {
      next(error);
    }
  };

  restoreTrack = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const restored = await this.service.restoreTrack(req.params.id, userId);
      sendSuccess(res, restored, 'Track restored from trash');
    } catch (error) {
      next(error);
    }
  };
}

export const trackController = new TrackController();
