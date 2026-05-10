import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_health.dart';

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  DESIGN TOKENS                                                           ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class _DS {
  static const bg            = Color(0xFF050D0A);
  static const bgCard        = Color(0xFF0C1A13);
  static const surface       = Color(0xFF0F2018);
  static const neon          = Color(0xFF00FF88);
  static const neonDim       = Color(0xFF00C46A);
  static const neonFaint     = Color(0xFF003D22);
  static const accent1       = Color(0xFF00E5FF);  // cyan
  static const accent2       = Color(0xFFB2FF59);  // lime
  static const accent3       = Color(0xFFFF6B6B);  // red
  static const accent4       = Color(0xFFFFD166);  // amber
  static const accent5       = Color(0xFFA78BFA);  // purple
  static const textPrimary   = Color(0xFFF0FFF8);
  static const textSecondary = Color(0xFF6EE7B7);
  static const textMuted     = Color(0xFF2E6B4A);
  static const borderFaint   = Color(0xFF1A3D2A);
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  MEDICAL INFO MODEL                                                      ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class _MedicalInfo {
  final String title;
  final String whatItIs;
  final String normalRange;
  final String whereToFind;
  final Color  color;

  const _MedicalInfo({
    required this.title,
    required this.whatItIs,
    required this.normalRange,
    required this.whereToFind,
    required this.color,
  });
}

const _medicalInfoMap = <String, _MedicalInfo>{
  'BP': _MedicalInfo(
    title: 'Blood Pressure',
    whatItIs: 'Blood pressure measures the force of blood pushing against artery walls. It is recorded as two numbers: systolic (top) over diastolic (bottom).',
    normalRange: 'Normal: 90/60 – 120/80 mmHg\nHigh: > 130/80 mmHg\nLow: < 90/60 mmHg',
    whereToFind: 'Measured with a BP monitor at home, clinic, or pharmacy. Available on any health check-up report.',
    color: _DS.accent3,
  ),
  'Sugar': _MedicalInfo(
    title: 'Blood Sugar Level',
    whatItIs: 'Blood glucose measures the amount of sugar in your blood. Fasting glucose (before eating) is most commonly tested.',
    normalRange: 'Fasting: 70–99 mg/dL (Normal)\n100–125 mg/dL (Pre-diabetic)\n≥ 126 mg/dL (Diabetic)',
    whereToFind: 'Found on a blood test report (FBS or RBS). Can also be measured with a home glucometer.',
    color: _DS.accent4,
  ),
  'Cholesterol': _MedicalInfo(
    title: 'Cholesterol',
    whatItIs: 'Cholesterol is a fatty substance in the blood. High levels can build up in arteries and raise heart disease risk.',
    normalRange: 'Total: < 200 mg/dL (desirable)\nLDL: < 100 mg/dL\nHDL: > 60 mg/dL (protective)',
    whereToFind: 'Found in a Lipid Profile blood test. Typically ordered by doctors during annual check-ups.',
    color: _DS.accent1,
  ),
  'Thyroid': _MedicalInfo(
    title: 'Thyroid Status',
    whatItIs: 'Thyroid hormones regulate metabolism, energy, and weight. TSH (Thyroid Stimulating Hormone) is the most common test.',
    normalRange: 'TSH: 0.4 – 4.0 mIU/L (Normal)\n< 0.4: Hyperthyroid\n> 4.0: Hypothyroid',
    whereToFind: 'Available from a Thyroid Function Test (TFT) blood report from any diagnostic lab.',
    color: _DS.accent5,
  ),
  'Vitamin D': _MedicalInfo(
    title: 'Vitamin D Level',
    whatItIs: 'Vitamin D supports bone health, immune function, and muscle strength. Deficiency is very common in India.',
    normalRange: 'Deficient: < 20 ng/mL\nInsufficient: 20–29 ng/mL\nNormal: 30–100 ng/mL',
    whereToFind: 'Tested via a 25-OH Vitamin D blood test at any diagnostic lab. Doctor may order it during a routine check-up.',
    color: _DS.accent4,
  ),
  'Iron': _MedicalInfo(
    title: 'Iron / Ferritin',
    whatItIs: 'Ferritin is a protein that stores iron. Low ferritin indicates iron deficiency (anaemia). It impacts energy levels and nutrition absorption.',
    normalRange: 'Men: 24–336 ng/mL\nWomen: 11–307 ng/mL\n< 12 ng/mL = Deficiency',
    whereToFind: 'Serum Ferritin test, available on a CBC (Complete Blood Count) or separate iron panel from any lab.',
    color: _DS.accent3,
  ),
  'Bone Density': _MedicalInfo(
    title: 'Bone Density (T-score)',
    whatItIs: 'A DEXA scan measures bone density. The T-score compares your bone density to a healthy young adult\'s peak bone mass.',
    normalRange: 'Normal: T-score ≥ -1.0\nOsteopenia: -1.0 to -2.5\nOsteoporosis: ≤ -2.5',
    whereToFind: 'Measured via a DEXA (Dual-Energy X-ray Absorptiometry) scan, ordered by a doctor or orthopedist.',
    color: _DS.accent2,
  ),
};

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  MAIN PAGE                                                               ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class HealthProfilePage extends StatefulWidget {
  const HealthProfilePage({super.key});

  @override
  State<HealthProfilePage> createState() => _HealthProfilePageState();
}

class _HealthProfilePageState extends State<HealthProfilePage>
    with TickerProviderStateMixin {

  // ── Loading / error state ─────────────────────────────────────────────────
  bool   _isLoading = true;
  bool   _hasError  = false;
  String _errorMsg  = '';

  // ── Mode toggle ───────────────────────────────────────────────────────────
  bool _advancedMode = false;

  // ── Health fields (unchanged variable names) ──────────────────────────────
  String height         = '—';
  String weight         = '—';
  String bmi            = '—';
  String bloodGroup     = '—';
  String isCardiac      = '—';
  String bodyType       = '—';
  String bp             = '—';
  String cholesterol    = '—';
  String sugarLevel     = '—';
  String thyroidStatus  = '—';
  String waist          = '—';
  String hip            = '—';
  String boneDensity    = '—';
  String vitaminD       = '—';
  String ironFerritin   = '—';
  String smoking        = '—';
  String alcohol        = '—';
  String activityLevel  = '—';
  String userId         = '';

  // ── Animations ────────────────────────────────────────────────────────────
  late AnimationController _fadeCtrl;
  late AnimationController _glowCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _slideAnim;
  late Animation<double>   _glowAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim  = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic),
    );

    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.2, end: 0.7).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    _fetchHealthData();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  // ── UNCHANGED backend fetch ───────────────────────────────────────────────
  Future<void> _fetchHealthData() async {
    setState(() {
      _isLoading = true;
      _hasError  = false;
      _errorMsg  = '';
    });

    try {
      final prefs   = await SharedPreferences.getInstance();
      final baseUrl = prefs.getString('url') ?? '';
      final lid     = prefs.getString('lid') ?? '';

      if (baseUrl.isEmpty || lid.isEmpty) throw Exception('Missing server URL or login ID');

      final response = await http.post(
        Uri.parse('$baseUrl/view_health_profile/'),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data['status'] == 'ok') {
          setState(() {
            userId        = data['id']?.toString()                         ?? '';
            height        = data['Height']?.toString()                     ?? '—';
            weight        = data['Weight']?.toString()                     ?? '—';
            bmi           = data['Bmi']?.toString()                        ?? '—';
            bloodGroup    = data['Blood_Group']?.toString()                ?? '—';
            isCardiac     = data['Is_Cardiac']?.toString()                 ?? '—';
            bodyType      = data['Body_Type']?.toString()                  ?? '—';
            bp            = data['Bp']?.toString()                         ?? '—';
            cholesterol   = data['Cholestrol']?.toString()                 ?? '—';
            sugarLevel    = data['Sugar_level']?.toString()                ?? '—';
            thyroidStatus = data['Thyroid_Status']?.toString()             ?? '—';
            waist         = data['Waist_Circumference']?.toString()        ?? '—';
            hip           = data['Hip_Circumference']?.toString()          ?? '—';
            boneDensity   = data['Bone_Density_Tscore']?.toString()        ?? '—';
            vitaminD      = data['Vitamin_D_Level']?.toString()            ?? '—';
            ironFerritin  = data['Iron_Ferritin']?.toString()              ?? '—';
            smoking       = data['Smoking']?.toString()                    ?? '—';
            alcohol       = data['Alcohol_Consumption']?.toString()        ?? '—';
            activityLevel = data['Physical_Activity_Level']?.toString()    ?? '—';
          });
          _fadeCtrl.forward(from: 0);
        } else {
          setState(() {
            _hasError = true;
            _errorMsg = data['message']?.toString() ?? 'Data not found';
          });
        }
      } else {
        setState(() {
          _hasError = true;
          _errorMsg = 'Server responded with status ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMsg = e.toString().replaceFirst('Exception: ', '');
      });
      if (mounted) {
        Fluttertoast.showToast(
          msg: _errorMsg,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: _DS.accent3,
          textColor: Colors.white,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── BMI helpers ───────────────────────────────────────────────────────────
  double? get _parsedBmi => double.tryParse(bmi);

  String _getBmiCategory(double? v) {
    if (v == null) return '';
    if (v < 18.5) return 'Underweight';
    if (v < 25)   return 'Normal';
    if (v < 30)   return 'Overweight';
    return 'Obese';
  }

  Color _getBmiColor(double? v) {
    if (v == null) return _DS.textMuted;
    if (v < 18.5)  return _DS.accent4;
    if (v < 25)    return _DS.neon;
    if (v < 30)    return _DS.accent4;
    return _DS.accent3;
  }

  String _getBmiGoalSuggestion(double? v) {
    if (v == null) return '';
    if (v < 18.5) return '⚡ Weight Gain recommended';
    if (v < 25)   return '✅ Maintain current weight';
    return '🎯 Weight Loss recommended';
  }

  // ── Health Risk Score (0–100, lower = healthier) ──────────────────────────
  int _calcRiskScore() {
    int risk = 0;

    // BMI risk
    final b = _parsedBmi;
    if (b != null) {
      if (b < 18.5 || b >= 30) risk += 20;
      else if (b >= 25) risk += 10;
    }

    // BP risk (parse systolic)
    final bpParts = bp.split('/');
    if (bpParts.length == 2) {
      final sys = int.tryParse(bpParts[0].trim());
      if (sys != null) {
        if (sys >= 140) risk += 20;
        else if (sys >= 130) risk += 10;
      }
    }

    // Sugar risk
    final sugar = double.tryParse(sugarLevel);
    if (sugar != null) {
      if (sugar >= 126) risk += 20;
      else if (sugar >= 100) risk += 10;
    }

    // Cholesterol risk
    final chol = double.tryParse(cholesterol);
    if (chol != null) {
      if (chol >= 240) risk += 20;
      else if (chol >= 200) risk += 10;
    }

    // Lifestyle
    if (smoking.toLowerCase() == 'yes') risk += 15;
    if (alcohol.toLowerCase() == 'yes' || alcohol.toLowerCase() == 'regular') risk += 10;

    return risk.clamp(0, 100);
  }

  Color _riskColor(int score) {
    if (score <= 20) return _DS.neon;
    if (score <= 45) return _DS.accent4;
    return _DS.accent3;
  }

  String _riskLabel(int score) {
    if (score <= 20) return 'Low Risk';
    if (score <= 45) return 'Moderate Risk';
    return 'High Risk';
  }

  // ── Show medical info bottom sheet ────────────────────────────────────────
  void _showMedicalInfo(String key) {
    final info = _medicalInfoMap[key];
    if (info == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MedicalInfoSheet(info: info),
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
        body: _isLoading
            ? _buildLoader()
            : _hasError
            ? _buildError()
            : _buildBody(),
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
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: _DS.neon,
              strokeWidth: 2.5,
              backgroundColor: _DS.neonFaint,
            ),
          ),
          const SizedBox(height: 16),
          Text("Loading health profile...",
              style: TextStyle(color: _DS.textMuted, fontSize: 13)),
        ],
      ),
    );
  }

  // ── Error state ───────────────────────────────────────────────────────────
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
                border: Border.all(color: _DS.accent3.withOpacity(0.3), width: 1),
              ),
              child: const Icon(Icons.error_outline_rounded, size: 48, color: _DS.accent3),
            ),
            const SizedBox(height: 20),
            Text("Failed to load health data",
                style: TextStyle(color: _DS.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(_errorMsg,
                style: TextStyle(color: _DS.textMuted, fontSize: 13, height: 1.5),
                textAlign: TextAlign.center),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _fetchHealthData,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: _DS.neonFaint,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _DS.neon.withOpacity(0.4), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded, color: _DS.neon, size: 18),
                    const SizedBox(width: 8),
                    Text("Retry", style: TextStyle(color: _DS.neon, fontSize: 14, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main body ─────────────────────────────────────────────────────────────
  Widget _buildBody() {
    final riskScore = _calcRiskScore();
    final bmiVal    = _parsedBmi;

    return RefreshIndicator(
      color: _DS.neon,
      backgroundColor: _DS.bgCard,
      onRefresh: _fetchHealthData,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverToBoxAdapter(child: _buildAppBar()),

          // Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 12),

                AnimatedBuilder(
                  animation: _fadeCtrl,
                  builder: (_, child) => Opacity(
                    opacity: _fadeAnim.value.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, _slideAnim.value),
                      child: child,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mode toggle
                      _buildModeToggle(),
                      const SizedBox(height: 20),

                      // BMI hero card
                      _buildBmiCard(bmiVal),
                      const SizedBox(height: 16),

                      // Risk score card
                      _buildRiskCard(riskScore),
                      const SizedBox(height: 20),

                      // Essential fields
                      _sectionLabel("Essential Measurements", Icons.monitor_heart_rounded, _DS.neon),
                      const SizedBox(height: 14),
                      _buildEssentialSection(),
                      const SizedBox(height: 20),

                      // Advanced fields (conditional)
                      if (_advancedMode) ...[
                        _sectionLabel("Vital Signs & Risks", Icons.favorite_rounded, _DS.accent3),
                        const SizedBox(height: 14),
                        _buildVitalsSection(),
                        const SizedBox(height: 20),

                        _sectionLabel("Nutrient & Bone Health", Icons.science_rounded, _DS.accent5),
                        const SizedBox(height: 14),
                        _buildNutrientSection(),
                        const SizedBox(height: 20),

                        _sectionLabel("Body Composition", Icons.straighten_rounded, _DS.accent2),
                        const SizedBox(height: 14),
                        _buildBodySection(),
                        const SizedBox(height: 20),

                        _sectionLabel("Lifestyle Factors", Icons.self_improvement_rounded, _DS.accent1),
                        const SizedBox(height: 14),
                        _buildLifestyleSection(),
                        const SizedBox(height: 20),
                      ],

                      // Edit button
                      _buildEditButton(),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
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
                Text("Health Profile",
                    style: TextStyle(color: _DS.textPrimary, fontSize: 18,
                        fontWeight: FontWeight.w900, letterSpacing: -0.3)),
                Text("Personalized AI health overview",
                    style: TextStyle(color: _DS.textMuted, fontSize: 11)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () { HapticFeedback.lightImpact(); _fetchHealthData(); },
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: _DS.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _DS.borderFaint, width: 1),
              ),
              child: const Icon(Icons.refresh_rounded, color: _DS.neon, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mode toggle ───────────────────────────────────────────────────────────
  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _DS.borderFaint, width: 1),
      ),
      child: Row(
        children: [
          _togglePill("Basic Mode", !_advancedMode, _DS.neon, () {
            HapticFeedback.lightImpact();
            setState(() => _advancedMode = false);
          }),
          _togglePill("Advanced Mode", _advancedMode, _DS.accent5, () {
            HapticFeedback.lightImpact();
            setState(() => _advancedMode = true);
          }),
        ],
      ),
    );
  }

  Widget _togglePill(String label, bool active, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: active ? color.withOpacity(0.5) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? color : _DS.textMuted,
              fontSize: 13,
              fontWeight: active ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ── BMI card ──────────────────────────────────────────────────────────────
  Widget _buildBmiCard(double? bmiVal) {
    final bmiColor    = _getBmiColor(bmiVal);
    final bmiCategory = _getBmiCategory(bmiVal);
    final goalSuggest = _getBmiGoalSuggestion(bmiVal);
    final progress    = bmiVal == null ? 0.0 : ((bmiVal - 10) / 30).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _DS.bgCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: bmiColor.withOpacity(0.25), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: bmiColor.withOpacity(_glowAnim.value * 0.15),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // BMI circle
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bmiColor.withOpacity(0.1),
                    border: Border.all(color: bmiColor.withOpacity(0.5), width: 2),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          bmiVal != null ? bmiVal.toStringAsFixed(1) : '—',
                          style: TextStyle(color: bmiColor, fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                        Text("BMI", style: TextStyle(color: bmiColor.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: bmiColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: bmiColor.withOpacity(0.35), width: 1),
                            ),
                            child: Text(bmiCategory.isEmpty ? 'Unknown' : bmiCategory,
                                style: TextStyle(color: bmiColor, fontSize: 12, fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(children: [
                        _miniStat("Height", height == '—' ? '—' : '${height} cm', _DS.accent1),
                        const SizedBox(width: 12),
                        _miniStat("Weight", weight == '—' ? '—' : '${weight} kg', _DS.accent2),
                      ]),
                    ],
                  ),
                ),
              ],
            ),

            if (goalSuggest.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: bmiColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: bmiColor.withOpacity(0.2), width: 1),
                ),
                child: Text(
                  goalSuggest,
                  style: TextStyle(color: bmiColor, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],

            const SizedBox(height: 14),
            // BMI scale bar
            Column(
              children: [
                // Scale labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Under", style: TextStyle(color: _DS.accent4, fontSize: 9, fontWeight: FontWeight.w600)),
                    Text("Normal", style: TextStyle(color: _DS.neon, fontSize: 9, fontWeight: FontWeight.w600)),
                    Text("Over", style: TextStyle(color: _DS.accent4, fontSize: 9, fontWeight: FontWeight.w600)),
                    Text("Obese", style: TextStyle(color: _DS.accent3, fontSize: 9, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 8,
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Container(color: _DS.accent4.withOpacity(0.6))),
                        Expanded(flex: 3, child: Container(color: _DS.neon.withOpacity(0.6))),
                        Expanded(flex: 2, child: Container(color: _DS.accent4.withOpacity(0.6))),
                        Expanded(flex: 3, child: Container(color: _DS.accent3.withOpacity(0.6))),
                      ],
                    ),
                  ),
                ),
                if (bmiVal != null) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment((progress * 2 - 1).clamp(-0.9, 0.9), 0),
                    child: Container(
                      width: 3,
                      height: 12,
                      decoration: BoxDecoration(
                        color: bmiColor,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [BoxShadow(color: bmiColor.withOpacity(0.7), blurRadius: 4)],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: _DS.textMuted, fontSize: 9, fontWeight: FontWeight.w600)),
        Text(val, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w800)),
      ],
    );
  }

  // ── Risk score card ───────────────────────────────────────────────────────
  Widget _buildRiskCard(int riskScore) {
    final color = _riskColor(riskScore);
    final label = _riskLabel(riskScore);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.25), width: 1),
                ),
                child: Icon(Icons.health_and_safety_rounded, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Text("Health Risk Score",
                  style: TextStyle(color: _DS.textPrimary, fontSize: 15, fontWeight: FontWeight.w900)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.3), width: 1),
                ),
                child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(height: 14, width: double.infinity, color: _DS.surface),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  height: 14,
                  width: MediaQuery.of(context).size.width * (riskScore / 100),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_DS.neon, _DS.accent4, _DS.accent3],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Based on BMI, BP, Sugar, Cholesterol, Lifestyle",
                  style: TextStyle(color: _DS.textMuted, fontSize: 10)),
              Text("$riskScore / 100",
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────
  Widget _sectionLabel(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.25), width: 1),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
                color: _DS.textPrimary, letterSpacing: -0.2)),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: _DS.borderFaint)),
      ],
    );
  }

  // ── Essential section ─────────────────────────────────────────────────────
  Widget _buildEssentialSection() {
    return _infoCard([
      _infoRow(Icons.height_rounded,          "Height",                   height,        _DS.neon,    unit: "cm",   required: true),
      _infoRow(Icons.monitor_weight_rounded,   "Weight",                   weight,        _DS.accent2, unit: "kg",   required: true),
      _infoRow(Icons.directions_run_rounded,   "Physical Activity Level",  activityLevel, _DS.accent1, required: true),
      _infoRow(Icons.bloodtype_rounded,        "Blood Group",              bloodGroup,    _DS.accent3),
      _infoRow(Icons.person_rounded,           "Body Type",                bodyType,      _DS.accent5),
    ]);
  }

  // ── Vitals section ────────────────────────────────────────────────────────
  Widget _buildVitalsSection() {
    return _infoCard([
      _infoRow(Icons.favorite_border_rounded,  "Blood Pressure",    bp,           _DS.accent3,  infoKey: 'BP'),
      _infoRow(Icons.bloodtype_rounded,        "Blood Group",       bloodGroup,   _DS.accent3),
      _infoRow(Icons.heart_broken_outlined,    "Cardiac Risk",      isCardiac,    _DS.accent3),
      _infoRow(Icons.water_drop_rounded,       "Cholesterol",       cholesterol,  _DS.accent1,  infoKey: 'Cholesterol'),
      _infoRow(Icons.science_rounded,          "Blood Sugar",       sugarLevel,   _DS.accent4,  infoKey: 'Sugar'),
      _infoRow(Icons.medical_services_rounded, "Thyroid Status",    thyroidStatus,_DS.accent5,  infoKey: 'Thyroid'),
    ]);
  }

  // ── Nutrient section ──────────────────────────────────────────────────────
  Widget _buildNutrientSection() {
    return _infoCard([
      _infoRow(Icons.opacity_rounded,          "Vitamin D Level",           vitaminD,   _DS.accent4, infoKey: 'Vitamin D'),
      _infoRow(Icons.grain_rounded,            "Iron / Ferritin",           ironFerritin, _DS.accent3, infoKey: 'Iron'),
      _infoRow(Icons.person_2_rounded,         "Bone Density (T-score)",    boneDensity, _DS.accent2, infoKey: 'Bone Density'),
    ]);
  }

  // ── Body section ──────────────────────────────────────────────────────────
  Widget _buildBodySection() {
    return _infoCard([
      _infoRow(Icons.straighten_rounded,       "Waist Circumference",  waist, _DS.accent2, unit: "cm"),
      _infoRow(Icons.straighten_rounded,       "Hip Circumference",    hip,   _DS.accent5, unit: "cm"),
    ]);
  }

  // ── Lifestyle section ─────────────────────────────────────────────────────
  Widget _buildLifestyleSection() {
    return _infoCard([
      _infoRow(Icons.smoking_rooms_rounded,    "Smoking",          smoking,       _DS.accent3),
      _infoRow(Icons.local_bar_rounded,        "Alcohol Consumption", alcohol,   _DS.accent4),
      _infoRow(Icons.directions_run_rounded,   "Physical Activity", activityLevel, _DS.accent1),
    ]);
  }

  // ── Info card container ───────────────────────────────────────────────────
  Widget _infoCard(List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _DS.borderFaint, width: 1),
      ),
      child: Column(
        children: rows.map((r) => Column(
          children: [r, Container(height: 1, color: _DS.borderFaint.withOpacity(0.5))],
        )).toList()
          ..last = Column(children: [rows.last]),
      ),
    );
  }

  // ── Info row ──────────────────────────────────────────────────────────────
  Widget _infoRow(
      IconData icon,
      String label,
      String value,
      Color color, {
        String?  unit,
        String?  infoKey,
        bool     required = false,
      }) {
    final displayValue = (value == '—' || value.trim().isEmpty)
        ? 'Not set'
        : '${value}${unit != null ? ' $unit' : ''}';
    final isSet = value != '—' && value.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(label,
                        style: TextStyle(color: _DS.textMuted, fontSize: 10,
                            fontWeight: FontWeight.w600, letterSpacing: 0.3)),
                    if (required)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text("*", style: TextStyle(color: _DS.accent3, fontSize: 10, fontWeight: FontWeight.w900)),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  displayValue,
                  style: TextStyle(
                    color: isSet ? _DS.textPrimary : _DS.textMuted,
                    fontSize: 14,
                    fontWeight: isSet ? FontWeight.w600 : FontWeight.w400,
                    fontStyle: isSet ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          if (infoKey != null)
            GestureDetector(
              onTap: () => _showMedicalInfo(infoKey),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _DS.accent1.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _DS.accent1.withOpacity(0.2), width: 1),
                ),
                child: const Icon(Icons.info_outline_rounded, color: _DS.accent1, size: 15),
              ),
            ),
        ],
      ),
    );
  }

  // ── Edit button ───────────────────────────────────────────────────────────
  Widget _buildEditButton() {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('id', userId);
        if (!mounted) return;

        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditHealthProfileScreen()),
        );

        if (mounted) _fetchHealthData();
      },
      child: AnimatedBuilder(
        animation: _glowAnim,
        builder: (_, __) => Container(
          width: double.infinity,
          height: 60,
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
              const Icon(Icons.edit_rounded, color: _DS.bg, size: 20),
              const SizedBox(width: 10),
              Text("Edit Health Profile",
                  style: TextStyle(color: _DS.bg, fontSize: 16,
                      fontWeight: FontWeight.w900, letterSpacing: 0.3)),
            ],
          ),
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  MEDICAL INFO BOTTOM SHEET                                               ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class _MedicalInfoSheet extends StatelessWidget {
  final _MedicalInfo info;
  const _MedicalInfoSheet({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1A13),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: info.color.withOpacity(0.3), width: 1.2),
        boxShadow: [
          BoxShadow(color: info.color.withOpacity(0.12), blurRadius: 32, offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF2E6B4A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: info.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: info.color.withOpacity(0.3), width: 1),
                ),
                child: Icon(Icons.medical_information_rounded, color: info.color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(info.title,
                  style: const TextStyle(color: Color(0xFFF0FFF8), fontSize: 18,
                      fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 20),

          // What it is
          _sheetSection("What is it?", info.whatItIs, Icons.help_outline_rounded, const Color(0xFF00E5FF)),
          const SizedBox(height: 16),

          // Normal range
          _sheetSection("Normal Range", info.normalRange, Icons.straighten_rounded, const Color(0xFF00FF88)),
          const SizedBox(height: 16),

          // Where to find
          _sheetSection("Where to find it?", info.whereToFind, Icons.find_in_page_rounded, const Color(0xFFFFD166)),
          const SizedBox(height: 24),

          // "I don't know" button
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: "You can update this later from your lab report.",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: const Color(0xFF0C1A13),
                textColor: const Color(0xFF00FF88),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF003D22),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3), width: 1),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.help_center_rounded, color: Color(0xFF00FF88), size: 18),
                  SizedBox(width: 8),
                  Text("I don't know this value — skip for now",
                      style: TextStyle(color: Color(0xFF00FF88), fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
          Center(
            child: Text("Skipped values won't block profile creation.",
                style: TextStyle(color: const Color(0xFF2E6B4A), fontSize: 11)),
          ),

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 8),
        ],
      ),
    );
  }

  Widget _sheetSection(String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.18), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(title,
                  style: TextStyle(color: color, fontSize: 11,
                      fontWeight: FontWeight.w800, letterSpacing: 0.3)),
            ],
          ),
          const SizedBox(height: 8),
          Text(content,
              style: const TextStyle(color: Color(0xFF6EE7B7), fontSize: 13,
                  height: 1.55, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}





// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'edit_health.dart'; // ← make sure this file exists & exports EditHealthProfileScreen
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primaryColor: const Color(0xFF4CAF50),
//         scaffoldBackgroundColor: const Color(0xFFF8FAFC),
//         colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
//         useMaterial3: true,
//         cardTheme: CardThemeData(                          // ← FIXED HERE
//           elevation: 2,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           color: Colors.white,
//           surfaceTintColor: Colors.transparent,            // recommended for M3
//         ),
//       ),
//       home: const HealthProfilePage(),
//     );
//   }
// }
//
// class HealthProfilePage extends StatefulWidget {
//   const HealthProfilePage({super.key});
//
//   @override
//   State<HealthProfilePage> createState() => _HealthProfilePageState();
// }
//
// class _HealthProfilePageState extends State<HealthProfilePage> {
//   bool _isLoading = true;
//   bool _hasError = false;
//   String _errorMsg = '';
//
//   // Health fields
//   String height = '—';
//   String weight = '—';
//   String bmi = '—';
//   String bloodGroup = '—';
//   String isCardiac = '—';
//   String bodyType = '—';
//   String bp = '—';
//   String cholesterol = '—';
//   String sugarLevel = '—';
//   String thyroidStatus = '—';
//   String waist = '—';
//   String hip = '—';
//   String boneDensity = '—';
//   String vitaminD = '—';
//   String ironFerritin = '—';
//   String smoking = '—';
//   String alcohol = '—';
//   String activityLevel = '—';
//   String userId = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchHealthData();
//   }
//
//   Future<void> _fetchHealthData() async {
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//       _errorMsg = '';
//     });
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final baseUrl = prefs.getString('url') ?? '';
//       final lid = prefs.getString('lid') ?? '';
//
//       if (baseUrl.isEmpty || lid.isEmpty) {
//         throw Exception('Missing server URL or login ID');
//       }
//
//       final uri = Uri.parse('$baseUrl/view_health_profile/');
//       final response = await http.post(
//         uri,
//         body: {'lid': lid},
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body) as Map<String, dynamic>;
//
//         if (data['status'] == 'ok') {
//           setState(() {
//             userId = data['id']?.toString() ?? '';
//             height = data['Height']?.toString() ?? '—';
//             weight = data['Weight']?.toString() ?? '—';
//             bmi = data['Bmi']?.toString() ?? '—';
//             bloodGroup = data['Blood_Group']?.toString() ?? '—';
//             isCardiac = data['Is_Cardiac']?.toString() ?? '—';
//             bodyType = data['Body_Type']?.toString() ?? '—';
//             bp = data['Bp']?.toString() ?? '—';
//             cholesterol = data['Cholestrol']?.toString() ?? '—'; // note spelling
//             sugarLevel = data['Sugar_level']?.toString() ?? '—';
//             thyroidStatus = data['Thyroid_Status']?.toString() ?? '—';
//             waist = data['Waist_Circumference']?.toString() ?? '—';
//             hip = data['Hip_Circumference']?.toString() ?? '—';
//             boneDensity = data['Bone_Density_Tscore']?.toString() ?? '—';
//             vitaminD = data['Vitamin_D_Level']?.toString() ?? '—';
//             ironFerritin = data['Iron_Ferritin']?.toString() ?? '—';
//             smoking = data['Smoking']?.toString() ?? '—';
//             alcohol = data['Alcohol_Consumption']?.toString() ?? '—';
//             activityLevel = data['Physical_Activity_Level']?.toString() ?? '—';
//           });
//         } else {
//           setState(() {
//             _hasError = true;
//             _errorMsg = data['message']?.toString() ?? 'Data not found';
//           });
//         }
//       } else {
//         setState(() {
//           _hasError = true;
//           _errorMsg = 'Server responded with status ${response.statusCode}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _hasError = true;
//         _errorMsg = e.toString().replaceFirst('Exception: ', '');
//       });
//       if (mounted) {
//         Fluttertoast.showToast(
//           msg: _errorMsg,
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.BOTTOM,
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   String _getBmiCategory(double? bmiValue) {
//     if (bmiValue == null) return '';
//     if (bmiValue < 18.5) return 'Underweight';
//     if (bmiValue < 25) return 'Normal';
//     if (bmiValue < 30) return 'Overweight';
//     return 'Obese';
//   }
//
//   Color? _getBmiColor(double? bmiValue) {
//     if (bmiValue == null) return null;
//     if (bmiValue < 18.5 || bmiValue >= 30) return Colors.red[700];
//     if (bmiValue >= 25) return Colors.orange[700];
//     return const Color(0xFF4CAF50);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final parsedBmi = double.tryParse(bmi);
//     final bmiColor = _getBmiColor(parsedBmi);
//     final bmiCategory = _getBmiCategory(parsedBmi);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Health Profile'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh_rounded),
//             onPressed: _fetchHealthData,
//             tooltip: 'Refresh',
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _hasError
//           ? Center(
//         child: Padding(
//           padding: const EdgeInsets.all(32),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.error_outline_rounded,
//                   size: 80, color: Colors.red[300]),
//               const SizedBox(height: 24),
//               Text(
//                 'Failed to load health data',
//                 style: Theme.of(context).textTheme.titleLarge,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 _errorMsg,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.grey[700]),
//               ),
//               const SizedBox(height: 32),
//               OutlinedButton.icon(
//                 onPressed: _fetchHealthData,
//                 icon: const Icon(Icons.refresh),
//                 label: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       )
//           : RefreshIndicator(
//         onRefresh: _fetchHealthData,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Quick stats card
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       _buildQuickStat('Height', height, 'cm'),
//                       _buildQuickStat('Weight', weight, 'kg'),
//                       _buildQuickStat(
//                         'BMI',
//                         bmi,
//                         bmiCategory,
//                         color: bmiColor,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//
//               _buildSectionCard(
//                 title: 'Body Composition',
//                 children: [
//                   _buildInfoRow(Icons.straighten, 'Body Type', bodyType),
//                   _buildInfoRow(Icons.monitor_weight,
//                       'Waist Circumference', waist, unit: 'cm'),
//                   _buildInfoRow(Icons.monitor_weight_outlined,
//                       'Hip Circumference', hip, unit: 'cm'),
//                 ],
//               ),
//
//               const SizedBox(height: 16),
//
//               _buildSectionCard(
//                 title: 'Vital Signs & Risks',
//                 children: [
//                   _buildInfoRow(Icons.favorite_border, 'Blood Pressure', bp),
//                   _buildInfoRow(Icons.bloodtype, 'Blood Group', bloodGroup),
//                   _buildInfoRow(Icons.heart_broken_outlined, 'Cardiac Risk', isCardiac),
//                   _buildInfoRow(Icons.water_drop, 'Cholesterol', cholesterol),
//                   _buildInfoRow(Icons.science, 'Blood Sugar', sugarLevel),
//                   _buildInfoRow(Icons.medical_services, 'Thyroid Status', thyroidStatus),
//                 ],
//               ),
//
//               const SizedBox(height: 16),
//
//               _buildSectionCard(
//                 title: 'Nutrient & Bone Health',
//                 children: [
//                   _buildInfoRow(Icons.opacity, 'Vitamin D Level', vitaminD),
//                   _buildInfoRow(Icons.grain, 'Iron / Ferritin', ironFerritin),
//                   _buildInfoRow(Icons.person, 'Bone Density (T-score)', boneDensity),
//                 ],
//               ),
//
//               const SizedBox(height: 16),
//
//               _buildSectionCard(
//                 title: 'Lifestyle Factors',
//                 children: [
//                   _buildInfoRow(Icons.smoking_rooms, 'Smoking', smoking),
//                   _buildInfoRow(Icons.local_bar, 'Alcohol Consumption', alcohol),
//                   _buildInfoRow(
//                       Icons.directions_run, 'Physical Activity Level', activityLevel),
//                 ],
//               ),
//
//               const SizedBox(height: 40),
//
//               // Edit button
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton.icon(
//                   onPressed: () async {
//                     final prefs = await SharedPreferences.getInstance();
//                     await prefs.setString('id', userId);
//                     if (!mounted) return;
//
//                     await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const EditHealthProfileScreen(),
//                       ),
//                     );
//
//                     if (mounted) {
//                       _fetchHealthData();
//                     }
//                   },
//                   icon: const Icon(Icons.edit_outlined),
//                   label: const Text('Edit Health Profile'),
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     side: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
//                     foregroundColor: const Color(0xFF4CAF50),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 60),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildQuickStat(String label, String value, String? subtitle, {Color? color}) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 26,
//             fontWeight: FontWeight.bold,
//             color: color ?? const Color(0xFF4CAF50),
//           ),
//         ),
//         const SizedBox(height: 6),
//         Text(
//           label,
//           style: TextStyle(fontSize: 14, color: Colors.grey[700]),
//         ),
//         if (subtitle != null && subtitle.isNotEmpty)
//           Text(
//             subtitle,
//             style: TextStyle(
//               fontSize: 13,
//               color: color ?? Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildSectionCard({
//     required String title,
//     required List<Widget> children,
//   }) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 19,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 16),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(
//       IconData icon,
//       String label,
//       String value, {
//         String? unit,
//       }) {
//     final displayValue = (value == '—' || value.trim().isEmpty)
//         ? 'Not set'
//         : '$value${unit != null ? ' $unit' : ''}';
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Row(
//         children: [
//           Icon(icon, size: 24, color: const Color(0xFF4CAF50)),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(fontSize: 14, color: Colors.grey[700]),
//                 ),
//                 const SizedBox(height: 3),
//                 Text(
//                   displayValue,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }