import 'package:flutter/material.dart';

import 'wizard/screens/wizard_flow_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D&D Character Editor',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      // TODO(Dev D): заменить на Home/библиотеку, когда появится репозиторий
      // и главный экран. Пока мастер (зона B) запускается напрямую для демо.
      home: const WizardFlowScreen(),
    );
  }
}
