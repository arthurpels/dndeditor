import 'package:flutter/material.dart';

import 'app_bootstrap.dart';
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
  late final AppBootstrap _boot;

  @override
  void initState() {
    super.initState();
    _boot = AppBootstrap.seeded();
    // Render Home immediately with seeded content, then hydrate in background.
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  @override
  Widget build(BuildContext context) {
    return HomebrewRepositoryScope(
      repository: _boot.homebrew,
      child: CharacterRepositoryScope(
        repository: _boot.characters,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DND Editor',
          theme: AppTheme.light(),
          home: const HomeScreen(),
        ),
      ),
    );
  }

  Future<void> _hydrate() async {
    await _boot.hydrate();
    if (mounted) setState(() {});
  }
}
