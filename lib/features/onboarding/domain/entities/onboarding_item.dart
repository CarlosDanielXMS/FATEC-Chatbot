import 'package:flutter/material.dart';

class OnboardingItem {
  const OnboardingItem({
    required this.title,
    required this.description,
    required this.imagePath,
    this.imageHeight = 280,
    this.backgroundColor,
  });

  final String title;
  final String description;
  final String imagePath;
  final double imageHeight;
  final Color? backgroundColor;
}