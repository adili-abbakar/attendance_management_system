class Validators {
  Validators._();

  // Required
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  // Email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }

    final emailRegExp = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  // Password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Name
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required.';
    }

    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters.';
    }

    return null;
  }

  // Staff ID
  static String? staffId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Staff ID is required.';
    }

    if (value.trim().length < 4) {
      return 'Staff ID is too short.';
    }

    return null;
  }

  // Login Identifier
  static String? loginIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email or Staff ID is required.';
    }

    return null;
  }
}
