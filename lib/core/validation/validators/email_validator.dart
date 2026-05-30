import 'package:chatbot/core/validation/validation_result.dart';

class EmailValidationResult implements ValidationResult {
  const EmailValidationResult({
    required this.hasValue,
    required this.hasValidFormat,
  });

  final bool hasValue;
  final bool hasValidFormat;

  @override
  bool get isValid {
    return hasValue && hasValidFormat;
  }

  @override
  String? get errorMessage {
    if (isValid) return null;
    if (!hasValue) return 'Informe o e-mail.';
    if (!hasValidFormat) return 'Informe um e-mail válido.';

    return 'Informe um e-mail válido.';
  }
}

abstract final class EmailValidator {
  static final RegExp _emailRegex = RegExp(
    r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$',
  );

  static EmailValidationResult validate(String email) {
    final normalized = email.trim();

    return EmailValidationResult(
      hasValue: normalized.isNotEmpty,
      hasValidFormat: _emailRegex.hasMatch(normalized),
    );
  }

  static bool isValid(String email) {
    return validate(email).isValid;
  }
}