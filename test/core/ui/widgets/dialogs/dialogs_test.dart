import 'package:chatbot/core/ui/widgets/dialogs/app_dialog.dart';
import 'package:chatbot/core/ui/widgets/dialogs/app_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('Dialogs', () {
    testWidgets('AppDialog exibe título, conteúdo e actions', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const AppDialog(
            title: 'Confirmar',
            content: Text('Deseja continuar?'),
            actions: [Text('Sim')],
          ),
        ),
      );

      expect(find.text('Confirmar'), findsOneWidget);
      expect(find.text('Deseja continuar?'), findsOneWidget);
      expect(find.text('Sim'), findsOneWidget);
    });

    testWidgets('AppOverlay envolve child em ColoredBox centralizado', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(const AppOverlay(child: Text('Loading'))));

      expect(find.byType(ColoredBox), findsWidgets);
      expect(find.text('Loading'), findsOneWidget);
    });
  });
}
