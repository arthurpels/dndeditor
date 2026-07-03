import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dndeditor/models/character.dart';
import 'package:dndeditor/repository/character_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('exports owned characters as valid JSON', () {
    final repository = CharacterRepository.seeded();
    repository.addToOwned(
      const Character(
        id: 'custom-1',
        name: 'Aria',
        race: 'Human',
        characterClass: 'Cleric',
        level: 2,
        hitPoints: 17,
        maxHitPoints: 17,
      ),
    );

    final decoded = jsonDecode(repository.exportOwnedJson());

    expect(decoded, isA<List<dynamic>>());
    expect((decoded as List<dynamic>).single, isA<Map<String, dynamic>>());
    expect(decoded.single['name'], 'Aria');
  });

  test('imports owned characters from json and replaces the current list', () async {
    final repository = CharacterRepository.seeded();
    repository.addToOwned(
      const Character(
        id: 'custom-1',
        name: 'Old',
        race: 'Human',
        characterClass: 'Fighter',
        level: 1,
        hitPoints: 10,
        maxHitPoints: 10,
      ),
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

  test('rejects invalid json during import', () async {
    final repository = CharacterRepository.seeded();

    expect(
      () => repository.importOwnedJson('not-json'),
      throwsFormatException,
    );
  });
}
