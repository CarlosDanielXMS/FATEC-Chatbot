import 'package:flutter/material.dart';

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({
    super.key,
    this.logoAssetPath = 'assets/logos/logo-header.png',
  });

  final String logoAssetPath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: Center(
        child: Image.asset(
          logoAssetPath,
          height: 82,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}