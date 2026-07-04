import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/character.dart';

/// Persistence boundary for owned characters.
///
/// The repository talks to this interface only, never to a concrete storage
/// mechanism. To add server sync later, provide another implementation
/// (e.g. `RemoteCharacterStore`) or wrap this one in a syncing decorator —
/// no repository or UI code has to change.
abstract interface class CharacterStore {
  Future<List<Character>> loadOwned();
  Future<void> saveOwned(List<Character> characters);
}

/// Default implementation backed by [SharedPreferences] (local device only).
class LocalCharacterStore implements CharacterStore {
  LocalCharacterStore({this.storageKey = 'owned_characters_v1'});

  final String storageKey;
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<List<Character>> loadOwned() async {
    try {
      final prefs = await _instance;
      final raw = prefs.getString(storageKey);
      if (raw == null || raw.isEmpty) return const [];

      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      return decoded
          .map((e) => Character.fromJson(Map<String, Object?>.from(e as Map)))
          .toList();
    } catch (error, stackTrace) {
      debugPrint('LocalCharacterStore.loadOwned failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return const [];
    }
  }

  @override
  Future<void> saveOwned(List<Character> characters) async {
    try {
      final prefs = await _instance;
      await prefs.setString(
        storageKey,
        jsonEncode(characters.map((c) => c.toJson()).toList()),
      );
    } catch (error, stackTrace) {
      debugPrint('LocalCharacterStore.saveOwned failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}

/// Volatile store useful for tests and for previewing a swapped data source
/// without touching device storage.
class InMemoryCharacterStore implements CharacterStore {
  InMemoryCharacterStore([List<Character>? seed])
      : _data = List<Character>.from(seed ?? const []);

  List<Character> _data;

  @override
  Future<List<Character>> loadOwned() async => List<Character>.from(_data);

  @override
  Future<void> saveOwned(List<Character> characters) async {
    _data = List<Character>.from(characters);
  }
}
