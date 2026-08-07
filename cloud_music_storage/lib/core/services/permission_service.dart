/// Runtime permissions helper service.
///
/// Handles requesting Android runtime permissions (Notification & Storage/Media Audio).
library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  const PermissionService._();

  /// Requests notification permission on Android 13+ (API 33+).
  static Future<bool> requestNotificationPermission() async {
    if (!kIsWeb && Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  /// Requests audio media permission on Android 13+ or external storage on legacy Android.
  static Future<bool> requestAudioStoragePermission() async {
    if (kIsWeb) return true;

    if (Platform.isAndroid) {
      // Permission.audio is mapped to READ_MEDIA_AUDIO on Android 13+
      final audioStatus = await Permission.audio.request();
      if (audioStatus.isGranted) return true;

      // Fallback for Android 12 and below (READ_EXTERNAL_STORAGE)
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    }

    return true;
  }
}
