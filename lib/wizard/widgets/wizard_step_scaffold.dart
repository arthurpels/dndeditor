import 'package:flutter/material.dart';

/// Общая обёртка для контента шага мастера: заголовок + прокручиваемое тело.
class WizardStepScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const WizardStepScaffold({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
