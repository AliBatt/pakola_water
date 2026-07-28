import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Product/storage image that works on Flutter web and mobile.
///
/// On web, [Image.network] defaults to fetching bytes for CanvasKit, which
/// fails when the Firebase Storage bucket has no CORS policy. Preferring an
/// HTML `<img>` element displays the image without requiring CORS.
class StorageNetworkImage extends StatelessWidget {
  const StorageNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.error,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? error;

  /// Kept for call sites that clear cache after deleting Storage objects.
  static void clearCache([String? url]) {}

  Widget _fallback(BuildContext context) {
    return error ??
        ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.broken_image_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: _fallback(context),
      );
    }

    final image = Image.network(
      trimmed,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
      // Critical for Flutter web + Firebase Storage without bucket CORS.
      webHtmlElementStrategy: kIsWeb
          ? WebHtmlElementStrategy.prefer
          : WebHtmlElementStrategy.never,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return placeholder ??
            ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
      },
      errorBuilder: (_, _, _) => _fallback(context),
    );

    final sized = SizedBox(
      width: width,
      height: height,
      child: image,
    );

    if (borderRadius == null) return sized;
    return ClipRRect(
      borderRadius: borderRadius!,
      child: sized,
    );
  }
}
