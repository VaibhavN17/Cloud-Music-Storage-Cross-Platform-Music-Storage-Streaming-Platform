import { Request, Response, NextFunction } from 'express';
import { adminService, AdminService } from '../services/admin.service';
import { sendSuccess } from '../utils/response';

export class AdminController {
  constructor(private service: AdminService = adminService) {}

  getStats = async (_req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const stats = await this.service.getSystemStats();
      sendSuccess(res, stats, 'Admin system stats retrieved');
    } catch (error) {
      next(error);
    }
  };

  listUsers = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const page = req.query.page ? Number(req.query.page) : 1;
      const limit = req.query.limit ? Number(req.query.limit) : 20;
      const search = req.query.search as string;
      const data = await this.service.listUsers(page, limit, search);
      sendSuccess(res, data.users, 'Users retrieved', 200, { page, limit, total: data.total });
    } catch (error) {
      next(error);
    }
  };

  suspendUser = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { userId } = req.params;
      const result = await this.service.setUserSuspension(userId, true);
      sendSuccess(res, result, 'User suspended successfully');
    } catch (error) {
      next(error);
    }
  };

  unsuspendUser = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { userId } = req.params;
      const result = await this.service.setUserSuspension(userId, false);
      sendSuccess(res, result, 'User unsuspended successfully');
    } catch (error) {
      next(error);
    }
  };

  listReports = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const status = req.query.status as any;
      const page = req.query.page ? Number(req.query.page) : 1;
      const limit = req.query.limit ? Number(req.query.limit) : 20;
      const data = await this.service.listReports(status, page, limit);
      sendSuccess(res, data.reports, 'Reports queue retrieved', 200, { page, limit, total: data.total });
    } catch (error) {
      next(error);
    }
  };

  resolveReport = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const adminId = req.user!.id;
      const { reportId } = req.params;
      const { status, resolutionNote } = req.body;
      const result = await this.service.resolveReport(reportId, adminId, status, resolutionNote);
      sendSuccess(res, result, 'Report resolution saved');
    } catch (error) {
      next(error);
    }
  };
}

export const adminController = new AdminController();
