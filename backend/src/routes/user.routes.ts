import { Router } from 'express';
import { userController } from '../controllers/user.controller';
import { authMiddleware } from '../middlewares/authMiddleware';
import { validate } from '../middlewares/validate';
import { updateProfileSchema, toggleArtistModeSchema } from '../validators/user.validator';

const router = Router();

router.use(authMiddleware);

router.get('/me', userController.getProfile);
router.patch('/me', validate(updateProfileSchema), userController.updateProfile);
router.post('/me/artist-mode', validate(toggleArtistModeSchema), userController.toggleArtistMode);
router.get('/me/storage', userController.getStorageQuota);
router.post('/me/storage/recalculate', userController.recalculateStorage);

export default router;
