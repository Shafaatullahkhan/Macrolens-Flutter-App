import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../models/models.dart';
import '../widgets/macro_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;
        final totals = provider.todayTotals;

        return Scaffold(
          backgroundColor: AppColors.cream,
          body: CustomScrollView(
            slivers: [
              // ── App Bar ────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 0,
                pinned: true,
                backgroundColor: AppColors.cream,
                elevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: GoogleFonts.dmSans(
                          fontSize: 13, color: AppColors.textLight),
                    ),
                    Text(
                      profile?.name ?? 'Welcome',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forest),
                    ),
                  ],
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.forest.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Text('📅', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d').format(DateTime.now()),
                          style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.forest),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Calorie Ring Card ──────────────────────────────
                    _CalorieRingCard(
                      consumed: totals.calories,
                      target: profile?.targetCalories ?? 2000,
                      burned: 0,
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

                    const SizedBox(height: 16),

                    // ── Macro Bars ─────────────────────────────────────
                    _MacroGridCard(
                      totals: totals,
                      profile: profile,
                    ).animate().fadeIn(delay: 100.ms, duration: 500.ms),

                    const SizedBox(height: 16),

                    // ── Water Tracker ──────────────────────────────────
                    WaterTracker(
                      currentMl: provider.todayLog?.waterMl ?? 0,
                      targetMl: profile?.targetWaterMl ?? 2500,
                      onAdd: (ml) => provider.logWater(ml),
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                    const SizedBox(height: 20),

                    // ── Meals ──────────────────────────────────────────
                    Text(
                      "Today's Meals",
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forest),
                    ).animate().fadeIn(delay: 250.ms),

                    const SizedBox(height: 12),

                    ...['breakfast', 'lunch', 'dinner', 'snack'].map((type) {
                      final meals = provider.todayLog?.byMealType[type] ?? [];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: MealSectionCard(
                          mealType: type,
                          entries: meals,
                          onDelete: (id) => provider.removeMealEntry(id),
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // ── Nutrition Grade ────────────────────────────────
                    _NutritionReportCard(totals: totals, profile: profile)
                        .animate().fadeIn(delay: 350.ms, duration: 500.ms),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}

// ─── Calorie Ring Card ────────────────────────────────────────────────────────

class _CalorieRingCard extends StatelessWidget {
  final double consumed;
  final double target;
  final double burned;

  const _CalorieRingCard({
    required this.consumed,
    required this.target,
    required this.burned,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (target - consumed + burned).clamp(0.0, double.infinity);
    final progress = target == 0 ? 0.0 : (consumed / target).clamp(0.0, 1.0);
    final isOver = consumed > target;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.forest, AppColors.leaf],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ring
          CircularPercentIndicator(
            radius: 72,
            lineWidth: 12,
            percent: progress,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  consumed.round().toString(),
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
                Text(
                  'kcal',
                  style: GoogleFonts.dmSans(
                      fontSize: 11, color: Colors.white60),
                ),
              ],
            ),
            backgroundColor: Colors.white.withOpacity(0.15),
            progressColor: isOver ? AppColors.coral : AppColors.mint,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 800,
          ),

          const SizedBox(width: 20),

          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CalStat('🎯 Goal', '${target.round()} kcal', Colors.white70),
                const SizedBox(height: 12),
                _CalStat(
                  isOver ? '⚠️ Over by' : '✅ Remaining',
                  '${remaining.round()} kcal',
                  isOver ? AppColors.coral : AppColors.mint,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(progress * 100).round()}% of goal',
                    style: GoogleFonts.dmMono(
                        fontSize: 11, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _CalStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: Colors.white60)),
      Text(value, style: GoogleFonts.dmSans(
          fontSize: 15, fontWeight: FontWeight.w700, color: color)),
    ],
  );
}

// ─── Macro Grid Card ──────────────────────────────────────────────────────────

class _MacroGridCard extends StatelessWidget {
  final NutrientValues totals;
  final UserProfile? profile;

  const _MacroGridCard({required this.totals, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.parchment, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Macronutrients',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.forest)),
          const SizedBox(height: 16),
          MacroBar(
            label: 'Protein',
            icon: '💪',
            current: totals.protein,
            target: profile?.targetProtein ?? 150,
            unit: 'g',
            color: AppColors.proteinColor,
          ),
          const SizedBox(height: 10),
          MacroBar(
            label: 'Carbs',
            icon: '🌾',
            current: totals.carbs,
            target: profile?.targetCarbs ?? 250,
            unit: 'g',
            color: AppColors.carbColor,
          ),
          const SizedBox(height: 10),
          MacroBar(
            label: 'Fat',
            icon: '🫒',
            current: totals.fat,
            target: profile?.targetFat ?? 65,
            unit: 'g',
            color: AppColors.fatColor,
          ),
          const SizedBox(height: 10),
          MacroBar(
            label: 'Fiber',
            icon: '🌿',
            current: totals.fiber,
            target: 30,
            unit: 'g',
            color: AppColors.fiberColor,
          ),
        ],
      ),
    );
  }
}

// ─── Nutrition Report Card ────────────────────────────────────────────────────

class _NutritionReportCard extends StatelessWidget {
  final NutrientValues totals;
  final UserProfile? profile;

  const _NutritionReportCard({required this.totals, required this.profile});

  String _grade(double current, double target) {
    if (target == 0) return 'N/A';
    final r = current / target;
    if (r >= 0.85 && r <= 1.1) return 'A';
    if (r >= 0.7 && r <= 1.25) return 'B';
    if (r >= 0.5 && r <= 1.4) return 'C';
    if (r >= 0.3) return 'D';
    return 'F';
  }

  Color _gradeColor(String g) => switch (g) {
    'A' => AppColors.gradeA, 'B' => AppColors.gradeB,
    'C' => AppColors.gradeC, 'D' => AppColors.gradeD, _ => AppColors.gradeF,
  };

  @override
  Widget build(BuildContext context) {
    final grades = {
      'Calories': _grade(totals.calories, profile?.targetCalories ?? 2000),
      'Protein': _grade(totals.protein, profile?.targetProtein ?? 150),
      'Carbs': _grade(totals.carbs, profile?.targetCarbs ?? 250),
      'Fat': _grade(totals.fat, profile?.targetFat ?? 65),
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.parchment, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📋 ',
                  style: TextStyle(fontSize: 18)),
              Text("Today's Report Card",
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.forest)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: grades.entries.map((e) => _GradeBadge(
              label: e.key,
              grade: e.value,
              color: _gradeColor(e.value),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _GradeBadge extends StatelessWidget {
  final String label;
  final String grade;
  final Color color;
  const _GradeBadge({required this.label, required this.grade, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Center(
          child: Text(grade,
              style: GoogleFonts.playfairDisplay(
                  fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        ),
      ),
      const SizedBox(height: 4),
      Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 11, color: AppColors.textLight)),
    ],
  );
}
