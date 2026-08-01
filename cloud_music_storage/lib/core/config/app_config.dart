/// Application environment configuration.
///
/// Centralizes all environment-specific settings including API URLs,
/// feature flags, and build-time configuration.
library;

enum Environment { dev, staging, prod }

class AppConfig {
  const AppConfig._();

  /// Current environment — change this for builds.
  static const Environment environment = Environment.dev;

  /// API base URL per environment.
  static String get apiBaseUrl {
    switch (environment) {
      case Environment.dev:
        return 'http://localhost:4000';
      case Environment.staging:
        return 'https://staging-api.cloudmusic.app';
      case Environment.prod:
        return 'https://api.cloudmusic.app';
    }
  }

  /// Request timeout in milliseconds.
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  /// Token refresh settings.
  static const int accessTokenTtlMinutes = 15;
  static const int refreshTokenTtlDays = 30;

  /// Upload settings.
  static const int maxUploadSizeBytes = 524288000; // 500 MB
  static const int maxConcurrentUploads = 3;
  static const int uploadChunkSizeBytes = 5242880; // 5 MB

  /// Playback settings.
  static const int playbackHeartbeatIntervalSeconds = 15;
  static const int signedUrlTtlMinutes = 10;

  /// Search settings.
  static const int searchDebounceMs = 300;
  static const int searchResultsPerPage = 20;

  /// Pagination.
  static const int defaultPageSize = 20;
  static const int libraryPageSize = 30;

  /// Cache settings.
  static const int metadataCacheTtlMinutes = 30;
  static const int artworkCacheMaxMb = 200;

  /// Feature flags.
  static const bool enableGoogleSignIn = true;
  static const bool enableAppleSignIn = true;
  static const bool enable2FA = false; // Future scope
  static const bool enableEqualizer = false; // Future scope
  static const bool enableLyrics = false; // Future scope
  static const bool enableSocketSync = false; // Future scope
}
