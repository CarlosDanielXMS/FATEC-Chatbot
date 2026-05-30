import 'package:chatbot/features/professional/presentation/widgets/professional_placeholder_view.dart';
import 'package:flutter/material.dart';

class ProfessionalProfilePage extends StatelessWidget {
  const ProfessionalProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfessionalPlaceholderView(
      title: 'Perfil do profissional',
      description:
          'Perfil do profissional será implementado na issue correspondente.',
      showSignOutAction: true,
    );
  }
}