import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modal bottom sheet displaying simulation event triggers:
/// 1. Start Trip
/// 2. Arrive at first location
/// 3. Surprise Plan
/// 4. Cafe closed
/// 5. Spend too much time on one location
class TripSimulationEventsSheet extends StatelessWidget {
  final void Function(String number, String title)? onEventSelected;

  const TripSimulationEventsSheet({
    super.key,
    this.onEventSelected,
  });

  static void show(
    BuildContext context, {
    void Function(String number, String title)? onEventSelected,
  }) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => TripSimulationEventsSheet(
        onEventSelected: onEventSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final simulationEvents = [
      (
        number: '1',
        title: 'Start Trip',
        icon: Icons.play_arrow_rounded,
        color: const Color(0xFFE65100),
      ),
      (
        number: '2',
        title: 'Arrive at first location',
        icon: Icons.location_on_rounded,
        color: const Color(0xFF00B894),
      ),
      (
        number: '3',
        title: 'Surprise Plan',
        icon: Icons.auto_awesome_rounded,
        color: const Color(0xFF2563EB),
      ),
      (
        number: '4',
        title: 'Cafe closed',
        icon: Icons.coffee_rounded,
        color: const Color(0xFFF43F5E),
      ),
      (
        number: '5',
        title: 'Spend too much time on one location',
        icon: Icons.hourglass_bottom_rounded,
        color: const Color(0xFFD97706),
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 28),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF7F0),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFEDE3D7), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E1C14).withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4CDC5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE65100).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded,
                      size: 20,
                      color: Color(0xFFE65100),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Simulate Events',
                          style: GoogleFonts.fredoka(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E1C14),
                          ),
                        ),
                        Text(
                          'Select an event scenario to simulate',
                          style: GoogleFonts.fredoka(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF7A6A60),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFE8DF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Color(0xFF6B5A50),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Event Items List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: simulationEvents.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                itemBuilder: (ctx, index) {
                  final event = simulationEvents[index];
                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).pop();
                        if (onEventSelected != null) {
                          onEventSelected!(event.number, event.title);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Selected: ${event.title}',
                                style: GoogleFonts.fredoka(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: const Color(0xFF2E1C14),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFF0EAE1),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: event.color.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  event.icon,
                                  size: 18,
                                  color: event.color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${event.number}. ${event.title}',
                                style: GoogleFonts.fredoka(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2E1C14),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: Color(0xFFB5A9A0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
