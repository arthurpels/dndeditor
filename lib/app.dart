import 'package:flutter/material.dart';

import 'repository/character_repository.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

class DndEditorApp extends StatefulWidget {
  const DndEditorApp({super.key});

  @override
  State<DndEditorApp> createState() => _DndEditorAppState();
}

class _DndEditorAppState extends State<DndEditorApp> {
  late final CharacterRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = CharacterRepository.seeded();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrapRepository();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CharacterRepositoryScope(
      repository: _repository,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DND Editor',
        theme: AppTheme.light(),
        home: const HomeScreen(),
      ),
    );
  }

  Future<void> _bootstrapRepository() async {
    await _repository.loadPersistedState();
    if (!mounted) {
      return;
    }

    setState(() {});
  }
}
