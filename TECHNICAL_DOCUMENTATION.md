# GrapeMaster - Technical Documentation

**Version:** 1.0.0  
**Last Updated:** November 12, 2025  
**Platform:** Flutter (Mobile - Android/iOS)  
**Backend:** Flask + YOLOv8 + Groq AI

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Architecture](#architecture)
3. [Frontend (Flutter App)](#frontend-flutter-app)
4. [Backend Services](#backend-services)
5. [Disease Detection Workflow](#disease-detection-workflow)
6. [AI Chatbot System](#ai-chatbot-system)
7. [Localization System](#localization-system)
8. [Firebase Integration](#firebase-integration)
9. [Data Flow Diagrams](#data-flow-diagrams)
10. [API Documentation](#api-documentation)
11. [Security & Configuration](#security--configuration)

---

## System Overview

GrapeMaster is a comprehensive mobile application designed for grape farmers to:
- Detect diseases in grape plants using AI/ML
- Get expert farming advice through an AI chatbot
- Manage crops and farming activities
- Connect with farming community
- Access marketplace for farming products
- Monitor weather conditions

### Tech Stack

**Frontend:**
- Flutter 3.35.1
- Dart
- Firebase (Auth, Firestore, Storage)
- Material Design 3

**Backend:**
- Flask (Python)
- YOLOv8 (Disease Detection Model)
- Groq API (LLM for Chatbot)
- OpenWeather API (Weather Data)

**Infrastructure:**
- Firebase Cloud Services
- Local Flask Server for ML Inference

---

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        GRAPEMASTER APP                          │
│                      (Flutter Mobile App)                       │
└────────────┬────────────────────────────────────────────────────┘
             │
             ├─────────────────┬──────────────────┬────────────────┐
             │                 │                  │                │
             ▼                 ▼                  ▼                ▼
    ┌────────────────┐  ┌──────────┐   ┌─────────────┐  ┌──────────────┐
    │ Flask Backend  │  │ Firebase │   │  Groq API   │  │ OpenWeather  │
    │   (Disease     │  │(Auth,DB, │   │  (AI Chat)  │  │     API      │
    │   Detection)   │  │ Storage) │   │             │  │             │
    └────────────────┘  └──────────┘   └─────────────┘  └──────────────┘
             │
             ▼
    ┌────────────────┐
    │  YOLOv8 Model  │
    │   (best.pt)    │
    └────────────────┘
```

### Component Architecture

```
┌───────────────────────────────────────────────────────────────────────┐
│                         FLUTTER APP STRUCTURE                         │
├───────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                      PRESENTATION LAYER                      │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │    │
│  │  │  Screens │  │  Widgets │  │  Routes  │  │   UI     │   │    │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                       BUSINESS LOGIC                         │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │    │
│  │  │ Controllers  │  │   Services   │  │   Utilities  │     │    │
│  │  └──────────────┘  └──────────────┘  └──────────────┘     │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                         DATA LAYER                           │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │    │
│  │  │  Models  │  │   API    │  │ Firebase │  │  Local   │   │    │
│  │  │          │  │  Client  │  │          │  │ Storage  │   │    │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
```

---

## Frontend (Flutter App)

### Main Application Structure

```
lib/
├── main.dart                          # App entry point, routing, localization
├── firebase_options.dart              # Firebase configuration
├── l10n/                              # Localization files
│   ├── intl_en.arb                   # English translations
│   ├── intl_hi.arb                   # Hindi translations
│   └── intl_mr.arb                   # Marathi translations
├── src/
│   ├── auth/
│   │   └── auth_service2.dart        # Firebase authentication
│   ├── models/
│   │   ├── crop_model.dart           # Crop data model
│   │   └── scan_history.dart         # Disease scan history model
│   ├── screens/
│   │   ├── chatbot_screen.dart       # AI Assistant
│   │   ├── disease_detection_screen.dart  # Disease scanner
│   │   ├── crops_list_screen.dart    # Crop management
│   │   ├── auth_screen.dart          # Login/Signup
│   │   ├── profile_settings_screen.dart
│   │   ├── language_screen.dart      # Language selection
│   │   └── [other screens]
│   ├── services/
│   │   ├── crop_service.dart         # Crop CRUD operations
│   │   └── weather_service.dart      # Weather API integration
│   └── utils/
│       └── image_helper.dart         # Image processing utilities
```

### Key Screens & Features

#### 1. **Disease Detection Screen**
- **Purpose:** Scan grape leaves to detect diseases
- **Features:**
  - Camera/Gallery image selection
  - Real-time disease analysis
  - Multilingual results (English, Hindi, Marathi)
  - Color-coded results (Green for healthy, Red for diseased)
  - AI-generated treatment recommendations
  - Scan history tracking

#### 2. **AI Chatbot Screen**
- **Purpose:** Expert farming assistance
- **Features:**
  - Natural language processing
  - Locale-aware responses
  - Chat history persistence
  - No-brand welcome message
  - Context-aware farming advice

#### 3. **Crop Management**
- **Purpose:** Track and manage grape crops
- **Features:**
  - Add/Edit/Delete crops
  - View crop details
  - Monitor crop health
  - Firestore integration

#### 4. **Community & Marketplace**
- **Purpose:** Connect with farmers and buy/sell products
- **Features:**
  - Post and share farming issues
  - Browse marketplace
  - Search products by category
  - Community discussions

---

## Backend Services

### Flask Disease Detection Server

**Location:** `grapeMasterBackend/app.py`

#### Server Specifications

```python
Host: 0.0.0.0 (All interfaces)
Port: 10000
Model: YOLOv8 (best.pt)
Framework: Flask + Ultralytics
```

#### Endpoints

##### POST `/predict`

**Purpose:** Analyze grape leaf image for disease detection

**Request:**
```http
POST http://192.168.110.50:10000/predict
Content-Type: multipart/form-data

file: [image file]
```

**Response:**
```json
{
  "prediction": "Powdery_Mildew",
  "confidence": 0.9964
}
```

**Disease Classes:**
- `Healthy` - No disease detected
- `Powdery_Mildew` - Powdery mildew infection
- `Downy_Mildew` - Downy mildew infection
- `Black_Rot` - Black rot disease
- `Anthracnose` - Anthracnose infection
- `Leaf_Spot` - Leaf spot disease
- `Botrytis_Bunch_Rot` - Grey mold

#### Model Architecture

```
┌──────────────────────────────────────────────────────────┐
│                    YOLOv8 Pipeline                       │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  Image Input                                             │
│      ↓                                                   │
│  Preprocessing (Resize, Normalize)                       │
│      ↓                                                   │
│  YOLOv8 Backbone (Feature Extraction)                    │
│      ↓                                                   │
│  Detection Head (Classification)                         │
│      ↓                                                   │
│  Post-processing (NMS, Confidence Thresholding)          │
│      ↓                                                   │
│  Output: {disease_class, confidence}                     │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## Disease Detection Workflow

### Complete Flow Diagram

```
┌─────────────┐
│    USER     │
│  Opens App  │
└──────┬──────┘
       │
       ▼
┌──────────────────────┐
│ Disease Detection    │
│      Screen          │
└──────┬───────────────┘
       │
       ├─────────────────┐
       │                 │
       ▼                 ▼
┌──────────┐      ┌──────────┐
│  Camera  │      │ Gallery  │
└──────┬───┘      └────┬─────┘
       │               │
       └───────┬───────┘
               │
               ▼
        ┌──────────────┐
        │ Image Select │
        │  & Compress  │
        └──────┬───────┘
               │
               ▼
        ┌──────────────────────────┐
        │  HTTP Multipart Request  │
        │  to Flask Server         │
        │  POST /predict           │
        └──────┬───────────────────┘
               │
               ▼
        ┌──────────────────────────┐
        │  YOLOv8 Model Inference  │
        │  - Load image            │
        │  - Run prediction        │
        │  - Calculate confidence  │
        └──────┬───────────────────┘
               │
               ▼
        ┌──────────────────────────┐
        │  JSON Response           │
        │  {prediction, confidence}│
        └──────┬───────────────────┘
               │
               ▼
        ┌──────────────────────────┐
        │  App Processing          │
        │  - Check if Healthy      │
        │  - Localize disease name │
        │  - Calculate severity    │
        └──────┬───────────────────┘
               │
               ├─────────────────┬──────────────┐
               │                 │              │
               ▼                 ▼              ▼
        ┌──────────┐      ┌──────────┐   ┌───────────┐
        │  Healthy │      │ Diseased │   │   Save    │
        │  (Green) │      │  (Red)   │   │  History  │
        └──────┬───┘      └────┬─────┘   └───────────┘
               │               │
               │               ▼
               │        ┌──────────────────┐
               │        │ Groq API Call    │
               │        │ (AI Treatment    │
               │        │  Recommendations)│
               │        └────┬─────────────┘
               │             │
               └─────────┬───┘
                         │
                         ▼
                  ┌──────────────┐
                  │ Display UI   │
                  │ - Disease    │
                  │ - Confidence │
                  │ - Severity   │
                  │ - Treatment  │
                  │ - Prevention │
                  └──────────────┘
```

### Detailed Step-by-Step Process

#### Step 1: Image Acquisition
```dart
// User selects camera or gallery
Future<void> _openCamera() async {
  final status = await Permission.camera.request();
  final XFile? photo = await _imagePicker.pickImage(
    source: ImageSource.camera,
    imageQuality: 50,
    maxWidth: 800,
    maxHeight: 800,
  );
  // Process image...
}
```

#### Step 2: API Request
```dart
// Send image to Flask backend
var request = http.MultipartRequest('POST', apiUri);
var imageFile = await http.MultipartFile.fromPath('file', imagePath);
request.files.add(imageFile);
var response = await request.send();
```

#### Step 3: Disease Classification
```python
# Flask backend processes image
@app.route('/predict', methods=['POST'])
def predict():
    file = request.files['file']
    img = Image.open(file.stream)
    results = model.predict(source=img, conf=0.25)
    
    predicted_class = results[0].names[class_id]
    confidence = float(results[0].probs[class_id])
    
    return jsonify({
        'prediction': predicted_class,
        'confidence': confidence
    })
```

#### Step 4: Result Processing
```dart
// App processes response
final prediction = responseData['prediction'];
final isHealthy = prediction.toLowerCase() == 'healthy';

setState(() {
  _detectionResult = {
    'disease': prediction,
    'confidence': confidence,
    'severity': _getSeverity(confidence),
    'description': isHealthy 
        ? 'Your grape plant appears healthy!'
        : 'Disease detected in grape leaf.',
  };
});

// Fetch AI recommendations (only for diseases)
if (!isHealthy) {
  _fetchAIRecommendations();
}
```

#### Step 5: AI Recommendations (Optional)
```dart
// Call Groq API for treatment advice
final prompt = """Provide treatment for $diseaseName in grape plants.
Format: DESCRIPTION, SYMPTOMS, TREATMENT, PREVENTION""";

final response = await http.post(
  Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
  headers: {
    'Authorization': 'Bearer $groqApiKey',
    'Content-Type': 'application/json',
  },
  body: json.encode({
    'model': 'llama-3.1-8b-instant',
    'messages': [
      {'role': 'system', 'content': 'Expert agricultural advisor'},
      {'role': 'user', 'content': prompt},
    ],
  }),
);
```

---

## AI Chatbot System

### Chatbot Architecture

```
┌────────────────────────────────────────────────────────────┐
│                    CHATBOT WORKFLOW                        │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  User Input                                                │
│      ↓                                                     │
│  ┌──────────────────────────────────────┐                │
│  │  Input Validation & Sanitization     │                │
│  └──────────────────┬───────────────────┘                │
│                     │                                      │
│                     ▼                                      │
│  ┌──────────────────────────────────────┐                │
│  │  Build Conversation Context          │                │
│  │  - Load chat history                 │                │
│  │  - Get locale preference             │                │
│  │  - Build system prompt               │                │
│  └──────────────────┬───────────────────┘                │
│                     │                                      │
│                     ▼                                      │
│  ┌──────────────────────────────────────┐                │
│  │  Groq API Request                    │                │
│  │  Model: llama-3.1-8b-instant         │                │
│  │  Temperature: 0.7                    │                │
│  └──────────────────┬───────────────────┘                │
│                     │                                      │
│                     ▼                                      │
│  ┌──────────────────────────────────────┐                │
│  │  Response Processing                 │                │
│  │  - Format markdown                   │                │
│  │  - Extract code blocks               │                │
│  │  - Validate content                  │                │
│  └──────────────────┬───────────────────┘                │
│                     │                                      │
│                     ▼                                      │
│  ┌──────────────────────────────────────┐                │
│  │  Save to History                     │                │
│  │  - Firebase (if authenticated)       │                │
│  │  - SharedPreferences (fallback)      │                │
│  └──────────────────┬───────────────────┘                │
│                     │                                      │
│                     ▼                                      │
│  Display Response in Chat UI                              │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### System Prompt Generation

```dart
String _buildSystemPrompt(BuildContext context) {
  final locale = LocaleController.instance.locale?.languageCode ?? 'en';
  
  // Language label map
  final langMap = {'en': 'English', 'hi': 'Hindi', 'mr': 'Marathi'};
  final langLabel = stringsOf(context).t(langMap[locale] ?? 'English');
  
  // Base system prompt (translated)
  final systemBase = stringsOf(context).t('chat_system_prompt');
  
  // Language instruction
  final respondPhrase = stringsOf(context)
      .t('chat_respond_in')
      .replaceAll('{lang}', langLabel);
  
  return '$systemBase\n\n$respondPhrase';
}
```

**Example System Prompts:**

**English:**
```
You are a specialized farming assistant focused ONLY on agriculture, 
farming, and crop cultivation topics. Provide expert, practical, 
and concise advice farmers can apply.

Please respond in English.
```

**Hindi:**
```
You are a specialized farming assistant focused ONLY on agriculture, 
farming, and crop cultivation topics. Provide expert, practical, 
and concise advice farmers can apply.

कृपया हिन्दी में जवाब दें।
```

### Chat Persistence

```dart
// Save chat history
Future<void> _saveChatHistory() async {
  final user = AuthService.instance.currentUser;
  
  if (user != null) {
    // Save to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('chatHistory')
        .doc('latest')
        .set({
      'messages': _storedMessages.map((m) => m.toJson()).toList(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  } else {
    // Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _storedMessages.map((m) => json.encode(m.toJson())).toList();
    await prefs.setStringList('chat_history', jsonList);
  }
}
```

---

## Localization System

### Localization Architecture

```
┌────────────────────────────────────────────────────────────┐
│                 LOCALIZATION SYSTEM                        │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  ┌──────────────────────────────────────────┐            │
│  │         LocaleController                  │            │
│  │  - Current locale state                   │            │
│  │  - setLocale(Locale)                      │            │
│  │  - notifyListeners()                      │            │
│  └──────────────────┬───────────────────────┘            │
│                     │                                      │
│                     ▼                                      │
│  ┌──────────────────────────────────────────┐            │
│  │      TranslationController                │            │
│  │  - Load translations from ARB files       │            │
│  │  - Cache in SharedPreferences             │            │
│  │  - Fallback to embedded translations      │            │
│  └──────────────────┬───────────────────────┘            │
│                     │                                      │
│                     ▼                                      │
│  ┌──────────────────────────────────────────┐            │
│  │           AppStrings Wrapper              │            │
│  │  - stringsOf(context).t(key)              │            │
│  │  - Runtime translation lookup             │            │
│  │  - Fallback chain                         │            │
│  └──────────────────┬───────────────────────┘            │
│                     │                                      │
│                     ▼                                      │
│  ┌──────────────────────────────────────────┐            │
│  │              UI Display                   │            │
│  │  - All text automatically localized       │            │
│  │  - Hot reload on locale change            │            │
│  └───────────────────────────────────────────┘            │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### Translation Files

**Structure:**
```
lib/l10n/
├── intl_en.arb      # English (base language)
├── intl_hi.arb      # Hindi translations
└── intl_mr.arb      # Marathi translations
```

**Example Keys:**
```json
{
  "disease_powdery_mildew": "Powdery Mildew",
  "disease_downy_mildew": "Downy Mildew",
  "disease_healthy": "Healthy",
  "Confidence": "Confidence",
  "Severity": "Severity",
  "Plant Status": "Plant Status"
}
```

### Disease Name Localization

```dart
String _localizedDiseaseLabel(BuildContext context, String raw) {
  final s = stringsOf(context);
  
  // Normalize: "Powdery_Mildew" → "disease_powdery_mildew"
  var normalized = raw.toLowerCase()
      .replaceAll(RegExp(r"[^a-z0-9]+"), '_')
      .trim();
  
  final transKey = 'disease_$normalized';
  final translated = s.t(transKey);
  
  // If translation exists, use it; otherwise clean up the raw string
  if (translated != transKey) {
    return translated;
  }
  
  // Fallback: "Powdery_Mildew" → "Powdery Mildew"
  return raw.replaceAll('_', ' ')
      .split(' ')
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
}
```

---

## Firebase Integration

### Firebase Services Used

```
┌────────────────────────────────────────────────────────────┐
│                   FIREBASE SERVICES                        │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  ┌──────────────────────────────────────────┐            │
│  │         Firebase Authentication           │            │
│  │  - Email/Password                         │            │
│  │  - Google Sign-In                         │            │
│  │  - Anonymous Auth                         │            │
│  └───────────────────────────────────────────┘            │
│                                                            │
│  ┌──────────────────────────────────────────┐            │
│  │         Cloud Firestore                   │            │
│  │  Collections:                             │            │
│  │    - users/{uid}/crops                    │            │
│  │    - users/{uid}/chatHistory              │            │
│  │    - users/{uid}/scanHistory              │            │
│  │    - community/posts                      │            │
│  │    - marketplace/products                 │            │
│  └───────────────────────────────────────────┘            │
│                                                            │
│  ┌──────────────────────────────────────────┐            │
│  │         Firebase Storage                  │            │
│  │  - User profile images                    │            │
│  │  - Crop images                            │            │
│  │  - Disease scan images                    │            │
│  │  - Community post images                  │            │
│  └───────────────────────────────────────────┘            │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### Firestore Data Models

#### User Crops Collection
```
users/{uid}/crops/{cropId}
{
  "cropName": "Thompson Seedless",
  "variety": "White Grape",
  "plantingDate": Timestamp,
  "area": 5.5,
  "location": "Nashik, Maharashtra",
  "status": "Active",
  "imageUrl": "gs://...",
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

#### Scan History Collection
```
users/{uid}/scanHistory/{scanId}
{
  "id": "1699789012345",
  "diseaseName": "Powdery_Mildew",
  "confidence": 0.9964,
  "severity": "High",
  "imagePath": "/storage/...",
  "timestamp": Timestamp,
  "recommendations": {
    "description": "...",
    "symptoms": [...],
    "treatment": [...],
    "prevention": [...]
  }
}
```

#### Chat History Collection
```
users/{uid}/chatHistory/latest
{
  "messages": [
    {
      "text": "How do I treat powdery mildew?",
      "isUser": true,
      "timestamp": Timestamp
    },
    {
      "text": "To treat powdery mildew...",
      "isUser": false,
      "timestamp": Timestamp
    }
  ],
  "timestamp": Timestamp
}
```

### Security Rules

**Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null 
                         && request.auth.uid == userId;
    }
    
    // Community posts - read public, write authenticated
    match /community/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Marketplace - read public, write authenticated
    match /marketplace/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

**Storage Rules:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
                   && request.auth.uid == userId;
    }
  }
}
```

---

## Data Flow Diagrams

### 1. User Authentication Flow

```
┌─────────┐
│  User   │
└────┬────┘
     │
     ▼
┌─────────────────┐
│  Auth Screen    │
│  (Login/Signup) │
└────┬────────────┘
     │
     ├────────────────┬─────────────────┐
     │                │                 │
     ▼                ▼                 ▼
┌──────────┐   ┌──────────┐   ┌──────────────┐
│  Email   │   │  Google  │   │  Anonymous   │
│  Login   │   │ Sign-In  │   │    Login     │
└────┬─────┘   └────┬─────┘   └──────┬───────┘
     │              │                 │
     └──────────────┴─────────────────┘
                    │
                    ▼
         ┌─────────────────────┐
         │ Firebase Auth       │
         │ Authentication      │
         └──────┬──────────────┘
                │
                ▼
         ┌─────────────────────┐
         │  Token Generation   │
         │  & Session Start    │
         └──────┬──────────────┘
                │
                ▼
         ┌─────────────────────┐
         │  Main App Screen    │
         │  (5 Bottom Tabs)    │
         └─────────────────────┘
```

### 2. Crop Management Flow

```
┌────────────────┐
│  User selects  │
│  "Your Crops"  │
└───────┬────────┘
        │
        ▼
┌────────────────────┐
│  Crops List Screen │
│  Load from Firestore│
└────┬───────────────┘
     │
     ├──────────────┬──────────────┐
     │              │              │
     ▼              ▼              ▼
┌─────────┐   ┌─────────┐   ┌─────────┐
│   Add   │   │  View   │   │  Edit   │
│  Crop   │   │  Crop   │   │  Crop   │
└────┬────┘   └────┬────┘   └────┬────┘
     │             │             │
     ▼             │             ▼
┌──────────┐       │       ┌──────────┐
│  Upload  │       │       │  Update  │
│  Image   │       │       │  Fields  │
└────┬─────┘       │       └────┬─────┘
     │             │             │
     └─────────────┴─────────────┘
                   │
                   ▼
        ┌──────────────────┐
        │  Firebase        │
        │  Firestore Write │
        └──────┬───────────┘
               │
               ▼
        ┌──────────────────┐
        │  Update UI       │
        │  (State Refresh) │
        └──────────────────┘
```

### 3. Weather Integration Flow

```
┌────────────────┐
│  App Launches  │
└───────┬────────┘
        │
        ▼
┌─────────────────────┐
│  Request Location   │
│  Permission         │
└────┬────────────────┘
     │
     ├──────────────┬──────────────┐
     │              │              │
     ▼              ▼              ▼
┌─────────┐   ┌─────────┐   ┌──────────┐
│ Granted │   │ Denied  │   │  Error   │
└────┬────┘   └────┬────┘   └────┬─────┘
     │             │              │
     ▼             ▼              ▼
┌─────────────┐  ┌──────────────────┐
│ Get GPS     │  │ Use IP-based     │
│ Coordinates │  │ Location (ip-api)│
└──────┬──────┘  └────┬─────────────┘
       │              │
       └──────┬───────┘
              │
              ▼
   ┌────────────────────────┐
   │  OpenWeather API Call  │
   │  GET /data/2.5/weather │
   └──────┬─────────────────┘
          │
          ▼
   ┌────────────────────────┐
   │  Parse Weather Data    │
   │  - Temperature         │
   │  - Conditions          │
   │  - Humidity            │
   │  - Wind                │
   └──────┬─────────────────┘
          │
          ▼
   ┌────────────────────────┐
   │  Display on Home       │
   │  Screen Widget         │
   └────────────────────────┘
```

---

## API Documentation

### Flask Backend API

#### Base URL
```
http://192.168.110.50:10000
```

#### Endpoints

##### 1. Health Check
```
GET /
```

**Response:**
```json
{
  "status": "Disease Detection API is running",
  "model": "YOLOv8",
  "version": "1.0.0"
}
```

##### 2. Disease Prediction
```
POST /predict
Content-Type: multipart/form-data
```

**Request Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| file | File | Yes | Image file (JPG, PNG) of grape leaf |

**Example Request (Python):**
```python
import requests

url = "http://192.168.110.50:10000/predict"
files = {'file': open('leaf.jpg', 'rb')}
response = requests.post(url, files=files)
print(response.json())
```

**Example Request (Flutter):**
```dart
var request = http.MultipartRequest('POST', Uri.parse(apiEndpoint));
var imageFile = await http.MultipartFile.fromPath('file', imagePath);
request.files.add(imageFile);
var response = await request.send();
```

**Success Response (200):**
```json
{
  "prediction": "Powdery_Mildew",
  "confidence": 0.9964
}
```

**Error Responses:**

400 Bad Request:
```json
{
  "error": "No file provided"
}
```

500 Internal Server Error:
```json
{
  "error": "Prediction failed",
  "details": "..."
}
```

### Groq AI API

#### Base URL
```
https://api.groq.com/openai/v1
```

#### Chat Completions Endpoint

```
POST /chat/completions
Authorization: Bearer {GROQ_API_KEY}
Content-Type: application/json
```

**Request Body:**
```json
{
  "model": "llama-3.1-8b-instant",
  "messages": [
    {
      "role": "system",
      "content": "You are an expert agricultural advisor..."
    },
    {
      "role": "user",
      "content": "How do I treat powdery mildew in grapes?"
    }
  ],
  "temperature": 0.7,
  "max_tokens": 500
}
```

**Response:**
```json
{
  "id": "chatcmpl-...",
  "object": "chat.completion",
  "created": 1699789012,
  "model": "llama-3.1-8b-instant",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "To treat powdery mildew in grapes:\n\n..."
      },
      "finish_reason": "stop"
    }
  ]
}
```

### OpenWeather API

#### Base URL
```
https://api.openweathermap.org/data/2.5
```

#### Current Weather Endpoint

```
GET /weather?lat={lat}&lon={lon}&units=metric&appid={API_KEY}
```

**Response:**
```json
{
  "coord": {"lon": 73.8502, "lat": 18.5211},
  "weather": [
    {
      "id": 800,
      "main": "Clear",
      "description": "clear sky",
      "icon": "01d"
    }
  ],
  "main": {
    "temp": 28.5,
    "feels_like": 30.2,
    "temp_min": 26.0,
    "temp_max": 31.0,
    "pressure": 1013,
    "humidity": 65
  },
  "wind": {"speed": 3.5, "deg": 120}
}
```

---

## Security & Configuration

### Environment Variables

**`.env` file:**
```bash
# Groq API for AI Chatbot
GROQ_API_KEY=your_groq_api_key_here

# OpenWeather API for Weather Data
OPENWEATHER_API_KEY=your_openweather_api_key_here
```

### Android Configuration

**Network Security Config:**
```xml
<!-- android/app/src/main/res/xml/network_security_config.xml -->
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">192.168.0.0</domain>
        <domain includeSubdomains="true">192.168.1.0</domain>
        <domain includeSubdomains="true">192.168.110.50</domain>
        <domain includeSubdomains="true">10.0.2.2</domain>
    </domain-config>
</network-security-config>
```

**Manifest Permissions:**
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### API Key Security Best Practices

1. **Never commit `.env` to Git**
   - Add `.env` to `.gitignore`
   - Use `.env.example` as template

2. **Use environment-specific keys**
   - Development keys for testing
   - Production keys for release

3. **Rotate keys regularly**
   - Change API keys periodically
   - Monitor API usage for anomalies

4. **Restrict API key permissions**
   - Set Firebase rules per user
   - Limit API rate limits

---

## Performance Optimization

### Image Processing
- **Compression:** Images compressed to 50% quality
- **Resizing:** Max dimensions 800x800px
- **Format:** JPEG for smaller file size

### Caching Strategy
- **Translation Cache:** Store in SharedPreferences
- **Weather Cache:** Update every 30 minutes
- **Model Cache:** YOLOv8 loaded once on server start

### Network Optimization
- **Timeout Settings:** 60s for disease detection, 15s for AI chat
- **Retry Logic:** Automatic retry on network failure
- **Compression:** Enable HTTP compression

---

## Deployment Guide

### Backend Deployment (Flask)

**1. Install Dependencies:**
```bash
cd grapeMasterBackend
pip install -r requirements.txt
```

**2. Run Server:**
```bash
python app.py
```

**3. Production Deployment (Gunicorn):**
```bash
gunicorn -w 4 -b 0.0.0.0:10000 app:app
```

### Mobile App Deployment

**1. Build APK (Android):**
```bash
flutter build apk --release
```

**2. Build App Bundle:**
```bash
flutter build appbundle --release
```

**3. iOS Build:**
```bash
flutter build ios --release
```

---

## Troubleshooting

### Common Issues

#### 1. Disease Detection Fails
**Symptom:** Network error or timeout  
**Solution:**
- Check Flask server is running
- Verify IP address in `apiHost`
- Check network security config
- Ensure firewall allows port 10000

#### 2. Chatbot Not Responding
**Symptom:** No AI response or error  
**Solution:**
- Verify GROQ_API_KEY in `.env`
- Check API quota/rate limits
- Test with simple prompt

#### 3. Location Not Working
**Symptom:** Weather not loading  
**Solution:**
- Grant location permissions
- Check GPS is enabled
- Verify OPENWEATHER_API_KEY

#### 4. Firebase Errors
**Symptom:** Auth/Firestore failures  
**Solution:**
- Check firebase_options.dart
- Verify Firebase project setup
- Check security rules

---

## Future Enhancements

### Planned Features

1. **Offline Mode**
   - Local disease detection model
   - Cached translations
   - Offline chat history

2. **Advanced Analytics**
   - Disease trend analysis
   - Crop health tracking
   - Yield prediction

3. **Community Features**
   - Direct messaging
   - Expert consultations
   - Video tutorials

4. **IoT Integration**
   - Soil sensors
   - Weather stations
   - Automated irrigation

5. **Marketplace Enhancements**
   - In-app payments
   - Order tracking
   - Seller ratings

---

## Conclusion

GrapeMaster is a comprehensive farming assistant app that combines:
- **AI/ML Disease Detection** using YOLOv8
- **Intelligent Chatbot** powered by Groq LLM
- **Multilingual Support** (English, Hindi, Marathi)
- **Cloud Integration** via Firebase
- **Real-time Weather** data
- **Community & Marketplace** features

The app architecture is modular, scalable, and follows Flutter best practices with clean separation of concerns between presentation, business logic, and data layers.

---

## Contact & Support

**Developer:** Asm  
**Repository:** [si-grapemaster](https://github.com/aayushamarne/si-grapemaster)  
**Last Updated:** November 12, 2025

For issues and feature requests, please create an issue on GitHub.

---

**End of Technical Documentation**
