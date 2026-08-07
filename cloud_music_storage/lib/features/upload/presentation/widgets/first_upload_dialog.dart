/// First upload success celebration dialog.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';

class FirstUploadSuccessDialog extends StatelessWidget {
  const FirstUploadSuccessDialog({
    super.key,
    required this.trackTitle,
    required this.onPlayPressed,
  });

  final String trackTitle;
  final VoidCallback onPlayPressed;

  static Future<void> show(
    BuildContext context, {
    required String trackTitle,
    required VoidCallback onPlayPressed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FirstUploadSuccessDialog(
        trackTitle: trackTitle,
        onPlayPressed: onPlayPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardRadius,
      ),
      backgroundColor: context.appColors.surfaceElevated,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebration Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Iconsax.flash_1,
                  size: 36,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              '🎉 You\'re all set!',
              style: AppTypography.h1(color: context.appColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Your first song "$trackTitle" has been uploaded.',
              style: AppTypography.bodySmall(color: context.appColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Features Checklist
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.appColors.surfaceVariant,
                borderRadius: AppRadius.chipRadius,
              ),
              child: const Column(
                children: [
                  _FeatureCheckRow(label: 'Stream anywhere across your devices'),
                  SizedBox(height: 8),
                  _FeatureCheckRow(label: 'Create custom playlists & favorites'),
                  SizedBox(height: 8),
                  _FeatureCheckRow(label: 'Download for offline listening'),
                  SizedBox(height: 8),
                  _FeatureCheckRow(label: 'Background & lock screen controls'),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // CTA Buttons
            AppButton(
              text: 'Play Now',
              onPressed: () {
                context.pop();
                onPlayPressed();
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Close',
                style: AppTypography.caption(color: context.appColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCheckRow extends StatelessWidget {
  const _FeatureCheckRow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.success),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTypography.caption(color: context.appColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
