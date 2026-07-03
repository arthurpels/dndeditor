import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/character.dart';

class CharacterRepositoryScope extends InheritedNotifier<CharacterRepository> {
  const CharacterRepositoryScope({
    super.key,
    required CharacterRepository repository,
    required super.child,
  }) : super(notifier: repository);

  static CharacterRepository of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<CharacterRepositoryScope>();
    assert(scope != null, 'CharacterRepositoryScope is missing above context');
    return scope!.notifier!;
  }
}

class CharacterRepository extends ChangeNotifier {
  CharacterRepository._({
    required List<Character> ownedCharacters,
    required List<Character> readyMadeCharacters,
  })  : _ownedCharacters = ownedCharacters,
        _readyMadeCharacters = readyMadeCharacters;

  static const String _storageKey = 'owned_characters_v1';

  factory CharacterRepository.seeded() {
    return CharacterRepository._(
      ownedCharacters: <Character>[],
      readyMadeCharacters: <Character>[
        const Character(
          id: 'ready-torin',
          name: 'Торин',
          race: 'Dwarf',
          characterClass: 'Fighter',
          level: 1,
          hitPoints: 12,
          maxHitPoints: 12,
          notes: 'Боевой ветеран из горного клана.',
        ),
        const Character(
          id: 'ready-liael',
          name: 'Лиэль',
          race: 'Elf',
          characterClass: 'Wizard',
          level: 1,
          hitPoints: 8,
          maxHitPoints: 8,
          notes: 'Исследует древние формулы и руины.',
        ),
        const Character(
          id: 'ready-mila',
          name: 'Мила',
          race: 'Halfling',
          characterClass: 'Rogue',
          level: 1,
          hitPoints: 9,
          maxHitPoints: 9,
          notes: 'Тихая, быстрая, очень внимательная к деталям.',
        ),
      ],
    );
  }

  static Future<CharacterRepository> bootstrap() async {
    final repository = CharacterRepository.seeded();
    repository._prefs = await SharedPreferences.getInstance();
    repository._loadOwnedCharacters();
    return repository;
  }

  final List<Character> _ownedCharacters;
  final List<Character> _readyMadeCharacters;
  SharedPreferences? _prefs;
  int _sequence = 0;

  UnmodifiableListView<Character> get ownedCharacters =>
      UnmodifiableListView(_ownedCharacters);

  UnmodifiableListView<Character> get readyMadeCharacters =>
      UnmodifiableListView(_readyMadeCharacters);

  String exportOwnedJson() {
    return const JsonEncoder.withIndent('  ').convert(
      _ownedCharacters.map((character) => character.toJson()).toList(),
    );
  }

  Future<void> importOwnedJson(String source) async {
    final decoded = jsonDecode(source);
    final List<dynamic> rawCharacters;
    if (decoded is List<dynamic>) {
      rawCharacters = decoded;
    } else if (decoded is Map<String, dynamic>) {
      rawCharacters = <dynamic>[decoded];
    } else {
      throw const FormatException('Unsupported character export format');
    }

    _ownedCharacters
      ..clear()
      ..addAll(
        rawCharacters.map(
          (entry) => Character.fromJson(
            Map<String, Object?>.from(entry as Map),
          ),
        ),
      );

    notifyListeners();
    await _persistOwnedCharacters();
  }

  Character createDraftCharacter() {
    final draft = Character.blank(id: _nextId('draft'));
    _ownedCharacters.insert(0, draft);
    notifyListeners();
    unawaited(_persistOwnedCharacters());
    return draft;
  }

  void addToOwned(Character character) {
    _ownedCharacters.insert(0, character.copyWith(id: _nextId(character.id)));
    notifyListeners();
    unawaited(_persistOwnedCharacters());
  }

  void duplicateOwned(String id) {
    final source = _ownedCharacters.firstWhere((item) => item.id == id);
    addToOwned(
      source.copyWith(
        id: _nextId(source.id),
        name: '${source.name} (копия)',
      ),
    );
  }

  void removeOwned(String id) {
    _ownedCharacters.removeWhere((item) => item.id == id);
    notifyListeners();
    unawaited(_persistOwnedCharacters());
  }

  Character? ownedById(String id) {
    for (final character in _ownedCharacters) {
      if (character.id == id) {
        return character;
      }
    }
    return null;
  }

  void _loadOwnedCharacters() {
    final rawJson = _prefs?.getString(_storageKey);
    if (rawJson == null || rawJson.isEmpty) {
      return;
    }

    final decoded = jsonDecode(rawJson);
    if (decoded is! List<dynamic>) {
      return;
    }

    _ownedCharacters
      ..clear()
      ..addAll(
        decoded.map(
          (entry) => Character.fromJson(
            Map<String, Object?>.from(entry as Map),
          ),
        ),
      );
  }

  Future<void> _persistOwnedCharacters() async {
    final prefs = _prefs;
    if (prefs == null) {
      return;
    }

    await prefs.setString(
      _storageKey,
      jsonEncode(_ownedCharacters.map((character) => character.toJson()).toList()),
    );
  }

  String _nextId(String prefix) {
    _sequence += 1;
    return '$prefix-${_sequence.toString().padLeft(3, '0')}';
  }
}
