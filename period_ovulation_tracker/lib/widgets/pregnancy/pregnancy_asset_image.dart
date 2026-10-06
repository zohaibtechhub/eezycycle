import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';

/// Renders pregnancy assets that may be SVG (size fruits) or raster (baby/body).
class PregnancyAssetImage extends StatelessWidget {
  final String? path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final IconData fallbackIcon;
  final Color? backgroundColor;

  const PregnancyAssetImage({
    super.key,
    required this.path,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.fallbackIcon = Icons.eco_rounded,
    this.backgroundColor,
  });

  bool get _isSvg =>
      path != null && path!.toLowerCase().endsWith('.svg');

  Widget _fallback(Color bg) {
    final child = Center(child: Icon(fallbackIcon, color: AppColors.pregnancy));
    if (bg.a == 0) return child;
    return ColoredBox(color: bg, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Colors.white;
    if (path == null || path!.isEmpty) return _fallback(bg);

    if (_isSvg) {
      final svg = Padding(
        padding: const EdgeInsets.all(8),
        child: SvgPicture.asset(
          path!,
          fit: fit,
          width: width,
          height: height,
          placeholderBuilder: (_) =>
              Center(child: Icon(fallbackIcon, color: AppColors.pregnancy)),
        ),
      );
      if (bg.a == 0) return svg;
      return ColoredBox(color: bg, child: svg);
    }

    return Image.asset(
      path!,
      fit: fit == BoxFit.contain ? BoxFit.cover : fit,
      width: width,
      height: height,
      errorBuilder: (_, _, _) => _fallback(bg),
    );
  }
}
