import 'package:flutter/material.dart';

import 'character_sheet_data.dart';

class CharacterSheetScreen extends StatefulWidget {
  const CharacterSheetScreen({super.key, required this.character});

  final CharacterSheetData character;

  @override
  State<CharacterSheetScreen> createState() => _CharacterSheetScreenState();
}

class _CharacterSheetScreenState extends State<CharacterSheetScreen> {
  late CharacterSheetData character;
  late int currentHp;
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    character = widget.character;
    currentHp = character.maxHp;
    notesController = TextEditingController(text: character.biography);
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  void changeLevel(int delta) {
    setState(() {
      final nextLevel = (character.level + delta).clamp(1, 20);
      character = character.copyWith(level: nextLevel);
      currentHp = currentHp.clamp(0, character.maxHp);
    });
  }

  void adjustHp(int delta) {
    setState(() {
      currentHp = (currentHp + delta).clamp(0, character.maxHp);
    });
  }

  void resetHp() {
    setState(() {
      currentHp = character.maxHp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final abilities = CharacterSheetData.allAbilities;
    final skills = CharacterSheetData.allSkills;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка персонажа'),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                character = character.copyWith(biography: notesController.text);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Локальные изменения сохранены в стейте')),
              );
            },
            icon: const Icon(Icons.save_outlined),
            label: const Text('Сохранить'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF09121F), Color(0xFF05101A)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _HeroCard(character: character),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'HP',
                      value: '$currentHp/${character.maxHp}',
                      subtitle: 'Current / Max',
                      accent: const Color(0xFF58C6F6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'AC',
                      value: '${character.armorClass}',
                      subtitle: 'Без брони',
                      accent: const Color(0xFF82D67A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Init',
                      value: '${character.initiative >= 0 ? '+' : ''}${character.initiative}',
                      subtitle: 'DEX mod',
                      accent: const Color(0xFFF7B267),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'PP',
                      value: '${character.passivePerception}',
                      subtitle: 'Passive Perception',
                      accent: const Color(0xFFB99AFF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Характеристики',
                subtitle: 'Базовые значения, расовые бонусы и модификаторы',
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (final ability in abilities)
                      _AbilityTile(
                        label: ability,
                        score: character.totalScoreFor(ability),
                        modifier: character.totalModifierFor(ability),
                        bonus: character.racialBonusFor(ability),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Редактирование состояния',
                subtitle: 'HP, уровень и заметки можно менять прямо здесь',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StepperCard(
                            label: 'Level',
                            value: '${character.level}',
                            onDecrease: () => changeLevel(-1),
                            onIncrease: () => changeLevel(1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StepperCard(
                            label: 'Current HP',
                            value: '$currentHp',
                            onDecrease: () => adjustHp(-1),
                            onIncrease: () => adjustHp(1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: character.maxHp == 0 ? 0 : currentHp / character.maxHp,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Бонус мастерства +${character.proficiencyBonus} · HP считаютcя по кости ${character.hitDie} и CON.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: resetHp,
                          icon: const Icon(Icons.restore),
                          label: const Text('Restore HP'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => adjustHp(-5),
                          icon: const Icon(Icons.remove_circle_outline),
                          label: const Text('-5 HP'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => adjustHp(5),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('+5 HP'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Спасброски',
                subtitle: 'Класс дает владение, остальное считает движок',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final ability in abilities)
                      _Pill(
                        title: ability,
                        value: character.savingThrowValue(ability),
                        active: character.savingThrowProficiencies.contains(ability),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Навыки',
                subtitle: 'Отмечены владения персонажа',
                child: Column(
                  children: [
                    for (final skill in skills)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _SkillRow(
                          skill: skill,
                          ability: CharacterSheetData.skillAbilityFor(skill),
                          value: character.skillValue(skill),
                          proficient: character.skillProficiencies.contains(skill),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Заметки',
                subtitle: 'То, что пойдет в карточку и потом в сохранение',
                child: TextField(
                  controller: notesController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Краткое описание персонажа, стиль игры, крючки для сюжета...',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.character});

  final CharacterSheetData character;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF14304B), Color(0xFF0E2136), Color(0xFF0A1522)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${character.race} ${character.characterClass} · ${character.background}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
              _LevelBadge(level: character.level),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(label: 'PB +${character.proficiencyBonus}'),
              _Tag(label: 'Speed ${character.speed} ft'),
              _Tag(label: 'Hit Die d${character.hitDie}'),
              _Tag(label: 'AC ${character.armorClass}'),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            character.biography,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF58C6F6).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF58C6F6).withValues(alpha: 0.28)),
      ),
      child: Column(
        children: [
          Text(
            '$level',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF9EE4FF),
                ),
          ),
          Text(
            'LEVEL',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white60,
                  letterSpacing: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.accent,
  });

  final String label;
  final String value;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFF0F1A29),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white60),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _AbilityTile extends StatelessWidget {
  const _AbilityTile({
    required this.label,
    required this.score,
    required this.modifier,
    required this.bonus,
  });

  final String label;
  final int score;
  final int modifier;
  final int bonus;

  @override
  Widget build(BuildContext context) {
    final modifierText = modifier >= 0 ? '+$modifier' : '$modifier';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101B2B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70)),
          Text(
            '$score',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF58C6F6),
                ),
          ),
          Text(
            modifierText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (bonus != 0)
            Text(
              'расс: ${bonus >= 0 ? '+' : ''}$bonus',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white54),
            )
          else
            const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _StepperCard extends StatelessWidget {
  const _StepperCard({
    required this.label,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String label;
  final String value;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101B2B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70)),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton.outlined(onPressed: onDecrease, icon: const Icon(Icons.remove)),
              const SizedBox(width: 8),
              Expanded(
                child: Center(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(onPressed: onIncrease, icon: const Icon(Icons.add)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.title, required this.value, required this.active});

  final String title;
  final int value;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF58C6F6).withValues(alpha: 0.16) : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? const Color(0xFF58C6F6).withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Text(
            value >= 0 ? '+$value' : '$value',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: active ? const Color(0xFF9EE4FF) : Colors.white70,
            ),
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
  });

  final String skill;
  final String ability;
  final int value;
  final bool proficient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: proficient ? const Color(0xFF58C6F6) : Colors.white30,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(skill, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  ability,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
                ),
              ],
            ),
          ),
          Text(
            value >= 0 ? '+$value' : '$value',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: proficient ? const Color(0xFF9EE4FF) : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}