import 'repository/character_repository.dart';
import 'homebrew/repository/homebrew_repository.dart';

/// Single, explicit startup sequence for the app.
///
/// Steps:
///   1. `AppBootstrap.seeded()` — build repositories with ready-made content
///      synchronously, so the Home screen can render immediately.
///   2. `hydrate()` — load persisted local state (owned characters + homebrew)
///      in the background, then repositories notify their listeners.
///
/// Keeping this in one place means `main`/`app.dart` never reach into storage
/// directly, and a future backend only changes what a repository's store does,
/// not this sequence.
class AppBootstrap {
  const AppBootstrap({
    required this.characters,
    required this.homebrew,
  });

  final CharacterRepository characters;
  final HomebrewRepository homebrew;

  factory AppBootstrap.seeded() => AppBootstrap(
        characters: CharacterRepository.seeded(),
        homebrew: HomebrewRepository.seeded(),
      );

  /// Load all persisted local state. Each repository handles its own errors,
  /// so a failure in one does not block the other.
  Future<void> hydrate() async {
    await Future.wait([
      characters.loadPersistedState(),
      homebrew.loadPersistedState(),
    ]);
  }
}
