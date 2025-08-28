import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
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
          title: 'Grapemaster',
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
  static const Map<String, Map<String, String>> _fallbackData = {
    'en': {
      'app_title': 'Plantix',
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
      'Select your Plantix language': 'Select your Plantix language',
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
    },
    'hi': {
      'app_title': 'प्लैन्टिक्स',
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
      'Select your Plantix language': 'अपनी प्लैन्टिक्स भाषा चुनें',
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
    },
    'mr': {
      'app_title': 'प्लॅन्टिक्स',
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
      'Select your Plantix language': 'आपली प्लॅन्टिक्स भाषा निवडा',
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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 18, child: Icon(Icons.eco)),
                  const SizedBox(width: 8),
                  Text(stringsOf(context).t('Namaste!'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 6),
              Text(stringsOf(context).t('Select your Plantix language'), style: const TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 16),
              _langTile('mr', stringsOf(context).t('मराठी'), stringsOf(context).t('स्वत:च्या भाषेत शेती')),
              _langTile('hi', stringsOf(context).t('हिन्दी'), stringsOf(context).t('खेती आपकी भाषा में')),
              _langTile('en', stringsOf(context).t('English'), stringsOf(context).t('Farming in your language')),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => widget.onAccept(Locale(_selected)),
                  child: Text(stringsOf(context).t('Accept')),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                children: [
                  Text(stringsOf(context).t('I read and accept the ')),
                  Text(stringsOf(context).t('terms of use'), style: const TextStyle(decoration: TextDecoration.underline)),
                  Text(stringsOf(context).t(' and the ')),
                  Text(stringsOf(context).t('privacy policy'), style: const TextStyle(decoration: TextDecoration.underline)),
                  Text(stringsOf(context).t('.')),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _langTile(String code, String title, String subtitle) {
    final selected = _selected == code;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE8EEFF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selected ? const Color(0xFF0D5EF9) : Colors.grey.shade300, width: selected ? 2 : 1),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: const Color(0xFF0D5EF9)),
        onTap: () => setState(() => _selected = code),
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
    MarketScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    final destinations = [
      NavigationDestination(icon: const Icon(Icons.spa_outlined), selectedIcon: const Icon(Icons.spa), label: s.t('tab_crops')),
      NavigationDestination(icon: const Icon(Icons.chat_bubble_outline), selectedIcon: const Icon(Icons.chat_bubble), label: s.t('tab_community')),
      NavigationDestination(icon: const Icon(Icons.storefront_outlined), selectedIcon: const Icon(Icons.storefront), label: s.t('tab_market')),
      NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: s.t('tab_you')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('app_title')),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.more_vert))
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: destinations,
        height: 72,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(s.t('take_picture')),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        _CropChipsRow(),
        const SizedBox(height: 12),
        _WeatherAndTaskCards(),
        const SizedBox(height: 16),
        Text(s.t('heal_your_crop'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _HealYourCropCard(),
        const SizedBox(height: 16),
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: s.t('search_community'),
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FilterChip(label: s.t('Capsicum & Chilli'), emoji: '🌶️'),
            _FilterChip(label: s.t('Apple'), emoji: '🍎'),
            _FilterChip(label: s.t('Grape'), emoji: '🍇'),
          ],
        ),
        const SizedBox(height: 12),
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
  late final TabController _tabController = TabController(length: 6, vsync: this);

  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            decoration: InputDecoration(
              hintText: s.t('search_market'),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _CategoriesRow(),
        const SizedBox(height: 8),
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
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(stringsOf(context).t('Profile')));
  }
}

class _CropChipsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final crops = ['🍅', '🍎', '🧅', '🍇', '+'];
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          return CircleAvatar(
            radius: 28,
            backgroundColor: i == 3 ? Colors.indigo.shade50 : Colors.grey.shade200,
            child: Text(crops[i], style: const TextStyle(fontSize: 24)),
          );
        },
        separatorBuilder: (context, i) => const SizedBox(width: 12),
        itemCount: crops.length,
      ),
    );
  }
}

class _WeatherAndTaskCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    return Row(
      children: [
        Expanded(
          child: _RoundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.todayLabel(), style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(s.t('clear')),
                const SizedBox(height: 12),
                const _LocationAllowRow(),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _RoundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.t('Spraying')),
                const SizedBox(height: 8),
                Text(s.t('Mode')),
                const SizedBox(height: 12),
                const _LocationAllowRow(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationAllowRow extends StatelessWidget {
  const _LocationAllowRow();

  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(s.t('location_perm'))),
          Text(s.t('allow'), style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _HealYourCropCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = stringsOf(context);
    return _RoundedCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Step(icon: Icons.camera_alt_outlined, label: s.t('Take a\npicture')),
              const Icon(Icons.chevron_right),
              _Step(icon: Icons.receipt_long_outlined, label: s.t('See\ndiagnosis')),
              const Icon(Icons.chevron_right),
              _Step(icon: Icons.medication_outlined, label: s.t('Get\nmedicine')),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {},
              child: Text(s.t('take_picture')),
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
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(color: Color(0x11000000), blurRadius: 6, offset: Offset(0, 2)),
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
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF0D5EF9)),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
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
    return Chip(
      avatar: Text(emoji),
      label: Text(label),
      side: BorderSide(color: Colors.grey.shade300),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _PostCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color imageColor;
  const _PostCard({required this.title, required this.subtitle, required this.imageColor});

  @override
  Widget build(BuildContext context) {
    return _RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 160, decoration: BoxDecoration(color: imageColor, borderRadius: BorderRadius.circular(12))),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(radius: 14),
              const SizedBox(width: 8),
              Text(stringsOf(context).t('Hari Shankar Shukla • India')),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(stringsOf(context).t('Translate'), style: const TextStyle(color: Colors.black54)),
              Text(stringsOf(context).t('0 answers'), style: const TextStyle(color: Colors.black54)),
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
    return SizedBox(
      height: 104, // extra room for longer Hindi/Marathi labels
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) => _CategoryTile(cat: categories[i]),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
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
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(cat.icon, color: const Color(0xFF0D5EF9)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 84,
          child: Text(
            cat.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, height: 1.2),
          ),
        ),
      ],
    );
  }
}

class _ProductsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: 8,
      itemBuilder: (_, i) => _ProductCard(index: i),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final int index;
  const _ProductCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return _RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(index.isEven ? stringsOf(context).t('ACROBAT') : stringsOf(context).t('AEROWON'), style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(stringsOf(context).t('by GAPL'), style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          Text(stringsOf(context).t('₹190'), style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(stringsOf(context).t('500 millilitre'), style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
