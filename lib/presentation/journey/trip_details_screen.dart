import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tabs/bookings_tab.dart';
import 'tabs/chat_tab.dart';
import 'tabs/diary_tab.dart';
import 'tabs/finance_tab.dart';
import 'tabs/trip_tab.dart';
import 'widgets/trip_chat_bottom_bar.dart';
import 'widgets/trip_details_nav_bar.dart';
import 'widgets/trip_hero_header.dart';
import 'widgets/trip_invite_sheet.dart';
import 'widgets/trip_overview_sheet.dart';

// Re-export modular components for seamless backwards compatibility
export 'tabs/bookings_tab.dart';
export 'tabs/chat_tab.dart';
export 'tabs/diary_tab.dart';
export 'tabs/finance_tab.dart';
export 'tabs/trip_tab.dart';
export 'widgets/realistic_push_pin.dart';
export 'widgets/trip_chat_bottom_bar.dart';
export 'widgets/trip_details_nav_bar.dart';
export 'widgets/trip_hero_header.dart';
export 'widgets/trip_invite_sheet.dart';
export 'widgets/trip_overview_sheet.dart';

/// Screen displayed after creating a trip.
/// Matches the reference design:
/// - Fully opaque hero photo (`tokyo_pagoda_blossom.jpg`) with pagoda and cherry blossoms
/// - Naked back arrow (<) directly on the photo, aligned with destination title
/// - Date range and member avatars with circular '+' add button
/// - Full-width cream sheet with rounded top corners overlapping the hero photo
/// - Navbar sits at the top of the below sheet (Chat, Trip, Bookings, Diary, Finance)
/// - Pinned overview card and interactive chat feed in Chat tab
/// - Modular tabs: Trip, Bookings, Diary, and Finance (ready for teammate implementation)
class TripDetailsScreen extends StatefulWidget {
  final String destination;
  final String? tripType;
  final DateTime? startDate;
  final DateTime? endDate;

  const TripDetailsScreen({
    super.key,
    this.destination = 'Tokyo, Japan',
    this.tripType = 'Group Trip',
    this.startDate,
    this.endDate,
  });

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  int _activeTabIndex = 0;
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  final List<Map<String, dynamic>> _chatMessages = [
    {
      'sender': 'Travelyn',
      'avatar': 'assets/mascot/avatar.png',
      'message':
          "Konnichiwa, explorers! 👏\nHere's a quick overview of our Tokyo adventure. Tap the card above to see day-by-day highlights, must-try food, top spots and more!",
      'time': '9:30 AM',
      'isBot': true,
      'reactionEmoji': '❤️',
      'reactionCount': '12',
    },
  ];

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';

    setState(() {
      _chatMessages.add({
        'sender': 'You',
        'avatar': 'assets/journey/member_avatar_4.jpg',
        'message': text,
        'time': timeStr,
        'isBot': false,
        'reactionEmoji': null,
        'reactionCount': null,
      });
      _chatController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showInviteSheet() {
    TripInviteSheet.show(context, destination: widget.destination);
  }

  void _showOverviewSheet() {
    TripOverviewSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    const brandOrange = Color(0xFFE65100);
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF6B5A50);

    final safeTop = MediaQuery.of(context).padding.top;
    final heroImageHeight = (safeTop + 195.0).clamp(235.0, 265.0);
    const navbarHeight = 64.0;
    const navbarOverlap = 32.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F0),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Stack(
          children: [
            // 1. TOP HERO CARD (Photo + destination info)
            TripHeroHeader(
              destination: widget.destination,
              startDate: widget.startDate,
              endDate: widget.endDate,
              heroImageHeight: heroImageHeight,
              onBackTap: () => Navigator.of(context).pop(),
              onInviteTap: _showInviteSheet,
              darkBrown: darkBrown,
            ),

            // 2. THE CREAM SHEET (Rounded top corners, overlapping hero photo)
            Positioned.fill(
              top: heroImageHeight - 10.0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF7F0),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: darkBrown.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: (navbarHeight - navbarOverlap) + 10.0,
                      bottom: _activeTabIndex == 0 ? 128.0 : 0.0,
                    ),
                    child: IndexedStack(
                      index: _activeTabIndex,
                      children: [
                        ChatTab(
                          destination: widget.destination,
                          messages: _chatMessages,
                          scrollController: _chatScrollController,
                          onOverviewTap: _showOverviewSheet,
                          brandOrange: brandOrange,
                          darkBrown: darkBrown,
                          textMuted: textMuted,
                        ),
                        TripTab(
                          destination: widget.destination,
                          startDate: widget.startDate,
                          endDate: widget.endDate,
                          tripType: widget.tripType,
                          brandOrange: brandOrange,
                          darkBrown: darkBrown,
                          textMuted: textMuted,
                        ),
                        BookingsTab(
                          destination: widget.destination,
                          startDate: widget.startDate,
                          endDate: widget.endDate,
                          tripType: widget.tripType,
                          brandOrange: brandOrange,
                          darkBrown: darkBrown,
                          textMuted: textMuted,
                        ),
                        DiaryTab(
                          destination: widget.destination,
                          startDate: widget.startDate,
                          endDate: widget.endDate,
                          tripType: widget.tripType,
                          brandOrange: brandOrange,
                          darkBrown: darkBrown,
                          textMuted: textMuted,
                        ),
                        FinanceTab(
                          destination: widget.destination,
                          startDate: widget.startDate,
                          endDate: widget.endDate,
                          tripType: widget.tripType,
                          brandOrange: brandOrange,
                          darkBrown: darkBrown,
                          textMuted: textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. THE INDEPENDENT NAVBAR (Lying between below sheet & hero card)
            Positioned(
              top: heroImageHeight - navbarOverlap,
              left: 14,
              right: 14,
              height: navbarHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF7F0),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFEDE3D7),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: darkBrown.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: darkBrown.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: TripDetailsNavBar(
                  activeTabIndex: _activeTabIndex,
                  onTabSelected: (index) {
                    setState(() {
                      _activeTabIndex = index;
                    });
                  },
                  brandOrange: brandOrange,
                  textMuted: textMuted,
                ),
              ),
            ),

            // 4. FIXED BOTTOM CHAT BOX (Active only on Chat tab)
            if (_activeTabIndex == 0)
              Positioned(
                left: 8,
                right: 8,
                bottom: 6,
                child: SafeArea(
                  top: false,
                  child: TripChatBottomBar(
                    controller: _chatController,
                    onSend: _sendMessage,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
