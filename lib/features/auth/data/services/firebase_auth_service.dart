import 'package:chatbot/core/config/legal_config.dart';
import 'package:chatbot/core/firebase/firestore_collections.dart';
import 'package:chatbot/core/firebase/firestore_fields.dart';
import 'package:chatbot/core/validation/validators/council_validator.dart';
import 'package:chatbot/core/validation/validators/cpf_validator.dart';
import 'package:chatbot/core/validation/validators/email_validator.dart';
import 'package:chatbot/core/validation/validators/full_name_validator.dart';
import 'package:chatbot/core/validation/validators/terms_acceptance_validator.dart';
import 'package:chatbot/features/auth/domain/entities/app_user_profile.dart';
import 'package:chatbot/features/auth/domain/enums/user_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  FirebaseAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  Future<AppUserProfile> registerPatient({
    required String name,
    required String cpf,
    required String email,
    required String password,
    required bool acceptedTerms,
  }) {
    return _registerWithEmailAndPassword(
      role: UserRole.patient,
      name: name,
      cpf: cpf,
      council: null,
      email: email,
      password: password,
      acceptedTerms: acceptedTerms,
    );
  }

  Future<AppUserProfile> registerProfessional({
    required String name,
    required String cpf,
    required String council,
    required String email,
    required String password,
    required bool acceptedTerms,
  }) {
    return _registerWithEmailAndPassword(
      role: UserRole.professional,
      name: name,
      cpf: cpf,
      council: council,
      email: email,
      password: password,
      acceptedTerms: acceptedTerms,
    );
  }

  Future<AppUserProfile> _registerWithEmailAndPassword({
    required UserRole role,
    required String name,
    required String cpf,
    required String? council,
    required String email,
    required String password,
    required bool acceptedTerms,
  }) async {
    final termsValidation = TermsAcceptanceValidator.validate(acceptedTerms);

    if (!termsValidation.isValid) {
      throw FirebaseAuthException(
        code: 'terms-not-accepted',
        message: termsValidation.errorMessage,
      );
    }

    final normalizedName = FullNameValidator.normalize(name);
    final normalizedCpf = CpfValidator.normalize(cpf);
    final normalizedCouncil = council == null
        ? null
        : CouncilValidator.normalize(council);
    final normalizedEmail = email.trim().toLowerCase();

    final credential = await _auth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'Usuário não retornado após cadastro.',
      );
    }

    final profile = AppUserProfile(
      uid: user.uid,
      role: role,
      name: normalizedName,
      cpf: normalizedCpf,
      email: normalizedEmail,
      council: normalizedCouncil,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
    );

    try {
      await user.updateDisplayName(normalizedName);
      await _persistRegistrationData(profile);
      await _auth.signOut();

      return profile;
    } catch (_) {
      await _rollbackCreatedAuthUser(user);
      rethrow;
    }
  }

  Future<void> _persistRegistrationData(AppUserProfile profile) async {
    final role = profile.role;

    if (role == null) {
      throw StateError(
        'Não é possível persistir usuário sem papel definido.',
      );
    }

    final now = FieldValue.serverTimestamp();
    final batch = _firestore.batch();

    final userRef = _firestore
        .collection(FirestoreCollections.users)
        .doc(profile.uid);

    batch.set(userRef, {
      FirestoreFields.uid: profile.uid,
      FirestoreFields.email: profile.email,
      FirestoreFields.role: role.value,
      FirestoreFields.createdAt: now,
      FirestoreFields.updatedAt: now,
    });

    if (role.isPatient) {
      final patientRef = _firestore
          .collection(FirestoreCollections.patients)
          .doc(profile.uid);

      batch.set(patientRef, {
        FirestoreFields.uid: profile.uid,
        FirestoreFields.name: profile.name,
        FirestoreFields.cpf: profile.cpf,
        FirestoreFields.email: profile.email,
        FirestoreFields.createdAt: now,
        FirestoreFields.updatedAt: now,
      });
    } else {
      final professionalRef = _firestore
          .collection(FirestoreCollections.professionals)
          .doc(profile.uid);

      batch.set(professionalRef, {
        FirestoreFields.uid: profile.uid,
        FirestoreFields.name: profile.name,
        FirestoreFields.cpf: profile.cpf,
        FirestoreFields.council: profile.council,
        FirestoreFields.email: profile.email,
        FirestoreFields.createdAt: now,
        FirestoreFields.updatedAt: now,
      });
    }

    final legalAcceptanceRef = _firestore
        .collection(FirestoreCollections.legalAcceptances)
        .doc();

    batch.set(legalAcceptanceRef, {
      FirestoreFields.uid: profile.uid,
      FirestoreFields.email: profile.email,
      FirestoreFields.role: role.value,
      FirestoreFields.termsAccepted: true,
      FirestoreFields.termsVersion: LegalConfig.termsVersion,
      FirestoreFields.privacyPolicyVersion: LegalConfig.privacyPolicyVersion,
      FirestoreFields.acceptedAt: now,
    });

    await batch.commit();
  }

  Future<void> _rollbackCreatedAuthUser(User user) async {
    try {
      await user.delete();
    } catch (_) {}

    try {
      await _auth.signOut();
    } catch (_) {}
  }

  Future<void> signIn({
    required String emailOrCpf,
    required String password,
  }) async {
    final loginEmail = await _resolveLoginEmail(emailOrCpf);

    await _auth.signInWithEmailAndPassword(
      email: loginEmail,
      password: password,
    );
  }

  Future<String> _resolveLoginEmail(String emailOrCpf) async {
    final normalized = emailOrCpf.trim();

    if (EmailValidator.isValid(normalized)) {
      return normalized.toLowerCase();
    }

    final cpfValidation = CpfValidator.validate(normalized);
    if (cpfValidation.isValid) {
      throw FirebaseAuthException(
        code: 'cpf-login-not-supported-client-side',
        message: 'Entre com seu e-mail. Login por CPF exige validação segura no backend.',
      );
    }

    throw FirebaseAuthException(
      code: 'invalid-login-identifier',
      message: 'Informe um e-mail válido.',
    );
  }

  Future<AppUserProfile> signInWithGoogle() async {
    try {
      final result = await _authenticateWithGoogle();

      return _profileFromExistingFirestoreUser(
        user: result.user,
        isNewGoogleUser: result.isNewUser,
      );
    } on GoogleSignInException catch (error) {
      if (_isGoogleSignInCanceled(error)) {
        throw FirebaseAuthException(
          code: 'google-sign-in-canceled',
          message: 'Login com Google cancelado.',
        );
      }

      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: 'Não foi possível entrar com Google.',
      );
    }
  }

  Future<_GoogleAuthenticationResult> _authenticateWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      final credential = await _auth.signInWithPopup(provider);
      final user = credential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'google-user-null',
          message: 'Usuário não retornado no login com Google.',
        );
      }

      return _GoogleAuthenticationResult(
        user: user,
        isNewUser: credential.additionalUserInfo?.isNewUser ?? false,
      );
    }

    await GoogleSignIn.instance.initialize();

    final googleAccount = await GoogleSignIn.instance.authenticate();
    final googleAuthentication = googleAccount.authentication;

    final googleCredential = GoogleAuthProvider.credential(
      idToken: googleAuthentication.idToken,
    );

    final credential = await _auth.signInWithCredential(googleCredential);
    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'google-user-null',
        message: 'Usuário não retornado no login com Google.',
      );
    }

    return _GoogleAuthenticationResult(
      user: user,
      isNewUser: credential.additionalUserInfo?.isNewUser ?? false,
    );
  }

  Future<AppUserProfile> _profileFromExistingFirestoreUser({
    required User user,
    required bool isNewGoogleUser,
  }) async {
    final userSnapshot = await _firestore
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .get();

    final userData = userSnapshot.data();
    final role = UserRole.tryFromString(
      userData?[FirestoreFields.role] as String?,
    );

    if (!userSnapshot.exists || role == null) {
      if (isNewGoogleUser) {
        await _deleteCurrentGoogleAuthUser(user);
      } else {
        await signOut();
      }

      throw FirebaseAuthException(
        code: 'google-account-not-registered',
        message: 'Cadastre-se antes de entrar com Google.',
      );
    }

    final domainSnapshot = await _firestore
        .collection(
          role.isPatient
              ? FirestoreCollections.patients
              : FirestoreCollections.professionals,
        )
        .doc(user.uid)
        .get();

    final domainData = domainSnapshot.data();

    if (!domainSnapshot.exists || domainData == null) {
      await signOut();

      throw FirebaseAuthException(
        code: 'google-profile-not-found',
        message: 'Perfil do usuário não encontrado.',
      );
    }

    return AppUserProfile(
      uid: user.uid,
      email: (userData?[FirestoreFields.email] as String?) ?? user.email ?? '',
      emailVerified: user.emailVerified,
      role: role,
      name: domainData[FirestoreFields.name] as String?,
      cpf: domainData[FirestoreFields.cpf] as String?,
      council: domainData[FirestoreFields.council] as String?,
      photoUrl: user.photoURL,
    );
  }

  Future<void> _deleteCurrentGoogleAuthUser(User user) async {
    try {
      await user.delete();
    } catch (_) {}

    try {
      await signOut();
    } catch (_) {}
  }

  Future<AppUserProfile?> getCurrentUserProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    return _profileFromExistingFirestoreUser(
      user: user,
      isNewGoogleUser: false,
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (!EmailValidator.isValid(normalizedEmail)) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Informe um e-mail válido.',
      );
    }

    await _auth.sendPasswordResetEmail(email: normalizedEmail);
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
    }

    await _auth.signOut();
  }

  bool _isGoogleSignInCanceled(GoogleSignInException error) {
    return error.code == GoogleSignInExceptionCode.canceled;
  }
}

class _GoogleAuthenticationResult {
  const _GoogleAuthenticationResult({
    required this.user,
    required this.isNewUser,
  });

  final User user;
  final bool isNewUser;
}