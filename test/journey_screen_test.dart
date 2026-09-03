import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelyn/presentation/journey/journey_screen.dart';

void main() {
  testWidgets('JourneyScreen renders header, empty state texts and Create Trip button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: JourneyScreen(),
      ),
    );

    // Initial pump for animation
    await tester.pumpAndSettle();

    // Verify header
    expect(find.text('Journey'), findsOneWidget);
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);

    // Verify empty state messages
    expect(find.text('You have no trips yet!'), findsOneWidget);
    expect(find.text('Every adventure starts\nwith a single step.'), findsOneWidget);

    // Verify CTA button
    expect(find.text('Create Trip'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);

    // Tap create trip button to navigate to CreateTripScreen
    await tester.tap(find.text('Create Trip'));
    await tester.pumpAndSettle();

    // CreateTripScreen should be visible
    expect(find.text('Where to next?'), findsOneWidget);
    expect(find.text("Let's plan your adventure"), findsOneWidget);
  });
}
