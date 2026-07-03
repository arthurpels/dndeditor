import 'package:dndeditor/wizard/mock_contract/ability.dart';
import 'package:dndeditor/wizard/mock_contract/race.dart';
import 'package:dndeditor/wizard/mock_contract/rules_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('abilityModifier (7.1)', () {
    test('matches PHB table', () {
      expect(abilityModifier(10), 0);
      expect(abilityModifier(11), 0);
      expect(abilityModifier(8), -1);
      expect(abilityModifier(15), 2);
      expect(abilityModifier(20), 5);
      expect(abilityModifier(1), -5);
    });
  });

  group('proficiencyBonusForLevel (7.2)', () {
    test('matches PHB table', () {
      expect(proficiencyBonusForLevel(1), 2);
      expect(proficiencyBonusForLevel(4), 2);
      expect(proficiencyBonusForLevel(5), 3);
      expect(proficiencyBonusForLevel(8), 3);
      expect(proficiencyBonusForLevel(9), 4);
      expect(proficiencyBonusForLevel(13), 5);
      expect(proficiencyBonusForLevel(17), 6);
      expect(proficiencyBonusForLevel(20), 6);
    });
  });

  group('valueWithProficiency (7.4)', () {
    test('adds proficiency bonus only when proficient', () {
      expect(valueWithProficiency(abilityScore: 14, proficient: false, proficiencyBonus: 2), 2);
      expect(valueWithProficiency(abilityScore: 14, proficient: true, proficiencyBonus: 2), 4);
    });
  });

  group('applyRacialBonuses (7.5)', () {
    test('dwarf gets +2 CON only', () {
      final base = {
        AbilityScore.strength: 10,
        AbilityScore.dexterity: 10,
        AbilityScore.constitution: 14,
        AbilityScore.intelligence: 10,
        AbilityScore.wisdom: 10,
        AbilityScore.charisma: 10,
      };
      final result = applyRacialBonuses(base, raceById('dwarf'));
      expect(result[AbilityScore.constitution], 16);
      expect(result[AbilityScore.strength], 10);
    });

    test('human gets +1 to all six', () {
      final base = {for (final a in AbilityScore.values) a: 10};
      final result = applyRacialBonuses(base, raceById('human'));
      for (final a in AbilityScore.values) {
        expect(result[a], 11);
      }
    });
  });

  group('derived combat stats (7.8)', () {
    test('maxHpLevel1 combines hit die and CON modifier', () {
      expect(maxHpLevel1(hitDie: 10, conModifier: 2), 12);
      expect(maxHpLevel1(hitDie: 6, conModifier: -1), 5);
    });

    test('armorClassBase and initiative use DEX modifier', () {
      expect(armorClassBase(3), 13);
      expect(initiativeValue(3), 3);
    });

    test('passivePerception adds 10 to the perception skill value', () {
      expect(passivePerception(2), 12);
    });
  });

  group('Point Buy (7.7)', () {
    test('cost table matches PRD', () {
      expect(pointBuyCost(8), 0);
      expect(pointBuyCost(13), 5);
      expect(pointBuyCost(14), 7);
      expect(pointBuyCost(15), 9);
    });

    test('all scores at 15 exceeds the 27 point budget', () {
      final scores = {for (final a in AbilityScore.values) a: 15};
      expect(pointBuyTotalCost(scores), greaterThan(pointBuyBudget));
    });

    test('a balanced spread stays within budget', () {
      final scores = {
        AbilityScore.strength: 15,
        AbilityScore.dexterity: 14,
        AbilityScore.constitution: 13,
        AbilityScore.intelligence: 12,
        AbilityScore.wisdom: 10,
        AbilityScore.charisma: 8,
      };
      expect(pointBuyTotalCost(scores), pointBuyBudget);
    });
  });

  group('4d6 drop lowest (7.7)', () {
    test('rollAbilityPool returns six values each between 3 and 18', () {
      final pool = rollAbilityPool();
      expect(pool, hasLength(6));
      for (final v in pool) {
        expect(v, inInclusiveRange(3, 18));
      }
    });
  });
}
