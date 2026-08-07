/// Quick Play Hero Card with State-Driven Empty State & Mode Selection.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/enums/view_state.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/track_model.dart';
import '../../../player/presentation/providers/player_provider.dart';

/// Quick Play Modes
enum QuickPlayMode {
  randomLibrary,
  randomFavorites,
  recentlyAdded,
  mostPlayed,
  publicRadio,
}

extension QuickPlayModeX on QuickPlayMode {
  String get title {
    switch (this) {
      case QuickPlayMode.randomLibrary:
        return 'Random Library';
      case QuickPlayMode.randomFavorites:
        return 'Random Favorites';
      case QuickPlayMode.recentlyAdded:
        return 'Recently Added';
      case QuickPlayMode.mostPlayed:
        return 'Most Played';
      case QuickPlayMode.publicRadio:
        return 'Public Radio';
    }
  }

  String get emoji {
    switch (this) {
      case QuickPlayMode.randomLibrary:
        return '🎲';
      case QuickPlayMode.randomFavorites:
        return '❤️';
      case QuickPlayMode.recentlyAdded:
        return '🆕';
      case QuickPlayMode.mostPlayed:
        return '🔥';
      case QuickPlayMode.publicRadio:
        return '🌍';
    }
  }

  bool get isFutureFeature => this == QuickPlayMode.publicRadio;
}

class QuickPlayHero extends ConsumerStatefulWidget {
  const QuickPlayHero({
    super.key,
    this.userTracks = const [],
    this.viewState = ViewState.empty,
  });

  final List<TrackModel> userTracks;
  final ViewState viewState;

  @override
  ConsumerState<QuickPlayHero> createState() => _QuickPlayHeroState();
}

class _QuickPlayHeroState extends ConsumerState<QuickPlayHero>
    with SingleTickerProviderStateMixin {
  QuickPlayMode _selectedMode = QuickPlayMode.randomLibrary;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerQuickPlay() {
    if (widget.userTracks.isEmpty) {
      context.push(RoutePaths.upload);
      return;
    }

    if (_selectedMode.isFutureFeature) return;

    final playerNotifier = ref.read(playerProvider.notifier);
    final playerState = ref.read(playerProvider);

    List<TrackModel> playlist = List<TrackModel>.from(widget.userTracks);

    switch (_selectedMode) {
      case QuickPlayMode.randomLibrary:
        playlist.shuffle();
        break;
      case QuickPlayMode.randomFavorites:
        playlist = playlist.where((t) => t.isFavorite).toList();
        playlist.shuffle();
        if (playlist.isEmpty) {
          playlist = List<TrackModel>.from(widget.userTracks)..shuffle();
        }
        break;
      case QuickPlayMode.recentlyAdded:
        playlist = List<TrackModel>.from(widget.userTracks.reversed);
        break;
      case QuickPlayMode.mostPlayed:
        playlist.sort((a, b) => b.playCount.compareTo(a.playCount));
        break;
      case QuickPlayMode.publicRadio:
        return;
    }

    if (playlist.isEmpty) return;

    if (playerState.currentTrack != null &&
        playlist.any((t) => t.id == playerState.currentTrack!.id)) {
      playerNotifier.togglePlayPause();
    } else {
      playerNotifier.playTrack(playlist.first, queue: playlist, index: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider);
    final isPlaying = playerState.isPlaying;
    final hasCurrentTrack = playerState.currentTrack != null;
    final isLibraryEmpty = widget.userTracks.isEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: AppRadius.cardRadius,
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.accent.withValues(alpha: 0.08),
            context.appColors.surfaceVariant,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Badge & Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.flash_1,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Quick Play',
                    style: AppTypography.bodySemiBold(
                      color: context.appColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: context.appColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.appColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedMode.emoji,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _selectedMode.title,
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

          // ── Large Center Play Button ──
          GestureDetector(
            onTap: _triggerQuickPlay,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final pulse = isPlaying ? (_pulseController.value * 8) : 0.0;
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isLibraryEmpty
                        ? LinearGradient(
                            colors: [
                              context.appColors.border,
                              context.appColors.border.withValues(alpha: 0.7),
                            ],
                          )
                        : AppColors.primaryGradient,
                    boxShadow: isLibraryEmpty
                        ? []
                        : [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.45),
                              blurRadius: 20 + pulse,
                              spreadRadius: 2 + (pulse / 2),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Icon(
                      isLibraryEmpty
                          ? Icons.add_rounded
                          : (isPlaying && hasCurrentTrack)
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Action Subtitle
          Text(
            isLibraryEmpty
                ? 'No music available — Upload songs to start Quick Play.'
                : (isPlaying && hasCurrentTrack)
                    ? 'Playing: ${playerState.currentTrack?.title ?? "Track"}'
                    : 'Instantly starts: ${_selectedMode.emoji} ${_selectedMode.title}',
            style: AppTypography.caption(
              color: isLibraryEmpty
                  ? AppColors.warning
                  : context.appColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          if (isLibraryEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () => context.push(RoutePaths.upload),
              icon: const Icon(Iconsax.arrow_up_2, size: 16),
              label: const Text('Upload Music'),
            ),
          ],

          if (!isLibraryEmpty) ...[
            const SizedBox(height: AppSpacing.lg),

            // ── Quick Play Modes Selector ──
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: QuickPlayMode.values.map((mode) {
                  final isSelected = _selectedMode == mode;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: ChoiceChip(
                      showCheckmark: false,
                      avatar: Text(
                        mode.emoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(mode.title),
                          if (mode.isFutureFeature) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Soon',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedMode = mode;
                          });
                        }
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: context.appColors.surfaceVariant,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : (mode.isFutureFeature
                                ? context.appColors.textTertiary
                                : context.appColors.textPrimary),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : context.appColors.border,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
