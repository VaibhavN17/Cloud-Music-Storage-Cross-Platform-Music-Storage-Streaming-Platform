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
