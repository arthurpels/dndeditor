import '../models/skill.dart';

/// A background grants two fixed skill proficiencies (PHB 2014, simplified for MVP).
class Background {
  const Background({
    required this.id,
    required this.name,
    required this.skillProficiencies,
    this.description = '',
  });

  final String id;
  final String name;
  final List<Skill> skillProficiencies;
  final String description;
}

const List<Background> kBackgrounds = [
  Background(
    id: 'soldier',
    name: 'Солдат',
    skillProficiencies: [Skill.athletics, Skill.intimidation],
    description: 'Владение: Атлетика, Запугивание.',
  ),
  Background(
    id: 'acolyte',
    name: 'Прислужник',
    skillProficiencies: [Skill.insight, Skill.religion],
    description: 'Владение: Проницательность, Религия.',
  ),
  Background(
    id: 'criminal',
    name: 'Преступник',
    skillProficiencies: [Skill.deception, Skill.stealth],
    description: 'Владение: Обман, Скрытность.',
  ),
  Background(
    id: 'sage',
    name: 'Мудрец',
    skillProficiencies: [Skill.arcana, Skill.history],
    description: 'Владение: Магия, История.',
  ),
  Background(
    id: 'folk_hero',
    name: 'Народный герой',
    skillProficiencies: [Skill.animalHandling, Skill.survival],
    description: 'Владение: Уход за животными, Выживание.',
  ),
];
