import 'package:flutter/material.dart';

abstract final class AppColors {
  // ========================
  // BASE (neutros)
  // ========================
  static const b01 = Color(0xFFFFFCF5);
  static const b02 = Color(0xFFE5E1DC);
  static const b03 = Color(0xFFB0ACA9);
  static const b04 = Color(0xFF575553);
  static const b05 = Color(0xFF2D2D2B);
  static const b06 = Color(0xFF000000);

  // ========================
  // PRIMARY (azul)
  // ========================
  static const p01 = Color(0xFFB2C8E9);
  static const p02 = Color(0xFF84A6D3);
  static const p03 = Color(0xFF5979BA);
  static const p04 = Color(0xFF3A5DA2);
  static const p05 = Color(0xFF172B83);
  static const p06 = Color(0xFF0C0064);

  // ========================
  // SECONDARY (laranja)
  // ========================
  static const s01 = Color(0xFFFFD1A8);
  static const s02 = Color(0xFFFFA050);
  static const s03 = Color(0xFFF5750C);

  // ========================
  // SEMÂNTICOS
  // ========================
  static const success = Color(0xFF2E7D32);
  static const error = Color(0xFFD32F2F);
  static const warning = s02;
  static const info = p01;

  // ========================
  // TEXT
  // ========================
  static const textPrimary = b05;
  static const textSecondary = b04;
  static const textMuted = b03;
  static const textInverse = b01;

  // ========================
  // BACKGROUND
  // ========================
  static const background = b01;
  static const surface = Color(0xFFFFFFFF);

  // ========================
  // BORDER
  // ========================
  static const border = b02;
  static const borderStrong = b03;
  static const borderError = error;

  // ========================
  // ACTIONS
  // ========================
  static const primary = p05;
  static const primaryPressed = p06;
  static const primaryDisabled = p02;

  static const secondary = s03;

  // ========================
  // OVERLAY
  // ========================
  static const overlay = Color(0x66000000);
}