import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';

class _VideoItem {
  final String title;
  final String channel;
  final String duration;
  final String youtubeId;

  const _VideoItem({required this.title, required this.channel, required this.duration, required this.youtubeId});

  String get thumbnailUrl => 'https://img.youtube.com/vi/$youtubeId/mqdefault.jpg';
  String get url => 'https://www.youtube.com/watch?v=$youtubeId';
}

/// 악기별 추천 영상 데이터
Map<String, List<_VideoItem>> _recommendedVideos = {
  'piano': [
    _VideoItem(title: '피아노 초보 첫 레슨', channel: '피아노 독학', duration: '15:20', youtubeId: 'dQw4w9WgXcQ'),
    _VideoItem(title: '반짝반짝 작은별 피아노 튜토리얼', channel: '뮤직 클래스', duration: '8:45', youtubeId: 'dQw4w9WgXcQ'),
    _VideoItem(title: '피아노 올바른 자세와 손 모양', channel: '피아노 마스터', duration: '12:30', youtubeId: 'dQw4w9WgXcQ'),
  ],
  'guitar': [
    _VideoItem(title: '기타 초보 Am 코드 잡는 법', channel: '기타 독학', duration: '10:15', youtubeId: 'dQw4w9WgXcQ'),
    _VideoItem(title: '기타 스트로크 기초', channel: '기타맨', duration: '7:30', youtubeId: 'dQw4w9WgXcQ'),
    _VideoItem(title: '기타 핑거피킹 입문', channel: '뮤직 클래스', duration: '14:20', youtubeId: 'dQw4w9WgXcQ'),
  ],
  'violin': [
    _VideoItem(title: '바이올린 첫 활 긋기', channel: '바이올린 클래스', duration: '11:00', youtubeId: 'dQw4w9WgXcQ'),
    _VideoItem(title: '바이올린 자세 완벽 가이드', channel: '클래식 뮤직', duration: '16:40', youtubeId: 'dQw4w9WgXcQ'),
    _VideoItem(title: '바이올린 기본 스케일', channel: '바이올린 독학', duration: '9:15', youtubeId: 'dQw4w9WgXcQ'),
  ],
  'drums': [
    _VideoItem(title: '드럼 기초 4비트 배우기', channel: '드럼 스쿨', duration: '8:50', youtubeId: 'dQw4w9WgXcQ'),
    _VideoItem(title: '드럼 스틱 잡는 법', channel: '드러머TV', duration: '6:30', youtubeId: 'dQw4w9WgXcQ'),
    _VideoItem(title: '드럼 8비트 완벽 마스터', channel: '드럼 스쿨', duration: '12:00', youtubeId: 'dQw4w9WgXcQ'),
  ],
};

class RecommendedVideos extends StatelessWidget {
  final String instrument;
  final String? title;
  const RecommendedVideos({super.key, required this.instrument, this.title});

  @override
  Widget build(BuildContext context) {
    final videos = _recommendedVideos[instrument] ?? _recommendedVideos['piano']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.play_circle_rounded, color: AppColors.scoreMiss, size: 20),
            const SizedBox(width: 8),
            Text(title ?? '추천 영상', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            itemBuilder: (context, i) {
              final v = videos[i];
              return GestureDetector(
                onTap: () async {
                  final uri = Uri.parse(v.url);
                  if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                child: Container(
                  width: 200,
                  margin: EdgeInsets.only(right: i < videos.length - 1 ? 12 : 0),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.bgSurface),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 썸네일 영역
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Stack(
                          children: [
                            Center(child: Icon(Icons.play_circle_filled_rounded, color: AppColors.scoreMiss, size: 36)),
                            Positioned(
                              bottom: 4, right: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
                                child: Text(v.duration, style: TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace')),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 제목
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
                        child: Text(v.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(v.channel, style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
