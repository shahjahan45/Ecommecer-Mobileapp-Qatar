import 'package:flutter/material.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../core/firebase/firebase_error_message.dart';
import '../../../core/firebase/verified_registration_service.dart';
import '../../../core/navigation/app_page_route.dart';
import '../../../core/network/api_environment.dart';
import '../../../core/network/api_models.dart';
import '../../../core/network/customer_identity_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../verification/email_verification_page.dart';
import '../verification/phone_otp_verification_page.dart';
import '../verification/verification_page.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String _normalizedPhone() {
    var value = _mobileController.text.trim().replaceAll(RegExp(r'[\s()-]'), '');
    if (value.startsWith('00')) {
      value = '+${value.substring(2)}';
    }
    if (!value.startsWith('+') && RegExp(r'^\d{8}$').hasMatch(value)) {
      value = '+974$value';
    }
    return value;
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms & Privacy Policy.')),
      );
      return;
    }

    if (!ApiEnvironment.isRemoteConfigured) {
      setState(() => _loading = true);
      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
      Navigator.push(
        context,
        AppPageRoute(
          page: VerificationPage(destination: _emailController.text.trim()),
        ),
      );
      return;
    }

    if (!FirebaseBootstrap.isConfigured) {
      _showError(
        'Customer registration requires Firebase configuration. Add the DCX Firebase dart-defines before running the production app.',
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final authConfig = await CustomerIdentityApi().fetchAuthConfig();
      if (authConfig['firebase_auth_enabled'] != true) {
        throw const ApiException(
          kind: ApiFailureKind.configuration,
          message:
              'DCX Core has not been connected to Firebase Authentication yet. Complete the backend Firebase setup before customer registration.',
        );
      }

      final challenge = await VerifiedRegistrationService.instance.sendPhoneOtp(
        phoneNumber: _normalizedPhone(),
      );
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);

      if (challenge.automaticCredential != null) {
        await VerifiedRegistrationService.instance.completePhoneRegistration(
          phoneCredential: challenge.automaticCredential!,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (!mounted) {
          return;
        }
        Navigator.push(
          context,
          AppPageRoute(
            page: EmailVerificationPage(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
            ),
          ),
        );
        return;
      }

      final verificationId = challenge.verificationId;
      if (verificationId == null || verificationId.isEmpty) {
        throw StateError('Firebase did not return an SMS verification session.');
      }
      Navigator.push(
        context,
        AppPageRoute(
          page: PhoneOtpVerificationPage(
            phoneNumber: _normalizedPhone(),
            verificationId: verificationId,
            resendToken: challenge.resendToken,
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
      _showError(error.message);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
      _showError(firebaseErrorMessage(error));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      title: 'Create your real account',
      subtitle:
          'Your mobile number is verified by SMS OTP and your email is verified before DCX Core creates the customer account.',
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF8F1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.verified_user_outlined, color: AppColors.success),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Secure registration: Mobile OTP → Email verification → DCX customer account.',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12.5,
                          height: 1.45,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AuthTextField(
                controller: _nameController,
                label: 'Full name',
                hint: 'Your full name',
                icon: Icons.person_outline_rounded,
                validator: (value) => Validators.requiredField(value, label: 'Full name'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 18),
              AuthTextField(
                controller: _emailController,
                label: 'Email address',
                hint: 'you@example.com',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 18),
              AuthTextField(
                controller: _mobileController,
                label: 'Mobile number',
                hint: '+974 0000 0000',
                icon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
                validator: Validators.mobile,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 18),
              AuthTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Minimum 8 characters',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                validator: Validators.password,
                textInputAction: TextInputAction.next,
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                ),
              ),
              const SizedBox(height: 18),
              AuthTextField(
                controller: _confirmController,
                label: 'Confirm password',
                hint: 'Re-enter your password',
                icon: Icons.lock_reset_rounded,
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _register(),
                validator: (value) {
                  final base = Validators.password(value);
                  if (base != null) {
                    return base;
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (value) => setState(() => _acceptTerms = value ?? false),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 11),
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.4),
                          children: [
                            TextSpan(text: 'I agree to the '),
                            TextSpan(text: 'Terms of Service', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                            TextSpan(text: ' and '),
                            TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'Verify mobile & create account',
                icon: Icons.sms_outlined,
                loading: _loading,
                onPressed: _register,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
