import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'post_detail_screen.dart';
import '../../domain/models/community_post.dart';
import '../providers/community_provider.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(filteredCommunityProvider);
    final selectedCat = ref.watch(selectedCommunityCategory);

    final categories = [
      ('all', '전체', Icons.dashboard_rounded),
      ('practice', '연습 기록', Icons.music_note_rounded),
      ('qna', 'Q&A', Icons.help_outline_rounded),
      ('notice', '공지사항', Icons.campaign_rounded),
      ('feedback', '문의·의견', Icons.feedback_rounded),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('커뮤니티')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPostDialog(context, ref),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
      body: Column(
        children: [
          // 카테고리 탭
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: categories.length,
              itemBuilder: (context, i) {
                final c = categories[i];
                final isSelected = selectedCat == c.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => ref.read(selectedCommunityCategory.notifier).state = c.$1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.bgCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.bgSurface),
                      ),
                      child: Row(
                        children: [
                          Icon(c.$3, size: 15, color: isSelected ? Colors.white : AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(c.$2, style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          )),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 게시글 목록
          Expanded(
            child: posts.isEmpty
                ? Center(
                    child: Text(
                      selectedCat == 'notice' ? '공지사항이 없습니다.' :
                      selectedCat == 'qna' ? '아직 질문이 없습니다. 첫 질문을 남겨보세요!' :
                      selectedCat == 'feedback' ? '의견을 남겨주세요!' :
                      '아직 게시물이 없습니다.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: posts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _PostCard(post: posts[i]),
                  ),
          ),
        ],
      ),
    );
  }

  void _showPostDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _NewPostSheet(ref: ref),
    );
  }
}

// ─── 새 게시글 작성 시트 ───
class _NewPostSheet extends StatefulWidget {
  final WidgetRef ref;
  const _NewPostSheet({required this.ref});

  @override
  State<_NewPostSheet> createState() => _NewPostSheetState();
}

class _NewPostSheetState extends State<_NewPostSheet> {
  final _ctrl = TextEditingController();
  String? _selectedMedia; // 'image', 'video', 'audio'
  bool _mediaAttached = false;
  String _postCategory = 'practice';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '새 게시글',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // 카테고리 선택
          Row(
            children: [
              for (final cat in [('practice', '연습 기록'), ('qna', 'Q&A'), ('feedback', '문의·의견')])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat.$2, style: TextStyle(fontSize: 12, color: _postCategory == cat.$1 ? Colors.white : AppColors.textSecondary)),
                    selected: _postCategory == cat.$1,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.bgCard,
                    onSelected: (_) => setState(() => _postCategory = cat.$1),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            maxLines: 3,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: '오늘 연습 어떠셨나요?',
              hintStyle: TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.bgCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 미디어 첨부 버튼
          Row(
            children: [
              _MediaButton(
                icon: Icons.image_rounded,
                label: '사진',
                isSelected: _selectedMedia == 'image',
                onTap: () => setState(() {
                  _selectedMedia = 'image';
                  _mediaAttached = true;
                }),
              ),
              const SizedBox(width: 8),
              _MediaButton(
                icon: Icons.videocam_rounded,
                label: '동영상',
                isSelected: _selectedMedia == 'video',
                onTap: () => setState(() {
                  _selectedMedia = 'video';
                  _mediaAttached = true;
                }),
              ),
              const SizedBox(width: 8),
              _MediaButton(
                icon: Icons.mic_rounded,
                label: '녹음',
                isSelected: _selectedMedia == 'audio',
                onTap: () => setState(() {
                  _selectedMedia = 'audio';
                  _mediaAttached = true;
                }),
              ),
            ],
          ),

          if (_mediaAttached) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedMedia == 'image' ? Icons.image_rounded
                        : _selectedMedia == 'video' ? Icons.videocam_rounded
                        : Icons.mic_rounded,
                    color: AppColors.accent, size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedMedia == 'image' ? '사진' : _selectedMedia == 'video' ? '동영상' : '녹음'} 첨부됨',
                    style: const TextStyle(color: AppColors.accent, fontSize: 13),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() { _selectedMedia = null; _mediaAttached = false; }),
                    child: Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 16),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (_ctrl.text.trim().isEmpty) return;
                final user = widget.ref.read(currentUserProvider);
                widget.ref.read(communityProvider.notifier).addPost(
                  CommunityPost(
                    id: 'new_${DateTime.now().millisecondsSinceEpoch}',
                    userId: user?.uid ?? 'guest',
                    userName: user?.displayName ?? '나',
                    content: _ctrl.text.trim(),
                    lessonTitle: '자유 연습',
                    instrument: 'piano',
                    score: 0,
                    likes: 0,
                    isLiked: false,
                    createdAt: DateTime.now(),
                    mediaType: _selectedMedia,
                    mediaUrls: _mediaAttached ? ['mock_${_selectedMedia}_url'] : [],
                    category: _postCategory,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('게시하기'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MediaButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.bgSurface,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            )),
          ],
        ),
      ),
    );
  }
}

// ─── 게시글 카드 ───
class _PostCard extends ConsumerWidget {
  final CommunityPost post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instrumentColor = AppColors.instrumentColors[post.instrument] ?? AppColors.primary;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(postId: post.id))),
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgSurface),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  post.userName.isNotEmpty ? post.userName[0] : '?',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.userName, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(timeago.format(post.createdAt, locale: 'ko'), style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              if (post.score > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _gradeColor(post.scoreLabel).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${post.scoreLabel}  ${post.score.round()}점',
                    style: TextStyle(color: _gradeColor(post.scoreLabel), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 레슨 태그
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: instrumentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(post.lessonTitle, style: TextStyle(color: instrumentColor, fontSize: 11, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 10),

          // 본문
          Text(post.content, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.5)),

          // 미디어 첨부 표시
          if (post.mediaUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.bgCard),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      post.mediaType == 'image' ? Icons.image_rounded
                          : post.mediaType == 'video' ? Icons.play_circle_rounded
                          : Icons.audio_file_rounded,
                      color: AppColors.textSecondary, size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.mediaType == 'image' ? '사진'
                          : post.mediaType == 'video' ? '동영상'
                          : '녹음 파일',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),

          // 반응 바: 하트 + 댓글 + 공유
          Row(
            children: [
              // 하트
              GestureDetector(
                onTap: () => ref.read(communityProvider.notifier).toggleLike(post.id),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        key: ValueKey(post.isLiked),
                        color: post.isLiked ? Color(0xFFFF4B6E) : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('${post.likes}', style: TextStyle(
                      color: post.isLiked ? Color(0xFFFF4B6E) : AppColors.textSecondary, fontSize: 13,
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // 댓글
              GestureDetector(
                onTap: () => _showComments(context, ref, post),
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded, color: AppColors.textSecondary, size: 18),
                    const SizedBox(width: 4),
                    Text('${post.comments.length}', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // 외부 공유
              GestureDetector(
                onTap: () {
                  ref.read(communityProvider.notifier).sharePost(post.id);
                  Share.share('[SynthTune Music]\n${post.userName}: ${post.content}\n\n#SynthTuneMusic #AI음악교육');
                },
                child: Row(
                  children: [
                    Icon(Icons.share_outlined, color: AppColors.textSecondary, size: 18),
                    const SizedBox(width: 4),
                    Text('${post.shares}', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  void _showComments(BuildContext context, WidgetRef ref, CommunityPost post) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          final updatedPost = ref.watch(communityProvider).firstWhere((p) => p.id == post.id, orElse: () => post);
          return Padding(
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('댓글 ${updatedPost.comments.length}개', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  // 댓글 목록
                  if (updatedPost.comments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text('아직 댓글이 없습니다.', style: TextStyle(color: AppColors.textSecondary))),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: updatedPost.comments.length,
                        itemBuilder: (_, i) {
                          final c = updatedPost.comments[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                                  child: Text(c.userName[0], style: TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(c.userName, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                                          const SizedBox(width: 8),
                                          Text(timeago.format(c.createdAt, locale: 'ko'), style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(c.text, style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  Divider(color: AppColors.bgCard),
                  // 댓글 입력
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: ctrl,
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: '댓글을 입력하세요...',
                            hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            filled: true,
                            fillColor: AppColors.bgCard,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          if (ctrl.text.trim().isEmpty) return;
                          final user = ref.read(currentUserProvider);
                          ref.read(communityProvider.notifier).addComment(
                            post.id,
                            Comment(
                              id: 'c_${DateTime.now().millisecondsSinceEpoch}',
                              userId: user?.uid ?? 'guest',
                              userName: user?.displayName ?? '나',
                              text: ctrl.text.trim(),
                              createdAt: DateTime.now(),
                            ),
                          );
                          ctrl.clear();
                          setSheetState(() {});
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'S': return AppColors.accentGold;
      case 'A': return AppColors.scorePerfect;
      case 'B': return AppColors.accent;
      case 'C': return AppColors.primary;
      default: return AppColors.textSecondary;
    }
  }
}
