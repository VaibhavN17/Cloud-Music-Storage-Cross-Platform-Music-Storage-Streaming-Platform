import Redis from 'ioredis';
import { env } from './env';
import { logger } from './logger';

export const redisClient = new Redis({
  host: env.REDIS_HOST,
  port: env.REDIS_PORT,
  password: env.REDIS_PASSWORD || undefined,
  lazyConnect: true,
  maxRetriesPerRequest: null, // Required by BullMQ
  retryStrategy(times) {
    const delay = Math.min(times * 100, 3000);
    return delay;
  },
});

redisClient.on('connect', () => {
  logger.info('Redis connection established');
});

redisClient.on('error', (err) => {
  logger.error({ err }, 'Redis connection error');
});

export async function checkRedisConnection(): Promise<boolean> {
  try {
    const ping = await redisClient.ping();
    return ping === 'PONG';
  } catch (error) {
    logger.error({ error }, 'Redis health check failed');
    return false;
  }
}
