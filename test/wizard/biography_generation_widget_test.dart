import 'package:dndeditor/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// End-to-end widget test driving the real app UI (not just the generator
/// function) through the wizard up to Review, generating a biography, and
/// checking the visible text field actually updates and stays editable.
Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('generating a biography on the Review step fills the visible field', (tester) async {
    await tester.pumpWidget(const DndEditorApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Basics: name + race + class + background.
    await tester.enterText(find.byType(TextFormField).first, 'Торин');
    await _tapVisible(tester, find.text('Человек'));
    await _tapVisible(tester, find.text('Воин'));
    await _tapVisible(tester, find.text('Солдат'));
    await _tapVisible(tester, find.text('Далее'));
    await tester.pumpAndSettle();

    // Abilities: Point Buy auto-satisfies validation (all 8s), skip straight through.
    await _tapVisible(tester, find.text('Point Buy'));
    await _tapVisible(tester, find.text('Далее'));
    await tester.pumpAndSettle();

    // Skills: fighter allows 2 choices beyond the soldier background skills.
    await _tapVisible(tester, find.text('История (INT)'));
    await _tapVisible(tester, find.text('Проницательность (WIS)'));
    await _tapVisible(tester, find.text('Далее'));
    await tester.pumpAndSettle();

    // Review: pick a tone and generate.
    expect(find.text('Обзор персонажа'), findsOneWidget);
    await _tapVisible(tester, find.text('Героический'));
    await _tapVisible(tester, find.text('Сгенерировать биографию'));
    await tester.pump();

    final textField = tester.widget<TextField>(find.byType(TextField));
    final generated = textField.controller!.text;

    expect(generated, isNotEmpty);
    expect(generated, contains('Торин'));

    // Still editable: user can append their own text.
    await tester.enterText(find.byType(TextField), '$generated Дополнено вручную.');
    await tester.pump();
    final edited = tester.widget<TextField>(find.byType(TextField)).controller!.text;
    expect(edited, endsWith('Дополнено вручную.'));
  });
}
