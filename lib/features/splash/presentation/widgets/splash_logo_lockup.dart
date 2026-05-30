import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class SplashLogoLockup extends StatelessWidget {
  const SplashLogoLockup({
    super.key,
    required this.logoScale,
    required this.beOffsetFactor,
    required this.valueOffsetFactor,
    required this.screenWidth,
    this.logoAssetPath = 'assets/logos/ilustracao.png',
  });

  final double logoScale;
  final double beOffsetFactor;
  final double valueOffsetFactor;
  final double screenWidth;
  final String logoAssetPath;

  @override
  Widget build(BuildContext context) {
    final beStartOffset = -(screenWidth * 0.60);
    final valueStartOffset = screenWidth * 0.60;

    final beOffset = beStartOffset * beOffsetFactor;
    final valueOffset = valueStartOffset * valueOffsetFactor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: logoScale,
          child: Image.asset(
            logoAssetPath,
            width: 160,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        SizedBox(
          height: 36,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: Offset(beOffset, 0),
                child: Text(
                  'Be',
                  style: AppTypography.h1.copyWith(
                    color: AppColors.p03,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 3),
              Transform.translate(
                offset: Offset(valueOffset, 0),
                child: Text(
                  'Value',
                  style: AppTypography.h1.copyWith(
                    color: AppColors.p05,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}