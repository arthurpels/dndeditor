import '../data/dnd_reference_data.dart' as ref;
import '../data/game_data.dart';
import '../models/ability.dart';
import '../models/character.dart';
import '../models/skill.dart';

/// Pure functions implementing D&D 5e (2014) PHB rules — §7 Using Ability Scores.
/// No side effects; all results are deterministic and covered by unit tests.
class RulesEngine {
  const RulesEngine._();

  // ---------------------------------------------------------------------------
  // Core formulas
  // ---------------------------------------------------------------------------

  /// Ability modifier: floor((score − 10) / 2).
  static int modifier(int score) => ((score - 10) / 2).floor();

  /// Proficiency bonus by character level (PHB p. 15).
  /// Level 1–4 → +2, 5–8 → +3, 9–12 → +4, 13–16 → +5, 17–20 → +6.
  static int proficiencyBonus(int level) => 2 + ((level - 1) ~/ 4);

  // ---------------------------------------------------------------------------
  // Typed API (used internally and by branch-A tests)
  // ---------------------------------------------------------------------------

  /// Final ability score = base + racial bonus.
  static int abilityScore(Character c, Ability a) {
    final base = c.baseAbilities[a] ?? 10;
    final racial = GameData.raceById(c.raceId)?.abilityBonuses[a] ?? 0;
    return base + racial;
  }

  static int abilityModifier(Character c, Ability a) =>
      modifier(abilityScore(c, a));

  /// Skill modifier = ability modifier + proficiency bonus (if proficient).
  static int skillModifier(Character c, Skill s) {
    final base = abilityModifier(c, s.ability);
    final prof =
        c.skillProficiencies.contains(s) ? proficiencyBonus(c.level) : 0;
    return base + prof;
  }

  /// Saving throw = ability modifier + proficiency bonus (if proficient).
  static int saveModifier(Character c, Ability a) {
    final base = abilityModifier(c, a);
    final prof =
        c.savingThrowProficiencies.contains(a) ? proficiencyBonus(c.level) : 0;
    return base + prof;
  }

  /// Unarmored AC = 10 + DEX modifier.
  static int armorClass(Character c) =>
      10 + abilityModifier(c, Ability.dexterity);

  static int initiative(Character c) =>
      abilityModifier(c, Ability.dexterity);

  /// Passive Perception = 10 + Perception skill modifier.
  static int passivePerception(Character c) =>
      10 + skillModifier(c, Skill.perception);

  static int speed(Character c) =>
      GameData.raceById(c.raceId)?.speed ?? 30;

  /// Average roll for a die: d8 → 5, d10 → 6, d12 → 7, d6 → 4.
  static int averageRoll(int die) => (die ~/ 2) + 1;

  /// Max HP: level 1 = max die + CON mod; each subsequent level adds average + CON mod.
  static int maxHp({
    required int hitDie,
    required int conModifier,
    required int level,
  }) {
    var hp = hitDie + conModifier;
    for (var lvl = 2; lvl <= level; lvl++) {
      hp += averageRoll(hitDie) + conModifier;
    }
    return hp < 1 ? 1 : hp;
  }

  static int maxHpForCharacter(Character c) {
    final cls = GameData.classById(c.classId);
    return maxHp(
      hitDie: cls?.hitDie ?? 8,
      conModifier: abilityModifier(c, Ability.constitution),
      level: c.level,
    );
  }

  /// Format a modifier with explicit sign: 3 → "+3", -1 → "-1".
  static String signed(int value) => value >= 0 ? '+$value' : '$value';

  static Set<Ability> classSavingThrows(String classId) =>
      GameData.classById(classId)?.savingThrows.toSet() ?? {};

  // ---------------------------------------------------------------------------
  // String-based API (used by character sheet UI — Dev C)
  // ---------------------------------------------------------------------------

  /// Racial ability bonus by string ability id ("STR", "CON", …).
  static int raceBonus(String raceId, String abilityId) =>
      ref.raceAbilityBonuses[raceId]?[abilityId] ?? 0;

  static int raceSpeed(String raceId) => ref.raceSpeeds[raceId] ?? 30;

  static int hitDieForClass(String classId) => ref.classHitDice[classId] ?? 8;

  /// Saving throw proficiency abbreviations for a class ("STR", "CON", …).
  static Set<String> savingThrowProficienciesForClass(String classId) =>
      ref.classSavingThrows[classId] ?? const {};

  /// Skill proficiency names for a background ("Athletics", "Intimidation", …).
  static Set<String> skillProficienciesForBackground(String backgroundId) =>
      ref.backgroundSkills[backgroundId] ?? const {};

  /// Governing ability abbreviation for a skill name ("Athletics" → "STR").
  static String skillAbility(String skillName) =>
      ref.skillAbilityMap[skillName] ?? 'INT';
}
