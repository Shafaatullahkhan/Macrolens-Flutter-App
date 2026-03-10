import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/nutrition_service.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';
import '../widgets/food_result_sheet.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final MobileScannerController _scanCtrl = MobileScannerController();
  final TextEditingController _searchCtrl = TextEditingController();

  final bool _scanning = true;
  bool _torchOn = false;
  bool _searching = false;
  bool _lookingUp = false;
  List<FoodItem> _searchResults = [];
  String _lastBarcode = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _scanCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code == _lastBarcode || _lookingUp) return;

    _lastBarcode = code;
    setState(() => _lookingUp = true);
    _scanCtrl.stop();

    final food = await NutritionService.lookupBarcode(code);
    setState(() => _lookingUp = false);

    if (mounted) {
      if (food != null) {
        _showFoodSheet(food);
      } else {
        _showNotFound(code);
      }
    }
  }

  Future<void> _searchFood(String query) async {
    if (query.trim().isEmpty) return;
    setState(() { _searching = true; _searchResults = []; });

    final results = await NutritionService.searchFood(query);
    if (mounted) setState(() { _searchResults = results; _searching = false; });
  }

  void _showFoodSheet(FoodItem food) {
    _scanCtrl.stop();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FoodResultSheet(
        food: food,
        onAdd: (entry) {
          context.read<AppProvider>().addMealEntry(entry);
          Navigator.pop(context);
          _showAddedSnack(food.name);
        },
      ),
    ).then((_) {
      _lastBarcode = '';
      if (_tabCtrl.index == 0) _scanCtrl.start();
    });
  }

  void _showNotFound(String barcode) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Not Found',
            style: GoogleFonts.playfairDisplay(color: AppColors.forest)),
        content: Text('Barcode $barcode was not found in the database.',
            style: GoogleFonts.dmSans(color: AppColors.textMid)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _lastBarcode = '';
              _scanCtrl.start();
            },
            child: Text('Try Again',
                style: GoogleFonts.dmSans(color: AppColors.forest)),
          ),
        ],
      ),
    );
  }

  void _showAddedSnack(String name) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Text('✅ '),
        Text('$name added to diary',
            style: GoogleFonts.dmSans(color: Colors.white)),
      ]),
      backgroundColor: AppColors.forest,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          _buildHeader(),

          // ── Tab Bar ───────────────────────────────────────────────────
          _buildTabBar(),

          // ── Content ───────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildScannerTab(),
                _buildSearchTab(),
                _buildLocalFoodsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.cream,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 20, right: 20, bottom: 12,
      ),
      child: Row(
        children: [
          Text('🍽️ MacroLens',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.forest)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.parchment,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabCtrl,
        indicator: BoxDecoration(
          color: AppColors.forest,
          borderRadius: BorderRadius.circular(11),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textMid,
        labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 12),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: '📷  Barcode'),
          Tab(text: '🔍  Search'),
          Tab(text: '🌍  Regional'),
        ],
      ),
    );
  }

  Widget _buildScannerTab() {
    return Stack(
      children: [
        // Scanner viewport
        ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: MobileScanner(
            controller: _scanCtrl,
            onDetect: _onBarcodeDetected,
          ),
        ),

        // Overlay
        _ScannerOverlay(),

        // Controls
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _scanBtn(
                  icon: _torchOn ? '🔦' : '💡',
                  label: 'Torch',
                  onTap: () {
                    _scanCtrl.toggleTorch();
                    setState(() => _torchOn = !_torchOn);
                  },
                ),
                const SizedBox(width: 40),
                _scanBtn(
                  icon: '🔄',
                  label: 'Flip',
                  onTap: () => _scanCtrl.switchCamera(),
                ),
              ],
            ),
          ),
        ),

        // Looking up indicator
        if (_lookingUp)
          Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.forest),
                    ),
                    const SizedBox(height: 12),
                    Text('Looking up barcode...',
                        style: GoogleFonts.dmSans(color: AppColors.textDark)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _scanBtn({required String icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.white30),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: TextField(
            controller: _searchCtrl,
            onSubmitted: _searchFood,
            style: GoogleFonts.dmSans(color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: 'Search foods, brands, dishes...',
              hintStyle: GoogleFonts.dmSans(color: AppColors.textLight),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.sage),
              suffixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(AppColors.forest),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.forest),
                      onPressed: () => _searchFood(_searchCtrl.text),
                    ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.parchment),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.parchment, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.sage, width: 2),
              ),
            ),
          ),
        ),

        // Results
        Expanded(
          child: _searchResults.isEmpty && !_searching
              ? _EmptySearchState()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _FoodListTile(
                    food: _searchResults[i],
                    onTap: () => _showFoodSheet(_searchResults[i]),
                  ).animate()
                      .fadeIn(delay: Duration(milliseconds: i * 40), duration: 300.ms)
                      .slideX(begin: 0.1),
                ),
        ),
      ],
    );
  }

  Widget _buildLocalFoodsTab() {
    final localFoods = NutritionService.localDatabase;
    final grouped = <String, List<FoodItem>>{};
    for (final f in localFoods) {
      final cuisine = f.cuisineType ?? 'International';
      grouped.putIfAbsent(cuisine, () => []).add(f);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
      children: grouped.entries.map((entry) {
        final flag = {
          'Pakistani': '🇵🇰', 'Indian': '🇮🇳',
          'Arabic': '🌙', 'International': '🌍',
        }[entry.key] ?? '🍽️';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '$flag ${entry.key} Cuisine',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.forest),
              ),
            ),
            ...entry.value.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _FoodListTile(food: f, onTap: () => _showFoodSheet(f)),
            )),
            const SizedBox(height: 4),
          ],
        );
      }).toList(),
    );
  }
}

// ─── Scanner Overlay ──────────────────────────────────────────────────────────

class _ScannerOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OverlayPainter(),
      child: Align(
        alignment: const Alignment(0, -0.2),
        child: Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.sage, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              // Corner accents
              ...[ Alignment.topLeft, Alignment.topRight,
                   Alignment.bottomLeft, Alignment.bottomRight ]
                  .map((a) => Align(alignment: a, child: _Corner(a))),
            ],
          ),
        ),
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final Alignment alignment;
  const _Corner(this.alignment);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        border: Border(
          top: alignment.y < 0 ? const BorderSide(color: AppColors.mint, width: 4) : BorderSide.none,
          bottom: alignment.y > 0 ? const BorderSide(color: AppColors.mint, width: 4) : BorderSide.none,
          left: alignment.x < 0 ? const BorderSide(color: AppColors.mint, width: 4) : BorderSide.none,
          right: alignment.x > 0 ? const BorderSide(color: AppColors.mint, width: 4) : BorderSide.none,
        ),
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;
    final center = Offset(size.width / 2, size.height * 0.38);
    const boxW = 250.0; const boxH = 250.0;
    final boxRect = Rect.fromCenter(center: center, width: boxW, height: boxH);
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()
      ..addRect(fullRect)
      ..addRRect(RRect.fromRectAndRadius(boxRect, const Radius.circular(20)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Food List Tile ───────────────────────────────────────────────────────────

class _FoodListTile extends StatelessWidget {
  final FoodItem food;
  final VoidCallback onTap;

  const _FoodListTile({required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.parchment, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.sage.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  food.cuisineType == 'Pakistani' ? '🇵🇰'
                    : food.cuisineType == 'Indian' ? '🇮🇳'
                    : food.cuisineType == 'Arabic' ? '🌙'
                    : '🍽️',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.name,
                      style: GoogleFonts.dmSans(
                          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    food.brand != null ? '${food.brand} · per 100g' : 'per 100g',
                    style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textLight),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${food.calories.round()}',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.forest)),
                Text('kcal',
                    style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textLight)),
              ],
            ),
            const SizedBox(width: 8),
            // Grade badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: _gradeColor(food.nutritionGrade).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _gradeColor(food.nutritionGrade).withOpacity(0.4)),
              ),
              child: Text(food.nutritionGrade,
                  style: GoogleFonts.dmSans(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: _gradeColor(food.nutritionGrade))),
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

class _EmptySearchState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          Text('Search for any food',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 18, color: AppColors.forest, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Over 3 million foods from Open Food Facts',
              style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textLight)),
        ],
      ),
    );
  }
}
