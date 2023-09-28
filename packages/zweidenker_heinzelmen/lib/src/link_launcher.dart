import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher.dart';

export 'package:flutter_web_browser/flutter_web_browser.dart'
    show CustomTabsOptions, SafariViewControllerOptions;

/// Wrapper class for opening urls inside apps
class LinkLauncher {
  /// Creates a LinkLauncher
  const LinkLauncher();

  /// Opens an url in a modal style on a mobile device or in a new tap on a web client
  /// if [openExternally] is `true` this will also be launched externally
  /// Use [tabsOptions] to customize the Chrome tabs on Android
  /// Use [safariViewControllerOptions] to customize the SafariController on iOS
  /// Use [checkTrackingPermission] if the website should be displayed in a SafariViewController on iOS and Displays Cookies
  /// This can lead to rejection during Apple Review if no Tracking Permission was granted by the user
  /// If you set this to true you need to declare the usage of `NSUserTrackingUsageDescription` in Info.plist
  Future<void> openWebPage({
    required Uri url,
    bool openExternally = false,
    CustomTabsOptions? tabsOptions,
    SafariViewControllerOptions? safariViewControllerOptions,
    bool checkTrackingPermission = false,
  }) async {
    // coverage:ignore-start
    // Ignore for Coverage as UniversalPlatform is not testable with a mock
    // Check https://github.com/gskinnerTeam/flutter-universal-platform/issues/15 for reference
    // This means that this branch of the if/else can not be properly testable
    if (checkTrackingPermission && UniversalPlatform.isIOS && !openExternally) {
      final status =
          await AppTrackingTransparency.requestTrackingAuthorization();
      openWebPage(
        url: url,
        openExternally: status != TrackingStatus.authorized,
        tabsOptions: tabsOptions,
        safariViewControllerOptions: safariViewControllerOptions,
        checkTrackingPermission: false,
      );
      // coverage:ignore-end
    } else {
      if (openExternally || kIsWeb || UniversalPlatform.isDesktopOrWeb) {
        /// Opens the url in a new tab in the browser
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // coverage:ignore-start
        // Ignore for Coverage as UniversalPlatform is not testable with a mock
        // Check https://github.com/gskinnerTeam/flutter-universal-platform/issues/15 for reference
        // This means that this branch of the if/else can not be properly testable

        /// Opens an url in a modal style on a mobile device
        await FlutterWebBrowser.openWebPage(
          url: url.toString(),
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
        // coverage:ignore-end
      }
    }
  }
}
