class Character {
  const Character({
    required this.id,
    required this.name,
    required this.race,
    required this.characterClass,
    required this.level,
    required this.hitPoints,
    required this.maxHitPoints,
    this.notes = '',
  });

  final String id;
  final String name;
  final String race;
  final String characterClass;
  final int level;
  final int hitPoints;
  final int maxHitPoints;
  final String notes;

  Character copyWith({
    String? id,
    String? name,
    String? race,
    String? characterClass,
    int? level,
    int? hitPoints,
    int? maxHitPoints,
    String? notes,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      race: race ?? this.race,
      characterClass: characterClass ?? this.characterClass,
      level: level ?? this.level,
      hitPoints: hitPoints ?? this.hitPoints,
      maxHitPoints: maxHitPoints ?? this.maxHitPoints,
      notes: notes ?? this.notes,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'race': race,
      'characterClass': characterClass,
      'level': level,
      'hitPoints': hitPoints,
      'maxHitPoints': maxHitPoints,
      'notes': notes,
    };
  }

  factory Character.fromJson(Map<String, Object?> json) {
    return Character(
      id: json['id'] as String,
      name: json['name'] as String,
      race: json['race'] as String,
      characterClass: json['characterClass'] as String,
      level: (json['level'] as num).toInt(),
      hitPoints: (json['hitPoints'] as num).toInt(),
      maxHitPoints: (json['maxHitPoints'] as num).toInt(),
      notes: (json['notes'] as String?) ?? '',
    );
  }

  static Character blank({required String id}) {
    return Character(
      id: id,
      name: 'Новый персонаж',
      race: 'Human',
      characterClass: 'Fighter',
      level: 1,
      hitPoints: 10,
      maxHitPoints: 10,
    );
  }
}
