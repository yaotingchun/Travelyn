import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelyn/main.dart';
import 'package:travelyn/presentation/auth/login_screen.dart';
import 'package:travelyn/presentation/home/home_screen.dart';
import 'package:travelyn/presentation/intro/intro_screen.dart';
import 'package:travelyn/presentation/mascot/travelyn_mascot.dart';

void main() {
  testWidgets('Intro shows only waving mascot and transitions to login', (WidgetTester tester) async {
    await tester.pumpWidget(const TravelynApp());
    await tester.pump();

    // 1. In IntroScreen, only the mascot is shown
    expect(find.byType(IntroScreen), findsOneWidget);
    expect(find.byType(TravelynMascot), findsOneWidget);
    expect(find.text('Sign In'), findsNothing);
    expect(find.text('Travelyn'), findsNothing);

    // Verify mascot is configured with isWaving: true on Intro
    final mascotWidget = tester.widget<TravelynMascot>(find.byType(TravelynMascot));
    expect(mascotWidget.isWaving, isTrue);

    // 2. Tap to transition to LoginScreen
    await tester.tap(find.byType(IntroScreen));
    await tester.pumpAndSettle();

    // 3. Verify LoginScreen is shown
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Verify mascot on LoginScreen has isWaving: false
    final loginMascot = tester.widget<TravelynMascot>(find.byType(TravelynMascot));
    expect(loginMascot.isWaving, isFalse);

    // 4. Submit login and verify HomeScreen navigation
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Log In'));
    await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
