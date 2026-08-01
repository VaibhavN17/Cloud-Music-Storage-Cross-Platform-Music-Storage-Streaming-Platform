import { Router } from 'express';
import { streamingController } from '../controllers/streaming.controller';
import { authMiddleware } from '../middlewares/authMiddleware';

const router = Router();

router.use(authMiddleware);

router.get('/url/:trackId', streamingController.getStreamUrl);
router.post('/heartbeat', streamingController.recordHeartbeat);

export default router;
