// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GrapeMaster';

  @override
  String get farmingAssistant => 'Farming Assistant';

  @override
  String get assistantWelcome =>
      'Hello! 👋 I\'m your farming assistant. Ask me anything about:\n\n• Grape farming & diseases\n• Pest management\n• Irrigation tips\n• Fertilizer recommendations\n• Weather-based advice\n\nHow can I help you today?';

  @override
  String get askAboutFarming => 'Ask about farming...';

  @override
  String get assistantTyping => 'Assistant is typing...';

  @override
  String get chatSettings => 'Chat settings';

  @override
  String get clearChatTooltip => 'Clear chat';

  @override
  String get chatSettingsSaved => 'Chat settings saved and validated.';

  @override
  String get chatSettingsSavedFailed =>
      'Chat settings saved (validation failed)';

  @override
  String get groqInvalidApiKeySnack => 'Groq returned 401 — invalid API key.';

  @override
  String get voiceComingSoon => 'Voice input coming soon!';

  @override
  String get chatCleared => 'Chat cleared! How can I help you?';

  @override
  String get disease_powdery_mildew => 'Powdery Mildew';

  @override
  String get disease_downy_mildew => 'Downy Mildew';

  @override
  String get disease_black_rot => 'Black Rot';

  @override
  String get disease_botrytis_bunch_rot => 'Botrytis (Grey Mold)';

  @override
  String get disease_anthracnose => 'Anthracnose';

  @override
  String get disease_leaf_spot => 'Leaf Spot';
}
