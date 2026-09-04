import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelyn/presentation/journey/trip_voting_screen.dart';

void main() {
  testWidgets('TripVotingScreen renders 3x3 mascot cards, allows voting, and triggers onDone',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    List<String>? submittedVotes;

    await tester.pumpWidget(
      MaterialApp(
        home: TripVotingScreen(
          destination: 'Tokyo, Japan',
          onDone: (votes) {
            submittedVotes = votes;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Header & Prompts
    expect(find.text('What kind of trip are we making?'), findsOneWidget);
    expect(
      find.text("Pick up to 3! Everyone's answers will be shown~"),
      findsOneWidget,
    );

    // 2. Verify All 9 Mascot Category Cards & Descriptions
    expect(find.text('Foodie'), findsOneWidget);
    expect(find.text('Eat everything'), findsOneWidget);

    expect(find.text('Culture'), findsOneWidget);
    expect(find.text('Feel traditional vibes'), findsOneWidget);

    expect(find.text('Adventure'), findsOneWidget);
    expect(find.text('Trek scenic trails'), findsOneWidget);

    expect(find.text('Chill'), findsOneWidget);
    expect(find.text('No rushing please'), findsOneWidget);

    expect(find.text('Sightseeing'), findsOneWidget);
    expect(find.text('See iconic landmarks'), findsOneWidget);

    expect(find.text('Photo Spots'), findsOneWidget);
    expect(find.text('Capture memories'), findsOneWidget);

    expect(find.text('Shopping'), findsOneWidget);
    expect(find.text('Shop till you drop'), findsOneWidget);

    expect(find.text('Hidden Gems'), findsOneWidget);
    expect(find.text('Find secret spots'), findsOneWidget);

    expect(find.text('Theme Parks'), findsOneWidget);
    expect(find.text('Thrilling fun & rides'), findsOneWidget);

    // 3. Verify Initial Selection count (3/3 selected)
    expect(find.text('3/3'), findsOneWidget);
    expect(find.text(' selected'), findsOneWidget);

    // 4. Toggle: Deselect 'Foodie' -> becomes 2/3 selected
    await tester.tap(find.text('Foodie'));
    await tester.pumpAndSettle();
    expect(find.text('2/3'), findsOneWidget);

    // Select 'Shopping' -> becomes 3/3 selected
    await tester.tap(find.text('Shopping'));
    await tester.pumpAndSettle();
    expect(find.text('3/3'), findsOneWidget);

    // Try selecting a 4th ('Theme Parks') -> blocked with SnackBar
    await tester.tap(find.text('Theme Parks'));
    await tester.pumpAndSettle();
    expect(find.text('You can pick up to 3 vibes!'), findsOneWidget);

    // Wait for SnackBar to auto-dismiss
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // 5. Tap "I'm Done!" Button -> navigates to TripPlacesInputScreen ("Anything you wanna go?")
    await tester.tap(find.text("I'm Done!"));
    await tester.pumpAndSettle();

    expect(find.text('Anything you wanna go?'), findsOneWidget);

    // 6. Tap CTA button ("Ready!") to finalize and submit votes
    await tester.tap(find.text("Ready!"));
    await tester.pumpAndSettle();

    expect(submittedVotes, isNotNull);
    expect(submittedVotes!.contains('Culture'), isTrue);
    expect(submittedVotes!.contains('Adventure'), isTrue);
    expect(submittedVotes!.contains('Shopping'), isTrue);
    expect(submittedVotes!.contains('Foodie'), isFalse);
  });
}
