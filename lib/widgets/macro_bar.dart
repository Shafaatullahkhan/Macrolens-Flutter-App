import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';

// ─── Macro Progress Bar ───────────────────────────────────────────────────────

class MacroBar extends StatelessWidget {
  final String label;
  final String icon;
  final double current;
  final double target;
  final String unit;
  final Color color;

  const MacroBar({
    super.key,
    required this.label,
    required this.icon,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target == 0 ? 0.0 : (current / target).clamp(0.0, 1.2);
    final isOver = progress > 1.0;

    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        SizedBox(
          width: 56,
          child: Text(label,
              style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textMid)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(height: 8, color: AppColors.parchment),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  height: 8,
                  width: double.infinity,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isOver ? AppColors.coral : color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 72,
          child: Text(
            '${current.round()} / ${target.round()}$unit',
            style: GoogleFonts.dmMono(
                fontSize: 10,
                color: isOver ? AppColors.coral : AppColors.textLight),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ─── Meal Section Card ────────────────────────────────────────────────────────

class MealSectionCard extends StatefulWidget {
  final String mealType;
  final List<MealEntry> entries;
  final Function(String) onDelete;

  const MealSectionCard({
    super.key,
    required this.mealType,
    required this.entries,
    required this.onDelete,
  });

  @override
  State<MealSectionCard> createState() => _MealSectionCardState();
}

class _MealSectionCardState extends State<MealSectionCard> {
  bool _expanded = false;

  double get _totalCals =>
      widget.entries.fold(0.0, (a, b) => a + b.calories);

  @override
  Widget build(BuildContext context) {
    final meta = MealTypeMeta.info[widget.mealType]!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.parchment, width: 1.5),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.sage.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(meta['icon'],
                          style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(meta['label'],
                            style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark)),
                        Text(
                          widget.entries.isEmpty
                              ? 'No foods logged'
                              : '${widget.entries.length} item${widget.entries.length > 1 ? 's' : ''}',
                          style: GoogleFonts.dmSans(
                              fontSize: 11, color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ),
                  if (widget.entries.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.forest.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_totalCals.round()} kcal',
                        style: GoogleFonts.dmMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.forest),
                      ),
                    ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textLight, size: 20),
                  ),
                ],
              ),
            ),
          ),

          // Entries
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: _expanded && widget.entries.isNotEmpty
                ? Column(
                    children: [
                      const Divider(
                          color: AppColors.parchment, height: 1),
                      ...widget.entries.asMap().entries.map((e) =>
                          _MealEntryRow(
                            entry: e.value,
                            onDelete: () => widget.onDelete(e.value.id),
                          ).animate()
                              .fadeIn(delay: Duration(milliseconds: e.key * 40), duration: 200.ms),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _MealEntryRow extends StatelessWidget {
  final MealEntry entry;
  final VoidCallback onDelete;

  const _MealEntryRow({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.coral.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.coral),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.foodName,
                      style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text('${entry.servingGrams.round()}g',
                      style: GoogleFonts.dmSans(
                          fontSize: 11, color: AppColors.textLight)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${entry.calories.round()} kcal',
                    style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.forest)),
                Text(
                  'P:${entry.protein.round()} C:${entry.carbs.round()} F:${entry.fat.round()}',
                  style: GoogleFonts.dmMono(
                      fontSize: 9, color: AppColors.textLight),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Water Tracker ────────────────────────────────────────────────────────────

class WaterTracker extends StatelessWidget {
  final double currentMl;
  final double targetMl;
  final Function(double) onAdd;

  const WaterTracker({
    super.key,
    required this.currentMl,
    required this.targetMl,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentMl / targetMl).clamp(0.0, 1.0);
    final glasses = (currentMl / 250).floor();

    return Container(
      padding: const EdgeInsets.all(18),
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
              const Text('💧', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('Hydration',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forest)),
              const Spacer(),
              Text(
                '${currentMl.round()} / ${targetMl.round()} ml',
                style: GoogleFonts.dmMono(
                    fontSize: 11, color: AppColors.textLight),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(height: 12, color: AppColors.parchment),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 500),
                  widthFactor: progress,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.sky, Color(0xFF4FC3F7)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Glass icons
          Row(
            children: [
              ...List.generate(8, (i) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  i < glasses ? '🥛' : '🫙',
                  style: const TextStyle(fontSize: 18),
                ),
              )),
              const Spacer(),
            ],
          ),

          const SizedBox(height: 12),

          // Quick add buttons
          Row(
            children: [150.0, 250.0, 350.0, 500.0].map((ml) =>
              Expanded(
                child: GestureDetector(
                  onTap: () => onAdd(ml),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.sky.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.sky.withOpacity(0.3)),
                    ),
                    child: Text(
                      '+${ml.round()}ml',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sky),
                    ),
                  ),
                ),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }
}
