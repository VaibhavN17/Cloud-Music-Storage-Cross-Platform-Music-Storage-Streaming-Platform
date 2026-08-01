/// Token refresh interceptor.
///
/// On 401 with AUTH_TOKEN_EXPIRED, automatically refreshes the access token
/// using the refresh token and retries the original request.
/// If refresh fails, forces logout.
library;

import 'dart:async';

import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../storage/secure_storage_service.dart';

class TokenRefreshInterceptor extends QueuedInterceptor {
  TokenRefreshInterceptor({
    required SecureStorageService secureStorage,
    required Dio tokenDio,
    required this.onForceLogout,
  })  : _secureStorage = secureStorage,
        _tokenDio = tokenDio;

  final SecureStorageService _secureStorage;

  /// A separate Dio instance specifically for token refresh requests.
  /// This avoids interceptor loop since this Dio has no auth interceptor.
  final Dio _tokenDio;

  /// Called when refresh token is invalid and user must re-authenticate.
  final void Function() onForceLogout;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Check if the error is specifically a token expiry.
    final errorCode = err.response?.data?['errorCode'] as String?;
    if (errorCode != 'AUTH_TOKEN_EXPIRED') {
      return handler.next(err);
    }

    // Don't try to refresh if the failing request IS the refresh request.
    if (err.requestOptions.path.contains(ApiEndpoints.refreshToken)) {
      onForceLogout();
      return handler.reject(err);
    }

    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        onForceLogout();
        return handler.reject(err);
      }

      // Attempt token refresh.
      final response = await _tokenDio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['accessToken'] as String;
      final newRefreshToken = response.data['refreshToken'] as String;

      // Persist new tokens.
      await _secureStorage.setTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      // Retry the original request with the new access token.
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

      final retryResponse = await _tokenDio.fetch(retryOptions);
      return handler.resolve(retryResponse);
    } on DioException catch (_) {
      // Refresh failed — force logout.
      onForceLogout();
      return handler.reject(err);
    }
  }
}

/// Callback type for force logout. Using this instead of importing
/// dart:ui directly.
typedef VoidCallback = void Function();
