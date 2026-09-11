import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tabs/bookings_tab.dart';
import 'tabs/chat_tab.dart';
import 'tabs/diary_tab.dart';
import 'tabs/finance_tab.dart';
import 'tabs/trip_tab.dart';
import '../../services/mapbox_config.dart';
import 'widgets/trip_all_set_button.dart';
import 'widgets/trip_chat_bottom_bar.dart';
import 'widgets/trip_details_nav_bar.dart';
import 'widgets/trip_hero_header.dart';
import 'widgets/trip_invite_sheet.dart';
import 'widgets/trip_overview_sheet.dart';
import 'widgets/trip_simulation_events_sheet.dart';
import 'widgets/trip_surprise_plan_sheet.dart';
import 'trip_voting_screen.dart';

// Re-export modular components for seamless backwards compatibility
export 'tabs/bookings_tab.dart';
export 'tabs/chat_tab.dart';
export 'tabs/diary_tab.dart';
export 'tabs/finance_tab.dart';
export 'tabs/trip_tab.dart';
export 'widgets/realistic_push_pin.dart';
export 'widgets/trip_all_set_button.dart';
export 'widgets/trip_lets_go_button.dart';
export 'widgets/trip_chat_bottom_bar.dart';
export 'widgets/trip_details_nav_bar.dart';
export 'widgets/trip_hero_header.dart';
export 'widgets/trip_invite_sheet.dart';
export 'widgets/trip_overview_sheet.dart';
export 'widgets/trip_simulation_events_sheet.dart';
export 'widgets/trip_surprise_plan_sheet.dart';
export 'widgets/trip_cafe_closed_sheet.dart';
export 'trip_voting_screen.dart';
export 'trip_places_input_screen.dart';
export 'trip_itinerary_screen.dart';

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
  final VoidCallback? onAllSet;
  final int initialTabIndex;

  const TripDetailsScreen({
    super.key,
    this.destination = 'Tokyo, Japan',
    this.tripType = 'Group Trip',
    this.startDate,
    this.endDate,
    this.onAllSet,
    this.initialTabIndex = 0,
  });

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  late int _activeTabIndex;
  bool _hasAllSetTriggered = false;
  bool _hasSurpriseDetourAdded = false;
  bool _hasCafeReplaced = false;
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.initialTabIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MapboxConfig.precacheTokyoDays(context);
  }

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
    {
      'isSystem': true,
      'message': 'Sarah has joined',
      'time': '9:31 AM',
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

    final isCafeClosedQuery = text.toLowerCase().contains('closed') ||
        (text.toLowerCase().contains('cafe') && text.toLowerCase().contains('nearby')) ||
        (text.toLowerCase().contains('bread') && text.toLowerCase().contains('closed')) ||
        text.toLowerCase().contains('backup cafe') ||
        text.toLowerCase().contains('arashiyama');

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

    if (isCafeClosedQuery) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        final nowResp = DateTime.now();
        final hourResp = nowResp.hour > 12 ? nowResp.hour - 12 : (nowResp.hour == 0 ? 12 : nowResp.hour);
        final minResp = nowResp.minute.toString().padLeft(2, '0');
        final perResp = nowResp.hour >= 12 ? 'PM' : 'AM';
        final timeStrResp = '$hourResp:$minResp $perResp';

        final cafeMsg = <String, dynamic>{
          'id': 'cafe_closed_${DateTime.now().millisecondsSinceEpoch}',
          'sender': 'Travelyn',
          'avatar': 'assets/mascot/avatar.png',
          'isBot': true,
          'isCafeClosed': true,
          'message':
              "Oh no, that's a bummer! Don't worry at all — just a 2-minute stroll around the corner is Chatei Hatou (茶亭 羽當). It's a cozy retro kissaten famous for siphon coffee & freshly baked matcha chiffon cake ☕🍰\n\nShould I swap our morning stop?",
          'time': timeStrResp,
          'decision': null,
        };

        setState(() {
          _chatMessages.add(cafeMsg);
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_chatScrollController.hasClients) {
            _chatScrollController.animateTo(
              _chatScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
            );
          }
        });
      });
    }
  }

  void _showInviteSheet() {
    TripInviteSheet.show(context, destination: widget.destination);
  }

  void _showOverviewSheet() {
    TripOverviewSheet.show(context);
  }

  void _showSimulationSheet() {
    TripSimulationEventsSheet.show(
      context,
      onEventSelected: (number, title) {
        if (number == '3' && !title.toLowerCase().contains('cafe')) {
          _triggerSurprisePlanSimulation();
        } else if (number == '4' || title.toLowerCase().contains('cafe')) {
          _triggerCafeClosedSimulation();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Selected: $number. $title',
                style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFF2E1C14),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  void _triggerCafeClosedSimulation() {
    setState(() {
      _activeTabIndex = 0;
      _chatController.text =
          "Hey @Travelyn, Bread, Espresso & Arashiyama Garden, Kyoto is closed today! Any other cafe nearby?";
      _chatController.selection = TextSelection.fromPosition(
        TextPosition(offset: _chatController.text.length),
      );
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

  void _handleCafeReplacement(Map<String, dynamic> msg) {
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';

    setState(() {
      _hasCafeReplaced = true;
      _activeTabIndex = 1; // Transition smoothly to the Trip tab to view updated stop
      msg['decision'] = 'swap';
      _chatMessages.add({
        'sender': 'Travelyn',
        'avatar': 'assets/mascot/avatar.png',
        'message':
            "All set! ☕ Replaced 'Bread, Espresso & Arashiyama Garden, Kyoto' with 'Chatei Hatou' on Day 1. Your morning schedule and route have been smoothly updated!",
        'time': timeStr,
        'isBot': true,
        'reactionEmoji': '☕',
        'reactionCount': '4',
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }

      try {
        final messenger = ScaffoldMessenger.maybeOf(context);
        if (messenger != null) {
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.coffee_rounded, color: Color(0xFFFFB74D), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Swapped to Chatei Hatou! Day 1 itinerary updated ☕✨",
                      style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF2E1C14),
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          );
        }
      } catch (_) {}
    });
  }

  void _handleCafeSkip(Map<String, dynamic> msg) {
    if (!mounted) return;
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';

    setState(() {
      msg['decision'] = 'skip';
      _chatMessages.add({
        'sender': 'Travelyn',
        'avatar': 'assets/mascot/avatar.png',
        'message':
            "Got it! Skipped the breakfast cafe. Head straight to Meiji Shrine whenever you're ready! ⛩️",
        'time': timeStr,
        'isBot': true,
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }

      try {
        final messenger = ScaffoldMessenger.maybeOf(context);
        if (messenger != null) {
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Breakfast skipped • Moving to next destination ⛩️",
                      style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF2E1C14),
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          );
        }
      } catch (_) {}
    });
  }

  void _triggerSurprisePlanSimulation() async {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';

    // 1. Add the Moments interactive card to the group chat
    final momentMsg = <String, dynamic>{
      'id': 'moment_${DateTime.now().millisecondsSinceEpoch}',
      'sender': 'Travelyn',
      'avatar': 'assets/mascot/avatar.png',
      'isBot': true,
      'isMoment': true,
      'distanceText': "You're 300m away from a hidden food alley",
      'locationName': 'Ura-Harajuku Secret Food Alley (裏原宿)',
      'message':
          "I found a cozy hidden alley just 300m away behind Cat Street! It's not in your itinerary, but it matches your group's interest in local street food and matcha treats.",
      'extraTime': '+4 min (300m)',
      'time': timeStr,
      'decision': null,
    };

    setState(() {
      _chatMessages.add(momentMsg);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });

    // 2. Present the interactive Moments modal sheet with [Let's go] and [Stay on plan]
    final result = await TripSurprisePlanSheet.show(context);
    if (!mounted) return;
    if (result == true) {
      _handleDetourAccept(momentMsg);
    } else if (result == false) {
      _handleDetourDecline(momentMsg);
    }
  }

  void _handleDetourAccept(Map<String, dynamic> msg) {
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';

    setState(() {
      _hasSurpriseDetourAdded = true;
      _activeTabIndex = 1; // Seamlessly transition user to the Trip tab to see the updated route & stop
      msg['decision'] = 'accept';
      _chatMessages.add({
        'sender': 'Travelyn',
        'avatar': 'assets/mascot/avatar.png',
        'message':
            "Awesome choice! 🍡 Added 'Ura-Harajuku Food Alley' (+4 min / 300m detour) to our timeline.\nLet's go explore some fresh street snacks and matcha treats!",
        'time': timeStr,
        'isBot': true,
        'reactionEmoji': '🍡',
        'reactionCount': '3',
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }

      try {
        final messenger = ScaffoldMessenger.maybeOf(context);
        if (messenger != null) {
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.explore_rounded, color: Color(0xFFFFB74D), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Detour added to itinerary! (+4 min at Ura-Harajuku) ✨",
                      style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF2E1C14),
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          );
        }
      } catch (_) {}
    });
  }

  void _handleDetourDecline(Map<String, dynamic> msg) {
    if (!mounted) return;
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';

    setState(() {
      msg['decision'] = 'stay';
      _chatMessages.add({
        'sender': 'Travelyn',
        'avatar': 'assets/mascot/avatar.png',
        'message':
            "Got it, sticking to the plan! ⛩️ I've saved 'Ura-Harajuku Food Alley' into your saved spots so you can visit next time.",
        'time': timeStr,
        'isBot': true,
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }

      try {
        final messenger = ScaffoldMessenger.maybeOf(context);
        if (messenger != null) {
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.bookmark_added_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Original plan kept • Market saved to Bookmarks 📌",
                      style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF2E1C14),
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          );
        }
      } catch (_) {}
    });
  }

  void _onAllSet() {
    if (widget.onAllSet != null) {
      widget.onAllSet!();
      return;
    }
    HapticFeedback.lightImpact();

    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';

    setState(() {
      _hasAllSetTriggered = true;
      _chatMessages.add({
        'sender': 'Travelyn',
        'avatar': 'assets/mascot/avatar.png',
        'message':
            "Everyone's here! 🎉\nTime to make this trip truly ours~\nLet's vote so I can plan the perfect Tokyo adventure for all of us!",
        'time': timeStr,
        'isBot': true,
        'actionText': "Let's Go!",
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _openVotingScreen() async {
    final result = await Navigator.of(context).push<List<String>>(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            TripVotingScreen(
          destination: widget.destination,
          onDone: (selected) {
            Navigator.of(context).pop(selected);
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: child,
          );
        },
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _activeTabIndex = 1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Votes submitted! Creating your perfect trip ✨",
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2E1C14),
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
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
              onSimulateTap: _showSimulationSheet,
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
                      bottom: _activeTabIndex == 0
                          ? (_hasAllSetTriggered ? 128.0 : 180.0)
                          : 0.0,
                    ),
                    child: IndexedStack(
                      index: _activeTabIndex,
                      children: [
                        ChatTab(
                          destination: widget.destination,
                          messages: _chatMessages,
                          scrollController: _chatScrollController,
                          onOverviewTap: _showOverviewSheet,
                          onLetsGoTap: _openVotingScreen,
                          onDetourAccept: _handleDetourAccept,
                          onDetourDecline: _handleDetourDecline,
                          onCafeReplace: _handleCafeReplacement,
                          onCafeSkip: _handleCafeSkip,
                          brandOrange: brandOrange,
                          darkBrown: darkBrown,
                          textMuted: textMuted,
                        ),
                        TripTab(
                          destination: widget.destination,
                          startDate: widget.startDate,
                          endDate: widget.endDate,
                          tripType: widget.tripType,
                          mapboxAccessToken: MapboxConfig.defaultAccessToken,
                          brandOrange: brandOrange,
                          darkBrown: darkBrown,
                          textMuted: textMuted,
                          hasSurpriseDetourAdded: _hasSurpriseDetourAdded,
                          hasCafeReplaced: _hasCafeReplaced,
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

            // 4. FIXED BOTTOM CHAT BOX & "WE'RE ALL SET!" BUTTON (Active only on Chat tab)
            if (_activeTabIndex == 0)
              Positioned(
                left: 8,
                right: 8,
                bottom: 6,
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_hasAllSetTriggered) ...[
                        TripAllSetButton(
                          onPressed: _onAllSet,
                        ),
                        const SizedBox(height: 8),
                      ],
                      TripChatBottomBar(
                        controller: _chatController,
                        onSend: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
