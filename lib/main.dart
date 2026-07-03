import 'package:flutter/material.dart';

import 'models/character.dart';
import 'wizard/screens/wizard_flow_screen.dart';

void main() {
  runApp(const DndEditorApp());
}

class DndEditorApp extends StatelessWidget {
  const DndEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Редактор персонажей D&D',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const LibraryScreen(),
    );
  }
}

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактор персонажей D&D'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Мои персонажи',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          CharacterTile.fromCharacter(Character.sample()),
          CharacterTile.fromCharacter(
            Character.sample().copyWith(
              id: 'sample-elara',
              name: 'Элара',
              raceId: 'elf',
              classId: 'wizard',
              backgroundId: 'sage',
              biography: 'Исследовательница древних текстов и магических традиций.',
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Готовые персонажи',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          CharacterTile.fromSummary(
            name: 'Лирис',
            details: 'Готовый пример для библиотеки и импорта',
          ),
          CharacterTile.fromSummary(
            name: 'Бран',
            details: 'Готовый пример для библиотеки и импорта',
          ),
          const SizedBox(height: 24),
          const Text(
            'Стартовые действия',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WizardFlowScreen(),
                ),
              );
            },
            child: const Text('Создать персонажа'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Открыть карточку персонажа'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Импорт JSON'),
          ),
        ],
      ),
    );
  }
}

class CharacterTile extends StatelessWidget {
  const CharacterTile({super.key, required this.name, required this.details});

  CharacterTile.fromSummary({super.key, required String name, required String details})
      : name = name,
        details = details;

  CharacterTile.fromCharacter(Character character, {super.key})
      : name = character.name,
        details =
            '${character.raceId} • ${character.classId} • level ${character.level} • HP ${character.currentHp}/${character.maxHp}';

  final String name;
  final String details;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text(details),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
