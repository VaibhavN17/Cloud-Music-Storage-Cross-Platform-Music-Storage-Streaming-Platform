import { Router } from 'express';
import { collaborationController } from '../controllers/collaboration.controller';
import { authMiddleware } from '../middlewares/authMiddleware';
import { validate } from '../middlewares/validate';
import {
  syncContactsSchema,
  inviteCollaborationSchema,
  respondInviteSchema,
} from '../validators/collaboration.validator';

const router = Router();

router.use(authMiddleware);

router.post('/contacts/sync', validate(syncContactsSchema), collaborationController.syncContacts);
router.post('/invite', validate(inviteCollaborationSchema), collaborationController.sendInvite);
router.get('/session', collaborationController.getInvitesAndSessions);
router.post('/invites/:id/respond', validate(respondInviteSchema), collaborationController.respondInvite);
router.get('/session/:id/tracks', collaborationController.getCombinedTracks);
router.post('/session/:id/play-random', collaborationController.playRandomSong);
router.post('/session/:id/end', collaborationController.endSession);

export default router;
