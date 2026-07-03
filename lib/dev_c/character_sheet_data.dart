import 'dart:math';

class CharacterSheetData {
  const CharacterSheetData({
    required this.name,
    required this.race,
    required this.characterClass,
    required this.background,
    required this.level,
    required this.hitDie,
    required this.speed,
    required this.baseAbilities,
    required this.skillProficiencies,
    required this.savingThrowProficiencies,
    required this.biography,
  });

  final String name;
  final String race;
  final String characterClass;
  final String background;
  final int level;
  final int hitDie;
  final int speed;
  final Map<String, int> baseAbilities;
  final Set<String> skillProficiencies;
  final Set<String> savingThrowProficiencies;
  final String biography;

  static CharacterSheetData sample() {
    return const CharacterSheetData(
      name: 'Торин',
      race: 'Dwarf',
      characterClass: 'Fighter',
      background: 'Soldier',
      level: 1,
      hitDie: 10,
      speed: 25,
      baseAbilities: {
        'STR': 15,
        'DEX': 13,
        'CON': 14,
        'INT': 10,
        'WIS': 12,
        'CHA': 8,
      },
      skillProficiencies: {'Athletics', 'Intimidation'},
      savingThrowProficiencies: {'STR', 'CON'},
      biography: 'Дисциплинированный фронтовик, привыкший держать строй и прикрывать отряд.',
    );
  }

  int abilityModifier(String ability) => modifier(scoreFor(ability));

  int get proficiencyBonus => 2 + ((level - 1) ~/ 4);

  int scoreFor(String ability) {
    return baseAbilities[ability] ?? 10;
  }

  int racialBonusFor(String ability) {
    switch (race) {
      case 'Dwarf':
        return ability == 'CON' ? 2 : 0;
      case 'Elf':
        return ability == 'DEX' ? 2 : 0;
      case 'Halfling':
        return ability == 'DEX' ? 2 : 0;
      case 'Dragonborn':
        return switch (ability) {
          'STR' => 2,
          'CHA' => 1,
          _ => 0,
        };
      case 'Gnome':
        return ability == 'INT' ? 2 : 0;
      case 'Half-Elf':
        return ability == 'CHA' ? 2 : 0;
      case 'Half-Orc':
        return switch (ability) {
          'STR' => 2,
          'CON' => 1,
          _ => 0,
        };
      case 'Tiefling':
        return switch (ability) {
          'CHA' => 2,
          'INT' => 1,
          _ => 0,
        };
      case 'Human':
        return 1;
      default:
        return 0;
    }
  }

  int totalScoreFor(String ability) => scoreFor(ability) + racialBonusFor(ability);

  int totalModifierFor(String ability) => modifier(totalScoreFor(ability));

  int skillValue(String skillName) {
    final ability = skillAbilityFor(skillName);
    final base = totalModifierFor(ability);
    return base + (skillProficiencies.contains(skillName) ? proficiencyBonus : 0);
  }

  int savingThrowValue(String ability) {
    final base = totalModifierFor(ability);
    return base + (savingThrowProficiencies.contains(ability) ? proficiencyBonus : 0);
  }

  int get maxHp {
    final conMod = totalModifierFor('CON');
    final firstLevelHp = hitDie + conMod;
    if (level <= 1) {
      return max(1, firstLevelHp);
    }

    final averageHitDie = (hitDie ~/ 2) + 1;
    final extraLevels = level - 1;
    return max(1, firstLevelHp + extraLevels * (averageHitDie + conMod));
  }

  int get armorClass => 10 + totalModifierFor('DEX');

  int get initiative => totalModifierFor('DEX');

  int get passivePerception => 10 + skillValue('Perception');

  CharacterSheetData copyWith({
    String? name,
    String? race,
    String? characterClass,
    String? background,
    int? level,
    int? hitDie,
    int? speed,
    Map<String, int>? baseAbilities,
    Set<String>? skillProficiencies,
    Set<String>? savingThrowProficiencies,
    String? biography,
  }) {
    return CharacterSheetData(
      name: name ?? this.name,
      race: race ?? this.race,
      characterClass: characterClass ?? this.characterClass,
      background: background ?? this.background,
      level: level ?? this.level,
      hitDie: hitDie ?? this.hitDie,
      speed: speed ?? this.speed,
      baseAbilities: baseAbilities ?? this.baseAbilities,
      skillProficiencies: skillProficiencies ?? this.skillProficiencies,
      savingThrowProficiencies: savingThrowProficiencies ?? this.savingThrowProficiencies,
      biography: biography ?? this.biography,
    );
  }

  static int modifier(int score) => (score - 10) ~/ 2;

  static String skillAbilityFor(String skillName) {
    switch (skillName) {
      case 'Athletics':
        return 'STR';
      case 'Acrobatics':
      case 'Sleight of Hand':
      case 'Stealth':
        return 'DEX';
      case 'Arcana':
      case 'History':
      case 'Investigation':
      case 'Nature':
      case 'Religion':
        return 'INT';
      case 'Animal Handling':
      case 'Insight':
      case 'Medicine':
      case 'Perception':
      case 'Survival':
        return 'WIS';
      case 'Deception':
      case 'Intimidation':
      case 'Performance':
      case 'Persuasion':
        return 'CHA';
      default:
        return 'INT';
    }
  }

  static const List<String> allAbilities = [
    'STR',
    'DEX',
    'CON',
    'INT',
    'WIS',
    'CHA',
  ];

  static const List<String> allSkills = [
    'Acrobatics',
    'Animal Handling',
    'Arcana',
    'Athletics',
    'Deception',
    'History',
    'Insight',
    'Intimidation',
    'Investigation',
    'Medicine',
    'Nature',
    'Perception',
    'Performance',
    'Persuasion',
    'Religion',
    'Sleight of Hand',
    'Stealth',
    'Survival',
  ];
}