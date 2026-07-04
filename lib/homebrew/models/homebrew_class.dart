import 'package:flutter/foundation.dart';

/// Пользовательский класс. Saving throws и навыки хранятся строками
/// (совпадают с именами AbilityScore.name и SkillDef.id в mock_contract).
@immutable
class HomebrewClass {
  const HomebrewClass({
    required this.id,
    required this.name,
    required this.hitDie,
    required this.savingThrows,
    required this.skillChoiceCount,
    required this.availableSkillIds,
    this.description = '',
  });

  final String id;
  final String name;
  final int hitDie;
  final List<String> savingThrows;
  final int skillChoiceCount;
  final List<String> availableSkillIds;
  final String description;

  HomebrewClass copyWith({
    String? id,
    String? name,
    int? hitDie,
    List<String>? savingThrows,
    int? skillChoiceCount,
    List<String>? availableSkillIds,
    String? description,
  }) =>
      HomebrewClass(
        id: id ?? this.id,
        name: name ?? this.name,
        hitDie: hitDie ?? this.hitDie,
        savingThrows: savingThrows ?? List<String>.from(this.savingThrows),
        skillChoiceCount: skillChoiceCount ?? this.skillChoiceCount,
        availableSkillIds:
            availableSkillIds ?? List<String>.from(this.availableSkillIds),
        description: description ?? this.description,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'hitDie': hitDie,
        'savingThrows': savingThrows,
        'skillChoiceCount': skillChoiceCount,
        'availableSkillIds': availableSkillIds,
        'description': description,
      };

  factory HomebrewClass.fromJson(Map<String, dynamic> json) => HomebrewClass(
        id: json['id'] as String,
        name: json['name'] as String,
        hitDie: (json['hitDie'] as num?)?.toInt() ?? 8,
        savingThrows:
            (json['savingThrows'] as List?)?.cast<String>() ?? const [],
        skillChoiceCount: (json['skillChoiceCount'] as num?)?.toInt() ?? 2,
        availableSkillIds:
            (json['availableSkillIds'] as List?)?.cast<String>() ?? const [],
        description: json['description'] as String? ?? '',
      );
}
