// MOCK CONTRACT — см. ability.dart. Чистые функции движка правил,
// раздел 7.1–7.8 PRD. Реальный `rules_engine.dart` от Dev A должен покрывать
// то же самое — эта копия только для локальной разработки/демо мастера.

import 'dart:math';

import 'ability.dart';
import 'race.dart';

/// 7.1 Модификатор характеристики.
int abilityModifier(int score) => ((score - 10) / 2).floor();

/// 7.2 Бонус мастерства по уровню.
int proficiencyBonusForLevel(int level) => 2 + ((level - 1) ~/ 4);

/// 7.4 Значение навыка/спасброска.
int valueWithProficiency({
  required int abilityScore,
  required bool proficient,
  required int proficiencyBonus,
}) =>
    abilityModifier(abilityScore) + (proficient ? proficiencyBonus : 0);

/// Применяет расовые бонусы к базовым характеристикам (до расы).
Map<AbilityScore, int> applyRacialBonuses(
  Map<AbilityScore, int> baseAbilities,
  RaceOption race,
) {
  return {
    for (final ability in AbilityScore.values)
      ability: (baseAbilities[ability] ?? 8) + race.bonusFor(ability),
  };
}

/// 7.8 maxHp на 1 уровне.
int maxHpLevel1({required int hitDie, required int conModifier}) => hitDie + conModifier;

/// 7.8 armorClass без брони.
int armorClassBase(int dexModifier) => 10 + dexModifier;

/// 7.8 initiative.
int initiativeValue(int dexModifier) => dexModifier;

/// 7.8 passive perception.
int passivePerception(int perceptionSkillValue) => 10 + perceptionSkillValue;

// ---------------------------------------------------------------------------
// 7.7 Генерация характеристик
// ---------------------------------------------------------------------------

const List<int> standardArrayValues = [15, 14, 13, 12, 10, 8];

/// Стоимость Point Buy по итоговому значению характеристики (8..15).
const Map<int, int> pointBuyCostTable = {
  8: 0, 9: 1, 10: 2, 11: 3, 12: 4, 13: 5, 14: 7, 15: 9,
};

const int pointBuyBudget = 27;
const int pointBuyMinScore = 8;
const int pointBuyMaxScore = 15;

int pointBuyCost(int score) {
  final cost = pointBuyCostTable[score];
  if (cost == null) {
    throw ArgumentError('Point Buy допускает значения 8..15, получено $score');
  }
  return cost;
}

int pointBuyTotalCost(Map<AbilityScore, int> scores) =>
    scores.values.fold(0, (sum, score) => sum + pointBuyCost(score));

/// 4d6, отбросить наименьший кубик — один бросок для одной характеристики.
int roll4d6DropLowest(Random random) {
  final rolls = List.generate(4, (_) => 1 + random.nextInt(6))..sort();
  return rolls.skip(1).fold(0, (sum, v) => sum + v); // отбросили самый маленький
}

/// Шесть бросков 4d6-drop-lowest — пул значений для распределения игроком.
List<int> rollAbilityPool([Random? random]) {
  final rng = random ?? Random();
  return List.generate(6, (_) => roll4d6DropLowest(rng));
}
