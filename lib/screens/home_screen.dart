import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../models/character.dart';
import '../repository/character_repository.dart';
import 'character_sheet_screen.dart';
import '../wizard/screens/wizard_flow_screen.dart';

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
                tooltip: 'Импорт из файла',
                onPressed: () => _importFromFile(context, repository),
                icon: const Icon(Icons.file_open_outlined),
              ),
              IconButton(
                tooltip: 'Импорт из буфера',
                onPressed: () => _importFromClipboard(context, repository),
                icon: const Icon(Icons.paste_outlined),
              ),
              IconButton(
                tooltip: 'Копировать JSON',
                onPressed: () => _copyToClipboard(context, repository),
                icon: const Icon(Icons.copy_outlined),
              ),
              IconButton(
                tooltip: 'Экспорт в файл',
                onPressed: () => _exportToFile(context, repository),
                icon: const Icon(Icons.save_alt_outlined),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openWizard(context),
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
                onAction: () => _openWizard(context),
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
                    child: Dismissible(
                      key: ValueKey(character.id),
                      direction: DismissDirection.horizontal,
                      background: _SwipeActionBackground(
                        icon: Icons.copy_outlined,
                        label: 'Дублировать',
                        alignment: Alignment.centerLeft,
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                      ),
                      secondaryBackground: _SwipeActionBackground(
                        icon: Icons.delete_outline,
                        label: 'Удалить',
                        alignment: Alignment.centerRight,
                        color: Theme.of(context).colorScheme.errorContainer,
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          repository.duplicateOwned(character.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${character.name} продублирован'),
                              ),
                            );
                          }
                          return false;
                        }

                        return _confirmDelete(context, character.name);
                      },
                      onDismissed: (_) {
                        repository.removeOwned(character.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${character.name} удалён'),
                          ),
                        );
                      },
                      child: _CharacterCard(
                        character: character,
                        onOpen: () => _openCharacter(context, character),
                        onDuplicate: () => repository.duplicateOwned(character.id),
                        onDelete: () => repository.removeOwned(character.id),
                      ),
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
                    onOpen: () => _addAndOpenCharacter(context, repository, character),
                    onDuplicate: null,
                    onDelete: null,
                    openLabel: 'Добавить и открыть',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openWizard(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const WizardFlowScreen(),
      ),
    );
  }

  Future<void> _openCharacter(BuildContext context, Character character) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CharacterSheetScreen(characterId: character.id),
      ),
    );
  }

  Future<void> _addAndOpenCharacter(
    BuildContext context,
    CharacterRepository repository,
    Character character,
  ) async {
    final added = repository.addToOwned(character);
    await _openCharacter(context, added);
  }

  Future<void> _copyToClipboard(
    BuildContext context,
    CharacterRepository repository,
  ) async {
    try {
      await Clipboard.setData(ClipboardData(text: repository.exportOwnedJson()));
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('JSON скопирован в буфер обмена')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось скопировать JSON: $error')),
      );
    }
  }

  Future<void> _importFromClipboard(
    BuildContext context,
    CharacterRepository repository,
  ) async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';

      if (text.isEmpty) {
        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('В буфере обмена нет JSON')),
        );
        return;
      }

      await repository.importOwnedJson(text);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('JSON импортирован из буфера')),
      );
    } on FormatException catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось импортировать JSON: ${error.message}')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось импортировать JSON из буфера: $error')),
      );
    }
  }
  Future<void> _exportToFile(
    BuildContext context,
    CharacterRepository repository,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final file = File('${directory.path}/dndeditor-export-$timestamp.json');
      await file.writeAsString(repository.exportOwnedJson());

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('JSON сохранён: ${file.path}')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось сохранить JSON: $error')),
      );
    }
  }

  Future<void> _importFromFile(
    BuildContext context,
    CharacterRepository repository,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;
    String importedJson;
    if (file.bytes != null) {
      importedJson = String.fromCharCodes(file.bytes!);
    } else if (file.path != null && file.path!.isNotEmpty) {
      importedJson = await File(file.path!).readAsString();
    } else {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось прочитать выбранный файл')),
      );
      return;
    }

    try {
      await repository.importOwnedJson(importedJson);
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('JSON импортирован')),
      );
    } on FormatException catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось импортировать JSON: ${error.message}')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось импортировать файл: $error')),
      );
    }
  }

  Future<bool> _confirmDelete(BuildContext context, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Удалить персонажа?'),
          content: Text('Персонаж "$name" будет удалён из библиотеки.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
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
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onOpen,
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

class _SwipeActionBackground extends StatelessWidget {
  const _SwipeActionBackground({
    required this.icon,
    required this.label,
    required this.alignment,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Alignment alignment;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
