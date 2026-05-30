import 'package:chatbot/features/auth/domain/repositories/auth_repository.dart';
import 'package:chatbot/features/auth/data/services/firebase_auth_service.dart';
import 'package:chatbot/features/auth/domain/entities/app_user_profile.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  FirebaseAuthRepositoryImpl({
    FirebaseAuthService? authService,
  }) : _authService = authService ?? FirebaseAuthService();

  final FirebaseAuthService _authService;

  @override
  Stream<bool> authStateChanges() {
    return _authService.authStateChanges().map((user) => user != null);
  }

  @override
  Future<AppUserProfile> registerPatient({
    required String name,
    required String cpf,
    required String email,
    required String password,
    required bool acceptedTerms,
  }) {
    return _authService.registerPatient(
      name: name,
      cpf: cpf,
      email: email,
      password: password,
      acceptedTerms: acceptedTerms,
    );
  }

  @override
  Future<AppUserProfile> registerProfessional({
    required String name,
    required String cpf,
    required String council,
    required String email,
    required String password,
    required bool acceptedTerms,
  }) {
    return _authService.registerProfessional(
      name: name,
      cpf: cpf,
      council: council,
      email: email,
      password: password,
      acceptedTerms: acceptedTerms,
    );
  }

  @override
  Future<void> signIn({
    required String emailOrCpf,
    required String password,
  }) {
    return _authService.signIn(
      emailOrCpf: emailOrCpf,
      password: password,
    );
  }

  @override
  Future<AppUserProfile> signInWithGoogle() {
    return _authService.signInWithGoogle();
  }

  @override
  Future<AppUserProfile?> getCurrentUserProfile() {
    return _authService.getCurrentUserProfile();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _authService.sendPasswordResetEmail(email);
  }

  @override
  Future<void> signOut() {
    return _authService.signOut();
  }
}