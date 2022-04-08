import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zweidenker_toolbox/zweidenker_toolbox.dart';

void main() {
  setUpAll(() {
    PackageInfo.setMockInitialValues(
      appName: 'appName',
      packageName: 'packageName',
      version: '1.2.3',
      buildNumber: '102030081',
      buildSignature: 'buildSignature',
    );
  });

  const formattedVersion = '1.2.3+81';

  group('Parse version Number', () {
    test('Get Version Number, unscrambles buildNumber', () async {
      final version = await getVersionInfo();

      expect(version, equals(formattedVersion));
    });
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
}
