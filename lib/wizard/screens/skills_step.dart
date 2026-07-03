import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../mock_contract/ability.dart';
import '../mock_contract/skill.dart';
import '../state/character_creation_controller.dart';
import '../widgets/wizard_step_scaffold.dart';

/// Экран 4 PRD — «Мастер: Навыки»: выбор N навыков класса, навыки
/// предыстории отмечены автоматически, счётчик «выбрано X из N».
class SkillsStep extends StatelessWidget {
  const SkillsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CharacterCreationController>();

    if (controller.selectedClass == null || controller.selectedBackground == null) {
      return const WizardStepScaffold(
        title: 'Навыки',
        child: Text('Сначала выберите класс и предысторию на предыдущем шаге.'),
      );
    }

    final visibleSkillIds = <String>{
      ...controller.availableClassSkillIds,
      ...controller.backgroundSkillIds,
    };
    final orderedSkills = mockSkills.where((s) => visibleSkillIds.contains(s.id)).toList();

    return WizardStepScaffold(
      title: 'Навыки',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Выбрано ${controller.selectedClassSkills.length} из ${controller.classSkillChoiceCount} '
            '(навыки предыстории отмечены отдельно и не расходуют лимит)',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          for (final skill in orderedSkills)
            CheckboxListTile(
              value: controller.isSkillSelected(skill.id),
              onChanged: controller.isSkillFromBackground(skill.id) ? null : (_) => controller.toggleSkill(skill.id),
              title: Text('${skill.nameRu} (${skill.ability.shortCode})'),
              subtitle: controller.isSkillFromBackground(skill.id) ? const Text('От предыстории') : null,
              controlAffinity: ListTileControlAffinity.leading,
            ),
        ],
      ),
    );
  }
}
