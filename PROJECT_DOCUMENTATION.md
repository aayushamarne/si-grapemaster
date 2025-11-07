# 🍇 GrapeMaster - Smart Grape Farming Assistant

## 📋 Project Overview

**GrapeMaster** is a comprehensive mobile application designed to revolutionize grape farming through AI-powered disease detection, intelligent chatbot assistance, and efficient crop management. Built with Flutter and powered by machine learning, this app serves as a complete farming companion for grape cultivators.

---

## 🎯 Key Features

### 1. **AI-Powered Disease Detection** 🔬
- **Real-time Image Analysis**: Capture or upload grape leaf images for instant disease identification
- **YOLO Model Integration**: Uses trained YOLOv8 model for accurate disease detection
- **Confidence Scoring**: Provides confidence levels for each detection
- **Scan History**: Maintains a complete history of all scans (up to 50 records)
- **Auto AI Recommendations**: Automatically fetches treatment and prevention tips after detection

### 2. **Intelligent Chatbot Assistant** 🤖
- **Groq AI Integration**: Powered by Llama-3.1-8b-instant model
- **Context-Aware Conversations**: Understands farming context and provides specific advice
- **Specialized Queries**: Beautiful card-style UI for disease and crop queries
- **Markdown Support**: Rich text formatting for better readability
- **Voice Input Ready**: Infrastructure prepared for future voice command integration

### 3. **Crop Management System** 🌱
- **Quick Crop Addition**: Add crops with emoji icons, varieties, and planting details
- **Crop Details Dashboard**: Comprehensive view of crop health, status, and care schedule
- **Health Monitoring**: Track crop status, inspections, and next care activities
- **Care Schedule**: Automated reminders for watering, fertilizing, and pest checks
- **Direct Actions**: Quick access to disease detection and AI consultation from crop details

### 4. **User Authentication & Profile** 👤
- **Firebase Authentication**: Secure sign-in/sign-up with email and Google
- **User Profiles**: Personalized experience with profile management
- **Settings & Privacy**: Complete control over app settings and privacy options
- **Multi-language Support**: Built-in localization infrastructure

### 5. **Beautiful UI/UX** 🎨
- **Modern Gradient Design**: Consistent blue gradient theme (#0D5EF9 to #4A90E2)
- **Responsive Layout**: Adapts to tablets and phones seamlessly
- **Card-based Interface**: Clean, organized content presentation
- **Smooth Animations**: Polished transitions and interactions
- **Dark Mode Ready**: Infrastructure for theme switching

---

## 🏗️ Technical Architecture

### **Frontend - Flutter/Dart**

#### Core Technologies:
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: StatefulWidget with setState
- **UI Components**: Material Design 3

#### Key Packages:
```yaml
dependencies:
  - flutter_dotenv: ^5.2.1          # Environment variable management
  - firebase_core: ^latest          # Firebase initialization
  - firebase_auth: ^latest          # User authentication
  - cloud_firestore: ^latest        # Cloud database
  - google_sign_in: ^latest         # Google OAuth
  - image_picker: ^latest           # Camera/Gallery access
  - permission_handler: ^latest     # Runtime permissions
  - http: ^latest                   # API requests
  - shared_preferences: ^latest     # Local storage
  - flutter_markdown: ^latest       # Markdown rendering
```

### **Backend Services**

#### 1. **Flask Disease Detection Server**
```python
# Location: grapeMasterBackend/app.py
- Framework: Flask + Flask-CORS
- Model: YOLOv8 (best.pt)
- Port: 10000
- Endpoint: POST /predict
- Input: Multipart form-data (image file)
- Output: JSON {"prediction": "disease_name", "confidence": 0.95}
```

#### 2. **Firebase Services**
- **Authentication**: User sign-in/sign-up management
- **Firestore Database**: 
  - Collection: `users/{userId}/quickCrops`
  - Stores: crop data, planting info, status
- **Storage**: Ready for image storage (future enhancement)

#### 3. **Groq AI API**
- **Model**: llama-3.1-8b-instant
- **Purpose**: Intelligent farming assistant
- **API Key**: Stored securely in .env file
- **Endpoint**: https://api.groq.com/openai/v1/chat/completions

---

## 📂 Project Structure

```
si-grapemaster/
├── android/                      # Android native code
├── ios/                         # iOS native code
├── lib/
│   ├── main.dart               # App entry point, main navigation
│   ├── firebase_options.dart   # Firebase configuration
│   └── src/
│       ├── screens/
│       │   ├── disease_detection_screen.dart    # Disease scanning & results
│       │   ├── chatbot_screen.dart              # AI assistant interface
│       │   ├── crop_details_screen.dart         # Individual crop management
│       │   ├── crops_list_screen.dart           # All crops overview
│       │   ├── add_crop_screen.dart             # Add new crops
│       │   ├── auth_screen.dart                 # Login/Signup
│       │   ├── profile_settings_screen.dart     # User profile
│       │   ├── notifications_screen.dart        # Notifications center
│       │   └── privacy_policy_screen.dart       # Privacy & terms
│       └── models/
│           └── scan_history.dart                # Scan history data model
├── grapeMasterBackend/
│   ├── app.py                  # Flask server for disease detection
│   ├── best.pt                 # YOLO model weights
│   ├── requirements.txt        # Python dependencies
│   └── uploads/                # Temporary image storage
├── .env                        # Environment variables (API keys)
├── pubspec.yaml               # Flutter dependencies
└── firebase.json              # Firebase configuration
```

---

## 🔄 Data Flow

### Disease Detection Flow:
```
1. User captures/selects image
   ↓
2. Flutter app sends image to Flask server (10.65.94.181:10000)
   ↓
3. YOLO model processes image
   ↓
4. Returns disease prediction + confidence
   ↓
5. App displays results with severity assessment
   ↓
6. Auto-triggers AI for treatment recommendations
   ↓
7. Saves scan to history (SharedPreferences)
```

### AI Chatbot Flow:
```
1. User sends query OR triggered by detection/crop action
   ↓
2. App formats query (detection/crop cards for external queries)
   ↓
3. Sends to Groq API with authentication
   ↓
4. Receives markdown-formatted response
   ↓
5. Renders with syntax highlighting and formatting
```

### Crop Management Flow:
```
1. User adds crop with details
   ↓
2. Saved to Firestore under user's collection
   ↓
3. Real-time sync across devices
   ↓
4. User can view details, check diseases, or consult AI
   ↓
5. Updates reflected immediately in UI
```

---

## 🔐 Security & Configuration

### Environment Variables (.env):
```env
GROQ_API_KEY=gsk_xxx...  # Groq AI API key
```

### Network Configuration:
- **Android Emulator**: Use `10.0.2.2` to access host machine
- **Physical Device**: Use computer's IP address (e.g., `10.65.94.181`)
- **Port**: Flask server runs on `10000`
- **Protocol**: HTTP (with cleartext traffic allowed for development)

### Firebase Security:
- Authentication required for all Firestore operations
- User-scoped data: `/users/{userId}/quickCrops`
- Firestore rules enforce user ownership

---

## 🎨 Design System

### Color Palette:
```dart
Primary Gradient: 
  - Color(0xFF0D5EF9) to Color(0xFF4A90E2)  // Blue gradient
  
Background:
  - Color(0xFFF5F7FA)  // Light gray
  
Success: Colors.green
Error: Colors.red
Warning: Colors.orange
```

### Typography:
- Headers: Bold, 18-20px
- Body: Regular, 14-15px
- Captions: 11-12px
- Special Cards: Bold, 16-17px with letter spacing

### UI Components:
- **Cards**: Rounded corners (12-20px), soft shadows
- **Buttons**: 
  - Primary: Gradient background
  - Outlined: Border with gradient color
  - Icon buttons: Circular with icons
- **Input Fields**: Rounded (24-28px), light background
- **Avatars**: Gradient borders with white background

---

## 🚀 Setup & Installation

### Prerequisites:
```bash
# Required software:
- Flutter SDK 3.x or higher
- Python 3.8+
- Android Studio / Xcode
- Firebase account
- Groq API account
```

### Installation Steps:

1. **Clone Repository**
```bash
git clone https://github.com/aayushamarne/si-grapemaster.git
cd si-grapemaster
```

2. **Install Flutter Dependencies**
```bash
flutter pub get
```

3. **Setup Environment Variables**
```bash
# Create .env file in root
echo "GROQ_API_KEY=your_groq_api_key_here" > .env
```

4. **Setup Firebase**
- Create Firebase project
- Add Android/iOS apps
- Download google-services.json (Android) / GoogleService-Info.plist (iOS)
- Place in respective directories

5. **Setup Python Backend**
```bash
cd grapeMasterBackend
pip install -r requirements.txt
```

6. **Configure Network**
```bash
# Get your IP address
ipconfig | Select-String "IPv4"

# Update in disease_detection_screen.dart:
static const String apiHost = 'YOUR_IP_HERE';
```

---

## 🎯 Running the Application

### Start Backend Server:
```bash
cd grapeMasterBackend
python app.py
# Server runs on port 10000
```

### Run Flutter App:

**For Emulator:**
```bash
# Update IP to 10.0.2.2 in disease_detection_screen.dart
flutter run
```

**For Physical Device:**
```bash
# Update IP to your computer's IP (e.g., 10.65.94.181)
flutter run -d <device-id>
```

### Check Connectivity:
```powershell
# Test if server is accessible
Test-NetConnection -ComputerName YOUR_IP -Port 10000
```

---

## 🧪 Testing

### Manual Testing:
1. **Authentication**: Test sign-up, sign-in, Google sign-in
2. **Disease Detection**: 
   - Test camera capture
   - Test gallery selection
   - Verify disease prediction accuracy
   - Check scan history persistence
3. **Chatbot**: 
   - Test manual queries
   - Test auto-generated queries from detection
   - Test crop consultation queries
4. **Crop Management**:
   - Add, view, update, delete crops
   - Test crop details actions
   - Verify Firestore sync

### Network Testing:
```bash
# Test Flask server
curl -X POST -F "file=@test_image.jpg" http://YOUR_IP:10000/predict

# Test Groq API
# Verify API key in .env file
```

---

## 📊 Features Breakdown

### Implemented Features ✅:
- [x] User Authentication (Email + Google)
- [x] Disease Detection with YOLO
- [x] AI Chatbot with Groq
- [x] Scan History Management
- [x] Crop CRUD Operations
- [x] Responsive UI Design
- [x] Special Query Cards (Disease/Crop)
- [x] Auto AI Recommendations
- [x] Firebase Integration
- [x] Environment Variables
- [x] Error Handling & Logging

### Future Enhancements 🚀:
- [ ] Voice Input for Chatbot
- [ ] Push Notifications
- [ ] Weather Integration
- [ ] Multi-language Support (Complete)
- [ ] Dark Mode
- [ ] Offline Mode
- [ ] Image Upload to Firebase Storage
- [ ] Community Forum
- [ ] Expert Consultation Booking
- [ ] Marketplace Integration
- [ ] Analytics Dashboard

---

## 🐛 Troubleshooting

### Common Issues:

**1. Image Not Posting to Server**
```
Problem: Network error when analyzing image
Solution: 
  - Check Flask server is running (python app.py)
  - Verify IP address matches your computer's IP
  - For emulator, use 10.0.2.2
  - Check network_security_config.xml allows cleartext
```

**2. Firebase Authentication Error**
```
Problem: Sign-in fails
Solution:
  - Verify google-services.json is present
  - Check Firebase project configuration
  - Enable Email/Password and Google sign-in in Firebase Console
```

**3. Groq API Error**
```
Problem: Chatbot not responding
Solution:
  - Verify GROQ_API_KEY in .env file
  - Check API key is valid
  - Ensure flutter_dotenv is loaded in main.dart
```

**4. Build Errors**
```
Problem: Compilation errors
Solution:
  - Run: flutter clean
  - Run: flutter pub get
  - Check all imports are correct
  - Verify Dart SDK version compatibility
```

---

## 👥 Team & Contributors

- **Developer**: Aayush Amarne
- **Project Type**: Academic (5th Semester)
- **Institution**: [Your Institution Name]

---

## 📄 License

This project is created for educational purposes.

---

## 🙏 Acknowledgments

- **Flutter Team** - For the amazing framework
- **Firebase** - For backend services
- **Groq** - For AI API access
- **Ultralytics** - For YOLO model
- **Open Source Community** - For various packages used

---

## 📞 Support & Contact

For issues, questions, or contributions:
- GitHub: [@aayushamarne](https://github.com/aayushamarne)
- Repository: [si-grapemaster](https://github.com/aayushamarne/si-grapemaster)

---

## 📈 Project Statistics

- **Lines of Code**: ~10,000+
- **Screens**: 12+
- **API Integrations**: 3 (Flask, Firebase, Groq)
- **Supported Platforms**: Android, iOS
- **Languages**: Dart, Python
- **Development Time**: [Your timeline]

---

## 🎓 Learning Outcomes

This project demonstrates:
- Cross-platform mobile development with Flutter
- Machine learning integration (YOLO)
- RESTful API design and consumption
- Firebase services integration
- State management in Flutter
- Responsive UI/UX design
- Real-time data synchronization
- Secure authentication implementation
- Environment-based configuration
- Error handling and user feedback

---

**Last Updated**: November 7, 2025
**Version**: 1.0.0
**Status**: Active Development 🚀
