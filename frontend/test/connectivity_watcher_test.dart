import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/sync/connectivity_watcher.dart';

void main() {
  test('checkOnline: wifi = true, none = false', () async {
    final online = ConnectivityWatcher(
      check: () async => [ConnectivityResult.wifi],
      changes: () => const Stream.empty(),
    );
    final offline = ConnectivityWatcher(
      check: () async => [ConnectivityResult.none],
      changes: () => const Stream.empty(),
    );
    expect(await online.checkOnline(), isTrue);
    expect(await offline.checkOnline(), isFalse);
  });

  test('onStatusChanged ส่งเฉพาะตอนสถานะเปลี่ยน', () async {
    final controller = StreamController<List<ConnectivityResult>>();
    final watcher = ConnectivityWatcher(
      check: () async => [ConnectivityResult.wifi],
      changes: () => controller.stream,
    );
    final events = watcher.onStatusChanged.toList();
    controller.add([ConnectivityResult.wifi]);
    controller.add([ConnectivityResult.mobile]);
    controller.add([ConnectivityResult.none]);
    controller.add([ConnectivityResult.none]);
    await controller.close();
    expect(await events, [true, false]);
  });

  test('onBackOnline ส่งสัญญาณเมื่อ Offline เป็น Online', () async {
    final controller = StreamController<List<ConnectivityResult>>();
    final watcher = ConnectivityWatcher(
      check: () async => [ConnectivityResult.none],
      changes: () => controller.stream,
    );
    final first = watcher.onBackOnline.first;
    controller.add([ConnectivityResult.wifi]);
    await first.timeout(const Duration(seconds: 2));
    await controller.close();
  });

  test('onBackOnline ไม่ส่งสัญญาณถ้าออนไลน์อยู่แล้ว', () async {
    final controller = StreamController<List<ConnectivityResult>>();
    final watcher = ConnectivityWatcher(
      check: () async => [ConnectivityResult.wifi],
      changes: () => controller.stream,
    );
    final events = watcher.onBackOnline.toList();
    controller.add([ConnectivityResult.mobile]);
    controller.add([ConnectivityResult.none]);
    await controller.close();
    expect(await events, isEmpty);
  });

  test('startWatching เรียก onOnline หนึ่งครั้งตอนเน็ตกลับมา', () async {
    final controller = StreamController<List<ConnectivityResult>>();
    final watcher = ConnectivityWatcher(
      check: () async => [ConnectivityResult.none],
      changes: () => controller.stream,
    );
    var calls = 0;
    watcher.startWatching(onOnline: () => calls++);
    await Future<void>.delayed(Duration.zero);
    controller.add([ConnectivityResult.wifi]);
    controller.add([ConnectivityResult.mobile]); // สลับเครือข่าย ไม่นับ
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(calls, 1);
    watcher.stopWatching();
    await controller.close();
  });
}