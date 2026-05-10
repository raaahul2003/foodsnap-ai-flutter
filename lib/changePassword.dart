import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login/src/loginPage.dart';

// ── Design Tokens ─────────────────────────────────────────────────────────────
class _DS {
  static const bg           = Color(0xFF050D0A);
  static const bgCard       = Color(0xFF0C1A13);
  static const surface      = Color(0xFF0F2018);
  static const neon         = Color(0xFF00FF88);
  static const neonDim      = Color(0xFF00C46A);
  static const neonFaint    = Color(0xFF003D22);
  static const accent1      = Color(0xFF00E5FF);
  static const accent3      = Color(0xFFFF6B6B);
  static const accent4      = Color(0xFFFFD166);
  static const textPrimary  = Color(0xFFF0FFF8);
  static const textMuted    = Color(0xFF2E6B4A);
  static const borderFaint  = Color(0xFF1A3D2A);
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage>
    with TickerProviderStateMixin {

  // ── Controllers (unchanged) ───────────────────────────────────────────────
  final _formKey      = GlobalKey<FormState>();
  final _currentCtrl  = TextEditingController();
  final _newCtrl      = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew     = true;
  bool _obscureConfirm = true;
  bool _isLoading      = false;

  // ── Password rules state ──────────────────────────────────────────────────
  bool _hasLength    = false;
  bool _hasUpper     = false;
  bool _hasLower     = false;
  bool _hasNumber    = false;
  bool _hasSpecial   = false;
  bool _passwordsMatch = false;

  // ── Animations ────────────────────────────────────────────────────────────
  late AnimationController _entryCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _shakeCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _slideAnim;
  late Animation<double>   _glowAnim;
  late Animation<double>   _shakeAnim;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic),
    );

    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.2, end: 0.75).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticOut),
    );

    _entryCtrl.forward();

    _newCtrl.addListener(_onNewPasswordChanged);
    _confirmCtrl.addListener(_onConfirmChanged);
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _glowCtrl.dispose();
    _shakeCtrl.dispose();
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Password rule checks ──────────────────────────────────────────────────
  void _onNewPasswordChanged() {
    final v = _newCtrl.text;
    setState(() {
      _hasLength  = v.length >= 8;
      _hasUpper   = v.contains(RegExp(r'[A-Z]'));
      _hasLower   = v.contains(RegExp(r'[a-z]'));
      _hasNumber  = v.contains(RegExp(r'[0-9]'));
      _hasSpecial = v.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]'));
      _passwordsMatch = v == _confirmCtrl.text && v.isNotEmpty;
    });
  }

  void _onConfirmChanged() {
    setState(() {
      _passwordsMatch = _confirmCtrl.text == _newCtrl.text && _confirmCtrl.text.isNotEmpty;
    });
  }

  // ── Strength score (0–5) ──────────────────────────────────────────────────
  int get _strengthScore =>
      [_hasLength, _hasUpper, _hasLower, _hasNumber, _hasSpecial]
          .where((r) => r)
          .length;

  Color get _strengthColor {
    if (_strengthScore <= 1) return _DS.accent3;
    if (_strengthScore <= 2) return _DS.accent4;
    if (_strengthScore <= 3) return _DS.accent4;
    if (_strengthScore == 4) return _DS.neonDim;
    return _DS.neon;
  }

  String get _strengthLabel {
    if (_newCtrl.text.isEmpty) return '';
    if (_strengthScore <= 1)   return 'Very Weak';
    if (_strengthScore == 2)   return 'Weak';
    if (_strengthScore == 3)   return 'Fair';
    if (_strengthScore == 4)   return 'Strong';
    return 'Very Strong';
  }

  // ── Backend (UNCHANGED) ───────────────────────────────────────────────────
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      _shakeCtrl.forward(from: 0);
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs   = await SharedPreferences.getInstance();
      final baseUrl = prefs.getString('url');
      final lid     = prefs.getString('lid');

      if (baseUrl == null || lid == null) {
        Fluttertoast.showToast(msg: "Missing configuration");
        return;
      }

      var request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/user_change_password_post/'));
      request.fields.addAll({
        'current': _currentCtrl.text,
        'newpass': _newCtrl.text,
        'confirm': _confirmCtrl.text,
        'lid':     lid,
      });

      final streamed  = await request.send();
      final response  = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'ok') {
          Fluttertoast.showToast(
            msg: "Password changed successfully ✓",
            backgroundColor: _DS.neonFaint,
            textColor: _DS.neon,
          );
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
          );
          return;
        }
      }

      Fluttertoast.showToast(
        msg: "Failed to change password. Check your current password.",
        backgroundColor: _DS.accent3,
        textColor: Colors.white,
      );
      _shakeCtrl.forward(from: 0);
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error: ${e.toString().split('\n').first}",
        backgroundColor: _DS.accent3,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (value.length < 8) return 'At least 8 characters required';
    return null;
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
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: AnimatedBuilder(
                  animation: _entryCtrl,
                  builder: (_, child) => Opacity(
                    opacity: _fadeAnim.value.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, _slideAnim.value),
                      child: child,
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          _buildHeroCard(),
                          const SizedBox(height: 24),
                          _buildCurrentPasswordField(),
                          const SizedBox(height: 16),
                          _buildNewPasswordField(),
                          const SizedBox(height: 12),
                          _buildStrengthMeter(),
                          const SizedBox(height: 12),
                          _buildPasswordRules(),
                          const SizedBox(height: 16),
                          _buildConfirmPasswordField(),
                          const SizedBox(height: 28),
                          _buildSubmitButton(),
                          const SizedBox(height: 20),
                          _buildLogoutNote(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _DS.neon, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Change Password",
                    style: const TextStyle(color: _DS.textPrimary, fontSize: 18,
                        fontWeight: FontWeight.w900, letterSpacing: -0.3)),
                Text("Keep your account secure",
                    style: TextStyle(color: _DS.textMuted, fontSize: 11)),
              ],
            ),
          ),
          // Lock icon pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _DS.neonFaint,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _DS.neon.withOpacity(0.3), width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_rounded, color: _DS.neon, size: 13),
                SizedBox(width: 5),
                Text("Secure", style: TextStyle(color: _DS.neon, fontSize: 11,
                    fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero info card ────────────────────────────────────────────────────────
  Widget _buildHeroCard() {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _DS.bgCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _DS.neon.withOpacity(0.15), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: _DS.neon.withOpacity(_glowAnim.value * 0.08),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _DS.neonFaint,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _DS.neon.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: _DS.neon.withOpacity(_glowAnim.value * 0.35),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(Icons.shield_rounded, color: _DS.neon, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Password Security",
                      style: const TextStyle(color: _DS.textPrimary, fontSize: 15,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(
                    "Use a strong password with uppercase, numbers & special characters.",
                    style: TextStyle(color: _DS.textMuted, fontSize: 11, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Current password field ────────────────────────────────────────────────
  Widget _buildCurrentPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel("Current Password", Icons.lock_outline_rounded, _DS.accent4),
        const SizedBox(height: 8),
        _passwordField(
          controller: _currentCtrl,
          hint: "Enter your current password",
          obscure: _obscureCurrent,
          onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          borderColor: _DS.accent4,
        ),
      ],
    );
  }

  // ── New password field ────────────────────────────────────────────────────
  Widget _buildNewPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel("New Password", Icons.lock_reset_rounded, _DS.neon),
        const SizedBox(height: 8),
        _passwordField(
          controller: _newCtrl,
          hint: "Create a strong new password",
          obscure: _obscureNew,
          onToggle: () => setState(() => _obscureNew = !_obscureNew),
          validator: _validatePassword,
          borderColor: _newCtrl.text.isEmpty ? _DS.borderFaint : _strengthColor,
        ),
      ],
    );
  }

  // ── Confirm password field ────────────────────────────────────────────────
  Widget _buildConfirmPasswordField() {
    final matchColor = _confirmCtrl.text.isEmpty
        ? _DS.borderFaint
        : _passwordsMatch
        ? _DS.neon
        : _DS.accent3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel("Confirm New Password", Icons.lock_rounded, _DS.accent1),
        const SizedBox(height: 8),
        _passwordField(
          controller: _confirmCtrl,
          hint: "Re-enter your new password",
          obscure: _obscureConfirm,
          onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
          validator: (value) {
            if (value != _newCtrl.text) return 'Passwords do not match';
            return null;
          },
          borderColor: matchColor,
          suffixStatus: _confirmCtrl.text.isEmpty
              ? null
              : _passwordsMatch
              ? Icons.check_circle_rounded
              : Icons.cancel_rounded,
          suffixColor: matchColor,
        ),
        if (_confirmCtrl.text.isNotEmpty && !_passwordsMatch)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 12, color: _DS.accent3),
                const SizedBox(width: 5),
                Text("Passwords don't match",
                    style: TextStyle(color: _DS.accent3, fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        if (_confirmCtrl.text.isNotEmpty && _passwordsMatch)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, size: 12, color: _DS.neon),
                const SizedBox(width: 5),
                Text("Passwords match",
                    style: TextStyle(color: _DS.neon, fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
      ],
    );
  }

  // ── Strength meter ────────────────────────────────────────────────────────
  Widget _buildStrengthMeter() {
    if (_newCtrl.text.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Password Strength",
                style: TextStyle(color: _DS.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
            Text(_strengthLabel,
                style: TextStyle(color: _strengthColor, fontSize: 11, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(5, (i) {
            final filled = i < _strengthScore;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 5,
                margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                decoration: BoxDecoration(
                  color: filled ? _strengthColor : _DS.surface,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: filled
                      ? [BoxShadow(color: _strengthColor.withOpacity(0.5), blurRadius: 4)]
                      : [],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Password rules checklist ──────────────────────────────────────────────
  Widget _buildPasswordRules() {
    if (_newCtrl.text.isEmpty) return const SizedBox.shrink();

    final rules = [
      (label: "At least 8 characters",          met: _hasLength),
      (label: "Uppercase letter (A–Z)",          met: _hasUpper),
      (label: "Lowercase letter (a–z)",          met: _hasLower),
      (label: "Number (0–9)",                    met: _hasNumber),
      (label: "Special character (!@#\$...)",   met: _hasSpecial),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _DS.borderFaint, width: 1),
      ),
      child: Column(
        children: rules.map((r) {
          final color = r.met ? _DS.neon : _DS.textMuted;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: r.met ? _DS.neon.withOpacity(0.15) : _DS.surface,
                    border: Border.all(
                      color: r.met ? _DS.neon : _DS.borderFaint,
                      width: 1.5,
                    ),
                  ),
                  child: r.met
                      ? const Icon(Icons.check_rounded, color: _DS.neon, size: 12)
                      : null,
                ),
                const SizedBox(width: 10),
                Text(r.label,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: r.met ? FontWeight.w700 : FontWeight.w400,
                    )),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Submit button ─────────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    final allRulesMet = _hasLength && _passwordsMatch;

    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnim, _shakeAnim]),
      builder: (_, __) {
        final shakeOffset = _shakeCtrl.isAnimating
            ? ((_shakeAnim.value * 12) * ((_shakeAnim.value * 10).toInt().isEven ? 1 : -1))
            : 0.0;

        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: GestureDetector(
            onTap: _isLoading ? null : () {
              HapticFeedback.mediumImpact();
              _changePassword();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: _isLoading || !allRulesMet
                    ? const LinearGradient(colors: [Color(0xFF003D22), Color(0xFF003D22)])
                    : const LinearGradient(
                  colors: [_DS.neon, _DS.neonDim],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: allRulesMet && !_isLoading
                      ? Colors.transparent
                      : _DS.borderFaint,
                  width: 1,
                ),
                boxShadow: allRulesMet && !_isLoading
                    ? [
                  BoxShadow(
                    color: _DS.neon.withOpacity(_glowAnim.value * 0.45),
                    blurRadius: 24,
                    spreadRadius: -4,
                    offset: const Offset(0, 6),
                  ),
                ]
                    : [],
              ),
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: _DS.neon, strokeWidth: 2.5),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: allRulesMet ? _DS.bg : _DS.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Update Password",
                      style: TextStyle(
                        color: allRulesMet ? _DS.bg : _DS.textMuted,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Logout note ───────────────────────────────────────────────────────────
  Widget _buildLogoutNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _DS.accent4.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _DS.accent4.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: _DS.accent4, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "After changing your password, you'll be logged out for security.",
              style: TextStyle(color: _DS.accent4.withOpacity(0.85), fontSize: 11, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared field label ────────────────────────────────────────────────────
  Widget _fieldLabel(String label, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 7),
        Text(label,
            style: TextStyle(color: color, fontSize: 12,
                fontWeight: FontWeight.w800, letterSpacing: 0.2)),
      ],
    );
  }

  // ── Shared password field ─────────────────────────────────────────────────
  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
    required Color borderColor,
    IconData? suffixStatus,
    Color? suffixColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withOpacity(0.5), width: 1.3),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        style: const TextStyle(
            color: _DS.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
        cursorColor: _DS.neon,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: _DS.textMuted, fontSize: 13),
          prefixIcon: const Icon(Icons.lock_outline_rounded,
              color: _DS.textMuted, size: 18),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (suffixStatus != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(suffixStatus, color: suffixColor, size: 18),
                ),
              GestureDetector(
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Icon(
                    obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: _DS.textMuted,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          errorStyle: const TextStyle(color: _DS.accent3, fontSize: 11),
        ),
      ),
    );
  }
}



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'login/src/loginPage.dart'; // adjust path if needed
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
//         inputDecorationTheme: InputDecorationTheme(
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide.none,
//           ),
//         ),
//       ),
//       home: const ChangePasswordPage(),
//     );
//   }
// }
//
// class ChangePasswordPage extends StatefulWidget {
//   const ChangePasswordPage({super.key});
//
//   @override
//   State<ChangePasswordPage> createState() => _ChangePasswordPageState();
// }
//
// class _ChangePasswordPageState extends State<ChangePasswordPage> {
//   final _formKey = GlobalKey<FormState>();
//
//   final _currentCtrl = TextEditingController();
//   final _newCtrl = TextEditingController();
//   final _confirmCtrl = TextEditingController();
//
//   bool _obscureCurrent = true;
//   bool _obscureNew = true;
//   bool _obscureConfirm = true;
//
//   bool _isLoading = false;
//
//   @override
//   void dispose() {
//     _currentCtrl.dispose();
//     _newCtrl.dispose();
//     _confirmCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _changePassword() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isLoading = true);
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
//       final uri = Uri.parse('$baseUrl/user_change_password_post/');
//
//       var request = http.MultipartRequest('POST', uri);
//       request.fields.addAll({
//         'current': _currentCtrl.text,
//         'newpass': _newCtrl.text,
//         'confirm': _confirmCtrl.text,
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
//             msg: "Password changed successfully",
//             backgroundColor: Colors.green[700],
//           );
//           if (!mounted) return;
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) =>  LoginPage()),
//           );
//           return;
//         }
//       }
//
//       Fluttertoast.showToast(msg: "Failed to change password");
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Error: ${e.toString().split('\n').first}");
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   String? _validatePassword(String? value) {
//     if (value == null || value.isEmpty) return 'Required';
//     if (value.length < 8) return 'At least 8 characters';
//     // You can add more rules: uppercase, number, etc.
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Change Password"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 16),
//
//                 // Header hint
//                 Text(
//                   "Update your password to keep your account secure.",
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Colors.grey[700],
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//
//                 const SizedBox(height: 40),
//
//                 // Current Password
//                 TextFormField(
//                   controller: _currentCtrl,
//                   obscureText: _obscureCurrent,
//                   validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
//                   decoration: InputDecoration(
//                     labelText: "Current Password",
//                     prefixIcon: const Icon(Icons.lock_outline),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscureCurrent ? Icons.visibility_off : Icons.visibility,
//                       ),
//                       onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 // New Password
//                 TextFormField(
//                   controller: _newCtrl,
//                   obscureText: _obscureNew,
//                   validator: _validatePassword,
//                   decoration: InputDecoration(
//                     labelText: "New Password",
//                     prefixIcon: const Icon(Icons.lock_reset),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscureNew ? Icons.visibility_off : Icons.visibility,
//                       ),
//                       onPressed: () => setState(() => _obscureNew = !_obscureNew),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 8),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 12),
//                   child: Text(
//                     "• At least 8 characters",
//                     style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 // Confirm Password
//                 TextFormField(
//                   controller: _confirmCtrl,
//                   obscureText: _obscureConfirm,
//                   validator: (value) {
//                     if (value != _newCtrl.text) return 'Passwords do not match';
//                     return null;
//                   },
//                   decoration: InputDecoration(
//                     labelText: "Confirm New Password",
//                     prefixIcon: const Icon(Icons.lock_outline),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscureConfirm ? Icons.visibility_off : Icons.visibility,
//                       ),
//                       onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 48),
//
//                 // Submit Button
//                 SizedBox(
//                   height: 56,
//                   child: ElevatedButton.icon(
//                     onPressed: _isLoading ? null : _changePassword,
//                     icon: _isLoading
//                         ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 2.5,
//                       ),
//                     )
//                         : const Icon(Icons.check_circle_outline),
//                     label: Text(
//                       _isLoading ? "Updating..." : "Update Password",
//                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF4CAF50),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                       elevation: 2,
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 32),
//
//                 Text(
//                   "After changing your password, you'll be logged out for security.",
//                   style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }