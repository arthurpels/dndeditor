import '../data/dnd_reference_data.dart';
import '../rules/rules_engine.dart';
import 'ability.dart';
import 'skill.dart';

/// D&D character. Stores only raw player choices — base ability scores (before
/// racial bonuses), proficiency selections, and mutable state (current HP).
/// All derived values (modifiers, skill bonuses, AC, etc.) are computed by
/// RulesEngine so re-choosing a race never corrupts stored data.
class Character {
  Character({
    required this.id,
    required this.name,
    this.level = 1,
    required this.raceId,
    required this.classId,
    this.backgroundId,
    this.abilityMethod = 'standard_array',
    required this.baseAbilities,
    Set<Skill>? skillProficiencies,
    Set<Ability>? savingThrowProficiencies,
    this.maxHp = 1,
    int? currentHp,
    this.biography = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : skillProficiencies = skillProficiencies ?? {},
        savingThrowProficiencies = savingThrowProficiencies ?? {},
        currentHp = currentHp ?? maxHp,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String id;
  String name;
  int level;
  String raceId;
  String classId;
  String? backgroundId;

  /// How ability scores were generated: standard_array | point_buy | roll.
  String abilityMethod;

  /// Raw ability scores BEFORE racial bonuses are applied.
  Map<Ability, int> baseAbilities;

  Set<Skill> skillProficiencies;
  Set<Ability> savingThrowProficiencies;

  int maxHp;
  int currentHp;
  String biography;
  DateTime createdAt;
  DateTime updatedAt;

  // ---------------------------------------------------------------------------
  // String-based computed getters (used by Dev C's character sheet UI)
  // dndSkills and Skill.values share the same order, enabling index-based lookup.
  // ---------------------------------------------------------------------------

  /// All skill proficiency names as English strings ("Athletics", "Stealth", …).
  Set<String> get _skillNames =>
      skillProficiencies
          .map((s) => dndSkills[Skill.values.indexOf(s)])
          .toSet();

  /// All saving throw proficiency abbreviations ("STR", "CON", …).
  Set<String> get _saveAbbrs =>
      savingThrowProficiencies.map((a) => a.abbr).toSet();

  int baseScore(String abilityId) =>
      baseAbilities[Ability.fromCode(abilityId.toLowerCase())] ?? 10;

  int totalScore(String abilityId) =>
      baseScore(abilityId) + RulesEngine.raceBonus(raceId, abilityId);

  int modifierFor(String abilityId) =>
      RulesEngine.modifier(totalScore(abilityId));

  int get proficiencyBonus => RulesEngine.proficiencyBonus(level);

  int skillValue(String skillName) {
    final abilityId = RulesEngine.skillAbility(skillName);
    final proficient = _skillNames.contains(skillName);
    return modifierFor(abilityId) + (proficient ? proficiencyBonus : 0);
  }

  int savingThrowValue(String abilityId) {
    final proficient = _saveAbbrs.contains(abilityId);
    return modifierFor(abilityId) + (proficient ? proficiencyBonus : 0);
  }

  int get armorClass => 10 + modifierFor('DEX');
  int get initiative => modifierFor('DEX');
  int get passivePerception => 10 + skillValue('Perception');
  int get speed => RulesEngine.raceSpeed(raceId);
  int get hitDie => RulesEngine.hitDieForClass(classId);

  Set<String> get backgroundSkillProficiencies =>
      backgroundId != null
          ? RulesEngine.skillProficienciesForBackground(backgroundId!)
          : const {};

  static const List<String> abilities = dndAbilities;
  static const List<String> skills = dndSkills;

  // ---------------------------------------------------------------------------
  // Sample character for UI development and testing
  // ---------------------------------------------------------------------------

  factory Character.sample() => Character(
        id: 'sample-thorin',
        name: 'Торин',
        level: 1,
        raceId: 'dwarf',
        classId: 'fighter',
        backgroundId: 'soldier',
        abilityMethod: 'standard_array',
        baseAbilities: {
          Ability.strength: 15,
          Ability.dexterity: 13,
          Ability.constitution: 14,
          Ability.intelligence: 10,
          Ability.wisdom: 12,
          Ability.charisma: 8,
        },
        skillProficiencies: {Skill.athletics, Skill.intimidation},
        savingThrowProficiencies: {Ability.strength, Ability.constitution},
        maxHp: 12,
        currentHp: 12,
        biography: 'Дисциплинированный фронтовик, привыкший держать строй и прикрывать отряд.',
        createdAt: DateTime.utc(2026, 7, 3),
        updatedAt: DateTime.utc(2026, 7, 3),
      );

  // ---------------------------------------------------------------------------
  // copyWith / serialization
  // ---------------------------------------------------------------------------

  Character copyWith({
    String? id,
    String? name,
    int? level,
    String? raceId,
    String? classId,
    String? backgroundId,
    String? abilityMethod,
    Map<Ability, int>? baseAbilities,
    Set<Skill>? skillProficiencies,
    Set<Ability>? savingThrowProficiencies,
    int? maxHp,
    int? currentHp,
    String? biography,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Character(
        id: id ?? this.id,
        name: name ?? this.name,
        level: level ?? this.level,
        raceId: raceId ?? this.raceId,
        classId: classId ?? this.classId,
        backgroundId: backgroundId ?? this.backgroundId,
        abilityMethod: abilityMethod ?? this.abilityMethod,
        baseAbilities:
            baseAbilities ?? Map<Ability, int>.from(this.baseAbilities),
        skillProficiencies:
            skillProficiencies ?? Set<Skill>.from(this.skillProficiencies),
        savingThrowProficiencies: savingThrowProficiencies ??
            Set<Ability>.from(this.savingThrowProficiencies),
        maxHp: maxHp ?? this.maxHp,
        currentHp: currentHp ?? this.currentHp,
        biography: biography ?? this.biography,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'level': level,
        'raceId': raceId,
        'classId': classId,
        'backgroundId': backgroundId,
        'abilityMethod': abilityMethod,
        'baseAbilities': {
          for (final a in Ability.values) a.code: baseAbilities[a] ?? 10,
        },
        'skillProficiencies': skillProficiencies.map((s) => s.name).toList(),
        'savingThrowProficiencies':
            savingThrowProficiencies.map((a) => a.code).toList(),
        'maxHp': maxHp,
        'currentHp': currentHp,
        'biography': biography,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Character.fromJson(Map<String, dynamic> json) {
    final raw =
        (json['baseAbilities'] as Map?)?.cast<String, dynamic>() ?? const {};
    return Character(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Безымянный',
      level: (json['level'] as num?)?.toInt() ?? 1,
      raceId: json['raceId'] as String,
      classId: json['classId'] as String,
      backgroundId: json['backgroundId'] as String?,
      abilityMethod: json['abilityMethod'] as String? ?? 'standard_array',
      baseAbilities: {
        for (final a in Ability.values)
          a: (raw[a.code] as num?)?.toInt() ?? 10,
      },
      skillProficiencies:
          ((json['skillProficiencies'] as List?) ?? const [])
              .map((e) => Skill.fromName(e as String))
              .toSet(),
      savingThrowProficiencies:
          ((json['savingThrowProficiencies'] as List?) ?? const [])
              .map((e) => Ability.fromCode(e as String))
              .toSet(),
      maxHp: (json['maxHp'] as num?)?.toInt() ?? 1,
      currentHp: (json['currentHp'] as num?)?.toInt(),
      biography: json['biography'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }
}
