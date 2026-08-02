/// Home screen — main dashboard.
///
/// Shows Recently Played, Continue Listening, Favorites, Playlists,
/// Storage Usage, and Quick Upload shortcut.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../authentication/presentation/providers/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final displayName = user?['displayName'] as String? ?? user?['email'] as String? ?? 'Music Lover';

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome, $displayName',
                      style: AppTypography.h3(
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Cloud Music Storage',
                      style: AppTypography.caption(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
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

          // Content
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: screenPadding),
            sliver: SliverList.list(
              children: [
                const SizedBox(height: AppSpacing.lg),

                // ── Quick Actions ──
                _QuickActions(),
                const SizedBox(height: AppSpacing.sectionGap),

                // ── Recently Played ──
                _SectionHeader(title: 'Recently Played', onSeeAll: () {}),
                const SizedBox(height: AppSpacing.md),
                _HorizontalTrackList(),
                const SizedBox(height: AppSpacing.sectionGap),

                // ── Your Playlists ──
                _SectionHeader(title: 'Your Playlists', onSeeAll: () {}),
                const SizedBox(height: AppSpacing.md),
                _HorizontalPlaylistList(),
                const SizedBox(height: AppSpacing.sectionGap),

                // ── Storage Usage ──
                _StorageUsageCard(user: user),
                const SizedBox(height: AppSpacing.sectionGap),

                // ── Favorites ──
                _SectionHeader(title: 'Favorites', onSeeAll: () {}),
                const SizedBox(height: AppSpacing.md),
                _HorizontalTrackList(),
                const SizedBox(height: AppSpacing.xxxxl),
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

// ── Quick Actions Row ──
class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickActionChip(
          icon: Iconsax.shuffle,
          label: 'Shuffle All',
          onTap: () {},
        ),
        const SizedBox(width: AppSpacing.sm),
        _QuickActionChip(
          icon: Iconsax.heart,
          label: 'Liked Songs',
          onTap: () {},
        ),
        const SizedBox(width: AppSpacing.sm),
        _QuickActionChip(
          icon: Iconsax.clock,
          label: 'Recent',
          onTap: () {},
        ),
      ],
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: AppTypography.caption(
                      color: context.appColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section Header ──
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

// ── Horizontal Track List (Mock) ──
class _HorizontalTrackList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          return _TrackCard(index: index);
        },
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Midnight Drive', 'Sunset Vibes', 'Ocean Waves',
      'City Lights', 'Morning Coffee', 'Late Night',
    ];
    final artists = [
      'Rahul', 'Priya', 'Meera', 'DJ Set', 'Acoustic', 'Electronic',
    ];
    final colors = [
      const Color(0xFF2E6BFF), const Color(0xFFFF6B4A),
      const Color(0xFF2ECC71), const Color(0xFFF5A623),
      const Color(0xFF9B59B6), const Color(0xFFE91E63),
    ];

    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Artwork
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors[index % colors.length],
                  colors[index % colors.length].withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.cardRadius,
            ),
            child: const Center(
              child: Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            titles[index % titles.length],
            style: AppTypography.bodySmall(
              color: context.appColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            artists[index % artists.length],
            style: AppTypography.caption(
              color: context.appColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Horizontal Playlist List (Mock) ──
class _HorizontalPlaylistList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final names = ['Workout Mix', 'Chill Vibes', 'Road Trip', 'Focus'];
          final counts = ['24 tracks', '18 tracks', '32 tracks', '12 tracks'];

          return SizedBox(
            width: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: context.appColors.surfaceVariant,
                    borderRadius: AppRadius.cardRadius,
                  ),
                  child: Icon(
                    Iconsax.music_playlist,
                    color: context.appColors.textTertiary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  names[index],
                  style: AppTypography.bodySmall(
                    color: context.appColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  counts[index],
                  style: AppTypography.caption(
                    color: context.appColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Storage Usage Card ──
class _StorageUsageCard extends StatelessWidget {
  const _StorageUsageCard({this.user});

  final Map<String, dynamic>? user;

  @override
  Widget build(BuildContext context) {
    final usedBytes = (user?['storageUsedBytes'] as num?)?.toDouble() ?? 0.0;
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
                'Storage',
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
