/// Queue bottom sheet widget.
///
/// Shows current playing queue with drag-and-drop reordering.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/player_provider.dart';

class QueueSheet extends ConsumerWidget {
  const QueueSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final queue = playerState.queue;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: context.appColors.surfaceElevated,
        borderRadius: AppRadius.sheetTopRadius,
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.appColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Playing Queue (${queue.length})',
                  style: AppTypography.h2(color: context.appColors.textPrimary),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),

          const Divider(),

          // Queue List
          Expanded(
            child: queue.isEmpty
                ? Center(
                    child: Text(
                      'Queue is empty',
                      style: AppTypography.body(color: context.appColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    itemCount: queue.length,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final track = queue[index];
                      final isCurrent = index == playerState.currentIndex;

                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : context.appColors.surfaceVariant,
                            borderRadius: AppRadius.imageRadius,
                          ),
                          child: Icon(
                            isCurrent ? Icons.volume_up_rounded : Icons.music_note_rounded,
                            color: isCurrent ? AppColors.primary : context.appColors.textTertiary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          track.title,
                          style: AppTypography.bodySmall(
                            color: isCurrent ? AppColors.primary : context.appColors.textPrimary,
                          ).copyWith(fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          track.displayArtist,
                          style: AppTypography.caption(color: context.appColors.textSecondary),
                        ),
                        trailing: const Icon(Icons.drag_handle_rounded, size: 20),
                        onTap: () {
                          ref.read(playerProvider.notifier).playTrack(
                                track,
                                queue: queue,
                                index: index,
                              );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
