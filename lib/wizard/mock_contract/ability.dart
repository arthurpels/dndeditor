// MOCK CONTRACT — временная заглушка зоны B (мастер создания).
//
// Dev A ещё не выложил реальный `lib/models/` + `lib/rules/rules_engine.dart`.
// Всё в `lib/wizard/mock_contract/` — локальный мок, повторяющий контракт из
// PRD (раздел 6–7) ровно настолько, чтобы мастер можно было собрать и
// продемонстрировать отдельно. Когда появится настоящий контракт, этот файл
// удаляется, а экраны/контроллер переключаются на реальные типы.

/// Шесть характеристик D&D 5e.
enum AbilityScore { strength, dexterity, constitution, intelligence, wisdom, charisma }

extension AbilityScoreLabels on AbilityScore {
  String get shortCode => switch (this) {
        AbilityScore.strength => 'STR',
        AbilityScore.dexterity => 'DEX',
        AbilityScore.constitution => 'CON',
        AbilityScore.intelligence => 'INT',
        AbilityScore.wisdom => 'WIS',
        AbilityScore.charisma => 'CHA',
      };

  String get labelRu => switch (this) {
        AbilityScore.strength => 'Сила',
        AbilityScore.dexterity => 'Ловкость',
        AbilityScore.constitution => 'Телосложение',
        AbilityScore.intelligence => 'Интеллект',
        AbilityScore.wisdom => 'Мудрость',
        AbilityScore.charisma => 'Харизма',
      };
}

/// Метод генерации характеристик (раздел 7.7 PRD).
enum AbilityMethod { standardArray, pointBuy, rolled4d6 }

extension AbilityMethodLabels on AbilityMethod {
  String get labelRu => switch (this) {
        AbilityMethod.standardArray => 'Стандартный массив',
        AbilityMethod.pointBuy => 'Point Buy',
        AbilityMethod.rolled4d6 => '4d6 (отбросить меньший)',
      };
}
