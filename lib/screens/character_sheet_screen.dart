import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/character.dart';
import '../repository/character_repository.dart';

class CharacterSheetScreen extends StatelessWidget {
  const CharacterSheetScreen({
    super.key,
    required this.characterId,
  });

  final String characterId;

  @override
  Widget build(BuildContext context) {
    final repository = CharacterRepositoryScope.of(context);
    final character = repository.ownedById(characterId);

    return Scaffold(
      appBar: AppBar(
        title: Text(character?.name ?? 'Персонаж'),
      ),
      body: character == null
          ? const Center(
              child: Text('Персонаж не найден'),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _HeaderCard(character: character),
                const SizedBox(height: 16),
                _ActionRow(
                  onDuplicate: () {
                    repository.duplicateOwned(character.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Создана копия персонажа')),
                    );
                  },
                  onDelete: () {
                    repository.removeOwned(character.id);
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 16),
                _DetailCard(
                  title: 'Основное',
                  rows: [
                    ('Имя', character.name),
                    ('Раса', character.race),
                    ('Класс', character.characterClass),
                    ('Уровень', character.level.toString()),
                    ('HP', '${character.hitPoints}/${character.maxHitPoints}'),
                  ],
                ),
                const SizedBox(height: 16),
                _DetailCard(
                  title: 'Примечания',
                  rows: [
                    ('Заметки', character.notes.isEmpty ? 'Нет' : character.notes),
                  ],
                ),
                const SizedBox(height: 16),
                _DetailCard(
                  title: 'JSON персонажа',
                  rows: [
                    ('Экспорт', JsonEncoder.withIndent('  ').convert(character.toJson())),
                  ],
                ),
              ],
            ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              character.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text('${character.race} / ${character.characterClass}'),
            const SizedBox(height: 8),
            Text('Уровень ${character.level} • HP ${character.hitPoints}/${character.maxHitPoints}'),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.onDuplicate,
    required this.onDelete,
  });

  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.tonalIcon(
          onPressed: onDuplicate,
          icon: const Icon(Icons.copy_outlined),
          label: const Text('Дублировать'),
        ),
        OutlinedButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Удалить'),
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.title,
    required this.rows,
  });

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.$1,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    SelectableText(row.$2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
