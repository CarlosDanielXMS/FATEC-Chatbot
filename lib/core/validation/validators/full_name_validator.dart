import 'package:chatbot/core/validation/validation_result.dart';

class FullNameValidationResult implements ValidationResult {
  const FullNameValidationResult({
    required this.hasValue,
    required this.hasAtLeastTwoNames,
    required this.hasValidCharacters,
    required this.hasValidParts,
  });

  final bool hasValue;
  final bool hasAtLeastTwoNames;
  final bool hasValidCharacters;
  final bool hasValidParts;

  @override
  bool get isValid {
    return hasValue &&
        hasAtLeastTwoNames &&
        hasValidCharacters &&
        hasValidParts;
  }

  @override
  String? get errorMessage {
    if (isValid) return null;
    if (!hasValue) return 'Informe o nome completo.';
    if (!hasAtLeastTwoNames) return 'Informe o nome completo.';

    return 'Informe um nome válido.';
  }
}

abstract final class FullNameValidator {
  static final RegExp _invalidCharactersRegex = RegExp(r'[0-9]');

  static FullNameValidationResult validate(String name) {
    final normalized = normalize(name);
    final parts = normalized.isEmpty ? <String>[] : normalized.split(' ');

    return FullNameValidationResult(
      hasValue: normalized.isNotEmpty,
      hasAtLeastTwoNames: parts.length >= 2,
      hasValidCharacters: !_invalidCharactersRegex.hasMatch(normalized),
      hasValidParts: parts.every((part) => part.length >= 2),
    );
  }

  static bool isValid(String name) {
    return validate(name).isValid;
  }

  static String normalize(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}