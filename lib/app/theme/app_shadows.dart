import 'package:flutter/material.dart';

class AppShadows {
  // Light mode shadows
  static List<BoxShadow> get xs => [
    const BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4, 
      offset: Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get sm => [
    const BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8, 
      offset: Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get md => [
    const BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16, 
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get lg => [
    const BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24, 
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get floating => [
    const BoxShadow(
      color: Color(0x24000000),
      blurRadius: 20, 
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get primaryButton => [
    const BoxShadow(
      color: Color(0x33111111),
      blurRadius: 14, 
      offset: Offset(0, 4),
    ),
  ];
}
