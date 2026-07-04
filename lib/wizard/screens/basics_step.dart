import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../mock_contract/ability.dart';
import '../mock_contract/background.dart';
import '../mock_contract/class_data.dart';
import '../mock_contract/race.dart';
import '../state/character_creation_controller.dart';
import '../widgets/wizard_step_scaffold.dart';

/// Экран 2 PRD — «Мастер: Основа»: имя, раса, класс, предыстория.
class BasicsStep extends StatelessWidget {
  const BasicsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CharacterCreationController>();

    return WizardStepScaffold(
      title: 'Основа персонажа',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            initialValue: controller.name,
            decoration: const InputDecoration(labelText: 'Имя персонажа'),
            onChanged: controller.setName,
          ),
          const SizedBox(height: 24),
          _SelectableSection<RaceOption>(
            title: 'Раса',
            options: controller.allRaces,
            selectedId: controller.raceId,
            idOf: (r) => r.id,
            labelOf: (r) => r.nameRu,
            descriptionOf: (r) => r.description,
            isHomebrew: (r) => r.id.startsWith('hb_'),
            onSelected: controller.selectRace,
          ),
          const SizedBox(height: 24),
          _SelectableSection<ClassOption>(
            title: 'Класс',
            options: controller.allClasses,
            selectedId: controller.classId,
            idOf: (c) => c.id,
            labelOf: (c) => c.nameRu,
            descriptionOf: (c) =>
                'Кость хитов d${c.hitDie}, спасброски ${c.savingThrows.map((a) => a.shortCode).join('/')}, '
                'навыков на выбор: ${c.skillChoiceCount}.',
            isHomebrew: (c) => c.id.startsWith('hb_'),
            onSelected: controller.selectClass,
          ),
          const SizedBox(height: 24),
          _SelectableSection<BackgroundOption>(
            title: 'Предыстория',
            options: mockBackgrounds,
            selectedId: controller.backgroundId,
            idOf: (b) => b.id,
            labelOf: (b) => b.nameRu,
            descriptionOf: (b) => 'Даёт владение: ${b.skillIds.join(', ')}.',
            isHomebrew: (_) => false,
            onSelected: controller.selectBackground,
          ),
        ],
      ),
    );
  }
}

class _SelectableSection<T> extends StatelessWidget {
  final String title;
  final List<T> options;
  final String? selectedId;
  final String Function(T) idOf;
  final String Function(T) labelOf;
  final String Function(T) descriptionOf;
  final bool Function(T) isHomebrew;
  final ValueChanged<String> onSelected;

  const _SelectableSection({
    required this.title,
    required this.options,
    required this.selectedId,
    required this.idOf,
    required this.labelOf,
    required this.descriptionOf,
    required this.isHomebrew,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    T? selected;
    for (final option in options) {
      if (idOf(option) == selectedId) {
        selected = option;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              ChoiceChip(
                label: isHomebrew(option)
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(labelOf(option)),
                          const SizedBox(width: 4),
                          const Icon(Icons.extension, size: 12),
                        ],
                      )
                    : Text(labelOf(option)),
                selected: idOf(option) == selectedId,
                onSelected: (_) => onSelected(idOf(option)),
              ),
          ],
        ),
        if (selected != null) ...[
          const SizedBox(height: 8),
          Text(descriptionOf(selected), style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }
}
