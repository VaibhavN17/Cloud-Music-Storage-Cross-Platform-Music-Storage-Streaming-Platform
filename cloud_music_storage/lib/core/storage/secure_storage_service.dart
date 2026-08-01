/// Secure storage service for sensitive data.
///
/// Stores JWT tokens, refresh tokens, and other sensitive credentials
/// using platform-specific secure storage.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

/// Provider for the secure storage singleton.
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Wraps [FlutterSecureStorage] with typed accessors for auth tokens.
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // ── Tokens ──
  Future<String?> getAccessToken() => _storage.read(key: StorageKeys.accessToken);

  Future<void> setAccessToken(String token) =>
      _storage.write(key: StorageKeys.accessToken, value: token);

  Future<String?> getRefreshToken() =>
      _storage.read(key: StorageKeys.refreshToken);

  Future<void> setRefreshToken(String token) =>
      _storage.write(key: StorageKeys.refreshToken, value: token);

  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      setAccessToken(accessToken),
      setRefreshToken(refreshToken),
    ]);
  }

  // ── User ──
  Future<String?> getUserId() => _storage.read(key: StorageKeys.userId);

  Future<void> setUserId(String id) =>
      _storage.write(key: StorageKeys.userId, value: id);

  // ── Generic ──
  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> delete(String key) => _storage.delete(key: key);

  /// Clear all auth data (logout).
  Future<void> clearAuth() async {
    await Future.wait([
      _storage.delete(key: StorageKeys.accessToken),
      _storage.delete(key: StorageKeys.refreshToken),
      _storage.delete(key: StorageKeys.userId),
    ]);
  }

  /// Clear everything.
  Future<void> clearAll() => _storage.deleteAll();
}
