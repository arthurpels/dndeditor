import '../models/character.dart';

/// Contract for a future server backend. Intentionally has **no
/// implementation** in this phase — it only fixes the shape of the sync
/// boundary so the local-only app can grow into a synced one without
/// reshaping the repository or UI.
///
/// Expected wiring once a server exists:
///   RemoteCharacterSyncApi implements CharacterSyncApi
///     → SyncingCharacterStore(local: LocalCharacterStore(), api: ...)
///       implements CharacterStore
///         → injected into CharacterRepository.seeded(store: ...)
///
/// None of the callers above need to change when that day comes.
abstract interface class CharacterSyncApi {
  /// Fetch the authoritative server copy of the user's characters.
  Future<List<Character>> pull();

  /// Push the local set to the server, returning the reconciled result.
  Future<SyncResult> push(List<Character> local);
}

/// Outcome of a sync round-trip. Kept minimal on purpose.
class SyncResult {
  const SyncResult({
    required this.status,
    required this.characters,
    this.message,
  });

  final SyncStatus status;

  /// Reconciled character set after the sync (server-wins, merge, etc. —
  /// the concrete api decides).
  final List<Character> characters;

  /// Optional human-readable detail (e.g. conflict summary or error text).
  final String? message;

  bool get isSuccess => status == SyncStatus.success;
}

enum SyncStatus { success, conflict, offline, error }
