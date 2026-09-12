import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForumSearchFilterBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onClear;

  const ForumSearchFilterBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onFilterTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF9E8E86);

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFEFE6DB),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: darkBrown.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(
            Icons.search_rounded,
            color: textMuted,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: GoogleFonts.nunito(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: darkBrown,
              ),
              decoration: InputDecoration(
                hintText: 'Search discussions, destinations, tips...',
                hintStyle: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textMuted,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onClear?.call();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.0),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: textMuted,
                ),
              ),
            ),
          // Filter tuning button
          GestureDetector(
            onTap: onFilterTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: const Icon(
                Icons.tune_rounded,
                size: 20,
                color: darkBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
