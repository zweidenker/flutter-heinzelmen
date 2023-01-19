# ZWEIDENKER Heinzelmen

These are little helper heinzelmen to help Flutter Development at [ZWEIDENKER](https://zweidenker.com)

## App Version

When building Flutter apps using [ZWEIDENKER's Flutter Workflow](https://github.com/zweidenker/flutter_workflows) the build number is generated based on the version specified in the app's `pubspec.yaml` file like this:
```
(major * 100000000) + (minor * 1000000) + (patch * 10000) + buildNumber
```

The `AppVersion` Widget displays the App Version based on the retrieved buildNumber of the above formula and brings it back to the format of `major.minor.patch+build`

```dart
const AppVersion(
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),
```

## Feature Toggle
The feature toggle is a helper to register taps on a widget and if a certain amount of taps is reached the callback returns true to indicate that a feature can be shown/activated. This is used primarily to display additional settings after tapping on a widget for a certain amount of time

```dart
const featureToggle = FeatureToggle(
  requiredTaps: 3,
  coolOff: const Duration(seconds: 2),
);

...

GestureDetector(
    onTap: () {
      final enabled = featureToggle.registerTap();
      if (enabled) {
        setState(() {
            showFeature = true;
        });
      }  
    },
    child: const Text('Tap me'),
)
```

## Link Launcher
A simple abstraction layer for launching links. This allows for easier testing, opening links externaly or in a tab view inside the app.
If you use `checkTrackingPermission` on iOS you need to declare the usage of `NSUserTrackingUsageDescription` in your Info.plist
```plist
<key>NSUserTrackingUsageDescription</key>
<string>This website uses cookies to make the experience user-friendly and effective.</string>
```

## Simple Loader Mixin
A mixin to provide simple loading functionality to widgets.
This provides `loading`, `error` and `data` variables to build UI based on the state
