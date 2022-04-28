import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zweidenker_heinzelmen/zweidenker_heinzelmen.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

void main() {
  const LinkLauncher _linkLauncher = LinkLauncher();
  const _testUri = 'https://en.apptivegrid.de/';
  final _mock = _MockUrlLauncherPlatform();

  setUpAll(() {
    UrlLauncherPlatform.instance = _mock;
  });

  test('Browser is called', () async {
    _mock.setLaunchExpectations(
      url: _testUri,
      useWebView: false,
      useSafariVC: false,
    );
    await _linkLauncher.openWebPage(url: _testUri);
    expect(_mock.launchCalled, true);
  });
}

class _MockUrlLauncherPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {
  String? url;
  bool? useSafariVC;
  bool? useWebView;

  bool launchCalled = false;

  void setLaunchExpectations({
    required String url,
    required bool? useSafariVC,
    required bool useWebView,
  }) {
    this.url = url;
    this.useSafariVC = useSafariVC;
    this.useWebView = useWebView;
  }

  @override
  Future<bool> launch(
    String url, {
    required bool useSafariVC,
    required bool useWebView,
    required bool enableJavaScript,
    required bool enableDomStorage,
    required bool universalLinksOnly,
    required Map<String, String> headers,
    String? webOnlyWindowName,
  }) async {
    expect(url, this.url);
    expect(useSafariVC, this.useSafariVC);
    expect(useWebView, this.useWebView);
    launchCalled = true;
    return true;
  }
}
