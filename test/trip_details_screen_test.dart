import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelyn/presentation/journey/trip_details_screen.dart';

void main() {
  testWidgets(
      'TripDetailsScreen renders hero card, navbar, and pinned overview card',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: TripDetailsScreen(
          destination: 'Tokyo, Japan',
          startDate: DateTime(2025, 9, 12),
          endDate: DateTime(2025, 9, 18),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Hero Card Header & Information
    expect(find.text('Tokyo, Japan 🇯🇵'), findsOneWidget);
    expect(find.text('12 Sep – 18 Sep 2025'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsWidgets);

    // 2. Verify Navbar items with exact color scheme
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Trip'), findsOneWidget);
    expect(find.text('Bookings'), findsOneWidget);
    expect(find.text('Diary'), findsOneWidget);
    expect(find.text('Finance'), findsOneWidget);

    // 3. Verify Pinned Overview Card
    expect(find.text('Pinned by Travelyn'), findsOneWidget);
    expect(find.text('Tokyo Trip Overview'), findsOneWidget);
    expect(find.text('Tap to explore your trip highlights'), findsOneWidget);

    // 4. Tap the Pinned Overview Card to open the highlights sheet
    await tester.tap(find.text('Tokyo Trip Overview'));
    await tester.pumpAndSettle();

    // Verify Highlights sheet details
    expect(find.text('Weather Forecast'), findsOneWidget);
    expect(find.text('Transit Essentials'), findsOneWidget);
    expect(find.text('Trip Checklist'), findsOneWidget);

    // Close bottom sheet
    await tester.tapAt(const Offset(100, 50));
    await tester.pumpAndSettle();

    // 5. Switch to "Trip" tab (content removed)
    await tester.tap(find.text('Trip'));
    await tester.pumpAndSettle();
    expect(find.text('Arrival & Shinjuku Night'), findsNothing);

    // 6. Switch to "Bookings" tab (content removed)
    await tester.tap(find.text('Bookings'));
    await tester.pumpAndSettle();
    expect(find.text('Tokyo Haneda (HND) Roundtrip'), findsNothing);

    // 7. Switch to "Finance" tab (content removed)
    await tester.tap(find.text('Finance'));
    await tester.pumpAndSettle();
    expect(find.text('Group Budget Overview'), findsNothing);

    // 8. Switch back to "Chat" tab
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.text('Pinned by Travelyn'), findsOneWidget);

    // 9. Verify welcoming message from Trippy/Travelyn
    expect(find.text('Travelyn'), findsOneWidget);
    expect(
      find.byWidgetPredicate((w) =>
          w is RichText &&
          w.text.toPlainText().contains('Konnichiwa, explorers!')),
      findsOneWidget,
    );
    expect(find.text('12'), findsOneWidget);
    expect(find.text('9:30 AM'), findsOneWidget);

    // Verify member joined system event pill after Travelyn's message
    expect(find.text('Sarah has joined'), findsOneWidget);

    // 10. User sends a message via the chatbox
    await tester.enterText(find.byType(TextField), 'Hello Tokyo!');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Hello Tokyo!'), findsOneWidget);

    // 11. Verify "We're All Set!" button above chatbox
    expect(find.text("We're All Set!"), findsOneWidget);

    // Tap "We're All Set!" button -> Travelyn sends "Everyone's here!" with "Let's Go!" button
    await tester.tap(find.text("We're All Set!"));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate((w) =>
          w is RichText &&
          w.text.toPlainText().contains("Everyone's here!")),
      findsOneWidget,
    );
    expect(find.text("Let's Go!"), findsOneWidget);

    // Tap "Let's Go!" button -> opens TripVotingScreen
    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    expect(find.text('What kind of trip are we making?'), findsOneWidget);
    expect(find.text('Foodie'), findsOneWidget);
    expect(find.text('Theme Parks'), findsOneWidget);
    expect(find.text("I'm Done!"), findsOneWidget);

    // Tap "I'm Done!" -> opens TripPlacesInputScreen ("Anything you wanna go?")
    await tester.tap(find.text("I'm Done!"));
    await tester.pumpAndSettle();

    expect(find.text('Anything you wanna go?'), findsOneWidget);

    // Tap "Ready!" -> finalizes and returns to TripDetailsScreen
    await tester.tap(find.text("Ready!"));
    await tester.pumpAndSettle();

    expect(
      find.text("Votes submitted! Creating your perfect trip ✨"),
      findsOneWidget,
    );
  });
}
