/// Home screen — main dashboard.
///
/// Fully reactive frontend integrated with tracksProvider and playlistsProvider.
/// Automatically transitions between empty onboarding and populated library sections.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/track_model.dart';
import '../../../../shared/providers/playlists_provider.dart';
import '../../../../shared/providers/tracks_provider.dart';
import '../../../../shared/widgets/app_empty_state.dart';

import '../../../authentication/presentation/providers/auth_controller.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../widgets/quick_play_hero.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final displayName = user?['displayName'] as String? ?? user?['email'] as String? ?? 'Music Lover';

    final tracksState = ref.watch(tracksProvider);
    final userTracks = tracksState.tracks;
    final isLibraryEmpty = userTracks.isEmpty;

    final recentTracks = ref.watch(recentTracksProvider);
    final favoriteTracks = ref.watch(favoritesProvider);
    final playlists = ref.watch(playlistsProvider).playlists;

    final screenPadding = context.isMobile
        ? AppSpacing.screenPaddingMobile
        : AppSpacing.screenPaddingDesktop;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome, $displayName',
                        style: AppTypography.h3(
                          color: context.appColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Cloud Music Storage',
                        style: AppTypography.caption(
                          color: context.appColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.people_outline_rounded),
                tooltip: 'Listen Together',
                onPressed: () => context.push(RoutePaths.collaboration),
              ),
              IconButton(
                icon: const Icon(Iconsax.notification),
                onPressed: () => context.push(RoutePaths.notifications),
              ),
              IconButton(
                icon: const Icon(Iconsax.setting_2),
                onPressed: () => context.push(RoutePaths.settings),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Content List
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: screenPadding),
            sliver: SliverList.list(
              children: [
                const SizedBox(height: AppSpacing.lg),

                // ── Quick Play Hero ──
                QuickPlayHero(
                  userTracks: userTracks,
                  viewState: tracksState.viewState,
                ),
                const SizedBox(height: AppSpacing.sectionGap),

                // ── Quick Actions ──
                _QuickActions(
                  isEnabled: !isLibraryEmpty,
                  onShuffle: () {
                    final shuffled = List<TrackModel>.from(userTracks)..shuffle();
                    ref.read(playerProvider.notifier).playTrack(shuffled.first, queue: shuffled);
                  },
                ),
                const SizedBox(height: AppSpacing.sectionGap),

                // ── Listen Together Banner ──
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.purple,
                      child: Icon(Icons.people_outline, color: Colors.white),
                    ),
                    title: const Text('Listen Together with Friends', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Invite contacts, combine music & play random songs together!'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(RoutePaths.collaboration),
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),

                // ── Storage Usage Card ──
                _StorageUsageCard(user: user, tracks: userTracks),
                const SizedBox(height: AppSpacing.sectionGap),

                // ── Empty State OR Dynamic Sections ──
                if (isLibraryEmpty) ...[
                  const AppEmptyState(
                    type: EmptyStateType.firstTimeLibrary,
                  ),
                  const SizedBox(height: AppSpacing.xxxxl),
                ] else ...[
                  // Recently Played
                  if (recentTracks.isNotEmpty) ...[
                    _SectionHeader(title: 'Recently Added', onSeeAll: () => context.go(RoutePaths.library)),
                    const SizedBox(height: AppSpacing.md),
                    _HorizontalTrackList(tracks: recentTracks, ref: ref),
                    const SizedBox(height: AppSpacing.sectionGap),
                  ],

                  // Playlists Section
                  if (playlists.isNotEmpty) ...[
                    _SectionHeader(title: 'Your Playlists', onSeeAll: () => context.go(RoutePaths.library)),
                    const SizedBox(height: AppSpacing.md),
                    _HorizontalPlaylistList(playlists: playlists),
                    const SizedBox(height: AppSpacing.sectionGap),
                  ],

                  // Favorites Section
                  if (favoriteTracks.isNotEmpty) ...[
                    _SectionHeader(title: 'Favorites', onSeeAll: () => context.go(RoutePaths.library)),
                    const SizedBox(height: AppSpacing.md),
                    _HorizontalTrackList(tracks: favoriteTracks, ref: ref),
                    const SizedBox(height: AppSpacing.sectionGap),
                  ],

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.upload),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Iconsax.arrow_up_2),
        label: const Text('Upload'),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.isEnabled,
    this.onShuffle,
  });

  final bool isEnabled;
  final VoidCallback? onShuffle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickActionChip(
          icon: Iconsax.shuffle,
          label: 'Shuffle All',
          isEnabled: isEnabled,
          onTap: isEnabled ? onShuffle : null,
        ),
        const SizedBox(width: AppSpacing.sm),
        _QuickActionChip(
          icon: Iconsax.heart,
          label: 'Liked Songs',
          isEnabled: isEnabled,
          onTap: isEnabled ? () => context.go(RoutePaths.library) : null,
        ),
        const SizedBox(width: AppSpacing.sm),
        _QuickActionChip(
          icon: Iconsax.clock,
          label: 'Recent',
          isEnabled: isEnabled,
          onTap: isEnabled ? () => context.go(RoutePaths.library) : null,
        ),
      ],
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.isEnabled,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.45,
        child: Material(
          color: context.appColors.surfaceVariant,
          borderRadius: AppRadius.cardRadius,
          child: InkWell(
            borderRadius: AppRadius.cardRadius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isEnabled ? AppColors.primary : context.appColors.textTertiary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      style: AppTypography.caption(
                        color: isEnabled
                            ? context.appColors.textPrimary
                            : context.appColors.textTertiary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.h2(color: context.appColors.textPrimary),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            'See all',
            style: AppTypography.caption(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _HorizontalTrackList extends StatelessWidget {
  const _HorizontalTrackList({
    required this.tracks,
    required this.ref,
  });

  final List<TrackModel> tracks;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tracks.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final track = tracks[index];
          return GestureDetector(
            onTap: () {
              ref.read(playerProvider.notifier).playTrack(track, queue: tracks, index: index);
            },
            child: SizedBox(
              width: 135,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 135,
                    height: 135,
                    decoration: BoxDecoration(
                      color: context.appColors.surfaceVariant,
                      borderRadius: AppRadius.cardRadius,
                      border: Border.all(color: context.appColors.border),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.music_note_rounded,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    track.title,
                    style: AppTypography.bodySmall(color: context.appColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    track.displayArtist,
                    style: AppTypography.caption(color: context.appColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HorizontalPlaylistList extends StatelessWidget {
  const _HorizontalPlaylistList({required this.playlists});

  final List<dynamic> playlists;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: playlists.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          return SizedBox(
            width: 135,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 135,
                  height: 135,
                  decoration: BoxDecoration(
                    color: context.appColors.surfaceVariant,
                    borderRadius: AppRadius.cardRadius,
                  ),
                  child: Icon(
                    Iconsax.music_playlist,
                    color: context.appColors.textTertiary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  playlist.name as String? ?? 'Playlist',
                  style: AppTypography.bodySmall(color: context.appColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${playlist.trackCount ?? 0} tracks',
                  style: AppTypography.caption(color: context.appColors.textSecondary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StorageUsageCard extends StatelessWidget {
  const _StorageUsageCard({
    this.user,
    required this.tracks,
  });

  final Map<String, dynamic>? user;
  final List<TrackModel> tracks;

  @override
  Widget build(BuildContext context) {
    final trackBytes = tracks.fold<double>(0.0, (acc, t) => acc + t.fileSizeBytes);
    final userBytes = (user?['storageUsedBytes'] as num?)?.toDouble() ?? 0.0;
    final usedBytes = trackBytes > 0 ? trackBytes : userBytes;
    final quotaBytes = (user?['storageQuotaBytes'] as num?)?.toDouble() ?? 5368709120.0;
    final progress = (quotaBytes > 0) ? (usedBytes / quotaBytes).clamp(0.0, 1.0) : 0.0;

    final usedMb = (usedBytes / (1024 * 1024)).toStringAsFixed(1);
    final quotaGb = (quotaBytes / (1024 * 1024 * 1024)).toStringAsFixed(0);
    final freeGb = ((quotaBytes - usedBytes) / (1024 * 1024 * 1024)).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surfaceVariant,
        borderRadius: AppRadius.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cloud Storage',
                style: AppTypography.bodySemiBold(
                  color: context.appColors.textPrimary,
                ),
              ),
              Text(
                '$usedMb MB / $quotaGb GB',
                style: AppTypography.caption(
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: context.appColors.border,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$freeGb GB available',
            style: AppTypography.caption(
              color: context.appColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
