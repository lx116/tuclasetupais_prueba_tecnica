import 'dart:math';

/// Randomizer that simulates the outcome of a back call with a six-sided die.
class DiceRoller {
  DiceRoller([Random? random]) : _random = random ?? Random();

  final Random _random;

  /// A value from 1 to 6.
  int roll() => _random.nextInt(6) + 1;
}
