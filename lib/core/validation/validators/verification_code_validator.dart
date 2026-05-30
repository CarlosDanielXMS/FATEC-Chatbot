import 'package:chatbot/core/validation/validation_result.dart';

class VerificationCodeValidationResult implements ValidationResult {
  const VerificationCodeValidationResult({
    required this.hasValue,
    required this.hasOnlyNumbers,
    required this.hasValidLength,
  });

  final bool hasValue;
  final bool hasOnlyNumbers;
  final bool hasValidLength;

  @override
  bool get isValid {
    return hasValue && hasOnlyNumbers && hasValidLength;
  }

  @override
  String? get errorMessage {
    if (isValid) return null;
    if (!hasValue) return 'Informe o código de verificação.';
    if (!hasOnlyNumbers) return 'O código deve conter apenas números.';
    if (!hasValidLength) return 'Informe o código completo.';

    return 'Informe um código válido.';
  }
}

abstract final class VerificationCodeValidator {
  static const int codeLength = 5;

  static VerificationCodeValidationResult validate(String code) {
    final normalized = code.trim();

    return VerificationCodeValidationResult(
      hasValue: normalized.isNotEmpty,
      hasOnlyNumbers: RegExp(r'^\d+$').hasMatch(normalized),
      hasValidLength: normalized.length == codeLength,
    );
  }

  static bool isValid(String code) {
    return validate(code).isValid;
  }
}