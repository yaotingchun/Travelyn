import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelyn/presentation/journey/trip_places_input_screen.dart';
import 'package:travelyn/presentation/journey/trip_planning_screen.dart';

void main() {
  testWidgets('TripPlanningScreen renders mascot background, checklist, and bottom note',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    bool finishedCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: TripPlanningScreen(
          destination: 'Tokyo, Japan',
          autoProgress: false,
          placesResult: const TripPlacesResult(
            selectedVibes: ['Culture', 'Foodie'],
          ),
          onFinished: () {
            finishedCalled = true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify "Let me work my magic..." header
    expect(find.text('Let me work my magic...'), findsOneWidget);

    // 2. Verify Checklist steps
    expect(find.text("Reading everyone's preferences"), findsOneWidget);
    expect(find.text('Analyzing the places you sent'), findsOneWidget);
    expect(find.text('Mapping the best routes'), findsOneWidget);
    expect(find.text('Finding hidden gems'), findsOneWidget);
    expect(find.text('Crafting your Tokyo adventure...'), findsOneWidget);

    // 3. Verify Bottom Note is removed
    expect(find.text('Almost there!'), findsNothing);
    expect(find.text('This will be worth the wait'), findsNothing);

    expect(finishedCalled, isFalse);
  });

  testWidgets('TripPlanningScreen completes step progression and calls onFinished',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    bool finishedCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: TripPlanningScreen(
          destination: 'Tokyo, Japan',
          autoProgress: true,
          stepDuration: const Duration(milliseconds: 50),
          onFinished: () {
            finishedCalled = true;
          },
        ),
      ),
    );
    await tester.pump();

    // Advance past step duration and celebration delay
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(finishedCalled, isTrue);
  });
}
