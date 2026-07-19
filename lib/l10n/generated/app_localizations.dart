import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('bn'),
    Locale('en')
  ];

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// No description provided for @commonYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get commonYesterday;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @thisMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonthLabel;

  /// No description provided for @openSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettingsButton;

  /// No description provided for @forbiddenTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Forbidden time · {name}'**
  String forbiddenTimeLabel(Object name);

  /// No description provided for @startFullSessionButton.
  ///
  /// In en, this message translates to:
  /// **'Start Full Session — {count} Dhikir'**
  String startFullSessionButton(Object count);

  /// No description provided for @allDhikirSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'All Dhikir'**
  String get allDhikirSectionTitle;

  /// No description provided for @tapNoLimit.
  ///
  /// In en, this message translates to:
  /// **'Tap to count — no limit'**
  String get tapNoLimit;

  /// No description provided for @remainingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} remaining'**
  String remainingCount(Object count);

  /// No description provided for @resetTodayCountTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Today’s Count?'**
  String get resetTodayCountTitle;

  /// No description provided for @goalLabelTimes.
  ///
  /// In en, this message translates to:
  /// **'{goal} times'**
  String goalLabelTimes(Object goal);

  /// No description provided for @goalLabelUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get goalLabelUnlimited;

  /// No description provided for @setUnlimitedButton.
  ///
  /// In en, this message translates to:
  /// **'Set Unlimited'**
  String get setUnlimitedButton;

  /// No description provided for @setGoalButton.
  ///
  /// In en, this message translates to:
  /// **'Set Goal: {label}'**
  String setGoalButton(Object label);

  /// No description provided for @goalSubtitleTasbihSubhanallah.
  ///
  /// In en, this message translates to:
  /// **'Tasbih — SubhanAllah'**
  String get goalSubtitleTasbihSubhanallah;

  /// No description provided for @goalSubtitleTasbihAlhamdulillah.
  ///
  /// In en, this message translates to:
  /// **'Tasbih — Alhamdulillah'**
  String get goalSubtitleTasbihAlhamdulillah;

  /// No description provided for @goalSubtitleNamesOfAllah.
  ///
  /// In en, this message translates to:
  /// **'Names of Allah'**
  String get goalSubtitleNamesOfAllah;

  /// No description provided for @goalSubtitleDailyCentury.
  ///
  /// In en, this message translates to:
  /// **'Daily century goal'**
  String get goalSubtitleDailyCentury;

  /// No description provided for @goalSubtitleNoLimit.
  ///
  /// In en, this message translates to:
  /// **'No limit — count freely'**
  String get goalSubtitleNoLimit;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutAppName.
  ///
  /// In en, this message translates to:
  /// **'Daily Dhikir'**
  String get aboutAppName;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(Object version);

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'A daily dhikir tracker app with 30-day tracking'**
  String get aboutDescription;

  /// No description provided for @aboutDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get aboutDeveloper;

  /// No description provided for @aboutDeveloperNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Developer name — TODO'**
  String get aboutDeveloperNamePlaceholder;

  /// No description provided for @aboutBioPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Short bio — TODO'**
  String get aboutBioPlaceholder;

  /// No description provided for @aboutContactPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Contact — TODO'**
  String get aboutContactPlaceholder;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageBangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get settingsLanguageBangla;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get settingsLanguageDialogTitle;

  /// No description provided for @qiblaTitle.
  ///
  /// In en, this message translates to:
  /// **'Qibla Compass'**
  String get qiblaTitle;

  /// No description provided for @qiblaComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get qiblaComingSoon;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorite dhikir yet'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon to favorite your dhikir'**
  String get favoritesEmptySubtitle;

  /// No description provided for @favoritesCustomSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Favourite Dhikir'**
  String get favoritesCustomSectionTitle;

  /// No description provided for @favoritesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Favourite Dhikir'**
  String get favoritesSectionTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCounter.
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get navCounter;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navMyDhikir.
  ///
  /// In en, this message translates to:
  /// **'My Dhikir'**
  String get navMyDhikir;

  /// No description provided for @homeSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Dhikir'**
  String get homeSectionTitle;

  /// No description provided for @todayCountBadge.
  ///
  /// In en, this message translates to:
  /// **'{count}× today'**
  String todayCountBadge(Object count);

  /// No description provided for @quickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActionsTitle;

  /// No description provided for @quickActionPrayerTime.
  ///
  /// In en, this message translates to:
  /// **'Prayer Time'**
  String get quickActionPrayerTime;

  /// No description provided for @quickActionQibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get quickActionQibla;

  /// No description provided for @themeToggleSwitchToLight.
  ///
  /// In en, this message translates to:
  /// **'Switch to light mode'**
  String get themeToggleSwitchToLight;

  /// No description provided for @themeToggleSwitchToDark.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark mode'**
  String get themeToggleSwitchToDark;

  /// No description provided for @resetTodayCountBody.
  ///
  /// In en, this message translates to:
  /// **'This resets today’s tap counter to 0.'**
  String get resetTodayCountBody;

  /// No description provided for @resetMonthTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset This Month?'**
  String get resetMonthTitle;

  /// No description provided for @resetMonthBody.
  ///
  /// In en, this message translates to:
  /// **'This clears all checkmarks for this month.'**
  String get resetMonthBody;

  /// No description provided for @daysCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'{completed} / {total} days'**
  String daysCompletedLabel(Object completed, Object total);

  /// No description provided for @pillArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get pillArabic;

  /// No description provided for @pillMeaning.
  ///
  /// In en, this message translates to:
  /// **'Meaning & Significance'**
  String get pillMeaning;

  /// No description provided for @pillTodayCounter.
  ///
  /// In en, this message translates to:
  /// **'Today’s Counter'**
  String get pillTodayCounter;

  /// No description provided for @goalUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Goal: ∞'**
  String get goalUnlimited;

  /// No description provided for @goalTarget.
  ///
  /// In en, this message translates to:
  /// **'Goal: {target}'**
  String goalTarget(Object target);

  /// No description provided for @goalReachedBannerDetail.
  ///
  /// In en, this message translates to:
  /// **'MāshāAllah! {target} completed today'**
  String goalReachedBannerDetail(Object target);

  /// No description provided for @historyButton.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyButton;

  /// No description provided for @legendDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get legendDone;

  /// No description provided for @legendPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get legendPending;

  /// No description provided for @legendFuture.
  ///
  /// In en, this message translates to:
  /// **'Future'**
  String get legendFuture;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'History Calendar'**
  String get calendarTitle;

  /// No description provided for @resetMonthDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset {month}?'**
  String resetMonthDialogTitle(Object month);

  /// No description provided for @resetMonthDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This clears all checkmarks for this month only.'**
  String get resetMonthDialogBody;

  /// No description provided for @resetMonthButton.
  ///
  /// In en, this message translates to:
  /// **'Reset Month'**
  String get resetMonthButton;

  /// No description provided for @legendCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get legendCompleted;

  /// No description provided for @legendMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get legendMissed;

  /// No description provided for @monthSummary.
  ///
  /// In en, this message translates to:
  /// **'This month: {completed} / {total} days ({pct}%)'**
  String monthSummary(Object completed, Object total, Object pct);

  /// No description provided for @daysCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCountLabel(Object count);

  /// No description provided for @daysCountShort.
  ///
  /// In en, this message translates to:
  /// **'{count} d'**
  String daysCountShort(Object count);

  /// No description provided for @statStreak.
  ///
  /// In en, this message translates to:
  /// **'🔥 Streak'**
  String get statStreak;

  /// No description provided for @statBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get statBest;

  /// No description provided for @yearOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Year Overview'**
  String get yearOverviewTitle;

  /// No description provided for @calendarFooter.
  ///
  /// In en, this message translates to:
  /// **'Tap a month to navigate  •  Total: {total} days'**
  String calendarFooter(Object total);

  /// No description provided for @resetMonthProgressButton.
  ///
  /// In en, this message translates to:
  /// **'Reset {month} Progress'**
  String resetMonthProgressButton(Object month);

  /// No description provided for @counterResetBody.
  ///
  /// In en, this message translates to:
  /// **'Reset counter for {title}?'**
  String counterResetBody(Object title);

  /// No description provided for @counterProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total} dhikir'**
  String counterProgressLabel(Object current, Object total);

  /// No description provided for @counterResetHint.
  ///
  /// In en, this message translates to:
  /// **'Reset  •  {count} counted'**
  String counterResetHint(Object count);

  /// No description provided for @counterCountedUnlimited.
  ///
  /// In en, this message translates to:
  /// **'{count} counted'**
  String counterCountedUnlimited(Object count);

  /// No description provided for @counterGoalReachedBanner.
  ///
  /// In en, this message translates to:
  /// **'MāshāAllah! Goal reached'**
  String get counterGoalReachedBanner;

  /// No description provided for @sessionGoalSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Session Goal'**
  String get sessionGoalSheetTitle;

  /// No description provided for @sessionGoalSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Applies to all dhikir in this session'**
  String get sessionGoalSheetSubtitle;

  /// No description provided for @setupGoalDescSubhanallah.
  ///
  /// In en, this message translates to:
  /// **'SubhanAllah tasbih'**
  String get setupGoalDescSubhanallah;

  /// No description provided for @setupGoalDescAlhamdulillah.
  ///
  /// In en, this message translates to:
  /// **'Alhamdulillah tasbih'**
  String get setupGoalDescAlhamdulillah;

  /// No description provided for @setupGoalDescCenturyGoal.
  ///
  /// In en, this message translates to:
  /// **'Century goal'**
  String get setupGoalDescCenturyGoal;

  /// No description provided for @setupGoalDescNoLimit.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get setupGoalDescNoLimit;

  /// No description provided for @setupSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Setup Session'**
  String get setupSheetTitle;

  /// No description provided for @setupSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} dhikir • Choose a shared goal'**
  String setupSheetSubtitle(Object count);

  /// No description provided for @setupGoalPerDhikir.
  ///
  /// In en, this message translates to:
  /// **'Goal per Dhikir'**
  String get setupGoalPerDhikir;

  /// No description provided for @setupSessionIncludes.
  ///
  /// In en, this message translates to:
  /// **'Session includes'**
  String get setupSessionIncludes;

  /// No description provided for @setupStartUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Start (Unlimited)'**
  String get setupStartUnlimited;

  /// No description provided for @setupStartGoal.
  ///
  /// In en, this message translates to:
  /// **'Start (Goal: {label})'**
  String setupStartGoal(Object label);

  /// No description provided for @goalPickSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Counter Goal'**
  String get goalPickSheetTitle;

  /// No description provided for @goalPickSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how many times to recite'**
  String get goalPickSheetSubtitle;

  /// No description provided for @analyticsAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Counter Analytics'**
  String get analyticsAppBarTitle;

  /// No description provided for @periodDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get periodDaily;

  /// No description provided for @periodWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get periodWeekly;

  /// No description provided for @periodMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get periodMonthly;

  /// No description provided for @byDhikirSection.
  ///
  /// In en, this message translates to:
  /// **'By Dhikir'**
  String get byDhikirSection;

  /// No description provided for @colDhikir.
  ///
  /// In en, this message translates to:
  /// **'Dhikir'**
  String get colDhikir;

  /// No description provided for @colCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get colCount;

  /// No description provided for @colDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get colDays;

  /// No description provided for @colShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get colShare;

  /// No description provided for @periodLabelThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get periodLabelThisWeek;

  /// No description provided for @avgPerDay.
  ///
  /// In en, this message translates to:
  /// **'/ day avg'**
  String get avgPerDay;

  /// No description provided for @totalCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Count'**
  String get totalCountLabel;

  /// No description provided for @activeTypesLabel.
  ///
  /// In en, this message translates to:
  /// **'Active Types'**
  String get activeTypesLabel;

  /// No description provided for @dayByDayLogSection.
  ///
  /// In en, this message translates to:
  /// **'Day-by-Day Log'**
  String get dayByDayLogSection;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30Days;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @showAllDays.
  ///
  /// In en, this message translates to:
  /// **'Show all {count} days'**
  String showAllDays(Object count);

  /// No description provided for @noCountsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No counts recorded'**
  String get noCountsRecorded;

  /// No description provided for @allTimeTotalsSection.
  ///
  /// In en, this message translates to:
  /// **'All-Time Totals'**
  String get allTimeTotalsSection;

  /// No description provided for @grandTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'{total} total'**
  String grandTotalLabel(Object total);

  /// No description provided for @allTimeEmptyState.
  ///
  /// In en, this message translates to:
  /// **'Start counting to see your all-time stats.'**
  String get allTimeEmptyState;

  /// No description provided for @analyticsWeekBarLabel.
  ///
  /// In en, this message translates to:
  /// **'W{n}'**
  String analyticsWeekBarLabel(Object n);

  /// No description provided for @colorMint.
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get colorMint;

  /// No description provided for @colorSky.
  ///
  /// In en, this message translates to:
  /// **'Sky'**
  String get colorSky;

  /// No description provided for @colorSand.
  ///
  /// In en, this message translates to:
  /// **'Sand'**
  String get colorSand;

  /// No description provided for @colorLavender.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get colorLavender;

  /// No description provided for @colorAqua.
  ///
  /// In en, this message translates to:
  /// **'Aqua'**
  String get colorAqua;

  /// No description provided for @colorCream.
  ///
  /// In en, this message translates to:
  /// **'Cream'**
  String get colorCream;

  /// No description provided for @colorRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get colorRose;

  /// No description provided for @colorPeriwinkle.
  ///
  /// In en, this message translates to:
  /// **'Periwinkle'**
  String get colorPeriwinkle;

  /// No description provided for @colorLime.
  ///
  /// In en, this message translates to:
  /// **'Lime'**
  String get colorLime;

  /// No description provided for @colorTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get colorTeal;

  /// No description provided for @colorCoral.
  ///
  /// In en, this message translates to:
  /// **'Coral'**
  String get colorCoral;

  /// No description provided for @colorViolet.
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get colorViolet;

  /// No description provided for @addDhikirAppBarUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get addDhikirAppBarUpdate;

  /// No description provided for @addDhikirEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Dhikir'**
  String get addDhikirEditTitle;

  /// No description provided for @addDhikirNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Dhikir'**
  String get addDhikirNewTitle;

  /// No description provided for @addDhikirEditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your dhikir'**
  String get addDhikirEditSubtitle;

  /// No description provided for @addDhikirNewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a personal dhikir'**
  String get addDhikirNewSubtitle;

  /// No description provided for @chooseIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose Icon'**
  String get chooseIconLabel;

  /// No description provided for @chooseColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose Color'**
  String get chooseColorLabel;

  /// No description provided for @dhikirDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Dhikir Details'**
  String get dhikirDetailsSection;

  /// No description provided for @titleFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleFieldLabel;

  /// No description provided for @titleFieldHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. SubhanAllah'**
  String get titleFieldHint;

  /// No description provided for @titleRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequiredError;

  /// No description provided for @titleTooShortError.
  ///
  /// In en, this message translates to:
  /// **'Title must be at least 2 characters'**
  String get titleTooShortError;

  /// No description provided for @titleTooLongError.
  ///
  /// In en, this message translates to:
  /// **'Title too long (max 60 characters)'**
  String get titleTooLongError;

  /// No description provided for @arabicTextFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Arabic Text'**
  String get arabicTextFieldLabel;

  /// No description provided for @arabicTextFieldHint.
  ///
  /// In en, this message translates to:
  /// **'سُبْحَانَ اللّهِ'**
  String get arabicTextFieldHint;

  /// No description provided for @arabicTextRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Arabic text is required'**
  String get arabicTextRequiredError;

  /// No description provided for @transliterationFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Transliteration (English)'**
  String get transliterationFieldLabel;

  /// No description provided for @transliterationFieldHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Subḥān Allāh'**
  String get transliterationFieldHint;

  /// No description provided for @transliterationRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Transliteration is required'**
  String get transliterationRequiredError;

  /// No description provided for @meaningFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Meaning / Description'**
  String get meaningFieldLabel;

  /// No description provided for @meaningFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Explain the significance of this dhikir...'**
  String get meaningFieldHint;

  /// No description provided for @meaningRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Meaning is required'**
  String get meaningRequiredError;

  /// No description provided for @meaningTooShortError.
  ///
  /// In en, this message translates to:
  /// **'Please provide a more detailed meaning'**
  String get meaningTooShortError;

  /// No description provided for @previewSection.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewSection;

  /// No description provided for @previewDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Dhikir'**
  String get previewDefaultTitle;

  /// No description provided for @previewDefaultArabic.
  ///
  /// In en, this message translates to:
  /// **'النص العربي'**
  String get previewDefaultArabic;

  /// No description provided for @previewDefaultTransliteration.
  ///
  /// In en, this message translates to:
  /// **'transliteration'**
  String get previewDefaultTransliteration;

  /// No description provided for @addDhikirUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update Dhikir'**
  String get addDhikirUpdateButton;

  /// No description provided for @addDhikirSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Dhikir'**
  String get addDhikirSaveButton;

  /// No description provided for @deleteDhikirTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{title}”?'**
  String deleteDhikirTitle(Object title);

  /// No description provided for @deleteDhikirBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this dhikir. Progress data will remain.'**
  String get deleteDhikirBody;

  /// No description provided for @myDhikirCountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} custom dhikir'**
  String myDhikirCountSubtitle(Object count);

  /// No description provided for @myDhikirEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No custom dhikir yet'**
  String get myDhikirEmptyTitle;

  /// No description provided for @myDhikirEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the Add button to create your first dhikir'**
  String get myDhikirEmptySubtitle;

  /// No description provided for @myDhikirStartSession.
  ///
  /// In en, this message translates to:
  /// **'Start Session — All {count} Dhikir'**
  String myDhikirStartSession(Object count);

  /// No description provided for @unfavAction.
  ///
  /// In en, this message translates to:
  /// **'Unfav'**
  String get unfavAction;

  /// No description provided for @favouriteAction.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get favouriteAction;

  /// No description provided for @prayerNameFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerNameFajr;

  /// No description provided for @prayerNameDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerNameDhuhr;

  /// No description provided for @prayerNameAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerNameAsr;

  /// No description provided for @prayerNameMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerNameMaghrib;

  /// No description provided for @prayerNameIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerNameIsha;

  /// No description provided for @prayerNameSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get prayerNameSunrise;

  /// No description provided for @prayerNameSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get prayerNameSunset;

  /// No description provided for @prayerNameZawal.
  ///
  /// In en, this message translates to:
  /// **'Zawal'**
  String get prayerNameZawal;

  /// No description provided for @prayerNameTahajjud.
  ///
  /// In en, this message translates to:
  /// **'Tahajjud'**
  String get prayerNameTahajjud;

  /// No description provided for @prayerNameIshraq.
  ///
  /// In en, this message translates to:
  /// **'Ishraq'**
  String get prayerNameIshraq;

  /// No description provided for @prayerNameChasht.
  ///
  /// In en, this message translates to:
  /// **'Chasht'**
  String get prayerNameChasht;

  /// No description provided for @todaysScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Today’s Schedule'**
  String get todaysScheduleTitle;

  /// No description provided for @tomorrowsScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow’s Schedule'**
  String get tomorrowsScheduleTitle;

  /// No description provided for @iftarStartsIn.
  ///
  /// In en, this message translates to:
  /// **'Iftar starts in'**
  String get iftarStartsIn;

  /// No description provided for @sehriEndsIn.
  ///
  /// In en, this message translates to:
  /// **'Sehri ends in'**
  String get sehriEndsIn;

  /// No description provided for @notifChannelName.
  ///
  /// In en, this message translates to:
  /// **'Prayer time reminders'**
  String get notifChannelName;

  /// No description provided for @notifChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Notifies you at the start of each prayer time'**
  String get notifChannelDescription;

  /// No description provided for @notifSilentChannelName.
  ///
  /// In en, this message translates to:
  /// **'Prayer time reminders (silent)'**
  String get notifSilentChannelName;

  /// No description provided for @notifSilentChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Notifies you at the start of each prayer time, without sound'**
  String get notifSilentChannelDescription;

  /// No description provided for @notifPrayerTitle.
  ///
  /// In en, this message translates to:
  /// **'{label} prayer time'**
  String notifPrayerTitle(Object label);

  /// No description provided for @notifPrayerBody.
  ///
  /// In en, this message translates to:
  /// **'It’s time for {label}.'**
  String notifPrayerBody(Object label);

  /// No description provided for @notifOptionalBody.
  ///
  /// In en, this message translates to:
  /// **'Time for {label}.'**
  String notifOptionalBody(Object label);

  /// No description provided for @alarmSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Alarm'**
  String get alarmSectionTitle;

  /// No description provided for @alarmFullWithAdhan.
  ///
  /// In en, this message translates to:
  /// **'Full alarm with Adhan'**
  String get alarmFullWithAdhan;

  /// No description provided for @alarmStateOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get alarmStateOn;

  /// No description provided for @alarmStateOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get alarmStateOff;

  /// No description provided for @alarmTimeOffset.
  ///
  /// In en, this message translates to:
  /// **'Alarm time offset'**
  String get alarmTimeOffset;

  /// No description provided for @alarmOffsetOnTime.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get alarmOffsetOnTime;

  /// No description provided for @alarmOffsetMinutesPlus.
  ///
  /// In en, this message translates to:
  /// **'+{minutes} min'**
  String alarmOffsetMinutesPlus(Object minutes);

  /// No description provided for @alarmOffsetMinutesMinus.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String alarmOffsetMinutesMinus(Object minutes);

  /// No description provided for @alarmVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get alarmVibration;

  /// No description provided for @alarmFullScreen.
  ///
  /// In en, this message translates to:
  /// **'Full-screen alarm'**
  String get alarmFullScreen;

  /// No description provided for @alarmFullScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show a lock-screen alert when the alarm fires'**
  String get alarmFullScreenSubtitle;

  /// No description provided for @alarmExactPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Exact alarms are off'**
  String get alarmExactPermissionTitle;

  /// No description provided for @alarmExactPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Allow exact alarms in system settings so this prayer alarm fires on time.'**
  String get alarmExactPermissionBody;

  /// No description provided for @alarmFullScreenPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Full-screen alerts are off'**
  String get alarmFullScreenPermissionTitle;

  /// No description provided for @alarmFullScreenPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Allow full-screen alerts in system settings so this alarm can show over the lock screen. It still rings as a notification either way.'**
  String get alarmFullScreenPermissionBody;

  /// No description provided for @hijriOffsetDayLabel.
  ///
  /// In en, this message translates to:
  /// **'{days} Day'**
  String hijriOffsetDayLabel(Object days);

  /// No description provided for @hijriOffsetDayLabelPlus.
  ///
  /// In en, this message translates to:
  /// **'+{days} Day'**
  String hijriOffsetDayLabelPlus(Object days);

  /// No description provided for @hijriEraSuffix.
  ///
  /// In en, this message translates to:
  /// **' AH'**
  String get hijriEraSuffix;

  /// No description provided for @hijriSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Hijri Date Settings'**
  String get hijriSettingsTitle;

  /// No description provided for @hijriInfoBanner.
  ///
  /// In en, this message translates to:
  /// **'Since the Hijri date depends on moonsighting, the calculated date may differ by a day. You may need to check and correct this each month to match your local community.'**
  String get hijriInfoBanner;

  /// No description provided for @hijriAdjustmentSection.
  ///
  /// In en, this message translates to:
  /// **'Hijri Date Adjustment'**
  String get hijriAdjustmentSection;

  /// No description provided for @hijriDayStartSection.
  ///
  /// In en, this message translates to:
  /// **'New Hijri Day Starts At'**
  String get hijriDayStartSection;

  /// No description provided for @hijriDayStartMidnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight (12:00 AM)'**
  String get hijriDayStartMidnight;

  /// No description provided for @hijriDayStartSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset (Maghrib)'**
  String get hijriDayStartSunset;

  /// No description provided for @prayerTimesTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerTimesTitle;

  /// No description provided for @prayerSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Prayer settings'**
  String get prayerSettingsTooltip;

  /// No description provided for @locationDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied. Open Settings to enable it.'**
  String get locationDeniedMessage;

  /// No description provided for @locationRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to calculate prayer times.'**
  String get locationRequiredMessage;

  /// No description provided for @enableLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Enable location'**
  String get enableLocationButton;

  /// No description provided for @previousDayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDayTooltip;

  /// No description provided for @nextDayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDayTooltip;

  /// No description provided for @markerMiddleOfNight.
  ///
  /// In en, this message translates to:
  /// **'Middle of night'**
  String get markerMiddleOfNight;

  /// No description provided for @markerLastThirdOfNight.
  ///
  /// In en, this message translates to:
  /// **'Last third of night'**
  String get markerLastThirdOfNight;

  /// No description provided for @notificationTooltip.
  ///
  /// In en, this message translates to:
  /// **'{name} notification'**
  String notificationTooltip(Object name);

  /// No description provided for @untilTime.
  ///
  /// In en, this message translates to:
  /// **'Until {time}'**
  String untilTime(Object time);

  /// No description provided for @prayerSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Settings'**
  String get prayerSettingsTitle;

  /// No description provided for @notificationsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSectionTitle;

  /// No description provided for @notificationsOptionalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional — off by default'**
  String get notificationsOptionalSubtitle;

  /// No description provided for @madhabSection.
  ///
  /// In en, this message translates to:
  /// **'Madhab (Asr calculation)'**
  String get madhabSection;

  /// No description provided for @madhabHanafi.
  ///
  /// In en, this message translates to:
  /// **'Hanafi'**
  String get madhabHanafi;

  /// No description provided for @madhabShafi.
  ///
  /// In en, this message translates to:
  /// **'Shafi'**
  String get madhabShafi;

  /// No description provided for @forbiddenMorning.
  ///
  /// In en, this message translates to:
  /// **'Forbidden Time (Morning)'**
  String get forbiddenMorning;

  /// No description provided for @forbiddenNoon.
  ///
  /// In en, this message translates to:
  /// **'Forbidden Time (Noon)'**
  String get forbiddenNoon;

  /// No description provided for @forbiddenEvening.
  ///
  /// In en, this message translates to:
  /// **'Forbidden Time (Evening)'**
  String get forbiddenEvening;

  /// No description provided for @todaysForbiddenTimesSection.
  ///
  /// In en, this message translates to:
  /// **'Today’s Forbidden Times'**
  String get todaysForbiddenTimesSection;

  /// No description provided for @notifOffDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off'**
  String get notifOffDialogTitle;

  /// No description provided for @notifOffDialogBody.
  ///
  /// In en, this message translates to:
  /// **'To get prayer time reminders, allow notifications for this app in system settings.'**
  String get notifOffDialogBody;

  /// No description provided for @notNowButton.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNowButton;

  /// No description provided for @notificationSwitchTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationSwitchTitle;

  /// No description provided for @notificationOnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You will be notified'**
  String get notificationOnSubtitle;

  /// No description provided for @notificationOffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notification is off'**
  String get notificationOffSubtitle;

  /// No description provided for @soundSection.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get soundSection;

  /// No description provided for @soundDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get soundDefault;

  /// No description provided for @soundSilent.
  ///
  /// In en, this message translates to:
  /// **'Silent'**
  String get soundSilent;

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} Hour {minutes} Minutes'**
  String durationHoursMinutes(Object hours, Object minutes);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} Minutes'**
  String durationMinutes(Object minutes);

  /// No description provided for @nextPrayerSection.
  ///
  /// In en, this message translates to:
  /// **'Next Prayer'**
  String get nextPrayerSection;

  /// No description provided for @sehriEndLabel.
  ///
  /// In en, this message translates to:
  /// **'Sehri End'**
  String get sehriEndLabel;

  /// No description provided for @iftarLabel.
  ///
  /// In en, this message translates to:
  /// **'Iftar'**
  String get iftarLabel;

  /// No description provided for @countdownRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time Remaining: {hours} Hour {minutes} Minutes'**
  String countdownRemaining(Object hours, Object minutes);

  /// No description provided for @countdownRemainingMinutes.
  ///
  /// In en, this message translates to:
  /// **'Time Remaining: {minutes} Minutes'**
  String countdownRemainingMinutes(Object minutes);

  /// No description provided for @semanticsLocationDeviceOff.
  ///
  /// In en, this message translates to:
  /// **'Prayer times unavailable. Enable device location.'**
  String get semanticsLocationDeviceOff;

  /// No description provided for @semanticsLocationPermOff.
  ///
  /// In en, this message translates to:
  /// **'Prayer times unavailable. Enable location permission.'**
  String get semanticsLocationPermOff;

  /// No description provided for @semanticsLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Prayer times unavailable. Unable to determine location.'**
  String get semanticsLocationUnavailable;

  /// No description provided for @semanticsCalcUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to calculate prayer times.'**
  String get semanticsCalcUnavailable;

  /// No description provided for @semanticsFinding.
  ///
  /// In en, this message translates to:
  /// **'Finding prayer times.'**
  String get semanticsFinding;

  /// No description provided for @semanticsForbidden.
  ///
  /// In en, this message translates to:
  /// **'Forbidden prayer time: {name}.'**
  String semanticsForbidden(Object name);

  /// No description provided for @semanticsNextPrayer.
  ///
  /// In en, this message translates to:
  /// **' Next prayer {name}.'**
  String semanticsNextPrayer(Object name);

  /// No description provided for @semanticsPrayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Prayer times.'**
  String get semanticsPrayerTimes;

  /// No description provided for @semanticsCurrentPrayer.
  ///
  /// In en, this message translates to:
  /// **'Current prayer {name}, {percent} percent through.'**
  String semanticsCurrentPrayer(Object name, Object percent);

  /// No description provided for @enableLocationMessage.
  ///
  /// In en, this message translates to:
  /// **'Enable device location to see prayer times'**
  String get enableLocationMessage;

  /// No description provided for @locationDeniedTapSettings.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied. Tap to open Settings.'**
  String get locationDeniedTapSettings;

  /// No description provided for @enableLocationShort.
  ///
  /// In en, this message translates to:
  /// **'Enable location to see prayer times'**
  String get enableLocationShort;

  /// No description provided for @unableToDetermineLocation.
  ///
  /// In en, this message translates to:
  /// **'Unable to determine location'**
  String get unableToDetermineLocation;

  /// No description provided for @unableToCalculate.
  ///
  /// In en, this message translates to:
  /// **'Unable to calculate prayer times'**
  String get unableToCalculate;

  /// No description provided for @findingPrayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Finding prayer times…'**
  String get findingPrayerTimes;

  /// No description provided for @endsInLabel.
  ///
  /// In en, this message translates to:
  /// **'Ends {duration}'**
  String endsInLabel(Object duration);

  /// No description provided for @nextPrayerInline.
  ///
  /// In en, this message translates to:
  /// **'Next: {name} {duration}'**
  String nextPrayerInline(Object name, Object duration);

  /// No description provided for @currentPrayerSection.
  ///
  /// In en, this message translates to:
  /// **'Current Prayer'**
  String get currentPrayerSection;

  /// No description provided for @sessionCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Session ({count})'**
  String sessionCountLabel(Object count);

  /// No description provided for @ofTarget.
  ///
  /// In en, this message translates to:
  /// **'of {target}'**
  String ofTarget(Object target);

  /// No description provided for @ofUnlimited.
  ///
  /// In en, this message translates to:
  /// **'of ∞'**
  String get ofUnlimited;

  /// No description provided for @dhikirSubhanallahTitle.
  ///
  /// In en, this message translates to:
  /// **'Subhanallah'**
  String get dhikirSubhanallahTitle;

  /// No description provided for @dhikirSubhanallahTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Subḥān Allāh'**
  String get dhikirSubhanallahTransliteration;

  /// No description provided for @dhikirSubhanallahMeaning.
  ///
  /// In en, this message translates to:
  /// **'Glory be to Allah. This dhikir is a declaration of Allah’s perfection and freedom from any imperfection or deficiency. It is one of the most beloved phrases to Allah.'**
  String get dhikirSubhanallahMeaning;

  /// No description provided for @dhikirAlhamdulillahTitle.
  ///
  /// In en, this message translates to:
  /// **'Alhamdulillah'**
  String get dhikirAlhamdulillahTitle;

  /// No description provided for @dhikirAlhamdulillahTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Al-Ḥamdu lillāh'**
  String get dhikirAlhamdulillahTransliteration;

  /// No description provided for @dhikirAlhamdulillahMeaning.
  ///
  /// In en, this message translates to:
  /// **'All praise is due to Allah. This is an expression of gratitude and praise to Allah for all His blessings, both visible and hidden.'**
  String get dhikirAlhamdulillahMeaning;

  /// No description provided for @dhikirAllahuakbarTitle.
  ///
  /// In en, this message translates to:
  /// **'Allahu Akbar'**
  String get dhikirAllahuakbarTitle;

  /// No description provided for @dhikirAllahuakbarTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Allāhu Akbar'**
  String get dhikirAllahuakbarTransliteration;

  /// No description provided for @dhikirAllahuakbarMeaning.
  ///
  /// In en, this message translates to:
  /// **'Allah is the Greatest. This declaration affirms that Allah is greater than everything — greater than our worries, our problems, and anything in existence.'**
  String get dhikirAllahuakbarMeaning;

  /// No description provided for @dhikirLailahaillallahTitle.
  ///
  /// In en, this message translates to:
  /// **'Lā ilāha ill-Allāh'**
  String get dhikirLailahaillallahTitle;

  /// No description provided for @dhikirLailahaillallahTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Lā ilāha illā Allāh'**
  String get dhikirLailahaillallahTransliteration;

  /// No description provided for @dhikirLailahaillallahMeaning.
  ///
  /// In en, this message translates to:
  /// **'There is no god but Allah. This is the foundation of Islamic faith — the testimony that no one is worthy of worship except Allah alone.'**
  String get dhikirLailahaillallahMeaning;

  /// No description provided for @dhikirAstaghfirullahTitle.
  ///
  /// In en, this message translates to:
  /// **'Astaghfirullah'**
  String get dhikirAstaghfirullahTitle;

  /// No description provided for @dhikirAstaghfirullahTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Astaghfiru Allāh'**
  String get dhikirAstaghfirullahTransliteration;

  /// No description provided for @dhikirAstaghfirullahMeaning.
  ///
  /// In en, this message translates to:
  /// **'I seek forgiveness from Allah. Seeking forgiveness regularly cleanses the heart, brings peace, and opens the doors of mercy and provision.'**
  String get dhikirAstaghfirullahMeaning;

  /// No description provided for @dhikirSalawatTitle.
  ///
  /// In en, this message translates to:
  /// **'Salawat'**
  String get dhikirSalawatTitle;

  /// No description provided for @dhikirSalawatTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Allāhumma ṣalli ’alā Muḥammad'**
  String get dhikirSalawatTransliteration;

  /// No description provided for @dhikirSalawatMeaning.
  ///
  /// In en, this message translates to:
  /// **'O Allah, send blessings upon Muhammad. Sending blessings upon the Prophet ﷺ earns tremendous reward and brings the sender closer to the Prophet on the Day of Judgment.'**
  String get dhikirSalawatMeaning;

  /// No description provided for @dhikirHasbunallahTitle.
  ///
  /// In en, this message translates to:
  /// **'Hasbunallah'**
  String get dhikirHasbunallahTitle;

  /// No description provided for @dhikirHasbunallahTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Ḥasbunā Allāh wa ni’ma al-Wakīl'**
  String get dhikirHasbunallahTransliteration;

  /// No description provided for @dhikirHasbunallahMeaning.
  ///
  /// In en, this message translates to:
  /// **'Allah is sufficient for us and He is the best disposer of affairs. This dhikir is a powerful expression of trust and reliance on Allah in times of difficulty.'**
  String get dhikirHasbunallahMeaning;

  /// No description provided for @dhikirLahawlaTitle.
  ///
  /// In en, this message translates to:
  /// **'La Hawla Wala Quwwata'**
  String get dhikirLahawlaTitle;

  /// No description provided for @dhikirLahawlaTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Lā ḥawla wa lā quwwata illā billāh'**
  String get dhikirLahawlaTransliteration;

  /// No description provided for @dhikirLahawlaMeaning.
  ///
  /// In en, this message translates to:
  /// **'There is no power or might except with Allah. This phrase is a treasure from the treasures of Paradise and a protection against anxiety and hardship.'**
  String get dhikirLahawlaMeaning;

  /// No description provided for @dhikirAllahummaInnakaAfuwwunTitle.
  ///
  /// In en, this message translates to:
  /// **'Allahumma Innaka ’Afuwwun'**
  String get dhikirAllahummaInnakaAfuwwunTitle;

  /// No description provided for @dhikirAllahummaInnakaAfuwwunTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Allahumma innaka ʿafuwwun tuḥibbul-ʿafwa faʿfu ʿannī'**
  String get dhikirAllahummaInnakaAfuwwunTransliteration;

  /// No description provided for @dhikirAllahummaInnakaAfuwwunMeaning.
  ///
  /// In en, this message translates to:
  /// **'O Allah, You are Most Forgiving and You love forgiveness, so forgive me. This duʿāʾ nurtures humility and invites Allah’s mercy.'**
  String get dhikirAllahummaInnakaAfuwwunMeaning;

  /// No description provided for @dhikirLaIlahaIllallahWahdahuTitle.
  ///
  /// In en, this message translates to:
  /// **'Lā ilāha ill-Allāh wahdahu'**
  String get dhikirLaIlahaIllallahWahdahuTitle;

  /// No description provided for @dhikirLaIlahaIllallahWahdahuTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Lā ilāha ill-Allāh waḥdahu lā sharīka lah, lahul-mulku wa lahul-ḥamd, yuḥyī wa yumīt, wa huwa ʿalā kulli shayʾIn qadīr'**
  String get dhikirLaIlahaIllallahWahdahuTransliteration;

  /// No description provided for @dhikirLaIlahaIllallahWahdahuMeaning.
  ///
  /// In en, this message translates to:
  /// **'There is no deity worthy of worship except Allah alone, without partner. To Him belongs sovereignty and praise. He gives life and causes death, and He has power over all things.'**
  String get dhikirLaIlahaIllallahWahdahuMeaning;

  /// No description provided for @dhikirSubhanallahiWaBihamdihiTitle.
  ///
  /// In en, this message translates to:
  /// **'Subhanallahi wa Bihamdihi'**
  String get dhikirSubhanallahiWaBihamdihiTitle;

  /// No description provided for @dhikirSubhanallahiWaBihamdihiTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Subḥānallāhi wa biḥamdih'**
  String get dhikirSubhanallahiWaBihamdihiTransliteration;

  /// No description provided for @dhikirSubhanallahiWaBihamdihiMeaning.
  ///
  /// In en, this message translates to:
  /// **'Glory be to Allah and all praise is His. A simple yet powerful remembrance that brings forgiveness and lightness to the heart.'**
  String get dhikirSubhanallahiWaBihamdihiMeaning;

  /// No description provided for @dhikirSubhanallahilAzeemTitle.
  ///
  /// In en, this message translates to:
  /// **'Subhanallahil Azeem'**
  String get dhikirSubhanallahilAzeemTitle;

  /// No description provided for @dhikirSubhanallahilAzeemTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Subḥānallāhil-ʿAẓīm'**
  String get dhikirSubhanallahilAzeemTransliteration;

  /// No description provided for @dhikirSubhanallahilAzeemMeaning.
  ///
  /// In en, this message translates to:
  /// **'Glory be to Allah, the Most Great. This dhikr instills awe of Allah’s greatness and strengthens faith.'**
  String get dhikirSubhanallahilAzeemMeaning;

  /// No description provided for @dhikirSayyidulIstighfarExtendedTitle.
  ///
  /// In en, this message translates to:
  /// **'Astaghfirullah wa Atubu Ilayh'**
  String get dhikirSayyidulIstighfarExtendedTitle;

  /// No description provided for @dhikirSayyidulIstighfarExtendedTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Astaghfirullāhal-ladhī lā ilāha illā huwal-ḥayyul-qayyūm wa atūbu ilayh'**
  String get dhikirSayyidulIstighfarExtendedTransliteration;

  /// No description provided for @dhikirSayyidulIstighfarExtendedMeaning.
  ///
  /// In en, this message translates to:
  /// **'I seek forgiveness from Allah, besides whom there is no deity, the Ever-Living, the Sustainer, and I repent to Him.'**
  String get dhikirSayyidulIstighfarExtendedMeaning;

  /// No description provided for @dhikirSalawatOnNabiTitle.
  ///
  /// In en, this message translates to:
  /// **'Salawat on the Prophet ﷺ'**
  String get dhikirSalawatOnNabiTitle;

  /// No description provided for @dhikirSalawatOnNabiTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Allāhumma ṣalli wa sallim ʿalā nabiyyinā Muḥammad'**
  String get dhikirSalawatOnNabiTransliteration;

  /// No description provided for @dhikirSalawatOnNabiMeaning.
  ///
  /// In en, this message translates to:
  /// **'O Allah, send Your peace and blessings upon our Prophet Muhammad. Sending salawat brings blessings and closeness to the Prophet ﷺ.'**
  String get dhikirSalawatOnNabiMeaning;
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
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
