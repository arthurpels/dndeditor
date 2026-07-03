import 'ability.dart';

/// All 18 D&D 5e (2014) skills with their governing ability.
enum Skill {
  acrobatics(Ability.dexterity, 'Акробатика'),
  animalHandling(Ability.wisdom, 'Уход за животными'),
  arcana(Ability.intelligence, 'Магия'),
  athletics(Ability.strength, 'Атлетика'),
  deception(Ability.charisma, 'Обман'),
  history(Ability.intelligence, 'История'),
  insight(Ability.wisdom, 'Проницательность'),
  intimidation(Ability.charisma, 'Запугивание'),
  investigation(Ability.intelligence, 'Расследование'),
  medicine(Ability.wisdom, 'Медицина'),
  nature(Ability.intelligence, 'Природа'),
  perception(Ability.wisdom, 'Внимательность'),
  performance(Ability.charisma, 'Выступление'),
  persuasion(Ability.charisma, 'Убеждение'),
  religion(Ability.intelligence, 'Религия'),
  sleightOfHand(Ability.dexterity, 'Ловкость рук'),
  stealth(Ability.dexterity, 'Скрытность'),
  survival(Ability.wisdom, 'Выживание');

  const Skill(this.ability, this.label);

  final Ability ability;
  final String label;

  static Skill fromName(String value) =>
      Skill.values.firstWhere((s) => s.name == value);
}
