/// Library screen — file manager for user's music collection.
///
/// Fully reactive frontend integrated with tracksProvider and playerProvider.
/// Supports tap-to-play, optimistic favorite toggle, track deletion, and state lifecycle.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/enums/view_state.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/track_model.dart';
import '../../../../shared/providers/tracks_provider.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../player/presentation/providers/player_provider.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  bool _isGridView = false;
  String _sortBy = 'Date Added';
  String _activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final tracksState = ref.watch(tracksProvider);
    final allTracks = tracksState.tracks;

    List<TrackModel> filteredTracks = List.from(allTracks);
    if (_activeFilter == 'Favorites') {
      filteredTracks = filteredTracks.where((t) => t.isFavorite).toList();
    }

    // Sort tracks
    if (_sortBy == 'Name') {
      filteredTracks.sort((a, b) => a.title.compareTo(b.title));
    } else if (_sortBy == 'Artist') {
      filteredTracks.sort((a, b) => a.displayArtist.compareTo(b.displayArtist));
    } else if (_sortBy == 'Size') {
      filteredTracks.sort((a, b) => b.fileSizeBytes.compareTo(a.fileSizeBytes));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Library',
          style: AppTypography.h2(color: context.appColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Iconsax.element_3 : Iconsax.row_vertical,
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Iconsax.sort),
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (context) => [
              'Date Added', 'Name', 'Artist', 'Size',
            ].map((s) => PopupMenuItem(
              value: s,
              child: Row(
                children: [
                  if (s == _sortBy) ...[
                    const Icon(Icons.check, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                  ] else
                    const SizedBox(width: 26),
                  Text(s),
                ],
              ),
            )).toList(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingMobile,
              ),
              children: [
                _FolderChip(
                  label: 'All (${allTracks.length})',
                  isSelected: _activeFilter == 'All',
                  onTap: () => setState(() => _activeFilter = 'All'),
                ),
                _FolderChip(
                  label: 'Favorites (${allTracks.where((t) => t.isFavorite).length})',
                  isSelected: _activeFilter == 'Favorites',
                  onTap: () => setState(() => _activeFilter = 'Favorites'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Content List
          Expanded(
            child: _buildBody(tracksState.viewState, filteredTracks),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ViewState viewState, List<TrackModel> tracks) {
    if (viewState == ViewState.loading) {
      return ListView.builder(
        itemCount: 6,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPaddingMobile,
        ),
        itemBuilder: (context, index) => const SkeletonTrackTile(),
      );
    }

    if (tracks.isEmpty) {
      return AppEmptyState(
        type: _activeFilter == 'Favorites'
            ? EmptyStateType.favorites
            : EmptyStateType.library,
      );
    }

    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingMobile),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final track = tracks[index];
          return _TrackGridTile(
            track: track,
            onTap: () => _playTrack(track, tracks, index),
            onFavoriteToggle: () => ref.read(tracksProvider.notifier).toggleFavorite(track.id),
          );
        },
      );
    }

    return ListView.separated(
      itemCount: tracks.length,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingMobile,
      ),
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final track = tracks[index];
        return ListTile(
          onTap: () => _playTrack(track, tracks, index),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.appColors.surfaceVariant,
              borderRadius: AppRadius.imageRadius,
            ),
            child: const Icon(
              Icons.music_note_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          title: Text(
            track.title,
            style: AppTypography.bodySmall(color: context.appColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${track.displayArtist} • ${track.format.toUpperCase()} • ${(track.fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
            style: AppTypography.caption(color: context.appColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  track.isFavorite ? Iconsax.heart : Iconsax.heart_copy,
                  color: track.isFavorite ? AppColors.accent : context.appColors.textTertiary,
                  size: 20,
                ),
                onPressed: () => ref.read(tracksProvider.notifier).toggleFavorite(track.id),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 20),
                onSelected: (val) {
                  if (val == 'delete') {
                    ref.read(tracksProvider.notifier).deleteTrack(track.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Iconsax.trash, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Delete Track', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _playTrack(TrackModel track, List<TrackModel> queue, int index) {
    ref.read(playerProvider.notifier).playTrack(track, queue: queue, index: index);
    ref.read(tracksProvider.notifier).recordPlay(track.id);
  }
}

class _TrackGridTile extends StatelessWidget {
  const _TrackGridTile({
    required this.track,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  final TrackModel track;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.appColors.surfaceVariant,
          borderRadius: AppRadius.cardRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: context.appColors.surfaceElevated,
                  borderRadius: AppRadius.imageRadius,
                ),
                child: const Center(
                  child: Icon(
                    Icons.music_note_rounded,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    track.title,
                    style: AppTypography.bodySmall(color: context.appColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: onFavoriteToggle,
                  child: Icon(
                    track.isFavorite ? Iconsax.heart : Iconsax.heart_copy,
                    color: track.isFavorite ? AppColors.accent : context.appColors.textTertiary,
                    size: 18,
                  ),
                ),
              ],
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
  }
}

class _FolderChip extends StatelessWidget {
  const _FolderChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: context.appColors.surfaceVariant,
        labelStyle: TextStyle(
          fontSize: 13,
          color: isSelected ? Colors.white : context.appColors.textPrimary,
        ),
      ),
    );
  }
}
