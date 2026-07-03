import '../models/ability.dart';

/// A D&D race definition: racial ability bonuses and base speed (PHB 2014).
class Race {
  const Race({
    required this.id,
    required this.name,
    this.abilityBonuses = const {},
    this.speed = 30,
    this.description = '',
  });

  final String id;
  final String name;
  final Map<Ability, int> abilityBonuses;
  final int speed;
  final String description;
}

/// Core PHB 2014 races. Sub-races and Variant Human omitted for MVP.
const List<Race> kRaces = [
  Race(
    id: 'human',
    name: 'Человек',
    speed: 30,
    abilityBonuses: {
      Ability.strength: 1,
      Ability.dexterity: 1,
      Ability.constitution: 1,
      Ability.intelligence: 1,
      Ability.wisdom: 1,
      Ability.charisma: 1,
    },
    description: '+1 ко всем характеристикам.',
  ),
  Race(
    id: 'dwarf',
    name: 'Дварф',
    speed: 25,
    abilityBonuses: {Ability.constitution: 2},
    description: '+2 Телосложение.',
  ),
  Race(
    id: 'elf',
    name: 'Эльф',
    speed: 30,
    abilityBonuses: {Ability.dexterity: 2},
    description: '+2 Ловкость.',
  ),
  Race(
    id: 'halfling',
    name: 'Полурослик',
    speed: 25,
    abilityBonuses: {Ability.dexterity: 2},
    description: '+2 Ловкость.',
  ),
  Race(
    id: 'dragonborn',
    name: 'Драконорождённый',
    speed: 30,
    abilityBonuses: {Ability.strength: 2, Ability.charisma: 1},
    description: '+2 Сила, +1 Харизма.',
  ),
  Race(
    id: 'gnome',
    name: 'Гном',
    speed: 25,
    abilityBonuses: {Ability.intelligence: 2},
    description: '+2 Интеллект.',
  ),
  Race(
    id: 'half_orc',
    name: 'Полуорк',
    speed: 30,
    abilityBonuses: {Ability.strength: 2, Ability.constitution: 1},
    description: '+2 Сила, +1 Телосложение.',
  ),
  Race(
    id: 'tiefling',
    name: 'Тифлинг',
    speed: 30,
    abilityBonuses: {Ability.charisma: 2, Ability.intelligence: 1},
    description: '+2 Харизма, +1 Интеллект.',
  ),
];
