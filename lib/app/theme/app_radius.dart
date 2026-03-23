import 'package:flutter/material.dart';

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 28.0;
  static const double full = 999.0;

  static BorderRadius get cardMd => BorderRadius.circular(md);
  static BorderRadius get cardLg => BorderRadius.circular(lg);
  static BorderRadius get button => BorderRadius.circular(full);
  static BorderRadius get input => BorderRadius.circular(md);
  static BorderRadius get chip => BorderRadius.circular(full);
  static BorderRadius get dialog => BorderRadius.circular(xxl);
  static BorderRadius get sheet => const BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );
}
