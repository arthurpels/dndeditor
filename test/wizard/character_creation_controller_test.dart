import 'package:dndeditor/wizard/mock_contract/ability.dart';
import 'package:dndeditor/wizard/state/character_creation_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Basics step validation (FR8)', () {
    test('cannot proceed until name, race, class and background are set', () {
      final c = CharacterCreationController();
      expect(c.canProceedFromBasics, isFalse);

      c.setName('Торин');
      expect(c.canProceedFromBasics, isFalse);

      c.selectRace('dwarf');
      c.selectClass('fighter');
      expect(c.canProceedFromBasics, isFalse);

      c.selectBackground('soldier');
      expect(c.canProceedFromBasics, isTrue);
    });

    test('blank/whitespace-only name does not satisfy validation', () {
      final c = CharacterCreationController()
        ..setName('   ')
        ..selectRace('dwarf')
        ..selectClass('fighter')
        ..selectBackground('soldier');
      expect(c.canProceedFromBasics, isFalse);
    });
  });

  group('Ability generation methods (7.7)', () {
    test('standard array: each pool value can only be assigned once', () {
      final c = CharacterCreationController();
      c.assignPoolValue(AbilityScore.strength, 15);

      final availableForDex = c.availableValuesFor(AbilityScore.dexterity);
      expect(availableForDex.contains(15), isFalse);

      final availableForStr = c.availableValuesFor(AbilityScore.strength);
      expect(availableForStr.contains(15), isTrue, reason: 'own current value stays selectable');
    });

    test('canProceedFromAbilities requires all six slots filled for standard array', () {
      final c = CharacterCreationController();
      expect(c.canProceedFromAbilities, isFalse);

      const values = [15, 14, 13, 12, 10, 8];
      for (var i = 0; i < AbilityScore.values.length; i++) {
        c.assignPoolValue(AbilityScore.values[i], values[i]);
      }
      expect(c.canProceedFromAbilities, isTrue);
    });

    test('point buy rejects a score that would exceed the 27 point budget', () {
      final c = CharacterCreationController()..setAbilityMethod(AbilityMethod.pointBuy);
      for (final a in AbilityScore.values) {
        c.setPointBuyScore(a, 15);
      }
      // 6 * 9 = 54 cost, way over budget: most should have been rejected.
      expect(c.pointBuySpent, lessThanOrEqualTo(27));
      expect(c.canProceedFromAbilities, isTrue);
    });

    test('switching ability method resets prior assignments', () {
      final c = CharacterCreationController();
      c.assignPoolValue(AbilityScore.strength, 15);
      c.setAbilityMethod(AbilityMethod.rolled4d6);
      expect(c.poolValueFor(AbilityScore.strength), isNull);
    });
  });

  group('Skill selection (FR4 + background proficiencies)', () {
    test('background skills are always selected and cannot be toggled off', () {
      final c = CharacterCreationController()
        ..selectClass('fighter')
        ..selectBackground('soldier'); // soldier grants athletics + intimidation
      expect(c.isSkillSelected('athletics'), isTrue);
      c.toggleSkill('athletics');
      expect(c.isSkillSelected('athletics'), isTrue, reason: 'background skill is fixed');
    });

    test('class skill selection is capped at skillChoiceCount', () {
      final c = CharacterCreationController()
        ..selectClass('fighter') // skillChoiceCount = 2
        ..selectBackground('soldier');

      c.toggleSkill('history');
      c.toggleSkill('insight');
      expect(c.selectedClassSkills.length, 2);

      c.toggleSkill('perception'); // should be rejected, limit reached
      expect(c.selectedClassSkills.length, 2);
      expect(c.selectedClassSkills.contains('perception'), isFalse);
    });

    test('canProceedFromSkills requires exactly skillChoiceCount selections', () {
      final c = CharacterCreationController()
        ..selectClass('fighter')
        ..selectBackground('soldier');
      expect(c.canProceedFromSkills, isFalse);

      c.toggleSkill('history');
      c.toggleSkill('insight');
      expect(c.canProceedFromSkills, isTrue);
    });

    test('changing class clears previously chosen class skills', () {
      final c = CharacterCreationController()
        ..selectClass('fighter')
        ..selectBackground('soldier');
      c.toggleSkill('history');
      expect(c.selectedClassSkills, contains('history'));

      c.selectClass('wizard');
      expect(c.selectedClassSkills, isEmpty);
    });
  });

  group('Navigation gating', () {
    test('nextStep refuses to advance past an incomplete basics step', () {
      final c = CharacterCreationController();
      c.nextStep();
      expect(c.currentStep, WizardStep.basics);
    });

    test('a fully completed wizard reaches the review step', () {
      final c = CharacterCreationController()
        ..setName('Торин')
        ..selectRace('dwarf')
        ..selectClass('fighter')
        ..selectBackground('soldier');
      c.nextStep(); // -> abilities
      expect(c.currentStep, WizardStep.abilities);

      const values = [15, 14, 13, 12, 10, 8];
      for (var i = 0; i < AbilityScore.values.length; i++) {
        c.assignPoolValue(AbilityScore.values[i], values[i]);
      }
      c.nextStep(); // -> skills
      expect(c.currentStep, WizardStep.skills);

      c.toggleSkill('history');
      c.toggleSkill('insight');
      c.nextStep(); // -> review
      expect(c.currentStep, WizardStep.review);
    });
  });

  group('buildDraft', () {
    test('produces a draft with racial bonuses baked into HP but not baseAbilities', () {
      final c = CharacterCreationController()
        ..setName('Торин')
        ..selectRace('dwarf') // CON +2
        ..selectClass('fighter') // d10, STR/CON saves
        ..selectBackground('soldier');

      const values = [15, 14, 13, 12, 10, 8];
      for (var i = 0; i < AbilityScore.values.length; i++) {
        c.assignPoolValue(AbilityScore.values[i], values[i]);
      }
      c.toggleSkill('history');
      c.toggleSkill('insight');

      final draft = c.buildDraft();
      expect(draft.name, 'Торин');
      expect(draft.skillProficiencies, {'athletics', 'intimidation', 'history', 'insight'});
      expect(draft.savingThrowProficiencies, [AbilityScore.strength, AbilityScore.constitution]);
      // Assignment order [str,dex,con,int,wis,cha] <- [15,14,13,12,10,8] => base CON = 13.
      expect(draft.baseAbilities[AbilityScore.constitution], 13);
      // Dwarf +2 CON => final CON 15 (mod +2); fighter hit die d10 => maxHp = 10 + 2 = 12.
      expect(draft.maxHp, 12);
      expect(draft.currentHp, draft.maxHp);
    });
  });
}
