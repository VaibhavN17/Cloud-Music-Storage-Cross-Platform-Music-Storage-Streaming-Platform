import { Router } from 'express';
import { folderController } from '../controllers/folder.controller';
import { authMiddleware } from '../middlewares/authMiddleware';
import { validate } from '../middlewares/validate';
import { createFolderSchema, updateFolderSchema } from '../validators/folder.validator';

const router = Router();

router.use(authMiddleware);

router.get('/', folderController.listFolders);
router.post('/', validate(createFolderSchema), folderController.createFolder);
router.get('/:id', folderController.getFolder);
router.patch('/:id', validate(updateFolderSchema), folderController.updateFolder);
router.delete('/:id', folderController.deleteFolder);
router.post('/:id/restore', folderController.restoreFolder);

export default router;
