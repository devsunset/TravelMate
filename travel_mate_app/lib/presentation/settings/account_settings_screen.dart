import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:travel_mate_app/app/theme.dart';
import 'package:travel_mate_app/app/constants.dart';
import 'package:travel_mate_app/presentation/common/app_app_bar.dart';
import 'package:travel_mate_app/core/services/auth_service.dart';
import 'package:travel_mate_app/domain/usecases/delete_user_account.dart';

/// 계정 설정 화면. 로그아웃, 계정 삭제. 사용자 식별은 백엔드 id만 사용(이메일 미수집).
class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _deleteAccount(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('계정 삭제', style: GoogleFonts.outfit(color: AppColors.textPrimary)),
        content: Text(
          '정말 계정을 삭제하시겠습니까? 삭제된 계정은 복구할 수 없습니다.',
          style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('취소', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary))),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = await authService.getCurrentBackendUserId();
      if (userId == null || userId.isEmpty) throw Exception('로그인이 필요합니다.');
      final deleteUserAccount = Provider.of<DeleteUserAccount>(context, listen: false);
      await deleteUserAccount.execute(userId);
      await Provider.of<AuthService>(context, listen: false).signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('계정이 삭제되었습니다.'), backgroundColor: AppColors.textSecondary));
        context.go('/login');
      }
    } catch (e) {
      setState(() => _errorMessage = '계정 삭제에 실패했습니다.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final hasPasswordProvider = currentUser?.providerData.any((p) => p.providerId == 'password') ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E32),
      appBar: const AppAppBar(title: '계정 설정'),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 배경 이미지 (설정/계정 느낌)
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1434494878577-86c23bcb06b9?w=800', // 좀 더 정돈된/정적인 느낌의 이미지
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF1E1E32)),
            ),
          ),
          // 그라데이션 오버레이 (ProfileDetailScreen과 동일한 코드)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1E1E32).withOpacity(0.82),
                    const Color(0xFF1E1E32).withOpacity(0.88),
                    const Color(0xFF1E1E32).withOpacity(0.95),
                  ],
                ),
              ),
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (hasPasswordProvider) ...[
                        _SettingsTile(
                          icon: Icons.lock_outline_rounded,
                          label: '비밀번호 변경',
                          color: AppColors.accent,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('비밀번호 변경 기능은 준비 중입니다.'), backgroundColor: AppColors.surface),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      _SettingsTile(
                        icon: Icons.vpn_key_rounded,
                        label: 'API 테스트용 토큰 복사',
                        color: AppColors.secondary,
                        onTap: () async {
                          final authService = Provider.of<AuthService>(context, listen: false);
                          final token = await authService.getIdToken();
                          if (token == null || token.isEmpty) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('토큰을 가져올 수 없습니다. 로그인 상태를 확인하세요.')),
                              );
                            }
                            return;
                          }
                          await Clipboard.setData(ClipboardData(text: token));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('토큰이 클립보드에 복사되었습니다. curl/Postman에서 Authorization: Bearer <붙여넣기> 로 사용하세요.')),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _SettingsTile(
                        icon: Icons.logout_rounded,
                        label: '로그아웃',
                        color: AppColors.primary,
                        onTap: () async {
                          await Provider.of<AuthService>(context, listen: false).signOut();
                          if (mounted) context.go('/login');
                        },
                      ),
                      const SizedBox(height: 16),
                      _SettingsTile(
                        icon: Icons.delete_forever_rounded,
                        label: '계정 삭제',
                        color: AppColors.error,
                        onTap: () => _deleteAccount(context),
                        isDanger: true,
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.error.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline_rounded, size: 20, color: AppColors.error),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(_errorMessage!, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.error)),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDanger;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    // ProfileDetailScreen의 카드 효과와 동일하게 계산
    final cardBase = Color.lerp(Colors.white, color, 0.12)!;
    final cardHighlight = Color.lerp(Colors.white, color, 0.22)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cardBase, cardHighlight, color.withOpacity(0.12)],
              stops: const [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.2), blurRadius: 14, offset: const Offset(0, 4)),
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold, // 프로필 카드 느낌을 위해 볼드 처리
                    color: isDanger ? AppColors.error : color, // 텍스트 컬러도 컬러감 반영
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 24, color: color.withOpacity(0.7)),
            ],
          ),
        ),
      ),
    );
  }
}
