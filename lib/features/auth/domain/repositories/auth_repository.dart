import 'package:chatbot/features/auth/domain/entities/app_user_profile.dart';

abstract class AuthRepository {
  Future<AppUserProfile> registerPatient({
    required String name,
    required String cpf,
    required String email,
    required String password,
    required bool acceptedTerms,
  });

  Future<AppUserProfile> registerProfessional({
    required String name,
    required String cpf,
    required String council,
    required String email,
    required String password,
    required bool acceptedTerms,
  });

  Future<void> signIn({
    required String emailOrCpf,
    required String password,
  });

  Future<AppUserProfile> signInWithGoogle();

  Future<AppUserProfile?> getCurrentUserProfile();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();

  Stream<bool> authStateChanges();
}