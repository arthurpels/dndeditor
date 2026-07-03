import 'package:flutter_test/flutter_test.dart';

import 'package:dndeditor/models/character.dart';
import 'package:dndeditor/rules/rules_engine.dart';

void main() {
  test('modifier and proficiency bonus follow D&D rules', () {
    expect(RulesEngine.modifier(15), 2);
    expect(RulesEngine.modifier(8), -1);
    expect(RulesEngine.proficiencyBonus(1), 2);
    expect(RulesEngine.proficiencyBonus(5), 3);
    expect(RulesEngine.proficiencyBonus(17), 6);
  });

  test('race, class and background lookups are available', () {
    expect(RulesEngine.raceBonus('dwarf', 'CON'), 2);
    expect(RulesEngine.raceSpeed('dwarf'), 25);
    expect(RulesEngine.hitDieForClass('fighter'), 10);
    expect(RulesEngine.savingThrowProficienciesForClass('fighter'), {'STR', 'CON'});
    expect(RulesEngine.skillProficienciesForBackground('soldier'), {'Athletics', 'Intimidation'});
  });

  test('character derives combat and skill values from rules', () {
    final character = Character.sample();

    expect(character.totalScore('CON'), 16);
    expect(character.modifierFor('CON'), 3);
    expect(character.skillValue('Athletics'), 4);
    expect(character.savingThrowValue('STR'), 4);
    expect(character.armorClass, 11);
    expect(character.initiative, 1);
    expect(character.passivePerception, 11);
    expect(character.toJson()['name'], 'Торин');
  });
}
