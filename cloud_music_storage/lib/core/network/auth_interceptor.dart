/// Auth interceptor — attaches JWT to every request.
///
/// Reads the access token from secure storage and adds it
/// as an `Authorization: Bearer` header.
library;

import 'package:dio/dio.dart';

import '../storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage);

  final SecureStorageService _secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for auth endpoints that don't need it.
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  /// Endpoints that should not include an auth header.
  bool _isPublicEndpoint(String path) {
    const publicPaths = [
      '/auth/signup',
      '/auth/login',
      '/auth/oauth/google',
      '/auth/oauth/apple',
      '/auth/forgot-password',
      '/auth/verify-email',
    ];
    return publicPaths.any((p) => path.contains(p));
  }
}
