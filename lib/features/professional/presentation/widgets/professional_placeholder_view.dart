import 'package:chatbot/core/routing/app_routes.dart';
import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/core/ui/widgets/buttons/app_button.dart';
import 'package:chatbot/core/ui/widgets/layout/app_scaffold.dart';
import 'package:chatbot/features/auth/data/repositories/firebase_auth_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfessionalPlaceholderView extends StatefulWidget {
  const ProfessionalPlaceholderView({
    super.key,
    required this.title,
    required this.description,
    this.showSignOutAction = false,
  });

  final String title;
  final String description;
  final bool showSignOutAction;

  @override
  State<ProfessionalPlaceholderView> createState() =>
      _ProfessionalPlaceholderViewState();
}

class _ProfessionalPlaceholderViewState
    extends State<ProfessionalPlaceholderView> {
  final _authRepository = FirebaseAuthRepositoryImpl();

  bool _isSigningOut = false;

  Future<void> _signOut() async {
    if (_isSigningOut) return;

    setState(() {
      _isSigningOut = true;
    });

    try {
      await _authRepository.signOut();

      if (!mounted) return;

      _returnToAuthHome();
    } finally {
      if (mounted) {
        setState(() {
          _isSigningOut = false;
        });
      }
    }
  }

  void _returnToAuthHome() {
    context.go(AppRoutes.authHome);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: AppTypography.h2.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(
                widget.description,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.showSignOutAction) ...[
                const SizedBox(height: AppSpacing.s24),
                AppButton.secondary(
                  label: _isSigningOut ? 'Saindo...' : 'Sair',
                  onPressed: _isSigningOut ? null : _signOut,
                  isLoading: _isSigningOut,
                  isExpanded: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}