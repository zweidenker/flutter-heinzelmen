import 'package:alchemist/alchemist.dart';
import 'package:apptive_grid_core/apptive_grid_core.dart';
import 'package:apptive_grid_heinzelmen/apptive_grid_heinzelmen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart' show loadAppFonts;
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

import '../infra/mocks.dart';
import 'attachment_image_test.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
    initializeDateFormatting(const Locale('en').toString());
    initializeDateFormatting(const Locale('de').toString());
  });

  group('Golden Tests', () {
    final attachmentUri = Uri.parse('https://attachment.image');
    final smallThumbnailUri = Uri.parse('https://small.thumbnail');
    final largeThumbnailUri = Uri.parse('https://large.thumbnail');

    goldenTest(
      'Show Image',
      constraints: const BoxConstraints(
        maxWidth: 500,
      ),
      fileName: 'testing-working-test-in-different-file',
      pumpBeforeTest: precacheImages,
      pumpWidget: (tester, widget) async {
        await mockNetworkImages(
          () async {
            await tester.pumpWidget(widget);
          },
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

    goldenTest(
      'Attachment Thumbnails',
      fileName: 'data-widget-attachment',
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      pumpBeforeTest: precacheImages,
      pumpWidget: (tester, widget) async {
        await mockNetworkImages(
          () async {
            await tester.pumpWidget(widget);
          },
        );
      },
      builder: () {
        return GoldenTestGroup(
          columns: 2,
          columnWidthBuilder: (_) => const FlexColumnWidth(),
          children: [
            GoldenTestScenario(
              name: 'Image',
              child: DataWidget(
                data: AttachmentDataEntity([
                  Attachment(
                    name: 'Thumbnail Image',
                    url: attachmentUri,
                    smallThumbnail: smallThumbnailUri,
                    largeThumbnail: largeThumbnailUri,
                    type: 'image/png',
                  ),
                ]),
              ),
            ),
            GoldenTestScenario(
              name: 'Pdf',
              child: DataWidget(
                data: AttachmentDataEntity([
                  Attachment(
                    name: 'File',
                    url: Uri.parse('https://attachment.uri'),
                    type: 'application/pdf',
                  ),
                ]),
              ),
            ),
          ],
        );
      },
    );

    goldenTest(
      'Created By',
      fileName: 'data-widget-created-by',
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      pumpBeforeTest: precacheImages,
      pumpWidget: (tester, widget) async {
        await mockNetworkImages(
          () async {
            await tester.pumpWidget(widget);
            await tester.pumpAndSettle();
          },
        );
      },
      builder: () {
        return GoldenTestGroup(
          columns: 2,
          columnWidthBuilder: (_) => const FlexColumnWidth(),
          children: [
            GoldenTestScenario(
              name: 'User',
              child: DataWidget(
                data: CreatedByDataEntity(
                  const CreatedBy(
                    type: CreatedByType.user,
                    displayValue: 'Jane Doe',
                    name: 'user@mail.de',
                    id: 'userId',
                  ),
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'Form',
              child: DataWidget(
                data: CreatedByDataEntity(
                  const CreatedBy(
                    type: CreatedByType.formLink,
                    name: 'Form',
                    id: 'formId',
                  ),
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'Api Credentials',
              child: DataWidget(
                data: CreatedByDataEntity(
                  const CreatedBy(
                    type: CreatedByType.apiCredentials,
                    name: 'Api Credentials',
                    id: 'apiCredentialsId',
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    goldenTest(
      'Data Widget Display Value',
      fileName: 'data-widget',
      constraints: const BoxConstraints(
        maxWidth: 800,
      ),
      builder: () {
        return GoldenTestGroup(
          columns: 1,
          columnWidthBuilder: (_) => const FlexColumnWidth(),
          children: {
            'Default Style': null,
            'Custom TextStyle': const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            )
          }.entries.map((style) {
            return GoldenTestScenario(
              name: style.key,
              child: GoldenTestGroup(
                columns: 4,
                columnWidthBuilder: (_) => const FlexColumnWidth(),
                children: DataType.values.map<Widget>((type) {
                  late final DataEntity data;
                  switch (type) {
                    case DataType.text:
                      data = StringDataEntity('String');
                      break;
                    case DataType.dateTime:
                      data = DateTimeDataEntity(DateTime(2022, 7, 28, 10, 17));
                      break;
                    case DataType.date:
                      data = DateDataEntity(DateTime(2022, 7, 28));
                      break;
                    case DataType.integer:
                      data = IntegerDataEntity(42);
                      break;
                    case DataType.decimal:
                      data = DecimalDataEntity(47.11);
                      break;
                    case DataType.checkbox:
                      data = BooleanDataEntity(true);
                      break;
                    case DataType.singleSelect:
                      data = EnumDataEntity(
                        value: 'Value',
                        options: {'Value', 'Other Value'},
                      );
                      break;
                    case DataType.enumCollection:
                      data = EnumCollectionDataEntity(
                        value: {'Multiple', 'Values'},
                        options: {
                          'Multiple',
                          'Values',
                          'Can',
                          'Be',
                          'Selected'
                        },
                      );
                      break;
                    case DataType.crossReference:
                      data = CrossReferenceDataEntity(
                        value: 'Value',
                        gridUri: Uri.parse('https://grid.uri'),
                        entityUri: Uri.parse('https://entity.uri'),
                      );
                      break;
                    case DataType.attachment:
                      data = AttachmentDataEntity([
                        Attachment(
                          name: 'Attachment',
                          url: Uri.parse('https://attachment.uri'),
                          smallThumbnail:
                              Uri.parse('https://attachment.uri/small'),
                          largeThumbnail:
                              Uri.parse('https://attachment.uri/large'),
                          type: 'image/png',
                        ),
                      ]);
                      break;
                    case DataType.geolocation:
                      data = GeolocationDataEntity(
                        const Geolocation(
                          latitude: 47.1,
                          longitude: 11.1,
                        ),
                      );
                      break;
                    case DataType.multiCrossReference:
                      data = MultiCrossReferenceDataEntity(
                        gridUri: Uri.parse('https://grid.uri'),
                        references: [
                          CrossReferenceDataEntity(
                            value: 'Value',
                            gridUri: Uri.parse('https://grid.uri'),
                            entityUri: Uri.parse('https://entity.uri/value'),
                          ),
                          CrossReferenceDataEntity(
                            value: 'Other Value',
                            gridUri: Uri.parse('https://grid.uri'),
                            entityUri: Uri.parse('https://entity.uri/other'),
                          ),
                        ],
                      );
                      break;
                    case DataType.createdBy:
                      data = CreatedByDataEntity(
                        const CreatedBy(
                          type: CreatedByType.user,
                          displayValue: 'User',
                          id: 'userId',
                        ),
                      );
                      break;
                    case DataType.user:
                      data = UserDataEntity(
                        DataUser(
                          displayValue: 'Jane Doe',
                          uri: Uri.parse('/users/userId'),
                        ),
                      );
                      break;
                    case DataType.currency:
                      data = CurrencyDataEntity(currency: 'EUR', value: 47.11);
                      break;
                    case DataType.uri:
                      data = UriDataEntity(Uri.parse('https://uri.uri'));
                      break;
                  }

                  return GoldenTestScenario(
                    name: type.backendName,
                    child: DataWidget(
                      data: data,
                      textStyle: style.value,
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        );
      },
    );
  });

  group('Locale is Used for Widgets', () {
    testWidgets('DateTime', (tester) async {
      const locale = Locale('de');

      final target = Localizations(
        locale: locale,
        delegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate
        ],
        child: Material(
          child: DataWidget(
            data: DateTimeDataEntity(DateTime(2022, 7, 28, 12, 01)),
          ),
        ),
      );

      await tester.pumpWidget(target);
      await tester.pump();

      expect(find.text('28.7.2022 12:01'), findsOneWidget);
    });

    testWidgets('Date', (tester) async {
      const locale = Locale('de');

      final target = Localizations(
        locale: locale,
        delegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate
        ],
        child: Material(
          child: DataWidget(
            data: DateDataEntity(DateTime(2022, 7, 28)),
          ),
        ),
      );

      await tester.pumpWidget(target);
      await tester.pump();

      expect(find.text('28.7.2022'), findsOneWidget);
    });

    testWidgets('Decimal', (tester) async {
      const locale = Locale('de');

      final target = Localizations(
        locale: locale,
        delegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate
        ],
        child: Material(
          child: DataWidget(data: DecimalDataEntity(47.11)),
        ),
      );

      await tester.pumpWidget(target);
      await tester.pump();

      expect(find.text('47,11'), findsOneWidget);
    });

    testWidgets('Currency', (tester) async {
      const locale = Locale('de');

      final target = Localizations(
        locale: locale,
        delegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate
        ],
        child: Material(
          child: DataWidget(
            data: CurrencyDataEntity(currency: 'EUR', value: 47.11),
          ),
        ),
      );

      await tester.pumpWidget(target);
      await tester.pump();

      expect(find.text('47,11 €'), findsOneWidget);
    });
  });

  group('Empty', () {
    testWidgets('Value is null', (tester) async {
      final target = MaterialApp(
        home: DataWidget(
          data: StringDataEntity(),
        ),
      );

      await tester.pumpWidget(target);
      await tester.pumpAndSettle();
      expect(find.text('-'), findsOneWidget);
    });

    testWidgets('Value is Empty List', (tester) async {
      final target = MaterialApp(
        home: DataWidget(
          data: MultiCrossReferenceDataEntity(
            gridUri: Uri.parse('https://grid.uri'),
          ),
        ),
      );

      await tester.pumpWidget(target);
      await tester.pumpAndSettle();
      expect(find.text('-'), findsOneWidget);
    });

    testWidgets('Custom Empty Builder', (tester) async {
      final target = MaterialApp(
        home: DataWidget(
          data: StringDataEntity(),
          emptyBuilder: (_) => const Text('Custom Empty Builder'),
        ),
      );

      await tester.pumpWidget(target);
      await tester.pumpAndSettle();
      expect(find.text('-'), findsNothing);
      expect(find.text('Custom Empty Builder'), findsOneWidget);
    });
  });

  group('Interactions', () {
    testWidgets('Uri Data Entity Launches', (tester) async {
      final uri = Uri.parse('https://uri.uri');
      final launcher = MockLinkLauncher();
      when(() => launcher.openWebPage(url: uri, openExternally: true))
          .thenAnswer((_) => Future.value());
      final target = MaterialApp(
        home: Material(
          child: DataWidget(
            data: UriDataEntity(uri),
            linkLauncher: launcher,
          ),
        ),
      );

      await tester.pumpWidget(target);
      await tester.pumpAndSettle();

      await tester.tap(find.text(uri.toString()));
      await tester.pumpAndSettle();

      verify(() => launcher.openWebPage(url: uri, openExternally: true))
          .called(1);
    });
  });

  testWidgets('Unknown Entity Returns Value', (tester) async {
    final target = MaterialApp(
      home: DataWidget(
        data: _UnknownDataEntity('Unknown Entity Type'),
      ),
    );

    await tester.pumpWidget(target);
    await tester.pumpAndSettle();
    expect(find.text('Unknown Entity Type'), findsOneWidget);
  });
}

class _UnknownDataEntity extends DataEntity<String, String> {
  _UnknownDataEntity([super.value]);

  @override
  String? get schemaValue => value;
}
