# 📱 FoodSnap AI — Mobile App (Flutter)

> Snap your food. Know your nutrition. Instantly.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-teal?style=for-the-badge&logo=dart)
![TFLite](https://img.shields.io/badge/TensorFlow_Lite-On--Device-orange?style=for-the-badge&logo=tensorflow)
![Android](https://img.shields.io/badge/Android-9--14-green?style=for-the-badge&logo=android)
![iOS](https://img.shields.io/badge/iOS-13--17-black?style=for-the-badge&logo=apple)
![IJSRD](https://img.shields.io/badge/Published-IJSRD_Vol.14_Issue_2_2026-red?style=for-the-badge)

---

## 📖 About

**FoodSnap AI** is a cross-platform mobile application that uses AI to identify food from a photo and instantly provide calorie and macronutrient breakdown. Built with Flutter for Android and iOS, it features fully **offline AI inference** via TensorFlow Lite — no internet required for food recognition.

📄 **Research Paper**: Published in IJSRD — International Journal for Scientific Research & Development, Vol. 14, Issue 2, 2026
> *"FoodSnap AI: An Attention-Augmented MobileNetV2 Framework for Real-Time Food Recognition, Nutritional Estimation, and Personalized Dietary Recommendations on Mobile Devices"*

---

## 📸 Screenshots

### Welcome & Authentication

<table>
  <tr>
    <td align="center"><b>Welcome Screen</b></td>
    <td align="center"><b>Login</b></td>
    <td align="center"><b>Dashboard</b></td>

  </tr>
  <tr>
    <td><img src="IMG_9588.JPG" width="220"/></td>
    <td><img src="IMG_9589.JPG" width="220"/></td>
    <td><img src="IMG_9592.JPG" width="220"/></td>
  </tr>
</table>

### Core Features

<table>
  <tr>
    <td align="center"><b>Create Account</b></td>
    <td align="center"><b>Food Scan (Nutrition Result)</b></td>
    <td align="center"><b>AI Daily Food Plan</b></td>
  </tr>
  <tr>
    <td><img src="IMG_9593.jpg" width="220"/></td>
    <td><img src="IMG_9595.JPG" width="220"/></td>
    <td><img src="IMG_9594.JPG" width="220"/></td>
  </tr>
</table>

### AI-Powered Tools

<table>
  <tr>
    <td align="center"><b>SafeBite Scanner</b></td>
    <td align="center"><b>SafeBite Results</b></td>
    <td align="center"><b>NutriBot Chatbot</b></td>
  </tr>
  <tr>
    <td><img src="IMG_9590.JPG" width="220"/></td>
    <td><img src="IMG_9596.JPG" width="220"/></td>
    <td><img src="IMG_9591.JPG" width="220"/></td>
  </tr>
</table>



---

## ✨ Features

### 🔍 AI Food Scanner
- One-tap photo capture or gallery upload
- Instant food identification using **AA-MobileNetV2** (93.2% accuracy)
- Displays calories, protein, carbs, and fat with color-coded cards
- Works **fully offline** — TFLite model (11.4 MB, 162 ms inference)

### 📦 SafeBite Scanner (OCR)
- Scan packaged food ingredient labels using camera
- AI extracts and reads ingredient list via Tesseract OCR
- Cross-checks ingredients against your health profile
- Generates a personalized **Safety Score (0–100)**

### 🤖 NutriBot — AI Health Chatbot
- Personalized AI copilot for dietary questions
- Daily snapshot: calories consumed, remaining, macros
- Ask anything — meal ideas, health score, what-if analysis

### 📊 Progress Dashboard
- Daily calorie ring with goal tracking
- Macronutrient breakdown (Protein / Carbs / Fats)
- Weekly snapshot bar chart
- Streak tracker and Health XP system

### 🥗 AI Daily Food Plan
- Personalized meal recommendations based on health profile
- AI Plan Compatibility Score
- Focus tags: High Protein, High Fiber, Low Fat, Hydrating, etc.
- Breakfast, Lunch, Dinner suggestions

### 👤 Health Profile
- BMI calculator and Health Risk score
- Physical activity level selection
- Cardiac risk and lifestyle flags
- Basic Mode / Advanced Mode toggle

### 📅 Daily Food Log
- Running calorie and nutrient totals
- Log every meal with timestamp
- User-defined daily calorie limit
- History view per day

---

## 🛠️ Tech Stack

| Component | Technology |
|-----------|-----------|
| Framework | Flutter 3.x (Dart) |
| On-Device AI | TensorFlow Lite (AA-MobileNetV2) |
| State Management | Provider / setState |
| HTTP Client | Dio / http package |
| Authentication | JWT Token Storage |
| Local Storage | SharedPreferences |
| Camera | image_picker |
| Charts | fl_chart |
| Animations | Lottie, AnimatedContainer |
| Backend API | Django REST Framework |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.x
- Android Studio or VS Code with Flutter plugin
- Android device/emulator (API 28+) or iOS device/simulator (iOS 13+)
- Backend server running (see [foodsnap-ai-backend](https://github.com/raaahul2003/foodsnap-ai-backend))

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/foodsnap-ai-flutter.git
cd foodsnap-ai-flutter

# 2. Install Flutter dependencies
flutter pub get

# 3. Configure backend API URL
# Open lib/constants.dart (or similar) and update:
# const String BASE_URL = 'http://YOUR_BACKEND_IP:8000';

# 4. Add TFLite model
# Place your .tflite model file in assets/models/
# Ensure pubspec.yaml includes the assets path

# 5. Run the app
flutter run

# For release build (Android APK)
flutter build apk --release

# For release build (iOS)
flutter build ios --release
```

### Project Structure

```
eatwise_ai/
├── lib/
│   ├── main.dart              # App entry point
│   ├── home.dart              # Home dashboard
│   ├── chatbot.dart           # NutriBot AI chatbot
│   ├── changePassword.dart    # Password management
│   ├── ippage.dart            # API configuration
│   └── ...                    # Other screens
├── assets/
│   ├── models/                # TFLite model files
│   └── images/                # App assets
├── screenshots/               # App screenshots (README images)
├── android/                   # Android-specific configs
├── ios/                       # iOS-specific configs
└── pubspec.yaml               # Dependencies
```

---

## 🧠 AI Model Info

The on-device model is **AA-MobileNetV2** — MobileNetV2 enhanced with Squeeze-and-Excitation (SE) attention blocks.

| Metric | Value |
|--------|-------|
| Top-1 Accuracy | **93.2%** |
| Top-5 Accuracy | **98.7%** |
| Model Size | **11.4 MB** |
| Inference Time | **162 ms** |
| Food Categories | **151** |
| Offline Support | ✅ Yes |

Supports Indian and Kerala-specific dishes including: Puttu, Appam, Kerala Fish Curry, Sadya, Karimeen Pollichathu, Avial, Payasam, Beef Fry, Parotta, and Kallappam.

---

## 👥 User Acceptance Testing Results

| Criterion | Rating (/5) | Satisfied |
|-----------|-------------|-----------|
| Ease of Use | 4.6 | 92% |
| Food Recognition Accuracy | 4.3 | 86% |
| Nutritional Info Clarity | 4.5 | 90% |
| App Speed / Responsiveness | 4.4 | 88% |
| **Overall Satisfaction** | **4.5** | **90%** |

*Evaluated by 20 participants across different age groups and technical backgrounds. 5 participants tested in areas with no internet — offline mode worked reliably in all cases.*

---

## 🔮 Future Scope

- Multi-food detection using **YOLOv8** for thali plates
- Automatic **portion size estimation** via monocular depth
- **AR-based** quantity estimation
- **INT8 quantization** to reduce model below 5 MB
- Multi-language support for wider accessibility
- Integration with **fitness trackers and smartwatches**
- Real-time video food detection

---

## 👥 Team — Group 9, MGM Technological Campus

| Name | Roll No | Role |
|------|---------|------|
| Arun Raj M R | CCV22CS005 | UI/UX Web Design |
| Rahil Abdul Razakh | CCV22CS037 | AI Model Integration |
| Rahul Raj C P | CCV22CS038 | UI/UX App Design |
| Suhaib V P | CCV22CS045 | Backend Development |

**Guide**: Ms. Ramsheena P, Asst. Professor, Dept. of CSE
**Institution**: MGM Technological Campus, Valanchery, Kerala
**Course**: B.Tech CSE — Semester 8 (2026)

---

## 🔗 Related Repository

🖥️ **Django Backend + Admin Portal**: [foodsnap-ai-backend](https://github.com/YOUR_USERNAME/foodsnap-ai-backend)

---

## 📜 License

This project is submitted as a final year academic project at MGM Technological Campus under APJ Abdul Kalam Technological University, Kerala.

---

*Published in IJSRD — Vol. 14, Issue 2, 2026 | Department of CSE, MGM Technological Campus, Valanchery, Kerala, India*
