import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_colors.dart';
import '../../../navigation/main_navigation.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/primary_button.dart';

class VerificationPage extends StatefulWidget {
  final String destination;

  const VerificationPage({
    super.key,
    required this.destination,
  });

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  bool _loading = false;

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

  bool get _complete =>
      _controllers.every((controller) => controller.text.length == 1);

  Future<void> _verify() async {
    if (!_complete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the complete 6-digit code.')),
      );
      return;
    }

    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.of(context).pushAndRemoveUntil(
      AppPageRoute(page: const MainNavigation()),
      (route) => false,
    );
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      title: 'Verify your account',
      subtitle: 'Enter the six-digit verification code to continue securely.',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.alternate_email_rounded,
                    color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.destination.isEmpty
                        ? 'Verification destination'
                        : widget.destination,
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: List.generate(6, (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == 5 ? 0 : 7),
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      filled: true,
                      fillColor: _controllers[index].text.isEmpty
                          ? AppColors.surface
                          : AppColors.primarySoft,
                    ),
                    onChanged: (value) => _onChanged(index, value),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              const Text(
                "Didn't receive the code?",
                style: TextStyle(color: AppColors.textSecondary),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Demo verification code resent.')),
                  );
                },
                child: const Text('Resend'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Verify and continue',
            icon: Icons.verified_rounded,
            loading: _loading,
            onPressed: _verify,
          ),
        ],
      ),
    );
  }
}
