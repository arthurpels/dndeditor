import 'package:flutter/material.dart';

import 'homebrew/repository/homebrew_repository.dart';
import 'repository/character_repository.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

class DndEditorApp extends StatefulWidget {
  const DndEditorApp({super.key});

  @override
  State<DndEditorApp> createState() => _DndEditorAppState();
}

class _DndEditorAppState extends State<DndEditorApp> {
  late final CharacterRepository _characters;
  late final HomebrewRepository _homebrew;

  @override
  void initState() {
    super.initState();
    _characters = CharacterRepository.seeded();
    _homebrew = HomebrewRepository.seeded();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  Widget build(BuildContext context) {
    return HomebrewRepositoryScope(
      repository: _homebrew,
      child: CharacterRepositoryScope(
        repository: _characters,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DND Editor',
          theme: AppTheme.light(),
          home: const HomeScreen(),
        ),
      ),
    );
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      _characters.loadPersistedState(),
      _homebrew.loadPersistedState(),
    ]);
    if (mounted) setState(() {});
  }
}
