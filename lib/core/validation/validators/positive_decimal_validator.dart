import 'package:chatbot/core/validation/validation_result.dart';

class PositiveDecimalValidationResult implements ValidationResult {
  const PositiveDecimalValidationResult({
    required this.hasValue,
    required this.hasValidFormat,
    required this.hasPositiveValue,
  });

  final bool hasValue;
  final bool hasValidFormat;
  final bool hasPositiveValue;

  @override
  bool get isValid {
    return hasValue && hasValidFormat && hasPositiveValue;
  }

  @override
  String? get errorMessage {
    if (isValid) return null;
    if (!hasValue) return 'Informe um valor.';
    if (!hasValidFormat) return 'Informe um valor válido.';
    if (!hasPositiveValue) return 'Informe um valor maior que zero.';

    return 'Informe um valor válido.';
  }
}

abstract final class PositiveDecimalValidator {
  static PositiveDecimalValidationResult validate(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    final parsedValue = double.tryParse(normalized);

    return PositiveDecimalValidationResult(
      hasValue: normalized.isNotEmpty,
      hasValidFormat: parsedValue != null,
      hasPositiveValue: parsedValue != null && parsedValue > 0,
    );
  }

  static bool isValid(String value) {
    return validate(value).isValid;
  }
}