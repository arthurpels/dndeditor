import 'package:flutter/material.dart';

import '../models/homebrew_race.dart';
import '../repository/homebrew_repository.dart';

class HomebrewRaceForm extends StatefulWidget {
  const HomebrewRaceForm({super.key, this.initial});

  final HomebrewRace? initial;

  @override
  State<HomebrewRaceForm> createState() => _HomebrewRaceFormState();
}

class _HomebrewRaceFormState extends State<HomebrewRaceForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late int _speed;
  late final Map<String, int> _bonuses;

  static const _abilities = [
    ('strength', 'Сила'),
    ('dexterity', 'Ловкость'),
    ('constitution', 'Телосложение'),
    ('intelligence', 'Интеллект'),
    ('wisdom', 'Мудрость'),
    ('charisma', 'Харизма'),
  ];

  @override
  void initState() {
    super.initState();
    final r = widget.initial;
    _name = TextEditingController(text: r?.name ?? '');
    _description = TextEditingController(text: r?.description ?? '');
    _speed = r?.speed ?? 30;
    _bonuses = {
      for (final (key, _) in _abilities) key: r?.abilityBonuses[key] ?? 0,
    };
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
        title: Text(isEdit ? 'Редактировать расу' : 'Новая раса'),
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
            Text('Скорость: $_speed фт.',
                style: Theme.of(context).textTheme.titleSmall),
            Slider(
              value: _speed.toDouble(),
              min: 20,
              max: 40,
              divisions: 4,
              label: '$_speed фт.',
              onChanged: (v) => setState(() => _speed = v.round()),
            ),
            const SizedBox(height: 8),
            Text('Бонусы к характеристикам',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final (key, label) in _abilities)
              _AbilityBonusRow(
                label: label,
                value: _bonuses[key]!,
                onChanged: (v) => setState(() => _bonuses[key] = v),
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

    final repo = HomebrewRepositoryScope.of(context);
    final nonZero = Map<String, int>.fromEntries(
      _bonuses.entries.where((e) => e.value != 0),
    );

    if (widget.initial != null) {
      repo.updateRace(widget.initial!.copyWith(
        name: _name.text.trim(),
        speed: _speed,
        abilityBonuses: nonZero,
        description: _description.text.trim(),
      ));
    } else {
      repo.addRace(HomebrewRace(
        id: 'hb_race_${DateTime.now().millisecondsSinceEpoch}',
        name: _name.text.trim(),
        speed: _speed,
        abilityBonuses: nonZero,
        description: _description.text.trim(),
      ));
    }

    Navigator.of(context).pop();
  }
}

class _AbilityBonusRow extends StatelessWidget {
  const _AbilityBonusRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label)),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: value > -2 ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 32,
            child: Text(
              value == 0 ? '0' : (value > 0 ? '+$value' : '$value'),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: value < 4 ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}
