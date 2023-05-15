import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zweidenker_heinzelmen/zweidenker_heinzelmen.dart';

void main() {
  const formattedVersion = '1.2.3+81';

  group('Factored Version', () {
    setUpAll(() {
      PackageInfo.setMockInitialValues(
        appName: 'appName',
        packageName: 'packageName',
        version: '1.2.3',
        buildNumber: '102030081',
        buildSignature: 'buildSignature',
      );
    });
    group('Version Number Widget', () {
      testWidgets('Shows Sized Box while loading', (tester) async {
        await tester.pumpWidget(const AppVersion());

        expect(find.byType(SizedBox), findsOneWidget);
      });

      testWidgets('Shows Version Number as Text', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: AppVersion()));
        await tester.pump();

        expect(find.text(formattedVersion), findsOneWidget);
      });

      testWidgets('Provided Style gets applied', (tester) async {
        const textStyle = TextStyle(fontWeight: FontWeight.bold);

        await tester.pumpWidget(
          const MaterialApp(
            home: AppVersion(
              textStyle: textStyle,
            ),
          ),
        );
        await tester.pump();

        final textWidget =
            find.text(formattedVersion).evaluate().first.widget as Text;
        expect(textWidget.style, equals(textStyle));
      });
    });
  });

  group('Offset Version', () {
    setUpAll(() {
      PackageInfo.setMockInitialValues(
        appName: 'appName',
        packageName: 'packageName',
        version: '1.2.3',
        buildNumber: '102030081',
        buildSignature: 'buildSignature',
      );
    });
    group('Version Number Widget', () {
      testWidgets('Shows Sized Box while loading', (tester) async {
        await tester.pumpWidget(
          AppVersion.offset(
            offset: 102030000,
          ),
        );

        expect(find.byType(SizedBox), findsOneWidget);
      });

      testWidgets('Shows Version Number as Text', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: AppVersion()));
        await tester.pump();

        expect(find.text(formattedVersion), findsOneWidget);
      });

      testWidgets('Provided Style gets applied', (tester) async {
        const textStyle = TextStyle(fontWeight: FontWeight.bold);

        await tester.pumpWidget(
          MaterialApp(
            home: AppVersion.offset(
              offset: 102030000,
              textStyle: textStyle,
            ),
          ),
        );
        await tester.pump();

        final textWidget =
            find.text(formattedVersion).evaluate().first.widget as Text;
        expect(textWidget.style, equals(textStyle));
      });
    });
  });
}
