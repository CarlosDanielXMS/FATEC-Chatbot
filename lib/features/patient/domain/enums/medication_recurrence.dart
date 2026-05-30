enum MedicationRecurrence {
  onceDaily('onceDaily', 'Uma vez ao dia', 24),
  every3Hours('every3Hours', 'A cada 3 horas', 3),
  every6Hours('every6Hours', 'A cada 6 horas', 6),
  every8Hours('every8Hours', 'A cada 8 horas', 8),
  every12Hours('every12Hours', 'A cada 12 horas', 12);

  const MedicationRecurrence(
    this.value,
    this.label,
    this.intervalHours,
  );

  final String value;
  final String label;
  final int intervalHours;

  static MedicationRecurrence? fromValue(String? value) {
    final normalizedValue = value?.trim();

    if (normalizedValue == null || normalizedValue.isEmpty) {
      return null;
    }

    for (final recurrence in MedicationRecurrence.values) {
      if (recurrence.value == normalizedValue ||
          recurrence.label == normalizedValue) {
        return recurrence;
      }
    }

    return null;
  }

  static MedicationRecurrence? fromIntervalHours(int? intervalHours) {
    if (intervalHours == null) return null;

    for (final recurrence in MedicationRecurrence.values) {
      if (recurrence.intervalHours == intervalHours) {
        return recurrence;
      }
    }

    return null;
  }
}