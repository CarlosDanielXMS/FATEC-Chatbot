import 'package:chatbot/core/validation/validation_result.dart';

class CpfValidationResult implements ValidationResult {
  const CpfValidationResult({
    required this.hasValue,
    required this.hasValidLength,
    required this.hasNoRepeatedSequence,
    required this.hasValidDigits,
  });

  final bool hasValue;
  final bool hasValidLength;
  final bool hasNoRepeatedSequence;
  final bool hasValidDigits;

  @override
  bool get isValid {
    return hasValue &&
        hasValidLength &&
        hasNoRepeatedSequence &&
        hasValidDigits;
  }

  @override
  String? get errorMessage {
    if (isValid) return null;
    if (!hasValue) return 'Informe o CPF.';

    return 'Informe um CPF válido.';
  }
}

abstract final class CpfValidator {
  static String normalize(String cpf) {
    return cpf.replaceAll(RegExp(r'\D'), '');
  }

  static CpfValidationResult validate(String cpf) {
    final normalized = normalize(cpf);

    final hasValue = normalized.isNotEmpty;
    final hasValidLength = normalized.length == 11;
    final hasNoRepeatedSequence = !RegExp(r'^(\d)\1{10}$').hasMatch(
      normalized,
    );

    final hasValidDigits = hasValidLength &&
        hasNoRepeatedSequence &&
        _hasValidDigits(normalized);

    return CpfValidationResult(
      hasValue: hasValue,
      hasValidLength: hasValidLength,
      hasNoRepeatedSequence: hasNoRepeatedSequence,
      hasValidDigits: hasValidDigits,
    );
  }

  static bool isValid(String cpf) {
    return validate(cpf).isValid;
  }

  static bool _hasValidDigits(String cpf) {
    final firstDigit = _calculateDigit(cpf.substring(0, 9), 10);
    final secondDigit = _calculateDigit(
      '${cpf.substring(0, 9)}$firstDigit',
      11,
    );

    return cpf == '${cpf.substring(0, 9)}$firstDigit$secondDigit';
  }

  static int _calculateDigit(String base, int factor) {
    var total = 0;

    for (var index = 0; index < base.length; index++) {
      total += int.parse(base[index]) * factor--;
    }

    final remainder = total % 11;

    return remainder < 2 ? 0 : 11 - remainder;
  }
}