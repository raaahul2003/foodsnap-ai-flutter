import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  DESIGN TOKENS  (matches full app _DS)                                  ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class _DS {
  static const bg          = Color(0xFF050D0A);
  static const bgCard      = Color(0xFF0C1A13);
  static const surface     = Color(0xFF0F2018);
  static const neon        = Color(0xFF00FF88);
  static const neonDim     = Color(0xFF00C46A);
  static const neonFaint   = Color(0xFF003D22);
  static const accent1     = Color(0xFF00E5FF);
  static const accent2     = Color(0xFFB2FF59);
  static const accent3     = Color(0xFFFF6B6B);
  static const accent4     = Color(0xFFFFD166);
  static const accent5     = Color(0xFFA78BFA);
  static const textPrimary   = Color(0xFFF0FFF8);
  static const textSecondary = Color(0xFF6EE7B7);
  static const textMuted     = Color(0xFF2E6B4A);
  static const borderFaint   = Color(0xFF1A3D2A);

  static Color  scoreColor(int s) => s >= 70 ? neon   : s >= 40 ? accent4 : accent3;
  static String scoreLabel(int s) => s >= 70 ? "SAFE" : s >= 40 ? "MODERATE RISK" : "HIGH RISK";
  static IconData scoreIcon(int s) =>
      s >= 70 ? Icons.verified_rounded
          : s >= 40 ? Icons.warning_amber_rounded
          : Icons.dangerous_rounded;
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  MODELS                                                                 ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class _ProfileChip {
  final String   label;
  final IconData icon;
  final Color    color;
  const _ProfileChip(this.label, this.icon, this.color);
}

class _HealthProfile {
  final String bmiCategory;
  final bool   hasHighBP;
  final bool   hasDiabetes;
  final bool   hasHighCholesterol;
  final String goalMode;

  const _HealthProfile({
    this.bmiCategory        = "Normal BMI",
    this.hasHighBP          = false,
    this.hasDiabetes        = false,
    this.hasHighCholesterol = false,
    this.goalMode           = "balanced",
  });

  List<_ProfileChip> get chips {
    final list = <_ProfileChip>[
      _ProfileChip(bmiCategory, Icons.monitor_weight_rounded, _DS.neon),
    ];
    if (hasHighBP)          list.add(_ProfileChip("High BP",      Icons.favorite_rounded,        _DS.accent3));
    if (hasDiabetes)        list.add(_ProfileChip("Diabetes",     Icons.bloodtype_rounded,        _DS.accent4));
    if (hasHighCholesterol) list.add(_ProfileChip("Cholesterol",  Icons.science_rounded,          _DS.accent1));
    switch (goalMode) {
      case 'weight_gain': list.add(_ProfileChip("Weight Gain",    Icons.trending_up_rounded,      _DS.accent2)); break;
      case 'fat_loss':    list.add(_ProfileChip("Fat Loss",       Icons.local_fire_department,    _DS.accent3)); break;
      case 'diabetic':    list.add(_ProfileChip("Diabetic Plan",  Icons.medical_services_rounded, _DS.accent1)); break;
      default:            list.add(_ProfileChip("Balanced",       Icons.balance_rounded,          _DS.neon));
    }
    return list;
  }
}

class _FlaggedItem {
  final String name;
  final bool   harmful;
  final String reason;
  const _FlaggedItem({required this.name, required this.harmful, required this.reason});
}

class _RiskCard {
  final String   category;
  final String   level;     // Low / Medium / High
  final String   explanation;
  final IconData icon;
  final Color    color;
  const _RiskCard({
    required this.category, required this.level,
    required this.explanation, required this.icon, required this.color,
  });
}

class _HistoryEntry {
  final String   label;
  final int      score;
  final DateTime time;
  const _HistoryEntry({required this.label, required this.score, required this.time});
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  SCREEN                                                                 ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class IngredientAIScreen extends StatefulWidget {
  const IngredientAIScreen({super.key});

  @override
  State<IngredientAIScreen> createState() => _IngredientAIScreenState();
}

class _IngredientAIScreenState extends State<IngredientAIScreen>
    with TickerProviderStateMixin {

  // ── EXISTING state (unchanged variable names) ────────────────────────────
  File?  _image;
  String extractedText = "";
  String aiResult      = "";
  bool   loading       = false;
  String userGoalMode  = "General";

  // ── New result state ──────────────────────────────────────────────────────
  bool   _hasResult            = false;
  int    _safetyScore          = 0;
  int    _loadingStep          = 0;
  _HealthProfile _profile      = const _HealthProfile();
  List<_FlaggedItem>  _flagged      = [];
  List<String>        _warnings     = [];
  List<String>        _alternatives = [];
  List<_RiskCard>     _riskCards    = [];
  List<_HistoryEntry> _history      = [];

  static const _steps = [
    "Reading ingredients…",
    "Extracting text using AI…",
    "Comparing with your health profile…",
    "Calculating safety score…",
  ];

  // ── Animation controllers ─────────────────────────────────────────────────
  late AnimationController _entryCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _scanCtrl;
  late AnimationController _scoreCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _stepCtrl;

  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _glowAnim;
  late Animation<double> _scanAnim;
  late Animation<double> _scoreAnim;
  late Animation<double> _pulseAnim;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Entry
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: 28.0, end: 0.0).animate(
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    // Ambient glow
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.18, end: 0.72).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    // Animated scan border
    _scanCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat();
    _scanAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _scanCtrl, curve: Curves.linear));

    // Score ring fill
    _scoreCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _scoreAnim = CurvedAnimation(parent: _scoreCtrl, curve: Curves.easeOutCubic);

    // Pulse for idle orb
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Step ticker (for loading animation)
    _stepCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    _entryCtrl.forward();
    _loadHealthProfile();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _glowCtrl.dispose();
    _scanCtrl.dispose();
    _scoreCtrl.dispose();
    _pulseCtrl.dispose();
    _stepCtrl.dispose();
    super.dispose();
  }

  // ── Load health profile from SharedPreferences + API ─────────────────────
  Future<void> _loadHealthProfile() async {
    final prefs   = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString('url') ?? '';
    final lid     = prefs.getString('lid') ?? '';

    // Read goal_mode immediately (fast)
    final gm = prefs.getString('goal_mode') ?? prefs.getString('h') ?? 'balanced';
    setState(() { userGoalMode = gm; });

    if (baseUrl.isEmpty || lid.isEmpty) return;

    try {
      final resp = await http.post(
          Uri.parse('$baseUrl/userviewhishealth/'), body: {'lid': lid});
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['status'] == 'ok') {
          final bmi = double.tryParse(data['bmi']?.toString() ?? '22') ?? 22.0;
          setState(() {
            userGoalMode = data['goal_mode']?.toString() ?? gm;
            _profile = _HealthProfile(
              bmiCategory:        _bmiCat(bmi),
              hasHighBP:          (data['has_high_bp']?.toString() ?? 'no') == 'yes',
              hasDiabetes:        (data['has_diabetes']?.toString() ?? 'no') == 'yes',
              hasHighCholesterol: (data['has_cholesterol']?.toString() ?? 'no') == 'yes',
              goalMode:           data['goal_mode']?.toString() ?? gm,
            );
          });
        }
      }
    } catch (_) {}
  }

  String _bmiCat(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25)   return "Normal BMI";
    if (bmi < 30)   return "Overweight";
    return "Obese";
  }

  // ╔══════════════════════════════════════════════════════════════════════╗
  // ║  EXISTING BACKEND METHODS (UNCHANGED)                               ║
  // ╚══════════════════════════════════════════════════════════════════════╝
  Future<void> pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(source: source, imageQuality: 82);
    if (file == null) return;

    setState(() {
      _image        = File(file.path);
      extractedText = "";
      aiResult      = "";
      loading       = true;
      _hasResult    = false;
      _loadingStep  = 0;
    });

    await extractText(_image!);
  }

  Future<void> extractText(File imageFile) async {
    _setStep(0);
    final inputImage     = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognized = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    _setStep(1);
    extractedText = recognized.text.trim();

    if (extractedText.isEmpty) {
      setState(() {
        extractedText = "No text could be detected in the image.";
        loading       = false;
      });
      return;
    }

    await analyzeIngredients(extractedText);
  }

  Future<void> analyzeIngredients(String ingredients) async {
    _setStep(2);
    try {
      final prefs   = await SharedPreferences.getInstance();
      final baseUrl = prefs.getString("url") ?? "http://127.0.0.1:8000";
      final lid     = prefs.getString("lid") ?? "";

      _setStep(3);
      final response = await http.post(
        Uri.parse("$baseUrl/analyze_ingredients/"),
        body: {"ingredients": ingredients, "lid": lid},
      );

      final data = jsonDecode(response.body);

      if (data["status"] == "ok") {
        setState(() {
          aiResult   = data["analysis"]?.toString() ?? "";
          loading    = false;
          _hasResult = true;
        });
        _parseAndBuildResult(data);
      } else {
        setState(() {
          aiResult = "Analysis error: ${data["message"] ?? "Unknown error"}";
          loading  = false;
        });
      }
    } catch (e) {
      setState(() {
        aiResult = "Connection error. Please try again.";
        loading  = false;
      });
    }
  }

  void _setStep(int step) =>
      setState(() => _loadingStep = step.clamp(0, _steps.length - 1));

  // ── Parse structured backend response + fallback inference ───────────────
  void _parseAndBuildResult(Map<String, dynamic> data) {
    // Score
    final score = int.tryParse(data['overallSafetyScore']?.toString() ?? '')
        ?? _inferScore();

    // Flagged ingredients
    final flagged = <_FlaggedItem>[];
    if (data['flaggedIngredients'] is List) {
      for (final it in (data['flaggedIngredients'] as List)) {
        if (it is Map) {
          flagged.add(_FlaggedItem(
            name:    it['name']?.toString() ?? '',
            harmful: it['harmful'] != false,
            reason:  it['reason']?.toString() ?? '',
          ));
        }
      }
    }
    if (flagged.isEmpty) flagged.addAll(_inferFlagged());

    // Warnings
    final warnings = <String>[];
    if (data['personalizedWarnings'] is List)
      for (final w in data['personalizedWarnings'] as List) warnings.add(w.toString());
    if (warnings.isEmpty) warnings.addAll(_buildWarnings());

    // Alternatives
    final alts = <String>[];
    if (data['saferAlternatives'] is List)
      for (final a in data['saferAlternatives'] as List) alts.add(a.toString());
    if (alts.isEmpty) alts.addAll(_buildAlts());

    // History
    final entry = _HistoryEntry(
      label: "Scan ${_history.length + 1}",
      score: score,
      time:  DateTime.now(),
    );

    setState(() {
      _safetyScore  = score;
      _flagged      = flagged;
      _warnings     = warnings;
      _alternatives = alts;
      _riskCards    = _buildRiskCards();
      _history      = [entry, ..._history];
    });
    _scoreCtrl.forward(from: 0);
  }

  // ── Inference helpers ─────────────────────────────────────────────────────
  int _inferScore() {
    final r = aiResult.toLowerCase();
    if (r.contains("safe")    || r.contains("good"))     return 82;
    if (r.contains("moderate")|| r.contains("caution"))  return 52;
    if (r.contains("harmful") || r.contains("high risk")) return 24;
    return 58;
  }

  List<_FlaggedItem> _inferFlagged() {
    final r = aiResult.toLowerCase();
    final out = <_FlaggedItem>[];
    if (r.contains("sodium") || r.contains("salt"))
      out.add(const _FlaggedItem(name: "High Sodium",    harmful: true,  reason: "Elevated sodium may worsen hypertension & cause water retention"));
    if (r.contains("sugar")  || r.contains("glucose") || r.contains("fructose"))
      out.add(const _FlaggedItem(name: "Added Sugar",    harmful: true,  reason: "Risk for elevated blood sugar, insulin resistance & weight gain"));
    if (r.contains("trans fat") || r.contains("hydrogenated"))
      out.add(const _FlaggedItem(name: "Trans Fat",      harmful: true,  reason: "Raises LDL cholesterol, harmful for cardiovascular health"));
    if (r.contains("preservative") || r.contains("benzoate") || r.contains("nitrate"))
      out.add(const _FlaggedItem(name: "Preservatives",  harmful: true,  reason: "Artificial additives linked to inflammation & gut health issues"));
    if (r.contains("whole grain") || r.contains("oat"))
      out.add(const _FlaggedItem(name: "Whole Grain",    harmful: false, reason: "Excellent fiber source supporting digestive & heart health"));
    if (r.contains("vitamin") || r.contains("mineral"))
      out.add(const _FlaggedItem(name: "Vitamins & Minerals", harmful: false, reason: "Contributes positively to daily micronutrient requirements"));
    if (r.contains("protein") || r.contains("amino"))
      out.add(const _FlaggedItem(name: "Protein",        harmful: false, reason: "Supports muscle maintenance and satiety"));
    return out;
  }

  List<String> _buildWarnings() {
    final w = <String>[];
    if (_profile.hasHighBP)
      w.add("High Sodium detected — Not recommended for High Blood Pressure");
    if (_profile.hasDiabetes)
      w.add("Added Sugar detected — Risk for elevated blood glucose levels");
    if (_profile.hasHighCholesterol)
      w.add("Trans Fat detected — Significantly raises LDL cholesterol");
    if (_profile.goalMode == 'fat_loss')
      w.add("High calorie density — May hinder your fat loss progress");
    if (_profile.goalMode == 'weight_gain')
      w.add("Low calorie content — May not support your weight gain goal");
    if (w.isEmpty) w.add("No major conflicts with your health profile detected");
    return w;
  }

  List<String> _buildAlts() {
    if (_profile.hasDiabetes)
      return ["Unsweetened oat milk", "Stevia-sweetened dark chocolate", "Whole grain crackers (no added sugar)"];
    if (_profile.hasHighBP)
      return ["Low-sodium vegetable chips", "Unsalted mixed nuts", "Fresh fruit with no added salt"];
    if (_profile.hasHighCholesterol)
      return ["Oat-based cereals with no palm oil", "Avocado-based spreads", "Olive oil products"];
    if (_profile.goalMode == 'fat_loss')
      return ["Air-popped popcorn (no butter)", "Low-calorie protein bars", "Raw vegetable sticks with hummus"];
    return ["Whole grain alternatives", "Low-sugar natural variants", "Products with <5 ingredients"];
  }

  List<_RiskCard> _buildRiskCards() {
    final r = aiResult.toLowerCase();
    String lvl(bool high, bool med) => high ? "High" : med ? "Medium" : "Low";
    Color  clr(bool high, bool med) => high ? _DS.accent3 : med ? _DS.accent4 : _DS.neon;

    final sugarHigh = (r.contains("sugar") || r.contains("fructose")) && _profile.hasDiabetes;
    final sugarMed  = r.contains("sugar") || r.contains("fructose");
    final sodHigh   = (r.contains("sodium") || r.contains("salt")) && _profile.hasHighBP;
    final sodMed    = r.contains("sodium") || r.contains("salt");
    final fatHigh   = r.contains("trans fat") || r.contains("hydrogenated");
    final fatMed    = r.contains("saturated");
    final presHigh  = r.contains("sodium benzoate") || r.contains("bha") || r.contains("bht");
    final presMed   = r.contains("preservative") || r.contains("artificial");

    return [
      _RiskCard(
        category:    "Sugar Risk",
        level:       lvl(sugarHigh, sugarMed),
        explanation: _profile.hasDiabetes
            ? "High sugar is critical for diabetics — monitor intake closely"
            : "Excess sugar links to weight gain and metabolic disorders",
        icon:  Icons.water_drop_rounded,
        color: clr(sugarHigh, sugarMed),
      ),
      _RiskCard(
        category:    "Sodium Risk",
        level:       lvl(sodHigh, sodMed),
        explanation: _profile.hasHighBP
            ? "Sodium directly elevates blood pressure in hypertensive patients"
            : "Keep daily sodium under 2,300mg for optimal heart health",
        icon:  Icons.grain_rounded,
        color: clr(sodHigh, sodMed),
      ),
      _RiskCard(
        category:    "Fat Risk",
        level:       lvl(fatHigh, fatMed),
        explanation: _profile.hasHighCholesterol
            ? "Trans fats significantly raise LDL — avoid entirely"
            : "Prefer unsaturated fats; limit saturated to <10% daily calories",
        icon:  Icons.opacity_rounded,
        color: clr(fatHigh, fatMed),
      ),
      _RiskCard(
        category:    "Preservative Risk",
        level:       lvl(presHigh, presMed),
        explanation: "BHA, BHT & sodium benzoate may cause oxidative stress with long-term consumption",
        icon:  Icons.science_rounded,
        color: clr(presHigh, presMed),
      ),
    ];
  }

  // ── Source picker ─────────────────────────────────────────────────────────
  void _showImageSourceDialog() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SourceSheet(
        onCamera:  () { Navigator.pop(context); pickImage(ImageSource.camera); },
        onGallery: () { Navigator.pop(context); pickImage(ImageSource.gallery); },
      ),
    );
  }

  // ╔══════════════════════════════════════════════════════════════════════╗
  // ║  BUILD                                                              ║
  // ╚══════════════════════════════════════════════════════════════════════╝
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _DS.bg,
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _entryCtrl,
            builder: (_, child) => Opacity(
              opacity: _fadeAnim.value,
              child: Transform.translate(offset: Offset(0, _slideAnim.value), child: child),
            ),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── App bar
                SliverToBoxAdapter(child: _buildAppBar()),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([

                      // 1. Profile chips
                      _buildProfileHeader(),
                      const SizedBox(height: 18),

                      // 2. Scan card
                      _buildScanCard(),
                      const SizedBox(height: 18),

                      // 3. Loading
                      if (loading) ...[_buildLoadingState(), const SizedBox(height: 18)],

                      // 4. Result panel
                      if (_hasResult && !loading) ...[
                        _buildScoreRing(),
                        const SizedBox(height: 16),
                        _buildExplainableAI(),
                        const SizedBox(height: 16),
                        _buildWarningsCard(),
                        const SizedBox(height: 16),
                        _buildRiskGrid(),
                        const SizedBox(height: 16),
                        _buildAlternatives(),
                        const SizedBox(height: 16),
                      ],

                      // 6. How it works (idle)
                      if (!_hasResult && !loading) ...[
                        _buildHowItWorks(),
                        const SizedBox(height: 16),
                      ],

                      // 5. History
                      if (_history.isNotEmpty) ...[
                        _buildHistory(),
                        const SizedBox(height: 16),
                      ],

                      // 8. Disclaimer
                      _buildDisclaimer(),
                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _DS.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _DS.borderFaint, width: 1),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: _DS.neon, size: 16),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("SafeBite Scanner",
                style: TextStyle(color: _DS.textPrimary, fontSize: 17,
                    fontWeight: FontWeight.w900, letterSpacing: -0.3)),
            Text("Analyzing based on your health profile",
                style: TextStyle(color: _DS.textMuted, fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ],
        )),
        AnimatedBuilder(
          animation: _glowAnim,
          builder: (_, __) => Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _DS.neonFaint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _DS.neon.withOpacity(0.3), width: 1),
              boxShadow: [BoxShadow(
                  color: _DS.neon.withOpacity(_glowAnim.value * 0.25),
                  blurRadius: 14)],
            ),
            child: const Icon(Icons.biotech_rounded, color: _DS.neon, size: 18),
          ),
        ),
      ]),
    );
  }

  // ── 1. Profile header ─────────────────────────────────────────────────────
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _DS.neon.withOpacity(0.14), width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: _DS.neon.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.person_rounded, color: _DS.neon, size: 15),
          ),
          const SizedBox(width: 9),
          Text("Your Health Profile",
              style: TextStyle(color: _DS.textPrimary, fontSize: 13, fontWeight: FontWeight.w800)),
          const Spacer(),
          _activePill(),
        ]),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _profile.chips.map((c) => _chip(c.label, c.icon, c.color)).toList(),
        ),
      ]),
    );
  }

  Widget _activePill() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: _DS.neon.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _DS.neon.withOpacity(0.2), width: 1),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 5, height: 5,
          decoration: const BoxDecoration(color: _DS.neon, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text("Live", style: TextStyle(color: _DS.neon, fontSize: 9, fontWeight: FontWeight.w800)),
    ]),
  );

  Widget _chip(String label, IconData icon, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.22), width: 1),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 11, color: color),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    ]),
  );

  // ── 2. Scan card ──────────────────────────────────────────────────────────
  Widget _buildScanCard() {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnim, _scanAnim, _pulseAnim]),
      builder: (_, __) => Stack(children: [
        // Main card
        Container(
          decoration: BoxDecoration(
            color: _DS.bgCard,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: _DS.neon.withOpacity(0.22), width: 1.2),
            boxShadow: [BoxShadow(
                color: _DS.neon.withOpacity(_glowAnim.value * 0.16),
                blurRadius: 24, offset: const Offset(0, 6))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Column(children: [
              // ── Image area
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: SizedBox(
                  height: _image == null ? 190 : 260,
                  width: double.infinity,
                  child: _image == null
                      ? _scanIdlePlaceholder()
                      : Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
                ),
              ),

              // ── Action row
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Expanded(child: _actionBtn(
                      "Camera", Icons.camera_enhance_rounded, _DS.neon,
                          () => pickImage(ImageSource.camera))),
                  const SizedBox(width: 12),
                  Expanded(child: _actionBtn(
                      "Gallery", Icons.photo_library_rounded, _DS.accent1,
                          () => pickImage(ImageSource.gallery))),
                ]),
              ),
            ]),
          ),
        ),

        // Animated corner brackets overlay (idle only)
        if (!_hasResult)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _CornerBracketPainter(
                  progress: _scanAnim.value,
                  color:    _DS.neon.withOpacity(0.45),
                  radius:   26,
                ),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _scanIdlePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_DS.neonFaint.withOpacity(0.5), _DS.surface.withOpacity(0.3)],
        ),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, __) => Transform.scale(
            scale: _pulseAnim.value,
            child: AnimatedBuilder(
              animation: _glowAnim,
              builder: (_, __) => Container(
                width: 76, height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _DS.neonFaint,
                  border: Border.all(color: _DS.neon.withOpacity(0.55), width: 1.5),
                  boxShadow: [BoxShadow(
                      color: _DS.neon.withOpacity(_glowAnim.value * 0.5),
                      blurRadius: 22, spreadRadius: 2)],
                ),
                child: const Center(
                    child: Icon(Icons.document_scanner_rounded, color: _DS.neon, size: 32)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text("Scan Ingredient List",
            style: TextStyle(color: _DS.textPrimary, fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text("AI detects harmful ingredients for YOU",
            style: TextStyle(color: _DS.textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onTap(); },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: color.withOpacity(0.28), width: 1.2),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 7),
          Text(label,
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  // ── 3. Loading state ──────────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _DS.neon.withOpacity(0.18), width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
                color: _DS.neon, strokeWidth: 2.5,
                backgroundColor: _DS.neonFaint),
          ),
          const SizedBox(width: 12),
          Text("AI Analysis in Progress",
              style: TextStyle(color: _DS.textPrimary, fontSize: 14, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 18),
        ...List.generate(_steps.length, (i) {
          final done    = i < _loadingStep;
          final current = i == _loadingStep;
          final color   = done ? _DS.neon : current ? _DS.accent1 : _DS.textMuted;
          return Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? _DS.neon : current ? _DS.accent1.withOpacity(0.15) : _DS.surface,
                  border: Border.all(color: color, width: 1.5),
                ),
                child: done
                    ? const Icon(Icons.check_rounded, color: _DS.bg, size: 13)
                    : current
                    ? Padding(
                    padding: const EdgeInsets.all(4),
                    child: CircularProgressIndicator(
                        color: _DS.accent1, strokeWidth: 2))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(_steps[i],
                  style: TextStyle(
                      color: color, fontSize: 13,
                      fontWeight: current ? FontWeight.w700 : FontWeight.w500))),
            ]),
          );
        }),
      ]),
    );
  }

  // ── 4A. Safety score ring ─────────────────────────────────────────────────
  Widget _buildScoreRing() {
    final color = _DS.scoreColor(_safetyScore);
    final label = _DS.scoreLabel(_safetyScore);

    return AnimatedBuilder(
      animation: Listenable.merge([_scoreAnim, _glowAnim]),
      builder: (_, __) {
        final animated = (_safetyScore * _scoreAnim.value).round();
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _DS.bgCard,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: color.withOpacity(0.28), width: 1.2),
            boxShadow: [BoxShadow(
                color: color.withOpacity(_glowAnim.value * 0.2),
                blurRadius: 30, offset: const Offset(0, 6))],
          ),
          child: Column(children: [
            // Ring
            SizedBox(
              width: 148, height: 148,
              child: Stack(alignment: Alignment.center, children: [
                // Track
                SizedBox(
                  width: 148, height: 148,
                  child: CircularProgressIndicator(
                    value: (animated / 100).clamp(0.0, 1.0),
                    strokeWidth: 13,
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(color),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Center text
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text("$animated",
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900,
                          color: color, letterSpacing: -2.0)),
                  Text("/ 100",
                      style: TextStyle(fontSize: 12, color: _DS.textMuted,
                          fontWeight: FontWeight.w500)),
                ]),
              ]),
            ),
            const SizedBox(height: 18),

            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: color.withOpacity(0.28), width: 1),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_DS.scoreIcon(_safetyScore), color: color, size: 18),
                const SizedBox(width: 9),
                Text(label,
                    style: TextStyle(color: color, fontSize: 17,
                        fontWeight: FontWeight.w900, letterSpacing: 0.4)),
              ]),
            ),
            const SizedBox(height: 10),
            Text("Score personalised for your health profile",
                style: TextStyle(color: _DS.textMuted, fontSize: 11, fontWeight: FontWeight.w500)),
          ]),
        );
      },
    );
  }

  // ── 4B. Explainable AI ────────────────────────────────────────────────────
  Widget _buildExplainableAI() {
    return _sectionCard(
      icon: Icons.psychology_rounded, iconColor: _DS.accent5,
      title: "Why this result?",
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Raw text snippet
        if (extractedText.isNotEmpty && !extractedText.startsWith("No text")) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _DS.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _DS.borderFaint, width: 1),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.receipt_long_rounded, color: _DS.textMuted, size: 13),
                const SizedBox(width: 6),
                Text("Detected Text",
                    style: TextStyle(color: _DS.textMuted, fontSize: 10,
                        fontWeight: FontWeight.w700, letterSpacing: 0.3)),
              ]),
              const SizedBox(height: 7),
              Text(extractedText,
                  style: TextStyle(color: _DS.textSecondary, fontSize: 12, height: 1.5),
                  maxLines: 5, overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(height: 14),
        ],

        // Flagged list
        if (_flagged.isEmpty)
          Text("No specific ingredients detected. Try a clearer image.",
              style: TextStyle(color: _DS.textMuted, fontSize: 13))
        else
          ..._flagged.map((item) {
            final c = item.harmful ? _DS.accent3 : _DS.neon;
            return Container(
              margin: const EdgeInsets.only(bottom: 9),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: c.withOpacity(0.07),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: c.withOpacity(0.18), width: 1),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.harmful ? "❌" : "✅",
                    style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: TextStyle(color: c, fontSize: 13, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(item.reason,
                        style: TextStyle(color: _DS.textMuted, fontSize: 11.5, height: 1.4)),
                  ],
                )),
              ]),
            );
          }),
      ]),
    );
  }

  // ── 4C. Personalized warnings ─────────────────────────────────────────────
  Widget _buildWarningsCard() {
    if (_warnings.isEmpty) return const SizedBox.shrink();
    return _sectionCard(
      icon: Icons.health_and_safety_rounded, iconColor: _DS.accent3,
      title: "Personalized Risk Warnings",
      child: Column(
        children: _warnings.map((w) {
          final isOk = w.startsWith("No major");
          final c    = isOk ? _DS.neon : _DS.accent3;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: c.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.withOpacity(0.18), width: 1),
            ),
            child: Row(children: [
              Container(
                  width: 5, height: 5,
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: Text(w,
                  style: TextStyle(color: c, fontSize: 12.5,
                      fontWeight: FontWeight.w600, height: 1.4))),
            ]),
          );
        }).toList(),
      ),
    );
  }

  // ── 4D. Risk grid ─────────────────────────────────────────────────────────
  Widget _buildRiskGrid() {
    return _sectionCard(
      icon: Icons.analytics_rounded, iconColor: _DS.accent1,
      title: "Ingredient Risk Breakdown",
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
        childAspectRatio: 1.22,
        children: _riskCards.map((rc) {
          final lvlColor = rc.level == "High" ? _DS.accent3
              : rc.level == "Medium" ? _DS.accent4 : _DS.neon;
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: rc.color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: rc.color.withOpacity(0.2), width: 1),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(rc.icon, color: rc.color, size: 15),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                      color: lvlColor.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(7)),
                  child: Text(rc.level,
                      style: TextStyle(color: lvlColor, fontSize: 9,
                          fontWeight: FontWeight.w900, letterSpacing: 0.2)),
                ),
              ]),
              const SizedBox(height: 8),
              Text(rc.category,
                  style: TextStyle(color: _DS.textPrimary, fontSize: 12,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Expanded(child: Text(rc.explanation,
                  style: TextStyle(color: _DS.textMuted, fontSize: 9.5, height: 1.4),
                  overflow: TextOverflow.ellipsis, maxLines: 3)),
            ]),
          );
        }).toList(),
      ),
    );
  }

  // ── 4E. Safer alternatives ────────────────────────────────────────────────
  Widget _buildAlternatives() {
    if (_alternatives.isEmpty) return const SizedBox.shrink();
    return _sectionCard(
      icon: Icons.eco_rounded, iconColor: _DS.accent2,
      title: "Healthier Alternatives for You",
      child: Column(
        children: _alternatives.map((alt) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(
            color: _DS.accent2.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _DS.accent2.withOpacity(0.18), width: 1),
          ),
          child: Row(children: [
            const Icon(Icons.check_circle_outline_rounded, color: _DS.accent2, size: 15),
            const SizedBox(width: 10),
            Expanded(child: Text(alt,
                style: TextStyle(color: _DS.textPrimary, fontSize: 13,
                    fontWeight: FontWeight.w600))),
          ]),
        )).toList(),
      ),
    );
  }

  // ── 5. History ────────────────────────────────────────────────────────────
  Widget _buildHistory() {
    return _sectionCard(
      icon: Icons.history_rounded, iconColor: _DS.accent5,
      title: "Scan History",
      child: Column(
        children: _history.take(6).map((h) {
          final c   = _DS.scoreColor(h.score);
          final t   = "${h.time.hour}:${h.time.minute.toString().padLeft(2, '0')}";
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: _DS.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _DS.borderFaint, width: 1),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: c.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(9)),
                child: Icon(Icons.document_scanner_rounded, color: c, size: 15),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(h.label,
                      style: TextStyle(color: _DS.textPrimary, fontSize: 13,
                          fontWeight: FontWeight.w700)),
                  Text(t,
                      style: TextStyle(color: _DS.textMuted, fontSize: 10)),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                    color: c.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: c.withOpacity(0.28), width: 1)),
                child: Text(_DS.scoreLabel(h.score),
                    style: TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.w900)),
              ),
            ]),
          );
        }).toList(),
      ),
    );
  }

  // ── 6. How it works ───────────────────────────────────────────────────────
  Widget _buildHowItWorks() {
    final steps = [
      ("1️⃣", "Scan",            "Take or upload an ingredient label photo",     _DS.neon),
      ("2️⃣", "AI Extracts",     "Smart OCR reads every ingredient on the label", _DS.accent1),
      ("3️⃣", "Health Match",    "Cross-checks ingredients with your health data", _DS.accent4),
      ("4️⃣", "Safety Score",    "Generates a personalised 0–100 safety rating",  _DS.accent5),
    ];

    return _sectionCard(
      icon: Icons.info_outline_rounded, iconColor: _DS.accent1,
      title: "How SafeBite Works",
      child: Column(
        children: steps.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.$1, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 11),
            Container(width: 3, height: 40,
                decoration: BoxDecoration(
                    color: s.$4.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 11),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.$2,
                    style: TextStyle(color: s.$4, fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(s.$3,
                    style: TextStyle(color: _DS.textMuted, fontSize: 12, height: 1.4)),
              ],
            )),
          ]),
        )).toList(),
      ),
    );
  }

  // ── 8. Disclaimer ─────────────────────────────────────────────────────────
  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _DS.borderFaint, width: 1),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.info_outline_rounded, color: _DS.textMuted, size: 15),
        const SizedBox(width: 10),
        Expanded(child: Text(
          "This analysis is AI-assisted and not a medical diagnosis. "
              "Always consult a qualified healthcare professional before making "
              "dietary decisions based on this information.",
          style: TextStyle(color: _DS.textMuted, fontSize: 11.5, height: 1.55),
        )),
      ]),
    );
  }

  // ── Reusable section card ─────────────────────────────────────────────────
  Widget _sectionCard({
    required IconData icon,
    required Color    iconColor,
    required String   title,
    required Widget   child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: iconColor.withOpacity(0.14), width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: iconColor.withOpacity(0.2), width: 1)),
            child: Icon(icon, size: 15, color: iconColor),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: TextStyle(color: _DS.textPrimary, fontSize: 14,
                  fontWeight: FontWeight.w900, letterSpacing: -0.2)),
        ]),
        const SizedBox(height: 12),
        Container(height: 1, color: _DS.borderFaint),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  SOURCE PICKER SHEET                                                    ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class _SourceSheet extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  const _SourceSheet({required this.onCamera, required this.onGallery});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: _DS.borderFaint, width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 38, height: 4,
            decoration: BoxDecoration(
                color: _DS.textMuted, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 18),
        Text("Choose Image Source",
            style: TextStyle(color: _DS.textPrimary, fontSize: 16,
                fontWeight: FontWeight.w900)),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: _srcBtn(context, "Camera",  Icons.camera_enhance_rounded, _DS.neon,   onCamera)),
          const SizedBox(width: 14),
          Expanded(child: _srcBtn(context, "Gallery", Icons.photo_library_rounded,  _DS.accent1, onGallery)),
        ]),
      ]),
    );
  }

  Widget _srcBtn(BuildContext context, String label, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.28), width: 1.2),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  ANIMATED CORNER BRACKETS PAINTER                                       ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class _CornerBracketPainter extends CustomPainter {
  final double progress;
  final Color  color;
  final double radius;
  _CornerBracketPainter({required this.progress, required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color     = color
      ..strokeWidth = 2.5
      ..style     = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final breathe = 18.0 + (math.sin(progress * 2 * math.pi) * 5);
    final r       = radius;

    void bracket(Offset corner, double dx, double dy) {
      canvas.drawLine(corner, Offset(corner.dx + dx * breathe, corner.dy), paint);
      canvas.drawLine(corner, Offset(corner.dx, corner.dy + dy * breathe), paint);
    }

    bracket(Offset(r, r),                              1,  1);   // top-left
    bracket(Offset(size.width - r, r),                -1,  1);   // top-right
    bracket(Offset(r, size.height - r),                1, -1);   // bottom-left
    bracket(Offset(size.width - r, size.height - r),  -1, -1);   // bottom-right
  }

  @override
  bool shouldRepaint(_CornerBracketPainter old) =>
      old.progress != progress || old.color != color;
}




// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// class IngredientAIScreen extends StatefulWidget {
//   const IngredientAIScreen({super.key});
//
//   @override
//   State<IngredientAIScreen> createState() => _IngredientAIScreenState();
// }
//
// class _IngredientAIScreenState extends State<IngredientAIScreen> {
//   File? _image;
//   String extractedText = "";
//   String aiResult = "";
//   bool loading = false;
//
//   final ImagePicker _picker = ImagePicker();
//
//   // ================= IMAGE PICK =================
//   Future<void> pickImage(ImageSource source) async {
//     final XFile? file =
//     await _picker.pickImage(source: source, imageQuality: 85);
//
//     if (file == null) return;
//
//     setState(() {
//       _image = File(file.path);
//       extractedText = "";
//       aiResult = "";
//     });
//
//     await extractText(_image!);
//   }
//
//   // ================= OCR =================
//   Future<void> extractText(File imageFile) async {
//     setState(() => loading = true);
//
//     final inputImage = InputImage.fromFile(imageFile);
//     final textRecognizer =
//     TextRecognizer(script: TextRecognitionScript.latin);
//
//     final RecognizedText recognizedText =
//     await textRecognizer.processImage(inputImage);
//
//     await textRecognizer.close();
//
//     extractedText = recognizedText.text.trim();
//
//     if (extractedText.isEmpty) {
//       setState(() {
//         extractedText = "No ingredients detected.";
//         loading = false;
//       });
//       return;
//     }
//
//     await analyzeIngredients(extractedText);
//   }
//
//   // ================= SEND TO DJANGO =================
//   Future<void> analyzeIngredients(String ingredients) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final baseUrl = prefs.getString("url") ?? "http://127.0.0.1:8000";
//
//       final response = await http.post(
//         Uri.parse("$baseUrl/analyze_ingredients/"),
//         body: {
//           "ingredients": ingredients,
//         },
//       );
//
//       final data = jsonDecode(response.body);
//
//       if (data["status"] == "ok") {
//         setState(() {
//           aiResult = data["analysis"];
//           loading = false;
//         });
//       } else {
//         setState(() {
//           aiResult = "AI Error: ${data["message"]}";
//           loading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         aiResult = "Server Error: $e";
//         loading = false;
//       });
//     }
//   }
//
//   // ================= IMAGE SOURCE DIALOG =================
//   void showImageSourceDialog() {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Select Image Source"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text("Camera"),
//               onTap: () {
//                 Navigator.pop(context);
//                 pickImage(ImageSource.camera);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo),
//               title: const Text("Gallery"),
//               onTap: () {
//                 Navigator.pop(context);
//                 pickImage(ImageSource.gallery);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ================= UI =================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Ingredient AI Scanner"),
//         backgroundColor: Colors.green,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             GestureDetector(
//               onTap: showImageSourceDialog,
//               child: Container(
//                 height: 200,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.green[50],
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: Colors.green),
//                 ),
//                 child: _image == null
//                     ? const Center(
//                   child: Text(
//                     "Tap to upload food packet image",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 )
//                     : ClipRRect(
//                   borderRadius: BorderRadius.circular(16),
//                   child: Image.file(_image!, fit: BoxFit.cover),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             if (loading) const CircularProgressIndicator(),
//
//             if (extractedText.isNotEmpty) ...[
//               const SizedBox(height: 20),
//               const Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Detected Ingredients:",
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(extractedText),
//             ],
//
//             if (aiResult.isNotEmpty) ...[
//               const SizedBox(height: 20),
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: aiResult.contains("HARMFUL")
//                       ? Colors.red[50]
//                       : Colors.green[50],
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: aiResult.contains("HARMFUL")
//                         ? Colors.red
//                         : Colors.green,
//                   ),
//                 ),
//                 child: Text(
//                   aiResult,
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: aiResult.contains("HARMFUL")
//                         ? Colors.red[800]
//                         : Colors.green[800],
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }