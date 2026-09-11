import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelyn/presentation/journey/trip_places_input_screen.dart';
import 'package:travelyn/presentation/journey/widgets/trip_done_button.dart';

void main() {
  testWidgets('TripPlacesInputScreen renders correctly and displays member links',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    TripPlacesResult? completedResult;

    await tester.pumpWidget(
      MaterialApp(
        home: TripPlacesInputScreen(
          destination: 'Tokyo, Japan',
          selectedVibes: const ['Foodie', 'Culture', 'Photo Spots'],
          onComplete: (result) {
            completedResult = result;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Header & Subtitle
    expect(find.text('Anything you wanna go?'), findsOneWidget);
    expect(
      find.text('Send me places, RedNote, IG Reel, or just tell me!'),
      findsOneWidget,
    );

    // 2. Verify Input field exists
    expect(find.byType(TextField), findsOneWidget);

    // 3. Verify Links from group members section
    expect(find.text('Links from group members'), findsOneWidget);
    expect(find.text('3'), findsOneWidget); // Initial 3 links
    expect(find.textContaining('Sarah'), findsOneWidget);
    expect(find.textContaining('Kenji'), findsOneWidget);
    expect(find.textContaining('Elena'), findsOneWidget);
    expect(find.text('3 locations detected'), findsWidgets);

    // 4. Verify CTA button has exact label "Ready!", shows readiness count "3/4", and does NOT show spots count
    expect(find.byType(TripDoneButton), findsOneWidget);
    expect(find.text("Ready!"), findsOneWidget);
    expect(find.textContaining('3/4'), findsOneWidget);
    expect(find.textContaining('spots'), findsNothing);
    expect(find.text("Skip for now, I'll add later"), findsNothing);
    await tester.tap(find.byType(TripDoneButton));
    await tester.pumpAndSettle();

    expect(completedResult, isNotNull);
    expect(completedResult!.selectedVibes, contains('Foodie'));
    expect(completedResult!.sharedLinks.length, 3);
    expect(completedResult!.places.isNotEmpty, isTrue);
  });

  testWidgets(
      'Pasting or typing in input bar adds a link to group members as You, and allows removing it',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    TripPlacesResult? completedResult;

    await tester.pumpWidget(
      MaterialApp(
        home: TripPlacesInputScreen(
          destination: 'Tokyo, Japan',
          selectedVibes: const ['Foodie'],
          onComplete: (result) {
            completedResult = result;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial count is 3
    expect(find.text('3'), findsOneWidget);

    // Enter a place name into the input bar
    final inputFinder = find.byType(TextField);
    await tester.enterText(inputFinder, 'Meiji Jingu Shrine');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Verify count increased to 4
    expect(find.text('4'), findsOneWidget);

    // Verify card for 'You' is displayed
    expect(find.text('You'), findsOneWidget);
    expect(find.text('Meiji Jingu Shrine'), findsWidgets);
    expect(find.text('1 location detected'), findsOneWidget);

    // Test removing the added link via the close icon
    final closeIcon = find.byIcon(Icons.close_rounded);
    expect(closeIcon, findsOneWidget);
    await tester.tap(closeIcon);
    await tester.pumpAndSettle();

    // Verify count went back to 3
    expect(find.text('3'), findsOneWidget);
    expect(find.text('You'), findsNothing);

    // Add another link using the add button
    await tester.enterText(inputFinder, 'https://instagram.com/reel/example');
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(find.text('4'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);

    // Tap CTA button
    await tester.tap(find.byType(TripDoneButton));
    await tester.pumpAndSettle();

    expect(completedResult, isNotNull);
    expect(completedResult!.sharedLinks.length, 4);
    expect(completedResult!.sharedLinks.first.memberName, 'You');
  });

  testWidgets('TripPlacesInputScreen does not show skip button and completes on I\'m Done!',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    TripPlacesResult? completedResult;

    await tester.pumpWidget(
      MaterialApp(
        home: TripPlacesInputScreen(
          destination: 'Tokyo, Japan',
          selectedVibes: const ['Chill'],
          onComplete: (result) {
            completedResult = result;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify skip button is not present
    expect(find.text("Skip for now, I'll add later"), findsNothing);

    // Tap "I'm Done!" button
    await tester.tap(find.byType(TripDoneButton));
    await tester.pumpAndSettle();

    expect(completedResult, isNotNull);
    expect(completedResult!.selectedVibes, contains('Chill'));
  });
}
