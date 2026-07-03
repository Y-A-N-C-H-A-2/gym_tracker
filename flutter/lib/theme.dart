import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class Palette {
  static const volt = Color(0xFFC8F72C);
  static const bg = Color(0xFF0D0E10);
  static const surface = Color(0xFF16181C);
  static const surface2 = Color(0xFF22252B);
  static const cardDone = Color(0xFF181D12);
  static const border = Color(0xFF2A2D33);
  static const borderHeader = Color(0xFF23262B);
  static const progressTrack = Color(0xFF1C1F24);
  static const textDim = Color(0xFF888D94);
  static const textFaint = Color(0xFF6B7077);
  static const textGhost = Color(0xFF4D5158);
  static const footNote = Color(0xFF5A5F66);
  static const restOrange = Color(0xFFFF7A2F);
  static const restText = Color(0xFFFF8A4F);
  static const watchBlue = Color(0xFF7DB5FF);
  static const watchBase = Color(0xFF468CFF);
  static const darkOnVolt = Color(0xFF15180A);
  static const darkOnTimer = Color(0xFF15110A);
}

/// The design's display font: Barlow Condensed.
TextStyle condensed(
  double size, {
  FontWeight weight = FontWeight.w700,
  Color color = Colors.white,
  double? letterSpacing,
  double? height,
}) =>
    GoogleFonts.barlowCondensed(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );

TextStyle body(
  double size, {
  FontWeight weight = FontWeight.w600,
  Color color = Colors.white,
  double? letterSpacing,
}) =>
    GoogleFonts.barlow(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );
