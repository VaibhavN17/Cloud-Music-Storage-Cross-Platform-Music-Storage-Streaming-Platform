import { Router } from 'express';
import { publicController } from '../controllers/public.controller';
import { authMiddleware } from '../middlewares/authMiddleware';

const router = Router();

// Publicly readable endpoints
router.get('/artists/:artistId', publicController.getArtistProfile);
router.get('/tracks/:trackId/comments', publicController.listComments);

// Authenticated social endpoints
router.use(authMiddleware);
router.post('/artists/:artistId/follow', publicController.followArtist);
router.delete('/artists/:artistId/follow', publicController.unfollowArtist);
router.post('/tracks/:trackId/like', publicController.likeTrack);
router.delete('/tracks/:trackId/like', publicController.unlikeTrack);
router.post('/tracks/:trackId/comments', publicController.addComment);
router.post('/reports', publicController.submitReport);

export default router;
