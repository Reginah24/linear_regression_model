import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutterapp/main.dart';

void main() {
  testWidgets('App loads and shows title', (WidgetTester tester) async {
    await tester.pumpWidget(const AgasekeApp());

    expect(find.text('Agaseke Savings Predictor'), findsOneWidget);
  });
}
