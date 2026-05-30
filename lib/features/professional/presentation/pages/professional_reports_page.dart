import 'package:chatbot/features/professional/presentation/widgets/professional_placeholder_view.dart';
import 'package:flutter/material.dart';

class ProfessionalReportsPage extends StatelessWidget {
  const ProfessionalReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfessionalPlaceholderView(
      title: 'Relatórios',
      description: 'Tela de relatórios será implementada na issue correspondente.',
      showSignOutAction: true,
    );
  }
}