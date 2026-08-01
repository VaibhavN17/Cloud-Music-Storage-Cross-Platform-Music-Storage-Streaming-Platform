import { Request, Response, NextFunction } from 'express';
import { playlistService, PlaylistService } from '../services/playlist.service';
import { sendSuccess } from '../utils/response';

export class PlaylistController {
  constructor(private service: PlaylistService = playlistService) {}

  listPlaylists = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const ownerId = req.user!.id;
      const playlists = await this.service.listPlaylists(ownerId);
      sendSuccess(res, playlists, 'Playlists retrieved');
    } catch (error) {
      next(error);
    }
  };

  getPlaylist = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const playlist = await this.service.getPlaylist(req.params.id, userId);
      sendSuccess(res, playlist, 'Playlist retrieved');
    } catch (error) {
      next(error);
    }
  };

  createPlaylist = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const ownerId = req.user!.id;
      const { name, description, visibility } = req.body;
      const playlist = await this.service.createPlaylist(ownerId, name, description, visibility);
      sendSuccess(res, playlist, 'Playlist created', 201);
    } catch (error) {
      next(error);
    }
  };

  updatePlaylist = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const ownerId = req.user!.id;
      const updated = await this.service.updatePlaylist(req.params.id, ownerId, req.body);
      sendSuccess(res, updated, 'Playlist updated');
    } catch (error) {
      next(error);
    }
  };

  deletePlaylist = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const ownerId = req.user!.id;
      const deleted = await this.service.deletePlaylist(req.params.id, ownerId);
      sendSuccess(res, deleted, 'Playlist deleted');
    } catch (error) {
      next(error);
    }
  };

  addTrack = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const ownerId = req.user!.id;
      const { trackId } = req.body;
      await this.service.addTrackToPlaylist(req.params.id, ownerId, trackId);
      sendSuccess(res, null, 'Track added to playlist');
    } catch (error) {
      next(error);
    }
  };

  removeTrack = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const ownerId = req.user!.id;
      const trackId = req.params.trackId;
      await this.service.removeTrackFromPlaylist(req.params.id, ownerId, trackId);
      sendSuccess(res, null, 'Track removed from playlist');
    } catch (error) {
      next(error);
    }
  };

  reorderTracks = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const ownerId = req.user!.id;
      const { trackOrder } = req.body;
      await this.service.reorderPlaylistTracks(req.params.id, ownerId, trackOrder);
      sendSuccess(res, null, 'Playlist tracks reordered successfully');
    } catch (error) {
      next(error);
    }
  };
}

export const playlistController = new PlaylistController();
