/// Library screen — file manager for user's music collection.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  bool _isGridView = false;
  String _sortBy = 'Date Added';

  @override
  Widget build(BuildContext context) {
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
              'Date Added', 'Name', 'Artist', 'Size', 'Duration',
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
          // Folder chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingMobile,
              ),
              children: [
                _FolderChip(label: 'All', isSelected: true, onTap: () {}),
                _FolderChip(label: 'Folders', isSelected: false, onTap: () {}),
                _FolderChip(label: 'Playlists', isSelected: false, onTap: () {}),
                _FolderChip(label: 'Favorites', isSelected: false, onTap: () {}),
                _FolderChip(label: 'Trash', isSelected: false, onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Track list
          Expanded(
            child: _isGridView ? _buildGrid() : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: 15,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingMobile,
      ),
      itemBuilder: (context, index) {
        return _TrackListTile(index: index);
      },
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingMobile,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.isMobile ? 2 : context.isTablet ? 3 : 4,
        crossAxisSpacing: AppSpacing.gridGap,
        mainAxisSpacing: AppSpacing.gridGap,
        childAspectRatio: 0.85,
      ),
      itemCount: 15,
      itemBuilder: (context, index) {
        return _TrackGridCard(index: index);
      },
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
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        checkmarkColor: AppColors.primary,
        labelStyle: AppTypography.caption(
          color: isSelected ? AppColors.primary : context.appColors.textSecondary,
        ),
      ),
    );
  }
}

class _TrackListTile extends StatelessWidget {
  const _TrackListTile({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Midnight Drive', 'Sunset Boulevard', 'Ocean Waves', 'City Pulse',
      'Morning Dew', 'Starlight', 'Thunder', 'Whisper', 'Eclipse',
      'Horizon', 'Nebula', 'Aurora', 'Cascade', 'Vortex', 'Zenith',
    ];

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: context.appColors.surfaceVariant,
          borderRadius: AppRadius.imageRadius,
        ),
        child: Icon(
          Icons.music_note_rounded,
          color: context.appColors.textTertiary,
          size: 22,
        ),
      ),
      title: Text(
        titles[index % titles.length],
        style: AppTypography.bodyMedium(color: context.appColors.textPrimary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        'Artist ${index + 1} • 3:${(20 + index).toString().padLeft(2, '0')}',
        style: AppTypography.caption(color: context.appColors.textSecondary),
      ),
      trailing: IconButton(
        icon: Icon(
          Iconsax.more,
          color: context.appColors.textSecondary,
          size: 20,
        ),
        onPressed: () {
          // TODO: Show track options bottom sheet.
        },
      ),
    );
  }
}

class _TrackGridCard extends StatelessWidget {
  const _TrackGridCard({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: context.appColors.surfaceVariant,
              borderRadius: AppRadius.cardRadius,
            ),
            child: Center(
              child: Icon(
                Icons.music_note_rounded,
                color: context.appColors.textTertiary,
                size: 36,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Track ${index + 1}',
          style: AppTypography.bodySmall(
            color: context.appColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          'Artist',
          style: AppTypography.caption(
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
