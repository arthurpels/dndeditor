import 'package:dndeditor/models/ability.dart';
import 'package:dndeditor/models/character.dart';
import 'package:dndeditor/models/skill.dart';
import 'package:dndeditor/rules/ability_generator.dart';
import 'package:dndeditor/rules/rules_engine.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

int _nextId = 1;

Character _make({
  String raceId = 'human',
  String classId = 'fighter',
  int level = 1,
  Map<Ability, int>? base,
  Set<Skill>? skills,
  Set<Ability>? saves,
}) {
  return Character(
    id: 'test-${_nextId++}',
    name: 'Test',
    level: level,
    raceId: raceId,
    classId: classId,
    baseAbilities: base ??
        {
          Ability.strength: 15,
          Ability.dexterity: 14,
          Ability.constitution: 13,
          Ability.intelligence: 12,
          Ability.wisdom: 10,
          Ability.charisma: 8,
        },
    skillProficiencies: skills,
    savingThrowProficiencies: saves,
  );
}

// ---------------------------------------------------------------------------
// modifier()
// ---------------------------------------------------------------------------

void main() {
  group('modifier()', () {
    test('score 10 → 0', () => expect(RulesEngine.modifier(10), 0));
    test('score 11 → 0', () => expect(RulesEngine.modifier(11), 0));
    test('score 12 → 1', () => expect(RulesEngine.modifier(12), 1));
    test('score 8  → -1', () => expect(RulesEngine.modifier(8), -1));
    test('score 9  → -1', () => expect(RulesEngine.modifier(9), -1));
    test('score 20 → 5', () => expect(RulesEngine.modifier(20), 5));
    test('score 1  → -5', () => expect(RulesEngine.modifier(1), -5));
    test('score 15 → 2', () => expect(RulesEngine.modifier(15), 2));
  });

  // ---------------------------------------------------------------------------
  // proficiencyBonus()
  // ---------------------------------------------------------------------------

  group('proficiencyBonus()', () {
    test('level 1  → +2', () => expect(RulesEngine.proficiencyBonus(1), 2));
    test('level 4  → +2', () => expect(RulesEngine.proficiencyBonus(4), 2));
    test('level 5  → +3', () => expect(RulesEngine.proficiencyBonus(5), 3));
    test('level 8  → +3', () => expect(RulesEngine.proficiencyBonus(8), 3));
    test('level 9  → +4', () => expect(RulesEngine.proficiencyBonus(9), 4));
    test('level 13 → +5', () => expect(RulesEngine.proficiencyBonus(13), 5));
    test('level 17 → +6', () => expect(RulesEngine.proficiencyBonus(17), 6));
    test('level 20 → +6', () => expect(RulesEngine.proficiencyBonus(20), 6));
  });

  // ---------------------------------------------------------------------------
  // abilityScore() — racial bonuses
  // ---------------------------------------------------------------------------

  group('abilityScore() with racial bonus', () {
    test('Dwarf Fighter CON base 13 → score 15 (+2 racial)', () {
      final c = _make(
        raceId: 'dwarf',
        base: {
          Ability.strength: 15,
          Ability.dexterity: 14,
          Ability.constitution: 13,
          Ability.intelligence: 12,
          Ability.wisdom: 10,
          Ability.charisma: 8,
        },
      );
      expect(RulesEngine.abilityScore(c, Ability.constitution), 15);
      expect(RulesEngine.abilityScore(c, Ability.strength), 15); // no bonus
    });

    test('Human gets +1 to all', () {
      final c = _make(
        raceId: 'human',
        base: {for (final a in Ability.values) a: 10},
      );
      for (final a in Ability.values) {
        expect(RulesEngine.abilityScore(c, a), 11,
            reason: '${a.abbr} should be 10+1=11');
      }
    });

    test('Tiefling CHA +2 INT +1', () {
      final c = _make(
        raceId: 'tiefling',
        base: {
          Ability.strength: 10,
          Ability.dexterity: 10,
          Ability.constitution: 10,
          Ability.intelligence: 10,
          Ability.wisdom: 10,
          Ability.charisma: 10,
        },
      );
      expect(RulesEngine.abilityScore(c, Ability.charisma), 12);
      expect(RulesEngine.abilityScore(c, Ability.intelligence), 11);
      expect(RulesEngine.abilityScore(c, Ability.strength), 10);
    });
  });

  // ---------------------------------------------------------------------------
  // skillModifier()
  // ---------------------------------------------------------------------------

  group('skillModifier()', () {
    test('not proficient: returns only ability mod', () {
      // Elf, DEX base 14 → score 16 → mod +3. Not proficient in Stealth.
      final c = _make(
        raceId: 'elf',
        base: {
          Ability.strength: 10,
          Ability.dexterity: 14,
          Ability.constitution: 10,
          Ability.intelligence: 10,
          Ability.wisdom: 10,
          Ability.charisma: 10,
        },
        skills: {},
      );
      expect(RulesEngine.skillModifier(c, Skill.stealth), 3);
    });

    test('proficient lvl 1: adds +2 proficiency bonus', () {
      final c = _make(
        raceId: 'elf',
        level: 1,
        base: {
          Ability.strength: 10,
          Ability.dexterity: 14,
          Ability.constitution: 10,
          Ability.intelligence: 10,
          Ability.wisdom: 10,
          Ability.charisma: 10,
        },
        skills: {Skill.stealth},
      );
      // DEX score 16 → mod +3, prof +2 → total +5
      expect(RulesEngine.skillModifier(c, Skill.stealth), 5);
    });

    test('proficient lvl 5: adds +3 proficiency bonus', () {
      final c = _make(
        raceId: 'human',
        level: 5,
        base: {
          Ability.strength: 10,
          Ability.dexterity: 10,
          Ability.constitution: 10,
          Ability.intelligence: 10,
          Ability.wisdom: 10,
          Ability.charisma: 10,
        },
        skills: {Skill.perception},
      );
      // Human: WIS 10+1=11 → mod 0, prof lvl5 = +3 → total +3
      expect(RulesEngine.skillModifier(c, Skill.perception), 3);
    });
  });

  // ---------------------------------------------------------------------------
  // saveModifier()
  // ---------------------------------------------------------------------------

  group('saveModifier()', () {
    test('STR save, proficient Fighter lvl1', () {
      final c = _make(
        raceId: 'human',
        level: 1,
        base: {
          Ability.strength: 15,
          Ability.dexterity: 10,
          Ability.constitution: 10,
          Ability.intelligence: 10,
          Ability.wisdom: 10,
          Ability.charisma: 10,
        },
        saves: {Ability.strength},
      );
      // Human STR 15+1=16 → mod +3, prof +2 → +5
      expect(RulesEngine.saveModifier(c, Ability.strength), 5);
    });

    test('INT save, not proficient', () {
      final c = _make(
        raceId: 'human',
        level: 1,
        base: {
          Ability.strength: 10,
          Ability.dexterity: 10,
          Ability.constitution: 10,
          Ability.intelligence: 12,
          Ability.wisdom: 10,
          Ability.charisma: 10,
        },
        saves: {},
      );
      // Human INT 12+1=13 → mod +1, no prof → +1
      expect(RulesEngine.saveModifier(c, Ability.intelligence), 1);
    });
  });

  // ---------------------------------------------------------------------------
  // armorClass / initiative / passivePerception
  // ---------------------------------------------------------------------------

  group('derived combat stats', () {
    test('AC unarmored = 10 + DEX mod', () {
      final c = _make(
        raceId: 'dwarf',
        base: {
          Ability.strength: 10,
          Ability.dexterity: 14,
          Ability.constitution: 10,
          Ability.intelligence: 10,
          Ability.wisdom: 10,
          Ability.charisma: 10,
        },
      );
      // Dwarf no DEX bonus: DEX 14 → mod +2 → AC 12
      expect(RulesEngine.armorClass(c), 12);
    });

    test('initiative = DEX modifier', () {
      final c = _make(
        raceId: 'human',
        base: {
          Ability.strength: 10,
          Ability.dexterity: 16,
          Ability.constitution: 10,
          Ability.intelligence: 10,
          Ability.wisdom: 10,
          Ability.charisma: 10,
        },
      );
      // Human DEX 16+1=17 → mod +3
      expect(RulesEngine.initiative(c), 3);
    });

    test('passive perception = 10 + perception modifier', () {
      final c = _make(
        raceId: 'human',
        level: 1,
        base: {
          Ability.strength: 10,
          Ability.dexterity: 10,
          Ability.constitution: 10,
          Ability.intelligence: 10,
          Ability.wisdom: 14,
          Ability.charisma: 10,
        },
        skills: {Skill.perception},
      );
      // Human WIS 14+1=15 → mod +2, proficient lvl1 +2 → perception +4
      // Passive = 10+4 = 14
      expect(RulesEngine.passivePerception(c), 14);
    });
  });

  // ---------------------------------------------------------------------------
  // maxHp()
  // ---------------------------------------------------------------------------

  group('maxHp()', () {
    test('Fighter d10 CON+2 lvl1 → 12', () {
      expect(RulesEngine.maxHp(hitDie: 10, conModifier: 2, level: 1), 12);
    });

    test('Wizard d6 CON+0 lvl1 → 6', () {
      expect(RulesEngine.maxHp(hitDie: 6, conModifier: 0, level: 1), 6);
    });

    test('Barbarian d12 CON+2 lvl2 → 12 + (7+2) = 21', () {
      // lvl1: 12+2=14; lvl2: +averageRoll(12)+2 = +7+2 = +9 → 23
      expect(RulesEngine.maxHp(hitDie: 12, conModifier: 2, level: 2), 23);
    });

    test('Minimum HP is always at least 1', () {
      expect(RulesEngine.maxHp(hitDie: 6, conModifier: -5, level: 1), 1);
    });

    test('maxHpForCharacter: Dwarf Fighter STR15 DEX14 CON13 lvl1', () {
      // Dwarf: CON 13+2=15 → mod +2. Fighter d10. HP = 10+2 = 12
      final c = _make(
        raceId: 'dwarf',
        classId: 'fighter',
        level: 1,
        base: {
          Ability.strength: 15,
          Ability.dexterity: 14,
          Ability.constitution: 13,
          Ability.intelligence: 12,
          Ability.wisdom: 10,
          Ability.charisma: 8,
        },
      );
      expect(RulesEngine.maxHpForCharacter(c), 12);
    });
  });

  // ---------------------------------------------------------------------------
  // signed()
  // ---------------------------------------------------------------------------

  group('signed()', () {
    test('positive → "+N"', () => expect(RulesEngine.signed(3), '+3'));
    test('zero → "+0"', () => expect(RulesEngine.signed(0), '+0'));
    test('negative → "-N"', () => expect(RulesEngine.signed(-2), '-2'));
  });

  // ---------------------------------------------------------------------------
  // AbilityGenerator
  // ---------------------------------------------------------------------------

  group('AbilityGenerator.pointBuy', () {
    test('all 8s costs 0 points', () {
      expect(AbilityGenerator.pointBuySpent(List.filled(6, 8)), 0);
      expect(AbilityGenerator.pointBuyRemaining(List.filled(6, 8)), 27);
    });

    test('all 15s costs 54 points (over budget)', () {
      expect(AbilityGenerator.pointBuySpent(List.filled(6, 15)), 54);
    });

    test('standard optimised buy: 15,15,15,8,8,8 costs 27', () {
      expect(
          AbilityGenerator.pointBuySpent([15, 15, 15, 8, 8, 8]), 27);
    });
  });

  group('AbilityGenerator.standardArray', () {
    test('has 6 values', () {
      expect(AbilityGenerator.standardArray.length, 6);
    });
    test('sum is 72', () {
      expect(AbilityGenerator.standardArray.reduce((a, b) => a + b), 72);
    });
    test('contains 15 and 8', () {
      expect(AbilityGenerator.standardArray, containsAll([15, 8]));
    });
  });

  group('AbilityGenerator.roll4d6DropLowest', () {
    test('returns 6 values', () {
      expect(AbilityGenerator.roll4d6DropLowest().length, 6);
    });
    test('all values between 3 and 18', () {
      for (final v in AbilityGenerator.roll4d6DropLowest()) {
        expect(v, inInclusiveRange(3, 18));
      }
    });
    test('sorted descending', () {
      final values = AbilityGenerator.roll4d6DropLowest();
      for (var i = 0; i < values.length - 1; i++) {
        expect(values[i], greaterThanOrEqualTo(values[i + 1]));
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Character toJson / fromJson round-trip
  // ---------------------------------------------------------------------------

  group('Character serialization', () {
    test('round-trip preserves all fields', () {
      final original = _make(
        raceId: 'elf',
        classId: 'rogue',
        level: 3,
        base: {
          Ability.strength: 8,
          Ability.dexterity: 15,
          Ability.constitution: 14,
          Ability.intelligence: 10,
          Ability.wisdom: 12,
          Ability.charisma: 13,
        },
        skills: {Skill.stealth, Skill.perception},
        saves: {Ability.dexterity, Ability.intelligence},
      );
      original.maxHp = 22;
      original.currentHp = 17;
      original.biography = 'Тестовая биография';

      final json = original.toJson();
      final restored = Character.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.level, original.level);
      expect(restored.raceId, original.raceId);
      expect(restored.classId, original.classId);
      expect(restored.maxHp, original.maxHp);
      expect(restored.currentHp, original.currentHp);
      expect(restored.biography, original.biography);
      expect(restored.skillProficiencies, original.skillProficiencies);
      expect(
          restored.savingThrowProficiencies, original.savingThrowProficiencies);
      for (final a in Ability.values) {
        expect(
          restored.baseAbilities[a],
          original.baseAbilities[a],
          reason: '${a.abbr} mismatch',
        );
      }
    });
  });
}
