/// Retry interceptor with exponential backoff.
///
/// Retries failed requests on transient errors (network, timeout, 5xx).
library;

import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.baseDelayMs = 1000,
  });

  final Dio dio;
  final int maxRetries;
  final int baseDelayMs;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;
    if (retryCount >= maxRetries) {
      return handler.next(err);
    }

    // Exponential backoff with jitter.
    final delay = _calculateDelay(retryCount);
    await Future<void>.delayed(Duration(milliseconds: delay));

    // Increment retry count.
    err.requestOptions.extra['retryCount'] = retryCount + 1;

    try {
      final response = await dio.fetch(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    // Retry on network errors, timeouts, and 5xx server errors.
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    final statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode >= 500 && statusCode != 501) {
      return true;
    }

    return false;
  }

  int _calculateDelay(int retryCount) {
    final exponentialDelay = baseDelayMs * pow(2, retryCount).toInt();
    final jitter = Random().nextInt(500);
    return exponentialDelay + jitter;
  }
}
