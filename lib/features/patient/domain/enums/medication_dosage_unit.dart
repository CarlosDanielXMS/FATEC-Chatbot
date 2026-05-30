enum MedicationDosageUnit {
  tablet('tablet', 'Comprimido'),
  capsule('capsule', 'Cápsula'),
  drops('drops', 'Gotas'),
  milliliter('milliliter', 'ml'),
  milligram('milligram', 'mg');

  const MedicationDosageUnit(this.value, this.label);

  final String value;
  final String label;

  static MedicationDosageUnit? fromValue(String? value) {
    final normalizedValue = value?.trim();

    if (normalizedValue == null || normalizedValue.isEmpty) {
      return null;
    }

    for (final unit in MedicationDosageUnit.values) {
      if (unit.value == normalizedValue || unit.label == normalizedValue) {
        return unit;
      }
    }

    return null;
  }
}