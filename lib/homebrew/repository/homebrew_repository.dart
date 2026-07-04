import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/homebrew_class.dart';
import '../models/homebrew_race.dart';

class HomebrewRepositoryScope
    extends InheritedNotifier<HomebrewRepository> {
  const HomebrewRepositoryScope({
    super.key,
    required HomebrewRepository repository,
    required super.child,
  }) : super(notifier: repository);

  static HomebrewRepository of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<HomebrewRepositoryScope>();
    assert(scope != null, 'HomebrewRepositoryScope is missing above context');
    return scope!.notifier!;
  }
}

class HomebrewRepository extends ChangeNotifier {
  HomebrewRepository._({
    required List<HomebrewRace> races,
    required List<HomebrewClass> classes,
  })  : _races = races,
        _classes = classes;

  static const _racesKey = 'homebrew_races_v1';
  static const _classesKey = 'homebrew_classes_v1';

  final List<HomebrewRace> _races;
  final List<HomebrewClass> _classes;
  SharedPreferences? _prefs;

  static Future<HomebrewRepository> bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final repo = HomebrewRepository._(
        races: _decodeRaces(prefs.getString(_racesKey)),
        classes: _decodeClasses(prefs.getString(_classesKey)),
      );
      repo._prefs = prefs;
      return repo;
    } catch (_) {
      return HomebrewRepository._(races: [], classes: []);
    }
  }

  UnmodifiableListView<HomebrewRace> get races =>
      UnmodifiableListView(_races);

  UnmodifiableListView<HomebrewClass> get classes =>
      UnmodifiableListView(_classes);

  // --- Races ---

  void addRace(HomebrewRace race) {
    _races.add(race);
    notifyListeners();
    _persistRaces();
  }

  void updateRace(HomebrewRace updated) {
    final i = _races.indexWhere((r) => r.id == updated.id);
    if (i < 0) return;
    _races[i] = updated;
    notifyListeners();
    _persistRaces();
  }

  void removeRace(String id) {
    _races.removeWhere((r) => r.id == id);
    notifyListeners();
    _persistRaces();
  }

  // --- Classes ---

  void addClass(HomebrewClass cls) {
    _classes.add(cls);
    notifyListeners();
    _persistClasses();
  }

  void updateClass(HomebrewClass updated) {
    final i = _classes.indexWhere((c) => c.id == updated.id);
    if (i < 0) return;
    _classes[i] = updated;
    notifyListeners();
    _persistClasses();
  }

  void removeClass(String id) {
    _classes.removeWhere((c) => c.id == id);
    notifyListeners();
    _persistClasses();
  }

  // --- Persistence ---

  void _persistRaces() {
    _prefs?.setString(
      _racesKey,
      jsonEncode(_races.map((r) => r.toJson()).toList()),
    );
  }

  void _persistClasses() {
    _prefs?.setString(
      _classesKey,
      jsonEncode(_classes.map((c) => c.toJson()).toList()),
    );
  }

  static List<HomebrewRace> _decodeRaces(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => HomebrewRace.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static List<HomebrewClass> _decodeClasses(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) =>
              HomebrewClass.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
