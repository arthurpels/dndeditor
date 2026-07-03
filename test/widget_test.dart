import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dndeditor/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('shows the home library screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DndEditorApp());
    await tester.pumpAndSettle();

    expect(find.text('DND Editor'), findsOneWidget);
    expect(find.text('Библиотека персонажей'), findsOneWidget);
    expect(find.text('Мои персонажи'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
