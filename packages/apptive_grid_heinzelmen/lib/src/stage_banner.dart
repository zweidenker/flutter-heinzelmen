import 'package:apptive_grid_core/apptive_grid_core.dart';
import 'package:apptive_grid_heinzelmen/src/configuration.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const double _kHeight = 12.0; // height of banner
const Color _kColor = Color(0xA0B71C1C);
const TextStyle _kTextStyle = TextStyle(
  color: Color(0xFFFFFFFF),
  fontSize: _kHeight * 0.85,
  fontWeight: FontWeight.w900,
  height: 1.0,
);

/// A [Banner] widget indicating the current [ApptiveGridEnvironment]
/// Note this requires that there is a [Provider]<ConfigurationChangeNotifier<T>> and [Provider]<EnableBannerNotifier> in the Widget Tree
class StageBanner<T> extends StatelessWidget {
  /// Creates a new StageBanner Widget
  /// It will show the Name of the current environment if [EnableBannerNotifier.enabled] is `true` and [ConfigurationChangeNotifier.environment] is not production
  /// Note this requires that there is a [Provider]<ConfigurationChangeNotifier> and [Provider]<EnableBannerNotifier> in the Widget Tree
  const StageBanner({
    super.key,
    required this.child,
    this.color,
    this.textStyle,
  });

  /// The widget that should be shown as the child
  final Widget child;

  /// The color of the Banner
  final Color? color;

  /// The TextStyle of the Banner
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final environment =
        context.watch<ConfigurationChangeNotifier<T>>().environment;
    final enableBanner = context.watch<EnableBannerNotifier>().enabled;
    if (environment == ApptiveGridEnvironment.production || !enableBanner) {
      return child;
    } else {
      return Banner(
        message: environment.name.toUpperCase(),
        location: BannerLocation.topEnd,
        color: color ?? _kColor,
        textStyle: textStyle ?? _kTextStyle,
        child: child,
      );
    }
  }
}

/// A ChangeNotifier to toggle [StageBanner] on/off
class EnableBannerNotifier extends ChangeNotifier {
  /// Creates a new [EnableBannerNotifier] that is [enabled] (defaults to `false`)
  EnableBannerNotifier({bool enabled = false})
      : _enabled = enabled,
        super();

  /// Creates a new [EnableBannerNotifier] that is initially false and will update to the value of [calculateInitiallyEnabled] once that completes
  factory EnableBannerNotifier.create(
    Future<bool> Function() calculateInitiallyEnabled,
  ) {
    final bannerNotifier = EnableBannerNotifier();

    calculateInitiallyEnabled().then((result) {
      bannerNotifier.enabled = result;
    });

    return bannerNotifier;
  }

  bool _enabled;

  /// Returns if the Banner is currently enabled
  bool get enabled => _enabled;

  /// Updates the enabled status. Will call [notifyListeners]
  set enabled(bool enabled) {
    _enabled = enabled;
    notifyListeners();
  }
}
