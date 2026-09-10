import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper for launching external booking URLs using in-app browser view (Chrome Custom Tabs on Android,
/// SFSafariViewController on iOS) to preserve the app's full state, selections, and cookies when returning.
class UrlHelper {
  static Future<void> launchExternalUrl(
    BuildContext context,
    String url, {
    LaunchMode preferredMode = LaunchMode.inAppBrowserView,
  }) async {
    final Uri uri = Uri.parse(url);

    try {
      bool launched = false;

      // 1. Try preferred mode (inAppBrowserView: Chrome Custom Tabs / Safari View Controller)
      // which keeps the user in the app task and preserves state 100%.
      try {
        launched = await launchUrl(
          uri,
          mode: preferredMode,
        );
      } catch (e) {
        debugPrint('preferred mode $preferredMode failed, falling back to external: $e');
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }

      debugPrint('UrlHelper launch result for $url: $launched');

      if (!launched && context.mounted) {
        _showFallback(context, url);
      }
    } catch (e) {
      debugPrint('Failed to launch URL: $e');

      if (context.mounted) {
        _showFallback(context, url);
      }
    }
  }

  static void _showFallback(
    BuildContext context,
    String urlString,
  ) {
    final isKlook = urlString.toLowerCase().contains('klook');
    final platformName = isKlook ? 'Klook' : 'Booking Platform';
    final brandColor = isKlook ? const Color(0xFFFF5722) : const Color(0xFFE65100);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: const BoxDecoration(
            color: Color(0xFFFFFBF7),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBC9B8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: brandColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.open_in_new_rounded,
                      color: brandColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Redirect to $platformName',
                          style: GoogleFonts.fredoka(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E1C14),
                          ),
                        ),
                        Text(
                          'Complete your booking in browser',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF8A766E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFE6DC),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF6B5A50)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Link Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7EFE6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEDE3D7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 13, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 5),
                        Text(
                          'Verified $platformName Booking Link',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SelectableText(
                      urlString,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3E2D24),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action Buttons Row: Retry Launch & Copy Link
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        try {
                          await launchUrl(
                            Uri.parse(urlString),
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (_) {}
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: Text(
                        'Retry Open',
                        style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: brandColor, width: 1.2),
                        foregroundColor: brandColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: urlString));
                        HapticFeedback.selectionClick();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  '$platformName link copied! 📋',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF2E7D32),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: Text(
                        'Copy Link',
                        style: GoogleFonts.fredoka(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Dismiss Button
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Close',
                    style: GoogleFonts.fredoka(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8A766E),
                    ),
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
