/// Typed API exceptions.
///
/// Maps backend error codes (Backend Schema §6) to Dart exceptions.
/// Every exception carries a user-facing message and optional error code.
library;

/// Base exception for all API errors.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  final String message;
  final int? statusCode;
  final String? errorCode;

  @override
  String toString() => 'ApiException($statusCode, $errorCode): $message';
}

/// 401 — Invalid credentials or token expired.
class AuthException extends ApiException {
  const AuthException({
    super.message = 'Authentication failed',
    super.statusCode = 401,
    super.errorCode,
  });
}

/// Token expired, needs refresh.
class TokenExpiredException extends AuthException {
  const TokenExpiredException()
      : super(
          message: 'Session expired. Refreshing...',
          errorCode: 'AUTH_TOKEN_EXPIRED',
        );
}

/// Refresh token invalid — must re-login.
class RefreshTokenInvalidException extends AuthException {
  const RefreshTokenInvalidException()
      : super(
          message: 'Session expired. Please log in again.',
          errorCode: 'AUTH_REFRESH_INVALID',
        );
}

/// 403 — Authenticated but forbidden.
class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'You don\'t have permission to perform this action',
    super.statusCode = 403,
    super.errorCode = 'FORBIDDEN',
  });
}

/// 404 — Resource not found.
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'The requested resource was not found',
    super.statusCode = 404,
    super.errorCode = 'NOT_FOUND',
  });
}

/// 422 — Validation error.
class ValidationException extends ApiException {
  const ValidationException({
    super.message = 'Invalid input. Please check your data.',
    super.statusCode = 422,
    super.errorCode = 'VALIDATION_ERROR',
    this.errors = const {},
  });

  /// Field-level validation errors.
  final Map<String, String> errors;
}

/// 429 — Rate limited.
class RateLimitException extends ApiException {
  const RateLimitException({
    super.message = 'Too many requests. Please wait and try again.',
    super.statusCode = 429,
    super.errorCode = 'RATE_LIMITED',
    this.retryAfterSeconds,
  });

  final int? retryAfterSeconds;
}

/// 413 — Storage quota exceeded.
class QuotaExceededException extends ApiException {
  const QuotaExceededException({
    super.message = 'Storage quota exceeded. Upgrade your plan to continue.',
    super.statusCode = 413,
    super.errorCode = 'QUOTA_EXCEEDED',
  });
}

/// Upload failed.
class UploadException extends ApiException {
  const UploadException({
    super.message = 'Upload failed. Please try again.',
    super.statusCode,
    super.errorCode = 'UPLOAD_FAILED',
  });
}

/// 5xx — Server error.
class ServerException extends ApiException {
  const ServerException({
    super.message = 'Something went wrong. Please try again later.',
    super.statusCode = 500,
    super.errorCode = 'INTERNAL_ERROR',
  });
}

/// No internet connection.
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'No internet connection. Please check your network.',
    super.statusCode,
    super.errorCode = 'NETWORK_ERROR',
  });
}

/// Request timeout.
class TimeoutException extends ApiException {
  const TimeoutException({
    super.message = 'Request timed out. Please try again.',
    super.statusCode,
    super.errorCode = 'TIMEOUT',
  });
}

/// Service under maintenance.
class MaintenanceException extends ApiException {
  const MaintenanceException({
    super.message = 'Service is under maintenance. Please try again later.',
    super.statusCode = 503,
    super.errorCode = 'MAINTENANCE',
  });
}
