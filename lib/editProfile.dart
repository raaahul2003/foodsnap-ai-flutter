import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eatwise_ai/viewProfile.dart';

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

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with TickerProviderStateMixin {

  // ── State (unchanged) ─────────────────────────────────────────────────────
  bool   _isLoading       = false;
  File?  _selectedImage;
  String _gender          = "Other";
  String _currentPhotoUrl = "";

  // ── Controllers (unchanged) ───────────────────────────────────────────────
  final _nameController     = TextEditingController();
  final _dobController      = TextEditingController();
  final _emailController    = TextEditingController();
  final _phoneController    = TextEditingController();
  final _placeController    = TextEditingController();
  final _postController     = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController    = TextEditingController();
  final _pinController      = TextEditingController();

  // ── Animations ────────────────────────────────────────────────────────────
  late AnimationController _fadeCtrl;
  late AnimationController _glowCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _slideAnim;
  late Animation<double>   _glowAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim  = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic),
    );

    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2600))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.2, end: 0.7).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    _loadProfileData();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _glowCtrl.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _placeController.dispose();
    _postController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  // ── Load profile (UNCHANGED backend logic) ────────────────────────────────
  Future<void> _loadProfileData() async {
    try {
      final prefs   = await SharedPreferences.getInstance();
      final baseUrl = prefs.getString('url') ?? '';
      final lid     = prefs.getString('lid') ?? '';
      final imgBase = prefs.getString('img') ?? '';

      if (baseUrl.isEmpty || lid.isEmpty) return;

      final response = await http.post(
        Uri.parse('$baseUrl/view_profile/'),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            _nameController.text     = data['Name']?.toString()     ?? '';
            _dobController.text      = data['Dob']?.toString()      ?? '';
            _gender                  = data['Gender']?.toString()   ?? 'Other';
            _emailController.text    = data['Email']?.toString()    ?? '';
            _phoneController.text    = data['Phone']?.toString()    ?? '';
            _placeController.text    = data['Place']?.toString()    ?? '';
            _postController.text     = data['Post']?.toString()     ?? '';
            _districtController.text = data['District']?.toString() ?? '';
            _stateController.text    = data['State']?.toString()    ?? '';
            _pinController.text      = data['Pin']?.toString()      ?? '';
            _currentPhotoUrl         =
            '$imgBase${data['Photo']?.toString() ?? ''}';
          });
          _fadeCtrl.forward();
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to load profile: $e",
        backgroundColor: _DS.accent3,
        textColor: Colors.white,
      );
    }
  }

  // ── Date picker (UNCHANGED logic) ─────────────────────────────────────────
  Future<void> _selectDate(BuildContext context) async {
    final now     = DateTime.now();
    final maxDate = DateTime(now.year - 18, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: maxDate,
      firstDate: DateTime(1900),
      lastDate: maxDate,
      helpText: 'Select Date of Birth',
      fieldLabelText: 'DOB',
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _DS.neon,
            onPrimary: _DS.bg,
            surface: _DS.bgCard,
            onSurface: _DS.textPrimary,
          ),
          dialogBackgroundColor: _DS.bgCard,
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() =>
      _dobController.text = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  // ── Image picker (UNCHANGED logic) ────────────────────────────────────────
  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    } else {
      Fluttertoast.showToast(msg: "No image selected");
    }
  }

  // ── Update profile (UNCHANGED backend logic) ──────────────────────────────
  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: "Name and Email are required",
        backgroundColor: _DS.accent3,
        textColor: Colors.white,
      );
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

      var request =
      http.MultipartRequest('POST', Uri.parse('$baseUrl/edit_profile/'));

      request.fields.addAll({
        'uname':     _nameController.text.trim(),
        'id':        lid,
        'udob':      _dobController.text.trim(),
        'uemail':    _emailController.text.trim(),
        'uphone':    _phoneController.text.trim(),
        'uplace':    _placeController.text.trim(),
        'upost':     _postController.text.trim(),
        'udistrict': _districtController.text.trim(),
        'ustate':    _stateController.text.trim(),
        'upin':      _pinController.text.trim(),
        'ugender':   _gender,
      });

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'photo', _selectedImage!.path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'ok') {
          Fluttertoast.showToast(
            msg: "Profile updated successfully ✓",
            backgroundColor: _DS.neonFaint,
            textColor: _DS.neon,
          );
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ViewProfilePage()),
          );
          return;
        }
      }

      Fluttertoast.showToast(
        msg: "Update failed. Please try again.",
        backgroundColor: _DS.accent3,
        textColor: Colors.white,
      );
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

  // ── Gender helpers ────────────────────────────────────────────────────────
  Color _genderColor(String g) {
    switch (g.toLowerCase()) {
      case 'male':   return _DS.accent1;
      case 'female': return _DS.accent3;
      default:       return _DS.accent4;
    }
  }

  IconData _genderIcon(String g) {
    switch (g.toLowerCase()) {
      case 'male':   return Icons.male_rounded;
      case 'female': return Icons.female_rounded;
      default:       return Icons.transgender_rounded;
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
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: AnimatedBuilder(
                  animation: _fadeCtrl,
                  builder: (_, child) => Opacity(
                    opacity: _fadeAnim.value.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, _slideAnim.value),
                      child: child,
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Photo
                        _buildPhotoSection(),
                        const SizedBox(height: 28),

                        // Personal
                        _sectionLabel("Personal Info",
                            Icons.person_rounded, _DS.neon),
                        const SizedBox(height: 14),
                        _buildField(_nameController, "Full Name",
                            Icons.badge_rounded),
                        _buildField(_dobController, "Date of Birth",
                            Icons.calendar_today_rounded,
                            readOnly: true,
                            onTap: () => _selectDate(context)),
                        _buildGenderPicker(),
                        const SizedBox(height: 20),

                        // Contact
                        _sectionLabel("Contact",
                            Icons.contact_phone_rounded, _DS.accent1),
                        const SizedBox(height: 14),
                        _buildField(_emailController, "Email",
                            Icons.email_rounded,
                            keyboard: TextInputType.emailAddress),
                        _buildField(_phoneController, "Phone Number",
                            Icons.phone_rounded,
                            keyboard: TextInputType.phone,
                            formatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ]),
                        const SizedBox(height: 20),

                        // Address
                        _sectionLabel("Address",
                            Icons.location_on_rounded, _DS.accent2),
                        const SizedBox(height: 14),
                        _buildField(_placeController, "Place",
                            Icons.place_rounded),
                        _buildField(_postController, "Post Office",
                            Icons.markunread_mailbox_rounded),
                        _buildField(_districtController, "District",
                            Icons.map_rounded),
                        _buildField(_stateController, "State",
                            Icons.flag_rounded),
                        _buildField(_pinController, "PIN Code",
                            Icons.pin_rounded,
                            keyboard: TextInputType.number,
                            formatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ]),

                        const SizedBox(height: 32),
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

  // ── App bar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
            child: Text(
              "Edit Profile",
              style: TextStyle(
                color: _DS.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _DS.neonFaint,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: _DS.neon.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.camera_enhance_rounded,
                    color: _DS.neon, size: 13),
                const SizedBox(width: 5),
                Text("FoodSnap AI",
                    style: TextStyle(
                        color: _DS.neon,
                        fontSize: 11,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Photo section ─────────────────────────────────────────────────────────
  Widget _buildPhotoSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _pickImage();
            },
            child: AnimatedBuilder(
              animation: _glowAnim,
              builder: (_, __) => Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [_DS.neon, _DS.neonDim],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _DS.neon
                              .withOpacity(_glowAnim.value * 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 58,
                      backgroundColor: _DS.surface,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                      as ImageProvider
                          : (_currentPhotoUrl.isNotEmpty
                          ? NetworkImage(_currentPhotoUrl)
                          : null),
                      child: _selectedImage == null &&
                          _currentPhotoUrl.isEmpty
                          ? Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text[0]
                            .toUpperCase()
                            : "?",
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: _DS.neon,
                        ),
                      )
                          : null,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _DS.neon,
                      shape: BoxShape.circle,
                      border: Border.all(color: _DS.bg, width: 2.5),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: _DS.bg, size: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _selectedImage != null
                ? "New photo selected ✓"
                : "Tap to change photo",
            style: TextStyle(
              color: _selectedImage != null
                  ? _DS.neon
                  : _DS.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────
  Widget _sectionLabel(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: color.withOpacity(0.25), width: 1),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: _DS.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Container(height: 1, color: _DS.borderFaint)),
      ],
    );
  }

  // ── Text field ────────────────────────────────────────────────────────────
  Widget _buildField(
      TextEditingController controller,
      String hint,
      IconData icon, {
        bool readOnly = false,
        VoidCallback? onTap,
        TextInputType? keyboard,
        List<TextInputFormatter>? formatters,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _DS.borderFaint, width: 1.2),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboard,
        inputFormatters: formatters,
        style: const TextStyle(
            color: _DS.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500),
        cursorColor: _DS.neon,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
          const TextStyle(color: _DS.textMuted, fontSize: 14),
          prefixIcon:
          Icon(icon, color: _DS.textMuted, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              vertical: 16, horizontal: 4),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
                color: _DS.neon.withOpacity(0.5), width: 1.2),
          ),
        ),
      ),
    );
  }

  // ── Gender picker ─────────────────────────────────────────────────────────
  Widget _buildGenderPicker() {
    final options = ["Male", "Female", "Other"];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              children: [
                const Icon(Icons.wc_rounded,
                    color: _DS.textMuted, size: 18),
                const SizedBox(width: 8),
                Text("Gender",
                    style: const TextStyle(
                        color: _DS.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Row(
            children: options.map((g) {
              final selected = _gender == g;
              final color = _genderColor(g);
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _gender = g);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin:
                    const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withOpacity(0.15)
                          : _DS.bgCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? color.withOpacity(0.6)
                            : _DS.borderFaint,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(_genderIcon(g),
                            color: selected
                                ? color
                                : _DS.textMuted,
                            size: 22),
                        const SizedBox(height: 4),
                        Text(
                          g,
                          style: TextStyle(
                            color: selected
                                ? color
                                : _DS.textMuted,
                            fontSize: 12,
                            fontWeight: selected
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Save button ───────────────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isLoading
          ? null
          : () {
        HapticFeedback.mediumImpact();
        _updateProfile();
      },
      child: AnimatedBuilder(
        animation: _glowAnim,
        builder: (_, __) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: _isLoading
                ? const LinearGradient(
                colors: [_DS.neonFaint, _DS.neonFaint])
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
                color: _DS.neon
                    .withOpacity(_glowAnim.value * 0.45),
                blurRadius: 24,
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
                const Icon(Icons.save_rounded,
                    color: _DS.bg, size: 20),
                const SizedBox(width: 10),
                Text(
                  "Save Changes",
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
}



// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:eatwise_ai/viewProfile.dart'; // adjust import path if needed
//
// class EditProfilePage extends StatefulWidget {
//   const EditProfilePage({super.key});
//
//   @override
//   State<EditProfilePage> createState() => _EditProfilePageState();
// }
//
// class _EditProfilePageState extends State<EditProfilePage> {
//   bool _isLoading = false;
//   File? _selectedImage;
//
//   // Controllers
//   final _nameController = TextEditingController();
//   final _dobController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _placeController = TextEditingController();
//   final _postController = TextEditingController();
//   final _districtController = TextEditingController();
//   final _stateController = TextEditingController();
//   final _pinController = TextEditingController();
//
//   String _gender = "Other"; // default
//   String _currentPhotoUrl = "";
//
//   @override
//   void initState() {
//     super.initState();
//     _loadProfileData();
//   }
//
//   Future<void> _loadProfileData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final baseUrl = prefs.getString('url') ?? '';
//       final lid = prefs.getString('lid') ?? '';
//       final imgBase = prefs.getString('img') ?? '';
//
//       if (baseUrl.isEmpty || lid.isEmpty) return;
//
//       final uri = Uri.parse('$baseUrl/view_profile/');
//       final response = await http.post(uri, body: {'lid': lid});
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status'] == 'ok') {
//           setState(() {
//             _nameController.text = data['Name']?.toString() ?? '';
//             _dobController.text = data['Dob']?.toString() ?? '';
//             _gender = data['Gender']?.toString() ?? 'Other';
//             _emailController.text = data['Email']?.toString() ?? '';
//             _phoneController.text = data['Phone']?.toString() ?? '';
//             _placeController.text = data['Place']?.toString() ?? '';
//             _postController.text = data['Post']?.toString() ?? '';
//             _districtController.text = data['District']?.toString() ?? '';
//             _stateController.text = data['State']?.toString() ?? '';
//             _pinController.text = data['Pin']?.toString() ?? '';
//             _currentPhotoUrl = '$imgBase${data['Photo']?.toString() ?? ''}';
//           });
//         }
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Failed to load profile: $e");
//     }
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final now = DateTime.now();
//     final maxDate = DateTime(now.year - 18, now.month, now.day); // at least 18 years old
//
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: maxDate,
//       firstDate: DateTime(1900),
//       lastDate: maxDate,
//       helpText: 'Select Date of Birth',
//       fieldLabelText: 'DOB',
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFF4CAF50),
//               onPrimary: Colors.white,
//               onSurface: Colors.black87,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null) {
//       setState(() {
//         _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
//       });
//     }
//   }
//
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//     } else {
//       Fluttertoast.showToast(msg: "No image selected");
//     }
//   }
//
//   Future<void> _updateProfile() async {
//     if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
//       Fluttertoast.showToast(msg: "Name and Email are required");
//       return;
//     }
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
//       final uri = Uri.parse('$baseUrl/edit_profile/');
//       var request = http.MultipartRequest('POST', uri);
//
//       request.fields.addAll({
//         'uname': _nameController.text.trim(),
//         'id': lid,
//         'udob': _dobController.text.trim(),
//         'uemail': _emailController.text.trim(),
//         'uphone': _phoneController.text.trim(),
//         'uplace': _placeController.text.trim(),
//         'upost': _postController.text.trim(),
//         'udistrict': _districtController.text.trim(),
//         'ustate': _stateController.text.trim(),
//         'upin': _pinController.text.trim(),
//         'ugender': _gender,
//       });
//
//       if (_selectedImage != null) {
//         request.files.add(await http.MultipartFile.fromPath(
//           'photo',
//           _selectedImage!.path,
//         ));
//       }
//
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status'] == 'ok') {
//           Fluttertoast.showToast(msg: "Profile updated successfully");
//           if (!mounted) return;
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => const ViewProfilePage()),
//           );
//           return;
//         }
//       }
//
//       Fluttertoast.showToast(msg: "Update failed. Please try again.");
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Error: ${e.toString().split('\n').first}");
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _dobController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _placeController.dispose();
//     _postController.dispose();
//     _districtController.dispose();
//     _stateController.dispose();
//     _pinController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       appBar: AppBar(
//         title: const Text("Edit Profile"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // Profile Photo Section
//               GestureDetector(
//                 onTap: _pickImage,
//                 child: Stack(
//                   alignment: Alignment.bottomRight,
//                   children: [
//                     CircleAvatar(
//                       radius: 68,
//                       backgroundColor: const Color(0xFFE8F5E9),
//                       child: CircleAvatar(
//                         radius: 64,
//                         backgroundColor: Colors.grey[300],
//                         backgroundImage: _selectedImage != null
//                             ? FileImage(_selectedImage!)
//                             : (_currentPhotoUrl.isNotEmpty
//                             ? NetworkImage(_currentPhotoUrl)
//                             : null),
//                         child: _selectedImage == null && _currentPhotoUrl.isEmpty
//                             ? const Icon(Icons.person, size: 64, color: Colors.white)
//                             : null,
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: const BoxDecoration(
//                         color: Color(0xFF4CAF50),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//               const Text(
//                 "Tap to change photo",
//                 style: TextStyle(fontSize: 13, color: Colors.grey),
//               ),
//
//               const SizedBox(height: 32),
//
//               // Form Fields
//               _buildTextField(_nameController, "Full Name", Icons.person_outline),
//               const SizedBox(height: 16),
//               _buildTextField(
//                 _dobController,
//                 "Date of Birth (yyyy-mm-dd)",
//                 Icons.calendar_today_outlined,
//                 onTap: () => _selectDate(context),
//                 readOnly: true,
//               ),
//               const SizedBox(height: 16),
//
//               // Gender Selection
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Padding(
//                       padding: EdgeInsets.only(bottom: 8),
//                       child: Text(
//                         "Gender",
//                         style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
//                       ),
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         _buildGenderOption("Male"),
//                         _buildGenderOption("Female"),
//                         _buildGenderOption("Other"),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//               _buildTextField(_emailController, "Email", Icons.email_outlined),
//               const SizedBox(height: 16),
//               _buildTextField(_phoneController, "Phone Number", Icons.phone_outlined),
//               const SizedBox(height: 16),
//               _buildTextField(_placeController, "Place", Icons.location_on_outlined),
//               const SizedBox(height: 16),
//               _buildTextField(_postController, "Post Office", Icons.local_post_office_outlined),
//               const SizedBox(height: 16),
//               _buildTextField(_districtController, "District", Icons.map_outlined),
//               const SizedBox(height: 16),
//               _buildTextField(_stateController, "State", Icons.public_outlined),
//               const SizedBox(height: 16),
//               _buildTextField(_pinController, "PIN Code", Icons.pin),
//
//               const SizedBox(height: 40),
//
//               // Submit Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton.icon(
//                   onPressed: _isLoading ? null : _updateProfile,
//                   icon: _isLoading
//                       ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
//                   )
//                       : const Icon(Icons.save_outlined),
//                   label: Text(
//                     _isLoading ? "Updating..." : "Save Changes",
//                     style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF4CAF50),
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                     elevation: 2,
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField(
//       TextEditingController controller,
//       String label,
//       IconData icon, {
//         VoidCallback? onTap,
//         bool readOnly = false,
//       }) {
//     return TextField(
//       controller: controller,
//       readOnly: readOnly,
//       onTap: onTap,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildGenderOption(String value) {
//     final selected = _gender == value;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => _gender = value),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           margin: const EdgeInsets.symmetric(horizontal: 4),
//           decoration: BoxDecoration(
//             color: selected ? const Color(0xFFE8F5E9) : Colors.transparent,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: selected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
//               width: selected ? 1.5 : 1,
//             ),
//           ),
//           child: Center(
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: selected ? const Color(0xFF4CAF50) : Colors.black87,
//                 fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }