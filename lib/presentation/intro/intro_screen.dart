import 'dart:async';
import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../mascot/travelyn_mascot.dart';

/// Intro screen displayed before login.
///
/// Requirement:
/// - Displays ONLY the mascot waving in the center of the screen, with zero other information.
/// - Automatically transitions to [LoginScreen] after a brief moment (or immediately upon tap).
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  Timer? _transitionTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    // Automatically transition to the Login Screen after 2.8 seconds of waving
    _transitionTimer = Timer(const Duration(milliseconds: 2800), _navigateToLogin);
  }

  void _navigateToLogin() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _transitionTimer?.cancel();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _transitionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F0),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToLogin, // Tap anywhere to skip straight to login
        child: const Center(
          child: TravelynMascot(
            width: 270,
            height: 324,
            isWaving: true, // Waving animation active before login
          ),
        ),
      ),
    );
  }
}
