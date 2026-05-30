import 'package:chatbot/core/validation/validation_result.dart';

class DateRangeValidationResult implements ValidationResult {
  const DateRangeValidationResult({
    required this.hasStartDate,
    required this.hasEndDate,
    required this.hasValidRange,
  });

  final bool hasStartDate;
  final bool hasEndDate;
  final bool hasValidRange;

  @override
  bool get isValid {
    return hasStartDate && hasEndDate && hasValidRange;
  }

  @override
  String? get errorMessage {
    if (isValid) return null;
    if (!hasStartDate) return 'Informe a data inicial.';
    if (!hasEndDate) return 'Informe a data final.';
    if (!hasValidRange) return 'A data final deve ser maior que a inicial.';

    return 'Informe um período válido.';
  }
}

abstract final class DateRangeValidator {
  static DateRangeValidationResult validate({
    required DateTime? startDate,
    required DateTime? endDate,
  }) {
    return DateRangeValidationResult(
      hasStartDate: startDate != null,
      hasEndDate: endDate != null,
      hasValidRange: _hasValidRange(
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  static bool isValid({
    required DateTime? startDate,
    required DateTime? endDate,
  }) {
    return validate(
      startDate: startDate,
      endDate: endDate,
    ).isValid;
  }

  static bool _hasValidRange({
    required DateTime? startDate,
    required DateTime? endDate,
  }) {
    if (startDate == null || endDate == null) {
      return false;
    }

    final normalizedStartDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    final normalizedEndDate = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    );

    return !normalizedEndDate.isBefore(normalizedStartDate);
  }
}