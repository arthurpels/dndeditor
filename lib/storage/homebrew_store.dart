import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../homebrew/models/homebrew_class.dart';
import '../homebrew/models/homebrew_race.dart';

/// Persistence boundary for homebrew content, mirroring CharacterStore so both
/// repositories isolate storage behind an interface and can share a future
/// backend swap.
abstract interface class HomebrewStore {
  Future<List<HomebrewRace>> loadRaces();
  Future<void> saveRaces(List<HomebrewRace> races);
  Future<List<HomebrewClass>> loadClasses();
  Future<void> saveClasses(List<HomebrewClass> classes);
}

/// Default implementation backed by [SharedPreferences].
class LocalHomebrewStore implements HomebrewStore {
  LocalHomebrewStore({
    this.racesKey = 'homebrew_races_v1',
    this.classesKey = 'homebrew_classes_v1',
  });

  final String racesKey;
  final String classesKey;
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<List<HomebrewRace>> loadRaces() async {
    final raw = await _read(racesKey);
    return _decode(raw, HomebrewRace.fromJson);
  }

  @override
  Future<void> saveRaces(List<HomebrewRace> races) =>
      _write(racesKey, races.map((r) => r.toJson()).toList());

  @override
  Future<List<HomebrewClass>> loadClasses() async {
    final raw = await _read(classesKey);
    return _decode(raw, HomebrewClass.fromJson);
  }

  @override
  Future<void> saveClasses(List<HomebrewClass> classes) =>
      _write(classesKey, classes.map((c) => c.toJson()).toList());

  Future<String?> _read(String key) async {
    try {
      final prefs = await _instance;
      return prefs.getString(key);
    } catch (error, stackTrace) {
      debugPrint('LocalHomebrewStore read failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> _write(String key, List<Map<String, dynamic>> data) async {
    try {
      final prefs = await _instance;
      await prefs.setString(key, jsonEncode(data));
    } catch (error, stackTrace) {
      debugPrint('LocalHomebrewStore write failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  static List<T> _decode<T>(
    String? raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }
}

/// Volatile store for tests and swapped-source previews.
class InMemoryHomebrewStore implements HomebrewStore {
  InMemoryHomebrewStore({
    List<HomebrewRace>? races,
    List<HomebrewClass>? classes,
  })  : _races = List<HomebrewRace>.from(races ?? const []),
        _classes = List<HomebrewClass>.from(classes ?? const []);

  List<HomebrewRace> _races;
  List<HomebrewClass> _classes;

  @override
  Future<List<HomebrewRace>> loadRaces() async =>
      List<HomebrewRace>.from(_races);

  @override
  Future<void> saveRaces(List<HomebrewRace> races) async =>
      _races = List<HomebrewRace>.from(races);

  @override
  Future<List<HomebrewClass>> loadClasses() async =>
      List<HomebrewClass>.from(_classes);

  @override
  Future<void> saveClasses(List<HomebrewClass> classes) async =>
      _classes = List<HomebrewClass>.from(classes);
}
