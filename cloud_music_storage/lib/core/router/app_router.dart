/// GoRouter configuration.
///
/// Defines all routes with auth guard, nested navigation,
/// and shell route for bottom nav / sidebar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/onboarding_screen.dart';
import '../../features/authentication/presentation/screens/otp_screen.dart';
import '../../features/authentication/presentation/screens/signup_screen.dart';
import '../../features/authentication/presentation/screens/splash_screen.dart';
import '../../features/downloads/presentation/screens/downloads_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/library/presentation/screens/library_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/upload/presentation/screens/upload_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../shared/widgets/adaptive_shell.dart';
import 'route_names.dart';

/// Provider for auth state — determines route redirects.
final authStateProvider = StateProvider<bool>((ref) => false);

/// Provider for onboarding completion state.
final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

/// Listenable notifier to trigger GoRouter redirects without destroying the router instance.
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<bool>(authStateProvider, (_, __) => notifyListeners());
    _ref.listen<bool>(onboardingCompleteProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

/// Main router provider.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: RoutePaths.splash,
    refreshListenable: notifier,

    // ── Auth Redirect ──
    redirect: (context, state) {
      final isAuthenticated = ref.read(authStateProvider);
      final onboardingComplete = ref.read(onboardingCompleteProvider);

      final location = state.matchedLocation;
      final loggingIn = location == RoutePaths.login ||
          location == RoutePaths.signup ||
          location == RoutePaths.forgotPassword ||
          location == RoutePaths.otp;
      final isSplash = location == RoutePaths.splash;
      final isOnboarding = location == RoutePaths.onboarding;

      // On splash, let it handle its own redirect.
      if (isSplash) return null;

      // Not authenticated — redirect to login (unless already on auth pages).
      if (!isAuthenticated) {
        if (!onboardingComplete && !isOnboarding && !loggingIn) {
          return RoutePaths.onboarding;
        }
        if (loggingIn || isOnboarding) return null;
        return RoutePaths.login;
      }

      // Authenticated — redirect away from auth pages to home dashboard.
      if (loggingIn || isOnboarding) {
        return RoutePaths.home;
      }

      return null;
    },

    // ── Routes ──
    routes: [
      // ── Auth Routes ──
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.signup,
        name: RouteNames.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.otp,
        name: RouteNames.otp,
        builder: (context, state) => OtpScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),

      // ── Main Shell (Bottom Nav / Sidebar) ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AdaptiveShell(navigationShell: navigationShell),
        branches: [
          // Home Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Library Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.library,
                name: RouteNames.library,
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),
          // Search Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.search,
                name: RouteNames.search,
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          // Downloads Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.downloads,
                name: RouteNames.downloads,
                builder: (context, state) => const DownloadsScreen(),
              ),
            ],
          ),
          // Profile Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                name: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Overlay Routes ──
      GoRoute(
        path: RoutePaths.upload,
        name: RouteNames.upload,
        builder: (context, state) => const UploadScreen(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.notifications,
        name: RouteNames.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],

    // ── Error Page ──
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? 'The page you\'re looking for doesn\'t exist.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
