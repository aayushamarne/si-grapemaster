import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'src/auth/auth_service2.dart';
import 'src/screens/auth_screen.dart';
import 'src/screens/add_farmer_screen.dart';
import 'src/screens/add_crop_screen.dart';
import 'src/screens/new_post_screen.dart';
import 'src/screens/crops_list_screen.dart';
import 'src/screens/disease_detection_screen.dart';
import 'src/screens/crop_details_screen.dart';
import 'src/screens/chatbot_screen.dart';
import 'src/screens/profile_settings_screen.dart';
import 'src/screens/notifications_screen.dart';
import 'src/screens/language_screen.dart';
import 'src/screens/help_support_screen.dart';
import 'src/screens/privacy_policy_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }
  runApp(const GrapemasterApp());
}

class GrapemasterApp extends StatefulWidget {
  const GrapemasterApp({super.key});

  @override
  State<GrapemasterApp> createState() => _GrapemasterAppState();
}

class _GrapemasterAppState extends State<GrapemasterApp> {
  final LocaleController _localeController = LocaleController.instance;
  final TranslationController _translationController = TranslationController.instance;
  bool _isReady = false;
  bool _needsLanguageSelection = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('selected_locale');
    if (code != null) {
      _localeController.setLocale(Locale(code));
      _needsLanguageSelection = false;
    }
    // Ensure translations for the initial or saved locale are loaded
    await _translationController.ensureLoaded(_localeController.locale?.languageCode ?? 'en');
    setState(() => _isReady = true);
  }

  Future<void> _onLanguageChosen(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_locale', locale.languageCode);
    _localeController.setLocale(locale);
    // Load translations for the newly selected locale and trigger UI rebuild
    await _translationController.ensureLoaded(locale.languageCode);
    _translationController.notifyListeners(); // Force UI rebuild
    setState(() => _needsLanguageSelection = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const MaterialApp(home: SizedBox());
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _localeController,
        _translationController,
      ]),
      builder: (context, _) {
        return MaterialApp(
          title: 'GrapeMaster - Indian Farming Assistant',
          locale: _localeController.locale,
          supportedLocales: const [Locale('en'), Locale('hi'), Locale('mr')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D5EF9)),
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          debugShowCheckedModeBanner: false,
          home: _needsLanguageSelection
              ? LanguageSelectionScreen(onAccept: _onLanguageChosen)
              : const RootScaffold(),
        );
      },
    );
  }
}

class LocaleController extends ChangeNotifier {
  static final LocaleController instance = LocaleController._();
  LocaleController._();

  Locale? _locale;
  Locale? get locale => _locale;
  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}

AppStrings stringsOf(BuildContext context) {
  final code = LocaleController.instance.locale?.languageCode ?? 'en';
  return AppStrings(code);
}

class AppStrings {
  final String code;
  AppStrings(this.code);

  // Fallback translations for immediate display while API loads
  // Make this `final` (not `const`) because some keys are duplicated in the
  // literal (duplicates will be resolved at runtime; const would cause a
  // compile-time duplicate-key error).
  static final Map<String, Map<String, String>> _fallbackData = {
    'en': {
             'app_title': 'GrapeMaster',
      'tab_crops': 'Your crops',
      'tab_community': 'Community',
      'tab_market': 'Market',
      'tab_you': 'You',
      'heal_your_crop': 'Heal your crop',
      'sponsored': 'Sponsored',
      'take_picture': 'Take a picture',
      'search_community': 'Search in Community',
      'search_market': 'Search by product name, crop,',
      'today': 'Today, 25 Aug',
      'clear': 'Clear • 24°C / 20°C',
      'location_perm': 'Location permission required',
      'allow': 'Allow',
      'Spraying': 'Spraying',
      'Mode': 'Mode',
      'Take a\npicture': 'Take a\npicture',
      'See\ndiagnosis': 'See\ndiagnosis',
      'Get\nmedicine': 'Get\nmedicine',
      'Profile': 'Profile',
      'Accept': 'Accept',
      'Namaste!': 'Namaste!',
             'Select your GrapeMaster language': 'Select your GrapeMaster language',
      'मराठी': 'मराठी',
      'हिन्दी': 'हिन्दी',
      'English': 'English',
      'स्वत:च्या भाषेत शेती': 'स्वत:च्या भाषेत शेती',
      'खेती आपकी भाषा में': 'खेती आपकी भाषा में',
      'Farming in your language': 'Farming in your language',
      'I read and accept the ': 'I read and accept the ',
      'terms of use': 'terms of use',
      ' and the ': ' and the ',
      'privacy policy': 'privacy policy',
      '.': '.',
             'Capsicum & Chilli': 'Capsicum & Chilli',
       'Apple': 'Apple',
       'Grape': 'Grape',
       'Wheat': 'Wheat',
       'Rice': 'Rice',
       'Cotton': 'Cotton',
       'Sugarcane': 'Sugarcane',
       'Potato': 'Potato',
       'Onion': 'Onion',
       'Tomato': 'Tomato',
       'Brinjal': 'Brinjal',
       'Okra': 'Okra',
       'Cucumber': 'Cucumber',
       'Pumpkin': 'Pumpkin',
       'Bitter Gourd': 'Bitter Gourd',
       'Bottle Gourd': 'Bottle Gourd',
       'Ridge Gourd': 'Ridge Gourd',
       'Sponge Gourd': 'Sponge Gourd',
       'Ash Gourd': 'Ash Gourd',
       'Snake Gourd': 'Snake Gourd',
       'Pointed Gourd': 'Pointed Gourd',
       'Ivy Gourd': 'Ivy Gourd',
      
       'Kundru': 'Kundru',
       'Parwal': 'Parwal',
       'Karela': 'Karela',
       'Lauki': 'Lauki',
       'Tori': 'Tori',
      'Share desease details': 'Share desease details',
      'Share solutions': 'Share solutions',
      'Hari Shankar Shukla • India': 'Hari Shankar Shukla • India',
      'Translate': 'Translate',
      '0 answers': '0 answers',
      'ACROBAT': 'ACROBAT',
      'AEROWON': 'AEROWON',
      'by GAPL': 'by GAPL',
      '₹190': '₹190',
      '500 millilitre': '500 millilitre',
      'Pesticides': 'Pesticides',
      'Fertilizers': 'Fertilizers',
      'Seeds': 'Seeds',
      'Organic Crop Nutrition': 'Organic Crop Nutrition',
      'Cattle Feed': 'Cattle Feed',
      'Tools and Machinery': 'Tools and Machinery',
      // Profile related translations
      'Profile Settings': 'Profile Settings',
      'Personal Information': 'Personal Information',
      'Update your profile details': 'Update your profile details',
      'Notifications': 'Notifications',
      'Manage notification preferences': 'Manage notification preferences',
      'Privacy & Security': 'Privacy & Security',
      'Control your privacy settings': 'Control your privacy settings',
      'Language': 'Language',
      'Change app language': 'Change app language',
      'Help & Support': 'Help & Support',
      'Get help and contact support': 'Get help and contact support',
      'About': 'About',
      'App version and information': 'App version and information',
      'Settings': 'Settings',
      'Account Actions': 'Account Actions',
      'Sign Out': 'Sign Out',
      'Delete Account': 'Delete Account',
      'Quick Actions': 'Quick Actions',
      'Take Photo': 'Take Photo',
      'History': 'History',
      'Favorites': 'Favorites',
      'Share App': 'Share App',
      'Active Crops': 'Active Crops',
      'Days Active': 'Days Active',
      'Rating': 'Rating',
      'Premium Member': 'Premium Member',
      'Quick Stats': 'Quick Stats',
      'Weekly Summary': 'Weekly Summary',
      'Photos Taken': 'Photos Taken',
      'Diseases Detected': 'Diseases Detected',
      'Solutions Applied': 'Solutions Applied',
      'Crops Monitored': 'Crops Monitored',
      'Recent Searches': 'Recent Searches',
      'Trending Topics': 'Trending Topics',
      'Organic Crop Protection': 'Organic Crop Protection',
      'Weekly Summary': 'Weekly Summary',
      'Photos Taken': 'Photos Taken',
      'Diseases Detected': 'Diseases Detected',
      'Solutions Applied': 'Solutions Applied',
      'Crops Monitored': 'Crops Monitored',
      'Camera': 'Camera',
      'Gallery': 'Gallery',
      'Cancel': 'Cancel',
    },
    'hi': {
             'app_title': 'ग्रेपमास्टर',
      'tab_crops': 'आपकी फ़सलें',
      'tab_community': 'समुदाय',
      'tab_market': 'बाज़ार',
      'tab_you': 'आप',
      'heal_your_crop': 'अपनी फ़सल का इलाज करें',
      'sponsored': 'प्रायोजित',
      'take_picture': 'तस्वीर लें',
      'search_community': 'समुदाय में खोजें',
      'search_market': 'उत्पाद नाम, फसल से खोजें',
      'today': 'आज, 25 अगस्त',
      'clear': 'साफ़ • 24°C / 20°C',
      'location_perm': 'स्थान अनुमति आवश्यक',
      'allow': 'अनुमति दें',
      'Spraying': 'स्प्रेइंग',
      'Mode': 'मोड',
      'Take a\npicture': 'तस्वीर\nलें',
      'See\ndiagnosis': 'निदान\nदेखें',
      'Get\nmedicine': 'दवा\nप्राप्त करें',
      'Profile': 'प्रोफ़ाइल',
      'Accept': 'स्वीकार करें',
      'Namaste!': 'नमस्ते!',
             'Select your GrapeMaster language': 'अपनी ग्रेपमास्टर भाषा चुनें',
      'मराठी': 'मराठी',
      'हिन्दी': 'हिन्दी',
      'English': 'English',
      'स्वत:च्या भाषेत शेती': 'स्वत:च्या भाषेत शेती',
      'खेती आपकी भाषा में': 'खेती आपकी भाषा में',
      'Farming in your language': 'Farming in your language',
      'I read and accept the ': 'मैं पढ़ता हूं और स्वीकार करता हूं ',
      'terms of use': 'उपयोग की शर्तें',
      ' and the ': ' और ',
      'privacy policy': 'गोपनीयता नीति',
      '.': '.',
      'Capsicum & Chilli': 'शिमला मिर्च और मिर्च',
      'Apple': 'सेब',
      'Grape': 'अंगूर',
      'Share desease details': 'रोग विवरण साझा करें',
      'Share solutions': 'समाधान साझा करें',
      'Hari Shankar Shukla • India': 'हरि शंकर शुक्ला • भारत',
      'Translate': 'अनुवाद करें',
      '0 answers': '0 उत्तर',
      'ACROBAT': 'एक्रोबैट',
      'AEROWON': 'एरोवॉन',
      'by GAPL': 'GAPL द्वारा',
      '₹190': '₹190',
      '500 millilitre': '500 मिलीलीटर',
      'Pesticides': 'कीटनाशक',
      'Fertilizers': 'उर्वरक',
      'Seeds': 'बीज',
      'Organic Crop Nutrition': 'जैविक फसल पोषण',
      'Cattle Feed': 'पशु आहार',
      'Tools and Machinery': 'उपकरण और मशीनरी',
      // Profile related translations
      'Profile Settings': 'प्रोफ़ाइल सेटिंग्स',
      'Personal Information': 'व्यक्तिगत जानकारी',
      'Update your profile details': 'अपनी प्रोफ़ाइल विवरण अपडेट करें',
      'Notifications': 'सूचनाएं',
      'Manage notification preferences': 'सूचना प्राथमिकताएं प्रबंधित करें',
      'Privacy & Security': 'गोपनीयता और सुरक्षा',
      'Control your privacy settings': 'अपनी गोपनीयता सेटिंग्स नियंत्रित करें',
      'Language': 'भाषा',
      'Change app language': 'ऐप भाषा बदलें',
      'Help & Support': 'सहायता और समर्थन',
      'Get help and contact support': 'सहायता प्राप्त करें और समर्थन से संपर्क करें',
      'About': 'के बारे में',
      'App version and information': 'ऐप संस्करण और जानकारी',
      'Settings': 'सेटिंग्स',
      'Account Actions': 'खाता कार्य',
      'Sign Out': 'साइन आउट',
      'Delete Account': 'खाता हटाएं',
      'Quick Actions': 'त्वरित कार्य',
      'Take Photo': 'फोटो लें',
      'History': 'इतिहास',
      'Favorites': 'पसंदीदा',
      'Share App': 'ऐप साझा करें',
      'Active Crops': 'सक्रिय फसलें',
      'Days Active': 'सक्रिय दिन',
      'Rating': 'रेटिंग',
      'Premium Member': 'प्रीमियम सदस्य',
    },
    'mr': {
             'app_title': 'ग्रेपमास्टर',
      'tab_crops': 'आपली पिके',
      'tab_community': 'समुदाय',
      'tab_market': 'बाजार',
      'tab_you': 'तुम्ही',
      'heal_your_crop': 'आपल्या पिकाचा उपचार करा',
      'sponsored': 'प्रायोजित',
      'take_picture': 'फोटो घ्या',
      'search_community': 'समुदायात शोधा',
      'search_market': 'उत्पादन नाव, पिकानुसार शोधा',
      'today': 'आज, २५ ऑगस्ट',
      'clear': 'स्वच्छ • 24°C / 20°C',
      'location_perm': 'स्थान परवानगी आवश्यक',
      'allow': 'परवानगी',
      'Spraying': 'स्प्रेइंग',
      'Mode': 'मोड',
      'Take a\npicture': 'फोटो\nघ्या',
      'See\ndiagnosis': 'निदान\nपहा',
      'Get\nmedicine': 'औषध\nमिळवा',
      'Profile': 'प्रोफाइल',
      'Accept': 'स्वीकार करा',
      'Namaste!': 'नमस्कार!',
             'Select your Plantix language': 'आपली ग्रेपमास्टर भाषा निवडा',
      'मराठी': 'मराठी',
      'हिन्दी': 'हिन्दी',
      'English': 'English',
      'स्वत:च्या भाषेत शेती': 'स्वत:च्या भाषेत शेती',
      'खेती आपकी भाषा में': 'खेती आपकी भाषा में',
      'Farming in your language': 'Farming in your language',
      'I read and accept the ': 'मी वाचतो आणि स्वीकारतो ',
      'terms of use': 'वापरण्याच्या अटी',
      ' and the ': ' आणि ',
      'privacy policy': 'गोपनीयता धोरण',
      '.': '.',
      'Capsicum & Chilli': 'भोपळी मिरची आणि मिरची',
      'Apple': 'सफरचंद',
      'Grape': 'द्राक्षे',
      'Share desease details': 'रोग तपशील सामायिक करा',
      'Share solutions': 'उपाय सामायिक करा',
      'Hari Shankar Shukla • India': 'हरी शंकर शुक्ला • भारत',
      'Translate': 'भाषांतर करा',
      '0 answers': '0 उत्तरे',
      'ACROBAT': 'एक्रोबॅट',
      'AEROWON': 'एरोवॉन',
      'by GAPL': 'GAPL द्वारे',
      '₹190': '₹190',
      '500 millilitre': '500 मिलीलीटर',
      'Pesticides': 'कीटकनाशके',
      'Fertilizers': 'खते',
      'Seeds': 'बियाणे',
      'Organic Crop Nutrition': 'सेंद्रिय पीक पोषण',
      'Cattle Feed': 'गुरेढोरे खाद्य',
      'Tools and Machinery': 'साधने आणि यंत्रे',
      // Profile related translations
      'Profile Settings': 'प्रोफाइल सेटिंग्ज',
      'Personal Information': 'वैयक्तिक माहिती',
      'Update your profile details': 'तुमची प्रोफाइल तपशील अपडेट करा',
      'Notifications': 'सूचना',
      'Manage notification preferences': 'सूचना प्राधान्ये व्यवस्थापित करा',
      'Privacy & Security': 'गोपनीयता आणि सुरक्षा',
      'Control your privacy settings': 'तुमची गोपनीयता सेटिंग्ज नियंत्रित करा',
      'Language': 'भाषा',
      'Change app language': 'अॅप भाषा बदला',
      'Help & Support': 'मदत आणि समर्थन',
      'Get help and contact support': 'मदत मिळवा आणि समर्थनाशी संपर्क साधा',
      'About': 'बद्दल',
      'App version and information': 'अॅप आवृत्ती आणि माहिती',
      'Settings': 'सेटिंग्ज',
      'Account Actions': 'खाते कृती',
      'Sign Out': 'साइन आउट',
      'Delete Account': 'खाते हटवा',
      'Quick Actions': 'त्वरित कृती',
      'Take Photo': 'फोटो घ्या',
      'History': 'इतिहास',
      'Favorites': 'आवडी',
      'Share App': 'अॅप शेअर करा',
      'Active Crops': 'सक्रिय पिके',
      'Days Active': 'सक्रिय दिवस',
      'Rating': 'रेटिंग',
      'Premium Member': 'प्रीमियम सदस्य',
    },
  };

  String t(String key) {
    // Translate the English phrase, not the key
    final englishText = _fallbackData['en']?[key] ?? key;
    final apiResult = TranslationController.instance.translate(code: code, key: englishText);
    if (apiResult != englishText) return apiResult;

    // Fallback to hardcoded translations by key → localized string
    return _fallbackData[code]?[key] ?? _fallbackData['en']?[key] ?? englishText;
  }

  // Builds a dynamic label like "Today, 28 Aug" in the selected language
  String todayLabel() {
    final now = DateTime.now();
    final months = <String, List<String>>{
      'en': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
      'hi': ['जन', 'फ़र', 'मार्च', 'अप्रै', 'मई', 'जून', 'जुला', 'अग', 'सितं', 'अक्टू', 'नव', 'दिसं'],
      'mr': ['जान', 'फेब', 'मार्च', 'एप्र', 'मे', 'जून', 'जुल', 'ऑग', 'सप्ट', 'ऑक्ट', 'नोव्ह', 'डिसं'],
    };
    final month = (months[code] ?? months['en'])![now.month - 1];
    final todayWord = switch (code) { 'hi' => 'आज', 'mr' => 'आज', _ => 'Today' };
    return '$todayWord, ${now.day} $month';
  }
}

/// Dynamic translation controller that can translate ANY text using LibreTranslate (free)
/// and caches results per text/locale combination in SharedPreferences.
class TranslationController extends ChangeNotifier {
  static final TranslationController instance = TranslationController._();
  TranslationController._();

  // LibreTranslate mirrors (no API key). We'll try these in order.
  static const List<String> _libreEndpoints = [
    'https://libretranslate.de/translate',
    'https://translate.mentality.rip/translate',
    'https://libretranslate.com/translate',
  ];

  final Map<String, Map<String, String>> _memoryCache = {};
  final Set<String> _loadingKeys = {};
  final Set<String> _failedKeys = {}; // avoid retry storms when offline

  Future<void> ensureLoaded(String code) async {
    // Load cached translations from disk
    if (_memoryCache.containsKey(code)) return;
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('translations_$code');
    if (cached != null) {
      final map = Map<String, dynamic>.from(jsonDecode(cached));
      _memoryCache[code] = map.map((k, v) => MapEntry(k, v.toString()));
      notifyListeners();
    }
    
    // Pre-translate common strings for better UX
    if (code != 'en') {
      await _preTranslateCommonStrings(code);
    }
  }

  Future<void> _preTranslateCommonStrings(String code) async {
    final commonStrings = [
      'Plantix',
      'Your crops',
      'Community', 
      'Market',
      'You',
      'Heal your crop',
      'Sponsored',
      'Take a picture',
      'Search in Community',
      'Search by product name, crop,',
      'Today, 25 Aug',
      'Clear • 24°C / 20°C',
      'Location permission required',
      'Allow',
      'Pesticides',
      'Fertilizers',
      'Seeds',
      'Organic Crop Nutrition',
      'Cattle Feed',
      'Tools and Machinery',
      'Profile',
      'Accept',
      'Namaste!',
      'Select your Plantix language',
      'मराठी',
      'हिन्दी',
      'English',
      'स्वत:च्या भाषेत शेती',
      'खेती आपकी भाषा में',
      'Farming in your language',
      'I read and accept the ',
      'terms of use',
      ' and the ',
      'privacy policy',
      '.',
      'Capsicum & Chilli',
      'Apple',
      'Grape',
      'Share desease details',
      'Share solutions',
      'Spraying',
      'Mode',
      'Take a\npicture',
      'See\ndiagnosis',
      'Get\nmedicine',
      'Hari Shankar Shukla • India',
      'Translate',
      '0 answers',
      'ACROBAT',
      'AEROWON',
      'by GAPL',
      '₹190',
      '500 millilitre',
      // Profile related strings
      'Profile Settings',
      'Personal Information',
      'Update your profile details',
      'Notifications',
      'Manage notification preferences',
      'Privacy & Security',
      'Control your privacy settings',
      'Language',
      'Change app language',
      'Help & Support',
      'Get help and contact support',
      'About',
      'App version and information',
      'Settings',
      'Account Actions',
      'Sign Out',
      'Delete Account',
      'Quick Actions',
      'Take Photo',
      'History',
      'Favorites',
      'Share App',
      'Active Crops',
      'Days Active',
      'Rating',
      'Premium Member',
      'Quick Stats',
      'Weekly Summary',
      'Photos Taken',
      'Diseases Detected',
      'Solutions Applied',
      'Crops Monitored',
      'Recent Searches',
      'Trending Topics',
      'Organic Crop Protection',
      'Weekly Summary',
      'Photos Taken',
      'Diseases Detected',
      'Solutions Applied',
      'Crops Monitored',
      'Camera',
      'Gallery',
      'Cancel',
    ];

    for (final text in commonStrings) {
      final cacheKey = '${code}_$text';
      if (!_loadingKeys.contains(cacheKey) && !_failedRecently(cacheKey)) {
        _loadingKeys.add(cacheKey);
        _translateAndCache(code: code, key: text);
      }
    }
  }

  String translate({required String code, required String key}) {
    // English returns the key as-is (source text)
    if (code == 'en') return key;
    
    // Check memory cache first
    final current = _memoryCache[code];
    if (current != null && current.containsKey(key)) {
      return current[key] ?? key;
    }

    // If not loading already, start translation
    final cacheKey = '${code}_$key';
    if (!_loadingKeys.contains(cacheKey)) {
      _loadingKeys.add(cacheKey);
      // Start translation in background
      _translateAndCache(code: code, key: key);
    }

    // Return English (source) while translating
    return key;
  }

  Future<void> _translateAndCache({required String code, required String key}) async {
    try {
      String? translatedText;

      // 1) Try LibreTranslate mirrors
      translatedText = await _translateViaLibreMirrors(key: key, targetCode: code);

      // 2) Fallback to MyMemory (free, no key)
      translatedText ??= await _translateViaMyMemory(key: key, targetCode: code);

      if (translatedText != null && translatedText.isNotEmpty && translatedText != key) {
        final map = _memoryCache.putIfAbsent(code, () => {});
        map[key] = translatedText;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('translations_$code', jsonEncode(map));

        notifyListeners();
      } else {
        _markFailed('${code}_$key');
      }
    } catch (e) {
      _markFailed('${code}_$key');
    } finally {
      _loadingKeys.remove('${code}_$key');
    }
  }

  Future<String?> _translateViaLibreMirrors({required String key, required String targetCode}) async {
    for (final base in _libreEndpoints) {
      try {
        final uri = Uri.parse(base);
        final resp = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'q': key,
                'source': 'en',
                'target': targetCode,
                'format': 'text',
              }),
            )
            .timeout(const Duration(seconds: 10));
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body) as Map<String, dynamic>;
          final text = data['translatedText']?.toString();
          if (text != null && text.isNotEmpty) return text;
        }
      } catch (_) {
        // try next mirror
      }
    }
    return null;
  }

  Future<String?> _translateViaMyMemory({required String key, required String targetCode}) async {
    try {
      final uri = Uri.parse('https://api.mymemory.translated.net/get?q=' + Uri.encodeQueryComponent(key) + '&langpair=en|' + Uri.encodeQueryComponent(targetCode));
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final responseData = data['responseData'] as Map<String, dynamic>?;
        final text = responseData?['translatedText']?.toString();
        if (text != null && text.isNotEmpty) return text;
      }
    } catch (_) {}
    return null;
  }

  // simple failure memory to avoid repeated retries when offline
  final Map<String, DateTime> _recentFailures = {};
  void _markFailed(String cacheKey) {
    _recentFailures[cacheKey] = DateTime.now();
  }
  bool _failedRecently(String cacheKey) {
    final ts = _recentFailures[cacheKey];
    if (ts == null) return false;
    return DateTime.now().difference(ts) < const Duration(minutes: 2);
  }
}

class LanguageSelectionScreen extends StatefulWidget {
  final Future<void> Function(Locale locale) onAccept;
  const LanguageSelectionScreen({super.key, required this.onAccept});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selected = 'en';
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: isTablet ? 24 : 18, 
                    child: Icon(
                      Icons.eco,
                      size: isTablet ? 28 : 24,
                    )
                  ),
                  SizedBox(width: isTablet ? 12 : 8),
                  Text(
                    stringsOf(context).t('Namaste!'), 
                    style: TextStyle(
                      fontSize: isTablet ? 32 : 28, 
                      fontWeight: FontWeight.w800
                    )
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 8 : 6),
              Text(
                stringsOf(context).t('Select your Plantix language'), 
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16, 
                  color: Colors.black54
                )
              ),
              SizedBox(height: isTablet ? 20 : 16),
              _langTile('mr', stringsOf(context).t('मराठी'), stringsOf(context).t('स्वत:च्या भाषेत शेती')),
              _langTile('hi', stringsOf(context).t('हिन्दी'), stringsOf(context).t('खेती आपकी भाषा में')),
              _langTile('en', stringsOf(context).t('English'), stringsOf(context).t('Farming in your language')),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => widget.onAccept(Locale(_selected)),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                  ),
                  child: Text(
                    stringsOf(context).t('Accept'),
                    style: TextStyle(fontSize: isTablet ? 16 : 14),
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 12 : 8),
              Wrap(
                children: [
                  Text(
                    stringsOf(context).t('I read and accept the '),
                    style: TextStyle(fontSize: isTablet ? 15 : 14),
                  ),
                  Text(
                    stringsOf(context).t('terms of use'), 
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: isTablet ? 15 : 14,
                    )
                  ),
                  Text(
                    stringsOf(context).t(' and the '),
                    style: TextStyle(fontSize: isTablet ? 15 : 14),
                  ),
                  Text(
                    stringsOf(context).t('privacy policy'), 
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: isTablet ? 15 : 14,
                    )
                  ),
                  Text(
                    stringsOf(context).t('.'),
                    style: TextStyle(fontSize: isTablet ? 15 : 14),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 16 : 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _langTile(String code, String title, String subtitle) {
    final selected = _selected == code;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: isTablet ? 8 : 6),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE8EEFF) : Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
        border: Border.all(
          color: selected ? const Color(0xFF0D5EF9) : Colors.grey.shade300, 
          width: selected ? (isDesktop ? 3 : 2) : 1
        ),
      ),
      child: ListTile(
        title: Text(
          title, 
          style: TextStyle(
            fontSize: isDesktop ? 26 : (isTablet ? 24 : 22), 
            fontWeight: FontWeight.w700
          )
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: isTablet ? 15 : 14),
        ),
        trailing: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off, 
          color: const Color(0xFF0D5EF9),
          size: isTablet ? 28 : 24,
        ),
        onTap: () => setState(() => _selected = code),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 12 : 8,
        ),
      ),
    );
  }
}

class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CommunityScreen(),
    ChatbotScreen(),
    MarketScreen(),
    ProfileScreen(),
  ];


  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;
    
    final destinations = [
      NavigationDestination(icon: const Icon(Icons.spa_outlined), selectedIcon: const Icon(Icons.spa), label: s.t('tab_crops')),
      NavigationDestination(icon: const Icon(Icons.chat_bubble_outline), selectedIcon: const Icon(Icons.chat_bubble), label: s.t('tab_community')),
      NavigationDestination(icon: const Icon(Icons.smart_toy_outlined), selectedIcon: const Icon(Icons.smart_toy), label: 'AI Assistant'),
      NavigationDestination(icon: const Icon(Icons.storefront_outlined), selectedIcon: const Icon(Icons.storefront), label: s.t('tab_market')),
      NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: s.t('tab_you')),
    ];

    // For desktop, show navigation rail instead of bottom navigation
    if (isDesktop) {
      return Scaffold(
        appBar: AppBar(
          title: Text(s.t('app_title')),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'auth':
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
                    break;
                  case 'add_farmer':
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddFarmerScreen()));
                    break;
                  case 'add_crop':
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddCropScreen()));
                    break;
                  case 'new_post':
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => NewPostScreen()));
                    break;
                  case 'signout':
                    if (AuthService.instance.currentUser != null) {
                      await AuthService.instance.signOut();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed out')));
                    }
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'auth', child: Text('Sign in / Sign up')),
                const PopupMenuItem(value: 'add_farmer', child: Text('Add Farmer')),
                const PopupMenuItem(value: 'add_crop', child: Text('Add Crop')),
                const PopupMenuItem(value: 'new_post', child: Text('New Post')),
                PopupMenuItem(
                  value: 'signout',
                  child: Text(AuthService.instance.currentUser == null ? 'Not signed in' : 'Sign out'),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Row(
          children: [
            NavigationRail(
              extended: true,
              minExtendedWidth: 200,
              destinations: destinations.map((dest) => NavigationRailDestination(
                icon: dest.icon,
                selectedIcon: dest.selectedIcon,
                label: Text(dest.label),
              )).toList(),
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) => setState(() => _currentIndex = i),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: _screens[_currentIndex]),
          ],
        ),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton.extended(
                onPressed: () => _showCameraDialog(context),
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(s.t('take_picture')),
                backgroundColor: const Color(0xFF0D5EF9),
                foregroundColor: Colors.white,
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }

    // For mobile and tablet, use bottom navigation
    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('app_title')),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'auth':
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
                  break;
                case 'add_farmer':
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddFarmerScreen()));
                  break;
                case 'add_crop':
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddCropScreen()));
                  break;
                case 'new_post':
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => NewPostScreen()));
                  break;
                case 'signout':
                  if (AuthService.instance.currentUser != null) {
                    await AuthService.instance.signOut();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed out')));
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'auth', child: Text('Sign in / Sign up')),
              const PopupMenuItem(value: 'add_farmer', child: Text('Add Farmer')),
              const PopupMenuItem(value: 'add_crop', child: Text('Add Crop')),
              const PopupMenuItem(value: 'new_post', child: Text('New Post')),
              PopupMenuItem(
                value: 'signout',
                child: Text(AuthService.instance.currentUser == null ? 'Not signed in' : 'Sign out'),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: destinations,
        height: isTablet ? 80 : 72,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showCameraDialog(context),
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(s.t('take_picture')),
              backgroundColor: const Color(0xFF0D5EF9),
              foregroundColor: Colors.white,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showCameraDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF0D5EF9)),
                title: Text(stringsOf(context).t('Camera')),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _openCamera(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF0D5EF9)),
                title: Text(stringsOf(context).t('Gallery')),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _openGallery(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: Text(stringsOf(context).t('Cancel')),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openCamera(BuildContext context) async {
    try {
      print('🔵 Requesting camera permission for disease detection...');
      final cameraStatus = await Permission.camera.request();
      
      if (!cameraStatus.isGranted) {
        print('❌ Camera permission denied');
        if (context.mounted) {
          _showSnackBar(context, 'Camera permission is required');
        }
        return;
      }

      print('✅ Camera permission granted, opening camera...');
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (photo != null && context.mounted) {
        print('✅ Photo captured: ${photo.path}');
        _showSnackBar(context, '📸 Photo captured! Disease detection coming soon...');
        // TODO: Implement disease detection with the captured image
        // You can process photo.path here
      } else {
        print('ℹ️ Camera cancelled by user');
      }
    } catch (e) {
      print('❌ Error opening camera: $e');
      if (context.mounted) {
        _showSnackBar(context, 'Error: $e');
      }
    }
  }

  Future<void> _openGallery(BuildContext context) async {
    try {
      print('🔵 Requesting storage permission for disease detection...');
      final storageStatus = await Permission.photos.request();
      
      if (!storageStatus.isGranted && !storageStatus.isLimited) {
        // Try storage permission as fallback
        final fallbackStatus = await Permission.storage.request();
        if (!fallbackStatus.isGranted) {
          print('❌ Storage permission denied');
          if (context.mounted) {
            _showSnackBar(context, 'Storage permission is required');
          }
          return;
        }
      }

      print('✅ Storage permission granted, opening gallery...');
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null && context.mounted) {
        print('✅ Image selected: ${image.path}');
        _showSnackBar(context, '🖼️ Image selected! Disease detection coming soon...');
        // TODO: Implement disease detection with the selected image
        // You can process image.path here
      } else {
        print('ℹ️ Gallery cancelled by user');
      }
    } catch (e) {
      print('❌ Error opening gallery: $e');
      if (context.mounted) {
        _showSnackBar(context, 'Error: $e');
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;
    
    if (isDesktop) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
              children: [
                _CropChipsRow(),
                const SizedBox(height: 20),
                _WeatherAndTaskCards(),
                const SizedBox(height: 24),
                Text(s.t('heal_your_crop'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                _HealYourCropCard(),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  left: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.t('Quick Stats'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _QuickStatsCard(),
                ],
              ),
            ),
          ),
        ],
      );
    }
    
    return ListView(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 24 : 16, 
        isTablet ? 12 : 8, 
        isTablet ? 24 : 16, 
        100
      ),
      children: [
        _CropChipsRow(),
        SizedBox(height: isTablet ? 16 : 12),
        _WeatherAndTaskCards(),
        SizedBox(height: isTablet ? 20 : 16),
        Text(
          s.t('heal_your_crop'), 
          style: TextStyle(
            fontSize: isTablet ? 22 : 20, 
            fontWeight: FontWeight.w700
          )
        ),
        SizedBox(height: isTablet ? 16 : 12),
        _HealYourCropCard(),
        SizedBox(height: isTablet ? 20 : 16),
        Text(s.t('sponsored'), style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 120),
      ],
    );
  }
}

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;
    
    if (isDesktop) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: s.t('search_community'),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 20),
                                 Wrap(
                   spacing: 12,
                   runSpacing: 12,
                   children: [
                     _FilterChip(label: s.t('Wheat'), emoji: '🌾'),
                     _FilterChip(label: s.t('Rice'), emoji: '🍚'),
                     _FilterChip(label: s.t('Cotton'), emoji: '🧶'),
                     _FilterChip(label: s.t('Sugarcane'), emoji: '🎋'),
                     _FilterChip(label: s.t('Tomato'), emoji: '🍅'),
                     _FilterChip(label: s.t('Onion'), emoji: '🧅'),
                     _FilterChip(label: s.t('Brinjal'), emoji: '🍆'),
                     _FilterChip(label: s.t('Cucumber'), emoji: '🥒'),
                   ],
                 ),
                const SizedBox(height: 20),
                _PostCard(
                  title: s.t('Share desease details'),
                  subtitle: s.t('Share solutions'),
                  imageColor: Colors.greenAccent,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  left: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.t('Trending Topics'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _TrendingTopics(),
                ],
              ),
            ),
          ),
        ],
      );
    }
    
    return ListView(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 24 : 16, 
        isTablet ? 12 : 8, 
        isTablet ? 24 : 16, 
        16
      ),
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: s.t('search_community'),
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
            isDense: true,
          ),
        ),
        SizedBox(height: isTablet ? 16 : 12),
                 Wrap(
           spacing: isTablet ? 12 : 8,
           runSpacing: isTablet ? 12 : 8,
           children: [
             _FilterChip(label: s.t('Wheat'), emoji: '🌾'),
             _FilterChip(label: s.t('Rice'), emoji: '🍚'),
             _FilterChip(label: s.t('Cotton'), emoji: '🧶'),
             _FilterChip(label: s.t('Sugarcane'), emoji: '🎋'),
             _FilterChip(label: s.t('Tomato'), emoji: '🍅'),
             _FilterChip(label: s.t('Onion'), emoji: '🧅'),
             _FilterChip(label: s.t('Brinjal'), emoji: '🍆'),
             _FilterChip(label: s.t('Cucumber'), emoji: '🥒'),
           ],
         ),
        SizedBox(height: isTablet ? 16 : 12),
        _PostCard(
          title: s.t('Share desease details'),
          subtitle: s.t('Share solutions'),
          imageColor: Colors.greenAccent,
        ),
      ],
    );
  }
}

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> with TickerProviderStateMixin {
  // Tab count must match the number of tabs provided below (6 tabs).
  late final TabController _tabController = TabController(length: 5, vsync: this);

  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;
    
    if (isDesktop) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: s.t('search_market'),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _CategoriesRow(),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: [
                    Tab(text: s.t('Pesticides')),
                    Tab(text: s.t('Fertilizers')),
                    Tab(text: s.t('Seeds')),
                    Tab(text: s.t('Organic Crop Nutrition')),
                    Tab(text: s.t('Cattle Feed')),
                    Tab(text: s.t('Tools and Machinery')),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: List.generate(6, (index) => _ProductsGrid()),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  left: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.t('Recent Searches'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _RecentSearches(),
                ],
              ),
            ),
          ),
        ],
      );
    }
    
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            isTablet ? 24 : 16, 
            isTablet ? 12 : 8, 
            isTablet ? 24 : 16, 
            0
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: s.t('search_market'),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              isDense: true,
            ),
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8),
        _CategoriesRow(),
        SizedBox(height: isTablet ? 12 : 8),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: s.t('Pesticides')),
            Tab(text: s.t('Fertilizers')),
            Tab(text: s.t('Seeds')),
            Tab(text: s.t('Organic Crop Nutrition')),
            Tab(text: s.t('Cattle Feed')),
            Tab(text: s.t('Tools and Machinery')),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: List.generate(10, (index) => _ProductsGrid()),
          ),
        ),
      ],
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showSurvey = true;
  bool _showShare = true;
  bool _showFeedback = true;

  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    final user = AuthService.instance.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final padding = isTablet ? 24.0 : 16.0;
    
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.all(padding),
        children: [
          // Account Card
          _buildAccountCard(context, user, isTablet),
          SizedBox(height: isTablet ? 20 : 16),
          
          // AI Chatbot Card
          _buildChatbotCard(context, isTablet),
          SizedBox(height: isTablet ? 20 : 16),
          
          // Survey/Feedback Banner
          if (_showSurvey) ...[
            _buildSurveyBanner(context, isTablet),
            SizedBox(height: isTablet ? 20 : 16),
          ],
          
          // Share Card
          if (_showShare) ...[
            _buildShareCard(context, isTablet),
            SizedBox(height: isTablet ? 20 : 16),
          ],
          
          // Feedback Card
          if (_showFeedback) ...[
            _buildFeedbackCard(context, isTablet),
            SizedBox(height: isTablet ? 20 : 16),
          ],
          
          // Settings Options
          if (user != null) ...[
            _buildMenuTile(context, Icons.person_outline, 'Profile Settings', () {
              print('🔵 Profile Settings tapped!');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileSettingsScreen()),
              );
            }, isTablet),
            _buildMenuTile(context, Icons.notifications_outlined, 'Notifications', () {
              print('🔵 Notifications tapped!');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            }, isTablet),
            _buildMenuTile(context, Icons.language, 'Language', () {
              print('🔵 Language tapped!');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LanguageScreen()),
              );
            }, isTablet),
            _buildMenuTile(context, Icons.help_outline, 'Help & Support', () {
              print('🔵 Help & Support tapped!');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
              );
            }, isTablet),
            _buildMenuTile(context, Icons.privacy_tip_outlined, 'Privacy Policy', () {
              print('🔵 Privacy Policy tapped!');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
              );
            }, isTablet),
            SizedBox(height: isTablet ? 20 : 16),
            _buildSignOutButton(context, isTablet),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, User? user, bool isTablet) {
    final avatarSize = isTablet ? 100.0 : 80.0;
    final titleSize = isTablet ? 20.0 : 18.0;
    final subtitleSize = isTablet ? 16.0 : 14.0;
    
    if (user == null) {
      return Container(
        padding: EdgeInsets.all(isTablet ? 24 : 20),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        ),
        child: Row(
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
              ),
              child: Icon(Icons.person, size: isTablet ? 50 : 40, color: Colors.orange.shade700),
            ),
            SizedBox(width: isTablet ? 20 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your account',
                    style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: isTablet ? 6 : 4),
                  Text(
                    'Join GrapeMaster Community',
                    style: TextStyle(fontSize: subtitleSize, color: Colors.black54),
                  ),
                  SizedBox(height: isTablet ? 16 : 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AuthScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                        side: const BorderSide(color: Color(0xFF0D5EF9), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0D5EF9),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final displayName = user.displayName ?? user.email?.split('@').first ?? 'User';
    final initials = displayName.length >= 2
        ? displayName.substring(0, 2).toUpperCase()
        : displayName.substring(0, 1).toUpperCase();

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isTablet ? 50 : 40,
            backgroundColor: const Color(0xFF0D5EF9),
            child: Text(
              initials,
              style: TextStyle(
                fontSize: isTablet ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Text(
                  user.email ?? '',
                  style: TextStyle(fontSize: subtitleSize, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatbotCard(BuildContext context, bool isTablet) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatbotScreen()),
        );
      },
      child: Container(
        padding: EdgeInsets.all(isTablet ? 24 : 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF0D5EF9), Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D5EF9).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              ),
              child: Icon(Icons.smart_toy, size: isTablet ? 48 : 40, color: Colors.white),
            ),
            SizedBox(width: isTablet ? 20 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Farming Assistant',
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isTablet ? 6 : 4),
                  Text(
                    'Get instant answers to all your grape farming questions!',
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 13,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: isTablet ? 24 : 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSurveyBanner(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            ),
            child: Icon(Icons.agriculture, size: isTablet ? 48 : 40, color: Colors.green.shade700),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Help us make a better app for your farming needs.',
                  style: TextStyle(fontSize: isTablet ? 16 : 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: isTablet ? 16 : 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D5EF9),
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32 : 24,
                      vertical: isTablet ? 16 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Take a survey',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            iconSize: isTablet ? 28 : 24,
            onPressed: () {
              // If user closes the survey banner, also hide related promo cards
              // (share and feedback) so the profile area is cleaned up as requested.
              setState(() {
                _showSurvey = false;
                _showShare = false;
                _showFeedback = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShareCard(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.eco, size: isTablet ? 36 : 32, color: Colors.green.shade700),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grow smart together!',
                  style: TextStyle(fontSize: isTablet ? 18 : 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Text(
                  'Share GrapeMaster and help farmers solve their grape problems.',
                  style: TextStyle(fontSize: isTablet ? 15 : 13, color: Colors.black54),
                ),
                SizedBox(height: isTablet ? 10 : 8),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Share GrapeMaster',
                    style: TextStyle(
                      color: const Color(0xFF0D5EF9),
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.star_outline, size: isTablet ? 36 : 32, color: Colors.blue.shade700),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How is your experience with GrapeMaster app?',
                  style: TextStyle(fontSize: isTablet ? 18 : 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Text(
                  'We\'d love to hear your thoughts and suggestions.',
                  style: TextStyle(fontSize: isTablet ? 15 : 13, color: Colors.black54),
                ),
                SizedBox(height: isTablet ? 10 : 8),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Give Feedback',
                    style: TextStyle(
                      color: const Color(0xFF0D5EF9),
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, IconData icon, String title, VoidCallback onTap, bool isTablet) {
    print('🟢 Building menu tile: $title');
    return ListTile(
      leading: Icon(icon, color: Colors.black87, size: isTablet ? 28 : 24),
      title: Text(title, style: TextStyle(fontSize: isTablet ? 18 : 16)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey, size: isTablet ? 28 : 24),
      onTap: () {
        print('🔴 Menu tile tapped: $title');
        onTap();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 8 : 4,
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
      child: OutlinedButton(
        onPressed: () async {
          await AuthService.instance.signOut();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Signed out successfully')),
            );
          }
        },
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: isTablet ? 18 : 14),
          side: BorderSide(color: Colors.red.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.red.shade700, size: isTablet ? 24 : 20),
            SizedBox(width: isTablet ? 10 : 8),
            Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: isTablet ? 18 : 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileProfileLayout extends StatelessWidget {
  final AppStrings s;
  const _MobileProfileLayout({required this.s});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ProfileHeader(s: s),
        const SizedBox(height: 24),
        _ProfileStats(s: s),
        const SizedBox(height: 24),
        _ProfileMenuItems(s: s),
        const SizedBox(height: 24),
        _ProfileActions(s: s),
      ],
    );
  }
}

class _TabletProfileLayout extends StatelessWidget {
  final AppStrings s;
  const _TabletProfileLayout({required this.s});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                right: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              children: [
                _ProfileHeader(s: s),
                const SizedBox(height: 32),
                _ProfileStats(s: s),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _ProfileMenuItems(s: s),
              const SizedBox(height: 32),
              _ProfileActions(s: s),
            ],
          ),
        ),
      ],
    );
  }
}

class _DesktopProfileLayout extends StatelessWidget {
  final AppStrings s;
  const _DesktopProfileLayout({required this.s});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                right: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              children: [
                _ProfileHeader(s: s),
                const SizedBox(height: 40),
                _ProfileStats(s: s),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.t('Profile Settings'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                _ProfileMenuItems(s: s),
                const SizedBox(height: 40),
                _ProfileActions(s: s),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.t('Quick Actions'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _QuickActions(s: s),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final AppStrings s;
  const _ProfileHeader({required this.s});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final displayName = user?.displayName ?? user?.email?.split('@').first ?? 'User';
    final email = user?.email ?? 'Not signed in';
    final initials = displayName.length >= 2 
        ? displayName.substring(0, 2).toUpperCase() 
        : displayName.substring(0, 1).toUpperCase();
    
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: const Color(0xFF0D5EF9),
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          email,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
           ),
         ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0D5EF9).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF0D5EF9).withOpacity(0.3),
            ),
          ),
          child: Text(
            s.t('Premium Member'),
            style: const TextStyle(
              color: Color(0xFF0D5EF9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileStats extends StatelessWidget {
  final AppStrings s;
  const _ProfileStats({required this.s});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
                 _StatItem(
           icon: Icons.eco,
           value: '8',
           label: s.t('Active Crops'),
         ),
         _StatItem(
           icon: Icons.calendar_today,
           value: '245',
           label: s.t('Days Active'),
         ),
         _StatItem(
           icon: Icons.star,
           value: '4.9',
           label: s.t('Rating'),
         ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0D5EF9).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF0D5EF9),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ProfileMenuItems extends StatelessWidget {
  final AppStrings s;
  const _ProfileMenuItems({required this.s});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _MenuItem(
        icon: Icons.person_outline,
        title: s.t('Personal Information'),
        subtitle: s.t('Update your profile details'),
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        title: s.t('Notifications'),
        subtitle: s.t('Manage notification preferences'),
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.security_outlined,
        title: s.t('Privacy & Security'),
        subtitle: s.t('Control your privacy settings'),
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.language_outlined,
        title: s.t('Language'),
        subtitle: s.t('Change app language'),
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.help_outline,
        title: s.t('Help & Support'),
        subtitle: s.t('Get help and contact support'),
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.info_outline,
        title: s.t('About'),
        subtitle: s.t('App version and information'),
        onTap: () {},
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.t('Settings'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...menuItems.map((item) => item),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF0D5EF9).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF0D5EF9),
          size: 20,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}

class _ProfileActions extends StatelessWidget {
  final AppStrings s;
  const _ProfileActions({required this.s});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.t('Account Actions'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.red.shade300),
            ),
            child: Text(
              s.t('Sign Out'),
              style: TextStyle(
                color: Colors.red.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {},
            child: Text(
              s.t('Delete Account'),
              style: TextStyle(
                color: Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  final AppStrings s;
  const _QuickActions({required this.s});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickActionItem(
        icon: Icons.camera_alt_outlined,
        title: s.t('Take Photo'),
        onTap: () {},
      ),
      _QuickActionItem(
        icon: Icons.history,
        title: s.t('History'),
        onTap: () {},
      ),
      _QuickActionItem(
        icon: Icons.favorite_outline,
        title: s.t('Favorites'),
        onTap: () {},
      ),
      _QuickActionItem(
        icon: Icons.share_outlined,
        title: s.t('Share App'),
        onTap: () {},
      ),
    ];

    return Column(
      children: actions.map((action) => action).toList(),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF0D5EF9).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF0D5EF9),
          size: 20,
        ),
      ),
      title: Text(title),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}

class _QuickStatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    return _RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D5EF9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Color(0xFF0D5EF9),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                s.t('Weekly Summary'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
                     _StatRow(label: s.t('Photos Taken'), value: '156', icon: Icons.camera_alt),
           _StatRow(label: s.t('Diseases Detected'), value: '12', icon: Icons.bug_report),
           _StatRow(label: s.t('Solutions Applied'), value: '8', icon: Icons.check_circle),
           _StatRow(label: s.t('Crops Monitored'), value: '8', icon: Icons.eco),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CropChipsRow extends StatefulWidget {
  @override
  State<_CropChipsRow> createState() => _CropChipsRowState();
}

class _CropChipsRowState extends State<_CropChipsRow> {
  static const Map<String, String> _cropEmojis = {
    'Tomato': '🍅',
    'Onion': '🧅',
    'Brinjal': '🍆',
    'Cucumber': '🥒',
    'Wheat': '🌾',
    'Rice': '🍚',
    'Cotton': '🧶',
    'Pumpkin': '🎃',
    'Mango': '🥭',
    'Grapes': '🍇',
    'Potato': '🥔',
    'Carrot': '🥕',
  };

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: isTablet ? 4 : 0, bottom: 12),
          child: Text(
            'Your Crops',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        SizedBox(
          height: isDesktop ? 140 : (isTablet ? 120 : 110),
          child: user == null
              ? Center(child: Text('Please login to see your crops'))
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('quickCrops')
                      .orderBy('addedAt', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final cropDocs = snapshot.data?.docs ?? [];
                    final totalItems = cropDocs.length + 1; // +1 for Add button
                    
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, i) {
                        // Add button at the end
                        if (i == cropDocs.length) {
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () => _showAddCropDialog(context),
                                child: Container(
                                  width: isDesktop ? 80 : (isTablet ? 70 : 60),
                                  height: isDesktop ? 80 : (isTablet ? 70 : 60),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '+',
                                      style: TextStyle(fontSize: isDesktop ? 36 : (isTablet ? 32 : 28)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add Crop',
                                style: TextStyle(
                                  fontSize: isTablet ? 14 : 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          );
                        }
                        
                        // Existing crops from Firestore
                        final cropDoc = cropDocs[i];
                        final crop = cropDoc.data() as Map<String, dynamic>;
                        crop['id'] = cropDoc.id;
                        
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () => _showCropDetails(context, crop),
                              child: Container(
                                width: isDesktop ? 80 : (isTablet ? 70 : 60),
                                height: isDesktop ? 80 : (isTablet ? 70 : 60),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(crop['status'] ?? 'Healthy'),
                                  borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
                                  border: Border.all(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    crop['emoji'] ?? '🌱',
                                    style: TextStyle(fontSize: isDesktop ? 36 : (isTablet ? 32 : 28)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              crop['name'] ?? '',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              crop['status'] ?? 'Healthy',
                              style: TextStyle(
                                fontSize: isTablet ? 12 : 10,
                                color: _getStatusTextColor(crop['status'] ?? 'Healthy'),
                              ),
                            ),
                            Text(
                              crop['area'] ?? '0 acre',
                              style: TextStyle(
                                fontSize: isTablet ? 10 : 8,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (context, i) => SizedBox(width: isTablet ? 16 : 12),
                      itemCount: totalItems,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Healthy':
        return Colors.green.shade100;
      case 'Disease Detected':
        return Colors.red.shade100;
      case 'Needs Care':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Healthy':
        return Colors.green.shade700;
      case 'Disease Detected':
        return Colors.red.shade700;
      case 'Needs Care':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  void _showAddCropDialog(BuildContext context) {
    final nameController = TextEditingController();
    final varietyController = TextEditingController();
    final areaController = TextEditingController();
    final plantingDateController = TextEditingController();
    String? selectedCrop;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Crop'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedCrop,
                      decoration: const InputDecoration(
                        labelText: 'Select Crop',
                        border: OutlineInputBorder(),
                      ),
                      items: _cropEmojis.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Row(
                            children: [
                              Text(entry.value, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(entry.key),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCrop = value;
                          nameController.text = value ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: varietyController,
                      decoration: const InputDecoration(
                        labelText: 'Variety',
                        hintText: 'e.g., HD-2967, PBW-343, Basmati',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: areaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Area (in acres)',
                        hintText: 'e.g., 2.5',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: plantingDateController,
                      decoration: const InputDecoration(
                        labelText: 'Planting Date',
                        hintText: 'e.g., 15 Nov 2024',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (selectedCrop == null || selectedCrop!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a crop')),
                      );
                      return;
                    }
                    
                    if (varietyController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter variety')),
                      );
                      return;
                    }

                    if (areaController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter area')),
                      );
                      return;
                    }

                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('quickCrops')
                          .add({
                            'name': selectedCrop,
                            'emoji': _cropEmojis[selectedCrop],
                            'status': 'Healthy',
                            'area': '${areaController.text} acre',
                            'variety': varietyController.text,
                            'plantingDate': plantingDateController.text.isEmpty 
                              ? DateTime.now().toString().split(' ')[0]
                              : plantingDateController.text,
                            'color': 'green',
                            'addedAt': FieldValue.serverTimestamp(),
                          });
                        
                        Navigator.of(dialogContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Crop added successfully!')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCropDetails(BuildContext context, Map<String, dynamic> crop) {
    // Directly navigate to CropDetailsScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CropDetailsScreen(
          crop: {
            'id': crop['id'] ?? 'temp_${crop['name']}',
            'name': crop['name'] ?? '',
            'emoji': crop['emoji'] ?? '🌱',
            'status': crop['status'] ?? 'Healthy',
            'area': crop['area'] ?? '0 acre',
            'color': crop['color'] ?? '0xFF4CAF50',
            'variety': crop['variety'] ?? 'Local',
            'plantingDate': crop['plantingDate'] ?? DateTime.now().toString().split(' ')[0],
          },
        ),
      ),
    );
  }
}

class _WeatherAndTaskCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;
    
    if (isDesktop) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _RoundedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.wb_sunny, color: Colors.orange.shade600, size: 24),
                          const SizedBox(width: 8),
                          Text(s.todayLabel(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 8),
                                             Text('${s.t('clear')} • 32°C / 28°C', style: const TextStyle(fontSize: 16)),
                       const SizedBox(height: 8),
                       Text('Humidity: 75% • Wind: 8 km/h', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                       const SizedBox(height: 8),
                       Text('UV Index: High • Air Quality: Good', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                      const SizedBox(height: 16),
                      const _LocationAllowRow(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _RoundedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.schedule, color: Colors.blue.shade600, size: 24),
                          const SizedBox(width: 8),
                          Text('Today\'s Tasks', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 8),
                                             _TaskItem(icon: Icons.water_drop, task: 'Water wheat field', time: '6:00 AM', completed: true),
                       _TaskItem(icon: Icons.bug_report, task: 'Check for stem borer', time: '10:00 AM', completed: false),
                       _TaskItem(icon: Icons.eco, task: 'Apply NPK fertilizer', time: '4:00 PM', completed: false),
                       _TaskItem(icon: Icons.agriculture, task: 'Harvest ready crops', time: '7:00 AM', completed: false),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _RoundedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.wb_sunny, color: Colors.orange.shade600, size: isTablet ? 22 : 20),
                        SizedBox(width: isTablet ? 8 : 6),
                        Text(
                          s.todayLabel(), 
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: isTablet ? 16 : 14,
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${s.t('clear')} • 24°C / 20°C', style: TextStyle(fontSize: isTablet ? 15 : 14)),
                    const SizedBox(height: 8),
                    Text('Humidity: 65% • Wind: 12 km/h', style: TextStyle(fontSize: isTablet ? 13 : 12, color: Colors.grey.shade600)),
                    const SizedBox(height: 12),
                    const _LocationAllowRow(),
                  ],
                ),
              ),
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Expanded(
              child: _RoundedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, color: Colors.blue.shade600, size: isTablet ? 22 : 20),
                        SizedBox(width: isTablet ? 8 : 6),
                        Text(
                          'Tasks', 
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: isTablet ? 16 : 14,
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _TaskItem(icon: Icons.water_drop, task: 'Water tomatoes', time: '9:00 AM', completed: true),
                    _TaskItem(icon: Icons.bug_report, task: 'Check for pests', time: '2:00 PM', completed: false),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TaskItem extends StatelessWidget {
  final IconData icon;
  final String task;
  final String time;
  final bool completed;

  const _TaskItem({
    required this.icon,
    required this.task,
    required this.time,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: completed ? Colors.green.shade600 : Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task,
              style: TextStyle(
                fontSize: 14,
                decoration: completed ? TextDecoration.lineThrough : null,
                color: completed ? Colors.grey.shade600 : Colors.black87,
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationAllowRow extends StatelessWidget {
  const _LocationAllowRow();

  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined, 
            size: isTablet ? 22 : 18,
            color: Colors.amber.shade700,
          ),
          SizedBox(width: isTablet ? 12 : 8),
          Expanded(
            child: Text(
              s.t('location_perm'),
              style: TextStyle(
                fontSize: isTablet ? 15 : 14,
                color: Colors.amber.shade800,
              ),
            )
          ),
          Text(
            s.t('allow'), 
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: isTablet ? 15 : 14,
              color: Colors.amber.shade800,
            )
          ),
        ],
      ),
    );
  }
}

class _HealYourCropCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;
    
    return _RoundedCard(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 20 : 16, 
        isTablet ? 20 : 16, 
        isTablet ? 20 : 16, 
        isTablet ? 20 : 16
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Step(icon: Icons.camera_alt_outlined, label: s.t('Take a\npicture')),
              Icon(
                Icons.chevron_right,
                size: isTablet ? 28 : 24,
                color: Colors.grey.shade400,
              ),
              _Step(icon: Icons.receipt_long_outlined, label: s.t('See\ndiagnosis')),
              Icon(
                Icons.chevron_right,
                size: isTablet ? 28 : 24,
                color: Colors.grey.shade400,
              ),
              _Step(icon: Icons.medication_outlined, label: s.t('Get\nmedicine')),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DiseaseDetectionScreen(),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
              ),
              child: Text(
                s.t('take_picture'),
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _RoundedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const _RoundedCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;
    
    return Container(
      padding: padding ?? EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: const Color(0x11000000), 
            blurRadius: isDesktop ? 8 : 6, 
            offset: const Offset(0, 2)
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Step extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Step({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;
    
    return Column(
      children: [
        Container(
          width: isDesktop ? 56 : (isTablet ? 52 : 48),
          height: isDesktop ? 56 : (isTablet ? 52 : 48),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(isDesktop ? 12 : 10),
          ),
          child: Icon(
            icon, 
            color: const Color(0xFF0D5EF9),
            size: isDesktop ? 28 : (isTablet ? 26 : 24),
          ),
        ),
        SizedBox(height: isDesktop ? 12 : (isTablet ? 10 : 8)),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? 13 : (isTablet ? 12.5 : 12),
            height: 1.2,
          ),
        )
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String emoji;
  const _FilterChip({required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;
    
    return Chip(
      avatar: Text(
        emoji,
        style: TextStyle(fontSize: isTablet ? 18 : 16),
      ),
      label: Text(
        label,
        style: TextStyle(fontSize: isTablet ? 14 : 12),
      ),
      side: BorderSide(color: Colors.grey.shade300),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 24 : 20)
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : 8,
        vertical: isTablet ? 8 : 4,
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color imageColor;
  final String? author;
  final String? likes;
  final String? comments;
  final String? time;
  
  const _PostCard({
    required this.title, 
    required this.subtitle, 
    required this.imageColor,
    this.author,
    this.likes,
    this.comments,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;
    
    return _RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: isDesktop ? 200 : (isTablet ? 180 : 160), 
            decoration: BoxDecoration(
              color: imageColor, 
              borderRadius: BorderRadius.circular(isDesktop ? 16 : 12)
            )
          ),
          SizedBox(height: isTablet ? 16 : 12),
                     Row(
             children: [
               CircleAvatar(radius: isTablet ? 16 : 14),
               SizedBox(width: isTablet ? 12 : 8),
               Text(
                 author ?? stringsOf(context).t('Hari Shankar Shukla • India'),
                 style: TextStyle(fontSize: isTablet ? 15 : 14),
               ),
             ],
           ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            title, 
            style: TextStyle(
              fontWeight: FontWeight.w700, 
              fontSize: isTablet ? 18 : 16
            )
          ),
          SizedBox(height: isTablet ? 8 : 4),
          Text(
            subtitle, 
            style: TextStyle(
              color: Colors.black54,
              fontSize: isTablet ? 15 : 14,
            )
          ),
          SizedBox(height: isTablet ? 12 : 8),
                     Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Row(
                 children: [
                   Icon(Icons.thumb_up_outlined, size: 16, color: Colors.grey.shade600),
                   SizedBox(width: 4),
                   Text(
                     likes ?? '0',
                     style: TextStyle(
                       color: Colors.grey.shade600,
                       fontSize: isTablet ? 13 : 12,
                     ),
                   ),
                   SizedBox(width: 16),
                   Icon(Icons.comment_outlined, size: 16, color: Colors.grey.shade600),
                   SizedBox(width: 4),
                   Text(
                     comments ?? '0',
                     style: TextStyle(
                       color: Colors.grey.shade600,
                       fontSize: isTablet ? 13 : 12,
                     ),
                   ),
                 ],
               ),
               Text(
                 time ?? '2 hours ago',
                 style: TextStyle(
                   color: Colors.grey.shade600,
                   fontSize: isTablet ? 12 : 11,
                 ),
               ),
             ],
           )
        ],
      ),
    );
  }
}

class _CategoriesRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categories = [
      _Category(stringsOf(context).t('Pesticides'), Icons.bug_report_outlined),
      _Category(stringsOf(context).t('Fertilizers'), Icons.eco_outlined),
      _Category(stringsOf(context).t('Seeds'), Icons.spa_outlined),
      _Category(stringsOf(context).t('Organic Crop Protection'), Icons.shield_moon_outlined),
      _Category(stringsOf(context).t('Organic Crop Nutrition'), Icons.energy_savings_leaf_outlined),
      _Category(stringsOf(context).t('Cattle Feed'), Icons.set_meal_outlined),
      _Category(stringsOf(context).t('Tools and Machinery'), Icons.build_outlined),
    ];
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;
    
    return SizedBox(
      height: isDesktop ? 120 : (isTablet ? 112 : 104), // extra room for longer Hindi/Marathi labels
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) => _CategoryTile(cat: categories[i]),
        separatorBuilder: (_, __) => SizedBox(width: isTablet ? 16 : 12),
        itemCount: categories.length,
      ),
    );
  }
}

class _Category {
  final String title;
  final IconData icon;
  _Category(this.title, this.icon);
}

class _CategoryTile extends StatelessWidget {
  final _Category cat;
  const _CategoryTile({required this.cat});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;
    
    return Column(
      children: [
        Container(
          width: isDesktop ? 64 : (isTablet ? 60 : 56),
          height: isDesktop ? 64 : (isTablet ? 60 : 56),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
          ),
          child: Icon(
            cat.icon, 
            color: const Color(0xFF0D5EF9),
            size: isDesktop ? 28 : (isTablet ? 26 : 24),
          ),
        ),
        SizedBox(height: isDesktop ? 12 : 8),
        SizedBox(
          width: isDesktop ? 100 : (isTablet ? 92 : 84),
          child: Text(
            cat.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 13 : (isTablet ? 12.5 : 12), 
              height: 1.2
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;
    
    int crossAxisCount = 2;
    if (isDesktop) crossAxisCount = 4;
    else if (isTablet) crossAxisCount = 3;
    
    return GridView.builder(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: isTablet ? 16 : 12,
        crossAxisSpacing: isTablet ? 16 : 12,
        childAspectRatio: isDesktop ? 0.8 : 0.72,
      ),
      itemCount: 8,
      itemBuilder: (_, i) => _ProductCard(index: i),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final searches = [
      'Wheat rust treatment',
      'Rice blast disease',
      'Cotton bollworm control',
      'Sugarcane red rot',
      'Tomato blight',
      'Onion thrips',
      'Brinjal fruit borer',
      'Cucumber mosaic virus',
      'NPK fertilizer rates',
      'Organic pest control',
      'Soil testing kit',
      'Water management tips',
    ];
    
    return Column(
      children: searches.map((search) => ListTile(
        leading: const Icon(Icons.history, size: 20),
        title: Text(
          search,
          style: const TextStyle(fontSize: 14),
        ),
        onTap: () {},
        contentPadding: EdgeInsets.zero,
      )).toList(),
    );
  }
}

class _TrendingTopics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topics = [
      'Wheat rust treatment',
      'Rice blast disease',
      'Cotton bollworm control',
      'Sugarcane red rot',
      'Tomato blight',
      'Onion thrips',
      'Brinjal fruit borer',
      'Cucumber mosaic virus',
      'Soil testing methods',
      'Organic farming techniques',
      'Water conservation',
      'Crop rotation benefits',
    ];
    
    return Column(
      children: topics.map((topic) => ListTile(
        leading: const Icon(Icons.trending_up, size: 20, color: Colors.orange),
        title: Text(
          topic,
          style: const TextStyle(fontSize: 14),
        ),
        onTap: () {},
        contentPadding: EdgeInsets.zero,
      )).toList(),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final int index;
  const _ProductCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;
    
    final products = [
      {'name': 'Urea', 'brand': 'IFFCO', 'price': '₹300', 'size': '50 kg', 'type': 'Fertilizer'},
      {'name': 'DAP', 'brand': 'IFFCO', 'price': '₹1400', 'size': '50 kg', 'type': 'Fertilizer'},
      {'name': 'NPK', 'brand': 'IFFCO', 'price': '₹1200', 'size': '50 kg', 'type': 'Fertilizer'},
      {'name': 'Monocrotophos', 'brand': 'UPL', 'price': '₹450', 'size': '1 L', 'type': 'Pesticide'},
      {'name': 'Chlorpyrifos', 'brand': 'UPL', 'price': '₹380', 'size': '1 L', 'type': 'Pesticide'},
      {'name': 'Imidacloprid', 'brand': 'Bayer', 'price': '₹520', 'size': '1 L', 'type': 'Pesticide'},
      {'name': 'Wheat Seeds', 'brand': 'Nirmal Seeds', 'price': '₹2800', 'size': '25 kg', 'type': 'Seeds'},
      {'name': 'Rice Seeds', 'brand': 'Nirmal Seeds', 'price': '₹3200', 'size': '25 kg', 'type': 'Seeds'},
      {'name': 'Cotton Seeds', 'brand': 'Nirmal Seeds', 'price': '₹1800', 'size': '1 kg', 'type': 'Seeds'},
      {'name': 'Organic Manure', 'brand': 'Organic India', 'price': '₹150', 'size': '25 kg', 'type': 'Organic'},
    ];
    
    final product = products[index % products.length];
    
    return _RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _getProductColor(product['type']!),
                borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
              ),
              child: Center(
                child: Icon(
                  _getProductIcon(product['type']!),
                  size: isDesktop ? 48 : 40,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            product['name']!, 
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: isTablet ? 15 : 14,
            )
          ),
          Text(
            'by ${product['brand']!}', 
            style: TextStyle(
              color: Colors.black54,
              fontSize: isTablet ? 13 : 12,
            )
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            product['price']!, 
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: isTablet ? 16 : 14,
              color: const Color(0xFF0D5EF9),
            )
          ),
          Text(
            product['size']!, 
            style: TextStyle(
              color: Colors.black54,
              fontSize: isTablet ? 13 : 12,
            )
          ),
        ],
      ),
    );
  }
  
  Color _getProductColor(String type) {
    switch (type) {
      case 'Fertilizer':
        return Colors.blue.shade600;
      case 'Pesticide':
        return Colors.red.shade600;
      case 'Seeds':
        return Colors.green.shade600;
      case 'Organic':
        return Colors.orange.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
  
  IconData _getProductIcon(String type) {
    switch (type) {
      case 'Fertilizer':
        return Icons.eco;
      case 'Pesticide':
        return Icons.bug_report;
      case 'Seeds':
        return Icons.spa;
      case 'Organic':
        // `Icons.eco_friendly` may not be available in older Flutter SDKs.
        // Use `Icons.eco` which is widely available.
        return Icons.eco;
      default:
        return Icons.inventory;
    }
  }
}
