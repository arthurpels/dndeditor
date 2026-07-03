import '../data/dnd_reference_data.dart';
import '../rules/rules_engine.dart';

class Character {
  const Character({
    required this.id,
    required this.name,
    required this.level,
    required this.raceId,
    required this.classId,
    required this.backgroundId,
    required this.abilityMethod,
    required this.baseAbilities,
    required this.skillProficiencies,
    required this.savingThrowProficiencies,
    required this.maxHp,
    required this.currentHp,
    required this.biography,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final int level;
  final String raceId;
  final String classId;
  final String backgroundId;
  final String abilityMethod;
  final Map<String, int> baseAbilities;
  final Set<String> skillProficiencies;
  final Set<String> savingThrowProficiencies;
  final int maxHp;
  final int currentHp;
  final String biography;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Character.sample() {
    return Character(
      id: 'sample-thorin',
      name: 'Торин',
      level: 1,
      raceId: 'dwarf',
      classId: 'fighter',
      backgroundId: 'soldier',
      abilityMethod: 'standard_array',
      baseAbilities: const {
        'STR': 15,
        'DEX': 13,
        'CON': 14,
        'INT': 10,
        'WIS': 12,
        'CHA': 8,
      },
      skillProficiencies: const {'Athletics', 'Intimidation'},
      savingThrowProficiencies: const {'STR', 'CON'},
      maxHp: 12,
      currentHp: 12,
      biography: 'Дисциплинированный фронтовик, привыкший держать строй и прикрывать отряд.',
      createdAt: DateTime.utc(2026, 7, 3),
      updatedAt: DateTime.utc(2026, 7, 3),
    );
  }

  Character copyWith({
    String? id,
    String? name,
    int? level,
    String? raceId,
    String? classId,
    String? backgroundId,
    String? abilityMethod,
    Map<String, int>? baseAbilities,
    Set<String>? skillProficiencies,
    Set<String>? savingThrowProficiencies,
    int? maxHp,
    int? currentHp,
    String? biography,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      raceId: raceId ?? this.raceId,
      classId: classId ?? this.classId,
      backgroundId: backgroundId ?? this.backgroundId,
      abilityMethod: abilityMethod ?? this.abilityMethod,
      baseAbilities: baseAbilities ?? this.baseAbilities,
      skillProficiencies: skillProficiencies ?? this.skillProficiencies,
      savingThrowProficiencies: savingThrowProficiencies ?? this.savingThrowProficiencies,
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      biography: biography ?? this.biography,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'raceId': raceId,
      'classId': classId,
      'backgroundId': backgroundId,
      'abilityMethod': abilityMethod,
      'baseAbilities': baseAbilities,
      'skillProficiencies': skillProficiencies.toList(),
      'savingThrowProficiencies': savingThrowProficiencies.toList(),
      'maxHp': maxHp,
      'currentHp': currentHp,
      'biography': biography,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as String,
      name: json['name'] as String,
      level: json['level'] as int,
      raceId: json['raceId'] as String,
      classId: json['classId'] as String,
      backgroundId: json['backgroundId'] as String,
      abilityMethod: json['abilityMethod'] as String,
      baseAbilities: Map<String, int>.from(json['baseAbilities'] as Map),
      skillProficiencies: Set<String>.from(json['skillProficiencies'] as List),
      savingThrowProficiencies: Set<String>.from(json['savingThrowProficiencies'] as List),
      maxHp: json['maxHp'] as int,
      currentHp: json['currentHp'] as int,
      biography: json['biography'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  int baseScore(String abilityId) => baseAbilities[abilityId] ?? 10;

  int totalScore(String abilityId) => baseScore(abilityId) + RulesEngine.raceBonus(raceId, abilityId);

  int modifierFor(String abilityId) => RulesEngine.modifier(totalScore(abilityId));

  int get proficiencyBonus => RulesEngine.proficiencyBonus(level);

  int skillValue(String skillName) {
    final abilityId = RulesEngine.skillAbility(skillName);
    final proficient = skillProficiencies.contains(skillName);
    return modifierFor(abilityId) + (proficient ? proficiencyBonus : 0);
  }

  int savingThrowValue(String abilityId) {
    final proficient = savingThrowProficiencies.contains(abilityId);
    return modifierFor(abilityId) + (proficient ? proficiencyBonus : 0);
  }

  int get armorClass => 10 + modifierFor('DEX');

  int get initiative => modifierFor('DEX');

  int get passivePerception => 10 + skillValue('Perception');

  int get speed => RulesEngine.raceSpeed(raceId);

  int get hitDie => RulesEngine.hitDieForClass(classId);

  Set<String> get backgroundSkillProficiencies {
    return RulesEngine.skillProficienciesForBackground(backgroundId);
  }

  static const List<String> abilities = dndAbilities;
  static const List<String> skills = dndSkills;
}
