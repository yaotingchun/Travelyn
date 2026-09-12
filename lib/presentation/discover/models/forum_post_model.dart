class ForumPost {
  final String id;
  final String title;
  final String content;
  final String category; // 'Destinations', 'Tips & Guides', 'Food', 'General', etc.
  final String tagType; // 'hot', 'tips', 'food', 'general', 'destinations'
  final String tagLabel; // 'Hot', 'Tips & Guides', 'Food', 'General'
  final String authorName;
  final String? authorAvatar;
  final String? coAuthorAvatar;
  final String authorBadge; // e.g. 'Tokyo Veteran', 'Foodie Nomad', 'Kyoto Local'
  final String timeAgo;
  final int commentsCount;
  final int likesCount;
  final String? imagePath;
  final String destination;
  final bool isLiked;
  final bool isSaved;

  const ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.tagType,
    required this.tagLabel,
    required this.authorName,
    this.authorAvatar,
    this.coAuthorAvatar,
    this.authorBadge = 'Traveler',
    required this.timeAgo,
    this.commentsCount = 0,
    this.likesCount = 0,
    this.imagePath,
    this.destination = '',
    this.isLiked = false,
    this.isSaved = false,
  });

  ForumPost copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    String? tagType,
    String? tagLabel,
    String? authorName,
    String? authorAvatar,
    String? coAuthorAvatar,
    String? authorBadge,
    String? timeAgo,
    int? commentsCount,
    int? likesCount,
    String? imagePath,
    String? destination,
    bool? isLiked,
    bool? isSaved,
  }) {
    return ForumPost(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tagType: tagType ?? this.tagType,
      tagLabel: tagLabel ?? this.tagLabel,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      coAuthorAvatar: coAuthorAvatar ?? this.coAuthorAvatar,
      authorBadge: authorBadge ?? this.authorBadge,
      timeAgo: timeAgo ?? this.timeAgo,
      commentsCount: commentsCount ?? this.commentsCount,
      likesCount: likesCount ?? this.likesCount,
      imagePath: imagePath ?? this.imagePath,
      destination: destination ?? this.destination,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

class ForumComment {
  final String id;
  final String authorName;
  final String? authorAvatar;
  final String authorBadge; // e.g. 'Local Resident', 'Frequent Flyer', 'Solo Backpacker'
  final String content;
  final String timeAgo;
  final int likesCount;
  final bool isLiked;

  const ForumComment({
    required this.id,
    required this.authorName,
    this.authorAvatar,
    this.authorBadge = 'Traveler',
    required this.content,
    required this.timeAgo,
    this.likesCount = 0,
    this.isLiked = false,
  });

  ForumComment copyWith({
    String? id,
    String? authorName,
    String? authorAvatar,
    String? authorBadge,
    String? content,
    String? timeAgo,
    int? likesCount,
    bool? isLiked,
  }) {
    return ForumComment(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      authorBadge: authorBadge ?? this.authorBadge,
      content: content ?? this.content,
      timeAgo: timeAgo ?? this.timeAgo,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
