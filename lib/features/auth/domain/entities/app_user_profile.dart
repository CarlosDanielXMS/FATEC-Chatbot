import 'package:chatbot/features/auth/domain/enums/user_role.dart';

class AppUserProfile {
  const AppUserProfile({
    required this.uid,
    required this.email,
    required this.emailVerified,
    this.role,
    this.name,
    this.cpf,
    this.council,
    this.photoUrl,
  });

  final String uid;
  final String email;
  final bool emailVerified;

  final UserRole? role;

  final String? name;
  final String? cpf;
  final String? council;
  final String? photoUrl;

  bool get hasRole => role != null;
  bool get isPatient => role == UserRole.patient;
  bool get isProfessional => role == UserRole.professional;

  String get firstName {
    final normalized = name?.trim().replaceAll(RegExp(r'\s+'), ' ') ?? '';
    if (normalized.isEmpty) return 'Usuário';

    return normalized.split(' ').first;
  }

  bool get hasDomainProfile {
    return name?.trim().isNotEmpty == true &&
        cpf?.trim().isNotEmpty == true &&
        role != null;
  }

  AppUserProfile copyWith({
    String? uid,
    String? email,
    bool? emailVerified,
    UserRole? role,
    String? name,
    String? cpf,
    String? council,
    String? photoUrl,
  }) {
    return AppUserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      role: role ?? this.role,
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      council: council ?? this.council,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}