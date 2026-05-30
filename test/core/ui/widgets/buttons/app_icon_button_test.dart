import 'package:chatbot/core/ui/widgets/buttons/app_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('AppIconButton', () {
    testWidgets('executa callback ao tocar', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        wrapWithMaterial(
          AppIconButton(
            icon: const Icon(Icons.add),
            onPressed: () => taps++,
          ),
        ),
      );
      await tester.tap(find.byType(AppIconButton));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('envolve com Tooltip quando tooltip é informado', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          AppIconButton(
            icon: const Icon(Icons.info),
            onPressed: () {},
            tooltip: 'Informações',
          ),
        ),
      );

      expect(find.byType(Tooltip), findsOneWidget);
    });
  });
}
