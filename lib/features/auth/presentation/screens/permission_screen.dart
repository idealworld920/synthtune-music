import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';

class PermissionScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const PermissionScreen({super.key, required this.onComplete});

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('permissions_shown') ?? false);
  }

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _micGranted = false;
  bool _cameraGranted = false;
  int _currentPage = 0;

  final _permissions = [
    _PermissionInfo(
      icon: Icons.mic_rounded,
      title: '마이크 권한',
      description: '연습 시 연주를 녹음하고\nAI가 음정을 실시간 분석합니다.',
      why: '정확한 피드백을 위해 필요해요',
      permission: Permission.microphone,
      color: AppColors.scorePerfect,
    ),
    _PermissionInfo(
      icon: Icons.videocam_rounded,
      title: '카메라 권한',
      description: '연습 중 연주 자세를 촬영하여\nAI가 자세 피드백을 제공합니다.',
      why: '자세 분석 및 녹화를 위해 필요해요',
      permission: Permission.camera,
      color: AppColors.primary,
    ),
  ];

  Future<void> _requestPermission(int index) async {
    final info = _permissions[index];
    final status = await info.permission.request();

    setState(() {
      if (index == 0) _micGranted = status.isGranted;
      if (index == 1) _cameraGranted = status.isGranted;
    });
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('permissions_shown', true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // 진행 표시
              Row(
                children: List.generate(2, (i) => Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i == 0 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: i <= _currentPage ? AppColors.primary : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ),
              const Spacer(),

              // 아이콘
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _permissions[_currentPage].color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _permissions[_currentPage].icon,
                  color: _permissions[_currentPage].color,
                  size: 48,
                ),
              ),
              const SizedBox(height: 32),

              // 제목
              Text(
                _permissions[_currentPage].title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // 설명
              Text(
                _permissions[_currentPage].description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 12),

              // 이유
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _permissions[_currentPage].color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _permissions[_currentPage].color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, color: _permissions[_currentPage].color, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _permissions[_currentPage].why,
                      style: TextStyle(color: _permissions[_currentPage].color, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 상태 표시
              if ((_currentPage == 0 && _micGranted) || (_currentPage == 1 && _cameraGranted))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.scorePerfect.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppColors.scorePerfect, size: 18),
                      const SizedBox(width: 6),
                      Text('허용됨', style: TextStyle(color: AppColors.scorePerfect, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),

              // 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    if ((_currentPage == 0 && !_micGranted) || (_currentPage == 1 && !_cameraGranted)) {
                      await _requestPermission(_currentPage);
                    }
                    if (_currentPage < 1) {
                      setState(() => _currentPage++);
                    } else {
                      await _complete();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    _currentPage == 0
                        ? (_micGranted ? '다음' : '마이크 허용')
                        : (_cameraGranted ? '시작하기' : '카메라 허용'),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 건너뛰기
              TextButton(
                onPressed: () {
                  if (_currentPage < 1) {
                    setState(() => _currentPage++);
                  } else {
                    _complete();
                  }
                },
                child: Text(
                  _currentPage < 1 ? '나중에 하기' : '건너뛰기',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionInfo {
  final IconData icon;
  final String title;
  final String description;
  final String why;
  final Permission permission;
  final Color color;

  const _PermissionInfo({
    required this.icon,
    required this.title,
    required this.description,
    required this.why,
    required this.permission,
    required this.color,
  });
}
