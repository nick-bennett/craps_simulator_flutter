import 'dart:math';

/// Creates an immutable single roll of 2 six-sided dice, with values sampled
/// from an instance of [Random].
class Roll {
  final int _die1;
  final int _die2;

  int get value => _die1 + _die2;
  int get die1 => _die1;
  int get die2 => _die2;

  /// Initializes this instance, setting the dice roll values from the specified
  /// source of randomness.
  Roll(Random rng)
      : _die1 = 1 + rng.nextInt(6),
        _die2 = 1 + rng.nextInt(6);
}

/// Encapsulates a single round of dice rolls, from the "come-out" roll to the
/// roll that results in a win or loss.
class Round {
  late final List<Roll> _rolls;
  late final bool _win;

  /// Ordered [List] of [Roll] instances in this instance.
  List<Roll> get rolls => _rolls;
  /// Flag indicating whether this round ended with a win for the shooter.
  bool get win => _win;

  /// Initializes this instance with the specified source of randomness (`rng`).
  ///
  /// The [Random] instance `rng` is used to generate all of the dice rolls in
  /// the round. On completion of execution of this constructor, all of the
  /// rolls are collected and may be obtained from the [Round.rolls] property.
  /// Similarly, the ending state of the round of rolls is accessible in the
  /// [Round.win] property.
  Round(Random rng) {
    List<Roll> _workingRolls = <Roll>[];
    _State state = _State.comeOut;
    int point = 0;
    do {
      Roll roll = Roll(rng);
      _workingRolls.add(roll);
      switch (state) {
        case _State.comeOut:
          switch (roll.value) {
            case 2:
            case 3:
            case 12:
              state = _State.loss;
              break;
            case 7:
            case 11:
              state = _State.win;
              break;
            default:
              state = _State.point;
              point = roll.value;
              break;
          }
          break;
        case _State.point:
          if (roll.value == point) {
            state = _State.win;
          } else if (roll.value == 7) {
            state = _State.loss;
          }
          break;
        default:
        // DO NOTHING.
      }
    } while (state == _State.point);
    _win = (state == _State.win);
    _rolls = List.unmodifiable(_workingRolls);
  }
}

/// Contains immutable summary statistics and a single [Round] of dice rolls.
class Snapshot {
  final int _wins;
  final int _losses;
  final Round? _round;

  /// Tally of wins in this instance.
  int get wins => _wins;
  /// Tally of losses in this instance.
  int get losses => _losses;
  /// Single (presumably the most recently completed) round of dice rolls.
  ///
  /// This should be `null` in a [Snapshot] created immediately after statistics
  /// are started/reset.
  Round? get round => _round;

  /// Initializes this instance with the specified tally of wins and losses, and
  /// a single (presumably the most recently completed) round of dice rolls.
  Snapshot(this._wins, this._losses, this._round);
}

enum _State { comeOut, point, win, loss }

