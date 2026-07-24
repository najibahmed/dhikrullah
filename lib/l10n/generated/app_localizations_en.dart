// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonSave => 'Save';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonDone => 'Done';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonToday => 'Today';

  @override
  String get commonYesterday => 'Yesterday';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonAdd => 'Add';

  @override
  String get thisMonthLabel => 'This Month';

  @override
  String get openSettingsButton => 'Open Settings';

  @override
  String forbiddenTimeLabel(Object name) {
    return 'Forbidden time · $name';
  }

  @override
  String startFullSessionButton(Object count) {
    return 'Start Full Session — $count Dhikir';
  }

  @override
  String get allDhikirSectionTitle => 'All Dhikir';

  @override
  String get tapNoLimit => 'Tap to count — no limit';

  @override
  String remainingCount(Object count) {
    return '$count remaining';
  }

  @override
  String get resetTodayCountTitle => 'Reset Today’s Count?';

  @override
  String goalLabelTimes(Object goal) {
    return '$goal times';
  }

  @override
  String get goalLabelUnlimited => 'Unlimited';

  @override
  String get setUnlimitedButton => 'Set Unlimited';

  @override
  String setGoalButton(Object label) {
    return 'Set Goal: $label';
  }

  @override
  String get goalSubtitleTasbihSubhanallah => 'Tasbih — SubhanAllah';

  @override
  String get goalSubtitleTasbihAlhamdulillah => 'Tasbih — Alhamdulillah';

  @override
  String get goalSubtitleNamesOfAllah => 'Names of Allah';

  @override
  String get goalSubtitleDailyCentury => 'Daily century goal';

  @override
  String get goalSubtitleNoLimit => 'No limit — count freely';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutAppName => 'Daily Dhikir';

  @override
  String aboutVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get aboutDescription =>
      'A daily dhikir tracker app with 30-day tracking';

  @override
  String get aboutDeveloper => 'Developer';

  @override
  String get aboutDeveloperNamePlaceholder => 'Developer name — TODO';

  @override
  String get aboutBioPlaceholder => 'Short bio — TODO';

  @override
  String get aboutContactPlaceholder => 'Contact — TODO';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageBangla => 'বাংলা';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsLanguageDialogTitle => 'Choose Language';

  @override
  String get themeSettingsRowLabel => 'Theme';

  @override
  String get themeSettingsDialogTitle => 'Choose Theme';

  @override
  String get themeSettingsSystem => 'System default';

  @override
  String get themeSettingsLight => 'Light';

  @override
  String get themeSettingsDark => 'Dark';

  @override
  String get qiblaTitle => 'Qibla Compass';

  @override
  String get qiblaFacing => 'Facing Qibla';

  @override
  String get qiblaTurnLeft => 'Turn left';

  @override
  String get qiblaTurnRight => 'Turn right';

  @override
  String get qiblaHeadingLabel => 'Heading';

  @override
  String get qiblaBearingLabel => 'Qibla';

  @override
  String get qiblaNoSensor => 'Compass sensor is not available on this device.';

  @override
  String get favoritesScreenTitle => 'Favourites';

  @override
  String get favoritesEmptyTitle => 'No favorite dhikir yet';

  @override
  String get favoritesEmptySubtitle =>
      'Tap the heart icon to favorite your dhikir';

  @override
  String get favoritesCustomSectionTitle => 'Custom Favourite Dhikir';

  @override
  String get favoritesSectionTitle => 'Favourite Dhikir';

  @override
  String get navHome => 'Home';

  @override
  String get navCounter => 'Counter';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navMyDhikir => 'My Dhikir';

  @override
  String get homeSectionTitle => 'Daily Dhikir';

  @override
  String todayCountBadge(Object count) {
    return '$count× today';
  }

  @override
  String get quickActionsTitle => 'Quick Actions';

  @override
  String get quickActionPrayerTime => 'Prayer Time';

  @override
  String get quickActionQibla => 'Qibla';

  @override
  String get quickActionNames99 => '99 Names';

  @override
  String get names99ScreenTitle => 'Allah\'s 99 Names';

  @override
  String get quickActionTasbih => 'Tasbih';

  @override
  String get counterAddCustomDhikir => 'Add Custom Dhikir';

  @override
  String get counterAnalytics => 'Dhikir Analytics';

  @override
  String get quickActionDua => 'Dua';

  @override
  String get duaScreenTitle => 'Dua';

  @override
  String get fontSettingsTitle => 'Font Settings';

  @override
  String get arabicFontSizeLabel => 'Arabic Font Size';

  @override
  String get transliterationFontSizeLabel => 'Transliteration Font Size';

  @override
  String get meaningFontSizeLabel => 'Meaning Font Size';

  @override
  String duaCountLabel(Object count) {
    return '$count duas';
  }

  @override
  String duaRepeatLabel(Object count) {
    return 'Repeat ×$count';
  }

  @override
  String get resetTodayCountBody => 'This resets today’s tap counter to 0.';

  @override
  String get resetMonthTitle => 'Reset This Month?';

  @override
  String get resetMonthBody => 'This clears all checkmarks for this month.';

  @override
  String daysCompletedLabel(Object completed, Object total) {
    return '$completed / $total days';
  }

  @override
  String get pillArabic => 'Arabic';

  @override
  String get pillMeaning => 'Meaning & Significance';

  @override
  String get pillTodayCounter => 'Today’s Counter';

  @override
  String get goalUnlimited => 'Goal: ∞';

  @override
  String goalTarget(Object target) {
    return 'Goal: $target';
  }

  @override
  String goalReachedBannerDetail(Object target) {
    return 'MāshāAllah! $target completed today';
  }

  @override
  String get historyButton => 'History';

  @override
  String get legendDone => 'Done';

  @override
  String get legendPending => 'Pending';

  @override
  String get legendFuture => 'Future';

  @override
  String get calendarTitle => 'History Calendar';

  @override
  String resetMonthDialogTitle(Object month) {
    return 'Reset $month?';
  }

  @override
  String get resetMonthDialogBody =>
      'This clears all checkmarks for this month only.';

  @override
  String get resetMonthButton => 'Reset Month';

  @override
  String get legendCompleted => 'Completed';

  @override
  String get legendMissed => 'Missed';

  @override
  String monthSummary(Object completed, Object total, Object pct) {
    return 'This month: $completed / $total days ($pct%)';
  }

  @override
  String daysCountLabel(Object count) {
    return '$count days';
  }

  @override
  String daysCountShort(Object count) {
    return '$count d';
  }

  @override
  String get statStreak => '🔥 Streak';

  @override
  String get statBest => 'Best';

  @override
  String get yearOverviewTitle => 'Year Overview';

  @override
  String calendarFooter(Object total) {
    return 'Tap a month to navigate  •  Total: $total days';
  }

  @override
  String resetMonthProgressButton(Object month) {
    return 'Reset $month Progress';
  }

  @override
  String counterResetBody(Object title) {
    return 'Reset counter for $title?';
  }

  @override
  String counterProgressLabel(Object current, Object total) {
    return '$current of $total dhikir';
  }

  @override
  String counterResetHint(Object count) {
    return 'Reset  •  $count counted';
  }

  @override
  String counterCountedUnlimited(Object count) {
    return '$count counted';
  }

  @override
  String get counterGoalReachedBanner => 'MāshāAllah! Goal reached';

  @override
  String get sessionGoalSheetTitle => 'Set Session Goal';

  @override
  String get sessionGoalSheetSubtitle =>
      'Applies to all dhikir in this session';

  @override
  String get setupGoalDescSubhanallah => 'SubhanAllah tasbih';

  @override
  String get setupGoalDescAlhamdulillah => 'Alhamdulillah tasbih';

  @override
  String get setupGoalDescCenturyGoal => 'Century goal';

  @override
  String get setupGoalDescNoLimit => 'No limit';

  @override
  String get setupSheetTitle => 'Setup Session';

  @override
  String setupSheetSubtitle(Object count) {
    return '$count dhikir • Choose a shared goal';
  }

  @override
  String get setupGoalPerDhikir => 'Goal per Dhikir';

  @override
  String get setupSessionIncludes => 'Session includes';

  @override
  String get setupStartUnlimited => 'Start (Unlimited)';

  @override
  String setupStartGoal(Object label) {
    return 'Start (Goal: $label)';
  }

  @override
  String get goalPickSheetTitle => 'Set Counter Goal';

  @override
  String get goalPickSheetSubtitle => 'Choose how many times to recite';

  @override
  String get analyticsAppBarTitle => 'Counter Analytics';

  @override
  String get periodDaily => 'Daily';

  @override
  String get periodWeekly => 'Weekly';

  @override
  String get periodMonthly => 'Monthly';

  @override
  String get byDhikirSection => 'By Dhikir';

  @override
  String get colDhikir => 'Dhikir';

  @override
  String get colCount => 'Count';

  @override
  String get colDays => 'Days';

  @override
  String get colShare => 'Share';

  @override
  String get periodLabelThisWeek => 'This Week';

  @override
  String get avgPerDay => '/ day avg';

  @override
  String get totalCountLabel => 'Total Count';

  @override
  String get activeTypesLabel => 'Active Types';

  @override
  String get dayByDayLogSection => 'Day-by-Day Log';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get showLess => 'Show less';

  @override
  String showAllDays(Object count) {
    return 'Show all $count days';
  }

  @override
  String get noCountsRecorded => 'No counts recorded';

  @override
  String get allTimeTotalsSection => 'All-Time Totals';

  @override
  String grandTotalLabel(Object total) {
    return '$total total';
  }

  @override
  String get allTimeEmptyState => 'Start counting to see your all-time stats.';

  @override
  String analyticsWeekBarLabel(Object n) {
    return 'W$n';
  }

  @override
  String get colorMint => 'Mint';

  @override
  String get colorSky => 'Sky';

  @override
  String get colorSand => 'Sand';

  @override
  String get colorLavender => 'Lavender';

  @override
  String get colorAqua => 'Aqua';

  @override
  String get colorCream => 'Cream';

  @override
  String get colorRose => 'Rose';

  @override
  String get colorPeriwinkle => 'Periwinkle';

  @override
  String get colorLime => 'Lime';

  @override
  String get colorTeal => 'Teal';

  @override
  String get colorCoral => 'Coral';

  @override
  String get colorViolet => 'Violet';

  @override
  String get addDhikirAppBarUpdate => 'Update';

  @override
  String get addDhikirEditTitle => 'Edit Dhikir';

  @override
  String get addDhikirNewTitle => 'Add New Dhikir';

  @override
  String get addDhikirEditSubtitle => 'Update your dhikir';

  @override
  String get addDhikirNewSubtitle => 'Create a personal dhikir';

  @override
  String get chooseIconLabel => 'Choose Icon';

  @override
  String get chooseColorLabel => 'Choose Color';

  @override
  String get dhikirDetailsSection => 'Dhikir Details';

  @override
  String get titleFieldLabel => 'Title';

  @override
  String get titleFieldHint => 'e.g. SubhanAllah';

  @override
  String get titleRequiredError => 'Title is required';

  @override
  String get titleTooShortError => 'Title must be at least 2 characters';

  @override
  String get titleTooLongError => 'Title too long (max 60 characters)';

  @override
  String get arabicTextFieldLabel => 'Arabic Text';

  @override
  String get arabicTextFieldHint => 'سُبْحَانَ اللّهِ';

  @override
  String get arabicTextRequiredError => 'Arabic text is required';

  @override
  String get transliterationFieldLabel => 'Transliteration';

  @override
  String get transliterationFieldHint => 'e.g. Subḥān Allāh';

  @override
  String get transliterationRequiredError => 'Transliteration is required';

  @override
  String get meaningFieldLabel => 'Meaning / Description';

  @override
  String get meaningFieldHint => 'Explain the significance of this dhikir...';

  @override
  String get meaningRequiredError => 'Meaning is required';

  @override
  String get meaningTooShortError => 'Please provide a more detailed meaning';

  @override
  String get previewSection => 'Preview';

  @override
  String get previewDefaultTitle => 'Your Dhikir';

  @override
  String get previewDefaultArabic => 'النص العربي';

  @override
  String get previewDefaultTransliteration => 'transliteration';

  @override
  String get addDhikirUpdateButton => 'Update Dhikir';

  @override
  String get addDhikirSaveButton => 'Save Dhikir';

  @override
  String deleteDhikirTitle(Object title) {
    return 'Delete “$title”?';
  }

  @override
  String get deleteDhikirBody =>
      'This will permanently delete this dhikir. Progress data will remain.';

  @override
  String myDhikirCountSubtitle(Object count) {
    return '$count custom dhikir';
  }

  @override
  String get myDhikirEmptyTitle => 'No custom dhikir yet';

  @override
  String get myDhikirEmptySubtitle =>
      'Tap the Add button to create your first dhikir';

  @override
  String myDhikirStartSession(Object count) {
    return 'Start Session — All $count Dhikir';
  }

  @override
  String get unfavAction => 'Unfav';

  @override
  String get favouriteAction => 'Favourite';

  @override
  String get prayerNameFajr => 'Fajr';

  @override
  String get prayerNameDhuhr => 'Dhuhr';

  @override
  String get prayerNameAsr => 'Asr';

  @override
  String get prayerNameMaghrib => 'Maghrib';

  @override
  String get prayerNameIsha => 'Isha';

  @override
  String get prayerNameSunrise => 'Sunrise';

  @override
  String get prayerNameSunset => 'Sunset';

  @override
  String get prayerNameZawal => 'Zawal';

  @override
  String get prayerNameTahajjud => 'Tahajjud';

  @override
  String get prayerNameIshraq => 'Ishraq';

  @override
  String get prayerNameChasht => 'Chasht';

  @override
  String get todaysScheduleTitle => 'Today’s Schedule';

  @override
  String get tomorrowsScheduleTitle => 'Tomorrow’s Schedule';

  @override
  String get iftarStartsIn => 'Iftar starts in';

  @override
  String get sehriEndsIn => 'Sehri ends in';

  @override
  String get notifChannelName => 'Prayer time reminders';

  @override
  String get notifChannelDescription =>
      'Notifies you at the start of each prayer time';

  @override
  String get notifSilentChannelName => 'Prayer time reminders (silent)';

  @override
  String get notifSilentChannelDescription =>
      'Notifies you at the start of each prayer time, without sound';

  @override
  String notifPrayerTitle(Object label) {
    return '$label prayer time';
  }

  @override
  String notifPrayerBody(Object label) {
    return 'It’s time for $label.';
  }

  @override
  String notifOptionalBody(Object label) {
    return 'Time for $label.';
  }

  @override
  String get alarmSectionTitle => 'Alarm';

  @override
  String get alarmFullWithAdhan => 'Full alarm with Adhan';

  @override
  String get alarmStateOn => 'On';

  @override
  String get alarmStateOff => 'Off';

  @override
  String get alarmTimeOffset => 'Alarm time offset';

  @override
  String get alarmOffsetOnTime => 'On time';

  @override
  String alarmOffsetMinutesPlus(Object minutes) {
    return '+$minutes min';
  }

  @override
  String alarmOffsetMinutesMinus(Object minutes) {
    return '$minutes min';
  }

  @override
  String get alarmVibration => 'Vibration';

  @override
  String get alarmFullScreen => 'Full-screen alarm';

  @override
  String get alarmFullScreenSubtitle =>
      'Show a lock-screen alert when the alarm fires';

  @override
  String get alarmExactPermissionTitle => 'Exact alarms are off';

  @override
  String get alarmExactPermissionBody =>
      'Allow exact alarms in system settings so this prayer alarm fires on time.';

  @override
  String get alarmFullScreenPermissionTitle => 'Full-screen alerts are off';

  @override
  String get alarmFullScreenPermissionBody =>
      'Allow full-screen alerts in system settings so this alarm can show over the lock screen. It still rings as a notification either way.';

  @override
  String hijriOffsetDayLabel(Object days) {
    return '$days Day';
  }

  @override
  String hijriOffsetDayLabelPlus(Object days) {
    return '+$days Day';
  }

  @override
  String get hijriEraSuffix => ' AH';

  @override
  String get hijriSettingsTitle => 'Hijri Date Settings';

  @override
  String get hijriInfoBanner =>
      'Since the Hijri date depends on moonsighting, the calculated date may differ by a day. You may need to check and correct this each month to match your local community.';

  @override
  String get hijriAdjustmentSection => 'Hijri Date Adjustment';

  @override
  String get hijriDayStartSection => 'New Hijri Day Starts At';

  @override
  String get hijriDayStartMidnight => 'Midnight (12:00 AM)';

  @override
  String get hijriDayStartSunset => 'Sunset (Maghrib)';

  @override
  String get prayerTimesTitle => 'Prayer Times';

  @override
  String get prayerSettingsTooltip => 'Prayer settings';

  @override
  String get locationDeniedMessage =>
      'Location permission was denied. Open Settings to enable it.';

  @override
  String get locationRequiredMessage =>
      'Location permission is required to calculate prayer times.';

  @override
  String get enableLocationButton => 'Enable location';

  @override
  String get previousDayTooltip => 'Previous day';

  @override
  String get nextDayTooltip => 'Next day';

  @override
  String get markerMiddleOfNight => 'Middle of night';

  @override
  String get markerLastThirdOfNight => 'Last third of night';

  @override
  String notificationTooltip(Object name) {
    return '$name notification';
  }

  @override
  String untilTime(Object time) {
    return 'Until $time';
  }

  @override
  String get prayerSettingsTitle => 'Prayer Settings';

  @override
  String get notificationsSectionTitle => 'Notifications';

  @override
  String get notificationsOptionalSubtitle => 'Optional — off by default';

  @override
  String get madhabSection => 'Madhab (Asr calculation)';

  @override
  String get madhabHanafi => 'Hanafi';

  @override
  String get madhabShafi => 'Shafi';

  @override
  String get forbiddenMorning => 'Forbidden Time (Morning)';

  @override
  String get forbiddenNoon => 'Forbidden Time (Noon)';

  @override
  String get forbiddenEvening => 'Forbidden Time (Evening)';

  @override
  String get todaysForbiddenTimesSection => 'Today’s Forbidden Times';

  @override
  String get notifOffDialogTitle => 'Notifications are off';

  @override
  String get notifOffDialogBody =>
      'To get prayer time reminders, allow notifications for this app in system settings.';

  @override
  String get notNowButton => 'Not now';

  @override
  String get notificationSwitchTitle => 'Notification';

  @override
  String get notificationOnSubtitle => 'You will be notified';

  @override
  String get notificationOffSubtitle => 'Notification is off';

  @override
  String get soundSection => 'Sound';

  @override
  String get soundDefault => 'Default';

  @override
  String get soundSilent => 'Silent';

  @override
  String durationHoursMinutes(Object hours, Object minutes) {
    return '$hours Hour $minutes Minutes';
  }

  @override
  String durationMinutes(Object minutes) {
    return '$minutes Minutes';
  }

  @override
  String get nextPrayerSection => 'Next Prayer';

  @override
  String get sehriEndLabel => 'Sehri End';

  @override
  String get iftarLabel => 'Iftar';

  @override
  String countdownRemaining(Object hours, Object minutes) {
    return 'Time Remaining: $hours Hour $minutes Minutes';
  }

  @override
  String countdownRemainingMinutes(Object minutes) {
    return 'Time Remaining: $minutes Minutes';
  }

  @override
  String get semanticsLocationDeviceOff =>
      'Prayer times unavailable. Enable device location.';

  @override
  String get semanticsLocationPermOff =>
      'Prayer times unavailable. Enable location permission.';

  @override
  String get semanticsLocationUnavailable =>
      'Prayer times unavailable. Unable to determine location.';

  @override
  String get semanticsCalcUnavailable => 'Unable to calculate prayer times.';

  @override
  String get semanticsFinding => 'Finding prayer times.';

  @override
  String semanticsForbidden(Object name) {
    return 'Forbidden prayer time: $name.';
  }

  @override
  String semanticsNextPrayer(Object name) {
    return ' Next prayer $name.';
  }

  @override
  String get semanticsPrayerTimes => 'Prayer times.';

  @override
  String semanticsCurrentPrayer(Object name, Object percent) {
    return 'Current prayer $name, $percent percent through.';
  }

  @override
  String get enableLocationMessage =>
      'Enable device location to see prayer times';

  @override
  String get locationDeniedTapSettings =>
      'Location permission denied. Tap to open Settings.';

  @override
  String get enableLocationShort => 'Enable location to see prayer times';

  @override
  String get unableToDetermineLocation => 'Unable to determine location';

  @override
  String get unableToCalculate => 'Unable to calculate prayer times';

  @override
  String get findingPrayerTimes => 'Finding prayer times…';

  @override
  String endsInLabel(Object duration) {
    return 'Ends $duration';
  }

  @override
  String nextPrayerInline(Object name, Object duration) {
    return 'Next: $name $duration';
  }

  @override
  String get currentPrayerSection => 'Current Prayer';

  @override
  String sessionCountLabel(Object count) {
    return 'Session ($count)';
  }

  @override
  String ofTarget(Object target) {
    return 'of $target';
  }

  @override
  String get ofUnlimited => 'of ∞';

  @override
  String get dhikirSubhanallahTitle => 'Subhanallah';

  @override
  String get dhikirSubhanallahTransliteration => 'Subḥān Allāh';

  @override
  String get dhikirSubhanallahMeaning =>
      'Glory be to Allah. This dhikir is a declaration of Allah’s perfection and freedom from any imperfection or deficiency. It is one of the most beloved phrases to Allah.';

  @override
  String get dhikirAlhamdulillahTitle => 'Alhamdulillah';

  @override
  String get dhikirAlhamdulillahTransliteration => 'Al-Ḥamdu lillāh';

  @override
  String get dhikirAlhamdulillahMeaning =>
      'All praise is due to Allah. This is an expression of gratitude and praise to Allah for all His blessings, both visible and hidden.';

  @override
  String get dhikirAllahuakbarTitle => 'Allahu Akbar';

  @override
  String get dhikirAllahuakbarTransliteration => 'Allāhu Akbar';

  @override
  String get dhikirAllahuakbarMeaning =>
      'Allah is the Greatest. This declaration affirms that Allah is greater than everything — greater than our worries, our problems, and anything in existence.';

  @override
  String get dhikirLailahaillallahTitle => 'Lā ilāha ill-Allāh';

  @override
  String get dhikirLailahaillallahTransliteration => 'Lā ilāha illā Allāh';

  @override
  String get dhikirLailahaillallahMeaning =>
      'There is no god but Allah. This is the foundation of Islamic faith — the testimony that no one is worthy of worship except Allah alone.';

  @override
  String get dhikirAstaghfirullahTitle => 'Astaghfirullah';

  @override
  String get dhikirAstaghfirullahTransliteration => 'Astaghfiru Allāh';

  @override
  String get dhikirAstaghfirullahMeaning =>
      'I seek forgiveness from Allah. Seeking forgiveness regularly cleanses the heart, brings peace, and opens the doors of mercy and provision.';

  @override
  String get dhikirSalawatTitle => 'Salawat';

  @override
  String get dhikirSalawatTransliteration => 'Allāhumma ṣalli ’alā Muḥammad';

  @override
  String get dhikirSalawatMeaning =>
      'O Allah, send blessings upon Muhammad. Sending blessings upon the Prophet ﷺ earns tremendous reward and brings the sender closer to the Prophet on the Day of Judgment.';

  @override
  String get dhikirHasbunallahTitle => 'Hasbunallah';

  @override
  String get dhikirHasbunallahTransliteration =>
      'Ḥasbunā Allāh wa ni’ma al-Wakīl';

  @override
  String get dhikirHasbunallahMeaning =>
      'Allah is sufficient for us and He is the best disposer of affairs. This dhikir is a powerful expression of trust and reliance on Allah in times of difficulty.';

  @override
  String get dhikirLahawlaTitle => 'La Hawla Wala Quwwata';

  @override
  String get dhikirLahawlaTransliteration =>
      'Lā ḥawla wa lā quwwata illā billāh';

  @override
  String get dhikirLahawlaMeaning =>
      'There is no power or might except with Allah. This phrase is a treasure from the treasures of Paradise and a protection against anxiety and hardship.';

  @override
  String get dhikirAllahummaInnakaAfuwwunTitle => 'Allahumma Innaka ’Afuwwun';

  @override
  String get dhikirAllahummaInnakaAfuwwunTransliteration =>
      'Allahumma innaka ʿafuwwun tuḥibbul-ʿafwa faʿfu ʿannī';

  @override
  String get dhikirAllahummaInnakaAfuwwunMeaning =>
      'O Allah, You are Most Forgiving and You love forgiveness, so forgive me. This duʿāʾ nurtures humility and invites Allah’s mercy.';

  @override
  String get dhikirLaIlahaIllallahWahdahuTitle => 'Lā ilāha ill-Allāh wahdahu';

  @override
  String get dhikirLaIlahaIllallahWahdahuTransliteration =>
      'Lā ilāha ill-Allāh waḥdahu lā sharīka lah, lahul-mulku wa lahul-ḥamd, yuḥyī wa yumīt, wa huwa ʿalā kulli shayʾIn qadīr';

  @override
  String get dhikirLaIlahaIllallahWahdahuMeaning =>
      'There is no deity worthy of worship except Allah alone, without partner. To Him belongs sovereignty and praise. He gives life and causes death, and He has power over all things.';

  @override
  String get dhikirSubhanallahiWaBihamdihiTitle => 'Subhanallahi wa Bihamdihi';

  @override
  String get dhikirSubhanallahiWaBihamdihiTransliteration =>
      'Subḥānallāhi wa biḥamdih';

  @override
  String get dhikirSubhanallahiWaBihamdihiMeaning =>
      'Glory be to Allah and all praise is His. A simple yet powerful remembrance that brings forgiveness and lightness to the heart.';

  @override
  String get dhikirSubhanallahilAzeemTitle => 'Subhanallahil Azeem';

  @override
  String get dhikirSubhanallahilAzeemTransliteration => 'Subḥānallāhil-ʿAẓīm';

  @override
  String get dhikirSubhanallahilAzeemMeaning =>
      'Glory be to Allah, the Most Great. This dhikr instills awe of Allah’s greatness and strengthens faith.';

  @override
  String get dhikirSayyidulIstighfarExtendedTitle =>
      'Astaghfirullah wa Atubu Ilayh';

  @override
  String get dhikirSayyidulIstighfarExtendedTransliteration =>
      'Astaghfirullāhal-ladhī lā ilāha illā huwal-ḥayyul-qayyūm wa atūbu ilayh';

  @override
  String get dhikirSayyidulIstighfarExtendedMeaning =>
      'I seek forgiveness from Allah, besides whom there is no deity, the Ever-Living, the Sustainer, and I repent to Him.';

  @override
  String get dhikirSalawatOnNabiTitle => 'Salawat on the Prophet ﷺ';

  @override
  String get dhikirSalawatOnNabiTransliteration =>
      'Allāhumma ṣalli wa sallim ʿalā nabiyyinā Muḥammad';

  @override
  String get dhikirSalawatOnNabiMeaning =>
      'O Allah, send Your peace and blessings upon our Prophet Muhammad. Sending salawat brings blessings and closeness to the Prophet ﷺ.';
}
