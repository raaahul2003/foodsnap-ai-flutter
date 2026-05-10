// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_gemini/flutter_gemini.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// // ╔══════════════════════════════════════════════════════════════════════════╗
// // ║  DESIGN TOKENS                                                           ║
// // ╚══════════════════════════════════════════════════════════════════════════╝
// class _DS {
//   static const bg           = Color(0xFF050D0A);
//   static const bgCard       = Color(0xFF0C1A13);
//   static const surface      = Color(0xFF0F2018);
//   static const neon         = Color(0xFF00FF88);
//   static const neonDim      = Color(0xFF00C46A);
//   static const neonFaint    = Color(0xFF003D22);
//   static const accent1      = Color(0xFF00E5FF);
//   static const accent2      = Color(0xFFB2FF59);
//   static const accent3      = Color(0xFFFF6B6B);
//   static const accent4      = Color(0xFFFFD166);
//   static const accent5      = Color(0xFFA78BFA);
//   static const textPrimary  = Color(0xFFF0FFF8);
//   static const textSecondary= Color(0xFF6EE7B7);
//   static const textMuted    = Color(0xFF2E6B4A);
//   static const borderFaint  = Color(0xFF1A3D2A);
// }
//
// // ╔══════════════════════════════════════════════════════════════════════════╗
// // ║  MESSAGE MODEL                                                           ║
// // ╚══════════════════════════════════════════════════════════════════════════╝
// class ChatMessage {
//   final String   text;
//   final bool     isUser;
//   final DateTime timestamp;
//   final bool     isError;
//   final String?  category; // 'health_score' | 'weekly' | 'whatif' | null
//
//   const ChatMessage({
//     required this.text,
//     required this.isUser,
//     required this.timestamp,
//     this.isError    = false,
//     this.category,
//   });
// }
//
// // ╔══════════════════════════════════════════════════════════════════════════╗
// // ║  USER HEALTH CONTEXT MODEL                                               ║
// // ╚══════════════════════════════════════════════════════════════════════════╝
// class HealthContext {
//   String age;
//   String weight;
//   String height;
//   String bmi;
//   String goal;
//   String disease;
//   String allergies;
//   String dailyCalorieTarget;
//   String caloriesConsumed;
//   String proteinConsumed;
//   String carbsConsumed;
//   String fatConsumed;
//   String weeklyCalories;
//   String consistencyScore;
//   String coachMode;
//
//   HealthContext({
//     this.age                 = '—',
//     this.weight              = '—',
//     this.height              = '—',
//     this.bmi                 = '—',
//     this.goal                = 'maintain',
//     this.disease             = 'None',
//     this.allergies           = 'None',
//     this.dailyCalorieTarget  = '2000',
//     this.caloriesConsumed    = '0',
//     this.proteinConsumed     = '0',
//     this.carbsConsumed       = '0',
//     this.fatConsumed         = '0',
//     this.weeklyCalories      = 'Not available',
//     this.consistencyScore    = 'Not available',
//     this.coachMode           = 'motivational',
//   });
// }
//
// // ╔══════════════════════════════════════════════════════════════════════════╗
// // ║  CHAT SCREEN                                                             ║
// // ╚══════════════════════════════════════════════════════════════════════════╝
// class ChatScreen extends StatefulWidget {
//   const ChatScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen>
//     with TickerProviderStateMixin {
//
//   // ── Controllers ───────────────────────────────────────────────────────────
//   final TextEditingController _textController  = TextEditingController();
//   final ScrollController       _scrollController = ScrollController();
//   final FocusNode              _focusNode       = FocusNode();
//   final List<ChatMessage>      _messages        = [];
//
//   // ── State ─────────────────────────────────────────────────────────────────
//   bool _isTyping       = false;
//   bool _isLoading      = false;
//   bool _isInitialized  = false;
//   bool _contextLoaded  = false;
//   String _coachMode    = 'motivational'; // motivational | friendly | strict
//
//   HealthContext _ctx = HealthContext();
//
//   // ── Quick prompts ─────────────────────────────────────────────────────────
//   final List<Map<String, String>> _quickPrompts = [
//     {'icon': '📊', 'label': 'Health Score',    'text': 'Generate my health score for today'},
//     {'icon': '📅', 'label': 'Weekly Summary',  'text': 'Give me a weekly nutrition summary'},
//     {'icon': '🍽️', 'label': 'Meal Ideas',      'text': 'Suggest healthy dinner ideas for tonight'},
//     {'icon': '⚡',  'label': 'Remaining Macros','text': 'What macros do I still need today?'},
//     {'icon': '🔄', 'label': 'Food Swap',       'text': 'Suggest healthy food swaps I can make'},
//     {'icon': '💪', 'label': 'Protein Plan',    'text': 'Help me hit my protein goal today'},
//   ];
//
//   // ── Animations ────────────────────────────────────────────────────────────
//   late AnimationController _typingCtrl;
//   late AnimationController _sendCtrl;
//   late AnimationController _glowCtrl;
//   late AnimationController _entryCtrl;
//   late Animation<double>   _glowAnim;
//   late Animation<double>   _entryAnim;
//
//   @override
//   void initState() {
//     super.initState();
//     _initAnims();
//     _initGemini();
//     _loadHealthContext();
//   }
//
//   void _initAnims() {
//     _typingCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 1500))
//       ..repeat();
//
//     _sendCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 200));
//
//     _glowCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 2600))
//       ..repeat(reverse: true);
//     _glowAnim = Tween<double>(begin: 0.2, end: 0.75)
//         .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
//
//     _entryCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 800));
//     _entryAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
//     _entryCtrl.forward();
//   }
//
//   @override
//   void dispose() {
//     _typingCtrl.dispose();
//     _sendCtrl.dispose();
//     _glowCtrl.dispose();
//     _entryCtrl.dispose();
//     _textController.dispose();
//     _scrollController.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }
//
//   // ── Init Gemini ───────────────────────────────────────────────────────────
//   Future<void> _initGemini() async {
//     try {
//       const apiKey = 'AIzaSyCX9zECZMJX3xKNl-icIXEkqcQ6dv17CJQ'; // replace with your key
//       Gemini.init(apiKey: apiKey, enableDebugging: false);
//       setState(() => _isInitialized = true);
//     } catch (e) {
//       setState(() => _isInitialized = false);
//     }
//   }
//
//   // ── Load health context from SharedPreferences + API ─────────────────────
//   Future<void> _loadHealthContext() async {
//     try {
//       final prefs   = await SharedPreferences.getInstance();
//       final baseUrl = prefs.getString('url') ?? '';
//       final lid     = prefs.getString('lid') ?? '';
//
//       // Load health profile fields
//       _ctx = HealthContext(
//         age:                prefs.getString('hp_age')          ?? '—',
//         weight:             prefs.getString('hp_weight')       ?? prefs.getString('weight') ?? '—',
//         height:             prefs.getString('hp_height')       ?? prefs.getString('height') ?? '—',
//         bmi:                prefs.getString('hp_bmi')          ?? '—',
//         goal:               prefs.getString('hp_goal')         ?? 'maintain',
//         disease:            prefs.getString('hp_disease')      ?? 'None',
//         allergies:          prefs.getString('hp_allergies')    ?? 'None',
//         dailyCalorieTarget: prefs.getString('calorie_target')  ?? '2000',
//         caloriesConsumed:   prefs.getString('calories_today')  ?? '0',
//         proteinConsumed:    prefs.getString('protein_today')   ?? '0',
//         carbsConsumed:      prefs.getString('carbs_today')     ?? '0',
//         fatConsumed:        prefs.getString('fat_today')       ?? '0',
//         weeklyCalories:     prefs.getString('weekly_calories') ?? 'Not available',
//         consistencyScore:   prefs.getString('consistency')     ?? 'Not available',
//         coachMode:          prefs.getString('coach_mode')      ?? 'motivational',
//       );
//       _coachMode = _ctx.coachMode;
//
//       // Try to fetch today's nutrition from API
//       if (baseUrl.isNotEmpty && lid.isNotEmpty) {
//         try {
//           final res = await http.post(
//             Uri.parse('$baseUrl/today_nutrition_summary/'),
//             body: {'lid': lid},
//           ).timeout(const Duration(seconds: 6));
//
//           if (res.statusCode == 200) {
//             final data = jsonDecode(res.body);
//             if (data['status'] == 'ok') {
//               // _ctx.caloriesConsumed = data['calories']?.toString() ?? _ctx.caloriesConsumed;
//               // _ctx.proteinConsumed  = data['protein']?.toString()  ?? _ctx.proteinConsumed;
//               // _ctx.carbsConsumed    = data['carbs']?.toString()    ?? _ctx.carbsConsumed;
//               // _ctx.fatConsumed      = data['fat']?.toString()      ?? _ctx.fatConsumed;
//
//               _ctx.caloriesConsumed =
//                   data['total_calories']?.toString() ?? _ctx.caloriesConsumed;
//
//               _ctx.proteinConsumed =
//                   data['total_protein']?.toString() ?? _ctx.proteinConsumed;
//
//               _ctx.carbsConsumed =
//                   data['total_carbs']?.toString() ?? _ctx.carbsConsumed;
//
//               _ctx.fatConsumed =
//                   data['total_fat']?.toString() ?? _ctx.fatConsumed;
//             }
//           }
//         } catch (_) {
//           // API unavailable — use cached prefs values
//         }
//       }
//
//       setState(() => _contextLoaded = true);
//       _addWelcomeMessage();
//
//     } catch (e) {
//       setState(() => _contextLoaded = true);
//       _addWelcomeMessage();
//     }
//   }
//
//   // ── Welcome message ───────────────────────────────────────────────────────
//   void _addWelcomeMessage() {
//     Future.delayed(const Duration(milliseconds: 400), () {
//       if (!mounted) return;
//       final calLeft = (int.tryParse(_ctx.dailyCalorieTarget) ?? 2000) -
//           (int.tryParse(_ctx.caloriesConsumed)   ?? 0);
//       setState(() {
//         _messages.add(ChatMessage(
//           text: "👋 Hey! I'm **NutriBot**, your FoodSnap AI health copilot.\n\n"
//               "📊 **Today's snapshot:**\n"
//               "• Calories consumed: ${_ctx.caloriesConsumed} / ${_ctx.dailyCalorieTarget} kcal\n"
//               "• Remaining: $calLeft kcal\n"
//               "• Protein: ${_ctx.proteinConsumed}g | Carbs: ${_ctx.carbsConsumed}g | Fat: ${_ctx.fatConsumed}g\n\n"
//               "Ask me anything — meal ideas, health score, what-if analysis, or how you're doing today! 💪",
//           isUser:    false,
//           timestamp: DateTime.now(),
//         ));
//       });
//     });
//   }
//
//   // ── Build system prompt ───────────────────────────────────────────────────
//   String _buildSystemPrompt() {
//     return """
// You are "FoodSnap AI – Intelligent Nutrition Copilot", an advanced AI health and nutrition assistant integrated inside a smart calorie tracking application.
// You are NOT a general chatbot. You are a personalized health-aware AI coach.
//
// ========================
// USER HEALTH PROFILE
// ========================
// Age: ${_ctx.age}
// Weight: ${_ctx.weight} kg
// Height: ${_ctx.height} cm
// BMI: ${_ctx.bmi}
// Goal: ${_ctx.goal}  (muscle_gain / fat_loss / maintain)
// Disease: ${_ctx.disease}
// Allergies: ${_ctx.allergies}
//
// ========================
// TODAY'S NUTRITION STATUS
// ========================
// Calorie Target: ${_ctx.dailyCalorieTarget} kcal
// Calories Consumed: ${_ctx.caloriesConsumed} kcal
// Protein: ${_ctx.proteinConsumed} g
// Carbs: ${_ctx.carbsConsumed} g
// Fat: ${_ctx.fatConsumed} g
//
// ========================
// WEEKLY DATA (If Available)
// ========================
// Weekly Average Calories: ${_ctx.weeklyCalories}
// Consistency Score: ${_ctx.consistencyScore}
//
// ========================
// AI BEHAVIOR RULES
// ========================
//
// 1️⃣ PERSONALIZATION
// - Always analyze the user's health profile before answering.
// - Base advice on BMI, goal, disease, and allergies.
// - If user has diabetes → suggest low glycemic index foods.
// - If user goal is muscle_gain and protein is low → suggest high protein foods.
// - If calorie exceeded → politely warn.
// - If calorie too low → warn about under-eating.
//
// 2️⃣ MACRO ANALYSIS
// - If protein intake is insufficient → suggest food sources.
// - If carbs too high → suggest balance strategies.
// - If fats excessive → suggest healthier fat alternatives.
// - Suggest portion control when needed.
//
// 3️⃣ WHAT-IF SIMULATION MODE
// If user asks "What if I eat…":
// - Estimate calorie impact.
// - Compare with remaining calories.
// - Suggest portion control or alternatives.
//
// 4️⃣ HEALTH RISK DETECTION
// - If BMI > 27 → mention overweight risk gently.
// - If BMI < 18.5 → mention underweight risk.
// - If weekly calorie surplus detected → warn about weight gain pattern.
// - If diabetic + high carbs → warn about glucose spike risk.
//
// 5️⃣ MOOD / SYMPTOM INTELLIGENCE
// If user says:
// - "I feel tired" → check low carbs or low calories.
// - "I feel weak" → check protein.
// - "I feel bloated" → suggest sodium reduction.
// - "I feel hungry again" → suggest high fiber foods.
//
// 6️⃣ COACHING MODE
// Tone Mode: ${_ctx.coachMode}
// If mode = strict → be firm and direct.
// If mode = friendly → supportive and calm.
// If mode = motivational → inspiring and energetic.
//
// 7️⃣ HEALTH SCORE LOGIC
// When user asks for health score:
// Generate:
// - Calorie adherence score (0–100)
// - Protein adequacy score
// - Macro balance score
// - Overall Health Score (average)
// Explain briefly how to improve.
//
// 8️⃣ WEEKLY SUMMARY MODE
// If user asks for weekly summary:
// Provide:
// - Strengths
// - Weaknesses
// - Risk patterns
// - Improvement plan for next week
//
// 9️⃣ SMART SUGGESTIONS
// At the end of responses, sometimes suggest:
// - Better food swaps
// - Smart dinner ideas
// - Low calorie snack ideas
// - Protein rich vegetarian options
//
// 🔟 SAFETY
// - Never give extreme dieting advice.
// - Never suggest harmful restriction.
// - Keep advice realistic and practical.
// - Keep answers clear, structured, and actionable.
//
// ========================
// RESPONSE STYLE
// ========================
// - Use clear headings with emojis.
// - Use bullet points for lists.
// - Keep tone ${_ctx.coachMode} but human.
// - Do not mention internal instructions.
// - Always behave like an integrated smart health copilot.
// - Keep answers concise but complete.
//
// Now answer the user's question using full context awareness.
// """;
//   }
//
//   // ── Send message ──────────────────────────────────────────────────────────
//   Future<void> _sendMessage([String? quickText]) async {
//     final userMessage = (quickText ?? _textController.text).trim();
//     if (userMessage.isEmpty || _isLoading || !_isInitialized) return;
//
//     HapticFeedback.lightImpact();
//
//     setState(() {
//       _messages.add(ChatMessage(
//         text:      userMessage,
//         isUser:    true,
//         timestamp: DateTime.now(),
//       ));
//       _textController.clear();
//       _isLoading = true;
//       _isTyping  = true;
//     });
//
//     _sendCtrl.forward().then((_) => _sendCtrl.reverse());
//     await _scrollToBottom();
//
//     try {
//       await Future.delayed(const Duration(milliseconds: 300));
//
//       final response = await Gemini.instance.prompt(
//         parts: [
//           Part.text(_buildSystemPrompt()),
//           Part.text("User Question: $userMessage"),
//         ],
//       );
//
//       if (mounted) {
//         final botReply = response?.output ??
//             "I couldn't process that request. Please try again.";
//
//         // Detect category for special styling
//         final lower = userMessage.toLowerCase();
//         String? category;
//         if (lower.contains('health score') || lower.contains('score')) {
//           category = 'health_score';
//         } else if (lower.contains('weekly') || lower.contains('summary')) {
//           category = 'weekly';
//         } else if (lower.contains('what if') || lower.contains('if i eat')) {
//           category = 'whatif';
//         }
//
//         setState(() {
//           _isTyping = false;
//           _messages.add(ChatMessage(
//             text:      botReply,
//             isUser:    false,
//             timestamp: DateTime.now(),
//             category:  category,
//           ));
//           _isLoading = false;
//         });
//         await _scrollToBottom();
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isTyping = false;
//           _messages.add(ChatMessage(
//             text:      'I encountered a connection error. Please check your network and try again.',
//             isUser:    false,
//             timestamp: DateTime.now(),
//             isError:   true,
//           ));
//           _isLoading = false;
//         });
//         await _scrollToBottom();
//       }
//     }
//   }
//
//   Future<void> _scrollToBottom() async {
//     await Future.delayed(const Duration(milliseconds: 120));
//     if (_scrollController.hasClients && mounted) {
//       await _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent + 120,
//         duration: const Duration(milliseconds: 320),
//         curve: Curves.easeOutCubic,
//       );
//     }
//   }
//
//   // ── Coach mode change ─────────────────────────────────────────────────────
//   Future<void> _setCoachMode(String mode) async {
//     HapticFeedback.lightImpact();
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('coach_mode', mode);
//     setState(() {
//       _coachMode      = mode;
//       _ctx.coachMode  = mode;
//     });
//     setState(() {
//       _messages.add(ChatMessage(
//         text:      '🎯 Coaching mode switched to **${mode[0].toUpperCase()}${mode.substring(1)}**. I\'ll adjust my tone accordingly!',
//         isUser:    false,
//         timestamp: DateTime.now(),
//       ));
//     });
//     _scrollToBottom();
//   }
//
//   // ── Clear chat ────────────────────────────────────────────────────────────
//   void _clearChat() {
//     HapticFeedback.mediumImpact();
//     setState(() => _messages.clear());
//     _addWelcomeMessage();
//   }
//
//   // ╔══════════════════════════════════════════════════════════════════════════╗
//   // ║  BUILD                                                                   ║
//   // ╚══════════════════════════════════════════════════════════════════════════╝
//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.light,
//       child: Scaffold(
//         backgroundColor: _DS.bg,
//         body: Column(
//           children: [
//             _buildAppBar(),
//             // _buildContextBanner(),
//             Expanded(
//               child: ListView.builder(
//                 controller: _scrollController,
//                 padding: const EdgeInsets.only(top: 8, bottom: 12),
//                 physics: const BouncingScrollPhysics(),
//                 itemCount: _messages.length + (_isTyping ? 1 : 0) + 1,
//                 itemBuilder: (context, index) {
//                   // Quick prompts row at top
//                   if (index == 0) return _buildQuickPrompts();
//                   final msgIdx = index - 1;
//                   if (_isTyping && msgIdx == _messages.length) {
//                     return _buildTypingIndicator();
//                   }
//                   if (msgIdx < _messages.length) {
//                     return _buildMessageBubble(_messages[msgIdx], msgIdx);
//                   }
//                   return const SizedBox.shrink();
//                 },
//               ),
//             ),
//             _buildInputBar(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── App bar ───────────────────────────────────────────────────────────────
//   Widget _buildAppBar() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
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
//               child: const Icon(Icons.arrow_back_ios_new_rounded, color: _DS.neon, size: 16),
//             ),
//           ),
//           const SizedBox(width: 12),
//
//           // Bot avatar
//           AnimatedBuilder(
//             animation: _glowAnim,
//             builder: (_, __) => Container(
//               width: 44,
//               height: 44,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: const LinearGradient(
//                   colors: [_DS.neon, _DS.neonDim],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: _DS.neon.withOpacity(_glowAnim.value * 0.5),
//                     blurRadius: 14,
//                     spreadRadius: 1,
//                   ),
//                 ],
//               ),
//               child: const Center(
//                 child: Text('🤖', style: TextStyle(fontSize: 22)),
//               ),
//             ),
//           ),
//
//           const SizedBox(width: 12),
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('NutriBot',
//                     style: TextStyle(color: _DS.textPrimary, fontSize: 17,
//                         fontWeight: FontWeight.w900, letterSpacing: -0.2)),
//                 Row(
//                   children: [
//                     AnimatedContainer(
//                       duration: const Duration(milliseconds: 500),
//                       width: 7, height: 7,
//                       decoration: BoxDecoration(
//                         color: _isInitialized ? _DS.neon : _DS.accent4,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: (_isInitialized ? _DS.neon : _DS.accent4)
//                                 .withOpacity(0.6),
//                             blurRadius: 5,
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       _isInitialized ? 'AI Copilot Online' : 'Connecting...',
//                       style: TextStyle(
//                         color: _isInitialized ? _DS.neon : _DS.accent4,
//                         fontSize: 11,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           // Coach mode button
//           GestureDetector(
//             onTap: _showCoachModeSheet,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//               decoration: BoxDecoration(
//                 color: _coachModeColor(_coachMode).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                     color: _coachModeColor(_coachMode).withOpacity(0.35), width: 1),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(_coachModeEmoji(_coachMode),
//                       style: const TextStyle(fontSize: 12)),
//                   const SizedBox(width: 4),
//                   Text(_coachMode[0].toUpperCase() + _coachMode.substring(1),
//                       style: TextStyle(
//                           color: _coachModeColor(_coachMode),
//                           fontSize: 10,
//                           fontWeight: FontWeight.w800)),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//
//           // Clear
//           GestureDetector(
//             onTap: _clearChat,
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: _DS.bgCard,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: _DS.borderFaint, width: 1),
//               ),
//               child: const Icon(Icons.refresh_rounded, color: _DS.textMuted, size: 16),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Color    _coachModeColor(String m) => m == 'strict' ? _DS.accent3 : m == 'friendly' ? _DS.accent1 : _DS.accent4;
//   String   _coachModeEmoji(String m) => m == 'strict' ? '💪' : m == 'friendly' ? '😊' : '⚡';
//
//   // ── Coach mode sheet ──────────────────────────────────────────────────────
//   void _showCoachModeSheet() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (_) => Container(
//         margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           color: _DS.bgCard,
//           borderRadius: BorderRadius.circular(28),
//           border: Border.all(color: _DS.borderFaint, width: 1),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(child: Container(width: 40, height: 4,
//                 decoration: BoxDecoration(color: _DS.textMuted,
//                     borderRadius: BorderRadius.circular(2)))),
//             const SizedBox(height: 18),
//             const Text('Choose Coaching Mode',
//                 style: TextStyle(color: _DS.textPrimary, fontSize: 17,
//                     fontWeight: FontWeight.w900)),
//             const SizedBox(height: 16),
//             ...['motivational', 'friendly', 'strict'].map((mode) {
//               final selected = _coachMode == mode;
//               final color    = _coachModeColor(mode);
//               return GestureDetector(
//                 onTap: () {
//                   Navigator.pop(context);
//                   _setCoachMode(mode);
//                 },
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   margin: const EdgeInsets.only(bottom: 10),
//                   padding: const EdgeInsets.all(14),
//                   decoration: BoxDecoration(
//                     color: selected ? color.withOpacity(0.1) : _DS.surface,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: selected ? color.withOpacity(0.5) : _DS.borderFaint,
//                       width: selected ? 1.5 : 1,
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Text(_coachModeEmoji(mode),
//                           style: const TextStyle(fontSize: 22)),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               mode[0].toUpperCase() + mode.substring(1),
//                               style: TextStyle(
//                                 color: selected ? color : _DS.textPrimary,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w800,
//                               ),
//                             ),
//                             Text(
//                               mode == 'motivational' ? 'Inspiring & energetic responses'
//                                   : mode == 'friendly' ? 'Supportive & calm guidance'
//                                   : 'Direct & firm accountability',
//                               style: TextStyle(
//                                   color: selected ? color.withOpacity(0.7) : _DS.textMuted,
//                                   fontSize: 11),
//                             ),
//                           ],
//                         ),
//                       ),
//                       if (selected)
//                         Icon(Icons.check_circle_rounded, color: color, size: 20),
//                     ],
//                   ),
//                 ),
//               );
//             }),
//             const SizedBox(height: 4),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Context banner ────────────────────────────────────────────────────────
//   // Widget _buildContextBanner() {
//   //   if (!_contextLoaded) return const SizedBox.shrink();
//   //
//   //   final target    = int.tryParse(_ctx.dailyCalorieTarget) ?? 2000;
//   //   final consumed  = int.tryParse(_ctx.caloriesConsumed)   ?? 0;
//   //   final remaining = (target - consumed).clamp(0, 9999);
//   //   final pct       = (consumed / target).clamp(0.0, 1.0);
//   //   final color     = pct > 1.0 ? _DS.accent3 : pct > 0.8 ? _DS.accent4 : _DS.neon;
//   //
//   //   return Container(
//   //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//   //     color: _DS.bgCard,
//   //     child: Row(
//   //       children: [
//   //         // Calorie mini ring
//   //         SizedBox(
//   //           width: 40,
//   //           height: 40,
//   //           child: Stack(
//   //             alignment: Alignment.center,
//   //             children: [
//   //               CircularProgressIndicator(
//   //                 value: pct,
//   //                 backgroundColor: _DS.surface,
//   //                 valueColor: AlwaysStoppedAnimation(color),
//   //                 strokeWidth: 3.5,
//   //               ),
//   //               Text('${(pct * 100).round()}%',
//   //                   style: TextStyle(color: color, fontSize: 9,
//   //                       fontWeight: FontWeight.w900)),
//   //             ],
//   //           ),
//   //         ),
//   //         const SizedBox(width: 12),
//   //         // Stats
//   //         Expanded(
//   //           child: Row(
//   //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //             children: [
//   //               _ctxStat('🔥', '${_ctx.caloriesConsumed}', 'kcal eaten', _DS.accent4),
//   //               _ctxStat('💧', '${remaining}', 'remaining', color),
//   //               _ctxStat('💪', '${_ctx.proteinConsumed}g', 'protein', _DS.accent1),
//   //               _ctxStat('🌾', '${_ctx.carbsConsumed}g', 'carbs', _DS.accent2),
//   //             ],
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//
//   Widget _ctxStat(String emoji, String val, String label, Color color) {
//     return Column(
//       children: [
//         Text(emoji, style: const TextStyle(fontSize: 12)),
//         Text(val, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900)),
//         Text(label, style: TextStyle(color: _DS.textMuted, fontSize: 8, fontWeight: FontWeight.w600)),
//       ],
//     );
//   }
//
//   // ── Quick prompts ─────────────────────────────────────────────────────────
//   Widget _buildQuickPrompts() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 8, 0, 4),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Quick Ask',
//               style: TextStyle(color: _DS.textMuted, fontSize: 10,
//                   fontWeight: FontWeight.w700, letterSpacing: 0.5)),
//           const SizedBox(height: 8),
//           SizedBox(
//             height: 38,
//             child: ListView.separated(
//               scrollDirection: Axis.horizontal,
//               itemCount: _quickPrompts.length,
//               separatorBuilder: (_, __) => const SizedBox(width: 8),
//               itemBuilder: (_, i) {
//                 final p = _quickPrompts[i];
//                 return GestureDetector(
//                   onTap: () => _sendMessage(p['text']),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: _DS.bgCard,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(color: _DS.borderFaint, width: 1),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(p['icon'] ?? '', style: const TextStyle(fontSize: 13)),
//                         const SizedBox(width: 6),
//                         Text(p['label'] ?? '',
//                             style: const TextStyle(color: _DS.textSecondary,
//                                 fontSize: 11, fontWeight: FontWeight.w700)),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           const SizedBox(height: 8),
//         ],
//       ),
//     );
//   }
//
//   // ── Message bubble ────────────────────────────────────────────────────────
//   Widget _buildMessageBubble(ChatMessage message, int index) {
//     final isUser     = message.isUser;
//     final showAvatar = index == 0 ||
//         (index > 0 && _messages[index - 1].isUser != message.isUser);
//
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0.0, end: 1.0),
//       duration: Duration(milliseconds: 350 + (index * 30).clamp(0, 300)),
//       curve: Curves.easeOutCubic,
//       builder: (context, value, _) {
//         final cv = value.clamp(0.0, 1.0);
//         return Opacity(
//           opacity: cv,
//           child: Transform.translate(
//             offset: Offset(isUser ? 20 * (1 - cv) : -20 * (1 - cv), 0),
//             child: Container(
//               margin: EdgeInsets.only(
//                 left: isUser ? 60 : 16,
//                 right: isUser ? 16 : 60,
//                 top: showAvatar ? 16 : 4,
//                 bottom: 4,
//               ),
//               child: Column(
//                 crossAxisAlignment: isUser
//                     ? CrossAxisAlignment.end
//                     : CrossAxisAlignment.start,
//                 children: [
//                   // Bot label
//                   if (showAvatar && !isUser)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 6, left: 2),
//                       child: Row(
//                         children: [
//                           _botAvatar(small: true),
//                           const SizedBox(width: 8),
//                           Text('NutriBot',
//                               style: TextStyle(color: _DS.neon, fontSize: 11,
//                                   fontWeight: FontWeight.w800)),
//                           if (message.category != null) ...[
//                             const SizedBox(width: 6),
//                             _categoryBadge(message.category!),
//                           ],
//                         ],
//                       ),
//                     ),
//
//                   // Bubble
//                   Container(
//                     constraints: BoxConstraints(
//                         maxWidth: MediaQuery.of(context).size.width * 0.78),
//                     padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
//                     decoration: BoxDecoration(
//                       gradient: isUser
//                           ? const LinearGradient(
//                         colors: [_DS.neon, _DS.neonDim],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       )
//                           : null,
//                       color: isUser
//                           ? null
//                           : message.isError
//                           ? _DS.accent3.withOpacity(0.1)
//                           : _DS.bgCard,
//                       borderRadius: BorderRadius.only(
//                         topLeft:     const Radius.circular(20),
//                         topRight:    const Radius.circular(20),
//                         bottomLeft:  Radius.circular(isUser ? 20 : 5),
//                         bottomRight: Radius.circular(isUser ? 5 : 20),
//                       ),
//                       border: Border.all(
//                         color: isUser
//                             ? Colors.transparent
//                             : message.isError
//                             ? _DS.accent3.withOpacity(0.4)
//                             : _DS.borderFaint,
//                         width: 1,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: isUser
//                               ? _DS.neon.withOpacity(0.2)
//                               : Colors.black.withOpacity(0.15),
//                           blurRadius: 12,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Render message text with basic markdown-like bold
//                         _buildMessageText(message.text, isUser, message.isError),
//                         const SizedBox(height: 5),
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               _formatTime(message.timestamp),
//                               style: TextStyle(
//                                 color: isUser
//                                     ? _DS.bg.withOpacity(0.6)
//                                     : _DS.textMuted,
//                                 fontSize: 10,
//                               ),
//                             ),
//                             if (isUser) ...[
//                               const SizedBox(width: 5),
//                               Icon(Icons.check_rounded,
//                                   size: 12, color: _DS.bg.withOpacity(0.6)),
//                             ],
//                           ],
//                         ),
//                       ],
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
//   Widget _botAvatar({bool small = false}) {
//     final size = small ? 24.0 : 36.0;
//     return AnimatedBuilder(
//       animation: _glowAnim,
//       builder: (_, __) => Container(
//         width: size, height: size,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           gradient: const LinearGradient(
//               colors: [_DS.neon, _DS.neonDim],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight),
//           boxShadow: [
//             BoxShadow(
//                 color: _DS.neon.withOpacity(_glowAnim.value * 0.4),
//                 blurRadius: 8)
//           ],
//         ),
//         child: Center(
//           child: Text('🤖',
//               style: TextStyle(fontSize: small ? 12 : 18)),
//         ),
//       ),
//     );
//   }
//
//   Widget _categoryBadge(String category) {
//     final data = {
//       'health_score': ('📊', 'Health Score', _DS.accent4),
//       'weekly':       ('📅', 'Weekly',       _DS.accent5),
//       'whatif':       ('🔮', 'What-If',      _DS.accent1),
//     }[category];
//     if (data == null) return const SizedBox.shrink();
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
//       decoration: BoxDecoration(
//         color: (data.$3 as Color).withOpacity(0.1),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: (data.$3 as Color).withOpacity(0.3)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(data.$1 as String, style: const TextStyle(fontSize: 9)),
//           const SizedBox(width: 3),
//           Text(data.$2 as String,
//               style: TextStyle(color: data.$3 as Color, fontSize: 9,
//                   fontWeight: FontWeight.w800)),
//         ],
//       ),
//     );
//   }
//
//   // Simple bold rendering for **text** pattern
//   Widget _buildMessageText(String text, bool isUser, bool isError) {
//     final parts = text.split('**');
//     final spans = <TextSpan>[];
//     final baseColor = isUser
//         ? _DS.bg
//         : isError
//         ? _DS.accent3
//         : _DS.textPrimary;
//
//     for (int i = 0; i < parts.length; i++) {
//       spans.add(TextSpan(
//         text: parts[i],
//         style: TextStyle(
//           color: baseColor,
//           fontWeight: i.isOdd ? FontWeight.w800 : FontWeight.w400,
//           fontSize: 14,
//           height: 1.55,
//         ),
//       ));
//     }
//
//     return RichText(text: TextSpan(children: spans));
//   }
//
//   String _formatTime(DateTime t) {
//     final diff = DateTime.now().difference(t);
//     if (diff.inSeconds < 30) return 'just now';
//     if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
//     return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
//   }
//
//   // ── Typing indicator ──────────────────────────────────────────────────────
//   Widget _buildTypingIndicator() {
//     return Container(
//       margin: const EdgeInsets.only(left: 16, right: 80, top: 6, bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           _botAvatar(small: true),
//           const SizedBox(width: 10),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: _DS.bgCard,
//               borderRadius: const BorderRadius.only(
//                 topLeft:     Radius.circular(18),
//                 topRight:    Radius.circular(18),
//                 bottomRight: Radius.circular(18),
//                 bottomLeft:  Radius.circular(5),
//               ),
//               border: Border.all(color: _DS.borderFaint, width: 1),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text('NutriBot is thinking',
//                     style: TextStyle(color: _DS.textMuted, fontSize: 11)),
//                 const SizedBox(width: 8),
//                 ...List.generate(3, (i) => _typingDot(i)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _typingDot(int index) {
//     return AnimatedBuilder(
//       animation: _typingCtrl,
//       builder: (_, __) {
//         final v     = _typingCtrl.value;
//         final delay = index * 0.2;
//         final glow  = (v >= delay && v <= delay + 0.4) ? 1.0 : 0.3;
//         return Container(
//           margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
//           width: 7, height: 7,
//           decoration: BoxDecoration(
//             color: _DS.neon.withOpacity(glow),
//             shape: BoxShape.circle,
//           ),
//         );
//       },
//     );
//   }
//
//   // ── Input bar ─────────────────────────────────────────────────────────────
//   Widget _buildInputBar() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
//       decoration: BoxDecoration(
//         color: _DS.bgCard,
//         border: Border(top: BorderSide(color: _DS.borderFaint, width: 1)),
//       ),
//       child: SafeArea(
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Expanded(
//               child: AnimatedBuilder(
//                 animation: _focusNode,
//                 builder: (_, __) => Container(
//                   constraints: const BoxConstraints(maxHeight: 120),
//                   decoration: BoxDecoration(
//                     color: _DS.surface,
//                     borderRadius: BorderRadius.circular(22),
//                     border: Border.all(
//                       color: _focusNode.hasFocus
//                           ? _DS.neon.withOpacity(0.5)
//                           : _DS.borderFaint,
//                       width: 1.2,
//                     ),
//                   ),
//                   child: TextField(
//                     controller: _textController,
//                     focusNode: _focusNode,
//                     maxLines: null,
//                     textCapitalization: TextCapitalization.sentences,
//                     enabled: !_isLoading && _isInitialized,
//                     style: const TextStyle(color: _DS.textPrimary, fontSize: 14, height: 1.4),
//                     cursorColor: _DS.neon,
//                     decoration: InputDecoration(
//                       hintText: _isInitialized
//                           ? 'Ask NutriBot anything...'
//                           : 'Connecting to AI...',
//                       hintStyle: TextStyle(color: _DS.textMuted, fontSize: 13),
//                       border: InputBorder.none,
//                       contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 18, vertical: 12),
//                     ),
//                     onSubmitted: (_) => _sendMessage(),
//                     onChanged: (_) => setState(() {}),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10),
//             _buildSendButton(),
//             const SizedBox(height: 10),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSendButton() {
//     final canSend = !_isLoading &&
//         _isInitialized &&
//         _textController.text.trim().isNotEmpty;
//
//     return GestureDetector(
//       onTap: canSend ? _sendMessage : null,
//       child: AnimatedBuilder(
//         animation: Listenable.merge([_sendCtrl, _glowAnim]),
//         builder: (_, __) => Transform.scale(
//           scale: 1.0 + _sendCtrl.value * 0.1,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             width: 48, height: 48,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: canSend
//                   ? const LinearGradient(
//                 colors: [_DS.neon, _DS.neonDim],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               )
//                   : null,
//               color: canSend ? null : _DS.surface,
//               boxShadow: canSend
//                   ? [
//                 BoxShadow(
//                   color: _DS.neon.withOpacity(_glowAnim.value * 0.5),
//                   blurRadius: 14,
//                   spreadRadius: 1,
//                 )
//               ]
//                   : null,
//             ),
//             child: Center(
//               child: _isLoading
//                   ? SizedBox(
//                 width: 20, height: 20,
//                 child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: _DS.neon,
//                     backgroundColor: _DS.neonFaint),
//               )
//                   : Icon(Icons.send_rounded,
//                   color: canSend ? _DS.bg : _DS.textMuted, size: 20),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  DESIGN TOKENS                                                           ║
// ╚══════════════════════════════════════════════════════════════════════════╝
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
  static const textMuted    = Color(0xFF2E6B4A);
  static const borderFaint  = Color(0xFF1A3D2A);
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  MESSAGE MODEL                                                           ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class ChatMessage {
  final String   text;
  final bool     isUser;
  final DateTime timestamp;
  final bool     isError;
  final String?  category; // 'health_score' | 'weekly' | 'whatif' | null

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError    = false,
    this.category,
  });
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  USER HEALTH CONTEXT MODEL                                               ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class HealthContext {
  String age;
  String weight;
  String height;
  String bmi;
  String goal;
  String disease;
  String allergies;
  String dailyCalorieTarget;
  String caloriesConsumed;
  String proteinConsumed;
  String carbsConsumed;
  String fatConsumed;
  String weeklyCalories;
  String consistencyScore;
  String coachMode;

  HealthContext({
    this.age                 = '—',
    this.weight              = '—',
    this.height              = '—',
    this.bmi                 = '—',
    this.goal                = 'maintain',
    this.disease             = 'None',
    this.allergies           = 'None',
    this.dailyCalorieTarget  = '2000',
    this.caloriesConsumed    = '0',
    this.proteinConsumed     = '0',
    this.carbsConsumed       = '0',
    this.fatConsumed         = '0',
    this.weeklyCalories      = 'Not available',
    this.consistencyScore    = 'Not available',
    this.coachMode           = 'motivational',
  });
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  CHAT SCREEN                                                             ║
// ╚══════════════════════════════════════════════════════════════════════════╝
class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin {

  // ── Controllers ───────────────────────────────────────────────────────────
  final TextEditingController _textController  = TextEditingController();
  final ScrollController       _scrollController = ScrollController();
  final FocusNode              _focusNode       = FocusNode();
  final List<ChatMessage>      _messages        = [];

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isTyping       = false;
  bool _isLoading      = false;
  bool _isInitialized  = false;
  bool _contextLoaded  = false;
  String _coachMode    = 'motivational'; // motivational | friendly | strict

  HealthContext _ctx = HealthContext();

  // ── Quick prompts ─────────────────────────────────────────────────────────
  final List<Map<String, String>> _quickPrompts = [
    {'icon': '📊', 'label': 'Health Score',    'text': 'Generate my health score for today'},
    {'icon': '📅', 'label': 'Weekly Summary',  'text': 'Give me a weekly nutrition summary'},
    {'icon': '🍽️', 'label': 'Meal Ideas',      'text': 'Suggest healthy dinner ideas for tonight'},
    {'icon': '⚡',  'label': 'Remaining Macros','text': 'What macros do I still need today?'},
    {'icon': '🔄', 'label': 'Food Swap',       'text': 'Suggest healthy food swaps I can make'},
    {'icon': '💪', 'label': 'Protein Plan',    'text': 'Help me hit my protein goal today'},
  ];

  // ── Animations ────────────────────────────────────────────────────────────
  late AnimationController _typingCtrl;
  late AnimationController _sendCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _entryCtrl;
  late Animation<double>   _glowAnim;
  late Animation<double>   _entryAnim;

  @override
  void initState() {
    super.initState();
    _initAnims();
    _initGemini();
    _loadHealthContext();
  }

  void _initAnims() {
    _typingCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();

    _sendCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));

    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2600))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.2, end: 0.75)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _entryAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _typingCtrl.dispose();
    _sendCtrl.dispose();
    _glowCtrl.dispose();
    _entryCtrl.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Init Gemini ───────────────────────────────────────────────────────────
  Future<void> _initGemini() async {
    try {
      // const apiKey = 'AIzaSyCX9zECZMJX3xKNl-icIXEkqcQ6dv17CJQ'; // replace with your key
      const apiKey = 'AIzaSyAP6nNbu82Flt2RFY-awuNBakDGQv3icUs'; // replace with your key
      Gemini.init(apiKey: apiKey, enableDebugging: false);
      setState(() => _isInitialized = true);
    } catch (e) {
      setState(() => _isInitialized = false);
    }
  }

  // ── Load health context from SharedPreferences + API ─────────────────────
  Future<void> _loadHealthContext() async {
    try {
      final prefs   = await SharedPreferences.getInstance();
      final baseUrl = prefs.getString('url') ?? '';
      final lid     = prefs.getString('lid') ?? '';

      // Load initial values from SharedPreferences
      _ctx = HealthContext(
        age:                prefs.getString('hp_age')          ?? '—',
        weight:             prefs.getString('hp_weight')       ?? prefs.getString('weight') ?? '—',
        height:             prefs.getString('hp_height')       ?? prefs.getString('height') ?? '—',
        bmi:                prefs.getString('hp_bmi')          ?? '—',
        goal:               prefs.getString('hp_goal')         ?? 'maintain',
        disease:            prefs.getString('hp_disease')      ?? 'None',
        allergies:          prefs.getString('hp_allergies')    ?? 'None',
        dailyCalorieTarget: prefs.getString('calorie_target')  ?? '2000',
        caloriesConsumed:   prefs.getString('calories_today')  ?? '0',
        proteinConsumed:    prefs.getString('protein_today')   ?? '0',
        carbsConsumed:      prefs.getString('carbs_today')     ?? '0',
        fatConsumed:        prefs.getString('fat_today')       ?? '0',
        weeklyCalories:     prefs.getString('weekly_calories') ?? 'Not available',
        consistencyScore:   prefs.getString('consistency')     ?? 'Not available',
        coachMode:          prefs.getString('coach_mode')      ?? 'motivational',
      );
      _coachMode = _ctx.coachMode;

      // FIRST: Try to fetch health profile to get the CORRECT calorie target
      if (baseUrl.isNotEmpty && lid.isNotEmpty) {
        try {
          // Fetch health profile to get calorie target
          final healthRes = await http.post(
            Uri.parse('$baseUrl/userviewhishealth/'),
            body: {'lid': lid},
          ).timeout(const Duration(seconds: 6));

          if (healthRes.statusCode == 200) {
            final healthData = jsonDecode(healthRes.body);
            if (healthData['status'] == 'ok') {
              // Get the calorie target from health profile
              String calorieTarget = healthData['healthvalue']?.toString() ?? '2000';

              // Also save to SharedPreferences for future use
              await prefs.setString('calorie_target', calorieTarget);

              _ctx.dailyCalorieTarget = calorieTarget;

              // Also update other health profile data if available
              if (healthData['goal_mode'] != null) {
                _ctx.goal = healthData['goal_mode'].toString();
              }
            }
          }
        } catch (e) {
          print('Error fetching health profile: $e');
        }

        // THEN: Try to fetch today's nutrition
        try {
          final res = await http.post(
            Uri.parse('$baseUrl/today_nutrition_summary/'),
            body: {'lid': lid},
          ).timeout(const Duration(seconds: 6));

          if (res.statusCode == 200) {
            final data = jsonDecode(res.body);
            if (data['status'] == 'ok') {
              _ctx.caloriesConsumed =
                  data['total_calories']?.toString() ?? _ctx.caloriesConsumed;
              _ctx.proteinConsumed =
                  data['total_protein']?.toString() ?? _ctx.proteinConsumed;
              _ctx.carbsConsumed =
                  data['total_carbs']?.toString() ?? _ctx.carbsConsumed;
              _ctx.fatConsumed =
                  data['total_fat']?.toString() ?? _ctx.fatConsumed;

              // Save to prefs for future use
              await prefs.setString('calories_today', _ctx.caloriesConsumed);
              await prefs.setString('protein_today', _ctx.proteinConsumed);
              await prefs.setString('carbs_today', _ctx.carbsConsumed);
              await prefs.setString('fat_today', _ctx.fatConsumed);
            }
          }
        } catch (_) {
          // API unavailable — use cached prefs values
        }
      }

      setState(() => _contextLoaded = true);
      _addWelcomeMessage();

    } catch (e) {
      setState(() => _contextLoaded = true);
      _addWelcomeMessage();
    }
  }

  // ── Welcome message ───────────────────────────────────────────────────────
  void _addWelcomeMessage() {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      // Parse values, handling potential parsing errors
      double target = double.tryParse(_ctx.dailyCalorieTarget) ?? 2000;
      double consumed = double.tryParse(_ctx.caloriesConsumed) ?? 0;
      double remaining = target - consumed; // CORRECT: total - consumed

      String remainingText;
      if (remaining > 0) {
        remainingText = '$remaining kcal left';
      } else if (remaining < 0) {
        remainingText = '${remaining.abs()} kcal over ⚠️';
      } else {
        remainingText = 'Goal achieved! 🎉';
      }

      setState(() {
        _messages.add(ChatMessage(
          text: "👋 Hey! I'm **NutriBot**, your FoodSnap AI health copilot.\n\n"
              "📊 **Today's snapshot:**\n"
              "• Calories consumed: ${_ctx.caloriesConsumed} / $target kcal\n"
              "• Remaining: $remainingText\n"
              "• Protein: ${_ctx.proteinConsumed}g | Carbs: ${_ctx.carbsConsumed}g | Fat: ${_ctx.fatConsumed}g\n\n"
              "Ask me anything — meal ideas, health score, what-if analysis, or how you're doing today! 💪",
          isUser:    false,
          timestamp: DateTime.now(),
        ));
      });
    });
  }

  // ── Build system prompt ───────────────────────────────────────────────────
  String _buildSystemPrompt() {
    int target = int.tryParse(_ctx.dailyCalorieTarget) ?? 2000;
    int consumed = int.tryParse(_ctx.caloriesConsumed) ?? 0;
    int remaining = target - consumed;

    return """
You are "FoodSnap AI – Intelligent Nutrition Copilot", an advanced AI health and nutrition assistant integrated inside a smart calorie tracking application.
You are NOT a general chatbot. You are a personalized health-aware AI coach.

========================
USER HEALTH PROFILE
========================
Age: ${_ctx.age}
Weight: ${_ctx.weight} kg
Height: ${_ctx.height} cm
BMI: ${_ctx.bmi}
Goal: ${_ctx.goal}  (muscle_gain / fat_loss / maintain)
Disease: ${_ctx.disease}
Allergies: ${_ctx.allergies}

========================
TODAY'S NUTRITION STATUS
========================
Calorie Target: ${_ctx.dailyCalorieTarget} kcal
Calories Consumed: ${_ctx.caloriesConsumed} kcal
Remaining Calories: $remaining kcal
Protein: ${_ctx.proteinConsumed} g
Carbs: ${_ctx.carbsConsumed} g
Fat: ${_ctx.fatConsumed} g

========================
WEEKLY DATA (If Available)
========================
Weekly Average Calories: ${_ctx.weeklyCalories}
Consistency Score: ${_ctx.consistencyScore}

========================
AI BEHAVIOR RULES
========================

1️⃣ PERSONALIZATION
- Always analyze the user's health profile before answering.
- Base advice on BMI, goal, disease, and allergies.
- If user has diabetes → suggest low glycemic index foods.
- If user goal is muscle_gain and protein is low → suggest high protein foods.
- If calorie exceeded → politely warn.
- If calorie too low → warn about under-eating.

2️⃣ MACRO ANALYSIS
- If protein intake is insufficient → suggest food sources.
- If carbs too high → suggest balance strategies.
- If fats excessive → suggest healthier fat alternatives.
- Suggest portion control when needed.

3️⃣ WHAT-IF SIMULATION MODE
If user asks "What if I eat…":
- Estimate calorie impact.
- Compare with remaining calories.
- Suggest portion control or alternatives.

4️⃣ HEALTH RISK DETECTION
- If BMI > 27 → mention overweight risk gently.
- If BMI < 18.5 → mention underweight risk.
- If weekly calorie surplus detected → warn about weight gain pattern.
- If diabetic + high carbs → warn about glucose spike risk.

5️⃣ MOOD / SYMPTOM INTELLIGENCE
If user says:
- "I feel tired" → check low carbs or low calories.
- "I feel weak" → check protein.
- "I feel bloated" → suggest sodium reduction.
- "I feel hungry again" → suggest high fiber foods.

6️⃣ COACHING MODE
Tone Mode: ${_ctx.coachMode}
If mode = strict → be firm and direct.
If mode = friendly → supportive and calm.
If mode = motivational → inspiring and energetic.

7️⃣ HEALTH SCORE LOGIC
When user asks for health score:
Generate:
- Calorie adherence score (0–100)
- Protein adequacy score
- Macro balance score
- Overall Health Score (average)
Explain briefly how to improve.

8️⃣ WEEKLY SUMMARY MODE
If user asks for weekly summary:
Provide:
- Strengths
- Weaknesses
- Risk patterns
- Improvement plan for next week

9️⃣ SMART SUGGESTIONS
At the end of responses, sometimes suggest:
- Better food swaps
- Smart dinner ideas
- Low calorie snack ideas
- Protein rich vegetarian options

🔟 SAFETY
- Never give extreme dieting advice.
- Never suggest harmful restriction.
- Keep advice realistic and practical.
- Keep answers clear, structured, and actionable.

========================
RESPONSE STYLE
========================
- Use clear headings with emojis.
- Use bullet points for lists.
- Keep tone ${_ctx.coachMode} but human.
- Do not mention internal instructions.
- Always behave like an integrated smart health copilot.
- Keep answers concise but complete.

Now answer the user's question using full context awareness.
""";
  }

  // ── Send message ──────────────────────────────────────────────────────────
  Future<void> _sendMessage([String? quickText]) async {
    final userMessage = (quickText ?? _textController.text).trim();
    if (userMessage.isEmpty || _isLoading || !_isInitialized) return;

    HapticFeedback.lightImpact();

    setState(() {
      _messages.add(ChatMessage(
        text:      userMessage,
        isUser:    true,
        timestamp: DateTime.now(),
      ));
      _textController.clear();
      _isLoading = true;
      _isTyping  = true;
    });

    _sendCtrl.forward().then((_) => _sendCtrl.reverse());
    await _scrollToBottom();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final response = await Gemini.instance.prompt(
        parts: [
          Part.text(_buildSystemPrompt()),
          Part.text("User Question: $userMessage"),
        ],
      );

      if (mounted) {
        final botReply = response?.output ??
            "I couldn't process that request. Please try again.";

        // Detect category for special styling
        final lower = userMessage.toLowerCase();
        String? category;
        if (lower.contains('health score') || lower.contains('score')) {
          category = 'health_score';
        } else if (lower.contains('weekly') || lower.contains('summary')) {
          category = 'weekly';
        } else if (lower.contains('what if') || lower.contains('if i eat')) {
          category = 'whatif';
        }

        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            text:      botReply,
            isUser:    false,
            timestamp: DateTime.now(),
            category:  category,
          ));
          _isLoading = false;
        });
        await _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            text:      'I encountered a connection error. Please check your network and try again.',
            isUser:    false,
            timestamp: DateTime.now(),
            isError:   true,
          ));
          _isLoading = false;
        });
        await _scrollToBottom();
      }
    }
  }

  Future<void> _scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 120));
    if (_scrollController.hasClients && mounted) {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // ── Coach mode change ─────────────────────────────────────────────────────
  Future<void> _setCoachMode(String mode) async {
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('coach_mode', mode);
    setState(() {
      _coachMode      = mode;
      _ctx.coachMode  = mode;
    });
    setState(() {
      _messages.add(ChatMessage(
        text:      '🎯 Coaching mode switched to **${mode[0].toUpperCase()}${mode.substring(1)}**. I\'ll adjust my tone accordingly!',
        isUser:    false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  // ── Clear chat ────────────────────────────────────────────────────────────
  void _clearChat() {
    HapticFeedback.mediumImpact();
    setState(() => _messages.clear());
    _addWelcomeMessage();
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
        body: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 8, bottom: 12),
                physics: const BouncingScrollPhysics(),
                itemCount: _messages.length + (_isTyping ? 1 : 0) + 1,
                itemBuilder: (context, index) {
                  // Quick prompts row at top
                  if (index == 0) return _buildQuickPrompts();
                  final msgIdx = index - 1;
                  if (_isTyping && msgIdx == _messages.length) {
                    return _buildTypingIndicator();
                  }
                  if (msgIdx < _messages.length) {
                    return _buildMessageBubble(_messages[msgIdx], msgIdx);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
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
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: _DS.neon, size: 16),
            ),
          ),
          const SizedBox(width: 12),

          // Bot avatar
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (_, __) => Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [_DS.neon, _DS.neonDim],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _DS.neon.withOpacity(_glowAnim.value * 0.5),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 22)),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('NutriBot',
                    style: TextStyle(color: _DS.textPrimary, fontSize: 17,
                        fontWeight: FontWeight.w900, letterSpacing: -0.2)),
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 7, height: 7,
                      decoration: BoxDecoration(
                        color: _isInitialized ? _DS.neon : _DS.accent4,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isInitialized ? _DS.neon : _DS.accent4)
                                .withOpacity(0.6),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isInitialized ? 'AI Copilot Online' : 'Connecting...',
                      style: TextStyle(
                        color: _isInitialized ? _DS.neon : _DS.accent4,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Coach mode button
          GestureDetector(
            onTap: _showCoachModeSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _coachModeColor(_coachMode).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _coachModeColor(_coachMode).withOpacity(0.35), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_coachModeEmoji(_coachMode),
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(_coachMode[0].toUpperCase() + _coachMode.substring(1),
                      style: TextStyle(
                          color: _coachModeColor(_coachMode),
                          fontSize: 10,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Clear
          GestureDetector(
            onTap: _clearChat,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _DS.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _DS.borderFaint, width: 1),
              ),
              child: const Icon(Icons.refresh_rounded, color: _DS.textMuted, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Color    _coachModeColor(String m) => m == 'strict' ? _DS.accent3 : m == 'friendly' ? _DS.accent1 : _DS.accent4;
  String   _coachModeEmoji(String m) => m == 'strict' ? '💪' : m == 'friendly' ? '😊' : '⚡';

  // ── Coach mode sheet ──────────────────────────────────────────────────────
  void _showCoachModeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _DS.bgCard,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _DS.borderFaint, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: _DS.textMuted,
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 18),
            const Text('Choose Coaching Mode',
                style: TextStyle(color: _DS.textPrimary, fontSize: 17,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            ...['motivational', 'friendly', 'strict'].map((mode) {
              final selected = _coachMode == mode;
              final color    = _coachModeColor(mode);
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _setCoachMode(mode);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected ? color.withOpacity(0.1) : _DS.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? color.withOpacity(0.5) : _DS.borderFaint,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(_coachModeEmoji(mode),
                          style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mode[0].toUpperCase() + mode.substring(1),
                              style: TextStyle(
                                color: selected ? color : _DS.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              mode == 'motivational' ? 'Inspiring & energetic responses'
                                  : mode == 'friendly' ? 'Supportive & calm guidance'
                                  : 'Direct & firm accountability',
                              style: TextStyle(
                                  color: selected ? color.withOpacity(0.7) : _DS.textMuted,
                                  fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        Icon(Icons.check_circle_rounded, color: color, size: 20),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  // ── Quick prompts ─────────────────────────────────────────────────────────
  Widget _buildQuickPrompts() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 0, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Ask',
              style: TextStyle(color: _DS.textMuted, fontSize: 10,
                  fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _quickPrompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final p = _quickPrompts[i];
                return GestureDetector(
                  onTap: () => _sendMessage(p['text']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _DS.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _DS.borderFaint, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(p['icon'] ?? '', style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                        Text(p['label'] ?? '',
                            style: const TextStyle(color: _DS.textSecondary,
                                fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Message bubble ────────────────────────────────────────────────────────
  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isUser     = message.isUser;
    final showAvatar = index == 0 ||
        (index > 0 && _messages[index - 1].isUser != message.isUser);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + (index * 30).clamp(0, 300)),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        final cv = value.clamp(0.0, 1.0);
        return Opacity(
          opacity: cv,
          child: Transform.translate(
            offset: Offset(isUser ? 20 * (1 - cv) : -20 * (1 - cv), 0),
            child: Container(
              margin: EdgeInsets.only(
                left: isUser ? 60 : 16,
                right: isUser ? 16 : 60,
                top: showAvatar ? 16 : 4,
                bottom: 4,
              ),
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Bot label
                  if (showAvatar && !isUser)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6, left: 2),
                      child: Row(
                        children: [
                          _botAvatar(small: true),
                          const SizedBox(width: 8),
                          Text('NutriBot',
                              style: TextStyle(color: _DS.neon, fontSize: 11,
                                  fontWeight: FontWeight.w800)),
                          if (message.category != null) ...[
                            const SizedBox(width: 6),
                            _categoryBadge(message.category!),
                          ],
                        ],
                      ),
                    ),

                  // Bubble
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.78),
                    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: isUser
                          ? const LinearGradient(
                        colors: [_DS.neon, _DS.neonDim],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : null,
                      color: isUser
                          ? null
                          : message.isError
                          ? _DS.accent3.withOpacity(0.1)
                          : _DS.bgCard,
                      borderRadius: BorderRadius.only(
                        topLeft:     const Radius.circular(20),
                        topRight:    const Radius.circular(20),
                        bottomLeft:  Radius.circular(isUser ? 20 : 5),
                        bottomRight: Radius.circular(isUser ? 5 : 20),
                      ),
                      border: Border.all(
                        color: isUser
                            ? Colors.transparent
                            : message.isError
                            ? _DS.accent3.withOpacity(0.4)
                            : _DS.borderFaint,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isUser
                              ? _DS.neon.withOpacity(0.2)
                              : Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Render message text with basic markdown-like bold
                        _buildMessageText(message.text, isUser, message.isError),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(message.timestamp),
                              style: TextStyle(
                                color: isUser
                                    ? _DS.bg.withOpacity(0.6)
                                    : _DS.textMuted,
                                fontSize: 10,
                              ),
                            ),
                            if (isUser) ...[
                              const SizedBox(width: 5),
                              Icon(Icons.check_rounded,
                                  size: 12, color: _DS.bg.withOpacity(0.6)),
                            ],
                          ],
                        ),
                      ],
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

  Widget _botAvatar({bool small = false}) {
    final size = small ? 24.0 : 36.0;
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
              colors: [_DS.neon, _DS.neonDim],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          boxShadow: [
            BoxShadow(
                color: _DS.neon.withOpacity(_glowAnim.value * 0.4),
                blurRadius: 8)
          ],
        ),
        child: Center(
          child: Text('🤖',
              style: TextStyle(fontSize: small ? 12 : 18)),
        ),
      ),
    );
  }

  Widget _categoryBadge(String category) {
    final data = {
      'health_score': ('📊', 'Health Score', _DS.accent4),
      'weekly':       ('📅', 'Weekly',       _DS.accent5),
      'whatif':       ('🔮', 'What-If',      _DS.accent1),
    }[category];
    if (data == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: (data.$3 as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: (data.$3 as Color).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(data.$1 as String, style: const TextStyle(fontSize: 9)),
          const SizedBox(width: 3),
          Text(data.$2 as String,
              style: TextStyle(color: data.$3 as Color, fontSize: 9,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  // Simple bold rendering for **text** pattern
  Widget _buildMessageText(String text, bool isUser, bool isError) {
    final parts = text.split('**');
    final spans = <TextSpan>[];
    final baseColor = isUser
        ? _DS.bg
        : isError
        ? _DS.accent3
        : _DS.textPrimary;

    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(
        text: parts[i],
        style: TextStyle(
          color: baseColor,
          fontWeight: i.isOdd ? FontWeight.w800 : FontWeight.w400,
          fontSize: 14,
          height: 1.55,
        ),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 30) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  // ── Typing indicator ──────────────────────────────────────────────────────
  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 80, top: 6, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _botAvatar(small: true),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _DS.bgCard,
              borderRadius: const BorderRadius.only(
                topLeft:     Radius.circular(18),
                topRight:    Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft:  Radius.circular(5),
              ),
              border: Border.all(color: _DS.borderFaint, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('NutriBot is thinking',
                    style: TextStyle(color: _DS.textMuted, fontSize: 11)),
                const SizedBox(width: 8),
                ...List.generate(3, (i) => _typingDot(i)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _typingDot(int index) {
    return AnimatedBuilder(
      animation: _typingCtrl,
      builder: (_, __) {
        final v     = _typingCtrl.value;
        final delay = index * 0.2;
        final glow  = (v >= delay && v <= delay + 0.4) ? 1.0 : 0.3;
        return Container(
          margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
          width: 7, height: 7,
          decoration: BoxDecoration(
            color: _DS.neon.withOpacity(glow),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  // ── Input bar ─────────────────────────────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        border: Border(top: BorderSide(color: _DS.borderFaint, width: 1)),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: AnimatedBuilder(
                animation: _focusNode,
                builder: (_, __) => Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: _DS.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: _focusNode.hasFocus
                          ? _DS.neon.withOpacity(0.5)
                          : _DS.borderFaint,
                      width: 1.2,
                    ),
                  ),
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    enabled: !_isLoading && _isInitialized,
                    style: const TextStyle(color: _DS.textPrimary, fontSize: 14, height: 1.4),
                    cursorColor: _DS.neon,
                    decoration: InputDecoration(
                      hintText: _isInitialized
                          ? 'Ask NutriBot anything...'
                          : 'Connecting to AI...',
                      hintStyle: TextStyle(color: _DS.textMuted, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _buildSendButton(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    final canSend = !_isLoading &&
        _isInitialized &&
        _textController.text.trim().isNotEmpty;

    return GestureDetector(
      onTap: canSend ? _sendMessage : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([_sendCtrl, _glowAnim]),
        builder: (_, __) => Transform.scale(
          scale: 1.0 + _sendCtrl.value * 0.1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48, height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: canSend
                  ? const LinearGradient(
                colors: [_DS.neon, _DS.neonDim],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : null,
              color: canSend ? null : _DS.surface,
              boxShadow: canSend
                  ? [
                BoxShadow(
                  color: _DS.neon.withOpacity(_glowAnim.value * 0.5),
                  blurRadius: 14,
                  spreadRadius: 1,
                )
              ]
                  : null,
            ),
            child: Center(
              child: _isLoading
                  ? SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _DS.neon,
                    backgroundColor: _DS.neonFaint),
              )
                  : Icon(Icons.send_rounded,
                  color: canSend ? _DS.bg : _DS.textMuted, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}