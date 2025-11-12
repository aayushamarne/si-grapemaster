import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
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
// Generated localizations (will be created by Flutter gen_l10n)
import 'package:grapemaster/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'src/services/weather_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase early so other services can use it
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Apply saved locale if present and pre-load translations
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString('selected_locale');
  if (code != null) {
    LocaleController.instance.setLocale(Locale(code));
  }
  await TranslationController.instance.ensureLoaded(LocaleController.instance.locale?.languageCode ?? 'en');

  runApp(const GrapemasterApp());
}

class GrapemasterApp extends StatefulWidget {
  const GrapemasterApp({super.key});

  @override
  State<GrapemasterApp> createState() => _GrapemasterAppState();
}

class _GrapemasterAppState extends State<GrapemasterApp> {
  bool _isReady = true; // initialization done in main()
  bool _needsLanguageSelection = LocaleController.instance.locale == null;

  final LocaleController _localeController = LocaleController.instance;
  final TranslationController _translationController = TranslationController.instance;

  Future<void> _onLanguageChosen(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_locale', locale.languageCode);
    _localeController.setLocale(locale);
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
            AppLocalizations.delegate,
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
    'Contact Support': 'Contact Support',
  'We\'re here to help you 24/7': 'We\'re here to help you 24/7',
  'Email Support': 'Email Support',
  'Call Us': 'Call Us',
  'Frequently Asked Questions': 'Frequently Asked Questions',
  'Quick Links': 'Quick Links',
  'User Guide': 'User Guide',
  'Video Tutorials': 'Video Tutorials',
  'Community Forum': 'Community Forum',
  'Report a Bug': 'Report a Bug',
  'GrapeMaster': 'GrapeMaster',
  'Version 1.0.0': 'Version 1.0.0',
             'app_title': 'GrapeMaster',
        'tab_crops': 'Your crops',
        'tab_ai': 'AI Assistant',
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
      'Choose your preferred language for the app': 'Choose your preferred language for the app',
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
  'Sign in / Sign up': 'Sign in / Sign up',
  'Not signed in': 'Not signed in',
  'New Post': 'New Post',
      'Delete Account': 'Delete Account',
      'Quick Actions': 'Quick Actions',
      'Take Photo': 'Take Photo',
      'History': 'History',
      'Favorites': 'Favorites',
      'Share App': 'Share App',
  'grow_smart_title': 'Grow smart together!',
  'grow_smart_desc': 'Share GrapeMaster and help farmers solve their grape problems.',
  'share_grapemaster': 'Share GrapeMaster',
  'feedback_title': 'How is your experience with GrapeMaster app?',
  'feedback_desc': 'We\'d love to hear your thoughts and suggestions.',
  'give_feedback': 'Give Feedback',
  'chat_welcome': 'Hello! 👋 I\'m GrapeMaster AI, your specialized farming assistant.\n\n🌾 I can help you with: • Grape farming & viticulture • Crop diseases & pest management • Irrigation & water management • Fertilizers & soil health • Weather-based farming advice • Agricultural techniques & best practices\n\n⚠️ Note: I only answer farming and agriculture-related questions. For other topics, please consult appropriate resources.\n\nHow can I help with your farming needs today?',
  'chat_welcome_nobrand': 'Hello! 👋 I\'m your specialized farming assistant.\n\n🌾 I can help you with: • Grape farming & viticulture • Crop diseases & pest management • Irrigation & water management • Fertilizers & soil health • Weather-based farming advice • Agricultural techniques & best practices\n\n⚠️ Note: I only answer farming and agriculture-related questions. For other topics, please consult appropriate resources.\n\nHow can I help with your farming needs today?',
  'chat_system_prompt': 'You are a specialized farming assistant focused ONLY on agriculture, farming, and crop cultivation topics. Provide expert, practical, and concise advice farmers can apply. If a question is not related to farming or agriculture, politely decline and ask the user to ask about crops, pests, irrigation, soil health, or other farming topics.',
  'chat_respond_in': 'Please respond in {lang}.',
  'Chat history': 'Chat history',
  'No saved chats': 'No saved chats',
  'Load history': 'Load history',
  'Clear saved history': 'Clear saved history',
  'Chat history cleared': 'Chat history cleared',
  'You': 'You',
  'Assistant': 'Assistant',
  'disease_powdery_mildew': 'Powdery Mildew',
  'disease_downy_mildew': 'Downy Mildew',
  'disease_black_rot': 'Black Rot',
  'disease_botrytis_bunch_rot': 'Botrytis (Grey Mold)',
  'disease_anthracnose': 'Anthracnose',
  'disease_leaf_spot': 'Leaf Spot',
  'disease_healthy': 'Healthy',
  'Plant Status': 'Plant Status',
  'Detected Disease': 'Detected Disease',
  'Confidence': 'Confidence',
  'Severity': 'Severity',
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
      'Contact Support': 'सहायता से संपर्क करें',
      'We\'re here to help you 24/7': 'हम 24/7 आपकी मदद के लिए यहां हैं',
      'Email Support': 'ईमेल सहायता',
      'Call Us': 'हमें कॉल करें',
      'Frequently Asked Questions': 'अक्सर पूछे जाने वाले प्रश्न',
      'Quick Links': 'त्वरित लिंक',
      'User Guide': 'उपयोगकर्ता गाइड',
      'Video Tutorials': 'वीडियो ट्यूटोरियल',
      'Community Forum': 'समुदाय मंच',
      'Report a Bug': 'बग रिपोर्ट करें',
      'GrapeMaster': 'GrapeMaster',
      'Version 1.0.0': 'संस्करण 1.0.0',
             'app_title': 'ग्रेपमास्टर',
        'tab_crops': 'आपकी फ़सलें',
        'tab_ai': 'एआई सहायक',
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
      'Choose your preferred language for the app': 'ऐप के लिए अपनी पसंदीदा भाषा चुनें',
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
  'Sign in / Sign up': 'साइन इन / साइन अप',
  'Not signed in': 'साइन इन नहीं हुआ',
  'New Post': 'नया पोस्ट',
      'Delete Account': 'खाता हटाएं',
      'Quick Actions': 'त्वरित कार्य',
      'Take Photo': 'फोटो लें',
      'History': 'इतिहास',
      'Favorites': 'पसंदीदा',
      'Share App': 'ऐप साझा करें',
  'grow_smart_title': 'साथ मिलकर स्मार्ट खेती करें!',
  'grow_smart_desc': 'GrapeMaster साझा करें और किसानो को उनके अंगूर की समस्याओं को हल करने में मदद करें।',
  'share_grapemaster': 'GrapeMaster साझा करें',
  'feedback_title': 'GrapeMaster ऐप के साथ आपका अनुभव कैसा है?',
  'feedback_desc': 'हम आपके विचारों और सुझावों को सुनना चाहेंगे।',
  'give_feedback': 'प्रतिक्रिया दें',
  'chat_welcome': 'Hello! 👋 मैं GrapeMaster AI हूं, आपका विशेष खेती सहायक।\n\n🌾 मैं आपकी मदद कर सकता हूं: • अंगूर की खेती और वाइनग्रेप • फसल रोग और कीट प्रबंधन • सिंचाई और जल प्रबंधन • उर्वरक और मिट्टी स्वास्थ्य • मौसम-आधारित खेती सलाह • कृषि तकनीक और सर्वोत्तम प्रथाएं\n\n⚠️ नोट: मैं केवल खेती और कृषि से संबंधित प्रश्नों के उत्तर देता/देती हूं। अन्य विषयों के लिए कृपया उपयुक्त संसाधनों की सलाह लें।\n\nमैं आज आपकी खेती में किस तरह मदद कर सकता/सकती हूं?',
  'chat_welcome_nobrand': 'नमस्ते! 👋 मैं आपका विशेष खेती सहायक हूँ।\n\n🌾 मैं आपकी मदद कर सकता हूं: • अंगूर की खेती और वाइनग्रेप • फसल रोग और कीट प्रबंधन • सिंचाई और जल प्रबंधन • उर्वरक और मिट्टी स्वास्थ्य • मौसम-आधारित खेती सलाह • कृषि तकनीक और सर्वोत्तम प्रथाएं\n\n⚠️ नोट: मैं केवल खेती और कृषि से संबंधित प्रश्नों के उत्तर देता/देती हूं। अन्य विषयों के लिए कृपया उपयुक्त संसाधनों की सलाह लें।\n\nमैं आज आपकी खेती में किस तरह मदद कर सकता/सकती हूं?',
  'chat_system_prompt': 'आप GrapeMaster AI हैं, एक विशेष खेती सहायक जो केवल कृषि, खेती और फसल उगाने से संबंधित विषयों पर केंद्रित है। किसानों को व्यावहारिक, संक्षिप्त और उपयोगी सलाह दें। यदि प्रश्न खेती या कृषि से संबंधित नहीं है, तो विनम्रता से इनकार करें और उपयोगकर्ता से कहें कि वे फसलों, कीट प्रबंधन, सिंचाई, मिट्टी स्वास्थ्य या अन्य कृषि विषयों के बारे में पूछें।',
  'chat_respond_in': 'कृपया {lang} में उत्तर दें।',
  'Chat history': 'चॅट इतिहास',
  'No saved chats': 'साठवलेली चॅट्स नाहीत',
  'Load history': 'इतिहास लोड करा',
  'Clear saved history': 'साठवलेला इतिहास साफ करा',
  'Chat history cleared': 'चॅट इतिहास साफ केला गेला',
  'You': 'तुम्ही',
  'Assistant': 'सहाय्यक',
    'Chat history': 'चैट इतिहास',
    'No saved chats': 'कोई सहेजी गई चैट नहीं',
    'Load history': 'इतिहास लोड करें',
    'Clear saved history': 'सहेजा गया इतिहास साफ़ करें',
    'Chat history cleared': 'चैट इतिहास साफ़ कर दिया गया',
    'You': 'आप',
    'Assistant': 'सहायक',
      'Active Crops': 'सक्रिय फसलें',
      'Days Active': 'सक्रिय दिन',
      'Rating': 'रेटिंग',
      'Premium Member': 'प्रीमियम सदस्य',
    },
    'mr': {
      'Contact Support': 'समर्थनाशी संपर्क साधा',
      'We\'re here to help you 24/7': 'आम्ही 24/7 आपल्या मदतीसाठी येथे आहोत',
      'Email Support': 'ईमेल समर्थन',
      'Call Us': 'आम्हाला कॉल करा',
      'Frequently Asked Questions': 'वारंवार विचारले जाणारे प्रश्न',
      'Quick Links': 'त्वरित दुवे',
      'User Guide': 'वापरकर्ता मार्गदर्शक',
      'Video Tutorials': 'व्हिडिओ ट्युटोरियल',
      'Community Forum': 'समुदाय फोरम',
      'Report a Bug': 'बग रिपोर्ट करा',
      'GrapeMaster': 'GrapeMaster',
      'Version 1.0.0': 'आवृत्ती 1.0.0',
             'app_title': 'ग्रेपमास्टर',
        'search_community': 'समुदायात शोधा',
        'tab_ai': 'एआय सहाय्यक',
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
        'Select your GrapeMaster language': 'आपली ग्रेपमास्टर भाषा निवडा',
      'Choose your preferred language for the app': 'अॅपसाठी आपली आवडती भाषा निवडा',
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
  'Sign in / Sign up': 'साइन इन / साइन अप',
  'Not signed in': 'साइन इन झाले नाही',
  'New Post': 'नवीन पोस्ट',
      'Delete Account': 'खाते हटवा',
      'Quick Actions': 'त्वरित कृती',
      'Take Photo': 'फोटो घ्या',
      'History': 'इतिहास',
      'Favorites': 'आवडी',
      'Share App': 'अॅप शेअर करा',
  'grow_smart_title': 'एकत्र स्मार्टपणे वाढवा!',
  'grow_smart_desc': 'GrapeMaster सामायिक करा आणि शेतकऱ्यांना त्यांच्या द्राक्ष समस्यांचे निराकरण करण्यात मदत करा.',
  'share_grapemaster': 'GrapeMaster शेअर करा',
  'feedback_title': 'GrapeMaster अॅपसह तुमचा अनुभव कसा आहे?',
  'feedback_desc': 'आम्हाला तुमच्या कल्पना आणि सुचना ऐकायला आवडतील.',
  'give_feedback': 'अभिप्राय द्या',
  'chat_welcome_nobrand': 'नमस्कार! 👋 मी तुमचा विशेष शेती सहाय्यक आहे.\n\n🌾 मी तुमची मदत करू शकतो: • द्राक्ष लागवड व विटीकल्चर • पीक आजार व किड नियंत्रण • सिंचन व पाणी व्यवस्थापन • खत व मातीची आरोग्य • हवामान-आधारित शेती सल्ला • कृषी तंत्र आणि सर्वोत्तम पद्धती\n\n⚠️ लक्षात घ्या: मी फक्त शेती आणि कृषी-संबंधित प्रश्नांना उत्तर देतो/देते. इतर विषयांसाठी कृपया योग्य स्रोतांचा सल्ला घ्या.\n\nआज मी तुमच्या शेतीसाठी कशी मदत करू?',
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
  'GrapeMaster',
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
  'Select your GrapeMaster language',
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
                stringsOf(context).t('Select your GrapeMaster language'), 
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

  // Keep persistent screen instances so switching tabs doesn't recreate
  // widgets unnecessarily (recreation can cause focus/IME issues on some devices).
  final List<Widget> _screens = [
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
  NavigationDestination(icon: const Icon(Icons.smart_toy_outlined), selectedIcon: const Icon(Icons.smart_toy), label: s.t('tab_ai')),
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
                PopupMenuItem(value: 'auth', child: Text(stringsOf(context).t('Sign in / Sign up'))),
                PopupMenuItem(
                  value: 'signout',
                  child: Text(AuthService.instance.currentUser == null ? stringsOf(context).t('Not signed in') : stringsOf(context).t('Sign Out')),
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
                // Avoid Tooltip (which needs an Overlay) to prevent build-time errors
                tooltip: null,
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }

    // For mobile and tablet, use bottom navigation
    return Scaffold(
      // Hide the root app bar when the Assistant (chat) tab is active so the
      // ChatbotScreen can present its own full-screen UI (no three-dot menu).
      appBar: _currentIndex == 2
          ? null
          : AppBar(
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
                    PopupMenuItem(value: 'auth', child: Text(stringsOf(context).t('Sign in / Sign up'))),
                    PopupMenuItem(
                      value: 'signout',
                      child: Text(AuthService.instance.currentUser == null ? stringsOf(context).t('Not signed in') : stringsOf(context).t('Sign Out')),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),

  // Use the persistent screen instance. ChatbotScreen has its own clear
  // action (trash icon) to reset the visible chat, so rebuilding the
  // widget isn't necessary and can break IME behavior on some devices.
  body: _screens[_currentIndex],
      floatingActionButton: _currentIndex == 1 // Show FAB only on Community screen
          ? FloatingActionButton.extended(
              onPressed: () => CommunityScreen.createPost(context),
              icon: const Icon(Icons.add),
              label: Text(stringsOf(context).t('New Post')),
              backgroundColor: const Color(0xFF0D5EF9),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: destinations,
        height: isTablet ? 80 : 72,
      ),
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

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
  
  // Static method to create a post from outside the widget
  static Future<void> createPost(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to create a post')),
      );
      return;
    }

    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCrop = 'Grape';
  XFile? selectedImage;
  Uint8List? selectedImageBytes;
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              margin: const EdgeInsets.only(top: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Create New Post', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Crop Type', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedCrop,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Grape', child: Text('🍇 Grape')),
                          DropdownMenuItem(value: 'Wheat', child: Text('🌾 Wheat')),
                          DropdownMenuItem(value: 'Rice', child: Text('🍚 Rice')),
                          DropdownMenuItem(value: 'Cotton', child: Text('🧶 Cotton')),
                          DropdownMenuItem(value: 'Sugarcane', child: Text('🎋 Sugarcane')),
                          DropdownMenuItem(value: 'Tomato', child: Text('🍅 Tomato')),
                          DropdownMenuItem(value: 'Onion', child: Text('🧅 Onion')),
                          DropdownMenuItem(value: 'Brinjal', child: Text('🍆 Brinjal')),
                          DropdownMenuItem(value: 'Cucumber', child: Text('🥒 Cucumber')),
                        ],
                        onChanged: (value) {
                          setState(() => selectedCrop = value!);
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Title', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: 'e.g., Need help with leaf spots',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          isDense: true,
                        ),
                        maxLength: 100,
                      ),
                      const SizedBox(height: 16),
                      const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Describe your issue or share your solution...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          isDense: true,
                        ),
                        maxLines: 4,
                        maxLength: 500,
                      ),
                      const SizedBox(height: 16),
                      const Text('Image (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (selectedImage != null) ...[
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: selectedImageBytes != null
                                  ? Image.memory(
                                      selectedImageBytes!,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(selectedImage!.path),
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.red,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      selectedImage = null;
                                      selectedImageBytes = null;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            // Permission and picker logic preserved from original implementation
                            if (Platform.isAndroid) {
                              final photosGranted = await Permission.photos.isGranted;
                              final storageGranted = await Permission.storage.isGranted;

                              if (!photosGranted && !storageGranted) {
                                try {
                                  final results = await [Permission.photos, Permission.storage].request();
                                  final anyGranted = results.values.any((s) => s.isGranted);
                                  final anyPermanentlyDenied = results.values.any((s) => s.isPermanentlyDenied);
                                  if (anyPermanentlyDenied) {
                                    if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(
                                      SnackBar(
                                        content: const Text('Permission permanently denied. Open app settings to enable.'),
                                        action: SnackBarAction(
                                          label: 'Settings',
                                          onPressed: () => openAppSettings(),
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  if (!anyGranted) {
                                    if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(
                                      const SnackBar(content: Text('Storage or Photos permission is required to pick images')),
                                    );
                                    return;
                                  }
                                } on PlatformException {
                                  if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(
                                    const SnackBar(content: Text('Permission request already running. Please try again.')),
                                  );
                                  return;
                                }
                              }
                            } else if (Platform.isIOS) {
                              final photosGranted = await Permission.photos.isGranted;
                              if (!photosGranted) {
                                final r = await Permission.photos.request();
                                if (!r.isGranted) {
                                  if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(
                                    const SnackBar(content: Text('Photos permission is required to pick images')),
                                  );
                                  return;
                                }
                              }
                            }

                            final picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                              maxWidth: 800,
                              maxHeight: 800,
                              imageQuality: 70,
                            );
                            if (image != null) {
                              try {
                                final bytes = await image.readAsBytes();
                                if (bytes.length > 600000) {
                                  if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(
                                    const SnackBar(content: Text('Selected image too large for preview (max ~600KB). Try a smaller image.')),
                                  );
                                } else {
                                  if (dialogContext.mounted) {
                                    setState(() {
                                      selectedImage = image;
                                      selectedImageBytes = bytes;
                                    });
                                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                                      SnackBar(content: Text('Image selected (${(bytes.length/1024).toStringAsFixed(1)} KB)')),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(
                                  SnackBar(content: Text('Error reading image: $e')),
                                );
                              }
                            }
                          } catch (e) {
                            if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(content: Text('Error picking image: $e')),
                            );
                          }
                        },
                        icon: const Icon(Icons.image),
                        label: Text(selectedImage == null ? 'Add Image' : 'Change Image'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 40),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () async {
                              if (titleController.text.trim().isEmpty) {
                                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter a title')),
                                );
                                return;
                              }

                              // Show loading indicator
                              showDialog(
                                context: dialogContext,
                                barrierDismissible: false,
                                builder: (loadingContext) => WillPopScope(
                                  onWillPop: () async => false,
                                  child: const AlertDialog(
                                    content: Row(
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(width: 20),
                                        Text('Creating post...'),
                                      ],
                                    ),
                                  ),
                                ),
                              );

                              try {
                                String? imageData;
                                if (selectedImage != null) {
                                  final bytes = selectedImageBytes ?? await File(selectedImage!.path).readAsBytes();
                                  if (bytes.length > 400000) {
                                    Navigator.pop(dialogContext); // Close loading
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Image too large (max 400KB). Try reducing quality')),
                                      );
                                    }
                                    return;
                                  }
                                  imageData = base64Encode(bytes);
                                }

                                final postData = {
                                  'title': titleController.text.trim(),
                                  'description': descriptionController.text.trim(),
                                  'crop': selectedCrop,
                                  'userId': user.uid,
                                  'userName': user.displayName ?? user.email?.split('@')[0] ?? 'Anonymous',
                                  'userEmail': user.email ?? '',
                                  'likes': 0,
                                  'likedBy': [],
                                  'comments': 0,
                                  'createdAt': FieldValue.serverTimestamp(),
                                  'updatedAt': FieldValue.serverTimestamp(),
                                };

                                if (imageData != null) postData['imageData'] = imageData;

                                await FirebaseFirestore.instance.collection('communityPosts').add(postData);

                                if (dialogContext.mounted) {
                                  Navigator.pop(dialogContext); // Close loading
                                  Navigator.pop(dialogContext); // Close sheet
                                }
                                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('✅ Post created successfully!')),
                                );
                              } catch (e) {
                                if (dialogContext.mounted) Navigator.pop(dialogContext); // Close loading
                                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error creating post: $e')),
                                );
                              }
                            },
                            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0D5EF9)),
                            child: const Text('Post'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createPost(BuildContext context) async {
    // Just call the static method - no need to duplicate code
    await CommunityScreen.createPost(context);
  }

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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: s.t('search_community'),
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                                isDense: true,
                              ),
                              onChanged: (value) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FloatingActionButton.extended(
                            onPressed: () => _createPost(context),
                            icon: const Icon(Icons.add),
                            label: const Text('New Post'),
                            backgroundColor: const Color(0xFF0D5EF9),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _FilterChip(
                            label: 'All',
                            emoji: '📱',
                            isSelected: _selectedFilter == 'All',
                            onTap: () => setState(() => _selectedFilter = 'All'),
                          ),
                          _FilterChip(
                            label: s.t('Grape'),
                            emoji: '🍇',
                            isSelected: _selectedFilter == 'Grape',
                            onTap: () => setState(() => _selectedFilter = 'Grape'),
                          ),
                          _FilterChip(
                            label: s.t('Wheat'),
                            emoji: '🌾',
                            isSelected: _selectedFilter == 'Wheat',
                            onTap: () => setState(() => _selectedFilter = 'Wheat'),
                          ),
                          _FilterChip(
                            label: s.t('Rice'),
                            emoji: '🍚',
                            isSelected: _selectedFilter == 'Rice',
                            onTap: () => setState(() => _selectedFilter = 'Rice'),
                          ),
                          _FilterChip(
                            label: s.t('Cotton'),
                            emoji: '🧶',
                            isSelected: _selectedFilter == 'Cotton',
                            onTap: () => setState(() => _selectedFilter = 'Cotton'),
                          ),
                          _FilterChip(
                            label: s.t('Sugarcane'),
                            emoji: '🎋',
                            isSelected: _selectedFilter == 'Sugarcane',
                            onTap: () => setState(() => _selectedFilter = 'Sugarcane'),
                          ),
                          _FilterChip(
                            label: s.t('Tomato'),
                            emoji: '🍅',
                            isSelected: _selectedFilter == 'Tomato',
                            onTap: () => setState(() => _selectedFilter = 'Tomato'),
                          ),
                          _FilterChip(
                            label: s.t('Onion'),
                            emoji: '🧅',
                            isSelected: _selectedFilter == 'Onion',
                            onTap: () => setState(() => _selectedFilter = 'Onion'),
                          ),
                          _FilterChip(
                            label: s.t('Brinjal'),
                            emoji: '🍆',
                            isSelected: _selectedFilter == 'Brinjal',
                            onTap: () => setState(() => _selectedFilter = 'Brinjal'),
                          ),
                          _FilterChip(
                            label: s.t('Cucumber'),
                            emoji: '🥒',
                            isSelected: _selectedFilter == 'Cucumber',
                            onTap: () => setState(() => _selectedFilter = 'Cucumber'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildPostsList(),
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
    
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            isTablet ? 24 : 16, 
            isTablet ? 12 : 8, 
            isTablet ? 24 : 16, 
            0
          ),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: s.t('search_community'),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                  isDense: true,
                ),
                onChanged: (value) => setState(() {}),
              ),
              SizedBox(height: isTablet ? 16 : 12),
              Wrap(
                spacing: isTablet ? 12 : 8,
                runSpacing: isTablet ? 12 : 8,
                children: [
                  _FilterChip(
                    label: 'All',
                    emoji: '📱',
                    isSelected: _selectedFilter == 'All',
                    onTap: () => setState(() => _selectedFilter = 'All'),
                  ),
                  _FilterChip(
                    label: s.t('Grape'),
                    emoji: '🍇',
                    isSelected: _selectedFilter == 'Grape',
                    onTap: () => setState(() => _selectedFilter = 'Grape'),
                  ),
                  _FilterChip(
                    label: s.t('Wheat'),
                    emoji: '🌾',
                    isSelected: _selectedFilter == 'Wheat',
                    onTap: () => setState(() => _selectedFilter = 'Wheat'),
                  ),
                  _FilterChip(
                    label: s.t('Rice'),
                    emoji: '🍚',
                    isSelected: _selectedFilter == 'Rice',
                    onTap: () => setState(() => _selectedFilter = 'Rice'),
                  ),
                  _FilterChip(
                    label: s.t('Cotton'),
                    emoji: '🧶',
                    isSelected: _selectedFilter == 'Cotton',
                    onTap: () => setState(() => _selectedFilter = 'Cotton'),
                  ),
                  _FilterChip(
                    label: s.t('Sugarcane'),
                    emoji: '🎋',
                    isSelected: _selectedFilter == 'Sugarcane',
                    onTap: () => setState(() => _selectedFilter = 'Sugarcane'),
                  ),
                  _FilterChip(
                    label: s.t('Tomato'),
                    emoji: '🍅',
                    isSelected: _selectedFilter == 'Tomato',
                    onTap: () => setState(() => _selectedFilter = 'Tomato'),
                  ),
                  _FilterChip(
                    label: s.t('Onion'),
                    emoji: '🧅',
                    isSelected: _selectedFilter == 'Onion',
                    onTap: () => setState(() => _selectedFilter = 'Onion'),
                  ),
                  _FilterChip(
                    label: s.t('Brinjal'),
                    emoji: '🍆',
                    isSelected: _selectedFilter == 'Brinjal',
                    onTap: () => setState(() => _selectedFilter = 'Brinjal'),
                  ),
                  _FilterChip(
                    label: s.t('Cucumber'),
                    emoji: '🥒',
                    isSelected: _selectedFilter == 'Cucumber',
                    onTap: () => setState(() => _selectedFilter = 'Cucumber'),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 16 : 12),
            ],
          ),
        ),
        Expanded(
          child: _buildPostsList(),
        ),
      ],
    );
  }

  Widget _buildPostsList() {
    final searchQuery = _searchController.text.toLowerCase();
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('communityPosts')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.forum_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No posts yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Be the first to share with the community!'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _createPost(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Post'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D5EF9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }

        // Filter posts
        var posts = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final title = (data['title'] ?? '').toString().toLowerCase();
          final description = (data['description'] ?? '').toString().toLowerCase();
          final crop = data['crop'] ?? '';

          // Apply crop filter
          if (_selectedFilter != 'All' && crop != _selectedFilter) {
            return false;
          }

          // Apply search filter
          if (searchQuery.isNotEmpty) {
            return title.contains(searchQuery) || description.contains(searchQuery);
          }

          return true;
        }).toList();

        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isNotEmpty
                      ? 'No posts found for "$searchQuery"'
                      : 'No posts in ${_selectedFilter}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final doc = posts[index];
            final data = doc.data() as Map<String, dynamic>;
            
            return _DynamicPostCard(
              postId: doc.id,
              title: data['title'] ?? 'Untitled',
              description: data['description'] ?? '',
              crop: data['crop'] ?? 'Unknown',
              userName: data['userName'] ?? 'Anonymous',
              likes: data['likes'] ?? 0,
              comments: data['comments'] ?? 0,
              createdAt: data['createdAt'],
              userId: data['userId'] ?? '',
              imageData: data['imageData'],
              likedBy: List<String>.from(data['likedBy'] ?? []),
            );
          },
        );
      },
    );
  }
}

class _DynamicPostCard extends StatelessWidget {
  final String postId;
  final String title;
  final String description;
  final String crop;
  final String userName;
  final int likes;
  final int comments;
  final dynamic createdAt;
  final String userId;
  final String? imageData;
  final List<String> likedBy;

  const _DynamicPostCard({
    required this.postId,
    required this.title,
    required this.description,
    required this.crop,
    required this.userName,
    required this.likes,
    required this.comments,
    required this.createdAt,
    required this.userId,
    this.imageData,
    required this.likedBy,
  });

  String _getCropEmoji(String crop) {
    switch (crop) {
      case 'Grape': return '🍇';
      case 'Wheat': return '🌾';
      case 'Rice': return '🍚';
      case 'Cotton': return '🧶';
      case 'Sugarcane': return '🎋';
      case 'Tomato': return '🍅';
      case 'Onion': return '🧅';
      case 'Brinjal': return '🍆';
      case 'Cucumber': return '🥒';
      default: return '🌱';
    }
  }

  String _getTimeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    
    try {
      final DateTime dateTime = (timestamp as Timestamp).toDate();
      final difference = DateTime.now().difference(dateTime);
      
      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  Future<void> _deletePost(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.uid != userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only delete your own posts')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('communityPosts')
            .doc(postId)
            .delete();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting post: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser?.uid == userId;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PostDetailScreen(postId: postId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF0D5EF9).withOpacity(0.1),
                  child: const Icon(Icons.person, color: Color(0xFF0D5EF9)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        _getTimeAgo(createdAt),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D5EF9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_getCropEmoji(crop)} $crop',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D5EF9),
                    ),
                  ),
                ),
                if (isOwner) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deletePost(context),
                    tooltip: 'Delete post',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            // Description
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            // Image thumbnail
            if (imageData != null && imageData!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 150,
                    minHeight: 150,
                  ),
                  child: Image.memory(
                    base64Decode(imageData!),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Actions
            Row(
              children: [
                InkWell(
                  onTap: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      final postRef = FirebaseFirestore.instance.collection('communityPosts').doc(postId);

                      if (likedBy.contains(user.uid)) {
                        // Unlike
                        await postRef.update({
                          'likes': FieldValue.increment(-1),
                          'likedBy': FieldValue.arrayRemove([user.uid]),
                        });
                      } else {
                        // Like
                        await postRef.update({
                          'likes': FieldValue.increment(1),
                          'likedBy': FieldValue.arrayUnion([user.uid]),
                        });
                      }
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        likedBy.contains(FirebaseAuth.instance.currentUser?.uid) 
                          ? Icons.thumb_up 
                          : Icons.thumb_up_outlined, 
                        size: 18, 
                        color: likedBy.contains(FirebaseAuth.instance.currentUser?.uid)
                          ? Colors.blue
                          : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$likes',
                        style: TextStyle(
                          color: likedBy.contains(FirebaseAuth.instance.currentUser?.uid)
                            ? Colors.blue
                            : Colors.grey.shade600, 
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Icon(Icons.comment_outlined, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '$comments',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }
}

// Post Detail Screen
class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        backgroundColor: const Color(0xFF0D5EF9),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('communityPosts')
            .doc(widget.postId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Post not found', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final currentUser = FirebaseAuth.instance.currentUser;
          final isOwner = currentUser?.uid == data['userId'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFF0D5EF9).withOpacity(0.1),
                              child: const Icon(Icons.person, color: Color(0xFF0D5EF9), size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['userName'] ?? 'Anonymous',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    _formatTimestamp(data['createdAt']),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D5EF9).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_getCropEmoji(data['crop'])} ${data['crop']}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0D5EF9),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        
                        // Title
                        Text(
                          data['title'] ?? 'Untitled',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Description
                        if (data['description'] != null && data['description'].toString().isNotEmpty) ...[
                          Text(
                            data['description'],
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Image if exists
                        if (data['imageData'] != null && data['imageData'].toString().isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              base64Decode(data['imageData']),
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Stats and Actions
                        Row(
                          children: [
                            InkWell(
                              onTap: () async {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  final postRef = FirebaseFirestore.instance.collection('communityPosts').doc(widget.postId);
                                  final postDoc = await postRef.get();
                                  final likedBy = List<String>.from(postDoc.data()?['likedBy'] ?? []);
                                  
                                  if (likedBy.contains(user.uid)) {
                                    // Unlike
                                    await postRef.update({
                                      'likes': FieldValue.increment(-1),
                                      'likedBy': FieldValue.arrayRemove([user.uid]),
                                    });
                                  } else {
                                    // Like
                                    await postRef.update({
                                      'likes': FieldValue.increment(1),
                                      'likedBy': FieldValue.arrayUnion([user.uid]),
                                    });
                                  }
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.thumb_up_outlined, size: 20, color: Colors.grey.shade600),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${data['likes'] ?? 0}',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Icon(Icons.comment_outlined, size: 20, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              '${data['comments'] ?? 0}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        const Divider(),
                        
                        // Comments Section
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Comments List
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('communityPosts')
                              .doc(widget.postId)
                              .collection('comments')
                              .orderBy('createdAt', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            
                            final comments = snapshot.data!.docs;
                            
                            if (comments.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: Text(
                                    'No comments yet. Be the first!',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            }
                            
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: comments.length,
                              separatorBuilder: (context, index) => const Divider(height: 20),
                              itemBuilder: (context, index) {
                                final comment = comments[index].data() as Map<String, dynamic>;
                                final commentId = comments[index].id;
                                final isCommentOwner = comment['userId'] == FirebaseAuth.instance.currentUser?.uid;
                                
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor: Colors.blue.shade100,
                                            child: Text(
                                              (comment['userName'] ?? 'A')[0].toUpperCase(),
                                              style: TextStyle(
                                                color: Colors.blue.shade700,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  comment['userName'] ?? 'Anonymous',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  _formatTimestamp(comment['createdAt']),
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isCommentOwner)
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, size: 20),
                                              color: Colors.red,
                                              onPressed: () async {
                                                await FirebaseFirestore.instance
                                                    .collection('communityPosts')
                                                    .doc(widget.postId)
                                                    .collection('comments')
                                                    .doc(commentId)
                                                    .delete();
                                                    
                                                await FirebaseFirestore.instance
                                                    .collection('communityPosts')
                                                    .doc(widget.postId)
                                                    .update({'comments': FieldValue.increment(-1)});
                                              },
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        comment['text'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Add Comment Input
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _commentController,
                                  decoration: InputDecoration(
                                    hintText: 'Add a comment...',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: Colors.grey.shade600),
                                  ),
                                  maxLines: null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.send, color: Colors.blue),
                                onPressed: () async {
                                  final text = _commentController.text.trim();
                                  if (text.isEmpty) return;
                                  
                                  final user = FirebaseAuth.instance.currentUser;
                                  if (user == null) return;
                                  
                                  await FirebaseFirestore.instance
                                      .collection('communityPosts')
                                      .doc(widget.postId)
                                      .collection('comments')
                                      .add({
                                    'text': text,
                                    'userId': user.uid,
                                    'userName': user.displayName ?? user.email?.split('@')[0] ?? 'Anonymous',
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });
                                  
                                  await FirebaseFirestore.instance
                                      .collection('communityPosts')
                                      .doc(widget.postId)
                                      .update({'comments': FieldValue.increment(1)});
                                  
                                  _commentController.clear();
                                  FocusScope.of(context).unfocus();
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Delete button for owner
                        if (isOwner) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _deletePost(context),
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              label: const Text('Delete Post', style: TextStyle(color: Colors.red)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getCropEmoji(String crop) {
    switch (crop) {
      case 'Grape': return '🍇';
      case 'Wheat': return '🌾';
      case 'Rice': return '🍚';
      case 'Cotton': return '🧶';
      case 'Sugarcane': return '🎋';
      case 'Tomato': return '🍅';
      case 'Onion': return '🧅';
      case 'Brinjal': return '🍆';
      case 'Cucumber': return '🥒';
      default: return '🌱';
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    
    try {
      final DateTime dateTime = (timestamp as Timestamp).toDate();
      final difference = DateTime.now().difference(dateTime);
      
      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  Future<void> _deletePost(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('communityPosts')
            .doc(widget.postId)
            .delete();
        
        if (context.mounted) {
          Navigator.pop(context); // Go back to community screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting post: $e')),
          );
        }
      }
    }
  }
}

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  // -1 means "All categories" (show everything). Tapping an already-selected
  // icon will toggle back to -1.
  int _selectedCategoryIndex = -1;

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
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v.trim()),
                    decoration: InputDecoration(
                      hintText: s.t('search_market'),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      isDense: true,
                      suffixIcon: _searchQuery.isNotEmpty ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() { _searchController.clear(); _searchQuery = ''; }),
                      ) : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _CategoriesRow(selectedIndex: _selectedCategoryIndex, onSelected: (i) {
                  setState(() => _selectedCategoryIndex = (_selectedCategoryIndex == i ? -1 : i));
                }),
                const SizedBox(height: 16),
                // Show products for the selected category (icons control selection)
                Expanded(
                  child: _ProductsGrid(categoryIndex: _selectedCategoryIndex, searchQuery: _searchQuery),
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
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v.trim()),
            decoration: InputDecoration(
              hintText: s.t('search_market'),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              isDense: true,
              suffixIcon: _searchQuery.isNotEmpty ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() { _searchController.clear(); _searchQuery = ''; }),
              ) : null,
            ),
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8),
  _CategoriesRow(selectedIndex: _selectedCategoryIndex, onSelected: (i) {
    setState(() => _selectedCategoryIndex = (_selectedCategoryIndex == i ? -1 : i));
  }),
        SizedBox(height: isTablet ? 12 : 8),
        SizedBox(height: isTablet ? 12 : 8),
        // Directly show products for selected category (mobile layout)
        Expanded(
          child: _ProductsGrid(categoryIndex: _selectedCategoryIndex, searchQuery: _searchQuery),
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
            _buildMenuTile(context, Icons.person_outline, stringsOf(context).t('Profile Settings'), () {
              print('🔵 Profile Settings tapped!');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileSettingsScreen()),
              );
            }, isTablet),
            _buildMenuTile(context, Icons.notifications_outlined, stringsOf(context).t('Notifications'), () {
              print('🔵 Notifications tapped!');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            }, isTablet),
            _buildMenuTile(context, Icons.language, stringsOf(context).t('Language'), () async {
              print('🔵 Language tapped!');
              final selectedCode = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LanguageScreen()),
              );
              // If the language screen popped with a selected language code,
              // apply it to the app's LocaleController and reload translations.
              if (selectedCode is String && selectedCode.isNotEmpty) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('selected_locale', selectedCode);
                LocaleController.instance.setLocale(Locale(selectedCode));
                await TranslationController.instance.ensureLoaded(selectedCode);
                TranslationController.instance.notifyListeners();
              }
            }, isTablet),
            _buildMenuTile(context, Icons.help_outline, stringsOf(context).t('Help & Support'), () {
              print('🔵 Help & Support tapped!');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
              );
            }, isTablet),
            _buildMenuTile(context, Icons.privacy_tip_outlined, stringsOf(context).t('privacy policy'), () {
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
                  stringsOf(context).t('grow_smart_title'),
                  style: TextStyle(fontSize: isTablet ? 18 : 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Text(
                  stringsOf(context).t('grow_smart_desc'),
                  style: TextStyle(fontSize: isTablet ? 15 : 13, color: Colors.black54),
                ),
                SizedBox(height: isTablet ? 10 : 8),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    stringsOf(context).t('share_grapemaster'),
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
                  stringsOf(context).t('feedback_title'),
                  style: TextStyle(fontSize: isTablet ? 18 : 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Text(
                  stringsOf(context).t('feedback_desc'),
                  style: TextStyle(fontSize: isTablet ? 15 : 13, color: Colors.black54),
                ),
                SizedBox(height: isTablet ? 10 : 8),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    stringsOf(context).t('give_feedback'),
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
                            'color': Colors.green.value, // Store as integer color value
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
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.blue.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200.withOpacity(0.5),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.shade300.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.wb_sunny, color: Colors.orange.shade600, size: 32),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                s.todayLabel(), 
                                style: TextStyle(
                                  fontSize: 24, 
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Real-time weather (fetched from OpenWeather)
                      FutureBuilder<Map<String, dynamic>?>(
                        future: WeatherService.fetchCurrentWeather(),
                        builder: (context, snap) {
                          if (snap.connectionState != ConnectionState.done) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: CircularProgressIndicator(color: Colors.blue.shade600),
                              ),
                            );
                          }
                          if (!snap.hasData || snap.data == null) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                '${s.t('clear')} • --°C / --°C', 
                                style: TextStyle(fontSize: 18, color: Colors.blue.shade800),
                              ),
                            );
                          }
                          final w = snap.data!;
                          final desc = (w['description'] ?? s.t('clear')).toString();
                          final currentTemp = w['temp'] != null ? (w['temp'] as double).round().toString() : '--';
                          final max = w['temp_max'] != null ? (w['temp_max'] as double).round().toString() : '--';
                          final min = w['temp_min'] != null ? (w['temp_min'] as double).round().toString() : '--';
                          final locationName = (w['raw'] != null && w['raw']['name'] != null && (w['raw']['name'] as String).isNotEmpty) 
                              ? w['raw']['name'] as String 
                              : '';
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Temperature and location
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Large temperature display
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currentTemp,
                                            style: TextStyle(
                                              fontSize: 56,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade900,
                                              height: 1,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              '°C',
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Weather description
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          desc.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.blue.shade800,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Location info
                                  if (locationName.isNotEmpty)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.location_on, color: Colors.blue.shade700, size: 20),
                                            const SizedBox(width: 4),
                                            Text(
                                              locationName,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.blue.shade900,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'H: ${max}° L: ${min}°',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Weather details
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _WeatherDetailItem(
                                      icon: Icons.water_drop,
                                      label: 'Humidity',
                                      value: '${w['humidity'] ?? '-'}%',
                                      color: Colors.blue.shade700,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: Colors.blue.shade300,
                                    ),
                                    _WeatherDetailItem(
                                      icon: Icons.air,
                                      label: 'Wind',
                                      value: '${w['wind_speed'] ?? '-'} m/s',
                                      color: Colors.blue.shade700,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: Colors.blue.shade300,
                                    ),
                                    _WeatherDetailItem(
                                      icon: Icons.wb_sunny_outlined,
                                      label: 'UV Index',
                                      value: 'High',
                                      color: Colors.orange.shade600,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
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
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(isTablet ? 18 : 16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isTablet ? 10 : 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade300.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(Icons.wb_sunny, color: Colors.orange.shade600, size: isTablet ? 26 : 22),
                        ),
                        SizedBox(width: isTablet ? 12 : 10),
                        Text(
                          s.todayLabel(), 
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 20 : 18,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 16 : 12),
                    // Real-time weather (mobile / small layout)
                    FutureBuilder<Map<String, dynamic>?>(
                      future: WeatherService.fetchCurrentWeather(),
                      builder: (context, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: CircularProgressIndicator(color: Colors.blue.shade600),
                            ),
                          );
                        }
                        if (!snap.hasData || snap.data == null) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              '${s.t('clear')} • --°C / --°C', 
                              style: TextStyle(fontSize: isTablet ? 16 : 15, color: Colors.blue.shade800),
                            ),
                          );
                        }
                        final w = snap.data!;
                        final desc = (w['description'] ?? s.t('clear')).toString();
                        final currentTemp = w['temp'] != null ? (w['temp'] as double).round().toString() : '--';
                        final max = w['temp_max'] != null ? (w['temp_max'] as double).round().toString() : '--';
                        final min = w['temp_min'] != null ? (w['temp_min'] as double).round().toString() : '--';
                        final locationName = (w['raw'] != null && w['raw']['name'] != null && (w['raw']['name'] as String).isNotEmpty) 
                            ? w['raw']['name'] as String 
                            : '';
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Temperature and location
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Large temperature
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentTemp,
                                      style: TextStyle(
                                        fontSize: isTablet ? 48 : 42,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade900,
                                        height: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '°C',
                                        style: TextStyle(
                                          fontSize: isTablet ? 22 : 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Location and H/L
                                if (locationName.isNotEmpty)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, color: Colors.blue.shade700, size: isTablet ? 18 : 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            locationName.length > 12 ? '${locationName.substring(0, 12)}...' : locationName,
                                            style: TextStyle(
                                              fontSize: isTablet ? 14 : 13,
                                              color: Colors.blue.shade900,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'H: ${max}° L: ${min}°',
                                        style: TextStyle(
                                          fontSize: isTablet ? 13 : 12,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            SizedBox(height: isTablet ? 12 : 10),
                            // Weather description
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 10, vertical: isTablet ? 6 : 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                desc.toUpperCase(),
                                style: TextStyle(
                                  fontSize: isTablet ? 13 : 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue.shade800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            SizedBox(height: isTablet ? 16 : 12),
                            // Weather details
                            Container(
                              padding: EdgeInsets.all(isTablet ? 14 : 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _WeatherDetailItem(
                                    icon: Icons.water_drop,
                                    label: 'Humidity',
                                    value: '${w['humidity'] ?? '-'}%',
                                    color: Colors.blue.shade700,
                                    isCompact: !isTablet,
                                  ),
                                  Container(
                                    width: 1,
                                    height: isTablet ? 36 : 32,
                                    color: Colors.blue.shade300,
                                  ),
                                  _WeatherDetailItem(
                                    icon: Icons.air,
                                    label: 'Wind',
                                    value: '${w['wind_speed'] ?? '-'} m/s',
                                    color: Colors.blue.shade700,
                                    isCompact: !isTablet,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
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

// Helper widget for weather detail items
class _WeatherDetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isCompact;

  const _WeatherDetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: isCompact ? 22 : 26),
        SizedBox(height: isCompact ? 4 : 6),
        Text(
          label,
          style: TextStyle(
            fontSize: isCompact ? 11 : 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: isCompact ? 2 : 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isCompact ? 13 : 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
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
  final bool isSelected;
  final VoidCallback onTap;
  
  const _FilterChip({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;
    
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        avatar: Text(
          emoji,
          style: TextStyle(fontSize: isTablet ? 18 : 16),
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: isSelected ? const Color(0xFF0D5EF9) : Colors.white,
        side: BorderSide(
          color: isSelected ? const Color(0xFF0D5EF9) : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 24 : 20)
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 12 : 8,
          vertical: isTablet ? 8 : 4,
        ),
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
  final void Function(int)? onSelected;
  final int? selectedIndex;
  const _CategoriesRow({this.onSelected, this.selectedIndex});

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
      height: isDesktop ? 120 : (isTablet ? 112 : 104), // space for labels under icons
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) => _CategoryTile(
          cat: categories[i],
          index: i,
          onSelected: onSelected,
          selectedIndex: selectedIndex,
        ),
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
  final int index;
  final void Function(int)? onSelected;
  final int? selectedIndex;
  const _CategoryTile({required this.cat, required this.index, this.onSelected, this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;

    final selected = selectedIndex == index;
    final bgColor = selected ? const Color(0xFF0D5EF9) : Colors.indigo.shade50;
    final iconColor = selected ? Colors.white : const Color(0xFF0D5EF9);
    final textColor = selected ? const Color(0xFF0D5EF9) : Colors.black87;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (onSelected != null) onSelected!(index);
          },
          child: Container(
            width: isDesktop ? 64 : (isTablet ? 60 : 56),
            height: isDesktop ? 64 : (isTablet ? 60 : 56),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
              border: Border.all(color: selected ? const Color(0xFF0D5EF9) : Colors.transparent, width: 1.5),
            ),
            child: Icon(
              cat.icon,
              color: iconColor,
              size: isDesktop ? 28 : (isTablet ? 26 : 24),
            ),
          ),
        ),
        SizedBox(height: isDesktop ? 12 : 8),
        SizedBox(
          width: isDesktop ? 90 : (isTablet ? 80 : 72),
          child: Text(
            cat.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isTablet ? 13 : 12,
              color: textColor,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Service that fetches market products from Firestore with a local fallback.
class MarketService {
  // categoryKey should match how documents are stored in Firestore.
  // Example keys: 'Pesticide', 'Fertilizer', 'Seeds', 'Organic', 'Cattle Feed', 'Tools'
  // If categoryKey is null or empty, return all products (Firestone + fallback)
  static Future<List<Map<String, dynamic>>> fetchProducts(String? categoryKey) async {
    try {
      Query query = FirebaseFirestore.instance.collection('marketProducts');
      if (categoryKey != null && categoryKey.isNotEmpty) {
        query = query.where('category', isEqualTo: categoryKey);
      }

      final snap = await query.get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((d) {
          final data = (d.data() as Map<String, dynamic>?) ?? <String, dynamic>{};
          return {
            'name': data['name'] ?? data['title'] ?? 'Unknown',
            'brand': data['brand'] ?? data['vendor'] ?? '',
            'price': data['price'] != null ? data['price'].toString() : (data['display_price'] ?? '--').toString(),
            'size': data['size'] ?? data['pack'] ?? '',
            'type': data['type'] ?? (categoryKey ?? ''),
            'image': (data['image'] ?? data['imageUrl'] ?? '').toString(),
          };
        }).toList();
      }
    } catch (e) {
      if (kDebugMode) print('MarketService fetch error: $e');
    }

    // Fallback static products (filtered by categoryKey)
    final fallback = [
      {'name': 'Urea', 'brand': 'IFFCO', 'price': '₹300', 'size': '50 kg', 'type': 'Fertilizer'},
      {'name': 'DAP', 'brand': 'IFFCO', 'price': '₹1400', 'size': '50 kg', 'type': 'Fertilizer'},
      {'name': 'NPK', 'brand': 'IFFCO', 'price': '₹1200', 'size': '50 kg', 'type': 'Fertilizer'},
      {'name': 'Monocrotophos', 'brand': 'UPL', 'price': '₹450', 'size': '1 L', 'type': 'Pesticide'},
      {'name': 'Chlorpyrifos', 'brand': 'UPL', 'price': '₹380', 'size': '1 L', 'type': 'Pesticide'},
      {'name': 'Imidacloprid', 'brand': 'Bayer', 'price': '₹520', 'size': '1 L', 'type': 'Pesticide'},
      {'name': 'Wheat Seeds', 'brand': 'Nirmal Seeds', 'price': '₹2800', 'size': '25 kg', 'type': 'Seeds'},
      {'name': 'Rice Seeds', 'brand': 'Nirmal Seeds', 'price': '₹3200', 'size': '25 kg', 'type': 'Seeds'},
      {'name': 'Organic Manure', 'brand': 'Organic India', 'price': '₹150', 'size': '25 kg', 'type': 'Organic'},
    ];

    // Return items matching the categoryKey (naive match)
    // If no category requested, return the full fallback list
    if (categoryKey == null || categoryKey.isEmpty) return fallback;

    return fallback.where((p) {
      final t = (p['type'] ?? '').toString().toLowerCase();
      return t.contains(categoryKey.toLowerCase().split(' ').first);
    }).toList();
  }
}

class _ProductsGrid extends StatelessWidget {
  final int categoryIndex;
  final String searchQuery;
  const _ProductsGrid({required this.categoryIndex, this.searchQuery = ''});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;

    int crossAxisCount = 2;
    if (isDesktop) crossAxisCount = 4;
    else if (isTablet) crossAxisCount = 3;

    // Map tab index to a category key used in Firestore
    // Keys that correspond to Firestore `category` values. Keep order in sync
    // with the icons shown above in `_CategoriesRow`.
    final categoryKeys = [
      'Pesticide',
      'Fertilizer',
      'Seeds',
      'OrganicProtection', // Organic Crop Protection
      'OrganicNutrition', // Organic Crop Nutrition
      'Cattle Feed',
      'Tools',
    ];
    // If categoryIndex is -1, we want all products → pass null to the service
    final categoryKey = (categoryIndex < 0 || categoryIndex >= categoryKeys.length)
      ? null
      : categoryKeys[categoryIndex % categoryKeys.length];

    return FutureBuilder<List<Map<String, dynamic>>>(
  future: MarketService.fetchProducts(categoryKey),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Center(child: CircularProgressIndicator());
        }
        final products = snap.data ?? [];
        // Apply search filtering (by name or brand) if query provided
        final query = searchQuery.trim().toLowerCase();
        final filtered = query.isEmpty
            ? products
            : products.where((p) {
                final name = (p['name'] ?? '').toString().toLowerCase();
                final brand = (p['brand'] ?? '').toString().toLowerCase();
                return name.contains(query) || brand.contains(query);
              }).toList();

        if (filtered.isEmpty) {
          return Center(child: Text('No products found'));
        }

        return GridView.builder(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: isTablet ? 16 : 12,
            crossAxisSpacing: isTablet ? 16 : 12,
            childAspectRatio: isDesktop ? 0.8 : 0.72,
          ),
          itemCount: filtered.length,
          itemBuilder: (_, i) => _ProductCard(product: filtered[i]),
        );
      },
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
  final Map<String, dynamic> product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;

    final name = product['name']?.toString() ?? 'Unknown';
    final brand = product['brand']?.toString() ?? '';
    final price = product['price']?.toString() ?? '--';
    final size = product['size']?.toString() ?? '';
    final type = product['type']?.toString() ?? '';

    return _RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
              child: (product['image'] != null && (product['image'] as String).isNotEmpty)
                  ? Image.network(
                      product['image'],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => Container(
                        color: _getProductColor(type),
                        child: Center(
                          child: Icon(_getProductIcon(type), size: isDesktop ? 48 : 40, color: Colors.white),
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: _getProductColor(type),
                      ),
                      child: Center(
                        child: Icon(_getProductIcon(type), size: isDesktop ? 48 : 40, color: Colors.white),
                      ),
                    ),
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: isTablet ? 15 : 14,
            ),
          ),
          Text(
            brand.isNotEmpty ? 'by $brand' : '',
            style: TextStyle(
              color: Colors.black54,
              fontSize: isTablet ? 13 : 12,
            ),
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            price,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: isTablet ? 16 : 14,
              color: const Color(0xFF0D5EF9),
            ),
          ),
          Text(
            size,
            style: TextStyle(
              color: Colors.black54,
              fontSize: isTablet ? 13 : 12,
            ),
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
