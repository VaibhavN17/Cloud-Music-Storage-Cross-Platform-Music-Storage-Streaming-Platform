/// Profile screen.
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

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            // Avatar & info
            const SizedBox(height: AppSpacing.lg),
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: Text(
                'U',
                style: AppTypography.display(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'User Name',
              style: AppTypography.h1(color: context.appColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'user@example.com',
              style: AppTypography.body(
                color: context.appColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Stats row
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(label: 'Tracks', value: '0'),
                _StatItem(label: 'Playlists', value: '0'),
                _StatItem(label: 'Followers', value: '0'),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Storage
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
                        'Storage Usage',
                        style: AppTypography.bodySemiBold(
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      Text(
                        '0 B / 5 GB',
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
                      value: 0,
                      backgroundColor: context.appColors.border,
                      color: AppColors.primary,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Menu items
            _ProfileMenuItem(
              icon: Iconsax.edit,
              label: 'Edit Profile',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Iconsax.people,
              label: 'Artist Profile',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Iconsax.notification,
              label: 'Notifications',
              onTap: () => context.push(RoutePaths.notifications),
            ),
            _ProfileMenuItem(
              icon: Iconsax.setting_2,
              label: 'Settings',
              onTap: () => context.push(RoutePaths.settings),
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
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.caption(
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(
        label,
        style: AppTypography.body(color: context.appColors.textPrimary),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: context.appColors.textTertiary,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
    );
  }
}
