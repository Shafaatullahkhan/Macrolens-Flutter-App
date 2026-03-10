import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// MacroLens design system: colors + theme.

// ─── MacroLens Design System ──────────────────────────────────────────────────
// Aesthetic: "Organic Science" — warm botanicals meet precise data visualization
// Palette: Deep forest green + warm cream + coral accent + golden amber

class AppColors {
  // Primary palette
  static const Color forest = Color(0xFF1B4332);       // Deep forest green
  static const Color leaf = Color(0xFF2D6A4F);         // Mid green
  static const Color sage = Color(0xFF52B788);         // Sage green accent
  static const Color mint = Color(0xFF95D5B2);         // Light mint

  // Warm neutrals
  static const Color cream = Color(0xFFF8F3E9);        // Warm cream bg
  static const Color parchment = Color(0xFFEEE8D5);    // Slightly darker cream
  static const Color sand = Color(0xFFD4C5A9);         // Sand/tan
  static const Color bark = Color(0xFF8B6F47);         // Warm bark brown

  // Accents
  static const Color coral = Color(0xFFE07A5F);        // Coral for protein
  static const Color amber = Color(0xFFD4A017);        // Amber for carbs
  static const Color sky = Color(0xFF6B9AB8);          // Blue for hydration
  static const Color lavender = Color(0xFF9B89B4);     // Purple for fiber

  // Macro-specific
  static const Color proteinColor = Color(0xFFE07A5F);
  static const Color carbColor = Color(0xFFD4A017);
  static const Color fatColor = Color(0xFF6B9AB8);
  static const Color calorieColor = Color(0xFF52B788);
  static const Color fiberColor = Color(0xFF9B89B4);

  // Dark surface
  static const Color darkBg = Color(0xFF0D1F18);
  static const Color darkCard = Color(0xFF162B22);
  static const Color darkBorder = Color(0xFF1F3D30);

  // Text
  static const Color textDark = Color(0xFF1B2E24);
  static const Color textMid = Color(0xFF4A6155);
  static const Color textLight = Color(0xFF8FA99A);

  // Grades
  static const Color gradeA = Color(0xFF52B788);
  static const Color gradeB = Color(0xFF95D5B2);
  static const Color gradeC = Color(0xFFD4A017);
  static const Color gradeD = Color(0xFFE07A5F);
  static const Color gradeF = Color(0xFFBF4040);
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: const ColorScheme.light(
          primary: AppColors.forest,
          secondary: AppColors.sage,
          surface: AppColors.cream,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.textDark,
        ),
        textTheme: GoogleFonts.dmSansTextTheme().copyWith(
          displayLarge: GoogleFonts.playfairDisplay(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: AppColors.forest,
          ),
          displayMedium: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.forest,
          ),
          headlineLarge: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.forest,
          ),
          headlineMedium: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          titleLarge: GoogleFonts.dmSans(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          bodyLarge: GoogleFonts.dmSans(
            fontSize: 15,
            color: AppColors.textDark,
          ),
          bodyMedium: GoogleFonts.dmSans(
            fontSize: 13,
            color: AppColors.textMid,
          ),
          labelSmall: GoogleFonts.dmMono(
            fontSize: 10,
            letterSpacing: 1.2,
            color: AppColors.textLight,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.parchment, width: 1.5),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.cream,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.forest,
          ),
          iconTheme: const IconThemeData(color: AppColors.forest),
        ),
      );
}

// Macro nutrient info
class MacroInfo {
  static const Map<String, Map<String, dynamic>> nutrients = {
    'calories': {'label': 'Calories', 'unit': 'kcal', 'color': AppColors.calorieColor, 'icon': '🔥'},
    'protein': {'label': 'Protein', 'unit': 'g', 'color': AppColors.proteinColor, 'icon': '💪'},
    'carbs': {'label': 'Carbs', 'unit': 'g', 'color': AppColors.carbColor, 'icon': '🌾'},
    'fat': {'label': 'Fat', 'unit': 'g', 'color': AppColors.fatColor, 'icon': '🫒'},
    'fiber': {'label': 'Fiber', 'unit': 'g', 'color': AppColors.fiberColor, 'icon': '🌿'},
    'sugar': {'label': 'Sugar', 'unit': 'g', 'color': AppColors.coral, 'icon': '🍬'},
    'sodium': {'label': 'Sodium', 'unit': 'mg', 'color': AppColors.sky, 'icon': '🧂'},
  };
}
