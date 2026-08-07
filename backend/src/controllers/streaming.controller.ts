import { Request, Response, NextFunction } from 'express';
import { streamingService, StreamingService } from '../services/streaming.service';
import { sendSuccess } from '../utils/response';

export class StreamingController {
  constructor(private service: StreamingService = streamingService) {}

  getStreamUrl = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      // Route is /:id/stream-url — param key is 'id', not 'trackId'.
      const trackId = req.params.id ?? req.params.trackId;
      const data = await this.service.getSignedStreamUrl(trackId, userId);
      sendSuccess(res, data, 'Signed streaming URL generated');
    } catch (error) {
      next(error);
    }
  };

  recordHeartbeat = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { trackId, positionSec, deviceInfo } = req.body;
      const result = await this.service.recordPlaybackHeartbeat(userId, trackId, positionSec, deviceInfo);
      sendSuccess(res, result, 'Playback heartbeat recorded');
    } catch (error) {
      next(error);
    }
  };
}

export const streamingController = new StreamingController();
