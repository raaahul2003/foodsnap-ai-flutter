import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';


// ─────────────────────────────────────────────────────────────────────────────
//  DESIGN TOKENS  (matches app dark theme)
// ─────────────────────────────────────────────────────────────────────────────
class _DS {
  static const bg         = Color(0xFF050D0A);
  static const bgCard     = Color(0xFF0C1A13);
  static const surface    = Color(0xFF0F2018);
  static const neon       = Color(0xFF00FF88);
  static const neonDim    = Color(0xFF00C46A);
  static const neonFaint  = Color(0xFF003D22);
  static const accent1    = Color(0xFF00E5FF);
  static const accent2    = Color(0xFFB2FF59);
  static const accent3    = Color(0xFFFF6B6B);
  static const accent4    = Color(0xFFFFD166);
  static const accent5    = Color(0xFFA78BFA);
  static const textPrimary   = Color(0xFFF0FFF8);
  static const textSecondary = Color(0xFF6EE7B7);
  static const textMuted     = Color(0xFF4A8A68);
  static const borderFaint   = Color(0xFF112B1E);
}

// ─────────────────────────────────────────────────────────────────────────────
//  MEDICAL FIELD METADATA
// ─────────────────────────────────────────────────────────────────────────────
class _MedicalInfo {
  final String label;
  final String whatIs;
  final String normalRange;
  final String whereToFind;
  final String hint;
  final IconData icon;
  final Color color;
  final TextInputType keyboard;
  final String? unit;

  const _MedicalInfo({
    required this.label,
    required this.whatIs,
    required this.normalRange,
    required this.whereToFind,
    required this.hint,
    required this.icon,
    required this.color,
    this.keyboard = TextInputType.text,
    this.unit,
  });
}

const _medicalFields = {
  'bp': _MedicalInfo(
    label: 'Blood Pressure',
    whatIs:
    'Blood pressure measures the force of blood pushing against your artery walls. It\'s recorded as two numbers: systolic (top) over diastolic (bottom).',
    normalRange: 'Normal: 90/60 – 120/80 mmHg\nElevated: 120–129/< 80\nHigh: 130/80+',
    whereToFind:
    'Measured at any clinic, pharmacy kiosk, or home BP monitor. Also found in your doctor\'s visit notes.',
    hint: 'Format: 120/80',
    icon: Icons.favorite_border_rounded,
    color: _DS.accent3,
    unit: 'mmHg',
  ),
  'sugar': _MedicalInfo(
    label: 'Blood Sugar (Fasting)',
    whatIs:
    'Fasting blood glucose is measured after not eating for 8+ hours. It shows how well your body processes sugar.',
    normalRange: 'Normal: 70–99 mg/dL\nPre-diabetic: 100–125 mg/dL\nDiabetic: 126+ mg/dL',
    whereToFind:
    'Found in blood test reports (CBC / metabolic panel), glucometer reading, or doctor s prescription notes.',
    hint: 'e.g. 90  (mg/dL)',
    icon: Icons.science_rounded,
    color: _DS.accent4,
    keyboard: TextInputType.number,
    unit: 'mg/dL',
  ),
  'cholesterol': _MedicalInfo(
    label: 'Total Cholesterol',
    whatIs:
    'Cholesterol is a fatty substance in your blood. High levels increase the risk of heart disease and stroke.',
    normalRange: 'Desirable: < 200 mg/dL\nBorderline: 200–239 mg/dL\nHigh: 240+ mg/dL',
    whereToFind:
    'Found in lipid panel blood test reports. Often part of routine annual checkup lab reports.',
    hint: 'e.g. 180  (mg/dL)',
    icon: Icons.water_drop_rounded,
    color: _DS.accent4,
    keyboard: TextInputType.number,
    unit: 'mg/dL',
  ),
  'vitamin': _MedicalInfo(
    label: 'Vitamin D Level',
    whatIs:
    'Vitamin D is essential for bone health, immune function, and mood regulation. Deficiency is very common.',
    normalRange: 'Deficient: < 20 ng/mL\nInsufficient: 20–29 ng/mL\nSufficient: 30–100 ng/mL',
    whereToFind:
    'Found in blood test as "25-OH Vitamin D" or "Calcidiol". Request from your doctor or lab.',
    hint: 'e.g. 35  (ng/mL)',
    icon: Icons.wb_sunny_rounded,
    color: _DS.accent4,
    keyboard: TextInputType.number,
    unit: 'ng/mL',
  ),
  'iron': _MedicalInfo(
    label: 'Iron / Ferritin Level',
    whatIs:
    'Ferritin stores iron in your body. Low ferritin causes fatigue, hair loss, and anemia. High levels can indicate inflammation.',
    normalRange: 'Men: 24–336 ng/mL\nWomen: 11–307 ng/mL\nLow = Anemia risk',
    whereToFind:
    'Found in CBC (Complete Blood Count) or serum ferritin test. Available in routine health checkup reports.',
    hint: 'e.g. 80  (ng/mL)',
    icon: Icons.grain_rounded,
    color: _DS.accent1,
    keyboard: TextInputType.number,
    unit: 'ng/mL',
  ),
  'waist': _MedicalInfo(
    label: 'Waist Circumference',
    whatIs:
    'Waist size measures abdominal fat which is a stronger indicator of cardiovascular risk than BMI alone.',
    normalRange: 'Low risk Men: < 94 cm  Women: < 80 cm\nHigh risk Men: > 102 cm  Women: > 88 cm',
    whereToFind:
    'Measure with a tape measure around your navel while standing. No medical test needed.',
    hint: 'e.g. 80  (cm)',
    icon: Icons.straighten_rounded,
    color: _DS.accent5,
    keyboard: TextInputType.number,
    unit: 'cm',
  ),
  'hip': _MedicalInfo(
    label: 'Hip Circumference',
    whatIs:
    'Hip measurement combined with waist gives the Waist-to-Hip Ratio (WHR), a key metric for fat distribution and metabolic risk.',
    normalRange: 'Healthy WHR  Men: < 0.90  Women: < 0.85',
    whereToFind:
    'Measure with a tape measure around the widest part of your hips/buttocks. No medical test needed.',
    hint: 'e.g. 95  (cm)',
    icon: Icons.accessibility_new_rounded,
    color: _DS.accent5,
    keyboard: TextInputType.number,
    unit: 'cm',
  ),
  'bodyDensity': _MedicalInfo(
    label: 'Bone Density T-score',
    whatIs:
    'A T-score from a DEXA scan shows how your bone density compares to a healthy 30-year-old. Used to diagnose osteoporosis.',
    normalRange: 'Normal: ≥ –1.0\nOsteopenia: –1.0 to –2.5\nOsteoporosis: < –2.5',
    whereToFind:
    'Found in DEXA (Dual-energy X-ray absorptiometry) scan report. Usually done by orthopedic doctors.',
    hint: 'e.g. –0.5',
    icon: Icons.monitor_heart_rounded,
    color: _DS.accent1,
    unit: 'T-score',
  ),
  'bloodGroup': _MedicalInfo(
    label: 'Blood Group',
    whatIs:
    'Your ABO blood type (A, B, AB, O) and Rh factor (positive/negative). Important for transfusions and some dietary recommendations.',
    normalRange: 'Types: A+, A–, B+, B–, AB+, AB–, O+, O–',
    whereToFind:
    'Found on blood donation card, hospital records, or any blood test report. Parents\' blood group can also suggest yours.',
    hint: 'e.g. O+, AB–',
    icon: Icons.bloodtype_rounded,
    color: _DS.accent3,
  ),
};

// ─────────────────────────────────────────────────────────────────────────────
//  PAGE
// ─────────────────────────────────────────────────────────────────────────────
class AddHealthProfilePage extends StatefulWidget {
  const AddHealthProfilePage({super.key});

  @override
  State<AddHealthProfilePage> createState() => _AddHealthProfilePageState();
}

class _AddHealthProfilePageState extends State<AddHealthProfilePage>
    with TickerProviderStateMixin {
  bool _isSubmitting = false;
  bool _advancedMode = false;

  // Essential controllers
  final _heightCtrl      = TextEditingController();
  final _weightCtrl      = TextEditingController();
  final _ageCtrl         = TextEditingController();
  final _bmiCtrl         = TextEditingController();
  final _activityCtrl    = TextEditingController();

  // Medical controllers
  final _bloodGroupCtrl  = TextEditingController();
  final _bodyTypeCtrl    = TextEditingController();
  final _bpCtrl          = TextEditingController();
  final _cholesterolCtrl = TextEditingController();
  final _sugarCtrl       = TextEditingController();
  final _waistCtrl       = TextEditingController();
  final _hipCtrl         = TextEditingController();
  final _vitaminCtrl     = TextEditingController();
  final _ironCtrl        = TextEditingController();
  final _boneDensityCtrl = TextEditingController();

  // Toggle state
  String? _gender         = null;
  String? _hasCardiacRisk = 'no';
  String? _hasThyroid     = 'no';
  String? _smoking        = 'no';
  String? _alcohol        = 'no';
  String? _suggestedGoal  = null;

  // "I don't know" nulls
  final Set<String> _unknownFields = {};

  // BMI computed
  double? _bmiValue;
  String  _bmiCategory  = '';
  Color   _bmiColor     = _DS.textMuted;

  // Health Risk Score (0–100, lower = better risk level)
  int _riskScore = 0;

  // Animation
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  // Validation errors
  final Map<String, String?> _errors = {};

  // Activity choices
  final List<String> _activityLevels = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
    'Extremely Active',
  ];
  String? _selectedActivity;

  @override
  void initState() {
    super.initState();
    _heightCtrl.addListener(_onMetricsChanged);
    _weightCtrl.addListener(_onMetricsChanged);
    _bpCtrl.addListener(_recalcRisk);
    _sugarCtrl.addListener(_recalcRisk);
    _cholesterolCtrl.addListener(_recalcRisk);

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  void _onMetricsChanged() {
    _calculateBMI();
    _recalcRisk();
  }

  void _calculateBMI() {
    final h = double.tryParse(_heightCtrl.text.trim());
    final w = double.tryParse(_weightCtrl.text.trim());
    if (h != null && w != null && h > 0 && w > 0) {
      final hm  = h / 100;
      final bmi = w / (hm * hm);
      String cat;
      Color   col;
      String? goal;
      if (bmi < 18.5) {
        cat  = 'Underweight';
        col  = _DS.accent1;
        goal = 'weight_gain';
      } else if (bmi < 25) {
        cat  = 'Normal';
        col  = _DS.neon;
        goal = 'balanced';
      } else if (bmi < 30) {
        cat  = 'Overweight';
        col  = _DS.accent4;
        goal = 'fat_loss';
      } else {
        cat  = 'Obese';
        col  = _DS.accent3;
        goal = 'fat_loss';
      }
      setState(() {
        _bmiValue    = bmi;
        _bmiCtrl.text = bmi.toStringAsFixed(1);
        _bmiCategory = cat;
        _bmiColor    = col;
        _suggestedGoal = goal;
      });
    } else {
      setState(() {
        _bmiValue    = null;
        _bmiCtrl.text = '';
        _bmiCategory = '';
        _bmiColor    = _DS.textMuted;
        _suggestedGoal = null;
      });
    }
  }

  void _recalcRisk() {
    int risk = 0;

    // BMI risk
    if (_bmiValue != null) {
      if (_bmiValue! >= 30)       risk += 20;
      else if (_bmiValue! >= 25)  risk += 10;
      else if (_bmiValue! < 18.5) risk += 5;
    }

    // Smoking / alcohol
    if (_smoking  == 'yes') risk += 20;
    if (_alcohol  == 'yes') risk += 10;

    // Cardiac risk
    if (_hasCardiacRisk == 'yes') risk += 15;

    // Thyroid
    if (_hasThyroid == 'yes') risk += 5;

    // Sugar
    final sugar = double.tryParse(_sugarCtrl.text.trim());
    if (sugar != null) {
      if (sugar >= 126)      risk += 20;
      else if (sugar >= 100) risk += 10;
    }

    // BP – parse systolic
    final bpParts = _bpCtrl.text.trim().split('/');
    if (bpParts.length == 2) {
      final sys = double.tryParse(bpParts[0].trim());
      if (sys != null) {
        if (sys >= 140)      risk += 15;
        else if (sys >= 130) risk += 8;
      }
    }

    // Cholesterol
    final chol = double.tryParse(_cholesterolCtrl.text.trim());
    if (chol != null) {
      if (chol >= 240)      risk += 15;
      else if (chol >= 200) risk += 8;
    }

    setState(() => _riskScore = risk.clamp(0, 100));
  }

  String get _riskLabel {
    if (_riskScore <= 15) return 'Low';
    if (_riskScore <= 35) return 'Moderate';
    if (_riskScore <= 55) return 'High';
    return 'Very High';
  }

  Color get _riskColor {
    if (_riskScore <= 15) return _DS.neon;
    if (_riskScore <= 35) return _DS.accent4;
    if (_riskScore <= 55) return _DS.accent3;
    return const Color(0xFFFF3B3B);
  }

  // ─── Validation ──────────────────────────────────────────────────────────
  bool _validate() {
    final errs = <String, String?>{};

    if (_heightCtrl.text.trim().isEmpty) errs['height'] = 'Height is required';
    else if ((double.tryParse(_heightCtrl.text.trim()) ?? 0) <= 0)
      errs['height'] = 'Enter a valid height';

    if (_weightCtrl.text.trim().isEmpty) errs['weight'] = 'Weight is required';
    else if ((double.tryParse(_weightCtrl.text.trim()) ?? 0) <= 0)
      errs['weight'] = 'Enter a valid weight';

    if (_ageCtrl.text.trim().isEmpty) errs['age'] = 'Age is required';
    else {
      final age = int.tryParse(_ageCtrl.text.trim()) ?? 0;
      if (age < 5 || age > 120) errs['age'] = 'Enter a valid age (5–120)';
    }

    if (_gender == null) errs['gender'] = 'Please select a gender';

    if (_selectedActivity == null) errs['activity'] = 'Select activity level';

    // BP format
    final bp = _bpCtrl.text.trim();
    if (bp.isNotEmpty && !_unknownFields.contains('bp')) {
      final parts = bp.split('/');
      if (parts.length != 2 ||
          double.tryParse(parts[0].trim()) == null ||
          double.tryParse(parts[1].trim()) == null) {
        errs['bp'] = 'Format must be 120/80';
      }
    }

    // Numeric fields
    for (final key in ['sugar', 'cholesterol', 'waist', 'hip']) {
      final ctrl = _ctrlFor(key);
      if (ctrl.text.trim().isNotEmpty && !_unknownFields.contains(key)) {
        if (double.tryParse(ctrl.text.trim()) == null) {
          errs[key] = 'Must be a number';
        }
      }
    }

    setState(() => _errors..clear()..addAll(errs));
    return errs.isEmpty;
  }

  TextEditingController _ctrlFor(String key) {
    switch (key) {
      case 'bp':          return _bpCtrl;
      case 'sugar':       return _sugarCtrl;
      case 'cholesterol': return _cholesterolCtrl;
      case 'waist':       return _waistCtrl;
      case 'hip':         return _hipCtrl;
      default:            return _bpCtrl;
    }
  }

  // ─── Submit ──────────────────────────────────────────────────────────────
  Future<void> _confirmAndSubmit() async {
    if (!_validate()) {
      Fluttertoast.showToast(msg: "Please fix the errors before saving");
      return;
    }

    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: _DS.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _DS.neonFaint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology_rounded,
                    color: _DS.neon, size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Save Health Profile?',
                  style: TextStyle(
                      color: _DS.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              const Text(
                'This data will be used by our AI engine to personalize your daily calorie goal, macro distribution, and diet plan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _DS.textMuted,
                    fontSize: 13,
                    height: 1.5),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _DS.textMuted,
                      side: const BorderSide(color: _DS.borderFaint),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Review'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _DS.neon,
                      foregroundColor: _DS.bg,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Confirm',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;
    await _submitHealthProfile();
  }

  Future<void> _submitHealthProfile() async {
    setState(() => _isSubmitting = true);
    try {
      final prefs   = await SharedPreferences.getInstance();
      final baseUrl = prefs.getString('url');
      final lid     = prefs.getString('lid');

      if (baseUrl == null || lid == null) {
        Fluttertoast.showToast(msg: "Missing configuration");
        return;
      }

      String _valOrNull(String key, TextEditingController ctrl) =>
          _unknownFields.contains(key) ? '' : ctrl.text.trim();

      final uri     = Uri.parse('$baseUrl/user_add_health_profile_post/');
      final request = http.MultipartRequest('POST', uri);
      request.fields.addAll({
        'height':      _heightCtrl.text.trim(),
        'weight':      _weightCtrl.text.trim(),
        'age':         _ageCtrl.text.trim(),
        'gender':      _gender ?? '',
        'bmi':         _bmiCtrl.text.trim(),
        'bloodg':      _valOrNull('bloodGroup', _bloodGroupCtrl),
        'cardiac':     _hasCardiacRisk ?? 'no',
        'bodytype':    _bodyTypeCtrl.text.trim(),
        'bp':          _valOrNull('bp', _bpCtrl),
        'cholestrol':  _valOrNull('cholesterol', _cholesterolCtrl),
        'sugarlevel':  _valOrNull('sugar', _sugarCtrl),
        'thyroid':     _hasThyroid ?? 'no',
        'waist':       _valOrNull('waist', _waistCtrl),
        'hip':         _valOrNull('hip', _hipCtrl),
        'vitamin':     _valOrNull('vitamin', _vitaminCtrl),
        'iron':        _valOrNull('iron', _ironCtrl),
        'smoking':     _smoking ?? 'no',
        'alcohol':     _alcohol ?? 'no',
        'physical':    _selectedActivity ?? '',
        'bodydensity': _valOrNull('bodyDensity', _boneDensityCtrl),
        'goal_mode':   _suggestedGoal ?? 'balanced',
        'lid':         lid,
      });

      final streamed  = await request.send();
      final response  = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'ok') {
          await prefs.setString('h', 'yes');
          await prefs.setString('gender', _gender ?? '');
          Fluttertoast.showToast(
              msg: "Health profile saved! AI goals calculated.",
              backgroundColor: const Color(0xFF00C46A));
          if (!mounted) return;
          Navigator.push(context, MaterialPageRoute(builder: (context)=> UserHome()));
          return;
        }
      }
      Fluttertoast.showToast(msg: "Failed to save profile");
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString().split('\n').first}");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ─── Info bottom sheet ────────────────────────────────────────────────────
  void _showInfoSheet(String fieldKey) {
    final info = _medicalFields[fieldKey]!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MedicalInfoSheet(
        info: info,
        fieldKey: fieldKey,
        isUnknown: _unknownFields.contains(fieldKey),
        onMarkUnknown: (key, val) {
          setState(() {
            if (val) {
              _unknownFields.add(key);
            } else {
              _unknownFields.remove(key);
            }
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    for (final c in [
      _heightCtrl, _weightCtrl, _ageCtrl, _bmiCtrl,
      _bloodGroupCtrl, _bodyTypeCtrl, _bpCtrl,
      _cholesterolCtrl, _sugarCtrl, _waistCtrl, _hipCtrl,
      _vitaminCtrl, _ironCtrl, _activityCtrl, _boneDensityCtrl,
    ]) c.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _DS.bg,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 16),

                    // ── Mode toggle ─────────────────────────────────────────
                    _buildModeToggle(),
                    const SizedBox(height: 20),

                    // ── BMI + Risk cards ────────────────────────────────────
                    Row(children: [
                      Expanded(child: _buildBMICard()),
                      const SizedBox(width: 12),
                      Expanded(child: _buildRiskCard()),
                    ]),
                    const SizedBox(height: 22),

                    // ── Section: Essential ──────────────────────────────────
                    _sectionHeader('Essential Information', Icons.star_rounded, _DS.neon),
                    const SizedBox(height: 14),
                    _buildEssentialSection(),

                    // ── Section: Lifestyle ──────────────────────────────────
                    const SizedBox(height: 22),
                    _sectionHeader('Lifestyle', Icons.self_improvement_rounded, _DS.accent2),
                    const SizedBox(height: 14),
                    _buildLifestyleSection(),

                    // ── Advanced mode: Medical ──────────────────────────────
                    if (_advancedMode) ...[
                      const SizedBox(height: 22),
                      _sectionHeader('Medical Records', Icons.biotech_rounded, _DS.accent1),
                      const SizedBox(height: 6),
                      _advancedNote(),
                      const SizedBox(height: 14),
                      _buildMedicalSection(),
                    ],

                    // ── Goal suggestion ─────────────────────────────────────
                    if (_suggestedGoal != null) ...[
                      const SizedBox(height: 22),
                      _buildGoalSuggestion(),
                    ],

                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  // ─── Sliver App Bar ───────────────────────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: _DS.bg,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _DS.surface,
            shape: BoxShape.circle,
            border: Border.all(color: _DS.borderFaint, width: 1),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: _DS.neon, size: 18),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF051510), Color(0xFF071A0F), _DS.bg],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _DS.neonFaint,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _DS.neon.withOpacity(0.3), width: 1),
                      ),
                      child:
                      const Icon(Icons.health_and_safety_rounded, color: _DS.neon, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Health Profile',
                            style: TextStyle(
                                color: _DS.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5)),
                        Text('Personalise your AI diet plan',
                            style: TextStyle(
                                color: _DS.textMuted, fontSize: 12)),
                      ],
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Mode toggle ──────────────────────────────────────────────────────────
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
          _modeTab('Basic Mode', Icons.tune_rounded, !_advancedMode, () {
            setState(() => _advancedMode = false);
          }),
          _modeTab('Advanced Mode', Icons.biotech_rounded, _advancedMode, () {
            setState(() => _advancedMode = true);
          }),
        ],
      ),
    );
  }

  Widget _modeTab(String label, IconData icon, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? _DS.neon : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: active ? _DS.bg : _DS.textMuted),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: active ? _DS.bg : _DS.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── BMI Card ─────────────────────────────────────────────────────────────
  Widget _buildBMICard() {
    final pct = _bmiValue != null ? (_bmiValue! / 40).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _bmiColor.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
              color: _bmiColor.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.calculate_rounded, size: 14, color: _bmiColor),
            const SizedBox(width: 5),
            Text('BMI',
                style: TextStyle(
                    color: _bmiColor, fontSize: 11, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          Text(
            _bmiValue != null ? _bmiValue!.toStringAsFixed(1) : '—',
            style: TextStyle(
                color: _DS.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -1),
          ),
          const SizedBox(height: 4),
          Text(
            _bmiCategory.isEmpty ? 'Enter height & weight' : _bmiCategory,
            style: TextStyle(
                color: _bmiColor,
                fontSize: 11,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: _bmiColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(_bmiColor),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Risk Card ────────────────────────────────────────────────────────────
  Widget _buildRiskCard() {
    final pct = (_riskScore / 100).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _riskColor.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
              color: _riskColor.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.shield_rounded, size: 14, color: _riskColor),
            const SizedBox(width: 5),
            Text('Health Risk',
                style: TextStyle(
                    color: _riskColor, fontSize: 11, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          Text(
            '$_riskScore',
            style: TextStyle(
                color: _DS.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -1),
          ),
          const SizedBox(height: 4),
          Text(_riskLabel,
              style: TextStyle(
                  color: _riskColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: _riskColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(_riskColor),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section header ───────────────────────────────────────────────────────
  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Icon(icon, size: 15, color: color),
      ),
      const SizedBox(width: 10),
      Text(title,
          style: const TextStyle(
              color: _DS.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2)),
    ]);
  }

  // ─── Essential section ────────────────────────────────────────────────────
  Widget _buildEssentialSection() {
    return Column(children: [
      Row(children: [
        Expanded(
          child: _inputField(
            ctrl: _heightCtrl,
            label: 'Height',
            icon: Icons.height_rounded,
            color: _DS.neon,
            keyboard: TextInputType.number,
            unit: 'cm',
            error: _errors['height'],
            hint: 'e.g. 170',
            required: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _inputField(
            ctrl: _weightCtrl,
            label: 'Weight',
            icon: Icons.monitor_weight_rounded,
            color: _DS.neon,
            keyboard: TextInputType.number,
            unit: 'kg',
            error: _errors['weight'],
            hint: 'e.g. 65',
            required: true,
          ),
        ),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: _inputField(
            ctrl: _ageCtrl,
            label: 'Age',
            icon: Icons.cake_rounded,
            color: _DS.accent2,
            keyboard: TextInputType.number,
            unit: 'yrs',
            error: _errors['age'],
            hint: 'e.g. 28',
            required: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _buildGenderSelector()),
      ]),
      const SizedBox(height: 12),
      _buildActivitySelector(),
    ]);
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Text('Gender',
              style: TextStyle(
                  color: _DS.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          const Text(' *',
              style: TextStyle(color: _DS.accent3, fontSize: 11)),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          _genderChip('Male', Icons.male_rounded, _DS.accent1),
          const SizedBox(width: 8),
          _genderChip('Female', Icons.female_rounded, _DS.accent3),
          const SizedBox(width: 8),
          _genderChip('Other', Icons.person_rounded, _DS.accent5),
        ]),
        if (_errors['gender'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(_errors['gender']!,
                style: const TextStyle(color: _DS.accent3, fontSize: 10)),
          ),
      ],
    );
  }

  Widget _genderChip(String val, IconData icon, Color color) {
    final selected = _gender == val.toLowerCase();
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _gender = val.toLowerCase());
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.18) : _DS.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? color : _DS.borderFaint, width: 1.2),
          ),
          child: Column(
            children: [
              Icon(icon, size: 16, color: selected ? color : _DS.textMuted),
              const SizedBox(height: 3),
              Text(val,
                  style: TextStyle(
                      color: selected ? color : _DS.textMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Text('Physical Activity Level',
              style: TextStyle(
                  color: _DS.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          const Text(' *',
              style: TextStyle(color: _DS.accent3, fontSize: 11)),
        ]),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _activityLevels.map((level) {
            final selected = _selectedActivity == level;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedActivity = level;
                  _recalcRisk();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: selected
                      ? _DS.neon.withOpacity(0.15)
                      : _DS.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: selected ? _DS.neon : _DS.borderFaint,
                      width: 1),
                ),
                child: Text(level,
                    style: TextStyle(
                        color: selected ? _DS.neon : _DS.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            );
          }).toList(),
        ),
        if (_errors['activity'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(_errors['activity']!,
                style: const TextStyle(color: _DS.accent3, fontSize: 10)),
          ),
      ],
    );
  }

  // ─── Lifestyle section ────────────────────────────────────────────────────
  Widget _buildLifestyleSection() {
    return Column(children: [
      _yesNoToggle('Cardiac Risk',
          Icons.favorite_border_rounded, _DS.accent3, _hasCardiacRisk,
              (v) => setState(() {
            _hasCardiacRisk = v;
            _recalcRisk();
          })),
      const SizedBox(height: 10),
      _yesNoToggle('Thyroid Condition',
          Icons.psychology_alt_rounded, _DS.accent4, _hasThyroid,
              (v) => setState(() {
            _hasThyroid = v;
            _recalcRisk();
          })),
      const SizedBox(height: 10),
      _yesNoToggle('Smoking',
          Icons.smoking_rooms_rounded, _DS.accent3, _smoking,
              (v) => setState(() {
            _smoking = v;
            _recalcRisk();
          })),
      const SizedBox(height: 10),
      _yesNoToggle('Alcohol Consumption',
          Icons.local_bar_rounded, _DS.accent4, _alcohol,
              (v) => setState(() {
            _alcohol = v;
            _recalcRisk();
          })),
    ]);
  }

  Widget _yesNoToggle(String label, IconData icon, Color color,
      String? value, ValueChanged<String?> onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: value == 'yes'
                ? color.withOpacity(0.3)
                : _DS.borderFaint,
            width: 1),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: _DS.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600))),
        _toggleBtn('No', value == 'no', _DS.textMuted, () => onChange('no')),
        const SizedBox(width: 6),
        _toggleBtn('Yes', value == 'yes', color, () => onChange('yes')),
      ]),
    );
  }

  Widget _toggleBtn(String label, bool active, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active ? color : _DS.borderFaint, width: 1),
        ),
        child: Text(label,
            style: TextStyle(
                color: active ? color : _DS.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ─── Medical section ──────────────────────────────────────────────────────
  Widget _buildMedicalSection() {
    final fields = [
      ('bp',          _bpCtrl,          'bp'),
      ('sugar',       _sugarCtrl,       'sugar'),
      ('cholesterol', _cholesterolCtrl, 'cholesterol'),
      ('vitamin',     _vitaminCtrl,     'vitamin'),
      ('iron',        _ironCtrl,        'iron'),
      ('waist',       _waistCtrl,       'waist'),
      ('hip',         _hipCtrl,         'hip'),
      ('bloodGroup',  _bloodGroupCtrl,  'bloodGroup'),
      ('bodyDensity', _boneDensityCtrl, 'bodyDensity'),
    ];

    return Column(
      children: fields.map((f) {
        final info = _medicalFields[f.$1]!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _medicalInputField(
            ctrl: f.$2,
            fieldKey: f.$1,
            info: info,
            error: _errors[f.$1],
          ),
        );
      }).toList(),
    );
  }

  Widget _advancedNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _DS.accent1.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _DS.accent1.withOpacity(0.15), width: 1),
      ),
      child: Row(children: [
        const Icon(Icons.info_outline_rounded, size: 14, color: _DS.accent1),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'All medical fields are optional. Tap ℹ to learn more. Use "I don\'t know" if you\'re unsure.',
            style: TextStyle(
                color: _DS.accent1, fontSize: 11, height: 1.4),
          ),
        ),
      ]),
    );
  }

  // ─── Goal suggestion banner ───────────────────────────────────────────────
  Widget _buildGoalSuggestion() {
    String goalText;
    IconData goalIcon;
    switch (_suggestedGoal) {
      case 'weight_gain':
        goalText = 'Based on your BMI, we suggest: Weight Gain Mode ⚡';
        goalIcon = Icons.trending_up_rounded;
        break;
      case 'fat_loss':
        goalText = 'Based on your BMI, we suggest: Weight Loss Mode 🎯';
        goalIcon = Icons.trending_down_rounded;
        break;
      default:
        goalText = 'Based on your BMI, we suggest: Balanced Mode 🌱';
        goalIcon = Icons.balance_rounded;
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DS.neonFaint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _DS.neon.withOpacity(0.3), width: 1),
      ),
      child: Row(children: [
        Icon(goalIcon, color: _DS.neon, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('AI Goal Suggestion',
                  style: TextStyle(
                      color: _DS.neon,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(goalText,
                  style: const TextStyle(
                      color: _DS.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.3)),
            ],
          ),
        ),
      ]),
    );
  }

  // ─── Bottom save bar ──────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      decoration: BoxDecoration(
        color: _DS.bg,
        border: Border(top: BorderSide(color: _DS.borderFaint, width: 1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _confirmAndSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _DS.neon,
            foregroundColor: _DS.bg,
            disabledBackgroundColor: _DS.neon.withOpacity(0.3),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: _isSubmitting
              ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  color: _DS.bg, strokeWidth: 2.5))
              : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.save_rounded, size: 18),
              SizedBox(width: 8),
              Text('Save Health Profile',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Input field (essential) ──────────────────────────────────────────────
  Widget _inputField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    required Color color,
    TextInputType keyboard = TextInputType.text,
    String? unit,
    String? error,
    String? hint,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(label,
              style: const TextStyle(
                  color: _DS.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          if (required)
            const Text(' *',
                style: TextStyle(color: _DS.accent3, fontSize: 11)),
          if (unit != null) ...[
            const Spacer(),
            Text(unit,
                style: const TextStyle(
                    color: _DS.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500)),
          ],
        ]),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboard,
          style: const TextStyle(
              color: _DS.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _DS.textMuted.withOpacity(0.6), fontSize: 13),
            prefixIcon: Icon(icon, color: color, size: 18),
            filled: true,
            fillColor: _DS.bgCard,
            errorText: error,
            errorStyle: const TextStyle(color: _DS.accent3, fontSize: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _DS.borderFaint, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: error != null
                      ? _DS.accent3.withOpacity(0.4)
                      : _DS.borderFaint,
                  width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: color, width: 1.5),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          ),
        ),
      ],
    );
  }

  // ─── Medical input field (with info icon + unknown toggle) ────────────────
  Widget _medicalInputField({
    required TextEditingController ctrl,
    required String fieldKey,
    required _MedicalInfo info,
    String? error,
  }) {
    final isUnknown = _unknownFields.contains(fieldKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row with info icon
        Row(children: [
          Expanded(
            child: Row(children: [
              Text(info.label,
                  style: const TextStyle(
                      color: _DS.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _showInfoSheet(fieldKey),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: info.color.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: info.color.withOpacity(0.25), width: 1),
                  ),
                  child: Icon(Icons.info_outline_rounded,
                      size: 11, color: info.color),
                ),
              ),
            ]),
          ),
          if (info.unit != null)
            Text(info.unit!,
                style: const TextStyle(
                    color: _DS.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 6),

        // Input or "I don't know" state
        if (isUnknown)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: _DS.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: info.color.withOpacity(0.2), width: 1,
                  style: BorderStyle.solid),
            ),
            child: Row(children: [
              Icon(Icons.help_outline_rounded, color: _DS.textMuted, size: 16),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Not set',
                        style: TextStyle(
                            color: _DS.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    Text('You can update later from lab report',
                        style: TextStyle(
                            color: _DS.textMuted,
                            fontSize: 10,
                            height: 1.3)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _unknownFields.remove(fieldKey)),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: info.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: info.color.withOpacity(0.25), width: 1),
                  ),
                  child: Text('Enter',
                      style: TextStyle(
                          color: info.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          )
        else
          TextField(
            controller: ctrl,
            keyboardType: info.keyboard,
            style: const TextStyle(
                color: _DS.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: info.hint,
              hintStyle: TextStyle(
                  color: _DS.textMuted.withOpacity(0.5), fontSize: 12),
              prefixIcon:
              Icon(info.icon, color: info.color, size: 18),
              suffixIcon: GestureDetector(
                onTap: () {
                  ctrl.clear();
                  setState(() => _unknownFields.add(fieldKey));
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _DS.textMuted.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text("?",
                      style: TextStyle(
                          color: _DS.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800)),
                ),
              ),
              filled: true,
              fillColor: _DS.bgCard,
              errorText: error,
              errorStyle:
              const TextStyle(color: _DS.accent3, fontSize: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                const BorderSide(color: _DS.borderFaint, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: error != null
                        ? _DS.accent3.withOpacity(0.4)
                        : _DS.borderFaint,
                    width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                BorderSide(color: info.color, width: 1.5),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            ),
          ),

        // Normal range hint
        if (!isUnknown) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => _showInfoSheet(fieldKey),
            child: Row(children: [
              const SizedBox(width: 2),
              Icon(Icons.info_outline_rounded,
                  size: 10, color: _DS.textMuted.withOpacity(0.6)),
              const SizedBox(width: 4),
              Text(info.normalRange.split('\n').first,
                  style: TextStyle(
                      color: _DS.textMuted.withOpacity(0.7),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500)),
            ]),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  MEDICAL INFO BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _MedicalInfoSheet extends StatelessWidget {
  final _MedicalInfo info;
  final String fieldKey;
  final bool isUnknown;
  final Function(String key, bool val) onMarkUnknown;

  const _MedicalInfoSheet({
    required this.info,
    required this.fieldKey,
    required this.isUnknown,
    required this.onMarkUnknown,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: info.color.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
              offset: const Offset(0, -4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _DS.borderFaint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: info.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: info.color.withOpacity(0.2), width: 1),
                    ),
                    child: Icon(info.icon, color: info.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(info.label,
                        style: const TextStyle(
                            color: _DS.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w900)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _DS.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: _DS.textMuted, size: 16),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),

                // What is it?
                _infoBlock('What is it?', info.whatIs, Icons.help_outline_rounded, _DS.accent1),
                const SizedBox(height: 14),

                // Normal range
                _infoBlock('Normal Range', info.normalRange, Icons.straighten_rounded, _DS.neon),
                const SizedBox(height: 14),

                // Where to find
                _infoBlock('Where to find it', info.whereToFind, Icons.search_rounded, _DS.accent2),
                const SizedBox(height: 20),

                // I don't know button
                GestureDetector(
                  onTap: () {
                    onMarkUnknown(fieldKey, !isUnknown);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isUnknown
                          ? _DS.neonFaint
                          : _DS.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isUnknown
                              ? _DS.neon.withOpacity(0.4)
                              : _DS.borderFaint,
                          width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isUnknown
                              ? Icons.check_circle_rounded
                              : Icons.help_outline_rounded,
                          color: isUnknown ? _DS.neon : _DS.textMuted,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isUnknown
                              ? "I'll enter this value"
                              : "I don't know this value",
                          style: TextStyle(
                              color:
                              isUnknown ? _DS.neon : _DS.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isUnknown) ...[
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'You can always update this later from your lab report',
                      style: TextStyle(
                          color: _DS.textMuted, fontSize: 10, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBlock(String title, String body, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.12), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 6),
            Text(title,
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3)),
          ]),
          const SizedBox(height: 8),
          Text(body,
              style: const TextStyle(
                  color: _DS.textSecondary,
                  fontSize: 12.5,
                  height: 1.55,
                  fontWeight: FontWeight.w400)),
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
// import 'package:eatwise_ai/viewHealth.dart';
// import 'package:eatwise_ai/home.dart';
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
//         inputDecorationTheme: InputDecorationTheme(
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide.none,
//           ),
//         ),
//       ),
//       home: const AddHealthProfilePage(),
//     );
//   }
// }
//
// class AddHealthProfilePage extends StatefulWidget {
//   const AddHealthProfilePage({super.key});
//
//   @override
//   State<AddHealthProfilePage> createState() => _AddHealthProfilePageState();
// }
//
// class _AddHealthProfilePageState extends State<AddHealthProfilePage> {
//   bool _isSubmitting = false;
//
//   // Controllers
//   final _heightCtrl = TextEditingController();
//   final _weightCtrl = TextEditingController();
//   final _bmiCtrl = TextEditingController();
//   final _bloodGroupCtrl = TextEditingController();
//   final _bodyTypeCtrl = TextEditingController();
//   final _bpCtrl = TextEditingController();
//   final _cholesterolCtrl = TextEditingController();
//   final _sugarCtrl = TextEditingController();
//   final _waistCtrl = TextEditingController();
//   final _hipCtrl = TextEditingController();
//   final _vitaminCtrl = TextEditingController();
//   final _ironCtrl = TextEditingController();
//   final _activityCtrl = TextEditingController();
//   final _boneDensityCtrl = TextEditingController();
//
//   // Yes/No states
//   String? _hasCardiacRisk = 'no';
//   String? _hasThyroid = 'no';
//   String? _smoking = 'no';
//   String? _alcohol = 'no';
//
//   @override
//   void initState() {
//     super.initState();
//     // Auto-calculate BMI when height or weight changes
//     _heightCtrl.addListener(_calculateBMI);
//     _weightCtrl.addListener(_calculateBMI);
//   }
//
//   void _calculateBMI() {
//     final hText = _heightCtrl.text.trim();
//     final wText = _weightCtrl.text.trim();
//
//     if (hText.isNotEmpty && wText.isNotEmpty) {
//       try {
//         final heightCm = double.parse(hText);
//         final weightKg = double.parse(wText);
//         if (heightCm > 0 && weightKg > 0) {
//           final heightM = heightCm / 100;
//           final bmi = weightKg / (heightM * heightM);
//           _bmiCtrl.text = bmi.toStringAsFixed(1);
//         }
//       } catch (_) {
//         _bmiCtrl.text = '';
//       }
//     } else {
//       _bmiCtrl.text = '';
//     }
//   }
//
//   Future<void> _submitHealthProfile() async {
//     if (_heightCtrl.text.trim().isEmpty || _weightCtrl.text.trim().isEmpty) {
//       Fluttertoast.showToast(msg: "Height and Weight are required");
//       return;
//     }
//
//     setState(() => _isSubmitting = true);
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final baseUrl = prefs.getString('url');
//       final lid = prefs.getString('lid');
//
//       if (baseUrl == null || lid == null) {
//         Fluttertoast.showToast(msg: "Missing configuration");
//         return;
//       }
//
//       final uri = Uri.parse('$baseUrl/user_add_health_profile_post/');
//       var request = http.MultipartRequest('POST', uri);
//
//       request.fields.addAll({
//         'height': _heightCtrl.text.trim(),
//         'weight': _weightCtrl.text.trim(),
//         'bmi': _bmiCtrl.text.trim(),
//         'bloodg': _bloodGroupCtrl.text.trim(),
//         'cardiac': _hasCardiacRisk ?? 'no',
//         'bodytype': _bodyTypeCtrl.text.trim(),
//         'bp': _bpCtrl.text.trim(),
//         'cholestrol': _cholesterolCtrl.text.trim(),
//         'sugarlevel': _sugarCtrl.text.trim(),
//         'thyroid': _hasThyroid ?? 'no',
//         'waist': _waistCtrl.text.trim(),
//         'hip': _hipCtrl.text.trim(),
//         'vitamin': _vitaminCtrl.text.trim(),
//         'iron': _ironCtrl.text.trim(),
//         'smoking': _smoking ?? 'no',
//         'alcohol': _alcohol ?? 'no',
//         'physical': _activityCtrl.text.trim(),
//         'bodydensity': _boneDensityCtrl.text.trim(),
//         'lid': lid,
//       });
//
//       final streamed = await request.send();
//       final response = await http.Response.fromStream(streamed);
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status'] == 'ok') {
//           Fluttertoast.showToast(
//             msg: "Health profile added successfully",
//             backgroundColor: Colors.green[700],
//           );
//           prefs.setString("h", "yes");
//           if (!mounted) return;
//           Navigator.push(context, MaterialPageRoute(builder: (context) => UserHome(),)); // or go to dashboard/home
//           return;
//         }
//       }
//
//       Fluttertoast.showToast(msg: "Failed to save profile");
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Error: ${e.toString().split('\n').first}");
//     } finally {
//       if (mounted) setState(() => _isSubmitting = false);
//     }
//   }
//
//   @override
//   void dispose() {
//     _heightCtrl.dispose();
//     _weightCtrl.dispose();
//     _bmiCtrl.dispose();
//     _bloodGroupCtrl.dispose();
//     _bodyTypeCtrl.dispose();
//     _bpCtrl.dispose();
//     _cholesterolCtrl.dispose();
//     _sugarCtrl.dispose();
//     _waistCtrl.dispose();
//     _hipCtrl.dispose();
//     _vitaminCtrl.dispose();
//     _ironCtrl.dispose();
//     _activityCtrl.dispose();
//     _boneDensityCtrl.dispose();
//     super.dispose();
//   }
//
//   Widget _buildTextField(
//       TextEditingController ctrl,
//       String label,
//       IconData icon, {
//         TextInputType keyboard = TextInputType.text,
//       }) {
//     return TextField(
//       controller: ctrl,
//       keyboardType: keyboard,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
//       ),
//     );
//   }
//
//   Widget _buildYesNoSection(String title, String? value, ValueChanged<String?> onChanged) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               Expanded(
//                 child: ChoiceChip(
//                   label: const Text("Yes"),
//                   selected: value == 'yes',
//                   onSelected: (_) => onChanged('yes'),
//                   selectedColor: const Color(0xFFE8F5E9),
//                   backgroundColor: Colors.grey[100],
//                   labelStyle: TextStyle(
//                     color: value == 'yes' ? const Color(0xFF4CAF50) : Colors.black87,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: ChoiceChip(
//                   label: const Text("No"),
//                   selected: value == 'no',
//                   onSelected: (_) => onChanged('no'),
//                   selectedColor: const Color(0xFFE8F5E9),
//                   backgroundColor: Colors.grey[100],
//                   labelStyle: TextStyle(
//                     color: value == 'no' ? const Color(0xFF4CAF50) : Colors.black87,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Add Health Profile"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const Text(
//                 "Help us personalize your calorie & nutrition insights",
//                 style: TextStyle(fontSize: 15, color: Colors.grey),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 32),
//
//               // Basic Metrics
//               _buildTextField(_heightCtrl, "Height (cm)", Icons.straighten, keyboard: TextInputType.number),
//               const SizedBox(height: 16),
//               _buildTextField(_weightCtrl, "Weight (kg)", Icons.monitor_weight, keyboard: TextInputType.number),
//               const SizedBox(height: 16),
//               _buildTextField(_bmiCtrl, "BMI (auto-calculated)", Icons.calculate_outlined, keyboard: TextInputType.number),
//
//               const SizedBox(height: 24),
//
//               // Yes/No quick toggles
//               _buildYesNoSection("Any cardiac risk?", _hasCardiacRisk, (v) => setState(() => _hasCardiacRisk = v)),
//               const SizedBox(height: 16),
//               _buildYesNoSection("Thyroid condition?", _hasThyroid, (v) => setState(() => _hasThyroid = v)),
//               const SizedBox(height: 16),
//               _buildYesNoSection("Do you smoke?", _smoking, (v) => setState(() => _smoking = v)),
//               const SizedBox(height: 16),
//               _buildYesNoSection("Alcohol consumption?", _alcohol, (v) => setState(() => _alcohol = v)),
//
//               const SizedBox(height: 24),
//
//               // Other fields
//               _buildTextField(_bloodGroupCtrl, "Blood Group", Icons.bloodtype),
//               const SizedBox(height: 16),
//               _buildTextField(_bodyTypeCtrl, "Body Type (e.g. Ectomorph)", Icons.accessibility_new),
//               const SizedBox(height: 16),
//               _buildTextField(_bpCtrl, "Blood Pressure (e.g. 120/80)", Icons.favorite_border),
//               const SizedBox(height: 16),
//               _buildTextField(_cholesterolCtrl, "Cholesterol Level", Icons.water_drop),
//               const SizedBox(height: 16),
//               _buildTextField(_sugarCtrl, "Blood Sugar Level", Icons.science),
//               const SizedBox(height: 16),
//               _buildTextField(_waistCtrl, "Waist Circumference (cm)", Icons.monitor_weight, keyboard: TextInputType.number),
//               const SizedBox(height: 16),
//               _buildTextField(_hipCtrl, "Hip Circumference (cm)", Icons.monitor_weight_outlined, keyboard: TextInputType.number),
//               const SizedBox(height: 16),
//               _buildTextField(_vitaminCtrl, "Vitamin D Level", Icons.opacity),
//               const SizedBox(height: 16),
//               _buildTextField(_ironCtrl, "Iron / Ferritin Level", Icons.grain),
//               const SizedBox(height: 16),
//               _buildTextField(_activityCtrl, "Physical Activity Level", Icons.directions_run),
//               const SizedBox(height: 16),
//               _buildTextField(_boneDensityCtrl, "Bone Density T-score", Icons.monitor_heart),
//
//               const SizedBox(height: 40),
//
//               // Submit
//               SizedBox(
//                 height: 56,
//                 child: ElevatedButton.icon(
//                   onPressed: _isSubmitting ? null : _submitHealthProfile,
//                   icon: _isSubmitting
//                       ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
//                   )
//                       : const Icon(Icons.save_outlined),
//                   label: Text(
//                     _isSubmitting ? "Saving..." : "Save Health Profile",
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF4CAF50),
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                     elevation: 2,
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }