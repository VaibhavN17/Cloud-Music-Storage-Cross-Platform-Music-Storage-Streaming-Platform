import { Router } from 'express';
import { authController } from '../controllers/auth.controller';
import { validate } from '../middlewares/validate';
import { authMiddleware } from '../middlewares/authMiddleware';
import {
  signupSchema,
  loginSchema,
  refreshTokenSchema,
  forgotPasswordSchema,
  resetPasswordSchema,
  oauthSchema,
} from '../validators/auth.validator';

const router = Router();

router.post('/signup', validate(signupSchema), authController.signup);
router.post('/login', validate(loginSchema), authController.login);
router.post('/refresh', validate(refreshTokenSchema), authController.refreshToken);
router.post('/logout', validate(refreshTokenSchema), authController.logout);
router.post('/logout-all', authMiddleware, authController.logoutAll);
router.post('/forgot-password', validate(forgotPasswordSchema), authController.forgotPassword);
router.post('/reset-password', validate(resetPasswordSchema), authController.resetPassword);
router.post('/oauth/google', validate(oauthSchema), authController.googleOAuth);
router.post('/oauth/apple', validate(oauthSchema), authController.appleOAuth);

export default router;
