import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'package:travel_mate_app/app/theme.dart';
import 'package:travel_mate_app/app/constants.dart';
import 'package:travel_mate_app/presentation/common/app_app_bar.dart';
import 'package:travel_mate_app/core/services/auth_service.dart';

/// 계정 설정 화면. 로그아웃·계정 삭제 등.
class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _changeEmail(BuildContext context) async {
    final TextEditingController emailController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이메일 변경'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: emailController,
            decoration: const InputDecoration(labelText: '새 이메일'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '새 이메일을 입력하세요';
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return '올바른 이메일 주소를 입력하세요';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                try {
                  await FirebaseAuth.instance.currentUser?.updateEmail(emailController.text.trim());
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('이메일이 변경되었습니다.')),
                    );
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  setState(() {
                    _errorMessage = '이메일 변경 실패: ${e.toString()}';
                  });
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정 삭제'),
        content: const Text(
          '정말 계정을 삭제하시겠습니까? 삭제된 계정은 복구할 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          throw Exception('로그인이 필요합니다.');
        }

        // Call backend API to delete user data
        // TODO: Implement actual API call for backend to delete user data in MariaDB
        // For now, simulate deletion in Firebase Auth directly
        await currentUser.delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('계정이 삭제되었습니다.')),
          );
          context.go('/login'); // Redirect to login screen after deletion
        }
      } catch (e) {
        setState(() {
          _errorMessage = '계정 삭제 실패: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: '계정 설정'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('이메일 변경'),
                    onTap: () => _changeEmail(context),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('비밀번호 변경'),
                    onTap: () {
                      // TODO: Implement change password functionality (Firebase Auth)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('비밀번호 변경 기능은 준비 중입니다.')),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app),
                    title: const Text('로그아웃'),
                    onTap: () async {
                      await Provider.of<AuthService>(context, listen: false).signOut();
                      if (mounted) {
                        context.go('/login'); // Redirect to login after logout
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('계정 삭제', style: TextStyle(color: Colors.red)),
                    onTap: () => _deleteAccount(context),
                  ),
                  const Spacer(),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
