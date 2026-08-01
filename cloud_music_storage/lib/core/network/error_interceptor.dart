/// Error interceptor — maps API responses and network errors to typed exceptions.
library;

import 'package:dio/dio.dart';

import 'api_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapException(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
        message: exception.message,
      ),
    );
  }

  ApiException _mapException(DioException err) {
    // Network/timeout errors (no response).
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return const TimeoutException();
    }

    if (err.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }

    // Server responded — map by status code + error code.
    final response = err.response;
    if (response == null) {
      return const NetworkException();
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;
    final errorCode = data is Map ? data['errorCode'] as String? : null;
    final message = data is Map ? data['message'] as String? : null;

    switch (statusCode) {
      case 401:
        if (errorCode == 'AUTH_TOKEN_EXPIRED') {
          return const TokenExpiredException();
        }
        if (errorCode == 'AUTH_REFRESH_INVALID') {
          return const RefreshTokenInvalidException();
        }
        return AuthException(
          message: message ?? 'Authentication failed',
          errorCode: errorCode,
        );

      case 403:
        return ForbiddenException(
          message: message ?? 'Permission denied',
        );

      case 404:
        return NotFoundException(
          message: message ?? 'Resource not found',
        );

      case 413:
        return QuotaExceededException(
          message: message ?? 'Storage quota exceeded',
        );

      case 422:
        final fieldErrors = <String, String>{};
        if (data is Map && data['errors'] is Map) {
          (data['errors'] as Map).forEach((key, value) {
            fieldErrors[key.toString()] = value.toString();
          });
        }
        return ValidationException(
          message: message ?? 'Validation failed',
          errors: fieldErrors,
        );

      case 429:
        final retryAfter = response.headers.value('retry-after');
        return RateLimitException(
          message: message ?? 'Too many requests',
          retryAfterSeconds:
              retryAfter != null ? int.tryParse(retryAfter) : null,
        );

      case 503:
        return MaintenanceException(
          message: message ?? 'Service under maintenance',
        );

      default:
        if (statusCode >= 500) {
          return ServerException(
            message: message ?? 'Internal server error',
            statusCode: statusCode,
          );
        }
        return ApiException(
          message: message ?? 'An unexpected error occurred',
          statusCode: statusCode,
          errorCode: errorCode,
        );
    }
  }
}
