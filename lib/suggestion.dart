import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  DESIGN TOKENS                                                           ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class _DS {
  static const bg           = Color(0xFF050D0A);
  static const bgCard       = Color(0xFF0C1A13);
  static const surface      = Color(0xFF0F2018);
  static const neon         = Color(0xFF00FF88);
  static const neonDim      = Color(0xFF00C46A);
  static const neonFaint    = Color(0xFF003D22);
  static const accent1      = Color(0xFF00E5FF); // cyan
  static const accent2      = Color(0xFFB2FF59); // lime
  static const accent3      = Color(0xFFFF6B6B); // red
  static const accent4      = Color(0xFFFFD166); // amber
  static const accent5      = Color(0xFFA78BFA); // purple
  static const textPrimary  = Color(0xFFF0FFF8);
  static const textSecondary= Color(0xFF6EE7B7);
  static const textMuted    = Color(0xFF2E6B4A);
  static const borderFaint  = Color(0xFF1A3D2A);
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  MEAL DATA MODEL                                                         ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class _MealSection {
  final String key;
  final String title;
  final String emoji;
  final IconData icon;
  final Color color;
  String content;
  bool eaten;
  bool saved;

  _MealSection({
    required this.key,
    required this.title,
    required this.emoji,
    required this.icon,
    required this.color,
    this.content = '',
    this.eaten   = false,
    this.saved   = false,
  });
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  BENEFIT TAG MODEL                                                       ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class _Tag {
  final String label;
  final Color  color;
  const _Tag(this.label, this.color);
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  MAIN SCREEN                                                             ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class DailySuggestionScreen extends StatefulWidget {
  const DailySuggestionScreen({super.key});

  @override
  State<DailySuggestionScreen> createState() => _DailySuggestionScreenState();
}

class _DailySuggestionScreenState extends State<DailySuggestionScreen>
    with TickerProviderStateMixin {

  // ── API state (UNCHANGED) ─────────────────────────────────────────────────
  String suggestion = '';
  String error      = '';
  bool   loading    = false;
  String? lid;

  // ── Health profile (loaded from prefs) ────────────────────────────────────
  double? _bmi;
  double? _sugar;
  double? _cholesterol;
  int?    _bpSystolic;
  String  _smokingStatus  = '';
  String  _alcoholStatus  = '';
  String  _activityLevel  = '';

  // ── Gamification state ────────────────────────────────────────────────────
  int  _streak         = 0;
  int  _xp             = 0;
  bool _allMealsEaten  = false;

  // ── Meal sections ─────────────────────────────────────────────────────────
  late List<_MealSection> _meals;

  // ── Animations ────────────────────────────────────────────────────────────
  late AnimationController _glowCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _flameCtrl;
  late Animation<double>   _glowAnim;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _flameAnim;

  // ── Card fade controllers (one per meal card) ─────────────────────────────
  final List<AnimationController> _cardCtrl = [];
  final List<Animation<double>>   _cardFade = [];
  final List<Animation<double>>   _cardSlide= [];

  @override
  void initState() {
    super.initState();
    _initMeals();
    _initAnims();
    loadUserAndFetch();
  }

  void _initMeals() {
    _meals = [
      _MealSection(key: 'Overall Health Advice',  title: 'Health Advice',  emoji: '🧬', icon: Icons.health_and_safety_rounded,  color: _DS.accent5),
      _MealSection(key: 'Breakfast Suggestion',   title: 'Breakfast',      emoji: '🌅', icon: Icons.free_breakfast_rounded,     color: _DS.accent4),
      _MealSection(key: 'Lunch Suggestion',       title: 'Lunch',          emoji: '☀️', icon: Icons.lunch_dining_rounded,       color: _DS.neon),
      _MealSection(key: 'Dinner Suggestion',      title: 'Dinner',         emoji: '🌙', icon: Icons.dinner_dining_rounded,      color: _DS.accent1),
      _MealSection(key: 'Snacks Suggestion',      title: 'Snacks',         emoji: '🍎', icon: Icons.fastfood_rounded,           color: _DS.accent2),
    ];
  }

  void _initAnims() {
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.2, end: 0.75)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim  = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _flameCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
    _flameAnim = Tween<double>(begin: 0.85, end: 1.15)
        .animate(CurvedAnimation(parent: _flameCtrl, curve: Curves.easeInOut));

    // Per-card stagger controllers
    for (int i = 0; i < 5; i++) {
      final ctrl = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 700));
      _cardCtrl.add(ctrl);
      _cardFade.add(CurvedAnimation(parent: ctrl, curve: Curves.easeOut));
      _cardSlide.add(Tween<double>(begin: 40.0, end: 0.0)
          .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic)));
    }
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _fadeCtrl.dispose();
    _flameCtrl.dispose();
    for (final c in _cardCtrl) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Stagger card animations ───────────────────────────────────────────────
  void _runCardAnimations() async {
    for (var c in _cardCtrl) {
      c.reset();
    }
    _fadeCtrl.forward(from: 0);
    for (int i = 0; i < _cardCtrl.length; i++) {
      await Future.delayed(Duration(milliseconds: 120 * i));
      if (mounted) _cardCtrl[i].forward();
    }
  }

  // ── UNCHANGED: Load user and fetch ────────────────────────────────────────
  Future<void> loadUserAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    lid = prefs.getString('lid');

    if (lid == null) {
      setState(() => error = 'User not logged in');
      return;
    }

    // Load health profile from prefs
    await _loadHealthProfile(prefs);
    // Load gamification
    await _loadGamification(prefs);
    // Load eaten states
    await _loadEatenStates(prefs);

    fetchSuggestion();
  }

  Future<void> _loadHealthProfile(SharedPreferences prefs) async {
    _bmi          = double.tryParse(prefs.getString('hp_bmi')          ?? '');
    _sugar        = double.tryParse(prefs.getString('hp_sugar')        ?? '');
    _cholesterol  = double.tryParse(prefs.getString('hp_cholesterol')  ?? '');
    _smokingStatus= prefs.getString('hp_smoking')   ?? '';
    _alcoholStatus= prefs.getString('hp_alcohol')   ?? '';
    _activityLevel= prefs.getString('hp_activity')  ?? '';
    final bpStr   = prefs.getString('hp_bp') ?? '';
    final bpParts = bpStr.split('/');
    if (bpParts.length == 2) _bpSystolic = int.tryParse(bpParts[0].trim());
  }

  Future<void> _loadGamification(SharedPreferences prefs) async {
    _streak = prefs.getInt('healthy_streak_count') ?? 0;
    _xp     = prefs.getInt('health_xp')            ?? 0;
  }

  Future<void> _loadEatenStates(SharedPreferences prefs) async {
    for (final m in _meals) {
      m.eaten = prefs.getBool('eaten_${m.key}') ?? false;
    }
    _checkAllEaten();
  }

  void _checkAllEaten() {
    // Only meal cards (not health advice)
    final mealOnly = _meals.where((m) => m.key != 'Overall Health Advice').toList();
    _allMealsEaten = mealOnly.isNotEmpty && mealOnly.every((m) => m.eaten);
  }

  // ── UNCHANGED: Fetch suggestion ───────────────────────────────────────────
  Future<void> fetchSuggestion() async {
    setState(() {
      loading    = true;
      error      = '';
      suggestion = '';
    });

    try {
      final prefs   = await SharedPreferences.getInstance();
      final baseUrl = prefs.getString('url') ?? 'http://YOUR_SERVER_IP:8000';

      final response = await http.post(
        Uri.parse('$baseUrl/get_food_suggestions/'),
        body: {'lid': lid!},
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'ok') {
        setState(() {
          suggestion = data['suggestion'];
          loading    = false;
        });
        _parseSections();
        _runCardAnimations();
      } else {
        setState(() {
          error   = data['message'];
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error   = e.toString();
        loading = false;
      });
    }
  }

  // ── IMPROVED: Parse sections ──────────────────────────────────────────────
  void _parseSections() {
    for (final meal in _meals) {
      meal.content = _extractSection(meal.key);
    }
  }

  String _extractSection(String header) {
    if (suggestion.isEmpty) return '';

    // Try exact match first (with colon variants)
    final variants = ['$header:', header, '**$header:**', '**$header**'];

    for (final v in variants) {
      final idx = suggestion.indexOf(v);
      if (idx == -1) continue;

      final start = idx + v.length;
      // Find the next section header or end
      int end = suggestion.length;
      for (final other in _meals) {
        if (other.key == header) continue;
        for (final ov in ['${other.key}:', other.key]) {
          final oi = suggestion.indexOf(ov, start);
          if (oi != -1 && oi < end) end = oi;
        }
      }

      return suggestion.substring(start, end).trim();
    }

    return '';
  }

  // ── Smart tag extraction ──────────────────────────────────────────────────
  List<_Tag> _extractTags(String text) {
    final lower = text.toLowerCase();
    final tags  = <_Tag>[];

    if (lower.contains('protein'))       tags.add(const _Tag('High Protein',   _DS.accent1));
    if (lower.contains('fiber'))         tags.add(const _Tag('High Fiber',     _DS.neon));
    if (lower.contains('omega'))         tags.add(const _Tag('Heart Healthy',  _DS.accent3));
    if (lower.contains('low glycemic') ||
        lower.contains('low gi'))        tags.add(const _Tag('Low GI',         _DS.accent4));
    if (lower.contains('antioxidant'))   tags.add(const _Tag('Immune Boost',   _DS.accent5));
    if (lower.contains('lean'))          tags.add(const _Tag('Low Fat',        _DS.accent2));
    if (lower.contains('calcium'))       tags.add(const _Tag('Bone Health',    _DS.accent4));
    if (lower.contains('vitamin'))       tags.add(const _Tag('Vitamin Rich',   _DS.accent2));
    if (lower.contains('iron'))          tags.add(const _Tag('Iron Rich',      _DS.accent3));
    if (lower.contains('hydrat') ||
        lower.contains('water'))         tags.add(const _Tag('Hydrating',      _DS.accent1));

    return tags;
  }

  // ── Risk score ────────────────────────────────────────────────────────────
  int get _riskScore {
    int risk = 0;
    if (_bmi != null) {
      if (_bmi! < 18.5 || _bmi! >= 30) risk += 20;
      else if (_bmi! >= 25) risk += 10;
    }
    if (_bpSystolic != null) {
      if (_bpSystolic! >= 140) risk += 20;
      else if (_bpSystolic! >= 130) risk += 10;
    }
    if (_sugar != null) {
      if (_sugar! >= 126) risk += 20;
      else if (_sugar! >= 100) risk += 10;
    }
    if (_cholesterol != null) {
      if (_cholesterol! >= 240) risk += 20;
      else if (_cholesterol! >= 200) risk += 10;
    }
    if (_smokingStatus.toLowerCase() == 'yes') risk += 15;
    if (_alcoholStatus.toLowerCase() == 'yes') risk += 10;
    return risk.clamp(0, 100);
  }

  int get _compatibilityScore => (100 - _riskScore).clamp(40, 100);

  // ── Focus banner data ─────────────────────────────────────────────────────
  Map<String, dynamic> get _focusBanner {
    if (_bmi != null && _bmi! >= 25) {
      return {
        'icon':  '🎯',
        'title': 'Focus: Weight Optimization',
        'desc':  'Your BMI suggests a calorie-aware, high-fiber plan.',
        'color': _DS.accent4,
      };
    }
    if (_sugar != null && _sugar! >= 100) {
      return {
        'icon':  '🩸',
        'title': 'Focus: Blood Sugar Control',
        'desc':  'Low-GI foods and balanced carbs are prioritized.',
        'color': _DS.accent3,
      };
    }
    if (_cholesterol != null && _cholesterol! >= 200) {
      return {
        'icon':  '❤️',
        'title': 'Focus: Heart-Friendly Plan',
        'desc':  'Omega-rich, fiber-dense meals to support LDL reduction.',
        'color': _DS.accent3,
      };
    }
    return {
      'icon':  '⚡',
      'title': 'Focus: Performance & Maintenance',
      'desc':  'Your health profile is strong. Optimized for sustained energy.',
      'color': _DS.neon,
    };
  }

  // ── Daily challenge ───────────────────────────────────────────────────────
  Map<String, String> get _dailyChallenge {
    final challenges = <Map<String, String>>[];

    if (_bmi != null && _bmi! >= 25) {
      challenges.add({'task': 'Stay under 1800 kcal today', 'icon': '🔥'});
      challenges.add({'task': 'Walk 8,000 steps', 'icon': '🚶'});
    }
    if (_sugar != null && _sugar! >= 100) {
      challenges.add({'task': 'Avoid added sugar today', 'icon': '🍬'});
      challenges.add({'task': 'Eat 25g fiber today', 'icon': '🌾'});
    }
    if (_cholesterol != null && _cholesterol! >= 200) {
      challenges.add({'task': 'Include omega-3 in one meal', 'icon': '🐟'});
    }
    challenges.add({'task': 'Drink 3L water today', 'icon': '💧'});
    challenges.add({'task': 'Eat a rainbow of vegetables', 'icon': '🥗'});

    final idx = DateTime.now().day % challenges.length;
    return challenges[idx];
  }

  // ── Mark meal as eaten ────────────────────────────────────────────────────
  Future<void> _toggleEaten(_MealSection meal) async {
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();

    setState(() => meal.eaten = !meal.eaten);
    await prefs.setBool('eaten_${meal.key}', meal.eaten);

    _checkAllEaten();

    if (_allMealsEaten) {
      setState(() {
        _streak++;
        _xp += 10;
      });
      await prefs.setInt('healthy_streak_count', _streak);
      await prefs.setInt('health_xp', _xp);
      _showStreakDialog();
    }

    setState(() {});
  }

  void _showStreakDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: _DS.bgCard,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _DS.neon.withOpacity(0.4), width: 1.5),
            boxShadow: [BoxShadow(color: _DS.neon.withOpacity(0.2), blurRadius: 40)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              Text('$_streak Day Streak!',
                  style: const TextStyle(color: _DS.neon, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('You completed all meals today!\n+10 Health XP',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _DS.textSecondary, fontSize: 13, height: 1.5)),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_DS.neon, _DS.neonDim]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('Keep Going! 💪',
                      style: TextStyle(color: _DS.bg, fontWeight: FontWeight.w900, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Swap meal (re-fetch, replace section) ─────────────────────────────────
  Future<void> _swapMeal(_MealSection meal) async {
    HapticFeedback.mediumImpact();
    setState(() => meal.content = '');
    await fetchSuggestion();
  }

  // ── Toggle save ───────────────────────────────────────────────────────────
  void _toggleSave(_MealSection meal) {
    HapticFeedback.lightImpact();
    setState(() => meal.saved = !meal.saved);
  }

  // ── Explain bottom sheet ──────────────────────────────────────────────────
  void _showExplainSheet(_MealSection meal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ExplainSheet(
        meal: meal,
        bmi: _bmi,
        sugar: _sugar,
        cholesterol: _cholesterol,
        bpSystolic: _bpSystolic,
        activityLevel: _activityLevel,
      ),
    );
  }

  // ╔══════════════════════════════════════════════════════════════════════════╗
  // ║  BUILD                                                                   ║
  // ╚══════════════════════════════════════════════════════════════════════════╝
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _DS.bg,
        body: RefreshIndicator(
          color: _DS.neon,
          backgroundColor: _DS.bgCard,
          onRefresh: fetchSuggestion,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildAppBar()),
              if (loading)
                SliverFillRemaining(child: _buildLoader())
              else if (error.isNotEmpty)
                SliverFillRemaining(child: _buildError())
              else if (suggestion.isEmpty)
                  SliverFillRemaining(child: _buildEmpty())
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(_buildContent()),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 52, 18, 14),
      decoration: BoxDecoration(
        color: _DS.bg,
        border: Border(bottom: BorderSide(color: _DS.borderFaint, width: 1)),
      ),
      child: Row(
        children: [
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Daily Food Plan',
                    style: const TextStyle(color: _DS.textPrimary, fontSize: 18,
                        fontWeight: FontWeight.w900, letterSpacing: -0.3)),
                Text('Personalized for your health profile',
                    style: TextStyle(color: _DS.textMuted, fontSize: 11)),
              ],
            ),
          ),
          // Streak badge
          AnimatedBuilder(
            animation: _flameAnim,
            builder: (_, __) => Transform.scale(
              scale: _flameAnim.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _DS.accent4.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _DS.accent4.withOpacity(0.35), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text('$_streak', style: const TextStyle(color: _DS.accent4,
                        fontSize: 14, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Loader ────────────────────────────────────────────────────────────────
  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 52, height: 52,
            child: CircularProgressIndicator(
                color: _DS.neon, strokeWidth: 2.5,
                backgroundColor: _DS.neonFaint),
          ),
          const SizedBox(height: 16),
          Text('Generating your AI meal plan...',
              style: TextStyle(color: _DS.textMuted, fontSize: 13)),
          const SizedBox(height: 6),
          Text('Analyzing your health profile',
              style: TextStyle(color: _DS.textMuted.withOpacity(0.6), fontSize: 11)),
        ],
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _DS.accent3.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: _DS.accent3.withOpacity(0.3)),
              ),
              child: const Icon(Icons.error_outline_rounded, color: _DS.accent3, size: 44),
            ),
            const SizedBox(height: 18),
            Text('Something went wrong',
                style: const TextStyle(color: _DS.textPrimary, fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center,
                style: TextStyle(color: _DS.textMuted, fontSize: 12, height: 1.5)),
            const SizedBox(height: 24),
            _neonButton('Try Again', Icons.refresh_rounded, fetchSuggestion),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text('No suggestions yet',
              style: const TextStyle(color: _DS.textPrimary, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          _neonButton('Generate Plan', Icons.auto_awesome_rounded, fetchSuggestion),
        ],
      ),
    );
  }

  // ── Content list ──────────────────────────────────────────────────────────
  List<Widget> _buildContent() {
    return [
      const SizedBox(height: 16),
      _buildProgressBar(),
      const SizedBox(height: 14),
      _buildFocusBanner(),
      const SizedBox(height: 14),
      _buildStreakXpRow(),
      const SizedBox(height: 14),
      _buildDailyChallenge(),
      const SizedBox(height: 20),
      ..._buildMealCards(),
      const SizedBox(height: 20),
      _buildAiConfidence(),
      const SizedBox(height: 16),
      _buildRegenerateButton(),
      const SizedBox(height: 48),
    ];
  }

  // ── Plan compatibility bar ────────────────────────────────────────────────
  Widget _buildProgressBar() {
    final score = _compatibilityScore;
    final isHigh = _riskScore > 45;
    final color  = score >= 80 ? _DS.neon : score >= 60 ? _DS.accent4 : _DS.accent3;

    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _DS.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
          boxShadow: [BoxShadow(color: color.withOpacity(_glowAnim.value * 0.1), blurRadius: 18)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.auto_awesome_rounded, color: color, size: 15),
                  const SizedBox(width: 7),
                  Text('AI Plan Compatibility Score',
                      style: const TextStyle(color: _DS.textPrimary, fontSize: 13,
                          fontWeight: FontWeight.w800)),
                ]),
                Text('$score / 100',
                    style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  Container(height: 10, color: _DS.surface),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    height: 10,
                    width: MediaQuery.of(context).size.width * score / 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_DS.neon, _DS.accent4, _DS.accent3],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isHigh
                  ? 'Plan designed to reduce your health risk'
                  : 'Plan optimized for performance & longevity',
              style: TextStyle(color: _DS.textMuted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // ── Focus banner ──────────────────────────────────────────────────────────
  Widget _buildFocusBanner() {
    final banner = _focusBanner;
    final color  = banner['color'] as Color;

    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1.2),
          boxShadow: [BoxShadow(color: color.withOpacity(_glowAnim.value * 0.12), blurRadius: 18)],
        ),
        child: Row(
          children: [
            Text(banner['icon'] as String, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(banner['title'] as String,
                      style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(banner['desc'] as String,
                      style: TextStyle(color: color.withOpacity(0.75), fontSize: 11, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Streak + XP row ───────────────────────────────────────────────────────
  Widget _buildStreakXpRow() {
    final mealsDone = _meals.where((m) => m.key != 'Overall Health Advice' && m.eaten).length;
    final total     = _meals.length - 1;

    return Row(
      children: [
        // Streak
        Expanded(child: _miniStatCard('🔥', '$_streak', 'Day Streak', _DS.accent4)),
        const SizedBox(width: 10),
        // XP
        Expanded(child: _miniStatCard('⚡', '$_xp', 'Health XP', _DS.accent5)),
        const SizedBox(width: 10),
        // Meals done
        Expanded(child: _miniStatCard('✅', '$mealsDone/$total', 'Meals Done', _DS.neon)),
      ],
    );
  }

  Widget _miniStatCard(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
          Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Daily challenge card ──────────────────────────────────────────────────
  Widget _buildDailyChallenge() {
    final c = _dailyChallenge;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DS.accent5.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _DS.accent5.withOpacity(0.25), width: 1),
      ),
      child: Row(
        children: [
          Text(c['icon'] ?? '🎯', style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text("Today's AI Challenge",
                      style: const TextStyle(color: _DS.accent5, fontSize: 12, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: _DS.accent5.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('+1 Health XP',
                        style: TextStyle(color: _DS.accent5, fontSize: 9, fontWeight: FontWeight.w800)),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(c['task'] ?? '',
                    style: const TextStyle(color: _DS.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Meal cards ────────────────────────────────────────────────────────────
  List<Widget> _buildMealCards() {
    return _meals.asMap().entries.map((entry) {
      final i    = entry.key;
      final meal = entry.value;
      if (meal.content.isEmpty) return const SizedBox.shrink();

      return AnimatedBuilder(
        animation: _cardCtrl[i],
        builder: (_, child) => Opacity(
          opacity: _cardFade[i].value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, _cardSlide[i].value),
            child: child,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _MealCard(
            meal: meal,
            tags: _extractTags(meal.content),
            onEaten:   () => _toggleEaten(meal),
            onSave:    () => _toggleSave(meal),
            onSwap:    () => _swapMeal(meal),
            onExplain: () => _showExplainSheet(meal),
            glowAnim:  _glowAnim,
          ),
        ),
      );
    }).toList();
  }

  // ── AI confidence ─────────────────────────────────────────────────────────
  Widget _buildAiConfidence() {
    final paramCount = [_bmi, _sugar, _cholesterol, _bpSystolic]
        .where((v) => v != null)
        .length;
    final totalParams = 4 + (_smokingStatus.isNotEmpty ? 1 : 0) +
        (_alcoholStatus.isNotEmpty ? 1 : 0) +
        (_activityLevel.isNotEmpty ? 1 : 0);
    final level = totalParams >= 5 ? 'High' : totalParams >= 3 ? 'Moderate' : 'Basic';
    final color = level == 'High' ? _DS.neon : level == 'Moderate' ? _DS.accent4 : _DS.accent1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _DS.borderFaint, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Icon(Icons.psychology_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('AI Confidence: ',
                      style: TextStyle(color: _DS.textMuted, fontSize: 12)),
                  Text(level,
                      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900)),
                ]),
                Text('Based on $totalParams health parameters',
                    style: TextStyle(color: _DS.textMuted, fontSize: 10)),
              ],
            ),
          ),
          // Tooltip info
          GestureDetector(
            onTap: () => _showConfidenceSheet(level, totalParams),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _DS.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _DS.borderFaint),
              ),
              child: const Icon(Icons.info_outline_rounded, color: _DS.textMuted, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfidenceSheet(String level, int paramCount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _DS.bgCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _DS.neon.withOpacity(0.2), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: _DS.textMuted, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('AI Confidence: $level',
                style: const TextStyle(color: _DS.textPrimary, fontSize: 17, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Text(
              'The AI plan is personalized based on $paramCount health parameters from your profile. '
                  'To improve accuracy, complete your health profile with BP, sugar, cholesterol, and lifestyle data.',
              style: TextStyle(color: _DS.textSecondary, fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 20),
            Text('Increase confidence by adding:',
                style: TextStyle(color: _DS.textMuted, fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...[
              if (_bmi == null) '• Complete your BMI (Height + Weight)',
              if (_sugar == null) '• Add Blood Sugar level',
              if (_cholesterol == null) '• Add Cholesterol reading',
              if (_bpSystolic == null) '• Add Blood Pressure',
            ].map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(t, style: TextStyle(color: _DS.textMuted, fontSize: 12)),
            )),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ── Regenerate button ─────────────────────────────────────────────────────
  Widget _buildRegenerateButton() {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          fetchSuggestion();
        },
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_DS.neon, _DS.neonDim],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _DS.neon.withOpacity(_glowAnim.value * 0.45),
                blurRadius: 24,
                spreadRadius: -4,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome_rounded, color: _DS.bg, size: 20),
              const SizedBox(width: 10),
              Text('Regenerate Plan',
                  style: TextStyle(color: _DS.bg, fontSize: 16,
                      fontWeight: FontWeight.w900, letterSpacing: 0.3)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _neonButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_DS.neon, _DS.neonDim]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _DS.bg, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: _DS.bg, fontSize: 14, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  MEAL CARD WIDGET                                                        ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class _MealCard extends StatelessWidget {
  final _MealSection   meal;
  final List<_Tag>     tags;
  final VoidCallback   onEaten;
  final VoidCallback   onSave;
  final VoidCallback   onSwap;
  final VoidCallback   onExplain;
  final Animation<double> glowAnim;

  const _MealCard({
    required this.meal,
    required this.tags,
    required this.onEaten,
    required this.onSave,
    required this.onSwap,
    required this.onExplain,
    required this.glowAnim,
  });

  @override
  Widget build(BuildContext context) {
    final isHealthAdvice = meal.key == 'Overall Health Advice';

    return AnimatedBuilder(
      animation: glowAnim,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          color: _DS.bgCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: meal.eaten
                ? _DS.neon.withOpacity(0.5)
                : meal.color.withOpacity(0.2),
            width: meal.eaten ? 1.5 : 1,
          ),
          boxShadow: meal.eaten
              ? [BoxShadow(color: _DS.neon.withOpacity(glowAnim.value * 0.2),
              blurRadius: 20, offset: const Offset(0, 4))]
              : [BoxShadow(color: meal.color.withOpacity(glowAnim.value * 0.08),
              blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              decoration: BoxDecoration(
                color: meal.color.withOpacity(0.07),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Text(meal.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(meal.title,
                            style: TextStyle(color: meal.color, fontSize: 16,
                                fontWeight: FontWeight.w900)),
                        if (!isHealthAdvice)
                          Text(meal.eaten ? '✅ Marked as eaten' : 'Tap ✓ to track',
                              style: TextStyle(
                                  color: meal.eaten ? _DS.neon : _DS.textMuted,
                                  fontSize: 10, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  // Info button
                  GestureDetector(
                    onTap: onExplain,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _DS.accent1.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _DS.accent1.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.info_outline_rounded,
                          color: _DS.accent1, size: 15),
                    ),
                  ),
                  if (meal.eaten) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _DS.neon.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: _DS.neon.withOpacity(0.5)),
                      ),
                      child: const Icon(Icons.check_rounded, color: _DS.neon, size: 14),
                    ),
                  ],
                ],
              ),
            ),

            // ── Content ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main text
                  Text(
                    meal.content,
                    style: const TextStyle(color: _DS.textPrimary, fontSize: 13, height: 1.65),
                  ),

                  // Tags
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: tag.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: tag.color.withOpacity(0.3), width: 1),
                        ),
                        child: Text(tag.label,
                            style: TextStyle(color: tag.color, fontSize: 10,
                                fontWeight: FontWeight.w800)),
                      )).toList(),
                    ),
                  ],

                  // Action buttons
                  if (!isHealthAdvice) ...[
                    const SizedBox(height: 14),
                    Container(height: 1, color: _DS.borderFaint),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Swap
                        _actionBtn(
                          '🔁', 'Swap',
                          _DS.accent1,
                          onSwap,
                        ),
                        const SizedBox(width: 8),
                        // Save
                        _actionBtn(
                          meal.saved ? '❤️' : '🤍', 'Save',
                          meal.saved ? _DS.accent3 : _DS.textMuted,
                          onSave,
                        ),
                        const SizedBox(width: 8),
                        // Eaten
                        Expanded(
                          child: GestureDetector(
                            onTap: onEaten,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                gradient: meal.eaten
                                    ? const LinearGradient(colors: [_DS.neon, _DS.neonDim])
                                    : null,
                                color: meal.eaten ? null : _DS.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: meal.eaten ? Colors.transparent : _DS.borderFaint,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    meal.eaten
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    color: meal.eaten ? _DS.bg : _DS.textMuted,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    meal.eaten ? 'Eaten ✓' : 'I Ate This',
                                    style: TextStyle(
                                      color: meal.eaten ? _DS.bg : _DS.textMuted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(String emoji, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  EXPLAIN THIS MEAL BOTTOM SHEET                                          ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class _ExplainSheet extends StatelessWidget {
  final _MealSection meal;
  final double? bmi;
  final double? sugar;
  final double? cholesterol;
  final int?    bpSystolic;
  final String  activityLevel;

  const _ExplainSheet({
    required this.meal,
    this.bmi,
    this.sugar,
    this.cholesterol,
    this.bpSystolic,
    required this.activityLevel,
  });

  String _bmiLabel(double v) {
    if (v < 18.5) return 'Underweight';
    if (v < 25)   return 'Normal';
    if (v < 30)   return 'Overweight';
    return 'Obese';
  }

  List<Map<String, String>> _buildInsights() {
    final insights = <Map<String, String>>[];
    final lower = meal.content.toLowerCase();

    if (bmi != null) {
      insights.add({
        'icon': '📊',
        'text': 'Your BMI is ${bmi!.toStringAsFixed(1)} (${_bmiLabel(bmi!)})',
        'sub':  bmi! >= 25
            ? 'This meal is portion-controlled and lower in calorie density.'
            : bmi! < 18.5
            ? 'This meal supports healthy weight gain with nutrient-dense foods.'
            : 'Balanced macros to help maintain your healthy weight.',
      });
    }

    if (sugar != null && sugar! >= 100) {
      insights.add({
        'icon': '🩸',
        'text': 'Blood Sugar: ${sugar!.toStringAsFixed(0)} mg/dL',
        'sub':  'Low-glycemic foods were prioritized to stabilize glucose levels.',
      });
    }

    if (cholesterol != null && cholesterol! >= 200) {
      insights.add({
        'icon': '❤️',
        'text': 'Cholesterol: ${cholesterol!.toStringAsFixed(0)} mg/dL',
        'sub':  'This meal avoids saturated fats and includes fiber to reduce LDL.',
      });
    }

    if (bpSystolic != null && bpSystolic! >= 130) {
      insights.add({
        'icon': '💓',
        'text': 'BP: $bpSystolic mmHg (Elevated)',
        'sub':  'Low-sodium options selected to support blood pressure management.',
      });
    }

    if (lower.contains('protein')) {
      insights.add({'icon': '💪', 'text': 'High Protein Content',
        'sub': 'Supports muscle maintenance and keeps you full longer.'});
    }
    if (lower.contains('fiber')) {
      insights.add({'icon': '🌾', 'text': 'High Fiber',
        'sub': 'Aids digestion, regulates blood sugar, and supports gut health.'});
    }
    if (lower.contains('omega')) {
      insights.add({'icon': '🐟', 'text': 'Omega-3 Rich',
        'sub': 'Anti-inflammatory. Beneficial for heart and brain health.'});
    }
    if (lower.contains('antioxidant')) {
      insights.add({'icon': '🫐', 'text': 'Antioxidants',
        'sub': 'Reduces cellular damage and supports immune function.'});
    }

    if (insights.isEmpty) {
      insights.add({'icon': '🥗', 'text': 'Balanced Meal',
        'sub': 'This meal is selected to provide balanced macronutrients for your daily needs.'});
    }

    return insights;
  }

  @override
  Widget build(BuildContext context) {
    final insights = _buildInsights();
    final color    = meal.color;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withOpacity(0.3), width: 1.2),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 32, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: _DS.textMuted, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 18),

          // Title
          Row(
            children: [
              Text(meal.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Why this meal suits you',
                        style: const TextStyle(color: _DS.textPrimary, fontSize: 16, fontWeight: FontWeight.w900)),
                    Text(meal.title,
                        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Insights
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.15), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(insight['icon'] ?? '•', style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(insight['text'] ?? '',
                            style: const TextStyle(color: _DS.textPrimary, fontSize: 12,
                                fontWeight: FontWeight.w700)),
                        if ((insight['sub'] ?? '').isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(insight['sub']!,
                              style: TextStyle(color: _DS.textSecondary, fontSize: 11, height: 1.4)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),

          const SizedBox(height: 6),
          Text('Insights are computed from your saved health profile.',
              style: TextStyle(color: _DS.textMuted, fontSize: 10),
              textAlign: TextAlign.center),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 6),
        ],
      ),
    );
  }
}


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// class DailySuggestionScreen extends StatefulWidget {
//   const DailySuggestionScreen({super.key});
//
//   @override
//   State<DailySuggestionScreen> createState() =>
//       _DailySuggestionScreenState();
// }
//
// class _DailySuggestionScreenState
//     extends State<DailySuggestionScreen> {
//   String suggestion = "";
//   String error = "";
//   bool loading = false;
//
//   String? lid;
//
//   @override
//   void initState() {
//     super.initState();
//     loadUserAndFetch();
//   }
//
//   // ================= LOAD LID FROM SHARED PREFERENCES =================
//   Future<void> loadUserAndFetch() async {
//     final prefs = await SharedPreferences.getInstance();
//     lid = prefs.getString("lid");
//
//     if (lid == null) {
//       setState(() {
//         error = "User not logged in";
//       });
//       return;
//     }
//
//     fetchSuggestion();
//   }
//
//   // ================= FETCH AI SUGGESTION =================
//   Future<void> fetchSuggestion() async {
//     setState(() {
//       loading = true;
//       error = "";
//       suggestion = "";
//     });
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final baseUrl =
//           prefs.getString("url") ?? "http://YOUR_SERVER_IP:8000";
//
//       final response = await http.post(
//         Uri.parse("$baseUrl/get_food_suggestions/"),
//         body: {
//           "lid": lid!,
//         },
//       );
//
//       final data = jsonDecode(response.body);
//
//       if (data["status"] == "ok") {
//         setState(() {
//           suggestion = data["suggestion"];
//           loading = false;
//         });
//       } else {
//         setState(() {
//           error = data["message"];
//           loading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         error = e.toString();
//         loading = false;
//       });
//     }
//   }
//
//   // ================= SECTION BUILDER =================
//   Widget buildSection(String title, IconData icon) {
//     if (!suggestion.contains(title)) return const SizedBox();
//
//     final startIndex = suggestion.indexOf(title);
//     final endIndex =
//     suggestion.indexOf("\n\n", startIndex + title.length);
//
//     final sectionText = endIndex == -1
//         ? suggestion.substring(startIndex)
//         : suggestion.substring(startIndex, endIndex);
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.green[50],
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.green),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: Colors.green, size: 28),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               sectionText,
//               style: const TextStyle(fontSize: 15),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ================= UI =================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("AI Daily Food Plan"),
//         backgroundColor: Colors.green,
//       ),
//       body: RefreshIndicator(
//         onRefresh: fetchSuggestion,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: loading
//               ? const Center(child: CircularProgressIndicator())
//               : error.isNotEmpty
//               ? Center(
//             child: Text(
//               error,
//               style: const TextStyle(
//                   color: Colors.red, fontSize: 16),
//             ),
//           )
//               : suggestion.isEmpty
//               ? const Center(
//             child: Text(
//               "No suggestions available",
//               style: TextStyle(fontSize: 16),
//             ),
//           )
//               : SingleChildScrollView(
//             physics:
//             const AlwaysScrollableScrollPhysics(),
//             child: Column(
//               crossAxisAlignment:
//               CrossAxisAlignment.start,
//               children: [
//                 buildSection(
//                     "Overall Health Advice:",
//                     Icons.health_and_safety),
//                 buildSection(
//                     "Breakfast Suggestion:",
//                     Icons.free_breakfast),
//                 buildSection(
//                     "Lunch Suggestion:",
//                     Icons.lunch_dining),
//                 buildSection(
//                     "Dinner Suggestion:",
//                     Icons.dinner_dining),
//                 buildSection(
//                     "Snacks Suggestion:",
//                     Icons.fastfood),
//                 const SizedBox(height: 20),
//                 Center(
//                   child: ElevatedButton.icon(
//                     onPressed: fetchSuggestion,
//                     icon: const Icon(Icons.refresh),
//                     label: const Text("Regenerate Plan"),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       padding:
//                       const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 12),
//                       shape:
//                       RoundedRectangleBorder(
//                         borderRadius:
//                         BorderRadius.circular(30),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }