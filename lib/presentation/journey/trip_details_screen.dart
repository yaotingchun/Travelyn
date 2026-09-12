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
import 'widgets/trip_mention_popup.dart';
import 'widgets/mention_text_editing_controller.dart';
import 'widgets/trip_overview_sheet.dart';
import 'widgets/trip_simulation_events_sheet.dart';
import 'widgets/trip_morning_briefing_dialog.dart';
import 'trip_arrival_screen.dart';
import 'widgets/trip_surprise_plan_sheet.dart';
import 'widgets/trip_schedule_sync_sheet.dart';
import 'widgets/trip_conflict_approval_sheet.dart';
import 'trip_voting_screen.dart';

export 'widgets/trip_conflict_approval_sheet.dart';

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
export 'widgets/trip_mention_popup.dart';
export 'widgets/mention_text_editing_controller.dart';
export 'widgets/trip_details_nav_bar.dart';
export 'widgets/trip_hero_header.dart';
export 'widgets/trip_invite_sheet.dart';
export 'widgets/trip_overview_sheet.dart';
export 'widgets/trip_simulation_events_sheet.dart';
export 'widgets/trip_morning_briefing_dialog.dart';
export 'widgets/trip_next_stop_bottom_card.dart';
export 'trip_arrival_screen.dart';
export 'widgets/trip_surprise_plan_sheet.dart';
export 'widgets/trip_cafe_closed_sheet.dart';
export 'widgets/trip_schedule_sync_sheet.dart';
export 'widgets/trip_location_overview_sheet.dart';
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
  final bool isTripStarted;
  final bool hasCompletedCheckin;
  final int currentStopIndex;

  const TripDetailsScreen({
    super.key,
    this.destination = 'Tokyo, Japan',
    this.tripType = 'Group Trip',
    this.startDate,
    this.endDate,
    this.onAllSet,
    this.initialTabIndex = 0,
    this.isTripStarted = false,
    this.hasCompletedCheckin = false,
    this.currentStopIndex = 0,
  });

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  late int _activeTabIndex;
  bool _hasAllSetTriggered = false;
  late bool _isTripStarted;
  late bool _hasCompletedCheckin;
  late int _currentStopIndex;
  int _tripStartVersion = 0;
  bool _hasSurpriseDetourAdded = false;
  bool _hasCafeReplaced = false;
  bool _hasScheduleAdjusted = false;
  bool _hasConflictResolved = false;
  bool _isConflictSimulationActive = false;
  final MentionTextEditingController _chatController = MentionTextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final FocusNode _chatFocusNode = FocusNode();

  bool _showMentionPopup = false;
  String _mentionQuery = '';

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.initialTabIndex;
    _isTripStarted = widget.isTripStarted;
    _hasCompletedCheckin = widget.hasCompletedCheckin || TripTab.hasCheckedInFirstStop;
    _currentStopIndex = widget.currentStopIndex;
    _chatController.addListener(_handleChatTextChange);
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
    _chatController.removeListener(_handleChatTextChange);
    _chatController.dispose();
    _chatScrollController.dispose();
    _chatFocusNode.dispose();
    super.dispose();
  }

  void _handleChatTextChange() {
    final text = _chatController.text;
    final selection = _chatController.selection;
    final cursorPos = selection.isValid && selection.baseOffset >= 0
        ? selection.baseOffset
        : text.length;

    if (cursorPos < 0 || cursorPos > text.length) return;

    final textBefore = text.substring(0, cursorPos);
    final lastAt = textBefore.lastIndexOf('@');

    if (lastAt != -1) {
      final afterAt = textBefore.substring(lastAt + 1);
      if (!afterAt.contains(' ')) {
        if (!_showMentionPopup || _mentionQuery != afterAt) {
          setState(() {
            _showMentionPopup = true;
            _mentionQuery = afterAt;
          });
        }
        return;
      }
    }

    if (_showMentionPopup) {
      setState(() {
        _showMentionPopup = false;
        _mentionQuery = '';
      });
    }
  }

  void _onMentionSelected(MentionItem item) {
    final text = _chatController.text;
    final selection = _chatController.selection;
    final cursorPos = selection.isValid && selection.baseOffset >= 0
        ? selection.baseOffset
        : text.length;

    final textBefore = text.substring(0, cursorPos);
    final lastAt = textBefore.lastIndexOf('@');

    String newText;
    int newCursorPos;

    if (lastAt != -1) {
      final prefix = text.substring(0, lastAt);
      final suffix = text.substring(cursorPos);
      newText = '$prefix${item.tag} $suffix';
      newCursorPos = lastAt + item.tag.length + 1;
    } else {
      newText = '${item.tag} $text';
      newCursorPos = item.tag.length + 1;
    }

    setState(() {
      _chatController.text = newText;
      _chatController.selection = TextSelection.fromPosition(
        TextPosition(offset: newCursorPos),
      );
      _showMentionPopup = false;
      _mentionQuery = '';
    });
    _chatFocusNode.requestFocus();
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
      _showMentionPopup = false;
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

    final lower = text.toLowerCase();
    final hasTravelynMention = lower.contains('@travelyn') || lower.contains('@ travelyn');

    // ONLY activate Travelyn AI response when @Travelyn is mentioned, or during active conflict simulation
    if (!hasTravelynMention && !_isConflictSimulationActive) {
      return;
    }

    final isCafeClosedQuery = lower.contains('closed') ||
        lower.contains('cafe') ||
        lower.contains('coffee') ||
        lower.contains('bread') ||
        lower.contains('espresso') ||
        lower.contains('arashiyama') ||
        lower.contains('bakery') ||
        lower.contains('shut') ||
        lower.contains('not open') ||
        lower.contains('chatei');

    final isTimeLagQuery = lower.contains('late') ||
        lower.contains('delay') ||
        lower.contains('behind') ||
        lower.contains('too much time') ||
        lower.contains('slow') ||
        lower.contains('traffic') ||
        lower.contains('rain') ||
        lower.contains('running late');

    final isConflictQuery = _isConflictSimulationActive ||
        lower.contains('conflict') ||
        lower.contains('what do you think') ||
        lower.contains('think') ||
        lower.contains('agree') ||
        lower.contains('disagree') ||
        lower.contains('resolve') ||
        lower.contains('different') ||
        lower.contains('help') ||
        lower.contains('which one') ||
        lower.contains('what should');

    if (isConflictQuery) {
      _isConflictSimulationActive = false;
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        _postConflictResolutionBotMessage();
      });
    } else if (isCafeClosedQuery) {
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
    } else if (isTimeLagQuery) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        _triggerTimeLagSimulation();
      });
    } else {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        final nowResp = DateTime.now();
        final hourResp = nowResp.hour > 12 ? nowResp.hour - 12 : (nowResp.hour == 0 ? 12 : nowResp.hour);
        final minResp = nowResp.minute.toString().padLeft(2, '0');
        final perResp = nowResp.hour >= 12 ? 'PM' : 'AM';
        final timeStrResp = '$hourResp:$minResp $perResp';

        setState(() {
          _chatMessages.add({
            'sender': 'Travelyn',
            'avatar': 'assets/mascot/avatar.png',
            'message':
                "Got it! 🦊 I'm keeping an eye on our schedule, transit times, and local spots. Let me know if you need alternative recommendations, directions, or plan adjustments!",
            'time': timeStrResp,
            'isBot': true,
            'reactionEmoji': '✨',
            'reactionCount': '1',
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
      });
    }
  }

  void _showInviteSheet() {
    TripInviteSheet.show(context, destination: widget.destination);
  }

  void _showOverviewSheet() {
    TripOverviewSheet.show(context);
  }

  void _triggerResolveConflictSimulation() async {
    // 1. Switch to Chat Tab
    setState(() {
      _activeTabIndex = 0;
    });

    _chatFocusNode.unfocus();

    String getTime(int minutesAgo) {
      final t = DateTime.now().subtract(Duration(minutes: minutesAgo));
      final hour = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
      final min = t.minute.toString().padLeft(2, '0');
      final per = t.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$min $per';
    }

    void scrollToBottom() {
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

    // Delay 1: Alex speaks (User A)
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    HapticFeedback.lightImpact();
    setState(() {
      _chatMessages.add({
        'sender': 'Alex',
        'avatar': 'assets/journey/member_avatar_1.jpg',
        'message':
            "Honestly, I think we should spend way more time thrifting around Harajuku & Cat Street! We can just grab quick street bites instead of sitting down for lunch",
        'time': getTime(3),
        'isBot': false,
      });
    });
    scrollToBottom();

    // Delay 2: Brenda speaks (User B)
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    HapticFeedback.lightImpact();
    setState(() {
      _chatMessages.add({
        'sender': 'Brenda',
        'avatar': 'assets/journey/member_avatar_2.jpg',
        'message':
            "Wait, no way! I really want a sit-down meal at AFURI for proper Yuzu ramen, and we definitely shouldn't rush our peaceful morning stroll through Meiji Shrine!",
        'time': getTime(2),
        'isBot': false,
      });
    });
    scrollToBottom();

    // Delay 3: Charlie speaks (User C)
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    HapticFeedback.lightImpact();
    setState(() {
      _chatMessages.add({
        'sender': 'Charlie',
        'avatar': 'assets/journey/member_avatar_3.jpg',
        'message':
            "Guys, but what about teamLab Planets in Toyosu? If we spend all morning shopping and waiting for ramen, we'll miss our booked entry slot! We should head over earlier!",
        'time': getTime(1),
        'isBot': false,
      });
    });
    scrollToBottom();

    // User's turn to write (like Cafe Closed simulation)
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() {
      _isConflictSimulationActive = true;
      _chatController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatFocusNode.requestFocus();
    });
  }

  void _postConflictResolutionBotMessage() {
    HapticFeedback.mediumImpact();
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final min = now.minute.toString().padLeft(2, '0');
    final per = now.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$min $per';

    final conflictMsg = <String, dynamic>{
      'id': 'conflict_res_${DateTime.now().millisecondsSinceEpoch}',
      'sender': 'Travelyn',
      'avatar': 'assets/mascot/avatar.png',
      'isBot': true,
      'isConflictResolution': true,
      'message':
          "Oh! I detected a conflict between everyone's plans.\n\nNo worries — here's my updated plan to keep everyone happy:",
      'time': timeStr,
      'decision': null,
    };

    setState(() {
      _chatMessages.add(conflictMsg);
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

  void _handleConflictViewPlan(Map<String, dynamic> msg) {
    HapticFeedback.mediumImpact();
    TripConflictApprovalSheet.show(
      context,
      destination: widget.destination,
      onApprove: () {
        _handleConflictApprove(msg);
      },
      onReject: () {
        _handleConflictReject(msg);
      },
    );
  }

  void _handleConflictApprove([Map<String, dynamic>? msg]) {
    if (!mounted) return;
    HapticFeedback.mediumImpact();

    setState(() {
      _hasConflictResolved = true;
      if (msg != null) {
        msg['decision'] = 'approved';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFFA7F3D0), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Conflict resolved! Itinerary updated for everyone',
                style: GoogleFonts.fredoka(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E1C14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
      ),
    );

    // After a smooth delay, switch to Trip Tab to see the updated itinerary!
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _activeTabIndex = 1;
      });
    });
  }

  void _handleConflictReject([Map<String, dynamic>? msg]) {
    if (!mounted) return;
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Keeping original itinerary plan 📋',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.w500, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E1C14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _triggerTimeLagSimulation() {
    TripScheduleSyncSheet.show(
      context,
      onApply: () {
        _handleScheduleApplyFromSheet();
      },
      onDecline: () {
        _handleScheduleDeclineFromSheet();
      },
    );
  }

  void _handleScheduleApplyFromSheet() {
    if (!mounted) return;
    HapticFeedback.mediumImpact();

    setState(() {
      _hasScheduleAdjusted = true;
      _activeTabIndex = 1; // Switch to Trip tab to view the adjusted itinerary
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final messenger = ScaffoldMessenger.maybeOf(context);
        if (messenger != null) {
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFB74D), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Schedule updated! No rush, take your time ⏱️✨",
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

  void _handleScheduleDeclineFromSheet() {
    // Sheet is dismissed without cluttering the chat feed
  }

  void _triggerCafeClosedSimulation() {
    setState(() {
      _activeTabIndex = 0;
      _chatController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatFocusNode.requestFocus();
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleScheduleApply(Map<String, dynamic> msg) {
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';

    setState(() {
      _hasScheduleAdjusted = true;
      _activeTabIndex = 1; // Seamlessly transition user to Trip tab to view updated timeline
      msg['decision'] = 'apply';
      _chatMessages.add({
        'sender': 'Travelyn',
        'avatar': 'assets/mascot/avatar.png',
        'message':
            "All set! ⛩️ Morning schedule updated. Enjoy your stroll without rushing!",
        'time': timeStr,
        'isBot': true,
        'reactionEmoji': '✨',
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
                  const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFB74D), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Schedule updated! No rush, take your time ⏱️✨",
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

  void _handleScheduleKeep(Map<String, dynamic> msg) {
    if (!mounted) return;
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';

    setState(() {
      msg['decision'] = 'keep';
      _chatMessages.add({
        'sender': 'Travelyn',
        'avatar': 'assets/mascot/avatar.png',
        'message':
            "Got it! Keeping your original pace. Let me know if you need any adjustments later ⛩️✨",
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
                  const Icon(Icons.hourglass_top_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Original pace kept • Schedule preserved ⛩️",
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
    final firstPlace = TripTab.getFirstPlace();
    final firstPlaceName = firstPlace?.name ?? 'Meiji Shrine';
    final detourInfo = TripSurprisePlanSheet.getDetailsForNearbyDetour(
      firstPlaceName: firstPlaceName,
    );

    // Present the interactive Moments modal sheet with [Let's go! 🦊] and [Stay on plan]
    final result = await TripSurprisePlanSheet.show(
      context,
      placeName: detourInfo.name,
      distanceText: detourInfo.distance,
      imageAsset: detourInfo.image,
      tags: detourInfo.tags,
      reasoningText: detourInfo.reasoning,
    );
    if (!mounted) return;
    if (result == true) {
      _handleDetourAccept();
    } else if (result == false) {
      _handleDetourDecline();
    }
  }

  void _handleDetourAccept([Map<String, dynamic>? msg]) {
    if (!mounted) return;
    HapticFeedback.mediumImpact();

    setState(() {
      _hasSurpriseDetourAdded = true;
      _isTripStarted = true;
      _hasCompletedCheckin = false;
      _currentStopIndex = 2; // Detour location (Ura-Harajuku Local Market) becomes the next location
      TripTab.currentStopIndex = 2;
      TripTab.hasCheckedInFirstStop = false;
      _tripStartVersion++;
      _activeTabIndex = 1; // Seamlessly transition user to the Trip tab to see the updated route & stop
      if (msg != null) {
        msg['decision'] = 'accept';
      }
    });
  }

  void _handleDetourDecline([Map<String, dynamic>? msg]) {
    if (!mounted) return;
    HapticFeedback.selectionClick();
    if (msg != null) {
      setState(() {
        msg['decision'] = 'stay';
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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

  void _showSimulationEventsSheet() {
    TripSimulationEventsSheet.show(
      context,
      destination: widget.destination,
      onSelectEvent: (eventId) {
        if (eventId == 1) {
          // Simulation 1: Resolve Conflict
          _triggerResolveConflictSimulation();
        } else if (eventId == 2) {
          // Simulation 2: Start Trip -> Show Morning Briefing Popout & re-activate Next Stop card
          setState(() {
            _isTripStarted = true;
            _tripStartVersion++;
            _hasCompletedCheckin = false;
            _currentStopIndex = 0;
            TripTab.hasCheckedInFirstStop = false;
            TripTab.currentStopIndex = 0;
          });
          _triggerMorningBriefing();
        } else if (eventId == 3) {
          // Simulation 3: Arrive at first location -> Show Arrival celebratory page
          _triggerArrivalScreen();
        } else if (eventId == 4) {
          // Simulation 4: Surprise Plan
          setState(() {
            _hasSurpriseDetourAdded = false;
          });
          _triggerSurprisePlanSimulation();
        } else if (eventId == 5) {
          // Simulation 5: Cafe closed
          setState(() {
            _hasCafeReplaced = false;
          });
          _triggerCafeClosedSimulation();
        } else if (eventId == 6) {
          // Simulation 6: Spend too much time on one location
          setState(() {
            _hasScheduleAdjusted = false;
          });
          _triggerTimeLagSimulation();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Selected: Simulation $eventId',
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

  void _triggerArrivalScreen() {
    setState(() {
      _isTripStarted = true;
    });

    final firstPlace = TripTab.getFirstPlace();
    final firstPlaceName = firstPlace?.name ?? 'Meiji Shrine';

    TripArrivalScreen.show(
      context,
      placeName: firstPlaceName,
      location: firstPlace?.location,
      imageAsset: firstPlace?.imageAsset ?? 'assets/journey/place_meiji_shrine.jpg',
      destination: widget.destination,
      tripType: widget.tripType,
      startDate: widget.startDate,
      endDate: widget.endDate,
      preTitle: "We've arrived at",
      tipTitle: "Trippy's tip",
      tipText: TripArrivalScreen.getTipForPlace(firstPlaceName),
      buttonText: "Start Exploring",
      onStartExploring: () {
        final now = DateTime.now();
        final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
        final minute = now.minute.toString().padLeft(2, '0');
        final period = now.hour >= 12 ? 'PM' : 'AM';
        final timeStr = '$hour:$minute $period';

        setState(() {
          _activeTabIndex = 1; // Switch to Trip Tab
          _chatMessages.add({
            'sender': 'Travelyn',
            'avatar': 'assets/mascot/avatar.png',
            'message':
                "🎉 We've arrived at $firstPlaceName! Let's explore together! ⛩️✨",
            'time': timeStr,
            'isBot': true,
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
      },
    );
  }

  void _triggerMorningBriefing() {
    final start = widget.startDate;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateLabel = start != null
        ? '${start.day} ${months[start.month - 1]} 🇯🇵'
        : '15 Sep 🇯🇵';

    TripMorningBriefingDialog.show(
      context,
      destination: widget.destination,
      dayNumber: 1,
      dateLabel: dateLabel,
      stopCount: 4,
      walkDistance: '~4.8 km',
      onLetsGo: () {
        final now = DateTime.now();
        final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
        final minute = now.minute.toString().padLeft(2, '0');
        final period = now.hour >= 12 ? 'PM' : 'AM';
        final timeStr = '$hour:$minute $period';

        setState(() {
          _isTripStarted = true;
          _tripStartVersion++;
          _chatMessages.add({
            'sender': 'Travelyn',
            'avatar': 'assets/mascot/avatar.png',
            'message':
                "Good morning, explorers! ☀️ Day 1 has officially started! Let's head to our first stop: Meiji Shrine ⛩️",
            'time': timeStr,
            'isBot': true,
          });
          _activeTabIndex = 1; // Switch to Trip Tab (Itinerary & Map)
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
      },
    );
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
              onSimulateTap: _showSimulationEventsSheet,
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
                          onScheduleApply: _handleScheduleApply,
                          onScheduleKeep: _handleScheduleKeep,
                          onConflictViewPlan: _handleConflictViewPlan,
                          onConflictApprove: _handleConflictApprove,
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
                          isTripStarted: _isTripStarted,
                          tripStartVersion: _tripStartVersion,
                          hasCompletedCheckin: _hasCompletedCheckin,
                          initialStopIndex: _currentStopIndex,
                          brandOrange: brandOrange,
                          darkBrown: darkBrown,
                          textMuted: textMuted,
                          hasSurpriseDetourAdded: _hasSurpriseDetourAdded,
                          hasCafeReplaced: _hasCafeReplaced,
                          hasScheduleAdjusted: _hasScheduleAdjusted,
                          hasConflictResolved: _hasConflictResolved,
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
                      if (_showMentionPopup) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TripMentionPopup(
                            query: _mentionQuery,
                            onSelected: _onMentionSelected,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (!_hasAllSetTriggered && !_showMentionPopup) ...[
                        TripAllSetButton(
                          onPressed: _onAllSet,
                        ),
                        const SizedBox(height: 8),
                      ],
                      TripChatBottomBar(
                        controller: _chatController,
                        focusNode: _chatFocusNode,
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
