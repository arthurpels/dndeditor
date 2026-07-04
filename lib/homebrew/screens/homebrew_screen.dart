import 'package:flutter/material.dart';

import '../models/homebrew_class.dart';
import '../models/homebrew_race.dart';
import '../repository/homebrew_repository.dart';
import 'homebrew_class_form.dart';
import 'homebrew_race_form.dart';

class HomebrewScreen extends StatelessWidget {
  const HomebrewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Хоумбрю'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Расы'),
              Tab(text: 'Классы'),
            ],
          ),
        ),
        floatingActionButton: _AddFab(),
        body: const TabBarView(
          children: [
            _RaceList(),
            _ClassList(),
          ],
        ),
      ),
    );
  }
}

class _AddFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DefaultTabController.of(context),
      builder: (context, child) {
        final isRaceTab = DefaultTabController.of(context).index == 0;
        return FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => isRaceTab
                  ? const HomebrewRaceForm()
                  : const HomebrewClassForm(),
            ),
          ),
          icon: const Icon(Icons.add),
          label: Text(isRaceTab ? 'Раса' : 'Класс'),
        );
      },
    );
  }
}

class _RaceList extends StatelessWidget {
  const _RaceList();

  @override
  Widget build(BuildContext context) {
    final repo = HomebrewRepositoryScope.of(context);

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        if (repo.races.isEmpty) {
          return const _Empty(
            message: 'Нет хоумбрю рас.\nНажми + чтобы создать.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: repo.races.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) => _RaceCard(race: repo.races[i]),
        );
      },
    );
  }
}

class _ClassList extends StatelessWidget {
  const _ClassList();

  @override
  Widget build(BuildContext context) {
    final repo = HomebrewRepositoryScope.of(context);

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        if (repo.classes.isEmpty) {
          return const _Empty(
            message: 'Нет хоумбрю классов.\nНажми + чтобы создать.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: repo.classes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) => _ClassCard(cls: repo.classes[i]),
        );
      },
    );
  }
}

class _RaceCard extends StatelessWidget {
  const _RaceCard({required this.race});

  final HomebrewRace race;

  @override
  Widget build(BuildContext context) {
    final bonusText = race.abilityBonuses.isEmpty
        ? 'нет бонусов'
        : race.abilityBonuses.entries
            .map((e) => '${e.key.substring(0, 3).toUpperCase()} ${e.value > 0 ? '+' : ''}${e.value}')
            .join(', ');

    return Card(
      child: ListTile(
        title: Row(
          children: [
            Text(race.name),
            const SizedBox(width: 8),
            _HomebrewBadge(),
          ],
        ),
        subtitle: Text('${race.speed} фт. · $bonusText'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => HomebrewRaceForm(initial: race),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, race.name, () {
                HomebrewRepositoryScope.of(context).removeRace(race.id);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.cls});

  final HomebrewClass cls;

  @override
  Widget build(BuildContext context) {
    final saves = cls.savingThrows
        .map((s) => s.substring(0, 3).toUpperCase())
        .join('/');

    return Card(
      child: ListTile(
        title: Row(
          children: [
            Text(cls.name),
            const SizedBox(width: 8),
            _HomebrewBadge(),
          ],
        ),
        subtitle: Text(
            'd${cls.hitDie} · спасброски $saves · навыков: ${cls.skillChoiceCount}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => HomebrewClassForm(initial: cls),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, cls.name, () {
                HomebrewRepositoryScope.of(context).removeClass(cls.id);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomebrewBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Homebrew',
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  String name,
  VoidCallback onConfirm,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Удалить?'),
      content: Text('«$name» будет удалён из хоумбрю.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Удалить'),
        ),
      ],
    ),
  );
  if (confirmed == true) onConfirm();
}
