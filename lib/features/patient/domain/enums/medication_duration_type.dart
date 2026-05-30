enum MedicationDurationType {
  continuous('continuous', 'Uso contínuo'),
  fixedDays('fixedDays', 'Duração definida');

  const MedicationDurationType(this.value, this.label);

  final String value;
  final String label;

  static MedicationDurationType? fromValue(String? value) {
    final normalizedValue = value?.trim();

    if (normalizedValue == null || normalizedValue.isEmpty) {
      return null;
    }

    for (final durationType in MedicationDurationType.values) {
      if (durationType.value == normalizedValue ||
          durationType.label == normalizedValue) {
        return durationType;
      }
    }

    return null;
  }
}