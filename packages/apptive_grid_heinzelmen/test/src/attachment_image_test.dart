import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:alchemist/alchemist.dart';
import 'package:apptive_grid_core/apptive_grid_core.dart';
import 'package:apptive_grid_heinzelmen/apptive_grid_heinzelmen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart' show loadAppFonts;
import 'package:mocktail/mocktail.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  final attachmentUri = Uri.parse('https://attachment.image');
  final smallThumbnailUri = Uri.parse('https://small.thumbnail');
  final largeThumbnailUri = Uri.parse('https://large.thumbnail');
  final images = {
    attachmentUri: base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M/wBwAEAwH9pVHAOwAAAABJRU5ErkJggg==',
    ),
    smallThumbnailUri: base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP0lG76AwADfwHkI/zBZQAAAABJRU5ErkJggg==',
    ),
    largeThumbnailUri: base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    ),
  };

  group('Loads Image', () {
    goldenTest(
      'Loading Widget',
      constraints: const BoxConstraints(
        maxWidth: 300,
      ),
      fileName: 'network-image-loading',
      pumpBeforeTest: pumpOnce,
      pumpWidget: (tester, widget) async {
        await mockNetworkImages(
          () async {
            await tester.pumpWidget(widget);
          },
          images: images,
        );
      },
      builder: () {
        return GoldenTestGroup(
          columnWidthBuilder: (_) => const FlexColumnWidth(),
          children: [
            GoldenTestScenario(
              name: 'Default Loading',
              child: SizedBox(
                height: 100,
                width: 100,
                child: AttachmentImage(
                  attachment: Attachment(
                    name: '',
                    url: attachmentUri,
                    type: 'image/png',
                  ),
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'Custom Loading',
              child: SizedBox(
                height: 100,
                width: 100,
                child: AttachmentImage(
                  attachment: Attachment(
                    name: '',
                    url: attachmentUri,
                    type: 'image/png',
                  ),
                  loadingWidget: Container(
                    color: Colors.pink,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    goldenTest(
      'Show Image',
      constraints: const BoxConstraints(
        maxWidth: 500,
      ),
      fileName: 'network-image-displaying',
      pumpBeforeTest: precacheImages,
      pumpWidget: (tester, widget) async {
        await mockNetworkImages(
          () async {
            await tester.pumpWidget(widget);
          },
          images: images,
        );
      },
      builder: () {
        final attachments = [
          Attachment(
            name: 'Only Image',
            url: attachmentUri,
            type: 'image/png',
          ),
          Attachment(
            name: 'With Large Thumbnail',
            url: attachmentUri,
            largeThumbnail: largeThumbnailUri,
            type: 'image/png',
          ),
          Attachment(
            name: 'With Small Thumbnail',
            url: attachmentUri,
            smallThumbnail: smallThumbnailUri,
            type: 'image/png',
          ),
          Attachment(
            name: 'With Both Thumbnails',
            url: attachmentUri,
            largeThumbnail: largeThumbnailUri,
            smallThumbnail: smallThumbnailUri,
            type: 'image/png',
          ),
        ];
        return GoldenTestGroup(
          columnWidthBuilder: (_) => const FlexColumnWidth(),
          columns: 3,
          children: [
            for (final attachment in attachments)
              for (final loadUntil in LoadUntil.values)
                GoldenTestScenario(
                  name: '${attachment.name}, $loadUntil',
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: AttachmentImage(
                      loadUntil: loadUntil,
                      attachment: attachment,
                    ),
                  ),
                ),
          ],
        );
      },
    );
  });
}

// https://github.com/felangel/mocktail/tree/main/packages/mocktail_image_network
T mockNetworkImages<T>(
  T Function() body, {
  Map<Uri, Uint8List>? images,
}) {
  return HttpOverrides.runZoned(
    body,
    createHttpClient: (_) {
      return _createHttpClient(images);
    },
  );
}

class _MockHttpClient extends Mock implements HttpClient {
  _MockHttpClient() {
    registerFallbackValue((List<int> _) {});
    registerFallbackValue(Uri());
    registerFallbackValue(Stream<List<int>>.fromIterable([]));
  }

  @override
  set autoUncompress(bool autoUncompress) {}
}

class _MockHttpClientRequest extends Mock implements HttpClientRequest {}

class _MockHttpClientResponse extends Mock implements HttpClientResponse {}

class _MockHttpHeaders extends Mock implements HttpHeaders {}

HttpClient _createHttpClient(Map<Uri, Uint8List>? images) {
  final fallbackImage = base64Decode(
    '''iVBORw0KGgoAAAANSUhEUgAAAToAAAE6CAYAAACGQp5cAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAQfSURBVHgB7dQBDYAADMCwQ/CLFdRh56BjaZNZ2HE/7w5A154DEGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5BkdkGd0QJ7RAXlGB+QZHZBndECe0QF5RgfkGR2QZ3RAntEBeUYH5F1/OwBd+wELkAhH4gq5YgAAAABJRU5ErkJggg==''',
  );

  final client = _MockHttpClient();
  when(() => client.getUrl(any())).thenAnswer((invocation) async {
    final uri = invocation.positionalArguments.first as Uri;

    final request = _MockHttpClientRequest();
    final response = _MockHttpClientResponse();
    final headers = _MockHttpHeaders();

    when(() => response.compressionState)
        .thenReturn(HttpClientResponseCompressionState.notCompressed);
    when(() => response.contentLength).thenAnswer((_) {
      return images?.values.first.length ?? fallbackImage.length;
    });
    when(() => response.statusCode).thenReturn(HttpStatus.ok);
    when(
      () => response.listen(
        any(),
        onDone: any(named: 'onDone'),
        onError: any(named: 'onError'),
        cancelOnError: any(named: 'cancelOnError'),
      ),
    ).thenAnswer((invocation) {
      final onData =
          invocation.positionalArguments[0] as void Function(List<int>);
      final onDone = invocation.namedArguments[#onDone] as void Function()?;
      return Stream<List<int>>.fromIterable(
        <List<int>>[images?[uri] ?? fallbackImage],
      ).listen(onData, onDone: onDone);
    });
    when(() => request.headers).thenReturn(headers);
    when(request.close).thenAnswer((_) async => response);

    return request;
  });

  HttpClientResponse _createResponse(Uri uri) {
  final response = _MockHttpClientResponse();
  final headers = _MockHttpHeaders();
  final data = images?[uri] ?? fallbackImage;

  when(() => response.headers).thenReturn(headers);
  when(() => response.contentLength).thenReturn(data.length);
  when(() => response.statusCode).thenReturn(HttpStatus.ok);
  when(() => response.isRedirect).thenReturn(false);
  when(() => response.redirects).thenReturn([]);
  when(() => response.persistentConnection).thenReturn(false);
  when(() => response.reasonPhrase).thenReturn('OK');
  when(
    () => response.compressionState,
  ).thenReturn(HttpClientResponseCompressionState.notCompressed);
  when(
    () => response.handleError(any(), test: any(named: 'test')),
  ).thenAnswer((_) => Stream<List<int>>.value(data));
  when(
    () => response.listen(
      any(),
      onDone: any(named: 'onDone'),
      onError: any(named: 'onError'),
      cancelOnError: any(named: 'cancelOnError'),
    ),
  ).thenAnswer((invocation) {
    final onData =
        invocation.positionalArguments.first as void Function(List<int>);
    final onDone = invocation.namedArguments[#onDone] as void Function()?;
    return Stream<List<int>>.fromIterable(
      <List<int>>[data],
    ).listen(onData, onDone: onDone);
  });
  return response;
}

  HttpClientRequest _createRequest(Uri uri) {
    final request = _MockHttpClientRequest();
    final headers = _MockHttpHeaders();

    when(() => request.headers).thenReturn(headers);
    when(
      () => request.addStream(any()),
    ).thenAnswer((invocation) {
      final stream = invocation.positionalArguments.first as Stream<List<int>>;
      return stream.fold<List<int>>(
        <int>[],
        (previous, element) => previous..addAll(element),
      );
    });
    when(
      request.close,
    ).thenAnswer((_) async => _createResponse(uri));

    return request;
  }

  

  when(() => client.openUrl(any(), any())).thenAnswer(
    (invokation) async => _createRequest(
      invokation.positionalArguments.last as Uri,
    ),
  );

  return client;
}
