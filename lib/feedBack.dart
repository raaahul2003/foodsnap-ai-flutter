import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────
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
  static const textPrimary = Color(0xFFF0FFF8);
  static const textSecondary = Color(0xFF6EE7B7);
  static const textMuted   = Color(0xFF4A8A68);
  static const borderFaint = Color(0xFF112B1E);
}

// ─────────────────────────────────────────────────────────────────────────────
//  FEEDBACK SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with TickerProviderStateMixin {

  final _formKey           = GlobalKey<FormState>();
  final _feedbackCtrl      = TextEditingController();
  final _focusNode         = FocusNode();

  int  _rating             = 0;
  int  _hoveredStar        = 0;
  bool _isSubmitting       = false;
  bool _submitted          = false;

  // Feedback category chips
  final List<String> _categories = [
    '🍎 Food Recognition',
    '📊 Calorie Accuracy',
    '🎨 Design & UI',
    '⚡ App Speed',
    '💡 New Feature Idea',
    '🐛 Bug Report',
    '🌟 General Praise',
  ];
  final Set<String> _selectedCategories = {};

  // Animations
  late AnimationController _fadeCtrl;
  late AnimationController _starCtrl;
  late AnimationController _successCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _starAnim;
  late Animation<double> _successAnim;
  late Animation<double> _pulseAnim;

  // Star burst particles
  final List<_StarParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _starCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _starAnim = CurvedAnimation(parent: _starCtrl, curve: Curves.elasticOut);

    _successCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _successAnim = CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut);

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _starCtrl.dispose();
    _successCtrl.dispose();
    _pulseCtrl.dispose();
    _feedbackCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onStarTap(int star) {
    HapticFeedback.lightImpact();
    setState(() {
      _rating = star;
      _particles.clear();
      // Generate burst particles
      final rng = math.Random();
      for (int i = 0; i < 12; i++) {
        _particles.add(_StarParticle(
          angle: rng.nextDouble() * 2 * math.pi,
          speed: 30 + rng.nextDouble() * 60,
          size: 3 + rng.nextDouble() * 5,
          color: [_DS.accent4, _DS.neon, _DS.accent1, _DS.accent2][rng.nextInt(4)],
        ));
      }
    });
    _starCtrl.reset();
    _starCtrl.forward();
  }

  // ── Rating label ───────────────────────────────────────────────────────────
  String get _ratingLabel {
    switch (_rating) {
      case 1: return 'Pretty bad 😔';
      case 2: return 'Could be better 😕';
      case 3: return 'It\'s okay 😐';
      case 4: return 'Really good! 😊';
      case 5: return 'Absolutely love it! 🔥';
      default: return 'Tap a star to rate';
    }
  }

  Color get _ratingColor {
    if (_rating == 0) return _DS.textMuted;
    if (_rating <= 2) return _DS.accent3;
    if (_rating == 3) return _DS.accent4;
    return _DS.neon;
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (_rating == 0) {
      HapticFeedback.heavyImpact();
      Fluttertoast.showToast(
        msg: "Please give us a star rating first ⭐",
        backgroundColor: _DS.accent3,
        textColor: Colors.white,
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    _focusNode.unfocus();

    try {
      final prefs   = await SharedPreferences.getInstance();
      final baseUrl = prefs.getString('url') ?? '';
      final lid     = prefs.getString('lid') ?? '';

      if (baseUrl.isEmpty || lid.isEmpty) {
        Fluttertoast.showToast(msg: "Missing server configuration");
        return;
      }

      final req = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/send_feedback/'));
      req.fields.addAll({
        'feedback': _feedbackCtrl.text.trim(),
        'rating':   _rating.toString(),
        'categories': _selectedCategories.join(', '),
        'lid':      lid,
      });

      final res  = await req.send();
      final body = await res.stream.bytesToString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      if (res.statusCode == 200 && data['status'] == 'ok') {
        setState(() { _submitted = true; _isSubmitting = false; });
        HapticFeedback.mediumImpact();
        _successCtrl.forward();
      } else {
        throw Exception(data['message'] ?? 'Server error');
      }
    } catch (_) {
      Fluttertoast.showToast(
        msg: "Couldn't send feedback. Please try again.",
        backgroundColor: _DS.accent3,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      if (mounted && !_submitted) setState(() => _isSubmitting = false);
    }
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
        body: _submitted ? _buildSuccessState() : _buildForm(),
      ),
    );
  }

  // ── Success state ──────────────────────────────────────────────────────────
  Widget _buildSuccessState() {
    return SafeArea(
      child: Center(
        child: ScaleTransition(
          scale: _successAnim,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated neon checkmark ring
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, __) => Transform.scale(
                    scale: _pulseAnim.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          _DS.neon.withOpacity(0.25),
                          _DS.neonFaint,
                        ]),
                        border: Border.all(
                            color: _DS.neon.withOpacity(0.5), width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: _DS.neon.withOpacity(0.35),
                              blurRadius: 40,
                              spreadRadius: 4),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.check_rounded,
                            color: _DS.neon, size: 56),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Thank you! 🎉',
                  style: TextStyle(
                      color: _DS.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your feedback helps us build a better\nFoodSnap AI for everyone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: _DS.textMuted,
                      fontSize: 15,
                      height: 1.55),
                ),
                const SizedBox(height: 32),

                // Show what was submitted
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _DS.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _DS.neon.withOpacity(0.2), width: 1),
                  ),
                  child: Row(children: [
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < _rating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: i < _rating ? _DS.accent4 : _DS.textMuted,
                        size: 22,
                      )),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _ratingLabel,
                        style: TextStyle(
                            color: _ratingColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 28),

                // Back button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _DS.neonFaint,
                      foregroundColor: _DS.neon,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                              color: _DS.neon.withOpacity(0.3), width: 1)),
                    ),
                    child: const Text('Back to Home',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Main form ──────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),

                // ── Subtitle ────────────────────────────────────────────
                const Text(
                  'Your voice shapes the future of\nAI-powered nutrition.',
                  style: TextStyle(
                      color: _DS.textMuted,
                      fontSize: 14,
                      height: 1.55),
                ),
                const SizedBox(height: 28),

                // ── Star Rating ─────────────────────────────────────────
                _buildStarCard(),
                const SizedBox(height: 20),

                // ── Category chips ──────────────────────────────────────
                _buildCategorySection(),
                const SizedBox(height: 20),

                // ── Feedback text ───────────────────────────────────────
                _buildFeedbackInput(),
                const SizedBox(height: 28),

                // ── Submit button ───────────────────────────────────────
                _buildSubmitButton(),
                const SizedBox(height: 20),

                // Footer note
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.lock_outline_rounded,
                          size: 11, color: _DS.textMuted),
                      SizedBox(width: 5),
                      Text(
                        'Your feedback is private and anonymous',
                        style: TextStyle(
                            color: _DS.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                      ),
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

  // ── Sliver app bar ─────────────────────────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
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
          child: const Icon(Icons.arrow_back_rounded,
              color: _DS.neon, size: 18),
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
              padding: const EdgeInsets.fromLTRB(20, 44, 20, 12),
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
                      child: const Icon(Icons.rate_review_rounded,
                          color: _DS.neon, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Text('Share Feedback',
                        style: TextStyle(
                            color: _DS.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5)),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Star rating card ───────────────────────────────────────────────────────
  Widget _buildStarCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: _ratingColor.withOpacity(_rating > 0 ? 0.3 : 0.1),
            width: 1),
        boxShadow: _rating > 0
            ? [
          BoxShadow(
              color: _ratingColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4))
        ]
            : [],
      ),
      child: Column(
        children: [
          Text(
            'How was your experience?',
            style: const TextStyle(
                color: _DS.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2),
          ),
          const SizedBox(height: 20),

          // Stars row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final starNum  = i + 1;
              final filled   = starNum <= _rating;
              final hovered  = starNum <= _hoveredStar;

              return GestureDetector(
                onTap: () => _onStarTap(starNum),
                child: AnimatedBuilder(
                  animation: _starAnim,
                  builder: (_, __) {
                    final scale = filled && _rating == starNum
                        ? 1.0 + (_starAnim.value * 0.3)
                        : filled ? 1.1 : 1.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: filled
                                ? _DS.accent4.withOpacity(0.12)
                                : _DS.surface,
                            border: Border.all(
                              color: filled
                                  ? _DS.accent4.withOpacity(0.4)
                                  : _DS.borderFaint,
                              width: 1,
                            ),
                            boxShadow: filled
                                ? [
                              BoxShadow(
                                  color: _DS.accent4.withOpacity(0.25),
                                  blurRadius: 12,
                                  spreadRadius: 1)
                            ]
                                : [],
                          ),
                          child: Icon(
                            filled || hovered
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: filled
                                ? _DS.accent4
                                : _DS.textMuted.withOpacity(0.5),
                            size: 26,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Rating label with animated color
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              color: _ratingColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
            child: Text(_ratingLabel),
          ),
        ],
      ),
    );
  }

  // ── Category chips ─────────────────────────────────────────────────────────
  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Text('What\'s this about?',
              style: TextStyle(
                  color: _DS.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          Text('(optional)',
              style: TextStyle(
                  color: _DS.textMuted.withOpacity(0.7),
                  fontSize: 11)),
        ]),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((cat) {
            final sel = _selectedCategories.contains(cat);
            // Pick a color per category
            final catColor = _categoryColor(cat);
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  if (sel) _selectedCategories.remove(cat);
                  else     _selectedCategories.add(cat);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? catColor.withOpacity(0.15) : _DS.bgCard,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                      color: sel ? catColor : _DS.borderFaint,
                      width: sel ? 1.2 : 1),
                  boxShadow: sel
                      ? [
                    BoxShadow(
                        color: catColor.withOpacity(0.12),
                        blurRadius: 8)
                  ]
                      : [],
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                      color: sel ? catColor : _DS.textMuted,
                      fontSize: 12,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _categoryColor(String cat) {
    if (cat.contains('Food'))     return _DS.neon;
    if (cat.contains('Calorie'))  return _DS.accent4;
    if (cat.contains('Design'))   return _DS.accent5;
    if (cat.contains('Speed'))    return _DS.accent1;
    if (cat.contains('Feature'))  return _DS.accent2;
    if (cat.contains('Bug'))      return _DS.accent3;
    return _DS.neon;
  }

  // ── Feedback text input ────────────────────────────────────────────────────
  Widget _buildFeedbackInput() {
    final charCount = _feedbackCtrl.text.length;
    final maxChars  = 500;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('Your thoughts',
                style: TextStyle(
                    color: _DS.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
            const Text(' *',
                style: TextStyle(color: _DS.accent3, fontSize: 13)),
          ]),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _feedbackCtrl,
            builder: (_, __) {
              final focused = _focusNode.hasFocus;
              return Stack(
                children: [
                  TextFormField(
                    controller: _feedbackCtrl,
                    focusNode: _focusNode,
                    maxLines: 6,
                    minLines: 5,
                    maxLength: maxChars,
                    buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                    const SizedBox.shrink(), // hide default counter
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                        color: _DS.textPrimary,
                        fontSize: 14,
                        height: 1.6),
                    decoration: InputDecoration(
                      hintText:
                      'e.g. "Love the food scanner! It would be amazing if I could create custom recipes and track home-cooked meals..."',
                      hintStyle: TextStyle(
                          color: _DS.textMuted.withOpacity(0.5),
                          fontSize: 13,
                          height: 1.5),
                      filled: true,
                      fillColor: _DS.bgCard,
                      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 42),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide:
                          const BorderSide(color: _DS.borderFaint, width: 1)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide:
                          const BorderSide(color: _DS.borderFaint, width: 1)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide:
                          const BorderSide(color: _DS.neon, width: 1.5)),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                              color: _DS.accent3, width: 1.2)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                              color: _DS.accent3, width: 1.5)),
                      errorStyle: const TextStyle(
                          color: _DS.accent3, fontSize: 11),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Please share something — even a short note helps!';
                      if (v.trim().length < 10)
                        return 'A bit more detail would really help us 🙏';
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),

                  // Character counter overlay
                  Positioned(
                    bottom: 12,
                    right: 14,
                    child: AnimatedOpacity(
                      opacity: charCount > 0 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: charCount > maxChars * 0.9
                              ? _DS.accent3.withOpacity(0.12)
                              : _DS.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: charCount > maxChars * 0.9
                                ? _DS.accent3.withOpacity(0.3)
                                : _DS.borderFaint,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '$charCount / $maxChars',
                          style: TextStyle(
                              color: charCount > maxChars * 0.9
                                  ? _DS.accent3
                                  : _DS.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Submit button ──────────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) {
        final readyToSend = _rating > 0 &&
            _feedbackCtrl.text.trim().length >= 10;
        return Transform.scale(
          scale: readyToSend ? _pulseAnim.value : 1.0,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: readyToSend
                  ? const LinearGradient(
                colors: [_DS.neon, _DS.neonDim],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
                  : null,
              color: readyToSend ? null : _DS.bgCard,
              border: readyToSend
                  ? null
                  : Border.all(color: _DS.borderFaint, width: 1),
              boxShadow: readyToSend
                  ? [
                BoxShadow(
                    color: _DS.neon.withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 6))
              ]
                  : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isSubmitting ? null : _submit,
                borderRadius: BorderRadius.circular(18),
                child: Center(
                  child: _isSubmitting
                      ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: readyToSend ? _DS.bg : _DS.neon,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.send_rounded,
                        size: 18,
                        color: readyToSend ? _DS.bg : _DS.textMuted,
                      ),
                      const SizedBox(width: 9),
                      Text(
                        readyToSend ? 'Send Feedback' : 'Rate & Write to Send',
                        style: TextStyle(
                            color: readyToSend ? _DS.bg : _DS.textMuted,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  STAR PARTICLE MODEL  (used for burst effect on star tap)
// ─────────────────────────────────────────────────────────────────────────────
class _StarParticle {
  final double angle;
  final double speed;
  final double size;
  final Color  color;
  _StarParticle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });
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
//         useMaterial3: true, // ← good to explicitly enable if you're using M3 styles
//         cardTheme: CardThemeData(                               // ← FIXED HERE
//           elevation: 3,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           color: Colors.white,
//           surfaceTintColor: Colors.transparent,                 // prevents M3 tint overlay
//           clipBehavior: Clip.antiAlias,
//         ),
//         inputDecorationTheme: InputDecorationTheme(
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide.none,
//           ),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//           labelStyle: TextStyle(color: Colors.grey.shade700),
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             elevation: 2,
//           ),
//         ),
//       ),
//       home: const FeedbackScreen(),
//     );
//   }
// }
//
// class FeedbackScreen extends StatefulWidget {
//   const FeedbackScreen({super.key});
//
//   @override
//   State<FeedbackScreen> createState() => _FeedbackScreenState();
// }
//
// class _FeedbackScreenState extends State<FeedbackScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _feedbackController = TextEditingController();
//   int _rating = 0;
//   bool _isSubmitting = false;
//
//   Future<void> _submitFeedback() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isSubmitting = true);
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final baseUrl = prefs.getString('url') ?? '';
//       final lid = prefs.getString('lid') ?? '';
//
//       if (baseUrl.isEmpty || lid.isEmpty) {
//         if (mounted) {
//           Fluttertoast.showToast(msg: "Missing server configuration");
//         }
//         return;
//       }
//
//       final uri = Uri.parse('$baseUrl/send_feedback/');
//       final request = http.MultipartRequest('POST', uri);
//
//       request.fields.addAll({
//         'feedback': _feedbackController.text.trim(),
//         'rating': _rating.toString(),
//         'lid': lid,
//       });
//
//       final response = await request.send();
//       final responseBody = await response.stream.bytesToString();
//       final data = jsonDecode(responseBody) as Map<String, dynamic>;
//
//       if (response.statusCode == 200 && data['status'] == 'ok') {
//         if (mounted) {
//           Fluttertoast.showToast(
//             msg: "Thank you for your feedback! ❤️",
//             backgroundColor: Colors.green.shade700,
//             textColor: Colors.white,
//             toastLength: Toast.LENGTH_LONG,
//           );
//           _feedbackController.clear();
//           setState(() => _rating = 0);
//         }
//       } else {
//         throw Exception(data['message'] ?? 'Server error');
//       }
//     } catch (e) {
//       if (mounted) {
//         Fluttertoast.showToast(
//           msg: "Couldn't send feedback. Please try again.",
//           backgroundColor: Colors.red.shade700,
//           textColor: Colors.white,
//           toastLength: Toast.LENGTH_LONG,
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isSubmitting = false);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       appBar: AppBar(
//         title: const Text("Feedback"),
//         backgroundColor: Colors.white,
//         foregroundColor: const Color(0xFF1F2937),
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 12),
//
//                 // Header
//                 const Text(
//                   "We'd love to hear from you",
//                   style: TextStyle(
//                     fontSize: 26,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF1F2937),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   "Your feedback helps us improve FoodSnap AI and make calorie tracking easier for everyone.",
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Colors.grey.shade700,
//                     height: 1.4,
//                   ),
//                 ),
//
//                 const SizedBox(height: 32),
//
//                 // Rating stars card
//                 Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(20),
//                     child: Column(
//                       children: [
//                         Text(
//                           "How would you rate your experience?",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.grey.shade800,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: List.generate(5, (index) {
//                             return IconButton(
//                               icon: Icon(
//                                 index < _rating ? Icons.star_rounded : Icons.star_border_rounded,
//                                 color: const Color(0xFFFFC107),
//                                 size: 40,
//                               ),
//                               padding: EdgeInsets.zero,
//                               constraints: const BoxConstraints(),
//                               onPressed: () {
//                                 setState(() => _rating = index + 1);
//                               },
//                             );
//                           }),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           _rating == 0
//                               ? "Tap a star"
//                               : _rating <= 2
//                               ? "We're sorry to hear that"
//                               : _rating == 3
//                               ? "It's okay"
//                               : "Glad you like it!",
//                           style: TextStyle(
//                             color: _rating <= 2 ? Colors.red.shade700 : Colors.green.shade700,
//                             fontWeight: FontWeight.w500,
//                             fontSize: 15,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 // Feedback input
//                 TextFormField(
//                   controller: _feedbackController,
//                   decoration: InputDecoration(
//                     labelText: "Your thoughts, suggestions, or issues",
//                     hintText:
//                     "e.g. \"Love the food recognition! Would be great to add custom recipes...\"",
//                     alignLabelWithHint: true,
//                     floatingLabelBehavior: FloatingLabelBehavior.auto,
//                   ),
//                   maxLines: 6,
//                   minLines: 4,
//                   textCapitalization: TextCapitalization.sentences,
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return "Please share something — even a short note helps!";
//                     }
//                     if (value.trim().length < 5) {
//                       return "Feedback is too short";
//                     }
//                     return null;
//                   },
//                 ),
//
//                 const SizedBox(height: 32),
//
//                 // Submit button
//                 SizedBox(
//                   width: double.infinity,
//                   height: 56,
//                   child: ElevatedButton.icon(
//                     onPressed: _isSubmitting ? null : _submitFeedback,
//                     icon: _isSubmitting
//                         ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2.5,
//                         color: Colors.white,
//                       ),
//                     )
//                         : const Icon(Icons.send_rounded),
//                     label: Text(
//                       _isSubmitting ? "Sending..." : "Send Feedback",
//                       style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF10B981),
//                       foregroundColor: Colors.white,
//                       disabledBackgroundColor: Colors.grey.shade300,
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 40),
//
//                 Center(
//                   child: Text(
//                     "Thank you for helping us improve FoodSnap AI",
//                     style: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _feedbackController.dispose();
//     super.dispose();
//   }
// }