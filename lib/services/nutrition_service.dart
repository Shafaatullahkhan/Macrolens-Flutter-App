import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class NutritionService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2';
  static const String _searchUrl = 'https://world.openfoodfacts.org/cgi/search.pl';

  // ── Barcode Lookup ────────────────────────────────────────────────────────
  static Future<FoodItem?> lookupBarcode(String barcode) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/product/$barcode?fields=product_name,brands,nutriments,image_url,categories_tags,code'),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 1 && data['product'] != null) {
          return FoodItem.fromOpenFoodFacts(data['product']);
        }
      }
    } catch (_) {}
    return null;
  }

  // ── Text Search ───────────────────────────────────────────────────────────
  static Future<List<FoodItem>> searchFood(String query, {int page = 1}) async {
    try {
      final uri = Uri.parse(_searchUrl).replace(queryParameters: {
        'search_terms': query,
        'search_simple': '1',
        'action': 'process',
        'json': '1',
        'page': '$page',
        'page_size': '20',
        'fields': 'product_name,brands,nutriments,image_url,categories_tags,code,_id',
      });

      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final products = data['products'] as List? ?? [];
        return products
            .map((p) => FoodItem.fromOpenFoodFacts(p))
            .where((f) => f.name.isNotEmpty && f.calories > 0)
            .toList();
      }
    } catch (_) {}
    // Fallback to local DB on network error
    return _localFoodDatabase
        .where((f) => f.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // ── Local Offline Database (regional foods) ───────────────────────────────
  static List<FoodItem> get localDatabase => _localFoodDatabase;

  static List<FoodItem> searchLocal(String query) => _localFoodDatabase
      .where((f) =>
          f.name.toLowerCase().contains(query.toLowerCase()) ||
          (f.cuisineType?.toLowerCase().contains(query.toLowerCase()) ?? false))
      .toList();

  static final List<FoodItem> _localFoodDatabase = [
    // ── Pakistani Foods ──────────────────────────────────────────────────
    FoodItem(id: 'pk_biryani', name: 'Chicken Biryani', brand: 'Pakistani',
        calories: 195, protein: 11, carbs: 24, fat: 5.5, fiber: 1.2, sugar: 1.5, sodium: 450,
        category: 'Main Course', cuisineType: 'Pakistani'),
    FoodItem(id: 'pk_daal', name: 'Daal Chawal', brand: 'Pakistani',
        calories: 130, protein: 7, carbs: 22, fat: 2.5, fiber: 4, sugar: 1, sodium: 280,
        category: 'Main Course', cuisineType: 'Pakistani'),
    FoodItem(id: 'pk_naan', name: 'Naan Bread', brand: 'Pakistani',
        calories: 290, protein: 9, carbs: 50, fat: 6, fiber: 2, sugar: 3, sodium: 380,
        category: 'Bread', cuisineType: 'Pakistani'),
    FoodItem(id: 'pk_nihari', name: 'Nihari', brand: 'Pakistani',
        calories: 220, protein: 18, carbs: 8, fat: 14, fiber: 1, sugar: 2, sodium: 520,
        category: 'Main Course', cuisineType: 'Pakistani'),
    FoodItem(id: 'pk_haleem', name: 'Haleem', brand: 'Pakistani',
        calories: 180, protein: 14, carbs: 18, fat: 5, fiber: 3, sugar: 1, sodium: 400,
        category: 'Main Course', cuisineType: 'Pakistani'),
    FoodItem(id: 'pk_samosa', name: 'Samosa (2 pcs)', brand: 'Pakistani',
        calories: 260, protein: 6, carbs: 32, fat: 13, fiber: 2, sugar: 2, sodium: 480,
        category: 'Snack', cuisineType: 'Pakistani'),
    FoodItem(id: 'pk_lassi', name: 'Sweet Lassi', brand: 'Pakistani',
        calories: 150, protein: 5, carbs: 24, fat: 4, fiber: 0, sugar: 20, sodium: 80,
        category: 'Beverage', cuisineType: 'Pakistani'),
    FoodItem(id: 'pk_paratha', name: 'Aloo Paratha', brand: 'Pakistani',
        calories: 310, protein: 7, carbs: 44, fat: 12, fiber: 3, sugar: 2, sodium: 420,
        category: 'Bread', cuisineType: 'Pakistani'),
    FoodItem(id: 'pk_kebab', name: 'Seekh Kebab (2 pcs)', brand: 'Pakistani',
        calories: 200, protein: 20, carbs: 5, fat: 12, fiber: 0.5, sugar: 1, sodium: 520,
        category: 'Protein', cuisineType: 'Pakistani'),

    // ── Indian Foods ─────────────────────────────────────────────────────
    FoodItem(id: 'in_palak_paneer', name: 'Palak Paneer', brand: 'Indian',
        calories: 170, protein: 9, carbs: 8, fat: 12, fiber: 2, sugar: 3, sodium: 350,
        category: 'Main Course', cuisineType: 'Indian'),
    FoodItem(id: 'in_idli', name: 'Idli (2 pcs)', brand: 'Indian',
        calories: 130, protein: 4, carbs: 28, fat: 0.5, fiber: 1, sugar: 0.5, sodium: 200,
        category: 'Breakfast', cuisineType: 'Indian'),
    FoodItem(id: 'in_masala_dosa', name: 'Masala Dosa', brand: 'Indian',
        calories: 220, protein: 5, carbs: 38, fat: 6, fiber: 2, sugar: 2, sodium: 320,
        category: 'Breakfast', cuisineType: 'Indian'),
    FoodItem(id: 'in_chole', name: 'Chole Bhature', brand: 'Indian',
        calories: 380, protein: 12, carbs: 52, fat: 14, fiber: 8, sugar: 4, sodium: 560,
        category: 'Main Course', cuisineType: 'Indian'),
    FoodItem(id: 'in_raita', name: 'Raita', brand: 'Indian',
        calories: 80, protein: 4, carbs: 8, fat: 3, fiber: 0.5, sugar: 7, sodium: 120,
        category: 'Side', cuisineType: 'Indian'),

    // ── Arabic Foods ─────────────────────────────────────────────────────
    FoodItem(id: 'ar_shawarma', name: 'Chicken Shawarma', brand: 'Arabic',
        calories: 290, protein: 22, carbs: 30, fat: 8, fiber: 2, sugar: 3, sodium: 650,
        category: 'Main Course', cuisineType: 'Arabic'),
    FoodItem(id: 'ar_hummus', name: 'Hummus (100g)', brand: 'Arabic',
        calories: 166, protein: 8, carbs: 14, fat: 9.5, fiber: 6, sugar: 0.5, sodium: 400,
        category: 'Dip', cuisineType: 'Arabic'),
    FoodItem(id: 'ar_falafel', name: 'Falafel (4 pcs)', brand: 'Arabic',
        calories: 280, protein: 12, carbs: 30, fat: 14, fiber: 5, sugar: 2, sodium: 480,
        category: 'Snack', cuisineType: 'Arabic'),
    FoodItem(id: 'ar_kabsa', name: 'Kabsa', brand: 'Arabic',
        calories: 230, protein: 14, carbs: 28, fat: 7, fiber: 2, sugar: 2, sodium: 520,
        category: 'Main Course', cuisineType: 'Arabic'),

    // ── Universal Basics ──────────────────────────────────────────────────
    FoodItem(id: 'egg_boiled', name: 'Boiled Egg', calories: 155, protein: 13,
        carbs: 1.1, fat: 11, fiber: 0, sugar: 1.1, sodium: 124),
    FoodItem(id: 'banana', name: 'Banana', calories: 89, protein: 1.1,
        carbs: 23, fat: 0.3, fiber: 2.6, sugar: 12, sodium: 1),
    FoodItem(id: 'apple', name: 'Apple', calories: 52, protein: 0.3,
        carbs: 14, fat: 0.2, fiber: 2.4, sugar: 10, sodium: 1),
    FoodItem(id: 'chicken_breast', name: 'Chicken Breast (grilled)', calories: 165,
        protein: 31, carbs: 0, fat: 3.6, fiber: 0, sugar: 0, sodium: 74),
    FoodItem(id: 'white_rice', name: 'White Rice (cooked)', calories: 130,
        protein: 2.7, carbs: 28, fat: 0.3, fiber: 0.4, sugar: 0, sodium: 1),
    FoodItem(id: 'brown_rice', name: 'Brown Rice (cooked)', calories: 112,
        protein: 2.6, carbs: 24, fat: 0.9, fiber: 1.8, sugar: 0.4, sodium: 5),
    FoodItem(id: 'oats', name: 'Rolled Oats', calories: 389, protein: 17,
        carbs: 66, fat: 7, fiber: 10.6, sugar: 1, sodium: 2),
    FoodItem(id: 'whole_milk', name: 'Whole Milk', calories: 61, protein: 3.2,
        carbs: 4.8, fat: 3.3, fiber: 0, sugar: 5, sodium: 43),
    FoodItem(id: 'greek_yogurt', name: 'Greek Yogurt (plain)', calories: 59,
        protein: 10, carbs: 3.6, fat: 0.4, fiber: 0, sugar: 3.2, sodium: 36),
    FoodItem(id: 'almonds', name: 'Almonds', calories: 579, protein: 21,
        carbs: 22, fat: 50, fiber: 12.5, sugar: 4, sodium: 1),
    FoodItem(id: 'salmon', name: 'Salmon (baked)', calories: 208, protein: 20,
        carbs: 0, fat: 13, fiber: 0, sugar: 0, sodium: 59),
    FoodItem(id: 'broccoli', name: 'Broccoli', calories: 34, protein: 2.8,
        carbs: 7, fat: 0.4, fiber: 2.6, sugar: 1.7, sodium: 33),
    FoodItem(id: 'sweet_potato', name: 'Sweet Potato', calories: 86, protein: 1.6,
        carbs: 20, fat: 0.1, fiber: 3, sugar: 4, sodium: 55),
    FoodItem(id: 'avocado', name: 'Avocado', calories: 160, protein: 2,
        carbs: 9, fat: 15, fiber: 7, sugar: 0.7, sodium: 7),
    FoodItem(id: 'whole_wheat_bread', name: 'Whole Wheat Bread', calories: 247,
        protein: 13, carbs: 41, fat: 3.4, fiber: 6, sugar: 6, sodium: 400),
    FoodItem(id: 'lentils', name: 'Lentils (cooked)', calories: 116, protein: 9,
        carbs: 20, fat: 0.4, fiber: 7.9, sugar: 1.8, sodium: 2),
  ];
}
