import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dndeditor/main.dart';

void main() {
  testWidgets('App launches into the character creation wizard', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Основа персонажа'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Имя персонажа'), findsOneWidget);
  });
}
