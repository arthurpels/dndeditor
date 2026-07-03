// MOCK CONTRACT — см. ability.dart. 18 навыков, раздел 7.3 PRD.

import 'ability.dart';

class SkillDef {
  final String id;
  final String nameRu;
  final AbilityScore ability;

  const SkillDef({required this.id, required this.nameRu, required this.ability});
}

const List<SkillDef> mockSkills = [
  SkillDef(id: 'athletics', nameRu: 'Атлетика', ability: AbilityScore.strength),
  SkillDef(id: 'acrobatics', nameRu: 'Акробатика', ability: AbilityScore.dexterity),
  SkillDef(id: 'sleight_of_hand', nameRu: 'Ловкость рук', ability: AbilityScore.dexterity),
  SkillDef(id: 'stealth', nameRu: 'Скрытность', ability: AbilityScore.dexterity),
  SkillDef(id: 'arcana', nameRu: 'Магия', ability: AbilityScore.intelligence),
  SkillDef(id: 'history', nameRu: 'История', ability: AbilityScore.intelligence),
  SkillDef(id: 'investigation', nameRu: 'Расследование', ability: AbilityScore.intelligence),
  SkillDef(id: 'nature', nameRu: 'Природа', ability: AbilityScore.intelligence),
  SkillDef(id: 'religion', nameRu: 'Религия', ability: AbilityScore.intelligence),
  SkillDef(id: 'animal_handling', nameRu: 'Уход за животными', ability: AbilityScore.wisdom),
  SkillDef(id: 'insight', nameRu: 'Проницательность', ability: AbilityScore.wisdom),
  SkillDef(id: 'medicine', nameRu: 'Медицина', ability: AbilityScore.wisdom),
  SkillDef(id: 'perception', nameRu: 'Восприятие', ability: AbilityScore.wisdom),
  SkillDef(id: 'survival', nameRu: 'Выживание', ability: AbilityScore.wisdom),
  SkillDef(id: 'deception', nameRu: 'Обман', ability: AbilityScore.charisma),
  SkillDef(id: 'intimidation', nameRu: 'Запугивание', ability: AbilityScore.charisma),
  SkillDef(id: 'performance', nameRu: 'Выступление', ability: AbilityScore.charisma),
  SkillDef(id: 'persuasion', nameRu: 'Убеждение', ability: AbilityScore.charisma),
];

SkillDef skillById(String id) => mockSkills.firstWhere((s) => s.id == id);

/// Все id навыков — используется классами вроде Барда, у которых выбор "любые".
List<String> get allSkillIds => mockSkills.map((s) => s.id).toList();
