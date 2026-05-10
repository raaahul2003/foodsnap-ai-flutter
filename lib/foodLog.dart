// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:fluttertoast/fluttertoast.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:intl/intl.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// // void main() {
// //   runApp(const FoodSnapApp());
// // }
// //
// // class FoodSnapApp extends StatelessWidget {
// //   const FoodSnapApp({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'FoodSnap AI',
// //       debugShowCheckedModeBanner: false,
// //       theme: ThemeData(
// //         primaryColor: const Color(0xFF4CAF50),
// //         colorScheme: ColorScheme.fromSeed(
// //           seedColor: const Color(0xFF4CAF50),
// //           brightness: Brightness.light,
// //         ),
// //         scaffoldBackgroundColor: const Color(0xFFF8FAFC),
// //         cardTheme: CardTheme(
// //           elevation: 2,
// //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //           color: Colors.white,
// //         ),
// //         elevatedButtonTheme: ElevatedButtonThemeData(
// //           style: ElevatedButton.styleFrom(
// //             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
// //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //           ),
// //         ),
// //         textTheme: const TextTheme(
// //           titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
// //           titleMedium: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
// //           bodyMedium: TextStyle(color: Color(0xFF4B5563)),
// //         ),
// //         inputDecorationTheme: InputDecorationTheme(
// //           filled: true,
// //           fillColor: Colors.white,
// //           border: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12),
// //             borderSide: BorderSide.none,
// //           ),
// //           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
// //         ),
// //       ),
// //       home: const FoodLogScreen(),
// //     );
// //   }
// // }
// //
// // class FoodLogScreen extends StatefulWidget {
// //   const FoodLogScreen({super.key});
// //
// //   @override
// //   State<FoodLogScreen> createState() => _FoodLogScreenState();
// // }
// //
// // class _FoodLogScreenState extends State<FoodLogScreen> {
// //   DateTime _selectedDate = DateTime.now();
// //   TimeOfDay _selectedTime = TimeOfDay.now();
// //   final TextEditingController _foodController = TextEditingController();
// //   final TextEditingController _typeController = TextEditingController();
// //
// //   String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
// //   String _formatTime(TimeOfDay time) => time.format(context);
// //
// //   Future<void> _pickDate() async {
// //     final DateTime? picked = await showDatePicker(
// //       context: context,
// //       initialDate: _selectedDate,
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime.now().add(const Duration(days: 365)),
// //     );
// //     if (picked != null && picked != _selectedDate) {
// //       setState(() => _selectedDate = picked);
// //     }
// //   }
// //
// //   Future<void> _pickTime() async {
// //     final TimeOfDay? picked = await showTimePicker(
// //       context: context,
// //       initialTime: _selectedTime,
// //     );
// //     if (picked != null && picked != _selectedTime) {
// //       setState(() => _selectedTime = picked);
// //     }
// //   }
// //
// //   Future<void> _addFoodLog() async {
// //     final date = _formatDate(_selectedDate);
// //     final time = _formatTime(_selectedTime);
// //     final type = _typeController.text.trim();
// //     final food = _foodController.text.trim();
// //
// //     if (food.isEmpty) {
// //       Fluttertoast.showToast(msg: "Please enter food description");
// //       return;
// //     }
// //
// //     if (type.isEmpty) {
// //       Fluttertoast.showToast(msg: "Please enter meal type (e.g. Breakfast)");
// //       return;
// //     }
// //
// //     setState(() { /* can add loading if wanted */ });
// //
// //     try {
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //       String? baseUrl = prefs.getString('url');
// //       String? lid = prefs.getString('lid');
// //
// //       if (baseUrl == null || lid == null) {
// //         Fluttertoast.showToast(msg: "Missing configuration");
// //         return;
// //       }
// //
// //       final uri = Uri.parse('$baseUrl/user_add_daily_food_log_post/');
// //       var request = http.MultipartRequest('POST', uri);
// //
// //       request.fields.addAll({
// //         'date': date,
// //         'time': time,
// //         'type': type,
// //         'food': food,
// //         'lid': lid,
// //       });
// //
// //       var response = await request.send();
// //       final responseBody = await response.stream.bytesToString();
// //       final data = jsonDecode(responseBody);
// //
// //       if (response.statusCode == 200 && data['status'] == 'ok') {
// //         Fluttertoast.showToast(
// //           msg: "Meal logged successfully!",
// //           backgroundColor: Colors.green.shade700,
// //         );
// //
// //         // Clear fields after success
// //         _foodController.clear();
// //         _typeController.clear();
// //         // Optionally reset date/time to now
// //         setState(() {
// //           _selectedDate = DateTime.now();
// //           _selectedTime = TimeOfDay.now();
// //         });
// //       } else {
// //         Fluttertoast.showToast(msg: "Failed to log meal");
// //       }
// //     } catch (e) {
// //       Fluttertoast.showToast(msg: "Error: ${e.toString().split('\n')[0]}");
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8FAFC),
// //       appBar: AppBar(
// //         title: const Text("Daily Food Log"),
// //         backgroundColor: Colors.white,
// //         foregroundColor: const Color(0xFF1F2937),
// //         elevation: 0,
// //         centerTitle: true,
// //       ),
// //       body: SafeArea(
// //         child: SingleChildScrollView(
// //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               const Text(
// //                 "Log Today's Meal",
// //                 style: TextStyle(
// //                   fontSize: 26,
// //                   fontWeight: FontWeight.w700,
// //                   color: Color(0xFF1F2937),
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               Text(
// //                 "Add what you ate — FoodSnap AI helps track calories & nutrients",
// //                 style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
// //               ),
// //
// //               const SizedBox(height: 32),
// //
// //               // Date Picker Field
// //               _buildSelectorTile(
// //                 icon: Icons.calendar_today_rounded,
// //                 label: "Date",
// //                 value: _formatDate(_selectedDate),
// //                 onTap: _pickDate,
// //               ),
// //
// //               const SizedBox(height: 16),
// //
// //               // Time Picker Field
// //               _buildSelectorTile(
// //                 icon: Icons.access_time_rounded,
// //                 label: "Time",
// //                 value: _formatTime(_selectedTime),
// //                 onTap: _pickTime,
// //               ),
// //
// //               const SizedBox(height: 16),
// //
// //               // Meal Type
// //               TextField(
// //                 controller: _typeController,
// //                 decoration: const InputDecoration(
// //                   labelText: "Meal Type",
// //                   hintText: "Breakfast • Lunch • Dinner • Snack",
// //                   prefixIcon: Icon(Icons.category_rounded),
// //                 ),
// //                 textCapitalization: TextCapitalization.words,
// //               ),
// //
// //               const SizedBox(height: 16),
// //
// //               // Food Description
// //               TextField(
// //                 controller: _foodController,
// //                 decoration: const InputDecoration(
// //                   labelText: "What did you eat?",
// //                   hintText: "e.g. Grilled chicken salad with olive oil, 2 eggs, avocado...",
// //                   prefixIcon: Icon(Icons.restaurant_menu_rounded),
// //                   alignLabelWithHint: true,
// //                 ),
// //                 maxLines: 3,
// //                 minLines: 2,
// //                 textCapitalization: TextCapitalization.sentences,
// //               ),
// //
// //               const SizedBox(height: 32),
// //
// //               SizedBox(
// //                 width: double.infinity,
// //                 height: 54,
// //                 child: ElevatedButton.icon(
// //                   onPressed: _addFoodLog,
// //                   icon: const Icon(Icons.add_circle_outline_rounded),
// //                   label: const Text(
// //                     "Log Meal",
// //                     style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
// //                   ),
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: const Color(0xFF10B981),
// //                     foregroundColor: Colors.white,
// //                   ),
// //                 ),
// //               ),
// //
// //               const SizedBox(height: 40),
// //
// //               // Optional: Quick hint or calorie goal preview could go here
// //               Center(
// //                 child: Text(
// //                   "Your daily nutrition summary appears here soon",
// //                   style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
// //                 ),
// //               ),
// //
// //               const SizedBox(height: 24),
// //             ],
// //           ),
// //         ),
// //       ),
// //       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
// //       // You could add FAB for quick photo log if you want to combine with camera feature
// //     );
// //   }
// //
// //   Widget _buildSelectorTile({
// //     required IconData icon,
// //     required String label,
// //     required String value,
// //     required VoidCallback onTap,
// //   }) {
// //     return InkWell(
// //       onTap: onTap,
// //       borderRadius: BorderRadius.circular(12),
// //       child: Container(
// //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(12),
// //           border: Border.all(color: Colors.grey.shade200),
// //         ),
// //         child: Row(
// //           children: [
// //             Icon(icon, color: const Color(0xFF4CAF50), size: 22),
// //             const SizedBox(width: 12),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     label,
// //                     style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
// //                   ),
// //                   const SizedBox(height: 2),
// //                   Text(
// //                     value,
// //                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   @override
// //   void dispose() {
// //     _foodController.dispose();
// //     _typeController.dispose();
// //     super.dispose();
// //   }
// // }
//
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:image_picker/image_picker.dart';
//
// void main() {
//   runApp(const FoodSnapApp());
// }
//
// class FoodSnapApp extends StatelessWidget {
//   const FoodSnapApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'FoodSnap AI',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primaryColor: const Color(0xFF4CAF50),
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF4CAF50),
//           brightness: Brightness.light,
//         ),
//         scaffoldBackgroundColor: const Color(0xFFF8FAFC),
//         cardTheme: CardTheme(
//           elevation: 2,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           color: Colors.white,
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//         ),
//         textTheme: const TextTheme(
//           titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
//           titleMedium: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
//           bodyMedium: TextStyle(color: Color(0xFF4B5563)),
//         ),
//         inputDecorationTheme: InputDecorationTheme(
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         ),
//       ),
//       home: const FoodLogScreen(),
//     );
//   }
// }
//
// class FoodLogScreen extends StatefulWidget {
//   const FoodLogScreen({super.key});
//
//   @override
//   State<FoodLogScreen> createState() => _FoodLogScreenState();
// }
//
// class _FoodLogScreenState extends State<FoodLogScreen> {
//   DateTime _selectedDate = DateTime.now();
//   TimeOfDay _selectedTime = TimeOfDay.now();
//   final TextEditingController _foodController = TextEditingController();
//   final TextEditingController _typeController = TextEditingController();
//
//   // Image picker state
//   File? _selectedImage;
//   final ImagePicker _picker = ImagePicker();
//
//   String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
//   String _formatTime(TimeOfDay time) => time.format(context);
//
//   // Pick date
//   Future<void> _pickDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() => _selectedDate = picked);
//     }
//   }
//
//   // Pick time
//   Future<void> _pickTime() async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime,
//     );
//     if (picked != null && picked != _selectedTime) {
//       setState(() => _selectedTime = picked);
//     }
//   }
//
//   // Pick image from camera
//   Future<void> _pickImageFromCamera() async {
//     final XFile? image = await _picker.pickImage(
//       source: ImageSource.camera,
//       maxWidth: 800,
//       maxHeight: 800,
//       imageQuality: 80,
//     );
//
//     if (image != null) {
//       setState(() {
//         _selectedImage = File(image.path);
//       });
//     }
//   }
//
//   // Add food log and upload
//   Future<void> _addFoodLog() async {
//     final date = _formatDate(_selectedDate);
//     final time = _formatTime(_selectedTime);
//     final type = _typeController.text.trim();
//     final food = _foodController.text.trim();
//
//     if (food.isEmpty) {
//       Fluttertoast.showToast(msg: "Please enter food description");
//       return;
//     }
//
//     if (type.isEmpty) {
//       Fluttertoast.showToast(msg: "Please enter meal type (e.g. Breakfast)");
//       return;
//     }
//
//     setState(() { /* optional loading */ });
//
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? baseUrl = prefs.getString('url');
//       String? lid = prefs.getString('lid');
//
//       if (baseUrl == null || lid == null) {
//         Fluttertoast.showToast(msg: "Missing configuration");
//         return;
//       }
//
//       final uri = Uri.parse('$baseUrl/user_add_daily_food_log_post/');
//       var request = http.MultipartRequest('POST', uri);
//
//       // Add fields
//       request.fields.addAll({
//         'date': date,
//         'time': time,
//         'type': type,
//         'food': food,
//         'lid': lid,
//       });
//
//       // Add image if selected
//       if (_selectedImage != null) {
//         request.files.add(
//           await http.MultipartFile.fromPath(
//             'image', // backend field name
//             _selectedImage!.path,
//           ),
//         );
//       }
//
//       var response = await request.send();
//       final responseBody = await response.stream.bytesToString();
//       final data = jsonDecode(responseBody);
//
//       if (response.statusCode == 200 && data['status'] == 'ok') {
//         Fluttertoast.showToast(
//           msg: "Meal logged successfully!",
//           backgroundColor: Colors.green.shade700,
//         );
//
//         // Clear inputs
//         _foodController.clear();
//         _typeController.clear();
//         setState(() {
//           _selectedDate = DateTime.now();
//           _selectedTime = TimeOfDay.now();
//           _selectedImage = null;
//         });
//       } else {
//         Fluttertoast.showToast(msg: "Failed to log meal");
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Error: ${e.toString().split('\n')[0]}");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       appBar: AppBar(
//         title: const Text("Daily Food Log"),
//         backgroundColor: Colors.white,
//         foregroundColor: const Color(0xFF1F2937),
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Log Today's Meal",
//                 style: TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFF1F2937),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 "Add what you ate — FoodSnap AI helps track calories & nutrients",
//                 style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
//               ),
//               const SizedBox(height: 32),
//
//               // Date picker
//               _buildSelectorTile(
//                 icon: Icons.calendar_today_rounded,
//                 label: "Date",
//                 value: _formatDate(_selectedDate),
//                 onTap: _pickDate,
//               ),
//               const SizedBox(height: 16),
//
//               // Time picker
//               _buildSelectorTile(
//                 icon: Icons.access_time_rounded,
//                 label: "Time",
//                 value: _formatTime(_selectedTime),
//                 onTap: _pickTime,
//               ),
//               const SizedBox(height: 16),
//
//               // Meal type
//               TextField(
//                 controller: _typeController,
//                 decoration: const InputDecoration(
//                   labelText: "Meal Type",
//                   hintText: "Breakfast • Lunch • Dinner • Snack",
//                   prefixIcon: Icon(Icons.category_rounded),
//                 ),
//                 textCapitalization: TextCapitalization.words,
//               ),
//               const SizedBox(height: 16),
//
//               // Food description
//               TextField(
//                 controller: _foodController,
//                 decoration: const InputDecoration(
//                   labelText: "What did you eat?",
//                   hintText: "e.g. Grilled chicken salad with olive oil, 2 eggs, avocado...",
//                   prefixIcon: Icon(Icons.restaurant_menu_rounded),
//                   alignLabelWithHint: true,
//                 ),
//                 maxLines: 3,
//                 minLines: 2,
//                 textCapitalization: TextCapitalization.sentences,
//               ),
//               const SizedBox(height: 16),
//
//               // Camera preview
//               if (_selectedImage != null)
//                 Container(
//                   height: 150,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey.shade300),
//                     image: DecorationImage(
//                       image: FileImage(_selectedImage!),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               const SizedBox(height: 8),
//
//               // Camera button
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: OutlinedButton.icon(
//                   onPressed: _pickImageFromCamera,
//                   icon: const Icon(Icons.camera_alt_rounded),
//                   label: const Text("Take Photo"),
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               // Log Meal button
//               SizedBox(
//                 width: double.infinity,
//                 height: 54,
//                 child: ElevatedButton.icon(
//                   onPressed: _addFoodLog,
//                   icon: const Icon(Icons.add_circle_outline_rounded),
//                   label: const Text(
//                     "Log Meal",
//                     style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF10B981),
//                     foregroundColor: Colors.white,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 40),
//
//               // Placeholder text
//               Center(
//                 child: Text(
//                   "Your daily nutrition summary appears here soon",
//                   style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
//                 ),
//               ),
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Selector widget for date/time
//   Widget _buildSelectorTile({
//     required IconData icon,
//     required String label,
//     required String value,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey.shade200),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: const Color(0xFF4CAF50), size: 22),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
//                   const SizedBox(height: 2),
//                   Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//                 ],
//               ),
//             ),
//             Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _foodController.dispose();
//     _typeController.dispose();
//     super.dispose();
//   }
// }
