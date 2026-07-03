import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    return ChangeNotifierProvider(
      create: (_) => CharacterCreationController(),
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
