class Validators {
  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!regex.hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? required(String? value, {String field = 'This field'}) {
    if ((value ?? '').trim().isEmpty) return '$field is required';
    return null;
  }

  static String? phone(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Phone is required';
    if (v.length < 8) return 'Enter a valid phone number';
    return null;
  }

  static String? amount(String? value) {
    final v = double.tryParse((value ?? '').trim());
    if (v == null || v <= 0) return 'Enter a valid amount';
    return null;
  }

  static String? sharesPrice(String? value) {
    final v = double.tryParse((value ?? '').trim());
    if (v == null || v <= 0) return 'Enter a valid price per share';
    return null;
  }
}


