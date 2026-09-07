import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelyn/presentation/journey/tabs/trip_tab.dart';
import 'package:travelyn/presentation/journey/trip_itinerary_screen.dart';

void main() {
  testWidgets('TripItineraryScreen renders celebration header, square carousel and CTA',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    bool tripHubOpened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: TripItineraryScreen(
          destination: 'Tokyo, Japan',
          planDuration: '5D4N',
          onOpenTripHub: () {
            tripHubOpened = true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Celebratory Header
    expect(find.text('Ta-da!'), findsOneWidget);
    expect(find.text("Here's your Tokyo adventure!"), findsOneWidget);
    expect(find.text('A 5D4N plan crafted just for your gang'), findsOneWidget);

    // 2. Verify Square Carousel (PageView) and first spot
    expect(find.byType(PageView), findsOneWidget);
    expect(find.text('Tokyo Tower'), findsOneWidget);
    expect(find.text('1 / 5'), findsOneWidget);
    expect(find.text('Sightseeing'), findsOneWidget);

    // 3. Verify CTA button
    expect(find.text('View Full Plan!'), findsOneWidget);
    await tester.tap(find.text('View Full Plan!'));
    await tester.pumpAndSettle();
    expect(tripHubOpened, isTrue);
  });

  testWidgets('Tapping indicator advances square carousel to selected place',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: TripItineraryScreen(
          destination: 'Tokyo, Japan',
          planDuration: '5D4N',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tokyo Tower'), findsOneWidget);

    // Tap the 2nd indicator dot
    await tester.tap(find.byKey(const ValueKey('carousel_indicator_1')));
    await tester.pumpAndSettle();

    expect(find.text('Sensō-ji Temple'), findsOneWidget);
    expect(find.text('2 / 5'), findsOneWidget);
    expect(find.text('Culture & Heritage'), findsOneWidget);

    // Tap the 4th indicator dot (Shibuya)
    await tester.tap(find.byKey(const ValueKey('carousel_indicator_3')));
    await tester.pumpAndSettle();

    expect(find.text('Shibuya Scramble'), findsOneWidget);
    expect(find.text('4 / 5'), findsOneWidget);
  });

  testWidgets('TripTab renders map, day picker, and itinerary cards',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TripTab(
            destination: 'Tokyo, Japan',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Day Selection Bar (Image 1: 08.09 SUN, 09.09 MON, etc.)
    expect(find.text('08.09 SUN'), findsOneWidget);
    expect(find.text('09.09 MON'), findsOneWidget);
    expect(find.text('10.09 TUE'), findsOneWidget);

    // 3. Verify Itinerary Timeline & Place Cards (Image 2)
    expect(find.text('Day 1'), findsOneWidget);
    expect(find.text('9 Sep (Wed)'), findsOneWidget);
    expect(find.text('Meiji Shrine'), findsOneWidget);
    expect(find.text('09:30'), findsOneWidget);
    expect(find.text('Shibuya, Tokyo'), findsWidgets);
    expect(find.text('15 min'), findsWidgets);
    expect(find.text('Harajuku Takeshita St.'), findsOneWidget);
    expect(find.text('11:00'), findsOneWidget);
    expect(find.text('20 min'), findsWidgets);

    // 4. Test selecting Day 2
    await tester.tap(find.byKey(const ValueKey('day_tab_1')));
    await tester.pumpAndSettle();

    expect(find.text('Day 2'), findsOneWidget);
    expect(find.text('10 Sep (Thu)'), findsOneWidget);
    expect(find.text('Ueno Park & Zoo'), findsOneWidget);
  });
}
