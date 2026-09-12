import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'trip_next_location_screen.dart';

/// Rating option definition matching the reference UI
enum TripRating {
  terrible(
    label: 'Terrible',
    assetPath: 'assets/journey/mascot_terrible.png',
  ),
  notGreat(
    label: 'Not great',
    assetPath: 'assets/journey/mascot_meh.png',
  ),
  okay(
    label: 'Okay',
    assetPath: 'assets/journey/mascot_okay.png',
  ),
  great(
    label: 'Great',
    assetPath: 'assets/journey/mascot_great.png',
  ),
  amazing(
    label: 'Amazing',
    assetPath: 'assets/journey/mascot_amazing.png',
  );

  final String label;
  final String assetPath;

  const TripRating({
    required this.label,
    required this.assetPath,
  });
}

/// Feedback data collected upon submission
class TripFeedbackData {
  final String placeName;
  final TripRating rating;
  final String comment;
  final Uint8List? attachedImageBytes;
  final String? attachedImagePath;

  const TripFeedbackData({
    required this.placeName,
    required this.rating,
    this.comment = '',
    this.attachedImageBytes,
    this.attachedImagePath,
  });
}

/// Feedback Screen shown after tapping "Move to next location".
/// Matches the reference UI layout:
/// - Vertically centered composition
/// - Top Title: "How was\n[Place Name]?"
/// - Center Mascot: `mascot_feedback.png` resting flush against the rating card with 0 padding
/// - Rating Card: 5 rating mascots with generous height
/// - Experience Card: "Share your experience...", text input, photo icon,
///   with the "Submit ✨" button sticking inside at the bottom and a slightly transparent bottom gradient
class TripFeedbackScreen extends StatefulWidget {
  final String placeName;
  final TripRating initialRating;
  final ValueChanged<TripFeedbackData>? onFeedbackSubmitted;
  final String? nextPlaceName;
  final String? nextLocation;
  final String? nextImageAsset;
  final String? nextWalkTime;
  final String? nextCategory;
  final String? nextDescription;
  final int? nextStopNumber;

  const TripFeedbackScreen({
    super.key,
    required this.placeName,
    this.initialRating = TripRating.amazing,
    this.onFeedbackSubmitted,
    this.nextPlaceName,
    this.nextLocation,
    this.nextImageAsset,
    this.nextWalkTime,
    this.nextCategory,
    this.nextDescription,
    this.nextStopNumber,
  });

  /// Presents the TripFeedbackScreen with a smooth slide and fade transition.
  static Future<bool?> show(
    BuildContext context, {
    required String placeName,
    TripRating initialRating = TripRating.amazing,
    ValueChanged<TripFeedbackData>? onFeedbackSubmitted,
    String? nextPlaceName,
    String? nextLocation,
    String? nextImageAsset,
    String? nextWalkTime,
    String? nextCategory,
    String? nextDescription,
    int? nextStopNumber,
  }) {
    HapticFeedback.mediumImpact();
    return Navigator.of(context).push<bool>(
      PageRouteBuilder<bool>(
        pageBuilder: (ctx, anim, secAnim) => TripFeedbackScreen(
          placeName: placeName,
          initialRating: initialRating,
          onFeedbackSubmitted: onFeedbackSubmitted,
          nextPlaceName: nextPlaceName,
          nextLocation: nextLocation,
          nextImageAsset: nextImageAsset,
          nextWalkTime: nextWalkTime,
          nextCategory: nextCategory,
          nextDescription: nextDescription,
          nextStopNumber: nextStopNumber,
        ),
        transitionsBuilder: (ctx, anim, secAnim, child) {
          final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.06),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  @override
  State<TripFeedbackScreen> createState() => _TripFeedbackScreenState();
}

class _TripFeedbackScreenState extends State<TripFeedbackScreen> {
  late TripRating _selectedRating;
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  XFile? _attachedPhoto;
  Uint8List? _attachedPhotoBytes;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.initialRating;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  /// Formats place name cleanly (e.g. "Senso-ji Temple & Asakusa" -> "Senso-ji Temple")
  String get _displayPlaceName {
    var name = widget.placeName.trim();
    if (name.contains(' & ') && name.length > 20) {
      name = name.split(' & ').first.trim();
    }
    if (name.endsWith('?')) {
      name = name.substring(0, name.length - 1).trim();
    }
    return name;
  }

  Future<void> _handleAttachPhoto() async {
    HapticFeedback.selectionClick();
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _attachedPhoto = photo;
          _attachedPhotoBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _handleRemovePhoto() {
    HapticFeedback.selectionClick();
    setState(() {
      _attachedPhoto = null;
      _attachedPhotoBytes = null;
    });
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    HapticFeedback.mediumImpact();

    setState(() {
      _isSubmitting = true;
    });

    final data = TripFeedbackData(
      placeName: widget.placeName,
      rating: _selectedRating,
      comment: _commentController.text.trim(),
      attachedImageBytes: _attachedPhotoBytes,
      attachedImagePath: _attachedPhoto?.path,
    );

    widget.onFeedbackSubmitted?.call(data);

    if (widget.nextPlaceName != null && mounted) {
      // Redirect to Next Location Page and await its result
      final nextResult = await Navigator.of(context).push<bool>(
        PageRouteBuilder<bool>(
          pageBuilder: (ctx, anim, secAnim) => TripNextLocationScreen(
            placeName: widget.nextPlaceName!,
            location: widget.nextLocation,
            imageAsset: widget.nextImageAsset,
            walkTime: widget.nextWalkTime,
            category: widget.nextCategory,
            description: widget.nextDescription,
            stopNumber: widget.nextStopNumber,
          ),
          transitionsBuilder: (ctx, anim, secAnim, child) {
            final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.06),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 320),
        ),
      );

      if (mounted) {
        // Pop the feedback screen returning the result from Next Location Page
        Navigator.of(context).pop(nextResult ?? false);
      }
    } else {
      // Pop screen with true (indicating successful submission to advance location)
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F5),
      body: Stack(
        children: [
          // 1. Soft warm ambient gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFAF6F2),
                    Color(0xFFFFECE0),
                    Color(0xFFFFF7F0),
                    Color(0xFFFAF3EC),
                  ],
                  stops: [0.0, 0.35, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // 2. Main Centered Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 16,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 14),

                          // Header: "How was\n[PlaceName]?"
                          Text(
                            'How was\n$_displayPlaceName?',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.fredoka(
                              fontSize: 27,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2E1C14),
                              height: 1.22,
                              letterSpacing: -0.2,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Big Mascot Section resting flush against the rating card (no padding)
                          Transform.translate(
                            offset: const Offset(0, 4),
                            child: _buildMascotSection(),
                          ),

                          // Rating Card (Terrible, Not great, Okay, Great, Amazing)
                          _buildRatingCard(),

                          const SizedBox(height: 14),

                          // Combined Experience Card with Submit button sticking inside
                          _buildExperienceCard(),

                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 3. Subtle Top-Left Back Chevron
          Positioned(
            top: topPadding + 6,
            left: 14,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop(false);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.65),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E1C14).withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: Color(0xFF4A3E38),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Big Mascot with 4-Point Golden Sparkle Stars & Delicate Petals, aligned flush to the bottom
  Widget _buildMascotSection() {
    return SizedBox(
      height: 205,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Background Sparkles positioned matching the mockup
          const Positioned(
            left: 28,
            top: 36,
            child: _DiamondSparkle(size: 20, color: Color(0xFFFDB528)),
          ),
          const Positioned(
            left: 32,
            bottom: 30,
            child: _DiamondSparkle(size: 26, color: Color(0xFFFDB528)),
          ),
          const Positioned(
            right: 36,
            top: 34,
            child: _DiamondSparkle(size: 24, color: Color(0xFFFDB528)),
          ),
          const Positioned(
            right: 28,
            bottom: 46,
            child: _DiamondSparkle(size: 17, color: Color(0xFFFDB528)),
          ),

          // Delicate floating blossom petals
          Positioned(
            left: 24,
            top: 8,
            child: _PetalDot(color: const Color(0xFFF7B9AB).withValues(alpha: 0.65), size: 6.5, rotation: 0.3),
          ),
          Positioned(
            right: 32,
            top: 10,
            child: _PetalDot(color: const Color(0xFFF7B9AB).withValues(alpha: 0.6), size: 5.5, rotation: -0.4),
          ),
          Positioned(
            right: 20,
            top: 75,
            child: _PetalDot(color: const Color(0xFFF7B9AB).withValues(alpha: 0.55), size: 7.0, rotation: 0.5),
          ),

          // Big Feedback Mascot
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              'assets/journey/mascot_feedback.png',
              height: 205,
              fit: BoxFit.contain,
              errorBuilder: (ctx, err, st) {
                return Container(
                  height: 180,
                  width: 180,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF8E7DB),
                  ),
                  child: const Center(
                    child: Icon(Icons.star_rounded, size: 64, color: Color(0xFFE24A08)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Soft Warm Translucent Rating Card with 5 Mascot Choices
  Widget _buildRatingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFFDF9).withValues(alpha: 0.75),
            const Color(0xFFFFF6ED).withValues(alpha: 0.65),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF382318).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: TripRating.values.map((rating) {
          final isSelected = rating == _selectedRating;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedRating = rating;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular Highlight Ring for Selected Mascot
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? const Color(0xFFEFE8DE).withValues(alpha: 0.75)
                          : Colors.transparent,
                      border: isSelected
                          ? Border.all(
                              color: const Color(0xFFDFD6C9).withValues(alpha: 0.8),
                              width: 1.5,
                            )
                          : Border.all(
                              color: Colors.transparent,
                              width: 1.5,
                            ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF2E1C14).withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutBack,
                        scale: isSelected ? 1.05 : 0.95,
                        child: Image.asset(
                          rating.assetPath,
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, err, st) {
                            return const Icon(
                              Icons.sentiment_satisfied_alt_rounded,
                              size: 28,
                              color: Color(0xFFB5ADA4),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Rating Label (Selected is bold orange, unselected is brown/charcoal)
                  Text(
                    rating.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fredoka(
                      fontSize: 12.0,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFFE24A08)
                          : const Color(0xFF3B2E28),
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Soft Warm Translucent Experience Card with Submit button sticking inside
  Widget _buildExperienceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFFDF9).withValues(alpha: 0.78),
            const Color(0xFFFFF6EE).withValues(alpha: 0.65),
            const Color(0xFFFFF0E3).withValues(alpha: 0.40),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF382318).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Share your experience..."
          Text(
            'Share your experience...',
            style: GoogleFonts.fredoka(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2E1C14),
              letterSpacing: -0.1,
            ),
          ),

          const SizedBox(height: 4),

          // Multi-line Text Input
          TextField(
            controller: _commentController,
            maxLines: 3,
            minLines: 2,
            style: GoogleFonts.fredoka(
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF2E1C14),
              height: 1.35,
            ),
            cursorColor: const Color(0xFFE24A08),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              hintText: 'What did you love or not love?',
              hintStyle: GoogleFonts.fredoka(
                fontSize: 14.5,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFBDB4AC),
              ),
            ),
          ),

          // Attached Image Thumbnail Preview if selected
          if (_attachedPhotoBytes != null) ...[
            const SizedBox(height: 8),
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _attachedPhotoBytes!,
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: GestureDetector(
                    onTap: _handleRemovePhoto,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E1C14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Photo Icon aligned to the right
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleAttachPhoto,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.image_outlined,
                    size: 24,
                    color: _attachedPhotoBytes != null
                        ? const Color(0xFFE24A08)
                        : const Color(0xFF4A3E38),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Submit Button sticking inside the card!
          _buildSubmitButton(),
        ],
      ),
    );
  }

  /// Vibrant Orange "Submit ✨" Pill Button inside the Experience Card
  Widget _buildSubmitButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isSubmitting ? null : _handleSubmit,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFFF05A22),
                Color(0xFFE24A08),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE24A08).withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.2,
                    ),
                  )
                : Text(
                    'Submit ✨',
                    style: GoogleFonts.fredoka(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// 4-Point Concave Diamond Sparkle Star (Anime / Japanese Sticker style)
class _DiamondSparkle extends StatelessWidget {
  final double size;
  final Color color;

  const _DiamondSparkle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.3),
      painter: _DiamondSparklePainter(color: color),
    );
  }
}

class _DiamondSparklePainter extends CustomPainter {
  final Color color;
  const _DiamondSparklePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    final path = Path();
    path.moveTo(cx, 0);
    path.quadraticBezierTo(cx, cy, w, cy);
    path.quadraticBezierTo(cx, cy, cx, h);
    path.quadraticBezierTo(cx, cy, 0, cy);
    path.quadraticBezierTo(cx, cy, cx, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DiamondSparklePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Soft Floating Blossom Petal Dot
class _PetalDot extends StatelessWidget {
  final Color color;
  final double size;
  final double rotation;

  const _PetalDot({
    required this.color,
    required this.size,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size,
        height: size * 1.5,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size),
        ),
      ),
    );
  }
}
