# Cloud Music Storage — Flutter Client : cloudtune

A production-grade, cross-platform cloud music storage and streaming application built with Flutter.

[![Flutter Version](https://img.shields.io/badge/Flutter-3.41.0-02569B?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.11.0-0175C2?logo=dart)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean_Architecture-2E6BFF)](#architecture)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 🎵 Overview

**Cloud Music Storage** lets users upload, organize, stream, and download their personal music collection across any device (Android, iOS, Web, Windows, macOS, Linux). It combines the personal cloud utility of Google Drive with the music-first player experience of Apple Music / Spotify.

The client communicates via REST APIs with a separate Node.js/Express TypeScript backend powered by PostgreSQL, Prisma, Redis, and Cloudflare R2 storage.

---

## ✨ Features

- 🎧 **Audio Engine**: Gapless playback, background audio, lock-screen controls, queue management, repeat/shuffle modes, playback speed adjustment using `just_audio` & `audio_service`.
- 📁 **Personal Library**: Folders, playlists, grid/list view toggle, multi-select, sort by date/artist/title/size, trash & soft-delete restore.
- ☁️ **Cloud Upload**: Drag & drop zone (Desktop/Web), file picker (Mobile), batch upload with parallel progress and presigned R2 URLs.
- 📥 **Offline Downloads**: Local encrypted audio caching, offline badges, and storage quota management.
- 🎨 **Design System**: Material 3 dark/light/system theme, smooth micro-interactions, shimmer loading skeletons, and content-forward UI.
- 📱 **Adaptive & Responsive**: Breakpoint-aware UI with bottom navigation bar (Mobile), navigation rail (Tablet), and collapsible sidebar (Desktop).
- 🔒 **Secure Auth**: Email/Password, Google OAuth, Apple Sign-In, 6-digit OTP verification, and automatic JWT token refresh.
- 🔍 **Global Search**: Debounced search across tracks, artists, albums, and playlists with browse categories.

---

## 🏗 Architecture

The application strictly enforces **Clean Architecture** with a **Feature-First** structure:

```
Presentation (UI, Widgets, Riverpod Controllers)
     ↓
Domain (Entities, Use Cases, Repository Interfaces)
     ↓
Data (Models, Data Sources, Repository Implementations)
     ↓
Core (Dio Network Client, Secure Storage, Audio Engine, Router, Theme)
```

### Directory Structure

```
lib/
├── core/
│   ├── config/          # AppConfig, environment variables, thresholds
│   ├── constants/       # ApiEndpoints, AppConstants, StorageKeys
│   ├── extensions/      # BuildContext extensions, theme tokens
│   ├── network/        # Dio client, Auth/Refresh/Retry/Error interceptors
│   ├── router/         # GoRouter configuration, Auth Guard, route paths
│   ├── storage/        # SecureStorageService, SettingsStorage
│   └── theme/          # AppColors, AppTypography, AppTheme, ThemeModeNotifier
├── features/
│   ├── authentication/ # Splash, Onboarding, Login, Signup, Forgot Password, OTP
│   ├── home/           # Main dashboard, recently played, quick actions
│   ├── library/        # Folder browser, track list/grid, sorting, trash
│   ├── upload/         # File picker, drag-and-drop zone, upload queue
│   ├── player/         # Audio engine, MiniPlayer, FullPlayerScreen, QueueSheet
│   ├── search/         # Global search, browse categories
│   ├── downloads/      # Offline storage manager & downloaded songs
│   ├── profile/        # User profile, statistics, storage quota card
│   ├── settings/       # Dark mode, audio quality, privacy, account management
│   ├── notifications/  # Notification center
│   ├── artist/         # Public artist profile & published tracks
│   └── admin/          # Storage analytics & content moderation
└── shared/
    ├── models/         # UserModel, TrackModel, FolderModel, PlaylistModel
    └── widgets/        # AdaptiveShell, AppButton, SkeletonLoader, EmptyState
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) v3.41.0 or higher
- [Dart SDK](https://dart.dev/get-dart) v3.11.0 or higher

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-org/cloud_music_storage.git
   cd cloud_music_storage
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure API Base URL**:
   Open `lib/core/config/app_config.dart` and set your backend API URL:
   ```dart
   static String get apiBaseUrl {
     switch (environment) {
       case Environment.dev:
         return 'http://localhost:4000'; // Or your local backend IP
       case Environment.staging:
         return 'https://staging-api.cloudmusic.app';
       case Environment.prod:
         return 'https://api.cloudmusic.app';
     }
   }
   ```

4. **Run the Application**:
   ```bash
   # Android / iOS / Web / Desktop
   flutter run -d chrome
   flutter run -d android
   flutter run -d windows
   ```

---

## 🛠 Commands & Scripts

| Command | Action |
|---|---|
| `flutter pub get` | Download and resolve dependencies |
| `flutter analyze` | Run static analysis and lint checks |
| `flutter test` | Run unit and widget tests |
| `flutter build apk --release` | Build Android release APK |
| `flutter build web` | Build web production bundle |
| `flutter build windows` | Build Windows desktop executable |

---

## 🛡 Network & Security Layer

- **JWT Rotation**: `TokenRefreshInterceptor` automatically catches `401 AUTH_TOKEN_EXPIRED` errors, refreshes tokens via `/auth/refresh`, and retries failed requests seamlessly.
- **Secure Token Storage**: Tokens are stored encrypted at rest via `flutter_secure_storage` (Android EncryptedSharedPreferences & iOS Keychain).
- **Transient Error Retry**: Exponential backoff with jitter retries transient network timeouts and `5xx` server errors up to 3 times.

---

## 💻 Supported Platforms

| Platform | Support Status |
|---|---|
| **Android** | ✅ Full Support (API 24+) |
| **iOS** | ✅ Full Support (iOS 15+) |
| **Web** | ✅ Full Support (Chrome, Safari, Edge, Firefox) |
| **Windows** | ✅ Full Support (Windows 10+) |
| **macOS** | ✅ Full Support (macOS 12+) |
| **Linux** | ✅ Full Support (Ubuntu 20.04+) |

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
