import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eatwise_ai/login/src/signup.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eatwise_ai/home.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eatwise_ai/healthProfile.dart'; // Add this import
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:eatwise_ai/forgetPassword.dart';

import 'Widget/bezierContainer.dart';

// ── Design Tokens (matches UserHome & SignUpPage) ─────────────────────────────
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

class LoginPage extends StatefulWidget {
  LoginPage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {

  // ── Controllers (unchanged) ───────────────────────────────────────────────
  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  // ── UI state ──────────────────────────────────────────────────────────────
  bool _obscurePassword = true;
  bool _isLoading       = false;

  // ── Validation errors ─────────────────────────────────────────────────────
  String? _emailError;
  String? _passwordError;

  // ── Animations ────────────────────────────────────────────────────────────
  late AnimationController _fadeCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _scanCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _slideAnim;
  late Animation<double>   _glowAnim;
  late Animation<double>   _scanAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnim  = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic),
    );

    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.2, end: 0.7).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    _scanCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat();
    _scanAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanCtrl, curve: Curves.linear),
    );

    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _glowCtrl.dispose();
    _scanCtrl.dispose();
    usernamecontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────
  bool _validate() {
    bool valid = true;
    setState(() {
      _emailError    = null;
      _passwordError = null;
    });

    if (usernamecontroller.text.trim().isEmpty) {
      setState(() => _emailError = 'Email is required');
      valid = false;
    } else if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(usernamecontroller.text.trim())) {
      setState(() => _emailError = 'Enter a valid email address');
      valid = false;
    }

    if (passwordcontroller.text.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      valid = false;
    }

    return valid;
  }

  // ── Send data (UNCHANGED backend logic) ───────────────────────────────────
  // void _send_data() async {
  //   if (!_validate()) return;
  //
  //   setState(() => _isLoading = true);
  //
  //   String uname    = usernamecontroller.text;
  //   String password = passwordcontroller.text;
  //
  //   SharedPreferences sh = await SharedPreferences.getInstance();
  //   String url = sh.getString('url').toString();
  //
  //   final urls = Uri.parse('$url/app_login/');
  //   try {
  //     final response = await http.post(urls, body: {
  //       'Username': uname,
  //       'Password': password,
  //     });
  //     if (response.statusCode == 200) {
  //       String status = jsonDecode(response.body)['status'];
  //       if (status == 'ok') {
  //         String lid = jsonDecode(response.body)['lid'];
  //         sh.setString("lid", lid);
  //         String h = jsonDecode(response.body)['h'];
  //         sh.setString("h", h);
  //
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => UserHome()),
  //         );
  //       } else {
  //         Fluttertoast.showToast(
  //           msg: 'Invalid email or password',
  //           backgroundColor: _DS.accent3,
  //           textColor: Colors.white,
  //         );
  //       }
  //     } else {
  //       Fluttertoast.showToast(
  //         msg: 'Network Error',
  //         backgroundColor: _DS.accent3,
  //         textColor: Colors.white,
  //       );
  //     }
  //   } catch (e) {
  //     Fluttertoast.showToast(
  //       msg: e.toString(),
  //       backgroundColor: _DS.accent3,
  //       textColor: Colors.white,
  //     );
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }


  // ── Send data with health profile check ───────────────────────────────────
  void _send_data() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    String uname    = usernamecontroller.text;
    String password = passwordcontroller.text;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();

    final urls = Uri.parse('$url/app_login/');
    try {
      final response = await http.post(urls, body: {
        'Username': uname,
        'Password': password,
      });
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String status = responseData['status'];

        if (status == 'ok') {
          String lid = responseData['lid'];
          String h = responseData['h']; // Get h value from response

          sh.setString("lid", lid);
          sh.setString("h", h);

          // Check if health profile exists
          if (h == "no") {
            // Show dialog asking to create health profile
            _showHealthProfileDialog(context);
          } else {
            // Go directly to home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserHome()),
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: 'Invalid email or password',
            backgroundColor: _DS.accent3,
            textColor: Colors.white,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Network Error',
          backgroundColor: _DS.accent3,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: _DS.accent3,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

// ── Health Profile Dialog ───────────────────────────────────────────────────
  void _showHealthProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap a button to close
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _DS.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: _DS.neon.withOpacity(0.2), width: 1),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _DS.neon.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: _DS.neon.withOpacity(0.3), width: 1),
                ),
                child: const Icon(
                  Icons.health_and_safety_rounded,
                  color: _DS.neon,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Welcome to FoodSnap AI!",
                style: TextStyle(
                  color: _DS.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _DS.neonFaint.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _DS.neon.withOpacity(0.15), width: 1),
                ),
                child: const Column(
                  children: [
                    Text(
                      "✨ First Time Setup ✨",
                      style: TextStyle(
                        color: _DS.neon,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "To give you personalized nutrition insights, meal suggestions, and accurate tracking, we need to know a bit about you first.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _DS.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, color: _DS.neon, size: 16),
                        SizedBox(width: 6),
                        Text(
                          "Personalized calorie goals",
                          style: TextStyle(color: _DS.textPrimary, fontSize: 13),
                        ),
                      ],
                    ),

                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, color: _DS.neon, size: 16),
                        SizedBox(width: 6),
                        Text(
                          "Accurate nutrition tracking",
                          style: TextStyle(color: _DS.textPrimary, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Skip for now - go to home anyway
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => UserHome()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: _DS.textMuted.withOpacity(0.3), width: 1),
                      ),
                    ),
                    child: Text(
                      "SKIP FOR NOW",
                      style: TextStyle(
                        color: _DS.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Navigate to health profile page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddHealthProfilePage()),
                      ).then((_) {
                        // After returning from health profile, go to home
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => UserHome()),
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _DS.neon,
                      foregroundColor: _DS.bg,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "SET UP PROFILE",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
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
        body: AnimatedBuilder(
          animation: _fadeCtrl,
          builder: (_, child) => Opacity(
            opacity: _fadeAnim.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnim.value),
              child: child,
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // ── Top hero section ──────────────────────────────────
                _buildHeroSection(size),

                // ── Form ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      _buildWelcomeText(),
                      const SizedBox(height: 28),
                      _buildEmailField(),
                      _buildPasswordField(),
                      const SizedBox(height: 10),
                      _buildForgotPassword(),
                      const SizedBox(height: 28),
                      _buildLoginButton(),
                      const SizedBox(height: 28),
                      _buildDivider(),
                      const SizedBox(height: 20),
                      _buildFeatureChips(),
                      const SizedBox(height: 32),
                      _buildSignUpLink(),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Hero section ───────────────────────────────────────────────────────────
  Widget _buildHeroSection(Size size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnim, _scanAnim]),
      builder: (_, __) => Container(
        width: double.infinity,
        height: size.height * 0.38,
        decoration: BoxDecoration(
          color: _DS.bgCard,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(44),
            bottomRight: Radius.circular(44),
          ),
          border: Border.all(color: _DS.neon.withOpacity(0.12), width: 1),
          boxShadow: [
            BoxShadow(
              color: _DS.neon.withOpacity(_glowAnim.value * 0.18),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Subtle grid dot background
            Positioned.fill(child: CustomPaint(painter: _GridDotPainter())),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated AI orb
                  SizedBox(
                    width: 112,
                    height: 112,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Rotating dashed ring
                        Transform.rotate(
                          angle: _scanAnim.value * 2 * 3.14159,
                          child: CustomPaint(
                            size: const Size(112, 112),
                            painter: _DashedRingPainter(color: _DS.neon.withOpacity(0.2)),
                          ),
                        ),
                        // Glowing inner circle
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _DS.neonFaint,
                            border: Border.all(
                              color: _DS.neon.withOpacity(0.45),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _DS.neon.withOpacity(_glowAnim.value * 0.45),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.camera_enhance_rounded,
                              color: _DS.neon,
                              size: 34,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // App name
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "FoodSnap",
                          style: TextStyle(
                            color: _DS.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                          ),
                        ),
                        TextSpan(
                          text: " AI",
                          style: TextStyle(
                            color: _DS.neon,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tagline pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _DS.neon.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _DS.neon.withOpacity(0.2), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, color: _DS.neon, size: 13),
                        const SizedBox(width: 6),
                        Text(
                          "AI-Powered Nutrition Intelligence",
                          style: TextStyle(
                            color: _DS.neon,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Welcome text ──────────────────────────────────────────────────────────
  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome back",
          style: TextStyle(
            color: _DS.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Sign in to continue",
          style: TextStyle(
            color: _DS.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }

  // ── Email field ───────────────────────────────────────────────────────────
  Widget _buildEmailField() {
    final hasError = _emailError != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: _DS.bgCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: hasError ? _DS.accent3.withOpacity(0.7) : _DS.borderFaint,
              width: 1.2,
            ),
          ),
          child: TextField(
            controller: usernamecontroller,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              color: _DS.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: _DS.neon,
            onChanged: (_) => setState(() => _emailError = null),
            decoration: InputDecoration(
              hintText: "Email address",
              hintStyle: TextStyle(color: _DS.textMuted, fontSize: 14),
              prefixIcon: Icon(
                Icons.email_rounded,
                color: hasError ? _DS.accent3 : _DS.textMuted,
                size: 20,
              ),
              suffixIcon: hasError
                  ? const Icon(Icons.error_outline_rounded, color: _DS.accent3, size: 18)
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 6, bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: _DS.accent3, size: 12),
                const SizedBox(width: 4),
                Text(
                  _emailError!,
                  style: const TextStyle(
                    color: _DS.accent3,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 14),
      ],
    );
  }

  // ── Password field ────────────────────────────────────────────────────────
  Widget _buildPasswordField() {
    final hasError = _passwordError != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: _DS.bgCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: hasError ? _DS.accent3.withOpacity(0.7) : _DS.borderFaint,
              width: 1.2,
            ),
          ),
          child: TextField(
            controller: passwordcontroller,
            obscureText: _obscurePassword,
            style: const TextStyle(
              color: _DS.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: _DS.neon,
            onChanged: (_) => setState(() => _passwordError = null),
            onSubmitted: (_) => _send_data(),
            decoration: InputDecoration(
              hintText: "Password",
              hintStyle: TextStyle(color: _DS.textMuted, fontSize: 14),
              prefixIcon: Icon(
                Icons.lock_rounded,
                color: hasError ? _DS.accent3 : _DS.textMuted,
                size: 20,
              ),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: _DS.textMuted,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 6, bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: _DS.accent3, size: 12),
                const SizedBox(width: 4),
                Text(
                  _passwordError!,
                  style: const TextStyle(
                    color: _DS.accent3,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 2),
      ],
    );
  }

  // ── Forgot password ───────────────────────────────────────────────────────
  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => changePassword(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _DS.accent4.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _DS.accent4.withOpacity(0.2), width: 1),
          ),
          child: Text(
            "Forgot Password?",
            style: TextStyle(
              color: _DS.accent4,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // ── Login button ──────────────────────────────────────────────────────────
  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading
          ? null
          : () {
        HapticFeedback.mediumImpact();
        _send_data();
      },
      child: AnimatedBuilder(
        animation: _glowAnim,
        builder: (_, __) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: _isLoading
                ? const LinearGradient(colors: [_DS.neonFaint, _DS.neonFaint])
                : const LinearGradient(
              colors: [_DS.neon, _DS.neonDim],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isLoading
                ? []
                : [
              BoxShadow(
                color: _DS.neon.withOpacity(_glowAnim.value * 0.5),
                blurRadius: 28,
                spreadRadius: -4,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: _DS.neon,
                strokeWidth: 2.5,
              ),
            )
                : Row(
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
    );
  }

  // ── Divider ───────────────────────────────────────────────────────────────
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: _DS.borderFaint)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            "What you get",
            style: TextStyle(
              color: _DS.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: _DS.borderFaint)),
      ],
    );
  }

  // ── Feature highlight chips ───────────────────────────────────────────────
  Widget _buildFeatureChips() {
    final features = [
      {'icon': Icons.camera_enhance_rounded,  'label': 'AI Food Scan',     'color': _DS.neon},
      {'icon': Icons.bar_chart_rounded,       'label': 'Nutrition Track',  'color': _DS.accent1},
      {'icon': Icons.restaurant_menu_rounded, 'label': 'Meal Suggestions', 'color': _DS.accent2},
      {'icon': Icons.chat_bubble_rounded,     'label': 'NutriBot',         'color': _DS.accent5},
      {'icon': Icons.shield_outlined,         'label': 'SafeBite',         'color': _DS.accent4},
      {'icon': Icons.local_fire_department,   'label': 'Streak Tracker',   'color': _DS.accent3},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: features.map((f) {
        final c = f['color'] as Color;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: c.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.withOpacity(0.2), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(f['icon'] as IconData, color: c, size: 13),
              const SizedBox(width: 5),
              Text(
                f['label'] as String,
                style: TextStyle(
                  color: c,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Sign up link ──────────────────────────────────────────────────────────
  Widget _buildSignUpLink() {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => SignUpPage())),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account?  ",
              style: TextStyle(
                color: _DS.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "Create one",
              style: TextStyle(
                color: _DS.neon,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_rounded, color: _DS.neon, size: 14),
          ],
        ),
      ),
    );
  }
}

// ── Grid dot background ───────────────────────────────────────────────────────
class _GridDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FF88).withOpacity(0.04)
      ..style = PaintingStyle.fill;

    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_GridDotPainter old) => false;
}

// ── Dashed ring (matches home scan ring) ─────────────────────────────────────
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

    const dashCount = 14;
    const dashAngle = 2 * 3.14159 / dashCount;
    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          i * dashAngle,
          dashAngle * 0.65,
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
// import 'package:eatwise_ai/login/src/signup.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:eatwise_ai/home.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'package:http/http.dart' as http;
// import 'dart:io';
// import 'dart:convert';
//
// import 'Widget/bezierContainer.dart';
//
// class LoginPage extends StatefulWidget {
//   LoginPage({Key? key, this.title}) : super(key: key);
//
//   final String? title;
//
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   TextEditingController usernamecontroller = new TextEditingController();
//   TextEditingController passwordcontroller = new TextEditingController();
//
//   void _send_data() async {
//     String uname = usernamecontroller.text;
//     String password = passwordcontroller.text;
//
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String url = sh.getString('url').toString();
//
//     final urls = Uri.parse('$url/app_login/');
//     try {
//       final response = await http.post(urls, body: {
//         'Username': uname,
//         'Password': password,
//       });
//       if (response.statusCode == 200) {
//         String status = jsonDecode(response.body)['status'];
//         if (status == 'ok') {
//           String lid = jsonDecode(response.body)['lid'];
//           sh.setString("lid", lid);
//           String h = jsonDecode(response.body)['h'];
//           sh.setString("h", h);
//
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => UserHome()),
//           );
//         } else {
//           Fluttertoast.showToast(msg: 'Not Found');
//         }
//       } else {
//         Fluttertoast.showToast(msg: 'Network Error');
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: e.toString());
//     }
//   }
//
//   Widget _backButton() {
//     return InkWell(
//       onTap: () {
//         Navigator.pop(context);
//       },
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 10),
//         child: Row(
//           children: <Widget>[
//             Container(
//               padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
//               child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
//             ),
//             Text('Back',
//                 style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _entryField(String title, {bool isPassword = false}) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Text(
//             title,
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           TextField(
//               controller: passwordcontroller,
//               obscureText: isPassword,
//               decoration: InputDecoration(
//                   border: InputBorder.none,
//                   fillColor: Color(0xfff3f3f4),
//                   filled: true))
//         ],
//       ),
//     );
//   }
//
//   Widget _submitButton() {
//     return Container(
//         width: MediaQuery.of(context).size.width,
//         padding: EdgeInsets.symmetric(vertical: 15),
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.all(Radius.circular(5)),
//             boxShadow: <BoxShadow>[
//               BoxShadow(
//                   color: Colors.grey.shade200,
//                   offset: Offset(2, 4),
//                   blurRadius: 5,
//                   spreadRadius: 2)
//             ],
//             gradient: LinearGradient(
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//                 colors: [Color(0xfffbb448), Color(0xfff7892b)])),
//         child: TextButton(
//             onPressed: () {
//               _send_data();
//             },
//             child: Text(
//               'Login',
//               style: TextStyle(fontSize: 20, color: Colors.white),
//             ))
//         // child: Text('Login', style: TextStyle(fontSize: 20, color: Colors.white),),
//         );
//   }
//
//   Widget _divider() {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 10),
//       child: Row(
//         children: <Widget>[
//           SizedBox(
//             width: 20,
//           ),
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 10),
//               child: Divider(
//                 thickness: 1,
//               ),
//             ),
//           ),
//           Text('or'),
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 10),
//               child: Divider(
//                 thickness: 1,
//               ),
//             ),
//           ),
//           SizedBox(
//             width: 20,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _facebookButton() {
//     return Container(
//       height: 50,
//       margin: EdgeInsets.symmetric(vertical: 20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.all(Radius.circular(10)),
//       ),
//       child: Row(
//         children: <Widget>[
//           Expanded(
//             flex: 1,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Color(0xff1959a9),
//                 borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(5),
//                     topLeft: Radius.circular(5)),
//               ),
//               alignment: Alignment.center,
//               child: Text('f',
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 25,
//                       fontWeight: FontWeight.w400)),
//             ),
//           ),
//           Expanded(
//             flex: 5,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Color(0xff2872ba),
//                 borderRadius: BorderRadius.only(
//                     bottomRight: Radius.circular(5),
//                     topRight: Radius.circular(5)),
//               ),
//               alignment: Alignment.center,
//               child: Text('Log in with Facebook',
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w400)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _createAccountLabel() {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//             context, MaterialPageRoute(builder: (context) => SignUpPage()));
//       },
//       child: Container(
//         margin: EdgeInsets.symmetric(vertical: 20),
//         padding: EdgeInsets.all(15),
//         alignment: Alignment.bottomCenter,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Don\'t have an account ?',
//               style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
//             ),
//             SizedBox(
//               width: 10,
//             ),
//             Text(
//               'Register',
//               style: TextStyle(
//                   color: Color(0xfff79c4f),
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _title() {
//     return RichText(
//       textAlign: TextAlign.center,
//       text: TextSpan(
//           text: 'F',
//           style: TextStyle(
//               fontSize: 30,
//               fontWeight: FontWeight.w700,
//               color: Color(0xffe46b10)),
//           children: [
//             TextSpan(
//               text: 'oodSnap',
//               style: TextStyle(color: Colors.black, fontSize: 30),
//             ),
//             TextSpan(
//               text: ' Ai',
//               style: TextStyle(color: Color(0xffe46b10), fontSize: 30),
//             ),
//           ]),
//     );
//   }
//
//   Widget _emailPasswordWidget() {
//     return Column(
//       children: <Widget>[
//         Container(
//           margin: EdgeInsets.symmetric(vertical: 10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Text(
//                 "Email",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               TextField(
//                   controller: usernamecontroller,
//                   decoration: InputDecoration(
//                       border: InputBorder.none,
//                       fillColor: Color(0xfff3f3f4),
//                       filled: true))
//             ],
//           ),
//         ),
//         _entryField("Password", isPassword: true),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     return Scaffold(
//         body: Container(
//       height: height,
//       child: Stack(
//         children: <Widget>[
//           Positioned(
//               top: -height * .15,
//               right: -MediaQuery.of(context).size.width * .4,
//               child: BezierContainer()),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 20),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   SizedBox(height: height * .2),
//                   _title(),
//                   SizedBox(height: 50),
//                   _emailPasswordWidget(),
//                   SizedBox(height: 20),
//                   _submitButton(),
//                   Container(
//                     padding: EdgeInsets.symmetric(vertical: 10),
//                     alignment: Alignment.centerRight,
//                     child: Text('Forgot Password ?',
//                         style: TextStyle(
//                             fontSize: 14, fontWeight: FontWeight.w500)),
//                   ),
//                   _divider(),
//                   _facebookButton(),
//                   SizedBox(height: height * .055),
//                   _createAccountLabel(),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(top: 40, left: 0, child: _backButton()),
//         ],
//       ),
//     ));
//   }
// }
