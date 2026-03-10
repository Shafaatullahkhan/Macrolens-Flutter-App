# 🍽️ MacroLens — AI-Powered Food Scanner & Nutrition Coach

A complete, production-grade Flutter nutrition tracking app with barcode scanning, food search, macro tracking, weekly analytics, and a beautiful "Organic Science" UI.

---

## 📁 Complete Project Structure

```
macrolens/
├── lib/
│   ├── main.dart                          # App entry, AppShell, bottom nav
│   ├── models/
│   │   └── models.dart                    # FoodItem, MealEntry, DailyLog, UserProfile
│   ├── providers/
│   │   └── app_provider.dart              # Central state — ChangeNotifier
│   ├── services/
│   │   └── nutrition_service.dart         # Open Food Facts API + 35-item local DB
│   ├── utils/
│   │   └── app_theme.dart                 # Colors, typography, design tokens
│   ├── screens/
│   │   ├── home_screen.dart               # Dashboard — calorie ring, macro bars, meal list
│   │   ├── scan_screen.dart               # Barcode scanner + food search + regional foods
│   │   ├── diary_screen.dart              # Date-navigable food diary
│   │   ├── insights_screen.dart           # Weekly charts (bar, donut, line, water)
│   │   ├── profile_screen.dart            # User stats, targets, BMI
│   │   ├── onboarding_screen.dart         # 4-step profile setup wizard
│   │   └── other_screens.dart             # DiaryScreen, ProfileScreen, OnboardingScreen
│   └── widgets/
│       ├── macro_bar.dart                 # MacroBar, MealSectionCard, WaterTracker
│       ├── food_result_sheet.dart         # Bottom sheet — serving slider, macros, add to meal
│       └── meal_section_card.dart         # Re-export barrel
├── assets/
│   ├── images/                            # App icons, food placeholder images
│   └── lottie/                            # Optional Lottie animations
└── pubspec.yaml
```

---

## 🚀 Setup & Run

```bash
# 1. Create Flutter project
flutter create macrolens
cd macrolens

# 2. Replace all lib/ files and pubspec.yaml with provided source

# 3. Install dependencies
flutter pub get

# 4. Add camera permissions:

# Android — android/app/src/main/AndroidManifest.xml:
# <uses-permission android:name="android.permission.CAMERA"/>
# <uses-permission android:name="android.permission.INTERNET"/>

# iOS — ios/Runner/Info.plist:
# <key>NSCameraUsageDescription</key>
# <string>MacroLens needs camera access to scan barcodes</string>

# 5. Run
flutter run
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flame` | — | Not used in this app |
| `camera` | ^0.11.0+2 | Camera preview |
| `mobile_scanner` | ^5.2.3 | Barcode/QR scanning |
| `image_picker` | ^1.1.2 | Photo selection |
| `hive` + `hive_flutter` | ^2.2.3 | Local database (offline) |
| `provider` | ^6.1.2 | State management |
| `flutter_animate` | ^4.5.0 | Smooth UI animations |
| `google_fonts` | ^6.2.1 | Playfair Display + DM Sans + DM Mono |
| `fl_chart` | ^0.69.0 | Bar, line, pie charts |
| `percent_indicator` | ^4.2.3 | Circular calorie ring |
| `http` | ^1.2.2 | Open Food Facts API |
| `shared_preferences` | ^2.2.3 | Simple key/value storage |
| `intl` | ^0.19.0 | Date formatting |
| `uuid` | ^4.4.2 | Unique IDs for meal entries |

---

## 🎨 Design System — "Organic Science"

**Concept:** Warm botanical aesthetics + precise scientific data visualization

### Typography
- **Playfair Display** — Headings, food names, calorie numbers (editorial, luxurious)
- **DM Sans** — Body text, labels, descriptions (clean, readable)
- **DM Mono** — Numbers, macros, measurements (precise, scientific)

### Color Palette
| Token | Color | Use |
|---|---|---|
| Forest | `#1B4332` | Primary, headers, buttons |
| Leaf | `#2D6A4F` | Secondary, gradients |
| Sage | `#52B788` | Accents, progress bars |
| Cream | `#F8F3E9` | Background |
| Parchment | `#EEE8D5` | Cards, borders |
| Coral | `#E07A5F` | Protein, warnings |
| Amber | `#D4A017` | Carbs, carbs |
| Sky | `#6B9AB8` | Fat, hydration |
| Lavender | `#9B89B4` | Fiber |

---

## 🏠 Screen Breakdown

### 1. Home Dashboard
- **Calorie ring** — animated circular progress with green → coral color shift
- **Macro bars** — animated progress bars for Protein/Carbs/Fat/Fiber
- **Water tracker** — glass icons + quick-add buttons (150/250/350/500ml)
- **Meal sections** — collapsible breakfast/lunch/dinner/snack cards
- **Nutrition Report Card** — A/B/C/D/F grades per macro

### 2. Scan Screen (3 tabs)
- **📷 Barcode** — Live camera scanner with corner overlays, torch, flip camera
- **🔍 Search** — Search Open Food Facts (3M+ products), shows grades
- **🌍 Regional** — Offline database: 🇵🇰 Pakistani, 🇮🇳 Indian, 🌙 Arabic, 🌍 International

### 3. Food Result Sheet
- Animated bottom sheet with drag handle
- Serving size slider (10–500g) + quick presets
- Live-updating calorie + macro display
- 6-nutrient grid (protein, carbs, fat, fiber, sugar, sodium)
- Meal type selector (breakfast/lunch/dinner/snack)
- Favorite toggle
- Nutrition grade badge (A–F)

### 4. Diary
- Date picker for historical log viewing
- Daily macro summary header
- Swipe-to-delete meal entries

### 5. Weekly Insights
- **Bar chart** — 7-day calorie intake vs target line
- **Donut chart** — Average macro distribution (% calories from P/C/F)
- **Line chart** — Protein & carb trends
- **Water chart** — Animated fill bars per day
- **Week summary card** — Days tracked, avg calories, total protein, total water

### 6. Profile
- BMI + BMR + TDEE calculations (Mifflin-St Jeor)
- Daily targets display
- Activity level + goal info

### 7. Onboarding (4 screens)
1. Welcome + name input
2. Weight/height/age sliders
3. Gender + activity level
4. Goal selection (lose/maintain/gain)
- Auto-calculates all targets after completion

---

## 🌍 Regional Food Database (Offline)

**Pakistani 🇵🇰:** Biryani, Daal Chawal, Naan, Nihari, Haleem, Samosa, Lassi, Paratha, Seekh Kebab
**Indian 🇮🇳:** Palak Paneer, Idli, Masala Dosa, Chole Bhature, Raita
**Arabic 🌙:** Chicken Shawarma, Hummus, Falafel, Kabsa
**International 🌍:** Eggs, fruits, chicken, rice, oats, salmon, vegetables, legumes (20+ items)

---

## 🧮 Nutrition Calculations

**BMR (Mifflin-St Jeor):**
- Male: `10W + 6.25H - 5A + 5`
- Female: `10W + 6.25H - 5A - 161`

**TDEE:** `BMR × Activity Factor` (1.2 – 1.9)

**Targets:**
- Protein: `bodyweight × 1.8g`
- Fat: `30% of calories ÷ 9`
- Carbs: `45% of calories ÷ 4`

**Nutrition Grade Algorithm:**
- Protein >15g → +2 pts
- Fiber >5g → +2 pts
- Sugar <5g, Fat <10g, Sodium <300mg → +1 pt each
- A(7+) / B(5-6) / C(3-4) / D(1-2) / F(0)

---

## 🌐 Open Food Facts API

- **Barcode lookup:** `GET /api/v2/product/{barcode}`
- **Text search:** `GET /cgi/search.pl?search_terms=...&json=1`
- Supports 3M+ products globally
- Falls back to local database on network error
- Free, open-source, no API key required

---

*Fully offline-capable (local DB) · Open Food Facts integration · 100% Flutter*
