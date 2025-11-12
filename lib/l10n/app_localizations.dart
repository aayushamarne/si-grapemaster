import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('mr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GrapeMaster'**
  String get appTitle;

  /// No description provided for @farmingAssistant.
  ///
  /// In en, this message translates to:
  /// **'Farming Assistant'**
  String get farmingAssistant;

  /// No description provided for @assistantWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hello! 👋 I\'m your farming assistant. Ask me anything about:\n\n• Grape farming & diseases\n• Pest management\n• Irrigation tips\n• Fertilizer recommendations\n• Weather-based advice\n\nHow can I help you today?'**
  String get assistantWelcome;

  /// No description provided for @askAboutFarming.
  ///
  /// In en, this message translates to:
  /// **'Ask about farming...'**
  String get askAboutFarming;

  /// No description provided for @assistantTyping.
  ///
  /// In en, this message translates to:
  /// **'Assistant is typing...'**
  String get assistantTyping;

  /// No description provided for @chatSettings.
  ///
  /// In en, this message translates to:
  /// **'Chat settings'**
  String get chatSettings;

  /// No description provided for @clearChatTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear chat'**
  String get clearChatTooltip;

  /// No description provided for @chatSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Chat settings saved and validated.'**
  String get chatSettingsSaved;

  /// No description provided for @chatSettingsSavedFailed.
  ///
  /// In en, this message translates to:
  /// **'Chat settings saved (validation failed)'**
  String get chatSettingsSavedFailed;

  /// No description provided for @groqInvalidApiKeySnack.
  ///
  /// In en, this message translates to:
  /// **'Groq returned 401 — invalid API key.'**
  String get groqInvalidApiKeySnack;

  /// No description provided for @voiceComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Voice input coming soon!'**
  String get voiceComingSoon;

  /// No description provided for @chatCleared.
  ///
  /// In en, this message translates to:
  /// **'Chat cleared! How can I help you?'**
  String get chatCleared;

  /// No description provided for @disease_powdery_mildew.
  ///
  /// In en, this message translates to:
  /// **'Powdery Mildew'**
  String get disease_powdery_mildew;

  /// No description provided for @disease_downy_mildew.
  ///
  /// In en, this message translates to:
  /// **'Downy Mildew'**
  String get disease_downy_mildew;

  /// No description provided for @disease_black_rot.
  ///
  /// In en, this message translates to:
  /// **'Black Rot'**
  String get disease_black_rot;

  /// No description provided for @disease_botrytis_bunch_rot.
  ///
  /// In en, this message translates to:
  /// **'Botrytis (Grey Mold)'**
  String get disease_botrytis_bunch_rot;

  /// No description provided for @disease_anthracnose.
  ///
  /// In en, this message translates to:
  /// **'Anthracnose'**
  String get disease_anthracnose;

  /// No description provided for @disease_leaf_spot.
  ///
  /// In en, this message translates to:
  /// **'Leaf Spot'**
  String get disease_leaf_spot;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
