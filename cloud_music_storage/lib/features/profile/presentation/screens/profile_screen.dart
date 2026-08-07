/// Profile screen.
///
/// Refactored to display truthful user profile stats without fake/demo metrics.
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
import '../../../authentication/presentation/providers/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final displayName = user?['displayName'] as String? ?? user?['email'] as String? ?? 'User';
    final email = user?['email'] as String? ?? '';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    final usedBytes = (user?['storageUsedBytes'] as num?)?.toDouble() ?? 0.0;
    final quotaBytes = (user?['storageQuotaBytes'] as num?)?.toDouble() ?? 5368709120.0;
    final progress = (quotaBytes > 0) ? (usedBytes / quotaBytes).clamp(0.0, 1.0) : 0.0;
    final usedMb = (usedBytes / (1024 * 1024)).toStringAsFixed(1);
    final quotaGb = (quotaBytes / (1024 * 1024 * 1024)).toStringAsFixed(0);

    final int trackCount = (user?['trackCount'] as num?)?.toInt() ?? 0;
    final int playlistCount = (user?['playlistCount'] as num?)?.toInt() ?? 0;
    final int favoriteCount = (user?['favoriteCount'] as num?)?.toInt() ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTypography.h2(color: context.appColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.setting_2),
            onPressed: () => context.push(RoutePaths.settings),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingMobile),
        child: Column(
          children: [
            // Avatar & user info
            const SizedBox(height: AppSpacing.lg),
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: Text(
                initial,
                style: AppTypography.display(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              displayName,
              style: AppTypography.h1(color: context.appColors.textPrimary),
            ),
            if (email.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                email,
                style: AppTypography.body(
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),

            // Truthful Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(label: 'Tracks', value: '$trackCount'),
                _StatItem(label: 'Playlists', value: '$playlistCount'),
                _StatItem(label: 'Favorites', value: '$favoriteCount'),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Storage Card
            Container(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.h2(color: context.appColors.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption(color: context.appColors.textSecondary),
        ),
      ],
    );
  }
}
