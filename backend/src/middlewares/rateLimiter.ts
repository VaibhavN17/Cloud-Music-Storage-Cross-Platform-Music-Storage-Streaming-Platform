import rateLimit from 'express-rate-limit';
import { ApiError } from '../utils/ApiError';

export const globalRateLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 100, // 100 requests per minute
  standardHeaders: true,
  legacyHeaders: false,
  handler: (_req, _res, next) => {
    next(ApiError.rateLimited('Too many requests, please try again later'));
  },
});

export const authRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 15, // 15 auth attempts per 15 minutes
  standardHeaders: true,
  legacyHeaders: false,
  handler: (_req, _res, next) => {
    next(ApiError.rateLimited('Too many authentication attempts, please try again later'));
  },
});
