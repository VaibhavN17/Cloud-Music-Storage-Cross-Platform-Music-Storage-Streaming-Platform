import { Router } from 'express';
import { playlistController } from '../controllers/playlist.controller';
import { authMiddleware } from '../middlewares/authMiddleware';
import { validate } from '../middlewares/validate';
import {
  createPlaylistSchema,
  updatePlaylistSchema,
  addTrackToPlaylistSchema,
  reorderPlaylistTracksSchema,
} from '../validators/playlist.validator';

const router = Router();

router.use(authMiddleware);

router.get('/', playlistController.listPlaylists);
router.post('/', validate(createPlaylistSchema), playlistController.createPlaylist);
router.get('/:id', playlistController.getPlaylist);
router.patch('/:id', validate(updatePlaylistSchema), playlistController.updatePlaylist);
router.delete('/:id', playlistController.deletePlaylist);
router.post('/:id/tracks', validate(addTrackToPlaylistSchema), playlistController.addTrack);
router.delete('/:id/tracks/:trackId', playlistController.removeTrack);
router.post('/:id/reorder', validate(reorderPlaylistTracksSchema), playlistController.reorderTracks);

export default router;
