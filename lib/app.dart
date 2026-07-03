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
  late final Future<CharacterRepository> _repositoryFuture;

  @override
  void initState() {
    super.initState();
    _repositoryFuture = CharacterRepository.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CharacterRepository>(
      future: _repositoryFuture,
      builder: (context, snapshot) {
        final repository = snapshot.data;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DND Editor',
          theme: AppTheme.light(),
          home: repository == null
              ? const _LoadingScreen()
              : CharacterRepositoryScope(
                  repository: repository,
                  child: const HomeScreen(),
                ),
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
