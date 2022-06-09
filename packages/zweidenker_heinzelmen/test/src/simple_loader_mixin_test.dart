import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zweidenker_heinzelmen/src/simple_loader_mixin.dart';

void main() {
  group('Test Mixin', () {
    testWidgets('Data gets set', (tester) async {
      final key = GlobalKey<_EntryLoaderTestWidgetState>();

      const data = 'data';
      await tester.pumpWidget(
        EntryLoaderTestWidget(
          key: key,
          loadData: () async => data,
        ),
      );
      await tester.pumpAndSettle();

      expect(key.currentState!.data, equals(data));
      expect(key.currentState!.error, isNull);
    });

    testWidgets('Loading is true while loading', (tester) async {
      final key = GlobalKey<_EntryLoaderTestWidgetState>();

      const data = 'data';
      final completer = Completer<String>();
      await tester.pumpWidget(
        EntryLoaderTestWidget(
          key: key,
          loadData: () => completer.future,
        ),
      );

      expect(key.currentState!.loading, true);
      completer.complete(data);
      await tester.pumpAndSettle();
      expect(key.currentState!.loading, false);
    });

    testWidgets('Error gets set', (tester) async {
      final key = GlobalKey<_EntryLoaderTestWidgetState>();

      const data = 'data';
      await tester.pumpWidget(
        EntryLoaderTestWidget(
          key: key,
          loadData: () => Future.error(data),
        ),
      );
      await tester.pumpAndSettle();

      expect(key.currentState!.error, equals(data));
    });
  });

  group('Reset', () {
    testWidgets('Reset Error resets Error', (tester) async {
      final key = GlobalKey<_EntryLoaderTestWidgetState>();

      const data = 'data';
      await tester.pumpWidget(
        EntryLoaderTestWidget(
          key: key,
          loadData: () => Future.error(data),
        ),
      );
      await tester.pumpAndSettle();

      expect(key.currentState!.error, equals(data));
      key.currentState!.resetError();
      await tester.pumpAndSettle();
      expect(key.currentState!.error, isNull);
    });

    testWidgets('Reset And reload resets everything and loads', (tester) async {
      final key = GlobalKey<_EntryLoaderTestWidgetState>();

      const data = 'data';
      int callFunctionCount = 0;
      await tester.pumpWidget(
        EntryLoaderTestWidget(
          key: key,
          loadData: () async {
            callFunctionCount++;
            return data;
          },
        ),
      );
      await tester.pumpAndSettle();

      key.currentState!.resetAndReload();

      expect(key.currentState!.error, isNull);
      expect(key.currentState!.data, isNull);
      expect(key.currentState!.loading, true);

      await tester.pumpAndSettle();
      expect(key.currentState!.data, equals(data));
      expect(key.currentState!.error, isNull);
      expect(key.currentState!.loading, false);
      expect(callFunctionCount, 2);
    });
  });

  group('AutoLoad', () {
    testWidgets('Data gets set', (tester) async {
      final key = GlobalKey<_EntryLoaderTestWidgetState>();

      const data = 'data';
      await tester.pumpWidget(
        EntryLoaderTestWidget(
          key: key,
          loadData: () async => data,
          autoLoadIfNull: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(key.currentState!.data, isNull);
      expect(key.currentState!.error, isNull);
      expect(key.currentState!.loading, false);
    });
  });
}

class EntryLoaderTestWidget extends StatefulWidget {
  const EntryLoaderTestWidget({
    super.key,
    required this.loadData,
    this.autoLoadIfNull,
  });

  final Future<String?> Function() loadData;
  final bool? autoLoadIfNull;

  @override
  State<EntryLoaderTestWidget> createState() => _EntryLoaderTestWidgetState();
}

class _EntryLoaderTestWidgetState extends State<EntryLoaderTestWidget>
    with SimpleLoaderMixin<EntryLoaderTestWidget, String> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  Future<String?> loadData() {
    return widget.loadData();
  }

  @override
  bool get autoLoadIfNull => widget.autoLoadIfNull ?? super.autoLoadIfNull;
}
