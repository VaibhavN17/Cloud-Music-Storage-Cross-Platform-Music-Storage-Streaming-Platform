/// Search screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  bool _hasQuery = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              onChanged: (v) => setState(() => _hasQuery = v.isNotEmpty),
              decoration: InputDecoration(
                hintText: 'Search tracks, artists, albums...',
                prefixIcon: const Icon(Iconsax.search_normal_1, size: 20),
                suffixIcon: _hasQuery
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _hasQuery = false);
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Content
          Expanded(
            child: _hasQuery ? _buildResults() : _buildBrowse(),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowse() {
    final categories = [
      ('Genres', Iconsax.music, const Color(0xFF2E6BFF)),
      ('Moods', Iconsax.emoji_happy, const Color(0xFFFF6B4A)),
      ('Recently Searched', Iconsax.clock, const Color(0xFF2ECC71)),
      ('Trending', Iconsax.trend_up, const Color(0xFFF5A623)),
      ('New Releases', Iconsax.flash_1, const Color(0xFF9B59B6)),
      ('Top Artists', Iconsax.people, const Color(0xFFE91E63)),
    ];

    return GridView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingMobile,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.isMobile ? 2 : 3,
        crossAxisSpacing: AppSpacing.gridGap,
        mainAxisSpacing: AppSpacing.gridGap,
        childAspectRatio: 1.6,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final (label, icon, color) = categories[index];
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.cardRadius,
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTypography.bodySemiBold(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.search_normal_1,
            size: 64,
            color: context.appColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Search results will appear here',
            style: AppTypography.body(
              color: context.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
