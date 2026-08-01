/// REST API endpoint constants.
///
/// Maps to the backend API surface defined in the Backend Schemas Document §4.
/// All endpoints are relative to [AppConfig.apiBaseUrl].
library;

class ApiEndpoints {
  const ApiEndpoints._();

  // ── Authentication ──
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';
  static const String oauthGoogle = '/auth/oauth/google';
  static const String oauthApple = '/auth/oauth/apple';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String enable2fa = '/auth/2fa/enable';
  static const String verify2fa = '/auth/2fa/verify';

  // ── User / Profile ──
  static const String me = '/me';
  static const String myStorage = '/me/storage';

  // ── Tracks ──
  static const String uploadUrl = '/tracks/upload-url';
  static const String tracks = '/tracks';
  static String trackById(String id) => '/tracks/$id';
  static String restoreTrack(String id) => '/tracks/$id/restore';
  static String publishTrack(String id) => '/tracks/$id/publish';
  static String streamUrl(String id) => '/tracks/$id/stream-url';

  // ── Folders ──
  static const String folders = '/folders';
  static String folderById(String id) => '/folders/$id';

  // ── Playlists ──
  static const String playlists = '/playlists';
  static String playlistById(String id) => '/playlists/$id';
  static String playlistTracks(String id) => '/playlists/$id/tracks';
  static String removePlaylistTrack(String playlistId, String trackId) =>
      '/playlists/$playlistId/tracks/$trackId';

  // ── Favorites ──
  static String favorite(String trackId) => '/favorites/$trackId';

  // ── Search ──
  static const String search = '/search';

  // ── Artists / Social ──
  static String artistProfile(String userId) => '/artists/$userId';
  static String followArtist(String userId) => '/artists/$userId/follow';
  static String trackComments(String trackId) => '/tracks/$trackId/comments';

  // ── Reports ──
  static const String reports = '/reports';

  // ── Admin ──
  static const String adminReports = '/admin/reports';
  static String adminReportById(String id) => '/admin/reports/$id';
  static const String adminUsers = '/admin/users';
  static String suspendUser(String id) => '/admin/users/$id/suspend';
  static const String adminStats = '/admin/stats';
  static const String adminLogs = '/admin/logs';

  // ── Playback ──
  static const String playbackHeartbeat = '/playback/heartbeat';
}
