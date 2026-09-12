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

  testWidgets(
      'Tapping a member link card opens TripDetectedLocationsSheet with detected locations list',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: TripPlacesInputScreen(
          destination: 'Tokyo, Japan',
          selectedVibes: ['Foodie'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on Sarah's Tokyo Sunset Spots card
    final cardFinder = find.text('Tokyo Sunset Spots & Aesthetic Rooftops');
    expect(cardFinder, findsOneWidget);
    await tester.tap(cardFinder);
    await tester.pumpAndSettle();

    // Verify bottom sheet is displayed with detected spots
    expect(find.text('Detected Locations'), findsOneWidget);
    expect(find.text('3 spots detected'), findsOneWidget);
    expect(find.text('Ready for itinerary'), findsNothing);
    expect(find.text('Shibuya Sky'), findsOneWidget);
    expect(find.text('Roppongi Hills Observation Deck'), findsOneWidget);
    expect(find.text('Miyashita Park'), findsOneWidget);
    expect(find.text('Included'), findsNWidgets(3));

    // Tap "Got it" button to dismiss sheet
    final gotItFinder = find.text('Got it');
    expect(gotItFinder, findsOneWidget);
    await tester.tap(gotItFinder);
    await tester.pumpAndSettle();

    // Verify sheet is closed
    expect(find.text('Detected Locations'), findsNothing);
  });

  testWidgets(
      'Pasting Instagram reel DdHET-KJzAr detects Café Zingaro, Nakano Broadway and Nakano Station',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: TripPlacesInputScreen(
          destination: 'Tokyo, Japan',
          selectedVibes: ['Foodie'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Paste the Instagram reel URL
    final inputFinder = find.byType(TextField);
    await tester.enterText(
      inputFinder,
      'https://www.instagram.com/reel/DdHET-KJzAr/?hl=en',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Verify card for 'You' is added with detected reel title and count
    expect(find.text('Café Zingaro · Takashi Murakami Retro Kissaten'), findsOneWidget);
    expect(find.text('3 locations detected'), findsNWidgets(3)); // Sarah's + Kenji's + You's

    // Tap on the newly added Café Zingaro card
    await tester.tap(find.text('Café Zingaro · Takashi Murakami Retro Kissaten'));
    await tester.pumpAndSettle();

    // Verify bottom sheet shows detected locations
    expect(find.text('Detected Locations'), findsOneWidget);
    expect(find.text('Ready for itinerary'), findsNothing);
    expect(find.text('Café Zingaro'), findsOneWidget);
    expect(find.text('Nakano Broadway'), findsOneWidget);
    expect(find.text('Nakano Station'), findsOneWidget);
    expect(find.text('Included'), findsNWidgets(3));

    // Dismiss sheet
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(find.text('Detected Locations'), findsNothing);
  });
}
