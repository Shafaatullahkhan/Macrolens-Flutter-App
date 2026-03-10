import 'package:hive/hive.dart';


// ─── Food Item ────────────────────────────────────────────────────────────────

@HiveType(typeId: 0)
class FoodItem extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) String? brand;
  @HiveField(3) String? barcode;
  @HiveField(4) double calories;       // per 100g
  @HiveField(5) double protein;
  @HiveField(6) double carbs;
  @HiveField(7) double fat;
  @HiveField(8) double fiber;
  @HiveField(9) double sugar;
  @HiveField(10) double sodium;        // mg per 100g
  @HiveField(11) String? imageUrl;
  @HiveField(12) String? category;
  @HiveField(13) bool isFavorite;
  @HiveField(14) DateTime? lastUsed;
  @HiveField(15) String? cuisineType;  // e.g. Pakistani, Indian, Arabic

  FoodItem({
    required this.id,
    required this.name,
    this.brand,
    this.barcode,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
    this.imageUrl,
    this.category,
    this.isFavorite = false,
    this.lastUsed,
    this.cuisineType,
  });

  // Returns nutrients scaled to servingGrams
  NutrientValues forServing(double servingGrams) {
    final factor = servingGrams / 100.0;
    return NutrientValues(
      calories: calories * factor,
      protein: protein * factor,
      carbs: carbs * factor,
      fat: fat * factor,
      fiber: fiber * factor,
      sugar: sugar * factor,
      sodium: sodium * factor,
    );
  }

  // Nutrition grade A-F
  String get nutritionGrade {
    int score = 0;
    if (protein > 15) score += 2;
    if (fiber > 5) score += 2;
    if (sugar < 5) score += 1;
    if (fat < 10) score += 1;
    if (sodium < 300) score += 1;
    if (calories < 200) score += 1;
    if (score >= 7) return 'A';
    if (score >= 5) return 'B';
    if (score >= 3) return 'C';
    if (score >= 1) return 'D';
    return 'F';
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'brand': brand,
    'calories': calories, 'protein': protein,
    'carbs': carbs, 'fat': fat, 'fiber': fiber,
    'sugar': sugar, 'sodium': sodium,
  };

  factory FoodItem.fromOpenFoodFacts(Map<String, dynamic> json) {
    final nutriments = json['nutriments'] as Map<String, dynamic>? ?? {};
    return FoodItem(
      id: json['_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['product_name'] ?? json['product_name_en'] ?? 'Unknown Food',
      brand: json['brands'],
      barcode: json['code'],
      calories: _toDouble(nutriments['energy-kcal_100g'] ?? nutriments['energy-kcal']),
      protein: _toDouble(nutriments['proteins_100g'] ?? nutriments['proteins']),
      carbs: _toDouble(nutriments['carbohydrates_100g'] ?? nutriments['carbohydrates']),
      fat: _toDouble(nutriments['fat_100g'] ?? nutriments['fat']),
      fiber: _toDouble(nutriments['fiber_100g'] ?? nutriments['fiber']),
      sugar: _toDouble(nutriments['sugars_100g'] ?? nutriments['sugars']),
      sodium: _toDouble(nutriments['sodium_100g'] ?? 0) * 1000,
      imageUrl: json['image_url'],
      category: (json['categories_tags'] as List?)?.isNotEmpty == true
          ? (json['categories_tags'] as List).first.toString().replaceAll('en:', '')
          : null,
    );
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }
}

// ─── Nutrient Values (calculated for a serving) ───────────────────────────────

class NutrientValues {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;

  const NutrientValues({
    this.calories = 0, this.protein = 0, this.carbs = 0,
    this.fat = 0, this.fiber = 0, this.sugar = 0, this.sodium = 0,
  });

  NutrientValues operator +(NutrientValues other) => NutrientValues(
    calories: calories + other.calories,
    protein: protein + other.protein,
    carbs: carbs + other.carbs,
    fat: fat + other.fat,
    fiber: fiber + other.fiber,
    sugar: sugar + other.sugar,
    sodium: sodium + other.sodium,
  );
}

// ─── Meal Entry ───────────────────────────────────────────────────────────────

@HiveType(typeId: 1)
class MealEntry extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String foodId;
  @HiveField(2) String foodName;
  @HiveField(3) double servingGrams;
  @HiveField(4) String mealType;       // breakfast, lunch, dinner, snack
  @HiveField(5) DateTime loggedAt;
  @HiveField(6) double calories;
  @HiveField(7) double protein;
  @HiveField(8) double carbs;
  @HiveField(9) double fat;
  @HiveField(10) double fiber;
  @HiveField(11) double sugar;
  @HiveField(12) double sodium;
  @HiveField(13) String? notes;

  MealEntry({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.servingGrams,
    required this.mealType,
    required this.loggedAt,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
    this.notes,
  });

  factory MealEntry.fromFood(FoodItem food, double grams, String mealType) {
    final n = food.forServing(grams);
    return MealEntry(
      id: '${food.id}_${DateTime.now().millisecondsSinceEpoch}',
      foodId: food.id,
      foodName: food.name,
      servingGrams: grams,
      mealType: mealType,
      loggedAt: DateTime.now(),
      calories: n.calories,
      protein: n.protein,
      carbs: n.carbs,
      fat: n.fat,
      fiber: n.fiber,
      sugar: n.sugar,
      sodium: n.sodium,
    );
  }
}

// ─── Daily Log ────────────────────────────────────────────────────────────────

@HiveType(typeId: 2)
class DailyLog extends HiveObject {
  @HiveField(0) String dateKey;        // 'yyyy-MM-dd'
  @HiveField(1) List<MealEntry> meals;
  @HiveField(2) double waterMl;
  @HiveField(3) String? notes;

  DailyLog({
    required this.dateKey,
    required this.meals,
    this.waterMl = 0,
    this.notes,
  });

  NutrientValues get totals => meals.fold(
    const NutrientValues(),
    (acc, m) => acc + NutrientValues(
      calories: m.calories, protein: m.protein,
      carbs: m.carbs, fat: m.fat,
      fiber: m.fiber, sugar: m.sugar, sodium: m.sodium,
    ),
  );

  Map<String, List<MealEntry>> get byMealType => {
    'breakfast': meals.where((m) => m.mealType == 'breakfast').toList(),
    'lunch': meals.where((m) => m.mealType == 'lunch').toList(),
    'dinner': meals.where((m) => m.mealType == 'dinner').toList(),
    'snack': meals.where((m) => m.mealType == 'snack').toList(),
  };
}

// ─── User Profile ─────────────────────────────────────────────────────────────

@HiveType(typeId: 3)
class UserProfile extends HiveObject {
  @HiveField(0) String name;
  @HiveField(1) double weightKg;
  @HiveField(2) double heightCm;
  @HiveField(3) int ageYears;
  @HiveField(4) String gender;           // male, female
  @HiveField(5) String activityLevel;    // sedentary, light, moderate, active, veryActive
  @HiveField(6) String goal;             // lose, maintain, gain
  @HiveField(7) double targetCalories;
  @HiveField(8) double targetProtein;
  @HiveField(9) double targetCarbs;
  @HiveField(10) double targetFat;
  @HiveField(11) double targetWaterMl;
  @HiveField(12) String? avatarPath;
  @HiveField(13) bool onboardingDone;

  UserProfile({
    required this.name,
    required this.weightKg,
    required this.heightCm,
    required this.ageYears,
    required this.gender,
    required this.activityLevel,
    required this.goal,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    this.targetWaterMl = 2500,
    this.avatarPath,
    this.onboardingDone = false,
  });

  // Calculate BMR using Mifflin-St Jeor
  double get bmr {
    if (gender == 'male') {
      return 10 * weightKg + 6.25 * heightCm - 5 * ageYears + 5;
    } else {
      return 10 * weightKg + 6.25 * heightCm - 5 * ageYears - 161;
    }
  }

  // TDEE
  double get tdee {
    const factors = {
      'sedentary': 1.2, 'light': 1.375,
      'moderate': 1.55, 'active': 1.725, 'veryActive': 1.9,
    };
    return bmr * (factors[activityLevel] ?? 1.55);
  }

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // Auto-calculate targets from TDEE + goal
  static UserProfile withAutoTargets({
    required String name, required double weightKg, required double heightCm,
    required int ageYears, required String gender, required String activityLevel,
    required String goal,
  }) {
    final p = UserProfile(
      name: name, weightKg: weightKg, heightCm: heightCm,
      ageYears: ageYears, gender: gender, activityLevel: activityLevel,
      goal: goal, targetCalories: 0, targetProtein: 0,
      targetCarbs: 0, targetFat: 0,
    );
    final base = p.tdee;
    final calTarget = goal == 'lose' ? base - 500 : goal == 'gain' ? base + 300 : base;
    return UserProfile(
      name: name, weightKg: weightKg, heightCm: heightCm, ageYears: ageYears,
      gender: gender, activityLevel: activityLevel, goal: goal,
      targetCalories: calTarget.roundToDouble(),
      targetProtein: (weightKg * 1.8).roundToDouble(),
      targetCarbs: ((calTarget * 0.45) / 4).roundToDouble(),
      targetFat: ((calTarget * 0.30) / 9).roundToDouble(),
      targetWaterMl: weightKg * 33,
      onboardingDone: true,
    );
  }
}

// ─── Meal Type Meta ───────────────────────────────────────────────────────────

class MealTypeMeta {
  static const Map<String, Map<String, dynamic>> info = {
    'breakfast': {'label': 'Breakfast', 'icon': '🌅', 'time': '6–10 AM'},
    'lunch': {'label': 'Lunch', 'icon': '☀️', 'time': '12–2 PM'},
    'dinner': {'label': 'Dinner', 'icon': '🌙', 'time': '6–9 PM'},
    'snack': {'label': 'Snack', 'icon': '🍎', 'time': 'Anytime'},
  };
}
