import 'package:flutter/material.dart';

import '../models/homebrew_class.dart';
import '../repository/homebrew_repository.dart';

class HomebrewClassForm extends StatefulWidget {
  const HomebrewClassForm({super.key, this.initial});

  final HomebrewClass? initial;

  @override
  State<HomebrewClassForm> createState() => _HomebrewClassFormState();
}

class _HomebrewClassFormState extends State<HomebrewClassForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late int _hitDie;
  late int _skillChoiceCount;
  late final Set<String> _savingThrows;
  late final Set<String> _availableSkills;

  static const _hitDieOptions = [6, 8, 10, 12];

  static const _abilities = [
    ('strength', 'Сила'),
    ('dexterity', 'Ловкость'),
    ('constitution', 'Телосложение'),
    ('intelligence', 'Интеллект'),
    ('wisdom', 'Мудрость'),
    ('charisma', 'Харизма'),
  ];

  static const _allSkills = [
    ('acrobatics', 'Акробатика'),
    ('animal_handling', 'Уход за животными'),
    ('arcana', 'Магия'),
    ('athletics', 'Атлетика'),
    ('deception', 'Обман'),
    ('history', 'История'),
    ('insight', 'Проницательность'),
    ('intimidation', 'Запугивание'),
    ('investigation', 'Расследование'),
    ('medicine', 'Медицина'),
    ('nature', 'Природа'),
    ('perception', 'Восприятие'),
    ('performance', 'Выступление'),
    ('persuasion', 'Убеждение'),
    ('religion', 'Религия'),
    ('sleight_of_hand', 'Ловкость рук'),
    ('stealth', 'Скрытность'),
    ('survival', 'Выживание'),
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.initial;
    _name = TextEditingController(text: c?.name ?? '');
    _description = TextEditingController(text: c?.description ?? '');
    _hitDie = c?.hitDie ?? 8;
    _skillChoiceCount = c?.skillChoiceCount ?? 2;
    _savingThrows = Set<String>.from(c?.savingThrows ?? const []);
    _availableSkills = Set<String>.from(c?.availableSkillIds ?? const []);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Редактировать класс' : 'Новый класс'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Название *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Введите название' : null,
            ),
            const SizedBox(height: 20),
            Text('Кость хитов',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final d in _hitDieOptions)
                  ChoiceChip(
                    label: Text('d$d'),
                    selected: _hitDie == d,
                    onSelected: (_) => setState(() => _hitDie = d),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Спасброски (выбери 2)',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final (key, label) in _abilities)
                  FilterChip(
                    label: Text(label),
                    selected: _savingThrows.contains(key),
                    onSelected: (on) => setState(() {
                      if (on) {
                        if (_savingThrows.length < 2) _savingThrows.add(key);
                      } else {
                        _savingThrows.remove(key);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text('Навыков на выбор: $_skillChoiceCount',
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _skillChoiceCount > 1
                      ? () => setState(() => _skillChoiceCount--)
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _skillChoiceCount < 6
                      ? () => setState(() => _skillChoiceCount++)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Доступные навыки',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final (key, label) in _allSkills)
                  FilterChip(
                    label: Text(label),
                    selected: _availableSkills.contains(key),
                    onSelected: (on) => setState(() {
                      if (on) {
                        _availableSkills.add(key);
                      } else {
                        _availableSkills.remove(key);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'Описание'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Text(isEdit ? 'Сохранить' : 'Создать'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_savingThrows.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выбери ровно 2 спасброска')),
      );
      return;
    }
    if (_availableSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добавь хотя бы один навык')),
      );
      return;
    }

    final repo = HomebrewRepositoryScope.of(context);

    if (widget.initial != null) {
      repo.updateClass(widget.initial!.copyWith(
        name: _name.text.trim(),
        hitDie: _hitDie,
        savingThrows: _savingThrows.toList(),
        skillChoiceCount: _skillChoiceCount,
        availableSkillIds: _availableSkills.toList(),
        description: _description.text.trim(),
      ));
    } else {
      repo.addClass(HomebrewClass(
        id: 'hb_class_${DateTime.now().millisecondsSinceEpoch}',
        name: _name.text.trim(),
        hitDie: _hitDie,
        savingThrows: _savingThrows.toList(),
        skillChoiceCount: _skillChoiceCount,
        availableSkillIds: _availableSkills.toList(),
        description: _description.text.trim(),
      ));
    }

    Navigator.of(context).pop();
  }
}
