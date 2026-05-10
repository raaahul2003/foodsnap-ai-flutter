import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  DESIGN TOKENS  (matches app dark theme)
// ─────────────────────────────────────────────────────────────────────────────
class _DS {
  static const bg           = Color(0xFF050D0A);
  static const bgCard       = Color(0xFF0C1A13);
  static const surface      = Color(0xFF0F2018);
  static const neon         = Color(0xFF00FF88);
  static const neonDim      = Color(0xFF00C46A);
  static const neonFaint    = Color(0xFF003D22);
  static const accent1      = Color(0xFF00E5FF);
  static const accent2      = Color(0xFFB2FF59);
  static const accent3      = Color(0xFFFF6B6B);
  static const accent4      = Color(0xFFFFD166);
  static const accent5      = Color(0xFFA78BFA);
  static const textPrimary  = Color(0xFFF0FFF8);
  static const textSecondary= Color(0xFF6EE7B7);
  static const textMuted    = Color(0xFF4A8A68);
  static const borderFaint  = Color(0xFF112B1E);
}

// ─────────────────────────────────────────────────────────────────────────────
//  MEDICAL FIELD METADATA
// ─────────────────────────────────────────────────────────────────────────────
class _MedInfo {
  final String label, whatIs, normalRange, whereToFind, hint;
  final IconData icon;
  final Color color;
  final TextInputType keyboard;
  final String? unit;
  const _MedInfo({
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

const _kMedFields = <String, _MedInfo>{
  'bp': _MedInfo(
    label: 'Blood Pressure',
    whatIs: 'Blood pressure measures the force of blood pushing against your artery walls. Recorded as systolic (top) over diastolic (bottom).',
    normalRange: 'Normal: 90/60 – 120/80 mmHg\nElevated: 120–129 / < 80\nHigh: 130/80+',
    whereToFind: 'Measured at any clinic, pharmacy kiosk, or home BP monitor. Also in doctor visit notes.',
    hint: 'e.g. 120/80',
    icon: Icons.favorite_border_rounded,
    color: _DS.accent3,
    unit: 'mmHg',
  ),
  'sugar': _MedInfo(
    label: 'Blood Sugar (Fasting)',
    whatIs: 'Fasting blood glucose is measured after 8+ hours without food. It shows how well your body manages sugar.',
    normalRange: 'Normal: 70–99 mg/dL\nPre-diabetic: 100–125 mg/dL\nDiabetic: 126+ mg/dL',
    whereToFind: 'Found in blood test reports (CBC / metabolic panel), glucometer reading, or doctor\'s notes.',
    hint: 'e.g. 90',
    icon: Icons.science_rounded,
    color: _DS.accent4,
    keyboard: TextInputType.number,
    unit: 'mg/dL',
  ),
  'cholesterol': _MedInfo(
    label: 'Total Cholesterol',
    whatIs: 'Cholesterol is a fatty substance in your blood. High levels increase the risk of heart disease and stroke.',
    normalRange: 'Desirable: < 200 mg/dL\nBorderline: 200–239 mg/dL\nHigh: 240+ mg/dL',
    whereToFind: 'Found in lipid panel blood test reports. Part of routine annual checkup lab reports.',
    hint: 'e.g. 180',
    icon: Icons.water_drop_rounded,
    color: _DS.accent4,
    keyboard: TextInputType.number,
    unit: 'mg/dL',
  ),
  'vitamin': _MedInfo(
    label: 'Vitamin D Level',
    whatIs: 'Vitamin D is essential for bone health, immune function, and mood regulation. Deficiency is very common worldwide.',
    normalRange: 'Deficient: < 20 ng/mL\nInsufficient: 20–29 ng/mL\nSufficient: 30–100 ng/mL',
    whereToFind: 'Found in blood test as "25-OH Vitamin D" or "Calcidiol". Request from your doctor or any diagnostic lab.',
    hint: 'e.g. 35',
    icon: Icons.wb_sunny_rounded,
    color: _DS.accent4,
    keyboard: TextInputType.number,
    unit: 'ng/mL',
  ),
  'iron': _MedInfo(
    label: 'Iron / Ferritin Level',
    whatIs: 'Ferritin stores iron in your body. Low ferritin causes fatigue, hair loss, and anemia. High levels can indicate inflammation.',
    normalRange: 'Men: 24–336 ng/mL\nWomen: 11–307 ng/mL\nLow = Anemia risk',
    whereToFind: 'Found in CBC (Complete Blood Count) or serum ferritin test. Available in routine health checkup reports.',
    hint: 'e.g. 80',
    icon: Icons.grain_rounded,
    color: _DS.accent1,
    keyboard: TextInputType.number,
    unit: 'ng/mL',
  ),
  'waist': _MedInfo(
    label: 'Waist Circumference',
    whatIs: 'Waist size measures abdominal fat — a stronger indicator of cardiovascular risk than BMI alone.',
    normalRange: 'Low risk  Men: < 94 cm   Women: < 80 cm\nHigh risk Men: > 102 cm  Women: > 88 cm',
    whereToFind: 'Measure with a tape measure around your navel while standing. No medical test needed.',
    hint: 'e.g. 80',
    icon: Icons.straighten_rounded,
    color: _DS.accent5,
    keyboard: TextInputType.number,
    unit: 'cm',
  ),
  'hip': _MedInfo(
    label: 'Hip Circumference',
    whatIs: 'Hip measurement combined with waist gives the Waist-to-Hip Ratio (WHR), a key metric for fat distribution and metabolic risk.',
    normalRange: 'Healthy WHR  Men: < 0.90   Women: < 0.85',
    whereToFind: 'Measure with a tape measure around the widest part of your hips/buttocks. No medical test needed.',
    hint: 'e.g. 95',
    icon: Icons.accessibility_new_rounded,
    color: _DS.accent5,
    keyboard: TextInputType.number,
    unit: 'cm',
  ),
  'bodyDensity': _MedInfo(
    label: 'Bone Density T-score',
    whatIs: 'A T-score from a DEXA scan shows how your bone density compares to a healthy 30-year-old. Used to diagnose osteoporosis.',
    normalRange: 'Normal: ≥ –1.0\nOsteopenia: –1.0 to –2.5\nOsteoporosis: < –2.5',
    whereToFind: 'Found in DEXA (Dual-energy X-ray absorptiometry) scan report. Usually ordered by orthopedic doctors.',
    hint: 'e.g. –0.5',
    icon: Icons.monitor_heart_rounded,
    color: _DS.accent1,
    unit: 'T-score',
  ),
  'bloodGroup': _MedInfo(
    label: 'Blood Group',
    whatIs: 'Your ABO blood type (A, B, AB, O) and Rh factor (positive/negative). Important for transfusions and some dietary considerations.',
    normalRange: 'Types: A+, A–, B+, B–, AB+, AB–, O+, O–',
    whereToFind: 'Found on blood donation card, hospital records, or any blood test report.',
    hint: 'e.g. O+, AB–',
    icon: Icons.bloodtype_rounded,
    color: _DS.accent3,
  ),
  'bodyType': _MedInfo(
    label: 'Body Type',
    whatIs: 'Somatotype describes your natural body frame. Ectomorphs are lean, Mesomorphs muscular, Endomorphs tend to store fat more easily.',
    normalRange: 'Ectomorph · Mesomorph · Endomorph',
    whereToFind: 'Self-assessed by looking at your frame size, fat distribution, and muscle-building tendency.',
    hint: 'e.g. Mesomorph',
    icon: Icons.accessibility_new_rounded,
    color: _DS.accent2,
  ),
};

// ─────────────────────────────────────────────────────────────────────────────
//  EDIT HEALTH PROFILE SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class EditHealthProfileScreen extends StatefulWidget {
  const EditHealthProfileScreen({super.key});

  @override
  State<EditHealthProfileScreen> createState() =>
      _EditHealthProfileScreenState();
}

class _EditHealthProfileScreenState extends State<EditHealthProfileScreen>
    with TickerProviderStateMixin {

  // ── State flags ───────────────────────────────────────────────────────────
  bool _isLoading   = true;
  bool _isSaving    = false;
  bool _advancedMode= false;
  bool _hasChanges  = false;

  // ── Essential controllers ─────────────────────────────────────────────────
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _ageCtrl    = TextEditingController();
  final _bmiCtrl    = TextEditingController();

  // ── Medical controllers ───────────────────────────────────────────────────
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

  // ── Toggle / select state ─────────────────────────────────────────────────
  String? _gender         = null;
  String  _hasCardiac     = 'no';
  String  _hasThyroid     = 'no';
  String  _smoking        = 'no';
  String  _alcohol        = 'no';
  String? _selectedActivity;
  String? _suggestedGoal;

  // ── "I don't know" set ────────────────────────────────────────────────────
  final Set<String> _unknownFields = {};

  // ── BMI ───────────────────────────────────────────────────────────────────
  double? _bmiValue;
  String  _bmiCategory = '';
  Color   _bmiColor    = _DS.textMuted;

  // ── Risk ─────────────────────────────────────────────────────────────────
  int     _riskScore   = 0;

  // ── Validation errors ─────────────────────────────────────────────────────
  final Map<String, String?> _errors = {};

  // ── Activity options ──────────────────────────────────────────────────────
  static const _activityLevels = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
    'Extremely Active',
  ];

  // ── Animation ─────────────────────────────────────────────────────────────
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  // ─────────────────────────────────────────────────────────────────────────
  //  LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _heightCtrl.addListener(_onMetricChange);
    _weightCtrl.addListener(_onMetricChange);
    _bpCtrl.addListener(_recalcRisk);
    _sugarCtrl.addListener(_recalcRisk);
    _cholesterolCtrl.addListener(_recalcRisk);

    // Mark dirty on any text change
    for (final c in _allControllers) {
      c.addListener(_markDirty);
    }

    _loadProfile();
  }

  void _markDirty() => setState(() => _hasChanges = true);

  List<TextEditingController> get _allControllers => [
    _heightCtrl, _weightCtrl, _ageCtrl,
    _bloodGroupCtrl, _bodyTypeCtrl, _bpCtrl, _cholesterolCtrl,
    _sugarCtrl, _waistCtrl, _hipCtrl, _vitaminCtrl, _ironCtrl,
    _boneDensityCtrl,
  ];

  @override
  void dispose() {
    _fadeCtrl.dispose();
    for (final c in [..._allControllers, _bmiCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  DATA  – load
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final prefs   = await SharedPreferences.getInstance();
      final baseUrl = prefs.getString('url') ?? '';
      final lid     = prefs.getString('lid') ?? '';

      if (baseUrl.isEmpty || lid.isEmpty) {
        _toast("Missing server configuration", isError: true);
        return;
      }

      final res = await http.post(
          Uri.parse('$baseUrl/view_health_profile/'), body: {'lid': lid});

      if (res.statusCode == 200) {
        final d = jsonDecode(res.body) as Map<String, dynamic>;
        if (d['status'] == 'ok') {
          setState(() {
            _heightCtrl.text     = _str(d['Height']);
            _weightCtrl.text     = _str(d['Weight']);
            _ageCtrl.text        = _str(d['Age']);
            _bmiCtrl.text        = _str(d['Bmi']);
            _bloodGroupCtrl.text = _str(d['Blood_Group']);
            _bodyTypeCtrl.text   = _str(d['Body_Type']);
            _bpCtrl.text         = _str(d['Bp']);
            _cholesterolCtrl.text= _str(d['Cholestrol']);
            _sugarCtrl.text      = _str(d['Sugar_level']);
            _waistCtrl.text      = _str(d['Waist_Circumference']);
            _hipCtrl.text        = _str(d['Hip_Circumference']);
            _vitaminCtrl.text    = _str(d['Vitamin_D_Level']);
            _ironCtrl.text       = _str(d['Iron_Ferritin']);
            _boneDensityCtrl.text= _str(d['Bone_Density_Tscore']);

            _hasCardiac = _yn(d['Is_Cardiac']);
            _hasThyroid = _yn(d['Thyroid_Status']);
            _smoking    = _yn(d['Smoking']);
            _alcohol    = _yn(d['Alcohol_Consumption']);

            _gender = _str(d['Gender']).isEmpty ? null
                : _str(d['Gender']).toLowerCase();

            final act = _str(d['Physical_Activity_Level']);
            _selectedActivity = _activityLevels.contains(act) ? act : null;

            // Mark nulled-out fields as unknown
            for (final key in ['bp', 'sugar', 'cholesterol', 'vitamin',
              'iron', 'waist', 'hip', 'bodyDensity', 'bloodGroup', 'bodyType']) {
              final ctrl = _ctrlForKey(key);
              if (ctrl != null && ctrl.text.isEmpty) _unknownFields.add(key);
            }
          });

          // Initial calculations
          _calculateBMI(silent: true);
          _recalcRisk();
          setState(() => _hasChanges = false); // reset after load
          _fadeCtrl.forward();
        } else {
          _toast(d['message'] ?? 'Profile not found', isError: true);
        }
      } else {
        _toast('Server error (${res.statusCode})', isError: true);
      }
    } catch (e) {
      _toast('Error loading profile', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _str(dynamic v) => v?.toString().trim() ?? '';
  String _yn(dynamic v)  {
    final s = (v?.toString() ?? 'no').toLowerCase();
    return (s == 'yes') ? 'yes' : 'no';
  }

  TextEditingController? _ctrlForKey(String key) {
    switch (key) {
      case 'bp':          return _bpCtrl;
      case 'sugar':       return _sugarCtrl;
      case 'cholesterol': return _cholesterolCtrl;
      case 'vitamin':     return _vitaminCtrl;
      case 'iron':        return _ironCtrl;
      case 'waist':       return _waistCtrl;
      case 'hip':         return _hipCtrl;
      case 'bodyDensity': return _boneDensityCtrl;
      case 'bloodGroup':  return _bloodGroupCtrl;
      case 'bodyType':    return _bodyTypeCtrl;
      default:            return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  CALCULATIONS
  // ─────────────────────────────────────────────────────────────────────────
  void _onMetricChange() {
    _calculateBMI();
    _recalcRisk();
    _markDirty();
  }

  void _calculateBMI({bool silent = false}) {
    final h = double.tryParse(_heightCtrl.text.trim());
    final w = double.tryParse(_weightCtrl.text.trim());
    if (h != null && w != null && h > 0 && w > 0) {
      final hm  = h / 100;
      final bmi = w / (hm * hm);
      String cat; Color col; String? goal;
      if (bmi < 18.5) {
        cat = 'Underweight'; col = _DS.accent1; goal = 'weight_gain';
      } else if (bmi < 25) {
        cat = 'Normal';      col = _DS.neon;    goal = 'balanced';
      } else if (bmi < 30) {
        cat = 'Overweight';  col = _DS.accent4; goal = 'fat_loss';
      } else {
        cat = 'Obese';       col = _DS.accent3; goal = 'fat_loss';
      }
      if (!silent) {
        setState(() {
          _bmiValue    = bmi;
          _bmiCtrl.text = bmi.toStringAsFixed(1);
          _bmiCategory  = cat;
          _bmiColor     = col;
          _suggestedGoal= goal;
        });
      } else {
        _bmiValue     = bmi;
        _bmiCtrl.text = bmi.toStringAsFixed(1);
        _bmiCategory  = cat;
        _bmiColor     = col;
        _suggestedGoal= goal;
      }
    } else {
      if (!silent) {
        setState(() {
          _bmiValue    = null;
          _bmiCategory = '';
          _bmiColor    = _DS.textMuted;
          _suggestedGoal= null;
        });
      } else {
        _bmiValue    = null;
        _bmiCategory = '';
        _bmiColor    = _DS.textMuted;
        _suggestedGoal= null;
      }
    }
  }

  void _recalcRisk() {
    int r = 0;
    if (_bmiValue != null) {
      if (_bmiValue! >= 30)       r += 20;
      else if (_bmiValue! >= 25)  r += 10;
      else if (_bmiValue! < 18.5) r += 5;
    }
    if (_smoking    == 'yes') r += 20;
    if (_alcohol    == 'yes') r += 10;
    if (_hasCardiac == 'yes') r += 15;
    if (_hasThyroid == 'yes') r += 5;

    final sugar = double.tryParse(_sugarCtrl.text.trim());
    if (sugar != null) {
      if (sugar >= 126)       r += 20;
      else if (sugar >= 100)  r += 10;
    }
    final bpP = _bpCtrl.text.trim().split('/');
    if (bpP.length == 2) {
      final sys = double.tryParse(bpP[0].trim());
      if (sys != null) {
        if (sys >= 140)      r += 15;
        else if (sys >= 130) r += 8;
      }
    }
    final chol = double.tryParse(_cholesterolCtrl.text.trim());
    if (chol != null) {
      if (chol >= 240)       r += 15;
      else if (chol >= 200)  r += 8;
    }
    setState(() => _riskScore = r.clamp(0, 100));
  }

  // ─── Risk helpers ──────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────────────────────
  //  VALIDATION
  // ─────────────────────────────────────────────────────────────────────────
  bool _validate() {
    final e = <String, String?>{};

    // Required
    if (_heightCtrl.text.trim().isEmpty)
      e['height'] = 'Required';
    else if ((double.tryParse(_heightCtrl.text.trim()) ?? 0) <= 0)
      e['height'] = 'Enter a valid height (cm)';

    if (_weightCtrl.text.trim().isEmpty)
      e['weight'] = 'Required';
    else if ((double.tryParse(_weightCtrl.text.trim()) ?? 0) <= 0)
      e['weight'] = 'Enter a valid weight (kg)';

    if (_ageCtrl.text.trim().isEmpty)
      e['age'] = 'Required';
    else {
      final age = int.tryParse(_ageCtrl.text.trim()) ?? 0;
      if (age < 5 || age > 120) e['age'] = 'Valid age: 5–120';
    }

    if (_gender == null) e['gender'] = 'Please select';
    if (_selectedActivity == null) e['activity'] = 'Please select';

    // Optional but formatted
    final bp = _bpCtrl.text.trim();
    if (bp.isNotEmpty && !_unknownFields.contains('bp')) {
      final parts = bp.split('/');
      if (parts.length != 2 ||
          double.tryParse(parts[0].trim()) == null ||
          double.tryParse(parts[1].trim()) == null)
        e['bp'] = 'Use format 120/80';
    }

    for (final key in ['sugar', 'cholesterol', 'waist', 'hip']) {
      final ctrl = _ctrlForKey(key);
      if (ctrl != null &&
          ctrl.text.trim().isNotEmpty &&
          !_unknownFields.contains(key) &&
          double.tryParse(ctrl.text.trim()) == null) {
        e[key] = 'Must be a number';
      }
    }

    setState(() { _errors.clear(); _errors.addAll(e); });
    return e.isEmpty;
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SAVE
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _confirmAndSave() async {
    if (!_validate()) {
      _toast('Please fix the highlighted errors', isError: true);
      return;
    }

    final confirmed = await _showConfirmDialog();
    if (confirmed != true) return;
    await _saveProfile();
  }

  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
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
                    color: _DS.neonFaint, shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: _DS.neon, size: 30),
              ),
              const SizedBox(height: 16),
              const Text('Save Changes?',
                  style: TextStyle(
                      color: _DS.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              const Text(
                'Saving will recalculate your:\n• Daily calorie goal\n• Macro distribution (protein / carbs / fats)\n• AI diet recommendations\n\nThis data is used for personalized nutrition insights.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _DS.textMuted, fontSize: 13, height: 1.6),
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
                    child: const Text('Save',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final prefs   = await SharedPreferences.getInstance();
      final baseUrl = prefs.getString('url') ?? '';
      final lid     = prefs.getString('lid') ?? '';
      if (baseUrl.isEmpty || lid.isEmpty) {
        _toast('Missing configuration', isError: true);
        return;
      }

      String _val(String key, TextEditingController ctrl) =>
          _unknownFields.contains(key) ? '' : ctrl.text.trim();

      final req = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/edit_health_profile/'));
      req.fields.addAll({
        'lid':         lid,
        'height':      _heightCtrl.text.trim(),
        'weight':      _weightCtrl.text.trim(),
        'age':         _ageCtrl.text.trim(),
        'gender':      _gender ?? '',
        'bmi':         _bmiCtrl.text.trim(),
        'bloodg':      _val('bloodGroup',  _bloodGroupCtrl),
        'cardiac':     _hasCardiac,
        'bodytype':    _val('bodyType',    _bodyTypeCtrl),
        'bp':          _val('bp',          _bpCtrl),
        'cholestrol':  _val('cholesterol', _cholesterolCtrl),
        'sugarlevel':  _val('sugar',       _sugarCtrl),
        'thyroid':     _hasThyroid,
        'waist':       _val('waist',       _waistCtrl),
        'hip':         _val('hip',         _hipCtrl),
        'vitamin':     _val('vitamin',     _vitaminCtrl),
        'iron':        _val('iron',        _ironCtrl),
        'smoking':     _smoking,
        'alcohol':     _alcohol,
        'physical':    _selectedActivity ?? '',
        'bodydensity': _val('bodyDensity', _boneDensityCtrl),
        'goal_mode':   _suggestedGoal ?? 'balanced',
      });

      final streamed = await req.send();
      final body     = await streamed.stream.bytesToString();
      final data     = jsonDecode(body) as Map<String, dynamic>;

      if (streamed.statusCode == 200 && data['status'] == 'ok') {
        await prefs.setString('gender', _gender ?? '');
        _toast('Profile updated! AI plan recalculated.');
        setState(() => _hasChanges = false);
        if (mounted) Navigator.pop(context);
      } else {
        _toast(data['message'] ?? 'Update failed', isError: true);
      }
    } catch (_) {
      _toast('Error saving profile', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _toast(String msg, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: isError ? _DS.accent3 : _DS.neonDim,
      textColor: isError ? Colors.white : _DS.bg,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  INFO BOTTOM SHEET
  // ─────────────────────────────────────────────────────────────────────────
  void _showInfoSheet(String key) {
    final info = _kMedFields[key]!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MedInfoSheet(
        info: info,
        fieldKey: key,
        isUnknown: _unknownFields.contains(key),
        onToggleUnknown: (k, v) => setState(() {
          if (v) _unknownFields.add(k); else _unknownFields.remove(k);
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingScreen();

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
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 110),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 16),

                    // Changes banner
                    if (_hasChanges) _buildChangesBanner(),
                    if (_hasChanges) const SizedBox(height: 14),

                    // Mode toggle
                    _buildModeToggle(),
                    const SizedBox(height: 16),

                    // BMI + Risk side by side
                    Row(children: [
                      Expanded(child: _buildBMICard()),
                      const SizedBox(width: 12),
                      Expanded(child: _buildRiskCard()),
                    ]),
                    const SizedBox(height: 22),

                    // ── Essential ─────────────────────────────────────────
                    _sectionHeader('Essential', Icons.star_rounded, _DS.neon),
                    const SizedBox(height: 14),
                    _buildEssentialSection(),

                    // ── Lifestyle ─────────────────────────────────────────
                    const SizedBox(height: 22),
                    _sectionHeader('Lifestyle', Icons.self_improvement_rounded, _DS.accent2),
                    const SizedBox(height: 14),
                    _buildLifestyleSection(),

                    // ── Advanced medical ──────────────────────────────────
                    if (_advancedMode) ...[
                      const SizedBox(height: 22),
                      _sectionHeader('Medical Records', Icons.biotech_rounded, _DS.accent1),
                      const SizedBox(height: 8),
                      _buildAdvancedNote(),
                      const SizedBox(height: 14),
                      _buildMedicalSection(),
                    ],

                    // ── Goal suggestion ───────────────────────────────────
                    if (_suggestedGoal != null) ...[
                      const SizedBox(height: 22),
                      _buildGoalBanner(),
                    ],

                    const SizedBox(height: 24),
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

  // ── Loading screen ─────────────────────────────────────────────────────────
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: _DS.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _DS.bgCard,
                shape: BoxShape.circle,
                border: Border.all(color: _DS.neon.withOpacity(0.3), width: 1),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                    color: _DS.neon, strokeWidth: 2.5),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Loading your health profile…',
                style: TextStyle(
                    color: _DS.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ── Sliver app bar ─────────────────────────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 150,
      pinned: true,
      backgroundColor: _DS.bg,
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          if (_hasChanges) {
            _showDiscardDialog();
          } else {
            Navigator.pop(context);
          }
        },
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
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 12),
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
                      child: const Icon(Icons.edit_note_rounded,
                          color: _DS.neon, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Edit Health Profile',
                            style: TextStyle(
                                color: _DS.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4)),
                        Text(
                          _hasChanges
                              ? 'Unsaved changes'
                              : 'Keep your data up to date',
                          style: TextStyle(
                              color: _hasChanges
                                  ? _DS.accent4
                                  : _DS.textMuted,
                              fontSize: 12),
                        ),
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

  // ── Discard dialog ─────────────────────────────────────────────────────────
  Future<void> _showDiscardDialog() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: _DS.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: _DS.accent4, size: 36),
              const SizedBox(height: 12),
              const Text('Discard Changes?',
                  style: TextStyle(
                      color: _DS.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Your unsaved changes will be lost.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _DS.textMuted, fontSize: 13)),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _DS.neon,
                      side: const BorderSide(color: _DS.neon, width: 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Keep Editing'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _DS.accent3,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Discard',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
    if (discard == true && mounted) Navigator.pop(context);
  }

  // ── Changes banner ─────────────────────────────────────────────────────────
  Widget _buildChangesBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _DS.accent4.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _DS.accent4.withOpacity(0.25), width: 1),
      ),
      child: Row(children: [
        const Icon(Icons.edit_rounded, size: 14, color: _DS.accent4),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'You have unsaved changes. Saving will recalculate your AI calorie & macro goals.',
            style: TextStyle(
                color: _DS.accent4, fontSize: 11, height: 1.4),
          ),
        ),
      ]),
    );
  }

  // ── Mode toggle ────────────────────────────────────────────────────────────
  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _DS.borderFaint, width: 1),
      ),
      child: Row(children: [
        _modeTab('Basic Mode', Icons.tune_rounded, !_advancedMode,
                () => setState(() => _advancedMode = false)),
        _modeTab('Advanced Mode', Icons.biotech_rounded, _advancedMode,
                () => setState(() => _advancedMode = true)),
      ]),
    );
  }

  Widget _modeTab(String label, IconData icon, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: () { HapticFeedback.lightImpact(); onTap(); },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? _DS.neon : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: active ? _DS.bg : _DS.textMuted),
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

  // ── BMI card ───────────────────────────────────────────────────────────────
  Widget _buildBMICard() {
    final pct = _bmiValue != null ? (_bmiValue! / 40).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _bmiColor.withOpacity(0.22), width: 1),
        boxShadow: [BoxShadow(color: _bmiColor.withOpacity(0.06), blurRadius: 14)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.calculate_rounded, size: 13, color: _bmiColor),
          const SizedBox(width: 4),
          Text('BMI',
              style: TextStyle(
                  color: _bmiColor, fontSize: 10, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        Text(_bmiValue != null ? _bmiValue!.toStringAsFixed(1) : '—',
            style: const TextStyle(
                color: _DS.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -1)),
        const SizedBox(height: 3),
        Text(
          _bmiCategory.isEmpty ? 'Enter height & weight' : _bmiCategory,
          style: TextStyle(
              color: _bmiColor, fontSize: 11, fontWeight: FontWeight.w600),
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
      ]),
    );
  }

  // ── Risk card ──────────────────────────────────────────────────────────────
  Widget _buildRiskCard() {
    final pct = (_riskScore / 100).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _riskColor.withOpacity(0.22), width: 1),
        boxShadow: [BoxShadow(color: _riskColor.withOpacity(0.06), blurRadius: 14)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.shield_rounded, size: 13, color: _riskColor),
          const SizedBox(width: 4),
          Text('Health Risk',
              style: TextStyle(
                  color: _riskColor, fontSize: 10, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        Text('$_riskScore',
            style: const TextStyle(
                color: _DS.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -1)),
        const SizedBox(height: 3),
        Text(_riskLabel,
            style: TextStyle(
                color: _riskColor, fontSize: 11, fontWeight: FontWeight.w600)),
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
      ]),
    );
  }

  // ── Section header ─────────────────────────────────────────────────────────
  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.18), width: 1),
        ),
        child: Icon(icon, size: 14, color: color),
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

  // ── Essential section ──────────────────────────────────────────────────────
  Widget _buildEssentialSection() {
    return Column(children: [
      Row(children: [
        Expanded(child: _input(
          ctrl: _heightCtrl, label: 'Height', icon: Icons.height_rounded,
          color: _DS.neon, keyboard: TextInputType.number,
          unit: 'cm', hint: 'e.g. 170', required: true, errorKey: 'height',
        )),
        const SizedBox(width: 12),
        Expanded(child: _input(
          ctrl: _weightCtrl, label: 'Weight', icon: Icons.monitor_weight_rounded,
          color: _DS.neon, keyboard: TextInputType.number,
          unit: 'kg', hint: 'e.g. 65', required: true, errorKey: 'weight',
        )),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _input(
          ctrl: _ageCtrl, label: 'Age', icon: Icons.cake_rounded,
          color: _DS.accent2, keyboard: TextInputType.number,
          unit: 'yrs', hint: 'e.g. 28', required: true, errorKey: 'age',
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildGenderSelector()),
      ]),
      const SizedBox(height: 12),
      _buildActivitySelector(),
    ]);
  }

  Widget _buildGenderSelector() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('Gender',
            style: TextStyle(
                color: _DS.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
        const Text(' *',
            style: TextStyle(color: _DS.accent3, fontSize: 11)),
      ]),
      const SizedBox(height: 6),
      Row(children: [
        _genderChip('Male',   Icons.male_rounded,   _DS.accent1),
        const SizedBox(width: 6),
        _genderChip('Female', Icons.female_rounded,  _DS.accent3),
        const SizedBox(width: 6),
        _genderChip('Other',  Icons.person_rounded,  _DS.accent5),
      ]),
      if (_errors['gender'] != null)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(_errors['gender']!,
              style: const TextStyle(color: _DS.accent3, fontSize: 10)),
        ),
    ]);
  }

  Widget _genderChip(String val, IconData icon, Color color) {
    final sel = _gender == val.toLowerCase();
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() { _gender = val.toLowerCase(); _hasChanges = true; });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: sel ? color.withOpacity(0.16) : _DS.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: sel ? color : _DS.borderFaint, width: 1.2),
          ),
          child: Column(children: [
            Icon(icon, size: 15, color: sel ? color : _DS.textMuted),
            const SizedBox(height: 3),
            Text(val,
                style: TextStyle(
                    color: sel ? color : _DS.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }

  Widget _buildActivitySelector() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('Physical Activity Level',
            style: TextStyle(
                color: _DS.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
        const Text(' *',
            style: TextStyle(color: _DS.accent3, fontSize: 11)),
      ]),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _activityLevels.map((level) {
          final sel = _selectedActivity == level;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() { _selectedActivity = level; _hasChanges = true; _recalcRisk(); });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: sel ? _DS.neon.withOpacity(0.14) : _DS.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: sel ? _DS.neon : _DS.borderFaint, width: 1),
              ),
              child: Text(level,
                  style: TextStyle(
                      color: sel ? _DS.neon : _DS.textMuted,
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
    ]);
  }

  // ── Lifestyle section ──────────────────────────────────────────────────────
  Widget _buildLifestyleSection() {
    return Column(children: [
      _yesNo('Cardiac Risk',       Icons.favorite_border_rounded, _DS.accent3,
          _hasCardiac, (v) => setState(() { _hasCardiac = v!; _recalcRisk(); _hasChanges = true; })),
      const SizedBox(height: 10),
      _yesNo('Thyroid Condition',  Icons.psychology_alt_rounded,  _DS.accent4,
          _hasThyroid, (v) => setState(() { _hasThyroid = v!; _recalcRisk(); _hasChanges = true; })),
      const SizedBox(height: 10),
      _yesNo('Smoking',            Icons.smoking_rooms_rounded,   _DS.accent3,
          _smoking,    (v) => setState(() { _smoking    = v!; _recalcRisk(); _hasChanges = true; })),
      const SizedBox(height: 10),
      _yesNo('Alcohol Consumption',Icons.local_bar_rounded,       _DS.accent4,
          _alcohol,    (v) => setState(() { _alcohol    = v!; _recalcRisk(); _hasChanges = true; })),
    ]);
  }

  Widget _yesNo(String label, IconData icon, Color color,
      String value, ValueChanged<String?> onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: value == 'yes' ? color.withOpacity(0.28) : _DS.borderFaint,
            width: 1),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label,
            style: const TextStyle(
                color: _DS.textPrimary, fontSize: 13, fontWeight: FontWeight.w600))),
        _toggleBtn('No',  value == 'no',  _DS.textMuted, () => onChange('no')),
        const SizedBox(width: 6),
        _toggleBtn('Yes', value == 'yes', color,         () => onChange('yes')),
      ]),
    );
  }

  Widget _toggleBtn(String label, bool active, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onTap(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? color : _DS.borderFaint, width: 1),
        ),
        child: Text(label,
            style: TextStyle(
                color: active ? color : _DS.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ── Advanced medical section ───────────────────────────────────────────────
  Widget _buildAdvancedNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _DS.accent1.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _DS.accent1.withOpacity(0.14), width: 1),
      ),
      child: Row(children: [
        const Icon(Icons.info_outline_rounded, size: 13, color: _DS.accent1),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'All medical fields are optional. Tap ℹ to learn what each means and where to find your value. Use "?" to mark as unknown.',
            style: TextStyle(color: _DS.accent1, fontSize: 11, height: 1.45),
          ),
        ),
      ]),
    );
  }

  Widget _buildMedicalSection() {
    final fields = <(String, TextEditingController)>[
      ('bp',          _bpCtrl),
      ('sugar',       _sugarCtrl),
      ('cholesterol', _cholesterolCtrl),
      ('vitamin',     _vitaminCtrl),
      ('iron',        _ironCtrl),
      ('waist',       _waistCtrl),
      ('hip',         _hipCtrl),
      ('bloodGroup',  _bloodGroupCtrl),
      ('bodyType',    _bodyTypeCtrl),
      ('bodyDensity', _boneDensityCtrl),
    ];

    return Column(
      children: fields.map((f) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _medField(fieldKey: f.$1, ctrl: f.$2),
      )).toList(),
    );
  }

  // ── Goal banner ────────────────────────────────────────────────────────────
  Widget _buildGoalBanner() {
    String text; IconData ic;
    switch (_suggestedGoal) {
      case 'weight_gain':
        text = 'Your BMI suggests: Weight Gain Mode ⚡'; ic = Icons.trending_up_rounded; break;
      case 'fat_loss':
        text = 'Your BMI suggests: Weight Loss Mode 🎯'; ic = Icons.trending_down_rounded; break;
      default:
        text = 'Your BMI suggests: Balanced Mode 🌱'; ic = Icons.balance_rounded;
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DS.neonFaint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _DS.neon.withOpacity(0.28), width: 1),
      ),
      child: Row(children: [
        Icon(ic, color: _DS.neon, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('AI Goal Suggestion',
                style: TextStyle(
                    color: _DS.neon, fontSize: 10, fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(text,
                style: const TextStyle(
                    color: _DS.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.3)),
            const SizedBox(height: 4),
            const Text(
              'Saving will update your calorie goal & diet plan automatically.',
              style: TextStyle(color: _DS.textMuted, fontSize: 11, height: 1.3),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      decoration: BoxDecoration(
        color: _DS.bg,
        border: const Border(top: BorderSide(color: _DS.borderFaint, width: 1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Row(children: [
        // Refresh from server
        GestureDetector(
          onTap: _isSaving ? null : () async {
            await _loadProfile();
            setState(() => _hasChanges = false);
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _DS.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _DS.borderFaint, width: 1),
            ),
            child: const Center(
              child: Icon(Icons.refresh_rounded, color: _DS.textMuted, size: 20),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _confirmAndSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: _hasChanges ? _DS.neon : _DS.neon.withOpacity(0.4),
                foregroundColor: _DS.bg,
                disabledBackgroundColor: _DS.neon.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: _DS.bg, strokeWidth: 2.5))
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                      _hasChanges
                          ? Icons.save_rounded
                          : Icons.check_circle_outline_rounded,
                      size: 17),
                  const SizedBox(width: 8),
                  Text(
                      _hasChanges ? 'Save Changes' : 'Up to Date',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  FIELD WIDGETS
  // ─────────────────────────────────────────────────────────────────────────

  // Essential text input
  Widget _input({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    required Color color,
    TextInputType keyboard = TextInputType.text,
    String? unit,
    String? hint,
    bool required = false,
    String? errorKey,
  }) {
    final err = errorKey != null ? _errors[errorKey] : null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label,
            style: const TextStyle(
                color: _DS.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
        if (required)
          const Text(' *', style: TextStyle(color: _DS.accent3, fontSize: 11)),
        if (unit != null) ...[
          const Spacer(),
          Text(unit,
              style: const TextStyle(
                  color: _DS.textMuted, fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ]),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        keyboardType: keyboard,
        style: const TextStyle(
            color: _DS.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: _DS.textMuted.withOpacity(0.55), fontSize: 12),
          prefixIcon: Icon(icon, color: color, size: 17),
          errorText: err,
          errorStyle: const TextStyle(color: _DS.accent3, fontSize: 10),
          filled: true,
          fillColor: _DS.bgCard,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _DS.borderFaint, width: 1)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: err != null
                      ? _DS.accent3.withOpacity(0.4)
                      : _DS.borderFaint,
                  width: 1)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: color, width: 1.5)),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      ),
    ]);
  }

  // Medical field with info icon + unknown toggle
  Widget _medField({
    required String fieldKey,
    required TextEditingController ctrl,
  }) {
    final info      = _kMedFields[fieldKey]!;
    final isUnknown = _unknownFields.contains(fieldKey);
    final err       = _errors[fieldKey];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Label row
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
                  color: info.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: info.color.withOpacity(0.22), width: 1),
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
                  color: _DS.textMuted, fontSize: 10, fontWeight: FontWeight.w500)),
      ]),
      const SizedBox(height: 6),

      if (isUnknown)
      // "Unknown" placeholder
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: _DS.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: info.color.withOpacity(0.18), width: 1),
          ),
          child: Row(children: [
            Icon(Icons.help_outline_rounded, color: _DS.textMuted, size: 16),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Not set',
                    style: TextStyle(
                        color: _DS.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text('Update later from lab report',
                    style: TextStyle(
                        color: _DS.textMuted, fontSize: 10, height: 1.3)),
              ]),
            ),
            GestureDetector(
              onTap: () => setState(() { _unknownFields.remove(fieldKey); _hasChanges = true; }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: info.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: info.color.withOpacity(0.22), width: 1),
                ),
                child: Text('Enter',
                    style: TextStyle(
                        color: info.color, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        )
      else
      // Actual text field
        TextField(
          controller: ctrl,
          keyboardType: info.keyboard,
          style: const TextStyle(
              color: _DS.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: info.hint,
            hintStyle: TextStyle(
                color: _DS.textMuted.withOpacity(0.5), fontSize: 12),
            prefixIcon: Icon(info.icon, color: info.color, size: 17),
            // "?" button to mark as unknown
            suffixIcon: GestureDetector(
              onTap: () {
                ctrl.clear();
                setState(() { _unknownFields.add(fieldKey); _hasChanges = true; });
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _DS.textMuted.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('?',
                    style: TextStyle(
                        color: _DS.textMuted, fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ),
            errorText: err,
            errorStyle: const TextStyle(color: _DS.accent3, fontSize: 10),
            filled: true,
            fillColor: _DS.bgCard,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _DS.borderFaint, width: 1)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: err != null
                        ? _DS.accent3.withOpacity(0.4)
                        : _DS.borderFaint,
                    width: 1)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: info.color, width: 1.5)),
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
                size: 10, color: _DS.textMuted.withOpacity(0.55)),
            const SizedBox(width: 4),
            Text(
              info.normalRange.split('\n').first,
              style: TextStyle(
                  color: _DS.textMuted.withOpacity(0.65),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500),
            ),
          ]),
        ),
      ],
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  MEDICAL INFO BOTTOM SHEET  (shared)
// ─────────────────────────────────────────────────────────────────────────────
class _MedInfoSheet extends StatelessWidget {
  final _MedInfo info;
  final String fieldKey;
  final bool isUnknown;
  final void Function(String key, bool val) onToggleUnknown;

  const _MedInfoSheet({
    required this.info,
    required this.fieldKey,
    required this.isUnknown,
    required this.onToggleUnknown,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: info.color.withOpacity(0.22), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.55),
              blurRadius: 30,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
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
                          color: _DS.surface, shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded,
                          color: _DS.textMuted, size: 16),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),

                _block('What is it?',      info.whatIs,       Icons.help_outline_rounded,   _DS.accent1),
                const SizedBox(height: 12),
                _block('Normal Range',     info.normalRange,  Icons.straighten_rounded,     _DS.neon),
                const SizedBox(height: 12),
                _block('Where to find it', info.whereToFind,  Icons.search_rounded,         _DS.accent2),
                const SizedBox(height: 20),

                // Toggle unknown
                GestureDetector(
                  onTap: () {
                    onToggleUnknown(fieldKey, !isUnknown);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isUnknown ? _DS.neonFaint : _DS.surface,
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
                              color: isUnknown ? _DS.neon : _DS.textSecondary,
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
                      'You can always update this later from your lab report.',
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

  Widget _block(String title, String body, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.12), width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 6),
          Text(title,
              style: TextStyle(
                  color: color,
                  fontSize: 10,
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
      ]),
    );
  }
}





// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() {
//   runApp(const FoodSnapApp());
// }
//
// class FoodSnapApp extends StatelessWidget {
//   const FoodSnapApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'FoodSnap AI',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primaryColor: const Color(0xFF4CAF50),
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF4CAF50),
//           brightness: Brightness.light,
//         ),
//         scaffoldBackgroundColor: const Color(0xFFF8FAFC),
//         useMaterial3: true, // recommended for modern look & behavior
//         cardTheme: CardThemeData(                                 // ← FIXED HERE
//           elevation: 2,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           color: Colors.white,
//           surfaceTintColor: Colors.transparent,                   // clean M3 cards
//           clipBehavior: Clip.antiAlias,
//         ),
//         inputDecorationTheme: InputDecorationTheme(
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           errorStyle: TextStyle(color: Colors.red.shade700),
//         ),
//         textTheme: const TextTheme(
//           titleLarge: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
//           titleMedium: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
//           bodyMedium: TextStyle(color: Color(0xFF4B5563)),
//         ),
//       ),
//       home: const EditHealthProfileScreen(),
//     );
//   }
// }
//
// class EditHealthProfileScreen extends StatefulWidget {
//   const EditHealthProfileScreen({super.key});
//
//   @override
//   State<EditHealthProfileScreen> createState() => _EditHealthProfileScreenState();
// }
//
// class _EditHealthProfileScreenState extends State<EditHealthProfileScreen> {
//   // Controllers
//   final _heightController     = TextEditingController();
//   final _weightController     = TextEditingController();
//   final _bmiController        = TextEditingController();
//   final _bloodGroupController = TextEditingController();
//   final _bodyTypeController   = TextEditingController();
//   final _bpController         = TextEditingController();
//   final _cholesterolController= TextEditingController();
//   final _sugarLevelController = TextEditingController();
//   final _waistController      = TextEditingController();
//   final _hipController        = TextEditingController();
//   final _vitaminDController   = TextEditingController();
//   final _ironController       = TextEditingController();
//   final _activityLevelController = TextEditingController();
//   final _boneDensityController= TextEditingController();
//
//   // Yes/No states
//   String _hasCardiac = 'no';
//   String _hasThyroid = 'no';
//   String _smoking    = 'no';
//   String _alcohol    = 'no';
//
//   bool _isLoading = true;
//   bool _isSaving  = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadHealthProfile();
//   }
//
//   Future<void> _loadHealthProfile() async {
//     setState(() => _isLoading = true);
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final baseUrl = prefs.getString('url') ?? '';
//       final lid     = prefs.getString('lid') ?? '';
//
//       if (baseUrl.isEmpty || lid.isEmpty) {
//         if (mounted) Fluttertoast.showToast(msg: "Missing server configuration");
//         return;
//       }
//
//       final uri = Uri.parse('$baseUrl/view_health_profile/');
//       final response = await http.post(uri, body: {'lid': lid});
//
//       if (response.statusCode == 200) {
//         final json = jsonDecode(response.body) as Map<String, dynamic>;
//         if (json['status'] == 'ok') {
//           setState(() {
//             _heightController.text      = json['Height']?.toString() ?? '';
//             _weightController.text      = json['Weight']?.toString() ?? '';
//             _bmiController.text         = json['Bmi']?.toString() ?? '';
//             _bloodGroupController.text  = json['Blood_Group']?.toString() ?? '';
//             _hasCardiac = (json['Is_Cardiac']?.toString() ?? 'no').toLowerCase();
//             _bodyTypeController.text    = json['Body_Type']?.toString() ?? '';
//             _bpController.text          = json['Bp']?.toString() ?? '';
//             _cholesterolController.text = json['Cholestrol']?.toString() ?? '';
//             _sugarLevelController.text  = json['Sugar_level']?.toString() ?? '';
//             _hasThyroid = (json['Thyroid_Status']?.toString() ?? 'no').toLowerCase();
//             _waistController.text       = json['Waist_Circumference']?.toString() ?? '';
//             _hipController.text         = json['Hip_Circumference']?.toString() ?? '';
//             _vitaminDController.text    = json['Vitamin_D_Level']?.toString() ?? '';
//             _ironController.text        = json['Iron_Ferritin']?.toString() ?? '';
//             _smoking    = (json['Smoking']?.toString() ?? 'no').toLowerCase();    // fixed typo
//             _alcohol    = (json['Alcohol_Consumption']?.toString() ?? 'no').toLowerCase();
//             _activityLevelController.text = json['Physical_Activity_Level']?.toString() ?? '';
//             _boneDensityController.text   = json['Bone_Density_Tscore']?.toString() ?? '';
//           });
//         } else {
//           if (mounted) Fluttertoast.showToast(msg: json['message'] ?? "Profile not found");
//         }
//       } else {
//         if (mounted) Fluttertoast.showToast(msg: "Server error (${response.statusCode})");
//       }
//     } catch (e) {
//       if (mounted) Fluttertoast.showToast(msg: "Error loading profile: ${e.toString()}");
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _saveHealthProfile() async {
//     setState(() => _isSaving = true);
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final baseUrl = prefs.getString('url') ?? '';
//       final lid     = prefs.getString('lid') ?? '';
//
//       if (baseUrl.isEmpty || lid.isEmpty) {
//         if (mounted) Fluttertoast.showToast(msg: "Missing configuration");
//         return;
//       }
//
//       final uri = Uri.parse('$baseUrl/edit_health_profile/');
//       final request = http.MultipartRequest('POST', uri);
//
//       request.fields.addAll({
//         'lid': lid,
//         'height': _heightController.text.trim(),
//         'weight': _weightController.text.trim(),
//         'bmi': _bmiController.text.trim(),
//         'bloodg': _bloodGroupController.text.trim(),
//         'cardiac': _hasCardiac,
//         'bodytype': _bodyTypeController.text.trim(),
//         'bp': _bpController.text.trim(),
//         'cholestrol': _cholesterolController.text.trim(),
//         'sugarlevel': _sugarLevelController.text.trim(),
//         'thyroid': _hasThyroid,
//         'waist': _waistController.text.trim(),
//         'hip': _hipController.text.trim(),
//         'vitamin': _vitaminDController.text.trim(),
//         'iron': _ironController.text.trim(),
//         'smoking': _smoking,
//         'alcohol': _alcohol,
//         'physical': _activityLevelController.text.trim(),
//         'bodydensity': _boneDensityController.text.trim(),
//       });
//
//       final response = await request.send();
//       final respStr = await response.stream.bytesToString();
//       final data = jsonDecode(respStr) as Map<String, dynamic>;
//
//       if (response.statusCode == 200 && data['status'] == 'ok') {
//         if (mounted) {
//           Fluttertoast.showToast(
//             msg: "Health profile updated successfully!",
//             backgroundColor: Colors.green.shade700,
//             textColor: Colors.white,
//           );
//           Navigator.pop(context); // or push to view screen
//         }
//       } else {
//         if (mounted) {
//           Fluttertoast.showToast(
//             msg: data['message'] ?? "Update failed",
//             backgroundColor: Colors.red.shade700,
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         Fluttertoast.showToast(
//           msg: "Error saving profile",
//           backgroundColor: Colors.red.shade700,
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isSaving = false);
//     }
//   }
//
//   Widget _buildYesNoRow(
//       String label,
//       String groupValue,
//       ValueChanged<String?> onChanged,
//       ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//           ),
//           Row(
//             children: [
//               Radio<String>(
//                 value: 'yes',
//                 groupValue: groupValue,
//                 activeColor: const Color(0xFF4CAF50),
//                 onChanged: onChanged,
//               ),
//               const Text('Yes'),
//               const SizedBox(width: 32),
//               Radio<String>(
//                 value: 'no',
//                 groupValue: groupValue,
//                 activeColor: const Color(0xFF4CAF50),
//                 onChanged: onChanged,
//               ),
//               const Text('No'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTextField(
//       TextEditingController controller,
//       String label,
//       IconData icon, {
//         bool enabled = true,
//         String? hint,
//       }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: TextField(
//         controller: controller,
//         enabled: enabled,
//         decoration: InputDecoration(
//           labelText: label,
//           hintText: hint,
//           prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         keyboardType: TextInputType.numberWithOptions(decimal: true),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       appBar: AppBar(
//         title: const Text("Edit Health Profile"),
//         backgroundColor: Colors.white,
//         foregroundColor: const Color(0xFF1F2937),
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Your Health Information",
//                 style: TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFF1F2937),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 "Keep your profile up to date for better calorie & nutrition insights",
//                 style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
//               ),
//
//               const SizedBox(height: 32),
//
//               _buildTextField(_heightController,     "Height (cm)",                Icons.straighten),
//               _buildTextField(_weightController,     "Weight (kg)",                Icons.monitor_weight),
//               _buildTextField(_bmiController,        "BMI",                        Icons.calculate_outlined, enabled: false, hint: "Calculated automatically"),
//
//               const SizedBox(height: 16),
//
//               _buildYesNoRow("Cardiac Condition", _hasCardiac, (v) {
//                 if (v != null) setState(() => _hasCardiac = v);
//               }),
//
//               _buildTextField(_bodyTypeController,   "Body Type (e.g. Ectomorph, Mesomorph…)", Icons.accessibility_new),
//
//               _buildTextField(_bpController,         "Blood Pressure (e.g. 120/80 mmHg)", Icons.favorite_border),
//               _buildTextField(_cholesterolController,"Cholesterol Level (mg/dL)",      Icons.analytics),
//               _buildTextField(_sugarLevelController, "Fasting Sugar Level (mg/dL)",    Icons.science),
//
//               const SizedBox(height: 16),
//
//               _buildYesNoRow("Thyroid Condition", _hasThyroid, (v) {
//                 if (v != null) setState(() => _hasThyroid = v);
//               }),
//
//               _buildTextField(_waistController,      "Waist Circumference (cm)",      Icons.straighten),
//               _buildTextField(_hipController,        "Hip Circumference (cm)",        Icons.straighten),
//
//               _buildTextField(_vitaminDController,   "Vitamin D Level (ng/mL)",       Icons.sunny),
//               _buildTextField(_ironController,       "Iron / Ferritin Level",         Icons.opacity),
//
//               const SizedBox(height: 16),
//
//               _buildYesNoRow("Smoking", _smoking, (v) {
//                 if (v != null) setState(() => _smoking = v);
//               }),
//
//               _buildYesNoRow("Alcohol Consumption", _alcohol, (v) {
//                 if (v != null) setState(() => _alcohol = v);
//               }),
//
//               _buildTextField(_activityLevelController, "Physical Activity Level", Icons.directions_run),
//               _buildTextField(_boneDensityController,   "Bone Density T-score",     Icons.person),
//
//               const SizedBox(height: 48),
//
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton.icon(
//                   onPressed: _isSaving ? null : _saveHealthProfile,
//                   icon: _isSaving
//                       ? const SizedBox(
//                     width: 22,
//                     height: 22,
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2.8,
//                     ),
//                   )
//                       : const Icon(Icons.save_rounded),
//                   label: Text(
//                     _isSaving ? "Saving..." : "Save Profile",
//                     style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF10B981),
//                     foregroundColor: Colors.white,
//                     disabledBackgroundColor: Colors.grey.shade400,
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
//   @override
//   void dispose() {
//     _heightController.dispose();
//     _weightController.dispose();
//     _bmiController.dispose();
//     _bloodGroupController.dispose();
//     _bodyTypeController.dispose();
//     _bpController.dispose();
//     _cholesterolController.dispose();
//     _sugarLevelController.dispose();
//     _waistController.dispose();
//     _hipController.dispose();
//     _vitaminDController.dispose();
//     _ironController.dispose();
//     _activityLevelController.dispose();
//     _boneDensityController.dispose();
//     super.dispose();
//   }
// }