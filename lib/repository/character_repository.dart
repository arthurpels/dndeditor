import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/ability.dart';
import '../models/character.dart';
import '../storage/character_store.dart';

class CharacterRepositoryScope extends InheritedNotifier<CharacterRepository> {
  const CharacterRepositoryScope({
    super.key,
    required CharacterRepository repository,
    required super.child,
  }) : super(notifier: repository);

  static CharacterRepository of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<CharacterRepositoryScope>();
    assert(scope != null, 'CharacterRepositoryScope is missing above context');
    return scope!.notifier!;
  }
}

/// In-memory source of truth for characters. Holds the owned/ready-made lists,
/// notifies listeners on change, and delegates all persistence to a
/// [CharacterStore]. It knows nothing about *where* data is stored, which is
/// what keeps a future backend swap isolated to the store layer.
class CharacterRepository extends ChangeNotifier {
  CharacterRepository._({
    required List<Character> ownedCharacters,
    required List<Character> readyMadeCharacters,
    required CharacterStore store,
  })  : _ownedCharacters = ownedCharacters,
        _readyMadeCharacters = readyMadeCharacters,
        _store = store;

  factory CharacterRepository.seeded({
    List<Character>? readyMadeCharacters,
    CharacterStore? store,
  }) {
    return CharacterRepository._(
      ownedCharacters: <Character>[],
      readyMadeCharacters: readyMadeCharacters ?? _defaultReadyMadeCharacters(),
      store: store ?? LocalCharacterStore(),
    );
  }

  final List<Character> _ownedCharacters;
  final List<Character> _readyMadeCharacters;
  final CharacterStore _store;
  int _sequence = 0;

  /// Load persisted owned characters from the store into memory.
  Future<void> loadPersistedState() async {
    final loaded = await _store.loadOwned();
    _ownedCharacters
      ..clear()
      ..addAll(loaded);
    notifyListeners();
  }

  UnmodifiableListView<Character> get ownedCharacters =>
      UnmodifiableListView(_ownedCharacters);

  UnmodifiableListView<Character> get readyMadeCharacters =>
      UnmodifiableListView(_readyMadeCharacters);

  String exportOwnedJson() {
    return const JsonEncoder.withIndent(
      '  ',
    ).convert(_ownedCharacters.map((character) => character.toJson()).toList());
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
          (entry) =>
              Character.fromJson(Map<String, Object?>.from(entry as Map)),
        ),
      );

    notifyListeners();
    await _store.saveOwned(_ownedCharacters);
  }

  Character createDraftCharacter() {
    final draft = Character.blank(id: _nextId('draft'));
    _ownedCharacters.insert(0, draft);
    notifyListeners();
    _persist();
    return draft;
  }

  Character addToOwned(Character character) {
    final added = character.copyWith(id: _nextId(character.id));
    _ownedCharacters.insert(0, added);
    notifyListeners();
    _persist();
    return added;
  }

  void duplicateOwned(String id) {
    final source = _ownedCharacters.firstWhere((item) => item.id == id);
    addToOwned(
      source.copyWith(id: _nextId(source.id), name: '${source.name} (копия)'),
    );
  }

  void removeOwned(String id) {
    _ownedCharacters.removeWhere((item) => item.id == id);
    notifyListeners();
    _persist();
  }

  Character? ownedById(String id) {
    for (final character in _ownedCharacters) {
      if (character.id == id) {
        return character;
      }
    }
    return null;
  }

  /// Update an owned character in-place and persist the change.
  void updateOwned(Character updated) {
    final index = _ownedCharacters.indexWhere((c) => c.id == updated.id);
    if (index < 0) return;
    _ownedCharacters[index] = updated;
    notifyListeners();
    _persist();
  }

  void _persist() => unawaited(_store.saveOwned(_ownedCharacters));

  String _nextId(String prefix) {
    _sequence += 1;
    return '$prefix-${_sequence.toString().padLeft(3, '0')}';
  }

  static List<Character> _defaultReadyMadeCharacters() {
    final defaultAbilities = {for (final a in Ability.values) a: 10};
    return <Character>[
      Character(
        id: 'ready-torin',
        name: 'Торин',
        raceId: 'dwarf',
        classId: 'fighter',
        level: 1,
        baseAbilities: defaultAbilities,
        maxHp: 12,
        currentHp: 12,
        biography: 'Боевой ветеран из горного клана.',
      ),
      Character(
        id: 'ready-liael',
        name: 'Лиэль',
        raceId: 'elf',
        classId: 'wizard',
        level: 1,
        baseAbilities: defaultAbilities,
        maxHp: 8,
        currentHp: 8,
        biography: 'Исследует древние формулы и руины.',
      ),
      Character(
        id: 'ready-mila',
        name: 'Мила',
        raceId: 'halfling',
        classId: 'rogue',
        level: 1,
        baseAbilities: defaultAbilities,
        maxHp: 9,
        currentHp: 9,
        biography: 'Тихая, быстрая, очень внимательная к деталям.',
      ),
    ];
  }
}
