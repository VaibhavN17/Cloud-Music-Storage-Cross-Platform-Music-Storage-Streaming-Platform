/// Shimmer loading placeholder components.
library;

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/extensions/theme_extension.dart';
import '../../core/theme/app_radius.dart';

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.appColors.shimmerBase,
      highlightColor: context.appColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.appColors.shimmerBase,
          borderRadius: borderRadius ?? AppRadius.cardRadius,
        ),
      ),
    );
  }
}

class SkeletonTrackTile extends StatelessWidget {
  const SkeletonTrackTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SkeletonLoader(width: 48, height: 48, borderRadius: AppRadius.imageRadius),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(width: double.infinity, height: 14, borderRadius: AppRadius.chipRadius),
                const SizedBox(height: 6),
                SkeletonLoader(width: 120, height: 10, borderRadius: AppRadius.chipRadius),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonPlaylistCard extends StatelessWidget {
  const SkeletonPlaylistCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(width: 140, height: 140, borderRadius: AppRadius.cardRadius),
          const SizedBox(height: 8),
          SkeletonLoader(width: 100, height: 12, borderRadius: AppRadius.chipRadius),
          const SizedBox(height: 4),
          SkeletonLoader(width: 60, height: 10, borderRadius: AppRadius.chipRadius),
        ],
      ),
    );
  }
}

class SkeletonHeroCard extends StatelessWidget {
  const SkeletonHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surfaceVariant,
        borderRadius: AppRadius.cardRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SkeletonLoader(width: 72, height: 72, borderRadius: BorderRadius.circular(36)),
          const SizedBox(height: 16),
          SkeletonLoader(width: 180, height: 14, borderRadius: AppRadius.chipRadius),
        ],
      ),
    );
  }
}
