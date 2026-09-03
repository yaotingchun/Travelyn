import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/realistic_push_pin.dart';

/// Tab 0: Chat Tab
/// Features the pinned trip overview card, Trippy welcome card,
/// interactive chat messages feed with rich text, reactions, and avatars.
class ChatTab extends StatefulWidget {
  final String destination;
  final List<Map<String, dynamic>> messages;
  final ScrollController scrollController;
  final VoidCallback? onOverviewTap;
  final Color brandOrange;
  final Color darkBrown;
  final Color textMuted;

  const ChatTab({
    super.key,
    this.destination = 'Tokyo, Japan',
    required this.messages,
    required this.scrollController,
    this.onOverviewTap,
    this.brandOrange = const Color(0xFFE65100),
    this.darkBrown = const Color(0xFF2E1C14),
    this.textMuted = const Color(0xFF6B5A50),
  });

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. "Pinned by Travelyn" Card (Narrower than navbar, aligned with chat messages)
          GestureDetector(
            onTap: widget.onOverviewTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Card Body
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBF7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFEDE3D7),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.darkBrown.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left Column: Pinned tag, Title, Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Top Pin Tag: Orange pushpin + "Pinned by Travelyn"
                            Row(
                              children: [
                                Transform.rotate(
                                  angle: -0.4,
                                  child: const Icon(
                                    Icons.push_pin_rounded,
                                    size: 15,
                                    color: Color(0xFFE65100),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Pinned by Travelyn',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFB8582B),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 7),

                            // Title
                            Text(
                              'Tokyo Trip Overview',
                              style: GoogleFonts.fredoka(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: widget.darkBrown,
                                letterSpacing: -0.3,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Subtitle
                            Text(
                              'Tap to explore your trip highlights',
                              style: GoogleFonts.fredoka(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: widget.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Right Tokyo Skyline Thumbnail Image
                      Container(
                        width: 86,
                        height: 66,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: widget.darkBrown.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            'assets/home/hero_tokyo.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, st) {
                              return Container(
                                color: const Color(0xFFE8DFD5),
                                child: const Icon(
                                  Icons.image_outlined,
                                  color: Color(0xFF6B5A50),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Exact realistic 3D black pushpin pinning the top-right corner
                const Positioned(
                  top: -6,
                  right: -4,
                  child: RealisticPushPin(size: 32),
                ),
              ],
            ),
          ),

          // Group Chat Feed
          if (widget.messages.isNotEmpty) ...[
            const SizedBox(height: 20),
            ...widget.messages.map(
              (msg) => _buildChatMessageItem(
                msg,
                widget.darkBrown,
                widget.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChatMessageItem(
    Map<String, dynamic> msg,
    Color darkBrown,
    Color textMuted,
  ) {
    final isMe = msg['sender'] == 'You';

    if (isMe) {
      return _buildOutgoingMessage(msg, darkBrown);
    }

    final isBot = msg['isBot'] as bool? ?? false;
    return _buildIncomingMessage(msg, isBot, darkBrown, textMuted);
  }

  /// Modern, compact outgoing speech bubble with warm sunset terracotta styling
  Widget _buildOutgoingMessage(Map<String, dynamic> msg, Color darkBrown) {
    final text = msg['message'] as String;
    final time = msg['time'] as String? ?? '';
    final isShort = text.length <= 22 && !text.contains('\n');

    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.74,
            minWidth: 70.0,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE85A1C), Color(0xFFF2742E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE85A1C).withValues(alpha: 0.22),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: isShort
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        text,
                        style: GoogleFonts.fredoka(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            time,
                            style: GoogleFonts.fredoka(
                              fontSize: 10.5,
                              color: Colors.white.withValues(alpha: 0.82),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            Icons.done_all_rounded,
                            size: 13,
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        text,
                        style: GoogleFonts.fredoka(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            time,
                            style: GoogleFonts.fredoka(
                              fontSize: 10.5,
                              color: Colors.white.withValues(alpha: 0.82),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            Icons.done_all_rounded,
                            size: 13,
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  /// Incoming speech bubble matching exact Trippy reference styling and colors
  Widget _buildIncomingMessage(
    Map<String, dynamic> msg,
    bool isBot,
    Color darkBrown,
    Color textMuted,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Mascot Avatar (42x42 circle)
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: ClipOval(
              child: Image.asset(
                msg['avatar'] as String,
                width: 42,
                height: 42,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => Container(
                  width: 42,
                  height: 42,
                  color: const Color(0xFFE8DFD5),
                  child: const Icon(
                    Icons.pets_rounded,
                    size: 22,
                    color: Color(0xFF6B5A50),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Content: Sender Name + Speech Bubble Card
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.74,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sender Name (above the bubble)
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 5.0),
                  child: Text(
                    msg['sender'] as String,
                    style: GoogleFonts.fredoka(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: isBot
                          ? const Color(0xFFE65100)
                          : const Color(0xFF2E1C14),
                    ),
                  ),
                ),

                // Speech Bubble Card matching exact reference colors & rounding
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF8F3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(
                      color: const Color(0xFFEFE6DC),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: darkBrown.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Message Text (with rich formatting for 'Tokyo adventure')
                      _buildMessageText(
                        msg['message'] as String,
                        const Color(0xFF2E1C14),
                      ),

                      // Bottom Row: Reaction Pill + Timestamp
                      if (msg['reactionEmoji'] != null ||
                          msg['time'] != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Reaction Pill
                            if (msg['reactionEmoji'] != null)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    final current = int.tryParse(
                                            msg['reactionCount']?.toString() ??
                                                '12') ??
                                        12;
                                    final reacted =
                                        msg['userReacted'] == true;
                                    msg['userReacted'] = !reacted;
                                    msg['reactionCount'] = (reacted
                                            ? current - 1
                                            : current + 1)
                                        .toString();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3E9DF),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        msg['reactionEmoji'] as String,
                                        style:
                                            const TextStyle(fontSize: 12.5),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        msg['reactionCount'] as String,
                                        style: GoogleFonts.fredoka(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF382319),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              const SizedBox(),

                            const SizedBox(width: 14),

                            // Timestamp
                            if (msg['time'] != null)
                              Text(
                                msg['time'] as String,
                                style: GoogleFonts.fredoka(
                                  fontSize: 11.5,
                                  color: const Color(0xFFA69588),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Formats message text with bold emphasis on key phrases like 'Tokyo adventure'
  Widget _buildMessageText(String message, Color defaultColor) {
    if (message.contains('Tokyo adventure')) {
      final parts = message.split('Tokyo adventure');
      return RichText(
        text: TextSpan(
          style: GoogleFonts.fredoka(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            color: defaultColor,
            height: 1.35,
          ),
          children: [
            TextSpan(text: parts[0]),
            const TextSpan(
              text: 'Tokyo adventure',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            if (parts.length > 1) TextSpan(text: parts[1]),
          ],
        ),
      );
    }
    return Text(
      message,
      style: GoogleFonts.fredoka(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: defaultColor,
        height: 1.35,
      ),
    );
  }
}
