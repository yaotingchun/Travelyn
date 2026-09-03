import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelyn/presentation/journey/trip_created_screen.dart';

void main() {
  testWidgets('TripCreatedScreen renders celebration mascot, invite card, and actions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: TripCreatedScreen(
          destination: 'Tokyo, Japan',
          tripType: 'Solo Trip',
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Welcome Headings
    expect(find.text('Welcome to your\nnew adventure!'), findsOneWidget);
    expect(find.text('Invite your friends and\nmake memories together.'), findsOneWidget);

    // 2. Verify Invite Card
    expect(find.text('Invite with link'), findsOneWidget);
    expect(find.text('travelyn.com/invite/TOK925'), findsOneWidget);
    expect(find.byIcon(Icons.copy_rounded), findsOneWidget);

    // 3. Verify Share Button & Maybe Later
    expect(find.text('Share Invite'), findsOneWidget);
    expect(find.byIcon(Icons.share_outlined), findsOneWidget);
    expect(find.text('Maybe later'), findsOneWidget);

    // 4. Tap copy link container
    await tester.tap(find.text('travelyn.com/invite/TOK925'));
    await tester.pump(); // Start snackbar animation
    expect(find.text('Invite link copied to clipboard!'), findsOneWidget);
    await tester.pumpAndSettle();

    // 5. Tap Share Invite button
    await tester.tap(find.text('Share Invite'));
    await tester.pumpAndSettle();

    // Verify share bottom sheet appears
    expect(find.text('Share with Friends'), findsOneWidget);
    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
  });
}
