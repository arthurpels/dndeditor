/// Local, template-based biography generator (Dev C — no external services).
///
/// Pure domain logic: takes simple display strings (already resolved from
/// whichever race/class/background representation the caller uses — the
/// wizard's mock contract or the real `GameData`) and returns a short
/// biography paragraph. Deterministic by design so generated text is always
/// coherent and testable, never random filler.
library;

enum BiographyTone { neutral, heroic, grim, adventurous }

extension BiographyToneLabels on BiographyTone {
  String get labelRu => switch (this) {
        BiographyTone.neutral => 'Нейтральный',
        BiographyTone.heroic => 'Героический',
        BiographyTone.grim => 'Мрачный',
        BiographyTone.adventurous => 'Авантюрный',
      };
}

/// Resolved display data needed to generate a biography. Deliberately made of
/// plain strings/ints so it doesn't depend on the wizard's mock contract or
/// the real `Race`/`CharClass` models — either can build one.
class BiographyInput {
  const BiographyInput({
    required this.characterName,
    required this.raceName,
    required this.className,
    required this.backgroundName,
    required this.skillNames,
    required this.keyAbilityLabel,
    required this.keyAbilityScore,
  });

  final String characterName;
  final String raceName;
  final String className;
  final String backgroundName;
  final List<String> skillNames;
  final String keyAbilityLabel;
  final int keyAbilityScore;
}

class BiographyGenerator {
  const BiographyGenerator._();

  static String generate(BiographyInput input, BiographyTone tone) {
    final name = input.characterName.trim().isEmpty
        ? 'Герой'
        : input.characterName.trim();
    final race = input.raceName.trim().isEmpty ? 'существо' : input.raceName.trim();
    final cls = input.className.trim().isEmpty ? 'авантюрист' : input.className.trim();
    final background =
        input.backgroundName.trim().isEmpty ? 'неизвестное прошлое' : input.backgroundName.trim();
    final skillsPhrase = _skillsPhrase(input.skillNames);
    final ability = input.keyAbilityLabel.trim().isEmpty ? 'внутренняя сила' : input.keyAbilityLabel.trim();

    return switch (tone) {
      BiographyTone.neutral => _neutral(name, race, cls, background, skillsPhrase, ability, input.keyAbilityScore),
      BiographyTone.heroic => _heroic(name, race, cls, background, skillsPhrase, ability),
      BiographyTone.grim => _grim(name, race, cls, background, skillsPhrase, ability),
      BiographyTone.adventurous => _adventurous(name, race, cls, background, skillsPhrase, ability),
    };
  }

  static String _skillsPhrase(List<String> skillNames) {
    final names = skillNames.where((s) => s.trim().isNotEmpty).take(3).toList();
    if (names.isEmpty) {
      return 'разносторонних, ещё не до конца раскрытых умениях';
    }
    return names.join(', ');
  }

  static String _neutral(
    String name,
    String race,
    String cls,
    String background,
    String skillsPhrase,
    String ability,
    int abilityScore,
  ) {
    return '$name — $race $cls с прошлым «$background». '
        'Ключевая черта персонажа — $ability ($abilityScore), которая находит применение в $skillsPhrase. '
        'История только начинается, и каждый день добавляет ей новую главу.';
  }

  static String _heroic(
    String name,
    String race,
    String cls,
    String background,
    String skillsPhrase,
    String ability,
  ) {
    return 'Мало кто помнит $name обычным(ой) $race-$cls — путь через испытания, '
        'связанные с «$background», превратил эту историю в легенду. '
        'Сила в $ability и мастерство в $skillsPhrase не раз спасали союзников на грани поражения. '
        'Слава о $name растёт с каждым подвигом.';
  }

  static String _grim(
    String name,
    String race,
    String cls,
    String background,
    String skillsPhrase,
    String ability,
  ) {
    return '$name, $race $cls, несёт на себе больше шрамов из прошлого «$background», '
        'чем историй для баек у костра. '
        'Выживание чаще держится на $ability, чем на удаче, а владение $skillsPhrase '
        'не раз оказывалось единственной разницей между жизнью и смертью. '
        'Признание не нужно — только ещё один прожитый день.';
  }

  static String _adventurous(
    String name,
    String race,
    String cls,
    String background,
    String skillsPhrase,
    String ability,
  ) {
    return 'Скучать рядом с $name не приходится: $race $cls с прошлым «$background» '
        'и вечной тягой сорваться за горизонт при первом же слухе о сокровищах. '
        '$ability и уверенное владение $skillsPhrase не раз выручали в передрягах, '
        'в которые $name обычно попадает по собственной воле. '
        'Следующее приключение уже не за горами.';
  }
}
