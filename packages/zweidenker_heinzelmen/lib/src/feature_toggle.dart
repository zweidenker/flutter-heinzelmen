import 'dart:async';

/// A toggle class to check if a feature is enabled.
class FeatureToggle {
  /// Creates a toggle class that can be increased by [registerTap]
  /// If users register [requiredTaps] [registerTap] will return `true`
  /// Between taps there may only be [coolOff] Duration after which the count goes back to 0
  FeatureToggle({
    this.requiredTaps = 5,
    this.coolOff = const Duration(seconds: 1),
  });

  /// The number of taps required to enable a feature
  final int requiredTaps;

  /// The duration that is allowed during each tap
  final Duration coolOff;

  Timer? _timer;

  int _taps = 0;

  void _createTimer() {
    _timer = Timer(coolOff, () {
      _taps = 0;
    });
  }

  /// Registers a new tap.
  /// Returns true or false depending on if the taps are >= [requiredTaps]
  bool registerTap() {
    _timer?.cancel();
    _taps = _taps + 1;
    _createTimer();
    return _taps >= requiredTaps;
  }
}
