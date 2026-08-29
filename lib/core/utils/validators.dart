class Validators {
  Validators._();

  static String? requiredField(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  static String? email(String? value) {
    final required = requiredField(value, label: 'Email');
    if (required != null) return required;

    final email = value!.trim();
    final expression = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!expression.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? mobile(String? value) {
    final required = requiredField(value, label: 'Mobile number');
    if (required != null) return required;

    final digits = value!.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) {
      return 'Enter a valid mobile number';
    }
    return null;
  }

  static String? password(String? value) {
    final required = requiredField(value, label: 'Password');
    if (required != null) return required;

    if (value!.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }
}
