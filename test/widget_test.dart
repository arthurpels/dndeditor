import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dndeditor/main.dart';

void main() {
  testWidgets('shows the home library screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DndEditorApp());

    expect(find.text('DND Editor'), findsOneWidget);
    expect(find.text('Библиотека персонажей'), findsOneWidget);
    expect(find.text('Мои персонажи'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
