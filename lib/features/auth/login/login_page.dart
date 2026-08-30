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
  final _scrollController = ScrollController(keepScrollOffset: false);

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
    _scrollController.dispose();
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

  void _showSocialUnavailable(String provider) {
    if (_loading || _socialLoadingProvider != null) return;
    FocusManager.instance.primaryFocus?.unfocus();
    HapticFeedback.selectionClick();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$provider sign in is not enabled yet.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _openRegister() {
    Navigator.push(
      context,
      AppPageRoute(page: const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardInset = mediaQuery.viewInsets.bottom;
    final safeBottom = mediaQuery.padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: PremiumAuthBackground(
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final compact = width < 390;
              final veryCompact = width < 340;
              final tablet = width >= 700;
              final horizontalPadding = tablet
                  ? 40.0
                  : veryCompact
                      ? 12.0
                      : compact
                          ? 16.0
                          : 20.0;

              return SingleChildScrollView(
                controller: _scrollController,
                primary: false,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const ClampingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  compact ? 12 : 16,
                  horizontalPadding,
                  24 + safeBottom + keyboardInset,
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
                            SizedBox(height: compact ? 22 : 28),
                            FadeSlideIn(
                              delayMilliseconds: 40,
                              child: _HeroCopy(compact: compact),
                            ),
                            SizedBox(height: compact ? 22 : 28),
                            FadeSlideIn(
                              delayMilliseconds: 90,
                              child: _buildLoginCard(context, compact),
                            ),
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
        color: Colors.white.withValues(alpha: 0.975),
        borderRadius: BorderRadius.circular(compact ? 24 : 28),
        border: Border.all(
          color: const Color(0xFFE9E7F1).withValues(alpha: 0.82),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C224F).withValues(alpha: 0.07),
            blurRadius: 30,
            spreadRadius: -10,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          compact ? 17 : 22,
          compact ? 20 : 24,
          compact ? 17 : 22,
          compact ? 18 : 21,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AccountHeader(compact: compact),
            SizedBox(height: compact ? 21 : 25),
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
            SizedBox(height: compact ? 15 : 17),
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
            const SizedBox(height: 8),
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
            SizedBox(height: compact ? 20 : 23),
            const _SocialDivider(),
            const SizedBox(height: 15),
            _buildSocialIconRow(),
            SizedBox(height: compact ? 17 : 21),
            _SignUpPrompt(onPressed: _openRegister),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIconRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        const minFitSize = 46.0;
        const maxSize = 54.0;
        const scrollSize = 50.0;
        const buttonCount = 5;

        final calculatedSize =
            (constraints.maxWidth - (gap * (buttonCount - 1))) / buttonCount;
        final fits = calculatedSize >= minFitSize;
        final buttonSize = fits
            ? calculatedSize.clamp(minFitSize, maxSize).toDouble()
            : scrollSize;

        Widget socialButton({
          required String label,
          required Widget icon,
          required VoidCallback? onPressed,
          bool loading = false,
        }) {
          return SocialIconButton(
            label: label,
            icon: icon,
            loading: loading,
            size: buttonSize,
            onPressed: onPressed,
          );
        }

        final buttons = <Widget>[
          socialButton(
            label: 'Google',
            icon: const GoogleMark(),
            loading: _socialLoadingProvider == AuthProvider.google,
            onPressed: _loading ||
                    (_socialLoadingProvider != null &&
                        _socialLoadingProvider != AuthProvider.google)
                ? null
                : () => _socialLogin(AuthProvider.google),
          ),
          socialButton(
            label: 'Apple',
            icon: const Icon(
              Icons.apple,
              color: Colors.black,
              size: 28,
            ),
            loading: _socialLoadingProvider == AuthProvider.apple,
            onPressed: _loading ||
                    (_socialLoadingProvider != null &&
                        _socialLoadingProvider != AuthProvider.apple)
                ? null
                : () => _socialLogin(AuthProvider.apple),
          ),
          socialButton(
            label: 'Facebook',
            icon: const FacebookMark(),
            onPressed: _loading || _socialLoadingProvider != null
                ? null
                : () => _showSocialUnavailable('Facebook'),
          ),
          socialButton(
            label: 'X',
            icon: const XMark(),
            onPressed: _loading || _socialLoadingProvider != null
                ? null
                : () => _showSocialUnavailable('X'),
          ),
          socialButton(
            label: 'Microsoft',
            icon: const MicrosoftMark(),
            onPressed: _loading || _socialLoadingProvider != null
                ? null
                : () => _showSocialUnavailable('Microsoft'),
          ),
        ];

        if (fits) {
          return Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: gap,
            runSpacing: gap,
            children: buttons,
          );
        }

        return SizedBox(
          height: scrollSize,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var index = 0; index < buttons.length; index++) ...[
                  buttons[index],
                  if (index != buttons.length - 1) const SizedBox(width: gap),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroCopy extends StatelessWidget {
  final bool compact;

  const _HeroCopy({required this.compact});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = constraints.maxWidth < 330
            ? 31.0
            : compact
                ? 34.0
                : 40.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: fontSize,
                      height: 1.08,
                      letterSpacing: -1.2,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                children: const [
                  TextSpan(text: 'Welcome '),
                  TextSpan(
                    text: 'back',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: true,
                applyHeightToLastDescent: true,
              ),
            ),
            const SizedBox(height: 11),
            Text(
              'Sign in to continue shopping, manage your cart and follow your orders.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: compact ? 14 : 15.5,
                    height: 1.46,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        );
      },
    );
  }
}

class _AccountHeader extends StatelessWidget {
  final bool compact;

  const _AccountHeader({required this.compact});

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 46.0 : 50.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
          child: Icon(
            Icons.person_rounded,
            color: AppColors.primary,
            size: compact ? 23 : 25,
          ),
        ),
        SizedBox(width: compact ? 12 : 14),
        const Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign in to your account',
                maxLines: 2,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16.5,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Enter your details below',
                maxLines: 2,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  height: 1.3,
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
            SizedBox(
              width: 46,
              height: 34,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Switch.adaptive(
                  value: value,
                  activeTrackColor: AppColors.primary,
                  onChanged: onChanged,
                ),
              ),
            ),
            const SizedBox(width: 5),
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
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      ),
      child: const Text(
        'Forgot password?',
        maxLines: 1,
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
      ),
    );

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
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'OR CONTINUE WITH',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 9.5,
              letterSpacing: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}

class _SignUpPrompt extends StatelessWidget {
  final VoidCallback onPressed;

  const _SignUpPrompt({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 3,
      runSpacing: 0,
      children: [
        const Text(
          'Don’t have an account?',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            minimumSize: const Size(44, 44),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          ),
          child: const Text(
            'Sign up',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
