/// Full screen expanded music player.
///
/// Features large artwork, seek bar, main playback controls, shuffle/repeat,
/// favorite toggle, queue modal launcher, speed adjustment, and offline download.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/player_provider.dart';
import '../widgets/queue_sheet.dart';

class FullPlayerScreen extends ConsumerWidget {
  const FullPlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final track = playerState.currentTrack;

    if (track == null) {
      return Scaffold(
        backgroundColor: context.appColors.playerBackground,
        body: Center(
          child: Text(
            'No track playing',
            style: AppTypography.body(color: context.appColors.textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.appColors.playerBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),

              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
                    onPressed: () => context.pop(),
                  ),
                  Column(
                    children: [
                      Text(
                        'PLAYING FROM LIBRARY',
                        style: AppTypography.overline(
                          color: context.appColors.textTertiary,
                        ),
                      ),
                      Text(
                        track.displayAlbum,
                        style: AppTypography.caption(
                          color: context.appColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.more, size: 24),
                    onPressed: () {},
                  ),
                ],
              ),

              const Spacer(),

              // Artwork
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 32,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.music_note_rounded,
                      color: Colors.white,
                      size: 96,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Title, Artist & Favorite
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          style: AppTypography.h1(
                            color: context.appColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          track.displayArtist,
                          style: AppTypography.body(
                            color: context.appColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      track.isFavorite ? Icons.favorite_rounded : Iconsax.heart,
                      color: track.isFavorite ? AppColors.accent : context.appColors.textPrimary,
                      size: 26,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Seek Slider
              Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    ),
                    child: Slider(
                      value: playerState.progress,
                      onChanged: (val) {
                        final newMs = (val * playerState.duration.inMilliseconds).toInt();
                        ref.read(playerProvider.notifier).seek(Duration(milliseconds: newMs));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(playerState.position),
                          style: AppTypography.caption(
                            color: context.appColors.textSecondary,
                          ),
                        ),
                        Text(
                          _formatDuration(playerState.duration),
                          style: AppTypography.caption(
                            color: context.appColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Main Playback Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Shuffle
                  IconButton(
                    icon: Icon(
                      Iconsax.shuffle,
                      color: playerState.isShuffleEnabled
                          ? AppColors.primary
                          : context.appColors.textTertiary,
                    ),
                    onPressed: () {
                      ref.read(playerProvider.notifier).toggleShuffle();
                    },
                  ),

                  // Previous
                  IconButton(
                    icon: const Icon(Iconsax.previous, size: 32),
                    onPressed: () {
                      ref.read(playerProvider.notifier).previous();
                    },
                  ),

                  // Play / Pause FAB
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        playerState.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 36,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        ref.read(playerProvider.notifier).togglePlayPause();
                      },
                    ),
                  ),

                  // Next
                  IconButton(
                    icon: const Icon(Iconsax.next, size: 32),
                    onPressed: () {
                      ref.read(playerProvider.notifier).next();
                    },
                  ),

                  // Repeat
                  IconButton(
                    icon: Icon(
                      playerState.repeatState == RepeatState.one
                          ? Iconsax.repeate_one
                          : Iconsax.repeate_music,
                      color: playerState.repeatState != RepeatState.off
                          ? AppColors.primary
                          : context.appColors.textTertiary,
                    ),
                    onPressed: () {
                      ref.read(playerProvider.notifier).toggleRepeat();
                    },
                  ),
                ],
              ),

              const Spacer(),

              // Extra Tools Row (Queue, Download, Speed)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Speed button
                  TextButton(
                    onPressed: () {
                      _showSpeedPicker(context, ref, playerState.speed);
                    },
                    child: Text(
                      '${playerState.speed}x',
                      style: AppTypography.buttonSmall(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ),

                  // Download button
                  IconButton(
                    icon: Icon(
                      track.isDownloaded ? Iconsax.arrow_down : Iconsax.arrow_down_2,
                      color: track.isDownloaded ? AppColors.success : context.appColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {},
                  ),

                  // Queue Sheet button
                  IconButton(
                    icon: const Icon(Iconsax.music_playlist, size: 22),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const QueueSheet(),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showSpeedPicker(BuildContext context, WidgetRef ref, double currentSpeed) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTopRadius),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Playback Speed',
                style: AppTypography.h3(color: context.appColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((s) {
                  final isSelected = (s == currentSpeed);
                  return ChoiceChip(
                    label: Text('${s}x'),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(playerProvider.notifier).setSpeed(s);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
