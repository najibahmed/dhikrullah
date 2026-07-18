// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get commonCancel => 'বাতিল';

  @override
  String get commonDelete => 'মুছে ফেলুন';

  @override
  String get commonSave => 'সংরক্ষণ করুন';

  @override
  String get commonReset => 'রিসেট';

  @override
  String get commonDone => 'সম্পন্ন';

  @override
  String get commonRetry => 'আবার চেষ্টা করুন';

  @override
  String get commonToday => 'আজ';

  @override
  String get commonYesterday => 'গতকাল';

  @override
  String get commonEdit => 'সম্পাদনা';

  @override
  String get commonAdd => 'যোগ করুন';

  @override
  String get thisMonthLabel => 'এই মাস';

  @override
  String get openSettingsButton => 'সেটিংসে যান';

  @override
  String forbiddenTimeLabel(Object name) {
    return 'নিষিদ্ধ সময় · $name';
  }

  @override
  String startFullSessionButton(Object count) {
    return 'সম্পূর্ণ সেশন শুরু করুন — $countটি যিকির';
  }

  @override
  String get allDhikirSectionTitle => 'সব যিকির';

  @override
  String get tapNoLimit => 'গণনা করতে ট্যাপ করুন — কোনো সীমা নেই';

  @override
  String remainingCount(Object count) {
    return '$count বাকি';
  }

  @override
  String get resetTodayCountTitle => 'আজকের কাউন্ট রিসেট করবেন?';

  @override
  String goalLabelTimes(Object goal) {
    return '$goal বার';
  }

  @override
  String get goalLabelUnlimited => 'সীমাহীন';

  @override
  String get setUnlimitedButton => 'সীমাহীন নির্ধারণ করুন';

  @override
  String setGoalButton(Object label) {
    return 'লক্ষ্য নির্ধারণ করুন: $label';
  }

  @override
  String get goalSubtitleTasbihSubhanallah => 'তাসবীহ — সুবহানাল্লাহ';

  @override
  String get goalSubtitleTasbihAlhamdulillah => 'তাসবীহ — আলহামদুলিল্লাহ';

  @override
  String get goalSubtitleNamesOfAllah => 'আল্লাহর নাম';

  @override
  String get goalSubtitleDailyCentury => 'দৈনিক ১০০ লক্ষ্য';

  @override
  String get goalSubtitleNoLimit => 'কোনো সীমা নেই — স্বাধীনভাবে গণনা করুন';

  @override
  String get aboutTitle => 'সম্পর্কে';

  @override
  String get aboutAppName => 'Daily Dhikir';

  @override
  String aboutVersion(Object version) {
    return 'সংস্করণ $version';
  }

  @override
  String get aboutDescription => '৩০ দিনের ট্র্যাকিংসহ একটি দৈনিক যিকির অ্যাপ';

  @override
  String get aboutDeveloper => 'ডেভেলপার';

  @override
  String get aboutDeveloperNamePlaceholder =>
      'ডেভেলপারের নাম — শীঘ্রই যুক্ত হবে';

  @override
  String get aboutBioPlaceholder => 'সংক্ষিপ্ত পরিচিতি — শীঘ্রই যুক্ত হবে';

  @override
  String get aboutContactPlaceholder => 'যোগাযোগ — শীঘ্রই যুক্ত হবে';

  @override
  String get settingsLanguage => 'ভাষা';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageBangla => 'বাংলা';

  @override
  String get settingsLanguageSystem => 'সিস্টেম ডিফল্ট';

  @override
  String get settingsLanguageDialogTitle => 'ভাষা নির্বাচন করুন';

  @override
  String get qiblaTitle => 'কিবলা কম্পাস';

  @override
  String get qiblaComingSoon => 'শীঘ্রই আসছে';

  @override
  String get favoritesEmptyTitle => 'এখনও কোনো প্রিয় যিকির নেই';

  @override
  String get favoritesEmptySubtitle =>
      'আপনার যিকির প্রিয় তালিকায় যুক্ত করতে হার্ট আইকনে ট্যাপ করুন';

  @override
  String get favoritesCustomSectionTitle => 'কাস্টম প্রিয় যিকির';

  @override
  String get favoritesSectionTitle => 'প্রিয় যিকির';

  @override
  String get navHome => 'হোম';

  @override
  String get navCounter => 'কাউন্টার';

  @override
  String get navFavorites => 'প্রিয়';

  @override
  String get navMyDhikir => 'আমার যিকির';

  @override
  String get homeSectionTitle => 'দৈনিক যিকির';

  @override
  String todayCountBadge(Object count) {
    return '$count× আজ';
  }

  @override
  String get quickActionsTitle => 'দ্রুত কার্যক্রম';

  @override
  String get quickActionPrayerTime => 'সালাতের সময়';

  @override
  String get quickActionQibla => 'কিবলা';

  @override
  String get themeToggleSwitchToLight => 'লাইট মোডে যান';

  @override
  String get themeToggleSwitchToDark => 'ডার্ক মোডে যান';

  @override
  String get resetTodayCountBody =>
      'এটি আজকের ট্যাপ কাউন্টার শূন্যে রিসেট করবে।';

  @override
  String get resetMonthTitle => 'এই মাস রিসেট করবেন?';

  @override
  String get resetMonthBody => 'এটি এই মাসের সব চেকমার্ক মুছে ফেলবে।';

  @override
  String daysCompletedLabel(Object completed, Object total) {
    return '$completed / $total দিন';
  }

  @override
  String get pillArabic => 'আরবি';

  @override
  String get pillMeaning => 'অর্থ ও তাৎপর্য';

  @override
  String get pillTodayCounter => 'আজকের কাউন্টার';

  @override
  String get goalUnlimited => 'লক্ষ্য: ∞';

  @override
  String goalTarget(Object target) {
    return 'লক্ষ্য: $target';
  }

  @override
  String goalReachedBannerDetail(Object target) {
    return 'মাশাআল্লাহ! আজ $target সম্পন্ন হয়েছে';
  }

  @override
  String get historyButton => 'ইতিহাস';

  @override
  String get legendDone => 'সম্পন্ন';

  @override
  String get legendPending => 'অপেক্ষমাণ';

  @override
  String get legendFuture => 'ভবিষ্যৎ';

  @override
  String get calendarTitle => 'ইতিহাস ক্যালেন্ডার';

  @override
  String resetMonthDialogTitle(Object month) {
    return '$month রিসেট করবেন?';
  }

  @override
  String get resetMonthDialogBody =>
      'এটি শুধুমাত্র এই মাসের সব চেকমার্ক মুছে ফেলবে।';

  @override
  String get resetMonthButton => 'মাস রিসেট করুন';

  @override
  String get legendCompleted => 'সম্পন্ন';

  @override
  String get legendMissed => 'মিস হয়েছে';

  @override
  String monthSummary(Object completed, Object total, Object pct) {
    return 'এই মাস: $completed / $total দিন ($pct%)';
  }

  @override
  String daysCountLabel(Object count) {
    return '$count দিন';
  }

  @override
  String daysCountShort(Object count) {
    return '$count দিন';
  }

  @override
  String get statStreak => '🔥 ধারাবাহিকতা';

  @override
  String get statBest => 'সেরা';

  @override
  String get yearOverviewTitle => 'বছরের পর্যালোচনা';

  @override
  String calendarFooter(Object total) {
    return 'মাসে যেতে ট্যাপ করুন  •  মোট: $total দিন';
  }

  @override
  String resetMonthProgressButton(Object month) {
    return '$month অগ্রগতি রিসেট করুন';
  }

  @override
  String counterResetBody(Object title) {
    return '$title-এর কাউন্টার রিসেট করবেন?';
  }

  @override
  String counterProgressLabel(Object current, Object total) {
    return '$total-এর মধ্যে $current নম্বর যিকির';
  }

  @override
  String counterResetHint(Object count) {
    return 'রিসেট  •  $count গণনা হয়েছে';
  }

  @override
  String counterCountedUnlimited(Object count) {
    return '$count গণনা হয়েছে';
  }

  @override
  String get counterGoalReachedBanner => 'মাশাআল্লাহ! লক্ষ্য পূর্ণ হয়েছে';

  @override
  String get sessionGoalSheetTitle => 'সেশনের লক্ষ্য নির্ধারণ করুন';

  @override
  String get sessionGoalSheetSubtitle => 'এই সেশনের সব যিকিরে প্রযোজ্য';

  @override
  String get setupGoalDescSubhanallah => 'সুবহানাল্লাহ তাসবীহ';

  @override
  String get setupGoalDescAlhamdulillah => 'আলহামদুলিল্লাহ তাসবীহ';

  @override
  String get setupGoalDescCenturyGoal => '১০০ লক্ষ্য';

  @override
  String get setupGoalDescNoLimit => 'কোনো সীমা নেই';

  @override
  String get setupSheetTitle => 'সেশন সেটআপ করুন';

  @override
  String setupSheetSubtitle(Object count) {
    return '$countটি যিকির • একটি সাধারণ লক্ষ্য বেছে নিন';
  }

  @override
  String get setupGoalPerDhikir => 'প্রতি যিকিরে লক্ষ্য';

  @override
  String get setupSessionIncludes => 'সেশনে অন্তর্ভুক্ত';

  @override
  String get setupStartUnlimited => 'শুরু করুন (সীমাহীন)';

  @override
  String setupStartGoal(Object label) {
    return 'শুরু করুন (লক্ষ্য: $label)';
  }

  @override
  String get goalPickSheetTitle => 'কাউন্টারের লক্ষ্য নির্ধারণ করুন';

  @override
  String get goalPickSheetSubtitle => 'কতবার পাঠ করবেন তা বেছে নিন';

  @override
  String get analyticsAppBarTitle => 'কাউন্টার অ্যানালিটিক্স';

  @override
  String get periodDaily => 'দৈনিক';

  @override
  String get periodWeekly => 'সাপ্তাহিক';

  @override
  String get periodMonthly => 'মাসিক';

  @override
  String get byDhikirSection => 'যিকির অনুযায়ী';

  @override
  String get colDhikir => 'যিকির';

  @override
  String get colCount => 'সংখ্যা';

  @override
  String get colDays => 'দিন';

  @override
  String get colShare => 'অংশ';

  @override
  String get periodLabelThisWeek => 'এই সপ্তাহ';

  @override
  String get avgPerDay => '/ দৈনিক গড়';

  @override
  String get totalCountLabel => 'মোট সংখ্যা';

  @override
  String get activeTypesLabel => 'সক্রিয় ধরন';

  @override
  String get dayByDayLogSection => 'দৈনিক লগ';

  @override
  String get last7Days => 'গত ৭ দিন';

  @override
  String get last30Days => 'গত ৩০ দিন';

  @override
  String get showLess => 'কম দেখুন';

  @override
  String showAllDays(Object count) {
    return 'সব $count দিন দেখুন';
  }

  @override
  String get noCountsRecorded => 'কোনো গণনা রেকর্ড করা হয়নি';

  @override
  String get allTimeTotalsSection => 'সর্বমোট';

  @override
  String grandTotalLabel(Object total) {
    return '$total মোট';
  }

  @override
  String get allTimeEmptyState => 'সর্বমোট পরিসংখ্যান দেখতে গণনা শুরু করুন।';

  @override
  String analyticsWeekBarLabel(Object n) {
    return 'W$n';
  }

  @override
  String get colorMint => 'মিন্ট';

  @override
  String get colorSky => 'আকাশি';

  @override
  String get colorSand => 'বালুকা';

  @override
  String get colorLavender => 'ল্যাভেন্ডার';

  @override
  String get colorAqua => 'অ্যাকোয়া';

  @override
  String get colorCream => 'ক্রিম';

  @override
  String get colorRose => 'গোলাপি';

  @override
  String get colorPeriwinkle => 'পেরিউইঙ্কল';

  @override
  String get colorLime => 'লাইম';

  @override
  String get colorTeal => 'টিল';

  @override
  String get colorCoral => 'কোরাল';

  @override
  String get colorViolet => 'বেগুনি';

  @override
  String get addDhikirAppBarUpdate => 'আপডেট';

  @override
  String get addDhikirEditTitle => 'যিকির সম্পাদনা করুন';

  @override
  String get addDhikirNewTitle => 'নতুন যিকির যোগ করুন';

  @override
  String get addDhikirEditSubtitle => 'আপনার যিকির আপডেট করুন';

  @override
  String get addDhikirNewSubtitle => 'একটি ব্যক্তিগত যিকির তৈরি করুন';

  @override
  String get chooseIconLabel => 'আইকন বেছে নিন';

  @override
  String get chooseColorLabel => 'রং বেছে নিন';

  @override
  String get dhikirDetailsSection => 'যিকিরের বিবরণ';

  @override
  String get titleFieldLabel => 'শিরোনাম';

  @override
  String get titleFieldHint => 'যেমন: সুবহানাল্লাহ';

  @override
  String get titleRequiredError => 'শিরোনাম আবশ্যক';

  @override
  String get titleTooShortError => 'শিরোনাম কমপক্ষে ২ অক্ষরের হতে হবে';

  @override
  String get titleTooLongError => 'শিরোনাম অনেক দীর্ঘ (সর্বোচ্চ ৬০ অক্ষর)';

  @override
  String get arabicTextFieldLabel => 'আরবি লেখা';

  @override
  String get arabicTextFieldHint => 'سُبْحَانَ اللّهِ';

  @override
  String get arabicTextRequiredError => 'আরবি লেখা আবশ্যক';

  @override
  String get transliterationFieldLabel => 'প্রতিবর্ণীকরণ (ইংরেজি)';

  @override
  String get transliterationFieldHint => 'যেমন: Subḥān Allāh';

  @override
  String get transliterationRequiredError => 'প্রতিবর্ণীকরণ আবশ্যক';

  @override
  String get meaningFieldLabel => 'অর্থ / বিবরণ';

  @override
  String get meaningFieldHint => 'এই যিকিরের তাৎপর্য ব্যাখ্যা করুন...';

  @override
  String get meaningRequiredError => 'অর্থ আবশ্যক';

  @override
  String get meaningTooShortError => 'অনুগ্রহ করে আরও বিস্তারিত অর্থ দিন';

  @override
  String get previewSection => 'প্রিভিউ';

  @override
  String get previewDefaultTitle => 'আপনার যিকির';

  @override
  String get previewDefaultArabic => 'النص العربي';

  @override
  String get previewDefaultTransliteration => 'প্রতিবর্ণীকরণ';

  @override
  String get addDhikirUpdateButton => 'যিকির আপডেট করুন';

  @override
  String get addDhikirSaveButton => 'যিকির সংরক্ষণ করুন';

  @override
  String deleteDhikirTitle(Object title) {
    return '“$title” মুছে ফেলবেন?';
  }

  @override
  String get deleteDhikirBody =>
      'এটি স্থায়ীভাবে এই যিকিরটি মুছে ফেলবে। অগ্রগতির তথ্য থেকে যাবে।';

  @override
  String myDhikirCountSubtitle(Object count) {
    return '$countটি কাস্টম যিকির';
  }

  @override
  String get myDhikirEmptyTitle => 'এখনও কোনো কাস্টম যিকির নেই';

  @override
  String get myDhikirEmptySubtitle =>
      'আপনার প্রথম যিকির তৈরি করতে Add বোতামে ট্যাপ করুন';

  @override
  String myDhikirStartSession(Object count) {
    return 'সেশন শুরু করুন — সব $countটি যিকির';
  }

  @override
  String get unfavAction => 'অপ্রিয়';

  @override
  String get favouriteAction => 'প্রিয়';

  @override
  String get prayerNameFajr => 'ফজর';

  @override
  String get prayerNameDhuhr => 'যোহর';

  @override
  String get prayerNameAsr => 'আসর';

  @override
  String get prayerNameMaghrib => 'মাগরিব';

  @override
  String get prayerNameIsha => 'এশা';

  @override
  String get prayerNameSunrise => 'সূর্যোদয়';

  @override
  String get prayerNameSunset => 'সূর্যাস্ত';

  @override
  String get prayerNameZawal => 'জাওয়াল';

  @override
  String get prayerNameTahajjud => 'তাহাজ্জুদ';

  @override
  String get prayerNameIshraq => 'ইশরাক';

  @override
  String get prayerNameChasht => 'চাশত';

  @override
  String get todaysScheduleTitle => 'আজকের সময়সূচী';

  @override
  String get tomorrowsScheduleTitle => 'আগামীকালের সময়সূচী';

  @override
  String get iftarStartsIn => 'ইফতার শুরু হবে';

  @override
  String get sehriEndsIn => 'সেহরি শেষ হবে';

  @override
  String get notifChannelName => 'সালাতের সময়ের রিমাইন্ডার';

  @override
  String get notifChannelDescription =>
      'প্রতিটি সালাতের সময় শুরুতে আপনাকে জানানো হবে';

  @override
  String get notifSilentChannelName => 'সালাতের সময়ের রিমাইন্ডার (নীরব)';

  @override
  String get notifSilentChannelDescription =>
      'শব্দ ছাড়াই প্রতিটি সালাতের সময় শুরুতে আপনাকে জানানো হবে';

  @override
  String notifPrayerTitle(Object label) {
    return '$label সালাতের সময়';
  }

  @override
  String notifPrayerBody(Object label) {
    return '$label-এর সময় হয়েছে।';
  }

  @override
  String notifOptionalBody(Object label) {
    return '$label-এর সময়।';
  }

  @override
  String hijriOffsetDayLabel(Object days) {
    return '$days দিন';
  }

  @override
  String hijriOffsetDayLabelPlus(Object days) {
    return '+$days দিন';
  }

  @override
  String get hijriEraSuffix => ' হিজরি';

  @override
  String get hijriSettingsTitle => 'হিজরি তারিখ সেটিংস';

  @override
  String get hijriInfoBanner =>
      'চাঁদ দেখার উপর নির্ভর করে হিজরি তারিখ নির্ধারিত হয় বলে গণনাকৃত তারিখ একদিন কম-বেশি হতে পারে। আপনার স্থানীয় কমিউনিটির সাথে মিলিয়ে প্রতি মাসে এটি যাচাই ও সংশোধন করতে হতে পারে।';

  @override
  String get hijriAdjustmentSection => 'হিজরি তারিখ সমন্বয়';

  @override
  String get hijriDayStartSection => 'নতুন হিজরি দিন শুরু হয়';

  @override
  String get hijriDayStartMidnight => 'মধ্যরাত (১২:০০ AM)';

  @override
  String get hijriDayStartSunset => 'সূর্যাস্ত (মাগরিব)';

  @override
  String get prayerTimesTitle => 'সালাতের সময়';

  @override
  String get prayerSettingsTooltip => 'সালাতের সেটিংস';

  @override
  String get locationDeniedMessage =>
      'লোকেশন অনুমতি প্রত্যাখ্যাত হয়েছে। এটি চালু করতে সেটিংসে যান।';

  @override
  String get locationRequiredMessage =>
      'সালাতের সময় নির্ণয়ের জন্য লোকেশন অনুমতি প্রয়োজন।';

  @override
  String get enableLocationButton => 'লোকেশন চালু করুন';

  @override
  String get previousDayTooltip => 'আগের দিন';

  @override
  String get nextDayTooltip => 'পরের দিন';

  @override
  String get markerMiddleOfNight => 'রাতের মধ্যভাগ';

  @override
  String get markerLastThirdOfNight => 'রাতের শেষ তৃতীয়াংশ';

  @override
  String notificationTooltip(Object name) {
    return '$name নোটিফিকেশন';
  }

  @override
  String untilTime(Object time) {
    return '$time পর্যন্ত';
  }

  @override
  String get prayerSettingsTitle => 'সালাতের সেটিংস';

  @override
  String get notificationsSectionTitle => 'নোটিফিকেশন';

  @override
  String get notificationsOptionalSubtitle => 'ঐচ্ছিক — ডিফল্টভাবে বন্ধ';

  @override
  String get madhabSection => 'মাযহাব (আসরের হিসাব)';

  @override
  String get madhabHanafi => 'হানাফি';

  @override
  String get madhabShafi => 'শাফি';

  @override
  String get forbiddenMorning => 'নিষিদ্ধ সময় (সকাল)';

  @override
  String get forbiddenNoon => 'নিষিদ্ধ সময় (দুপুর)';

  @override
  String get forbiddenEvening => 'নিষিদ্ধ সময় (সন্ধ্যা)';

  @override
  String get todaysForbiddenTimesSection => 'আজকের নিষিদ্ধ সময়সমূহ';

  @override
  String get notifOffDialogTitle => 'নোটিফিকেশন বন্ধ আছে';

  @override
  String get notifOffDialogBody =>
      'সালাতের সময়ের রিমাইন্ডার পেতে সিস্টেম সেটিংসে এই অ্যাপের জন্য নোটিফিকেশন চালু করুন।';

  @override
  String get notNowButton => 'এখন না';

  @override
  String get notificationSwitchTitle => 'নোটিফিকেশন';

  @override
  String get notificationOnSubtitle => 'আপনাকে জানানো হবে';

  @override
  String get notificationOffSubtitle => 'নোটিফিকেশন বন্ধ আছে';

  @override
  String get soundSection => 'শব্দ';

  @override
  String get soundDefault => 'ডিফল্ট';

  @override
  String get soundSilent => 'নীরব';

  @override
  String durationHoursMinutes(Object hours, Object minutes) {
    return '$hours ঘণ্টা $minutes মিনিট';
  }

  @override
  String durationMinutes(Object minutes) {
    return '$minutes মিনিট';
  }

  @override
  String get nextPrayerSection => 'পরবর্তী সালাত';

  @override
  String get sehriEndLabel => 'সেহরি শেষ';

  @override
  String get iftarLabel => 'ইফতার';

  @override
  String countdownRemaining(Object hours, Object minutes) {
    return 'অবশিষ্ট সময়: $hours ঘণ্টা $minutes মিনিট';
  }

  @override
  String countdownRemainingMinutes(Object minutes) {
    return 'অবশিষ্ট সময়: $minutes মিনিট';
  }

  @override
  String get semanticsLocationDeviceOff =>
      'সালাতের সময় পাওয়া যাচ্ছে না। ডিভাইসের লোকেশন চালু করুন।';

  @override
  String get semanticsLocationPermOff =>
      'সালাতের সময় পাওয়া যাচ্ছে না। লোকেশন অনুমতি চালু করুন।';

  @override
  String get semanticsLocationUnavailable =>
      'সালাতের সময় পাওয়া যাচ্ছে না। লোকেশন নির্ণয় করা যাচ্ছে না।';

  @override
  String get semanticsCalcUnavailable => 'সালাতের সময় হিসাব করা যাচ্ছে না।';

  @override
  String get semanticsFinding => 'সালাতের সময় খোঁজা হচ্ছে।';

  @override
  String semanticsForbidden(Object name) {
    return 'নিষিদ্ধ সালাতের সময়: $name।';
  }

  @override
  String semanticsNextPrayer(Object name) {
    return ' পরবর্তী সালাত $name।';
  }

  @override
  String get semanticsPrayerTimes => 'সালাতের সময়।';

  @override
  String semanticsCurrentPrayer(Object name, Object percent) {
    return 'বর্তমান সালাত $name, $percent শতাংশ অতিক্রান্ত।';
  }

  @override
  String get enableLocationMessage =>
      'সালাতের সময় দেখতে ডিভাইসের লোকেশন চালু করুন';

  @override
  String get locationDeniedTapSettings =>
      'লোকেশন অনুমতি প্রত্যাখ্যাত। সেটিংস খুলতে ট্যাপ করুন।';

  @override
  String get enableLocationShort => 'সালাতের সময় দেখতে লোকেশন চালু করুন';

  @override
  String get unableToDetermineLocation => 'লোকেশন নির্ণয় করা যাচ্ছে না';

  @override
  String get unableToCalculate => 'সালাতের সময় হিসাব করা যাচ্ছে না';

  @override
  String get findingPrayerTimes => 'সালাতের সময় খোঁজা হচ্ছে…';

  @override
  String endsInLabel(Object duration) {
    return 'শেষ হবে $duration';
  }

  @override
  String nextPrayerInline(Object name, Object duration) {
    return 'পরবর্তী: $name $duration';
  }

  @override
  String get currentPrayerSection => 'বর্তমান সালাত';

  @override
  String sessionCountLabel(Object count) {
    return 'সেশন ($count)';
  }

  @override
  String ofTarget(Object target) {
    return '$target-এর মধ্যে';
  }

  @override
  String get ofUnlimited => '∞-এর মধ্যে';

  @override
  String get dhikirSubhanallahTitle => 'সুবহানাল্লাহ';

  @override
  String get dhikirSubhanallahTransliteration => 'সুবহানাল্লাহ';

  @override
  String get dhikirSubhanallahMeaning =>
      'আল্লাহর পবিত্রতা ঘোষণা করা হয় এই যিকিরে। এটি আল্লাহর সকল ত্রুটি ও অসম্পূর্ণতা থেকে মুক্ত হওয়ার স্বীকৃতি। এটি আল্লাহর কাছে সবচেয়ে প্রিয় বাক্যগুলোর একটি।';

  @override
  String get dhikirAlhamdulillahTitle => 'আলহামদুলিল্লাহ';

  @override
  String get dhikirAlhamdulillahTransliteration => 'আলহামদুলিল্লাহ';

  @override
  String get dhikirAlhamdulillahMeaning =>
      'সকল প্রশংসা আল্লাহর জন্য। এটি আল্লাহর সকল দৃশ্য ও অদৃশ্য নিয়ামতের জন্য কৃতজ্ঞতা ও প্রশংসা প্রকাশের একটি বাক্য।';

  @override
  String get dhikirAllahuakbarTitle => 'আল্লাহু আকবার';

  @override
  String get dhikirAllahuakbarTransliteration => 'আল্লাহু আকবার';

  @override
  String get dhikirAllahuakbarMeaning =>
      'আল্লাহ সর্বশ্রেষ্ঠ। এই ঘোষণা প্রমাণ করে যে আল্লাহ সবকিছুর চেয়ে মহান — আমাদের দুশ্চিন্তা, সমস্যা এবং সৃষ্টিজগতের সবকিছুর চেয়ে।';

  @override
  String get dhikirLailahaillallahTitle => 'লা ইলাহা ইল্লাল্লাহ';

  @override
  String get dhikirLailahaillallahTransliteration => 'লা ইলাহা ইল্লাল্লাহ';

  @override
  String get dhikirLailahaillallahMeaning =>
      'আল্লাহ ছাড়া কোনো সত্য উপাস্য নেই। এটি ইসলামি বিশ্বাসের ভিত্তি — যে সাক্ষ্য দেয় একমাত্র আল্লাহ ছাড়া কেউ ইবাদতের যোগ্য নয়।';

  @override
  String get dhikirAstaghfirullahTitle => 'আস্তাগফিরুল্লাহ';

  @override
  String get dhikirAstaghfirullahTransliteration => 'আস্তাগফিরুল্লাহ';

  @override
  String get dhikirAstaghfirullahMeaning =>
      'আমি আল্লাহর কাছে ক্ষমা প্রার্থনা করছি। নিয়মিত ক্ষমা প্রার্থনা অন্তরকে পরিশুদ্ধ করে, শান্তি আনে এবং রহমত ও রিজিকের দরজা খুলে দেয়।';

  @override
  String get dhikirSalawatTitle => 'দরুদ শরীফ';

  @override
  String get dhikirSalawatTransliteration => 'দরুদ শরীফ';

  @override
  String get dhikirSalawatMeaning =>
      'হে আল্লাহ, মুহাম্মদ ﷺ-এর উপর রহমত বর্ষণ করুন। নবী ﷺ-এর উপর দরুদ পাঠ করলে অসীম সওয়াব লাভ হয় এবং কিয়ামতের দিন নবীজির নৈকট্য লাভ হয়।';

  @override
  String get dhikirHasbunallahTitle => 'হাসবুনাল্লাহ';

  @override
  String get dhikirHasbunallahTransliteration => 'হাসবুনাল্লাহ';

  @override
  String get dhikirHasbunallahMeaning =>
      'আল্লাহ আমাদের জন্য যথেষ্ট এবং তিনিই সর্বোত্তম কর্মবিধায়ক। এই যিকির কঠিন সময়ে আল্লাহর উপর ভরসা ও নির্ভরতার শক্তিশালী প্রকাশ।';

  @override
  String get dhikirLahawlaTitle => 'লা হাওলা ওয়ালা কুওয়াতা';

  @override
  String get dhikirLahawlaTransliteration => 'লা হাওলা ওয়ালা কুওয়াতা';

  @override
  String get dhikirLahawlaMeaning =>
      'আল্লাহ ছাড়া কোনো শক্তি বা ক্ষমতা নেই। এই বাক্যটি জান্নাতের ধনভাণ্ডারগুলোর একটি এবং উদ্বেগ ও কষ্টের বিরুদ্ধে সুরক্ষা।';

  @override
  String get dhikirAllahummaInnakaAfuwwunTitle => 'আল্লাহুম্মা ইন্নাকা আফুউউন';

  @override
  String get dhikirAllahummaInnakaAfuwwunTransliteration =>
      'আল্লাহুম্মা ইন্নাকা আফুউউন';

  @override
  String get dhikirAllahummaInnakaAfuwwunMeaning =>
      'হে আল্লাহ, আপনি ক্ষমাশীল এবং ক্ষমা করতে ভালোবাসেন, তাই আমাকে ক্ষমা করুন। এই দোয়া বিনম্রতা জাগ্রত করে এবং আল্লাহর রহমতকে আহ্বান করে।';

  @override
  String get dhikirLaIlahaIllallahWahdahuTitle =>
      'লা ইলাহা ইল্লাল্লাহু ওয়াহদাহু';

  @override
  String get dhikirLaIlahaIllallahWahdahuTransliteration =>
      'লা ইলাহা ইল্লাল্লাহু ওয়াহদাহু';

  @override
  String get dhikirLaIlahaIllallahWahdahuMeaning =>
      'আল্লাহ ছাড়া কোনো সত্য উপাস্য নেই, তিনি একক, তাঁর কোনো শরিক নেই। সমস্ত রাজত্ব ও প্রশংসা তাঁরই। তিনি জীবন দেন ও মৃত্যু ঘটান, এবং তিনি সবকিছুর উপর ক্ষমতাবান।';

  @override
  String get dhikirSubhanallahiWaBihamdihiTitle =>
      'সুবহানাল্লাহি ওয়া বিহামদিহি';

  @override
  String get dhikirSubhanallahiWaBihamdihiTransliteration =>
      'সুবহানাল্লাহি ওয়া বিহামদিহি';

  @override
  String get dhikirSubhanallahiWaBihamdihiMeaning =>
      'আল্লাহর পবিত্রতা ও সকল প্রশংসা তাঁরই। এই সহজ অথচ শক্তিশালী যিকির ক্ষমা ও অন্তরের প্রশান্তি বয়ে আনে।';

  @override
  String get dhikirSubhanallahilAzeemTitle => 'সুবহানাল্লাহিল আজীম';

  @override
  String get dhikirSubhanallahilAzeemTransliteration => 'সুবহানাল্লাহিল আজীম';

  @override
  String get dhikirSubhanallahilAzeemMeaning =>
      'মহান আল্লাহর পবিত্রতা ঘোষণা। এই যিকির আল্লাহর মহত্ত্বের প্রতি ভয়-শ্রদ্ধা জাগ্রত করে এবং ঈমান দৃঢ় করে।';

  @override
  String get dhikirSayyidulIstighfarExtendedTitle => 'সাইয়িদুল ইস্তিগফার';

  @override
  String get dhikirSayyidulIstighfarExtendedTransliteration =>
      'সাইয়িদুল ইস্তিগফার';

  @override
  String get dhikirSayyidulIstighfarExtendedMeaning =>
      'আমি আল্লাহর কাছে ক্ষমা প্রার্থনা করছি, যিনি ছাড়া কোনো সত্য উপাস্য নেই, চিরঞ্জীব, সর্বসত্তার ধারক, এবং আমি তাঁর কাছে তওবা করছি।';

  @override
  String get dhikirSalawatOnNabiTitle => 'নবীজির ﷺ উপর দরুদ';

  @override
  String get dhikirSalawatOnNabiTransliteration => 'নবীজির ﷺ উপর দরুদ';

  @override
  String get dhikirSalawatOnNabiMeaning =>
      'হে আল্লাহ, আমাদের নবী মুহাম্মদ ﷺ-এর উপর আপনার শান্তি ও রহমত বর্ষণ করুন। দরুদ পাঠ রহমত এবং নবীজি ﷺ-এর নৈকট্য বয়ে আনে।';
}
