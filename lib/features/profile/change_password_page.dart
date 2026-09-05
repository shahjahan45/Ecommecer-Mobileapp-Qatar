import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/design_system/app_tokens.dart';
import '../../core/firebase/firebase_error_message.dart';
import '../../core/network/api_models.dart';
import '../../core/network/session_controller.dart';
import '../../core/theme/app_colors.dart';
import 'services/customer_account_service.dart';

class ChangePasswordPage extends StatefulWidget {
  final CustomerAccountService? accountService;

  const ChangePasswordPage({super.key, this.accountService});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  late final CustomerAccountService _service;
  bool _saving = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void initState() {
    super.initState();
    _service = widget.accountService ?? CustomerAccountServiceFactory.create();
    _newController.addListener(_refreshStrength);
  }

  @override
  void dispose() {
    _newController.removeListener(_refreshStrength);
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _refreshStrength() {
    if (mounted) {
      setState(() {});
    }
  }

  int get _passwordScore {
    final value = _newController.text;
    var score = 0;
    if (value.length >= 8) {
      score++;
    }
    if (RegExp(r'[a-z]').hasMatch(value) && RegExp(r'[A-Z]').hasMatch(value)) {
      score++;
    }
    if (RegExp(r'[0-9]').hasMatch(value)) {
      score++;
    }
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
      score++;
    }
    return score;
  }

  String? _validateCurrent(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Enter your current password.';
    }
    return null;
  }

  String? _validateNew(String? value) {
    final text = value ?? '';
    if (text.length < 8) {
      return 'Use at least 8 characters.';
    }
    if (!RegExp(r'[a-z]').hasMatch(text) || !RegExp(r'[A-Z]').hasMatch(text)) {
      return 'Include uppercase and lowercase letters.';
    }
    if (!RegExp(r'[0-9]').hasMatch(text)) {
      return 'Include at least one number.';
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(text)) {
      return 'Include at least one symbol.';
    }
    if (text == _currentController.text) {
      return 'Choose a different password.';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value != _newController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_saving || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _saving = true);
    try {
      await _service.changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );
      if (!mounted) {
        return;
      }
      _currentController.clear();
      _newController.clear();
      _confirmController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully. Your account credentials are now secure.'),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_messageFrom(error))),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(firebaseErrorMessage(error))),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to change your password right now.')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  String _messageFrom(ApiException error) {
    final errors = error.details?['errors'];
    if (errors is Map) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          return '${value.first}';
        }
        if (value is String && value.trim().isNotEmpty) {
          return value;
        }
      }
    }
    return error.message;
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionController.instance;
    return Scaffold(
      key: const Key('change-password-page'),
      appBar: AppBar(title: const Text('Change password')),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth < 380 ? 16.0 : 20.0;
            return ListView(
              padding: EdgeInsets.fromLTRB(
                horizontal,
                10,
                horizontal,
                MediaQuery.paddingOf(context).bottom + 30,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: AnimatedBuilder(
                      animation: session,
                      builder: (context, child) {
                        if (!session.isAuthenticated) {
                          return const _SecurityNotice(
                            icon: Icons.lock_person_outlined,
                            title: 'Sign in required',
                            description: 'Sign in before changing your DCX account password.',
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _PasswordHero(),
                            const SizedBox(height: 16),
                            _PasswordForm(
                              formKey: _formKey,
                              currentController: _currentController,
                              newController: _newController,
                              confirmController: _confirmController,
                              showCurrent: _showCurrent,
                              showNew: _showNew,
                              showConfirm: _showConfirm,
                              onToggleCurrent: () => setState(() => _showCurrent = !_showCurrent),
                              onToggleNew: () => setState(() => _showNew = !_showNew),
                              onToggleConfirm: () => setState(() => _showConfirm = !_showConfirm),
                              validateCurrent: _validateCurrent,
                              validateNew: _validateNew,
                              validateConfirm: _validateConfirm,
                              passwordScore: _passwordScore,
                              saving: _saving,
                              onSubmit: _submit,
                            ),
                            const SizedBox(height: 12),
                            const _SecurityNotice(
                              icon: Icons.devices_other_rounded,
                              title: 'Other devices are protected',
                              description: 'After a successful password change, DCX disconnects other active API sessions while keeping this phone signed in.',
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PasswordHero extends StatelessWidget {
  const _PasswordHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF17151D), Color(0xFF2C2940)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: Color(0x24FFFFFF),
            child: Icon(Icons.password_rounded, color: Colors.white, size: 27),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create a stronger password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Use a unique password with mixed letters, a number and a symbol.',
                  style: TextStyle(
                    color: Color(0xFFD7D4E5),
                    fontSize: 11.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController currentController;
  final TextEditingController newController;
  final TextEditingController confirmController;
  final bool showCurrent;
  final bool showNew;
  final bool showConfirm;
  final VoidCallback onToggleCurrent;
  final VoidCallback onToggleNew;
  final VoidCallback onToggleConfirm;
  final String? Function(String?) validateCurrent;
  final String? Function(String?) validateNew;
  final String? Function(String?) validateConfirm;
  final int passwordScore;
  final bool saving;
  final VoidCallback onSubmit;

  const _PasswordForm({
    required this.formKey,
    required this.currentController,
    required this.newController,
    required this.confirmController,
    required this.showCurrent,
    required this.showNew,
    required this.showConfirm,
    required this.onToggleCurrent,
    required this.onToggleNew,
    required this.onToggleConfirm,
    required this.validateCurrent,
    required this.validateNew,
    required this.validateConfirm,
    required this.passwordScore,
    required this.saving,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const Key('change-password-current'),
              controller: currentController,
              validator: validateCurrent,
              obscureText: !showCurrent,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: 'Current password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: onToggleCurrent,
                  icon: Icon(showCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('change-password-new'),
              controller: newController,
              validator: validateNew,
              obscureText: !showNew,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                labelText: 'New password',
                prefixIcon: const Icon(Icons.password_rounded),
                suffixIcon: IconButton(
                  onPressed: onToggleNew,
                  icon: Icon(showNew ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _PasswordStrength(score: passwordScore),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('change-password-confirm'),
              controller: confirmController,
              validator: validateConfirm,
              obscureText: !showConfirm,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onFieldSubmitted: (_) => onSubmit(),
              decoration: InputDecoration(
                labelText: 'Confirm new password',
                prefixIcon: const Icon(Icons.verified_user_outlined),
                suffixIcon: IconButton(
                  onPressed: onToggleConfirm,
                  icon: Icon(showConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              key: const Key('change-password-submit'),
              onPressed: saving ? null : onSubmit,
              icon: saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.shield_rounded, size: 19),
              label: Text(saving ? 'Updating securely…' : 'Update password'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordStrength extends StatelessWidget {
  final int score;

  const _PasswordStrength({required this.score});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = switch (score) {
      4 => 'Strong',
      3 => 'Good',
      2 => 'Fair',
      1 => 'Weak',
      _ => 'Start typing',
    };
    final activeColor = score >= 4
        ? AppColors.success
        : score >= 2
            ? AppColors.warning
            : scheme.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index == 3 ? 0 : 5),
                      decoration: BoxDecoration(
                        color: index < score ? activeColor : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: score == 0 ? scheme.onSurfaceVariant : activeColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          '8+ characters • upper & lower case • number • symbol',
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SecurityNotice extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _SecurityNotice({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: scheme.onPrimaryContainer, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
