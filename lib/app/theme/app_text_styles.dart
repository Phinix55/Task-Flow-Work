import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // ─── Display ───────────────────────────────────────────
  static TextStyle get displayXl => GoogleFonts.plusJakartaSans(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.5,
  );
  
  static TextStyle get displayLg => GoogleFonts.plusJakartaSans(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.4,
  );

  static TextStyle get displayMd => GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.3,
  );

  // ─── Heading ───────────────────────────────────────────
  static TextStyle get headingXl => GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
  );
  
  static TextStyle get headingLg => GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.15,
  );
  
  static TextStyle get headingMd => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.1,
  );
  
  static TextStyle get headingSm => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
  );

  // ─── Body ──────────────────────────────────────────────
  static TextStyle get bodyLg => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0,
  );
  
  static TextStyle get bodyMd => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.55,
    letterSpacing: 0,
  );
  
  static TextStyle get bodySm => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );
  
  static TextStyle get bodyXs => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );

  // ─── Label ─────────────────────────────────────────────
  static TextStyle get labelLg => GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0,
  );
  
  static TextStyle get labelMd => GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.1,
  );
  
  static TextStyle get labelSm => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.5,
  );

  static TextStyle get labelXs => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.5,
  );
}
