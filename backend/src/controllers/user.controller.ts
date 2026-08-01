import { Request, Response, NextFunction } from 'express';
import { userService, UserService } from '../services/user.service';
import { sendSuccess } from '../utils/response';

export class UserController {
  constructor(private service: UserService = userService) {}

  getProfile = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const user = await this.service.getProfile(userId);
      sendSuccess(res, user, 'Profile retrieved successfully');
    } catch (error) {
      next(error);
    }
  };

  updateProfile = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const updated = await this.service.updateProfile(userId, req.body);
      sendSuccess(res, updated, 'Profile updated successfully');
    } catch (error) {
      next(error);
    }
  };

  toggleArtistMode = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { enable } = req.body;
      const updated = await this.service.toggleArtistMode(userId, enable);
      sendSuccess(res, updated, `Artist mode ${enable ? 'enabled' : 'disabled'}`);
    } catch (error) {
      next(error);
    }
  };

  getStorageQuota = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const stats = await this.service.getStorageQuota(userId);
      sendSuccess(res, stats, 'Storage quota stats retrieved');
    } catch (error) {
      next(error);
    }
  };

  recalculateStorage = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const newTotal = await this.service.recalculateStorage(userId);
      sendSuccess(res, { usedBytes: newTotal }, 'Storage usage recalculated');
    } catch (error) {
      next(error);
    }
  };
}

export const userController = new UserController();
