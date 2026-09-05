import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/firebase/firebase_error_message.dart';
import '../../../core/firebase/verified_registration_service.dart';
import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_colors.dart';
import 'email_verification_page.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/primary_button.dart';

class PhoneOtpVerificationPage extends StatefulWidget {
  const PhoneOtpVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    required this.name,
    required this.email,
    required this.password,
    this.resendToken,
  });

  final String phoneNumber;
  final String verificationId;
  final int? resendToken;
  final String name;
  final String email;
  final String password;

  @override
  State<PhoneOtpVerificationPage> createState() => _PhoneOtpVerificationPageState();
}

class _PhoneOtpVerificationPageState extends State<PhoneOtpVerificationPage> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late String _verificationId;
  int? _resendToken;
  bool _loading = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _resendToken = widget.resendToken;
    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((controller) => controller.text).join();

  Future<void> _verify() async {
    if (_code.length != 6) {
      _show('Enter the complete six-digit SMS code.');
      return;
    }
    setState(() => _loading = true);
    try {
      await VerifiedRegistrationService.instance.confirmSmsCode(
        verificationId: _verificationId,
        smsCode: _code,
        name: widget.name,
        email: widget.email,
        password: widget.password,
      );
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
      Navigator.pushReplacement(
        context,
        AppPageRoute(
          page: EmailVerificationPage(name: widget.name, email: widget.email),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
      _show(firebaseErrorMessage(error));
    }
  }

  Future<void> _resend() async {
    if (_resending) {
      return;
    }
    setState(() => _resending = true);
    try {
      final challenge = await VerifiedRegistrationService.instance.sendPhoneOtp(
        phoneNumber: widget.phoneNumber,
        forceResendingToken: _resendToken,
      );
      if (!mounted) {
        return;
      }
      if (challenge.automaticCredential != null) {
        await VerifiedRegistrationService.instance.completePhoneRegistration(
          phoneCredential: challenge.automaticCredential!,
          name: widget.name,
          email: widget.email,
          password: widget.password,
        );
        if (!mounted) {
          return;
        }
        Navigator.pushReplacement(
          context,
          AppPageRoute(page: EmailVerificationPage(name: widget.name, email: widget.email)),
        );
        return;
      }
      if (challenge.verificationId != null) {
        _verificationId = challenge.verificationId!;
      }
      _resendToken = challenge.resendToken ?? _resendToken;
      _show('A new SMS verification code was sent.');
    } catch (error) {
      if (mounted) {
        _show(firebaseErrorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => _resending = false);
      }
    }
  }

  void _show(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      title: 'Verify your mobile',
      subtitle: 'Enter the six-digit SMS code sent by Firebase Authentication.',
      child: Column(
        children: [
          _DestinationCard(icon: Icons.phone_android_rounded, text: widget.phoneNumber),
          const SizedBox(height: 24),
          Row(
            children: List.generate(6, (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == 5 ? 0 : 7),
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  decoration: const InputDecoration(counterText: ''),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 5) {
                      _focusNodes[index + 1].requestFocus();
                    }
                    if (value.isEmpty && index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }
                  },
                ),
              ),
            )),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _resending ? null : _resend,
            icon: _resending
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh_rounded),
            label: Text(_resending ? 'Sending…' : 'Resend SMS code'),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Verify mobile number',
            icon: Icons.verified_rounded,
            loading: _loading,
            onPressed: _verify,
          ),
        ],
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [Icon(icon, color: AppColors.primary), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)))]),
      );
}
