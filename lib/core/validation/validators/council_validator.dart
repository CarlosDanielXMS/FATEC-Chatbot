import 'package:chatbot/core/validation/validation_result.dart';

class CouncilValidationResult implements ValidationResult {
  const CouncilValidationResult({
    required this.hasValue,
    required this.hasValidLength,
    required this.hasValidCharacters,
    required this.hasNumber,
  });

  final bool hasValue;
  final bool hasValidLength;
  final bool hasValidCharacters;
  final bool hasNumber;

  @override
  bool get isValid {
    return hasValue && hasValidLength && hasValidCharacters && hasNumber;
  }

  @override
  String? get errorMessage {
    if (isValid) return null;
    if (!hasValue) return 'Informe o conselho.';
    if (!hasValidLength) return 'O conselho deve ter entre 4 e 20 caracteres.';
    if (!hasValidCharacters) return 'Informe um conselho válido.';
    if (!hasNumber) return 'O conselho deve conter ao menos um número.';

    return 'Informe um conselho válido.';
  }
}

abstract final class CouncilValidator {
  static final _allowedCharactersRegex = RegExp(r'^[A-Za-z0-9.\-/ ]+$');
  static final _numberRegex = RegExp(r'\d');

  static CouncilValidationResult validate(String council) {
    final normalized = normalize(council);

    return CouncilValidationResult(
      hasValue: normalized.isNotEmpty,
      hasValidLength: normalized.length >= 4 && normalized.length <= 20,
      hasValidCharacters: normalized.isNotEmpty &&
          _allowedCharactersRegex.hasMatch(normalized),
      hasNumber: _numberRegex.hasMatch(normalized),
    );
  }

  static bool isValid(String council) {
    return validate(council).isValid;
  }

  static String normalize(String council) {
    return council.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}