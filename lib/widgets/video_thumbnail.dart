import 'package:flutter/material.dart';

import '../core/config/env.dart';
import '../core/theme/app_colors.dart';

/// Displays a video's signed CDN [thumbnailUrl] when available, falling back
/// cleanly to a bundled static image ([fallbackAsset]) when the URL is null,
/// empty, or fails to load.
class VideoThumbnail extends StatelessWidget {
  const VideoThumbnail({
    super.key,
    required this.thumbnailUrl,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.showPlayBadge = true,
    this.fit = BoxFit.cover,
    this.fallbackAsset = defaultFallbackAsset,
  });

  static const String defaultFallbackAsset = 'assets/images/tks-banner2.jpg';

  final String? thumbnailUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool showPlayBadge;
  final BoxFit fit;
  final String fallbackAsset;

  static String? resolveUrl(String? rawUrl) {
    final trimmed = rawUrl?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('/')) {
      try {
        final base = Env.apiBaseUrl.trim();
        if (base.isNotEmpty) {
          return Uri.parse(base).resolve(trimmed).toString();
        }
      } catch (_) {
        // Env may not be initialized in isolated widget tests.
      }
    }
    return trimmed;
  }

  Widget _buildFallback() {
    return Image.asset(
      fallbackAsset,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => Container(
        width: width,
        height: height,
        color: AppColors.primaryLight,
        alignment: Alignment.center,
        child: const Icon(
          Icons.play_circle_outline_rounded,
          color: AppColors.primaryDark,
          size: 28,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = resolveUrl(thumbnailUrl);

    Widget image = resolvedUrl == null
        ? _buildFallback()
        : Image.network(
            resolvedUrl,
            width: width,
            height: height,
            fit: fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Stack(
                fit: StackFit.passthrough,
                children: [
                  _buildFallback(),
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.25),
                    ),
                  ),
                ],
              );
            },
            errorBuilder: (_, _, _) => _buildFallback(),
          );

    if (showPlayBadge) {
      image = Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.center,
        children: [
          image,
          Positioned.fill(
            child: ColoredBox(color: Colors.black.withValues(alpha: 0.22)),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.58),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: image,
      ),
    );
  }
}

