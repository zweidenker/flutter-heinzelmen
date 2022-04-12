import 'package:flutter_test/flutter_test.dart';
import 'package:zweidenker_heinzelmen/src/feature_toggle.dart';

void main() {
  test('Insufficient taps returns false', () {
    final toggle = FeatureToggle(requiredTaps: 3);

    expect(toggle.registerTap(), false);
    expect(toggle.registerTap(), false);
  });

  test('Sufficient Tests returns true', () {
    final toggle = FeatureToggle(requiredTaps: 3);

    toggle.registerTap();
    toggle.registerTap();
    expect(toggle.registerTap(), true);
    expect(toggle.registerTap(), true);
  });

  testWidgets('Cooloff resets count', (tester) async {
    const coolOff = Duration(milliseconds: 200);
    final toggle = FeatureToggle(requiredTaps: 2, coolOff: coolOff);

    toggle.registerTap();
    expect(toggle.registerTap(), true);

    await tester.pump(coolOff);
    expect(toggle.registerTap(), false);
    await tester.pump(coolOff);
  });
}
