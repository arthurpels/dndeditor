/// Six core D&D 5e (2014) ability scores.
enum Ability {
  strength('STR', 'Сила'),
  dexterity('DEX', 'Ловкость'),
  constitution('CON', 'Телосложение'),
  intelligence('INT', 'Интеллект'),
  wisdom('WIS', 'Мудрость'),
  charisma('CHA', 'Харизма');

  const Ability(this.abbr, this.label);

  final String abbr;
  final String label;

  /// JSON key: "str", "dex", "con", "int", "wis", "cha".
  String get code => name.substring(0, 3);

  static Ability fromCode(String code) =>
      Ability.values.firstWhere((a) => a.code == code);
}
