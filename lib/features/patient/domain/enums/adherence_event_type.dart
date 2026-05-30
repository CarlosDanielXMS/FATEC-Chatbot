enum AdherenceEventType {
  taken('taken'),
  postponed('postponed'),
  missed('missed');

  const AdherenceEventType(this.value);

  final String value;

  static AdherenceEventType? tryFromString(String? value) {
    if (value == null) return null;

    for (final type in values) {
      if (type.value == value) {
        return type;
      }
    }

    return null;
  }

  bool get isTaken => this == AdherenceEventType.taken;
  bool get isPostponed => this == AdherenceEventType.postponed;
  bool get isMissed => this == AdherenceEventType.missed;
}