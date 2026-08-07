/// Notifications screen.
///
/// Refactored to follow production state strategy: uses AppEmptyState.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_empty_state.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifications',
          style: AppTypography.h2(color: context.appColors.textPrimary),
        ),
      ),
      body: const AppEmptyState(
        type: EmptyStateType.notifications,
      ),
    );
  }
}
