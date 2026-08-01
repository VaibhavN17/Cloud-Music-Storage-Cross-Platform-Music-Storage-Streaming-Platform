/// Application-wide constants.
///
/// Centralized values for durations, limits, keys, and magic numbers
/// used across the app. Never hardcode these values in UI or logic code.
library;

class AppConstants {
  const AppConstants._();

  // ── App Info ──
  static const String appName = 'Cloud Music Storage';
  static const String appVersion = '0.1.0';
  static const int appBuildNumber = 1;

  // ── Pagination ──
  static const int defaultPageSize = 20;
  static const int libraryPageSize = 30;
  static const int commentsPageSize = 15;

  // ── Upload ──
  static const int maxFileSizeBytes = 524288000; // 500 MB
  static const List<String> supportedAudioFormats = [
    'mp3', 'flac', 'm4a', 'wav', 'ogg', 'aac', 'webm',
  ];
  static const List<String> supportedAudioMimeTypes = [
    'audio/mpeg',
    'audio/flac',
    'audio/mp4',
    'audio/x-m4a',
    'audio/wav',
    'audio/x-wav',
    'audio/ogg',
    'audio/aac',
    'audio/webm',
  ];

  // ── Playback ──
  static const double minPlaybackSpeed = 0.5;
  static const double maxPlaybackSpeed = 2.0;
  static const double defaultPlaybackSpeed = 1.0;
  static const List<double> playbackSpeedOptions = [
    0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0,
  ];

  // ── Sleep Timer Presets (minutes) ──
  static const List<int> sleepTimerPresets = [5, 10, 15, 30, 45, 60, 90];

  // ── Trash ──
  static const int trashRetentionDays = 30;

  // ── Search ──
  static const int searchDebounceMs = 300;
  static const int maxSearchHistoryItems = 20;

  // ── Storage ──
  static const int defaultQuotaBytes = 5368709120; // 5 GB

  // ── Animation Durations (ms) ──
  static const int microAnimationMs = 150;
  static const int shortAnimationMs = 250;
  static const int mediumAnimationMs = 350;
  static const int longAnimationMs = 500;

  // ── UI ──
  static const double miniPlayerHeight = 64.0;
  static const double bottomNavHeight = 80.0;
  static const double sidebarWidth = 280.0;
  static const double sidebarCollapsedWidth = 72.0;

  // ── Breakpoints ──
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;

  // ── Accessibility ──
  static const double minTouchTarget = 44.0;
}
