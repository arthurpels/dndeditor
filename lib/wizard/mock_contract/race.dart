// MOCK CONTRACT — см. ability.dart. Данные рас, раздел 7.5 PRD.

import 'ability.dart';

class RaceOption {
  final String id;
  final String nameRu;
  final Map<AbilityScore, int> abilityBonuses;
  final int speed;
  final String description;

  const RaceOption({
    required this.id,
    required this.nameRu,
    required this.abilityBonuses,
    required this.speed,
    required this.description,
  });

  int bonusFor(AbilityScore ability) => abilityBonuses[ability] ?? 0;
}

/// Базовые расы PHB 2014 (раздел 7.5). Half-Elf упрощён: фиксированная пара
/// DEX/WIS вместо выбора игрока — так решено в PRD ради скорости MVP.
const List<RaceOption> mockRaces = [
  RaceOption(
    id: 'human',
    nameRu: 'Человек',
    abilityBonuses: {
      AbilityScore.strength: 1,
      AbilityScore.dexterity: 1,
      AbilityScore.constitution: 1,
      AbilityScore.intelligence: 1,
      AbilityScore.wisdom: 1,
      AbilityScore.charisma: 1,
    },
    speed: 30,
    description: '+1 ко всем шести характеристикам.',
  ),
  RaceOption(
    id: 'dwarf',
    nameRu: 'Дварф',
    abilityBonuses: {AbilityScore.constitution: 2},
    speed: 25,
    description: 'CON +2.',
  ),
  RaceOption(
    id: 'elf',
    nameRu: 'Эльф',
    abilityBonuses: {AbilityScore.dexterity: 2},
    speed: 30,
    description: 'DEX +2.',
  ),
  RaceOption(
    id: 'halfling',
    nameRu: 'Полурослик',
    abilityBonuses: {AbilityScore.dexterity: 2},
    speed: 25,
    description: 'DEX +2.',
  ),
  RaceOption(
    id: 'dragonborn',
    nameRu: 'Драконорождённый',
    abilityBonuses: {AbilityScore.strength: 2, AbilityScore.charisma: 1},
    speed: 30,
    description: 'STR +2, CHA +1.',
  ),
  RaceOption(
    id: 'gnome',
    nameRu: 'Гном',
    abilityBonuses: {AbilityScore.intelligence: 2},
    speed: 25,
    description: 'INT +2.',
  ),
  RaceOption(
    id: 'half_elf',
    nameRu: 'Полуэльф',
    abilityBonuses: {
      AbilityScore.charisma: 2,
      AbilityScore.dexterity: 1,
      AbilityScore.wisdom: 1,
    },
    speed: 30,
    description: 'CHA +2, DEX +1, WIS +1 (упрощено для MVP).',
  ),
  RaceOption(
    id: 'half_orc',
    nameRu: 'Полуорк',
    abilityBonuses: {AbilityScore.strength: 2, AbilityScore.constitution: 1},
    speed: 30,
    description: 'STR +2, CON +1.',
  ),
  RaceOption(
    id: 'tiefling',
    nameRu: 'Тифлинг',
    abilityBonuses: {AbilityScore.charisma: 2, AbilityScore.intelligence: 1},
    speed: 30,
    description: 'CHA +2, INT +1.',
  ),
];

RaceOption raceById(String id) => mockRaces.firstWhere((r) => r.id == id);
