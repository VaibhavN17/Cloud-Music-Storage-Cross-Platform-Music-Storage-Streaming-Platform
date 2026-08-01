import { Folder } from '@prisma/client';
import { folderRepository, FolderRepository } from '../repositories/folder.repository';
import { ApiError } from '../utils/ApiError';

export class FolderService {
  constructor(private repo: FolderRepository = folderRepository) {}

  async listFolders(ownerId: string, parentId?: string | null): Promise<Folder[]> {
    return this.repo.listUserFolders(ownerId, parentId);
  }

  async getFolderById(id: string, ownerId: string): Promise<Folder> {
    const folder = await this.repo.findById(id, ownerId);
    if (!folder) {
      throw ApiError.notFound('Folder not found');
    }
    return folder;
  }

  async createFolder(ownerId: string, name: string, parentId?: string | null): Promise<Folder> {
    if (parentId) {
      const parent = await this.repo.findById(parentId, ownerId);
      if (!parent) {
        throw ApiError.notFound('Parent folder not found');
      }
    }

    return this.repo.create({
      name,
      owner: { connect: { id: ownerId } },
      parent: parentId ? { connect: { id: parentId } } : undefined,
    });
  }

  async renameFolder(id: string, ownerId: string, newName: string): Promise<Folder> {
    await this.getFolderById(id, ownerId);
    return this.repo.update(id, ownerId, { name: newName });
  }

  async moveFolder(id: string, ownerId: string, newParentId: string | null): Promise<Folder> {
    await this.getFolderById(id, ownerId);

    if (newParentId) {
      if (newParentId === id) {
        throw ApiError.badRequest('Cannot move folder into itself');
      }
      const parent = await this.repo.findById(newParentId, ownerId);
      if (!parent) {
        throw ApiError.notFound('Target parent folder not found');
      }
    }

    return this.repo.update(id, ownerId, {
      parent: newParentId ? { connect: { id: newParentId } } : { disconnect: true },
    });
  }

  async softDeleteFolder(id: string, ownerId: string): Promise<Folder> {
    await this.getFolderById(id, ownerId);
    return this.repo.softDelete(id, ownerId);
  }

  async restoreFolder(id: string, ownerId: string): Promise<Folder> {
    return this.repo.restore(id, ownerId);
  }
}

export const folderService = new FolderService();
