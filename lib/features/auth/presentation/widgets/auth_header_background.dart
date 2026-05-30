import 'package:chatbot/core/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AuthHeaderBackground extends StatelessWidget {
  const AuthHeaderBackground({
    super.key,
    required this.child,
    this.height = 434,
  });

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _AuthHeaderClipper(),
      child: Container(
        height: height,
        width: double.infinity,
        color: AppColors.p05,
        child: child,
      ),
    );
  }
}

class _AuthHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 65);

    path.quadraticBezierTo(
      size.width * 0.35,
      size.height - 0,
      size.width * 0.50,
      size.height - 5,
    );

    path.quadraticBezierTo(
      size.width * 0.65,
      size.height - 0,
      size.width,
      size.height - 65,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}