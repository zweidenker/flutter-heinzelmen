# ApptiveGrid Heinzelmen

These are little helper heinzelmen to help with the [ApptiveGrid Flutter Packages](https://pub.dev/packages?q=apptive_grid)

## Attachment Image

Display an Attachment Image from ApptiveGrid. This includes loading logic for thumbnails. It also allows to only load thumbnails when the full size image is not needed.

```dart
AttachmentImage(
  attachment: attachment,
  loadingWidget: WidgetToShowWhileLoading(),
  // Only load small and large thumbnail
  loadUntil: LoadUntil.large,
),
```

## Configuration Change Notifier

Useful to provide different Options based on differen ApptiveGridEnviornments.
```dart
_configurationNotifier = ConfigurationChangeNotifier<dynamic>(
    environment: widget.initialEnvironment,
    configurations: {
        ApptiveGridEnvironment.alpha: ApptiveGridEnvironment.alpha,
        ApptiveGridEnvironment.beta: ApptiveGridEnvironment.beta,
        ApptiveGridEnvironment.production: ApptiveGridEnvironment.production,
    },
);

...

return ChangeNotifierProvider.value(
  value: _configurationNotifier,
  child: child,
);
```

## Environment Switcher
A widget which takes Info from a ConfigurationChangeNotifier and displays a dropdown menu button to switch between available Environments.

```dart
ListTile(
  title: Text('Environment'),
  trailing: EnvironmentSwitcher(
    onChangeEnvironment: (environment) async {
      await _logout();
    },
  ),
),
```

## Stage Banner
A combination of a ChangeNotifier to keep track of the setting and a Banner Widget to show the current Environment as a Banner. Note this will never show a banner on production only on beta and alpha.

```dart
ChangeNotifierProvider(
  create: (_) => EnableBannerNotifier.create(() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PreferencesKeys.enableBanner) ?? true;
  }),
  child: child,
);

...

/// Further down the widget tree
return StageBanner(
  child: child,
);
```

## FormalGermanApptiveGridUserManagementTranslation
Formal German Translations for ApptiveGridUserManagementTranslations
to use this instead of the default Strings that address the user with 'DU' add this to the ApptiveGridUserManagement Widget like this

```dart
ApptiveGridUserManagement(
    customTranslations: {
        const Locale.fromSubtags(languageCode: 'de'):
            FormalGermanApptiveGridUserManagementTranslation(),
        },
   ...
```

## DataWidget

Show a DataEntity in a format closer to the ApptiveGrid Web UI.

```dart
const DataWidget(
  data: dataEntity,
),
```

## ProfilePicture
Show a ProfilePicture for an ApptiveGrid User and show the initials if no image is available.

```dart
const ProfilePicture({
    userId: 'userId',
    name: 'Christian Denker',
  })
```