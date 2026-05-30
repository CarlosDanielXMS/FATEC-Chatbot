enum UserRole {
  patient,
  professional;

  String get value {
    return switch (this) {
      UserRole.patient => 'patient',
      UserRole.professional => 'professional',
    };
  }

  String get label {
    return switch (this) {
      UserRole.patient => 'Paciente',
      UserRole.professional => 'Profissional',
    };
  }

  bool get isPatient => this == UserRole.patient;
  bool get isProfessional => this == UserRole.professional;

  static UserRole fromString(String value) {
    final role = tryFromString(value);

    if (role == null) {
      throw ArgumentError('Tipo de usuário inválido: $value');
    }

    return role;
  }

  static UserRole? tryFromString(String? value) {
    return switch (value?.trim()) {
      'patient' => UserRole.patient,
      'professional' => UserRole.professional,
      _ => null,
    };
  }
}