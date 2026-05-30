import 'package:chatbot/core/routing/app_routes.dart';
import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/core/ui/widgets/buttons/app_button.dart';
import 'package:chatbot/core/ui/widgets/navigation/app_top_bar.dart';
import 'package:chatbot/core/ui/widgets/profile/profile.dart';
import 'package:chatbot/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({
    super.key,
    required this.authRepository,
  });

  final AuthRepository authRepository;

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  static const _avatarName = 'Paciente';
  static const _avatarSubtitle = 'Área do paciente';

  bool _isSigningOut = false;

  Future<void> _signOut() async {
    if (_isSigningOut) return;

    setState(() {
      _isSigningOut = true;
    });

    try {
      await widget.authRepository.signOut();

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

  void _goToAdherenceHistory() {
    context.push(AppRoutes.patientAdherenceHistory);
  }

  void _returnToAuthHome() {
    context.go(AppRoutes.authHome);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          const AppTopBar(title: 'Perfil'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                AppSpacing.s8,
                AppSpacing.s16,
                AppSpacing.s24,
              ),
              children: [
                const ProfileHeaderCard(
                  name: _avatarName,
                  email: _avatarSubtitle,
                ),
                const SizedBox(height: AppSpacing.s24),
                _ProfileSection(
                  title: 'Acompanhamento',
                  children: [
                    SettingsTile(
                      title: 'Histórico de adesão',
                      subtitle: 'Veja suas respostas aos alarmes de medicação',
                      leading: Image.asset(
                        'assets/icons/tabler-icon-alarm.png',
                        width: 22,
                        height: 22,
                        color: AppColors.textSecondary,
                      ),
                      onTap: _goToAdherenceHistory,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s24),
                _ProfileSection(
                  title: 'Conta',
                  children: [
                    AppButton.secondary(
                      label: _isSigningOut ? 'Saindo...' : 'Logout',
                      onPressed: _isSigningOut ? null : _signOut,
                      isLoading: _isSigningOut,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.label.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.s10),
        ..._withSpacing(children),
      ],
    );
  }

  List<Widget> _withSpacing(List<Widget> items) {
    final widgets = <Widget>[];

    for (var index = 0; index < items.length; index++) {
      widgets.add(items[index]);

      if (index < items.length - 1) {
        widgets.add(const SizedBox(height: AppSpacing.s12));
      }
    }

    return widgets;
  }
}