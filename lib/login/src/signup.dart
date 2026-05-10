import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:eatwise_ai/login/src/Widget/bezierContainer.dart';
import 'package:eatwise_ai/login/src/loginPage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Design Tokens (matches UserHome _DS) ──────────────────────────────────────
class _DS {
  static const bg        = Color(0xFF050D0A);
  static const bgCard    = Color(0xFF0C1A13);
  static const surface   = Color(0xFF0F2018);
  static const neon      = Color(0xFF00FF88);
  static const neonDim   = Color(0xFF00C46A);
  static const neonFaint = Color(0xFF003D22);
  static const accent1   = Color(0xFF00E5FF);
  static const accent2   = Color(0xFFB2FF59);
  static const accent3   = Color(0xFFFF6B6B);
  static const accent4   = Color(0xFFFFD166);
  static const textPrimary   = Color(0xFFF0FFF8);
  static const textSecondary = Color(0xFF6EE7B7);
  static const textMuted     = Color(0xFF2E6B4A);
  static const borderFaint   = Color(0xFF1A3D2A);
}

class SignUpPage extends StatefulWidget {
  SignUpPage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {

  // ── Controllers (unchanged) ───────────────────────────────────────────────
  final TextEditingController namecontroller            = TextEditingController();
  final TextEditingController Dobcontroller             = TextEditingController();
  final TextEditingController emailcontroller           = TextEditingController();
  final TextEditingController phonenumberontroller      = TextEditingController();
  final TextEditingController placecontroller           = TextEditingController();
  final TextEditingController postcontroller            = TextEditingController();
  final TextEditingController districtcontroller        = TextEditingController();
  final TextEditingController statecontroller           = TextEditingController();
  final TextEditingController pincontroller             = TextEditingController();
  final TextEditingController passwordcontroller        = TextEditingController();
  final TextEditingController confirmpasswordcontroller = TextEditingController();

  String gender = "";

  // ── UI state ──────────────────────────────────────────────────────────────
  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting           = false;

  // ── Validation errors ─────────────────────────────────────────────────────
  final Map<String, String?> _errors = {};

  // ── Animations ────────────────────────────────────────────────────────────
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    namecontroller.dispose();
    Dobcontroller.dispose();
    emailcontroller.dispose();
    phonenumberontroller.dispose();
    placecontroller.dispose();
    postcontroller.dispose();
    districtcontroller.dispose();
    statecontroller.dispose();
    pincontroller.dispose();
    passwordcontroller.dispose();
    confirmpasswordcontroller.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────
  bool _validate() {
    final Map<String, String?> e = {};

    if (namecontroller.text.trim().isEmpty)
      e['name'] = 'Full name is required';

    if (Dobcontroller.text.trim().isEmpty)
      e['dob'] = 'Date of birth is required';

    if (gender.isEmpty)
      e['gender'] = 'Please select a gender';

    if (emailcontroller.text.trim().isEmpty)
      e['email'] = 'Email is required';
    else if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(emailcontroller.text.trim()))
      e['email'] = 'Enter a valid email address';

    if (phonenumberontroller.text.trim().isEmpty)
      e['phone'] = 'Phone number is required';
    else if (phonenumberontroller.text.trim().length < 10)
      e['phone'] = 'Enter a valid 10-digit number';

    if (placecontroller.text.trim().isEmpty)
      e['place'] = 'Place is required';

    if (postcontroller.text.trim().isEmpty)
      e['post'] = 'Post is required';

    if (districtcontroller.text.trim().isEmpty)
      e['district'] = 'District is required';

    if (statecontroller.text.trim().isEmpty)
      e['state'] = 'State is required';

    if (pincontroller.text.trim().isEmpty)
      e['pin'] = 'PIN code is required';
    else if (pincontroller.text.trim().length != 6)
      e['pin'] = 'PIN must be 6 digits';

    if (passwordcontroller.text.isEmpty)
      e['password'] = 'Password is required';
    else if (passwordcontroller.text.length < 6)
      e['password'] = 'Minimum 6 characters';

    if (confirmpasswordcontroller.text.isEmpty)
      e['confirm'] = 'Please confirm your password';
    else if (confirmpasswordcontroller.text != passwordcontroller.text)
      e['confirm'] = 'Passwords do not match';

    if (_selectedImage == null)
      e['photo'] = 'Profile photo is required';

    setState(() => _errors.addAll(e));
    return e.isEmpty;
  }

  // ── Date picker (unchanged logic) ─────────────────────────────────────────
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now      = DateTime.now();
    final DateTime lastDate = DateTime(now.year - 18, now.month, now.day);
    final DateTime firstDate = DateTime(1900);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: lastDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select Date of Birth',
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

    if (pickedDate != null) {
      setState(() {
        Dobcontroller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        _errors.remove('dob');
      });
    }
  }

  // ── Send data (UNCHANGED backend logic) ───────────────────────────────────
  Future<void> _sendData() async {
    // Clear previous errors
    setState(() => _errors.clear());

    if (!_validate()) {
      Fluttertoast.showToast(
        msg: "Please fill all required fields",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: _DS.accent3,
        textColor: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    String uname           = namecontroller.text;
    String udob            = Dobcontroller.text;
    String uemail          = emailcontroller.text;
    String uphone          = phonenumberontroller.text;
    String uplace          = placecontroller.text;
    String upost           = postcontroller.text;
    String udistrict       = districtcontroller.text;
    String ustate          = statecontroller.text;
    String upin            = pincontroller.text;
    String upassword       = passwordcontroller.text;
    String uconfirmpassword = confirmpasswordcontroller.text;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');

    // if (url == null) {
    //   Fluttertoast.showToast(msg: "Server URL not found.");
    //   setState(() => _isSubmitting = false);
    //   return;
    // }

    final uri = Uri.parse('$url/user_signup/');
    var request = http.MultipartRequest('POST', uri);
    request.fields['uname']            = uname;
    request.fields['udob']             = udob;
    request.fields['uemail']           = uemail;
    request.fields['uphone']           = uphone;
    request.fields['uplace']           = uplace;
    request.fields['upost']            = upost;
    request.fields['udistrict']        = udistrict;
    request.fields['ustate']           = ustate;
    request.fields['upin']             = upin;
    request.fields['ugender']          = gender;
    request.fields['upassword']        = upassword;
    request.fields['uconfirmpassword'] = uconfirmpassword;

    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
    }

    try {
      var response = await request.send();
      var respStr  = await response.stream.bytesToString();
      var data     = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(
          msg: "Account created successfully! 🎉",
          backgroundColor: _DS.neon,
          textColor: _DS.bg,
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
      } else if (response.statusCode == 200 && data['status'] == 'ex') {
        Fluttertoast.showToast(
          msg: "Email already exists",
          backgroundColor: _DS.accent3,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Submission failed. Please try again.",
          backgroundColor: _DS.accent3,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  // ── Image picker (unchanged logic) ────────────────────────────────────────
  File? _selectedImage;
  Future<void> _chooseImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _errors.remove('photo');
      });
    } else {
      Fluttertoast.showToast(msg: "No image selected");
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
        body: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header ──────────────────────────────────────────────────
              SliverToBoxAdapter(child: _buildHeader()),

              // ── Form body ───────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    // Photo upload
                    _buildPhotoSection(),
                    const SizedBox(height: 28),

                    // Personal info section
                    _sectionLabel("Personal Info", Icons.person_rounded, _DS.neon),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: namecontroller,
                      hint: "Full Name",
                      icon: Icons.badge_rounded,
                      errorKey: 'name',
                      onChanged: (_) => setState(() => _errors.remove('name')),
                    ),
                    _buildField(
                      controller: Dobcontroller,
                      hint: "Date of Birth",
                      icon: Icons.calendar_today_rounded,
                      errorKey: 'dob',
                      readOnly: true,
                      onTap: () => _selectDate(context),
                    ),
                    _buildGenderPicker(),
                    const SizedBox(height: 20),

                    // Contact section
                    _sectionLabel("Contact", Icons.contact_phone_rounded, _DS.accent1),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: emailcontroller,
                      hint: "Email Address",
                      icon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      errorKey: 'email',
                      onChanged: (_) => setState(() => _errors.remove('email')),
                    ),
                    _buildField(
                      controller: phonenumberontroller,
                      hint: "Phone Number",
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                      errorKey: 'phone',
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                      onChanged: (_) => setState(() => _errors.remove('phone')),
                    ),
                    const SizedBox(height: 20),

                    // Address section
                    _sectionLabel("Address", Icons.location_on_rounded, _DS.accent2),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: placecontroller,
                      hint: "Place",
                      icon: Icons.place_rounded,
                      errorKey: 'place',
                      onChanged: (_) => setState(() => _errors.remove('place')),
                    ),
                    _buildField(
                      controller: postcontroller,
                      hint: "Post",
                      icon: Icons.markunread_mailbox_rounded,
                      errorKey: 'post',
                      onChanged: (_) => setState(() => _errors.remove('post')),
                    ),
                    _buildField(
                      controller: districtcontroller,
                      hint: "District",
                      icon: Icons.map_rounded,
                      errorKey: 'district',
                      onChanged: (_) => setState(() => _errors.remove('district')),
                    ),
                    _buildField(
                      controller: statecontroller,
                      hint: "State",
                      icon: Icons.flag_rounded,
                      errorKey: 'state',
                      onChanged: (_) => setState(() => _errors.remove('state')),
                    ),
                    _buildField(
                      controller: pincontroller,
                      hint: "PIN Code",
                      icon: Icons.pin_rounded,
                      keyboardType: TextInputType.number,
                      errorKey: 'pin',
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                      onChanged: (_) => setState(() => _errors.remove('pin')),
                    ),
                    const SizedBox(height: 20),

                    // Security section
                    _sectionLabel("Security", Icons.lock_rounded, _DS.accent4),
                    const SizedBox(height: 14),
                    _buildPasswordField(
                      controller: passwordcontroller,
                      hint: "Password",
                      errorKey: 'password',
                      obscure: _obscurePassword,
                      onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                      onChanged: (_) => setState(() => _errors.remove('password')),
                    ),
                    _buildPasswordField(
                      controller: confirmpasswordcontroller,
                      hint: "Confirm Password",
                      errorKey: 'confirm',
                      obscure: _obscureConfirmPassword,
                      onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      onChanged: (_) => setState(() => _errors.remove('confirm')),
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    _buildSubmitButton(),
                    const SizedBox(height: 20),

                    // Login link
                    _buildLoginLink(),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
      decoration: BoxDecoration(
        color: _DS.bgCard,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        border: Border.all(color: _DS.neon.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(color: _DS.neon.withOpacity(0.08), blurRadius: 32, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + Logo row
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: _DS.neonFaint,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _DS.neon.withOpacity(0.3), width: 1),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: _DS.neon, size: 16),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _DS.neonFaint,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: _DS.neon.withOpacity(0.35), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.camera_enhance_rounded, color: _DS.neon, size: 15),
                    const SizedBox(width: 6),
                    Text(
                      "FoodSnap AI",
                      style: TextStyle(
                        color: _DS.neon,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            "Create Account",
            style: TextStyle(
              color: _DS.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              text: "Join ",
              style: TextStyle(color: _DS.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
              children: [
                TextSpan(
                  text: "FoodSnap AI",
                  style: TextStyle(color: _DS.neon, fontWeight: FontWeight.w700),
                ),
                TextSpan(text: " — your AI nutrition companion"),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Progress indicator — 3 steps visually
          Row(
            children: [
              _stepDot("1", "Personal", _DS.neon, true),
              _stepLine(),
              _stepDot("2", "Address", _DS.accent1, false),
              _stepLine(),
              _stepDot("3", "Security", _DS.accent4, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepDot(String step, String label, Color color, bool active) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.2) : _DS.surface,
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(active ? 0.7 : 0.25), width: 1.5),
          ),
          child: Center(
            child: Text(step, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _stepLine() {
    return Expanded(
      child: Container(
        height: 1,
        margin: const EdgeInsets.only(bottom: 18, left: 4, right: 4),
        color: _DS.borderFaint,
      ),
    );
  }

  // ── Photo upload section ────────────────────────────────────────────────────
  Widget _buildPhotoSection() {
    final hasError = _errors['photo'] != null;
    return Column(
      children: [
        const SizedBox(height: 28),
        Center(
          child: GestureDetector(
            onTap: _chooseImage,
            child: Stack(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _DS.bgCard,
                    border: Border.all(
                      color: hasError ? _DS.accent3 : (_selectedImage != null ? _DS.neon : _DS.borderFaint),
                      width: hasError ? 2 : 1.5,
                    ),
                    boxShadow: _selectedImage != null
                        ? [BoxShadow(color: _DS.neon.withOpacity(0.25), blurRadius: 20, spreadRadius: 0)]
                        : [],
                  ),
                  child: ClipOval(
                    child: _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover)
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_rounded,
                            color: hasError ? _DS.accent3 : _DS.textMuted, size: 28),
                        const SizedBox(height: 4),
                        Text(
                          "Add Photo",
                          style: TextStyle(
                            color: hasError ? _DS.accent3 : _DS.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Edit badge
                if (_selectedImage != null)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _DS.neon,
                        shape: BoxShape.circle,
                        border: Border.all(color: _DS.bg, width: 2),
                      ),
                      child: const Icon(Icons.edit_rounded, color: _DS.bg, size: 13),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          Text(
            _errors['photo']!,
            style: const TextStyle(color: _DS.accent3, fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            _selectedImage != null ? "Photo selected ✓" : "* Profile photo required",
            style: TextStyle(
              color: _selectedImage != null ? _DS.neon : _DS.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
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
            border: Border.all(color: color.withOpacity(0.25), width: 1),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: _DS.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: _DS.borderFaint)),
      ],
    );
  }

  // ── Text field ────────────────────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String errorKey,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    final hasError = _errors[errorKey] != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: _DS.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError ? _DS.accent3.withOpacity(0.7) : _DS.borderFaint,
              width: 1.2,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            onChanged: onChanged,
            inputFormatters: inputFormatters,
            style: const TextStyle(color: _DS.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
            cursorColor: _DS.neon,
            decoration: InputDecoration(
              hintText: "$hint *",
              hintStyle: TextStyle(color: _DS.textMuted, fontSize: 14),
              prefixIcon: Icon(icon, color: hasError ? _DS.accent3 : _DS.textMuted, size: 20),
              suffixIcon: hasError ? const Icon(Icons.error_outline_rounded, color: _DS.accent3, size: 18) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 14, bottom: 10),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: _DS.accent3, size: 12),
                const SizedBox(width: 4),
                Text(
                  _errors[errorKey]!,
                  style: const TextStyle(color: _DS.accent3, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )
        else
          const SizedBox(height: 12),
      ],
    );
  }

  // ── Password field ────────────────────────────────────────────────────────
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required String errorKey,
    required bool obscure,
    required VoidCallback onToggle,
    ValueChanged<String>? onChanged,
  }) {
    final hasError = _errors[errorKey] != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: _DS.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError ? _DS.accent3.withOpacity(0.7) : _DS.borderFaint,
              width: 1.2,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            onChanged: onChanged,
            style: const TextStyle(color: _DS.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
            cursorColor: _DS.neon,
            decoration: InputDecoration(
              hintText: "$hint *",
              hintStyle: TextStyle(color: _DS.textMuted, fontSize: 14),
              prefixIcon: Icon(Icons.lock_rounded, color: hasError ? _DS.accent3 : _DS.textMuted, size: 20),
              suffixIcon: IconButton(
                onPressed: onToggle,
                icon: Icon(
                  obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: _DS.textMuted,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 14, bottom: 10),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: _DS.accent3, size: 12),
                const SizedBox(width: 4),
                Text(
                  _errors[errorKey]!,
                  style: const TextStyle(color: _DS.accent3, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )
        else
          const SizedBox(height: 12),
      ],
    );
  }

  // ── Gender picker ─────────────────────────────────────────────────────────
  Widget _buildGenderPicker() {
    final hasError = _errors['gender'] != null;
    final options = ["Male", "Female", "Other"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Icon(Icons.wc_rounded, color: hasError ? _DS.accent3 : _DS.textMuted, size: 18),
              const SizedBox(width: 8),
              Text(
                "Gender *",
                style: TextStyle(
                  color: hasError ? _DS.accent3 : _DS.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Pills
        Row(
          children: options.map((g) {
            final selected = gender == g;
            final color = g == "Male" ? _DS.accent1 : g == "Female" ? _DS.accent3 : _DS.accent4;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    gender = g;
                    _errors.remove('gender');
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? color.withOpacity(0.18) : _DS.bgCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? color.withOpacity(0.6) : _DS.borderFaint,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        g == "Male"
                            ? Icons.male_rounded
                            : g == "Female"
                            ? Icons.female_rounded
                            : Icons.transgender_rounded,
                        color: selected ? color : _DS.textMuted,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        g,
                        style: TextStyle(
                          color: selected ? color : _DS.textMuted,
                          fontSize: 12,
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 8, bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: _DS.accent3, size: 12),
                const SizedBox(width: 4),
                Text(
                  _errors['gender']!,
                  style: const TextStyle(color: _DS.accent3, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  // ── Submit button ─────────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isSubmitting ? null : _sendData,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isSubmitting
                ? [_DS.neonFaint, _DS.neonFaint]
                : [_DS.neon, _DS.neonDim],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: _isSubmitting
              ? []
              : [
            BoxShadow(color: _DS.neon.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 6)),
          ],
        ),
        child: Center(
          child: _isSubmitting
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              color: _DS.neon,
              strokeWidth: 2.5,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded, color: _DS.bg, size: 20),
              const SizedBox(width: 10),
              Text(
                "Create Account",
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

  // ── Login link ────────────────────────────────────────────────────────────
  Widget _buildLoginLink() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage())),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Already have an account? ",
              style: TextStyle(color: _DS.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Text(
              "Sign In",
              style: TextStyle(color: _DS.neon, fontSize: 13, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_rounded, color: _DS.neon, size: 14),
          ],
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
// import 'package:eatwise_ai/login/src/Widget/bezierContainer.dart';
// import 'package:eatwise_ai/login/src/loginPage.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class SignUpPage extends StatefulWidget {
//   SignUpPage({Key ?key, this.title}) : super(key: key);
//
//   final String? title;
//
//
//   @override
//   _SignUpPageState createState() => _SignUpPageState();
// }
//
// class _SignUpPageState extends State<SignUpPage> {
//
//
//
//   TextEditingController namecontroller = new TextEditingController();
//   TextEditingController Dobcontroller = new TextEditingController();
//   TextEditingController emailcontroller = new TextEditingController();
//   TextEditingController phonenumberontroller = new TextEditingController();
//   TextEditingController placecontroller = new TextEditingController();
//   TextEditingController postcontroller = new TextEditingController();
//   TextEditingController districtcontroller = new TextEditingController();
//   TextEditingController statecontroller = new TextEditingController();
//   TextEditingController pincontroller = new TextEditingController();
//   TextEditingController passwordcontroller = new TextEditingController();
//   TextEditingController confirmpasswordcontroller = new TextEditingController();
//
//   String gender = "";
//
//
//   Future<void> _selectDate(BuildContext context) async {
//     // Calculate the latest valid date (must be at least 18 years old)
//     final DateTime now = DateTime.now();
//     final DateTime lastDate = DateTime(now.year - 18, now.month, now.day);
//     final DateTime firstDate = DateTime(1900); // You can adjust this
//
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: lastDate,
//       firstDate: firstDate,
//       lastDate: lastDate, // user can’t pick dates after this (younger than 18)
//       helpText: 'Select Date of Birth',
//     );
//
//     if (pickedDate != null) {
//       String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
//       setState(() {
//         Dobcontroller.text = formattedDate;
//       });
//     }
//   }
//
//
//   Future<void> _sendData() async {
//     String uname = namecontroller.text;
//     String udob = Dobcontroller.text;
//     String uemail = emailcontroller.text;
//     String uphone = phonenumberontroller.text;
//     String uplace = placecontroller.text;
//     String upost = postcontroller.text;
//     String udistrict = districtcontroller.text;
//     String ustate = statecontroller.text;
//     String upin = pincontroller.text;
//     String upassword = passwordcontroller.text;
//     String uconfirmpassword = confirmpasswordcontroller.text;
//
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String? url = sh.getString('url');
//
//     if (url == null) {
//       Fluttertoast.showToast(msg: "Server URL not found.");
//       return;
//     }
//
//     final uri = Uri.parse('$url/user_signup/');
//     var request = http.MultipartRequest('POST', uri);
//     request.fields['uname'] = uname;
//     request.fields['udob'] = udob;
//     request.fields['uemail'] = uemail;
//     request.fields['uphone'] = uphone;
//     request.fields['uplace'] = uplace;
//     request.fields['upost'] = upost;
//     request.fields['udistrict'] = udistrict;
//     request.fields['ustate'] = ustate;
//     request.fields['upin'] = upin;
//     request.fields['ugender'] = gender;
//     request.fields['upassword'] = upassword;
//     request.fields['uconfirmpassword'] = uconfirmpassword;
//
//     if (_selectedImage != null) {
//       request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
//     }
//
//     try {
//       var response = await request.send();
//       var respStr = await response.stream.bytesToString();
//       var data = jsonDecode(respStr);
//
//       if (response.statusCode == 200 && data['status'] == 'ok') {
//         Fluttertoast.showToast(msg: "Submitted successfully.");
//         Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
//       }
//       else if (response.statusCode == 200 && data['status'] == 'ex') {
//         Fluttertoast.showToast(msg: "Email already existing");
//       }
//
//       else {
//         Fluttertoast.showToast(msg: "Submission failed.");
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Error: $e");
//     }
//   }
//
//
//
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
//
//   Widget _submitButton() {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       padding: EdgeInsets.symmetric(vertical: 15),
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.all(Radius.circular(5)),
//           boxShadow: <BoxShadow>[
//             BoxShadow(
//                 color: Colors.grey.shade200,
//                 offset: Offset(2, 4),
//                 blurRadius: 5,
//                 spreadRadius: 2)
//           ],
//           gradient: LinearGradient(
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//               colors: [Color(0xfff3a71c), Color(0xfff3a71c)])),
//       child:TextButton(onPressed: (){
//         _sendData();
//       }, child: Text('Register Now',style: TextStyle(fontSize: 20, color: Colors.white),))
//       // Text(
//       //   'Register Now',
//       //   style: TextStyle(fontSize: 20, color: Colors.white),
//       // ),
//     );
//   }
//
//   Widget _loginAccountLabel() {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//             context, MaterialPageRoute(builder: (context) => LoginPage()));
//       },
//       child: Container(
//         margin: EdgeInsets.symmetric(vertical: 20),
//         padding: EdgeInsets.all(15),
//         alignment: Alignment.bottomCenter,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Already have an account ?',
//               style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
//             ),
//             SizedBox(
//               width: 10,
//             ),
//             Text(
//               'Login',
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
//           text: 'd',
//           style: TextStyle(
//               fontSize: 30,
//               fontWeight: FontWeight.w700,
//               color: Color(0xffe46b10)
//           ),
//
//           children: [
//             TextSpan(
//               text: 'ev',
//               style: TextStyle(color: Colors.black, fontSize: 30),
//             ),
//             TextSpan(
//               text: 'rnz',
//               style: TextStyle(color: Color(0xffe46b10), fontSize: 30),
//             ),
//           ]),
//     );
//   }
//
//   Widget _emailPasswordWidget() {
//     return Column(
//       children: <Widget>[
//
//         _selectedImage != null
//             ? Image.file(_selectedImage!, height: 150)
//             : const Text("No Image Selected"),
//         const SizedBox(height: 10),
//         ElevatedButton(
//           onPressed: _chooseImage,
//           child: const Text("Choose Image"),
//         ),
//         SizedBox(
//           height: 15,
//         ),
//         TextField(
//           // obscureText: true,
//           controller: namecontroller,
//             decoration: InputDecoration(
//               hintText: 'User Name',
//                 border: InputBorder.none,
//                 fillColor: Color(0xfff3f3f4),
//                 filled: true)
//         ),
//         SizedBox(
//           height: 15,
//         ),
//         TextField(
//           // obscureText: true,
//             controller: Dobcontroller,
//             decoration: InputDecoration(
//                 hintText: 'DOB : yyyy-mm-dd',
//                 border: InputBorder.none,
//                 fillColor: Color(0xfff3f3f4),
//                 filled: true),
//           onTap: () => _selectDate(context),
//     ),
//         SizedBox(
//           height: 15,
//         ),
//             RadioListTile(value: "Male", groupValue: gender, onChanged: (value) { setState(() {gender="Male";}); },title: Text("Male"),),
//             RadioListTile(value: "Female", groupValue: gender, onChanged: (value) { setState(() {gender="Female";}); },title: Text("Female"),),
//             RadioListTile(value: "Other", groupValue: gender, onChanged: (value) { setState(() {gender="Other";}); },title: Text("Other"),),
//         SizedBox(
//           height: 15,
//         ),
//         TextField(
//           // obscureText: true,
//             controller: emailcontroller,
//             decoration: InputDecoration(
//                 hintText: 'Email',
//                 border: InputBorder.none,
//                 fillColor: Color(0xfff3f3f4),
//                 filled: true)
//         ),
//         SizedBox(
//           height: 15,
//         ),
//         TextField(
//           // obscureText: true,
//             controller: phonenumberontroller,
//             decoration: InputDecoration(
//                 hintText: 'Phone Number',
//                 border: InputBorder.none,
//                 fillColor: Color(0xfff3f3f4),
//                 filled: true)
//         ),
//         SizedBox(
//           height: 15,
//         ),
//         TextField(
//           // obscureText: true,
//             controller: placecontroller,
//             decoration: InputDecoration(
//                 hintText: 'Place',
//                 border: InputBorder.none,
//                 fillColor: Color(0xfff3f3f4),
//                 filled: true)
//         ),
//         SizedBox(
//           height: 15,
//         ),
//         TextField(
//           // obscureText: true,
//             controller: postcontroller,
//             decoration: InputDecoration(
//                 hintText: 'Post',
//                 border: InputBorder.none,
//                 fillColor: Color(0xfff3f3f4),
//                 filled: true)
//         ),
//         SizedBox(
//           height: 15,
//         ),
//         TextField(
//           // obscureText: true,
//             controller: districtcontroller,
//             decoration: InputDecoration(
//                 hintText: 'District',
//                 border: InputBorder.none,
//                 fillColor: Color(0xfff3f3f4),
//                 filled: true)
//         ),
//         SizedBox(
//           height: 15,
//         ),
//         TextField(
//           // obscureText: true,
//             controller: statecontroller,
//             decoration: InputDecoration(
//                 hintText: 'State',
//                 border: InputBorder.none,
//                 fillColor: Color(0xfff3f3f4),
//                 filled: true)
//         ),
//         SizedBox(
//           height: 15,
//         ),
//         TextField(
//           // obscureText: true,
//             controller: pincontroller,
//             decoration: InputDecoration(
//                 hintText: 'Pin',
//                 border: InputBorder.none,
//                 fillColor: Color(0xfff3f3f4),
//                 filled: true)
//         ),SizedBox(
//           height: 15,
//         ),
//         TextField(
//           // obscureText: true,
//             controller: passwordcontroller,
//             decoration: InputDecoration(
//                 hintText: 'Password',
//                 border: InputBorder.none,
//                 fillColor: Color(0xfff3f3f4),
//                 filled: true)
//         ),SizedBox(
//           height: 15,
//         ),
//         TextField(
//           // obscureText: true,
//             controller: confirmpasswordcontroller,
//             decoration: InputDecoration(
//                 hintText: 'Confirm password',
//                 border: InputBorder.none,
//                 fillColor: Color(0xfff3f3f4),
//                 filled: true)
//         ),
//
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     return Scaffold(
//       body: Container(
//         height: height,
//         child: Stack(
//           children: <Widget>[
//             Positioned(
//               top: -MediaQuery.of(context).size.height * .15,
//               right: -MediaQuery.of(context).size.width * .4,
//               child: BezierContainer(),
//             ),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 20),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     SizedBox(height: height * .2),
//                     _title(),
//                     SizedBox(
//                       height: 50,
//                     ),
//                     _emailPasswordWidget(),
//                     SizedBox(
//                       height: 20,
//                     ),
//                     _submitButton(),
//                     SizedBox(height: height * .14),
//                     _loginAccountLabel(),
//                   ],
//                 ),
//               ),
//             ),
//             Positioned(top: 40, left: 0, child: _backButton()),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   File? _selectedImage;
//   Future<void> _chooseImage() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//     }
//     else {
//       Fluttertoast.showToast(msg: "No image selected");
//     }
//   }
// }
