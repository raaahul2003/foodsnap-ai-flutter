import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  DESIGN TOKENS  (identical to SnapFood theme)                            ║
// ╚══════════════════════════════════════════════════════════════════════════╝
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

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  APP ENTRY (unchanged)                                                   ║
// ╚══════════════════════════════════════════════════════════════════════════╝
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Nutrition Scanner',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const FoodUploadScreen(title: "Food Scanner"),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  FOOD UPLOAD SCREEN                                                      ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class FoodUploadScreen extends StatefulWidget {
  final String title;
  const FoodUploadScreen({super.key, required this.title});

  @override
  State<FoodUploadScreen> createState() => _FoodUploadScreenState();
}

class _FoodUploadScreenState extends State<FoodUploadScreen>
    with TickerProviderStateMixin {

  // ── State (original – untouched) ─────────────────────────────────────────
  final _formKey  = GlobalKey<FormState>();
  bool  _isLoading  = false;
  bool  _isScanning = false;
  File? _selectedImage;
  Map<String, dynamic>? _scanResult;
  List<dynamic> _nutrients = [];

  // ── Animation controllers ─────────────────────────────────────────────────
  late AnimationController _glowCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _orbitCtrl;
  late AnimationController _scanCtrl;
  late Animation<double>   _glowAnim;
  late Animation<double>   _pulseAnim;
  late Animation<double>   _orbitAnim;
  late Animation<double>   _scanLineAnim;

  @override
  void initState() {
    super.initState();

    _glowCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 2200))..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.25, end: 0.85).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _pulseCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.93, end: 1.07).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _orbitCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 3000))..repeat();
    _orbitAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _orbitCtrl, curve: Curves.linear));

    _scanCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1600))..repeat();
    _scanLineAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _scanCtrl, curve: Curves.linear));
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _pulseCtrl.dispose();
    _orbitCtrl.dispose();
    _scanCtrl.dispose();
    super.dispose();
  }

  // ╔════════════════════════════════════════════════════════════════════════╗
  // ║  BACKEND FUNCTIONS — 100 % ORIGINAL, ZERO CHANGES                     ║
  // ╚════════════════════════════════════════════════════════════════════════╝

  Future<void> pickImageFromGallery() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _scanResult = null;
        _nutrients  = [];
      });
    }
  }

  Future<void> captureImageFromCamera() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _scanResult = null;
        _nutrients  = [];
      });
    }
  }



  Future<void> scanFoodImage() async {
    if (_selectedImage == null) {
      Fluttertoast.showToast(
        msg: "Please select an image first",
        backgroundColor: Colors.orange,
      );
      return;
    }

    setState(() {
      _isScanning = true;
      _scanResult = null;
      _nutrients  = [];
    });

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString("url").toString();
      String lid = sh.getString("lid").toString();

      if (url.isEmpty) throw Exception("Server URL not configured");

      var request = http.MultipartRequest(
          "POST", Uri.parse("$url/food_prediction/"));

      request.fields['uid']=lid;

      request.files.add(await http.MultipartFile.fromPath(
          'photo', _selectedImage!.path));

      var response  = await request.send();
      var resBody   = await response.stream.bytesToString();
      var data      = jsonDecode(resBody);

      if (response.statusCode == 200) {
        if (data['status'] == "ok") {
          setState(() {
            _scanResult = data;
            _nutrients  = data['nutrients'] ?? [];
          });
          Fluttertoast.showToast(
              msg: "Food identified successfully!",
              backgroundColor: Colors.green);
        } else {
          Fluttertoast.showToast(
              msg: "Could not identify food. Please try with a clearer image.",
              backgroundColor: Colors.orange);
        }
      } else {
        Fluttertoast.showToast(
            msg: "Server error: ${response.statusCode}",
            backgroundColor: Colors.red);
      }
    } catch (e) {
      print("Error scanning food: $e");
      Fluttertoast.showToast(
          msg: "Network error: ${e.toString()}",
          backgroundColor: Colors.red);
    } finally {
      setState(() => _isScanning = false);
    }
  }

  // ╔════════════════════════════════════════════════════════════════════════╗
  // ║  BUILD                                                                 ║
  // ╚════════════════════════════════════════════════════════════════════════╝
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeroBadge(),
                      const SizedBox(height: 28),
                      _buildImageArea(),
                      const SizedBox(height: 20),
                      _buildPickerButtons(),
                      const SizedBox(height: 24),
                      _buildScanButton(),
                      if (_isScanning) ...[
                        const SizedBox(height: 24),
                        _buildScanningIndicator(),
                      ],
                      if (_scanResult != null && !_isScanning) ...[
                        const SizedBox(height: 24),
                        _buildFoodNameCard(),
                        const SizedBox(height: 20),
                        _buildNutritionHeader(),
                        const SizedBox(height: 14),
                        ..._buildNutrientList(),
                      ],
                      if (_selectedImage == null &&
                          _scanResult == null &&
                          !_isScanning) ...[
                        const SizedBox(height: 48),
                        _buildEmptyState(),
                      ],
                      const SizedBox(height: 40),
                    ],
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: _DS.bg,
        border: Border(
            bottom: BorderSide(color: _DS.borderFaint, width: 1)),
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
                Text(widget.title,
                    style: const TextStyle(
                        color: _DS.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3)),
                const Text("AI-powered nutrition scanner",
                    style: TextStyle(
                        color: _DS.textMuted, fontSize: 11)),
              ],
            ),
          ),
          // AI badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _DS.neonFaint,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: _DS.neon.withOpacity(0.35), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.auto_awesome_rounded,
                    color: _DS.neon, size: 12),
                SizedBox(width: 5),
                Text("AI Vision",
                    style: TextStyle(
                        color: _DS.neon,
                        fontSize: 10,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero badge row ────────────────────────────────────────────────────────
  Widget _buildHeroBadge() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: _DS.neonFaint,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: _DS.neon.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.bolt_rounded, color: _DS.neon, size: 13),
              SizedBox(width: 6),
              Text("Instant Food Analysis",
                  style: TextStyle(
                      color: _DS.neon,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text("What did you eat?",
            style: TextStyle(
                color: _DS.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6)),
        const SizedBox(height: 4),
        const Text(
            "Snap or upload a photo for instant nutrition breakdown",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _DS.textMuted, fontSize: 12, height: 1.5)),
      ],
    );
  }

  // ── Image area ────────────────────────────────────────────────────────────
  Widget _buildImageArea() {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => GestureDetector(
        onTap: _showSourcePicker,
        child: Container(
          height: 260,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _DS.bgCard,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _selectedImage != null
                  ? _DS.neon.withOpacity(0.45)
                  : _DS.borderFaint,
              width: 1.5,
            ),
            boxShadow: _selectedImage != null
                ? [
              BoxShadow(
                  color: _DS.neon
                      .withOpacity(_glowAnim.value * 0.18),
                  blurRadius: 32,
                  offset: const Offset(0, 6))
            ]
                : [],
          ),
          child: _selectedImage != null
              ? _buildPreviewThumb()
              : _buildEmptyImagePlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPreviewThumb() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Image.file(_selectedImage!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity),
        ),
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _DS.bg.withOpacity(0.88),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _DS.borderFaint, width: 1),
              ),
              child: const Text("Tap to change photo",
                  style: TextStyle(
                      color: _DS.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyImagePlaceholder() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: _pulseAnim.value,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _DS.neonFaint,
                  border: Border.all(
                      color: _DS.neon.withOpacity(0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                        color: _DS.neon.withOpacity(0.18),
                        blurRadius: 22,
                        spreadRadius: 2)
                  ],
                ),
                child: const Icon(Icons.add_photo_alternate_rounded,
                    color: _DS.neon, size: 38),
              ),
            ),
            const SizedBox(height: 14),
            const Text("Tap to upload food photo",
                style: TextStyle(
                    color: _DS.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text("Camera or gallery",
                style: TextStyle(
                    color: _DS.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // ── Picker buttons ─────────────────────────────────────────────────────────
  Widget _buildPickerButtons() {
    return Row(
      children: [
        Expanded(
            child: _actionBtn(
                icon: Icons.camera_alt_rounded,
                label: "Camera",
                color: _DS.neon,
                onTap: () {
                  HapticFeedback.lightImpact();
                  captureImageFromCamera();
                })),
        const SizedBox(width: 12),
        Expanded(
            child: _actionBtn(
                icon: Icons.photo_library_rounded,
                label: "Gallery",
                color: _DS.accent1,
                onTap: () {
                  HapticFeedback.lightImpact();
                  pickImageFromGallery();
                })),
      ],
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: color.withOpacity(0.3), width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  // ── Scan / Analyze button (AI glow style) ─────────────────────────────────
  Widget _buildScanButton() {
    final hasImage = _selectedImage != null;

    return AnimatedBuilder(
      animation: Listenable.merge(
          [_glowAnim, _orbitAnim, _scanLineAnim]),
      builder: (_, __) {
        return GestureDetector(
          onTap: (hasImage && !_isScanning)
              ? () {
            HapticFeedback.mediumImpact();
            scanFoodImage();
          }
              : null,
          child: AnimatedOpacity(
            opacity: hasImage ? 1.0 : 0.45,
            duration: const Duration(milliseconds: 300),
            child: SizedBox(
              width: double.infinity,
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow halo
                  if (hasImage && !_isScanning)
                    Container(
                      width: double.infinity,
                      height: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                              color: _DS.neon.withOpacity(
                                  _glowAnim.value * 0.55),
                              blurRadius: 40,
                              spreadRadius: -2),
                          BoxShadow(
                              color: _DS.neon.withOpacity(
                                  _glowAnim.value * 0.25),
                              blurRadius: 80,
                              spreadRadius: 4),
                        ],
                      ),
                    ),

                  // Orbit ring
                  if (hasImage && !_isScanning)
                    Transform.rotate(
                      angle: _orbitAnim.value * 2 * math.pi,
                      child: Container(
                        width: double.infinity,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: _DS.neon.withOpacity(0.15),
                              width: 1),
                        ),
                      ),
                    ),

                  // Main body
                  Container(
                    width: double.infinity,
                    height: 68,
                    decoration: BoxDecoration(
                      gradient: hasImage && !_isScanning
                          ? LinearGradient(colors: [
                        Color.lerp(_DS.neon, _DS.accent1,
                            _glowAnim.value * 0.3)!,
                        _DS.neonDim,
                      ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight)
                          : const LinearGradient(colors: [
                        _DS.neonFaint,
                        _DS.neonFaint,
                      ]),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: hasImage
                            ? _DS.neon.withOpacity(0.6)
                            : _DS.borderFaint,
                        width: 1.2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Scan sweep
                          if (hasImage && !_isScanning)
                            Positioned.fill(
                              child: Transform.translate(
                                offset: Offset(
                                  (_scanLineAnim.value * 2 - 1) *
                                      MediaQuery.of(context)
                                          .size
                                          .width,
                                  0,
                                ),
                                child: Container(
                                  width: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        _DS.neon.withOpacity(0.18),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Label
                          _isScanning
                              ? Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: _DS.neon.withOpacity(0.8),
                                  strokeWidth: 2.5,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text("Analyzing...",
                                  style: TextStyle(
                                      color: _DS.neon,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.3)),
                            ],
                          )
                              : Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Transform.scale(
                                scale: hasImage
                                    ? 0.92 +
                                    _glowAnim.value * 0.16
                                    : 1.0,
                                child: Icon(
                                  Icons.search_rounded,
                                  color: hasImage
                                      ? _DS.bg
                                      : _DS.textMuted,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text("Scan Food",
                                  style: TextStyle(
                                      color: hasImage
                                          ? _DS.bg
                                          : _DS.textMuted,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.3)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Scanning indicator ────────────────────────────────────────────────────
  Widget _buildScanningIndicator() {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _DS.bgCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: _DS.neon.withOpacity(0.25), width: 1.2),
          boxShadow: [
            BoxShadow(
                color: _DS.neon.withOpacity(_glowAnim.value * 0.12),
                blurRadius: 24,
                offset: const Offset(0, 6))
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                  color: _DS.neon, strokeWidth: 2.5),
            ),
            const SizedBox(height: 14),
            const Text("Analyzing food image...",
                style: TextStyle(
                    color: _DS.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text("This may take a few seconds",
                style: TextStyle(
                    color: _DS.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // ── Food name result card ─────────────────────────────────────────────────
  Widget _buildFoodNameCard() {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _DS.bgCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: _DS.neon.withOpacity(0.35), width: 1.2),
          boxShadow: [
            BoxShadow(
                color:
                _DS.neon.withOpacity(_glowAnim.value * 0.18),
                blurRadius: 28,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _DS.neonFaint,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: _DS.neon.withOpacity(0.3), width: 1),
              ),
              child: const Icon(Icons.restaurant_rounded,
                  color: _DS.neon, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Identified Food",
                      style: TextStyle(
                          color: _DS.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(
                    _scanResult!['foodname']?.toString() ??
                        "Unknown Food",
                    style: const TextStyle(
                        color: _DS.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _DS.neonFaint,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _DS.neon.withOpacity(0.3), width: 1),
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: _DS.neon, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  // ── Nutrition facts header ────────────────────────────────────────────────
  Widget _buildNutritionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: _DS.accent1.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: _DS.accent1.withOpacity(0.25), width: 1),
          ),
          child: const Icon(Icons.list_alt_rounded,
              size: 15, color: _DS.accent1),
        ),
        const SizedBox(width: 10),
        const Text("Nutrition Facts",
            style: TextStyle(
                color: _DS.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2)),
        const Spacer(),
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _DS.accent1.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: _DS.accent1.withOpacity(0.25), width: 1),
          ),
          child: const Text("100g Serving",
              style: TextStyle(
                  color: _DS.accent1,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  // ── Nutrient list ─────────────────────────────────────────────────────────
  List<Widget> _buildNutrientList() {
    if (_nutrients.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: _DS.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _DS.borderFaint, width: 1),
          ),
          child: Column(
            children: const [
              Icon(Icons.info_outline_rounded,
                  color: _DS.textMuted, size: 40),
              SizedBox(height: 10),
              Text("No nutrient data available",
                  style: TextStyle(
                      color: _DS.textMuted,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        )
      ];
    }

    // Accent color rotation
    final colors = [
      _DS.neon,
      _DS.accent1,
      _DS.accent4,
      _DS.accent2,
      _DS.accent5,
      _DS.accent3,
    ];

    return List.generate(_nutrients.length, (i) {
      final n     = _nutrients[i] as Map<String, dynamic>;
      final color = colors[i % colors.length];

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: _DS.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: color.withOpacity(0.18), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.7),
                  shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n['nutrientName']?.toString() ??
                        "Unknown Nutrient",
                    style: const TextStyle(
                        color: _DS.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  const Text("",
                      style: TextStyle(
                          color: _DS.textMuted, fontSize: 10)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: color.withOpacity(0.25), width: 1),
              ),
              child: Text(
                "${n['value']?.toString() ?? '0'} ${n['unitName']?.toString() ?? ''}",
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => Column(
        children: [
          Transform.scale(
            scale: _pulseAnim.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _DS.neonFaint,
                border: Border.all(
                    color: _DS.neon.withOpacity(0.2), width: 1),
              ),
              child: const Icon(Icons.food_bank_outlined,
                  size: 40, color: _DS.textMuted),
            ),
          ),
          const SizedBox(height: 16),
          const Text("Upload a food image to analyze",
              style: TextStyle(
                  color: _DS.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text("Take a photo or select from gallery",
              style: TextStyle(
                  color: _DS.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  // ── Source picker bottom sheet ────────────────────────────────────────────
  void _showSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _DS.bgCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _DS.borderFaint, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: _DS.textMuted,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text("Select Photo Source",
                style: TextStyle(
                    color: _DS.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            _sourceOpt(
                Icons.camera_alt_rounded, "Take New Photo", _DS.neon,
                    () {
                  Navigator.pop(context);
                  captureImageFromCamera();
                }),
            const SizedBox(height: 10),
            _sourceOpt(Icons.photo_library_rounded,
                "Choose from Gallery", _DS.accent1, () {
                  Navigator.pop(context);
                  pickImageFromGallery();
                }),
            SizedBox(
                height: MediaQuery.of(context).viewInsets.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _sourceOpt(
      IconData icon, String label, Color c, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: c, size: 20),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    color: c,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}




// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
//
// void main() => runApp(const MyApp());
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Food Nutrition Scanner',
//       theme: ThemeData(
//         primarySwatch: Colors.deepPurple,
//         fontFamily: 'Inter',
//         useMaterial3: true,
//       ),
//       home: const FoodUploadScreen(title: "Food Scanner"),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
//
// class FoodUploadScreen extends StatefulWidget {
//   final String title;
//
//   const FoodUploadScreen({super.key, required this.title});
//
//   @override
//   State<FoodUploadScreen> createState() => _FoodUploadScreenState();
// }
//
// class _FoodUploadScreenState extends State<FoodUploadScreen> {
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   bool _isScanning = false;
//   File? _selectedImage;
//   Map<String, dynamic>? _scanResult;
//   List<dynamic> _nutrients = [];
//
//   // -------------------------
//   // PICK IMAGE FROM GALLERY
//   // -------------------------
//   Future<void> pickImageFromGallery() async {
//     final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       setState(() {
//         _selectedImage = File(picked.path);
//         _scanResult = null; // Reset previous results
//         _nutrients = [];
//       });
//     }
//   }
//
//   // -------------------------
//   // CAPTURE IMAGE FROM CAMERA
//   // -------------------------
//   Future<void> captureImageFromCamera() async {
//     final picked = await ImagePicker().pickImage(source: ImageSource.camera);
//     if (picked != null) {
//       setState(() {
//         _selectedImage = File(picked.path);
//         _scanResult = null; // Reset previous results
//         _nutrients = [];
//       });
//     }
//   }
//
//   // -------------------------
//   // SCAN FOOD IMAGE
//   // -------------------------
//   Future<void> scanFoodImage() async {
//     if (_selectedImage == null) {
//       Fluttertoast.showToast(
//         msg: "Please select an image first",
//         backgroundColor: Colors.orange,
//       );
//       return;
//     }
//
//     setState(() {
//       _isScanning = true;
//       _scanResult = null;
//       _nutrients = [];
//     });
//
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       String url = sh.getString("url").toString();
//
//       if (url.isEmpty) {
//         throw Exception("Server URL not configured");
//       }
//
//       var request = http.MultipartRequest(
//         "POST",
//         Uri.parse("$url/food_prediction/"),
//       );
//
//       // Add image file
//       request.files.add(await http.MultipartFile.fromPath(
//         'photo',
//         _selectedImage!.path,
//       ));
//
//       var response = await request.send();
//       var resBody = await response.stream.bytesToString();
//       var data = jsonDecode(resBody);
//
//       if (response.statusCode == 200) {
//         if (data['status'] == "ok") {
//           setState(() {
//             _scanResult = data;
//             _nutrients = data['nutrients'] ?? [];
//           });
//
//           Fluttertoast.showToast(
//             msg: "Food identified successfully!",
//             backgroundColor: Colors.green,
//           );
//         } else {
//           Fluttertoast.showToast(
//             msg: "Could not identify food. Please try with a clearer image.",
//             backgroundColor: Colors.orange,
//           );
//         }
//       } else {
//         Fluttertoast.showToast(
//           msg: "Server error: ${response.statusCode}",
//           backgroundColor: Colors.red,
//         );
//       }
//     } catch (e) {
//       print("Error scanning food: $e");
//       Fluttertoast.showToast(
//         msg: "Network error: ${e.toString()}",
//         backgroundColor: Colors.red,
//       );
//     } finally {
//       setState(() {
//         _isScanning = false;
//       });
//     }
//   }
//
//   // -------------------------
//   // BUILD NUTRIENT ITEM
//   // -------------------------
//   Widget _buildNutrientItem(Map<String, dynamic> nutrient, int index) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12),
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: index % 2 == 0 ? Colors.deepPurple.shade50 : Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.deepPurple.shade100, width: 1),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   nutrient['nutrientName']?.toString() ?? "Unknown Nutrient",
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.deepPurple.shade800,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   "Per 100g serving",
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.deepPurple,
//                   Colors.deepPurple.shade300,
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               "${nutrient['value']?.toString() ?? '0'} ${nutrient['unitName']?.toString() ?? ''}",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.deepPurple.shade50,
//               Colors.black,
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Header
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 child: Row(
//                   children: [
//                     IconButton(
//                       onPressed: () => Navigator.pop(context),
//                       icon: Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.05),
//                               blurRadius: 10,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: const Icon(Icons.arrow_back_ios_new_rounded,
//                             color: Colors.black, size: 20),
//                       ),
//                     ),
//                     const Spacer(),
//                     Text(
//                       "Food Scanner",
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.deepPurple,
//                       ),
//                     ),
//                     const Spacer(),
//                     const SizedBox(width: 48),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 10),
//
//               // Main Content
//               Expanded(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: const BorderRadius.vertical(
//                       top: Radius.circular(30),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.deepPurple.withOpacity(0.1),
//                         blurRadius: 30,
//                         offset: const Offset(0, -10),
//                       ),
//                     ],
//                   ),
//                   child: SingleChildScrollView(
//                     physics: const BouncingScrollPhysics(),
//                     padding: const EdgeInsets.fromLTRB(25, 30, 25, 30),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         // Image Upload Section
//                         Center(
//                           child: Column(
//                             children: [
//                               GestureDetector(
//                                 onTap: () {
//                                   showModalBottomSheet(
//                                     context: context,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.vertical(
//                                         top: Radius.circular(20),
//                                       ),
//                                     ),
//                                     builder: (context) => Container(
//                                       padding: EdgeInsets.all(20),
//                                       child: Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           ListTile(
//                                             leading: Icon(Icons.camera_alt,
//                                                 color: Colors.deepPurple),
//                                             title: Text("Take Photo"),
//                                             onTap: () {
//                                               Navigator.pop(context);
//                                               captureImageFromCamera();
//                                             },
//                                           ),
//                                           ListTile(
//                                             leading: Icon(Icons.photo_library,
//                                                 color: Colors.deepPurple),
//                                             title: Text("Choose from Gallery"),
//                                             onTap: () {
//                                               Navigator.pop(context);
//                                               pickImageFromGallery();
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 child: AnimatedContainer(
//                                   duration: const Duration(milliseconds: 300),
//                                   curve: Curves.easeInOut,
//                                   width: 150,
//                                   height: 150,
//                                   decoration: BoxDecoration(
//                                     color: Colors.deepPurple.shade50,
//                                     borderRadius: BorderRadius.circular(20),
//                                     border: Border.all(
//                                       color: Colors.deepPurple.shade200,
//                                       width: 2,
//                                     ),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.deepPurple.withOpacity(0.1),
//                                         blurRadius: 15,
//                                         offset: const Offset(0, 8),
//                                       ),
//                                     ],
//                                   ),
//                                   child: _selectedImage != null
//                                       ? ClipRRect(
//                                     borderRadius: BorderRadius.circular(18),
//                                     child: Image.file(
//                                       _selectedImage!,
//                                       fit: BoxFit.cover,
//                                       width: 146,
//                                       height: 146,
//                                     ),
//                                   )
//                                       : Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Icon(
//                                         Icons.camera_alt_rounded,
//                                         size: 50,
//                                         color: Colors.deepPurple.shade400,
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         "Upload Food Image",
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                           color: Colors.deepPurple.shade600,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 "Tap to upload food photo",
//                                 style: TextStyle(
//                                   color: Colors.grey.shade600,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         const SizedBox(height: 30),
//
//                         // Scan Button
//                         AnimatedContainer(
//                           duration: const Duration(milliseconds: 300),
//                           curve: Curves.easeInOut,
//                           height: 56,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(15),
//                             boxShadow: _isScanning
//                                 ? []
//                                 : [
//                               BoxShadow(
//                                 color: Colors.deepPurple.withOpacity(0.3),
//                                 blurRadius: 20,
//                                 offset: const Offset(0, 10),
//                               ),
//                             ],
//                           ),
//                           child: ElevatedButton(
//                             onPressed: _isScanning ? null : scanFoodImage,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.deepPurple,
//                               foregroundColor: Colors.white,
//                               elevation: 0,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                             ),
//                             child: _isScanning
//                                 ? const SizedBox(
//                               width: 24,
//                               height: 24,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 3,
//                                 color: Colors.white,
//                               ),
//                             )
//                                 : const Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.search, size: 20),
//                                 SizedBox(width: 10),
//                                 Text(
//                                   "Scan Food",
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//
//                         // Results Section
//                         if (_isScanning)
//                           Container(
//                             margin: EdgeInsets.only(top: 30),
//                             padding: EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               color: Colors.deepPurple.shade50,
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                             child: Column(
//                               children: [
//                                 CircularProgressIndicator(
//                                   color: Colors.deepPurple,
//                                 ),
//                                 SizedBox(height: 15),
//                                 Text(
//                                   "Analyzing food image...",
//                                   style: TextStyle(
//                                     color: Colors.deepPurple.shade700,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   "This may take a few seconds",
//                                   style: TextStyle(
//                                     color: Colors.grey.shade600,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                         // Scan Results
//                         if (_scanResult != null && !_isScanning) ...[
//                           const SizedBox(height: 30),
//
//                           // Food Name Card
//                           Container(
//                             padding: EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                                 colors: [
//                                   Colors.deepPurple,
//                                   Colors.deepPurple.shade300,
//                                 ],
//                               ),
//                               borderRadius: BorderRadius.circular(15),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.deepPurple.withOpacity(0.3),
//                                   blurRadius: 15,
//                                   offset: Offset(0, 5),
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.restaurant,
//                                   color: Colors.white,
//                                   size: 30,
//                                 ),
//                                 SizedBox(width: 15),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         "Identified Food",
//                                         style: TextStyle(
//                                           color: Colors.white.withOpacity(0.9),
//                                           fontSize: 12,
//                                         ),
//                                       ),
//                                       Text(
//                                         _scanResult!['foodname']?.toString() ??
//                                             "Unknown Food",
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 22,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Container(
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal: 12, vertical: 6),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withOpacity(0.2),
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   child: Icon(
//                                     Icons.check_circle,
//                                     color: Colors.white,
//                                     size: 20,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           const SizedBox(height: 20),
//
//                           // Nutrition Facts Header
//                           Row(
//                             children: [
//                               Container(
//                                 width: 4,
//                                 height: 20,
//                                 decoration: BoxDecoration(
//                                   color: Colors.deepPurple,
//                                   borderRadius: BorderRadius.circular(2),
//                                 ),
//                               ),
//                               SizedBox(width: 12),
//                               Text(
//                                 "Nutrition Facts",
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                               Spacer(),
//                               Container(
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal: 12, vertical: 6),
//                                 decoration: BoxDecoration(
//                                   color: Colors.deepPurple.shade50,
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Text(
//                                   "100g Serving",
//                                   style: TextStyle(
//                                     color: Colors.deepPurple,
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                           const SizedBox(height: 15),
//
//                           // Nutrients List
//                           if (_nutrients.isNotEmpty)
//                             Column(
//                               children: [
//                                 ...List.generate(
//                                   _nutrients.length,
//                                       (index) =>
//                                       _buildNutrientItem(_nutrients[index], index),
//                                 ),
//                               ],
//                             )
//                           else
//                             Container(
//                               padding: EdgeInsets.all(30),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade50,
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(
//                                   color: Colors.grey.shade200,
//                                 ),
//                               ),
//                               child: Column(
//                                 children: [
//                                   Icon(
//                                     Icons.info_outline,
//                                     color: Colors.grey.shade400,
//                                     size: 40,
//                                   ),
//                                   SizedBox(height: 10),
//                                   Text(
//                                     "No nutrient data available",
//                                     style: TextStyle(
//                                       color: Colors.grey.shade600,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//
//                           const SizedBox(height: 20),
//
//                           // Action Buttons
//
//                         ],
//
//                         // Empty State
//                         if (_selectedImage == null &&
//                             _scanResult == null &&
//                             !_isScanning) ...[
//                           const SizedBox(height: 50),
//                           Icon(
//                             Icons.food_bank_outlined,
//                             size: 80,
//                             color: Colors.grey.shade300,
//                           ),
//                           const SizedBox(height: 20),
//                           Text(
//                             "Upload a food image to analyze",
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.grey.shade600,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             "Take a photo or select from gallery",
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey.shade500,
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }