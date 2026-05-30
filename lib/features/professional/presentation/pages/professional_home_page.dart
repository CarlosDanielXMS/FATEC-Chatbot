import 'package:chatbot/features/professional/presentation/widgets/professional_placeholder_view.dart';
import 'package:flutter/material.dart';


class ProfessionalHomePage extends StatelessWidget {
  const ProfessionalHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfessionalPlaceholderView(
      title: 'Área do profissional',
      description: 'Shell do profissional será implementado nas próximas issues.',
      showSignOutAction: true,
    );
  }
}