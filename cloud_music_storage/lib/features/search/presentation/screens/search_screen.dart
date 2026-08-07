/// Search screen.
///
/// Fully reactive search filtering over user's tracks library.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/track_model.dart';
import '../../../../shared/providers/tracks_provider.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../player/presentation/providers/player_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tracksState = ref.watch(tracksProvider);
    final allTracks = tracksState.tracks;

    final queryClean = _query.trim().toLowerCase();
    final searchResults = queryClean.isEmpty
        ? <TrackModel>[]
        : allTracks.where((t) {
            final titleMatch = t.title.toLowerCase().contains(queryClean);
            final artistMatch = t.displayArtist.toLowerCase().contains(queryClean);
            final albumMatch = (t.album ?? '').toLowerCase().contains(queryClean);
            final genreMatch = (t.genre ?? '').toLowerCase().contains(queryClean);
            return titleMatch || artistMatch || albumMatch || genreMatch;
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search',
          style: AppTypography.h2(color: context.appColors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPaddingMobile,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search songs, artists, albums, playlists...',
                prefixIcon: const Icon(Iconsax.search_normal_1, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Search Content Body
          Expanded(
            child: queryClean.isEmpty
                ? const AppEmptyState(type: EmptyStateType.searchPrompt)
                : searchResults.isEmpty
                    ? const AppEmptyState(type: EmptyStateType.noSearchResults)
                    : ListView.separated(
                        itemCount: searchResults.length,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPaddingMobile,
                        ),
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final track = searchResults[index];
                          return ListTile(
                            onTap: () {
                              ref.read(playerProvider.notifier).playTrack(
                                    track,
                                    queue: searchResults,
                                    index: index,
                                  );
                            },
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
                              style: AppTypography.bodySmall(
                                  color: context.appColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${track.displayArtist} • ${track.format.toUpperCase()}',
                              style: AppTypography.caption(
                                  color: context.appColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                track.isFavorite ? Iconsax.heart : Iconsax.heart_copy,
                                color: track.isFavorite ? AppColors.accent : context.appColors.textTertiary,
                                size: 20,
                              ),
                              onPressed: () => ref.read(tracksProvider.notifier).toggleFavorite(track.id),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
