// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:luffalense/main.dart';

void main() {
  testWidgets('Home Page has a title and a get started button', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the Home Page has the correct widgets.
    expect(find.byType(Image), findsNWidgets(2)); // Background and Logo
    expect(find.text('Get Started'), findsOneWidget);
  });
}
