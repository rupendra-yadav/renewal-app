import 'package:flutter/material.dart';
import 'package:renewtrack/services/authProvider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── Sign-in handler ──────────────────────────
  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = AuthScope.of(context);

    final success = await auth.login(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
    // On failure, AuthProvider.error is set → _ErrorBanner renders automatically
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild whenever AuthProvider notifies (loading / error changes)
    final auth = AuthScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Purple header ────────────────────────
          const _Header(),

          // ── Scrollable form ──────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xxl,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Heading
                    Text(
                      'Welcome back!',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Sign in to continue managing your renewals.',
                      style: TextStyle(
                        fontSize: AppTextSize.sm,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),

                    // ── API error banner ──────────────
                    if (auth.error != null)
                      _ErrorBanner(
                        message: auth.error!,
                        onDismiss: auth.clearError,
                      ),

                    // ── Email ─────────────────────────
                    CustomTextField(
                      label: 'Email address',
                      hint: 'you@example.com',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      onChanged: (_) {
                        if (auth.error != null) auth.clearError();
                      },
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Password ──────────────────────
                    CustomTextField(
                      label: 'Password',
                      controller: _passCtrl,
                      obscureText: _obscurePass,
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePass = !_obscurePass),
                      ),
                      onChanged: (_) {
                        if (auth.error != null) auth.clearError();
                      },
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Enter your password';
                        }
                        if (v.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // ── Forgot password ───────────────
                    const SizedBox(height: AppSpacing.xl),

                    // ── Sign in button ────────────────
                    PrimaryButton(
                      label: 'Sign in',
                      onPressed: auth.loading ? null : _signIn,
                      isLoading: auth.loading,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Error banner
// ─────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.expired,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.expiredText.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.expiredText,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: AppTextSize.sm,
                color: AppColors.expiredText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(
              Icons.close_rounded,
              color: AppColors.expiredText,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.xl,
        bottom: AppSpacing.xxxl,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
      ),
      child: Column(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.autorenew_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'RenewTrack',
            style: TextStyle(
              fontSize: AppTextSize.xxl,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Manage all your client renewals',
            style: TextStyle(
              fontSize: AppTextSize.sm,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Google icon
// ─────────────────────────────────────────────────
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      width: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: Color(0xFF4285F4),
          ),
        ),
      ),
    );
  }
}
