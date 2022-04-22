import 'dart:io';

import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:url_launcher/url_launcher.dart';

/// Wrapper class for opening url's inside apps
class LinkLauncher {
  /// Creates a LinkLauncher
  const LinkLauncher();

  /// Opens an url in a modal style on a mobile device or in a new tap on a web client
  void openWebPage({
    required String url,
    CustomTabsOptions? tabsOptions,
    SafariViewControllerOptions? safariViewControllerOptions,
  }) {
    if (Platform.isAndroid || Platform.isIOS) {
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
      launch(url);
    }
  }
}
