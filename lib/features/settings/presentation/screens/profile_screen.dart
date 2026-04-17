import '../../../../core/utils/locale_text.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nicknameCtrl = TextEditingController();
  File? _newPhoto;
  bool _saving = false;
  String _currentName = '';
  String _currentEmail = '';
  bool _isGoogleUser = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    final user = FirebaseAuth.instance.currentUser;
    _currentName = user?.displayName ?? '';
    _currentEmail = user?.email ?? '';
    _nicknameCtrl.text = _currentName;
    _isGoogleUser = user?.providerData.any((p) => p.providerId == 'google.com') ?? false;
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512);
    if (img != null) setState(() => _newPhoto = File(img.path));
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final newName = _nicknameCtrl.text.trim();
        if (newName.isNotEmpty && newName != _currentName) {
          await user.updateDisplayName(newName);
        }
        // 변경 반영
        await user.reload();
        final updated = FirebaseAuth.instance.currentUser;
        setState(() {
          _currentName = updated?.displayName ?? newName;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로필이 저장되었습니다.'), backgroundColor: AppColors.scorePerfect),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e'), backgroundColor: AppColors.scoreMiss),
        );
      }
    }
    setState(() => _saving = false);
  }

  void _showPasswordChange() {
    final currentPwCtrl = TextEditingController();
    final newPwCtrl = TextEditingController();
    final confirmPwCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('비밀번호 변경', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_isGoogleUser)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: AppColors.accentGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.accentGold, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Google 계정은 Google 설정에서 비밀번호를 변경하세요.', style: TextStyle(color: AppColors.accentGold, fontSize: 12))),
                    ],
                  ),
                ),
              if (!_isGoogleUser) ...[
                _PwField(controller: currentPwCtrl, label: '현재 비밀번호'),
                const SizedBox(height: 12),
              ],
              _PwField(controller: newPwCtrl, label: '새 비밀번호'),
              const SizedBox(height: 12),
              _PwField(controller: confirmPwCtrl, label: '새 비밀번호 확인'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isGoogleUser ? null : () async {
                    if (newPwCtrl.text != confirmPwCtrl.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('비밀번호가 일치하지 않습니다.'), backgroundColor: AppColors.scoreMiss),
                      );
                      return;
                    }
                    if (newPwCtrl.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('비밀번호는 6자 이상이어야 합니다.'), backgroundColor: AppColors.scoreMiss),
                      );
                      return;
                    }
                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user?.email != null) {
                        final cred = EmailAuthProvider.credential(email: user!.email!, password: currentPwCtrl.text);
                        await user.reauthenticateWithCredential(cred);
                        await user.updatePassword(newPwCtrl.text);
                        if (ctx.mounted) Navigator.pop(ctx);

                        // 로그인 유지 여부
                        if (mounted) _askKeepLogin();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('변경 실패: 현재 비밀번호를 확인하세요.'), backgroundColor: AppColors.scoreMiss),
                        );
                      }
                    }
                  },
                  child: const Text('변경'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _askKeepLogin() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: Text('비밀번호 변경 완료', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('로그인을 유지하시겠습니까?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              // 로그아웃 → 재로그인
              await ref.read(authNotifierProvider.notifier).signOut();
              if (mounted) context.go(RouteNames.login);
            },
            child: Text('아니오 (재로그인)', style: TextStyle(color: AppColors.scoreMiss)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('비밀번호가 변경되었습니다.'), backgroundColor: AppColors.scorePerfect),
              );
            },
            child: Text('예 (유지)', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;

    return Scaffold(
      appBar: AppBar(title: const Text('프로필 설정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 프로필 사진
            GestureDetector(
              onTap: _pickPhoto,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    backgroundImage: _newPhoto != null
                        ? FileImage(_newPhoto!) as ImageProvider
                        : photoUrl != null ? NetworkImage(photoUrl) as ImageProvider : null,
                    child: _newPhoto == null && photoUrl == null
                        ? Text(
                            (_currentName.isNotEmpty ? _currentName[0] : '?').toUpperCase(),
                            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                      child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('사진 변경', style: TextStyle(color: AppColors.primary, fontSize: 13)),
            const SizedBox(height: 24),

            // 닉네임
            TextField(
              controller: _nicknameCtrl,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
              decoration: InputDecoration(
                labelText: '닉네임',
                prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 16),

            // 이메일 (읽기 전용)
            TextField(
              readOnly: true,
              controller: TextEditingController(text: _currentEmail),
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              decoration: InputDecoration(
                labelText: '이메일',
                prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
                suffixIcon: _isGoogleUser ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                    child: Text('Google', style: TextStyle(color: AppColors.primary, fontSize: 10)),
                  ),
                ) : null,
              ),
            ),
            const SizedBox(height: 24),

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveProfile,
                child: _saving
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('프로필 저장'),
              ),
            ),
            const SizedBox(height: 24),

            // 비밀번호 변경 (모든 사용자에게 표시)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showPasswordChange,
                icon: Icon(Icons.lock_outline),
                label: const Text('비밀번호 변경'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: BorderSide(color: AppColors.bgCard),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PwField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const _PwField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.lock_outline, color: AppColors.textSecondary),
      ),
    );
  }
}
