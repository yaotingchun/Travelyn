import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/forum_post_model.dart';
import '../services/forum_service.dart';

class ForumPostDetailScreen extends StatefulWidget {
  final ForumPost post;

  const ForumPostDetailScreen({
    super.key,
    required this.post,
  });

  @override
  State<ForumPostDetailScreen> createState() => _ForumPostDetailScreenState();
}

class _ForumPostDetailScreenState extends State<ForumPostDetailScreen> {
  late ForumPost _post;
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    ForumService().addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    ForumService().removeListener(_onServiceUpdate);
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    final updated = ForumService().posts.firstWhere(
          (p) => p.id == _post.id,
          orElse: () => _post,
        );
    if (mounted) {
      setState(() {
        _post = updated;
      });
    }
  }

  void _sendReply() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    ForumService().addComment(_post.id, text, authorName: 'You');
    _commentController.clear();
    FocusScope.of(context).unfocus();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 250), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Your travel advice was added! 🎒'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF2E1C14);
    const brandOrange = Color(0xFFE65100);
    const contentColor = Color(0xFF5E4D45);
    const textMuted = Color(0xFF8F7F77);

    final comments = ForumService().getComments(_post.id);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF7F0),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEFE6DB), width: 0.8),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 14,
              color: darkBrown,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Discussion',
          style: GoogleFonts.fredoka(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: darkBrown,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _post.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _post.isSaved ? brandOrange : darkBrown,
            ),
            onPressed: () => ForumService().toggleSavePost(_post.id),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: darkBrown),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Discussion link copied to clipboard!'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // OP Card container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF7F2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEFE6DB), width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: darkBrown.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // OP Author Row
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFE8DFD5),
                              ),
                              child: ClipOval(
                                child: _buildAvatarImage(_post.authorAvatar),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _post.authorName,
                                        style: GoogleFonts.fredoka(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: darkBrown,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFECE0),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _post.authorBadge,
                                          style: GoogleFonts.nunito(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: brandOrange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_post.timeAgo} • ${_post.destination}',
                                    style: GoogleFonts.nunito(
                                      fontSize: 11.5,
                                      color: textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Title
                        Text(
                          _post.title,
                          style: GoogleFonts.fredoka(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: darkBrown,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Question / Story Content
                        Text(
                          _post.content,
                          style: GoogleFonts.nunito(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: contentColor,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Post image (if available)
                        if (_post.imagePath != null && _post.imagePath!.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SizedBox(
                              width: double.infinity,
                              height: 180,
                              child: _buildPostImage(_post.imagePath!),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Interactive action row
                        const Divider(color: Color(0xFFEAE0D4), thickness: 0.8),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => ForumService().toggleLikePost(_post.id),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _post.isLiked
                                      ? const Color(0xFFFFEBEE)
                                      : const Color(0xFFF3ECE4),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _post.isLiked
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      size: 16,
                                      color: _post.isLiked
                                          ? const Color(0xFFE53935)
                                          : textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Helpful (${_post.likesCount})',
                                      style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: _post.isLiked
                                            ? const Color(0xFFE53935)
                                            : textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 16,
                                  color: textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${_post.commentsCount} replies',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Peer Replies Section Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Peer Advice & Answers (${comments.length})',
                        style: GoogleFonts.fredoka(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: darkBrown,
                        ),
                      ),
                      Text(
                        'Verified Travelers ✈️',
                        style: GoogleFonts.nunito(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: brandOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Replies List
                  if (comments.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF7F2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'No answers yet. Be the first traveller to share tips!',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            color: textMuted,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return _buildCommentCard(comment, darkBrown, textMuted, brandOrange);
                      },
                    ),
                ],
              ),
            ),
          ),

          // Bottom Reply Input Bar
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              border: const Border(
                top: BorderSide(color: Color(0xFFEFE6DB), width: 1.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: darkBrown.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3ECE4),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _commentController,
                      style: GoogleFonts.nunito(fontSize: 13.5, color: darkBrown),
                      decoration: InputDecoration(
                        hintText: 'Share your advice, tips or experience...',
                        hintStyle: GoogleFonts.nunito(
                          fontSize: 13,
                          color: const Color(0xFF9E8E86),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendReply,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: brandOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(
    ForumComment comment,
    Color darkBrown,
    Color textMuted,
    Color brandOrange,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFE6DB), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE8DFD5),
                ),
                child: ClipOval(
                  child: _buildAvatarImage(comment.authorAvatar),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                comment.authorName,
                style: GoogleFonts.fredoka(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: darkBrown,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3ECE4),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  comment.authorBadge,
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7E6E66),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                comment.timeAgo,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  color: textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.content,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4A3D36),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => ForumService().toggleLikeComment(_post.id, comment.id),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Icon(
                      comment.isLiked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                      size: 13,
                      color: comment.isLiked ? brandOrange : textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Helpful (${comment.likesCount})',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: comment.isLiked ? brandOrange : textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(String? path) {
    if (path == null || path.isEmpty) {
      return const Icon(Icons.person, size: 16);
    }
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 16),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 16),
    );
  }

  Widget _buildPostImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFFF0E7DB),
          child: const Icon(Icons.photo_rounded, color: Color(0xFFB0A096), size: 40),
        ),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFF0E7DB),
        child: const Icon(Icons.photo_rounded, color: Color(0xFFB0A096), size: 40),
      ),
    );
  }
}
