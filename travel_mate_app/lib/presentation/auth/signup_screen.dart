import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_mate_app/app/theme.dart';
import 'package:travel_mate_app/app/constants.dart';
import 'package:travel_mate_app/core/services/auth_service.dart';
import 'package:travel_mate_app/presentation/common/app_app_bar.dart';

/// 회원가입 화면. 이메일/비밀번호 가입 지원.
class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isCheckingEmail = false;
  String? _errorMessage;
  /// null: 미확인, true: 사용 가능, false: 이미 사용 중
  bool? _emailDuplicateChecked;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _checkEmailDuplicate() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = '이메일을 입력한 뒤 중복 확인해 주세요.');
      return;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() => _errorMessage = '올바른 이메일 주소를 입력해 주세요.');
      return;
    }
    setState(() {
      _isCheckingEmail = true;
      _errorMessage = null;
      _emailDuplicateChecked = null;
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final inUse = await authService.isEmailAlreadyInUse(email);
      if (mounted) {
        setState(() {
          _emailDuplicateChecked = !inUse;
          _isCheckingEmail = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(inUse ? '이미 사용 중인 이메일입니다.' : '사용 가능한 이메일입니다.'),
            backgroundColor: inUse ? AppColors.error : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingEmail = false;
          _errorMessage = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
        });
      }
    }
  }

  void _signup() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final inUse = await authService.isEmailAlreadyInUse(email);
        if (inUse && mounted) {
          setState(() {
            _emailDuplicateChecked = false;
            _errorMessage = '이미 사용 중인 이메일입니다. 다른 이메일을 사용해 주세요.';
            _isLoading = false;
          });
          return;
        }

        if (!mounted) return;
        final user = await authService.registerWithEmailAndPassword(
          email,
          _passwordController.text,
        );

        if (user != null) {
          context.go('/');
        } else {
          setState(() {
            _errorMessage = '회원가입에 실패했습니다. 다시 시도해 주세요.';
          });
        }
      } on FirebaseAuthException catch (e) {
        final message = e.code == 'email-already-in-use'
            ? '이미 사용 중인 이메일입니다. 다른 이메일을 사용해 주세요.'
            : '회원가입에 실패했습니다. 다시 시도해 주세요.';
        setState(() => _errorMessage = message);
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().contains('firebase_auth')
              ? '회원가입에 실패했습니다. 다시 시도해 주세요.'
              : '오류가 발생했습니다: ${e.toString()}';
        });
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: '회원가입'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '계정 만들기',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLarge),
                TextFormField(
                  controller: _emailController,
                  onChanged: (_) => setState(() => _emailDuplicateChecked = null),
                  decoration: InputDecoration(
                    labelText: '이메일',
                    hintText: '이메일을 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    prefixIcon: const Icon(Icons.email),
                    suffixIcon: _emailDuplicateChecked == true
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : _emailDuplicateChecked == false
                            ? const Icon(Icons.cancel, color: AppColors.error)
                            : null,
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
                const SizedBox(height: AppConstants.spacingSmall),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isCheckingEmail ? null : _checkEmailDuplicate,
                    icon: _isCheckingEmail
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search, size: 20),
                    label: Text(_isCheckingEmail ? '확인 중...' : '이메일 중복 확인'),
                  ),
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
                const SizedBox(height: AppConstants.spacingMedium),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호 확인',
                    hintText: '비밀번호를 다시 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호 확인을 입력하세요';
                    }
                    if (value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다';
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
                    onPressed: _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      ),
                    ),
                    child: Text(
                      '회원가입',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLarge),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('이미 계정이 있으신가요?'),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        '로그인',
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
