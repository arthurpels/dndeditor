import '../models/ability.dart';
import '../models/skill.dart';

/// A D&D class: hit die, saving throw proficiencies, skill choices (PHB 2014).
class CharClass {
  const CharClass({
    required this.id,
    required this.name,
    required this.hitDie,
    required this.savingThrows,
    required this.skillChoices,
    required this.skillOptions,
    this.description = '',
  });

  final String id;
  final String name;
  final int hitDie;
  final List<Ability> savingThrows;
  final int skillChoices;
  final List<Skill> skillOptions;
  final String description;
}

final List<CharClass> kClasses = [
  const CharClass(
    id: 'barbarian',
    name: 'Варвар',
    hitDie: 12,
    savingThrows: [Ability.strength, Ability.constitution],
    skillChoices: 2,
    skillOptions: [
      Skill.animalHandling, Skill.athletics, Skill.intimidation,
      Skill.nature, Skill.perception, Skill.survival,
    ],
    description: 'Кость хитов d12.',
  ),
  CharClass(
    id: 'bard',
    name: 'Бард',
    hitDie: 8,
    savingThrows: const [Ability.dexterity, Ability.charisma],
    skillChoices: 3,
    skillOptions: Skill.values,
    description: 'Кость хитов d8. Любые 3 навыка.',
  ),
  const CharClass(
    id: 'cleric',
    name: 'Жрец',
    hitDie: 8,
    savingThrows: [Ability.wisdom, Ability.charisma],
    skillChoices: 2,
    skillOptions: [
      Skill.history, Skill.insight, Skill.medicine,
      Skill.persuasion, Skill.religion,
    ],
    description: 'Кость хитов d8.',
  ),
  const CharClass(
    id: 'druid',
    name: 'Друид',
    hitDie: 8,
    savingThrows: [Ability.intelligence, Ability.wisdom],
    skillChoices: 2,
    skillOptions: [
      Skill.arcana, Skill.animalHandling, Skill.insight, Skill.medicine,
      Skill.nature, Skill.perception, Skill.religion, Skill.survival,
    ],
    description: 'Кость хитов d8.',
  ),
  const CharClass(
    id: 'fighter',
    name: 'Воин',
    hitDie: 10,
    savingThrows: [Ability.strength, Ability.constitution],
    skillChoices: 2,
    skillOptions: [
      Skill.acrobatics, Skill.animalHandling, Skill.athletics,
      Skill.history, Skill.insight, Skill.intimidation,
      Skill.perception, Skill.survival,
    ],
    description: 'Кость хитов d10.',
  ),
  const CharClass(
    id: 'monk',
    name: 'Монах',
    hitDie: 8,
    savingThrows: [Ability.strength, Ability.dexterity],
    skillChoices: 2,
    skillOptions: [
      Skill.acrobatics, Skill.athletics, Skill.history,
      Skill.insight, Skill.religion, Skill.stealth,
    ],
    description: 'Кость хитов d8.',
  ),
  const CharClass(
    id: 'paladin',
    name: 'Паладин',
    hitDie: 10,
    savingThrows: [Ability.wisdom, Ability.charisma],
    skillChoices: 2,
    skillOptions: [
      Skill.athletics, Skill.insight, Skill.intimidation,
      Skill.medicine, Skill.persuasion, Skill.religion,
    ],
    description: 'Кость хитов d10.',
  ),
  const CharClass(
    id: 'ranger',
    name: 'Следопыт',
    hitDie: 10,
    savingThrows: [Ability.strength, Ability.dexterity],
    skillChoices: 3,
    skillOptions: [
      Skill.animalHandling, Skill.athletics, Skill.insight,
      Skill.investigation, Skill.nature, Skill.perception,
      Skill.stealth, Skill.survival,
    ],
    description: 'Кость хитов d10.',
  ),
  const CharClass(
    id: 'rogue',
    name: 'Плут',
    hitDie: 8,
    savingThrows: [Ability.dexterity, Ability.intelligence],
    skillChoices: 4,
    skillOptions: [
      Skill.acrobatics, Skill.athletics, Skill.deception,
      Skill.insight, Skill.intimidation, Skill.investigation,
      Skill.perception, Skill.performance, Skill.persuasion,
      Skill.sleightOfHand, Skill.stealth,
    ],
    description: 'Кость хитов d8.',
  ),
  const CharClass(
    id: 'sorcerer',
    name: 'Чародей',
    hitDie: 6,
    savingThrows: [Ability.constitution, Ability.charisma],
    skillChoices: 2,
    skillOptions: [
      Skill.arcana, Skill.deception, Skill.insight,
      Skill.intimidation, Skill.persuasion, Skill.religion,
    ],
    description: 'Кость хитов d6.',
  ),
  const CharClass(
    id: 'warlock',
    name: 'Колдун',
    hitDie: 8,
    savingThrows: [Ability.wisdom, Ability.charisma],
    skillChoices: 2,
    skillOptions: [
      Skill.arcana, Skill.deception, Skill.history,
      Skill.intimidation, Skill.investigation, Skill.nature, Skill.religion,
    ],
    description: 'Кость хитов d8.',
  ),
  const CharClass(
    id: 'wizard',
    name: 'Волшебник',
    hitDie: 6,
    savingThrows: [Ability.intelligence, Ability.wisdom],
    skillChoices: 2,
    skillOptions: [
      Skill.arcana, Skill.history, Skill.insight,
      Skill.investigation, Skill.medicine, Skill.religion,
    ],
    description: 'Кость хитов d6.',
  ),
];
