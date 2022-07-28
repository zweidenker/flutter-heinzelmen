import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:zweidenker_heinzelmen/zweidenker_heinzelmen.dart';

import '../infra/mocks.dart';

void main() {
  const LinkLauncher linkLauncher = LinkLauncher();
  final testUri = Uri.parse('https://en.apptivegrid.de/');
  final mockUrlLauncher = MockUrlLauncherPlatform();

  setUpAll(() {
    UrlLauncherPlatform.instance = mockUrlLauncher;
    registerFallbackValue(const LaunchOptions());
  });

  group('Url Launcher', () {
    test('Calls Url Launcher on Desktop', () async {
      // TODO: Set Universal Explicitly to desktop (https://github.com/gskinnerTeam/flutter-universal-platform/issues/15)
      when(
        () => mockUrlLauncher.launchUrl(
          testUri.toString(),
          any(),
        ),
      ).thenAnswer((invocation) async => true);
      await linkLauncher.openWebPage(url: testUri);

      verify(
        () => mockUrlLauncher.launchUrl(
          testUri.toString(),
          any(),
        ),
      ).called(1);
    });

    test('Open Externally. Calls Url Launcher', () async {
      when(
        () => mockUrlLauncher.launchUrl(
          testUri.toString(),
          any(),
        ),
      ).thenAnswer((invocation) async => true);
      await linkLauncher.openWebPage(url: testUri, openExternally: true);

      verify(
        () => mockUrlLauncher.launchUrl(
          testUri.toString(),
          any(),
        ),
      ).called(1);
    });
  });

  // TODO: Add Test for non Desktop/Web (Waiting for https://github.com/gskinnerTeam/flutter-universal-platform/issues/15)
}
