import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import '../../storage/homebrew_store.dart';
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

/// In-memory source of truth for homebrew races and classes. Delegates all
/// persistence to a [HomebrewStore], mirroring CharacterRepository.
class HomebrewRepository extends ChangeNotifier {
  HomebrewRepository._({
    required List<HomebrewRace> races,
    required List<HomebrewClass> classes,
    required HomebrewStore store,
  })  : _races = races,
        _classes = classes,
        _store = store;

  factory HomebrewRepository.seeded({HomebrewStore? store}) =>
      HomebrewRepository._(
        races: [],
        classes: [],
        store: store ?? LocalHomebrewStore(),
      );

  final List<HomebrewRace> _races;
  final List<HomebrewClass> _classes;
  final HomebrewStore _store;

  Future<void> loadPersistedState() async {
    final results = await Future.wait([
      _store.loadRaces(),
      _store.loadClasses(),
    ]);
    _races
      ..clear()
      ..addAll(results[0] as List<HomebrewRace>);
    _classes
      ..clear()
      ..addAll(results[1] as List<HomebrewClass>);
    notifyListeners();
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

  void _persistRaces() => unawaited(_store.saveRaces(_races));
  void _persistClasses() => unawaited(_store.saveClasses(_classes));
}
