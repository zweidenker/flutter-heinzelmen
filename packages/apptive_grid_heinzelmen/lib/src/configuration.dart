import 'package:apptive_grid_core/apptive_grid_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// A change notifier to switch configurations based on [ApptiveGridEnvironment]
class ConfigurationChangeNotifier<T> extends ChangeNotifier {
  /// Creates a new configuration change notifier for [configurations]
  /// [configurations] must contain an entry with key [environment]. By default [environment] is [ApptiveGridEnvironment.production]
  ConfigurationChangeNotifier({
    required Map<ApptiveGridEnvironment, T> configurations,
    ApptiveGridEnvironment environment = ApptiveGridEnvironment.production,
  })  : assert(
          configurations[environment] != null,
          '`configurations` must include a configuration for `environment`',
        ),
        _configurations = configurations,
        _configuration = configurations[environment]!,
        _environment = environment,
        super();

  final Map<ApptiveGridEnvironment, T> _configurations;
  late T _configuration;
  late ApptiveGridEnvironment _environment;

  /// Updates [environment] and calls [notifyListeners] if the configuration has changed.
  /// If the environment is the current one or there is matching configuration in [_configurations] it will not do anything
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

  /// The current [ApptiveGridEnvironment] environment
  ApptiveGridEnvironment get environment => _environment;

  /// Returns a list of [ApptiveGridEnvironment] that have configuratinos in [_configurations]
  List<ApptiveGridEnvironment> get availableEnvironments =>
      _configurations.keys.toList(growable: false);
}

/// A [DropdownButton] to switch the [ApptiveGridEnvironment]
/// Note this requires that there is a [Provider]<ConfigurationChangeNotifier<T>> in the Widget Tree
class EnvironmentSwitcher<T> extends StatelessWidget {
  /// Creates the Dropdown Button
  /// Note this requires that there is a [Provider]<ConfigurationChangeNotifier> in the Widget Tree
  const EnvironmentSwitcher({Key? key, this.onChangeEnvironment})
      : super(key: key);

  /// Called when the environment changed to [environment] to perform additional actions
  final Future<void> Function(ApptiveGridEnvironment environment)?
      onChangeEnvironment;

  @override
  Widget build(BuildContext context) {
    final configurationProvider =
        context.watch<ConfigurationChangeNotifier<T>>();
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
