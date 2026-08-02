/// Settings screen.
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
import '../../../../core/theme/theme_provider.dart';
import '../../../authentication/presentation/providers/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: AppTypography.h2(color: context.appColors.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPaddingMobile,
          vertical: AppSpacing.lg,
        ),
        children: [
          // ── Appearance ──
          const _SectionHeader(title: 'Appearance'),
          _SettingsTile(
            icon: Iconsax.moon,
            title: 'Theme',
            subtitle: themeMode.name[0].toUpperCase() + themeMode.name.substring(1),
            onTap: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Playback ──
          const _SectionHeader(title: 'Playback'),
          _SettingsTile(
            icon: Iconsax.music,
            title: 'Audio Quality',
            subtitle: 'High (320 kbps)',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Iconsax.timer_1,
            title: 'Crossfade',
            subtitle: 'Off',
            onTap: () {},
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Downloads ──
          const _SectionHeader(title: 'Downloads'),
          _SettingsTile(
            icon: Iconsax.arrow_down_2,
            title: 'Download Quality',
            subtitle: 'Original',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Iconsax.wifi,
            title: 'Wi-Fi Only',
            subtitle: 'Download using Wi-Fi only',
            trailing: Switch.adaptive(
              value: true,
              onChanged: (_) {},
              activeTrackColor: AppColors.primary,
            ),
            onTap: () {},
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Account ──
          const _SectionHeader(title: 'Account'),
          _SettingsTile(
            icon: Iconsax.shield_tick,
            title: 'Privacy & Security',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Iconsax.notification,
            title: 'Notifications',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Iconsax.cloud,
            title: 'Storage',
            subtitle: '1.2 GB used of 5 GB',
            onTap: () {},
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── About ──
          const _SectionHeader(title: 'About'),
          _SettingsTile(
            icon: Iconsax.info_circle,
            title: 'About',
            subtitle: 'Version 0.1.0',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Iconsax.document_text,
            title: 'Terms of Service',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Iconsax.shield_cross,
            title: 'DMCA Policy',
            onTap: () {},
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Logout
          Center(
            child: TextButton.icon(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) {
                  context.go(RoutePaths.login);
                }
              },
              icon: const Icon(Iconsax.logout, color: AppColors.error, size: 20),
              label: Text(
                'Log Out',
                style: AppTypography.bodySemiBold(color: AppColors.error),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Delete account
          Center(
            child: TextButton(
              onPressed: () {
                // TODO: Account deletion flow.
              },
              child: Text(
                'Delete Account',
                style: AppTypography.caption(
                  color: context.appColors.textTertiary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.overline(
          color: context.appColors.textTertiary,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(
        title,
        style: AppTypography.body(color: context.appColors.textPrimary),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTypography.caption(
                color: context.appColors.textSecondary,
              ),
            )
          : null,
      trailing: trailing ??
          Icon(
            Icons.chevron_right_rounded,
            color: context.appColors.textTertiary,
          ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
    );
  }
}
