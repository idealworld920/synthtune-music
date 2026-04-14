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
  });

  CommunityPost copyWith({bool? isLiked, int? likes}) {
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
