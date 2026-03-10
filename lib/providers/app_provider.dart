// Central app state (profile, daily logs, favorites) backed by Hive boxes.
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

class AppProvider extends ChangeNotifier {
  static const String _profileBox = 'user_profile';
  static const String _mealsBox = 'meal_entries';
  static const String _foodsBox = 'food_items';
  static const String _waterBox = 'water_logs';

  UserProfile? _profile;
  DailyLog? _todayLog;
  List<FoodItem> _favorites = [];
  List<FoodItem> _recentFoods = [];
  bool _isLoading = false;
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  UserProfile? get profile => _profile;
  DailyLog? get todayLog => _todayLog;
  List<FoodItem> get favorites => _favorites;
  List<FoodItem> get recentFoods => _recentFoods;
  bool get isLoading => _isLoading;
  String get selectedDate => _selectedDate;
  bool get hasProfile => _profile != null && _profile!.onboardingDone;

  NutrientValues get todayTotals => _todayLog?.totals ?? const NutrientValues();

  double get calorieProgress =>
      _profile == null || _profile!.targetCalories == 0
          ? 0
          : (todayTotals.calories / _profile!.targetCalories).clamp(0.0, 1.5);

  // ── Init ──────────────────────────────────────────────────────────────────
  Future<void> init() async {
    await Hive.initFlutter();
    // In a full app you'd register adapters here
    // For now we use simple maps stored in boxes

    await loadProfile();
    await loadTodayLog();
    await _loadFavorites();
    await _loadRecentFoods();
  }

  // ── Profile ───────────────────────────────────────────────────────────────
  Future<void> loadProfile() async {
    try {
      final box = await Hive.openBox(_profileBox);
      final data = box.get('profile');
      if (data != null) {
        _profile = _profileFromMap(Map<String, dynamic>.from(data));
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    try {
      final box = await Hive.openBox(_profileBox);
      await box.put('profile', _profileToMap(profile));
    } catch (_) {}
    notifyListeners();
  }

  // ── Daily Log ─────────────────────────────────────────────────────────────
  Future<void> loadTodayLog({String? date}) async {
    final key = date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    _selectedDate = key;
    _isLoading = true;
    notifyListeners();

    try {
      final box = await Hive.openBox(_mealsBox);
      final raw = box.get(key);
      if (raw != null) {
        final list = (raw as List).map((e) => _mealFromMap(Map<String, dynamic>.from(e))).toList();
        final waterBox = await Hive.openBox(_waterBox);
        final water = (waterBox.get(key) ?? 0.0).toDouble();
        _todayLog = DailyLog(dateKey: key, meals: list, waterMl: water);
      } else {
        _todayLog = DailyLog(dateKey: key, meals: []);
      }
    } catch (_) {
      _todayLog = DailyLog(dateKey: key, meals: []);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMealEntry(MealEntry entry) async {
    _todayLog ??= DailyLog(dateKey: _selectedDate, meals: []);
    _todayLog!.meals.add(entry);
    await _saveTodayLog();
    await _updateRecentFood(entry.foodId, entry.foodName);
    notifyListeners();
  }

  Future<void> removeMealEntry(String entryId) async {
    _todayLog?.meals.removeWhere((m) => m.id == entryId);
    await _saveTodayLog();
    notifyListeners();
  }

  Future<void> logWater(double ml) async {
    _todayLog ??= DailyLog(dateKey: _selectedDate, meals: []);
    final box = await Hive.openBox(_waterBox);
    final current = (box.get(_selectedDate) ?? 0.0).toDouble();
    final newVal = current + ml;
    await box.put(_selectedDate, newVal);
    _todayLog = DailyLog(
      dateKey: _todayLog!.dateKey,
      meals: _todayLog!.meals,
      waterMl: newVal,
    );
    notifyListeners();
  }

  Future<void> _saveTodayLog() async {
    if (_todayLog == null) return;
    try {
      final box = await Hive.openBox(_mealsBox);
      await box.put(
        _selectedDate,
        _todayLog!.meals.map(_mealToMap).toList(),
      );
    } catch (_) {}
  }

  // ── Weekly data for charts ────────────────────────────────────────────────
  Future<List<DailyLog>> getWeeklyLogs() async {
    final logs = <DailyLog>[];
    final box = await Hive.openBox(_mealsBox);
    final waterBox = await Hive.openBox(_waterBox);
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      final raw = box.get(key);
      final meals = raw != null
          ? (raw as List).map((e) => _mealFromMap(Map<String, dynamic>.from(e))).toList()
          : <MealEntry>[];
      final water = (waterBox.get(key) ?? 0.0).toDouble();
      logs.add(DailyLog(dateKey: key, meals: meals, waterMl: water));
    }
    return logs;
  }

  // ── Favorites ─────────────────────────────────────────────────────────────
  Future<void> _loadFavorites() async {
    try {
      final box = await Hive.openBox(_foodsBox);
      final raw = box.get('favorites');
      if (raw != null) {
        _favorites = (raw as List)
            .map((e) => _foodFromMap(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {}
  }

  Future<void> toggleFavorite(FoodItem food) async {
    final exists = _favorites.any((f) => f.id == food.id);
    if (exists) {
      _favorites.removeWhere((f) => f.id == food.id);
    } else {
      _favorites.insert(0, food);
    }
    final box = await Hive.openBox(_foodsBox);
    await box.put('favorites', _favorites.map(_foodToMap).toList());
    notifyListeners();
  }

  bool isFavorite(String foodId) => _favorites.any((f) => f.id == foodId);

  // ── Recent Foods ──────────────────────────────────────────────────────────
  Future<void> _loadRecentFoods() async {
    try {
      final box = await Hive.openBox(_foodsBox);
      final raw = box.get('recents');
      if (raw != null) {
        _recentFoods = (raw as List)
            .map((e) => _foodFromMap(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {}
  }

  Future<void> _updateRecentFood(String foodId, String foodName) async {
    // Placeholder — in production lookup full FoodItem
  }

  // ── Serialization helpers ─────────────────────────────────────────────────
  Map<String, dynamic> _mealToMap(MealEntry m) => {
    'id': m.id, 'foodId': m.foodId, 'foodName': m.foodName,
    'servingGrams': m.servingGrams, 'mealType': m.mealType,
    'loggedAt': m.loggedAt.toIso8601String(),
    'calories': m.calories, 'protein': m.protein, 'carbs': m.carbs,
    'fat': m.fat, 'fiber': m.fiber, 'sugar': m.sugar, 'sodium': m.sodium,
  };

  MealEntry _mealFromMap(Map<String, dynamic> m) => MealEntry(
    id: m['id'], foodId: m['foodId'], foodName: m['foodName'],
    servingGrams: (m['servingGrams'] as num).toDouble(),
    mealType: m['mealType'], loggedAt: DateTime.parse(m['loggedAt']),
    calories: (m['calories'] as num).toDouble(),
    protein: (m['protein'] as num).toDouble(),
    carbs: (m['carbs'] as num).toDouble(),
    fat: (m['fat'] as num).toDouble(),
    fiber: (m['fiber'] as num? ?? 0).toDouble(),
    sugar: (m['sugar'] as num? ?? 0).toDouble(),
    sodium: (m['sodium'] as num? ?? 0).toDouble(),
  );

  Map<String, dynamic> _profileToMap(UserProfile p) => {
    'name': p.name, 'weightKg': p.weightKg, 'heightCm': p.heightCm,
    'ageYears': p.ageYears, 'gender': p.gender, 'activityLevel': p.activityLevel,
    'goal': p.goal, 'targetCalories': p.targetCalories, 'targetProtein': p.targetProtein,
    'targetCarbs': p.targetCarbs, 'targetFat': p.targetFat,
    'targetWaterMl': p.targetWaterMl, 'onboardingDone': p.onboardingDone,
  };

  UserProfile _profileFromMap(Map<String, dynamic> m) => UserProfile(
    name: m['name'], weightKg: (m['weightKg'] as num).toDouble(),
    heightCm: (m['heightCm'] as num).toDouble(), ageYears: m['ageYears'],
    gender: m['gender'], activityLevel: m['activityLevel'], goal: m['goal'],
    targetCalories: (m['targetCalories'] as num).toDouble(),
    targetProtein: (m['targetProtein'] as num).toDouble(),
    targetCarbs: (m['targetCarbs'] as num).toDouble(),
    targetFat: (m['targetFat'] as num).toDouble(),
    targetWaterMl: (m['targetWaterMl'] as num? ?? 2500).toDouble(),
    onboardingDone: m['onboardingDone'] ?? false,
  );

  Map<String, dynamic> _foodToMap(FoodItem f) => {
    'id': f.id, 'name': f.name, 'brand': f.brand, 'calories': f.calories,
    'protein': f.protein, 'carbs': f.carbs, 'fat': f.fat,
    'fiber': f.fiber, 'sugar': f.sugar, 'sodium': f.sodium,
    'cuisineType': f.cuisineType, 'category': f.category,
  };

  FoodItem _foodFromMap(Map<String, dynamic> f) => FoodItem(
    id: f['id'], name: f['name'], brand: f['brand'],
    calories: (f['calories'] as num).toDouble(),
    protein: (f['protein'] as num).toDouble(),
    carbs: (f['carbs'] as num).toDouble(),
    fat: (f['fat'] as num).toDouble(),
    fiber: (f['fiber'] as num? ?? 0).toDouble(),
    sugar: (f['sugar'] as num? ?? 0).toDouble(),
    sodium: (f['sodium'] as num? ?? 0).toDouble(),
    cuisineType: f['cuisineType'],
    category: f['category'],
  );
}
