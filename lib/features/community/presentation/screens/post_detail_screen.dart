import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/community_post.dart';
import '../providers/community_provider.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(communityProvider);
    final post = posts.cast<CommunityPost?>().firstWhere((p) => p?.id == widget.postId, orElse: () => null);

    if (post == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text('글을 찾을 수 없습니다.', style: TextStyle(color: AppColors.textSecondary))));
    }

    final currentUser = ref.watch(currentUserProvider);
    final isMyPost = currentUser?.uid == post.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글'),
        actions: [
          if (isMyPost)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
              color: AppColors.bgCard,
              onSelected: (value) {
                if (value == 'edit') _showEditDialog(context, ref, post);
                if (value == 'delete') _showDeleteDialog(context, ref, post);
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_rounded, size: 18, color: AppColors.primary), const SizedBox(width: 8), Text('수정', style: TextStyle(color: AppColors.textPrimary))])),
                PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_rounded, size: 18, color: AppColors.scoreMiss), const SizedBox(width: 8), Text('삭제', style: TextStyle(color: AppColors.scoreMiss))])),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 작성자 헤더
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        child: Text(post.userName.isNotEmpty ? post.userName[0] : '?', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.userName, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
                            Text(timeago.format(post.createdAt, locale: 'ko'), style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      if (post.score > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                          child: Text('${post.scoreLabel} ${post.score.round()}점', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                    ],
                  ),

                  // 카테고리 태그
                  if (post.lessonTitle.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                      child: Text(post.lessonTitle, style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ],

                  // 본문
                  const SizedBox(height: 16),
                  Text(post.content, style: TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.6)),

                  // 미디어
                  if (post.mediaUrls.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      height: 200, width: double.infinity,
                      decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(14)),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              post.mediaType == 'image' ? Icons.image_rounded : post.mediaType == 'video' ? Icons.play_circle_rounded : Icons.audio_file_rounded,
                              color: AppColors.textSecondary, size: 48,
                            ),
                            const SizedBox(height: 8),
                            Text(post.mediaType == 'image' ? '사진' : post.mediaType == 'video' ? '동영상' : '녹음', style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // 반응 바
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: AppColors.bgCard))),
                    child: Row(
                      children: [
                        // 하트
                        GestureDetector(
                          onTap: () => ref.read(communityProvider.notifier).toggleLike(post.id),
                          child: Row(
                            children: [
                              Icon(
                                post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: post.isLiked ? const Color(0xFFFF4B6E) : AppColors.textSecondary, size: 24,
                              ),
                              const SizedBox(width: 6),
                              Text('${post.likes}', style: TextStyle(color: post.isLiked ? const Color(0xFFFF4B6E) : AppColors.textSecondary, fontSize: 15)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // 댓글 수
                        Icon(Icons.chat_bubble_outline_rounded, color: AppColors.textSecondary, size: 22),
                        const SizedBox(width: 6),
                        Text('${post.comments.length}', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                        const SizedBox(width: 24),
                        // 공유
                        GestureDetector(
                          onTap: () {
                            ref.read(communityProvider.notifier).sharePost(post.id);
                            Share.share('[SynthTune Music]\n${post.userName}: ${post.content}\n\n#SynthTuneMusic');
                          },
                          child: Icon(Icons.share_outlined, color: AppColors.textSecondary, size: 22),
                        ),
                      ],
                    ),
                  ),

                  // 댓글 목록
                  const SizedBox(height: 16),
                  Text('댓글 ${post.comments.length}개', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  if (post.comments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text('첫 댓글을 남겨보세요!', style: TextStyle(color: AppColors.textSecondary))),
                    )
                  else
                    ...post.comments.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                            child: Text(c.userName[0], style: TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12)),
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
                                  Text(c.text, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.4)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                ],
              ),
            ),
          ),

          // 댓글 입력
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
            decoration: BoxDecoration(color: AppColors.bgSurface, border: Border(top: BorderSide(color: AppColors.bgCard))),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentCtrl,
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: '댓글을 입력하세요...',
                        hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        filled: true, fillColor: AppColors.bgCard,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      if (_commentCtrl.text.trim().isEmpty) return;
                      final user = ref.read(currentUserProvider);
                      ref.read(communityProvider.notifier).addComment(
                        post.id,
                        Comment(
                          id: 'c_${DateTime.now().millisecondsSinceEpoch}',
                          userId: user?.uid ?? 'guest',
                          userName: user?.displayName ?? '나',
                          text: _commentCtrl.text.trim(),
                          createdAt: DateTime.now(),
                        ),
                      );
                      _commentCtrl.clear();
                    },
                    child: Container(
                      width: 44, height: 44,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, CommunityPost post) {
    final ctrl = TextEditingController(text: post.content);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('게시글 수정', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              maxLines: 5,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '내용을 수정하세요',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                filled: true, fillColor: AppColors.bgCard,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.textSecondary, side: BorderSide(color: AppColors.bgCard), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (ctrl.text.trim().isEmpty) return;
                      ref.read(communityProvider.notifier).editPost(post.id, ctrl.text.trim());
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('게시글이 수정되었습니다.'), backgroundColor: AppColors.scorePerfect),
                      );
                    },
                    child: const Text('수정 완료'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, CommunityPost post) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: Text('게시글 삭제', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('이 게시글을 삭제하시겠습니까?\n삭제 후 되돌릴 수 없습니다.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('취소', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(communityProvider.notifier).deletePost(post.id);
              Navigator.of(context).pop(); // 상세 화면도 닫기
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('게시글이 삭제되었습니다.'), backgroundColor: AppColors.scoreMiss),
              );
            },
            child: Text('삭제', style: TextStyle(color: AppColors.scoreMiss)),
          ),
        ],
      ),
    );
  }
}
