import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modal bottom sheet to invite friends and travel companions to collaborate on the trip.
class TripInviteSheet extends StatelessWidget {
  final String destination;

  const TripInviteSheet({
    super.key,
    required this.destination,
  });

  static Future<void> show(BuildContext context, {required String destination}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TripInviteSheet(destination: destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clean = destination.replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase();
    final prefix = clean.length >= 3 ? clean.substring(0, 3) : 'TOK';
    final inviteCode = '${prefix}925';
    final inviteLink = 'travelyn.com/invite/$inviteCode';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFFDF7F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDBC9B8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Trip Members',
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2E1C14),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Invite travel companions to collaborate on $destination.',
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF6B5A50),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEDE3D7)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.link_rounded,
                  color: Color(0xFFE65100),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    inviteLink,
                    style: GoogleFonts.fredoka(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2E1C14),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: 'https://$inviteLink'));
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Invite link copied to clipboard!',
                          style: GoogleFonts.fredoka(color: Colors.white),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF2E1C14),
                        duration: const Duration(seconds: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1E6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Copy',
                      style: GoogleFonts.fredoka(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE65100),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
