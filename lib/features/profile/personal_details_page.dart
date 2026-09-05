import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/design_system/app_tokens.dart';
import '../../core/firebase/firebase_bootstrap.dart';
import '../../core/network/api_models.dart';
import '../../core/network/session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login/login_page.dart';
import 'services/customer_account_service.dart';

class PersonalDetailsPage extends StatefulWidget {
  final CustomerAccountService? accountService;

  const PersonalDetailsPage({super.key, this.accountService});

  @override
  State<PersonalDetailsPage> createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  late final CustomerAccountService _service;
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  bool get _firebaseIdentityLocked =>
      FirebaseBootstrap.isReady && FirebaseAuth.instance.currentUser != null;

  @override
  void initState() {
    super.initState();
    _service = widget.accountService ?? CustomerAccountServiceFactory.create();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!SessionController.instance.isAuthenticated) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final profile = await _service.loadProfile();
      if (!mounted) return;
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone ?? '';
      setState(() {
        _loading = false;
        _loadError = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = _messageFrom(error);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'We could not load your account details.';
      });
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await _service.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your personal details were updated.')),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_messageFrom(error))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update your profile right now.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _messageFrom(ApiException error) {
    final errors = error.details?['errors'];
    if (errors is Map) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) return '${value.first}';
        if (value is String && value.trim().isNotEmpty) return value;
      }
    }
    return error.message;
  }

  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < 2) return 'Enter your full name.';
    if (text.length > 120) return 'Name must be 120 characters or fewer.';
    return null;
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    final valid = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text);
    if (!valid) return 'Enter a valid email address.';
    return null;
  }

  String? _validatePhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (!RegExp(r'^[0-9+()\-\s.]+$').hasMatch(text)) {
      return 'Enter a valid phone number.';
    }
    if (text.length < 7 || text.length > 40) return 'Check the phone number.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionController.instance;
    return Scaffold(
      key: const Key('personal-details-page'),
      appBar: AppBar(title: const Text('Personal details')),
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
                          return const _SignInRequiredCard();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _ProfileHero(),
                            const SizedBox(height: 16),
                            if (_loading)
                              const _LoadingCard()
                            else if (_loadError != null)
                              _ErrorCard(message: _loadError!, onRetry: _load)
                            else
                              _DetailsForm(
                                formKey: _formKey,
                                nameController: _nameController,
                                emailController: _emailController,
                                phoneController: _phoneController,
                                saving: _saving,
                                onSave: _save,
                                validateName: _validateName,
                                validateEmail: _validateEmail,
                                validatePhone: _validatePhone,
                                identityLocked: _firebaseIdentityLocked,
                              ),
                            const SizedBox(height: 12),
                            const _PrivacyNote(),
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

class _ProfileHero extends StatelessWidget {
  const _ProfileHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6847F5), Color(0xFF5033D7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: Color(0x26FFFFFF),
            child: Icon(Icons.person_outline_rounded, color: Colors.white, size: 28),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your account identity',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Keep your contact details accurate for orders, delivery updates and support.',
                  style: TextStyle(
                    color: Color(0xFFE9E4FF),
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

class _DetailsForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final bool saving;
  final VoidCallback onSave;
  final String? Function(String?) validateName;
  final String? Function(String?) validateEmail;
  final String? Function(String?) validatePhone;
  final bool identityLocked;

  const _DetailsForm({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.saving,
    required this.onSave,
    required this.validateName,
    required this.validateEmail,
    required this.validatePhone,
    required this.identityLocked,
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
            Text(
              'Contact information',
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your profile name is editable here. Verified email and mobile identity stay protected by Firebase.',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 11.5,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              key: const Key('personal-details-name'),
              controller: nameController,
              validator: validateName,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('personal-details-email'),
              controller: emailController,
              validator: validateEmail,
              enabled: !identityLocked,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'Email address',
                prefixIcon: const Icon(Icons.alternate_email_rounded),
                suffixIcon: identityLocked
                    ? const Tooltip(
                        message: 'Verified by Firebase',
                        child: Icon(Icons.verified_rounded),
                      )
                    : null,
                helperText: identityLocked
                    ? 'Verified email · protected identity field'
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('personal-details-phone'),
              controller: phoneController,
              validator: validatePhone,
              enabled: !identityLocked,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.telephoneNumber],
              onFieldSubmitted: (_) => onSave(),
              decoration: InputDecoration(
                labelText: 'Phone number',
                hintText: '+974 5555 0101',
                prefixIcon: const Icon(Icons.phone_outlined),
                suffixIcon: identityLocked
                    ? const Tooltip(
                        message: 'SMS OTP verified',
                        child: Icon(Icons.verified_user_outlined),
                      )
                    : null,
                helperText: identityLocked
                    ? 'SMS OTP verified · protected identity field'
                    : null,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              key: const Key('personal-details-save'),
              onPressed: saving ? null : onSave,
              icon: saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded, size: 19),
              label: Text(saving ? 'Saving securely…' : 'Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline_rounded, color: scheme.primary, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Your verified email and mobile number protect account access, OTP verification, order communication and customer support.',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 11,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 190,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, color: scheme.onErrorContainer, size: 30),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: scheme.onErrorContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _SignInRequiredCard extends StatelessWidget {
  const _SignInRequiredCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.person_outline_rounded, color: scheme.primary, size: 38),
          const SizedBox(height: 12),
          Text(
            'Sign in to manage your details',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your personal details are linked to your secure DCX customer account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 11.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const LoginPage()),
            ),
            icon: const Icon(Icons.login_rounded),
            label: const Text('Sign in'),
          ),
        ],
      ),
    );
  }
}
