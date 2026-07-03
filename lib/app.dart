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
  late Future<CharacterRepository> _repositoryFuture;

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
        Widget home;

        if (snapshot.connectionState != ConnectionState.done) {
          home = const _LoadingScreen();
        } else if (snapshot.hasError || snapshot.data == null) {
          home = _StartupErrorScreen(
            error: snapshot.error,
            onRetry: _reloadRepository,
          );
        } else {
          home = CharacterRepositoryScope(
            repository: snapshot.data!,
            child: const HomeScreen(),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DND Editor',
          theme: AppTheme.light(),
          home: home,
        );
      },
    );
  }

  void _reloadRepository() {
    setState(() {
      _repositoryFuture = CharacterRepository.bootstrap();
    });
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

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen({
    required this.error,
    required this.onRetry,
  });

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 56, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Не удалось запустить приложение',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'Неизвестная ошибка запуска',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
