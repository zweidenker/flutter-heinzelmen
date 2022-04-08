import 'package:flutter/widgets.dart';

/// A mixin for [State]s to provide simple Loading Logic with data and error accessors
mixin SimpleLoaderMixin<W extends StatefulWidget, D> on State<W> {
  bool _loading = false;
  dynamic _error;
  D? _data;

  /// true if currently loading
  bool get loading => _loading;

  /// error that occurred during loading operation
  dynamic get error => _error;

  /// the data that was received
  D? get data => _data;

  /// Function that is called to load data
  Future<D?> loadData();

  /// Determines if the data should be automatically loaded in the first run.
  bool get autoLoadIfNull => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_data == null && autoLoadIfNull) {
      reload();
    }
  }

  /// Resets [error] to `null`. This will not load new data
  void resetError() {
    setState(() {
      _error = null;
    });
  }

  /// Resets [error] and [data] to `null` and reloads
  void resetAndReload() {
    setState(() {
      _error = null;
      _loading = true;
      _data = null;
    });
    reload();
  }

  /// Reloads the data. This will also set [error] to `null`
  Future<void> reload() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    dynamic newError;
    final newData = await loadData().catchError((caughtError) {
      newError = caughtError;
      return null;
    });

    if (mounted) {
      setState(() {
        _loading = false;
        _data = newData;
        _error = newError;
      });
    }
  }
}
