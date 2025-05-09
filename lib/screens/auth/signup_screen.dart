import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signUp(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입에 성공했습니다. 로그인해주세요.')),
        );
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen())
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('회원가입'),
        ),
        body: SafeArea(
        child: Center(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
    child: Form(
    key: _formKey,
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
    // 이름 입력 필드
    CustomTextField(
    controller: _nameController,
    hintText: '이름',
    prefixIcon: Icons.person_outline,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return '이름을 입력해주세요';
    }
    return null;
    },
    ),
    const SizedBox(height: 16),

    // 이메일 입력 필드
    CustomTextField(
    controller: _emailController,
    hintText: '이메일',
    prefixIcon: Icons.email_outlined,
    keyboardType: TextInputType.emailAddress,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return '이메일을 입력해주세요';
    }
    if (!value.contains('@')) {
    return '유효한 이메일 주소를 입력해주세요';
    }
    return null;
    },
    ),
    const SizedBox(height: 16),

    // 비밀번호 입력 필드
    CustomTextField(
    controller: _passwordController,
    hintText: '비밀번호',
    prefixIcon: Icons.lock_outline,
    obscureText: _obscurePassword,
    suffixIcon: IconButton(
    icon: Icon(
    _obscurePassword ? Icons.visibility_off : Icons.visibility,
    color: Colors.grey,
    ),
    onPressed: () {
    setState(() {
    _obscurePassword = !_obscurePassword;
    });
    },
    ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '비밀번호를 입력해주세요';
        }
        if (value.length < 6) {
          return '비밀번호는 최소 6자 이상이어야 합니다';
        }
        return null;
      },
    ),
      const SizedBox(height: 16),

      // 비밀번호 확인 필드
      CustomTextField(
        controller: _confirmPasswordController,
        hintText: '비밀번호 확인',
        prefixIcon: Icons.lock_outline,
        obscureText: _obscureConfirmPassword,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '비밀번호를 다시 입력해주세요';
          }
          if (value != _passwordController.text) {
            return '비밀번호가 일치하지 않습니다';
          }
          return null;
        },
      ),
      const SizedBox(height: 24),

      // 에러 메시지
      if (authProvider.error != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            authProvider.error!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),

      // 회원가입 버튼
      CustomButton(
        text: '회원가입',
        isLoading: authProvider.isLoading,
        onPressed: _signUp,
      ),
      const SizedBox(height: 16),

      // 로그인 화면으로 돌아가기
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('이미 계정이 있으신가요? 로그인으로 돌아가기'),
      ),
    ],
    ),
    ),
        ),
        ),
        ),
    );
  }
}