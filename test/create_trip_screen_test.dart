import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelyn/presentation/journey/create_trip_screen.dart';

void main() {
  testWidgets('CreateTripScreen renders header, form inputs, and trip type cards', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: CreateTripScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. App Bar
    expect(find.text('Create Trip'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

    // 2. Hero Header
    expect(find.text('Where to next?'), findsOneWidget);
    expect(find.text("Let's plan your adventure"), findsOneWidget);

    // 3. Destination Card
    expect(find.text('Destination'), findsOneWidget);
    expect(find.text('Enter location'), findsOneWidget);

    // 4. Dates Card
    expect(find.text('From'), findsOneWidget);
    expect(find.text('Select start date'), findsOneWidget);
    expect(find.text('To'), findsOneWidget);
    expect(find.text('Select end date'), findsOneWidget);

    // 5. Trip Type
    expect(find.text('Trip type'), findsOneWidget);
    expect(find.text('Solo Trip'), findsOneWidget);
    expect(find.text('Just you and the world'), findsOneWidget);
    expect(find.text('Group Trip'), findsOneWidget);
    expect(find.text('Better together, more fun!'), findsOneWidget);

    // 6. Next Button
    expect(find.text('Next'), findsOneWidget);

    // Toggle Group Trip
    await tester.ensureVisible(find.text('Group Trip'));
    await tester.tap(find.text('Group Trip'));
    await tester.pumpAndSettle();

    // Toggle back to Solo Trip
    await tester.ensureVisible(find.text('Solo Trip'));
    await tester.tap(find.text('Solo Trip'));
    await tester.pumpAndSettle();

    // Test Destination Substring Autocomplete:
    // Type "kyo" -> should match "Tokyo" and "Kyoto"
    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'kyo');
    await tester.pumpAndSettle();

    // Suggestions should appear with Tokyo and Kyoto
    expect(find.text('Kyoto, Japan'), findsWidgets);
    expect(find.text('Tokyo, Japan'), findsWidgets);

    // Tap on Kyoto suggestion to select it
    final kyotoFinder = find.text('Kyoto, Japan').first;
    await tester.tap(kyotoFinder);
    await tester.pumpAndSettle();

    // Text field should now have "Kyoto, Japan"
    expect(find.text('Kyoto, Japan'), findsOneWidget);
  });
}
