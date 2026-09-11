import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tabs/trip_tab.dart';

/// Floating bottom card displaying the next upcoming location in the trip.
/// Matches the reference design with thumbnail, "Next Stop" tag, place title,
/// and time range (e.g. "09:00 - 10:00").
/// Can be dismissed smoothly by dragging down.
class TripNextStopBottomCard extends StatefulWidget {
  final ItineraryCardItem place;
  final String nextStopLabel;
  final String timeRange;
  final VoidCallback? onDismissed;
  final VoidCallback? onTap;

  const TripNextStopBottomCard({
    super.key,
    required this.place,
    this.nextStopLabel = 'Next Stop',
    required this.timeRange,
    this.onDismissed,
    this.onTap,
  });

  @override
  State<TripNextStopBottomCard> createState() => _TripNextStopBottomCardState();
}

class _TripNextStopBottomCardState extends State<TripNextStopBottomCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  double _dragOffset = 0.0;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 1.5),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInCubic,
    ));
  }

  @override
  void didUpdateWidget(covariant TripNextStopBottomCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.place.id != widget.place.id) {
      if (_isDismissed) {
        setState(() {
          _isDismissed = false;
          _dragOffset = 0.0;
        });
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isDismissed) return;
    if (details.delta.dy > 0 || _dragOffset > 0) {
      setState(() {
        _dragOffset = (_dragOffset + details.delta.dy).clamp(0.0, 160.0);
      });
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isDismissed) return;
    if (_dragOffset > 32.0 || (details.primaryVelocity ?? 0) > 250.0) {
      _dismissCard();
    } else {
      setState(() {
        _dragOffset = 0.0;
      });
    }
  }

  void _dismissCard() {
    HapticFeedback.lightImpact();
    setState(() {
      _isDismissed = true;
    });
    _controller.forward().then((_) {
      if (widget.onDismissed != null) {
        widget.onDismissed!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed && _controller.isCompleted) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: Transform.translate(
        offset: Offset(0.0, _dragOffset),
        child: GestureDetector(
          onVerticalDragUpdate: _onDragUpdate,
          onVerticalDragEnd: _onDragEnd,
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF7),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFEDE3D7),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E1C14).withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Pill Drag Handle Indicator
                  Center(
                    child: Container(
                      width: 36,
                      height: 4.5,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8D0C7),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),

                  // Content Row: Thumbnail + Next Stop text details
                  Row(
                    children: [
                      // Location Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: 52,
                          height: 52,
                          child: Image.asset(
                            widget.place.imageAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, st) {
                              return Container(
                                color: const Color(0xFFE8DFD5),
                                child: const Icon(
                                  Icons.place_rounded,
                                  color: Color(0xFF9E8E82),
                                  size: 24,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Text column: Next Stop, Title, Time Range
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.nextStopLabel,
                              style: GoogleFonts.fredoka(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFB8582B),
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              widget.place.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.fredoka(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2E1C14),
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.timeRange,
                              style: GoogleFonts.fredoka(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF7A6A60),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Drag down dismiss chevron hint
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFFB5A9A0),
                        size: 22,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
