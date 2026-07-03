import 'package:flutter/material.dart';

import '../data/dnd_reference_data.dart';
import '../models/character.dart';
import '../repository/character_repository.dart';
import '../rules/rules_engine.dart';

/// Full character sheet screen (Экран 6 по PRD).
///
/// Displays abilities, modifiers, saving throws, 18 skills, combat stats,
/// and editable state (HP, level, notes). All edits persist via repository.
class CharacterSheetScreen extends StatefulWidget {
  const CharacterSheetScreen({super.key, required this.characterId});

  final String characterId;

  @override
  State<CharacterSheetScreen> createState() => _CharacterSheetScreenState();
}

class _CharacterSheetScreenState extends State<CharacterSheetScreen> {
  late Character _character;
  late int _currentHp;
  late TextEditingController _notesController;
  bool _initialised = false;

  CharacterRepository get _repository => CharacterRepositoryScope.of(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loaded = _repository.ownedById(widget.characterId);
    if (loaded != null) {
      _character = loaded;
      if (!_initialised) {
        _currentHp = _character.currentHp;
        _notesController = TextEditingController(text: _character.biography);
        _initialised = true;
      }
    }
  }

  @override
  void dispose() {
    if (_initialised) _notesController.dispose();
    super.dispose();
  }

  // -- State mutations --------------------------------------------------------

  void _changeLevel(int delta) {
    setState(() {
      final nextLevel = (_character.level + delta).clamp(1, 20);
      _character = _character.copyWith(level: nextLevel, updatedAt: DateTime.now());
      final newMaxHp = RulesEngine.maxHpForCharacter(_character);
      _character = _character.copyWith(maxHp: newMaxHp);
      _currentHp = _currentHp.clamp(0, newMaxHp);
      _character = _character.copyWith(currentHp: _currentHp);
    });
    _persist();
  }

  void _adjustHp(int delta) {
    setState(() {
      _currentHp = (_currentHp + delta).clamp(0, _character.maxHp);
      _character = _character.copyWith(currentHp: _currentHp, updatedAt: DateTime.now());
    });
    _persist();
  }

  void _resetHp() {
    setState(() {
      _currentHp = _character.maxHp;
      _character = _character.copyWith(currentHp: _currentHp, updatedAt: DateTime.now());
    });
    _persist();
  }

  void _saveNotes() {
    setState(() {
      _character = _character.copyWith(
        biography: _notesController.text,
        updatedAt: DateTime.now(),
      );
    });
    _persist();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Сохранено')),
    );
  }

  void _persist() => _repository.updateOwned(_character);

  // -- Build ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (!_initialised) {
      return Scaffold(
        appBar: AppBar(title: const Text('Персонаж')),
        body: const Center(child: Text('Персонаж не найден')),
      );
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_character.name),
        actions: [
          TextButton.icon(
            onPressed: _saveNotes,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Сохранить'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // -- Header --
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _character.name,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'Ур. ${_character.level}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_character.race} · ${_character.characterClass}',
                    style: theme.textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
                  ),
                  if (_character.backgroundId != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Предыстория: ${_character.backgroundId}',
                      style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Chip('PB +${_character.proficiencyBonus}', colors),
                      _Chip('Speed ${_character.speed} ft', colors),
                      _Chip('Hit Die d${_character.hitDie}', colors),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // -- Combat stats --
          Row(
            children: [
              Expanded(child: _StatCard('HP', '$_currentHp/${_character.maxHp}', colors)),
              const SizedBox(width: 8),
              Expanded(child: _StatCard('AC', '${_character.armorClass}', colors)),
              const SizedBox(width: 8),
              Expanded(child: _StatCard('Init', RulesEngine.signed(_character.initiative), colors)),
              const SizedBox(width: 8),
              Expanded(child: _StatCard('PP', '${_character.passivePerception}', colors)),
            ],
          ),
          const SizedBox(height: 12),

          // -- HP / Level control --
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Управление', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StepperRow(
                          label: 'Уровень',
                          value: '${_character.level}',
                          onMinus: () => _changeLevel(-1),
                          onPlus: () => _changeLevel(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StepperRow(
                          label: 'HP',
                          value: '$_currentHp',
                          onMinus: () => _adjustHp(-1),
                          onPlus: () => _adjustHp(1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _character.maxHp == 0 ? 0 : _currentHp / _character.maxHp,
                      minHeight: 8,
                      backgroundColor: colors.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _resetHp,
                        icon: const Icon(Icons.restore, size: 18),
                        label: const Text('Полное HP'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _adjustHp(-5),
                        icon: const Icon(Icons.remove, size: 18),
                        label: const Text('−5'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _adjustHp(5),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('+5'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // -- Abilities --
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Характеристики', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      for (final id in Character.abilities)
                        _AbilityCell(
                          label: id,
                          score: _character.totalScore(id),
                          modifier: _character.modifierFor(id),
                          bonus: RulesEngine.raceBonus(_character.raceId ?? 'human', id),
                          colors: colors,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // -- Saving throws --
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Спасброски', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final id in Character.abilities)
                        _SaveChip(
                          label: id,
                          value: _character.savingThrowValue(id),
                          proficient: _character.savingThrowProficiencies
                              .map((a) => a.abbr)
                              .contains(id),
                          colors: colors,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // -- Skills --
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Навыки', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  for (final skill in Character.skills)
                    _SkillRow(
                      skill: skill,
                      ability: RulesEngine.skillAbility(skill),
                      value: _character.skillValue(skill),
                      proficient: _character.skillProficiencies
                          .map((s) => dndSkills[s.index])
                          .contains(skill),
                      colors: colors,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // -- Notes --
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Заметки', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Биография, стиль игры, заметки...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Small helper widgets
// =============================================================================

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.colors);
  final String label;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSurfaceVariant)),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value, this.colors);
  final String label;
  final String value;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colors.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });
  final String label;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        Row(
          children: [
            IconButton.outlined(onPressed: onMinus, icon: const Icon(Icons.remove, size: 18)),
            Expanded(
              child: Center(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            IconButton.filled(onPressed: onPlus, icon: const Icon(Icons.add, size: 18)),
          ],
        ),
      ],
    );
  }
}

class _AbilityCell extends StatelessWidget {
  const _AbilityCell({
    required this.label,
    required this.score,
    required this.modifier,
    required this.bonus,
    required this.colors,
  });
  final String label;
  final int score;
  final int modifier;
  final int bonus;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: colors.onSurfaceVariant)),
          Text('$score', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: colors.primary)),
          Text(
            RulesEngine.signed(modifier),
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (bonus != 0)
            Text(
              'раса ${RulesEngine.signed(bonus)}',
              style: theme.textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}

class _SaveChip extends StatelessWidget {
  const _SaveChip({
    required this.label,
    required this.value,
    required this.proficient,
    required this.colors,
  });
  final String label;
  final int value;
  final bool proficient;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: proficient ? colors.primaryContainer : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: proficient ? colors.onPrimaryContainer : colors.onSurfaceVariant)),
          const SizedBox(width: 6),
          Text(
            RulesEngine.signed(value),
            style: TextStyle(fontWeight: FontWeight.w800, color: proficient ? colors.primary : colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({
    required this.skill,
    required this.ability,
    required this.value,
    required this.proficient,
    required this.colors,
  });
  final String skill;
  final String ability;
  final int value;
  final bool proficient;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(
            proficient ? Icons.circle : Icons.circle_outlined,
            size: 10,
            color: proficient ? colors.primary : colors.outlineVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              skill,
              style: TextStyle(
                fontWeight: proficient ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            ability,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              RulesEngine.signed(value),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: proficient ? colors.primary : colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
