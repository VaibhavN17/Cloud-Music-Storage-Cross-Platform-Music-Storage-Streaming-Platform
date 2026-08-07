/// Standard reusable Empty State widget with preset variants.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/extensions/theme_extension.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'app_button.dart';

enum EmptyStateType {
  firstTimeLibrary,
  library,
  deletedLibrary,
  playlists,
  favorites,
  downloads,
  searchPrompt,
  noSearchResults,
  recent,
  queue,
  notifications,
  offline,
  error,
  permission,
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.type,
    this.customTitle,
    this.customMessage,
    this.onActionPressed,
    this.actionLabel,
  });

  final EmptyStateType type;
  final String? customTitle;
  final String? customMessage;
  final VoidCallback? onActionPressed;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final title = customTitle ?? _getTitle();
    final message = customMessage ?? _getMessage();
    final icon = _getIcon();
    final ctaText = actionLabel ?? _getActionLabel();
    final action = onActionPressed ?? _getDefaultAction(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.appColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 38,
                color: context.appColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.h2(color: context.appColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.body(color: context.appColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (ctaText != null && action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: 220,
                child: AppButton(
                  text: ctaText,
                  onPressed: action,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case EmptyStateType.firstTimeLibrary:
      case EmptyStateType.library:
      case EmptyStateType.deletedLibrary:
        return Iconsax.music_library_2;
      case EmptyStateType.playlists:
        return Iconsax.music_playlist;
      case EmptyStateType.favorites:
        return Iconsax.heart;
      case EmptyStateType.downloads:
        return Iconsax.arrow_down_2;
      case EmptyStateType.searchPrompt:
        return Iconsax.search_normal_1;
      case EmptyStateType.noSearchResults:
        return Iconsax.search_status;
      case EmptyStateType.recent:
        return Iconsax.clock;
      case EmptyStateType.queue:
        return Iconsax.music_filter;
      case EmptyStateType.notifications:
        return Iconsax.notification;
      case EmptyStateType.offline:
        return Iconsax.wifi_square;
      case EmptyStateType.error:
        return Iconsax.warning_2;
      case EmptyStateType.permission:
        return Iconsax.shield_security;
    }
  }

  String _getTitle() {
    switch (type) {
      case EmptyStateType.firstTimeLibrary:
        return 'Your music library is empty';
      case EmptyStateType.library:
        return 'No music yet';
      case EmptyStateType.deletedLibrary:
        return 'Your library is empty';
      case EmptyStateType.playlists:
        return 'No playlists';
      case EmptyStateType.favorites:
        return 'No favorites yet';
      case EmptyStateType.downloads:
        return 'No offline music';
      case EmptyStateType.searchPrompt:
        return 'Search your music';
      case EmptyStateType.noSearchResults:
        return 'No results found';
      case EmptyStateType.recent:
        return 'Nothing played yet';
      case EmptyStateType.queue:
        return 'Queue is empty';
      case EmptyStateType.notifications:
        return 'No notifications';
      case EmptyStateType.offline:
        return 'You\'re offline';
      case EmptyStateType.error:
        return 'Something went wrong';
      case EmptyStateType.permission:
        return 'Permission needed';
    }
  }

  String _getMessage() {
    switch (type) {
      case EmptyStateType.firstTimeLibrary:
        return 'Upload your first song to start streaming across all your devices.';
      case EmptyStateType.library:
        return 'Upload MP3, FLAC, WAV, M4A and other supported audio formats.';
      case EmptyStateType.deletedLibrary:
        return 'Looks like you\'ve removed all your music from your cloud storage.';
      case EmptyStateType.playlists:
        return 'Create your first playlist to organize your cloud music.';
      case EmptyStateType.favorites:
        return 'Tap ❤️ on songs to find them here later.';
      case EmptyStateType.downloads:
        return 'Downloaded tracks for offline listening will appear here.';
      case EmptyStateType.searchPrompt:
        return 'Search songs, artists, albums, or playlists.';
      case EmptyStateType.noSearchResults:
        return 'No matches found. Try searching with another keyword.';
      case EmptyStateType.recent:
        return 'Played songs will appear here once you start listening.';
      case EmptyStateType.queue:
        return 'Add tracks to queue to start listening.';
      case EmptyStateType.notifications:
        return 'You\'re all caught up!';
      case EmptyStateType.offline:
        return 'Connect to the internet to stream your cloud music.';
      case EmptyStateType.error:
        return 'Failed to load content. Please check your connection.';
      case EmptyStateType.permission:
        return 'Grant storage permission to select audio files from your device.';
    }
  }

  String? _getActionLabel() {
    switch (type) {
      case EmptyStateType.firstTimeLibrary:
      case EmptyStateType.library:
      case EmptyStateType.deletedLibrary:
      case EmptyStateType.recent:
        return 'Upload Music';
      case EmptyStateType.playlists:
        return 'Create Playlist';
      case EmptyStateType.downloads:
        return 'Browse Library';
      case EmptyStateType.offline:
      case EmptyStateType.error:
        return 'Try Again';
      case EmptyStateType.permission:
        return 'Grant Permission';
      case EmptyStateType.favorites:
      case EmptyStateType.searchPrompt:
      case EmptyStateType.noSearchResults:
      case EmptyStateType.queue:
      case EmptyStateType.notifications:
        return null;
    }
  }

  VoidCallback? _getDefaultAction(BuildContext context) {
    switch (type) {
      case EmptyStateType.firstTimeLibrary:
      case EmptyStateType.library:
      case EmptyStateType.deletedLibrary:
      case EmptyStateType.recent:
        return () => context.push(RoutePaths.upload);
      case EmptyStateType.downloads:
        return () => context.go(RoutePaths.library);
      default:
        return null;
    }
  }
}
