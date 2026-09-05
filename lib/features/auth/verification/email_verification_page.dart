import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/firebase/firebase_error_message.dart';
import '../../../core/firebase/firebase_session_bridge.dart';
import '../../../core/firebase/push_notification_service.dart';
import '../../../core/navigation/app_page_route.dart';
import '../../../core/network/api_models.dart';
import '../../../core/network/customer_identity_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../navigation/main_navigation.dart';
import 'laravel_email_otp_page.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/primary_button.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({
    super.key,
    required this.name,
    required this.email,
  });

  final String name;
  final String email;

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final CustomerIdentityApi _identityApi = CustomerIdentityApi();
  Timer? _pollTimer;
  bool _checking = false;
  bool _resending = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => _check(silent: true));
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _check({bool silent = false}) async {
    if (_checking) {
      return;
    }
    setState(() => _checking = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw StateError('The Firebase registration session is no longer active.');
      }
      await user.reload();
      final refreshed = FirebaseAuth.instance.currentUser;
      if (refreshed == null) {
        throw StateError('The Firebase session was lost.');
      }
      if (!refreshed.emailVerified) {
        if (!silent && mounted) {
          setState(() => _message = 'Email is not verified yet. Open the verification link and try again.');
        }
        return;
      }

      final idToken = await refreshed.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        throw StateError('Firebase did not return an identity token.');
      }
      final result = await _identityApi.exchangeFirebaseToken(
        idToken: idToken,
        name: widget.name,
      );
      if (!mounted) {
        return;
      }
      _pollTimer?.cancel();
      if (result['registration_email_otp_required'] == true) {
        await _identityApi.sendRegistrationEmailOtp(idToken: idToken);
        if (!mounted) {
          return;
        }
        Navigator.pushReplacement(
          context,
          AppPageRoute(
            page: LaravelEmailOtpPage(
              idToken: idToken,
              name: widget.name,
              email: widget.email,
            ),
          ),
        );
        return;
      }
      FirebaseSessionBridge.activateFromApi(result);
      await PushNotificationService.instance.initialize();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
        AppPageRoute(page: const MainNavigation()),
        (route) => false,
      );
    } catch (error) {
      if (!silent && mounted) {
        final text = error is ApiException ? error.message : firebaseErrorMessage(error);
        setState(() => _message = text);
      }
    } finally {
      if (mounted) {
        setState(() => _checking = false);
      }
    }
  }

  Future<void> _resend() async {
    if (_resending) {
      return;
    }
    setState(() => _resending = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw StateError('The Firebase registration session is no longer active.');
      }
      await user.sendEmailVerification();
      if (mounted) {
        setState(() => _message = 'A new verification email was sent to ${widget.email}.');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _message = firebaseErrorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => _resending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: false,
      title: 'Verify your email',
      subtitle: 'Firebase sent a secure verification link. DCX Core creates your real customer account only after verification succeeds.',
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: const BoxDecoration(color: Color(0xFFE6F7EF), shape: BoxShape.circle),
            child: const Icon(Icons.mark_email_unread_outlined, color: AppColors.success, size: 40),
          ),
          const SizedBox(height: 18),
          Text(widget.email, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          const Text(
            'Open the verification link in your email. This page checks automatically every few seconds, or you can check manually.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          if (_message != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(14)),
              child: Text(_message!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
          ],
          const SizedBox(height: 22),
          PrimaryButton(
            label: _checking ? 'Checking verification…' : 'I verified my email',
            icon: Icons.verified_user_outlined,
            loading: _checking,
            onPressed: _checking ? null : () => _check(),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _resending ? null : _resend,
            icon: const Icon(Icons.send_outlined),
            label: Text(_resending ? 'Sending…' : 'Resend verification email'),
          ),
        ],
      ),
    );
  }
}
