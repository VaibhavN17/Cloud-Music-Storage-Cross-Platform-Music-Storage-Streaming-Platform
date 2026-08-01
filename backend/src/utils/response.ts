import { Response } from 'express';

export interface ApiResponseMeta {
  page?: number;
  limit?: number;
  total?: number;
  totalPages?: number;
  cursor?: string | null;
  [key: string]: unknown;
}

export interface ApiResponseEnvelope<T = unknown> {
  success: boolean;
  message: string;
  data: T | null;
  meta?: ApiResponseMeta;
  error?: {
    code: string;
    details?: unknown;
  };
  timestamp: string;
  requestId: string;
}

export function sendSuccess<T>(
  res: Response,
  data: T,
  message = 'Operation successful',
  statusCode = 200,
  meta?: ApiResponseMeta
): Response {
  const requestId = (res.getHeader('x-request-id') as string) || (res.req.headers['x-request-id'] as string) || 'req_unknown';

  const responseBody: ApiResponseEnvelope<T> = {
    success: true,
    message,
    data,
    meta,
    timestamp: new Date().toISOString(),
    requestId,
  };

  return res.status(statusCode).json(responseBody);
}

export function sendError(
  res: Response,
  message: string,
  statusCode = 500,
  errorCode = 'INTERNAL_ERROR',
  details?: unknown
): Response {
  const requestId = (res.getHeader('x-request-id') as string) || (res.req.headers['x-request-id'] as string) || 'req_unknown';

  const responseBody: ApiResponseEnvelope = {
    success: false,
    message,
    data: null,
    error: {
      code: errorCode,
      details,
    },
    timestamp: new Date().toISOString(),
    requestId,
  };

  return res.status(statusCode).json(responseBody);
}
