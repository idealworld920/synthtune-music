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

  void addComment(String postId, Comment comment) {
    state = state.map((post) {
      if (post.id == postId) {
        return post.copyWith(comments: [...post.comments, comment]);
      }
      return post;
    }).toList();
  }

  void sharePost(String postId) {
    state = state.map((post) {
      if (post.id == postId) {
        return post.copyWith(shares: post.shares + 1);
      }
      return post;
    }).toList();
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

  final posts = List.generate(10, (i) {
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
      category: 'practice',
    );
  }).toList();

  // 공지사항 mock
  posts.addAll([
    CommunityPost(
      id: 'notice_1', userId: 'admin', userName: '운영팀',
      content: '앱 업데이트 v1.1.0이 출시되었습니다!\n새로운 기능: 나만의 음악 창작, 카메라 피드백, 커뮤니티 개편.',
      lessonTitle: '', instrument: '', score: 0, likes: 42, isLiked: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      category: 'notice',
    ),
    CommunityPost(
      id: 'notice_2', userId: 'admin', userName: '운영팀',
      content: '학생 할인 요금제 출시! 학교 이메일(.ac.kr, .edu) 인증으로 프리미엄 기능을 ₩4,900/월에 이용하세요.',
      lessonTitle: '', instrument: '', score: 0, likes: 28, isLiked: false,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      category: 'notice',
    ),
  ]);

  // Q&A mock
  posts.addAll([
    CommunityPost(
      id: 'qna_1', userId: 'user_q1', userName: '초보피아니스트',
      content: '피아노 독학하는데 손가락 번호가 헷갈려요. 도레미파솔을 칠 때 어떤 손가락을 써야 하나요?',
      lessonTitle: '', instrument: 'piano', score: 0, likes: 5, isLiked: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      category: 'qna',
      comments: [
        Comment(id: 'ans_1', userId: 'user_a1', userName: '김선생', text: '엄지=1, 검지=2, 중지=3, 약지=4, 새끼=5 입니다. C장조는 1-2-3-1-2-3-4-5로 치면 됩니다!', createdAt: DateTime.now().subtract(const Duration(hours: 6))),
      ],
    ),
    CommunityPost(
      id: 'qna_2', userId: 'user_q2', userName: '기타초보',
      content: 'F 코드가 너무 어려워요... 바레 코드 쉽게 잡는 팁 있을까요?',
      lessonTitle: '', instrument: 'guitar', score: 0, likes: 12, isLiked: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      category: 'qna',
    ),
  ]);

  return posts;
}

// 커뮤니티 카테고리 필터
final selectedCommunityCategory = StateProvider<String>((ref) => 'all');

// 필터된 커뮤니티 게시글
final filteredCommunityProvider = Provider<List<CommunityPost>>((ref) {
  final category = ref.watch(selectedCommunityCategory);
  final posts = ref.watch(communityProvider);
  if (category == 'all') return posts;
  return posts.where((p) => p.category == category).toList();
});

final communityProvider =
    StateNotifierProvider<CommunityNotifier, List<CommunityPost>>(
  (ref) => CommunityNotifier(),
);
