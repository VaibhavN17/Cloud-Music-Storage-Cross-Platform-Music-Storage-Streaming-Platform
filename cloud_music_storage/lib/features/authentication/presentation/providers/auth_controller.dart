/// Authentication controller & state management using Riverpod.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_router.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final Map<String, dynamic>? user;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    Map<String, dynamic>? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

/// Main AuthController provider.
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthState());

  final Ref _ref;

  AuthRepository get _authRepo => _ref.read(authRepositoryProvider);

  /// Check stored token and verify with backend (/me) on app startup.
  Future<bool> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authRepo.getCurrentUser();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      _ref.read(authStateProvider.notifier).state = true;
      return true;
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      );
      _ref.read(authStateProvider.notifier).state = false;
      return false;
    }
  }

  /// Login with email and password.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final data = await _authRepo.login(email: email, password: password);
      final user = data['user'] as Map<String, dynamic>?;
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      _ref.read(authStateProvider.notifier).state = true;
    } on ApiException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      rethrow;
    } catch (e) {
      const message = 'An unexpected login error occurred.';
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: message,
      );
      throw const AuthException(message: message);
    }
  }

  /// Register new user account.
  Future<void> signup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final data = await _authRepo.signup(
        email: email,
        password: password,
        displayName: displayName,
      );
      final user = data['user'] as Map<String, dynamic>?;
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      _ref.read(authStateProvider.notifier).state = true;
    } on ApiException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      rethrow;
    } catch (e) {
      const message = 'An unexpected signup error occurred.';
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: message,
      );
      throw const ApiException(message: message);
    }
  }

  /// Log out user session.
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    await _authRepo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
    _ref.read(authStateProvider.notifier).state = false;
  }

  /// Triggered by HTTP Interceptors on unrecoverable token failure.
  void forceLogout() {
    state = const AuthState(status: AuthStatus.unauthenticated);
    _ref.read(authStateProvider.notifier).state = false;
  }

  /// Send password reset request email.
  Future<void> forgotPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _authRepo.forgotPassword(email);
      state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: null);
    } catch (e) {
      final message = e is ApiException ? e.message : e.toString();
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: message,
      );
      rethrow;
    }
  }
}
