import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelyn/presentation/journey/trip_feedback_screen.dart';

void main() {
  testWidgets('TripFeedbackScreen renders title with place name, rating options and submit button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TripFeedbackScreen(
          placeName: 'Senso-ji Temple',
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('How was\nSenso-ji Temple?'), findsOneWidget);

    // Verify all 5 rating option labels
    expect(find.text('Terrible'), findsOneWidget);
    expect(find.text('Not great'), findsOneWidget);
    expect(find.text('Okay'), findsOneWidget);
    expect(find.text('Great'), findsOneWidget);
    expect(find.text('Amazing'), findsOneWidget);

    // Verify Experience Card
    expect(find.text('Share your experience...'), findsOneWidget);
    expect(find.text('What did you love or not love?'), findsOneWidget);

    // Verify Submit button
    expect(find.text('Submit ✨'), findsOneWidget);
  });

  testWidgets('Selecting a different rating updates the selected rating and triggers callback on submit', (WidgetTester tester) async {
    TripFeedbackData? submittedData;

    await tester.pumpWidget(
      MaterialApp(
        home: TripFeedbackScreen(
          placeName: 'Senso-ji Temple & Asakusa',
          onFeedbackSubmitted: (data) {
            submittedData = data;
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Title should format "Senso-ji Temple & Asakusa" cleanly to "Senso-ji Temple"
    expect(find.text('How was\nSenso-ji Temple?'), findsOneWidget);

    // Tap "Great" rating
    await tester.tap(find.text('Great'));
    await tester.pumpAndSettle();

    // Enter comment in textfield
    await tester.enterText(find.byType(TextField), 'Loved the incense burner and pagodas!');
    await tester.pumpAndSettle();

    // Tap "Submit ✨"
    await tester.tap(find.text('Submit ✨'));
    await tester.pumpAndSettle();

    expect(submittedData, isNotNull);
    expect(submittedData!.rating, TripRating.great);
    expect(submittedData!.comment, 'Loved the incense burner and pagodas!');
    expect(submittedData!.placeName, 'Senso-ji Temple & Asakusa');
  });

  testWidgets('Submitting feedback with nextPlaceName redirects to TripNextLocationScreen and clicking Yes lets go returns true', (WidgetTester tester) async {
    bool? navigationResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  final res = await TripFeedbackScreen.show(
                    context,
                    placeName: 'Meiji Shrine',
                    nextPlaceName: 'Harajuku Takeshita St.',
                    nextLocation: 'Harajuku, Tokyo',
                    nextWalkTime: '20 min',
                    nextStopNumber: 2,
                  );
                  navigationResult = res;
                },
                child: const Text('Open Feedback'),
              ),
            );
          },
        ),
      ),
    );

    // Tap button to show TripFeedbackScreen
    await tester.tap(find.text('Open Feedback'));
    await tester.pumpAndSettle();

    // Verify on feedback screen
    expect(find.text('How was\nMeiji Shrine?'), findsOneWidget);

    // Tap Submit ✨
    await tester.tap(find.text('Submit ✨'));
    await tester.pumpAndSettle();

    // Verify redirected to TripNextLocationScreen
    expect(find.text('Harajuku Takeshita St.!'), findsOneWidget);
    expect(find.text("Yes, let's go! 🏃"), findsOneWidget);

    // Tap "Yes, let's go! 🏃"
    await tester.tap(find.text("Yes, let's go! 🏃"));
    await tester.pumpAndSettle();

    // Should be back to base screen and navigationResult should be true
    expect(find.text('Open Feedback'), findsOneWidget);
    expect(navigationResult, isTrue);
  });

  testWidgets('Submitting feedback with nextPlaceName redirects to TripNextLocationScreen and clicking Not now returns false', (WidgetTester tester) async {
    bool? navigationResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  final res = await TripFeedbackScreen.show(
                    context,
                    placeName: 'Meiji Shrine',
                    nextPlaceName: 'Harajuku Takeshita St.',
                    nextLocation: 'Harajuku, Tokyo',
                    nextWalkTime: '20 min',
                    nextStopNumber: 2,
                  );
                  navigationResult = res;
                },
                child: const Text('Open Feedback'),
              ),
            );
          },
        ),
      ),
    );

    // Tap button to show TripFeedbackScreen
    await tester.tap(find.text('Open Feedback'));
    await tester.pumpAndSettle();

    // Tap Submit ✨
    await tester.tap(find.text('Submit ✨'));
    await tester.pumpAndSettle();

    // Verify redirected to TripNextLocationScreen
    expect(find.text('Not now'), findsOneWidget);

    // Scroll until "Not now" is visible and tap it
    await tester.ensureVisible(find.text('Not now'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    // Should be back to base screen and navigationResult should be false
    expect(find.text('Open Feedback'), findsOneWidget);
    expect(navigationResult, isFalse);
  });
}
