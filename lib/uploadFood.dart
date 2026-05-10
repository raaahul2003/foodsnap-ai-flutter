// import 'dart:io';
// import 'dart:convert';
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// // ── Import your real home/dashboard screen ────────────────────────────────────
// // Replace this with your actual import path
// import 'package:eatwise_ai/Home.dart';
//
// // ╔══════════════════════════════════════════════════════════════════════════╗
// // ║  DESIGN TOKENS                                                           ║
// // ╚══════════════════════════════════════════════════════════════════════════╝
// class _DS {
//   static const bg            = Color(0xFF050D0A);
//   static const bgCard        = Color(0xFF0C1A13);
//   static const surface       = Color(0xFF0F2018);
//   static const neon          = Color(0xFF00FF88);
//   static const neonDim       = Color(0xFF00C46A);
//   static const neonFaint     = Color(0xFF003D22);
//   static const accent1       = Color(0xFF00E5FF);
//   static const accent2       = Color(0xFFB2FF59);
//   static const accent3       = Color(0xFFFF6B6B);
//   static const accent4       = Color(0xFFFFD166);
//   static const accent5       = Color(0xFFA78BFA);
//   static const textPrimary   = Color(0xFFF0FFF8);
//   static const textSecondary = Color(0xFF6EE7B7);
//   static const textMuted     = Color(0xFF2E6B4A);
//   static const borderFaint   = Color(0xFF1A3D2A);
// }
//
// // ╔══════════════════════════════════════════════════════════════════════════╗
// // ║  1. UPLOAD / CAPTURE SCREEN                                              ║
// // ╚══════════════════════════════════════════════════════════════════════════╝
// class UploadFoodScreen extends StatefulWidget {
//   const UploadFoodScreen({super.key});
//   @override
//   State<UploadFoodScreen> createState() => _UploadFoodScreenState();
// }
//
// class _UploadFoodScreenState extends State<UploadFoodScreen>
//     with TickerProviderStateMixin {
//
//   File? _selectedImage;
//   bool  _isUploading  = false;
//   bool  _isShimmering = false;
//
//   // ── AI glow button animation controllers ─────────────────────────────────
//   late AnimationController _pulseCtrl;   // empty state orb pulse
//   late AnimationController _glowCtrl;    // button glow breathe
//   late AnimationController _orbitCtrl;   // button orbit ring spin
//   late AnimationController _scanCtrl;    // button scan line
//   late Animation<double>   _pulseAnim;
//   late Animation<double>   _glowAnim;
//   late Animation<double>   _orbitAnim;
//   late Animation<double>   _scanAnim;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _pulseCtrl = AnimationController(vsync: this,
//         duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
//     _pulseAnim = Tween<double>(begin: 0.93, end: 1.07).animate(
//         CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
//
//     _glowCtrl = AnimationController(vsync: this,
//         duration: const Duration(milliseconds: 2200))..repeat(reverse: true);
//     _glowAnim = Tween<double>(begin: 0.25, end: 0.85).animate(
//         CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
//
//     _orbitCtrl = AnimationController(vsync: this,
//         duration: const Duration(milliseconds: 3000))..repeat();
//     _orbitAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(parent: _orbitCtrl, curve: Curves.linear));
//
//     _scanCtrl = AnimationController(vsync: this,
//         duration: const Duration(milliseconds: 1600))..repeat();
//     _scanAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(parent: _scanCtrl, curve: Curves.linear));
//
//     _checkFirstTime();
//   }
//
//   @override
//   void dispose() {
//     _pulseCtrl.dispose();
//     _glowCtrl.dispose();
//     _orbitCtrl.dispose();
//     _scanCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _checkFirstTime() async {
//     final prefs = await SharedPreferences.getInstance();
//     final seen  = prefs.getBool('snap_tips_seen') ?? false;
//     if (!seen && mounted) {
//       await Future.delayed(const Duration(milliseconds: 500));
//       _showSmartInstructionSheet();
//     }
//   }
//
//   Future<void> _showSmartInstructionSheet() async {
//     await showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => const _SmartInstructionSheet(),
//     );
//   }
//
//   // ── REAL: pick image (unchanged backend logic) ────────────────────────────
//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final pickedFile = await ImagePicker()
//           .pickImage(source: source, imageQuality: 85);
//       if (pickedFile != null) {
//         setState(() => _isShimmering = true);
//         await Future.delayed(const Duration(milliseconds: 400));
//         setState(() {
//           _selectedImage = File(pickedFile.path);
//           _isShimmering  = false;
//         });
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Failed to get image");
//     }
//   }
//
//   // ── REAL: upload food (unchanged backend logic) ───────────────────────────
//   Future<void> _uploadFood() async {
//     if (_selectedImage == null) {
//       Fluttertoast.showToast(msg: "Please select an image first");
//       return;
//     }
//
//     setState(() => _isUploading = true);
//
//     try {
//       final prefs   = await SharedPreferences.getInstance();
//       final baseUrl = prefs.getString('url');
//       final lid     = prefs.getString('lid');
//
//       if (baseUrl == null || baseUrl.isEmpty) {
//         Fluttertoast.showToast(msg: "Server URL not configured");
//         setState(() => _isUploading = false);
//         return;
//       }
//
//       final uri     = Uri.parse("$baseUrl/upload_food/");
//       var   request = http.MultipartRequest("POST", uri);
//       request.fields['lid'] = lid ?? "";
//       request.files.add(
//           await http.MultipartFile.fromPath("photo", _selectedImage!.path));
//
//       final response     = await request.send();
//       final responseBody = await response.stream.bytesToString();
//
//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(responseBody);
//         if (jsonData["status"] == "ok") {
//           if (!mounted) return;
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (_) => NutritionResultScreen(
//                 foodName:  jsonData["foodname"] ?? "Food",
//                 protein:   jsonData["protein"]  ?? "0",
//                 carbs:     jsonData["carbs"]    ?? "0",
//                 fat:       jsonData["fat"]      ?? "0",
//                 nutrients: jsonData["nutrients"] ?? [],
//                 imageFile: _selectedImage,
//               ),
//             ),
//           );
//         } else {
//           Fluttertoast.showToast(
//               msg: jsonData["message"] ?? "No food detected");
//         }
//       } else {
//         Fluttertoast.showToast(msg: "Server error ${response.statusCode}");
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Upload failed: $e");
//     } finally {
//       if (mounted) setState(() => _isUploading = false);
//     }
//   }
//
//   // ╔════════════════════════════════════════════════════════════════════════╗
//   // ║  BUILD                                                                 ║
//   // ╚════════════════════════════════════════════════════════════════════════╝
//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.light,
//       child: Scaffold(
//         backgroundColor: _DS.bg,
//         body: SafeArea(
//           child: Column(
//             children: [
//               _buildAppBar(),
//               Expanded(
//                 child: SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 28),
//                       _buildHeroText(),
//                       const SizedBox(height: 36),
//                       _buildImageArea(),
//                       const SizedBox(height: 24),
//                       _buildActionButtons(),
//                       const SizedBox(height: 28),
//                       _buildAnalyzeButton(),
//                       const SizedBox(height: 40),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAppBar() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//       decoration: BoxDecoration(
//         color: _DS.bg,
//         border: Border(bottom: BorderSide(color: _DS.borderFaint, width: 1)),
//       ),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               padding: const EdgeInsets.all(9),
//               decoration: BoxDecoration(
//                 color: _DS.bgCard,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: _DS.borderFaint, width: 1),
//               ),
//               child: const Icon(Icons.arrow_back_ios_new_rounded,
//                   color: _DS.neon, size: 16),
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Snap Your Food",
//                     style: TextStyle(color: _DS.textPrimary, fontSize: 18,
//                         fontWeight: FontWeight.w900, letterSpacing: -0.3)),
//                 Text("AI-powered nutrition analysis",
//                     style: TextStyle(color: _DS.textMuted, fontSize: 11)),
//               ],
//             ),
//           ),
//           GestureDetector(
//             onTap: _showSmartInstructionSheet,
//             child: Container(
//               padding: const EdgeInsets.all(9),
//               decoration: BoxDecoration(
//                 color: _DS.neonFaint,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: _DS.neon.withOpacity(0.3), width: 1),
//               ),
//               child: const Icon(Icons.lightbulb_rounded,
//                   color: _DS.neon, size: 18),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHeroText() {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
//           decoration: BoxDecoration(
//             color: _DS.neonFaint,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: _DS.neon.withOpacity(0.3), width: 1),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.auto_awesome_rounded,
//                   color: _DS.neon, size: 13),
//               const SizedBox(width: 6),
//               Text("AI Nutrition Coach",
//                   style: TextStyle(color: _DS.neon, fontSize: 11,
//                       fontWeight: FontWeight.w700)),
//             ],
//           ),
//         ),
//         const SizedBox(height: 12),
//         Text("What did you eat?",
//             style: TextStyle(color: _DS.textPrimary, fontSize: 26,
//                 fontWeight: FontWeight.w900, letterSpacing: -0.6)),
//         const SizedBox(height: 6),
//         Text("Take or upload a photo for instant AI nutrition analysis",
//             textAlign: TextAlign.center,
//             style: TextStyle(color: _DS.textMuted, fontSize: 13, height: 1.5)),
//       ],
//     );
//   }
//
//   Widget _buildImageArea() {
//     return AnimatedBuilder(
//       animation: _glowAnim,
//       builder: (_, __) => Container(
//         height: 300,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: _DS.bgCard,
//           borderRadius: BorderRadius.circular(28),
//           border: Border.all(
//             color: _selectedImage != null
//                 ? _DS.neon.withOpacity(0.45)
//                 : _DS.borderFaint,
//             width: 1.5,
//           ),
//           boxShadow: _selectedImage != null
//               ? [BoxShadow(
//               color: _DS.neon.withOpacity(_glowAnim.value * 0.18),
//               blurRadius: 32, offset: const Offset(0, 6))]
//               : [],
//         ),
//         child: _isShimmering
//             ? _buildShimmer()
//             : _selectedImage != null
//             ? _buildPreviewThumb()
//             : _buildEmptyState(),
//       ),
//     );
//   }
//
//   Widget _buildShimmer() {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(26),
//       child: Stack(
//         children: [
//           Container(color: _DS.surface),
//           TweenAnimationBuilder<double>(
//             tween: Tween(begin: -1.0, end: 2.0),
//             duration: const Duration(milliseconds: 800),
//             builder: (_, val, __) => Positioned.fill(
//               child: Transform.translate(
//                 offset: Offset(val * 400, 0),
//                 child: Container(
//                   width: 120,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(colors: [
//                       Colors.transparent,
//                       _DS.neon.withOpacity(0.09),
//                       Colors.transparent,
//                     ]),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SizedBox(width: 28, height: 28,
//                     child: CircularProgressIndicator(
//                         color: _DS.neon, strokeWidth: 2.5)),
//                 SizedBox(height: 12),
//                 Text("Loading image...",
//                     style: TextStyle(color: _DS.textMuted, fontSize: 13)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPreviewThumb() {
//     return Stack(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(26),
//           child: Image.file(_selectedImage!, fit: BoxFit.cover,
//               width: double.infinity, height: double.infinity),
//         ),
//         Positioned(
//           bottom: 12, left: 0, right: 0,
//           child: Center(
//             child: GestureDetector(
//               onTap: _showSourcePicker,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 14, vertical: 7),
//                 decoration: BoxDecoration(
//                   color: _DS.bg.withOpacity(0.88),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: _DS.borderFaint, width: 1),
//                 ),
//                 child: const Text("Tap to change photo",
//                     style: TextStyle(color: _DS.textSecondary,
//                         fontSize: 11, fontWeight: FontWeight.w600)),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return AnimatedBuilder(
//       animation: _pulseAnim,
//       builder: (_, __) => Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Transform.scale(
//               scale: _pulseAnim.value,
//               child: Container(
//                 width: 90, height: 90,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: _DS.neonFaint,
//                   border: Border.all(
//                       color: _DS.neon.withOpacity(0.4), width: 1.5),
//                   boxShadow: [BoxShadow(
//                       color: _DS.neon.withOpacity(0.18),
//                       blurRadius: 22, spreadRadius: 2)],
//                 ),
//                 child: const Icon(Icons.add_photo_alternate_rounded,
//                     color: _DS.neon, size: 40),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text("No image selected",
//                 style: TextStyle(color: _DS.textPrimary, fontSize: 15,
//                     fontWeight: FontWeight.w700)),
//             const SizedBox(height: 4),
//             Text("Use buttons below to capture or upload",
//                 style: TextStyle(color: _DS.textMuted, fontSize: 12)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildActionButtons() {
//     return Row(
//       children: [
//         Expanded(child: _actionBtn(
//           icon: Icons.camera_alt_rounded, label: "Take Photo", color: _DS.neon,
//           onTap: () => _pickImage(ImageSource.camera),
//         )),
//         const SizedBox(width: 12),
//         Expanded(child: _actionBtn(
//           icon: Icons.photo_library_rounded, label: "Gallery", color: _DS.accent1,
//           onTap: () => _pickImage(ImageSource.gallery),
//         )),
//       ],
//     );
//   }
//
//   Widget _actionBtn({
//     required IconData icon, required String label,
//     required Color color, required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: () { HapticFeedback.lightImpact(); onTap(); },
//       child: Container(
//         height: 64,
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: color.withOpacity(0.3), width: 1.2),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: color, size: 22),
//             const SizedBox(width: 8),
//             Text(label, style: TextStyle(color: color, fontSize: 14,
//                 fontWeight: FontWeight.w800)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── AI Glow Analyze Button ────────────────────────────────────────────────
//   Widget _buildAnalyzeButton() {
//     final hasImage = _selectedImage != null;
//
//     return AnimatedBuilder(
//       animation: Listenable.merge([_glowAnim, _orbitAnim, _scanAnim]),
//       builder: (_, __) {
//         return GestureDetector(
//           onTap: (hasImage && !_isUploading)
//               ? () { HapticFeedback.mediumImpact(); _uploadFood(); }
//               : null,
//           child: AnimatedOpacity(
//             opacity: hasImage ? 1.0 : 0.45,
//             duration: const Duration(milliseconds: 300),
//             child: SizedBox(
//               width: double.infinity,
//               height: 72,
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   // Outer glow halo
//                   if (hasImage && !_isUploading)
//                     Container(
//                       width: double.infinity,
//                       height: 72,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(24),
//                         boxShadow: [
//                           BoxShadow(
//                             color: _DS.neon.withOpacity(_glowAnim.value * 0.55),
//                             blurRadius: 40,
//                             spreadRadius: -2,
//                           ),
//                           BoxShadow(
//                             color: _DS.neon.withOpacity(_glowAnim.value * 0.25),
//                             blurRadius: 80,
//                             spreadRadius: 4,
//                           ),
//                         ],
//                       ),
//                     ),
//
//                   // Orbit ring (rotating dashes)
//                   if (hasImage && !_isUploading)
//                     Transform.rotate(
//                       angle: _orbitAnim.value * 2 * math.pi,
//                       child: Container(
//                         width: double.infinity,
//                         height: 72,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(24),
//                           border: Border.all(
//                             color: _DS.neon.withOpacity(0.15),
//                             width: 1,
//                           ),
//                         ),
//                       ),
//                     ),
//
//                   // Main button body
//                   Container(
//                     width: double.infinity,
//                     height: 68,
//                     decoration: BoxDecoration(
//                       gradient: hasImage && !_isUploading
//                           ? LinearGradient(
//                         colors: [
//                           Color.lerp(_DS.neon, _DS.accent1,
//                               _glowAnim.value * 0.3)!,
//                           _DS.neonDim,
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       )
//                           : const LinearGradient(
//                           colors: [_DS.neonFaint, _DS.neonFaint]),
//                       borderRadius: BorderRadius.circular(22),
//                       border: Border.all(
//                         color: hasImage
//                             ? _DS.neon.withOpacity(0.6)
//                             : _DS.borderFaint,
//                         width: 1.2,
//                       ),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(22),
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           // Animated scan line sweep across button
//                           if (hasImage && !_isUploading)
//                             Positioned.fill(
//                               child: Transform.translate(
//                                 offset: Offset(
//                                   (_scanAnim.value * 2 - 1) *
//                                       MediaQuery.of(context).size.width,
//                                   0,
//                                 ),
//                                 child: Container(
//                                   width: 80,
//                                   decoration: BoxDecoration(
//                                     gradient: LinearGradient(
//                                       colors: [
//                                         Colors.transparent,
//                                         _DS.neon.withOpacity(0.18),
//                                         Colors.transparent,
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//
//                           // Button content
//                           _isUploading
//                               ? Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               SizedBox(
//                                 width: 20, height: 20,
//                                 child: CircularProgressIndicator(
//                                   color: _DS.neon.withOpacity(0.8),
//                                   strokeWidth: 2.5,
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Text("Analyzing...",
//                                   style: TextStyle(
//                                     color: _DS.neon,
//                                     fontSize: 17,
//                                     fontWeight: FontWeight.w900,
//                                     letterSpacing: 0.3,
//                                   )),
//                             ],
//                           )
//                               : Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               // Pulsing icon
//                               Transform.scale(
//                                 scale: hasImage
//                                     ? 0.92 + _glowAnim.value * 0.16
//                                     : 1.0,
//                                 child: Icon(
//                                   Icons.bolt_rounded,
//                                   color: hasImage
//                                       ? _DS.bg
//                                       : _DS.textMuted,
//                                   size: 24,
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Text(
//                                 "Analyze Nutrition",
//                                 style: TextStyle(
//                                   color: hasImage
//                                       ? _DS.bg
//                                       : _DS.textMuted,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w900,
//                                   letterSpacing: 0.3,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   void _showSourcePicker() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (_) => Container(
//         margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: _DS.bgCard,
//           borderRadius: BorderRadius.circular(24),
//           border: Border.all(color: _DS.borderFaint, width: 1),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(width: 40, height: 4,
//                 decoration: BoxDecoration(color: _DS.textMuted,
//                     borderRadius: BorderRadius.circular(2))),
//             const SizedBox(height: 20),
//             Text("Change Photo",
//                 style: TextStyle(color: _DS.textPrimary, fontSize: 16,
//                     fontWeight: FontWeight.w900)),
//             const SizedBox(height: 16),
//             _sourceOpt(Icons.camera_alt_rounded, "Take New Photo", _DS.neon,
//                     () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
//             const SizedBox(height: 10),
//             _sourceOpt(Icons.photo_library_rounded, "Choose from Gallery",
//                 _DS.accent1,
//                     () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _sourceOpt(IconData icon, String label, Color c, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         decoration: BoxDecoration(
//           color: c.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: c.withOpacity(0.2), width: 1),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: c, size: 20),
//             const SizedBox(width: 12),
//             Text(label, style: TextStyle(color: c, fontSize: 14,
//                 fontWeight: FontWeight.w700)),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ╔══════════════════════════════════════════════════════════════════════════╗
// // ║  2. SMART INSTRUCTION SHEET (first-time only)                            ║
// // ╚══════════════════════════════════════════════════════════════════════════╝
// class _SmartInstructionSheet extends StatefulWidget {
//   const _SmartInstructionSheet();
//   @override
//   State<_SmartInstructionSheet> createState() => _SmartInstructionSheetState();
// }
//
// class _SmartInstructionSheetState extends State<_SmartInstructionSheet>
//     with SingleTickerProviderStateMixin {
//
//   late AnimationController _ctrl;
//   late Animation<double>   _slideAnim;
//   late Animation<double>   _fadeAnim;
//
//   final _tips = [
//     ['💡', 'Good Lighting',  'Bright, even light improves food detection accuracy.'],
//     ['🍽', 'Show Full Meal', 'Include all dishes, sides, and drinks in the frame.'],
//     ['🔍', 'Avoid Clutter',  'Remove unrelated objects; keep background clean.'],
//     ['📷', 'Keep Steady',    'Blurry or shaky photos reduce AI confidence.'],
//   ];
//   final List<bool> _ticked = [false, false, false, false];
//
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(vsync: this,
//         duration: const Duration(milliseconds: 450));
//     _slideAnim = Tween<double>(begin: 60.0, end: 0.0).animate(
//         CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
//     _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
//     _ctrl.forward();
//     for (int i = 0; i < _tips.length; i++) {
//       Future.delayed(Duration(milliseconds: 280 + i * 140), () {
//         if (mounted) setState(() => _ticked[i] = true);
//       });
//     }
//   }
//
//   @override
//   void dispose() { _ctrl.dispose(); super.dispose(); }
//
//   Future<void> _dismiss({bool dontShow = false}) async {
//     if (dontShow) {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('snap_tips_seen', true);
//     }
//     if (mounted) Navigator.pop(context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _ctrl,
//       builder: (_, child) => Opacity(
//         opacity: _fadeAnim.value,
//         child: Transform.translate(
//             offset: Offset(0, _slideAnim.value), child: child),
//       ),
//       child: Container(
//         margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           color: _DS.bgCard,
//           borderRadius: BorderRadius.circular(28),
//           border: Border.all(color: _DS.neon.withOpacity(0.2), width: 1.2),
//           boxShadow: [BoxShadow(
//               color: _DS.neon.withOpacity(0.1),
//               blurRadius: 32, offset: const Offset(0, -4))],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(child: Container(width: 40, height: 4,
//                 decoration: BoxDecoration(color: _DS.textMuted,
//                     borderRadius: BorderRadius.circular(2)))),
//             const SizedBox(height: 20),
//
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: _DS.neonFaint,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: _DS.neon.withOpacity(0.3), width: 1),
//                   ),
//                   child: const Icon(Icons.camera_enhance_rounded,
//                       color: _DS.neon, size: 20),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("📸 Capture Smart for Better Accuracy",
//                         style: TextStyle(color: _DS.textPrimary, fontSize: 14,
//                             fontWeight: FontWeight.w900)),
//                     Text("Better photos = higher AI accuracy",
//                         style: TextStyle(color: _DS.textMuted, fontSize: 11)),
//                   ],
//                 )),
//               ],
//             ),
//             const SizedBox(height: 20),
//
//             ...List.generate(_tips.length, (i) => Padding(
//               padding: const EdgeInsets.only(bottom: 10),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 280),
//                 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
//                 decoration: BoxDecoration(
//                   color: _ticked[i]
//                       ? _DS.neon.withOpacity(0.06) : _DS.surface,
//                   borderRadius: BorderRadius.circular(14),
//                   border: Border.all(
//                     color: _ticked[i]
//                         ? _DS.neon.withOpacity(0.3) : _DS.borderFaint,
//                     width: 1,
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Text(_tips[i][0],
//                         style: const TextStyle(fontSize: 18)),
//                     const SizedBox(width: 10),
//                     Expanded(child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(_tips[i][1],
//                             style: TextStyle(color: _DS.textPrimary,
//                                 fontSize: 13, fontWeight: FontWeight.w700)),
//                         Text(_tips[i][2],
//                             style: TextStyle(color: _DS.textMuted,
//                                 fontSize: 11, height: 1.4)),
//                       ],
//                     )),
//                     AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 280),
//                       child: _ticked[i]
//                           ? const Icon(Icons.check_circle_rounded,
//                           color: _DS.neon, size: 20, key: ValueKey('t'))
//                           : const SizedBox(width: 20, key: ValueKey('e')),
//                     ),
//                   ],
//                 ),
//               ),
//             )),
//
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: _DS.accent5.withOpacity(0.07),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: _DS.accent5.withOpacity(0.2), width: 1),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.auto_awesome_rounded,
//                       color: _DS.accent5, size: 15),
//                   const SizedBox(width: 8),
//                   Expanded(child: Text(
//                       "AI confidence improves with clear, well-lit photos.",
//                       style: TextStyle(color: _DS.accent5, fontSize: 11,
//                           fontWeight: FontWeight.w600, height: 1.4))),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             GestureDetector(
//               onTap: () => _dismiss(),
//               child: Container(
//                 width: double.infinity, height: 54,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                       colors: [_DS.neon, _DS.neonDim],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight),
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [BoxShadow(
//                       color: _DS.neon.withOpacity(0.3),
//                       blurRadius: 16, offset: const Offset(0, 4))],
//                 ),
//                 child: Center(child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(Icons.camera_alt_rounded,
//                         color: _DS.bg, size: 18),
//                     const SizedBox(width: 8),
//                     Text("Got it, Open Camera",
//                         style: TextStyle(color: _DS.bg, fontSize: 15,
//                             fontWeight: FontWeight.w900)),
//                   ],
//                 )),
//               ),
//             ),
//             const SizedBox(height: 10),
//             GestureDetector(
//               onTap: () => _dismiss(dontShow: true),
//               child: Center(child: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 6),
//                 child: Text("Don't show again",
//                     style: TextStyle(color: _DS.textMuted, fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                         decoration: TextDecoration.underline,
//                         decorationColor: _DS.textMuted)),
//               )),
//             ),
//             SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 4),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ╔══════════════════════════════════════════════════════════════════════════╗
// // ║  3. NUTRITION RESULT SCREEN  (real API data only)                        ║
// // ╚══════════════════════════════════════════════════════════════════════════╝
// class NutritionResultScreen extends StatefulWidget {
//   final String foodName;
//   final String protein;
//   final String carbs;
//   final String fat;
//   final List   nutrients;
//   final File?  imageFile;
//
//   const NutritionResultScreen({
//     super.key,
//     required this.foodName,
//     required this.protein,
//     required this.carbs,
//     required this.fat,
//     required this.nutrients,
//     this.imageFile,
//   });
//
//   @override
//   State<NutritionResultScreen> createState() =>
//       _NutritionResultScreenState();
// }
//
// class _NutritionResultScreenState extends State<NutritionResultScreen>
//     with TickerProviderStateMixin {
//
//   late AnimationController _entryCtrl;
//   late AnimationController _barCtrl;
//   late AnimationController _glowCtrl;
//   late Animation<double>   _fadeAnim;
//   late Animation<double>   _slideAnim;
//   late Animation<double>   _barAnim;
//   late Animation<double>   _glowAnim;
//
//   bool _saved = false;
//
//   // ── Real API values ───────────────────────────────────────────────────────
//   double get _protein  => double.tryParse(widget.protein) ?? 0;
//   double get _carbs    => double.tryParse(widget.carbs)   ?? 0;
//   double get _fat      => double.tryParse(widget.fat)     ?? 0;
//   double get _calories => (_protein * 4) + (_carbs * 4) + (_fat * 9);
//
//   // Daily reference values (standard)
//   static const double _goalCalories = 2000;
//   static const double _goalProtein  = 50;
//   static const double _goalCarbs    = 275;
//   static const double _goalFat      = 78;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _entryCtrl = AnimationController(vsync: this,
//         duration: const Duration(milliseconds: 800));
//     _fadeAnim  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
//     _slideAnim = Tween<double>(begin: 28.0, end: 0.0).animate(
//         CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
//
//     _barCtrl = AnimationController(vsync: this,
//         duration: const Duration(milliseconds: 1100));
//     _barAnim = CurvedAnimation(parent: _barCtrl, curve: Curves.easeOutCubic);
//
//     _glowCtrl = AnimationController(vsync: this,
//         duration: const Duration(milliseconds: 2400))..repeat(reverse: true);
//     _glowAnim = Tween<double>(begin: 0.2, end: 0.75).animate(
//         CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
//
//     _entryCtrl.forward();
//     Future.delayed(
//         const Duration(milliseconds: 350), () => _barCtrl.forward());
//   }
//
//   @override
//   void dispose() {
//     _entryCtrl.dispose();
//     _barCtrl.dispose();
//     _glowCtrl.dispose();
//     super.dispose();
//   }
//
//   Color get _calorieColor {
//     final pct = _calories / _goalCalories;
//     if (pct >= 1.0) return _DS.accent3;
//     if (pct >= 0.7) return _DS.accent4;
//     return _DS.neon;
//   }
//
//   // ── Navigate to calorie dashboard ─────────────────────────────────────────
//   Future<void> _saveAndGoHome() async {
//     HapticFeedback.mediumImpact();
//     setState(() => _saved = true);
//
//     Fluttertoast.showToast(
//       msg: "✓ Added successfully to today's intake.",
//       toastLength: Toast.LENGTH_LONG,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: _DS.neonFaint,
//       textColor: _DS.neon,
//     );
//
//     await Future.delayed(const Duration(milliseconds: 900));
//     if (!mounted) return;
//
//     // Navigate back to UserHome (calorie dashboard)
//     // Uses pushAndRemoveUntil to clear the upload stack
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const UserHome()),
//           (route) => false,
//     );
//   }
//
//   // ╔════════════════════════════════════════════════════════════════════════╗
//   // ║  BUILD                                                                 ║
//   // ╚════════════════════════════════════════════════════════════════════════╝
//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.light,
//       child: Scaffold(
//         backgroundColor: _DS.bg,
//         body: SafeArea(
//           child: Column(
//             children: [
//               _buildAppBar(),
//               Expanded(
//                 child: AnimatedBuilder(
//                   animation: _entryCtrl,
//                   builder: (_, child) => Opacity(
//                     opacity: _fadeAnim.value,
//                     child: Transform.translate(
//                         offset: Offset(0, _slideAnim.value), child: child),
//                   ),
//                   child: SingleChildScrollView(
//                     physics: const BouncingScrollPhysics(),
//                     padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
//                     child: Column(
//                       children: [
//                         // Food image (if available)
//                         if (widget.imageFile != null) ...[
//                           _buildFoodImage(),
//                           const SizedBox(height: 16),
//                         ],
//                         _buildCalorieSummary(),
//                         const SizedBox(height: 16),
//                         _buildMacroCard(),
//                         const SizedBox(height: 16),
//                         if (widget.nutrients.isNotEmpty) ...[
//                           _buildNutrientList(),
//                           const SizedBox(height: 16),
//                         ],
//                         _buildSaveButton(),
//                         const SizedBox(height: 40),
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
//
//   Widget _buildAppBar() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//       decoration: BoxDecoration(
//         color: _DS.bg,
//         border: Border(bottom: BorderSide(color: _DS.borderFaint, width: 1)),
//       ),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               padding: const EdgeInsets.all(9),
//               decoration: BoxDecoration(
//                 color: _DS.bgCard,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: _DS.borderFaint, width: 1),
//               ),
//               child: const Icon(Icons.arrow_back_ios_new_rounded,
//                   color: _DS.neon, size: 16),
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(widget.foodName,
//                     style: TextStyle(color: _DS.textPrimary, fontSize: 17,
//                         fontWeight: FontWeight.w900, letterSpacing: -0.3),
//                     overflow: TextOverflow.ellipsis),
//                 Text("Nutrition Analysis",
//                     style: TextStyle(color: _DS.textMuted, fontSize: 11)),
//               ],
//             ),
//           ),
//           // Neon AI badge
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//             decoration: BoxDecoration(
//               color: _DS.neonFaint,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: _DS.neon.withOpacity(0.35), width: 1),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.auto_awesome_rounded,
//                     color: _DS.neon, size: 12),
//                 const SizedBox(width: 5),
//                 Text("AI Result",
//                     style: TextStyle(color: _DS.neon, fontSize: 10,
//                         fontWeight: FontWeight.w800)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Food image thumbnail ──────────────────────────────────────────────────
//   Widget _buildFoodImage() {
//     return AnimatedBuilder(
//       animation: _glowAnim,
//       builder: (_, __) => Container(
//         height: 220,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(24),
//           border: Border.all(
//               color: _DS.neon.withOpacity(0.3), width: 1.5),
//           boxShadow: [BoxShadow(
//               color: _DS.neon.withOpacity(_glowAnim.value * 0.15),
//               blurRadius: 24, offset: const Offset(0, 6))],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(22),
//           child: Image.file(widget.imageFile!,
//               fit: BoxFit.cover,
//               width: double.infinity,
//               height: double.infinity),
//         ),
//       ),
//     );
//   }
//
//   // ── Calorie summary card ──────────────────────────────────────────────────
//   Widget _buildCalorieSummary() {
//     final calPct = (_calories / _goalCalories).clamp(0.0, 1.0);
//
//     return AnimatedBuilder(
//       animation: _glowAnim,
//       builder: (_, __) => Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: _DS.bgCard,
//           borderRadius: BorderRadius.circular(24),
//           border: Border.all(
//               color: _calorieColor.withOpacity(0.25), width: 1.2),
//           boxShadow: [BoxShadow(
//               color: _calorieColor.withOpacity(_glowAnim.value * 0.14),
//               blurRadius: 24, offset: const Offset(0, 6))],
//         ),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 // Big calorie number
//                 Container(
//                   width: 90, height: 90,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: _calorieColor.withOpacity(0.1),
//                     border: Border.all(
//                         color: _calorieColor.withOpacity(0.45), width: 2),
//                     boxShadow: [BoxShadow(
//                         color: _calorieColor.withOpacity(
//                             _glowAnim.value * 0.4),
//                         blurRadius: 18, spreadRadius: 2)],
//                   ),
//                   child: Center(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(_calories.toStringAsFixed(0),
//                             style: TextStyle(color: _calorieColor,
//                                 fontSize: 20, fontWeight: FontWeight.w900)),
//                         Text("kcal",
//                             style: TextStyle(
//                                 color: _calorieColor.withOpacity(0.7),
//                                 fontSize: 10, fontWeight: FontWeight.w700)),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(widget.foodName,
//                           style: TextStyle(color: _DS.textPrimary,
//                               fontSize: 16, fontWeight: FontWeight.w900),
//                           overflow: TextOverflow.ellipsis),
//                       const SizedBox(height: 6),
//                       _inlinePill(
//                           "${(_calories / _goalCalories * 100).toStringAsFixed(0)}% of daily goal",
//                           _calorieColor),
//                       const SizedBox(height: 6),
//                       _inlinePill(
//                           _calories >= _goalCalories
//                               ? "⚠ Exceeds daily goal"
//                               : "Within daily goal",
//                           _calories >= _goalCalories
//                               ? _DS.accent3 : _DS.neon),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             // Calorie progress bar
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text("Daily Calorie Goal",
//                         style: TextStyle(color: _DS.textMuted,
//                             fontSize: 11, fontWeight: FontWeight.w600)),
//                     Text("${_calories.toStringAsFixed(0)} / "
//                         "${_goalCalories.toStringAsFixed(0)} kcal",
//                         style: TextStyle(color: _calorieColor,
//                             fontSize: 11, fontWeight: FontWeight.w700)),
//                   ],
//                 ),
//                 const SizedBox(height: 7),
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Stack(
//                     children: [
//                       Container(height: 12, color: _DS.surface),
//                       AnimatedBuilder(
//                         animation: _barAnim,
//                         builder: (_, __) => FractionallySizedBox(
//                           widthFactor: calPct * _barAnim.value,
//                           child: Container(
//                             height: 12,
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(colors: [
//                                 _DS.neon.withOpacity(0.7),
//                                 _calorieColor,
//                               ]),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _inlinePill(String text, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: color.withOpacity(0.25), width: 1),
//       ),
//       child: Text(text,
//           style: TextStyle(color: color, fontSize: 10,
//               fontWeight: FontWeight.w700)),
//     );
//   }
//
//   // ── Macro card (protein ring + carbs/fat bars) ────────────────────────────
//   Widget _buildMacroCard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: _DS.bgCard,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: _DS.borderFaint, width: 1),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionHeader("Macronutrients",
//               Icons.bar_chart_rounded, _DS.accent1),
//           const SizedBox(height: 18),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Protein ring
//               Column(
//                 children: [
//                   AnimatedBuilder(
//                     animation: _barAnim,
//                     builder: (_, __) => SizedBox(
//                       width: 88, height: 88,
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           SizedBox(
//                             width: 88, height: 88,
//                             child: CircularProgressIndicator(
//                               value: (_protein / _goalProtein * _barAnim.value)
//                                   .clamp(0.0, 1.0),
//                               strokeWidth: 8,
//                               backgroundColor: _DS.surface,
//                               valueColor: const AlwaysStoppedAnimation<Color>(
//                                   _DS.accent1),
//                             ),
//                           ),
//                           Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text("${_protein.toStringAsFixed(1)}g",
//                                   style: const TextStyle(color: _DS.accent1,
//                                       fontSize: 13, fontWeight: FontWeight.w900)),
//                               const Text("Protein",
//                                   style: TextStyle(color: _DS.textMuted,
//                                       fontSize: 9, fontWeight: FontWeight.w600)),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 5),
//                   Text("${(_protein / _goalProtein * 100).toStringAsFixed(0)}% DRI",
//                       style: const TextStyle(color: _DS.textMuted,
//                           fontSize: 9, fontWeight: FontWeight.w600)),
//                 ],
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   children: [
//                     _macroBar("Carbohydrates", _carbs,
//                         _goalCarbs, _DS.accent4),
//                     const SizedBox(height: 14),
//                     _macroBar("Fat", _fat, _goalFat, _DS.accent3),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _macroBar(String label, double val, double goal, Color color) {
//     final pct = (val / goal).clamp(0.0, 1.0);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(label, style: TextStyle(color: _DS.textSecondary,
//                 fontSize: 12, fontWeight: FontWeight.w700)),
//             Text("${val.toStringAsFixed(1)}g",
//                 style: TextStyle(color: color, fontSize: 12,
//                     fontWeight: FontWeight.w800)),
//           ],
//         ),
//         const SizedBox(height: 6),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(6),
//           child: Stack(
//             children: [
//               Container(height: 10, color: _DS.surface),
//               AnimatedBuilder(
//                 animation: _barAnim,
//                 builder: (_, __) => FractionallySizedBox(
//                   widthFactor: pct * _barAnim.value,
//                   child: Container(
//                     height: 10,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(colors: [
//                         color.withOpacity(0.65), color,
//                       ]),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 3),
//         Text("${(pct * 100).toStringAsFixed(0)}% of daily recommended",
//             style: const TextStyle(color: _DS.textMuted, fontSize: 9)),
//       ],
//     );
//   }
//
//   // ── Full nutrient list (real API data) ─────────────────────────────────────
//   Widget _buildNutrientList() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: _DS.bgCard,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: _DS.borderFaint, width: 1),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionHeader("Full Nutrient Details",
//               Icons.list_alt_rounded, _DS.accent2),
//           const SizedBox(height: 14),
//           ...widget.nutrients.map<Widget>((n) => Container(
//             margin: const EdgeInsets.only(bottom: 2),
//             padding: const EdgeInsets.symmetric(vertical: 10),
//             decoration: BoxDecoration(
//               border: Border(
//                   bottom: BorderSide(
//                       color: _DS.borderFaint.withOpacity(0.5), width: 1)),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 6, height: 6,
//                   decoration: BoxDecoration(
//                       color: _DS.neon.withOpacity(0.5),
//                       shape: BoxShape.circle),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(n["nutrientName"] ?? "",
//                       style: const TextStyle(color: _DS.textSecondary,
//                           fontSize: 13, fontWeight: FontWeight.w500)),
//                 ),
//                 Text("${n["value"]} ${n["unitName"]}",
//                     style: const TextStyle(color: _DS.textPrimary,
//                         fontSize: 13, fontWeight: FontWeight.w700)),
//               ],
//             ),
//           )).toList(),
//         ],
//       ),
//     );
//   }
//
//   // ── Save → Dashboard button ────────────────────────────────────────────────
//   Widget _buildSaveButton() {
//     return AnimatedBuilder(
//       animation: _glowAnim,
//       builder: (_, __) => GestureDetector(
//         onTap: _saved ? null : _saveAndGoHome,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           width: double.infinity,
//           height: 64,
//           decoration: BoxDecoration(
//             gradient: _saved
//                 ? const LinearGradient(
//                 colors: [_DS.neonFaint, _DS.neonFaint])
//                 : const LinearGradient(
//                 colors: [_DS.neon, _DS.neonDim],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight),
//             borderRadius: BorderRadius.circular(22),
//             boxShadow: _saved
//                 ? []
//                 : [
//               BoxShadow(
//                 color: _DS.neon
//                     .withOpacity(_glowAnim.value * 0.5),
//                 blurRadius: 30,
//                 spreadRadius: -4,
//                 offset: const Offset(0, 8),
//               ),
//               BoxShadow(
//                 color: _DS.neon
//                     .withOpacity(_glowAnim.value * 0.2),
//                 blurRadius: 60,
//                 spreadRadius: 2,
//               ),
//             ],
//             border: Border.all(
//               color: _saved
//                   ? _DS.neon.withOpacity(0.25)
//                   : Colors.transparent,
//               width: 1,
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 _saved
//                     ? Icons.check_circle_rounded
//                     : Icons.dashboard_rounded,
//                 color: _saved ? _DS.neon : _DS.bg,
//                 size: 22,
//               ),
//               const SizedBox(width: 10),
//               Text(
//                 _saved
//                     ? "Saved! Opening Dashboard..."
//                     : "Save & Go to Dashboard",
//                 style: TextStyle(
//                   color: _saved ? _DS.neon : _DS.bg,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w900,
//                   letterSpacing: 0.3,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _sectionHeader(String title, IconData icon, Color color) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(7),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.12),
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: color.withOpacity(0.25), width: 1),
//           ),
//           child: Icon(icon, size: 15, color: color),
//         ),
//         const SizedBox(width: 10),
//         Text(title,
//             style: const TextStyle(color: _DS.textPrimary, fontSize: 15,
//                 fontWeight: FontWeight.w900, letterSpacing: -0.2)),
//       ],
//     );
//   }
// }
//
//
//



import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ── Import your real home/dashboard screen ────────────────────────────────────
// Replace this with your actual import path
import 'package:eatwise_ai/Home.dart';

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
// ║  1. UPLOAD / CAPTURE SCREEN                                              ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class UploadFoodScreen extends StatefulWidget {
  const UploadFoodScreen({super.key});
  @override
  State<UploadFoodScreen> createState() => _UploadFoodScreenState();
}

class _UploadFoodScreenState extends State<UploadFoodScreen>
    with TickerProviderStateMixin {

  File? _selectedImage;
  bool  _isUploading  = false;
  bool  _isShimmering = false;

  // ── AI glow button animation controllers ─────────────────────────────────
  late AnimationController _pulseCtrl;   // empty state orb pulse
  late AnimationController _glowCtrl;    // button glow breathe
  late AnimationController _orbitCtrl;   // button orbit ring spin
  late AnimationController _scanCtrl;    // button scan line
  late Animation<double>   _pulseAnim;
  late Animation<double>   _glowAnim;
  late Animation<double>   _orbitAnim;
  late Animation<double>   _scanAnim;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.93, end: 1.07).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _glowCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 2200))..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.25, end: 0.85).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _orbitCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 3000))..repeat();
    _orbitAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _orbitCtrl, curve: Curves.linear));

    _scanCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1600))..repeat();
    _scanAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _scanCtrl, curve: Curves.linear));

    _checkFirstTime();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _glowCtrl.dispose();
    _orbitCtrl.dispose();
    _scanCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final seen  = prefs.getBool('snap_tips_seen') ?? false;
    if (!seen && mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      _showSmartInstructionSheet();
    }
  }

  Future<void> _showSmartInstructionSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SmartInstructionSheet(),
    );
  }

  // ── REAL: pick image (unchanged backend logic) ────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker()
          .pickImage(source: source, imageQuality: 85);
      if (pickedFile != null) {
        setState(() => _isShimmering = true);
        await Future.delayed(const Duration(milliseconds: 400));
        setState(() {
          _selectedImage = File(pickedFile.path);
          _isShimmering  = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to get image");
    }
  }

  // ── REAL: upload food (unchanged backend logic) ───────────────────────────
  Future<void> _uploadFood() async {
    if (_selectedImage == null) {
      Fluttertoast.showToast(msg: "Please select an image first");
      return;
    }

    setState(() => _isUploading = true);

    try {
      final prefs   = await SharedPreferences.getInstance();
      final baseUrl = prefs.getString('url');
      final lid     = prefs.getString('lid');

      if (baseUrl == null || baseUrl.isEmpty) {
        Fluttertoast.showToast(msg: "Server URL not configured");
        setState(() => _isUploading = false);
        return;
      }

      final uri     = Uri.parse("$baseUrl/upload_food/");
      var   request = http.MultipartRequest("POST", uri);
      request.fields['lid'] = lid ?? "";
      request.files.add(
          await http.MultipartFile.fromPath("photo", _selectedImage!.path));

      final response     = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(responseBody);
        if (jsonData["status"] == "ok") {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => NutritionResultScreen(
                foodName:  jsonData["foodname"] ?? "Food",
                protein:   jsonData["protein"]  ?? "0",
                carbs:     jsonData["carbs"]    ?? "0",
                fat:       jsonData["fat"]      ?? "0",
                nutrients: jsonData["nutrients"] ?? [],
                imageFile: _selectedImage,
              ),
            ),
          );
        } else {
          Fluttertoast.showToast(
              msg: jsonData["message"] ?? "No food detected");
        }
      } else {
        Fluttertoast.showToast(msg: "Server error ${response.statusCode}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Upload failed: $e");
    } finally {
      if (mounted) setState(() => _isUploading = false);
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 28),
                      _buildHeroText(),
                      const SizedBox(height: 36),
                      _buildImageArea(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                      const SizedBox(height: 28),
                      _buildAnalyzeButton(),
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

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                Text("Snap Your Food",
                    style: TextStyle(color: _DS.textPrimary, fontSize: 18,
                        fontWeight: FontWeight.w900, letterSpacing: -0.3)),
                Text("AI-powered nutrition analysis",
                    style: TextStyle(color: _DS.textMuted, fontSize: 11)),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showSmartInstructionSheet,
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: _DS.neonFaint,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _DS.neon.withOpacity(0.3), width: 1),
              ),
              child: const Icon(Icons.lightbulb_rounded,
                  color: _DS.neon, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroText() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: _DS.neonFaint,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _DS.neon.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: _DS.neon, size: 13),
              const SizedBox(width: 6),
              Text("AI Nutrition Coach",
                  style: TextStyle(color: _DS.neon, fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text("What did you eat?",
            style: TextStyle(color: _DS.textPrimary, fontSize: 26,
                fontWeight: FontWeight.w900, letterSpacing: -0.6)),
        const SizedBox(height: 6),
        Text("Take or upload a photo for instant AI nutrition analysis",
            textAlign: TextAlign.center,
            style: TextStyle(color: _DS.textMuted, fontSize: 13, height: 1.5)),
      ],
    );
  }

  Widget _buildImageArea() {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => Container(
        height: 300,
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
              ? [BoxShadow(
              color: _DS.neon.withOpacity(_glowAnim.value * 0.18),
              blurRadius: 32, offset: const Offset(0, 6))]
              : [],
        ),
        child: _isShimmering
            ? _buildShimmer()
            : _selectedImage != null
            ? _buildPreviewThumb()
            : _buildEmptyState(),
      ),
    );
  }

  Widget _buildShimmer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Stack(
        children: [
          Container(color: _DS.surface),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: -1.0, end: 2.0),
            duration: const Duration(milliseconds: 800),
            builder: (_, val, __) => Positioned.fill(
              child: Transform.translate(
                offset: Offset(val * 400, 0),
                child: Container(
                  width: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      _DS.neon.withOpacity(0.09),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ),
          ),
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 28, height: 28,
                    child: CircularProgressIndicator(
                        color: _DS.neon, strokeWidth: 2.5)),
                SizedBox(height: 12),
                Text("Loading image...",
                    style: TextStyle(color: _DS.textMuted, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewThumb() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Image.file(_selectedImage!, fit: BoxFit.cover,
              width: double.infinity, height: double.infinity),
        ),
        Positioned(
          bottom: 12, left: 0, right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _showSourcePicker,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: _DS.bg.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _DS.borderFaint, width: 1),
                ),
                child: const Text("Tap to change photo",
                    style: TextStyle(color: _DS.textSecondary,
                        fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: _pulseAnim.value,
              child: Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _DS.neonFaint,
                  border: Border.all(
                      color: _DS.neon.withOpacity(0.4), width: 1.5),
                  boxShadow: [BoxShadow(
                      color: _DS.neon.withOpacity(0.18),
                      blurRadius: 22, spreadRadius: 2)],
                ),
                child: const Icon(Icons.add_photo_alternate_rounded,
                    color: _DS.neon, size: 40),
              ),
            ),
            const SizedBox(height: 16),
            Text("No image selected",
                style: TextStyle(color: _DS.textPrimary, fontSize: 15,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text("Use buttons below to capture or upload",
                style: TextStyle(color: _DS.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(child: _actionBtn(
          icon: Icons.camera_alt_rounded, label: "Take Photo", color: _DS.neon,
          onTap: () => _pickImage(ImageSource.camera),
        )),
        const SizedBox(width: 12),
        Expanded(child: _actionBtn(
          icon: Icons.photo_library_rounded, label: "Gallery", color: _DS.accent1,
          onTap: () => _pickImage(ImageSource.gallery),
        )),
      ],
    );
  }

  Widget _actionBtn({
    required IconData icon, required String label,
    required Color color, required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onTap(); },
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.3), width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontSize: 14,
                fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  // ── AI Glow Analyze Button ────────────────────────────────────────────────
  Widget _buildAnalyzeButton() {
    final hasImage = _selectedImage != null;

    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnim, _orbitAnim, _scanAnim]),
      builder: (_, __) {
        return GestureDetector(
          onTap: (hasImage && !_isUploading)
              ? () { HapticFeedback.mediumImpact(); _uploadFood(); }
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
                  if (hasImage && !_isUploading)
                    Container(
                      width: double.infinity,
                      height: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: _DS.neon.withOpacity(_glowAnim.value * 0.55),
                            blurRadius: 40,
                            spreadRadius: -2,
                          ),
                          BoxShadow(
                            color: _DS.neon.withOpacity(_glowAnim.value * 0.25),
                            blurRadius: 80,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),

                  // Orbit ring (rotating dashes)
                  if (hasImage && !_isUploading)
                    Transform.rotate(
                      angle: _orbitAnim.value * 2 * math.pi,
                      child: Container(
                        width: double.infinity,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _DS.neon.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                      ),
                    ),

                  // Main button body
                  Container(
                    width: double.infinity,
                    height: 68,
                    decoration: BoxDecoration(
                      gradient: hasImage && !_isUploading
                          ? LinearGradient(
                        colors: [
                          Color.lerp(_DS.neon, _DS.accent1,
                              _glowAnim.value * 0.3)!,
                          _DS.neonDim,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : const LinearGradient(
                          colors: [_DS.neonFaint, _DS.neonFaint]),
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
                          // Animated scan line sweep across button
                          if (hasImage && !_isUploading)
                            Positioned.fill(
                              child: Transform.translate(
                                offset: Offset(
                                  (_scanAnim.value * 2 - 1) *
                                      MediaQuery.of(context).size.width,
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

                          // Button content
                          _isUploading
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                  color: _DS.neon.withOpacity(0.8),
                                  strokeWidth: 2.5,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text("Analyzing...",
                                  style: TextStyle(
                                    color: _DS.neon,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.3,
                                  )),
                            ],
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Pulsing icon
                              Transform.scale(
                                scale: hasImage
                                    ? 0.92 + _glowAnim.value * 0.16
                                    : 1.0,
                                child: Icon(
                                  Icons.bolt_rounded,
                                  color: hasImage
                                      ? _DS.bg
                                      : _DS.textMuted,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Analyze Nutrition",
                                style: TextStyle(
                                  color: hasImage
                                      ? _DS.bg
                                      : _DS.textMuted,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                ),
                              ),
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
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: _DS.textMuted,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text("Change Photo",
                style: TextStyle(color: _DS.textPrimary, fontSize: 16,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            _sourceOpt(Icons.camera_alt_rounded, "Take New Photo", _DS.neon,
                    () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
            const SizedBox(height: 10),
            _sourceOpt(Icons.photo_library_rounded, "Choose from Gallery",
                _DS.accent1,
                    () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
          ],
        ),
      ),
    );
  }

  Widget _sourceOpt(IconData icon, String label, Color c, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: c, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: c, fontSize: 14,
                fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  2. SMART INSTRUCTION SHEET (first-time only)                            ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class _SmartInstructionSheet extends StatefulWidget {
  const _SmartInstructionSheet();
  @override
  State<_SmartInstructionSheet> createState() => _SmartInstructionSheetState();
}

class _SmartInstructionSheetState extends State<_SmartInstructionSheet>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;
  late Animation<double>   _slideAnim;
  late Animation<double>   _fadeAnim;

  final _tips = [
    ['💡', 'Good Lighting',  'Bright, even light improves food detection accuracy.'],
    ['🍽', 'Show Full Meal', 'Include all dishes, sides, and drinks in the frame.'],
    ['🔍', 'Avoid Clutter',  'Remove unrelated objects; keep background clean.'],
    ['📷', 'Keep Steady',    'Blurry or shaky photos reduce AI confidence.'],
  ];
  final List<bool> _ticked = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 450));
    _slideAnim = Tween<double>(begin: 60.0, end: 0.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    for (int i = 0; i < _tips.length; i++) {
      Future.delayed(Duration(milliseconds: 280 + i * 140), () {
        if (mounted) setState(() => _ticked[i] = true);
      });
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _dismiss({bool dontShow = false}) async {
    if (dontShow) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('snap_tips_seen', true);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: _fadeAnim.value,
        child: Transform.translate(
            offset: Offset(0, _slideAnim.value), child: child),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _DS.bgCard,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _DS.neon.withOpacity(0.2), width: 1.2),
          boxShadow: [BoxShadow(
              color: _DS.neon.withOpacity(0.1),
              blurRadius: 32, offset: const Offset(0, -4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: _DS.textMuted,
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _DS.neonFaint,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _DS.neon.withOpacity(0.3), width: 1),
                  ),
                  child: const Icon(Icons.camera_enhance_rounded,
                      color: _DS.neon, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("📸 Capture Smart for Better Accuracy",
                        style: TextStyle(color: _DS.textPrimary, fontSize: 14,
                            fontWeight: FontWeight.w900)),
                    Text("Better photos = higher AI accuracy",
                        style: TextStyle(color: _DS.textMuted, fontSize: 11)),
                  ],
                )),
              ],
            ),
            const SizedBox(height: 20),

            ...List.generate(_tips.length, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: _ticked[i]
                      ? _DS.neon.withOpacity(0.06) : _DS.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _ticked[i]
                        ? _DS.neon.withOpacity(0.3) : _DS.borderFaint,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(_tips[i][0],
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_tips[i][1],
                            style: TextStyle(color: _DS.textPrimary,
                                fontSize: 13, fontWeight: FontWeight.w700)),
                        Text(_tips[i][2],
                            style: TextStyle(color: _DS.textMuted,
                                fontSize: 11, height: 1.4)),
                      ],
                    )),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: _ticked[i]
                          ? const Icon(Icons.check_circle_rounded,
                          color: _DS.neon, size: 20, key: ValueKey('t'))
                          : const SizedBox(width: 20, key: ValueKey('e')),
                    ),
                  ],
                ),
              ),
            )),

            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _DS.accent5.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _DS.accent5.withOpacity(0.2), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded,
                      color: _DS.accent5, size: 15),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                      "AI confidence improves with clear, well-lit photos.",
                      style: TextStyle(color: _DS.accent5, fontSize: 11,
                          fontWeight: FontWeight.w600, height: 1.4))),
                ],
              ),
            ),
            const SizedBox(height: 20),

            GestureDetector(
              onTap: () => _dismiss(),
              child: Container(
                width: double.infinity, height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_DS.neon, _DS.neonDim],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                      color: _DS.neon.withOpacity(0.3),
                      blurRadius: 16, offset: const Offset(0, 4))],
                ),
                child: Center(child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.camera_alt_rounded,
                        color: _DS.bg, size: 18),
                    const SizedBox(width: 8),
                    Text("Got it, Open Camera",
                        style: TextStyle(color: _DS.bg, fontSize: 15,
                            fontWeight: FontWeight.w900)),
                  ],
                )),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _dismiss(dontShow: true),
              child: Center(child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text("Don't show again",
                    style: TextStyle(color: _DS.textMuted, fontSize: 13,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: _DS.textMuted)),
              )),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 4),
          ],
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  3. NUTRITION RESULT SCREEN  (with dynamic user goals)                   ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class NutritionResultScreen extends StatefulWidget {
  final String foodName;
  final String protein;
  final String carbs;
  final String fat;
  final List   nutrients;
  final File?  imageFile;

  const NutritionResultScreen({
    super.key,
    required this.foodName,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.nutrients,
    this.imageFile,
  });

  @override
  State<NutritionResultScreen> createState() =>
      _NutritionResultScreenState();
}

class _NutritionResultScreenState extends State<NutritionResultScreen>
    with TickerProviderStateMixin {

  late AnimationController _entryCtrl;
  late AnimationController _barCtrl;
  late AnimationController _glowCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _slideAnim;
  late Animation<double>   _barAnim;
  late Animation<double>   _glowAnim;

  bool _saved = false;

  // User's actual calorie goal from health profile (will be loaded dynamically)
  double _userCalorieGoal = 2000; // Default fallback
  double _userProteinGoal = 50;   // Default fallback
  double _userCarbsGoal = 275;    // Default fallback
  double _userFatGoal = 78;       // Default fallback

  bool _isLoadingGoals = true;

  // ── Real API values ───────────────────────────────────────────────────────
  double get _protein  => double.tryParse(widget.protein) ?? 0;
  double get _carbs    => double.tryParse(widget.carbs)   ?? 0;
  double get _fat      => double.tryParse(widget.fat)     ?? 0;
  double get _calories => (_protein * 4) + (_carbs * 4) + (_fat * 9);

  @override
  void initState() {
    super.initState();
    _loadUserGoals();

    _entryCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 800));
    _fadeAnim  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: 28.0, end: 0.0).animate(
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _barCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1100));
    _barAnim = CurvedAnimation(parent: _barCtrl, curve: Curves.easeOutCubic);

    _glowCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 2400))..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.2, end: 0.75).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _entryCtrl.forward();
    Future.delayed(
        const Duration(milliseconds: 350), () => _barCtrl.forward());
  }

  Future<void> _loadUserGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final baseUrl = prefs.getString('url') ?? '';
      final lid = prefs.getString('lid') ?? '';

      // Try to get from SharedPreferences first (fast)
      String? calorieTarget = prefs.getString('calorie_target');
      String? proteinGoal = prefs.getString('protein_goal');
      String? carbsGoal = prefs.getString('carbs_goal');
      String? fatGoal = prefs.getString('fat_goal');

      setState(() {
        if (calorieTarget != null && calorieTarget.isNotEmpty) {
          _userCalorieGoal = double.tryParse(calorieTarget) ?? 2000;
        }
        if (proteinGoal != null && proteinGoal.isNotEmpty) {
          _userProteinGoal = double.tryParse(proteinGoal) ?? 50;
        }
        if (carbsGoal != null && carbsGoal.isNotEmpty) {
          _userCarbsGoal = double.tryParse(carbsGoal) ?? 275;
        }
        if (fatGoal != null && fatGoal.isNotEmpty) {
          _userFatGoal = double.tryParse(fatGoal) ?? 78;
        }
      });

      // Fetch from API to get latest values
      if (baseUrl.isNotEmpty && lid.isNotEmpty) {
        final response = await http.post(
          Uri.parse('$baseUrl/userviewhishealth/'),
          body: {'lid': lid},
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'ok') {
            setState(() {
              _userCalorieGoal = double.tryParse(data['healthvalue']?.toString() ?? '2000') ?? 2000;
              _userProteinGoal = double.tryParse(data['protienvalue']?.toString() ?? '50') ?? 50;
              _userCarbsGoal = double.tryParse(data['carbvalue']?.toString() ?? '275') ?? 275;
              _userFatGoal = double.tryParse(data['fatvalue']?.toString() ?? '78') ?? 78;

              // Save to SharedPreferences for faster access next time
              prefs.setString('calorie_target', _userCalorieGoal.toString());
              prefs.setString('protein_goal', _userProteinGoal.toString());
              prefs.setString('carbs_goal', _userCarbsGoal.toString());
              prefs.setString('fat_goal', _userFatGoal.toString());
            });
          }
        }
      }
    } catch (e) {
      print('Error loading user goals: $e');
      // Keep default values if API fails
    } finally {
      setState(() {
        _isLoadingGoals = false;
      });
    }
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _barCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  Color get _calorieColor {
    final pct = _calories / _userCalorieGoal;
    if (pct >= 1.0) return _DS.accent3;
    if (pct >= 0.7) return _DS.accent4;
    return _DS.neon;
  }

  String get _calorieStatus {
    final pct = _calories / _userCalorieGoal;
    if (pct >= 1.0) return "⚠ Exceeds daily goal";
    if (pct >= 0.9) return "⚠ Close to daily limit";
    if (pct >= 0.7) return "Moderate impact";
    return "Light impact";
  }

  // ── Navigate to calorie dashboard ─────────────────────────────────────────
  Future<void> _saveAndGoHome() async {
    HapticFeedback.mediumImpact();
    setState(() => _saved = true);

    Fluttertoast.showToast(
      msg: "✓ Added successfully to today's intake.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: _DS.neonFaint,
      textColor: _DS.neon,
    );

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    // Navigate back to UserHome (calorie dashboard)
    // Uses pushAndRemoveUntil to clear the upload stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const UserHome()),
          (route) => false,
    );
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
                child: AnimatedBuilder(
                  animation: _entryCtrl,
                  builder: (_, child) => Opacity(
                    opacity: _fadeAnim.value,
                    child: Transform.translate(
                        offset: Offset(0, _slideAnim.value), child: child),
                  ),
                  child: _isLoadingGoals
                      ? _buildLoadingIndicator()
                      : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                    child: Column(
                      children: [
                        // Food image (if available)
                        if (widget.imageFile != null) ...[
                          _buildFoodImage(),
                          const SizedBox(height: 16),
                        ],
                        _buildCalorieSummary(),
                        const SizedBox(height: 16),
                        _buildMacroCard(),
                        const SizedBox(height: 16),
                        if (widget.nutrients.isNotEmpty) ...[
                          _buildNutrientList(),
                          const SizedBox(height: 16),
                        ],
                        _buildSaveButton(),
                        const SizedBox(height: 40),
                      ],
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

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40, height: 40,
            child: CircularProgressIndicator(
              color: _DS.neon,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Loading your personalized goals...",
            style: TextStyle(
              color: _DS.textMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                Text(widget.foodName,
                    style: TextStyle(color: _DS.textPrimary, fontSize: 17,
                        fontWeight: FontWeight.w900, letterSpacing: -0.3),
                    overflow: TextOverflow.ellipsis),
                Text("Nutrition Analysis",
                    style: TextStyle(color: _DS.textMuted, fontSize: 11)),
              ],
            ),
          ),
          // Neon AI badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _DS.neonFaint,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _DS.neon.withOpacity(0.35), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: _DS.neon, size: 12),
                const SizedBox(width: 5),
                Text("AI Result",
                    style: TextStyle(color: _DS.neon, fontSize: 10,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Food image thumbnail ──────────────────────────────────────────────────
  Widget _buildFoodImage() {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: _DS.neon.withOpacity(0.3), width: 1.5),
          boxShadow: [BoxShadow(
              color: _DS.neon.withOpacity(_glowAnim.value * 0.15),
              blurRadius: 24, offset: const Offset(0, 6))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Image.file(widget.imageFile!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity),
        ),
      ),
    );
  }

  // ── Calorie summary card ──────────────────────────────────────────────────
  Widget _buildCalorieSummary() {
    final calPct = (_calories / _userCalorieGoal).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _DS.bgCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: _calorieColor.withOpacity(0.25), width: 1.2),
          boxShadow: [BoxShadow(
              color: _calorieColor.withOpacity(_glowAnim.value * 0.14),
              blurRadius: 24, offset: const Offset(0, 6))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Big calorie number
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _calorieColor.withOpacity(0.1),
                    border: Border.all(
                        color: _calorieColor.withOpacity(0.45), width: 2),
                    boxShadow: [BoxShadow(
                        color: _calorieColor.withOpacity(
                            _glowAnim.value * 0.4),
                        blurRadius: 18, spreadRadius: 2)],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_calories.toStringAsFixed(0),
                            style: TextStyle(color: _calorieColor,
                                fontSize: 20, fontWeight: FontWeight.w900)),
                        Text("kcal",
                            style: TextStyle(
                                color: _calorieColor.withOpacity(0.7),
                                fontSize: 10, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.foodName,
                          style: TextStyle(color: _DS.textPrimary,
                              fontSize: 16, fontWeight: FontWeight.w900),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      _inlinePill(
                          "${(_calories / _userCalorieGoal * 100).toStringAsFixed(0)}% of daily goal",
                          _calorieColor),
                      const SizedBox(height: 6),
                      _inlinePill(
                          _calorieStatus,
                          _calories >= _userCalorieGoal
                              ? _DS.accent3 : _DS.neon),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Calorie progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Daily Calorie Goal",
                        style: TextStyle(color: _DS.textMuted,
                            fontSize: 11, fontWeight: FontWeight.w600)),
                    Text("${_calories.toStringAsFixed(0)} / "
                        "${_userCalorieGoal.toStringAsFixed(0)} kcal",
                        style: TextStyle(color: _calorieColor,
                            fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Container(height: 12, color: _DS.surface),
                      AnimatedBuilder(
                        animation: _barAnim,
                        builder: (_, __) => FractionallySizedBox(
                          widthFactor: calPct * _barAnim.value,
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                _DS.neon.withOpacity(0.7),
                                _calorieColor,
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _inlinePill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Text(text,
          style: TextStyle(color: color, fontSize: 10,
              fontWeight: FontWeight.w700)),
    );
  }

  // ── Macro card (protein ring + carbs/fat bars) ────────────────────────────
  Widget _buildMacroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _DS.borderFaint, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("Macronutrients",
              Icons.bar_chart_rounded, _DS.accent1),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Protein ring
              Column(
                children: [
                  AnimatedBuilder(
                    animation: _barAnim,
                    builder: (_, __) => SizedBox(
                      width: 88, height: 88,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 88, height: 88,
                            child: CircularProgressIndicator(
                              value: (_protein / _userProteinGoal * _barAnim.value)
                                  .clamp(0.0, 1.0),
                              strokeWidth: 8,
                              backgroundColor: _DS.surface,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  _DS.accent1),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("${_protein.toStringAsFixed(1)}g",
                                  style: const TextStyle(color: _DS.accent1,
                                      fontSize: 13, fontWeight: FontWeight.w900)),
                              const Text("Protein",
                                  style: TextStyle(color: _DS.textMuted,
                                      fontSize: 9, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text("${(_protein / _userProteinGoal * 100).toStringAsFixed(0)}% DRI",
                      style: const TextStyle(color: _DS.textMuted,
                          fontSize: 9, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _macroBar("Carbohydrates", _carbs,
                        _userCarbsGoal, _DS.accent4),
                    const SizedBox(height: 14),
                    _macroBar("Fat", _fat, _userFatGoal, _DS.accent3),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroBar(String label, double val, double goal, Color color) {
    final pct = (val / goal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: _DS.textSecondary,
                fontSize: 12, fontWeight: FontWeight.w700)),
            Text("${val.toStringAsFixed(1)}g",
                style: TextStyle(color: color, fontSize: 12,
                    fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              Container(height: 10, color: _DS.surface),
              AnimatedBuilder(
                animation: _barAnim,
                builder: (_, __) => FractionallySizedBox(
                  widthFactor: pct * _barAnim.value,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        color.withOpacity(0.65), color,
                      ]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Text("${(pct * 100).toStringAsFixed(0)}% of daily recommended",
            style: const TextStyle(color: _DS.textMuted, fontSize: 9)),
      ],
    );
  }

  // ── Full nutrient list (real API data) ─────────────────────────────────────
  Widget _buildNutrientList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _DS.borderFaint, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("Full Nutrient Details",
              Icons.list_alt_rounded, _DS.accent2),
          const SizedBox(height: 14),
          ...widget.nutrients.map<Widget>((n) => Container(
            margin: const EdgeInsets.only(bottom: 2),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: _DS.borderFaint.withOpacity(0.5), width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                      color: _DS.neon.withOpacity(0.5),
                      shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(n["nutrientName"] ?? "",
                      style: const TextStyle(color: _DS.textSecondary,
                          fontSize: 13, fontWeight: FontWeight.w500)),
                ),
                Text("${n["value"]} ${n["unitName"]}",
                    style: const TextStyle(color: _DS.textPrimary,
                        fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  // ── Save → Dashboard button ────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => GestureDetector(
        onTap: _saved ? null : _saveAndGoHome,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            gradient: _saved
                ? const LinearGradient(
                colors: [_DS.neonFaint, _DS.neonFaint])
                : const LinearGradient(
                colors: [_DS.neon, _DS.neonDim],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(22),
            boxShadow: _saved
                ? []
                : [
              BoxShadow(
                color: _DS.neon
                    .withOpacity(_glowAnim.value * 0.5),
                blurRadius: 30,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: _DS.neon
                    .withOpacity(_glowAnim.value * 0.2),
                blurRadius: 60,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: _saved
                  ? _DS.neon.withOpacity(0.25)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _saved
                    ? Icons.check_circle_rounded
                    : Icons.dashboard_rounded,
                color: _saved ? _DS.neon : _DS.bg,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                _saved
                    ? "Saved! Opening Dashboard..."
                    : "Save & Go to Dashboard",
                style: TextStyle(
                  color: _saved ? _DS.neon : _DS.bg,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.25), width: 1),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(color: _DS.textPrimary, fontSize: 15,
                fontWeight: FontWeight.w900, letterSpacing: -0.2)),
      ],
    );
  }
}