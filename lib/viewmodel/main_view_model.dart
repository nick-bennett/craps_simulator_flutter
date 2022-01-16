import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';

import '../model/craps.dart';
import '../service/simulator.dart';

/// Encapsulates the coordination of model content & updates presented in views.
///
/// This class publishes a [Stream] providing updates (as [Snapshot] instances)
/// to be consumed by the UI&mdash;e.g. in a [StreamBuilder].
class MainViewModel {
  final StreamController<Snapshot> _snapshotStreamController;

  final ReceivePort _receivePort;
  late final SendPort _sendPort;
  late final Isolate _simulator;

  // ignore: unused_field
  late bool _running;

  MainViewModel()
      : _snapshotStreamController = StreamController<Snapshot>(),
        _receivePort = ReceivePort() {
    _running = false;
    _receivePort.listen(_listen);
    Isolate.spawn(Simulator.start, _receivePort.sendPort)
        .then((isolate) => _simulator = isolate);
  }

  /// A source of [Snapshot] updates to be consumed by a [StreamBuilder] in a
  /// [StatefulWidget].
  Stream<Snapshot> get snapshotStream => _snapshotStreamController.stream;

  /// Resets tally statistics of the Craps simulation, suspending
  /// continuous-mode execution as a side effect.
  void reset() {
    _running = false;
    _sendPort.send({'init': null});
  }

  /// Requests simulation of the next batch of rounds.
  ///
  /// If `ignoreRunning` is `true`, simulation is unconditional&mdash;i.e. the
  /// batch is simulated, even if the simulation is not currently running in
  /// continuous-execution mode.
  void simulate([bool ignoreRunning = false]) {
    if (ignoreRunning || _running) {
      _sendPort.send({'simulate': 1000000}); // TODO: Take from settings
    }
  }

  /// Starts the Craps simulation in continuous-execution mode.
  void start() {
    _running = true;
    simulate();
  }

  /// Stops continuous-mode execution of the Craps simulation.
  void stop() {
    _running = false;
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
