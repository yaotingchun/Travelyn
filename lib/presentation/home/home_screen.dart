import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../auth/login_screen.dart';
import '../journey/journey_screen.dart';
import '../profile/pages/me_page.dart';
import 'widgets/free_time_banner.dart';
import 'widgets/hero_tokyo_card.dart';
import 'widgets/top_gradient_padding.dart';
import 'widgets/whats_next_section.dart';
import 'widgets/your_journey_card.dart';

/// Clean home dashboard screen with full-bleed hero Tokyo card, journey map, upcoming itinerary, and floating nav bar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    const brandOrange = Color(0xFFE65100);
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F0),
      // No standard AppBar on Home tab so the hero card bleeds edge-to-edge to the top of screen
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: IndexedStack(
          index: _currentIndex,
          children: [
            // Tab 0: Home Dashboard
            Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Hero Tokyo Card with Passport Reminder
                      HeroTokyoCard(
                        onNotificationTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('No new notifications'),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        onProfileTap: () {
                          setState(() {
                            _currentIndex = 3;
                          });
                        },
                        onSignOutTap: () {
                          Navigator.of(context).pushReplacement(
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 400),
                              pageBuilder: (context, animation,
                                      secondaryAnimation) =>
                                  const LoginScreen(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
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
                        },
                      ),

                      // Spacing before content sections
                      const SizedBox(height: 22),

                      // 2. Sections Container: Your Journey, What's next?, Free time idea
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            YourJourneyCard(
                              onViewFullTripTap: () {
                                setState(() {
                                  _currentIndex = 1;
                                });
                              },
                            ),
                            const SizedBox(height: 18),
                            const WhatsNextSection(),
                            const SizedBox(height: 16),
                            const FreeTimeBanner(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Top gradient spacer
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: TopGradientPadding(),
                ),
              ],
            ),

            // Tab 1: Journey Screen
            const JourneyScreen(),

            // Tab 2: Discover Screen (Placeholder)
            const SafeArea(
              child: Center(
                child: Text(
                  'Discover',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: darkBrown,
                  ),
                ),
              ),
            ),

            // Tab 3: Me / Profile Screen
            const MePage(),
          ],
        ),
      ),

      // Flat, Floating Rounded Pill Navigation Bar with Soft Warm Active Pill
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
          child: Container(
            height: 56,
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF4EEE6),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFFE8DFD5),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E1C14).withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildNavItem(
                    index: 0,
                    label: 'Home',
                    activeIcon: Icons.home_rounded,
                    inactiveIcon: Icons.home_outlined,
                    brandOrange: brandOrange,
                    textMuted: textMuted,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    index: 1,
                    label: 'Journey',
                    activeIcon: Icons.place_rounded,
                    inactiveIcon: Icons.place_outlined,
                    brandOrange: brandOrange,
                    textMuted: textMuted,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    index: 2,
                    label: 'Discover',
                    activeIcon: Icons.explore_rounded,
                    inactiveIcon: Icons.explore_outlined,
                    brandOrange: brandOrange,
                    textMuted: textMuted,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    index: 3,
                    label: 'Me',
                    activeIcon: Icons.person_rounded,
                    inactiveIcon: Icons.person_outline_rounded,
                    brandOrange: brandOrange,
                    textMuted: textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required Color brandOrange,
    required Color textMuted,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFAF7F2) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: const Color(0xFFECE4D9), width: 0.8)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2E1C14).withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 1.5),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? brandOrange : textMuted,
              size: 21,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? brandOrange : textMuted,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
