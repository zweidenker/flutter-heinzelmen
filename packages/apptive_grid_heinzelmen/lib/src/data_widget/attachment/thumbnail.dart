import 'package:apptive_grid_core/apptive_grid_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

part 'package:apptive_grid_heinzelmen/src/data_widget/attachment/type_map.dart';

/// A Thumbnail for an [Attachment]
class Thumbnail extends StatelessWidget {
  /// Creates a Thumbnail Widget for a given [attachment]
  /// If [addAttachmentAction] is not null it will be used to create Image Thumbnails from [AddAttachmentAction.path] or [AddAttachmentAction.byteData]
  ///
  /// If an image Thumbnail can not be loaded or the [Attachment.type] does not indicate that this is an image a File Icon with a file ending will be used to display
  const Thumbnail({
    super.key,
    required this.attachment,
  });

  /// The Attachment to display a Thumbnail for
  final Attachment attachment;

  @override
  Widget build(BuildContext context) {
    final fallback = Center(
      child: SizedBox(
        height: 24,
        width: 24,
        child: _FileIcon(type: attachment.type),
      ),
    );

    // svg Pictures
    if (attachment.type.contains('svg')) {
      return SvgPicture.network(
        attachment.url.toString(),
        fit: BoxFit.contain,
        placeholderBuilder: (_) => fallback,
      );
    }

    // Images
    if (attachment.type.startsWith('image/')) {
      return Image.network(
        (attachment.smallThumbnail ??
                attachment.largeThumbnail ??
                attachment.url)
            .toString(),
        fit: BoxFit.contain,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
            frame == null ? fallback : child,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    // Other Files
    return fallback;
  }
}

class _FileIcon extends StatelessWidget {
  const _FileIcon({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FileIconPainter(
        color: Theme.of(context).colorScheme.primary,
        type: type,
      ),
    );
  }
}

class _FileIconPainter extends CustomPainter {
  const _FileIconPainter({required this.color, required this.type});

  final Color color;
  final String type;

  @override
  void paint(Canvas canvas, Size size) {
    // Generated from https://fluttershapemaker.com/

    Path filePath = Path();
    filePath.moveTo(size.width * 0.1978720, size.height * 0.9648120);
    filePath.cubicTo(
      size.width * 0.1792800,
      size.height * 0.9648120,
      size.width * 0.1630120,
      size.height * 0.9578400,
      size.width * 0.1490680,
      size.height * 0.9438960,
    );
    filePath.cubicTo(
      size.width * 0.1351220,
      size.height * 0.9299520,
      size.width * 0.1281500,
      size.height * 0.9136820,
      size.width * 0.1281500,
      size.height * 0.8950880,
    );
    filePath.lineTo(size.width * 0.1281500, size.height * 0.1049100);
    filePath.cubicTo(
      size.width * 0.1281500,
      size.height * 0.08631800,
      size.width * 0.1351220,
      size.height * 0.07004800,
      size.width * 0.1490680,
      size.height * 0.05610400,
    );
    filePath.cubicTo(
      size.width * 0.1630120,
      size.height * 0.04216000,
      size.width * 0.1792800,
      size.height * 0.03518800,
      size.width * 0.1978720,
      size.height * 0.03518800,
    );
    filePath.lineTo(size.width * 0.6173660, size.height * 0.03518800);
    filePath.lineTo(size.width * 0.8718500, size.height * 0.2896720);
    filePath.lineTo(size.width * 0.8718500, size.height * 0.8950880);
    filePath.cubicTo(
      size.width * 0.8718500,
      size.height * 0.9136820,
      size.width * 0.8648780,
      size.height * 0.9299520,
      size.width * 0.8509300,
      size.height * 0.9438960,
    );
    filePath.cubicTo(
      size.width * 0.8369860,
      size.height * 0.9578400,
      size.width * 0.8207200,
      size.height * 0.9648120,
      size.width * 0.8021280,
      size.height * 0.9648120,
    );
    filePath.lineTo(size.width * 0.1978720, size.height * 0.9648120);
    filePath.close();
    filePath.moveTo(size.width * 0.5825040, size.height * 0.3210480);
    filePath.lineTo(size.width * 0.5825040, size.height * 0.1049100);
    filePath.lineTo(size.width * 0.1978720, size.height * 0.1049100);
    filePath.lineTo(size.width * 0.1978720, size.height * 0.8950880);
    filePath.lineTo(size.width * 0.8021280, size.height * 0.8950880);
    filePath.lineTo(size.width * 0.8021280, size.height * 0.3210480);
    filePath.lineTo(size.width * 0.5825040, size.height * 0.3210480);
    filePath.close();
    filePath.moveTo(size.width * 0.1978720, size.height * 0.1049100);
    filePath.lineTo(size.width * 0.1978720, size.height * 0.3210480);
    filePath.lineTo(size.width * 0.1978720, size.height * 0.1049100);
    filePath.lineTo(size.width * 0.1978720, size.height * 0.8950880);
    filePath.lineTo(size.width * 0.1978720, size.height * 0.1049100);
    filePath.close();

    Paint fileFill = Paint()..style = PaintingStyle.fill;
    fileFill.color = color;
    canvas.drawPath(filePath, fileFill);

    final textPainter = TextPainter(
      text: TextSpan(
        text: _fileAbbreviation,
        style: TextStyle(
          color: color,
          fontSize: (size.width / (_fileAbbreviation.length)) * 0.8,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.width / 2 - textPainter.width / 2,
        size.height - textPainter.height * 1.5,
      ),
    );
  }

  // coverage:ignore-start
  @override
  bool shouldRepaint(covariant _FileIconPainter oldDelegate) {
    return color != oldDelegate.color || type != oldDelegate.type;
  }
  // coverage:ignore-end

  String get _fileAbbreviation => _typeMap[type] ?? type.split('/').last;
}
