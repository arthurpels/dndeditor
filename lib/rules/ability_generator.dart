import 'dart:math';

/// Three PHB 2014 methods for generating the six ability scores.
class AbilityGenerator {
  const AbilityGenerator._();

  // ---------------------------------------------------------------------------
  // Standard Array
  // ---------------------------------------------------------------------------

  static const List<int> standardArray = [15, 14, 13, 12, 10, 8];

  // ---------------------------------------------------------------------------
  // Point Buy (PHB p. 13)
  // ---------------------------------------------------------------------------

  static const int pointBuyBudget = 27;
  static const int pointBuyMin = 8;
  static const int pointBuyMax = 15;

  /// Cost table: score → points spent.
  static const Map<int, int> pointBuyCost = {
    8: 0, 9: 1, 10: 2, 11: 3, 12: 4, 13: 5, 14: 7, 15: 9,
  };

  static int pointBuySpent(Iterable<int> scores) => scores.fold(
        0,
        (sum, s) =>
            sum + (pointBuyCost[s.clamp(pointBuyMin, pointBuyMax)] ?? 0),
      );

  static int pointBuyRemaining(Iterable<int> scores) =>
      pointBuyBudget - pointBuySpent(scores);

  // ---------------------------------------------------------------------------
  // Roll 4d6, drop lowest
  // ---------------------------------------------------------------------------

  /// Rolls 4d6 drop lowest six times, returns results sorted descending.
  static List<int> roll4d6DropLowest([Random? rng]) {
    final r = rng ?? Random();
    final results = List.generate(6, (_) {
      final dice = List.generate(4, (_) => r.nextInt(6) + 1)..sort();
      return dice[1] + dice[2] + dice[3];
    });
    return results..sort((a, b) => b.compareTo(a));
  }
}
