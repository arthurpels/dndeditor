import 'backgrounds.dart';
import 'classes.dart';
import 'races.dart';

export 'backgrounds.dart';
export 'classes.dart';
export 'races.dart';

/// Central registry for static game data — look up by id.
class GameData {
  const GameData._();

  static List<Race> get races => kRaces;
  static List<CharClass> get classes => kClasses;
  static List<Background> get backgrounds => kBackgrounds;

  static Race? raceById(String? id) =>
      id == null ? null : kRaces.where((r) => r.id == id).firstOrNull;

  static CharClass? classById(String? id) =>
      id == null ? null : kClasses.where((c) => c.id == id).firstOrNull;

  static Background? backgroundById(String? id) =>
      id == null ? null : kBackgrounds.where((b) => b.id == id).firstOrNull;
}
