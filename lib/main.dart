import 'dart:ui';
import 'package:flutter/material.dart';
import 'presentation/intro/intro_screen.dart';

void main() {
  runApp(const TravelynApp());
}

class TravelynApp extends StatelessWidget {
  const TravelynApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travelyn',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.trackpad,
        },
      ),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFDF7F0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE65100),
          surface: const Color(0xFFFDF7F0),
        ),
      ),
      home: const IntroScreen(),
    );
  }
}
