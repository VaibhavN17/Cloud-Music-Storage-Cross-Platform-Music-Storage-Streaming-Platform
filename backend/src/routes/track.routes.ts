import { Router } from 'express';
import { trackController } from '../controllers/track.controller';
import { authMiddleware } from '../middlewares/authMiddleware';
import { validate } from '../middlewares/validate';
import { updateTrackSchema } from '../validators/track.validator';

const router = Router();

router.use(authMiddleware);

router.get('/', trackController.listTracks);
router.get('/:id', trackController.getTrack);
router.patch('/:id', validate(updateTrackSchema), trackController.updateTrack);
router.delete('/:id', trackController.deleteTrack);
router.post('/:id/restore', trackController.restoreTrack);

export default router;
