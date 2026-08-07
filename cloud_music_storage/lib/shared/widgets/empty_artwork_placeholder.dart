/// Consistent empty artwork placeholder widget.
library;

import 'package:flutter/material.dart';
import '../../core/extensions/theme_extension.dart';
import '../../core/theme/app_radius.dart';

class EmptyArtworkPlaceholder extends StatelessWidget {
  const EmptyArtworkPlaceholder({
    super.key,
    this.size = 48.0,
    this.iconSize = 24.0,
    this.borderRadius,
  });

  final double size;
  final double iconSize;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.appColors.surfaceVariant,
        borderRadius: borderRadius ?? AppRadius.imageRadius,
      ),
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          size: iconSize,
          color: context.appColors.textTertiary,
        ),
      ),
    );
  }
}
