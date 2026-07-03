// MOCK CONTRACT — см. ability.dart.
//
// Черновик персонажа, который собирает мастер (зона B). Поля повторяют
// раздел 6 PRD (`Character` JSON), но без id/createdAt/updatedAt — это
// проставит репозиторий Dev D при реальном сохранении. Здесь `toPreviewJson`
// нужен только для демонстрации итога на экране "Обзор".

import 'ability.dart';

class CharacterDraft {
  final String name;
  final int level;
  final String raceId;
  final String classId;
  final String backgroundId;
  final AbilityMethod abilityMethod;
  final Map<AbilityScore, int> baseAbilities;
  final Set<String> skillProficiencies;
  final List<AbilityScore> savingThrowProficiencies;
  final int maxHp;
  final int currentHp;
  final String biography;

  const CharacterDraft({
    required this.name,
    required this.level,
    required this.raceId,
    required this.classId,
    required this.backgroundId,
    required this.abilityMethod,
    required this.baseAbilities,
    required this.skillProficiencies,
    required this.savingThrowProficiencies,
    required this.maxHp,
    required this.currentHp,
    required this.biography,
  });

  Map<String, dynamic> toPreviewJson() => {
        'name': name,
        'level': level,
        'raceId': raceId,
        'classId': classId,
        'backgroundId': backgroundId,
        'abilityMethod': abilityMethod.name,
        'baseAbilities': {
          for (final entry in baseAbilities.entries) entry.key.shortCode.toLowerCase(): entry.value,
        },
        'skillProficiencies': skillProficiencies.toList()..sort(),
        'savingThrowProficiencies': savingThrowProficiencies.map((a) => a.shortCode.toLowerCase()).toList(),
        'maxHp': maxHp,
        'currentHp': currentHp,
        'biography': biography,
      };
}
