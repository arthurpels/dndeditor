import 'package:dndeditor/rules/biography_generator.dart';
import 'package:flutter_test/flutter_test.dart';

BiographyInput _input({
  String characterName = 'Торин',
  String raceName = 'Дварф',
  String className = 'Воин',
  String backgroundName = 'Солдат',
  List<String> skillNames = const ['Атлетика', 'Запугивание'],
  String keyAbilityLabel = 'Сила',
  int keyAbilityScore = 16,
}) =>
    BiographyInput(
      characterName: characterName,
      raceName: raceName,
      className: className,
      backgroundName: backgroundName,
      skillNames: skillNames,
      keyAbilityLabel: keyAbilityLabel,
      keyAbilityScore: keyAbilityScore,
    );

void main() {
  group('BiographyGenerator', () {
    for (final tone in BiographyTone.values) {
      test('${tone.name}: produces non-empty text mentioning key facts', () {
        final text = BiographyGenerator.generate(_input(), tone);

        expect(text, isNotEmpty);
        expect(text.length, greaterThan(40));
        expect(text, contains('Торин'));
        expect(text, contains('Дварф'));
        expect(text, contains('Воин'));
        expect(text, contains('Солдат'));
        expect(text, contains('Атлетика'));
      });
    }

    test('is deterministic for the same input and tone', () {
      final a = BiographyGenerator.generate(_input(), BiographyTone.heroic);
      final b = BiographyGenerator.generate(_input(), BiographyTone.heroic);
      expect(a, b);
    });

    test('different tones produce different text for the same input', () {
      final neutral = BiographyGenerator.generate(_input(), BiographyTone.neutral);
      final grim = BiographyGenerator.generate(_input(), BiographyTone.grim);
      expect(neutral, isNot(equals(grim)));
    });

    test('falls back gracefully when skills are empty', () {
      final text = BiographyGenerator.generate(_input(skillNames: const []), BiographyTone.neutral);
      expect(text, isNotEmpty);
      expect(text, isNot(contains('null')));
    });

    test('falls back gracefully when name/race/class/background are blank', () {
      final text = BiographyGenerator.generate(
        _input(characterName: '', raceName: '', className: '', backgroundName: ''),
        BiographyTone.adventurous,
      );
      expect(text, isNotEmpty);
      expect(text, isNot(contains('null')));
    });
  });
}
