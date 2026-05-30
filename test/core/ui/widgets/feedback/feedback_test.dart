import 'package:chatbot/core/ui/widgets/feedback/app_feedback_state.dart';
import 'package:chatbot/core/ui/widgets/feedback/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('Feedback widgets', () {
    testWidgets('AppLoading exibe indicador e mensagem opcional', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(const AppLoading(message: 'Carregando...')));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Carregando...'), findsOneWidget);
    });

    testWidgets('AppFeedbackState.empty exibe ação quando informada', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        wrapWithMaterial(
          AppFeedbackState.empty(
            title: 'Nada por aqui',
            description: 'Cadastre um item.',
            actionLabel: 'Adicionar',
            onActionPressed: () => taps++,
          ),
        ),
      );
      await tester.tap(find.text('Adicionar'));
      await tester.pump();

      expect(find.text('Nada por aqui'), findsOneWidget);
      expect(find.text('Cadastre um item.'), findsOneWidget);
      expect(taps, 1);
    });

    testWidgets('AppFeedbackState.error e success exibem ícones padrão', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const AppFeedbackState.error(title: 'Erro', description: 'Tente novamente.'),
        ),
      );
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      await tester.pumpWidget(
        wrapWithMaterial(
          const AppFeedbackState.success(title: 'Sucesso', description: 'Finalizado.'),
        ),
      );
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });
  });
}
