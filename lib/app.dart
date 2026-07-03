import 'package:flutter/material.dart';

import 'repository/character_repository.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

class DndEditorApp extends StatelessWidget {
  const DndEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CharacterRepositoryScope(
      repository: CharacterRepository.seeded(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DND Editor',
        theme: AppTheme.light(),
        home: const HomeScreen(),
      ),
    );
  }
}
