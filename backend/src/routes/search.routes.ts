import { Router } from 'express';
import { searchController } from '../controllers/search.controller';
import { authMiddleware } from '../middlewares/authMiddleware';

const router = Router();

router.use(authMiddleware);

router.get('/', searchController.search);

export default router;
