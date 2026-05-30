import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/core/ui/widgets/feedback/app_feedback_state.dart';
import 'package:chatbot/core/ui/widgets/navigation/app_top_bar.dart';
import 'package:flutter/material.dart';

class PatientSideEffectsPlaceholderPage extends StatelessWidget {
  const PatientSideEffectsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: const [
          AppTopBar(
            title: 'Efeitos adversos',
            showBackButton: true,
          ),
          Expanded(
            child: AppFeedbackState.empty(
              title: 'Registro em breve',
              description:
                  'O formulário de efeitos adversos será implementado na próxima etapa.',
            ),
          ),
        ],
      ),
    );
  }
}