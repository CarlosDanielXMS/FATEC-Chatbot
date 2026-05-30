import 'package:chatbot/features/onboarding/domain/entities/onboarding_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingItem', () {
    test('usa altura padrão e preserva valores informados', () {
      const item = OnboardingItem(
        title: 'Título',
        description: 'Descrição',
        imagePath: 'assets/image.png',
      );

      expect(item.title, 'Título');
      expect(item.description, 'Descrição');
      expect(item.imagePath, 'assets/image.png');
      expect(item.imageHeight, 280);
      expect(item.backgroundColor, isNull);
    });

    test('permite customizar altura e cor de fundo', () {
      const item = OnboardingItem(
        title: 'Título',
        description: 'Descrição',
        imagePath: 'assets/image.png',
        imageHeight: 120,
        backgroundColor: Colors.red,
      );

      expect(item.imageHeight, 120);
      expect(item.backgroundColor, Colors.red);
    });
  });
}
