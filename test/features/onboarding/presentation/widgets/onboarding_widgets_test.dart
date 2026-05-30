import 'package:chatbot/features/onboarding/presentation/widgets/onboarding_footer.dart';
import 'package:chatbot/features/onboarding/presentation/widgets/onboarding_header.dart';
import 'package:chatbot/features/onboarding/presentation/widgets/onboarding_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('Onboarding widgets', () {
    testWidgets('OnboardingProgressIndicator cria indicadores', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(const OnboardingProgressIndicator(length: 4, currentIndex: 2)));

      expect(find.byType(AnimatedContainer), findsNWidgets(4));
    });

    testWidgets('OnboardingHeader renderiza imagem da logo', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(const OnboardingHeader()));
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('OnboardingFooter chama pular e próximo quando não é última página', (tester) async {
      var next = 0;
      var skip = 0;

      await tester.pumpWidget(
        wrapWithMaterial(
          OnboardingFooter(
            length: 3,
            currentIndex: 0,
            isLastPage: false,
            startButtonKey: GlobalKey(),
            onNextPressed: () => next++,
            onStartPressed: () {},
            onSkipPressed: () => skip++,
          ),
        ),
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.tap(find.text('Pular'));
      await tester.pump();

      expect(next, 1);
      expect(skip, 1);
    });

    testWidgets('OnboardingFooter mostra botão Comece agora na última página', (tester) async {
      var started = 0;

      await tester.pumpWidget(
        wrapWithMaterial(
          OnboardingFooter(
            length: 3,
            currentIndex: 2,
            isLastPage: true,
            startButtonKey: GlobalKey(),
            onNextPressed: () {},
            onStartPressed: () => started++,
            onSkipPressed: () {},
          ),
        ),
      );
      await tester.tap(find.text('Comece agora'));
      await tester.pump();

      expect(started, 1);
      expect(find.text('Pular'), findsOneWidget);
    });
  });
}
