import 'package:flutter/material.dart';

class AuthLogoHeader extends StatelessWidget {
  const AuthLogoHeader({
    super.key,
    this.logoAssetPath = 'assets/logos/ilustracao.png',
    this.height = 67,
  });

  final String logoAssetPath;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        logoAssetPath,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}