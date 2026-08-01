/// Named route constants.
///
/// All route paths and names centralized for type-safe navigation.
library;

class RouteNames {
  const RouteNames._();

  // ── Auth ──
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String forgotPassword = 'forgot-password';
  static const String otp = 'otp';
  static const String emailVerification = 'email-verification';

  // ── Main Shell ──
  static const String home = 'home';
  static const String library = 'library';
  static const String search = 'search';
  static const String downloads = 'downloads';
  static const String profile = 'profile';

  // ── Sub-routes ──
  static const String folder = 'folder';
  static const String playlist = 'playlist';
  static const String playlistDetail = 'playlist-detail';
  static const String createPlaylist = 'create-playlist';
  static const String player = 'player';
  static const String upload = 'upload';
  static const String settings = 'settings';
  static const String editProfile = 'edit-profile';
  static const String artistProfile = 'artist-profile';
  static const String notifications = 'notifications';
  static const String trackDetail = 'track-detail';
  static const String trash = 'trash';

  // ── Admin ──
  static const String admin = 'admin';
  static const String adminReports = 'admin-reports';
  static const String adminUsers = 'admin-users';
  static const String adminLogs = 'admin-logs';

  // ── Error ──
  static const String notFound = 'not-found';
  static const String maintenance = 'maintenance';
}

/// Route paths.
class RoutePaths {
  const RoutePaths._();

  // ── Auth ──
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String emailVerification = '/email-verification';

  // ── Main ──
  static const String home = '/home';
  static const String library = '/library';
  static const String search = '/search';
  static const String downloads = '/downloads';
  static const String profile = '/profile';

  // ── Nested ──
  static const String folder = 'folder/:folderId';
  static const String playlist = 'playlist/:playlistId';
  static const String createPlaylist = 'create-playlist';
  static const String player = '/player';
  static const String upload = '/upload';
  static const String settings = '/settings';
  static const String editProfile = 'edit';
  static const String artistProfile = '/artist/:userId';
  static const String notifications = '/notifications';
  static const String trackDetail = 'track/:trackId';
  static const String trash = 'trash';

  // ── Admin ──
  static const String admin = '/admin';
  static const String adminReports = 'reports';
  static const String adminUsers = 'users';
  static const String adminLogs = 'logs';
}
