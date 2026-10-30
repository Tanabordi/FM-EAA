import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Monitors network connectivity state changes to trigger auto-sync on reconnect.
class ConnectivityWatcher {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void startWatching({required Function onOnline}) {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final isOnline = results.any((result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet);

      if (isOnline) {
        onOnline();
      }
    });
  }

  void stopWatching() {
    _subscription?.cancel();
  }
}

