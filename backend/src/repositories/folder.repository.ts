import { Folder, Prisma } from '@prisma/client';
import { prisma } from '../config/database';

export class FolderRepository {
  async findById(id: string, ownerId: string): Promise<Folder | null> {
    return prisma.folder.findFirst({
      where: { id, ownerId, deletedAt: null },
      include: {
        children: { where: { deletedAt: null } },
        tracks: { where: { deletedAt: null } },
      },
    });
  }

  async listUserFolders(ownerId: string, parentId?: string | null): Promise<Folder[]> {
    return prisma.folder.findMany({
      where: {
        ownerId,
        parentId: parentId ?? null,
        deletedAt: null,
      },
      orderBy: { name: 'asc' },
    });
  }

  async create(data: Prisma.FolderCreateInput): Promise<Folder> {
    return prisma.folder.create({ data });
  }

  async update(id: string, ownerId: string, data: Prisma.FolderUpdateInput): Promise<Folder> {
    return prisma.folder.update({
      where: { id, ownerId },
      data,
    });
  }

  async softDelete(id: string, ownerId: string): Promise<Folder> {
    return prisma.folder.update({
      where: { id, ownerId },
      data: { deletedAt: new Date() },
    });
  }

  async restore(id: string, ownerId: string): Promise<Folder> {
    return prisma.folder.update({
      where: { id, ownerId },
      data: { deletedAt: null },
    });
  }
}

export const folderRepository = new FolderRepository();
