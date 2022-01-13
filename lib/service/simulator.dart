import 'dart:isolate';

import 'dart:math';

import 'package:xrandom/xrandom.dart';

import '../model/craps.dart';

class Simulator {
  Simulator(this._sendPort)
      : _receivePort = ReceivePort(),
        _rng = Xrandom() {
    _receivePort.listen(_listen);
    _sendPort.send(_receivePort.sendPort);
    _reset();
  }

  final SendPort _sendPort;
  final ReceivePort _receivePort;
  final Random _rng;

  late int _wins;
  late int _losses;

  static void start(dynamic message) {
    Simulator(message as SendPort);
  }

  void _sendSnapshot(Snapshot snapshot) {
    _sendPort.send(snapshot);
  }

  void _listen(dynamic message) {
    final payload = message as Map<String, Object?>;
    if (payload.containsKey('init')) {
      _reset();
    } else if (payload.containsKey('simulate')) {
      _simulate(payload['simulate'] as int);
    }
  }

  void _reset() {
    _wins = 0;
    _losses = 0;
    _sendSnapshot(Snapshot(0, 0, null));
  }

  void _simulate(int numRounds) {
    Round? round;
    for (var i = 0; i < numRounds; i++) {
      round = Round(_rng);
      if (round.win) {
        _wins++;
      } else {
        _losses++;
      }
    }
    _sendSnapshot(Snapshot(_wins, _losses, round));
  }
}
