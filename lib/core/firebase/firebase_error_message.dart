import 'package:firebase_auth/firebase_auth.dart';

String firebaseErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-phone-number':
        return 'Enter a valid mobile number including the country code.';
      case 'too-many-requests':
        return 'Too many verification attempts. Please wait and try again.';
      case 'invalid-verification-code':
        return 'The SMS verification code is incorrect.';
      case 'session-expired':
        return 'The SMS verification session expired. Request a new code.';
      case 'email-already-in-use':
      case 'credential-already-in-use':
        return 'This email is already linked to another account. Sign in or reset your password.';
      case 'phone-number-already-exists':
        return 'This mobile number is already linked to another account.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'The email or password is incorrect.';
      case 'user-disabled':
        return 'This account has been disabled. Contact DCX Support.';
      case 'user-not-found':
        return 'No account was found for this email address.';
      case 'weak-password':
        return 'Choose a stronger password with at least 8 characters.';
      case 'network-request-failed':
        return 'The verification service could not be reached. Check your internet connection.';
      case 'phone-linked-to-different-email':
        return error.message ?? 'This mobile number belongs to another account.';
      case 'firebase-not-configured':
        return 'Firebase Authentication is not configured for this app build.';
    }
    if (error.message != null && error.message!.trim().isNotEmpty) {
      return error.message!.trim();
    }
  }
  return 'We could not complete the secure account verification. Please try again.';
}
