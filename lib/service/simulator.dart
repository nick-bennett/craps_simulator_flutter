import 'dart:isolate';
import 'dart:math';

import 'package:xrandom/xrandom.dart';

import '../model/craps.dart';

/// Encapsulates Monte Carlo simulation of outcomes for the shooter in Craps.
///
/// This class does not model wagering actions or outcomes, but simply simulates
/// rounds of dice rolls, each beginning with a "come out" roll, and ending with
/// a win or loss for the shooter. These outcomes are tallied; at the end of
/// each batch of rounds, the current tally and the most recent round of rolls
/// is sent as a [Snapshot] to the [SendPort] provided by the consumer in the
/// invocation of the [constructor][Simulator(_sendPort)].
class Simulator {
  final SendPort _sendPort;
  final ReceivePort _receivePort;
  final Random _rng;

  late int _wins;
  late int _losses;

  /// Initializes this instance with a [SendPort] to be used for sending
  /// [Snapshot] instances to the consumer.
  Simulator(this._sendPort)
      : _receivePort = ReceivePort(),
        _rng = Xrandom() {
    _receivePort.listen(_listen);
    _sendPort.send(_receivePort.sendPort);
    _reset();
  }

  /// Instantiates and initializes a [Simulator] instance.
  ///
  /// A reference to this method should be passed as an argument when invoking
  /// [Isolate.spawn((message) { }, message)]
  static void start(dynamic message) {
    Simulator(message as SendPort);
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

  void _sendSnapshot(Snapshot snapshot) {
    _sendPort.send(snapshot);
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
