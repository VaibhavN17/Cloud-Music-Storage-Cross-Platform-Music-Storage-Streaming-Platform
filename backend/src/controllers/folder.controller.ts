import { Request, Response, NextFunction } from 'express';
import { folderService, FolderService } from '../services/folder.service';
import { sendSuccess } from '../utils/response';

export class FolderController {
  constructor(private service: FolderService = folderService) {}

  listFolders = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const ownerId = req.user!.id;
      const parentId = (req.query.parentId as string) || null;
      const folders = await this.service.listFolders(ownerId, parentId);
      sendSuccess(res, folders, 'Folders retrieved successfully');
    } catch (error) {
      next(error);
    }
  };

  getFolder = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const ownerId = req.user!.id;
      const folder = await this.service.getFolderById(req.params.id, ownerId);
      sendSuccess(res, folder, 'Folder retrieved');
    } catch (error) {
      next(error);
    }
  };

  createFolder = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const ownerId = req.user!.id;
      const { name, parentId } = req.body;
      const folder = await this.service.createFolder(ownerId, name, parentId);
      sendSuccess(res, folder, 'Folder created', 201);
    } catch (error) {
      next(error);
    }
  };

  updateFolder = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const ownerId = req.user!.id;
      const { name, parentId } = req.body;
      let folder;
      if (name) {
        folder = await this.service.renameFolder(req.params.id, ownerId, name);
      }
      if (parentId !== undefined) {
        folder = await this.service.moveFolder(req.params.id, ownerId, parentId);
      }
      sendSuccess(res, folder, 'Folder updated');
    } catch (error) {
      next(error);
    }
  };

  deleteFolder = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const ownerId = req.user!.id;
      const folder = await this.service.softDeleteFolder(req.params.id, ownerId);
      sendSuccess(res, folder, 'Folder moved to trash');
    } catch (error) {
      next(error);
    }
  };

  restoreFolder = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const ownerId = req.user!.id;
      const folder = await this.service.restoreFolder(req.params.id, ownerId);
      sendSuccess(res, folder, 'Folder restored');
    } catch (error) {
      next(error);
    }
  };
}

export const folderController = new FolderController();
