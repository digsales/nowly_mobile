import 'package:flutter/widgets.dart';

typedef Validator = String? Function(String value);

abstract final class Validators {
  static Validator required(String message) {
    return (value) => value.trim().isEmpty ? message : null;
  }

  static Validator email(String message) {
    return (value) {
      final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
      return regex.hasMatch(value.trim()) ? null : message;
    };
  }

  static Validator minLength(int min, String message) {
    return (value) => value.length < min ? message : null;
  }

  static Validator maxLength(int max, String message) {
    return (value) => value.length > max ? message : null;
  }

  static Validator hasUppercase(String message) {
    return (value) => RegExp(r'[A-Z]').hasMatch(value) ? null : message;
  }

  static Validator hasLowercase(String message) {
    return (value) => RegExp(r'[a-z]').hasMatch(value) ? null : message;
  }

  static Validator hasDigit(String message) {
    return (value) => RegExp(r'[0-9]').hasMatch(value) ? null : message;
  }

  static Validator hasSpecialChar(String message) {
    return (value) =>
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value) ? null : message;
  }

  static Validator match(TextEditingController controller, String message) {
    return (value) => value != controller.text ? message : null;
  }

  static Validator combine(List<Validator> validators) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
