import 'package:flutter/material.dart';

/// Dark palette shared by every screen. Status colors are lighter than
/// their usual light-mode values so they keep contrast on dark surfaces.
abstract final class AppColors {
  static const background = Color(0xFF0A0A0F);
  static const surface = Color(0xFF14141B);
  static const surfaceRaised = Color(0xFF1C1C25);
  static const border = Color(0x14FFFFFF);

  static const textPrimary = Color(0xFFF4F4F7);
  static const textSecondary = Color(0xFFA1A1AE);
  static const textTertiary = Color(0xFF6E6E7C);

  static const accent = Color(0xFF8B8DFF);
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);
  static const danger = Color(0xFFF87171);
}
