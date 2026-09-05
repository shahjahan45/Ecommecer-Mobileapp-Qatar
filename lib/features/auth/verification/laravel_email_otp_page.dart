import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/firebase/firebase_session_bridge.dart';
import '../../../core/firebase/push_notification_service.dart';
import '../../../core/network/api_models.dart';
import '../../../core/network/customer_identity_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../navigation/main_navigation.dart';
import '../../../core/navigation/app_page_route.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/primary_button.dart';

class LaravelEmailOtpPage extends StatefulWidget {
  const LaravelEmailOtpPage({
    super.key,
    required this.idToken,
    required this.name,
    required this.email,
  });

  final String idToken;
  final String name;
  final String email;

  @override
  State<LaravelEmailOtpPage> createState() => _LaravelEmailOtpPageState();
}

class _LaravelEmailOtpPageState extends State<LaravelEmailOtpPage> {
  final CustomerIdentityApi _api = CustomerIdentityApi();
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  bool _loading = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
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
      _show('Enter the complete six-digit email code.');
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await _api.verifyRegistrationEmailOtp(
        idToken: widget.idToken,
        code: _code,
        name: widget.name,
      );
      FirebaseSessionBridge.activateFromApi(result);
      await PushNotificationService.instance.initialize();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
        AppPageRoute(page: const MainNavigation()),
        (route) => false,
      );
    } on ApiException catch (error) {
      if (mounted) {
        _show(error.message);
      }
    } catch (_) {
      if (mounted) {
        _show('The email verification code could not be confirmed.');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _resend() async {
    if (_resending) {
      return;
    }
    setState(() => _resending = true);
    try {
      await _api.sendRegistrationEmailOtp(idToken: widget.idToken);
      if (mounted) {
        _show('A new six-digit code was sent to ${widget.email}.');
      }
    } on ApiException catch (error) {
      if (mounted) {
        _show(error.message);
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
      showBackButton: false,
      title: 'Enter your email code',
      subtitle: 'DCX Core sent a six-digit code through the configured Laravel email provider.',
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(16)),
            child: Row(children: [const Icon(Icons.alternate_email_rounded, color: AppColors.primary), const SizedBox(width: 10), Expanded(child: Text(widget.email, style: const TextStyle(fontWeight: FontWeight.w700)))]),
          ),
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
          TextButton.icon(onPressed: _resending ? null : _resend, icon: const Icon(Icons.refresh_rounded), label: Text(_resending ? 'Sending…' : 'Resend email code')),
          const SizedBox(height: 12),
          PrimaryButton(label: 'Verify & create DCX account', icon: Icons.verified_rounded, loading: _loading, onPressed: _verify),
        ],
      ),
    );
  }
}
