// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'dart:math' as math;
// import 'package:http/http.dart' as http;
// import 'foodupload.dart';
// import 'viewProfile.dart';
// import 'uploadFood.dart';
// import 'changePassword.dart';
// import 'healthProfile.dart';
// import 'viewHealth.dart';
// import 'login/src/loginPage.dart';
// import 'feedBack.dart';
// import 'chatbot.dart';
// import 'ingredients.dart';
// import 'suggestion.dart';
//
// void main() {
//   runApp(const MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: UserHome(),
//   ));
// }
//
// // ══════════════════════════════════════════════════════════════════════════════
// //  DESIGN TOKENS
// // ══════════════════════════════════════════════════════════════════════════════
// class _DS {
//   static const bg         = Color(0xFF050D0A);
//   static const bgCard     = Color(0xFF0C1A13);
//   static const bgCardAlt  = Color(0xFF0A1510);
//   static const surface    = Color(0xFF0F2018);
//   static const surfaceAlt = Color(0xFF122318);
//
//   static const neon      = Color(0xFF00FF88);
//   static const neonDim   = Color(0xFF00C46A);
//   static const neonFaint = Color(0xFF003D22);
//
//   static const accent1 = Color(0xFF00E5FF);
//   static const accent2 = Color(0xFFB2FF59);
//   static const accent3 = Color(0xFFFF6B6B);
//   static const accent4 = Color(0xFFFFD166);
//   static const accent5 = Color(0xFFA78BFA);
//
//   static const textPrimary   = Color(0xFFF0FFF8);
//   static const textSecondary = Color(0xFF6EE7B7);
//   static const textMuted     = Color(0xFF2E6B4A);
//
//   // Reduced border opacity for friendlier look
//   static const borderFaint = Color(0xFF112B1E);
// }
//
// // ══════════════════════════════════════════════════════════════════════════════
// //  SETTINGS SCREEN
// // ══════════════════════════════════════════════════════════════════════════════
// class _SettingsScreen extends StatelessWidget {
//   const _SettingsScreen();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _DS.bg,
//       appBar: AppBar(
//         backgroundColor: _DS.bg,
//         elevation: 0,
//         leading: GestureDetector(
//           onTap: () {
//
//           },
//           child: Container(
//             margin: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: _DS.surface,
//               shape: BoxShape.circle,
//               border: Border.all(color: _DS.borderFaint, width: 1),
//             ),
//             child: const Icon(Icons.arrow_back_rounded, color: _DS.neon, size: 20),
//           ),
//         ),
//         title: const Text(
//           "Settings",
//           style: TextStyle(
//               color: _DS.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w900,
//               letterSpacing: -0.3),
//         ),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           _SettingsTile(
//             icon: Icons.person_rounded,
//             label: "View Profile",
//             subtitle: "Edit your personal information",
//             color: _DS.accent5,
//             onTap: () => Navigator.push(
//                 context, MaterialPageRoute(builder: (_) => const ViewProfilePage())),
//           ),
//           const SizedBox(height: 12),
//           _SettingsTile(
//             icon: Icons.lock_reset_rounded,
//             label: "Change Password",
//             subtitle: "Update your account password",
//             color: _DS.accent1,
//             onTap: () => Navigator.push(
//                 context, MaterialPageRoute(builder: (_) => const ChangePasswordPage())),
//           ),
//           const SizedBox(height: 12),
//           _SettingsTile(
//             icon: Icons.rate_review_rounded,
//             label: "Feedback",
//             subtitle: "Share your thoughts with us",
//             color: _DS.accent3,
//             onTap: () => Navigator.push(
//                 context, MaterialPageRoute(builder: (_) => const FeedbackScreen())),
//           ),
//           _SettingsTile(
//             icon: Icons.rate_review_rounded,
//             label: "Check",
//             subtitle: "check food",
//             color: _DS.accent3,
//             onTap: () => Navigator.push(
//                 context, MaterialPageRoute(builder: (_) => const FoodUploadScreen(title: '',))),
//           ),
//           const SizedBox(height: 32),
//           Container(height: 1, color: _DS.borderFaint),
//           const SizedBox(height: 24),
//           _SettingsTile(
//             icon: Icons.logout_rounded,
//             label: "Logout",
//             subtitle: "Sign out of your account",
//             color: _DS.textMuted,
//             onTap: () async {
//               final prefs = await SharedPreferences.getInstance();
//               await prefs.clear();
//               if (!context.mounted) return;
//               Navigator.pushReplacement(
//                   context, MaterialPageRoute(builder: (_) => LoginPage()));
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _SettingsTile extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String subtitle;
//   final Color color;
//   final VoidCallback onTap;
//
//   const _SettingsTile({
//     required this.icon,
//     required this.label,
//     required this.subtitle,
//     required this.color,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         onTap();
//       },
//       child: Container(
//         padding: const EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           color: _DS.bgCard,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: color.withOpacity(0.15), width: 1),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: Icon(icon, color: color, size: 20),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(label,
//                       style: const TextStyle(
//                           color: _DS.textPrimary,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w800)),
//                   const SizedBox(height: 2),
//                   Text(subtitle,
//                       style: const TextStyle(
//                           color: _DS.textMuted,
//                           fontSize: 11,
//                           fontWeight: FontWeight.w500)),
//                 ],
//               ),
//             ),
//             const Icon(Icons.chevron_right_rounded, color: _DS.textMuted, size: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ══════════════════════════════════════════════════════════════════════════════
// //  INSIGHTS SCREEN
// // ══════════════════════════════════════════════════════════════════════════════
// class _InsightsScreen extends StatelessWidget {
//   final int caloriesToday;
//   final int caloriesGoal;
//   final int proteinToday;
//   final int proteinGoal;
//   final int carbsToday;
//   final int carbsGoal;
//   final int fatToday;
//   final int fatGoal;
//   final int streakDays;
//   final List<Map<String, dynamic>> insights;
//
//   const _InsightsScreen({
//     required this.caloriesToday,
//     required this.caloriesGoal,
//     required this.proteinToday,
//     required this.proteinGoal,
//     required this.carbsToday,
//     required this.carbsGoal,
//     required this.fatToday,
//     required this.fatGoal,
//     required this.streakDays,
//     required this.insights,
//   });
//
//   Color get _ringColor {
//     if (caloriesGoal <= 0) return _DS.neon;
//     final p = caloriesToday / caloriesGoal;
//     if (p > 1.0) return _DS.accent3;
//     if (p >= 0.8) return _DS.accent4;
//     return _DS.neon;
//   }
//
//   Color _macroStatusColor(int cur, int goal) {
//     if (goal <= 0) return _DS.textMuted;
//     final p = cur / goal;
//     if (p < 0.5) return _DS.accent4;
//     if (p > 1.1) return _DS.accent3;
//     return _DS.neon;
//   }
//
//   String _macroStatusLabel(int cur, int goal) {
//     if (goal <= 0) return "—";
//     final p = cur / goal;
//     if (p < 0.5) return "Low";
//     if (p > 1.1) return "Excess";
//     return "Optimal";
//   }
//
//   bool get _hasHealthAlerts =>
//       (carbsGoal > 0 && carbsToday / carbsGoal > 1.1) ||
//           (proteinGoal > 0 && proteinToday / proteinGoal < 0.4) ||
//           (fatGoal > 0 && fatToday / fatGoal > 1.1);
//
//   @override
//   Widget build(BuildContext context) {
//     final pct       = caloriesGoal > 0 ? (caloriesToday / caloriesGoal) : 0.0;
//     final remaining = caloriesGoal - caloriesToday;
//     final isOver    = pct > 1.0;
//
//     return Scaffold(
//       backgroundColor: _DS.bg,
//       appBar: AppBar(
//         backgroundColor: _DS.bg,
//         elevation: 0,
//         leading: GestureDetector(
//           onTap: () => Navigator.pop(context),
//           child: Container(
//             margin: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: _DS.surface,
//               shape: BoxShape.circle,
//               border: Border.all(color: _DS.borderFaint, width: 1),
//             ),
//             child: const Icon(Icons.arrow_back_rounded, color: _DS.neon, size: 20),
//           ),
//         ),
//         title: const Text(
//           "Nutrition Insights",
//           style: TextStyle(
//               color: _DS.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w900,
//               letterSpacing: -0.3),
//         ),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.fromLTRB(18, 4, 18, 48),
//         children: [
//           Container(
//             padding: const EdgeInsets.all(22),
//             decoration: BoxDecoration(
//               color: _DS.bgCard,
//               borderRadius: BorderRadius.circular(28),
//               border: Border.all(
//                   color: _ringColor.withOpacity(isOver ? 0.35 : 0.18), width: 1),
//               boxShadow: [
//                 BoxShadow(
//                     color: _ringColor.withOpacity(0.06),
//                     blurRadius: 20,
//                     offset: const Offset(0, 4))
//               ],
//             ),
//             child: Row(
//               children: [
//                 SizedBox(
//                   width: 110,
//                   height: 110,
//                   child: Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       CircularProgressIndicator(
//                         value: pct.clamp(0.0, 1.0),
//                         strokeWidth: 10,
//                         backgroundColor: _ringColor.withOpacity(0.1),
//                         valueColor: AlwaysStoppedAnimation(_ringColor),
//                         strokeCap: StrokeCap.round,
//                       ),
//                       Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text("${(pct * 100).toInt()}%",
//                               style: TextStyle(
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.w900,
//                                   color: _ringColor)),
//                           const Text("of goal",
//                               style: TextStyle(fontSize: 9, color: _DS.textMuted)),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 20),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text("Daily Calories",
//                           style: TextStyle(
//                               color: _DS.textMuted,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               letterSpacing: 0.5)),
//                       const SizedBox(height: 6),
//                       RichText(
//                         text: TextSpan(children: [
//                           TextSpan(
//                             text: "$caloriesToday",
//                             style: const TextStyle(
//                                 fontSize: 32,
//                                 fontWeight: FontWeight.w900,
//                                 color: _DS.textPrimary,
//                                 letterSpacing: -1.5),
//                           ),
//                           TextSpan(
//                             text: " / $caloriesGoal kcal",
//                             style: const TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w500,
//                                 color: _DS.textMuted),
//                           ),
//                         ]),
//                       ),
//                       const SizedBox(height: 10),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 5),
//                         decoration: BoxDecoration(
//                           color: _ringColor.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(
//                               color: _ringColor.withOpacity(0.2), width: 1),
//                         ),
//                         child: Text(
//                           isOver
//                               ? "Over by ${remaining.abs()} kcal ⚠"
//                               : remaining > 0
//                               ? "$remaining kcal remaining"
//                               : "Goal Achieved 🎉",
//                           style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w700,
//                               color: _ringColor),
//                         ),
//                       ),
//                       if (streakDays > 0) ...[
//                         const SizedBox(height: 8),
//                         Row(children: [
//                           const Icon(Icons.local_fire_department,
//                               size: 13, color: _DS.accent3),
//                           const SizedBox(width: 4),
//                           Text("$streakDays-day streak",
//                               style: const TextStyle(
//                                   color: _DS.accent3,
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w700)),
//                         ]),
//                       ],
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 22),
//
//           if (_hasHealthAlerts) ...[
//             _sectionLabel("Health Alerts", Icons.warning_amber_rounded, _DS.accent3),
//             const SizedBox(height: 12),
//             _buildHealthAlertsCarousel(),
//             const SizedBox(height: 22),
//           ],
//
//           _sectionLabel("Macronutrients", Icons.pie_chart_rounded, _DS.accent1),
//           const SizedBox(height: 12),
//           _macroBar("Protein", proteinToday, proteinGoal,
//               const Color(0xFFF97316), Icons.fitness_center_rounded),
//           const SizedBox(height: 10),
//           _macroBar("Carbs", carbsToday, carbsGoal,
//               const Color(0xFF3B82F6), Icons.bolt_rounded),
//           const SizedBox(height: 10),
//           _macroBar("Fats", fatToday, fatGoal,
//               const Color(0xFFA855F7), Icons.opacity_rounded),
//           const SizedBox(height: 22),
//
//           _sectionLabel("AI Insights", Icons.auto_awesome_rounded, _DS.neon),
//           const SizedBox(height: 12),
//           _buildInsightsCarousel(),
//           const SizedBox(height: 22),
//
//           _sectionLabel("Weekly Snapshot", Icons.insights_rounded, _DS.accent1),
//           const SizedBox(height: 12),
//           _buildWeeklySnapshot(),
//           const SizedBox(height: 22),
//
//           _sectionLabel("Suggested for You", Icons.restaurant_menu_rounded, _DS.accent2),
//           const SizedBox(height: 12),
//           _MealSuggestionCard(
//             carbsToday: carbsToday,
//             carbsGoal: carbsGoal,
//             proteinToday: proteinToday,
//             proteinGoal: proteinGoal,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _sectionLabel(String title, IconData icon, Color color) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(6),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: color.withOpacity(0.15), width: 1),
//           ),
//           child: Icon(icon, size: 15, color: color),
//         ),
//         const SizedBox(width: 10),
//         Text(title,
//             style: const TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w900,
//                 color: _DS.textPrimary,
//                 letterSpacing: -0.3)),
//       ],
//     );
//   }
//
//   Widget _buildHealthAlertsCarousel() {
//     final alerts = <Map<String, dynamic>>[];
//     if (carbsGoal > 0 && carbsToday / carbsGoal > 1.1)
//       alerts.add({
//         'title': 'Carb Overload',
//         'suggestion': 'Reduce refined carbs today',
//         'color': _DS.accent3,
//         'icon': Icons.bolt_rounded,
//       });
//     if (proteinGoal > 0 && proteinToday / proteinGoal < 0.4)
//       alerts.add({
//         'title': 'Low Protein',
//         'suggestion': 'Add a protein-rich meal soon',
//         'color': _DS.accent4,
//         'icon': Icons.fitness_center_rounded,
//       });
//     if (fatGoal > 0 && fatToday / fatGoal > 1.1)
//       alerts.add({
//         'title': 'Fat Excess',
//         'suggestion': 'Avoid fried or oily foods',
//         'color': _DS.accent4,
//         'icon': Icons.opacity_rounded,
//       });
//
//     return SizedBox(
//       height: 92,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         physics: const BouncingScrollPhysics(),
//         itemCount: alerts.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 10),
//         itemBuilder: (_, i) {
//           final a = alerts[i];
//           final c = a['color'] as Color;
//           return Container(
//             width: 200,
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: _DS.bgCard,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: c.withOpacity(0.2), width: 1),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                     width: 6,
//                     height: 48,
//                     decoration: BoxDecoration(
//                         color: c, borderRadius: BorderRadius.circular(4))),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Row(children: [
//                         Icon(a['icon'] as IconData, size: 13, color: c),
//                         const SizedBox(width: 4),
//                         Text(a['title'] as String,
//                             style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w800,
//                                 color: c)),
//                       ]),
//                       const SizedBox(height: 4),
//                       Text(a['suggestion'] as String,
//                           style: const TextStyle(
//                               fontSize: 11, color: _DS.textMuted, height: 1.3)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _macroBar(
//       String label, int current, int goal, Color color, IconData icon) {
//     final progress    = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
//     final statusColor = _macroStatusColor(current, goal);
//     final statusLabel = _macroStatusLabel(current, goal);
//     final pct         = goal > 0 ? (current / goal * 100).toInt() : 0;
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: _DS.bgCard,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: color.withOpacity(0.1), width: 1),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(7),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, size: 16, color: color),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(label,
//                         style: const TextStyle(
//                             color: _DS.textPrimary,
//                             fontSize: 13,
//                             fontWeight: FontWeight.w700)),
//                     Row(children: [
//                       Text("$current/$goal g",
//                           style: const TextStyle(
//                               color: _DS.textMuted,
//                               fontSize: 11,
//                               fontWeight: FontWeight.w500)),
//                       const SizedBox(width: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 7, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: statusColor.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                               color: statusColor.withOpacity(0.2), width: 1),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Container(
//                                 width: 5,
//                                 height: 5,
//                                 decoration: BoxDecoration(
//                                     color: statusColor,
//                                     shape: BoxShape.circle)),
//                             const SizedBox(width: 4),
//                             Text(statusLabel,
//                                 style: TextStyle(
//                                     color: statusColor,
//                                     fontSize: 9,
//                                     fontWeight: FontWeight.w800)),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 6),
//                       Text("$pct%",
//                           style: TextStyle(
//                               color: color,
//                               fontSize: 13,
//                               fontWeight: FontWeight.w800)),
//                     ]),
//                   ],
//                 ),
//                 const SizedBox(height: 7),
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(6),
//                   child: LinearProgressIndicator(
//                     value: progress,
//                     backgroundColor: color.withOpacity(0.1),
//                     valueColor: AlwaysStoppedAnimation(statusColor),
//                     minHeight: 6,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInsightsCarousel() {
//     return SizedBox(
//       height: 112,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         physics: const BouncingScrollPhysics(),
//         itemCount: insights.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (_, index) {
//           final insight = insights[index];
//           final c       = insight['color'] as Color;
//           return Container(
//             width: 220,
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: _DS.bgCard,
//               borderRadius: BorderRadius.circular(22),
//               border: Border.all(color: c.withOpacity(0.18), width: 1),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(9),
//                   decoration: BoxDecoration(
//                     color: c.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(insight['icon'] as IconData, color: c, size: 20),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(insight['title'] as String,
//                           style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w800,
//                               color: c),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis),
//                       const SizedBox(height: 4),
//                       Text(insight['message'] as String,
//                           style: const TextStyle(
//                               fontSize: 11,
//                               color: _DS.textMuted,
//                               height: 1.35),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildWeeklySnapshot() {
//     final mockData = [
//       0.60, 0.80, 0.75, 0.90, 0.70, 0.85,
//       caloriesGoal > 0
//           ? (caloriesToday / caloriesGoal).clamp(0.0, 1.0)
//           : 0.0,
//     ];
//     const days  = ["M", "T", "W", "T", "F", "S", "S"];
//     final today = DateTime.now().weekday - 1;
//
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: _DS.bgCard,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: _DS.accent1.withOpacity(0.12), width: 1),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: List.generate(7, (i) {
//               final val     = i < mockData.length ? mockData[i] : 0.0;
//               final isToday = i == today;
//               return Column(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   if (isToday)
//                     Container(
//                         width: 5,
//                         height: 5,
//                         decoration: const BoxDecoration(
//                             color: _DS.neon, shape: BoxShape.circle))
//                   else
//                     const SizedBox(height: 5),
//                   const SizedBox(height: 3),
//                   AnimatedContainer(
//                     duration: const Duration(milliseconds: 700),
//                     curve: Curves.easeOutBack,
//                     width: 28,
//                     height: (val * 64).clamp(6.0, 64.0),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.bottomCenter,
//                         end: Alignment.topCenter,
//                         colors: isToday
//                             ? [_DS.neonDim, _DS.neon]
//                             : [_DS.neonFaint, _DS.neon.withOpacity(0.25)],
//                       ),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     days[i],
//                     style: TextStyle(
//                       fontSize: 11,
//                       fontWeight:
//                       isToday ? FontWeight.w900 : FontWeight.w500,
//                       color: isToday ? _DS.neon : _DS.textMuted,
//                     ),
//                   ),
//                 ],
//               );
//             }),
//           ),
//           const SizedBox(height: 16),
//           Container(height: 1, color: _DS.borderFaint),
//           const SizedBox(height: 14),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _sparkStat(
//                   "Avg Cal", "${(caloriesToday * 0.9).toInt()} kcal", _DS.neon),
//               _sparkStat("Best Day", "Day ${today + 1}", _DS.accent1),
//               _sparkStat("Streak", "$streakDays days", _DS.accent3),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   Future<List<double>> fetchWeeklyCalories() async {
//
//     final prefs = await SharedPreferences.getInstance();
//     final baseUrl = prefs.getString('url') ?? '';
//     final lid = prefs.getString('lid') ?? '';
//
//     final response = await http.post(
//       Uri.parse('$baseUrl/find_daily_intake/'),
//       body: {"lid": lid},
//     );
//
//     final data = jsonDecode(response.body);
//
//     if (data["status"] == "ok") {
//
//       List week = data["week_data"];
//
//       return week.map<double>((d) {
//         double cal = (d["calories"] ?? 0).toDouble();
//         return (cal / caloriesGoal).clamp(0.0, 1.0);
//       }).toList();
//     }
//
//     return [];
//   }
//
//   Widget _sparkStat(String label, String value, Color color) => Column(
//     children: [
//       Text(value,
//           style: TextStyle(
//               fontSize: 14, fontWeight: FontWeight.w900, color: color)),
//       const SizedBox(height: 2),
//       Text(label,
//           style: const TextStyle(
//               fontSize: 10,
//               color: _DS.textMuted,
//               fontWeight: FontWeight.w500)),
//     ],
//   );
// }
//
// // ══════════════════════════════════════════════════════════════════════════════
// //  HOME  SCREEN
// // ══════════════════════════════════════════════════════════════════════════════
// class UserHome extends StatefulWidget {
//   const UserHome({super.key});
//
//   @override
//   State<UserHome> createState() => _UserHomeState();
// }
//
// class _UserHomeState extends State<UserHome> with TickerProviderStateMixin {
//   // ── State ──────────────────────────────────────────────────────────────────
//   String  username            = "User";
//   String? profilePhotoUrl;
//   String  healthProfileStatus = "no";
//   String  userGender          = ""; // "male" or "female" from profile data
//
//   int    caloriesGoal = 0;
//   int    proteinGoal  = 0;
//   int    carbsGoal    = 0;
//   int    fatGoal      = 0;
//   double waterGoal    = 2.5;
//   String goalMode     = "balanced";
//
//   int    caloriesToday = 0;
//   int    proteinToday  = 0;
//   int    carbsToday    = 0;
//   int    fatToday      = 0;
//   double waterLiters   = 0.0;
//
//   int                        streakDays = 0;
//   List<Map<String, dynamic>> insights   = [];
//
//   // ── Animation controllers ──────────────────────────────────────────────────
//   late AnimationController _animCtrl;
//   late AnimationController _pulseCtrl;
//   late AnimationController _glowCtrl;
//   late AnimationController _scanRingCtrl;
//   late Animation<double>   _fadeAnim;
//   late Animation<double>   _slideAnim;
//   late Animation<double>   _pulseAnim;
//   late Animation<double>   _glowAnim;
//   late Animation<double>   _scanRingAnim;
//
//   // ── Computed ───────────────────────────────────────────────────────────────
//   Color get _headerGlowColor {
//     if (caloriesGoal <= 0) return _DS.neon;
//     final p = caloriesToday / caloriesGoal;
//     if (p > 1.0) return _DS.accent3;
//     if (p >= 0.8) return _DS.accent4;
//     return _DS.neon;
//   }
//
//   String get _calStatusText {
//     if (caloriesGoal <= 0) return '';
//     final p = caloriesToday / caloriesGoal;
//     if (p > 1.0)  return 'Over Limit ⚠';
//     if (p >= 1.0) return 'Goal Achieved 🎉';
//     if (p >= 0.8) return 'Nearing Limit';
//     return 'On Track';
//   }
//
//   Color get _calStatusColor {
//     if (caloriesGoal <= 0) return _DS.neon;
//     final p = caloriesToday / caloriesGoal;
//     if (p > 1.0)  return _DS.accent3;
//     if (p >= 1.0) return _DS.accent1;
//     if (p >= 0.8) return _DS.accent4;
//     return _DS.neon;
//   }
//
//   String get _greeting {
//     final h = DateTime.now().hour;
//     if (h < 12) return "Good morning";
//     if (h < 17) return "Good afternoon";
//     return "Good evening";
//   }
//
//   String get _goalLabel {
//     switch (goalMode) {
//       case 'weight_gain': return "⚡ Weight Gain Mode";
//       case 'fat_loss':    return "🎯 Fat Loss Mode";
//       case 'diabetic':    return "💊 Diabetic Mode";
//       default:            return "🌱 Balanced Mode";
//     }
//   }
//
//   int get _healthScore {
//     if (caloriesGoal == 0) return 72;
//     int s = 100;
//     final cp = caloriesToday / caloriesGoal;
//     if (cp > 1.15)       s -= 25;
//     else if (cp > 1.0)   s -= 10;
//     if (proteinGoal > 0 && proteinToday / proteinGoal < 0.5)   s -= 15;
//     if (carbsGoal   > 0 && carbsToday   / carbsGoal   > 1.15)  s -= 20;
//     if (fatGoal     > 0 && fatToday     / fatGoal     > 1.15)  s -= 15;
//     if (streakDays >= 7) s = (s + 5).clamp(0, 100);
//     return s.clamp(0, 100);
//   }
//
//   Color get _healthScoreColor {
//     final s = _healthScore;
//     if (s >= 80) return _DS.neon;
//     if (s >= 60) return _DS.accent4;
//     return _DS.accent3;
//   }
//
//   /// Returns gender-aware avatar icon
//   IconData get _genderAvatarIcon {
//     final g = userGender.toLowerCase();
//     if (g == 'female' || g == 'f' || g == 'woman') {
//       return Icons.face_3_rounded; // female face icon
//     }
//     return Icons.face_rounded; // male/default face icon
//   }
//
//
//
//
//   // ── Lifecycle ──────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     _fetchProfileData();
//     // _loadUserData();
//     _loadGoals();
//     _fetchTodayNutrition();
//     _fetchStreak();
//
//     _animCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 1000));
//     _fadeAnim  = Tween<double>(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
//     _slideAnim = Tween<double>(begin: 40.0, end: 0.0).animate(
//         CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
//
//     _pulseCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 2000))
//       ..repeat(reverse: true);
//     _pulseAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
//         CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
//
//     _glowCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 2400))
//       ..repeat(reverse: true);
//     _glowAnim = Tween<double>(begin: 0.25, end: 0.75).animate(
//         CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
//
//     _scanRingCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 3000))
//       ..repeat();
//     _scanRingAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(parent: _scanRingCtrl, curve: Curves.linear));
//
//     _animCtrl.forward();
//   }
//
//   @override
//   void dispose() {
//     _animCtrl.dispose();
//     _pulseCtrl.dispose();
//     _glowCtrl.dispose();
//     _scanRingCtrl.dispose();
//     super.dispose();
//   }
//
//
//   String name = '';
//   String photoUrl = '';
//
//   Future<void> _fetchProfileData() async {
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//       _errorMessage = '';
//     });
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final baseUrl = prefs.getString('url') ?? '';
//       final lid = prefs.getString('lid') ?? '';
//       final imgBase = prefs.getString('img') ?? '';
//
//       if (baseUrl.isEmpty || lid.isEmpty) {
//         throw Exception('Missing URL or user ID');
//       }
//
//       final uri = Uri.parse('$baseUrl/view_profile/');
//
//       final response = await http.post(
//         uri,
//         body: {'lid': lid},
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//
//         if (data['status'] == 'ok') {
//           setState(() {
//             name = data['Name']?.toString() ?? '—';
//             photoUrl = '$imgBase${data['Photo']?.toString() ?? ''}';
//           });
//         } else {
//           setState(() {
//             _hasError = true;
//             _errorMessage = data['message'] ?? 'Profile not found';
//           });
//         }
//       } else {
//         setState(() {
//           _hasError = true;
//           _errorMessage = 'Server error (${response.statusCode})';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _hasError = true;
//         _errorMessage = e.toString().replaceAll('Exception: ', '');
//       });
//       Fluttertoast.showToast(
//         msg: _errorMessage,
//         toastLength: Toast.LENGTH_LONG,
//         gravity: ToastGravity.BOTTOM,
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//
//
//   // ── Data fetching ──────────────────────────────────────────────────────────
//   // Future<void> _loadUserData() async {
//   //
//   //   ######view profile call url http
//   //
//   //
//   //
//   //
//   //
//   //   final prefs   = await SharedPreferences.getInstance();
//   //   final imgBase = prefs.getString('img') ?? '';
//   //   setState(() {
//   //     username            = prefs.getString('username')?.trim() ?? "User";
//   //     final photoPath     = prefs.getString('photo') ?? '';
//   //     profilePhotoUrl     = photoPath.isNotEmpty ? '$imgBase$photoPath' : null;
//   //     healthProfileStatus = prefs.getString('h') ?? "no";
//   //     userGender          = prefs.getString('gender') ?? '';
//   //   });
//   // }
//
//
//
//
//
//   // Future<void> _loadGoals() async {
//   //   final prefs   = await SharedPreferences.getInstance();
//   //   final baseUrl = prefs.getString('url') ?? '';
//   //   final lid     = prefs.getString('lid') ?? '';
//   //   if (baseUrl.isEmpty || lid.isEmpty) return;
//   //   try {
//   //     final r = await http.post(
//   //         Uri.parse('$baseUrl/userviewhishealth/'), body: {'lid': lid});
//   //     if (r.statusCode == 200) {
//   //       final d = jsonDecode(r.body);
//   //       if (d['status'] == 'ok') {
//   //         setState(() {
//   //           caloriesGoal =
//   //               int.tryParse(d['healthvalue']?.toString()  ?? '2000') ?? 2000;
//   //           proteinGoal  =
//   //               int.tryParse(d['protienvalue']?.toString() ?? '100')  ?? 100;
//   //           carbsGoal    =
//   //               int.tryParse(d['carbvalue']?.toString()    ?? '250')  ?? 250;
//   //           fatGoal      =
//   //               int.tryParse(d['fatvalue']?.toString()     ?? '70')   ?? 70;
//   //           goalMode     = d['goal_mode']?.toString() ?? 'balanced';
//   //           // Also try to get gender from health profile if available
//   //           if (d['gender'] != null && d['gender'].toString().isNotEmpty) {
//   //             userGender = d['gender'].toString();
//   //           }
//   //         });
//   //         _generateInsights();
//   //       }
//   //     }
//   //   } catch (e) {
//   //     debugPrint("Error loading goals: $e");
//   //   }
//   // }
//
//
//   Future<void> _loadGoals() async {
//     final prefs = await SharedPreferences.getInstance();
//     final baseUrl = prefs.getString('url') ?? '';
//     final lid = prefs.getString('lid') ?? '';
//
//     print('Loading goals - URL: $baseUrl, LID: $lid');
//
//     if (baseUrl.isEmpty || lid.isEmpty) return;
//
//     try {
//       final r = await http.post(
//           Uri.parse('$baseUrl/userviewhishealth/'),
//           body: {'lid': lid}
//       );
//
//       print('Response status: ${r.statusCode}');
//       print('Response body: ${r.body}');
//
//       if (r.statusCode == 200) {
//         final d = jsonDecode(r.body);
//         if (d['status'] == 'ok') {
//           setState(() {
//             // FIXED: Map the correct field names from your backend
//             caloriesGoal = int.tryParse(d['healthvalue']?.toString() ?? '2000') ?? 2000;
//             proteinGoal = int.tryParse(d['protienvalue']?.toString() ?? '100') ?? 100;
//             carbsGoal = int.tryParse(d['carbvalue']?.toString() ?? '250') ?? 250;
//             fatGoal = int.tryParse(d['fatvalue']?.toString() ?? '70') ?? 70;
//
//             // Note: Your backend doesn't return goal_mode, so set a default
//             goalMode = 'balanced'; // or you can add this to your backend
//
//             // Note: Your backend doesn't return gender, so keep existing or set default
//             // userGender = d['gender']?.toString() ?? userGender;
//
//             print('Goals loaded - Calories: $caloriesGoal, Protein: $proteinGoal, Carbs: $carbsGoal, Fat: $fatGoal');
//           });
//           _generateInsights();
//         } else {
//           print('Health profile not found for LID: $lid');
//         }
//       }
//     } catch (e) {
//       print('Error loading goals: $e');
//     }
//   }
//
//   Future<void> _fetchTodayNutrition() async {
//     final prefs = await SharedPreferences.getInstance();
//     final lid = prefs.getString("lid");
//     final baseUrl = prefs.getString("url");
//
//     if (lid == null || baseUrl == null) return;
//
//     try {
//       print('Fetching today nutrition for LID: $lid');
//       final r = await http.post(
//           Uri.parse("$baseUrl/today_nutrition_summary/"),
//           body: {"lid": lid}
//       );
//
//       print('Nutrition response: ${r.body}');
//
//       if (r.statusCode == 200) {
//         final d = jsonDecode(r.body);
//         if (d["status"] == "ok") {
//           setState(() {
//             proteinToday = (d["total_protein"] as num?)?.round() ?? 0;
//             carbsToday = (d["total_carbs"] as num?)?.round() ?? 0;
//             fatToday = (d["total_fat"] as num?)?.round() ?? 0;
//             caloriesToday = (d["total_calories"] as num?)?.round() ?? 0;
//           });
//           _generateInsights();
//         }
//       }
//     } catch (e) {
//       print("Nutrition fetch error: $e");
//     }
//   }
//   // Future<void> _fetchTodayNutrition() async {
//   //   final prefs   = await SharedPreferences.getInstance();
//   //   final lid     = prefs.getString("lid");
//   //   final baseUrl = prefs.getString("url");
//   //   if (lid == null || baseUrl == null) return;
//   //   try {
//   //     final r = await http.post(
//   //         Uri.parse("$baseUrl/today_nutrition_summary/"), body: {"lid": lid});
//   //     if (r.statusCode == 200) {
//   //       final d = jsonDecode(r.body);
//   //       if (d["status"] == "ok") {
//   //         setState(() {
//   //           proteinToday  = (d["total_protein"]  as num?)?.round() ?? 0;
//   //           carbsToday    = (d["total_carbs"]    as num?)?.round() ?? 0;
//   //           fatToday      = (d["total_fat"]      as num?)?.round() ?? 0;
//   //           caloriesToday = (d["total_calories"] as num?)?.round() ?? 0;
//   //         });
//   //         _generateInsights();
//   //       }
//   //     }
//   //   } catch (e) {
//   //     debugPrint("Nutrition fetch error: $e");
//   //   }
//   // }
//
//   Future<void> _fetchStreak() async {
//     final prefs   = await SharedPreferences.getInstance();
//     final lid     = prefs.getString("lid");
//     final baseUrl = prefs.getString("url");
//     if (lid == null || baseUrl == null) return;
//     try {
//       final r = await http.post(
//           Uri.parse("$baseUrl/get_streak/"), body: {"lid": lid});
//       if (r.statusCode == 200) {
//         final d = jsonDecode(r.body);
//         if (d["status"] == "ok") {
//           setState(
//                   () => streakDays = (d["streak"] as num?)?.toInt() ?? 0);
//           _generateInsights();
//         }
//       }
//     } catch (e) {
//       debugPrint("Streak fetch error: $e");
//     }
//   }
//
//   void _generateInsights() {
//     final List<Map<String, dynamic>> n = [];
//     if (proteinGoal > 0) {
//       final p = proteinToday / proteinGoal;
//       if (p < 0.5)
//         n.add({
//           'title': 'Low Protein',
//           'message': 'Try eggs, chicken, lentils or Greek yogurt',
//           'icon': Icons.egg_alt,
//           'color': _DS.accent4,
//         });
//       else if (p >= 1.0)
//         n.add({
//           'title': 'Protein Goal Met!',
//           'message': 'Excellent protein intake today',
//           'icon': Icons.emoji_events,
//           'color': _DS.neon,
//         });
//     }
//     if (caloriesGoal > 0) {
//       final p = caloriesToday / caloriesGoal;
//       if (p >= 1.0)
//         n.add({
//           'title': 'Calorie Goal Reached',
//           'message': "You hit your daily target — great job!",
//           'icon': Icons.check_circle,
//           'color': _DS.accent5,
//         });
//       else if (p > 0.85)
//         n.add({
//           'title': 'Almost There',
//           'message': 'Just a bit more to reach your goal',
//           'icon': Icons.timeline,
//           'color': _DS.accent1,
//         });
//     }
//     if (streakDays >= 3)
//       n.add({
//         'title': '🔥 $streakDays-Day Streak',
//         'message': streakDays > 14 ? 'Incredible consistency!' : 'Keep going!',
//         'icon': Icons.local_fire_department,
//         'color': _DS.accent3,
//       });
//     if (waterLiters < waterGoal * 0.4)
//       n.add({
//         'title': 'Hydration Check',
//         'message': 'Time to drink some water',
//         'icon': Icons.water_drop,
//         'color': _DS.accent1,
//       });
//     if (n.length < 2) {
//       final sug = [
//         {
//           'title': 'Meal Idea',
//           'message': 'Grilled chicken salad bowl',
//           'icon': Icons.restaurant,
//           'color': _DS.neonDim,
//         },
//         {
//           'title': 'Quick Snack',
//           'message': 'Greek yogurt + berries',
//           'icon': Icons.yard,
//           'color': _DS.accent5,
//         },
//         {
//           'title': 'Healthy Option',
//           'message': 'Oats with nuts & banana',
//           'icon': Icons.free_breakfast,
//           'color': _DS.accent1,
//         },
//       ];
//       n.add(sug[DateTime.now().millisecondsSinceEpoch % 3]);
//     }
//     setState(() => insights = n);
//   }
//
//   Future<void> _onRefresh() async {
//     await Future.wait([
//       _loadUserData(),
//       _loadGoals(),
//       _fetchTodayNutrition(),
//       _fetchStreak(),
//     ]);
//   }
//
//   void _openInsights() {
//     HapticFeedback.lightImpact();
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => _InsightsScreen(
//           caloriesToday: caloriesToday,
//           caloriesGoal: caloriesGoal,
//           proteinToday: proteinToday,
//           proteinGoal: proteinGoal,
//           carbsToday: carbsToday,
//           carbsGoal: carbsGoal,
//           fatToday: fatToday,
//           fatGoal: fatGoal,
//           streakDays: streakDays,
//           insights: insights,
//         ),
//       ),
//     );
//   }
//   // void _openInsights() {
//   //   HapticFeedback.lightImpact();
//   //   Navigator.push(
//   //     context,
//   //     MaterialPageRoute(
//   //       builder: (_) => _InsightsScreen(
//   //         caloriesToday: caloriesToday,
//   //         caloriesGoal:  caloriesGoal,
//   //         proteinToday:  proteinToday,
//   //         proteinGoal:   proteinGoal,
//   //         carbsToday:    carbsToday,
//   //         carbsGoal:     carbsGoal,
//   //         fatToday:      fatToday,
//   //         fatGoal:       fatGoal,
//   //         streakDays:    streakDays,
//   //         insights:      insights,
//   //       ),
//   //     ),
//   //   );
//   // }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  BUILD
//   // ══════════════════════════════════════════════════════════════════════════
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//         onWillPop: () async => false,
//
//         child:
//       AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.light,
//       child:
//
//
//
//     Scaffold(
//         backgroundColor: _DS.bg,
//         floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//         floatingActionButton: _buildChatbotFAB(),
//         body: SafeArea(
//           child: RefreshIndicator(
//             color: _DS.neon,
//             backgroundColor: _DS.bgCard,
//             onRefresh: _onRefresh,
//             child: AnimatedBuilder(
//               animation: _animCtrl,
//               builder: (_, child) => Opacity(
//                 opacity: _fadeAnim.value,
//                 child: Transform.translate(
//                     offset: Offset(0, _slideAnim.value), child: child),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // ── Top bar ─────────────────────────────────────────────
//                     const SizedBox(height: 8),
//                     _buildTopBar(),
//
//                     // ── 1. Greeting card ────────────────────────────────────
//                     const SizedBox(height: 10),
//                     _buildSmartHeader(),
//
//                     // ── 2. Scan + Actions unified hero block ─────────────────
//                     const SizedBox(height: 10),
//                     _buildScanHeroBlock(),
//
//                     // ── 3. Calorie dashboard (Expanded to fill remaining) ────
//                     const SizedBox(height: 10),
//                     Expanded(child: _buildCalorieDashboard()),
//
//                     const SizedBox(height: 10),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     ));
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  TOP BAR
//   // ══════════════════════════════════════════════════════════════════════════
//   Widget _buildTopBar() {
//     return Row(
//       children: [
//         AnimatedBuilder(
//           animation: _glowAnim,
//           builder: (_, __) => Container(
//             padding:
//             const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//             decoration: BoxDecoration(
//               color: _DS.neonFaint,
//               borderRadius: BorderRadius.circular(30),
//               border: Border.all(color: _DS.neon.withOpacity(0.3), width: 1),
//               boxShadow: [
//                 BoxShadow(
//                     color: _DS.neon.withOpacity(_glowAnim.value * 0.18),
//                     blurRadius: 16,
//                     spreadRadius: -2)
//               ],
//             ),
//             child: Row(mainAxisSize: MainAxisSize.min, children: [
//               const Icon(Icons.camera_enhance_rounded,
//                   color: _DS.neon, size: 15),
//               const SizedBox(width: 5),
//               const Text("FoodSnap AI",
//                   style: TextStyle(
//                       color: _DS.neon,
//                       fontSize: 13,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 0.4)),
//             ]),
//           ),
//         ),
//         const Spacer(),
//         Container(
//           padding:
//           const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//           decoration: BoxDecoration(
//             color: _healthScoreColor.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(
//                 color: _healthScoreColor.withOpacity(0.2), width: 1),
//           ),
//           child: Row(mainAxisSize: MainAxisSize.min, children: [
//             Icon(Icons.monitor_heart_rounded,
//                 size: 13, color: _healthScoreColor),
//             const SizedBox(width: 4),
//             Text("$_healthScore",
//                 style: TextStyle(
//                     color: _healthScoreColor,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w800)),
//           ]),
//         ),
//         const SizedBox(width: 8),
//         GestureDetector(
//           onTap: () {
//             HapticFeedback.lightImpact();
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (_) => const _SettingsScreen()))
//                 .then((_) => _loadUserData());
//           },
//           child: Container(
//             decoration: BoxDecoration(
//               color: _DS.surface,
//               shape: BoxShape.circle,
//               border: Border.all(color: _DS.borderFaint, width: 1),
//             ),
//             padding: const EdgeInsets.all(9),
//             child: const Icon(Icons.settings_rounded,
//                 color: _DS.neon, size: 19),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  1. SMART HEADER — with gender avatar
//   // ══════════════════════════════════════════════════════════════════════════
//   Widget _buildSmartHeader() {
//     return GestureDetector(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => healthProfileStatus == "no"
//                 ? const AddHealthProfilePage()
//                 : const HealthProfilePage(),
//           ),
//         ).then((_) {
//           _loadUserData();
//           _loadGoals();
//         });
//       },
//       child: AnimatedBuilder(
//         animation: _glowAnim,
//         builder: (_, __) => Container(
//           padding:
//           const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
//           decoration: BoxDecoration(
//             color: _DS.bgCard,
//             borderRadius: BorderRadius.circular(22),
//             border: Border.all(
//                 color: _headerGlowColor.withOpacity(0.2), width: 1),
//             boxShadow: [
//               BoxShadow(
//                 color: _headerGlowColor
//                     .withOpacity(_glowAnim.value * 0.12),
//                 blurRadius: 20,
//                 spreadRadius: -4,
//                 offset: const Offset(0, 4),
//               )
//             ],
//           ),
//           child: Row(
//             children: [
//               // Gender-aware avatar
//               Container(
//                 padding: const EdgeInsets.all(2),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     colors: _isFemale
//                         ? [const Color(0xFFFF80AB), const Color(0xFFF48FB1)]
//                         : [_DS.neon, _DS.neonDim],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//                 child: CircleAvatar(
//                   radius: 20,
//                   backgroundColor: _DS.surface,
//                   backgroundImage: profilePhotoUrl != null
//                       ? NetworkImage(profilePhotoUrl!)
//                       : null,
//                   child: profilePhotoUrl == null
//                       ? Icon(
//                     _genderAvatarIcon,
//                     size: 22,
//                     color: _isFemale
//                         ? const Color(0xFFFF80AB)
//                         : _DS.neon,
//                   )
//                       : null,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(_greeting,
//                         style: const TextStyle(
//                             color: _DS.textSecondary,
//                             fontSize: 10,
//                             fontWeight: FontWeight.w500)),
//                     Text(
//                       name.split(' ').first,
//                       style: const TextStyle(
//                           color: _DS.textPrimary,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w900,
//                           letterSpacing: -0.5),
//                     ),
//                     const SizedBox(height: 3),
//                     Row(children: [
//                       _miniChip(_goalLabel, _DS.neon),
//                       const SizedBox(width: 5),
//                       _miniChip(_calStatusText, _calStatusColor),
//                     ]),
//                   ],
//                 ),
//               ),
//               Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: _DS.neonFaint,
//                       borderRadius: BorderRadius.circular(11),
//                       border: Border.all(
//                           color: _DS.neon.withOpacity(0.2), width: 1),
//                     ),
//                     child: const Icon(Icons.health_and_safety_rounded,
//                         color: _DS.neon, size: 17),
//                   ),
//                   const SizedBox(height: 2),
//                   const Text("Health",
//                       style: TextStyle(
//                           color: _DS.neon,
//                           fontSize: 8,
//                           fontWeight: FontWeight.w600)),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   bool get _isFemale {
//     final g = userGender.toLowerCase();
//     return g == 'female' || g == 'f' || g == 'woman';
//   }
//
//   Widget _miniChip(String text, Color color) {
//     if (text.isEmpty) return const SizedBox.shrink();
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withOpacity(0.2), width: 1),
//       ),
//       child: Text(text,
//           style: TextStyle(
//               color: color, fontSize: 9, fontWeight: FontWeight.w700)),
//     );
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  2+3. UNIFIED SCAN HERO + QUICK ACTIONS BLOCK
//   //  Large scan button on the left, 2×2 action grid on the right
//   // ══════════════════════════════════════════════════════════════════════════
//   Widget _buildScanHeroBlock() {
//     return AnimatedBuilder(
//       animation: Listenable.merge([_pulseAnim, _scanRingAnim, _glowAnim]),
//       builder: (_, __) => SizedBox(
//         height: 148,
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // ── LEFT: large scan CTA ────────────────────────────────────────
//             Expanded(
//               flex: 5,
//               child: GestureDetector(
//                 onTap: () {
//                   HapticFeedback.mediumImpact();
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (_) => const UploadFoodScreen()))
//                       .then((_) => _fetchTodayNutrition());
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: _DS.bgCard,
//                     borderRadius: BorderRadius.circular(22),
//                     border: Border.all(
//                         color: _DS.neon.withOpacity(0.22), width: 1.2),
//                     boxShadow: [
//                       BoxShadow(
//                           color: _DS.neon.withOpacity(_glowAnim.value * 0.28),
//                           blurRadius: 32,
//                           spreadRadius: -4,
//                           offset: const Offset(0, 4))
//                     ],
//                   ),
//                   child: Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       // Ambient glow background
//                       Positioned.fill(
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(22),
//                           child: CustomPaint(
//                             painter: _RadialGlowPainter(
//                                 color: _DS.neon,
//                                 opacity: _glowAnim.value * 0.06),
//                           ),
//                         ),
//                       ),
//                       // Rotating dashed ring
//                       Transform.rotate(
//                         angle: _scanRingAnim.value * 2 * math.pi,
//                         child: CustomPaint(
//                           size: const Size(96, 96),
//                           painter: _ScanRingPainter(
//                               color: _DS.neon.withOpacity(0.14)),
//                         ),
//                       ),
//                       // Content
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Transform.scale(
//                             scale: _pulseAnim.value,
//                             child: Container(
//                               width: 60,
//                               height: 60,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 gradient: RadialGradient(
//                                   colors: [
//                                     _DS.neon.withOpacity(0.22),
//                                     _DS.neonFaint,
//                                   ],
//                                 ),
//                                 border: Border.all(
//                                     color: _DS.neon.withOpacity(0.5),
//                                     width: 1.5),
//                                 boxShadow: [
//                                   BoxShadow(
//                                       color: _DS.neon.withOpacity(
//                                           _glowAnim.value * 0.45),
//                                       blurRadius: 22,
//                                       spreadRadius: 2)
//                                 ],
//                               ),
//                               child: const Icon(Icons.camera_enhance_rounded,
//                                   color: _DS.neon, size: 28),
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           const Text("SCAN FOOD",
//                               style: TextStyle(
//                                   color: _DS.neon,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w900,
//                                   letterSpacing: 2.8)),
//                           const SizedBox(height: 3),
//                           const Text("AI nutrition analysis",
//                               style: TextStyle(
//                                   color: _DS.textMuted,
//                                   fontSize: 9.5,
//                                   fontWeight: FontWeight.w500)),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10),
//
//             // ── RIGHT: 2×2 quick action grid ───────────────────────────────
//             Expanded(
//               flex: 4,
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: [
//                         _quickActionTile(
//                           icon: Icons.biotech_rounded,
//                           label: 'Ingredient',
//                           color: _DS.accent1,
//                           onTap: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (_) => IngredientAIScreen())),
//                         ),
//                         const SizedBox(width: 8),
//                         _quickActionTile(
//                           icon: Icons.restaurant_menu_rounded,
//                           label: 'Suggest',
//                           color: _DS.accent2,
//                           onTap: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (_) => DailySuggestionScreen())),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Expanded(
//                     child: Row(
//                       children: [
//                         _quickActionTile(
//                           icon: Icons.insights_rounded,
//                           label: 'Insights',
//                           color: _DS.accent4,
//                           onTap: _openInsights,
//                         ),
//                         const SizedBox(width: 8),
//                         _quickActionTile(
//                           icon: Icons.settings_rounded,
//                           label: 'Settings',
//                           color: _DS.accent5,
//                           onTap: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (_) => const _SettingsScreen()))
//                               .then((_) => _loadUserData()),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _quickActionTile({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           HapticFeedback.lightImpact();
//           onTap();
//         },
//         child: Container(
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.07),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: color.withOpacity(0.18), width: 1),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(icon, color: color, size: 18),
//               ),
//               const SizedBox(height: 6),
//               Text(label,
//                   style: TextStyle(
//                       color: color,
//                       fontSize: 9.5,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 0.2)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  4. CALORIE DASHBOARD — fills remaining screen height richly
//   // ══════════════════════════════════════════════════════════════════════════
//   Widget _buildCalorieDashboard() {
//     final pct       = caloriesGoal > 0 ? caloriesToday / caloriesGoal : 0.0;
//     final progress  = pct.clamp(0.0, 1.0);
//     final remaining = caloriesGoal - caloriesToday;
//     final isOver    = pct > 1.0;
//
//     Color ringColor;
//     if (pct > 1.0)       ringColor = _DS.accent3;
//     else if (pct >= 1.0) ringColor = _DS.accent1;
//     else if (pct >= 0.8) ringColor = _DS.accent4;
//     else                 ringColor = _DS.neon;
//
//     return GestureDetector(
//       onTap: _openInsights,
//       child: AnimatedBuilder(
//         animation: _glowAnim,
//         builder: (_, __) => Container(
//           width: double.infinity,
//           decoration: BoxDecoration(
//             color: _DS.bgCard,
//             borderRadius: BorderRadius.circular(26),
//             border: Border.all(
//                 color: ringColor.withOpacity(isOver ? 0.35 : 0.18),
//                 width: 1),
//             boxShadow: [
//               BoxShadow(
//                   color: ringColor.withOpacity(
//                       isOver ? _glowAnim.value * 0.22 : 0.04),
//                   blurRadius: isOver ? 30 : 14,
//                   spreadRadius: -4,
//                   offset: const Offset(0, 4))
//             ],
//           ),
//           child: Stack(
//             children: [
//               Positioned.fill(
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(26),
//                   child: CustomPaint(
//                       painter: _BgArcPainter(
//                           color: ringColor, progress: progress)),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//
//                     // ── Header row ──────────────────────────────────────────
//                     Row(
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text("Daily Calories",
//                                 style: TextStyle(
//                                     color: _DS.textMuted,
//                                     fontSize: 11,
//                                     fontWeight: FontWeight.w600,
//                                     letterSpacing: 0.4)),
//                             const SizedBox(height: 1),
//                             Text("Goal: $caloriesGoal kcal",
//                                 style: const TextStyle(
//                                     color: _DS.textMuted,
//                                     fontSize: 9,
//                                     fontWeight: FontWeight.w500)),
//                           ],
//                         ),
//                         const Spacer(),
//                         if (streakDays > 0)
//                           Container(
//                             margin: const EdgeInsets.only(right: 8),
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: _DS.accent3.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(14),
//                               border: Border.all(
//                                   color: _DS.accent3.withOpacity(0.2),
//                                   width: 1),
//                             ),
//                             child: Row(children: [
//                               const Icon(Icons.local_fire_department,
//                                   size: 11, color: _DS.accent3),
//                               const SizedBox(width: 3),
//                               Text("$streakDays",
//                                   style: const TextStyle(
//                                       color: _DS.accent3,
//                                       fontSize: 11,
//                                       fontWeight: FontWeight.w800)),
//                             ]),
//                           ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 9, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: ringColor.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(18),
//                             border: Border.all(
//                                 color: ringColor.withOpacity(0.2),
//                                 width: 1),
//                           ),
//                           child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(Icons.insights_rounded,
//                                     size: 10, color: ringColor),
//                                 const SizedBox(width: 4),
//                                 Text("Details",
//                                     style: TextStyle(
//                                         color: ringColor,
//                                         fontSize: 9,
//                                         fontWeight: FontWeight.w700)),
//                               ]),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 14),
//
//                     // ── Ring + calorie number + status ──────────────────────
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         // Large ring
//                         SizedBox(
//                           width: 130,
//                           height: 130,
//                           child: Stack(
//                             alignment: Alignment.center,
//                             children: [
//                               SizedBox(
//                                 width: 130,
//                                 height: 130,
//                                 child: CircularProgressIndicator(
//                                   value: progress,
//                                   strokeWidth: 13,
//                                   backgroundColor:
//                                   ringColor.withOpacity(0.1),
//                                   valueColor:
//                                   AlwaysStoppedAnimation(ringColor),
//                                   strokeCap: StrokeCap.round,
//                                 ),
//                               ),
//                               Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Text(
//                                     "${(pct * 100).toInt()}%",
//                                     style: TextStyle(
//                                         fontSize: 28,
//                                         fontWeight: FontWeight.w900,
//                                         color: ringColor,
//                                         letterSpacing: -1),
//                                   ),
//                                   Text(
//                                     pct >= 1.0 ? "done" : "of goal",
//                                     style: const TextStyle(
//                                         fontSize: 10,
//                                         color: _DS.textMuted,
//                                         fontWeight: FontWeight.w500),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 18),
//
//                         // Calorie number + status pill
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               RichText(
//                                 text: TextSpan(children: [
//                                   TextSpan(
//                                     text: "$caloriesToday",
//                                     style: const TextStyle(
//                                         fontSize: 42,
//                                         fontWeight: FontWeight.w900,
//                                         color: _DS.textPrimary,
//                                         letterSpacing: -2.5),
//                                   ),
//                                   const TextSpan(
//                                     text: "\nkcal",
//                                     style: TextStyle(
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.w500,
//                                         color: _DS.textMuted),
//                                   ),
//                                 ]),
//                               ),
//                               const SizedBox(height: 10),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 12, vertical: 7),
//                                 decoration: BoxDecoration(
//                                   color: ringColor.withOpacity(0.12),
//                                   borderRadius:
//                                   BorderRadius.circular(12),
//                                   border: Border.all(
//                                       color: ringColor.withOpacity(0.25),
//                                       width: 1),
//                                 ),
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(
//                                       isOver
//                                           ? Icons.warning_rounded
//                                           : remaining == 0
//                                           ? Icons.check_circle_rounded
//                                           : Icons.bolt_rounded,
//                                       size: 12,
//                                       color: ringColor,
//                                     ),
//                                     const SizedBox(width: 5),
//                                     Text(
//                                       isOver
//                                           ? "Over by ${remaining.abs()} kcal"
//                                           : remaining > 0
//                                           ? "$remaining left"
//                                           : "Goal Hit! 🎉",
//                                       style: TextStyle(
//                                           fontSize: 11,
//                                           fontWeight: FontWeight.w700,
//                                           color: ringColor),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//
//                     // ── Divider ─────────────────────────────────────────────
//                     Container(height: 1, color: _DS.borderFaint),
//                     const SizedBox(height: 14),
//
//                     // ── MACRO PROGRESS BARS (inline, compact) ───────────────
//                     const Text("Macronutrients",
//                         style: TextStyle(
//                             color: _DS.textMuted,
//                             fontSize: 10,
//                             fontWeight: FontWeight.w600,
//                             letterSpacing: 0.5)),
//                     const SizedBox(height: 10),
//                     _inlineMacroBar("Protein", proteinToday, proteinGoal,
//                         const Color(0xFFF97316)),
//                     const SizedBox(height: 8),
//                     _inlineMacroBar("Carbs", carbsToday, carbsGoal,
//                         const Color(0xFF3B82F6)),
//                     const SizedBox(height: 8),
//                     _inlineMacroBar("Fats", fatToday, fatGoal,
//                         const Color(0xFFA855F7)),
//
//                     const SizedBox(height: 8),
//                     Container(height: 1, color: _DS.borderFaint),
//                     const SizedBox(height: 8),
//
//                     // ── MINI WEEK BAR CHART ─────────────────────────────────
//                     _buildMiniWeekChart(),
//
//                     const Spacer(),
//
//                     // ── Tap hint ────────────────────────────────────────────
//                     Center(
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: const [
//                           Icon(Icons.touch_app_rounded,
//                               color: _DS.textMuted, size: 10),
//                           SizedBox(width: 4),
//                           Text(
//                             "Tap for full insights & AI recommendations",
//                             style: TextStyle(
//                                 color: _DS.textMuted,
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.w500),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// Compact single-line macro progress bar
//   Widget _inlineMacroBar(
//       String label, int current, int goal, Color color) {
//     final pct = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
//     final pctInt = goal > 0 ? (current / goal * 100).toInt() : 0;
//     return Row(
//       children: [
//         SizedBox(
//           width: 46,
//           child: Text(label,
//               style: const TextStyle(
//                   color: _DS.textSecondary,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600)),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(6),
//             child: LinearProgressIndicator(
//               value: pct,
//               minHeight: 7,
//               backgroundColor: color.withOpacity(0.1),
//               valueColor: AlwaysStoppedAnimation(
//                   pctInt > 110 ? _DS.accent3 : pctInt < 40 ? _DS.accent4 : color),
//             ),
//           ),
//         ),
//         const SizedBox(width: 10),
//         SizedBox(
//           width: 50,
//           child: Text("$current/$goal g",
//               textAlign: TextAlign.right,
//               style: TextStyle(
//                   color: color.withOpacity(0.8),
//                   fontSize: 10,
//                   fontWeight: FontWeight.w700)),
//         ),
//       ],
//     );
//   }
//
//   /// Compact 7-day calorie bar chart inside the dashboard
//   Widget _buildMiniWeekChart() {
//     final mockData = [0.60, 0.80, 0.75, 0.90, 0.70, 0.85,
//       caloriesGoal > 0 ? (caloriesToday / caloriesGoal).clamp(0.0, 1.0) : 0.0];
//     const days = ["M", "T", "W", "T", "F", "S", "S"];
//     final today = DateTime.now().weekday - 1;
//
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         const Text("This Week",
//             style: TextStyle(
//                 color: _DS.textMuted,
//                 fontSize: 10,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 0.3)),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: List.generate(7, (i) {
//               final val     = i < mockData.length ? mockData[i] : 0.0;
//               final isToday = i == today;
//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   AnimatedContainer(
//                     duration: const Duration(milliseconds: 600),
//                     curve: Curves.easeOutBack,
//                     width: 20,
//                     height: (val * 40).clamp(4.0, 40.0),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.bottomCenter,
//                         end: Alignment.topCenter,
//                         colors: isToday
//                             ? [_DS.neonDim, _DS.neon]
//                             : [_DS.neonFaint, _DS.neon.withOpacity(0.22)],
//                       ),
//                       borderRadius: BorderRadius.circular(5),
//                       boxShadow: isToday
//                           ? [
//                         BoxShadow(
//                             color: _DS.neon.withOpacity(0.35),
//                             blurRadius: 8,
//                             offset: const Offset(0, -2))
//                       ]
//                           : [],
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(days[i],
//                       style: TextStyle(
//                           fontSize: 9,
//                           fontWeight:
//                           isToday ? FontWeight.w900 : FontWeight.w500,
//                           color: isToday ? _DS.neon : _DS.textMuted)),
//                 ],
//               );
//             }),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ── Chatbot FAB ────────────────────────────────────────────────────────────
//   Widget _buildChatbotFAB() {
//     return AnimatedBuilder(
//       animation: _glowAnim,
//       builder: (_, __) => Container(
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//                 color: _DS.accent2
//                     .withOpacity(_glowAnim.value * 0.4),
//                 blurRadius: 20,
//                 spreadRadius: 1)
//           ],
//         ),
//         child: FloatingActionButton(
//           onPressed: () => Navigator.push(context,
//               MaterialPageRoute(builder: (_) => const ChatScreen())),
//           backgroundColor: _DS.bgCard,
//           elevation: 0,
//           shape: const CircleBorder(),
//           child: Container(
//             width: 56,
//             height: 56,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                   color: _DS.accent2.withOpacity(0.4), width: 1.5),
//             ),
//             child: const Center(
//               child: Icon(Icons.chat_bubble_rounded,
//                   color: _DS.accent2, size: 22),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ══════════════════════════════════════════════════════════════════════════════
// //  CUSTOM PAINTERS
// // ══════════════════════════════════════════════════════════════════════════════
//
// class _ScanRingPainter extends CustomPainter {
//   final Color color;
//   _ScanRingPainter({required this.color});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.5;
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2;
//     const dashCount = 12;
//     const dashAngle = 2 * math.pi / dashCount;
//     for (int i = 0; i < dashCount; i++) {
//       if (i % 2 == 0) {
//         canvas.drawArc(
//             Rect.fromCircle(center: center, radius: radius),
//             i * dashAngle,
//             dashAngle * 0.7,
//             false,
//             paint);
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(_ScanRingPainter old) => old.color != color;
// }
//
// /// Radial glow background for scan hero
// class _RadialGlowPainter extends CustomPainter {
//   final Color  color;
//   final double opacity;
//   _RadialGlowPainter({required this.color, required this.opacity});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final paint = Paint()
//       ..shader = RadialGradient(
//         colors: [color.withOpacity(opacity), Colors.transparent],
//       ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.65));
//     canvas.drawCircle(center, size.width * 0.65, paint);
//   }
//
//   @override
//   bool shouldRepaint(_RadialGlowPainter old) =>
//       old.opacity != opacity || old.color != color;
// }
//
// class _BgArcPainter extends CustomPainter {
//   final Color  color;
//   final double progress;
//   _BgArcPainter({required this.color, required this.progress});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color       = color.withOpacity(0.028)
//       ..style       = PaintingStyle.stroke
//       ..strokeWidth = 60;
//     final center = Offset(size.width * 1.08, size.height * 0.5);
//     canvas.drawArc(
//       Rect.fromCircle(center: center, radius: 190.0),
//       -math.pi / 2,
//       2 * math.pi * progress,
//       false,
//       paint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(_BgArcPainter old) =>
//       old.progress != progress || old.color != color;
// }
//
// // ══════════════════════════════════════════════════════════════════════════════
// //  MEAL SUGGESTION CARD
// // ══════════════════════════════════════════════════════════════════════════════
// class _MealSuggestionCard extends StatefulWidget {
//   final int carbsToday;
//   final int carbsGoal;
//   final int proteinToday;
//   final int proteinGoal;
//
//   const _MealSuggestionCard({
//     required this.carbsToday,
//     required this.carbsGoal,
//     required this.proteinToday,
//     required this.proteinGoal,
//   });
//
//   @override
//   State<_MealSuggestionCard> createState() => _MealSuggestionCardState();
// }
//
// class _MealSuggestionCardState extends State<_MealSuggestionCard>
//     with SingleTickerProviderStateMixin {
//   bool _expanded = false;
//   late AnimationController _ctrl;
//   late Animation<double> _anim;
//
//   String get _mealTitle {
//     if (widget.carbsGoal > 0 &&
//         widget.carbsToday / widget.carbsGoal > 0.9)
//       return "Leafy Green Salad + Egg";
//     if (widget.proteinGoal > 0 &&
//         widget.proteinToday / widget.proteinGoal < 0.4)
//       return "Greek Yogurt + Almonds";
//     return "Grilled Chicken & Quinoa";
//   }
//
//   String get _mealReason {
//     if (widget.carbsGoal > 0 &&
//         widget.carbsToday / widget.carbsGoal > 0.9)
//       return "Recommended because carbs exceeded today";
//     if (widget.proteinGoal > 0 &&
//         widget.proteinToday / widget.proteinGoal < 0.4)
//       return "Quick protein boost to hit your daily goal";
//     return "High protein, balanced carbs — perfect for your goal";
//   }
//
//   String get _whyText {
//     if (widget.carbsGoal > 0 &&
//         widget.carbsToday / widget.carbsGoal > 0.9)
//       return "You're close to your carb limit. A salad with eggs adds protein without overloading carbs — keeping your macros balanced.";
//     if (widget.proteinGoal > 0 &&
//         widget.proteinToday / widget.proteinGoal < 0.4)
//       return "Your protein intake is low. Greek yogurt provides ~17g protein per serving with healthy fats from almonds.";
//     return "Based on your current macros, you need more protein and moderate carbs. This meal provides ~40g protein and 45g complex carbs.";
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 320));
//     _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: _DS.bgCard,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(
//             color: _DS.neon.withOpacity(0.15), width: 1),
//         boxShadow: [
//           BoxShadow(
//               color: _DS.neon.withOpacity(0.06),
//               blurRadius: 16,
//               offset: const Offset(0, 4))
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(24),
//           splashColor: _DS.neon.withOpacity(0.04),
//           onTap: () {
//             setState(() {
//               _expanded = !_expanded;
//               _expanded ? _ctrl.forward() : _ctrl.reverse();
//             });
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(18),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: _DS.neonFaint,
//                         borderRadius: BorderRadius.circular(14),
//                         border: Border.all(
//                             color: _DS.neon.withOpacity(0.2),
//                             width: 1),
//                       ),
//                       child: const Icon(
//                           Icons.restaurant_menu_rounded,
//                           color: _DS.neon,
//                           size: 20),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(_mealTitle,
//                               style: const TextStyle(
//                                   color: _DS.textPrimary,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w800,
//                                   letterSpacing: -0.2)),
//                           const SizedBox(height: 3),
//                           Text(_mealReason,
//                               style: const TextStyle(
//                                   color: _DS.textMuted,
//                                   fontSize: 11.5,
//                                   fontWeight: FontWeight.w500)),
//                         ],
//                       ),
//                     ),
//                     AnimatedRotation(
//                       turns: _expanded ? 0.5 : 0,
//                       duration: const Duration(milliseconds: 320),
//                       child: const Icon(
//                           Icons.keyboard_arrow_down_rounded,
//                           color: _DS.neon,
//                           size: 22),
//                     ),
//                   ],
//                 ),
//                 SizeTransition(
//                   sizeFactor: _anim,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 14),
//                       Container(height: 1, color: _DS.borderFaint),
//                       const SizedBox(height: 14),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Icon(Icons.info_outline_rounded,
//                               color: _DS.neon.withOpacity(0.6),
//                               size: 15),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(_whyText,
//                                 style: const TextStyle(
//                                     color: _DS.textSecondary,
//                                     fontSize: 12.5,
//                                     height: 1.55,
//                                     fontWeight: FontWeight.w400)),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 14),
//                       Row(
//                         children: [
//                           _suggestionBtn("Why?",
//                               Icons.help_outline_rounded, _DS.neon),
//                           const SizedBox(width: 8),
//                           _suggestionBtn("Swap",
//                               Icons.swap_horiz_rounded, _DS.accent1),
//                           const SizedBox(width: 8),
//                           _suggestionBtn("Add to Plan",
//                               Icons.add_rounded, _DS.accent2),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (!_expanded) ...[
//                   const SizedBox(height: 10),
//                   Row(children: const [
//                     Icon(Icons.touch_app_rounded,
//                         color: _DS.textMuted, size: 11),
//                     SizedBox(width: 4),
//                     Text("Tap to learn why",
//                         style: TextStyle(
//                             color: _DS.textMuted,
//                             fontSize: 11,
//                             fontWeight: FontWeight.w500)),
//                   ]),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _suggestionBtn(String label, IconData icon, Color color) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//               color: color.withOpacity(0.2), width: 1),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 13, color: color),
//             const SizedBox(width: 4),
//             Text(label,
//                 style: TextStyle(
//                     color: color,
//                     fontSize: 11,
//                     fontWeight: FontWeight.w700)),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
////////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart'; // ADD THIS IMPORT
import 'foodupload.dart';
import 'viewProfile.dart';
import 'uploadFood.dart';
import 'changePassword.dart';
import 'healthProfile.dart';
import 'viewHealth.dart';
import 'login/src/loginPage.dart';
import 'feedBack.dart';
import 'chatbot.dart';
import 'ingredients.dart';
import 'suggestion.dart';
import 'dart:async';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: UserHome(),
  ));
}

// ══════════════════════════════════════════════════════════════════════════════
//  DESIGN TOKENS
// ══════════════════════════════════════════════════════════════════════════════
class _DS {
  static const bg         = Color(0xFF050D0A);
  static const bgCard     = Color(0xFF0C1A13);
  static const bgCardAlt  = Color(0xFF0A1510);
  static const surface    = Color(0xFF0F2018);
  static const surfaceAlt = Color(0xFF122318);

  static const neon      = Color(0xFF00FF88);
  static const neonDim   = Color(0xFF00C46A);
  static const neonFaint = Color(0xFF003D22);

  static const accent1 = Color(0xFF00E5FF);
  static const accent2 = Color(0xFFB2FF59);
  static const accent3 = Color(0xFFFF6B6B);
  static const accent4 = Color(0xFFFFD166);
  static const accent5 = Color(0xFFA78BFA);

  static const textPrimary   = Color(0xFFF0FFF8);
  static const textSecondary = Color(0xFF6EE7B7);
  static const textMuted     = Color(0xFF2E6B4A);

  // Reduced border opacity for friendlier look
  static const borderFaint = Color(0xFF112B1E);
}

// ══════════════════════════════════════════════════════════════════════════════
//  SETTINGS SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _DS.bg,
      appBar: AppBar(
        backgroundColor: _DS.bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context); // FIXED: Added navigation
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _DS.surface,
              shape: BoxShape.circle,
              border: Border.all(color: _DS.borderFaint, width: 1),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: _DS.neon, size: 20),
          ),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
              color: _DS.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SettingsTile(
            icon: Icons.person_rounded,
            label: "View Profile",
            subtitle: "Edit your personal information",
            color: _DS.accent5,
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ViewProfilePage())),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.lock_reset_rounded,
            label: "Change Password",
            subtitle: "Update your account password",
            color: _DS.accent1,
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ChangePasswordPage())),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.rate_review_rounded,
            label: "Feedback",
            subtitle: "Share your thoughts with us",
            color: _DS.accent3,
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const FeedbackScreen())),
          ),
          _SettingsTile(
            icon: Icons.rate_review_rounded,
            label: "Check",
            subtitle: "check food",
            color: _DS.accent3,
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const FoodUploadScreen(title: '',))),
          ),
          const SizedBox(height: 32),
          Container(height: 1, color: _DS.borderFaint),
          const SizedBox(height: 24),
          _SettingsTile(
            icon: Icons.logout_rounded,
            label: "Logout",
            subtitle: "Sign out of your account",
            color: _DS.textMuted,
            onTap: () async {
              // final prefs = await SharedPreferences.getInstance();
              // await prefs.clear();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                    (route) => false, // This removes all previous routes
              );
              // Navigator.pushReplacement(
              //     context, MaterialPageRoute(builder: (_) => LoginPage()));
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _DS.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.15), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: _DS.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: _DS.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _DS.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  INSIGHTS SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class _InsightsScreen extends StatelessWidget {
  final int caloriesToday;
  final int caloriesGoal;
  final int proteinToday;
  final int proteinGoal;
  final int carbsToday;
  final int carbsGoal;
  final int fatToday;
  final int fatGoal;
  final int streakDays;
  final List<Map<String, dynamic>> insights;

  const _InsightsScreen({
    required this.caloriesToday,
    required this.caloriesGoal,
    required this.proteinToday,
    required this.proteinGoal,
    required this.carbsToday,
    required this.carbsGoal,
    required this.fatToday,
    required this.fatGoal,
    required this.streakDays,
    required this.insights,
  });

  Color get _ringColor {
    if (caloriesGoal <= 0) return _DS.neon;
    final p = caloriesToday / caloriesGoal;
    if (p > 1.0) return _DS.accent3;
    if (p >= 0.8) return _DS.accent4;
    return _DS.neon;
  }

  Color _macroStatusColor(int cur, int goal) {
    if (goal <= 0) return _DS.textMuted;
    final p = cur / goal;
    if (p < 0.5) return _DS.accent4;
    if (p > 1.1) return _DS.accent3;
    return _DS.neon;
  }

  String _macroStatusLabel(int cur, int goal) {
    if (goal <= 0) return "—";
    final p = cur / goal;
    if (p < 0.5) return "Low";
    if (p > 1.1) return "Excess";
    return "Optimal";
  }

  bool get _hasHealthAlerts =>
      (carbsGoal > 0 && carbsToday / carbsGoal > 1.1) ||
          (proteinGoal > 0 && proteinToday / proteinGoal < 0.4) ||
          (fatGoal > 0 && fatToday / fatGoal > 1.1);

  @override
  Widget build(BuildContext context) {
    final pct       = caloriesGoal > 0 ? (caloriesToday / caloriesGoal) : 0.0;
    final remaining = caloriesGoal - caloriesToday;
    final isOver    = pct > 1.0;

    return Scaffold(
      backgroundColor: _DS.bg,
      appBar: AppBar(
        backgroundColor: _DS.bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _DS.surface,
              shape: BoxShape.circle,
              border: Border.all(color: _DS.borderFaint, width: 1),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: _DS.neon, size: 20),
          ),
        ),
        title: const Text(
          "Nutrition Insights",
          style: TextStyle(
              color: _DS.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 48),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: _DS.bgCard,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                  color: _ringColor.withOpacity(isOver ? 0.35 : 0.18), width: 1),
              boxShadow: [
                BoxShadow(
                    color: _ringColor.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  height: 110,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: pct.clamp(0.0, 1.0),
                        strokeWidth: 10,
                        backgroundColor: _ringColor.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(_ringColor),
                        strokeCap: StrokeCap.round,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("${(pct * 100).toInt()}%",
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: _ringColor)),
                          const Text("of goal",
                              style: TextStyle(fontSize: 9, color: _DS.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Daily Calories",
                          style: TextStyle(
                              color: _DS.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: "$caloriesToday",
                            style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: _DS.textPrimary,
                                letterSpacing: -1.5),
                          ),
                          TextSpan(
                            text: " / $caloriesGoal kcal",
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _DS.textMuted),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _ringColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: _ringColor.withOpacity(0.2), width: 1),
                        ),
                        child: Text(
                          isOver
                              ? "Over by ${remaining.abs()} kcal ⚠"
                              : remaining > 0
                              ? "$remaining kcal remaining"
                              : "Goal Achieved 🎉",
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _ringColor),
                        ),
                      ),
                      if (streakDays > 0) ...[
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.local_fire_department,
                              size: 13, color: _DS.accent3),
                          const SizedBox(width: 4),
                          Text("$streakDays-day streak",
                              style: const TextStyle(
                                  color: _DS.accent3,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ]),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // if (_hasHealthAlerts) ...[
          //   _sectionLabel("Health Alerts", Icons.warning_amber_rounded, _DS.accent3),
          //   const SizedBox(height: 12),
          //   _buildHealthAlertsCarousel(),
          //   const SizedBox(height: 22),
          // ],

          _sectionLabel("Macronutrients", Icons.pie_chart_rounded, _DS.accent1),
          const SizedBox(height: 12),
          _macroBar("Protein", proteinToday, proteinGoal,
              const Color(0xFFF97316), Icons.fitness_center_rounded),
          const SizedBox(height: 10),
          _macroBar("Carbs", carbsToday, carbsGoal,
              const Color(0xFF3B82F6), Icons.bolt_rounded),
          const SizedBox(height: 10),
          _macroBar("Fats", fatToday, fatGoal,
              const Color(0xFFA855F7), Icons.opacity_rounded),
          const SizedBox(height: 22),

          // _sectionLabel("AI Insights", Icons.auto_awesome_rounded, _DS.neon),
          // const SizedBox(height: 12),
          // _buildInsightsCarousel(),
          // const SizedBox(height: 22),

          _sectionLabel("Weekly Snapshot", Icons.insights_rounded, _DS.accent1),
          const SizedBox(height: 12),
          _buildWeeklySnapshot(),
          const SizedBox(height: 22),

          // _sectionLabel("Suggested for You", Icons.restaurant_menu_rounded, _DS.accent2),
          // const SizedBox(height: 12),
          // const _MealSuggestionCard( // FIXED: Added const and proper parameters
          //   carbsToday: 0,
          //   carbsGoal: 0,
          //   proteinToday: 0,
          //   proteinGoal: 0,
          // ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.15), width: 1),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: _DS.textPrimary,
                letterSpacing: -0.3)),
      ],
    );
  }

  Widget _buildHealthAlertsCarousel() {
    final alerts = <Map<String, dynamic>>[];
    if (carbsGoal > 0 && carbsToday / carbsGoal > 1.1)
      alerts.add({
        'title': 'Carb Overload',
        'suggestion': 'Reduce refined carbs today',
        'color': _DS.accent3,
        'icon': Icons.bolt_rounded,
      });
    if (proteinGoal > 0 && proteinToday / proteinGoal < 0.4)
      alerts.add({
        'title': 'Low Protein',
        'suggestion': 'Add a protein-rich meal soon',
        'color': _DS.accent4,
        'icon': Icons.fitness_center_rounded,
      });
    if (fatGoal > 0 && fatToday / fatGoal > 1.1)
      alerts.add({
        'title': 'Fat Excess',
        'suggestion': 'Avoid fried or oily foods',
        'color': _DS.accent4,
        'icon': Icons.opacity_rounded,
      });

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: alerts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final a = alerts[i];
          final c = a['color'] as Color;
          return Container(
            width: 200,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _DS.bgCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.withOpacity(0.2), width: 1),
            ),
            child: Row(
              children: [
                Container(
                    width: 6,
                    height: 48,
                    decoration: BoxDecoration(
                        color: c, borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(children: [
                        Icon(a['icon'] as IconData, size: 13, color: c),
                        const SizedBox(width: 4),
                        Text(a['title'] as String,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: c)),
                      ]),
                      const SizedBox(height: 4),
                      Text(a['suggestion'] as String,
                          style: const TextStyle(
                              fontSize: 11, color: _DS.textMuted, height: 1.3)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _macroBar(
      String label, int current, int goal, Color color, IconData icon) {
    final progress    = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final statusColor = _macroStatusColor(current, goal);
    final statusLabel = _macroStatusLabel(current, goal);
    final pct         = goal > 0 ? (current / goal * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: _DS.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    Row(children: [
                      Text("$current/$goal g",
                          style: const TextStyle(
                              color: _DS.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: statusColor.withOpacity(0.2), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Text(statusLabel,
                                style: TextStyle(
                                    color: statusColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text("$pct%",
                          style: TextStyle(
                              color: color,
                              fontSize: 13,
                              fontWeight: FontWeight.w800)),
                    ]),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(statusColor),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCarousel() {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: insights.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final insight = insights[index];
          final c       = insight['color'] as Color;
          return Container(
            width: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _DS.bgCard,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: c.withOpacity(0.18), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: c.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(insight['icon'] as IconData, color: c, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(insight['title'] as String,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: c),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(insight['message'] as String,
                          style: const TextStyle(
                              fontSize: 11,
                              color: _DS.textMuted,
                              height: 1.35),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklySnapshot() {
    final mockData = [
      0.60, 0.80, 0.75, 0.90, 0.70, 0.85,
      caloriesGoal > 0
          ? (caloriesToday / caloriesGoal).clamp(0.0, 1.0)
          : 0.0,
    ];
    const days  = ["M", "T", "W", "T", "F", "S", "S"];
    final today = DateTime.now().weekday - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _DS.accent1.withOpacity(0.12), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final val     = i < mockData.length ? mockData[i] : 0.0;
              final isToday = i == today;
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isToday)
                    Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                            color: _DS.neon, shape: BoxShape.circle))
                  else
                    const SizedBox(height: 5),
                  const SizedBox(height: 3),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutBack,
                    width: 28,
                    height: (val * 64).clamp(6.0, 64.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: isToday
                            ? [_DS.neonDim, _DS.neon]
                            : [_DS.neonFaint, _DS.neon.withOpacity(0.25)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    days[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                      isToday ? FontWeight.w900 : FontWeight.w500,
                      color: isToday ? _DS.neon : _DS.textMuted,
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: _DS.borderFaint),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _sparkStat(
                  "Avg Cal", "${(caloriesToday * 0.9).toInt()} kcal", _DS.neon),
              _sparkStat("Best Day", "Day ${today + 1}", _DS.accent1),
              _sparkStat("Streak", "$streakDays days", _DS.accent3),
            ],
          ),
        ],
      ),
    );
  }

  Future<List<double>> fetchWeeklyCalories() async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString('url') ?? '';
    final lid = prefs.getString('lid') ?? '';

    final response = await http.post(
      Uri.parse('$baseUrl/find_daily_intake/'),
      body: {"lid": lid},
    );

    final data = jsonDecode(response.body);

    if (data["status"] == "ok") {
      List week = data["week_data"];
      return week.map<double>((d) {
        double cal = (d["calories"] ?? 0).toDouble();
        return (cal / caloriesGoal).clamp(0.0, 1.0);
      }).toList();
    }
    return [];
  }

  Widget _sparkStat(String label, String value, Color color) => Column(
    children: [
      Text(value,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w900, color: color)),
      const SizedBox(height: 2),
      Text(label,
          style: const TextStyle(
              fontSize: 10,
              color: _DS.textMuted,
              fontWeight: FontWeight.w500)),
    ],
  );
}

// ══════════════════════════════════════════════════════════════════════════════
//  HOME  SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  String  username            = "User";
  String? profilePhotoUrl;
  String  healthProfileStatus = "no";
  String  userGender          = ""; // "male" or "female" from profile data

  int    caloriesGoal = 0;
  int    proteinGoal  = 0;
  int    carbsGoal    = 0;
  int    fatGoal      = 0;
  double waterGoal    = 2.5;
  String goalMode     = "balanced";

  int    caloriesToday = 0;
  int    proteinToday  = 0;
  int    carbsToday    = 0;
  int    fatToday      = 0;
  double waterLiters   = 0.0;

  int                        streakDays = 0;
  List<Map<String, dynamic>> insights   = [];

  // Add missing state variables
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  String name = '';
  String photoUrl = '';

  // ── Animation controllers ──────────────────────────────────────────────────
  late AnimationController _animCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _scanRingCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _slideAnim;
  late Animation<double>   _pulseAnim;
  late Animation<double>   _glowAnim;
  late Animation<double>   _scanRingAnim;

  // ── Computed ───────────────────────────────────────────────────────────────
  Color get _headerGlowColor {
    if (caloriesGoal <= 0) return _DS.neon;
    final p = caloriesToday / caloriesGoal;
    if (p > 1.0) return _DS.accent3;
    if (p >= 0.8) return _DS.accent4;
    return _DS.neon;
  }

  String get _calStatusText {
    if (caloriesGoal <= 0) return '';
    final p = caloriesToday / caloriesGoal;
    if (p > 1.0)  return 'Over Limit ⚠';
    if (p >= 1.0) return 'Goal Achieved 🎉';
    if (p >= 0.8) return 'Nearing Limit';
    return 'On Track';
  }

  Color get _calStatusColor {
    if (caloriesGoal <= 0) return _DS.neon;
    final p = caloriesToday / caloriesGoal;
    if (p > 1.0)  return _DS.accent3;
    if (p >= 1.0) return _DS.accent1;
    if (p >= 0.8) return _DS.accent4;
    return _DS.neon;
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return "Good morning";
    if (h < 17) return "Good afternoon";
    return "Good evening";
  }

  String get _goalLabel {
    switch (goalMode) {
      case 'weight_gain': return "⚡ Weight Gain Mode";
      case 'fat_loss':    return "🎯 Fat Loss Mode";
      case 'diabetic':    return "💊 Diabetic Mode";
      default:            return "🌱 Balanced Mode";
    }
  }

  int get _healthScore {
    if (caloriesGoal == 0) return 72;
    int s = 100;
    final cp = caloriesToday / caloriesGoal;
    if (cp > 1.15)       s -= 25;
    else if (cp > 1.0)   s -= 10;
    if (proteinGoal > 0 && proteinToday / proteinGoal < 0.5)   s -= 15;
    if (carbsGoal   > 0 && carbsToday   / carbsGoal   > 1.15)  s -= 20;
    if (fatGoal     > 0 && fatToday     / fatGoal     > 1.15)  s -= 15;
    if (streakDays >= 7) s = (s + 5).clamp(0, 100);
    return s.clamp(0, 100);
  }

  Color get _healthScoreColor {
    final s = _healthScore;
    if (s >= 80) return _DS.neon;
    if (s >= 60) return _DS.accent4;
    return _DS.accent3;
  }

  /// Returns gender-aware avatar icon
  IconData get _genderAvatarIcon {
    final g = userGender.toLowerCase();
    if (g == 'female' || g == 'f' || g == 'woman') {
      return Icons.face_3_rounded; // female face icon
    }
    return Icons.face_rounded; // male/default face icon
  }

  bool get _isFemale {
    final g = userGender.toLowerCase();
    return g == 'female' || g == 'f' || g == 'woman';
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _loadGoals();
    _fetchTodayNutrition();
    _fetchStreak();


    Timer.periodic(Duration(seconds: 5),(timer){

      _loadGoals();
    });

    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnim  = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _slideAnim = Tween<double>(begin: 40.0, end: 0.0).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.25, end: 0.75).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _scanRingCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat();
    _scanRingAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _scanRingCtrl, curve: Curves.linear));

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _pulseCtrl.dispose();
    _glowCtrl.dispose();
    _scanRingCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchProfileData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final baseUrl = prefs.getString('url') ?? '';
      final lid = prefs.getString('lid') ?? '';
      final imgBase = prefs.getString('img') ?? '';

      if (baseUrl.isEmpty || lid.isEmpty) {
        throw Exception('Missing URL or user ID');
      }

      final uri = Uri.parse('$baseUrl/view_profile/');

      final response = await http.post(
        uri,
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'ok') {
          setState(() {
            name = data['Name']?.toString() ?? '—';
            username = name;
            photoUrl = '$imgBase${data['Photo']?.toString() ?? ''}';
            profilePhotoUrl = photoUrl.isNotEmpty ? photoUrl : null;
          });
        } else {
          setState(() {
            _hasError = true;
            _errorMessage = data['message'] ?? 'Profile not found';
          });
        }
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Server error (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      Fluttertoast.showToast(
        msg: _errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString('url') ?? '';
    final lid = prefs.getString('lid') ?? '';

    print('Loading goals - URL: $baseUrl, LID: $lid');

    if (baseUrl.isEmpty || lid.isEmpty) return;

    try {
      final r = await http.post(
          Uri.parse('$baseUrl/userviewhishealth/'),
          body: {'lid': lid}
      );

      print('Response status: ${r.statusCode}');
      print('Response body: ${r.body}');

      if (r.statusCode == 200) {
        final d = jsonDecode(r.body);
        if (d['status'] == 'ok') {
          setState(() {
            caloriesGoal = int.tryParse(d['healthvalue']?.toString() ?? '2000') ?? 2000;
            proteinGoal = int.tryParse(d['protienvalue']?.toString() ?? '100') ?? 100;
            carbsGoal = int.tryParse(d['carbvalue']?.toString() ?? '250') ?? 250;
            fatGoal = int.tryParse(d['fatvalue']?.toString() ?? '70') ?? 70;
            goalMode = 'balanced';
          });
          _generateInsights();
        } else {
          print('Health profile not found for LID: $lid');
        }
      }
    } catch (e) {
      print('Error loading goals: $e');
    }
  }

  Future<void> _fetchTodayNutrition() async {
    final prefs = await SharedPreferences.getInstance();
    final lid = prefs.getString("lid");
    final baseUrl = prefs.getString("url");

    if (lid == null || baseUrl == null) return;

    try {
      print('Fetching today nutrition for LID: $lid');
      final r = await http.post(
          Uri.parse("$baseUrl/today_nutrition_summary/"),
          body: {"lid": lid}
      );

      print('Nutrition response: ${r.body}');

      if (r.statusCode == 200) {
        final d = jsonDecode(r.body);
        if (d["status"] == "ok") {
          setState(() {
            proteinToday = (d["total_protein"] as num?)?.round() ?? 0;
            carbsToday = (d["total_carbs"] as num?)?.round() ?? 0;
            fatToday = (d["total_fat"] as num?)?.round() ?? 0;
            caloriesToday = (d["total_calories"] as num?)?.round() ?? 0;
          });
          _generateInsights();
        }
      }
    } catch (e) {
      print("Nutrition fetch error: $e");
    }
  }

  Future<void> _fetchStreak() async {
    final prefs   = await SharedPreferences.getInstance();
    final lid     = prefs.getString("lid");
    final baseUrl = prefs.getString("url");
    if (lid == null || baseUrl == null) return;
    try {
      final r = await http.post(
          Uri.parse("$baseUrl/get_streak/"), body: {"lid": lid});
      if (r.statusCode == 200) {
        final d = jsonDecode(r.body);
        if (d["status"] == "ok") {
          setState(
                  () => streakDays = (d["streak"] as num?)?.toInt() ?? 0);
          _generateInsights();
        }
      }
    } catch (e) {
      debugPrint("Streak fetch error: $e");
    }
  }

  void _generateInsights() {
    final List<Map<String, dynamic>> n = [];
    if (proteinGoal > 0) {
      final p = proteinToday / proteinGoal;
      if (p < 0.5)
        n.add({
          'title': 'Low Protein',
          'message': 'Try eggs, chicken, lentils or Greek yogurt',
          'icon': Icons.egg_alt,
          'color': _DS.accent4,
        });
      else if (p >= 1.0)
        n.add({
          'title': 'Protein Goal Met!',
          'message': 'Excellent protein intake today',
          'icon': Icons.emoji_events,
          'color': _DS.neon,
        });
    }
    if (caloriesGoal > 0) {
      final p = caloriesToday / caloriesGoal;
      if (p >= 1.0)
        n.add({
          'title': 'Calorie Goal Reached',
          'message': "You hit your daily target — great job!",
          'icon': Icons.check_circle,
          'color': _DS.accent5,
        });
      else if (p > 0.85)
        n.add({
          'title': 'Almost There',
          'message': 'Just a bit more to reach your goal',
          'icon': Icons.timeline,
          'color': _DS.accent1,
        });
    }
    if (streakDays >= 3)
      n.add({
        'title': '🔥 $streakDays-Day Streak',
        'message': streakDays > 14 ? 'Incredible consistency!' : 'Keep going!',
        'icon': Icons.local_fire_department,
        'color': _DS.accent3,
      });
    if (waterLiters < waterGoal * 0.4)
      n.add({
        'title': 'Hydration Check',
        'message': 'Time to drink some water',
        'icon': Icons.water_drop,
        'color': _DS.accent1,
      });
    if (n.length < 2) {
      final sug = [
        {
          'title': 'Meal Idea',
          'message': 'Grilled chicken salad bowl',
          'icon': Icons.restaurant,
          'color': _DS.neonDim,
        },
        {
          'title': 'Quick Snack',
          'message': 'Greek yogurt + berries',
          'icon': Icons.yard,
          'color': _DS.accent5,
        },
        {
          'title': 'Healthy Option',
          'message': 'Oats with nuts & banana',
          'icon': Icons.free_breakfast,
          'color': _DS.accent1,
        },
      ];
      n.add(sug[DateTime.now().millisecondsSinceEpoch % 3]);
    }
    setState(() => insights = n);
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      _fetchProfileData(),
      _loadGoals(),
      _fetchTodayNutrition(),
      _fetchStreak(),
    ]);
  }

  void _openInsights() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _InsightsScreen(
          caloriesToday: caloriesToday,
          caloriesGoal: caloriesGoal,
          proteinToday: proteinToday,
          proteinGoal: proteinGoal,
          carbsToday: carbsToday,
          carbsGoal: carbsGoal,
          fatToday: fatToday,
          fatGoal: fatGoal,
          streakDays: streakDays,
          insights: insights,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: _DS.bg,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: _buildChatbotFAB(),
          body: SafeArea(
            child: RefreshIndicator(
              color: _DS.neon,
              backgroundColor: _DS.bgCard,
              onRefresh: _onRefresh,
              child: AnimatedBuilder(
                animation: _animCtrl,
                builder: (_, child) => Opacity(
                  opacity: _fadeAnim.value,
                  child: Transform.translate(
                      offset: Offset(0, _slideAnim.value), child: child),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Top bar ─────────────────────────────────────────────
                      const SizedBox(height: 8),
                      _buildTopBar(),

                      // ── 1. Greeting card ────────────────────────────────────
                      const SizedBox(height: 10),
                      _buildSmartHeader(),

                      // ── 2. Scan + Actions unified hero block ─────────────────
                      const SizedBox(height: 10),
                      _buildScanHeroBlock(),

                      // ── 3. Calorie dashboard (Expanded to fill remaining) ────
                      const SizedBox(height: 10),
                      Expanded(child: _buildCalorieDashboard()),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  TOP BAR
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTopBar() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _glowAnim,
          builder: (_, __) => Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: _DS.neonFaint,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _DS.neon.withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(
                    color: _DS.neon.withOpacity(_glowAnim.value * 0.18),
                    blurRadius: 16,
                    spreadRadius: -2)
              ],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.camera_enhance_rounded,
                  color: _DS.neon, size: 15),
              const SizedBox(width: 5),
              const Text("FoodSnap AI",
                  style: TextStyle(
                      color: _DS.neon,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4)),
            ]),
          ),
        ),
        const Spacer(),
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _healthScoreColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: _healthScoreColor.withOpacity(0.2), width: 1),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.monitor_heart_rounded,
                size: 13, color: _healthScoreColor),
            const SizedBox(width: 4),
            Text("$_healthScore",
                style: TextStyle(
                    color: _healthScoreColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800)),
          ]),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const _SettingsScreen()))
                .then((_) => _fetchProfileData());
          },
          child: Container(
            decoration: BoxDecoration(
              color: _DS.surface,
              shape: BoxShape.circle,
              border: Border.all(color: _DS.borderFaint, width: 1),
            ),
            padding: const EdgeInsets.all(9),
            child: const Icon(Icons.settings_rounded,
                color: _DS.neon, size: 19),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  1. SMART HEADER — with gender avatar
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSmartHeader() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => healthProfileStatus == "no"
                ? const AddHealthProfilePage()
                : const HealthProfilePage(),
          ),
        ).then((_) {
          _fetchProfileData();
          _loadGoals();
        });
      },
      child: AnimatedBuilder(
        animation: _glowAnim,
        builder: (_, __) => Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: _DS.bgCard,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: _headerGlowColor.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: _headerGlowColor
                    .withOpacity(_glowAnim.value * 0.12),
                blurRadius: 20,
                spreadRadius: -4,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              // Gender-aware avatar
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _isFemale
                        ? [const Color(0xFFFF80AB), const Color(0xFFF48FB1)]
                        : [_DS.neon, _DS.neonDim],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: _DS.surface,
                  backgroundImage: profilePhotoUrl != null
                      ? NetworkImage(profilePhotoUrl!)
                      : null,
                  child: profilePhotoUrl == null
                      ? Icon(
                    _genderAvatarIcon,
                    size: 22,
                    color: _isFemale
                        ? const Color(0xFFFF80AB)
                        : _DS.neon,
                  )
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_greeting,
                        style: const TextStyle(
                            color: _DS.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w500)),
                    Text(
                      name.split(' ').first,
                      style: const TextStyle(
                          color: _DS.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 3),
                    Row(children: [
                      _miniChip(_goalLabel, _DS.neon),
                      const SizedBox(width: 5),
                      _miniChip(_calStatusText, _calStatusColor),
                    ]),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _DS.neonFaint,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                          color: _DS.neon.withOpacity(0.2), width: 1),
                    ),
                    child: const Icon(Icons.health_and_safety_rounded,
                        color: _DS.neon, size: 17),
                  ),
                  const SizedBox(height: 2),
                  const Text("Health",
                      style: TextStyle(
                          color: _DS.neon,
                          fontSize: 8,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniChip(String text, Color color) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 9, fontWeight: FontWeight.w700)),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  2+3. UNIFIED SCAN HERO + QUICK ACTIONS BLOCK
  //  Large scan button on the left, 2×2 action grid on the right
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildScanHeroBlock() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnim, _scanRingAnim, _glowAnim]),
      builder: (_, __) => SizedBox(
        height: 148,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── LEFT: large scan CTA ────────────────────────────────────────
            Expanded(
              flex: 5,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const UploadFoodScreen()))
                      .then((_) => _fetchTodayNutrition());
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _DS.bgCard,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                        color: _DS.neon.withOpacity(0.22), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                          color: _DS.neon.withOpacity(_glowAnim.value * 0.28),
                          blurRadius: 32,
                          spreadRadius: -4,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ambient glow background
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: CustomPaint(
                            painter: _RadialGlowPainter(
                                color: _DS.neon,
                                opacity: _glowAnim.value * 0.06),
                          ),
                        ),
                      ),
                      // Rotating dashed ring
                      Transform.rotate(
                        angle: _scanRingAnim.value * 2 * math.pi,
                        child: CustomPaint(
                          size: const Size(96, 96),
                          painter: _ScanRingPainter(
                              color: _DS.neon.withOpacity(0.14)),
                        ),
                      ),
                      // Content
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scale: _pulseAnim.value,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    _DS.neon.withOpacity(0.22),
                                    _DS.neonFaint,
                                  ],
                                ),
                                border: Border.all(
                                    color: _DS.neon.withOpacity(0.5),
                                    width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                      color: _DS.neon.withOpacity(
                                          _glowAnim.value * 0.45),
                                      blurRadius: 22,
                                      spreadRadius: 2)
                                ],
                              ),
                              child: const Icon(Icons.camera_enhance_rounded,
                                  color: _DS.neon, size: 28),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text("SCAN FOOD",
                              style: TextStyle(
                                  color: _DS.neon,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.8)),
                          const SizedBox(height: 3),
                          const Text("AI nutrition analysis",
                              style: TextStyle(
                                  color: _DS.textMuted,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // ── RIGHT: 2×2 quick action grid ───────────────────────────────
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _quickActionTile(
                          icon: Icons.biotech_rounded,
                          label: 'Ingredient',
                          color: _DS.accent1,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => IngredientAIScreen())),
                        ),
                        const SizedBox(width: 8),
                        _quickActionTile(
                          icon: Icons.restaurant_menu_rounded,
                          label: 'Suggest',
                          color: _DS.accent2,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => DailySuggestionScreen())),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Row(
                      children: [
                        _quickActionTile(
                          icon: Icons.insights_rounded,
                          label: 'Insights',
                          color: _DS.accent4,
                          onTap: _openInsights,
                        ),
                        const SizedBox(width: 8),
                        _quickActionTile(
                          icon: Icons.settings_rounded,
                          label: 'Settings',
                          color: _DS.accent5,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const _SettingsScreen()))
                              .then((_) => _fetchProfileData()),
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

  Widget _quickActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.18), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2)),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  4. CALORIE DASHBOARD — fills remaining screen height richly
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildCalorieDashboard() {
    final pct       = caloriesGoal > 0 ? caloriesToday / caloriesGoal : 0.0;
    final progress  = pct.clamp(0.0, 1.0);
    final remaining = caloriesGoal - caloriesToday;
    final isOver    = pct > 1.0;

    Color ringColor;
    if (pct > 1.0)       ringColor = _DS.accent3;
    else if (pct >= 1.0) ringColor = _DS.accent1;
    else if (pct >= 0.8) ringColor = _DS.accent4;
    else                 ringColor = _DS.neon;

    return GestureDetector(
      onTap: _openInsights,
      child: AnimatedBuilder(
        animation: _glowAnim,
        builder: (_, __) => Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _DS.bgCard,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
                color: ringColor.withOpacity(isOver ? 0.35 : 0.18),
                width: 1),
            boxShadow: [
              BoxShadow(
                  color: ringColor.withOpacity(
                      isOver ? _glowAnim.value * 0.22 : 0.04),
                  blurRadius: isOver ? 30 : 14,
                  spreadRadius: -4,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: CustomPaint(
                      painter: _BgArcPainter(
                          color: ringColor, progress: progress)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Header row ──────────────────────────────────────────
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Daily Calories",
                                style: TextStyle(
                                    color: _DS.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.4)),
                            const SizedBox(height: 1),
                            Text("Goal: $caloriesGoal kcal",
                                style: const TextStyle(
                                    color: _DS.textMuted,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const Spacer(),
                        if (streakDays > 0)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _DS.accent3.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: _DS.accent3.withOpacity(0.2),
                                  width: 1),
                            ),
                            child: Row(children: [
                              const Icon(Icons.local_fire_department,
                                  size: 11, color: _DS.accent3),
                              const SizedBox(width: 3),
                              Text("$streakDays",
                                  style: const TextStyle(
                                      color: _DS.accent3,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800)),
                            ]),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: ringColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: ringColor.withOpacity(0.2),
                                width: 1),
                          ),
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.insights_rounded,
                                    size: 10, color: ringColor),
                                const SizedBox(width: 4),
                                Text("Details",
                                    style: TextStyle(
                                        color: ringColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700)),
                              ]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Ring + calorie number + status ──────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Large ring
                        SizedBox(
                          width: 130,
                          height: 130,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 130,
                                height: 130,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 13,
                                  backgroundColor:
                                  ringColor.withOpacity(0.1),
                                  valueColor:
                                  AlwaysStoppedAnimation(ringColor),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${(pct * 100).toInt()}%",
                                    style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        color: ringColor,
                                        letterSpacing: -1),
                                  ),
                                  Text(
                                    pct >= 1.0 ? "done" : "of goal",
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: _DS.textMuted,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),

                        // Calorie number + status pill
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: "$caloriesToday",
                                    style: const TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.w900,
                                        color: _DS.textPrimary,
                                        letterSpacing: -2.5),
                                  ),
                                  const TextSpan(
                                    text: "\nkcal",
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: _DS.textMuted),
                                  ),
                                ]),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: ringColor.withOpacity(0.12),
                                  borderRadius:
                                  BorderRadius.circular(12),
                                  border: Border.all(
                                      color: ringColor.withOpacity(0.25),
                                      width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isOver
                                          ? Icons.warning_rounded
                                          : remaining == 0
                                          ? Icons.check_circle_rounded
                                          : Icons.bolt_rounded,
                                      size: 12,
                                      color: ringColor,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      isOver
                                          ? "Over by ${remaining.abs()} kcal"
                                          : remaining > 0
                                          ? "$remaining left"
                                          : "Goal Hit! 🎉",
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: ringColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Divider ─────────────────────────────────────────────
                    Container(height: 1, color: _DS.borderFaint),
                    const SizedBox(height: 14),

                    // ── MACRO PROGRESS BARS (inline, compact) ───────────────
                    const Text("Macronutrients",
                        style: TextStyle(
                            color: _DS.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 10),
                    _inlineMacroBar("Protein", proteinToday, proteinGoal,
                        const Color(0xFFF97316)),
                    const SizedBox(height: 8),
                    _inlineMacroBar("Carbs", carbsToday, carbsGoal,
                        const Color(0xFF3B82F6)),
                    const SizedBox(height: 8),
                    _inlineMacroBar("Fats", fatToday, fatGoal,
                        const Color(0xFFA855F7)),

                    const SizedBox(height: 8),
                    Container(height: 1, color: _DS.borderFaint),
                    const SizedBox(height: 8),

                    // ── MINI WEEK BAR CHART ─────────────────────────────────
                    _buildMiniWeekChart(),

                    const Spacer(),

                    // ── Tap hint ────────────────────────────────────────────
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.touch_app_rounded,
                              color: _DS.textMuted, size: 10),
                          SizedBox(width: 4),
                          Text(
                            "Tap for full insights & AI recommendations",
                            style: TextStyle(
                                color: _DS.textMuted,
                                fontSize: 9,
                                fontWeight: FontWeight.w500),
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
      ),
    );
  }

  /// Compact single-line macro progress bar
  Widget _inlineMacroBar(
      String label, int current, int goal, Color color) {
    final pct = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final pctInt = goal > 0 ? (current / goal * 100).toInt() : 0;
    return Row(
      children: [
        SizedBox(
          width: 46,
          child: Text(label,
              style: const TextStyle(
                  color: _DS.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 7,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(
                  pctInt > 110 ? _DS.accent3 : pctInt < 40 ? _DS.accent4 : color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 50,
          child: Text("$current/$goal g",
              textAlign: TextAlign.right,
              style: TextStyle(
                  color: color.withOpacity(0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  /// Compact 7-day calorie bar chart inside the dashboard
  Widget _buildMiniWeekChart() {
    final mockData = [0.60, 0.80, 0.75, 0.90, 0.70, 0.85,
      caloriesGoal > 0 ? (caloriesToday / caloriesGoal).clamp(0.0, 1.0) : 0.0];
    const days = ["M", "T", "W", "T", "F", "S", "S"];
    final today = DateTime.now().weekday - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text("This Week",
            style: TextStyle(
                color: _DS.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3)),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final val     = i < mockData.length ? mockData[i] : 0.0;
              final isToday = i == today;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                    width: 20,
                    height: (val * 40).clamp(4.0, 40.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: isToday
                            ? [_DS.neonDim, _DS.neon]
                            : [_DS.neonFaint, _DS.neon.withOpacity(0.22)],
                      ),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: isToday
                          ? [
                        BoxShadow(
                            color: _DS.neon.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, -2))
                      ]
                          : [],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(days[i],
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight:
                          isToday ? FontWeight.w900 : FontWeight.w500,
                          color: isToday ? _DS.neon : _DS.textMuted)),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  // ── Chatbot FAB ────────────────────────────────────────────────────────────
  Widget _buildChatbotFAB() {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: _DS.accent2
                    .withOpacity(_glowAnim.value * 0.4),
                blurRadius: 20,
                spreadRadius: 1)
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ChatScreen())),
          backgroundColor: _DS.bgCard,
          elevation: 0,
          shape: const CircleBorder(),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: _DS.accent2.withOpacity(0.4), width: 1.5),
            ),
            child: const Center(
              child: Icon(Icons.chat_bubble_rounded,
                  color: _DS.accent2, size: 22),
            ),
          ),
        ),
      ),
    );
  }
} // ← THIS CLOSING BRACE WAS MISSING! FIXED

// ══════════════════════════════════════════════════════════════════════════════
//  CUSTOM PAINTERS (MOVED OUTSIDE _UserHomeState - TOP LEVEL)
// ══════════════════════════════════════════════════════════════════════════════

class _ScanRingPainter extends CustomPainter {
  final Color color;
  _ScanRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const dashCount = 12;
    const dashAngle = 2 * math.pi / dashCount;
    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius),
            i * dashAngle,
            dashAngle * 0.7,
            false,
            paint);
      }
    }
  }

  @override
  bool shouldRepaint(_ScanRingPainter old) => old.color != color;
}

/// Radial glow background for scan hero
class _RadialGlowPainter extends CustomPainter {
  final Color  color;
  final double opacity;
  _RadialGlowPainter({required this.color, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color.withOpacity(opacity), Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.65));
    canvas.drawCircle(center, size.width * 0.65, paint);
  }

  @override
  bool shouldRepaint(_RadialGlowPainter old) =>
      old.opacity != opacity || old.color != color;
}

class _BgArcPainter extends CustomPainter {
  final Color  color;
  final double progress;
  _BgArcPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color       = color.withOpacity(0.028)
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 60;
    final center = Offset(size.width * 1.08, size.height * 0.5);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 190.0),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_BgArcPainter old) =>
      old.progress != progress || old.color != color;
}

// ══════════════════════════════════════════════════════════════════════════════
//  MEAL SUGGESTION CARD
// ══════════════════════════════════════════════════════════════════════════════
class _MealSuggestionCard extends StatefulWidget {
  final int carbsToday;
  final int carbsGoal;
  final int proteinToday;
  final int proteinGoal;

  const _MealSuggestionCard({
    required this.carbsToday,
    required this.carbsGoal,
    required this.proteinToday,
    required this.proteinGoal,
  });

  @override
  State<_MealSuggestionCard> createState() => _MealSuggestionCardState();
}

class _MealSuggestionCardState extends State<_MealSuggestionCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _ctrl;
  late Animation<double> _anim;

  String get _mealTitle {
    if (widget.carbsGoal > 0 &&
        widget.carbsToday / widget.carbsGoal > 0.9)
      return "Leafy Green Salad + Egg";
    if (widget.proteinGoal > 0 &&
        widget.proteinToday / widget.proteinGoal < 0.4)
      return "Greek Yogurt + Almonds";
    return "Grilled Chicken & Quinoa";
  }

  String get _mealReason {
    if (widget.carbsGoal > 0 &&
        widget.carbsToday / widget.carbsGoal > 0.9)
      return "Recommended because carbs exceeded today";
    if (widget.proteinGoal > 0 &&
        widget.proteinToday / widget.proteinGoal < 0.4)
      return "Quick protein boost to hit your daily goal";
    return "High protein, balanced carbs — perfect for your goal";
  }

  String get _whyText {
    if (widget.carbsGoal > 0 &&
        widget.carbsToday / widget.carbsGoal > 0.9)
      return "You're close to your carb limit. A salad with eggs adds protein without overloading carbs — keeping your macros balanced.";
    if (widget.proteinGoal > 0 &&
        widget.proteinToday / widget.proteinGoal < 0.4)
      return "Your protein intake is low. Greek yogurt provides ~17g protein per serving with healthy fats from almonds.";
    return "Based on your current macros, you need more protein and moderate carbs. This meal provides ~40g protein and 45g complex carbs.";
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: _DS.neon.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
              color: _DS.neon.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          splashColor: _DS.neon.withOpacity(0.04),
          onTap: () {
            setState(() {
              _expanded = !_expanded;
              _expanded ? _ctrl.forward() : _ctrl.reverse();
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _DS.neonFaint,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: _DS.neon.withOpacity(0.2),
                            width: 1),
                      ),
                      child: const Icon(
                          Icons.restaurant_menu_rounded,
                          color: _DS.neon,
                          size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_mealTitle,
                              style: const TextStyle(
                                  color: _DS.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2)),
                          const SizedBox(height: 3),
                          Text(_mealReason,
                              style: const TextStyle(
                                  color: _DS.textMuted,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 320),
                      child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _DS.neon,
                          size: 22),
                    ),
                  ],
                ),
                SizeTransition(
                  sizeFactor: _anim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),
                      Container(height: 1, color: _DS.borderFaint),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: _DS.neon.withOpacity(0.6),
                              size: 15),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_whyText,
                                style: const TextStyle(
                                    color: _DS.textSecondary,
                                    fontSize: 12.5,
                                    height: 1.55,
                                    fontWeight: FontWeight.w400)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _suggestionBtn("Why?",
                              Icons.help_outline_rounded, _DS.neon),
                          const SizedBox(width: 8),
                          _suggestionBtn("Swap",
                              Icons.swap_horiz_rounded, _DS.accent1),
                          const SizedBox(width: 8),
                          _suggestionBtn("Add to Plan",
                              Icons.add_rounded, _DS.accent2),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!_expanded) ...[
                  const SizedBox(height: 10),
                  Row(children: const [
                    Icon(Icons.touch_app_rounded,
                        color: _DS.textMuted, size: 11),
                    SizedBox(width: 4),
                    Text("Tap to learn why",
                        style: TextStyle(
                            color: _DS.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                  ]),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _suggestionBtn(String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
