import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dndeditor/models/ability.dart';
import 'package:dndeditor/models/character.dart';
import 'package:dndeditor/repository/character_repository.dart';

Character _makeSimple({
  required String id,
  required String name,
  String raceId = 'human',
  String classId = 'fighter',
  int level = 1,
  int hp = 10,
  String biography = '',
}) =>
    Character(
      id: id,
      name: name,
      raceId: raceId,
      classId: classId,
      level: level,
      baseAbilities: {for (final a in Ability.values) a: 10},
      maxHp: hp,
      currentHp: hp,
      biography: biography,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('exports owned characters as valid JSON', () {
    final repository = CharacterRepository.seeded();
    repository.addToOwned(
      _makeSimple(id: 'custom-1', name: 'Aria', raceId: 'human', classId: 'cleric', level: 2, hp: 17),
    );

    final decoded = jsonDecode(repository.exportOwnedJson());

    expect(decoded, isA<List<dynamic>>());
    expect((decoded as List<dynamic>).single, isA<Map<String, dynamic>>());
    expect(decoded.single['name'], 'Aria');
  });

  test('imports owned characters from Dev D simplified JSON format', () async {
    final repository = CharacterRepository.seeded();
    repository.addToOwned(
      _makeSimple(id: 'custom-1', name: 'Old'),
    );

    await repository.importOwnedJson(
      '''
      [
        {
          "id": "imported-1",
          "name": "New",
          "race": "Elf",
          "characterClass": "Wizard",
          "level": 3,
          "hitPoints": 14,
          "maxHitPoints": 14,
          "notes": "Imported"
        }
      ]
      ''',
    );

    expect(repository.ownedCharacters, hasLength(1));
    expect(repository.ownedCharacters.single.name, 'New');
    expect(repository.ownedCharacters.single.notes, 'Imported');
  });

  test('imports owned characters from full JSON format', () async {
    final repository = CharacterRepository.seeded();
    final exported = repository.exportOwnedJson();
    repository.addToOwned(_makeSimple(id: 'tmp', name: 'Tmp'));

    await repository.importOwnedJson(
      jsonEncode([_makeSimple(id: 'full-1', name: 'Full').toJson()]),
    );

    expect(repository.ownedCharacters.single.name, 'Full');
  });

  test('rejects invalid json during import', () async {
    final repository = CharacterRepository.seeded();

    expect(
      () => repository.importOwnedJson('not-json'),
      throwsFormatException,
    );
  });
}
