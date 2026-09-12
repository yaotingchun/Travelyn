import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelyn/presentation/journey/trip_next_location_screen.dart';

void main() {
  testWidgets('TripNextLocationScreen renders header, square card, transit subtitle and action buttons', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool letsGoTapped = false;
    bool notNowTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: TripNextLocationScreen(
          placeName: 'Nakamise Shopping Street',
          location: 'Asakusa, Taito City',
          walkTime: '5 min',
          category: 'Shopping & Street Food',
          imageAsset: 'assets/journey/place_sensoji.jpg',
          stopNumber: 2,
          onLetsGo: () => letsGoTapped = true,
          onNotNow: () => notNowTapped = true,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Header matches Image 1
    expect(find.text('Your next location:'), findsOneWidget);
    expect(find.text('Nakamise Shopping Street!'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    // Verify Location Square Card content
    expect(find.text('Stop 2'), findsOneWidget);
    expect(find.text('Shopping & Street Food'), findsOneWidget);
    expect(find.text('Asakusa, Taito City'), findsOneWidget);

    // Verify Proximity and Ready to Explore texts
    expect(find.text("It's just a 5 min walk away,"), findsOneWidget);
    expect(find.text('Ready to Explore?'), findsOneWidget);

    // Verify Bottom Buttons match Image 2
    expect(find.text("Yes, let's go! 🏃"), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);

    // Tap "Yes, let's go! 🏃"
    await tester.tap(find.text("Yes, let's go! 🏃"));
    await tester.pumpAndSettle();

    expect(letsGoTapped, isTrue);
  });

  testWidgets('TripNextLocationScreen tapping Not now triggers callback', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool notNowTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: TripNextLocationScreen(
          placeName: 'Tokyo Skytree',
          walkTime: '15 min',
          onNotNow: () => notNowTapped = true,
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(notNowTapped, isTrue);
  });
}
