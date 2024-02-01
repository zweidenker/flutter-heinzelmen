import 'package:apptive_grid_core/apptive_grid_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// A change notifier for changes in [ApptiveGridEnvironment]
class EnvironmentChangeNotifier extends ChangeNotifier {
  /// Creates a new configuration change notifier for [environment]
  EnvironmentChangeNotifier({
    ApptiveGridEnvironment environment = ApptiveGridEnvironment.production,
    this.availableEnvironments = ApptiveGridEnvironment.values,
  })  : _environment = environment,
        super();

  ApptiveGridEnvironment _environment;

  /// Returns a list of available [ApptiveGridEnvironment]s
  final List<ApptiveGridEnvironment> availableEnvironments;

  /// Updates [environment] and calls [notifyListeners] if the environment has changed.
  /// If the environment is the current one it will not do anything
  set environment(ApptiveGridEnvironment environment) {
    if (environment != _environment &&
        availableEnvironments.contains(environment)) {
      _environment = environment;
      notifyListeners();
    }
  }

  /// The current [ApptiveGridEnvironment] environment
  ApptiveGridEnvironment get environment => _environment;
}

/// A change notifier to switch configurations based on [ApptiveGridEnvironment]
class ConfigurationChangeNotifier<T> extends EnvironmentChangeNotifier {
  /// Creates a new configuration change notifier for [configurations]
  /// [configurations] must contain an entry with key [environment]. By default [environment] is [ApptiveGridEnvironment.production]
  ConfigurationChangeNotifier({
    required Map<ApptiveGridEnvironment, T> configurations,
    super.environment,
  })  : assert(
          configurations[environment] != null,
          '`configurations` must include a configuration for `environment`',
        ),
        _configurations = configurations,
        _configuration = configurations[environment]!;

  final Map<ApptiveGridEnvironment, T> _configurations;
  late T _configuration;

  /// Updates [environment] and calls [notifyListeners] if the configuration has changed.
  /// If the environment is the current one or there is matching configuration in [_configurations] it will not do anything
  @override
  set environment(ApptiveGridEnvironment environment) {
    if (environment != _environment) {
      final newConfiguration = _configurations[environment];
      if (newConfiguration != null) {
        _environment = environment;
        _configuration = newConfiguration;
        notifyListeners();
      }
    }
  }

  /// The current [T] configuration
  T get configuration => _configuration;

  /// Returns a list of [ApptiveGridEnvironment] that have configuratinos in [_configurations]
  @override
  List<ApptiveGridEnvironment> get availableEnvironments =>
      _configurations.keys.toList(growable: false);
}

/// A [DropdownButton] to switch the [ApptiveGridEnvironment]
/// Note this requires that there is a [Provider]<EnvironmentChangeNotifier> in the Widget Tree
class EnvironmentSwitcher extends StatelessWidget {
  /// Creates the Dropdown Button
  /// Note this requires that there is a [Provider]<ConfigurationChangeNotifier> in the Widget Tree
  const EnvironmentSwitcher({super.key, this.onChangeEnvironment});

  /// Called when the environment changed to [environment] to perform additional actions
  final Future<void> Function(ApptiveGridEnvironment environment)?
      onChangeEnvironment;

  @override
  Widget build(BuildContext context) {
    final configurationProvider = context.watch<EnvironmentChangeNotifier>();
    return DropdownButton<ApptiveGridEnvironment>(
      value: configurationProvider.environment,
      underline: const SizedBox(),
      items: configurationProvider.availableEnvironments
          .map(
            (environment) => DropdownMenuItem(
              value: environment,
              child: Text(
                toBeginningOfSentenceCase(
                  environment.name,
                  Localizations.localeOf(context).toString(),
                )!,
              ),
            ),
          )
          .toList(),
      onChanged: (newEnvironment) async {
        if (newEnvironment != null &&
            configurationProvider.environment != newEnvironment) {
          await onChangeEnvironment?.call(newEnvironment);
          configurationProvider.environment = newEnvironment;
        }
      },
    );
  }
}
