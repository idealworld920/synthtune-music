class CommunityPost {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final String lessonTitle;
  final String instrument;
  final double score;
  final int likes;
  final bool isLiked;
  final DateTime createdAt;
  final String? audioUrl;
  final List<String> mediaUrls;   // 사진/동영상 URL 목록
  final String? mediaType;         // 'image', 'video', 'audio'
  final List<Comment> comments;
  final int shares;
  final String category; // 'practice', 'qna', 'notice', 'feedback'

  const CommunityPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.lessonTitle,
    required this.instrument,
    required this.score,
    required this.likes,
    required this.isLiked,
    required this.createdAt,
    this.audioUrl,
    this.mediaUrls = const [],
    this.mediaType,
    this.comments = const [],
    this.shares = 0,
    this.category = 'practice',
  });

  CommunityPost copyWith({
    bool? isLiked,
    int? likes,
    List<Comment>? comments,
    int? shares,
  }) {
    return CommunityPost(
      id: id,
      userId: userId,
      userName: userName,
      content: content,
      lessonTitle: lessonTitle,
      instrument: instrument,
      score: score,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
      audioUrl: audioUrl,
      mediaUrls: mediaUrls,
      mediaType: mediaType,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      category: category,
    );
  }

  String get scoreLabel {
    if (score >= 95) return 'S';
    if (score >= 85) return 'A';
    if (score >= 70) return 'B';
    if (score >= 55) return 'C';
    return 'D';
  }
}

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });
}
