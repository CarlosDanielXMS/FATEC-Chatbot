import 'package:chatbot/core/validation/validation_result.dart';

class TimeTextValidationResult implements ValidationResult {
  const TimeTextValidationResult({
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
    if (!hasValue) return 'Informe o horário.';
    if (!hasValidFormat) return 'Informe um horário válido.';

    return 'Informe um horário válido.';
  }
}

abstract final class TimeTextValidator {
  static final RegExp _timeRegex = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

  static TimeTextValidationResult validate(String value) {
    final normalized = value.trim();

    return TimeTextValidationResult(
      hasValue: normalized.isNotEmpty,
      hasValidFormat: _timeRegex.hasMatch(normalized),
    );
  }

  static bool isValid(String value) {
    return validate(value).isValid;
  }
}