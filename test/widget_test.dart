import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dndeditor/main.dart';

void main() {
  testWidgets('shows the library screen with starter actions', (WidgetTester tester) async {
    await tester.pumpWidget(const DndEditorApp());

    expect(find.text('Редактор персонажей D&D'), findsOneWidget);
    expect(find.text('Мои персонажи'), findsOneWidget);
    expect(find.text('Готовые персонажи'), findsOneWidget);
    expect(find.text('Создать персонажа'), findsOneWidget);
    expect(find.text('Открыть карточку персонажа'), findsOneWidget);

    await tester.tap(find.text('Создать персонажа'));
    await tester.pumpAndSettle();

    expect(find.text('Мастер создания'), findsOneWidget);
  });
}
