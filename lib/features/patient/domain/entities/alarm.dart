class Alarm {
  const Alarm({
    required this.id,
    required this.patientId,
    required this.medicationId,
    required this.medicationName,
    required this.scheduledAt,
    required this.time,
    required this.enabled,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String patientId;
  final String medicationId;
  final String medicationName;
  final DateTime scheduledAt;
  final String time;
  final bool enabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isFuture {
    return scheduledAt.isAfter(DateTime.now());
  }
}