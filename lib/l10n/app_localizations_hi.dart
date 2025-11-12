// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'ग्रेपमास्टर';

  @override
  String get farmingAssistant => 'खेती सहायक';

  @override
  String get assistantWelcome =>
      'नमस्ते! 👋 मैं आपका खेती सहायक हूँ। मुझसे नीचे के बारे में कुछ भी पूछें:\n\n• अंगूर की खेती और रोग\n• कीट प्रबंधन\n• सिंचाई के सुझाव\n• उर्वरक की सलाह\n• मौसम-आधारित सुझाव\n\nमैं आपकी कैसे मदद कर सकता हूँ?';

  @override
  String get askAboutFarming => 'खेती के बारे में पूछें...';

  @override
  String get assistantTyping => 'सहायक टाइप कर रहा है...';

  @override
  String get chatSettings => 'चैट सेटिंग्स';

  @override
  String get clearChatTooltip => 'चैट साफ़ करें';

  @override
  String get chatSettingsSaved => 'चैट सेटिंग्स सुरक्षित और सत्यापित हो गईं।';

  @override
  String get chatSettingsSavedFailed =>
      'चैट सेटिंग्स सुरक्षित की गईं (सत्यापन विफल)';

  @override
  String get groqInvalidApiKeySnack => 'Groq ने 401 लौटाया — अमान्य API कुंजी।';

  @override
  String get voiceComingSoon => 'वॉइस इनपुट जल्द आ रहा है!';

  @override
  String get chatCleared => 'चैट साफ़ कर दी गई! मैं आपकी कैसे मदद करूं?';

  @override
  String get disease_powdery_mildew => 'धूल जैसा फफूंदी (Powdery Mildew)';

  @override
  String get disease_downy_mildew => 'डाउनी मिल्ड्यू (Downy Mildew)';

  @override
  String get disease_black_rot => 'ब्लैक रॉट (Black Rot)';

  @override
  String get disease_botrytis_bunch_rot => 'बोट्राइटिस (ग्रे मोल्ड)';

  @override
  String get disease_anthracnose => 'एंथ्राक्नोज़ (Anthracnose)';

  @override
  String get disease_leaf_spot => 'लीफ स्पॉट (Leaf Spot)';
}
