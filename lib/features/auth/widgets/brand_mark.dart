import 'package:flutter/material.dart';

class BrandMark extends StatelessWidget {
  final bool compact;

  const BrandMark({
    super.key,
    this.compact = false,
  });

  static const String _logoAsset = 'assets/icon/app_icon.png';

  @override
  Widget build(BuildContext context) {
    final height = compact ? 48.0 : 138.0;
    final maxWidth = compact ? 58.0 : 154.0;

    return Semantics(
      image: true,
      label: 'DCX Online Store official logo',
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: height,
        ),
        child: Image.asset(
          _logoAsset,
          height: height,
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}
