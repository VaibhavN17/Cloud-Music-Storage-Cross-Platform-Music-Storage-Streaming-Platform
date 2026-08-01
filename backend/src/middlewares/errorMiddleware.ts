import { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';
import { ApiError, ErrorCode } from '../utils/ApiError';
import { sendError } from '../utils/response';
import { logger } from '../config/logger';

export function errorMiddleware(
  err: Error,
  req: Request,
  res: Response,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  _next: NextFunction
): void {
  const requestId = (req.headers['x-request-id'] as string) || 'req_unknown';

  if (err instanceof ApiError) {
    logger.warn({
      requestId,
      statusCode: err.statusCode,
      errorCode: err.errorCode,
      message: err.message,
      path: req.originalUrl,
      method: req.method,
    }, `API Error: ${err.message}`);

    sendError(res, err.message, err.statusCode, err.errorCode, err.errors);
    return;
  }

  if (err instanceof ZodError || err.name === 'ZodError') {
    const zodErr = err as ZodError;
    const formatted = zodErr.errors ? zodErr.errors.map((e) => ({
      field: e.path.join('.').replace(/^body\.|^query\.|^params\./, ''),
      message: e.message,
    })) : zodErr;

    sendError(res, 'Validation failed', 400, ErrorCode.VALIDATION_FAILED, formatted);
    return;
  }

  logger.error({
    requestId,
    err,
    path: req.originalUrl,
    method: req.method,
  }, `Unhandled Server Error: ${err.message}`);

  sendError(
    res,
    process.env.NODE_ENV === 'production' ? 'An unexpected internal server error occurred' : err.message,
    500,
    ErrorCode.INTERNAL_ERROR
  );
}
