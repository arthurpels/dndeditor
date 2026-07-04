import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/ability.dart' as model;
import '../../models/character.dart';
import '../../models/skill.dart';
import '../../repository/character_repository.dart';
import '../mock_contract/ability.dart';
import '../mock_contract/rules_engine.dart';
import '../mock_contract/skill.dart';
import '../state/character_creation_controller.dart';
import '../widgets/wizard_step_scaffold.dart';

class ReviewStep extends StatelessWidget {
  const ReviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CharacterCreationController>();

    if (controller.selectedRace == null ||
        controller.selectedClass == null ||
        controller.selectedBackground == null) {
      return const WizardStepScaffold(
        title: 'Обзор',
        child: Text('Заполните предыдущие шаги, чтобы увидеть предпросмотр.'),
      );
    }

    final race = controller.selectedRace!;
    final cls = controller.selectedClass!;
    final background = controller.selectedBackground!;
    final profBonus = proficiencyBonusForLevel(1);
    final finalAbilities = controller.finalAbilities;
    final skillProficiencies = controller.skillProficiencies;
    final dexMod = controller.modifierFor(AbilityScore.dexterity);
    final perceptionValue = valueWithProficiency(
      abilityScore: finalAbilities[AbilityScore.wisdom]!,
      proficient: skillProficiencies.contains('perception'),
      proficiencyBonus: profBonus,
    );

    return WizardStepScaffold(
      title: 'Обзор персонажа',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(controller.name, style: Theme.of(context).textTheme.headlineMedium),
          Text('${race.nameRu} · ${cls.nameRu} · ${background.nameRu} · Уровень 1'),
          const SizedBox(height: 20),

          Text('Характеристики', style: Theme.of(context).textTheme.titleMedium),
          for (final ability in AbilityScore.values)
            Text(
              '${ability.shortCode}: ${finalAbilities[ability]} '
              '(мод. ${_fmt(controller.modifierFor(ability))})',
            ),
          const SizedBox(height: 12),

          Text('Бонус мастерства: +$profBonus'),
          Text(
            'Спасброски: ${controller.savingThrowProficiencies.map((a) => '${a.shortCode} ${_fmt(valueWithProficiency(abilityScore: finalAbilities[a]!, proficient: true, proficiencyBonus: profBonus))}').join(', ')}',
          ),
          const SizedBox(height: 20),

          Text('Навыки', style: Theme.of(context).textTheme.titleMedium),
          for (final skillId in skillProficiencies.toList()..sort())
            Builder(builder: (context) {
              final skill = skillById(skillId);
              final val = valueWithProficiency(
                abilityScore: finalAbilities[skill.ability]!,
                proficient: true,
                proficiencyBonus: profBonus,
              );
              return Text('${skill.nameRu}: ${_fmt(val)}');
            }),
          const SizedBox(height: 20),

          Text('Боевые параметры', style: Theme.of(context).textTheme.titleMedium),
          Text('HP: ${controller.maxHp} / ${controller.maxHp}'),
          Text('AC: ${armorClassBase(dexMod)}'),
          Text('Инициатива: ${_fmt(initiativeValue(dexMod))}'),
          Text('Скорость: ${race.speed} фт.'),
          Text('Пассивное восприятие: ${passivePerception(perceptionValue)}'),
          const SizedBox(height: 20),

          TextFormField(
            initialValue: controller.biography,
            decoration: const InputDecoration(labelText: 'Заметки / биография'),
            maxLines: 3,
            onChanged: controller.setBiography,
          ),
          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: () => _save(context, controller),
            icon: const Icon(Icons.save),
            label: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _save(BuildContext context, CharacterCreationController controller) {
    final draft = controller.buildDraft();

    // AbilityScore (mock) и Ability (model) идут в одном порядке — индекс совпадает
    final baseAbilities = <model.Ability, int>{
      for (final entry in draft.baseAbilities.entries)
        model.Ability.values[AbilityScore.values.indexOf(entry.key)]: entry.value,
    };

    // mock использует snake_case ('sleight_of_hand'), Skill.fromName ждёт camelCase
    final skills = draft.skillProficiencies
        .map((id) => Skill.fromName(_toCamel(id)))
        .toSet();

    final saves = draft.savingThrowProficiencies
        .map((a) => model.Ability.values[AbilityScore.values.indexOf(a)])
        .toSet();

    final abilityMethodStr = switch (draft.abilityMethod) {
      AbilityMethod.standardArray => 'standard_array',
      AbilityMethod.pointBuy => 'point_buy',
      AbilityMethod.rolled4d6 => 'roll',
    };

    // nameRu может содержать ✦ для homebrew — убираем значок для хранения
    final raceName = _stripBadge(controller.selectedRace?.nameRu);
    final className = _stripBadge(controller.selectedClass?.nameRu);

    final character = Character(
      id: 'wizard',
      name: draft.name,
      level: draft.level,
      raceId: draft.raceId,
      classId: draft.classId,
      race: raceName,
      characterClass: className,
      backgroundId: draft.backgroundId,
      abilityMethod: abilityMethodStr,
      baseAbilities: baseAbilities,
      skillProficiencies: skills,
      savingThrowProficiencies: saves,
      maxHp: draft.maxHp,
      currentHp: draft.currentHp,
      biography: draft.biography,
    );

    CharacterRepositoryScope.of(context).addToOwned(character);
    Navigator.of(context).pop();
  }

  static String? _stripBadge(String? name) =>
      name?.endsWith(' ✦') == true ? name!.substring(0, name.length - 2) : name;

  // 'animal_handling' → 'animalHandling'
  static String _toCamel(String snake) {
    final parts = snake.split('_');
    return parts.first +
        parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
  }
}

String _fmt(int modifier) => modifier >= 0 ? '+$modifier' : '$modifier';
