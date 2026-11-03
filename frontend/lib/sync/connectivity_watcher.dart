import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Monitors network connectivity state changes to trigger auto-sync on reconnect.
class ConnectivityWatcher {
  ConnectivityWatcher({
    Future<List<ConnectivityResult>> Function()? check,
    Stream<List<ConnectivityResult>> Function()? changes,
  })  : _check = check ?? (() => Connectivity().checkConnectivity()),
        _changes = changes ?? (() => Connectivity().onConnectivityChanged);

  final Future<List<ConnectivityResult>> Function() _check;
  final Stream<List<ConnectivityResult>> Function() _changes;
  StreamSubscription<void>? _subscription;

  static bool _isOnline(List<ConnectivityResult> results) => results.any(
        (result) =>
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.ethernet,
      );

  /// เช็กสถานะตอนนี้ (true = Online)
  Future<bool> checkOnline() async => _isOnline(await _check());

  /// ส่งค่าใหม่เฉพาะตอนสถานะเปลี่ยน (true = Online, false = Offline)
  Stream<bool> get onStatusChanged => _changes().map(_isOnline).distinct();

  /// ส่งสัญญาณหนึ่งครั้งทุกครั้งที่เปลี่ยนจาก Offline เป็น Online
  Stream<void> get onBackOnline async* {
    var wasOnline = await checkOnline();
    await for (final online in onStatusChanged) {
      if (online && !wasOnline) yield null;
      wasOnline = online;
    }
  }

  /// เรียก [onOnline] ทุกครั้งที่เครือข่ายกลับมา (Offline -> Online)
  void startWatching({required void Function() onOnline}) {
    _subscription?.cancel();
    _subscription = onBackOnline.listen((_) => onOnline());
  }

  void stopWatching() {
    _subscription?.cancel();
    _subscription = null;
  }
}

final connectivityWatcherProvider = Provider<ConnectivityWatcher>((ref) {
  final watcher = ConnectivityWatcher();
  ref.onDispose(watcher.stopWatching);
  return watcher;
});

/// สถานะ Online ปัจจุบันสำหรับให้ UI หรือ Sync Engine เฝ้าดู
final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final watcher = ref.watch(connectivityWatcherProvider);
  yield await watcher.checkOnline();
  yield* watcher.onStatusChanged;
});