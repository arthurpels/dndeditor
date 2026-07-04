import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/character_creation_controller.dart';
import 'abilities_step.dart';
import 'basics_step.dart';
import 'review_step.dart';
import 'skills_step.dart';

/// Host of the character creation wizard: keeps [CharacterCreationController] and
/// switches the steps (PRD screens 2-5) with a Navigator-like flow without go_router.
class WizardFlowScreen extends StatefulWidget {
  const WizardFlowScreen({super.key});

  @override
  State<WizardFlowScreen> createState() => _WizardFlowScreenState();
}

class _WizardFlowScreenState extends State<WizardFlowScreen> {
  bool _onboardingShown = false;

  static const _stepTitles = ['Основа', 'Характеристики', 'Навыки', 'Обзор'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_onboardingShown) return;
    _onboardingShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Как пройти мастер'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: [
                  Text('• Basics — имя, раса, класс и предыстория.'),
                  SizedBox(height: 8),
                  Text('• Abilities — выбери способ генерации и распредели значения.'),
                  SizedBox(height: 8),
                  Text('• Skills — background уже даёт часть навыков, остальное добирается классом.'),
                  SizedBox(height: 8),
                  Text('• Review — проверь итог и сохрани персонажа.'),
                ],
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Понятно'),
              ),
            ],
          );
        },
      );
    });
  }

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
