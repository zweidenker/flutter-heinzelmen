import 'dart:convert';

import 'package:apptive_grid_core/apptive_grid_core.dart';
import 'package:apptive_grid_heinzelmen/src/data_widget/attachment/thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../attachment_image_test.dart';

void main() {
  group('Files', () {
    testWidgets('application/pdf shows pdf file', (tester) async {
      final target = MaterialApp(
        home: SizedBox(
          width: 70,
          height: 70,
          child: Thumbnail(
            attachment: Attachment(
              name: 'pdf',
              url: Uri(path: '/attachmentPath'),
              type: 'application/pdf',
            ),
          ),
        ),
      );

      await tester.pumpWidget(target);

      expect(
        find.descendant(
          of: find.byType(Thumbnail),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });
  });

  group('Images', () {
    testWidgets('Error shows File Paint', (tester) async {
      final target = MaterialApp(
        home: SizedBox(
          width: 70,
          height: 70,
          child: Thumbnail(
            attachment: Attachment(
              name: 'png',
              url: Uri.parse('https://image.com/uri'),
              type: 'image/png',
            ),
          ),
        ),
      );

      await tester.pumpWidget(target);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(Image),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Shows image from url', (tester) async {
      await mockNetworkImages(() async {
        final target = MaterialApp(
          home: SizedBox(
            width: 70,
            height: 70,
            child: Thumbnail(
              attachment: Attachment(
                name: 'png',
                url: Uri(path: '/uri'),
                type: 'image/png',
              ),
            ),
          ),
        );

        await tester.pumpWidget(target);

        final imageUrl = ((find.byType(Image).evaluate().first.widget as Image)
                .image as NetworkImage)
            .url;
        expect(imageUrl, '/uri');
      });
    });

    testWidgets('Shows image from large thumbnail', (tester) async {
      await mockNetworkImages(() async {
        final target = MaterialApp(
          home: SizedBox(
            width: 70,
            height: 70,
            child: Thumbnail(
              attachment: Attachment(
                name: 'png',
                url: Uri(path: '/uri'),
                largeThumbnail: Uri(path: '/largeThumbnailUri'),
                type: 'image/png',
              ),
            ),
          ),
        );

        await tester.pumpWidget(target);

        final imageUrl = ((find.byType(Image).evaluate().first.widget as Image)
                .image as NetworkImage)
            .url;
        expect(imageUrl, '/largeThumbnailUri');
      });
    });

    testWidgets('Shows image from small thumbnail', (tester) async {
      await mockNetworkImages(() async {
        final target = MaterialApp(
          home: SizedBox(
            width: 70,
            height: 70,
            child: Thumbnail(
              attachment: Attachment(
                name: 'png',
                url: Uri(path: '/uri'),
                largeThumbnail: Uri(path: '/largeThumbnailUri'),
                smallThumbnail: Uri(path: '/smallThumbnailUri'),
                type: 'image/png',
              ),
            ),
          ),
        );

        await tester.pumpWidget(target);

        final imageUrl = ((find.byType(Image).evaluate().first.widget as Image)
                .image as NetworkImage)
            .url;
        expect(imageUrl, '/smallThumbnailUri');
      });
    });
  });

  group('SVG Images', () {
    testWidgets('Shows image from url', (tester) async {
      const uri = 'https://attachment.svg';
      await mockNetworkImages(images: {
        Uri.parse(uri): base64Decode(
          '''PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNyI+CjxwYXRoIGZpbGw9IiMwRkZGMDAiIHN0cm9rZT0iIzBGMEYwMCIgc3Ryb2tlLXdpZHRoPSIwIiBkPSJtNCw0djloOVY0eiIvPgo8L3N2Zz4=''',
        ),
      }, () async {
        final target = MaterialApp(
          home: SizedBox(
            width: 70,
            height: 70,
            child: Thumbnail(
              attachment: Attachment(
                name: 'svg',
                url: Uri.parse(uri),
                type: 'image/svg+xml',
              ),
            ),
          ),
        );

        await tester.pumpWidget(target);

        final imageUrl =
            ((find.byType(SvgPicture).evaluate().first.widget as SvgPicture)
                    .bytesLoader as SvgNetworkLoader)
                .url;
        expect(imageUrl, uri);
      });
    });

    testWidgets('Ingores thumbnail', (tester) async {
      const uri = 'https://attachment.svg2';
      await mockNetworkImages(images: {
        Uri.parse(uri): base64Decode(
          '''PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNyI+CjxwYXRoIGZpbGw9IiMwRkZGMDAiIHN0cm9rZT0iIzBGMEYwMCIgc3Ryb2tlLXdpZHRoPSIwIiBkPSJtNCw0djloOVY0eiIvPgo8L3N2Zz4=''',
        ),
      }, () async {
        final target = MaterialApp(
          home: SizedBox(
            width: 70,
            height: 70,
            child: Thumbnail(
              attachment: Attachment(
                name: 'svg',
                url: Uri.parse(uri),
                largeThumbnail:
                    Uri.parse('https://image.com/largeThumbnailUri'),
                smallThumbnail:
                    Uri.parse('https://image.com/smallThumbnailUri'),
                type: 'image/svg+xml',
              ),
            ),
          ),
        );

        await tester.pumpWidget(target);

        final imageUrl =
            ((find.byType(SvgPicture).evaluate().first.widget as SvgPicture)
                    .bytesLoader as SvgNetworkLoader)
                .url;
        expect(imageUrl, uri);
      });
    });
  });
}
