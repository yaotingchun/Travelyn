import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/forum_post_model.dart';

class ForumPostCard extends StatelessWidget {
  final ForumPost post;
  final VoidCallback onTap;
  final VoidCallback onLikeTap;

  const ForumPostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);
    const contentColor = Color(0xFF6E5D55);
    const textMuted = Color(0xFF8F7F77);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F2),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFEFE6DB),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: darkBrown.withValues(alpha: 0.035),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left content column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Tag pill badge
                  _buildTagBadge(post.tagType, post.tagLabel),
                  const SizedBox(height: 7),

                  // 2. Title
                  Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fredoka(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: darkBrown,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // 3. Excerpt
                  Text(
                    post.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: contentColor,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 4. Bottom row: avatars + author/time + comment count
                  Row(
                    children: [
                      _buildAvatarsStack(),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'by ${post.authorName} • ${post.timeAgo}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: textMuted,
                          ),
                        ),
                      ),
                      // Comments count bubble matching mockup (💬 48)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 14,
                            color: textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post.commentsCount}',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      // Upvote heart
                      GestureDetector(
                        onTap: onLikeTap,
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              post.isLiked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 14,
                              color: post.isLiked
                                  ? const Color(0xFFE53935)
                                  : textMuted,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${post.likesCount}',
                              style: GoogleFonts.nunito(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: post.isLiked
                                    ? const Color(0xFFE53935)
                                    : textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Right side rounded thumbnail image
            if (post.imagePath != null && post.imagePath!.isNotEmpty) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 78,
                  height: 78,
                  child: _buildThumbnail(post.imagePath!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTagBadge(String tagType, String label) {
    Color bgColor;
    Color textColor;
    String prefixEmoji = '';

    switch (tagType) {
      case 'hot':
        bgColor = const Color(0xFFFFECE0);
        textColor = const Color(0xFFE65100);
        prefixEmoji = '🔥 ';
        break;
      case 'tips':
        bgColor = const Color(0xFFFEF7DD);
        textColor = const Color(0xFFB57D18);
        prefixEmoji = '💡 ';
        break;
      case 'food':
        bgColor = const Color(0xFFFDECEB);
        textColor = const Color(0xFFC83E2D);
        prefixEmoji = '🍴 ';
        break;
      case 'general':
        bgColor = const Color(0xFFEFEAFF);
        textColor = const Color(0xFF624FA8);
        prefixEmoji = '💬 ';
        break;
      case 'destinations':
      default:
        bgColor = const Color(0xFFE1F5FE);
        textColor = const Color(0xFF0277BD);
        prefixEmoji = '🗺️ ';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$prefixEmoji$label',
        style: GoogleFonts.fredoka(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: -0.1,
        ),
      ),
    );
  }

  Widget _buildAvatarsStack() {
    return SizedBox(
      width: post.coAuthorAvatar != null ? 34 : 20,
      height: 20,
      child: Stack(
        children: [
          _buildCircleAvatar(post.authorAvatar ?? 'assets/journey/member_avatar_1.jpg'),
          if (post.coAuthorAvatar != null)
            Positioned(
              left: 13,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFAF7F2), width: 1.5),
                ),
                child: _buildCircleAvatar(post.coAuthorAvatar!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCircleAvatar(String path) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE8DFD5),
      ),
      child: ClipOval(
        child: path.startsWith('http')
            ? Image.network(
                path,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 12),
              )
            : Image.asset(
                path,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 12),
              ),
      ),
    );
  }

  Widget _buildThumbnail(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFFF0E7DB),
          child: const Icon(Icons.photo_rounded, color: Color(0xFFB0A096), size: 28),
        ),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFF0E7DB),
        child: const Icon(Icons.photo_rounded, color: Color(0xFFB0A096), size: 28),
      ),
    );
  }
}
