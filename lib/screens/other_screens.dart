// ════════════════════════════════════════════════════════════════════════════
// diary_screen.dart
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/macro_bar.dart';
import '../models/models.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final totals = provider.todayTotals;
        final profile = provider.profile;

        return Scaffold(
          backgroundColor: AppColors.cream,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.cream,
                title: Text('Food Diary',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.forest)),
                actions: [
                  // Date picker
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 90)),
                          lastDate: DateTime.now(),
                          builder: (ctx, child) => Theme(
                            data: Theme.of(ctx).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.forest,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          provider.loadTodayLog(
                            date: DateFormat('yyyy-MM-dd').format(picked));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.forest.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 14, color: AppColors.forest),
                          const SizedBox(width: 6),
                          Text(
                            provider.selectedDate == DateFormat('yyyy-MM-dd').format(DateTime.now())
                                ? 'Today'
                                : DateFormat('MMM d').format(DateTime.parse(provider.selectedDate)),
                            style: GoogleFonts.dmSans(
                                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.forest),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Daily totals summary
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.parchment, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _DiaryStat('🔥', '${totals.calories.round()}', 'kcal'),
                              _Divider(),
                              _DiaryStat('💪', '${totals.protein.round()}g', 'protein'),
                              _Divider(),
                              _DiaryStat('🌾', '${totals.carbs.round()}g', 'carbs'),
                              _Divider(),
                              _DiaryStat('🫒', '${totals.fat.round()}g', 'fat'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          MacroBar(
                            label: 'Cal',
                            icon: '🔥',
                            current: totals.calories,
                            target: profile?.targetCalories ?? 2000,
                            unit: '',
                            color: AppColors.calorieColor,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms),

                    const SizedBox(height: 20),

                    Text("Meals",
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.forest)),
                    const SizedBox(height: 12),

                    ...['breakfast', 'lunch', 'dinner', 'snack'].map((type) =>
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: MealSectionCard(
                          mealType: type,
                          entries: provider.todayLog?.byMealType[type] ?? [],
                          onDelete: provider.removeMealEntry,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DiaryStat extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  const _DiaryStat(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(icon, style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 4),
      Text(value,
          style: GoogleFonts.playfairDisplay(
              fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.forest)),
      Text(label,
          style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textLight)),
    ],
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 40, color: AppColors.parchment);
}


// ════════════════════════════════════════════════════════════════════════════
// profile_screen.dart
// ════════════════════════════════════════════════════════════════════════════

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;

        return Scaffold(
          backgroundColor: AppColors.cream,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.cream,
                title: Text('My Profile',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.forest)),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Profile Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.forest, AppColors.leaf],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Text('🧑‍💪', style: TextStyle(fontSize: 36)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(profile?.name ?? 'User',
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(
                            profile == null ? '' :
                            '${profile.weightKg}kg · ${profile.heightCm}cm · ${profile.ageYears}y',
                            style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _ProfileStat('BMI', profile?.bmi.toStringAsFixed(1) ?? '-', profile?.bmiCategory ?? ''),
                              _ProfileStat('Goal', profile?.goal ?? '-', ''),
                              _ProfileStat('TDEE', '${profile?.tdee.round() ?? '-'}', 'kcal'),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 500.ms),

                    const SizedBox(height: 20),

                    // Targets
                    _SectionTitle('Daily Targets'),
                    const SizedBox(height: 12),
                    _TargetCard([
                      ['🔥', 'Calories', '${profile?.targetCalories.round() ?? 0} kcal'],
                      ['💪', 'Protein', '${profile?.targetProtein.round() ?? 0} g'],
                      ['🌾', 'Carbs', '${profile?.targetCarbs.round() ?? 0} g'],
                      ['🫒', 'Fat', '${profile?.targetFat.round() ?? 0} g'],
                      ['💧', 'Water', '${profile?.targetWaterMl.round() ?? 0} ml'],
                    ]),

                    const SizedBox(height: 16),

                    // Info
                    _SectionTitle('Activity & Goal'),
                    const SizedBox(height: 12),
                    _InfoCard([
                      ['🏃', 'Activity', _activityLabel(profile?.activityLevel)],
                      ['🎯', 'Goal', _goalLabel(profile?.goal)],
                      ['⚡', 'BMR', '${profile?.bmr.round() ?? 0} kcal'],
                    ]),

                    const SizedBox(height: 24),

                    // Reset data
                    GestureDetector(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: Text('Reset All Data?',
                                style: GoogleFonts.playfairDisplay(color: AppColors.forest)),
                            content: Text('This will clear all meal logs and profile data.',
                                style: GoogleFonts.dmSans(color: AppColors.textMid)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(context, true),
                                  child: Text('Reset',
                                      style: GoogleFonts.dmSans(color: AppColors.coral))),
                            ],
                          ),
                        );
                        // Reset handled in production
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.coral.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.coral.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.delete_outline_rounded,
                                color: AppColors.coral, size: 18),
                            const SizedBox(width: 8),
                            Text('Reset All Data',
                                style: GoogleFonts.dmSans(
                                    fontSize: 14, color: AppColors.coral,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _activityLabel(String? a) => switch (a) {
    'sedentary' => '🪑 Sedentary',
    'light' => '🚶 Light',
    'moderate' => '🏃 Moderate',
    'active' => '🏋️ Active',
    'veryActive' => '🔥 Very Active',
    _ => '-',
  };

  String _goalLabel(String? g) => switch (g) {
    'lose' => '📉 Lose Weight',
    'maintain' => '⚖️ Maintain',
    'gain' => '📈 Build Muscle',
    _ => '-',
  };
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  const _ProfileStat(this.label, this.value, this.sub);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: Colors.white60)),
      Text(value, style: GoogleFonts.playfairDisplay(
          fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
      if (sub.isNotEmpty)
        Text(sub, style: GoogleFonts.dmSans(fontSize: 9, color: Colors.white.withOpacity(0.5))),
    ],
  );
}

Widget _SectionTitle(String t) => Text(t,
    style: GoogleFonts.playfairDisplay(
        fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.forest));

Widget _TargetCard(List<List<String>> rows) => Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.parchment, width: 1.5),
  ),
  child: Column(
    children: rows.asMap().entries.map((e) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        border: Border(
          bottom: e.key < rows.length - 1
              ? const BorderSide(color: AppColors.parchment)
              : BorderSide.none,
        ),
      ),
      child: Row(children: [
        Text(e.value[0], style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Text(e.value[1],
            style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMid)),
        const Spacer(),
        Text(e.value[2],
            style: GoogleFonts.dmSans(
                fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.forest)),
      ]),
    )).toList(),
  ),
);

Widget _InfoCard(List<List<String>> rows) => Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.parchment, width: 1.5),
  ),
  child: Column(
    children: rows.asMap().entries.map((e) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        border: Border(
          bottom: e.key < rows.length - 1
              ? const BorderSide(color: AppColors.parchment)
              : BorderSide.none,
        ),
      ),
      child: Row(children: [
        Text(e.value[0], style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 12),
        Text(e.value[1],
            style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMid)),
        const Spacer(),
        Text(e.value[2],
            style: GoogleFonts.dmSans(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
      ]),
    )).toList(),
  ),
);


// ════════════════════════════════════════════════════════════════════════════
// onboarding_screen.dart
// ════════════════════════════════════════════════════════════════════════════

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  // Form state
  final _nameCtrl = TextEditingController(text: 'Alex');
  double _weight = 75;
  double _height = 170;
  int _age = 28;
  String _gender = 'male';
  String _activity = 'moderate';
  String _goal = 'maintain';

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 3) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    final profile = UserProfile.withAutoTargets(
      name: _nameCtrl.text.trim().isEmpty ? 'User' : _nameCtrl.text.trim(),
      weightKg: _weight,
      heightCm: _height,
      ageYears: _age,
      gender: _gender,
      activityLevel: _activity,
      goal: _goal,
    );
    context.read<AppProvider>().saveProfile(profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // Progress dots
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: List.generate(4, (i) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    height: 3,
                    decoration: BoxDecoration(
                      color: i <= _page ? AppColors.forest : AppColors.sand,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (p) => setState(() => _page = p),
                children: [
                  _OnboardPage1(nameCtrl: _nameCtrl),
                  _OnboardPage2(
                    weight: _weight, height: _height, age: _age,
                    onWeight: (v) => setState(() => _weight = v),
                    onHeight: (v) => setState(() => _height = v),
                    onAge: (v) => setState(() => _age = v),
                  ),
                  _OnboardPage3(
                    gender: _gender, activity: _activity,
                    onGender: (v) => setState(() => _gender = v),
                    onActivity: (v) => setState(() => _activity = v),
                  ),
                  _OnboardPage4(
                    goal: _goal,
                    onGoal: (v) => setState(() => _goal = v),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: GestureDetector(
                onTap: _next,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.forest, AppColors.leaf],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.forest.withOpacity(0.3),
                        blurRadius: 16, offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    _page == 3 ? '🚀  Start Tracking' : 'Continue →',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                        fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage1 extends StatelessWidget {
  final TextEditingController nameCtrl;
  const _OnboardPage1({required this.nameCtrl});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const Text('🍽️', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 20),
        Text('Welcome to\nMacroLens',
            style: GoogleFonts.playfairDisplay(
                fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.forest)),
        const SizedBox(height: 12),
        Text('Your AI-powered nutrition companion.\nTrack every bite, reach every goal.',
            style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.textMid, height: 1.5)),
        const SizedBox(height: 48),
        Text("What's your name?",
            style: GoogleFonts.dmSans(
                fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 10),
        TextField(
          controller: nameCtrl,
          style: GoogleFonts.playfairDisplay(fontSize: 20, color: AppColors.forest),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: GoogleFonts.dmSans(color: AppColors.sand),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.parchment),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.sage, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.parchment, width: 1.5),
            ),
          ),
        ),
      ],
    ),
  ));
}

class _OnboardPage2 extends StatelessWidget {
  final double weight, height;
  final int age;
  final Function(double) onWeight, onHeight;
  final Function(int) onAge;
  const _OnboardPage2({required this.weight, required this.height, required this.age,
    required this.onWeight, required this.onHeight, required this.onAge});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text('Your Body Stats',
            style: GoogleFonts.playfairDisplay(
                fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.forest)),
        const SizedBox(height: 8),
        Text('Used to calculate your calorie needs.',
            style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMid)),
        const SizedBox(height: 32),
        _Slider('⚖️ Weight', '${weight.round()} kg', weight, 40, 200,
            (v) => onWeight(v)),
        const SizedBox(height: 24),
        _Slider('📏 Height', '${height.round()} cm', height, 140, 220,
            (v) => onHeight(v)),
        const SizedBox(height: 24),
        _Slider('🎂 Age', '$age years', age.toDouble(), 15, 80,
            (v) => onAge(v.round())),
      ],
    ),
  ));
}

Widget _Slider(String label, String value, double val, double min, double max, Function(double) onChanged) =>
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(20)),
            child: Text(value, style: GoogleFonts.dmMono(fontSize: 13, color: Colors.white)),
          ),
        ],
      ),
      Slider(
        value: val, min: min, max: max,
        activeColor: AppColors.sage, inactiveColor: AppColors.sand,
        onChanged: onChanged,
      ),
    ],
  );

class _OnboardPage3 extends StatelessWidget {
  final String gender, activity;
  final Function(String) onGender, onActivity;
  const _OnboardPage3({required this.gender, required this.activity,
    required this.onGender, required this.onActivity});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text('Activity Level',
            style: GoogleFonts.playfairDisplay(
                fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.forest)),
        const SizedBox(height: 8),
        Text('Helps calculate how many calories you burn.',
            style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMid)),
        const SizedBox(height: 24),
        Row(children: ['male', 'female'].map((g) => Expanded(
          child: GestureDetector(
            onTap: () => onGender(g),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: gender == g ? AppColors.forest : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: gender == g ? AppColors.forest : AppColors.parchment, width: 1.5),
              ),
              child: Column(children: [
                Text(g == 'male' ? '👨' : '👩', style: const TextStyle(fontSize: 24)),
                Text(g == 'male' ? 'Male' : 'Female',
                    style: GoogleFonts.dmSans(
                        fontSize: 13, color: gender == g ? Colors.white : AppColors.textMid,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        )).toList()),
        const SizedBox(height: 24),
        ...{
          'sedentary': ['🪑', 'Sedentary', 'Desk job, no exercise'],
          'light': ['🚶', 'Lightly Active', 'Exercise 1-3×/week'],
          'moderate': ['🏃', 'Moderately Active', 'Exercise 3-5×/week'],
          'active': ['🏋️', 'Very Active', 'Hard exercise 6-7×/week'],
        }.entries.map((e) => GestureDetector(
          onTap: () => onActivity(e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: activity == e.key ? AppColors.forest.withOpacity(0.08) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: activity == e.key ? AppColors.forest : AppColors.parchment,
                width: activity == e.key ? 2 : 1.5,
              ),
            ),
            child: Row(children: [
              Text(e.value[0], style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.value[1], style: GoogleFonts.dmSans(
                    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                Text(e.value[2], style: GoogleFonts.dmSans(
                    fontSize: 11, color: AppColors.textLight)),
              ]),
              const Spacer(),
              if (activity == e.key)
                const Icon(Icons.check_circle_rounded, color: AppColors.forest, size: 20),
            ]),
          ),
        )),
      ],
    ),
  ));
}

class _OnboardPage4 extends StatelessWidget {
  final String goal;
  final Function(String) onGoal;
  const _OnboardPage4({required this.goal, required this.onGoal});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text('Your Goal',
            style: GoogleFonts.playfairDisplay(
                fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.forest)),
        const SizedBox(height: 8),
        Text("We'll set your daily calorie target based on this.",
            style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMid)),
        const SizedBox(height: 32),
        ...[
          ['lose', '📉', 'Lose Weight', 'Calorie deficit of 500 kcal'],
          ['maintain', '⚖️', 'Maintain Weight', 'Eat at your TDEE'],
          ['gain', '📈', 'Build Muscle', 'Calorie surplus of 300 kcal'],
        ].map((g) => GestureDetector(
          onTap: () => onGoal(g[0]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: goal == g[0] ? AppColors.forest : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: goal == g[0] ? AppColors.forest : AppColors.parchment,
                width: 1.5,
              ),
            ),
            child: Row(children: [
              Text(g[1], style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(g[2], style: GoogleFonts.playfairDisplay(
                    fontSize: 17, fontWeight: FontWeight.w700,
                    color: goal == g[0] ? Colors.white : AppColors.forest)),
                Text(g[3], style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: goal == g[0] ? Colors.white70 : AppColors.textLight)),
              ]),
            ]),
          ),
        )),
      ],
    ),
  ));
}
