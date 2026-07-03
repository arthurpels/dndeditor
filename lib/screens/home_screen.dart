import 'package:flutter/material.dart';

import '../models/character.dart';
import '../repository/character_repository.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = CharacterRepositoryScope.of(context);

    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('DND Editor'),
            actions: [
              IconButton(
                tooltip: 'Импорт',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Импорт подключим следующим коммитом'),
                    ),
                  );
                },
                icon: const Icon(Icons.file_upload_outlined),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: repository.createDraftCharacter,
            icon: const Icon(Icons.add),
            label: const Text('Создать'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _HeroCard(
                ownedCount: repository.ownedCharacters.length,
                readyCount: repository.readyMadeCharacters.length,
              ),
              const SizedBox(height: 24),
              _SectionHeader(
                title: 'Мои персонажи',
                actionLabel: 'Добавить',
                onAction: repository.createDraftCharacter,
              ),
              const SizedBox(height: 12),
              if (repository.ownedCharacters.isEmpty)
                const _EmptyState(
                  title: 'Пока здесь пусто',
                  subtitle: 'Создай первого персонажа или импортируй JSON-файл.',
                )
              else
                ...repository.ownedCharacters.map(
                  (character) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CharacterCard(
                      character: character,
                      onOpen: () {},
                      onDuplicate: () => repository.duplicateOwned(character.id),
                      onDelete: () => repository.removeOwned(character.id),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              const _SectionHeader(
                title: 'Готовые персонажи',
                actionLabel: '',
              ),
              const SizedBox(height: 12),
              ...repository.readyMadeCharacters.map(
                (character) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CharacterCard(
                    character: character,
                    onOpen: () => repository.addToOwned(character),
                    onDuplicate: null,
                    onDelete: null,
                    openLabel: 'Добавить в мои',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.ownedCount,
    required this.readyCount,
  });

  final int ownedCount;
  final int readyCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Библиотека персонажей', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Мои: $ownedCount, готовые: $readyCount',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (onAction != null && actionLabel.isNotEmpty)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel),
          ),
      ],
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({
    required this.character,
    required this.onOpen,
    this.onDuplicate,
    this.onDelete,
    this.openLabel = 'Открыть',
  });

  final Character character;
  final VoidCallback onOpen;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
  final String openLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    character.name,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Text('${character.level} lvl'),
              ],
            ),
            const SizedBox(height: 8),
            Text('${character.race} / ${character.characterClass}'),
            const SizedBox(height: 6),
            Text('HP ${character.hitPoints}/${character.maxHitPoints}'),
            if (character.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                character.notes,
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: onOpen,
                  child: Text(openLabel),
                ),
                if (onDuplicate != null)
                  OutlinedButton(
                    onPressed: onDuplicate,
                    child: const Text('Дублировать'),
                  ),
                if (onDelete != null)
                  OutlinedButton(
                    onPressed: onDelete,
                    child: const Text('Удалить'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}
