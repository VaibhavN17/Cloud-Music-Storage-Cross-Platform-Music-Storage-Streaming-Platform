import { Request, Response, NextFunction } from 'express';
import { publicService, PublicService } from '../services/public.service';
import { sendSuccess } from '../utils/response';

export class PublicController {
  constructor(private service: PublicService = publicService) {}

  getArtistProfile = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const profile = await this.service.getPublicArtistProfile(req.params.artistId);
      sendSuccess(res, profile, 'Artist profile retrieved');
    } catch (error) {
      next(error);
    }
  };

  followArtist = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const followerId = req.user!.id;
      const followingId = req.params.artistId;
      await this.service.followArtist(followerId, followingId);
      sendSuccess(res, null, 'Artist followed successfully');
    } catch (error) {
      next(error);
    }
  };

  unfollowArtist = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const followerId = req.user!.id;
      const followingId = req.params.artistId;
      await this.service.unfollowArtist(followerId, followingId);
      sendSuccess(res, null, 'Artist unfollowed successfully');
    } catch (error) {
      next(error);
    }
  };

  likeTrack = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const trackId = req.params.trackId;
      await this.service.likeTrack(userId, trackId);
      sendSuccess(res, null, 'Track liked');
    } catch (error) {
      next(error);
    }
  };

  unlikeTrack = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const trackId = req.params.trackId;
      await this.service.unlikeTrack(userId, trackId);
      sendSuccess(res, null, 'Track unliked');
    } catch (error) {
      next(error);
    }
  };

  addComment = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const trackId = req.params.trackId;
      const { body } = req.body;
      const comment = await this.service.addComment(userId, trackId, body);
      sendSuccess(res, comment, 'Comment added', 201);
    } catch (error) {
      next(error);
    }
  };

  listComments = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const trackId = req.params.trackId;
      const page = req.query.page ? Number(req.query.page) : 1;
      const limit = req.query.limit ? Number(req.query.limit) : 20;
      const comments = await this.service.listComments(trackId, page, limit);
      sendSuccess(res, comments, 'Comments retrieved');
    } catch (error) {
      next(error);
    }
  };

  submitReport = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const reporterId = req.user!.id;
      const { type, reason, trackId, reportedUserId, evidenceUrl } = req.body;
      const report = await this.service.reportAbuseOrDmca(
        reporterId,
        type,
        reason,
        trackId,
        reportedUserId,
        evidenceUrl
      );
      sendSuccess(res, report, 'Report submitted successfully', 201);
    } catch (error) {
      next(error);
    }
  };
}

export const publicController = new PublicController();
