import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../mock_contract/ability.dart';
import '../mock_contract/rules_engine.dart';
import '../mock_contract/skill.dart';
import '../state/character_creation_controller.dart';
import '../widgets/wizard_step_scaffold.dart';

/// Экран 5 PRD — «Мастер: Обзор»: полный предпросмотр карточки + «Сохранить».
///
/// Репозитория (Dev D) в проекте ещё нет, поэтому «Сохранить» здесь только
/// демонстрирует итоговый JSON черновика — реальная запись в хранилище
/// подключается позже теми, кто владеет `repository/`.
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
            'Спасброски: ${controller.savingThrowProficiencies.map((a) => '${a.shortCode} '
                '${_fmt(valueWithProficiency(abilityScore: finalAbilities[a]!, proficient: true, proficiencyBonus: profBonus))}').join(', ')}',
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
            onPressed: () => _showSaveDialog(context, controller),
            icon: const Icon(Icons.save),
            label: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showSaveDialog(BuildContext context, CharacterCreationController controller) {
    final draft = controller.buildDraft();
    final json = const JsonEncoder.withIndent('  ').convert(draft.toPreviewJson());
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Черновик готов'),
        content: SingleChildScrollView(
          child: Text(
            'Репозиторий (Dev D) ещё не подключён, поэтому вот итоговый JSON, '
            'который должен уйти в CharacterRepository.save():\n\n$json',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Ок')),
        ],
      ),
    );
  }
}

String _fmt(int modifier) => modifier >= 0 ? '+$modifier' : '$modifier';
