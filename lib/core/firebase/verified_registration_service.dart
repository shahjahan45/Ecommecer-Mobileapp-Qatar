import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_bootstrap.dart';

class PhoneOtpChallenge {
  const PhoneOtpChallenge({
    this.verificationId,
    this.resendToken,
    this.automaticCredential,
  });

  final String? verificationId;
  final int? resendToken;
  final PhoneAuthCredential? automaticCredential;

  bool get wasAutomaticallyVerified => automaticCredential != null;
}

class VerifiedRegistrationService {
  VerifiedRegistrationService._();

  static final VerifiedRegistrationService instance =
      VerifiedRegistrationService._();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<PhoneOtpChallenge> sendPhoneOtp({
    required String phoneNumber,
    int? forceResendingToken,
  }) async {
    if (!await FirebaseBootstrap.ensureInitialized()) {
      throw FirebaseAuthException(
        code: 'firebase-not-configured',
        message: 'Firebase Authentication is not configured for this build.',
      );
    }

    final completer = Completer<PhoneOtpChallenge>();
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) {
        if (!completer.isCompleted) {
          completer.complete(
            PhoneOtpChallenge(automaticCredential: credential),
          );
        }
      },
      verificationFailed: (error) {
        if (!completer.isCompleted) completer.completeError(error);
      },
      codeSent: (verificationId, resendToken) {
        if (!completer.isCompleted) {
          completer.complete(
            PhoneOtpChallenge(
              verificationId: verificationId,
              resendToken: resendToken,
            ),
          );
        }
      },
      codeAutoRetrievalTimeout: (verificationId) {
        if (!completer.isCompleted) {
          completer.complete(
            PhoneOtpChallenge(verificationId: verificationId),
          );
        }
      },
    );
    return completer.future;
  }

  Future<User> completePhoneRegistration({
    required PhoneAuthCredential phoneCredential,
    required String name,
    required String email,
    required String password,
  }) async {
    final phoneResult = await _auth.signInWithCredential(phoneCredential);
    final phoneUser = phoneResult.user;
    if (phoneUser == null) {
      throw FirebaseAuthException(
        code: 'invalid-user',
        message: 'Firebase could not create the phone-verified account.',
      );
    }

    final normalizedEmail = email.trim().toLowerCase();
    final currentEmail = phoneUser.email?.trim().toLowerCase();
    if (currentEmail != null &&
        currentEmail.isNotEmpty &&
        currentEmail != normalizedEmail) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'phone-linked-to-different-email',
        message:
            'This mobile number is already linked to another email account.',
      );
    }

    if (currentEmail == null || currentEmail.isEmpty) {
      final credential = EmailAuthProvider.credential(
        email: normalizedEmail,
        password: password,
      );
      await phoneUser.linkWithCredential(credential);
    }

    await phoneUser.updateDisplayName(name.trim());
    await phoneUser.reload();
    final refreshed = _auth.currentUser;
    if (refreshed == null) {
      throw FirebaseAuthException(
        code: 'invalid-user',
        message: 'The verified account session was lost.',
      );
    }
    if (!refreshed.emailVerified) {
      await refreshed.sendEmailVerification();
    }
    return refreshed;
  }

  Future<User> confirmSmsCode({
    required String verificationId,
    required String smsCode,
    required String name,
    required String email,
    required String password,
  }) {
    return completePhoneRegistration(
      phoneCredential: PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      ),
      name: name,
      email: email,
      password: password,
    );
  }
}
