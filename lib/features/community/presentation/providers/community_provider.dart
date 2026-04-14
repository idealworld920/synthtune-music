import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/community_post.dart';

class CommunityNotifier extends StateNotifier<List<CommunityPost>> {
  CommunityNotifier() : super(_mockPosts());

  void toggleLike(String postId) {
    state = state.map((post) {
      if (post.id == postId) {
        final newLiked = !post.isLiked;
        return post.copyWith(
          isLiked: newLiked,
          likes: post.likes + (newLiked ? 1 : -1),
        );
      }
      return post;
    }).toList();
  }

  void addPost(CommunityPost post) {
    state = [post, ...state];
  }
}

List<CommunityPost> _mockPosts() {
  final rng = Random(123);
  final names = ['김민준', '이서연', '박지호', '최예린', '정우성', '한소희', '오승준', '임나연'];
  final lessons = [
    ('반짝반짝 작은별', 'piano'),
    ('도레미파솔라시도', 'piano'),
    ('Am 코드 연습', 'guitar'),
    ('비행기', 'piano'),
    ('G 코드 마스터', 'guitar'),
    ('아리랑', 'guitar'),
  ];
  final contents = [
    '드디어 첫 곡 완성! 너무 기쁘네요 😊',
    '오늘도 꾸준히 연습했습니다. 조금씩 나아지고 있는 것 같아요!',
    '어제보다 훨씬 잘 된 것 같아요. AI 피드백 정말 도움이 돼요!',
    '음정이 아직 불안하지만 계속 연습하면 될 것 같아요',
    '처음엔 너무 어렵더니 이제 손가락이 익숙해졌어요',
    '연속 7일 연습 달성! 스트릭 유지 중 🔥',
    '이 곡 너무 좋아서 매일 연습하고 있어요',
    '피드백 보니까 D음이 항상 빗나가네요... 더 연습해야겠어요',
  ];

  return List.generate(10, (i) {
    final lesson = lessons[i % lessons.length];
    final score = 65.0 + rng.nextDouble() * 33;
    return CommunityPost(
      id: 'post_$i',
      userId: 'user_$i',
      userName: names[i % names.length],
      content: contents[i % contents.length],
      lessonTitle: lesson.$1,
      instrument: lesson.$2,
      score: score,
      likes: rng.nextInt(30),
      isLiked: rng.nextBool(),
      createdAt: DateTime.now().subtract(Duration(
        hours: rng.nextInt(72),
        minutes: rng.nextInt(60),
      )),
    );
  });
}

final communityProvider =
    StateNotifierProvider<CommunityNotifier, List<CommunityPost>>(
  (ref) => CommunityNotifier(),
);
