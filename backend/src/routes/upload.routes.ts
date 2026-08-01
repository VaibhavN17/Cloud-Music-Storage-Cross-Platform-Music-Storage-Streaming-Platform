import { Router } from 'express';
import { uploadController } from '../controllers/upload.controller';
import { authMiddleware } from '../middlewares/authMiddleware';
import { validate } from '../middlewares/validate';
import { requestUploadUrlSchema, confirmUploadSchema } from '../validators/track.validator';

const router = Router();

router.use(authMiddleware);

router.post('/presigned-url', validate(requestUploadUrlSchema), uploadController.requestUploadUrl);
router.post('/confirm', validate(confirmUploadSchema), uploadController.confirmUpload);

export default router;
