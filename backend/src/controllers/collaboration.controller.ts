import { Request, Response, NextFunction } from 'express';
import { collaborationService, CollaborationService } from '../services/collaboration.service';
import { sendSuccess } from '../utils/response';

export class CollaborationController {
  constructor(private service: CollaborationService = collaborationService) {}

  syncContacts = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { phoneNumbers } = req.body;
      const results = await this.service.syncContacts(userId, phoneNumbers);
      sendSuccess(res, results, 'Contacts matched against app users');
    } catch (error) {
      next(error);
    }
  };

  sendInvite = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const hostId = req.user!.id;
      const { phoneNumber, guestId } = req.body;
      const session = await this.service.sendInvite(hostId, { phoneNumber, guestId });
      sendSuccess(res, session, 'Collaboration invite sent successfully');
    } catch (error) {
      next(error);
    }
  };

  getInvitesAndSessions = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const data = await this.service.getInvitesAndSessions(userId);
      sendSuccess(res, data, 'Collaboration sessions and invites retrieved');
    } catch (error) {
      next(error);
    }
  };

  respondInvite = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { id } = req.params;
      const { accept } = req.body;
      const result = await this.service.respondInvite(userId, id, accept);
      sendSuccess(res, result, `Invitation ${accept ? 'accepted' : 'declined'}`);
    } catch (error) {
      next(error);
    }
  };

  getCombinedTracks = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { id } = req.params;
      const tracksData = await this.service.getCombinedTracks(userId, id);
      sendSuccess(res, tracksData, 'Combined session tracks retrieved');
    } catch (error) {
      next(error);
    }
  };

  playRandomSong = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { id } = req.params;
      const randomTrackData = await this.service.playRandomSong(userId, id);
      sendSuccess(res, randomTrackData, 'Random song selected from combined library');
    } catch (error) {
      next(error);
    }
  };

  endSession = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { id } = req.params;
      const ended = await this.service.endSession(userId, id);
      sendSuccess(res, ended, 'Collaboration session ended');
    } catch (error) {
      next(error);
    }
  };
}

export const collaborationController = new CollaborationController();
