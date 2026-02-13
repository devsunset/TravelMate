import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_mate_app/app/theme.dart';
import 'package:travel_mate_app/app/constants.dart';
import 'package:travel_mate_app/core/services/auth_service.dart';
import 'package:travel_mate_app/presentation/common/app_app_bar.dart';

/// 로그인 화면. 이메일/비밀번호, Google 로그인 지원.
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final user = await authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (user != null) {
          if (mounted) context.go('/');
        } else {
          setState(() {
            _errorMessage = '로그인에 실패했습니다. 이메일과 비밀번호를 확인해 주세요.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().contains('firebase_auth')
              ? '이메일 또는 비밀번호가 올바르지 않습니다.'
              : '오류가 발생했습니다: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.signInWithGoogle();

      if (user != null) {
        if (mounted) context.go('/');
      } else {
        setState(() {
          _errorMessage = 'Google 로그인이 취소되었거나 실패했습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Google 로그인 실패: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: '로그인', showBackButton: false),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '다시 오신 걸 환영해요!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLarge),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: '이메일',
                    hintText: '이메일을 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이메일을 입력하세요';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return '올바른 이메일 주소를 입력하세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    hintText: '비밀번호를 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력하세요';
                    }
                    if (value.length < 6) {
                      return '비밀번호는 6자 이상이어야 합니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spacingLarge),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      ),
                    ),
                    child: Text(
                      '로그인',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                TextButton(
                  onPressed: () async {
                    if (_emailController.text.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('비밀번호 재설정을 위해 유효한 이메일을 입력해주세요.')),
                      );
                      return;
                    }
                    try {
                      setState(() {
                        _isLoading = true;
                      });
                      await Provider.of<AuthService>(context, listen: false)
                          .sendPasswordResetEmail(_emailController.text.trim());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('비밀번호 재설정 이메일을 보냈습니다. 이메일을 확인해주세요.')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('비밀번호 재설정 실패: ${e.toString()}')),
                      );
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  child: Text(
                    '비밀번호를 잊으셨나요?',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLarge),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                      child: Text(
                        '또는',
                        style: TextStyle(color: AppColors.grey),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingLarge),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _loginWithGoogle,
                    icon: Icon(Icons.g_mobiledata, size: 24, color: AppColors.textPrimary),
                    label: Text(
                      'Google로 로그인',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      ),
                      side: BorderSide(color: AppColors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLarge),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('계정이 없으신가요?'),
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      child: Text(
                        '회원가입',
                        style: TextStyle(color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
