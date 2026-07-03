import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  factory CharacterRepository.seeded({
    List<Character>? readyMadeCharacters,
  }) {
    return CharacterRepository._(ownedCharacters: <Character>[], readyMadeCharacters: readyMadeCharacters ?? <Character>[]);
  }

  static Future<CharacterRepository> bootstrap() async {
    final repository = CharacterRepository.seeded(
      readyMadeCharacters: await _loadReadyMadeCharacters(),
    );
    repository._prefs = await SharedPreferences.getInstance();
    repository._loadOwnedCharacters();
    return repository;
  }

  static Future<List<Character>> _loadReadyMadeCharacters() async {
    const assetPaths = <String>[
      'assets/characters/torin.json',
      'assets/characters/liael.json',
      'assets/characters/mila.json',
    ];

    final characters = <Character>[];
    for (final assetPath in assetPaths) {
      try {
        final rawJson = await rootBundle.loadString(assetPath);
        characters.add(
          Character.fromJson(
            Map<String, Object?>.from(jsonDecode(rawJson) as Map),
          ),
        );
      } on Object {
        continue;
      }
    }

    return characters;
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

  Character addToOwned(Character character) {
    final added = character.copyWith(id: _nextId(character.id));
    _ownedCharacters.insert(0, added);
    notifyListeners();
    unawaited(_persistOwnedCharacters());
    return added;
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
