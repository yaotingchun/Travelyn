import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_profile.dart';

/// Visually attractive profile identity section showing avatar, name, username/email,
/// travel identity pills, and single Edit Profile button.
class ProfileIdentityCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEditProfileTap;

  const ProfileIdentityCard({
    super.key,
    required this.profile,
    required this.onEditProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    const brandOrange = Color(0xFFE65100);
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF7A6860);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFEDE4DA),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E1C14).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Prominent Circular Avatar with layered soft ring
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFCC80),
                        Color(0xFFFF8A50),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: brandOrange.withValues(alpha: 0.20),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF3E0),
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    profile.avatarPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFFFE0B2),
                        alignment: Alignment.center,
                        child: Text(
                          profile.name.isNotEmpty ? profile.name[0] : 'E',
                          style: GoogleFonts.fredoka(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: brandOrange,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF43A047),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.2),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // User Name & Username/Email
          Text(
            profile.name,
            style: GoogleFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: darkBrown,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            profile.username,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: brandOrange,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            profile.email,
            style: GoogleFonts.nunito(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 12),

          // Bio
          if (profile.bio.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                profile.bio,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: darkBrown,
                  height: 1.3,
                ),
              ),
            ),
          const SizedBox(height: 14),

          // Travel Identity Badges
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: profile.travelIdentities.map((identity) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF6EE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFFDEC9),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  identity,
                  style: GoogleFonts.fredoka(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFBF360C),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: onEditProfileTap,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: Text(
                'Edit Profile',
                style: GoogleFonts.fredoka(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFAF7F2),
                foregroundColor: darkBrown,
                elevation: 0,
                side: const BorderSide(
                  color: Color(0xFFE5DDD3),
                  width: 1.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
