import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Theme constants', () {
    test('cores, espaçamentos e raios principais permanecem estáveis', () {
      expect(AppColors.primary, const Color(0xFF172B83));
      expect(AppColors.secondary, const Color(0xFFF5750C));
      expect(AppSpacing.s16, 16);
      expect(AppRadius.md, 12);
      expect(AppDurations.normal, const Duration(milliseconds: 250));
    });

    test('AppTheme.light configura Material 3 e cores principais', () {
      final theme = AppTheme.light;

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.secondary, AppColors.secondary);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.textTheme.headlineLarge, AppTypography.h1);
    });
  });
}
