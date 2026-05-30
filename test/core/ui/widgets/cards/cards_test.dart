import 'package:chatbot/core/ui/widgets/cards/app_card.dart';
import 'package:chatbot/core/ui/widgets/cards/app_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('Cards', () {
    testWidgets('AppCard exibe conteúdo e executa onTap', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        wrapWithMaterial(
          AppCard(
            onTap: () => taps++,
            child: const Text('Conteúdo'),
          ),
        ),
      );
      await tester.tap(find.text('Conteúdo'));
      await tester.pump();

      expect(find.text('Conteúdo'), findsOneWidget);
      expect(taps, 1);
    });

    testWidgets('AppDivider renderiza Divider', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(const AppDivider()));

      expect(find.byType(Divider), findsOneWidget);
    });
  });
}
