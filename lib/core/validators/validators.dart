import 'package:flutter/widgets.dart';

/// A function that validates a [String] value and returns an error message
/// or `null` if valid.
typedef Validator = String? Function(String value);

/// Collection of reusable field validators.
///
/// Each method returns a [Validator] closure that can be used standalone
/// or composed with [combine] to chain multiple rules.
///
/// ```dart
/// final validator = Validators.combine([
///   Validators.required(l10n.validatorRequired),
///   Validators.email(l10n.validatorEmail),
/// ]);
/// final error = validator(value); // null if valid
/// ```
abstract final class Validators {
  /// Fails if the value is empty or whitespace-only.
  static Validator required(String message) {
    return (value) => value.trim().isEmpty ? message : null;
  }

  /// Fails if the value is not a valid email format.
  static Validator email(String message) {
    return (value) {
      final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
      return regex.hasMatch(value.trim()) ? null : message;
    };
  }

  /// Fails if the value has fewer than [min] characters.
  static Validator minLength(int min, String message) {
    return (value) => value.length < min ? message : null;
  }

  /// Fails if the value has more than [max] characters.
  static Validator maxLength(int max, String message) {
    return (value) => value.length > max ? message : null;
  }

  /// Fails if the value has no uppercase letter.
  static Validator hasUppercase(String message) {
    return (value) => RegExp(r'[A-Z]').hasMatch(value) ? null : message;
  }

  /// Fails if the value has no lowercase letter.
  static Validator hasLowercase(String message) {
    return (value) => RegExp(r'[a-z]').hasMatch(value) ? null : message;
  }

  /// Fails if the value has no digit.
  static Validator hasDigit(String message) {
    return (value) => RegExp(r'[0-9]').hasMatch(value) ? null : message;
  }

  /// Fails if the value has no special character.
  static Validator hasSpecialChar(String message) {
    return (value) =>
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value) ? null : message;
  }

  /// Fails if the value does not match the [controller]'s current text.
  /// Useful for password confirmation fields.
  static Validator match(TextEditingController controller, String message) {
    return (value) => value != controller.text ? message : null;
  }

  /// Chains multiple [validators] and returns the first error found,
  /// or `null` if all pass.
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
