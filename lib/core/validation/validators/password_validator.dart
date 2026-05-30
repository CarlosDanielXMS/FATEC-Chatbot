import 'package:chatbot/core/validation/validation_result.dart';

class PasswordValidationResult implements ValidationResult {
  const PasswordValidationResult({
    required this.hasValue,
    required this.hasMinLength,
    required this.hasLowercase,
    required this.hasUppercase,
    required this.hasSpecialChar,
    required this.hasNumber,
  });

  final bool hasValue;
  final bool hasMinLength;
  final bool hasLowercase;
  final bool hasUppercase;
  final bool hasSpecialChar;
  final bool hasNumber;

  @override
  bool get isValid {
    return hasValue &&
        hasMinLength &&
        hasLowercase &&
        hasUppercase &&
        hasSpecialChar &&
        hasNumber;
  }

  @override
  String? get errorMessage {
    if (isValid) return null;

    if (!hasValue) return 'Informe a senha.';
    if (!hasMinLength) return 'A senha deve ter no mínimo 8 caracteres.';
    if (!hasUppercase) return 'A senha deve ter pelo menos 1 letra maiúscula.';
    if (!hasLowercase) return 'A senha deve ter pelo menos 1 letra minúscula.';
    if (!hasNumber) return 'A senha deve ter pelo menos 1 número.';
    if (!hasSpecialChar) return 'A senha deve ter pelo menos 1 caractere especial.';
    
    return 'Informe uma senha válida.';
  }
}

abstract final class PasswordValidator {
  static final RegExp _lowercaseRegex = RegExp(r'[a-z]');
  static final RegExp _uppercaseRegex = RegExp(r'[A-Z]');
  static final RegExp _numberRegex = RegExp(r'\d');
  static final RegExp _specialCharRegex =
      RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=/\\[\];]');

  static PasswordValidationResult validate(String password) {
    return PasswordValidationResult(
      hasValue: password.isNotEmpty,
      hasMinLength: password.length >= 8,
      hasLowercase: _lowercaseRegex.hasMatch(password),
      hasUppercase: _uppercaseRegex.hasMatch(password),
      hasSpecialChar: _specialCharRegex.hasMatch(password),
      hasNumber: _numberRegex.hasMatch(password),
    );
  }

  static bool isValid(String password) {
    return validate(password).isValid;
  }
}