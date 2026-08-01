import { Request, Response, NextFunction } from 'express';
import { searchService, SearchService } from '../services/search.service';
import { sendSuccess } from '../utils/response';

export class SearchController {
  constructor(private service: SearchService = searchService) {}

  search = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { q, type, page, limit } = req.query;

      if (!q || typeof q !== 'string') {
        sendSuccess(res, { tracks: [], playlists: [], folders: [] }, 'Empty search query');
        return;
      }

      const results = await this.service.searchLibrary(userId, q, {
        type: (type as 'all' | 'tracks' | 'playlists' | 'folders') || 'all',
        page: page ? Number(page) : 1,
        limit: limit ? Number(limit) : 20,
      });

      sendSuccess(res, results, 'Search completed successfully');
    } catch (error) {
      next(error);
    }
  };
}

export const searchController = new SearchController();
