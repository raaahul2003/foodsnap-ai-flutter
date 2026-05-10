import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eatwise_ai/login/src/loginPage.dart';
import 'package:eatwise_ai/login/src/signup.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// ── Design Tokens (matches full app) ─────────────────────────────────────────
class _DS {
  static const bg            = Color(0xFF050D0A);
  static const bgCard        = Color(0xFF0C1A13);
  static const surface       = Color(0xFF0F2018);
  static const neon          = Color(0xFF00FF88);
  static const neonDim       = Color(0xFF00C46A);
  static const neonFaint     = Color(0xFF003D22);
  static const accent1       = Color(0xFF00E5FF);
  static const accent2       = Color(0xFFB2FF59);
  static const accent3       = Color(0xFFFF6B6B);
  static const accent4       = Color(0xFFFFD166);
  static const accent5       = Color(0xFFA78BFA);
  static const textPrimary   = Color(0xFFF0FFF8);
  static const textSecondary = Color(0xFF6EE7B7);
  static const textMuted     = Color(0xFF2E6B4A);
  static const borderFaint   = Color(0xFF1A3D2A);
}

class WelcomePage extends StatefulWidget {
  WelcomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {

  // ── Animation controllers ─────────────────────────────────────────────────
  late AnimationController _entryCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _orbitCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _scanCtrl;

  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;
  late Animation<double> _orbitAnim;
  late Animation<double> _floatAnim;
  late Animation<double> _scanAnim;

  // Stagger delays for child elements
  late Animation<double> _fade1; // logo
  late Animation<double> _fade2; // tagline
  late Animation<double> _fade3; // features
  late Animation<double> _fade4; // buttons

  @override
  void initState() {
    super.initState();

    // Entry animation (1.4s)
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _fadeAnim  = CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _slideAnim = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)),
    );
    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack)),
    );

    // Staggered child fades
    _fade1 = CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.1, 0.55, curve: Curves.easeOut));
    _fade2 = CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.25, 0.65, curve: Curves.easeOut));
    _fade3 = CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.4, 0.75, curve: Curves.easeOut));
    _fade4 = CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.55, 0.9, curve: Curves.easeOut));

    // Continuous glow pulse
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.2, end: 0.75).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    // Orbit ring rotation
    _orbitCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 8000))
      ..repeat();
    _orbitAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _orbitCtrl, curve: Curves.linear),
    );

    // Float up-down
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    // Dashed inner ring
    _scanCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000))
      ..repeat();
    _scanAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanCtrl, curve: Curves.linear),
    );

    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _glowCtrl.dispose();
    _orbitCtrl.dispose();
    _floatCtrl.dispose();
    _scanCtrl.dispose();
    super.dispose();
  }

  // ╔════════════════════════════════════════════════════════════════════════╗
  // ║  BUILD                                                                ║
  // ╚════════════════════════════════════════════════════════════════════════╝
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _DS.bg,
        body: Stack(
          children: [
            // ── Static background grid ──────────────────────────────────
            Positioned.fill(
              child: CustomPaint(painter: _GridDotPainter()),
            ),

            // ── Ambient background glow blobs ───────────────────────────
            AnimatedBuilder(
              animation: _glowAnim,
              builder: (_, __) => Stack(
                children: [
                  // Top-left green blob
                  Positioned(
                    top: -80,
                    left: -80,
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _DS.neon.withOpacity(_glowAnim.value * 0.12),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Bottom-right cyan blob
                  Positioned(
                    bottom: -60,
                    right: -60,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _DS.accent1.withOpacity(_glowAnim.value * 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Main content ────────────────────────────────────────────
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Top badge
                    FadeTransition(
                      opacity: _fade1,
                      child: _buildTopBadge(),
                    ),

                    const Spacer(flex: 1),

                    // Central orb + logo
                    FadeTransition(
                      opacity: _fade1,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnim.value),
                        child: _buildCentralOrb(size),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // App name
                    FadeTransition(
                      opacity: _fade1,
                      child: _buildAppName(),
                    ),

                    const SizedBox(height: 14),

                    // Tagline
                    FadeTransition(
                      opacity: _fade2,
                      child: _buildTagline(),
                    ),

                    const Spacer(flex: 1),

                    // Feature row
                    FadeTransition(
                      opacity: _fade3,
                      child: _buildFeatureRow(),
                    ),

                    const SizedBox(height: 28),

                    // Buttons
                    FadeTransition(
                      opacity: _fade4,
                      child: _buildButtons(),
                    ),

                    const SizedBox(height: 24),

                    // Bottom hint
                    FadeTransition(
                      opacity: _fade4,
                      child: _buildBottomHint(),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top badge ─────────────────────────────────────────────────────────────
  Widget _buildTopBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Version chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _DS.neonFaint,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _DS.neon.withOpacity(0.25), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 6, height: 6,
                  decoration: const BoxDecoration(color: _DS.neon, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text("v2.0 — AI Edition",
                  style: TextStyle(color: _DS.neon, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
            ],
          ),
        ),

        // Logo pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _DS.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _DS.neon.withOpacity(0.2), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_enhance_rounded, color: _DS.neon, size: 14),
              const SizedBox(width: 6),
              Text("FoodSnap AI",
                  style: TextStyle(color: _DS.neon, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Central animated orb ──────────────────────────────────────────────────
  Widget _buildCentralOrb(Size size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnim, _orbitAnim, _floatAnim, _scanAnim]),
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _floatAnim.value),
        child: SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [

              // Outermost glow halo
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _DS.neon.withOpacity(_glowAnim.value * 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Orbit ring (rotating) with small planets
              Transform.rotate(
                angle: _orbitAnim.value * 2 * math.pi,
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Orbit circle
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _DS.neon.withOpacity(0.12),
                            width: 1,
                          ),
                        ),
                      ),
                      // Planet 1 — top
                      Positioned(
                        top: 0,
                        child: _orbitDot(_DS.neon, 8),
                      ),
                      // Planet 2 — right
                      Positioned(
                        right: 0,
                        top: 96,
                        child: _orbitDot(_DS.accent1, 6),
                      ),
                      // Planet 3 — bottom
                      Positioned(
                        bottom: 0,
                        child: _orbitDot(_DS.accent2, 5),
                      ),
                      // Planet 4 — left
                      Positioned(
                        left: 0,
                        top: 96,
                        child: _orbitDot(_DS.accent4, 6),
                      ),
                    ],
                  ),
                ),
              ),

              // Dashed inner ring (counter-rotate)
              Transform.rotate(
                angle: -_scanAnim.value * 2 * math.pi,
                child: CustomPaint(
                  size: const Size(148, 148),
                  painter: _DashedRingPainter(color: _DS.neon.withOpacity(0.22)),
                ),
              ),

              // Core glowing circle
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _DS.bgCard,
                  border: Border.all(
                    color: _DS.neon.withOpacity(0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _DS.neon.withOpacity(_glowAnim.value * 0.55),
                      blurRadius: 32,
                      spreadRadius: 4,
                    ),
                    BoxShadow(
                      color: _DS.neon.withOpacity(0.08),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),

              // Inner icon
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_enhance_rounded, color: _DS.neon, size: 40),
                  const SizedBox(height: 4),
                  Text(
                    "AI",
                    style: TextStyle(
                      color: _DS.neon,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orbitDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.6), blurRadius: 8, spreadRadius: 1),
        ],
      ),
    );
  }

  // ── App name ──────────────────────────────────────────────────────────────
  Widget _buildAppName() {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: "Food",
                style: TextStyle(
                  color: _DS.textPrimary,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                ),
              ),
              TextSpan(
                text: "Snap",
                style: TextStyle(
                  color: _DS.neon,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                ),
              ),
              TextSpan(
                text: " AI",
                style: TextStyle(
                  color: _DS.textPrimary,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Tagline ───────────────────────────────────────────────────────────────
  Widget _buildTagline() {
    return Column(
      children: [
        Text(
          "Your AI-powered nutrition companion",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _DS.textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        // Stat pills row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _statPill("📸", "Snap & Analyze", _DS.neon),
            const SizedBox(width: 8),
            _statPill("🤖", "AI Insights", _DS.accent1),
            const SizedBox(width: 8),
            _statPill("🔥", "Track Goals", _DS.accent3),
          ],
        ),
      ],
    );
  }

  Widget _statPill(String emoji, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.22), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Feature row ───────────────────────────────────────────────────────────
  Widget _buildFeatureRow() {
    final features = [
      {'icon': Icons.camera_enhance_rounded,    'label': 'Scan Meals',      'color': _DS.neon},
      {'icon': Icons.bar_chart_rounded,         'label': 'Track Macros',    'color': _DS.accent1},
      {'icon': Icons.restaurant_menu_rounded,   'label': 'Meal Plans',      'color': _DS.accent2},
      {'icon': Icons.shield_outlined,           'label': 'SafeBite',        'color': _DS.accent4},
      {'icon': Icons.chat_bubble_rounded,       'label': 'NutriBot',        'color': _DS.accent5},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: features.map((f) {
        final c = f['color'] as Color;
        return Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: c.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.withOpacity(0.25), width: 1),
              ),
              child: Center(
                child: Icon(f['icon'] as IconData, color: c, size: 22),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              f['label'] as String,
              style: TextStyle(
                color: c.withOpacity(0.8),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // ── Buttons ───────────────────────────────────────────────────────────────
  Widget _buildButtons() {
    return Column(
      children: [
        // Primary — Sign In
        AnimatedBuilder(
          animation: _glowAnim,
          builder: (_, __) => GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage()));
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
                    color: _DS.neon.withOpacity(_glowAnim.value * 0.55),
                    blurRadius: 28,
                    spreadRadius: -4,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.login_rounded, color: _DS.bg, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    "Sign In",
                    style: TextStyle(
                      color: _DS.bg,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary — Register
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpPage()));
          },
          child: Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _DS.neon.withOpacity(0.35), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add_rounded, color: _DS.neon, size: 20),
                const SizedBox(width: 10),
                Text(
                  "Create Account",
                  style: TextStyle(
                    color: _DS.neon,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Bottom hint ───────────────────────────────────────────────────────────
  Widget _buildBottomHint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline_rounded, color: _DS.textMuted, size: 12),
        const SizedBox(width: 6),
        Text(
          "Your data is private & encrypted",
          style: TextStyle(
            color: _DS.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────
class _GridDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FF88).withOpacity(0.035)
      ..style = PaintingStyle.fill;

    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_GridDotPainter old) => false;
}

class _DashedRingPainter extends CustomPainter {
  final Color color;
  _DashedRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    const dashCount = 16;
    const dashAngle = 2 * math.pi / dashCount;
    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          i * dashAngle,
          dashAngle * 0.6,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter old) => old.color != color;
}




// import 'package:flutter/material.dart';
// import 'package:eatwise_ai/login/src/loginPage.dart';
// import 'package:eatwise_ai/login/src/signup.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class WelcomePage extends StatefulWidget {
//   WelcomePage({Key? key, this.title}) : super(key: key);
//
//   final String? title;
//
//   @override
//   _WelcomePageState createState() => _WelcomePageState();
// }
//
// class _WelcomePageState extends State<WelcomePage> {
//   Widget _submitButton() {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//             context, MaterialPageRoute(builder: (context) => LoginPage()));
//       },
//       child: Container(
//         width: MediaQuery.of(context).size.width,
//         padding: EdgeInsets.symmetric(vertical: 13),
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.all(Radius.circular(5)),
//             boxShadow: <BoxShadow>[
//               BoxShadow(
//                   color: Color(0xff33cbdf).withAlpha(100),
//                   offset: Offset(2, 4),
//                   blurRadius: 8,
//                   spreadRadius: 2)
//             ],
//             color: Colors.white),
//         child: Text(
//           'Login',
//           style: TextStyle(fontSize: 20, color: Color(0xfff7892b)),
//         ),
//       ),
//     );
//   }
//
//   Widget _signUpButton() {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//             context, MaterialPageRoute(builder: (context) => SignUpPage()));
//       },
//       child: Container(
//         width: MediaQuery.of(context).size.width,
//         padding: EdgeInsets.symmetric(vertical: 13),
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.all(Radius.circular(5)),
//           border: Border.all(color: Colors.white, width: 2),
//         ),
//         child: Text(
//           'Register now',
//           style: TextStyle(fontSize: 20, color: Colors.white),
//         ),
//       ),
//     );
//   }
//
//   Widget _label() {
//     return Container(
//         margin: EdgeInsets.only(top: 40, bottom: 20),
//         child: Column(
//           children: <Widget>[
//             Text(
//               'Quick login with Touch ID',
//               style: TextStyle(color: Colors.white, fontSize: 17),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             Icon(Icons.fingerprint, size: 90, color: Colors.white),
//             SizedBox(
//               height: 20,
//             ),
//             Text(
//               'Touch ID',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 15,
//                 decoration: TextDecoration.underline,
//               ),
//             ),
//           ],
//         ));
//   }
//
//   Widget _title() {
//     return RichText(
//       textAlign: TextAlign.center,
//       text: TextSpan(
//           text: 'Food',
//           style: GoogleFonts.portLligatSans(
//             textStyle: Theme.of(context).textTheme.displayLarge,
//             fontSize: 30,
//             fontWeight: FontWeight.w700,
//             color: Colors.white,
//           ),
//           children: [
//             TextSpan(
//               text: 'Snap',
//               style: TextStyle(color: Colors.black, fontSize: 30),
//             ),
//             TextSpan(
//               text: '  AI',
//               style: TextStyle(color: Colors.white, fontSize: 30),
//             ),
//           ]),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body:SingleChildScrollView(
//         child:Container(
//             padding: EdgeInsets.symmetric(horizontal: 20),
//             height: MediaQuery.of(context).size.height,
//             decoration: BoxDecoration(
//                 borderRadius: BorderRadius.all(Radius.circular(5)),
//                 boxShadow: <BoxShadow>[
//                   BoxShadow(
//                       color: Colors.grey.shade200,
//                       offset: Offset(2, 4),
//                       blurRadius: 5,
//                       spreadRadius: 2)
//                 ],
//                 gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [Color(0xff72d5ca), Color(0xe8e9ffec)])),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 _title(),
//                 SizedBox(
//                   height: 80,
//                 ),
//                 _submitButton(),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 _signUpButton(),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 _label()
//               ],
//             ),
//           ),
//       ),
//     );
//   }
// }
