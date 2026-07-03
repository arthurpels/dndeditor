import 'package:flutter/material.dart';

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
          const CharacterTile(
            name: 'Торин',
            details: 'Dwarf • Fighter • level 1 • HP 12/12',
          ),
          const CharacterTile(
            name: 'Элара',
            details: 'Elf • Wizard • level 1 • HP 8/8',
          ),
          const SizedBox(height: 24),
          const Text(
            'Готовые персонажи',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const CharacterTile(
            name: 'Лирис',
            details: 'Prebuilt sample character',
          ),
          const CharacterTile(
            name: 'Бран',
            details: 'Prebuilt sample character',
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
                  builder: (_) => const WizardScreen(),
                ),
              );
            },
            child: const Text('Создать персонажа'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CharacterCardScreen(),
                ),
              );
            },
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

  final String name;
  final String details;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text(details),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CharacterCardScreen(),
            ),
          );
        },
      ),
    );
  }
}

class WizardScreen extends StatelessWidget {
  const WizardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мастер создания'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SectionBlock(title: 'Шаг 1', description: 'Имя персонажа'),
          SectionBlock(title: 'Шаг 2', description: 'Раса, класс, предыстория'),
          SectionBlock(title: 'Шаг 3', description: 'Характеристики и навыки'),
          SectionBlock(title: 'Шаг 4', description: 'Обзор и сохранение'),
        ],
      ),
    );
  }
}

class CharacterCardScreen extends StatelessWidget {
  const CharacterCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка персонажа'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SectionBlock(title: 'Основные данные', description: 'Имя, раса, класс, уровень'),
          SectionBlock(title: 'Характеристики', description: 'STR, DEX, CON, INT, WIS, CHA'),
          SectionBlock(title: 'Навыки', description: 'Список навыков и владения'),
          SectionBlock(title: 'Состояние', description: 'HP, AC, инициатива, заметки'),
        ],
      ),
    );
  }
}

class SectionBlock extends StatelessWidget {
  const SectionBlock({super.key, required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }
}
