import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../homebrew/models/homebrew_class.dart';
import '../../homebrew/models/homebrew_race.dart';
import '../../homebrew/repository/homebrew_repository.dart';
import '../mock_contract/ability.dart';
import '../mock_contract/class_data.dart';
import '../mock_contract/race.dart';
import '../state/character_creation_controller.dart';
import 'abilities_step.dart';
import 'basics_step.dart';
import 'review_step.dart';
import 'skills_step.dart';

/// Хост мастера создания персонажа: держит [CharacterCreationController] и
/// переключает шаги (экраны 2–5 PRD) по `Navigator`-подобной модели без
/// go_router — как и решено в разделе 4/8 PRD ради скорости.
class WizardFlowScreen extends StatelessWidget {
  const WizardFlowScreen({super.key});

  static const _stepTitles = ['Основа', 'Характеристики', 'Навыки', 'Обзор'];

  @override
  Widget build(BuildContext context) {
    final homebrew = HomebrewRepositoryScope.of(context);

    return ChangeNotifierProvider(
      create: (_) => CharacterCreationController(
        extraRaces: homebrew.races.map(_toRaceOption).toList(),
        extraClasses: homebrew.classes.map(_toClassOption).toList(),
      ),
      child: Consumer<CharacterCreationController>(
        builder: (context, controller, _) {
          final stepIndex = WizardStep.values.indexOf(controller.currentStep);

          return Scaffold(
            appBar: AppBar(title: Text('Создание персонажа — ${_stepTitles[stepIndex]}')),
            body: switch (controller.currentStep) {
              WizardStep.basics => const BasicsStep(),
              WizardStep.abilities => const AbilitiesStep(),
              WizardStep.skills => const SkillsStep(),
              WizardStep.review => const ReviewStep(),
            },
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: LinearProgressIndicator(
                  value: (stepIndex + 1) / _stepTitles.length,
                ),
              ),
            ),
            persistentFooterButtons: controller.currentStep == WizardStep.review
                ? null
                : [
                    if (stepIndex > 0)
                      OutlinedButton(onPressed: controller.previousStep, child: const Text('Назад')),
                    FilledButton(
                      onPressed: controller.canProceedFromCurrentStep ? controller.nextStep : null,
                      child: const Text('Далее'),
                    ),
                  ],
          );
        },
      ),
    );
  }
}

RaceOption _toRaceOption(HomebrewRace r) {
  final bonuses = <AbilityScore, int>{};
  for (final entry in r.abilityBonuses.entries) {
    for (final a in AbilityScore.values) {
      if (a.name == entry.key) {
        bonuses[a] = entry.value;
        break;
      }
    }
  }
  return RaceOption(
    id: r.id,
    nameRu: '${r.name} ✦',
    abilityBonuses: bonuses,
    speed: r.speed,
    description: r.description,
  );
}

ClassOption _toClassOption(HomebrewClass c) {
  final saves = <AbilityScore>[];
  for (final s in c.savingThrows) {
    for (final a in AbilityScore.values) {
      if (a.name == s) {
        saves.add(a);
        break;
      }
    }
  }
  return ClassOption(
    id: c.id,
    nameRu: '${c.name} ✦',
    hitDie: c.hitDie,
    savingThrows: saves,
    skillChoiceCount: c.skillChoiceCount,
    availableSkillIds: c.availableSkillIds,
  );
}
