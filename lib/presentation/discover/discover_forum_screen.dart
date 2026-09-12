import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/forum_post_model.dart';
import 'pages/forum_post_detail_screen.dart';
import 'services/forum_service.dart';
import 'widgets/create_forum_post_sheet.dart';
import 'widgets/forum_category_chips.dart';
import 'widgets/forum_filter_sheet.dart';
import 'widgets/forum_header_banner.dart';
import 'widgets/forum_post_card.dart';
import 'widgets/forum_search_filter_bar.dart';

class DiscoverForumScreen extends StatefulWidget {
  final VoidCallback? onBackTap;

  const DiscoverForumScreen({
    super.key,
    this.onBackTap,
  });

  @override
  State<DiscoverForumScreen> createState() => _DiscoverForumScreenState();
}

class _DiscoverForumScreenState extends State<DiscoverForumScreen> {
  final _searchController = TextEditingController();
  final _forumService = ForumService();

  String _selectedCategory = 'All';
  String _selectedSort = 'Hot';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _forumService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _forumService.removeListener(_onServiceUpdate);
    _searchController.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ForumFilterSheet(
          currentSort: _selectedSort,
          currentCategory: _selectedCategory,
          onApply: (sort, category) {
            setState(() {
              _selectedSort = sort;
              _selectedCategory = category;
            });
          },
        );
      },
    );
  }

  void _openCreatePostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateForumPostSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandOrange = Color(0xFFE65100);
    const darkBrown = Color(0xFF2E1C14);
    const textMuted = Color(0xFF8F7F77);

    final posts = _forumService.filterPosts(
      category: _selectedCategory,
      query: _searchQuery,
      sortBy: _selectedSort,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F0),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 68.0),
        child: FloatingActionButton.extended(
          onPressed: _openCreatePostSheet,
          backgroundColor: brandOrange,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.edit_note_rounded, size: 20),
          label: Text(
            'Ask Community',
            style: GoogleFonts.fredoka(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Header with Japanese pagoda backdrop, titles, and mascot
            SliverToBoxAdapter(
              child: ForumHeaderBanner(
                onBackTap: widget.onBackTap,
              ),
            ),

            // 2. Search & Filter Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
                child: ForumSearchFilterBar(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  onClear: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  onFilterTap: _openFilterSheet,
                ),
              ),
            ),

            // 3. Category Horizontal Pills
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ForumCategoryChips(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (cat) {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                ),
              ),
            ),

            // 4. Forum Posts List
            if (posts.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3ECE4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search_off_rounded,
                          size: 36,
                          color: Color(0xFFB0A096),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'No discussions found',
                        style: GoogleFonts.fredoka(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: darkBrown,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Try adjusting your search terms or filters.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = posts[index];
                    return ForumPostCard(
                      post: post,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForumPostDetailScreen(post: post),
                          ),
                        );
                      },
                      onLikeTap: () {
                        _forumService.toggleLikePost(post.id);
                      },
                    );
                  },
                  childCount: posts.length,
                ),
              ),

            // Bottom spacer for floating navigation bar
            const SliverToBoxAdapter(
              child: SizedBox(height: 90),
            ),
          ],
        ),
      ),
    );
  }
}
