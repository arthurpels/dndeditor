// MOCK CONTRACT — см. ability.dart. Классы PHB 2014, раздел 7.6 PRD.

import 'ability.dart';
import 'skill.dart';

class ClassOption {
  final String id;
  final String nameRu;
  final int hitDie; // d6/d8/d10/d12 -> 6/8/10/12
  final List<AbilityScore> savingThrows; // ровно 2
  final int skillChoiceCount;
  final List<String> availableSkillIds;

  const ClassOption({
    required this.id,
    required this.nameRu,
    required this.hitDie,
    required this.savingThrows,
    required this.skillChoiceCount,
    required this.availableSkillIds,
  });
}

final List<ClassOption> mockClasses = [
  ClassOption(
    id: 'barbarian',
    nameRu: 'Варвар',
    hitDie: 12,
    savingThrows: [AbilityScore.strength, AbilityScore.constitution],
    skillChoiceCount: 2,
    availableSkillIds: [
      'animal_handling', 'athletics', 'intimidation', 'nature', 'perception', 'survival',
    ],
  ),
  ClassOption(
    id: 'bard',
    nameRu: 'Бард',
    hitDie: 8,
    savingThrows: [AbilityScore.dexterity, AbilityScore.charisma],
    skillChoiceCount: 3,
    availableSkillIds: allSkillIds,
  ),
  ClassOption(
    id: 'cleric',
    nameRu: 'Жрец',
    hitDie: 8,
    savingThrows: [AbilityScore.wisdom, AbilityScore.charisma],
    skillChoiceCount: 2,
    availableSkillIds: ['history', 'insight', 'medicine', 'persuasion', 'religion'],
  ),
  ClassOption(
    id: 'druid',
    nameRu: 'Друид',
    hitDie: 8,
    savingThrows: [AbilityScore.intelligence, AbilityScore.wisdom],
    skillChoiceCount: 2,
    availableSkillIds: [
      'arcana', 'animal_handling', 'insight', 'medicine', 'nature', 'perception', 'religion', 'survival',
    ],
  ),
  ClassOption(
    id: 'fighter',
    nameRu: 'Воин',
    hitDie: 10,
    savingThrows: [AbilityScore.strength, AbilityScore.constitution],
    skillChoiceCount: 2,
    availableSkillIds: [
      'acrobatics', 'animal_handling', 'athletics', 'history', 'insight', 'intimidation', 'perception', 'survival',
    ],
  ),
  ClassOption(
    id: 'monk',
    nameRu: 'Монах',
    hitDie: 8,
    savingThrows: [AbilityScore.strength, AbilityScore.dexterity],
    skillChoiceCount: 2,
    availableSkillIds: ['acrobatics', 'athletics', 'history', 'insight', 'religion', 'stealth'],
  ),
  ClassOption(
    id: 'paladin',
    nameRu: 'Паладин',
    hitDie: 10,
    savingThrows: [AbilityScore.wisdom, AbilityScore.charisma],
    skillChoiceCount: 2,
    availableSkillIds: ['athletics', 'insight', 'intimidation', 'medicine', 'persuasion', 'religion'],
  ),
  ClassOption(
    id: 'ranger',
    nameRu: 'Следопыт',
    hitDie: 10,
    savingThrows: [AbilityScore.strength, AbilityScore.dexterity],
    skillChoiceCount: 3,
    availableSkillIds: [
      'animal_handling', 'athletics', 'insight', 'investigation', 'nature', 'perception', 'stealth', 'survival',
    ],
  ),
  ClassOption(
    id: 'rogue',
    nameRu: 'Плут',
    hitDie: 8,
    savingThrows: [AbilityScore.dexterity, AbilityScore.intelligence],
    skillChoiceCount: 4,
    availableSkillIds: [
      'acrobatics', 'athletics', 'deception', 'insight', 'intimidation', 'investigation',
      'perception', 'performance', 'persuasion', 'sleight_of_hand', 'stealth',
    ],
  ),
  ClassOption(
    id: 'sorcerer',
    nameRu: 'Чародей',
    hitDie: 6,
    savingThrows: [AbilityScore.constitution, AbilityScore.charisma],
    skillChoiceCount: 2,
    availableSkillIds: ['arcana', 'deception', 'insight', 'intimidation', 'persuasion', 'religion'],
  ),
  ClassOption(
    id: 'warlock',
    nameRu: 'Колдун',
    hitDie: 8,
    savingThrows: [AbilityScore.wisdom, AbilityScore.charisma],
    skillChoiceCount: 2,
    availableSkillIds: ['arcana', 'deception', 'history', 'intimidation', 'investigation', 'nature', 'religion'],
  ),
  ClassOption(
    id: 'wizard',
    nameRu: 'Волшебник',
    hitDie: 6,
    savingThrows: [AbilityScore.intelligence, AbilityScore.wisdom],
    skillChoiceCount: 2,
    availableSkillIds: ['arcana', 'history', 'insight', 'investigation', 'medicine', 'religion'],
  ),
];

ClassOption classById(String id) => mockClasses.firstWhere((c) => c.id == id);
