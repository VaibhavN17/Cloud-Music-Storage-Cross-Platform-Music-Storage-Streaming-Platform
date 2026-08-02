/// Authentication repository.
///
/// Handles API calls for login, signup, and logout, and manages user auth tokens.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';

/// Provider for [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.watch(apiClientProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

class AuthRepository {
  const AuthRepository({
    required Dio dio,
    required SecureStorageService secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage;

  final Dio _dio;
  final SecureStorageService _secureStorage;

  /// Authenticate user with email and password.
  ///
  /// Saves returned access token, refresh token, and user ID to secure storage.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final responseBody = response.data;
      if (responseBody == null || responseBody['data'] == null) {
        throw const AuthException(message: 'Invalid response from server');
      }

      final data = responseBody['data'] as Map<String, dynamic>;
      final tokens = data['tokens'] as Map<String, dynamic>?;
      final user = data['user'] as Map<String, dynamic>?;

      if (tokens != null) {
        final accessToken = tokens['accessToken'] as String?;
        final refreshToken = tokens['refreshToken'] as String?;
        if (accessToken != null && refreshToken != null) {
          await _secureStorage.setTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }
      }

      if (user != null) {
        final userId = user['id'] as String?;
        if (userId != null) {
          await _secureStorage.setUserId(userId);
        }
      }

      return data;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw AuthException(
        message: e.response?.data?['message']?.toString() ?? 'Login failed',
      );
    }
  }

  /// Register a new user account.
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.signup,
        data: {
          'email': email,
          'password': password,
          'displayName': displayName,
        },
      );

      final responseBody = response.data;
      if (responseBody == null || responseBody['data'] == null) {
        throw const ApiException(message: 'Invalid response from server');
      }

      final data = responseBody['data'] as Map<String, dynamic>;
      final tokens = data['tokens'] as Map<String, dynamic>?;
      final user = data['user'] as Map<String, dynamic>?;

      if (tokens != null) {
        final accessToken = tokens['accessToken'] as String?;
        final refreshToken = tokens['refreshToken'] as String?;
        if (accessToken != null && refreshToken != null) {
          await _secureStorage.setTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }
      }

      if (user != null) {
        final userId = user['id'] as String?;
        if (userId != null) {
          await _secureStorage.setUserId(userId);
        }
      }

      return data;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(
        message: e.response?.data?['message']?.toString() ?? 'Signup failed',
      );
    }
  }

  /// Fetch currently authenticated user profile (/me).
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.me);
      final responseBody = response.data;
      if (responseBody == null || responseBody['data'] == null) {
        throw const AuthException(message: 'Failed to retrieve user profile');
      }
      return responseBody['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw AuthException(
        message: e.response?.data?['message']?.toString() ?? 'Failed to retrieve user',
      );
    }
  }

  /// Manually refresh auth tokens.
  Future<void> refreshToken() async {
    final savedRefresh = await _secureStorage.getRefreshToken();
    if (savedRefresh == null || savedRefresh.isEmpty) {
      throw const RefreshTokenInvalidException();
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': savedRefresh},
      );

      final responseBody = response.data;
      final data = responseBody?['data'] is Map<String, dynamic>
          ? responseBody!['data'] as Map<String, dynamic>
          : responseBody;

      if (data != null) {
        final accessToken = data['accessToken'] as String?;
        final refreshToken = data['refreshToken'] as String?;
        if (accessToken != null && refreshToken != null) {
          await _secureStorage.setTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }
      }
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw const RefreshTokenInvalidException();
    }
  }

  /// Log out current user session.
  Future<void> logout() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken != null) {
        await _dio.post<void>(
          ApiEndpoints.logout,
          data: {'refreshToken': refreshToken},
        );
      }
    } catch (_) {
      // Ignore network errors during logout and clear storage anyway
    } finally {
      await _secureStorage.clearAuth();
    }
  }
}
