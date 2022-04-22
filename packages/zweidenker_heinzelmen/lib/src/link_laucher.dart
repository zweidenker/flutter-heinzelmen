import 'dart:io';

import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:url_launcher/url_launcher.dart';

/// Wrapper class for opening url's inside apps
class LinkLauncher {
  /// Creates a LinkLauncher
  const LinkLauncher();

  /// Opens an url in a modal style on a mobile device or in a new tap on a web client
  /// Use [tabsOptions] to customize the Chrome taps on Android
  /// Use [safariViewControllerOptions] to customize the SafariController on iOS
  void openWebPage({
    required String url,
    CustomTabsOptions? tabsOptions,
    SafariViewControllerOptions? safariViewControllerOptions,
  }) {
    if (Platform.isAndroid || Platform.isIOS) {
      /// Opens an url in a modal style on a mobile device
      FlutterWebBrowser.openWebPage(
        url: url,
        customTabsOptions: tabsOptions ??
            const CustomTabsOptions(
              instantAppsEnabled: true,
              urlBarHidingEnabled: true,
            ),
        safariVCOptions: safariViewControllerOptions ??
            const SafariViewControllerOptions(
              barCollapsingEnabled: true,
              modalPresentationCapturesStatusBarAppearance: true,
              dismissButtonStyle: SafariViewControllerDismissButtonStyle.done,
              modalPresentationStyle: UIModalPresentationStyle.fullScreen,
            ),
      );
    } else {
      /// Opens the url in a new tab in the browser
      launch(url);
    }
  }
}
