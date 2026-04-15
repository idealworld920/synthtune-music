import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/sheet_music_widget.dart';
import '../../../lesson/domain/models/lesson.dart';
import '../../../subscription/domain/subscription_tier.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../community/presentation/providers/community_provider.dart';
import '../../../community/domain/models/community_post.dart';

class ComposeScreen extends ConsumerStatefulWidget {
  const ComposeScreen({super.key});

  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen> {
  final _titleController = TextEditingController();
  final Set<(int, int)> _selectedCells = {};
  bool _isPlaying = false;
  int _playbackBeat = -1;

  // Row index 0 = top (C5), row index 7 = bottom (C4)
  static const List<String> _noteNames = [
    'C5', 'B4', 'A4', 'G4', 'F4', 'E4', 'D4', 'C4',
  ];

  static const List<double> _noteFrequencies = [
    NoteFrequency.c5,
    NoteFrequency.b4,
    NoteFrequency.a4,
    NoteFrequency.g4,
    NoteFrequency.f4,
    NoteFrequency.e4,
    NoteFrequency.d4,
    NoteFrequency.c4,
  ];

  static const int _totalBeats = 8;
  static const int _totalRows = 8;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _toggleCell(int row, int col) {
    setState(() {
      final cell = (row, col);
      if (_selectedCells.contains(cell)) {
        _selectedCells.remove(cell);
      } else {
        _selectedCells.add(cell);
      }
    });
  }

  List<MusicNote> _buildMusicNotes() {
    final notes = <MusicNote>[];
    // Sort by column (time), then by row (pitch descending)
    final sorted = _selectedCells.toList()
      ..sort((a, b) {
        final colCmp = a.$2.compareTo(b.$2);
        if (colCmp != 0) return colCmp;
        return a.$1.compareTo(b.$1);
      });

    for (int i = 0; i < sorted.length; i++) {
      final (row, col) = sorted[i];
      notes.add(MusicNote(
        noteName: _noteNames[row],
        frequency: _noteFrequencies[row],
        startTime: col * 0.5,
        duration: 0.5,
        order: i,
      ));
    }
    return notes;
  }

  Future<void> _simulatePlayback() async {
    if (_isPlaying) return;
    setState(() => _isPlaying = true);

    for (int beat = 0; beat < _totalBeats; beat++) {
      if (!mounted) return;
      setState(() => _playbackBeat = beat);
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (mounted) {
      setState(() {
        _isPlaying = false;
        _playbackBeat = -1;
      });
    }
  }

  void _shareToCommmunity() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해주세요')),
      );
      return;
    }
    if (_selectedCells.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('음표를 하나 이상 추가해주세요')),
      );
      return;
    }

    final post = CommunityPost(
      id: 'compose_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      userName: '나',
      content: '\uD83C\uDFBC 새 곡: $title',
      lessonTitle: title,
      instrument: 'piano',
      score: 0,
      likes: 0,
      isLiked: false,
      createdAt: DateTime.now(),
    );

    ref.read(communityProvider.notifier).addPost(post);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('커뮤니티에 공유되었습니다!'),
        backgroundColor: AppColors.scorePerfect,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tier = ref.watch(subscriptionTierProvider);
    final isPremium =
        tier == SubscriptionTier.premium || tier == SubscriptionTier.student;
    final musicNotes = _buildMusicNotes();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('악보 만들기'),
        backgroundColor: AppColors.bgSurface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title input
                TextField(
                  controller: _titleController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: '곡 제목을 입력하세요',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.bgCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.music_note,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Piano roll header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '피아노 롤',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Playback button
                    IconButton(
                      onPressed: _isPlaying ? null : _simulatePlayback,
                      icon: Icon(
                        _isPlaying ? Icons.stop_circle : Icons.play_circle,
                        color: _isPlaying
                            ? AppColors.textSecondary
                            : AppColors.accent,
                        size: 36,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Piano roll grid
                _buildPianoRollGrid(),
                const SizedBox(height: 24),

                // Sheet music preview
                const Text(
                  '악보 미리보기',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SheetMusicWidget(
                  notes: musicNotes,
                  showLabels: true,
                  height: 180,
                ),
                const SizedBox(height: 24),

                // Share button
                ElevatedButton.icon(
                  onPressed: _shareToCommmunity,
                  icon: const Icon(Icons.share),
                  label: const Text(
                    '커뮤니티에 공유',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),

          // Premium gate overlay
          if (!isPremium) _buildPremiumOverlay(),
        ],
      ),
    );
  }

  Widget _buildPianoRollGrid() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgSurface, width: 1.5),
      ),
      child: Column(
        children: List.generate(_totalRows, (row) {
          return Row(
            children: [
              // Note label
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.bgDark.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  borderRadius: row == 0
                      ? const BorderRadius.only(topLeft: Radius.circular(15))
                      : row == _totalRows - 1
                          ? const BorderRadius.only(
                              bottomLeft: Radius.circular(15))
                          : null,
                ),
                child: Text(
                  _noteNames[row],
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              // Beat cells
              ...List.generate(_totalBeats, (col) {
                final isSelected = _selectedCells.contains((row, col));
                final isPlayhead = _isPlaying && col == _playbackBeat;
                final isWhiteKey = ![1, 3, 5].contains(row); // visual hint

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _toggleCell(row, col),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : isPlayhead
                                ? AppColors.accent.withValues(alpha: 0.15)
                                : isWhiteKey
                                    ? AppColors.bgCard
                                    : AppColors.bgSurface
                                        .withValues(alpha: 0.5),
                        border: Border.all(
                          color: AppColors.bgDark.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: isSelected
                          ? const Center(
                              child: Icon(
                                Icons.music_note,
                                color: Colors.white,
                                size: 18,
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              }),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPremiumOverlay() {
    return Positioned.fill(
      child: Container(
        color: AppColors.bgDark.withValues(alpha: 0.85),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.accentGold, width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline,
                  color: AppColors.accentGold,
                  size: 56,
                ),
                const SizedBox(height: 16),
                const Text(
                  '프리미엄 기능',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '악보 만들기는 프리미엄 또는 학생 구독자만\n이용할 수 있습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.push(RouteNames.subscription),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: AppColors.bgDark,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '구독 업그레이드',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
