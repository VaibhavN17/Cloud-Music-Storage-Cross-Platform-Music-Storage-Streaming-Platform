import { Router } from 'express';
import { adminController } from '../controllers/admin.controller';
import { authMiddleware, rbacMiddleware } from '../middlewares/authMiddleware';

const router = Router();

router.use(authMiddleware);
router.use(rbacMiddleware(['ADMIN', 'MODERATOR']));

router.get('/stats', adminController.getStats);
router.get('/users', adminController.listUsers);
router.post('/users/:userId/suspend', adminController.suspendUser);
router.post('/users/:userId/unsuspend', adminController.unsuspendUser);
router.get('/reports', adminController.listReports);
router.post('/reports/:reportId/resolve', adminController.resolveReport);

export default router;
