import 'package:flutter/material.dart';

class BrandMark extends StatelessWidget {
  final bool compact;
  final double? height;
  final double? maxWidth;
  final AlignmentGeometry alignment;

  const BrandMark({
    super.key,
    this.compact = false,
    this.height,
    this.maxWidth,
    this.alignment = Alignment.centerLeft,
  });

  static const String _logoAsset = 'assets/icon/app_icon.png';

  @override
  Widget build(BuildContext context) {
    final resolvedHeight = height ?? (compact ? 48.0 : 138.0);
    final resolvedMaxWidth = maxWidth ?? (compact ? 58.0 : 154.0);

    return Semantics(
      image: true,
      label: 'DCX Online Store official logo',
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: resolvedMaxWidth,
          maxHeight: resolvedHeight,
        ),
        child: Image.asset(
          _logoAsset,
          height: resolvedHeight,
          fit: BoxFit.contain,
          alignment: alignment,
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}
