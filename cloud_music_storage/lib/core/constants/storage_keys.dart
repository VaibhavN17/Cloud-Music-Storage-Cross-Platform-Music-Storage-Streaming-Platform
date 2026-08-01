/// Storage key constants for local persistence.
///
/// Keys for Hive boxes, secure storage entries, and shared preferences.
/// Centralizing keys prevents typo-based bugs and makes migration easier.
library;

class StorageKeys {
  const StorageKeys._();

  // ── Secure Storage ──
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';

  // ── Hive Box Names ──
  static const String userBox = 'user_box';
  static const String libraryBox = 'library_box';
  static const String playlistBox = 'playlist_box';
  static const String settingsBox = 'settings_box';
  static const String cacheBox = 'cache_box';
  static const String searchHistoryBox = 'search_history_box';
  static const String downloadBox = 'download_box';
  static const String playbackBox = 'playback_box';

  // ── Settings Keys ──
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String playbackQuality = 'playback_quality';
  static const String downloadQuality = 'download_quality';
  static const String downloadWifiOnly = 'download_wifi_only';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String crossfadeEnabled = 'crossfade_enabled';
  static const String crossfadeDurationMs = 'crossfade_duration_ms';
  static const String gaplessPlayback = 'gapless_playback';
  static const String lastSyncTimestamp = 'last_sync_timestamp';

  // ── Cache Keys ──
  static const String cachedUser = 'cached_user';
  static const String cachedLibrary = 'cached_library';
  static const String recentlyPlayed = 'recently_played';
  static const String searchSuggestions = 'search_suggestions';
}
