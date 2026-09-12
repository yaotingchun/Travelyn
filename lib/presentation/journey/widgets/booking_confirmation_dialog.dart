import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Interactive pop-out dialog that asks the user whether they completed
/// their booking after clicking "Book on [Platform]", rather than automatically
/// changing the status to selected/booked.
class BookingConfirmationDialog extends StatelessWidget {
  final String title;
  final String itemName;
  final String platformName;
  final Color platformBrandColor;
  final IconData headerIcon;
  final String confirmText;
  final String notYetText;
  final VoidCallback onAlreadyBooked;
  final VoidCallback? onNotYetBooked;
  final Color brandOrange;
  final Color darkBrown;

  const BookingConfirmationDialog({
    super.key,
    this.title = 'Did you complete your booking?',
    required this.itemName,
    required this.platformName,
    required this.platformBrandColor,
    this.headerIcon = Icons.hotel_rounded,
    this.confirmText = 'Already booked',
    this.notYetText = "Haven't booked yet",
    required this.onAlreadyBooked,
    this.onNotYetBooked,
    this.brandOrange = const Color(0xFFE65100),
    this.darkBrown = const Color(0xFF2E1C14),
  });

  /// Displays the stylish pop-out confirmation dialog with smooth scale/fade animation.
  static Future<void> show({
    required BuildContext context,
    String title = 'Did you complete your booking?',
    required String itemName,
    required String platformName,
    required Color platformBrandColor,
    IconData headerIcon = Icons.hotel_rounded,
    String confirmText = 'Already booked',
    String notYetText = "Haven't booked yet",
    required VoidCallback onAlreadyBooked,
    VoidCallback? onNotYetBooked,
    Color brandOrange = const Color(0xFFE65100),
    Color darkBrown = const Color(0xFF2E1C14),
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Booking Confirmation',
      barrierColor: Colors.black.withValues(alpha: 0.52),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (ctx, anim1, anim2) {
        return BookingConfirmationDialog(
          title: title,
          itemName: itemName,
          platformName: platformName,
          platformBrandColor: platformBrandColor,
          headerIcon: headerIcon,
          confirmText: confirmText,
          notYetText: notYetText,
          onAlreadyBooked: onAlreadyBooked,
          onNotYetBooked: onNotYetBooked,
          brandOrange: brandOrange,
          darkBrown: darkBrown,
        );
      },
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.88,
          constraints: const BoxConstraints(maxWidth: 380),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF9),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFEDE3D7), width: 1.3),
            boxShadow: [
              BoxShadow(
                color: darkBrown.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Header Icon in soft circular accent
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: brandOrange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  headerIcon,
                  color: brandOrange,
                  size: 30,
                ),
              ),

              const SizedBox(height: 12),

              // 2. Platform Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: platformBrandColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: platformBrandColor.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 11.5,
                      color: platformBrandColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      platformName,
                      style: GoogleFonts.fredoka(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: platformBrandColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 3. Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: darkBrown,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 8),

              // 4. Subtitle & Context
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.nunito(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B5A50),
                    height: 1.45,
                  ),
                  children: [
                    const TextSpan(text: 'Let us know if your booking for\n'),
                    TextSpan(
                      text: itemName,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        color: darkBrown,
                      ),
                    ),
                    const TextSpan(text: ' was completed on '),
                    TextSpan(
                      text: platformName,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        color: platformBrandColor,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // 5. Button 1: Already Booked (Confirm & Select Stay)
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    onAlreadyBooked();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        confirmText,
                        style: GoogleFonts.fredoka(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 6. Button 2: Haven't Booked Yet (Do not select stay)
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFDCCFC3), width: 1.2),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    if (onNotYetBooked != null) {
                      onNotYetBooked!();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: Color(0xFF6B5A50),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        notYetText,
                        style: GoogleFonts.fredoka(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B5A50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
