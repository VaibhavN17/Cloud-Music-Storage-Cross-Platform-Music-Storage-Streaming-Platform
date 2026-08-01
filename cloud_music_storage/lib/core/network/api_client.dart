/// Dio API client factory.
///
/// Creates a configured Dio instance with all interceptors:
/// - Auth (JWT attach)
/// - Token Refresh (auto-refresh on 401)
/// - Error Mapping (typed exceptions)
/// - Retry (exponential backoff)
/// - Logging (debug mode)
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';
import 'retry_interceptor.dart';
import 'token_refresh_interceptor.dart';

/// Provider for the main Dio API client.
final apiClientProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiClient.create(
    secureStorage: secureStorage,
    onForceLogout: () {
      // This will be connected to auth state provider later.
      // For now, just clear tokens.
      secureStorage.clearAuth();
    },
  );
});

/// Factory for creating a fully-configured Dio instance.
class ApiClient {
  const ApiClient._();

  /// Creates the main API client with all interceptors.
  static Dio create({
    required SecureStorageService secureStorage,
    required void Function() onForceLogout,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: Duration(milliseconds: AppConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
        sendTimeout: Duration(milliseconds: AppConfig.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Separate Dio for token refresh to avoid interceptor loops.
    final tokenDio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: Duration(milliseconds: AppConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Order matters: auth first, then refresh, then retry, then error mapping.
    dio.interceptors.addAll([
      AuthInterceptor(secureStorage),
      TokenRefreshInterceptor(
        secureStorage: secureStorage,
        tokenDio: tokenDio,
        onForceLogout: onForceLogout,
      ),
      RetryInterceptor(dio: dio),
      ErrorInterceptor(),
      if (kDebugMode)
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          compact: true,
        ),
    ]);

    return dio;
  }
}
