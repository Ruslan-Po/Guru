import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static final TextStyle buttons = GoogleFonts.gabarito(
    fontSize: 15,
    shadows: [
      Shadow(
        offset: Offset(0, 0),
        blurRadius: 10.0,
        color: Color.fromARGB(62, 163, 239, 224),
      ),
    ],
    color: const Color.fromARGB(228, 163, 239, 224),
  );
  static final TextStyle descriptions = GoogleFonts.gowunDodum(
    fontSize: 21,
    shadows: [
      Shadow(
        offset: Offset(0, 0),
        blurRadius: 10.0,
        color: Color.fromARGB(255, 163, 239, 224),
      ),
    ],
    color: const Color.fromARGB(228, 163, 239, 224),
  );

  static final TextStyle flowAnswer = GoogleFonts.raleway(
    fontSize: 24,
    color: const Color(0xFF1ECBE1),
    shadows: [
      Shadow(
        offset: Offset(0, 0),
        blurRadius: 10.0,
        color: Color.fromARGB(100, 30, 202, 225),
      ),
    ],
  );

  static final TextStyle logicAnswer = GoogleFonts.raleway(
    fontSize: 24,
    color: const Color(0xFF7CA9C3),
    shadows: [
      Shadow(
        offset: Offset(0, 0),
        blurRadius: 10.0,
        color: Color.fromARGB(100, 53, 91, 125),
      ),
    ],
  );

  static final TextStyle poetryAnswer = GoogleFonts.raleway(
    fontSize: 24,
    color: const Color(0xFFC47AD6),
    shadows: [
      Shadow(
        offset: Offset(0, 0),
        blurRadius: 10.0,
        color: Color.fromARGB(100, 196, 122, 214),
      ),
    ],
  );

  static final TextStyle silenceAnswer = GoogleFonts.raleway(
    fontSize: 24,
    color: const Color(0xFFE2E7EF),
    shadows: [
      Shadow(
        offset: Offset(0, 0),
        blurRadius: 10.0,
        color: Color.fromARGB(100, 226, 231, 239),
      ),
    ],
  );
}
