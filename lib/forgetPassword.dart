import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'login/src/loginPage.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  DESIGN TOKENS  (matches app dark neon theme)
// ─────────────────────────────────────────────────────────────────────────────
class _DS {
  static const bg            = Color(0xFF050D0A);
  static const bgCard        = Color(0xFF0C1A13);
  static const surface       = Color(0xFF0F2018);
  static const neon          = Color(0xFF00FF88);
  static const neonDim       = Color(0xFF00C46A);
  static const neonFaint     = Color(0xFF003D22);
  static const accent3       = Color(0xFFFF6B6B);
  static const accent4       = Color(0xFFFFD166);
  static const accent1       = Color(0xFF00E5FF);
  static const textPrimary   = Color(0xFFF0FFF8);
  static const textSecondary = Color(0xFF6EE7B7);
  static const textMuted     = Color(0xFF4A8A68);
  static const borderFaint   = Color(0xFF112B1E);
}

// ─────────────────────────────────────────────────────────────────────────────
//  PAGE
//  Your original API contract is kept exactly:
//    POST  <url>/and_forget_password_post/   body: { email }
//    OK response:  status == 'ok'  →  navigate to LoginPage
// ─────────────────────────────────────────────────────────────────────────────
class changePassword extends StatefulWidget {
  const changePassword({super.key});

  @override
  State<changePassword> createState() => _changePasswordState();
}

class _changePasswordState extends State<changePassword>
    with TickerProviderStateMixin {

  final _emailCtrl = TextEditingController();
  bool   _loading  = false;
  bool   _sent     = false;   // flips to true after successful API call
  String _error    = '';

  // ── Animations ─────────────────────────────────────────────────────────────
  late final AnimationController _fadeCtrl;
  late final AnimationController _shakeCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _particleCtrl;

  late final Animation<double> _fadeAnim;
  late final Animation<double> _shakeAnim;
  late final Animation<double> _pulseAnim;

  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticOut));

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _fadeCtrl.dispose();
    _shakeCtrl.dispose();
    _pulseCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  // ── Validate email ─────────────────────────────────────────────────────────
  bool _isValidEmail(String e) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e);

  void _triggerError(String msg) {
    setState(() => _error = msg);
    _shakeCtrl.reset();
    _shakeCtrl.forward();
    HapticFeedback.heavyImpact();
  }

  // ── Submit  (keeps your exact API) ────────────────────────────────────────
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final email = _emailCtrl.text.trim();

    if (email.isEmpty) {
      _triggerError('Please enter your email address');
      return;
    }
    if (!_isValidEmail(email)) {
      _triggerError('Enter a valid email (e.g. user@gmail.com)');
      return;
    }

    setState(() { _loading = true; _error = ''; });

    try {
      final sh  = await SharedPreferences.getInstance();
      final url = sh.getString('url').toString();

      final response = await http.post(
        Uri.parse('$url/and_forget_password_post/'),
        body: {'email': email},   // ← your original body
      );

      if (response.statusCode == 200) {
        final status = jsonDecode(response.body)['status'];

        if (status == 'ok') {
          // ── SUCCESS ─────────────────────────────────────────────────────
          _spawnParticles();
          _particleCtrl.forward(from: 0);
          setState(() { _sent = true; _loading = false; });
          HapticFeedback.mediumImpact();
        } else {
          setState(() => _loading = false);
          _triggerError('Email not found. Check and try again.');
        }
      } else {
        setState(() => _loading = false);
        _triggerError('Network error (${response.statusCode}). Try again.');
      }
    } catch (e) {
      setState(() => _loading = false);
      _triggerError('Connection failed. Check your internet.');
    }
  }

  // ── Particle burst ─────────────────────────────────────────────────────────
  void _spawnParticles() {
    final rng = math.Random();
    _particles
      ..clear()
      ..addAll(List.generate(20, (_) => _Particle(
        angle: rng.nextDouble() * 2 * math.pi,
        speed: 50 + rng.nextDouble() * 90,
        size:  3 + rng.nextDouble() * 5,
        color: [_DS.neon, _DS.accent1, _DS.accent4, _DS.neonDim,
          const Color(0xFFB2FF59)][rng.nextInt(5)],
      )));
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
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: _sent ? _buildSuccess() : _buildForm(),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  FORM
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Back button ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: _DS.surface,
                shape: BoxShape.circle,
                border: Border.all(color: _DS.borderFaint, width: 1),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: _DS.neon, size: 18),
            ),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Pulsing icon ─────────────────────────────────────────
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, __) => Transform.scale(
                    scale: _pulseAnim.value,
                    child: Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(colors: [
                          _DS.neon.withOpacity(0.2),
                          _DS.neonFaint,
                        ]),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                            color: _DS.neon.withOpacity(0.35), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: _DS.neon.withOpacity(0.22),
                              blurRadius: 28,
                              spreadRadius: 2),
                        ],
                      ),
                      child: const Icon(Icons.lock_open_rounded,
                          color: _DS.neon, size: 34),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Heading ───────────────────────────────────────────────
                const Text('Forgot your\npassword?',
                    style: TextStyle(
                        color: _DS.textPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                        height: 1.15)),
                const SizedBox(height: 12),
                const Text(
                  "Enter the email linked to your account and we'll send you a reset link.",
                  style: TextStyle(
                      color: _DS.textMuted, fontSize: 14, height: 1.6),
                ),
                const SizedBox(height: 40),

                // ── Label ─────────────────────────────────────────────────
                Row(children: const [
                  Text('Email address',
                      style: TextStyle(
                          color: _DS.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                  Text(' *',
                      style: TextStyle(color: _DS.accent3, fontSize: 12)),
                ]),
                const SizedBox(height: 8),

                // ── Email field with shake animation ──────────────────────
                AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(
                      _error.isNotEmpty
                          ? (4 * (_shakeAnim.value - 0.5).abs() - 1) * 10
                          : 0,
                      0,
                    ),
                    child: child,
                  ),
                  child: _buildEmailField(),
                ),

                // ── Error ─────────────────────────────────────────────────
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  child: _error.isNotEmpty
                      ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 13, color: _DS.accent3),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(_error,
                            style: const TextStyle(
                                color: _DS.accent3,
                                fontSize: 11,
                                height: 1.4)),
                      ),
                    ]),
                  )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 32),

                // ── Button ────────────────────────────────────────────────
                _buildSubmitButton(),
                const SizedBox(height: 24),

                // ── Back to login link ────────────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 13),
                        children: [
                          TextSpan(
                              text: 'Remember it? ',
                              style: TextStyle(color: _DS.textMuted)),
                          TextSpan(
                              text: 'Back to Login',
                              style: TextStyle(
                                  color: _DS.neon,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Email input ────────────────────────────────────────────────────────────
  Widget _buildEmailField() {
    return AnimatedBuilder(
      animation: _emailCtrl,
      builder: (_, __) {
        final hasText = _emailCtrl.text.isNotEmpty;
        final isValid = hasText && _isValidEmail(_emailCtrl.text.trim());

        return TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          onChanged: (_) {
            if (_error.isNotEmpty) setState(() => _error = '');
          },
          style: const TextStyle(
              color: _DS.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'yourname@example.com',
            hintStyle: TextStyle(
                color: _DS.textMuted.withOpacity(0.45), fontSize: 14),
            prefixIcon: Icon(
              Icons.email_outlined,
              color: _error.isNotEmpty
                  ? _DS.accent3
                  : hasText ? _DS.neon : _DS.textMuted,
              size: 18,
            ),
            // Live check/cross icon as user types
            suffixIcon: hasText
                ? Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                isValid
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: isValid ? _DS.neon : _DS.accent3,
                size: 18,
              ),
            )
                : null,
            filled: true,
            fillColor: _DS.bgCard,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                const BorderSide(color: _DS.borderFaint, width: 1)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                    color: _error.isNotEmpty
                        ? _DS.accent3.withOpacity(0.5)
                        : _DS.borderFaint,
                    width: 1)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                    color: _error.isNotEmpty ? _DS.accent3 : _DS.neon,
                    width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 15),
          ),
        );
      },
    );
  }

  // ── Submit button — reactive gradient ─────────────────────────────────────
  Widget _buildSubmitButton() {
    return AnimatedBuilder(
      animation: _emailCtrl,
      builder: (_, __) {
        final ready = _isValidEmail(_emailCtrl.text.trim());

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: ready
                  ? const LinearGradient(
                  colors: [_DS.neon, _DS.neonDim],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight)
                  : null,
              color: ready ? null : _DS.bgCard,
              border:
              ready ? null : Border.all(color: _DS.borderFaint, width: 1),
              boxShadow: ready
                  ? [
                BoxShadow(
                    color: _DS.neon.withOpacity(0.28),
                    blurRadius: 20,
                    offset: const Offset(0, 6))
              ]
                  : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _loading ? null : _submit,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: _loading
                      ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: ready ? _DS.bg : _DS.neon,
                        strokeWidth: 2.5),
                  )
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.send_rounded,
                          size: 17,
                          color: ready ? _DS.bg : _DS.textMuted),
                      const SizedBox(width: 8),
                      Text(
                        'Send Reset Link',
                        style: TextStyle(
                            color: ready ? _DS.bg : _DS.textMuted,
                            fontSize: 15,
                            fontWeight: FontWeight.w800),
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

  // ─────────────────────────────────────────────────────────────────────────
  //  SUCCESS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSuccess() {
    return Stack(
      children: [
        // Particle burst
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _particleCtrl,
            builder: (_, __) => CustomPaint(
              painter: _ParticlePainter(_particles, _particleCtrl.value),
            ),
          ),
        ),

        // Content
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // Glowing envelope
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, __) => Transform.scale(
                    scale: _pulseAnim.value,
                    child: Container(
                      width: 118,
                      height: 118,
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
                              blurRadius: 44,
                              spreadRadius: 4),
                        ],
                      ),
                      child: const Icon(Icons.mark_email_read_rounded,
                          color: _DS.neon, size: 56),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                const Text('Check your inbox! 📬',
                    style: TextStyle(
                        color: _DS.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5)),
                const SizedBox(height: 14),

                // Show email used
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                        color: _DS.textMuted, fontSize: 14, height: 1.65),
                    children: [
                      const TextSpan(text: 'A password reset link was sent to\n'),
                      TextSpan(
                        text: _emailCtrl.text.trim(),
                        style: const TextStyle(
                            color: _DS.neon, fontWeight: FontWeight.w800),
                      ),
                      const TextSpan(
                          text: '\n\nCheck spam if you don\'t see it.'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Tip card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _DS.bgCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: _DS.accent4.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.tips_and_updates_rounded,
                          color: _DS.accent4, size: 17),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'After resetting, come back here and log in with your new password.',
                          style: TextStyle(
                              color: _DS.accent4,
                              fontSize: 12,
                              height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Go to Login  (your original navigation target) ─────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginPage()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _DS.neon,
                      foregroundColor: _DS.bg,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Back to Login',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(height: 14),

                // Try a different email
                GestureDetector(
                  onTap: () {
                    _fadeCtrl.reset();
                    setState(() {
                      _sent = false;
                      _emailCtrl.clear();
                      _error = '';
                    });
                    _fadeCtrl.forward();
                  },
                  child: const Text(
                    'Try a different email',
                    style: TextStyle(
                        color: _DS.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PARTICLE BURST PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _Particle {
  final double angle, speed, size;
  final Color color;
  const _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;

  const _ParticlePainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 - 80;

    for (final p in particles) {
      final fade = (1.0 - t).clamp(0.0, 1.0);
      final dist = p.speed * t;
      final px   = cx + math.cos(p.angle) * dist;
      final py   = cy + math.sin(p.angle) * dist;

      canvas.drawCircle(
        Offset(px, py),
        p.size * (1 - t * 0.4),
        Paint()
          ..color = p.color.withOpacity(fade * 0.9)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}




// import 'package:flutter/material.dart';
//
// void main(){
//   runApp(myapp());
// }
// class myapp extends StatelessWidget {
//   const myapp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: changePassword(),
//     );
//   }
// }
// class changePassword extends StatefulWidget {
//   const changePassword({super.key});
//
//   @override
//   State<changePassword> createState() => _changePasswordState();
// }
//
// class _changePasswordState extends State<changePassword> {
//
//   TextEditingController emailcontroller = new TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return  Scaffold(
//       appBar: AppBar(
//         leading: BackButton(),
//         title: Text("Forget Password"),
//         backgroundColor: Colors.orange,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: emailcontroller,
//               decoration: InputDecoration(
//                   hintText: 'E-mail',
//                   border: InputBorder.none,
//                   fillColor: Color(0xfff3f3f4),
//                   filled: true),
//             ),
//           ),
//           SizedBox(
//             height: 20,
//           ),
//           ElevatedButton(onPressed: (){}, child: Text('Submit'))
//         ],
//       ),
//     );
//   }
// }
