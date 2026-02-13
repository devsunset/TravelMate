// Basic Flutter widget test.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('TripMate')),
        ),
      ),
    );
    expect(find.text('TripMate'), findsOneWidget);
  });
}
