import '../data/dnd_reference_data.dart';

class RulesEngine {
  const RulesEngine._();

  static int modifier(int score) => (score - 10) ~/ 2;

  static int proficiencyBonus(int level) => 2 + ((level - 1) ~/ 4);

  static String skillAbility(String skillName) {
    return skillAbilityMap[skillName] ?? 'INT';
  }

  static int raceBonus(String raceId, String abilityId) {
    return raceAbilityBonuses[raceId]?[abilityId] ?? 0;
  }

  static int raceSpeed(String raceId) {
    return raceSpeeds[raceId] ?? 30;
  }

  static int hitDieForClass(String classId) {
    return classHitDice[classId] ?? 8;
  }

  static Set<String> savingThrowProficienciesForClass(String classId) {
    return classSavingThrows[classId] ?? const <String>{};
  }

  static Set<String> skillProficienciesForBackground(String backgroundId) {
    return backgroundSkills[backgroundId] ?? const <String>{};
  }
}
