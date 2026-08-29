import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      title: 'Reset your password',
      subtitle:
          'Enter your account email. In the backend phase, Laravel will send the real reset link.',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        child: _sent ? _successState(context) : _formState(),
      ),
    );
  }

  Widget _formState() {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('form'),
        children: [
          AuthTextField(
            controller: _emailController,
            label: 'Email address',
            hint: 'you@example.com',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _sendReset(),
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            label: 'Send reset instructions',
            icon: Icons.send_rounded,
            loading: _loading,
            onPressed: _sendReset,
          ),
        ],
      ),
    );
  }

  Widget _successState(BuildContext context) {
    return Column(
      key: const ValueKey('success'),
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: const BoxDecoration(
            color: Color(0xFFE6F7EF),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            color: AppColors.success,
            size: 38,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Check your email',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'A reset instruction preview was prepared for ${_emailController.text.trim()}.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: 'Back to sign in',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
