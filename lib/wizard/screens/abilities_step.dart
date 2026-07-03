import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../mock_contract/ability.dart';
import '../mock_contract/rules_engine.dart';
import '../state/character_creation_controller.dart';
import '../widgets/wizard_step_scaffold.dart';

/// Экран 3 PRD — «Мастер: Характеристики»: метод генерации + распределение
/// 6 значений, итог с расовым бонусом и модификатором в реальном времени.
class AbilitiesStep extends StatelessWidget {
  const AbilitiesStep({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CharacterCreationController>();

    return WizardStepScaffold(
      title: 'Характеристики',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<AbilityMethod>(
            segments: const [
              ButtonSegment(value: AbilityMethod.standardArray, label: Text('Стандартный массив')),
              ButtonSegment(value: AbilityMethod.pointBuy, label: Text('Point Buy')),
              ButtonSegment(value: AbilityMethod.rolled4d6, label: Text('4d6')),
            ],
            selected: {controller.abilityMethod},
            onSelectionChanged: (s) => controller.setAbilityMethod(s.first),
          ),
          const SizedBox(height: 20),
          if (controller.abilityMethod == AbilityMethod.pointBuy)
            _PointBuyEditor(controller: controller)
          else
            _PoolEditor(controller: controller),
        ],
      ),
    );
  }
}

class _PoolEditor extends StatelessWidget {
  final CharacterCreationController controller;
  const _PoolEditor({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isRolled = controller.abilityMethod == AbilityMethod.rolled4d6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isRolled)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                FilledButton.icon(
                  onPressed: controller.rollAbilityPoolValues,
                  icon: const Icon(Icons.casino),
                  label: Text(controller.currentPool.isEmpty ? 'Бросить кубики' : 'Перебросить'),
                ),
                if (controller.currentPool.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Text('Пул: ${controller.currentPool.join(', ')}'),
                ],
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('Пул: ${standardArrayValues.join(', ')}'),
          ),
        for (final ability in AbilityScore.values) _AbilityPoolRow(controller: controller, ability: ability),
      ],
    );
  }
}

class _AbilityPoolRow extends StatelessWidget {
  final CharacterCreationController controller;
  final AbilityScore ability;
  const _AbilityPoolRow({required this.controller, required this.ability});

  @override
  Widget build(BuildContext context) {
    final options = controller.availableValuesFor(ability);
    final value = controller.poolValueFor(ability);
    final base = value ?? 8;
    final raceBonus = controller.selectedRace?.bonusFor(ability) ?? 0;
    final total = base + raceBonus;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 56, child: Text(ability.shortCode, style: const TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(
            width: 100,
            child: DropdownButton<int?>(
              value: value,
              hint: const Text('—'),
              isExpanded: true,
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('—')),
                for (final v in options) DropdownMenuItem<int?>(value: v, child: Text('$v')),
              ],
              onChanged: (v) => controller.assignPoolValue(ability, v),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              raceBonus == 0 ? 'Итог: $total' : 'Итог: $base + $raceBonus (раса) = $total',
            ),
          ),
          Text('Мод. ${_formatModifier(abilityModifier(total))}'),
        ],
      ),
    );
  }
}

class _PointBuyEditor extends StatelessWidget {
  final CharacterCreationController controller;
  const _PointBuyEditor({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Осталось очков: ${controller.pointBuyRemaining} из $pointBuyBudget'),
        const SizedBox(height: 8),
        for (final ability in AbilityScore.values) _PointBuyRow(controller: controller, ability: ability),
      ],
    );
  }
}

class _PointBuyRow extends StatelessWidget {
  final CharacterCreationController controller;
  final AbilityScore ability;
  const _PointBuyRow({required this.controller, required this.ability});

  @override
  Widget build(BuildContext context) {
    final score = controller.pointBuyScoreFor(ability);
    final raceBonus = controller.selectedRace?.bonusFor(ability) ?? 0;
    final total = score + raceBonus;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 56, child: Text(ability.shortCode, style: const TextStyle(fontWeight: FontWeight.bold))),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () => controller.setPointBuyScore(ability, score - 1),
          ),
          SizedBox(width: 24, child: Text('$score', textAlign: TextAlign.center)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => controller.setPointBuyScore(ability, score + 1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              raceBonus == 0 ? 'Итог: $total' : 'Итог: $score + $raceBonus (раса) = $total',
            ),
          ),
          Text('Мод. ${_formatModifier(abilityModifier(total))}'),
        ],
      ),
    );
  }
}

String _formatModifier(int modifier) => modifier >= 0 ? '+$modifier' : '$modifier';
