import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'editProfile.dart';

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

class ViewProfilePage extends StatefulWidget {
  const ViewProfilePage({super.key});

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage>
    with TickerProviderStateMixin {

  // ── State (unchanged) ─────────────────────────────────────────────────────
  bool _isLoading    = true;
  bool _hasError     = false;
  String _errorMessage = '';

  String name     = '';
  String dob      = '';
  String gender   = '';
  String email    = '';
  String phone    = '';
  String place    = '';
  String post     = '';
  String pin      = '';
  String district = '';
  String state    = '';
  String photoUrl = '';

  // ── Animations ────────────────────────────────────────────────────────────
  late AnimationController _fadeCtrl;
  late AnimationController _glowCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _slideAnim;
  late Animation<double>   _glowAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim  = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic),
    );

    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.2, end: 0.7).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    _fetchProfileData();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  // ── Fetch (UNCHANGED backend logic) ──────────────────────────────────────
  Future<void> _fetchProfileData() async {
    setState(() {
      _isLoading    = true;
      _hasError     = false;
      _errorMessage = '';
    });

    try {
      final prefs   = await SharedPreferences.getInstance();
      final baseUrl = prefs.getString('url') ?? '';
      final lid     = prefs.getString('lid') ?? '';
      final imgBase = prefs.getString('img') ?? '';

      if (baseUrl.isEmpty || lid.isEmpty) throw Exception('Missing URL or user ID');

      final response = await http.post(
        Uri.parse('$baseUrl/view_profile/'),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'ok') {
          final fetchedName = data['Name']?.toString() ?? '—';
          await prefs.setString('username', fetchedName);

          setState(() {
            name     = fetchedName;
            dob      = data['Dob']?.toString()      ?? '—';
            gender   = data['Gender']?.toString()   ?? '—';
            email    = data['Email']?.toString()     ?? '—';
            phone    = data['Phone']?.toString()     ?? '—';
            place    = data['Place']?.toString()     ?? '—';
            post     = data['Post']?.toString()      ?? '—';
            pin      = data['Pin']?.toString()       ?? '—';
            district = data['District']?.toString()  ?? '—';
            state    = data['State']?.toString()     ?? '—';
            photoUrl = '$imgBase${data['Photo']?.toString() ?? ''}';
          });

          _fadeCtrl.forward(from: 0);
        } else {
          setState(() {
            _hasError     = true;
            _errorMessage = data['message'] ?? 'Profile not found';
          });
        }
      } else {
        setState(() {
          _hasError     = true;
          _errorMessage = 'Server error (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _hasError     = true;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      Fluttertoast.showToast(
        msg: _errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: _DS.accent3,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Gender color helper ───────────────────────────────────────────────────
  Color _genderColor() {
    switch (gender.toLowerCase()) {
      case 'male':   return _DS.accent1;
      case 'female': return _DS.accent3;
      default:       return _DS.accent4;
    }
  }

  // ╔════════════════════════════════════════════════════════════════════════╗
  // ║  BUILD                                                                ║
  // ╚════════════════════════════════════════════════════════════════════════╝
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _DS.bg,
        body: _isLoading
            ? _buildLoader()
            : _hasError
            ? _buildErrorState()
            : _buildProfile(),
      ),
    );
  }

  // ── Loading ───────────────────────────────────────────────────────────────
  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: _DS.neon,
              strokeWidth: 2.5,
              backgroundColor: _DS.neonFaint,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Loading profile...",
            style: TextStyle(color: _DS.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ── Error state ───────────────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _DS.accent3.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: _DS.accent3.withOpacity(0.3), width: 1),
              ),
              child: const Icon(Icons.error_outline_rounded, size: 48, color: _DS.accent3),
            ),
            const SizedBox(height: 20),
            Text(
              "Something went wrong",
              style: TextStyle(color: _DS.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: _DS.textMuted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _fetchProfileData,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: _DS.neonFaint,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _DS.neon.withOpacity(0.4), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded, color: _DS.neon, size: 18),
                    const SizedBox(width: 8),
                    Text("Try Again", style: TextStyle(color: _DS.neon, fontSize: 14, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Profile body ──────────────────────────────────────────────────────────
  Widget _buildProfile() {
    return RefreshIndicator(
      color: _DS.neon,
      backgroundColor: _DS.bgCard,
      onRefresh: _fetchProfileData,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── SliverAppBar ─────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: _DS.bg,
            elevation: 0,
            floating: true,
            pinned: false,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _DS.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _DS.borderFaint, width: 1),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: _DS.neon, size: 16),
              ),
            ),
            title: Text(
              "Profile",
              style: TextStyle(
                color: _DS.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _fetchProfileData();
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: _DS.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _DS.borderFaint, width: 1),
                  ),
                  child: const Icon(Icons.refresh_rounded, color: _DS.neon, size: 18),
                ),
              ),
            ],
          ),

          // ── Content ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _fadeCtrl,
              builder: (_, child) => Opacity(
                opacity: _fadeAnim.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnim.value),
                  child: child,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
                child: Column(
                  children: [
                    _buildHeroCard(),
                    const SizedBox(height: 20),
                    _buildInfoSection(
                      title: "Personal Info",
                      icon: Icons.person_rounded,
                      color: _DS.neon,
                      items: [
                        _InfoItem(Icons.cake_rounded,         "Date of Birth", dob,      _DS.accent4),
                        _InfoItem(Icons.wc_rounded,           "Gender",        gender,   _genderColor()),
                        _InfoItem(Icons.phone_rounded,        "Phone",         phone,    _DS.accent1),
                        _InfoItem(Icons.email_rounded,        "Email",         email,    _DS.accent5),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoSection(
                      title: "Address",
                      icon: Icons.location_on_rounded,
                      color: _DS.accent2,
                      items: [
                        _InfoItem(Icons.place_rounded,            "Place",        place,    _DS.accent2),
                        _InfoItem(Icons.markunread_mailbox_rounded,"Post Office",  post,     _DS.neon),
                        _InfoItem(Icons.pin_rounded,               "PIN Code",     pin,      _DS.accent4),
                        _InfoItem(Icons.map_rounded,               "District",     district, _DS.accent1),
                        _InfoItem(Icons.flag_rounded,              "State",        state,    _DS.accent3),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildEditButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero card ─────────────────────────────────────────────────────────────
  Widget _buildHeroCard() {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _DS.bgCard,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _DS.neon.withOpacity(0.2), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: _DS.neon.withOpacity(_glowAnim.value * 0.12),
              blurRadius: 28,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [_DS.neon, _DS.neonDim],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _DS.neon.withOpacity(_glowAnim.value * 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: _DS.surface,
                    backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                    child: photoUrl.isEmpty
                        ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "?",
                      style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: _DS.neon),
                    )
                        : null,
                  ),
                ),
                // Online badge
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _DS.bg,
                    shape: BoxShape.circle,
                    border: Border.all(color: _DS.neon, width: 2),
                  ),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(color: _DS.neon, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Name
            Text(
              name.isEmpty ? "—" : name,
              style: TextStyle(
                color: _DS.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),

            // Email
            Text(
              email.isEmpty ? "—" : email,
              style: TextStyle(color: _DS.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),

            // Quick stat chips
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _heroChip(Icons.wc_rounded, gender, _genderColor()),
                const SizedBox(width: 8),
                _heroChip(Icons.cake_rounded, dob, _DS.accent4),
                const SizedBox(width: 8),
                _heroChip(Icons.location_on_rounded, place, _DS.accent2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroChip(IconData icon, String value, Color color) {
    if (value.isEmpty || value == '—') return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 80),
            child: Text(
              value,
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Info section card ─────────────────────────────────────────────────────
  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<_InfoItem> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.2), width: 1),
                ),
                child: Icon(icon, size: 15, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: _DS.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: _DS.borderFaint),
          const SizedBox(height: 4),

          // Info rows
          ...items.map((item) => _buildInfoRow(item)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(_InfoItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(item.icon, size: 15, color: item.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(color: _DS.textMuted, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.3),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value.isEmpty ? '—' : item.value,
                  style: TextStyle(
                    color: item.value.isEmpty || item.value == '—'
                        ? _DS.textMuted
                        : _DS.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Copy icon
          if (item.value.isNotEmpty && item.value != '—')
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Clipboard.setData(ClipboardData(text: item.value));
                Fluttertoast.showToast(
                  msg: "${item.label} copied",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: _DS.neonFaint,
                  textColor: _DS.neon,
                );
              },
              child: Icon(Icons.copy_rounded, size: 15, color: _DS.textMuted.withOpacity(0.5)),
            ),
        ],
      ),
    );
  }

  // ── Edit profile button ────────────────────────────────────────────────────
  Widget _buildEditButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditProfilePage()),
        ).then((_) => _fetchProfileData());
      },
      child: AnimatedBuilder(
        animation: _glowAnim,
        builder: (_, __) => Container(
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
                color: _DS.neon.withOpacity(_glowAnim.value * 0.45),
                blurRadius: 24,
                spreadRadius: -4,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit_rounded, color: _DS.bg, size: 20),
              const SizedBox(width: 10),
              Text(
                "Edit Profile",
                style: TextStyle(
                  color: _DS.bg,
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
}

// ── Data model ────────────────────────────────────────────────────────────────
class _InfoItem {
  final IconData icon;
  final String   label;
  final String   value;
  final Color    color;
  const _InfoItem(this.icon, this.label, this.value, this.color);
}




// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'editProfile.dart'; // ← make sure this file exists
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
//         fontFamily: 'Roboto',
//         colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
//         useMaterial3: true,
//       ),
//       home: const ViewProfilePage(),
//     );
//   }
// }
//
// class ViewProfilePage extends StatefulWidget {
//   const ViewProfilePage({super.key});
//
//   @override
//   State<ViewProfilePage> createState() => _ViewProfilePageState();
// }
//
// class _ViewProfilePageState extends State<ViewProfilePage> {
//   bool _isLoading = true;
//   bool _hasError = false;
//   String _errorMessage = '';
//
//   // Profile fields
//   String name = '';
//   String dob = '';
//   String gender = '';
//   String email = '';
//   String phone = '';
//   String place = '';
//   String post = '';
//   String pin = '';
//   String district = '';
//   String state = '';
//   String photoUrl = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchProfileData();
//   }
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
//             dob = data['Dob']?.toString() ?? '—';
//             gender = data['Gender']?.toString() ?? '—';
//             email = data['Email']?.toString() ?? '—';
//             phone = data['Phone']?.toString() ?? '—';
//             place = data['Place']?.toString() ?? '—';
//             post = data['Post']?.toString() ?? '—';
//             pin = data['Pin']?.toString() ?? '—';
//             district = data['District']?.toString() ?? '—';
//             state = data['State']?.toString() ?? '—';
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
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh_rounded),
//             onPressed: _fetchProfileData,
//             tooltip: 'Refresh',
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _hasError
//           ? Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.error_outline_rounded, size: 64, color: Colors.red[300]),
//             const SizedBox(height: 16),
//             Text(
//               'Something went wrong',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: 8),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 32),
//               child: Text(
//                 _errorMessage,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.grey[700]),
//               ),
//             ),
//             const SizedBox(height: 24),
//             OutlinedButton.icon(
//               onPressed: _fetchProfileData,
//               icon: const Icon(Icons.refresh),
//               label: const Text('Try Again'),
//             ),
//           ],
//         ),
//       )
//           : RefreshIndicator(
//         onRefresh: _fetchProfileData,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
//           child: Column(
//             children: [
//               // ── Profile Header Card ───────────────────────────────
//               Card(
//                 elevation: 2,
//                 shadowColor: Colors.black12,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     children: [
//                       CircleAvatar(
//                         radius: 62,
//                         backgroundColor: const Color(0xFFE8F5E9),
//                         child: CircleAvatar(
//                           radius: 58,
//                           backgroundColor: Colors.grey[300],
//                           backgroundImage:
//                           photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
//                           child: photoUrl.isEmpty
//                               ? const Icon(Icons.person, size: 60, color: Colors.white)
//                               : null,
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Text(
//                         name,
//                         style: const TextStyle(
//                           fontSize: 26,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         email,
//                         style: TextStyle(
//                           fontSize: 15,
//                           color: Colors.grey[700],
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       SizedBox(
//                         width: double.infinity,
//                         child: OutlinedButton.icon(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>  EditProfilePage(),
//                               ),
//                             ).then((_) => _fetchProfileData()); // refresh after edit
//                           },
//                           icon: const Icon(Icons.edit_outlined, size: 18),
//                           label: const Text('Edit Profile'),
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             side: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
//                             foregroundColor: const Color(0xFF4CAF50),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//
//               // ── Personal Info Card ────────────────────────────────
//               Card(
//                 elevation: 1,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Personal Information',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       _buildInfoRow('Date of Birth', dob),
//                       _buildInfoRow('Gender', gender),
//                       _buildInfoRow('Phone', phone),
//                       _buildInfoRow('Email', email),
//                       const Divider(height: 32),
//                       _buildInfoRow('Place', place),
//                       _buildInfoRow('Post Office', post),
//                       _buildInfoRow('PIN', pin),
//                       _buildInfoRow('District', district),
//                       _buildInfoRow('State', state),
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
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: TextStyle(
//                 color: Colors.grey[700],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value.isEmpty ? '—' : value,
//               style: const TextStyle(fontWeight: FontWeight.w500),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }