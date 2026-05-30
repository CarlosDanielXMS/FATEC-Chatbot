import 'package:chatbot/core/validation/validation_result.dart';

class RequiredTextValidationResult implements ValidationResult {
  const RequiredTextValidationResult({
    required this.hasValue,
  });

  final bool hasValue;

  @override
  bool get isValid {
    return hasValue;
  }

  @override
  String? get errorMessage {
    if (isValid) return null;
    if (!hasValue) return 'Campo obrigatório.';

    return 'Campo inválido.';
  }
}

abstract final class RequiredTextValidator {
  static RequiredTextValidationResult validate(String value) {
    return RequiredTextValidationResult(
      hasValue: value.trim().isNotEmpty,
    );
  }

  static bool isValid(String value) {
    return validate(value).isValid;
  }
}