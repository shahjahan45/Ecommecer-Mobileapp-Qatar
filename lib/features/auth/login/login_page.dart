import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design_system/app_tokens.dart';
import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../navigation/main_navigation.dart';
import '../forgot_password/forgot_password_page.dart';
import '../register/register_page.dart';
import '../services/auth_service.dart';
import '../widgets/modern_text_field.dart';
import '../widgets/premium_auth_background.dart';
import '../widgets/premium_brand_header.dart';
import '../widgets/primary_button.dart';
import '../widgets/security_message.dart';
import '../widgets/social_login_button.dart';

class LoginPage extends StatefulWidget {
  final AuthService authService;

  const LoginPage({
    super.key,
    this.authService = const MockAuthService(),
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _loading = false;
  AuthProvider? _socialLoadingProvider;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loading || _socialLoadingProvider != null) return;

    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    HapticFeedback.selectionClick();
    setState(() => _loading = true);

    try {
      await widget.authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );

      if (!mounted) return;
      _openStore();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showFriendlyError();
    }
  }

  Future<void> _socialLogin(AuthProvider provider) async {
    if (_loading || _socialLoadingProvider != null) return;

    FocusManager.instance.primaryFocus?.unfocus();
    HapticFeedback.selectionClick();
    setState(() => _socialLoadingProvider = provider);

    try {
      await widget.authService.loginWithProvider(provider);
      if (!mounted) return;
      _openStore();
    } catch (_) {
      if (!mounted) return;
      setState(() => _socialLoadingProvider = null);
      _showFriendlyError();
    }
  }

  void _openStore() {
    Navigator.of(context).pushAndRemoveUntil(
      AppPageRoute(page: const MainNavigation()),
      (route) => false,
    );
  }

  void _showFriendlyError() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'We could not sign you in. Please check your details and try again.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardInset = mediaQuery.viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: PremiumAuthBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final compact = width < 360;
              final tablet = width >= 700;
              final horizontalPadding = tablet
                  ? 36.0
                  : compact
                      ? 14.0
                      : 20.0;

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const ClampingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  compact ? 12 : 18,
                  horizontalPadding,
                  24 + keyboardInset,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: AutofillGroup(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const FadeSlideIn(
                              child: PremiumBrandHeader(),
                            ),
                            SizedBox(height: compact ? 28 : 40),
                            FadeSlideIn(
                              delayMilliseconds: 40,
                              child: _HeroCopy(compact: compact),
                            ),
                            SizedBox(height: compact ? 22 : 30),
                            FadeSlideIn(
                              delayMilliseconds: 90,
                              child: _buildLoginCard(context, compact),
                            ),
                            const SizedBox(height: 18),
                            FadeSlideIn(
                              delayMilliseconds: 130,
                              child: _CreateAccountBar(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    AppPageRoute(page: const RegisterPage()),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 22),
                            const FadeSlideIn(
                              delayMilliseconds: 160,
                              child: SecurityMessage(),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context, bool compact) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.92),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C224F).withValues(alpha: 0.10),
            blurRadius: 38,
            spreadRadius: -8,
            offset: const Offset(0, 22),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.82),
            blurRadius: 2,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 18 : 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _AccountHeader(),
            SizedBox(height: compact ? 22 : 26),
            ModernTextField(
              controller: _emailController,
              focusNode: _emailFocus,
              label: 'Email address',
              hint: 'you@example.com',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
              onFieldSubmitted: (_) {
                _passwordFocus.requestFocus();
              },
            ),
            const SizedBox(height: 18),
            ModernTextField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              label: 'Password',
              hint: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              textInputAction: TextInputAction.done,
              obscureText: _obscurePassword,
              autofillHints: const [AutofillHints.password],
              validator: Validators.password,
              onFieldSubmitted: (_) => _login(),
              suffixIcon: IconButton(
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: AnimatedSwitcher(
                  duration: AppMotion.fast,
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    key: ValueKey(_obscurePassword),
                    color: AppColors.textSecondary,
                    size: 21,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _RememberAndForgotRow(
              value: _rememberMe,
              onChanged: (value) {
                setState(() => _rememberMe = value);
              },
              onForgotPassword: () {
                Navigator.push(
                  context,
                  AppPageRoute(page: const ForgotPasswordPage()),
                );
              },
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              label: 'Sign in',
              icon: Icons.arrow_forward_rounded,
              loading: _loading,
              onPressed: _socialLoadingProvider == null ? _login : null,
            ),
            const SizedBox(height: 24),
            const _SocialDivider(),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final stackButtons = constraints.maxWidth < 330;
                final googleButton = SocialLoginButton(
                  label: 'Google',
                  icon: const GoogleMark(),
                  loading: _socialLoadingProvider == AuthProvider.google,
                  onPressed: _loading ||
                          (_socialLoadingProvider != null &&
                              _socialLoadingProvider != AuthProvider.google)
                      ? null
                      : () => _socialLogin(AuthProvider.google),
                );
                final appleButton = SocialLoginButton(
                  label: 'Apple',
                  icon: const Icon(
                    Icons.apple,
                    color: Colors.black,
                    size: 24,
                  ),
                  loading: _socialLoadingProvider == AuthProvider.apple,
                  onPressed: _loading ||
                          (_socialLoadingProvider != null &&
                              _socialLoadingProvider != AuthProvider.apple)
                      ? null
                      : () => _socialLogin(AuthProvider.apple),
                );

                if (stackButtons) {
                  return Column(
                    children: [
                      googleButton,
                      const SizedBox(height: 10),
                      appleButton,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: googleButton),
                    const SizedBox(width: 12),
                    Expanded(child: appleButton),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  final bool compact;

  const _HeroCopy({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: compact ? 32 : 38,
                height: 1.02,
                letterSpacing: -1.35,
                color: const Color(0xFF161421),
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Sign in to continue shopping, manage your cart and follow your orders.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                fontSize: compact ? 14 : 15.5,
                height: 1.55,
              ),
        ),
      ],
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 13),
        const Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign in to your account',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Enter your details below',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RememberAndForgotRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onForgotPassword;

  const _RememberAndForgotRow({
    required this.value,
    required this.onChanged,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    final rememberControl = InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 0.82,
              child: Switch.adaptive(
                value: value,
                activeTrackColor: AppColors.primary,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 2),
            const Text(
              'Remember me',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );

    final forgot = TextButton(
      onPressed: onForgotPassword,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
      child: const Text(
        'Forgot password?',
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
      ),
    );

    // Wrap is intentionally used instead of a width breakpoint.
    // It keeps both controls on one line when they fit and naturally
    // moves the second control to the next line when device/font metrics
    // require more space. This removes the 412px breakpoint edge case.
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 0,
      children: [
        rememberControl,
        forgot,
      ],
    );
  }
}

class _SocialDivider extends StatelessWidget {
  const _SocialDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR CONTINUE WITH',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 9.5,
              letterSpacing: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}

class _CreateAccountBar extends StatelessWidget {
  final VoidCallback onPressed;

  const _CreateAccountBar({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.11),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 330;
          const prompt = Text(
            'New to DCX Online Store?',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          );
          final action = TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Create account',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward_ios_rounded, size: 13),
              ],
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                prompt,
                Align(alignment: Alignment.centerRight, child: action),
              ],
            );
          }

          return Row(
            children: [
              const Expanded(child: prompt),
              action,
            ],
          );
        },
      ),
    );
  }
}
