import 'package:apptive_grid_core/apptive_grid_core.dart';
import 'package:flutter/material.dart';

/// A Widget to show an [attachment] as a Image
class AttachmentImage extends StatelessWidget {
  /// Creates a new Widget to display [attachment]
  const AttachmentImage({
    super.key,
    required this.attachment,
    this.loadUntil = LoadUntil.full,
    this.loadingWidget,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  /// The [attachment] that should be shown
  final Attachment attachment;

  /// The level that should be loaded. e.g if the displayed widget will be quite small it might be enough to only [LoadUnit.small] to just load the small thumbnail
  /// If [loadUntil] is [LoadUntil.small] or [LoadUntil.large] and the respective size is not present in [attachment] it will load the next available bigger size.
  /// So for [LoadUntil.large] it will load the full image
  /// For [LoadUntil.small] it will load the largeThumbnail. If that is also `null` it will load the full image
  final LoadUntil loadUntil;

  /// Image that should be shown while loading. If this is `null` [CircularProgressIndicator.adaptive()] will be shown
  final Widget? loadingWidget;

  /// The [BoxFit] for the Image
  final BoxFit fit;

  ///
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  @override
  Widget build(BuildContext context) {
    final smallThumbnail = attachment.smallThumbnail != null
        ? _NetworkImageWithBuilder(
            url: attachment.smallThumbnail!.toString(),
            fit: fit,
            errorBuilder: errorBuilder,
            loadingWidget: loadingWidget,
          )
        : loadingWidget;

    final largeThumbnail = attachment.largeThumbnail != null
        ? _NetworkImageWithBuilder(
            url: attachment.largeThumbnail!.toString(),
            fit: fit,
            errorBuilder: errorBuilder,
            loadingWidget: smallThumbnail,
          )
        : attachment.smallThumbnail != null
            ? smallThumbnail
            : loadingWidget;

    final fullImage = _NetworkImageWithBuilder(
      url: attachment.url.toString(),
      fit: fit,
      errorBuilder: errorBuilder,
      loadingWidget: largeThumbnail,
    );

    switch (loadUntil) {
      case LoadUntil.full:
        return fullImage;
      case LoadUntil.large:
        return largeThumbnail ?? fullImage;
      case LoadUntil.small:
        return smallThumbnail ?? largeThumbnail ?? fullImage;
    }
  }
}

class _NetworkImageWithBuilder extends StatelessWidget {
  const _NetworkImageWithBuilder({
    required this.url,
    this.loadingWidget,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  final String url;

  final Widget? loadingWidget;

  final BoxFit fit;

  /// See [Image.errorBuilder] for details
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      errorBuilder: errorBuilder,
      loadingBuilder: (_, child, progress) {
        if (progress == null) {
          return child;
        } else if (loadingWidget != null) {
          return loadingWidget!;
        } else {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }
      },
    );
  }
}

/// Determine up to which state the image will be loaded
enum LoadUntil {
  /// The full image will be loaded
  full,

  /// It will be loaded until the large thumbnail is loaded
  large,

  /// It will be loaded until the small thumbnail is loaded
  small
}
