import 'package:chatbot/core/ui/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('AppButton', () {
    testWidgets('executa callback ao tocar no botão primário', (tester) async {
      var taps = 0;

      await tester.pumpWidget(wrapWithMaterial(AppButton.primary(label: 'Salvar', onPressed: () => taps++)));
      await tester.tap(find.text('Salvar'));
      await tester.pump();

      expect(taps, 1);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('botão secundário renderiza OutlinedButton', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(AppButton.secondary(label: 'Voltar', onPressed: () {})));

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Voltar'), findsOneWidget);
    });

    testWidgets('botão text renderiza TextButton não expandido por padrão', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(AppButton.text(label: 'Cancelar', onPressed: () {})));

      expect(find.byType(TextButton), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('mostra indicador e bloqueia callback durante loading', (tester) async {
      var taps = 0;

      await tester.pumpWidget(wrapWithMaterial(AppButton.primary(label: 'Salvar', isLoading: true, onPressed: () => taps++)));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Salvar'), findsNothing);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(taps, 0);
    });

    testWidgets('exibe ícone quando informado', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          AppButton.primary(
            label: 'Salvar',
            onPressed: () {},
            icon: const Icon(Icons.save),
          ),
        ),
      );

      expect(find.byIcon(Icons.save), findsOneWidget);
      expect(find.text('Salvar'), findsOneWidget);
    });
  });
}
