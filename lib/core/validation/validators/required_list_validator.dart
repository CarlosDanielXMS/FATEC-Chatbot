import 'package:chatbot/core/validation/validation_result.dart';

class RequiredListValidationResult implements ValidationResult {
  const RequiredListValidationResult({
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
    if (!hasValue) return 'Informe pelo menos um item.';

    return 'Lista inválida.';
  }
}

abstract final class RequiredListValidator {
  static RequiredListValidationResult validate<T>(List<T> value) {
    return RequiredListValidationResult(
      hasValue: value.isNotEmpty,
    );
  }

  static bool isValid<T>(List<T> value) {
    return validate(value).isValid;
  }
}