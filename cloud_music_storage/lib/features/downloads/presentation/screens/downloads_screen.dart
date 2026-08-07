/// Downloads screen.
///
/// Refactored to follow production state strategy: uses AppEmptyState with direct CTA.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_empty_state.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Downloads',
          style: AppTypography.h2(color: context.appColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.setting_2),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: const AppEmptyState(
        type: EmptyStateType.downloads,
      ),
    );
  }
}
