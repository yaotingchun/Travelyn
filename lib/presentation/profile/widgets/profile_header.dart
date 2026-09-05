import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Top header for the Me Profile screen with title and settings gear.
class ProfileHeader extends StatelessWidget {
  final VoidCallback onSettingsTap;

  const ProfileHeader({
    super.key,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'My Profile',
            style: GoogleFonts.fredoka(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: darkBrown,
              letterSpacing: -0.5,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSettingsTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7F2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE8DFD5),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E1C14).withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  color: Color(0xFF2E1C14),
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
