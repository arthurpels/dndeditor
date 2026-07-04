import '../data/dnd_reference_data.dart';
import '../data/game_data.dart';
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
    String? raceId,
    String? classId,
    this.backgroundId,
    this.abilityMethod = 'standard_array',
    Map<Ability, int>? baseAbilities,
    Set<Skill>? skillProficiencies,
    Set<Ability>? savingThrowProficiencies,
    int? maxHp,
    int? currentHp,
    String? biography,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? race,
    String? characterClass,
    int? hitPoints,
    int? maxHitPoints,
    String? notes,
  })  : raceId = _resolveRaceId(raceId, race),
        classId = _resolveClassId(classId, characterClass),
        baseAbilities = baseAbilities ?? _defaultBaseAbilities(),
        skillProficiencies = skillProficiencies ?? <Skill>{},
        savingThrowProficiencies = savingThrowProficiencies ?? <Ability>{},
        maxHp = maxHp ?? maxHitPoints ?? hitPoints ?? 1,
        currentHp = currentHp ?? hitPoints ?? maxHp ?? maxHitPoints ?? 1,
        biography = biography ?? notes ?? '',
        createdAt = createdAt,
        updatedAt = updatedAt,
        raceName = race,
        className = characterClass;

  String id;
  String name;
  int level;
  String? raceId;
  String? classId;
  String? backgroundId;

  /// Custom display name for race/class, used when the id is not a PHB entry
  /// (e.g. homebrew). Null for standard content — the getter falls back to
  /// GameData lookup by id.
  String? raceName;
  String? className;

  /// How ability scores were generated: standard_array | point_buy | roll.
  String abilityMethod;

  /// Raw ability scores BEFORE racial bonuses are applied.
  Map<Ability, int> baseAbilities;

  Set<Skill> skillProficiencies;
  Set<Ability> savingThrowProficiencies;

  int maxHp;
  int currentHp;
  String biography;
  DateTime? createdAt;
  DateTime? updatedAt;

  String get _effectiveRaceId => raceId ?? 'human';
  String get _effectiveClassId => classId ?? 'fighter';

  // Legacy compatibility getters used by older UI code and imported JSON.
  // Prefer an explicit custom name (homebrew) before the PHB GameData lookup.
  String get race =>
      raceName ?? GameData.raceById(_effectiveRaceId)?.name ?? _effectiveRaceId;
  String get characterClass =>
      className ??
      GameData.classById(_effectiveClassId)?.name ??
      _effectiveClassId;
  int get hitPoints => currentHp;
  int get maxHitPoints => maxHp;
  String get notes => biography;

  // ---------------------------------------------------------------------------
  // String-based computed getters (used by Dev C's character sheet UI)
  // dndSkills and Skill.values share the same order, enabling index-based lookup.
  // ---------------------------------------------------------------------------

  Set<String> get _skillNames =>
      skillProficiencies
          .map((s) => dndSkills[Skill.values.indexOf(s)])
          .toSet();

  Set<String> get _saveAbbrs =>
      savingThrowProficiencies.map((a) => a.abbr).toSet();

  int baseScore(String abilityId) =>
      baseAbilities[Ability.fromCode(abilityId.toLowerCase())] ?? 10;

  int totalScore(String abilityId) =>
      baseScore(abilityId) + RulesEngine.raceBonus(_effectiveRaceId, abilityId);

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
  int get speed => RulesEngine.raceSpeed(_effectiveRaceId);
  int get hitDie => RulesEngine.hitDieForClass(_effectiveClassId);

  Set<String> get backgroundSkillProficiencies =>
      backgroundId != null
          ? RulesEngine.skillProficienciesForBackground(backgroundId!)
          : const {};

  static const List<String> abilities = dndAbilities;
  static const List<String> skills = dndSkills;

  // ---------------------------------------------------------------------------
  // Factories
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

  /// Blank draft character for Dev D's repository (create-new flow).
  static Character blank({required String id}) => Character(
        id: id,
        name: 'Новый персонаж',
        raceId: 'human',
        classId: 'fighter',
        baseAbilities: {for (final a in Ability.values) a: 10},
        maxHp: 10,
        currentHp: 10,
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
        race: this.race,
        characterClass: this.characterClass,
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
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'race': race,
        'characterClass': characterClass,
        'hitPoints': hitPoints,
        'maxHitPoints': maxHitPoints,
        'notes': notes,
      };

  factory Character.fromJson(Map<String, Object?> json) {
    // Dev D's simplified asset format: has 'race' key instead of 'raceId'.
    if (json.containsKey('race') && !json.containsKey('raceId')) {
      return Character(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Безымянный',
        level: (json['level'] as num?)?.toInt() ?? 1,
        raceId: (json['race'] as String? ?? 'human').toLowerCase(),
        classId: (json['characterClass'] as String? ?? 'fighter').toLowerCase(),
        baseAbilities: {for (final a in Ability.values) a: 10},
        maxHp: (json['maxHitPoints'] as num?)?.toInt() ?? 1,
        currentHp: (json['hitPoints'] as num?)?.toInt(),
        biography: json['notes'] as String? ?? '',
      );
    }

    // Full format (branch-a / our schema).
    final raw =
        (json['baseAbilities'] as Map?)?.cast<String, dynamic>() ?? const {};
    final isModern = json.containsKey('raceId') ||
        json.containsKey('classId') ||
        json.containsKey('baseAbilities');

    if (isModern) {
      return Character(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Безымянный',
        level: (json['level'] as num?)?.toInt() ?? 1,
        raceId: json['raceId'] as String?,
        classId: json['classId'] as String?,
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
        maxHp: (json['maxHp'] as num?)?.toInt() ??
            (json['maxHitPoints'] as num?)?.toInt(),
        currentHp: (json['currentHp'] as num?)?.toInt() ??
            (json['hitPoints'] as num?)?.toInt(),
        biography:
            json['biography'] as String? ?? json['notes'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
        race: json['race'] as String?,
        characterClass: json['characterClass'] as String?,
      );
    }

    return Character(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Безымянный',
      level: (json['level'] as num?)?.toInt() ?? 1,
      raceId: json['raceId'] as String?,
      classId: json['classId'] as String?,
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
      biography: json['biography'] as String? ?? json['notes'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      race: json['race'] as String?,
      characterClass: json['characterClass'] as String?,
    );
  }

  static Map<Ability, int> _defaultBaseAbilities() => {
        for (final a in Ability.values) a: 10,
      };

  static String? _resolveRaceId(String? raceId, String? race) {
    if (raceId != null && raceId.trim().isNotEmpty) {
      return raceId;
    }
    return _findIdByName(race, GameData.races);
  }

  static String? _resolveClassId(String? classId, String? characterClass) {
    if (classId != null && classId.trim().isNotEmpty) {
      return classId;
    }
    return _findIdByName(characterClass, GameData.classes);
  }

  static String? _findIdByName(
    String? value,
    Iterable<dynamic> options,
  ) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    for (final option in options) {
      final id = option.id as String;
      final name = option.name as String;
      if (id.toLowerCase() == normalized || name.toLowerCase() == normalized) {
        return id;
      }
    }
    return normalized;
  }
}
