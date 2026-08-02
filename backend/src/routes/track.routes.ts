import { Router } from 'express';
import { trackController } from '../controllers/track.controller';
import { uploadController } from '../controllers/upload.controller';
import { streamingController } from '../controllers/streaming.controller';
import { authMiddleware } from '../middlewares/authMiddleware';
import { validate } from '../middlewares/validate';
import { requestUploadUrlSchema, updateTrackSchema } from '../validators/track.validator';

const router = Router();

router.use(authMiddleware);

router.post('/upload-url', validate(requestUploadUrlSchema), uploadController.requestUploadUrl);
router.get('/', trackController.listTracks);
router.get('/:id', trackController.getTrack);
router.get('/:id/stream-url', streamingController.getStreamUrl);
router.patch('/:id', validate(updateTrackSchema), trackController.updateTrack);
router.delete('/:id', trackController.deleteTrack);
router.post('/:id/restore', trackController.restoreTrack);

export default router;
