import 'dart:async';

import 'package:chatbot/core/firebase/firestore_collections.dart';
import 'package:chatbot/core/firebase/firestore_fields.dart';
import 'package:chatbot/features/auth/domain/enums/user_role.dart';
import 'package:chatbot/features/onboarding/data/onboarding_local_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AppNavigationState extends ChangeNotifier {
  AppNavigationState({
    required OnboardingLocalStore onboardingLocalStore,
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _onboardingLocalStore = onboardingLocalStore,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _onboardingCompleted = _onboardingLocalStore.isCompleted();

    _authSubscription = _firebaseAuth.authStateChanges().listen(
      _handleAuthStateChanged,
    );

    _restoreCurrentSession();
  }

  static const _roleLoadMaxAttempts = 6;
  static const _roleLoadRetryDelay = Duration(milliseconds: 300);

  final OnboardingLocalStore _onboardingLocalStore;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  StreamSubscription<User?>? _authSubscription;

  bool _splashCompleted = false;
  bool _onboardingCompleted = false;
  bool _isAuthenticated = false;
  bool _isRestoringSession = true;
  bool _isLoadingRole = false;

  UserRole? _role;
  int _roleLoadGeneration = 0;

  bool get splashCompleted => _splashCompleted;
  bool get onboardingCompleted => _onboardingCompleted;
  bool get isAuthenticated => _isAuthenticated;
  bool get isRestoringSession => _isRestoringSession;
  bool get isLoadingRole => _isLoadingRole;
  bool get isSessionResolving => _isRestoringSession || _isLoadingRole;

  UserRole? get role => _role;

  bool get hasRole => _role != null;
  bool get isPatient => _role?.isPatient ?? false;
  bool get isProfessional => _role?.isProfessional ?? false;

  void completeSplash() {
    if (_splashCompleted) return;

    _splashCompleted = true;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    if (_onboardingCompleted) return;

    await _onboardingLocalStore.setCompleted();

    _onboardingCompleted = true;
    notifyListeners();
  }

  Future<void> _restoreCurrentSession() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      _finishSessionRestoreWithoutUser();
      return;
    }

    try {
      await user.reload();

      final refreshedUser = _firebaseAuth.currentUser;

      if (refreshedUser == null) {
        _clearAuthenticatedState();
        return;
      }

      await refreshedUser.getIdToken(true);

      _isAuthenticated = true;
      _isRestoringSession = false;
      notifyListeners();

      await _loadRoleForUser(refreshedUser);
    } on FirebaseAuthException catch (error) {
      if (_isExpiredOrInvalidSession(error)) {
        await _firebaseAuth.signOut();
        _clearAuthenticatedState();
        return;
      }

      debugPrint('Erro ao restaurar sessão: ${error.code}');

      _isAuthenticated = _firebaseAuth.currentUser != null;
      _isRestoringSession = false;
      notifyListeners();

      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        await _loadRoleForUser(currentUser);
      }
    } catch (error, stackTrace) {
      debugPrint('Erro inesperado ao restaurar sessão: $error');
      debugPrintStack(stackTrace: stackTrace);

      _isAuthenticated = _firebaseAuth.currentUser != null;
      _isRestoringSession = false;
      notifyListeners();

      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        await _loadRoleForUser(currentUser);
      }
    }
  }

  void _finishSessionRestoreWithoutUser() {
    _isAuthenticated = false;
    _isRestoringSession = false;
    _isLoadingRole = false;
    _role = null;
    notifyListeners();
  }

  bool _isExpiredOrInvalidSession(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-disabled':
      case 'user-not-found':
      case 'user-token-expired':
      case 'invalid-user-token':
        return true;
      default:
        return false;
    }
  }

  Future<void> _handleAuthStateChanged(User? user) async {
    if (_isRestoringSession) return;

    if (user == null) {
      _clearAuthenticatedState();
      return;
    }

    if (_isAuthenticated && _role != null && !_isLoadingRole) {
      return;
    }

    _isAuthenticated = true;
    await _loadRoleForUser(user);
  }

  Future<void> _loadRoleForUser(User user) async {
    final generation = ++_roleLoadGeneration;

    _isLoadingRole = true;
    _role = null;
    notifyListeners();

    try {
      final role = await _waitForUserRole(
        uid: user.uid,
        generation: generation,
      );

      if (generation != _roleLoadGeneration) return;

      if (role == null) {
        await _firebaseAuth.signOut();
        return;
      }

      _role = role;
    } catch (error, stackTrace) {
      debugPrint('Erro ao carregar papel do usuário: $error');
      debugPrintStack(stackTrace: stackTrace);

      await _firebaseAuth.signOut();
    } finally {
      if (generation == _roleLoadGeneration) {
        _isLoadingRole = false;
        notifyListeners();
      }
    }
  }

  Future<UserRole?> _waitForUserRole({
    required String uid,
    required int generation,
  }) async {
    for (var attempt = 0; attempt < _roleLoadMaxAttempts; attempt++) {
      if (generation != _roleLoadGeneration) return null;

      final snapshot = await _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .get();

      final data = snapshot.data();
      final roleValue = data?[FirestoreFields.role];

      if (snapshot.exists && roleValue is String) {
        final role = UserRole.tryFromString(roleValue);

        if (role != null) {
          return role;
        }
      }

      if (attempt < _roleLoadMaxAttempts - 1) {
        await Future<void>.delayed(_roleLoadRetryDelay);
      }
    }

    return null;
  }

  void _clearAuthenticatedState() {
    _roleLoadGeneration++;
    _isAuthenticated = false;
    _isRestoringSession = false;
    _isLoadingRole = false;
    _role = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}