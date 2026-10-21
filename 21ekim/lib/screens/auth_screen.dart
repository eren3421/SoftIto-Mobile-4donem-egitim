import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../services/i18n_service.dart';

enum AuthViewMode {
  login,
  register,
  forgotPassword,
  resetPassword,
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthViewMode _mode = AuthViewMode.login;

  final _emailController = TextEditingController(text: 'demo@bahcivan.com');
  final _passwordController = TextEditingController(text: '123456');
  final _confirmPasswordController = TextEditingController();

  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final lang = state.lang;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand Logo & Title
                    _buildHeader(lang),
                    const SizedBox(height: 24),

                    // Error Message Banner (Direct wireframe requirement)
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: Color(0xFFEF4444), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Color(0xFFB91C1C),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Current Auth Form Form
                    _buildFormBody(context, state, lang),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String lang) {
    String subTitle;
    switch (_mode) {
      case AuthViewMode.login:
        subTitle = AppStrings.get('user_login', lang);
        break;
      case AuthViewMode.register:
        subTitle = AppStrings.get('register_title', lang);
        break;
      case AuthViewMode.forgotPassword:
        subTitle = AppStrings.get('forgot_pw_title', lang);
        break;
      case AuthViewMode.resetPassword:
        subTitle = AppStrings.get('reset_pw_title', lang);
        break;
    }

    return Column(
      children: [
        // Leaf/Waterdrop Badge
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1B5E20).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Text('🌿', style: TextStyle(fontSize: 36)),
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.get('app_title', lang),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subTitle,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  Widget _buildFormBody(BuildContext context, AppState state, String lang) {
    switch (_mode) {
      case AuthViewMode.login:
        return _buildLoginForm(state, lang);
      case AuthViewMode.register:
        return _buildRegisterForm(state, lang);
      case AuthViewMode.forgotPassword:
        return _buildForgotPasswordForm(lang);
      case AuthViewMode.resetPassword:
        return _buildResetPasswordForm(state, lang);
    }
  }

  // 1A. Login Form
  Widget _buildLoginForm(AppState state, String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: AppStrings.get('email_label', lang),
            hintText: AppStrings.get('email_hint', lang),
            prefixIcon: const Icon(Icons.email_outlined, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: AppStrings.get('password_label', lang),
            hintText: AppStrings.get('password_hint', lang),
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            final email = _emailController.text.trim();
            final pw = _passwordController.text.trim();
            if (email.isEmpty || pw.isEmpty) {
              setState(() {
                _errorMessage = AppStrings.get('auth_error_msg', lang);
              });
              return;
            }
            final success = await state.login(email, pw);
            if (!success) {
              setState(() {
                _errorMessage = AppStrings.get('auth_error_msg', lang);
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            AppStrings.get('login_btn', lang),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 4,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _mode = AuthViewMode.forgotPassword;
                });
              },
              child: Text(
                AppStrings.get('forgot_password_link', lang),
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _mode = AuthViewMode.register;
                });
              },
              child: Text(
                AppStrings.get('create_account_link', lang),
                style: const TextStyle(
                  color: Color(0xFF1B5E20),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 1B. Register Form
  Widget _buildRegisterForm(AppState state, String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: AppStrings.get('email_label', lang),
            prefixIcon: const Icon(Icons.email_outlined, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: AppStrings.get('password_label', lang),
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            final email = _emailController.text.trim();
            final pw = _passwordController.text.trim();
            if (email.isEmpty || pw.isEmpty) {
              setState(() {
                _errorMessage = AppStrings.get('auth_error_msg', lang);
              });
              return;
            }
            await state.register(email, pw);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            AppStrings.get('register_btn', lang),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                _errorMessage = null;
                _mode = AuthViewMode.login;
              });
            },
            child: Text(
              AppStrings.get('back_to_login', lang),
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
        ),
      ],
    );
  }

  // 1C. Forgot Password (E-mail Check step)
  Widget _buildForgotPasswordForm(String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: AppStrings.get('email_label', lang),
            prefixIcon: const Icon(Icons.email_outlined, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            AppStrings.get('forgot_pw_instruction', lang),
            style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (_emailController.text.trim().isEmpty) {
              setState(() {
                _errorMessage = AppStrings.get('auth_error_msg', lang);
              });
              return;
            }
            setState(() {
              _errorMessage = null;
              _mode = AuthViewMode.resetPassword;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            AppStrings.get('verify_continue_btn', lang),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                _errorMessage = null;
                _mode = AuthViewMode.login;
              });
            },
            child: Text(
              AppStrings.get('back_to_login', lang),
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
        ),
      ],
    );
  }

  // 1D. Reset Password Form (Enter new password & refresh)
  Widget _buildResetPasswordForm(AppState state, String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: AppStrings.get('new_password_label', lang),
            prefixIcon: const Icon(Icons.lock_reset_rounded, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: AppStrings.get('confirm_password_label', lang),
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            final pw = _passwordController.text.trim();
            final confirm = _confirmPasswordController.text.trim();
            if (pw.isEmpty || pw != confirm) {
              setState(() {
                _errorMessage = AppStrings.get('auth_pw_mismatch', lang);
              });
              return;
            }
            await state.resetPassword(_emailController.text.trim(), pw);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            AppStrings.get('refresh_pw_btn', lang),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                _errorMessage = null;
                _mode = AuthViewMode.login;
              });
            },
            child: Text(
              AppStrings.get('back_to_login', lang),
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
        ),
      ],
    );
  }
}
