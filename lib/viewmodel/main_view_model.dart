import 'dart:async';
import 'dart:isolate';

import '../model/craps.dart';
import '../service/simulator.dart';

class MainViewModel {
  MainViewModel()
      : _snapshotStreamController = StreamController<Snapshot>(),
        _receivePort = ReceivePort() {
    _running = false;
    _receivePort.listen(_listen);
    Isolate.spawn(Simulator.start, _receivePort.sendPort)
        .then((isolate) => _simulator = isolate);
  }

  final StreamController<Snapshot> _snapshotStreamController;
  final ReceivePort _receivePort;
  late final SendPort _sendPort;
  late final Isolate _simulator;

  late bool _running;

  Stream<Snapshot> get snapshotStream => _snapshotStreamController.stream;

  void start() {
    _running = true;
    simulate();
  }

  void stop() {
    _running = false;
  }

  void reset() {
    _running = false;
    _sendPort.send({'init': null});
  }

  void simulate([bool ignoreRunning = false]) {
    if (ignoreRunning || _running) {
      _sendPort.send({'simulate': 100000});
    }
  }

  void _listen(dynamic message) {
    if (message is SendPort) {
      _sendPort = message;
    } else {
      _snapshotStreamController.add(message as Snapshot);
      simulate();
    }
  }
}
