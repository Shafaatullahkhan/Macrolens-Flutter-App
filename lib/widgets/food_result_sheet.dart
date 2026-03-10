import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';
import '../providers/app_provider.dart';
import 'package:uuid/uuid.dart';

class FoodResultSheet extends StatefulWidget {
  final FoodItem food;
  final Function(MealEntry) onAdd;

  const FoodResultSheet({super.key, required this.food, required this.onAdd});

  @override
  State<FoodResultSheet> createState() => _FoodResultSheetState();
}

class _FoodResultSheetState extends State<FoodResultSheet> {
  double _servingGrams = 100;
  String _mealType = 'lunch';

  NutrientValues get _scaled => widget.food.forServing(_servingGrams);

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final grade = food.nutritionGrade;
    final gradeColor = _gradeColor(grade);
    final isFav = context.watch<AppProvider>().isFavorite(food.id);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Drag handle
            const SizedBox(height: 10),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.sand,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                children: [
                  // ── Food Name & Grade ────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(food.name,
                                style: GoogleFonts.playfairDisplay(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.forest)),
                            if (food.brand != null) ...[
                              const SizedBox(height: 4),
                              Text(food.brand!,
                                  style: GoogleFonts.dmSans(
                                      fontSize: 13, color: AppColors.textLight)),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(
                              color: gradeColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: gradeColor.withOpacity(0.5)),
                            ),
                            child: Center(
                              child: Text(grade,
                                  style: GoogleFonts.playfairDisplay(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: gradeColor)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Grade', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textLight)),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // Favorite
                      GestureDetector(
                        onTap: () => context.read<AppProvider>().toggleFavorite(food),
                        child: Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            color: isFav
                                ? AppColors.coral.withOpacity(0.12)
                                : AppColors.parchment,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(isFav ? '❤️' : '🤍',
                                style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Calorie Hero ─────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.forest, AppColors.leaf],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Column(
                          children: [
                            Text(
                              _scaled.calories.round().toString(),
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                            Text('calories',
                                style: GoogleFonts.dmSans(
                                    fontSize: 12, color: Colors.white70)),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Text('for ${_servingGrams.round()}g',
                            style: GoogleFonts.dmSans(
                                fontSize: 13, color: Colors.white60)),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 16),

                  // ── Serving Slider ───────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.parchment.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Serving Size',
                                style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.forest,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('${_servingGrams.round()}g',
                                  style: GoogleFonts.dmMono(
                                      fontSize: 13, color: Colors.white)),
                            ),
                          ],
                        ),
                        Slider(
                          value: _servingGrams,
                          min: 10,
                          max: 500,
                          divisions: 49,
                          activeColor: AppColors.sage,
                          inactiveColor: AppColors.sand,
                          onChanged: (v) => setState(() => _servingGrams = v),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ...[50.0, 100.0, 150.0, 200.0, 300.0].map((g) =>
                              GestureDetector(
                                onTap: () => setState(() => _servingGrams = g),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _servingGrams == g
                                        ? AppColors.forest
                                        : AppColors.parchment,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('${g.round()}g',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 11,
                                          color: _servingGrams == g
                                              ? Colors.white
                                              : AppColors.textMid)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Macro Grid ───────────────────────────────────────
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.2,
                    children: [
                      _MacroChip('💪 Protein', '${_scaled.protein.toStringAsFixed(1)}g', AppColors.proteinColor),
                      _MacroChip('🌾 Carbs', '${_scaled.carbs.toStringAsFixed(1)}g', AppColors.carbColor),
                      _MacroChip('🫒 Fat', '${_scaled.fat.toStringAsFixed(1)}g', AppColors.fatColor),
                      _MacroChip('🌿 Fiber', '${_scaled.fiber.toStringAsFixed(1)}g', AppColors.fiberColor),
                      _MacroChip('🍬 Sugar', '${_scaled.sugar.toStringAsFixed(1)}g', AppColors.coral),
                      _MacroChip('🧂 Sodium', '${_scaled.sodium.round()}mg', AppColors.sky),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Meal Type Selector ───────────────────────────────
                  Text('Add to',
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  const SizedBox(height: 10),
                  Row(
                    children: ['breakfast', 'lunch', 'dinner', 'snack'].map((type) {
                      final meta = MealTypeMeta.info[type]!;
                      final isSelected = _mealType == type;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _mealType = type),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.forest : AppColors.parchment,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(meta['icon'], style: const TextStyle(fontSize: 18)),
                                const SizedBox(height: 2),
                                Text(
                                  meta['label'],
                                  style: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : AppColors.textMid,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // ── Add Button ───────────────────────────────────────
                  GestureDetector(
                    onTap: () {
                      final entry = MealEntry.fromFood(
                        widget.food, _servingGrams, _mealType,
                      );
                      widget.onAdd(entry);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.forest, AppColors.leaf],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.forest.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('✅', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Text(
                            'Add to ${MealTypeMeta.info[_mealType]!['label']}',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _gradeColor(String g) => switch (g) {
    'A' => AppColors.gradeA, 'B' => AppColors.gradeB,
    'C' => AppColors.gradeC, 'D' => AppColors.gradeD, _ => AppColors.gradeF,
  };
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMid)),
          Text(value,
              style: GoogleFonts.dmSans(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
