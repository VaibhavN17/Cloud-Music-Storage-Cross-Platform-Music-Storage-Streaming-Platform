export enum ErrorCode {
  AUTH_INVALID = 'AUTH_INVALID',
  UNAUTHORIZED = 'UNAUTHORIZED',
  FORBIDDEN = 'FORBIDDEN',
  TRACK_NOT_FOUND = 'TRACK_NOT_FOUND',
  USER_NOT_FOUND = 'USER_NOT_FOUND',
  FOLDER_NOT_FOUND = 'FOLDER_NOT_FOUND',
  PLAYLIST_NOT_FOUND = 'PLAYLIST_NOT_FOUND',
  QUOTA_EXCEEDED = 'QUOTA_EXCEEDED',
  RATE_LIMITED = 'RATE_LIMITED',
  VALIDATION_FAILED = 'VALIDATION_FAILED',
  CONFLICT = 'CONFLICT',
  FILE_INVALID = 'FILE_INVALID',
  INTERNAL_ERROR = 'INTERNAL_ERROR',
}

export class ApiError extends Error {
  public readonly statusCode: number;
  public readonly errorCode: ErrorCode;
  public readonly errors?: Record<string, unknown> | Array<unknown>;

  constructor(
    statusCode: number,
    message: string,
    errorCode: ErrorCode = ErrorCode.INTERNAL_ERROR,
    errors?: Record<string, unknown> | Array<unknown>
  ) {
    super(message);
    this.statusCode = statusCode;
    this.errorCode = errorCode;
    this.errors = errors;
    Object.setPrototypeOf(this, new.target.prototype);
  }

  static badRequest(message: string, errorCode: ErrorCode = ErrorCode.VALIDATION_FAILED, errors?: Record<string, unknown> | Array<unknown>) {
    return new ApiError(400, message, errorCode, errors);
  }

  static unauthorized(message = 'Unauthorized access', errorCode: ErrorCode = ErrorCode.UNAUTHORIZED) {
    return new ApiError(401, message, errorCode);
  }

  static forbidden(message = 'Access forbidden', errorCode: ErrorCode = ErrorCode.FORBIDDEN) {
    return new ApiError(403, message, errorCode);
  }

  static notFound(message = 'Resource not found', errorCode: ErrorCode = ErrorCode.TRACK_NOT_FOUND) {
    return new ApiError(404, message, errorCode);
  }

  static conflict(message: string, errorCode: ErrorCode = ErrorCode.CONFLICT) {
    return new ApiError(409, message, errorCode);
  }

  static quotaExceeded(message = 'Storage quota exceeded', errorCode: ErrorCode = ErrorCode.QUOTA_EXCEEDED) {
    return new ApiError(413, message, errorCode);
  }

  static rateLimited(message = 'Too many requests', errorCode: ErrorCode = ErrorCode.RATE_LIMITED) {
    return new ApiError(429, message, errorCode);
  }

  static internal(message = 'Internal server error', errorCode: ErrorCode = ErrorCode.INTERNAL_ERROR) {
    return new ApiError(500, message, errorCode);
  }
}
