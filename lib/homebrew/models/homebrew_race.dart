import 'package:flutter/foundation.dart';

/// Пользовательская раса. Бонусы хранятся по имени характеристики
/// ('strength', 'dexterity', ...) — совпадает с AbilityScore.name.
@immutable
class HomebrewRace {
  const HomebrewRace({
    required this.id,
    required this.name,
    required this.speed,
    required this.abilityBonuses,
    this.description = '',
  });

  final String id;
  final String name;
  final int speed;
  final Map<String, int> abilityBonuses;
  final String description;

  HomebrewRace copyWith({
    String? id,
    String? name,
    int? speed,
    Map<String, int>? abilityBonuses,
    String? description,
  }) =>
      HomebrewRace(
        id: id ?? this.id,
        name: name ?? this.name,
        speed: speed ?? this.speed,
        abilityBonuses: abilityBonuses ?? Map<String, int>.from(this.abilityBonuses),
        description: description ?? this.description,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'speed': speed,
        'abilityBonuses': abilityBonuses,
        'description': description,
      };

  factory HomebrewRace.fromJson(Map<String, dynamic> json) => HomebrewRace(
        id: json['id'] as String,
        name: json['name'] as String,
        speed: (json['speed'] as num?)?.toInt() ?? 30,
        abilityBonuses:
            (json['abilityBonuses'] as Map?)?.cast<String, int>() ?? {},
        description: json['description'] as String? ?? '',
      );
}
