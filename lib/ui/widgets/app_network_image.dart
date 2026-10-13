import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? placeholderText;
  final IconData placeholderIcon;
  final Widget? fallbackWidget;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderText,
    this.placeholderIcon = Icons.fastfood_rounded,
    this.fallbackWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget errorWidget = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2C1E1B), const Color(0xFF1F242C)]
              : [const Color(0xFFFFECE8), const Color(0xFFF3F4F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              placeholderIcon,
              size: (height != null && height! < 80) ? 24 : 36,
              color: theme.colorScheme.primary.withAlpha(160),
            ),
            if (placeholderText != null && (height == null || height! >= 90)) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  placeholderText!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    Widget imageWidget = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF222731) : const Color(0xFFF3F4F6),
            borderRadius: borderRadius,
          ),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary.withAlpha(150),
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Gracefully return stylized fallback on stream reading / connection reset errors
        return fallbackWidget ?? errorWidget;
      },
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
