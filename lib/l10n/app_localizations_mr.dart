// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appTitle => 'ग्रेपमास्टर';

  @override
  String get farmingAssistant => 'शेत सहाय्यक';

  @override
  String get assistantWelcome =>
      'नमस्कार! 👋 मी तुमचा शेत सहाय्यक आहे. मला खालील विषयांबद्दल काहीही विचारा:\n\n• द्राक्ष लागवड आणि रोग\n• कीटक व्यवस्थापन\n• सिंचन सूचना\n• खत शिफारसी\n• हवामान-आधारित सल्ला\n\nमी तुम्हाला कशी मदत करू शकतो?';

  @override
  String get askAboutFarming => 'शेतबद्दल विचारा...';

  @override
  String get assistantTyping => 'सहाय्यक टाइप करत आहे...';

  @override
  String get chatSettings => 'चॅट सेटिंग्ज';

  @override
  String get clearChatTooltip => 'चॅट साफ करा';

  @override
  String get chatSettingsSaved => 'चॅट सेटिंग्ज जतन आणि समर्थनीय आहेत.';

  @override
  String get chatSettingsSavedFailed =>
      'चॅट सेटिंग्ज जतन झाल्या (सत्यापन अयशस्वी)';

  @override
  String get groqInvalidApiKeySnack => 'Groq ने 401 परत केले — अमान्य API की.';

  @override
  String get voiceComingSoon => 'व्हॉइस इनपुट लवकरच येणार!';

  @override
  String get chatCleared => 'चॅट स्वच्छ केली! मी तुमची कशी मदत करू शकतो?';

  @override
  String get disease_powdery_mildew => 'पावरी मिल्ड्यू (Powdery Mildew)';

  @override
  String get disease_downy_mildew => 'डाउनी मिल्ड्यू (Downy Mildew)';

  @override
  String get disease_black_rot => 'ब्लॅक रॉट (Black Rot)';

  @override
  String get disease_botrytis_bunch_rot => 'बोट्राइटिस (ग्रे मोल्ड)';

  @override
  String get disease_anthracnose => 'एंथ्रॅक्नोज (Anthracnose)';

  @override
  String get disease_leaf_spot => 'लीफ स्पॉट (Leaf Spot)';
}
