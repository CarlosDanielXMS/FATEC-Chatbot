import 'package:chatbot/app/navigation/app_navigation_state.dart';
import 'package:chatbot/core/routing/app_routes.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class AppRedirector {
  const AppRedirector(this._navigationState);

  final AppNavigationState _navigationState;

  String? redirect(BuildContext context, GoRouterState state) {
    final path = state.uri.path;

    if (!_navigationState.splashCompleted) {
      return _redirectToSplashWhenNeeded(path);
    }

    if (!_navigationState.onboardingCompleted) {
      return _redirectToOnboardingWhenNeeded(path);
    }

    if (_isSplashOrOnboardingRoute(path)) {
      return _redirectAfterInitialFlow();
    }

    if (_navigationState.isSessionResolving) {
      return _redirectWhileSessionIsResolving(path);
    }

    if (!_navigationState.isAuthenticated && _isProtectedRoute(path)) {
      return AppRoutes.authHome;
    }

    if (_navigationState.isAuthenticated && !_navigationState.hasRole) {
      return _redirectWhenRoleIsMissing(path);
    }

    if (_navigationState.isAuthenticated && _isAuthRoute(path)) {
      return _authenticatedHomeRoute();
    }

    if (_navigationState.isAuthenticated && _isPatientRoute(path)) {
      if (_navigationState.isProfessional) {
        return AppRoutes.professionalHome;
      }
    }

    if (_navigationState.isAuthenticated && _isProfessionalRoute(path)) {
      if (_navigationState.isPatient) {
        return AppRoutes.patientHome;
      }
    }

    return null;
  }

  String? _redirectToSplashWhenNeeded(String path) {
    if (path == AppRoutes.splash) return null;

    return AppRoutes.splash;
  }

  String? _redirectToOnboardingWhenNeeded(String path) {
    if (path == AppRoutes.onboarding) return null;

    return AppRoutes.onboarding;
  }

  String _redirectAfterInitialFlow() {
    if (_navigationState.isSessionResolving) {
      return AppRoutes.authHome;
    }

    if (!_navigationState.isAuthenticated) {
      return AppRoutes.authHome;
    }

    if (!_navigationState.hasRole) {
      return AppRoutes.authHome;
    }

    return _authenticatedHomeRoute();
  }

  String? _redirectWhileSessionIsResolving(String path) {
    if (_isAuthRoute(path)) return null;

    return AppRoutes.authHome;
  }

  String? _redirectWhenRoleIsMissing(String path) {
    if (_isAuthRoute(path)) return null;

    return AppRoutes.authHome;
  }

  String _authenticatedHomeRoute() {
    if (_navigationState.isProfessional) {
      return AppRoutes.professionalHome;
    }

    if (_navigationState.isPatient) {
      return AppRoutes.patientHome;
    }

    return AppRoutes.authHome;
  }

  bool _isSplashOrOnboardingRoute(String path) {
    return path == AppRoutes.splash || path == AppRoutes.onboarding;
  }

  bool _isAuthRoute(String path) {
    return path == AppRoutes.authHome ||
        path == AppRoutes.login ||
        path == AppRoutes.register ||
        path == AppRoutes.registerSuccess ||
        path == AppRoutes.forgotPassword ||
        path == AppRoutes.forgotPasswordSent;
  }

  bool _isProtectedRoute(String path) {
    return _isPatientRoute(path) || _isProfessionalRoute(path);
  }

  bool _isPatientRoute(String path) {
    return path == AppRoutes.patientHome || path.startsWith('/patient/');
  }

  bool _isProfessionalRoute(String path) {
    return path == AppRoutes.professionalHome ||
        path.startsWith('/professional/');
  }
}