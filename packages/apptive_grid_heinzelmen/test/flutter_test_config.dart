// flutter_test_config.dart

import 'dart:async';
import 'dart:io';

import 'package:alchemist/alchemist.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final isRunningInCi = Platform.environment['CI'] == 'true';

  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(
        enabled: !isRunningInCi,
        tolerance: 0.001,
      ),
      ciGoldensConfig: const CiGoldensConfig(
        tolerance: 0.001,
      ),
    ),
    run: testMain,
  );
}
