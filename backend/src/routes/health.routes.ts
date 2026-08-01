import { Router, Request, Response } from 'express';
import { checkDatabaseConnection } from '../config/database';
import { checkRedisConnection } from '../config/redis';
import { checkR2Connection } from '../config/r2';
import { sendSuccess, sendError } from '../utils/response';

const router = Router();

router.get('/', (_req: Request, res: Response) => {
  sendSuccess(
    res,
    {
      name: 'Cloud Music Storage API',
      version: 'v1',
      status: 'online',
      documentation: '/api-docs',
      health: '/health',
      readiness: '/ready',
      apiPrefix: '/api/v1',
    },
    'Welcome to Cloud Music Storage Enterprise API'
  );
});

router.get('/health', async (_req: Request, res: Response) => {
  sendSuccess(res, { status: 'pass', uptime: process.uptime() }, 'Service is healthy');
});

router.get('/live', (_req: Request, res: Response) => {
  sendSuccess(res, { status: 'alive' }, 'Service is live');
});

router.get('/ready', async (_req: Request, res: Response) => {
  const [dbOk, redisOk, r2Ok] = await Promise.all([
    checkDatabaseConnection(),
    checkRedisConnection(),
    checkR2Connection(),
  ]);

  const allReady = dbOk && redisOk && r2Ok;
  const statusDetails = {
    database: dbOk ? 'UP' : 'DOWN',
    redis: redisOk ? 'UP' : 'DOWN',
    storageR2: r2Ok ? 'UP' : 'DOWN',
  };

  if (allReady) {
    sendSuccess(res, { status: 'READY', checks: statusDetails }, 'All dependencies are ready');
  } else {
    sendError(res, 'Service not ready', 503, 'SERVICE_UNAVAILABLE', statusDetails);
  }
});

export default router;
