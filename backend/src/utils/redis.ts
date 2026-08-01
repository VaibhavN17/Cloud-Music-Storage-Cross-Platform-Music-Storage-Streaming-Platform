import { Redis } from 'ioredis';
import { env } from '../config/env.js';
import { logger } from './logger.js';

export const redis = new Redis({
  host: env.REDIS_HOST,
  port: env.REDIS_PORT,
  password: env.REDIS_PASSWORD || undefined,
  maxRetriesPerRequest: null,
  enableReadyCheck: false,
});

redis.on('connect', () => logger.info('✅ Redis connected successfully'));
redis.on('error', (err) => logger.error({ err }, '❌ Redis connection error'));
