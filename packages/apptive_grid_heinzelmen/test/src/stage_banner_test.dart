import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:apptive_grid_core/apptive_grid_core.dart';
import 'package:apptive_grid_heinzelmen/apptive_grid_heinzelmen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart' show loadAppFonts;
import 'package:provider/provider.dart';

void main() {
  group('Banner Provider', () {
    test('Default is off', () {
      final bannerNotifier = EnableBannerNotifier();
      addTearDown(bannerNotifier.dispose);

      expect(bannerNotifier.enabled, false);
    });

    test('Set default', () {
      final bannerNotifier = EnableBannerNotifier(enabled: true);
      addTearDown(bannerNotifier.dispose);

      expect(bannerNotifier.enabled, true);
    });

    test('Create callback updates', () async {
      final calculationCompleter = Completer<bool>();
      final updateCompleter = Completer<bool>();

      final bannerNotifier =
          EnableBannerNotifier.create(() => calculationCompleter.future);
      addTearDown(bannerNotifier.dispose);

      bannerNotifier.addListener(() {
        if (!updateCompleter.isCompleted) {
          updateCompleter.complete(bannerNotifier.enabled);
        }
      });

      expect(bannerNotifier.enabled, false);
      calculationCompleter.complete(true);

      expect(await updateCompleter.future, true);
    });

    test('Update Value, notifies', () async {
      final updateCompleter = Completer<bool>();

      final bannerNotifier = EnableBannerNotifier();
      addTearDown(bannerNotifier.dispose);

      bannerNotifier.addListener(() {
        if (!updateCompleter.isCompleted) {
          updateCompleter.complete(bannerNotifier.enabled);
        }
      });

      expect(bannerNotifier.enabled, false);

      bannerNotifier.enabled = true;

      expect(await updateCompleter.future, true);
    });
  });

  group('Stage Banner', () {
    setUpAll(() async {
      await loadAppFonts();
    });
    group('Golden Test', () {
      goldenTest(
        'Stage Banner Test',
        fileName: 'stage-banner',
        constraints: const BoxConstraints(maxWidth: 500),
        builder: () {
          return GoldenTestGroup(
            columnWidthBuilder: (_) => const FlexColumnWidth(),
            columns: 2,
            children: [
              GoldenTestScenario(
                name: 'Production - Enabled',
                child: const StageBannerTestWidget(
                  environment: ApptiveGridEnvironment.production,
                  enabled: true,
                ),
              ),
              GoldenTestScenario(
                name: 'Production - Disabled',
                child: const StageBannerTestWidget(
                  environment: ApptiveGridEnvironment.production,
                  enabled: false,
                ),
              ),
              GoldenTestScenario(
                name: 'Beta - Enabled',
                child: const StageBannerTestWidget(
                  environment: ApptiveGridEnvironment.beta,
                  enabled: true,
                ),
              ),
              GoldenTestScenario(
                name: 'Beta - Disabled',
                child: const StageBannerTestWidget(
                  environment: ApptiveGridEnvironment.beta,
                  enabled: false,
                ),
              ),
              GoldenTestScenario(
                name: 'Alpha - Enabled',
                child: const StageBannerTestWidget(
                  environment: ApptiveGridEnvironment.alpha,
                  enabled: true,
                ),
              ),
              GoldenTestScenario(
                name: 'Alpha - Disabled',
                child: const StageBannerTestWidget(
                  environment: ApptiveGridEnvironment.alpha,
                  enabled: false,
                ),
              ),
              GoldenTestScenario(
                name: 'Custom Style',
                child: const StageBannerTestWidget(
                  environment: ApptiveGridEnvironment.alpha,
                  enabled: true,
                  color: Colors.yellow,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 5,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  });
}

class StageBannerTestWidget extends StatelessWidget {
  const StageBannerTestWidget({
    super.key,
    required this.environment,
    required this.enabled,
    this.color,
    this.textStyle,
  });

  final ApptiveGridEnvironment environment;
  final bool enabled;
  final Color? color;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ConfigurationChangeNotifier>(
          create: (_) => ConfigurationChangeNotifier(
            configurations: {environment: ''},
            environment: environment,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => EnableBannerNotifier(enabled: enabled),
        )
      ],
      builder: (_, __) {
        return SizedBox(
          height: 100,
          child: StageBanner(
            color: color,
            textStyle: textStyle,
            child: const SizedBox(
              height: 100,
              width: 200,
            ),
          ),
        );
      },
    );
  }
}
