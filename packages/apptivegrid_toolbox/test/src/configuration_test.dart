import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:apptive_grid_core/apptive_grid_core.dart';
import 'package:apptivegrid_toolbox/apptivegrid_toolbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart' show loadAppFonts;
import 'package:provider/provider.dart';

void main() {
  group('Configuration Provider', () {
    test('Initial configuration from stage', () {
      final configProvider = ConfigurationChangeNotifier(
        configurations: {
          ApptiveGridEnvironment.beta: 'betaTest',
        },
        environment: ApptiveGridEnvironment.beta,
      );

      expect(configProvider.environment, equals(ApptiveGridEnvironment.beta));
      expect(
        configProvider.configuration,
        equals('betaTest'),
      );
      expect(
        configProvider.availableEnvironments,
        equals([ApptiveGridEnvironment.beta]),
      );
    });

    test('Default configuration is production', () {
      final configProvider = ConfigurationChangeNotifier(
        configurations: {
          ApptiveGridEnvironment.production: 'productionTest',
          ApptiveGridEnvironment.beta: 'betaTest',
        },
      );

      expect(
        configProvider.environment,
        equals(ApptiveGridEnvironment.production),
      );
      expect(
        configProvider.configuration,
        equals('productionTest'),
      );
      expect(
        configProvider.availableEnvironments,
        equals(
          [ApptiveGridEnvironment.production, ApptiveGridEnvironment.beta],
        ),
      );
    });

    group('Update Environment', () {
      late ConfigurationChangeNotifier configProvider;

      setUp(() {
        configProvider = ConfigurationChangeNotifier(
          configurations: {
            ApptiveGridEnvironment.production: 'productionTest',
            ApptiveGridEnvironment.beta: 'betaTest',
          },
        );
      });

      tearDown(() {
        configProvider.dispose();
      });

      test('Updating environment updates notifies', () async {
        int listenerCallCount = 0;
        final completer = Completer();

        configProvider.addListener(() {
          listenerCallCount++;
          completer.complete();
        });

        expect(
          configProvider.environment,
          equals(ApptiveGridEnvironment.production),
        );
        expect(
          configProvider.configuration,
          equals('productionTest'),
        );

        configProvider.environment = ApptiveGridEnvironment.beta;
        await completer.future;

        expect(configProvider.environment, equals(ApptiveGridEnvironment.beta));
        expect(
          configProvider.configuration,
          equals('betaTest'),
        );
        expect(listenerCallCount, 1);
      });

      test('Same environment does nothing', () async {
        int listenerCallCount = 0;

        configProvider.addListener(() {
          listenerCallCount++;
        });

        expect(
          configProvider.environment,
          equals(ApptiveGridEnvironment.production),
        );
        expect(
          configProvider.configuration,
          equals('productionTest'),
        );

        configProvider.environment = ApptiveGridEnvironment.production;

        expect(
          configProvider.environment,
          equals(ApptiveGridEnvironment.production),
        );
        expect(
          configProvider.configuration,
          equals('productionTest'),
        );
        expect(listenerCallCount, 0);
      });

      test('Unknown environment does nothing', () async {
        int listenerCallCount = 0;

        configProvider.addListener(() {
          listenerCallCount++;
        });

        expect(
          configProvider.environment,
          equals(ApptiveGridEnvironment.production),
        );
        expect(
          configProvider.configuration,
          equals('productionTest'),
        );

        configProvider.environment = ApptiveGridEnvironment.alpha;

        expect(
          configProvider.environment,
          equals(ApptiveGridEnvironment.production),
        );
        expect(
          configProvider.configuration,
          equals('productionTest'),
        );
        expect(listenerCallCount, 0);
      });
    });
  });

  group('Environment Switch', () {
    late ConfigurationChangeNotifier configProvider;
    late Widget target;
    late Completer<ApptiveGridEnvironment> callbackCompleter;

    setUp(() {
      configProvider = ConfigurationChangeNotifier(
        configurations: {
          ApptiveGridEnvironment.production: 'productionTest',
          ApptiveGridEnvironment.beta: 'betaTest',
        },
      );

      callbackCompleter = Completer<ApptiveGridEnvironment>();
      target = Material(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: ChangeNotifierProvider(
            create: (_) => configProvider,
            builder: (_, __) => EnvironmentSwitcher(
              onChangeEnvironment: (env) async {
                callbackCompleter.complete(env);
              },
            ),
          ),
        ),
      );
    });

    testWidgets('Switching environments updates', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(target);
        await tester.pump();
        await tester.tap(find.byType(EnvironmentSwitcher));
        await tester.pump();

        await tester.tap(
          find.text('Beta').last,
        );
        await tester.pumpAndSettle();

        expect(
          await callbackCompleter.future,
          equals(ApptiveGridEnvironment.beta),
        );
        expect(configProvider.environment, equals(ApptiveGridEnvironment.beta));
        expect(find.text('Beta'), findsOneWidget);
      });
    });

    group('Golden Tests', () {
      setUpAll(() async {
        await loadAppFonts();
      });

      goldenTest(
        'Initial Stage',
        constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
        fileName: 'stage-switcher',
        builder: () => target,
      );

      goldenTest(
        'Show options',
        constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
        pumpWidget: (tester, widget) async {
          await tester.pumpWidget(widget);
          await tester.pumpAndSettle();
          await tester.tap(find.byType(EnvironmentSwitcher));
        },
        fileName: 'stage-switcher-show-options',
        builder: () => target,
      );

      goldenTest(
        'Select new option',
        constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
        pumpWidget: (tester, widget) async {
          await tester.pumpWidget(widget);
          await tester.pumpAndSettle();
          await tester.tap(find.byType(EnvironmentSwitcher));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Beta').last);
        },
        fileName: 'stage-switcher-new-selection',
        builder: () => target,
      );
    });
  });
}
