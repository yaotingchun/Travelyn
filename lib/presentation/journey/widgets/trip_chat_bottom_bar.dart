import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Illustrated Japanese clipboard chatbox with base_layer_chatbox as the base layer.
/// Centralized, naturally blended, and sized with comfortable touch targets.
class TripChatBottomBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const TripChatBottomBar({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        // Aspect ratio of base_layer_chatbox.png: 1940 / 528 ≈ 3.674
        final barHeight = (barWidth / 3.674).clamp(94.0, 118.0);
        const pillHeight = 48.0;

        return SizedBox(
          width: barWidth,
          height: barHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // 1. Transparent Base Layer Image underneath the chatbox
              Positioned.fill(
                child: Image.asset(
                  'assets/journey/base_layer_chatbox.png',
                  fit: BoxFit.fill,
                  errorBuilder: (ctx, err, st) {
                    return Image.asset(
                      'assets/journey/base_layer_chatbox.jpg',
                      fit: BoxFit.fill,
                    );
                  },
                ),
              ),

              // 2. Naturally Blended & Perfectly Centralized Pill Input Field
              Positioned(
                left: barWidth * 0.128, // Symmetrically centered between stamps
                right: barWidth * 0.128,
                top: (barHeight - pillHeight) * 0.5 + 0.5, // Centered vertically on parchment
                height: pillHeight,
                child: Container(
                  padding: const EdgeInsets.only(left: 16, right: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF8F2).withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFEADBCE).withValues(alpha: 0.70),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF382315).withValues(alpha: 0.03),
                        blurRadius: 5,
                        offset: const Offset(0, 1.5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Text input field
                      Expanded(
                        child: TextField(
                          controller: controller,
                          style: GoogleFonts.fredoka(
                            fontSize: 14.5,
                            color: const Color(0xFF2E1C14),
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Say something...',
                            hintStyle: GoogleFonts.fredoka(
                              fontSize: 14.0,
                              color: const Color(0xFFA69385),
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onSubmitted: (_) => onSend(),
                        ),
                      ),

                      // 1. Photo / Gallery Icon
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Photo attachment coming soon!',
                                style: GoogleFonts.fredoka(color: Colors.white),
                              ),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFCF0E4),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 20.5,
                              color: Color(0xFF743414),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      // 2. Mic / Voice / Send Icon
                      AnimatedBuilder(
                        animation: controller,
                        builder: (context, _) {
                          final hasText = controller.text.trim().isNotEmpty;
                          return GestureDetector(
                            onTap: () {
                              if (hasText) {
                                onSend();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Voice input coming soon!',
                                      style: GoogleFonts.fredoka(
                                        color: Colors.white,
                                      ),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFCF0E4),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  hasText
                                      ? Icons.arrow_upward_rounded
                                      : Icons.mic_none_rounded,
                                  size: 21.0,
                                  color: const Color(0xFF743414),
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
            ],
          ),
        );
      },
    );
  }
}
