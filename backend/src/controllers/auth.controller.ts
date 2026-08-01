import { Request, Response, NextFunction } from 'express';
import { authService, AuthService } from '../services/auth.service';
import { sendSuccess } from '../utils/response';

export class AuthController {
  constructor(private service: AuthService = authService) {}

  signup = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { email, password, displayName } = req.body;
      const result = await this.service.signup(email, password, displayName);
      sendSuccess(res, result, 'User account registered successfully', 201);
    } catch (error) {
      next(error);
    }
  };

  login = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { email, password } = req.body;
      const result = await this.service.login(email, password);
      sendSuccess(res, result, 'Authentication successful', 200);
    } catch (error) {
      next(error);
    }
  };

  refreshToken = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { refreshToken } = req.body;
      const tokens = await this.service.refreshToken(refreshToken);
      sendSuccess(res, tokens, 'Token refreshed successfully', 200);
    } catch (error) {
      next(error);
    }
  };

  logout = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { refreshToken } = req.body;
      await this.service.logout(refreshToken);
      sendSuccess(res, null, 'Logged out successfully', 200);
    } catch (error) {
      next(error);
    }
  };

  logoutAll = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      if (!req.user) return;
      await this.service.logoutAll(req.user.id);
      sendSuccess(res, null, 'Logged out from all sessions', 200);
    } catch (error) {
      next(error);
    }
  };

  googleOAuth = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { idToken } = req.body;
      const result = await this.service.googleOAuth(idToken);
      sendSuccess(res, result, 'Google login successful', 200);
    } catch (error) {
      next(error);
    }
  };

  appleOAuth = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { idToken } = req.body;
      const result = await this.service.appleOAuth(idToken);
      sendSuccess(res, result, 'Apple login successful', 200);
    } catch (error) {
      next(error);
    }
  };

  forgotPassword = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { email } = req.body;
      await this.service.forgotPassword(email);
      sendSuccess(res, null, 'If that email exists, a reset link has been sent');
    } catch (error) {
      next(error);
    }
  };

  resetPassword = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { token, newPassword } = req.body;
      await this.service.resetPassword(token, newPassword);
      sendSuccess(res, null, 'Password reset successful');
    } catch (error) {
      next(error);
    }
  };
}

export const authController = new AuthController();
