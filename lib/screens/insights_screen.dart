import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});
  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  List<DailyLog> _weeklyLogs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWeekly();
  }

  Future<void> _loadWeekly() async {
    final logs = await context.read<AppProvider>().getWeeklyLogs();
    if (mounted) setState(() { _weeklyLogs = logs; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.cream,
            title: Text('Weekly Insights',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.forest)),
          ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.forest))),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _CalorieBarChart(logs: _weeklyLogs)
                      .animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 16),
                  _MacroDonutChart(logs: _weeklyLogs)
                      .animate().fadeIn(delay: 100.ms, duration: 500.ms),
                  const SizedBox(height: 16),
                  _NutrientTrend(logs: _weeklyLogs)
                      .animate().fadeIn(delay: 200.ms, duration: 500.ms),
                  const SizedBox(height: 16),
                  _WaterChart(logs: _weeklyLogs)
                      .animate().fadeIn(delay: 300.ms, duration: 500.ms),
                  const SizedBox(height: 16),
                  _WeekSummaryCard(logs: _weeklyLogs)
                      .animate().fadeIn(delay: 400.ms, duration: 500.ms),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Calorie Bar Chart ────────────────────────────────────────────────────────

class _CalorieBarChart extends StatelessWidget {
  final List<DailyLog> logs;
  const _CalorieBarChart({required this.logs});

  @override
  Widget build(BuildContext context) {
    final profile = context.read<AppProvider>().profile;
    final target = profile?.targetCalories ?? 2000;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now().weekday - 1;

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
              Text('🔥 Calorie Intake',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.forest)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.sage.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('7 days',
                    style: GoogleFonts.dmSans(
                        fontSize: 11, color: AppColors.forest)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Target: ${target.round()} kcal/day',
              style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textLight)),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                      '${rod.toY.round()} kcal',
                      GoogleFonts.dmSans(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= days.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            days[i],
                            style: GoogleFonts.dmSans(
                                fontSize: 10, color: AppColors.textLight),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppColors.parchment, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: target,
                      color: AppColors.coral.withOpacity(0.5),
                      strokeWidth: 1.5,
                      dashArray: [6, 4],
                    ),
                  ],
                ),
                barGroups: List.generate(logs.length, (i) {
                  final cal = logs[i].totals.calories;
                  final isToday = i == logs.length - 1;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: cal,
                        width: 28,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: cal > target
                              ? [AppColors.coral.withOpacity(0.6), AppColors.coral]
                              : isToday
                                  ? [AppColors.forest, AppColors.sage]
                                  : [AppColors.sage.withOpacity(0.4), AppColors.sage.withOpacity(0.7)],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Macro Donut ─────────────────────────────────────────────────────────────

class _MacroDonutChart extends StatelessWidget {
  final List<DailyLog> logs;
  const _MacroDonutChart({required this.logs});

  @override
  Widget build(BuildContext context) {
    double totalP = 0, totalC = 0, totalF = 0;
    for (final log in logs) {
      totalP += log.totals.protein;
      totalC += log.totals.carbs;
      totalF += log.totals.fat;
    }
    final total = totalP * 4 + totalC * 4 + totalF * 9;
    final pPct = total == 0 ? 0.0 : (totalP * 4 / total * 100);
    final cPct = total == 0 ? 0.0 : (totalC * 4 / total * 100);
    final fPct = total == 0 ? 0.0 : (totalF * 9 / total * 100);

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
          Text('🍩 Macro Distribution',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.forest)),
          Text('Average this week',
              style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textLight)),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                height: 140,
                width: 140,
                child: PieChart(
                  PieChartData(
                    sections: total == 0
                        ? [PieChartSectionData(value: 1, color: AppColors.parchment, radius: 40, title: '')]
                        : [
                            PieChartSectionData(
                              value: pPct,
                              color: AppColors.proteinColor,
                              radius: 42,
                              title: '${pPct.round()}%',
                              titleStyle: GoogleFonts.dmMono(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            PieChartSectionData(
                              value: cPct,
                              color: AppColors.carbColor,
                              radius: 42,
                              title: '${cPct.round()}%',
                              titleStyle: GoogleFonts.dmMono(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            PieChartSectionData(
                              value: fPct,
                              color: AppColors.fatColor,
                              radius: 42,
                              title: '${fPct.round()}%',
                              titleStyle: GoogleFonts.dmMono(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                    centerSpaceRadius: 30,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  _Legend('💪 Protein', '${pPct.round()}%', AppColors.proteinColor),
                  const SizedBox(height: 12),
                  _Legend('🌾 Carbs', '${cPct.round()}%', AppColors.carbColor),
                  const SizedBox(height: 12),
                  _Legend('🫒 Fat', '${fPct.round()}%', AppColors.fatColor),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Legend(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(width: 12, height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          label,
          style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMid),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      const SizedBox(width: 8),
      Text(
        value,
        style: GoogleFonts.dmSans(
            fontSize: 13, fontWeight: FontWeight.w700, color: color),
      ),
    ],
  );
}

// ─── Nutrient Trend Line Chart ────────────────────────────────────────────────

class _NutrientTrend extends StatelessWidget {
  final List<DailyLog> logs;
  const _NutrientTrend({required this.logs});

  @override
  Widget build(BuildContext context) {
    final days = logs.map((l) {
      final d = DateTime.parse(l.dateKey);
      return DateFormat('E').format(d);
    }).toList();

    LineChartBarData line(List<double> values, Color color) => LineChartBarData(
      spots: values.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
      isCurved: true,
      color: color,
      barWidth: 2.5,
      dotData: FlDotData(
        getDotPainter: (_, __, ___, i) => FlDotCirclePainter(
          radius: 3.5, color: color, strokeWidth: 0),
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.06),
      ),
    );

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
          Text('📈 Protein & Carbs Trend',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.forest)),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: AppColors.parchment, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= days.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(days[i],
                              style: GoogleFonts.dmSans(
                                  fontSize: 10, color: AppColors.textLight)),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  line(logs.map((l) => l.totals.protein).toList(), AppColors.proteinColor),
                  line(logs.map((l) => l.totals.carbs / 3).toList(), AppColors.carbColor),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Row(children: [
            _Legend('💪 Protein (g)', '', AppColors.proteinColor),
            SizedBox(width: 16),
            _Legend('🌾 Carbs ÷3', '', AppColors.carbColor),
          ]),
        ],
      ),
    );
  }
}

// ─── Water Chart ─────────────────────────────────────────────────────────────

class _WaterChart extends StatelessWidget {
  final List<DailyLog> logs;
  const _WaterChart({required this.logs});

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
          Text('💧 Hydration History',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.forest)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: logs.map((log) {
              final d = DateTime.parse(log.dateKey);
              final glasses = (log.waterMl / 250).floor();
              final isToday = log.dateKey ==
                  DateFormat('yyyy-MM-dd').format(DateTime.now());
              return Column(
                children: [
                  Text(DateFormat('E').format(d),
                      style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: isToday ? AppColors.forest : AppColors.textLight,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w400)),
                  const SizedBox(height: 4),
                  Container(
                    width: 32,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.parchment,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        height: 60 * (log.waterMl / 3000).clamp(0.0, 1.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [AppColors.sky, Color(0xFF81D4FA)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('$glasses🥛',
                      style: const TextStyle(fontSize: 10)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Week Summary ─────────────────────────────────────────────────────────────

class _WeekSummaryCard extends StatelessWidget {
  final List<DailyLog> logs;
  const _WeekSummaryCard({required this.logs});

  @override
  Widget build(BuildContext context) {
    final daysLogged = logs.where((l) => l.meals.isNotEmpty).length;
    final avgCal = daysLogged == 0 ? 0.0 :
        logs.fold(0.0, (a, b) => a + b.totals.calories) / daysLogged;
    final totalProtein = logs.fold(0.0, (a, b) => a + b.totals.protein);
    final totalWater = logs.fold(0.0, (a, b) => a + b.waterMl);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.forest, AppColors.leaf],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📋 Week Summary',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 16),
          Row(
            children: [
              _SumItem('Days Tracked', '$daysLogged / 7', '📅'),
              _SumItem('Avg Calories', '${avgCal.round()}', '🔥'),
              _SumItem('Total Protein', '${totalProtein.round()}g', '💪'),
              _SumItem('Total Water', '${(totalWater / 1000).toStringAsFixed(1)}L', '💧'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SumItem extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  const _SumItem(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.playfairDisplay(
                fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        Text(label,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 9, color: Colors.white60)),
      ],
    ),
  );
}
