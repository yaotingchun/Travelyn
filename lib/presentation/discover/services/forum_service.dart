import 'package:flutter/foundation.dart';
import '../models/forum_post_model.dart';

class ForumService extends ChangeNotifier {
  static final ForumService _instance = ForumService._internal();
  factory ForumService() => _instance;

  ForumService._internal() {
    _initDefaultData();
  }

  final List<ForumPost> _posts = [];
  final Map<String, List<ForumComment>> _comments = {};

  List<ForumPost> get posts => List.unmodifiable(_posts);

  void _initDefaultData() {
    _posts.addAll([
      const ForumPost(
        id: 'post_1',
        title: 'Best time to visit Japan?',
        content:
            "I'm planning a trip to Japan next spring. Is it better to go in March or April? Any advice on the weather and crowds?",
        category: 'Destinations',
        tagType: 'hot',
        tagLabel: 'Hot',
        authorName: 'SarahL',
        authorAvatar: 'assets/journey/member_avatar_1.jpg',
        coAuthorAvatar: 'assets/journey/member_avatar_2.jpg',
        authorBadge: 'Cherry Blossom Lover',
        timeAgo: '2 days ago',
        commentsCount: 48,
        likesCount: 132,
        imagePath: 'assets/home/tokyo_pagoda_blossom.jpg',
        destination: 'Japan, Tokyo',
      ),
      const ForumPost(
        id: 'post_2',
        title: 'Hidden gems in Kyoto',
        content:
            'Besides the usual temples, what are some less crowded but beautiful spots in Kyoto?',
        category: 'Tips & Guides',
        tagType: 'tips',
        tagLabel: 'Tips & Guides',
        authorName: 'TravelBug',
        authorAvatar: 'assets/journey/member_avatar_3.jpg',
        coAuthorAvatar: 'assets/journey/member_avatar_4.jpg',
        authorBadge: 'Kyoto Explorer',
        timeAgo: '3 days ago',
        commentsCount: 32,
        likesCount: 94,
        imagePath: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=600&auto=format&fit=crop&q=80',
        destination: 'Kyoto, Japan',
      ),
      const ForumPost(
        id: 'post_3',
        title: 'Must-try street food in Seoul',
        content:
            "I've heard the food scene in Seoul is amazing! What are your top 5 street food picks?",
        category: 'Food',
        tagType: 'food',
        tagLabel: 'Food',
        authorName: 'FoodieNomad',
        authorAvatar: 'assets/journey/member_avatar_2.jpg',
        coAuthorAvatar: 'assets/journey/member_avatar_1.jpg',
        authorBadge: 'Street Food Critic',
        timeAgo: '4 days ago',
        commentsCount: 56,
        likesCount: 185,
        imagePath: 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=600&auto=format&fit=crop&q=80',
        destination: 'Seoul, South Korea',
      ),
      const ForumPost(
        id: 'post_4',
        title: 'Solo travel tips?',
        content:
            'Has anyone travelled solo to Europe before? Any safety tips or must-have apps?',
        category: 'General',
        tagType: 'general',
        tagLabel: 'General',
        authorName: 'WanderJess',
        authorAvatar: 'assets/journey/member_avatar_4.jpg',
        coAuthorAvatar: 'assets/journey/member_avatar_3.jpg',
        authorBadge: 'Solo Backpacker',
        timeAgo: '5 days ago',
        commentsCount: 27,
        likesCount: 79,
        imagePath: 'https://images.unsplash.com/photo-1527631746610-bca00a040d60?w=600&auto=format&fit=crop&q=80',
        destination: 'Europe',
      ),
    ]);

    // Initial peer-to-peer replies
    _comments['post_1'] = [
      const ForumComment(
        id: 'c1_1',
        authorName: 'Kenji_Local',
        authorAvatar: 'assets/journey/member_avatar_3.jpg',
        authorBadge: 'Tokyo Local',
        content:
            'Early April is peak bloom for Tokyo and Kyoto, but definitely expect heavy crowds! If you want pleasant weather and fewer tour groups, the last week of March or mid-April right after the petals fall is magical.',
        timeAgo: '1 day ago',
        likesCount: 24,
      ),
      const ForumComment(
        id: 'c1_2',
        authorName: 'Maya_Backpack',
        authorAvatar: 'assets/journey/member_avatar_4.jpg',
        authorBadge: 'Frequent Explorer',
        content:
            'Book your Shinkansen bullet train reservations in advance if you are traveling between Tokyo and Kyoto! Also pick up an IC card (Suica/Pasmo) on your phone beforehand.',
        timeAgo: '1 day ago',
        likesCount: 15,
      ),
      const ForumComment(
        id: 'c1_3',
        authorName: 'David_Photo',
        authorAvatar: 'assets/journey/member_avatar_2.jpg',
        authorBadge: 'Photographer',
        content:
            'For photography without the sea of people, visit Senso-ji or Meguro River at 6:30 AM. Morning light is stunning and you will have the bridges almost to yourself!',
        timeAgo: '18 hours ago',
        likesCount: 9,
      ),
    ];

    _comments['post_2'] = [
      const ForumComment(
        id: 'c2_1',
        authorName: 'Aoi_Zen',
        authorAvatar: 'assets/journey/member_avatar_1.jpg',
        authorBadge: 'Kyoto Guide',
        content:
            'Check out Gio-ji Temple in Arashiyama (the moss garden temple) and Daikaku-ji. Almost zero crowds compared to the bamboo grove!',
        timeAgo: '2 days ago',
        likesCount: 19,
      ),
      const ForumComment(
        id: 'c2_2',
        authorName: 'TravelBug',
        authorAvatar: 'assets/journey/member_avatar_3.jpg',
        authorBadge: 'Author',
        content: 'Added Gio-ji to my list right away! Thank you so much Aoi!',
        timeAgo: '1 day ago',
        likesCount: 4,
      ),
    ];

    _comments['post_3'] = [
      const ForumComment(
        id: 'c3_1',
        authorName: 'SeoulBite',
        authorAvatar: 'assets/journey/member_avatar_4.jpg',
        authorBadge: 'Foodie',
        content:
            'Top 5 non-negotiables: 1. Gwangjang Market Bindaetteok (mung bean pancake), 2. Hotteok (brown sugar pancake) in Insadong, 3. Tteokbokki at Sindang-dong, 4. Fish cake skewers with broth at night, 5. Mayak Kimbap!',
        timeAgo: '3 days ago',
        likesCount: 38,
      ),
    ];

    _comments['post_4'] = [
      const ForumComment(
        id: 'c4_1',
        authorName: 'Elena_Globetrotter',
        authorAvatar: 'assets/journey/member_avatar_2.jpg',
        authorBadge: 'Solo Veteran',
        content:
            'Citymapper is a lifesaver for public transit in European capitals. Always keep an offline Google Map downloaded, and stay in social hostels with female dorms or private rooms for great peer meetups!',
        timeAgo: '4 days ago',
        likesCount: 21,
      ),
    ];
  }

  List<ForumPost> filterPosts({
    String category = 'All',
    String query = '',
    String sortBy = 'Hot',
  }) {
    List<ForumPost> result = List.from(_posts);

    // Category filter
    if (category != 'All') {
      result = result.where((p) {
        if (category == 'Destinations') return p.category == 'Destinations';
        if (category == 'Tips & Guides') return p.category == 'Tips & Guides';
        if (category == 'Food') return p.category == 'Food';
        if (category == 'General') return p.category == 'General';
        return p.category.toLowerCase().contains(category.toLowerCase());
      }).toList();
    }

    // Search query
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      result = result.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.content.toLowerCase().contains(q) ||
            p.destination.toLowerCase().contains(q) ||
            p.authorName.toLowerCase().contains(q);
      }).toList();
    }

    // Sorting
    if (sortBy == 'Hot') {
      result.sort((a, b) => b.likesCount.compareTo(a.likesCount));
    } else if (sortBy == 'Recent') {
      // Keep newest first
    } else if (sortBy == 'Most Answered') {
      result.sort((a, b) => b.commentsCount.compareTo(a.commentsCount));
    }

    return result;
  }

  List<ForumComment> getComments(String postId) {
    return _comments[postId] ?? [];
  }

  void addComment(String postId, String content, {String authorName = 'Diana'}) {
    final comment = ForumComment(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      authorName: authorName,
      authorAvatar: 'assets/journey/member_avatar_1.jpg',
      authorBadge: 'Travelyn Member',
      content: content,
      timeAgo: 'Just now',
      likesCount: 0,
    );

    if (!_comments.containsKey(postId)) {
      _comments[postId] = [];
    }
    _comments[postId]!.insert(0, comment);

    // Update comment count on post
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = post.copyWith(commentsCount: post.commentsCount + 1);
    }

    notifyListeners();
  }

  void toggleLikePost(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final isLiked = !post.isLiked;
      final likesDelta = isLiked ? 1 : -1;
      _posts[index] = post.copyWith(
        isLiked: isLiked,
        likesCount: (post.likesCount + likesDelta).clamp(0, 99999),
      );
      notifyListeners();
    }
  }

  void toggleSavePost(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = post.copyWith(isSaved: !post.isSaved);
      notifyListeners();
    }
  }

  void toggleLikeComment(String postId, String commentId) {
    final list = _comments[postId];
    if (list != null) {
      final idx = list.indexWhere((c) => c.id == commentId);
      if (idx != -1) {
        final comment = list[idx];
        final isLiked = !comment.isLiked;
        final delta = isLiked ? 1 : -1;
        list[idx] = comment.copyWith(
          isLiked: isLiked,
          likesCount: (comment.likesCount + delta).clamp(0, 99999),
        );
        notifyListeners();
      }
    }
  }

  void addPost({
    required String title,
    required String content,
    required String category,
    required String destination,
    String? imagePath,
  }) {
    String tagType = 'general';
    String tagLabel = category;
    if (category == 'Tips & Guides') {
      tagType = 'tips';
    } else if (category == 'Food') {
      tagType = 'food';
    } else if (category == 'Destinations') {
      tagType = 'destinations';
    }

    final newPost = ForumPost(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      category: category,
      tagType: tagType,
      tagLabel: tagLabel,
      authorName: 'Diana',
      authorAvatar: 'assets/journey/member_avatar_1.jpg',
      authorBadge: 'New Contributor',
      timeAgo: 'Just now',
      commentsCount: 0,
      likesCount: 1,
      imagePath: imagePath ?? 'assets/home/hero_tokyo.jpg',
      destination: destination.isEmpty ? 'Global' : destination,
      isLiked: true,
    );

    _posts.insert(0, newPost);
    _comments[newPost.id] = [];
    notifyListeners();
  }
}
