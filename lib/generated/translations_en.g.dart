///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'translations.g.dart';

// Path: <root>
class TranslationsEn extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final TranslationsEn _root = this; // ignore: unused_field

	@override 
	TranslationsEn $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEn(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$common$en common = _Translations$common$en._(_root);
	@override late final _Translations$core$en core = _Translations$core$en._(_root);
	@override late final _Translations$settings$en settings = _Translations$settings$en._(_root);
}

// Path: common
class _Translations$common$en extends Translations$common$zh {
	_Translations$common$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get confirm => 'Confirm';
	@override String get cancel => 'Cancel';
	@override String get unexpectProblemTitle => 'Unexpected problem :P';
	@override String get unexpectProblemHint => 'An unexpected behavior occurred!';
	@override String get errorDetected => 'Ouch! An error occurred!';
	@override String get clickToRefresh => 'Click to refresh';
}

// Path: core
class _Translations$core$en extends Translations$core$zh {
	_Translations$core$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$core$language$en language = _Translations$core$language$en._(_root);
	@override late final _Translations$core$theme$en theme = _Translations$core$theme$en._(_root);
	@override late final _Translations$core$gridPage$en gridPage = _Translations$core$gridPage$en._(_root);
}

// Path: settings
class _Translations$settings$en extends Translations$settings$zh {
	_Translations$settings$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Settings';
	@override String get aboutInfo => 'APP info';
	@override String acknowledgement({required Object developers}) => 'Made With Love From ${developers} People';
	@override String get about => 'About';
	@override String get aboutThisProgram => 'About this APP';
	@override String version({required Object version}) => 'Version：${version}';
	@override String get userInfo => 'User information';
	@override String get checkUpdate => 'Check for updates';
	@override String latestVersion({required Object latest}) => 'Latest version: ${latest}';
	@override String get waiting => 'Waiting for obtain';
	@override String get fetchingUpdate => 'Fetching update information';
	@override String get newVersion => 'New version released，PLEASE UPDATE AT ONCE!';
	@override String get currentStable => 'You are running the latest version';
	@override String get currentTesting => 'You are running the testing version';
	@override String get fetchFailed => 'Failed to fetch update information';
	@override String get uiSetting => 'UI Settings';
	@override String get brightnessSetting => 'Light/Dark mode';
	@override String get colorSetting => 'Color theme';
	@override String get simplifyTimeline => 'Simplify schedule timeline';
	@override String get simplifyTimelineDescription => 'Reduce space occupation while no schedule';
	@override String get lowElectricityWarning => 'Low electricity card color warning';
	@override String get lowElectricityWarningDescription => 'Change the homepage electricity card color when remaining electricity is below the threshold';
	@override String get lowElectricityThreshold => 'Low electricity threshold';
	@override String lowElectricityThresholdDescription({required Object threshold}) => 'Current: ${threshold} kWh';
	@override late final _Translations$settings$lowElectricityThresholdDialog$en lowElectricityThresholdDialog = _Translations$settings$lowElectricityThresholdDialog$en._(_root);
	@override String get accountSetting => 'Account Settings';
	@override String get sportPasswordSetting => 'PE system password';
	@override String get experimentPasswordSetting => 'Physics experiment password';
	@override String get electricityPasswordSetting => 'Electricity account password';
	@override String get electricityPasswordDescription => 'Please set if not default';
	@override String get electricityAccountSetting => 'Electricity account setting';
	@override String get schoolnetPasswordSetting => 'Campus net password';
	@override String get schoolnetPasswordDescription => 'If you have not setted it, you cannot query it.';
	@override String get airconImeiTitle => 'Aircon device';
	@override String get airconImei => 'Aircon IMEI';
	@override String get airconImeiNotSet => 'Not set. Aircon data and remote control are unavailable.';
	@override String airconImeiCurrent({required Object imei}) => 'Current IMEI: ${imei}';
	@override String get airconImeiSaved => 'Aircon IMEI saved';
	@override String get airconImeiCleared => 'Aircon IMEI cleared';
	@override String get airconImeiInvalid => 'No valid 15-digit IMEI found';
	@override String get airconImeiClear => 'Clear';
	@override String get scanAirconQr => 'Scan aircon QR code';
	@override String get pickAirconQrImage => 'Choose QR image';
	@override String get airconCameraUnavailable => 'Camera scanning is unavailable on this platform. Choose a QR image or enter the IMEI manually.';
	@override String get airconScanHint => 'Tap to focus. If the aircon is far away and stays blurry when zoomed in, take a photo with the system camera instead.';
	@override String get airconTakePhoto => 'Take a photo with the system camera';
	@override String airconCameraError({required Object error}) => 'Unable to open the camera: ${error}';
	@override String get notificationSetting => 'Notification Settings';
	@override String get courseReminderSetting => 'Pre-class Reminder Settings';
	@override String get courseReminderDescription => 'Configure pre-class reminder notifications';
	@override late final _Translations$settings$notificationPage$en notificationPage = _Translations$settings$notificationPage$en._(_root);
	@override String get notificationDebugPage => 'Notification status and test';
	@override String get classtableSetting => 'Class Schedule Related';
	@override String get background => 'Background image';
	@override String get noBackground => 'You need to select an image first, it\'s at below';
	@override String get chooseBackground => 'Choose background image';
	@override String get noPermission => 'No storage permission obtained, cannot read files';
	@override String get successfulSetting => 'Successfully set';
	@override String get failureSetting => 'You did not select an image';
	@override String get clearUserClass => 'Clear all customized courses';
	@override String get clearUserClassTitle => 'Clear Confirmation';
	@override String get clearUserClassContent => 'Do you want to clear all user-added courses? This function does not affect the schedule obtained from the school.';
	@override String get clearUserClassClear => 'Already cleared';
	@override String get classRefresh => 'Force refresh class schedule';
	@override String get classRefreshTitle => 'Refresh Confirmation';
	@override String get classRefreshContent => 'Do you want to force refreshing the class schedule? If you agree, we will fetch the schedule from the school, which may takes a long time.';
	@override String get classSwift => 'Class schedule offset setting';
	@override String classSwiftDescription({required Object swift}) => 'Currently ${swift}';
	@override String get coreSetting => 'Cached login settings';
	@override String get checkLogger => 'View network interceptor and logs';
	@override String get clearAndRestart => 'Clear cache and restart';
	@override late final _Translations$settings$clearAndRestartDialog$en clearAndRestartDialog = _Translations$settings$clearAndRestartDialog$en._(_root);
	@override String get logout => 'Log out and restart the app';
	@override late final _Translations$settings$logoutDialog$en logoutDialog = _Translations$settings$logoutDialog$en._(_root);
	@override late final _Translations$settings$needCloseDialog$en needCloseDialog = _Translations$settings$needCloseDialog$en._(_root);
	@override late final _Translations$settings$changeColorDialog$en changeColorDialog = _Translations$settings$changeColorDialog$en._(_root);
	@override late final _Translations$settings$changeBrightnessDialog$en changeBrightnessDialog = _Translations$settings$changeBrightnessDialog$en._(_root);
	@override late final _Translations$settings$changeSwiftDialog$en changeSwiftDialog = _Translations$settings$changeSwiftDialog$en._(_root);
	@override String get changeElectricityTitle => 'Modify electricity account';
	@override late final _Translations$settings$changeElectricityAccount$en changeElectricityAccount = _Translations$settings$changeElectricityAccount$en._(_root);
	@override String get changeExperimentTitle => 'Modify physics experiment account password';
	@override String get changeSportTitle => 'Modify sports system account password';
	@override late final _Translations$settings$changePasswordDialog$en changePasswordDialog = _Translations$settings$changePasswordDialog$en._(_root);
	@override String get changeSchoolnetPasswordTitle => 'Modify the schoolnet query password';
	@override late final _Translations$settings$updateDialog$en updateDialog = _Translations$settings$updateDialog$en._(_root);
	@override late final _Translations$settings$localizationDialog$en localizationDialog = _Translations$settings$localizationDialog$en._(_root);
	@override String get semesterChange => 'Change semester';
	@override String semesterChangeDescription({required Object semester}) => 'Using semester ${semester}';
	@override String get semesterUpdateData => 'Applying new semester setting';
	@override String get easterEggPage => 'You found an Easter egg';
	@override late final _Translations$settings$aboutPage$en aboutPage = _Translations$settings$aboutPage$en._(_root);
	@override late final _Translations$settings$editor$en editor = _Translations$settings$editor$en._(_root);
	@override late final _Translations$settings$sections$en sections = _Translations$settings$sections$en._(_root);
	@override late final _Translations$settings$navigation$en navigation = _Translations$settings$navigation$en._(_root);
	@override String get fontSizeSetting => 'Font size & weight';
	@override late final _Translations$settings$fontSizePage$en fontSizePage = _Translations$settings$fontSizePage$en._(_root);
	@override String get generalAccountSettings => 'General accounts';
	@override String get undergraduateSystemAccounts => 'Undergraduate system accounts';
	@override String get classTableBackgroundSection => 'Class schedule background';
	@override String backgroundBlur({required Object value}) => 'Background blur: ${value}';
	@override String get backgroundBlurOff => 'Off';
	@override String get classTableStyleSetting => 'Class schedule display & style';
	@override String get classTableStyleDescription => 'Time indicator and course card style';
	@override late final _Translations$settings$classTableStylePage$en classTableStylePage = _Translations$settings$classTableStylePage$en._(_root);
	@override String get classSwiftExplain => 'Positive number delays the start date, negative number advances the start date';
}

// Path: core.language
class _Translations$core$language$en extends Translations$core$language$zh {
	_Translations$core$language$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Language';
	@override String get selection => 'App language';
	@override String get system => 'Follow system';
	@override String get simplifiedChinese => '简体中文';
	@override String get traditionalChinese => '繁體中文';
	@override String get english => 'English';
	@override String get saveFailed => 'Unable to save language setting';
}

// Path: core.theme
class _Translations$core$theme$en extends Translations$core$theme$zh {
	_Translations$core$theme$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get saveFailed => 'Unable to save theme settings';
	@override String get display => 'Display';
	@override String get languageAndText => 'Text';
	@override String get colorSetting => 'Color theme';
	@override String get brightnessSetting => 'Light/Dark mode';
	@override String get sizeTitle => 'Font size';
	@override String get weightTitle => 'Font weight';
	@override late final _Translations$core$theme$weight$en weight = _Translations$core$theme$weight$en._(_root);
	@override late final _Translations$core$theme$palette$en palette = _Translations$core$theme$palette$en._(_root);
	@override late final _Translations$core$theme$brightness$en brightness = _Translations$core$theme$brightness$en._(_root);
}

// Path: core.gridPage
class _Translations$core$gridPage$en extends Translations$core$gridPage$zh {
	_Translations$core$gridPage$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get label => 'Info';
	@override String get title => 'School Info Center';
	@override String get editMode => 'Edit Layout';
	@override String get editDone => 'Done';
	@override String get editReset => 'Reset Layout';
	@override String get manageHidden => 'Manage hidden cards';
	@override String get hideEmpty => 'No hidden cards';
}

// Path: settings.lowElectricityThresholdDialog
class _Translations$settings$lowElectricityThresholdDialog$en extends Translations$settings$lowElectricityThresholdDialog$zh {
	_Translations$settings$lowElectricityThresholdDialog$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Set low electricity threshold';
	@override String get inputHint => 'Input remaining electricity';
}

// Path: settings.notificationPage
class _Translations$settings$notificationPage$en extends Translations$settings$notificationPage$zh {
	_Translations$settings$notificationPage$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pre-class Reminder Settings';
	@override String loadFailed({required Object error}) => 'Failed to load settings: ${error}';
	@override String get functionSection => 'Notification Function';
	@override String get enableNotification => 'Enable Pre-class Reminders';
	@override String notificationScheduled({required Object count}) => '${count} notifications scheduled';
	@override String get notificationDisabledHint => 'All scheduled notifications will be cancelled when disabled';
	@override String get updateSchedule => 'Update Notification Schedule';
	@override String get updateScheduleHint => 'Reschedule notifications based on the latest course data';
	@override String get deleteAllSchedule => 'Delete All Scheduled Reminder';
	@override String get deleteAllScheduleHint => 'This action will delete all scheduled events, but you can click \'Update Notification Schedule\' again to re-add them.';
	@override String get deleteAllSuccess => 'Delete successfully';
	@override String get viewTheInstructions => 'View the instructions';
	@override String get viewTheInstructionsHint => 'Check more instructions to ensure that you can see the notifications sent by the program';
	@override String get permissionSection => 'Permission Status';
	@override String get notificationPermission => 'Notification Permission';
	@override String get exactAlarmPermission => 'Exact Alarm Permission';
	@override String get permissionGranted => 'Granted';
	@override String get permissionDenied => 'Denied';
	@override String get requestPermission => 'Request Permission';
	@override String get systemSettings => 'System Notification Settings';
	@override String get systemSettingsHint => 'Open system settings to check notification configuration';
	@override String get permissionGrantedMsg => 'Permission granted';
	@override String get permissionDeniedMsg => 'Permission denied, please enable it in system settings';
	@override String get reminderSection => 'Reminder Settings';
	@override String get experimentReminder => 'Include the physics experiments';
	@override String get experimentReminderHint => 'Enable this option to add the physics experiment to the Pre-class Reminder';
	@override String get minutesBefore => 'Advance Reminder Time';
	@override String get minutesBeforeHint => 'The time setting for pre-class reminders';
	@override String get minutesUnit => 'minutes';
	@override String get daysToSchedule => 'Schedule Duration';
	@override String get daysToScheduleHint => 'This program writes course information into the planned schedule in advance. This setting can adjust the number of days for writing into the planned schedule';
	@override String get daysUnit => 'days';
	@override String get settingsGuideTitle => 'Notification Settings Guide';
	@override String get settingsGuideContent1 => 'To ensure you receive pre-class reminders in time, please make sure:\n1. App notification permission is enabled\n2. Notification sound is enabled\n3. Banner notifications are enabled\n4. Non-native Android users, enable auto-start and disable power optimization';
	@override String get settingsGuideContent2 => 'Pre-class Reminder Module Operating Mechanism:\n1. When first activated, it will automatically schedule pre-class reminders for the upcoming days\n2. Each time the app is opened, it will automatically check and update the notification schedule\n3. After modifying settings, it will automatically reschedule all notifications';
	@override String get gotIt => 'Got it';
	@override String get openSettings => 'Open System Settings';
	@override String get noClasstableData => 'Please fetch course schedule, exam, or experiment data first';
	@override String scheduleSuccess({required Object count}) => 'Scheduled ${count} pre-class reminders';
	@override String scheduleFailed({required Object error}) => 'Failed to schedule notifications: ${error}';
	@override String get cancelAllSuccess => 'All pre-class reminders cancelled';
	@override String rescheduleSuccess({required Object count}) => 'Rescheduled ${count} pre-class reminders';
	@override String rescheduleFailed({required Object error}) => 'Failed to reschedule notifications: ${error}';
}

// Path: settings.clearAndRestartDialog
class _Translations$settings$clearAndRestartDialog$en extends Translations$settings$clearAndRestartDialog$zh {
	_Translations$settings$clearAndRestartDialog$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Restart confirmation';
	@override String get content => 'Are you sure to clear cache and restart the program?';
	@override String get cleaning => 'Clearing cache...';
	@override String get clear => 'Cache has been cleared';
}

// Path: settings.logoutDialog
class _Translations$settings$logoutDialog$en extends Translations$settings$logoutDialog$zh {
	_Translations$settings$logoutDialog$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Logout confirmation';
	@override String get content => 'Are you want to log out? All your data will be completely deleted!';
	@override String get loggingOut => 'Logging out...';
}

// Path: settings.needCloseDialog
class _Translations$settings$needCloseDialog$en extends Translations$settings$needCloseDialog$zh {
	_Translations$settings$needCloseDialog$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Crashed';
	@override String get content => 'Due to technical limitations, you need to close the window manually and then reopen the app.';
}

// Path: settings.changeColorDialog
class _Translations$settings$changeColorDialog$en extends Translations$settings$changeColorDialog$zh {
	_Translations$settings$changeColorDialog$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Color setting';
	@override String get kDefault => 'Default';
	@override String get blue => 'Sky Blue';
	@override String get deepPurple => 'Deep Purple';
	@override String get green => 'Spring Green';
	@override String get orange => 'Asuka Orange';
	@override String get pink => 'Sakura Pink';
}

// Path: settings.changeBrightnessDialog
class _Translations$settings$changeBrightnessDialog$en extends Translations$settings$changeBrightnessDialog$zh {
	_Translations$settings$changeBrightnessDialog$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Brightness settings';
	@override String get followSetting => 'Follow system';
	@override String get dayMode => 'Light';
	@override String get nightMode => 'Dark';
}

// Path: settings.changeSwiftDialog
class _Translations$settings$changeSwiftDialog$en extends Translations$settings$changeSwiftDialog$zh {
	_Translations$settings$changeSwiftDialog$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Class schedule offset setting';
	@override String get inputHint => 'Please input number here';
	@override String get invalidNumber => 'Please enter a valid whole number';
}

// Path: settings.changeElectricityAccount
class _Translations$settings$changeElectricityAccount$en extends Translations$settings$changeElectricityAccount$zh {
	_Translations$settings$changeElectricityAccount$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Modify electricity account';
	@override String get campus => 'Campus';
	@override String get northCampus => 'Northern Campus';
	@override String get southCampus => 'Southern Campus';
	@override String get unitOrZone => 'Unit  / Zone';
	@override String get unitCode => 'Unit';
	@override String get zoneCode => 'Zone';
	@override String pleaseInput({required Object unit_or_zone_code}) => 'Please input ${unit_or_zone_code}';
	@override String successfulFetch({required Object account_number}) => 'Successful fetching account: ${account_number}';
	@override String failedFetch({required Object e}) => 'Failed to fetch: ${e}';
	@override String accountSaved({required Object account_number}) => 'Account saved：${account_number}';
	@override String get unknownCodingPattern => 'Unknown coding pattern';
	@override String get selectBuilding => 'Select Building';
	@override String get building => 'Building';
	@override String get northernBuilding => 'Northern Building';
	@override String get southernBuilding => 'Southern Building';
	@override String failedGenerate({required Object e}) => 'Failed to generate: ${e}';
	@override String get buildingNumber => 'Building number';
	@override String get buildingNumberHint => 'eg: 16, 7, 55';
	@override String get buildingNumberQuery => 'Please input building No.';
	@override String get yard => 'Yard';
	@override String get yardHint => 'Select Yard';
	@override String get northYard => 'North Yard';
	@override String get southYard => 'South Yard';
	@override String get yardQuery => 'Please select yard';
	@override String get apartment => 'Apartment';
	@override String get apartmentHint => 'Select Apartment';
	@override String get northApartment => 'North Apartment';
	@override String get southApartment => 'South Apartment';
	@override String get apartmentQuery => 'Please select apartment';
	@override String get levelCode => 'Floor number';
	@override String get levelCodeQuery => 'Floor number';
	@override String get roomCode => 'Room code';
	@override String get roomCodeHint => 'eg: 304, 508';
	@override String get roomCodeQuery => 'Please input room code';
	@override String get account => 'Electricity Account';
	@override String get accountHint => 'Please enter your account';
	@override String get accountQuery => 'Please input your account';
	@override String get accountLength => 'Account length is larger than 10';
	@override String get fetching => 'Fetching...';
	@override String get fetchFromInternet => 'Sync from backend';
	@override String get saveAccount => 'Save account';
	@override String get confirmSaving => 'Confirm account';
	@override String get calculateAccount => 'Calculate account';
	@override String get calculate => 'Calculate';
	@override String get input => 'Input';
	@override String get confirmAccount => 'Confirm your account: ';
	@override String get change => 'Edit';
	@override String get cancel => 'Cancel';
	@override String get noSetting => 'No new electricity account set';
	@override String get successfulSetting => 'Successfully setting new electricity account';
}

// Path: settings.changePasswordDialog
class _Translations$settings$changePasswordDialog$en extends Translations$settings$changePasswordDialog$zh {
	_Translations$settings$changePasswordDialog$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get inputHint => 'Please input password here';
	@override String get blankInput => 'Blank input!';
}

// Path: settings.updateDialog
class _Translations$settings$updateDialog$en extends Translations$settings$updateDialog$zh {
	_Translations$settings$updateDialog$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get newVersion => 'New version available';
	@override String get notNow => 'Not now';
	@override String get appStore => 'Update from App Store';
	@override String get downloadApk => 'Download APK';
	@override String get githubRelease => 'Go to Git Release';
	@override String newContent({required Object code}) => 'New features from version ${code}:\n';
}

// Path: settings.localizationDialog
class _Translations$settings$localizationDialog$en extends Translations$settings$localizationDialog$zh {
	_Translations$settings$localizationDialog$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Languages';
	@override String get undefined => 'Follow system setting';
	@override String get simplifiedChinese => 'Simplified Chinese';
	@override String get traditionalChinese => 'Traditional Chinese';
	@override String get english => 'English';
}

// Path: settings.aboutPage
class _Translations$settings$aboutPage$en extends Translations$settings$aboutPage$zh {
	_Translations$settings$aboutPage$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get benderblog => 'Main developer, iOS widget';
	@override String get alnair => 'Development: Library search and covers, library layout fixes, water dispenser functionality and API updates';
	@override String get aqqkad => 'Development: Class attendance history, air conditioner remote control and electricity data integration, library API updates';
	@override String get bellssgit => 'Support: best and longest feedback source';
	@override String get brackrat => 'Design: homepage, login page, color scheme, iOS widgets, etc.';
	@override String get breezeline => 'Support: valueless and meaningless product manager (from his own description)';
	@override String get cafebabe => 'Support: provide Easter egg code / Development: Development: New Slider \'26';
	@override String get chitao1234 => 'Development: fix slider misalignment issue';
	@override String get copperkoi => 'Development: latest time arrangement sync to calendar';
	@override String get dimole => 'Development support: assist in fixing slider issue';
	@override String get elitewars => 'Design: sports score page';
	@override String get elliot => 'Internationalization: English translation / Development guidance: on partner classtable development (This function has been removed)';
	@override String get flyingpig => 'Development: Fix null pointer exception at user defined class info';
	@override String get godhu777777 => 'Internationalization: Traditional Chinese conversion code & Easter egg code / Development: Optimize outputing arrangements to the calendar';
	@override String get hancl777 => 'Internationalization: Traditional Chinese conversion code';
	@override String get hazukiKeatsu => 'Development: Physics experiment score query and recognization';
	@override String get hawa130 => 'Design: Class info card';
	@override String get hhzm => 'Development: electricity fee inquiry account calculation';
	@override String get imaginary17 => 'Developement: Ruisi navigator stack fix';
	@override String get imoscarz => 'Development: Homepage for software / Development: Checkin check for pad / Development: Sport UI Change / Development: Settings category refactoring and master-detail layout adaptation';
	@override String get kaMateKaOra => 'Internationalization: English correction';
	@override String get lagrangeX => 'Development: Class progress indicator (adopted) / Development: Gray cover on attended class and other classtable design';
	@override String get lhx666Cool => 'Support: Windows and Linux build scripts / Development: New Slider \'26';
	@override String get lichtyy => 'Design: color pattern and blank page picture / Development: HTML reader for the experiment system';
	@override String get lqsyH => 'Support: Promotion Picture';
	@override String get lsy223622 => 'Design: iOS and Android icons / Support: titled XDYou';
	@override String get mrbrilliant2046 => 'Support: Provided the school net user guide / Internationalization: English correction';
	@override String get nancunchild => 'Development: library search function / Internationalization: English correction';
	@override String get nkanf => 'Development: Class progress indicator (original) / Support: MacOS build support';
	@override String get pairman => 'Development: score cache and optimize slider algorithm / Internationalization: English correction';
	@override String get reverierxu => 'Design: REX card for information display / Development support: on postgraduate class schedule';
	@override String get rrrilac => 'Development support: electricity query';
	@override String get ray => 'Design: splash screen / Support: iOS publisher / Development guidance: on partner classtable development (This function has been removed) / Internationalization: English correction';
	@override String get shadowyingyi => 'Support: two times of pigeon house official account publicity';
	@override String get stalomeow => 'Design: homepage timeline / Development: asynchronous login and captcha predict';
	@override String get xeonds => 'Design: settings page / Development: XDU Planet / Development: Payment Code';
	@override String get xingshuyu => 'Development: Fix physics experiment api and electricity graph';
	@override String get xiue233 => 'Development: Android applet';
	@override String get xizi => 'Development support: on postgraduate version';
	@override String get wirsbf => 'Development: fix course adjustment did not proceed as expected';
	@override String get zcwzy => 'Development: fix Dingxiang apartment electricity fee / development support: on postgraduate version / design: blank page picture';
	@override String get zyarEr => 'Development support: fix shortcut url';
	@override String get homepage => 'Homepage';
	@override String get code => 'Source code';
	@override String get knowMore => 'Learn more';
	@override String get copyrightNotice => 'This software is compiled, or derived from the traintime_pda (a.k.a watermeter) codebase, which is licensed under Mozilla Public License v2.0.\nThis APP has no relation to Xidian University, Tishineng Service, Shuwow and other services.\nCopyright 2023-2025 BenderBlog Rodriguez and contributors. Copyright 2025-present Traintime PDA authors.\nThe Copyright of the Software is protected by NCAC, register code is 2026SR0738647\nThe Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, you can obtain one at https://mozilla.org/MPL/2.0/.';
	@override String get beian => 'ICP record code';
	@override String get copyrightRegisterCode => 'Copyright register code';
	@override String get signAndroid => 'Android signature';
	@override String get title => 'About this APP';
	@override String get contributors => 'Contributors & acknowledgements';
	@override String get licenses => 'Open source licenses';
	@override String get extras => 'More';
	@override String get dami => 'Development: Fix negative course offset input and input validation on iOS';
	@override String get l1angyun => 'Development: Live availability of classrooms, timetable background blur, timetable layout and screen corner adaptation; fix campus network data display';
	@override String get littlestejan => 'Development: Campus network captcha refresh and captcha input dialog improvements';
	@override String get sixteenforever => 'Development: HarmonyOS port';
}

// Path: settings.editor
class _Translations$settings$editor$en extends Translations$settings$editor$zh {
	_Translations$settings$editor$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get save => 'Save';
	@override String get apply => 'Apply';
	@override String get passwordSet => 'Set';
	@override String get passwordNotSet => 'Not set';
	@override String get passwordVisibility => 'Show or hide password';
	@override String get toggleSign => 'Toggle positive or negative';
	@override String get positiveNumber => 'Enter an integer greater than 0';
	@override String get electricityUnit => 'kWh';
	@override String get textPreview => 'Course schedule · TrainTime PDA · 0123456789';
	@override String get brightness => 'Brightness';
	@override String get borderOpacity => 'Border opacity';
	@override String get fillOpacity => 'Fill opacity';
	@override String get fillSaturation => 'Fill saturation';
	@override String get textSaturation => 'Text saturation';
	@override String get backgroundBlur => 'Background blur';
	@override String get year => 'Year';
	@override String get semester => 'Semester';
}

// Path: settings.sections
class _Translations$settings$sections$en extends Translations$settings$sections$zh {
	_Translations$settings$sections$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get display => 'Display';
	@override String get languageAndText => 'Language and text';
	@override String get home => 'Home screen';
	@override String get electricity => 'Electricity alerts';
	@override String get timetableAppearance => 'Timetable appearance';
	@override String get semester => 'Semester and weeks';
	@override String get courseData => 'Course data';
}

// Path: settings.navigation
class _Translations$settings$navigation$en extends Translations$settings$navigation$zh {
	_Translations$settings$navigation$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get uiDescription => 'Theme, text, language and home display';
	@override String get classtableDescription => 'Timetable style, semester and course data';
	@override String get accountDescription => 'Accounts and passwords for campus services';
	@override String get notificationsDescription => 'Course reminders and notifications';
	@override String get coreDescription => 'Logs, cached data and sign out';
}

// Path: settings.fontSizePage
class _Translations$settings$fontSizePage$en extends Translations$settings$fontSizePage$zh {
	_Translations$settings$fontSizePage$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get sizeTitle => 'Font size';
	@override String get weightTitle => 'Font weight';
	@override String get previewTitle => 'Preview';
	@override String get weightThin => 'Thin';
	@override String get weightRegular => 'Regular';
	@override String get weightMedium => 'Medium';
	@override String get weightSemibold => 'Semi bold';
	@override String get weightBold => 'Bold';
	@override String summary({required Object scale, required Object weight}) => '${scale}% · ${weight}';
}

// Path: settings.classTableStylePage
class _Translations$settings$classTableStylePage$en extends Translations$settings$classTableStylePage$zh {
	_Translations$settings$classTableStylePage$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get frostedSection => 'Frosted backgrounds';
	@override String get frostedEnabled => 'Enable frosted backgrounds';
	@override String get frostedEnabledHint => 'When off, the controls keep their translucent tint and drop the blur';
	@override String get frostedCardSigma => 'Course card blur';
	@override String get frostedTimeLineSigma => 'Time line blur';
	@override String get frostedDateRowSigma => 'Date row blur';
	@override String get frostedWeekBarSigma => 'Week bar blur';
	@override String get frostedBannerSigma => 'Status banner blur';
	@override String get frostedAppBarSigma => 'Navigation bar blur';
	@override String get currentTimeSettingsTitle => 'Time indicator settings';
	@override String get classColorSettingsTitle => 'Class schedule style settings';
	@override String get currentTimeSection => 'Time indicator settings';
	@override String get showCurrentTimeIndicator => 'Show current time indicator';
	@override String get showCurrentTimeLabel => 'Show mini time label';
	@override String get showTodayColumnHighlight => 'Highlight today\'s column';
	@override String get activeSection => 'Course card style';
	@override String get unfinishedSection => 'Course card style';
	@override String activeBrightnessFactor({required Object value}) => 'Brightness: ${value}';
	@override String activeBorderAlpha({required Object value}) => 'Border opacity: ${value}';
	@override String activeInnerAlpha({required Object value}) => 'Fill opacity: ${value}';
	@override String get completedSection => 'Completed class style';
	@override String get completedStyleEnabled => 'Completed class styling distinction';
	@override String completedSaturationFactor({required Object value}) => 'Fill saturation: ${value}';
	@override String completedBrightnessFactor({required Object value}) => 'Brightness: ${value}';
	@override String completedTextSaturationFactor({required Object value}) => 'Text saturation: ${value}';
	@override String completedBorderAlpha({required Object value}) => 'Border opacity: ${value}';
	@override String completedInnerAlpha({required Object value}) => 'Fill opacity: ${value}';
}

// Path: core.theme.weight
class _Translations$core$theme$weight$en extends Translations$core$theme$weight$zh {
	_Translations$core$theme$weight$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get thin => 'Thin';
	@override String get regular => 'Regular';
	@override String get medium => 'Medium';
	@override String get semibold => 'Semi bold';
	@override String get bold => 'Bold';
}

// Path: core.theme.palette
class _Translations$core$theme$palette$en extends Translations$core$theme$palette$zh {
	_Translations$core$theme$palette$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get indigo => 'Default';
	@override String get blue => 'Sky Blue';
	@override String get deepPurple => 'Deep Purple';
	@override String get green => 'Spring Green';
	@override String get orange => 'Asuka Orange';
	@override String get pink => 'Sakura Pink';
}

// Path: core.theme.brightness
class _Translations$core$theme$brightness$en extends Translations$core$theme$brightness$zh {
	_Translations$core$theme$brightness$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get system => 'Follow system';
	@override String get light => 'Light';
	@override String get dark => 'Dark';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEn {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.confirm' => 'Confirm',
			'common.cancel' => 'Cancel',
			'common.unexpectProblemTitle' => 'Unexpected problem :P',
			'common.unexpectProblemHint' => 'An unexpected behavior occurred!',
			'common.errorDetected' => 'Ouch! An error occurred!',
			'common.clickToRefresh' => 'Click to refresh',
			'core.language.title' => 'Language',
			'core.language.selection' => 'App language',
			'core.language.system' => 'Follow system',
			'core.language.simplifiedChinese' => '简体中文',
			'core.language.traditionalChinese' => '繁體中文',
			'core.language.english' => 'English',
			'core.language.saveFailed' => 'Unable to save language setting',
			'core.theme.saveFailed' => 'Unable to save theme settings',
			'core.theme.display' => 'Display',
			'core.theme.languageAndText' => 'Text',
			'core.theme.colorSetting' => 'Color theme',
			'core.theme.brightnessSetting' => 'Light/Dark mode',
			'core.theme.sizeTitle' => 'Font size',
			'core.theme.weightTitle' => 'Font weight',
			'core.theme.weight.thin' => 'Thin',
			'core.theme.weight.regular' => 'Regular',
			'core.theme.weight.medium' => 'Medium',
			'core.theme.weight.semibold' => 'Semi bold',
			'core.theme.weight.bold' => 'Bold',
			'core.theme.palette.indigo' => 'Default',
			'core.theme.palette.blue' => 'Sky Blue',
			'core.theme.palette.deepPurple' => 'Deep Purple',
			'core.theme.palette.green' => 'Spring Green',
			'core.theme.palette.orange' => 'Asuka Orange',
			'core.theme.palette.pink' => 'Sakura Pink',
			'core.theme.brightness.system' => 'Follow system',
			'core.theme.brightness.light' => 'Light',
			'core.theme.brightness.dark' => 'Dark',
			'core.gridPage.label' => 'Info',
			'core.gridPage.title' => 'School Info Center',
			'core.gridPage.editMode' => 'Edit Layout',
			'core.gridPage.editDone' => 'Done',
			'core.gridPage.editReset' => 'Reset Layout',
			'core.gridPage.manageHidden' => 'Manage hidden cards',
			'core.gridPage.hideEmpty' => 'No hidden cards',
			'settings.title' => 'Settings',
			'settings.aboutInfo' => 'APP info',
			'settings.acknowledgement' => ({required Object developers}) => 'Made With Love From ${developers} People',
			'settings.about' => 'About',
			'settings.aboutThisProgram' => 'About this APP',
			'settings.version' => ({required Object version}) => 'Version：${version}',
			'settings.userInfo' => 'User information',
			'settings.checkUpdate' => 'Check for updates',
			'settings.latestVersion' => ({required Object latest}) => 'Latest version: ${latest}',
			'settings.waiting' => 'Waiting for obtain',
			'settings.fetchingUpdate' => 'Fetching update information',
			'settings.newVersion' => 'New version released，PLEASE UPDATE AT ONCE!',
			'settings.currentStable' => 'You are running the latest version',
			'settings.currentTesting' => 'You are running the testing version',
			'settings.fetchFailed' => 'Failed to fetch update information',
			'settings.uiSetting' => 'UI Settings',
			'settings.brightnessSetting' => 'Light/Dark mode',
			'settings.colorSetting' => 'Color theme',
			'settings.simplifyTimeline' => 'Simplify schedule timeline',
			'settings.simplifyTimelineDescription' => 'Reduce space occupation while no schedule',
			'settings.lowElectricityWarning' => 'Low electricity card color warning',
			'settings.lowElectricityWarningDescription' => 'Change the homepage electricity card color when remaining electricity is below the threshold',
			'settings.lowElectricityThreshold' => 'Low electricity threshold',
			'settings.lowElectricityThresholdDescription' => ({required Object threshold}) => 'Current: ${threshold} kWh',
			'settings.lowElectricityThresholdDialog.title' => 'Set low electricity threshold',
			'settings.lowElectricityThresholdDialog.inputHint' => 'Input remaining electricity',
			'settings.accountSetting' => 'Account Settings',
			'settings.sportPasswordSetting' => 'PE system password',
			'settings.experimentPasswordSetting' => 'Physics experiment password',
			'settings.electricityPasswordSetting' => 'Electricity account password',
			'settings.electricityPasswordDescription' => 'Please set if not default',
			'settings.electricityAccountSetting' => 'Electricity account setting',
			'settings.schoolnetPasswordSetting' => 'Campus net password',
			'settings.schoolnetPasswordDescription' => 'If you have not setted it, you cannot query it.',
			'settings.airconImeiTitle' => 'Aircon device',
			'settings.airconImei' => 'Aircon IMEI',
			'settings.airconImeiNotSet' => 'Not set. Aircon data and remote control are unavailable.',
			'settings.airconImeiCurrent' => ({required Object imei}) => 'Current IMEI: ${imei}',
			'settings.airconImeiSaved' => 'Aircon IMEI saved',
			'settings.airconImeiCleared' => 'Aircon IMEI cleared',
			'settings.airconImeiInvalid' => 'No valid 15-digit IMEI found',
			'settings.airconImeiClear' => 'Clear',
			'settings.scanAirconQr' => 'Scan aircon QR code',
			'settings.pickAirconQrImage' => 'Choose QR image',
			'settings.airconCameraUnavailable' => 'Camera scanning is unavailable on this platform. Choose a QR image or enter the IMEI manually.',
			'settings.airconScanHint' => 'Tap to focus. If the aircon is far away and stays blurry when zoomed in, take a photo with the system camera instead.',
			'settings.airconTakePhoto' => 'Take a photo with the system camera',
			'settings.airconCameraError' => ({required Object error}) => 'Unable to open the camera: ${error}',
			'settings.notificationSetting' => 'Notification Settings',
			'settings.courseReminderSetting' => 'Pre-class Reminder Settings',
			'settings.courseReminderDescription' => 'Configure pre-class reminder notifications',
			'settings.notificationPage.title' => 'Pre-class Reminder Settings',
			'settings.notificationPage.loadFailed' => ({required Object error}) => 'Failed to load settings: ${error}',
			'settings.notificationPage.functionSection' => 'Notification Function',
			'settings.notificationPage.enableNotification' => 'Enable Pre-class Reminders',
			'settings.notificationPage.notificationScheduled' => ({required Object count}) => '${count} notifications scheduled',
			'settings.notificationPage.notificationDisabledHint' => 'All scheduled notifications will be cancelled when disabled',
			'settings.notificationPage.updateSchedule' => 'Update Notification Schedule',
			'settings.notificationPage.updateScheduleHint' => 'Reschedule notifications based on the latest course data',
			'settings.notificationPage.deleteAllSchedule' => 'Delete All Scheduled Reminder',
			'settings.notificationPage.deleteAllScheduleHint' => 'This action will delete all scheduled events, but you can click \'Update Notification Schedule\' again to re-add them.',
			'settings.notificationPage.deleteAllSuccess' => 'Delete successfully',
			'settings.notificationPage.viewTheInstructions' => 'View the instructions',
			'settings.notificationPage.viewTheInstructionsHint' => 'Check more instructions to ensure that you can see the notifications sent by the program',
			'settings.notificationPage.permissionSection' => 'Permission Status',
			'settings.notificationPage.notificationPermission' => 'Notification Permission',
			'settings.notificationPage.exactAlarmPermission' => 'Exact Alarm Permission',
			'settings.notificationPage.permissionGranted' => 'Granted',
			'settings.notificationPage.permissionDenied' => 'Denied',
			'settings.notificationPage.requestPermission' => 'Request Permission',
			'settings.notificationPage.systemSettings' => 'System Notification Settings',
			'settings.notificationPage.systemSettingsHint' => 'Open system settings to check notification configuration',
			'settings.notificationPage.permissionGrantedMsg' => 'Permission granted',
			'settings.notificationPage.permissionDeniedMsg' => 'Permission denied, please enable it in system settings',
			'settings.notificationPage.reminderSection' => 'Reminder Settings',
			'settings.notificationPage.experimentReminder' => 'Include the physics experiments',
			'settings.notificationPage.experimentReminderHint' => 'Enable this option to add the physics experiment to the Pre-class Reminder',
			'settings.notificationPage.minutesBefore' => 'Advance Reminder Time',
			'settings.notificationPage.minutesBeforeHint' => 'The time setting for pre-class reminders',
			'settings.notificationPage.minutesUnit' => 'minutes',
			'settings.notificationPage.daysToSchedule' => 'Schedule Duration',
			'settings.notificationPage.daysToScheduleHint' => 'This program writes course information into the planned schedule in advance. This setting can adjust the number of days for writing into the planned schedule',
			'settings.notificationPage.daysUnit' => 'days',
			'settings.notificationPage.settingsGuideTitle' => 'Notification Settings Guide',
			'settings.notificationPage.settingsGuideContent1' => 'To ensure you receive pre-class reminders in time, please make sure:\n1. App notification permission is enabled\n2. Notification sound is enabled\n3. Banner notifications are enabled\n4. Non-native Android users, enable auto-start and disable power optimization',
			'settings.notificationPage.settingsGuideContent2' => 'Pre-class Reminder Module Operating Mechanism:\n1. When first activated, it will automatically schedule pre-class reminders for the upcoming days\n2. Each time the app is opened, it will automatically check and update the notification schedule\n3. After modifying settings, it will automatically reschedule all notifications',
			'settings.notificationPage.gotIt' => 'Got it',
			'settings.notificationPage.openSettings' => 'Open System Settings',
			'settings.notificationPage.noClasstableData' => 'Please fetch course schedule, exam, or experiment data first',
			'settings.notificationPage.scheduleSuccess' => ({required Object count}) => 'Scheduled ${count} pre-class reminders',
			'settings.notificationPage.scheduleFailed' => ({required Object error}) => 'Failed to schedule notifications: ${error}',
			'settings.notificationPage.cancelAllSuccess' => 'All pre-class reminders cancelled',
			'settings.notificationPage.rescheduleSuccess' => ({required Object count}) => 'Rescheduled ${count} pre-class reminders',
			'settings.notificationPage.rescheduleFailed' => ({required Object error}) => 'Failed to reschedule notifications: ${error}',
			'settings.notificationDebugPage' => 'Notification status and test',
			'settings.classtableSetting' => 'Class Schedule Related',
			'settings.background' => 'Background image',
			'settings.noBackground' => 'You need to select an image first, it\'s at below',
			'settings.chooseBackground' => 'Choose background image',
			'settings.noPermission' => 'No storage permission obtained, cannot read files',
			'settings.successfulSetting' => 'Successfully set',
			'settings.failureSetting' => 'You did not select an image',
			'settings.clearUserClass' => 'Clear all customized courses',
			'settings.clearUserClassTitle' => 'Clear Confirmation',
			'settings.clearUserClassContent' => 'Do you want to clear all user-added courses? This function does not affect the schedule obtained from the school.',
			'settings.clearUserClassClear' => 'Already cleared',
			'settings.classRefresh' => 'Force refresh class schedule',
			'settings.classRefreshTitle' => 'Refresh Confirmation',
			'settings.classRefreshContent' => 'Do you want to force refreshing the class schedule? If you agree, we will fetch the schedule from the school, which may takes a long time.',
			'settings.classSwift' => 'Class schedule offset setting',
			'settings.classSwiftDescription' => ({required Object swift}) => 'Currently ${swift}',
			'settings.coreSetting' => 'Cached login settings',
			'settings.checkLogger' => 'View network interceptor and logs',
			'settings.clearAndRestart' => 'Clear cache and restart',
			'settings.clearAndRestartDialog.title' => 'Restart confirmation',
			'settings.clearAndRestartDialog.content' => 'Are you sure to clear cache and restart the program?',
			'settings.clearAndRestartDialog.cleaning' => 'Clearing cache...',
			'settings.clearAndRestartDialog.clear' => 'Cache has been cleared',
			'settings.logout' => 'Log out and restart the app',
			'settings.logoutDialog.title' => 'Logout confirmation',
			'settings.logoutDialog.content' => 'Are you want to log out? All your data will be completely deleted!',
			'settings.logoutDialog.loggingOut' => 'Logging out...',
			'settings.needCloseDialog.title' => 'Crashed',
			'settings.needCloseDialog.content' => 'Due to technical limitations, you need to close the window manually and then reopen the app.',
			'settings.changeColorDialog.title' => 'Color setting',
			'settings.changeColorDialog.kDefault' => 'Default',
			'settings.changeColorDialog.blue' => 'Sky Blue',
			'settings.changeColorDialog.deepPurple' => 'Deep Purple',
			'settings.changeColorDialog.green' => 'Spring Green',
			'settings.changeColorDialog.orange' => 'Asuka Orange',
			'settings.changeColorDialog.pink' => 'Sakura Pink',
			'settings.changeBrightnessDialog.title' => 'Brightness settings',
			'settings.changeBrightnessDialog.followSetting' => 'Follow system',
			'settings.changeBrightnessDialog.dayMode' => 'Light',
			'settings.changeBrightnessDialog.nightMode' => 'Dark',
			'settings.changeSwiftDialog.title' => 'Class schedule offset setting',
			'settings.changeSwiftDialog.inputHint' => 'Please input number here',
			'settings.changeSwiftDialog.invalidNumber' => 'Please enter a valid whole number',
			'settings.changeElectricityTitle' => 'Modify electricity account',
			'settings.changeElectricityAccount.title' => 'Modify electricity account',
			'settings.changeElectricityAccount.campus' => 'Campus',
			'settings.changeElectricityAccount.northCampus' => 'Northern Campus',
			'settings.changeElectricityAccount.southCampus' => 'Southern Campus',
			'settings.changeElectricityAccount.unitOrZone' => 'Unit  / Zone',
			'settings.changeElectricityAccount.unitCode' => 'Unit',
			'settings.changeElectricityAccount.zoneCode' => 'Zone',
			'settings.changeElectricityAccount.pleaseInput' => ({required Object unit_or_zone_code}) => 'Please input ${unit_or_zone_code}',
			'settings.changeElectricityAccount.successfulFetch' => ({required Object account_number}) => 'Successful fetching account: ${account_number}',
			'settings.changeElectricityAccount.failedFetch' => ({required Object e}) => 'Failed to fetch: ${e}',
			'settings.changeElectricityAccount.accountSaved' => ({required Object account_number}) => 'Account saved：${account_number}',
			'settings.changeElectricityAccount.unknownCodingPattern' => 'Unknown coding pattern',
			'settings.changeElectricityAccount.selectBuilding' => 'Select Building',
			'settings.changeElectricityAccount.building' => 'Building',
			'settings.changeElectricityAccount.northernBuilding' => 'Northern Building',
			'settings.changeElectricityAccount.southernBuilding' => 'Southern Building',
			'settings.changeElectricityAccount.failedGenerate' => ({required Object e}) => 'Failed to generate: ${e}',
			'settings.changeElectricityAccount.buildingNumber' => 'Building number',
			'settings.changeElectricityAccount.buildingNumberHint' => 'eg: 16, 7, 55',
			'settings.changeElectricityAccount.buildingNumberQuery' => 'Please input building No.',
			'settings.changeElectricityAccount.yard' => 'Yard',
			'settings.changeElectricityAccount.yardHint' => 'Select Yard',
			'settings.changeElectricityAccount.northYard' => 'North Yard',
			'settings.changeElectricityAccount.southYard' => 'South Yard',
			'settings.changeElectricityAccount.yardQuery' => 'Please select yard',
			'settings.changeElectricityAccount.apartment' => 'Apartment',
			'settings.changeElectricityAccount.apartmentHint' => 'Select Apartment',
			'settings.changeElectricityAccount.northApartment' => 'North Apartment',
			'settings.changeElectricityAccount.southApartment' => 'South Apartment',
			'settings.changeElectricityAccount.apartmentQuery' => 'Please select apartment',
			'settings.changeElectricityAccount.levelCode' => 'Floor number',
			'settings.changeElectricityAccount.levelCodeQuery' => 'Floor number',
			'settings.changeElectricityAccount.roomCode' => 'Room code',
			'settings.changeElectricityAccount.roomCodeHint' => 'eg: 304, 508',
			'settings.changeElectricityAccount.roomCodeQuery' => 'Please input room code',
			'settings.changeElectricityAccount.account' => 'Electricity Account',
			'settings.changeElectricityAccount.accountHint' => 'Please enter your account',
			'settings.changeElectricityAccount.accountQuery' => 'Please input your account',
			'settings.changeElectricityAccount.accountLength' => 'Account length is larger than 10',
			'settings.changeElectricityAccount.fetching' => 'Fetching...',
			'settings.changeElectricityAccount.fetchFromInternet' => 'Sync from backend',
			'settings.changeElectricityAccount.saveAccount' => 'Save account',
			'settings.changeElectricityAccount.confirmSaving' => 'Confirm account',
			'settings.changeElectricityAccount.calculateAccount' => 'Calculate account',
			'settings.changeElectricityAccount.calculate' => 'Calculate',
			'settings.changeElectricityAccount.input' => 'Input',
			'settings.changeElectricityAccount.confirmAccount' => 'Confirm your account: ',
			'settings.changeElectricityAccount.change' => 'Edit',
			'settings.changeElectricityAccount.cancel' => 'Cancel',
			'settings.changeElectricityAccount.noSetting' => 'No new electricity account set',
			'settings.changeElectricityAccount.successfulSetting' => 'Successfully setting new electricity account',
			'settings.changeExperimentTitle' => 'Modify physics experiment account password',
			'settings.changeSportTitle' => 'Modify sports system account password',
			'settings.changePasswordDialog.inputHint' => 'Please input password here',
			'settings.changePasswordDialog.blankInput' => 'Blank input!',
			'settings.changeSchoolnetPasswordTitle' => 'Modify the schoolnet query password',
			'settings.updateDialog.newVersion' => 'New version available',
			'settings.updateDialog.notNow' => 'Not now',
			'settings.updateDialog.appStore' => 'Update from App Store',
			'settings.updateDialog.downloadApk' => 'Download APK',
			'settings.updateDialog.githubRelease' => 'Go to Git Release',
			'settings.updateDialog.newContent' => ({required Object code}) => 'New features from version ${code}:\n',
			'settings.localizationDialog.title' => 'Languages',
			'settings.localizationDialog.undefined' => 'Follow system setting',
			'settings.localizationDialog.simplifiedChinese' => 'Simplified Chinese',
			'settings.localizationDialog.traditionalChinese' => 'Traditional Chinese',
			'settings.localizationDialog.english' => 'English',
			'settings.semesterChange' => 'Change semester',
			'settings.semesterChangeDescription' => ({required Object semester}) => 'Using semester ${semester}',
			'settings.semesterUpdateData' => 'Applying new semester setting',
			'settings.easterEggPage' => 'You found an Easter egg',
			'settings.aboutPage.benderblog' => 'Main developer, iOS widget',
			'settings.aboutPage.alnair' => 'Development: Library search and covers, library layout fixes, water dispenser functionality and API updates',
			'settings.aboutPage.aqqkad' => 'Development: Class attendance history, air conditioner remote control and electricity data integration, library API updates',
			'settings.aboutPage.bellssgit' => 'Support: best and longest feedback source',
			'settings.aboutPage.brackrat' => 'Design: homepage, login page, color scheme, iOS widgets, etc.',
			'settings.aboutPage.breezeline' => 'Support: valueless and meaningless product manager (from his own description)',
			'settings.aboutPage.cafebabe' => 'Support: provide Easter egg code / Development: Development: New Slider \'26',
			'settings.aboutPage.chitao1234' => 'Development: fix slider misalignment issue',
			'settings.aboutPage.copperkoi' => 'Development: latest time arrangement sync to calendar',
			'settings.aboutPage.dimole' => 'Development support: assist in fixing slider issue',
			'settings.aboutPage.elitewars' => 'Design: sports score page',
			'settings.aboutPage.elliot' => 'Internationalization: English translation / Development guidance: on partner classtable development (This function has been removed)',
			'settings.aboutPage.flyingpig' => 'Development: Fix null pointer exception at user defined class info',
			'settings.aboutPage.godhu777777' => 'Internationalization: Traditional Chinese conversion code & Easter egg code / Development: Optimize outputing arrangements to the calendar',
			'settings.aboutPage.hancl777' => 'Internationalization: Traditional Chinese conversion code',
			'settings.aboutPage.hazukiKeatsu' => 'Development: Physics experiment score query and recognization',
			'settings.aboutPage.hawa130' => 'Design: Class info card',
			'settings.aboutPage.hhzm' => 'Development: electricity fee inquiry account calculation',
			'settings.aboutPage.imaginary17' => 'Developement: Ruisi navigator stack fix',
			'settings.aboutPage.imoscarz' => 'Development: Homepage for software / Development: Checkin check for pad / Development: Sport UI Change / Development: Settings category refactoring and master-detail layout adaptation',
			'settings.aboutPage.kaMateKaOra' => 'Internationalization: English correction',
			'settings.aboutPage.lagrangeX' => 'Development: Class progress indicator (adopted) / Development: Gray cover on attended class and other classtable design',
			'settings.aboutPage.lhx666Cool' => 'Support: Windows and Linux build scripts / Development: New Slider \'26',
			'settings.aboutPage.lichtyy' => 'Design: color pattern and blank page picture / Development: HTML reader for the experiment system',
			'settings.aboutPage.lqsyH' => 'Support: Promotion Picture',
			'settings.aboutPage.lsy223622' => 'Design: iOS and Android icons / Support: titled XDYou',
			'settings.aboutPage.mrbrilliant2046' => 'Support: Provided the school net user guide / Internationalization: English correction',
			'settings.aboutPage.nancunchild' => 'Development: library search function / Internationalization: English correction',
			'settings.aboutPage.nkanf' => 'Development: Class progress indicator (original) / Support: MacOS build support',
			'settings.aboutPage.pairman' => 'Development: score cache and optimize slider algorithm / Internationalization: English correction',
			'settings.aboutPage.reverierxu' => 'Design: REX card for information display / Development support: on postgraduate class schedule',
			'settings.aboutPage.rrrilac' => 'Development support: electricity query',
			'settings.aboutPage.ray' => 'Design: splash screen / Support: iOS publisher / Development guidance: on partner classtable development (This function has been removed) / Internationalization: English correction',
			'settings.aboutPage.shadowyingyi' => 'Support: two times of pigeon house official account publicity',
			'settings.aboutPage.stalomeow' => 'Design: homepage timeline / Development: asynchronous login and captcha predict',
			'settings.aboutPage.xeonds' => 'Design: settings page / Development: XDU Planet / Development: Payment Code',
			'settings.aboutPage.xingshuyu' => 'Development: Fix physics experiment api and electricity graph',
			'settings.aboutPage.xiue233' => 'Development: Android applet',
			'settings.aboutPage.xizi' => 'Development support: on postgraduate version',
			'settings.aboutPage.wirsbf' => 'Development: fix course adjustment did not proceed as expected',
			'settings.aboutPage.zcwzy' => 'Development: fix Dingxiang apartment electricity fee / development support: on postgraduate version / design: blank page picture',
			'settings.aboutPage.zyarEr' => 'Development support: fix shortcut url',
			'settings.aboutPage.homepage' => 'Homepage',
			'settings.aboutPage.code' => 'Source code',
			'settings.aboutPage.knowMore' => 'Learn more',
			'settings.aboutPage.copyrightNotice' => 'This software is compiled, or derived from the traintime_pda (a.k.a watermeter) codebase, which is licensed under Mozilla Public License v2.0.\nThis APP has no relation to Xidian University, Tishineng Service, Shuwow and other services.\nCopyright 2023-2025 BenderBlog Rodriguez and contributors. Copyright 2025-present Traintime PDA authors.\nThe Copyright of the Software is protected by NCAC, register code is 2026SR0738647\nThe Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, you can obtain one at https://mozilla.org/MPL/2.0/.',
			'settings.aboutPage.beian' => 'ICP record code',
			'settings.aboutPage.copyrightRegisterCode' => 'Copyright register code',
			'settings.aboutPage.signAndroid' => 'Android signature',
			'settings.aboutPage.title' => 'About this APP',
			'settings.aboutPage.contributors' => 'Contributors & acknowledgements',
			'settings.aboutPage.licenses' => 'Open source licenses',
			'settings.aboutPage.extras' => 'More',
			'settings.aboutPage.dami' => 'Development: Fix negative course offset input and input validation on iOS',
			'settings.aboutPage.l1angyun' => 'Development: Live availability of classrooms, timetable background blur, timetable layout and screen corner adaptation; fix campus network data display',
			'settings.aboutPage.littlestejan' => 'Development: Campus network captcha refresh and captcha input dialog improvements',
			'settings.aboutPage.sixteenforever' => 'Development: HarmonyOS port',
			'settings.editor.save' => 'Save',
			'settings.editor.apply' => 'Apply',
			'settings.editor.passwordSet' => 'Set',
			'settings.editor.passwordNotSet' => 'Not set',
			'settings.editor.passwordVisibility' => 'Show or hide password',
			'settings.editor.toggleSign' => 'Toggle positive or negative',
			'settings.editor.positiveNumber' => 'Enter an integer greater than 0',
			'settings.editor.electricityUnit' => 'kWh',
			'settings.editor.textPreview' => 'Course schedule · TrainTime PDA · 0123456789',
			'settings.editor.brightness' => 'Brightness',
			'settings.editor.borderOpacity' => 'Border opacity',
			'settings.editor.fillOpacity' => 'Fill opacity',
			'settings.editor.fillSaturation' => 'Fill saturation',
			'settings.editor.textSaturation' => 'Text saturation',
			'settings.editor.backgroundBlur' => 'Background blur',
			'settings.editor.year' => 'Year',
			'settings.editor.semester' => 'Semester',
			'settings.sections.display' => 'Display',
			'settings.sections.languageAndText' => 'Language and text',
			'settings.sections.home' => 'Home screen',
			'settings.sections.electricity' => 'Electricity alerts',
			'settings.sections.timetableAppearance' => 'Timetable appearance',
			'settings.sections.semester' => 'Semester and weeks',
			'settings.sections.courseData' => 'Course data',
			'settings.navigation.uiDescription' => 'Theme, text, language and home display',
			'settings.navigation.classtableDescription' => 'Timetable style, semester and course data',
			'settings.navigation.accountDescription' => 'Accounts and passwords for campus services',
			'settings.navigation.notificationsDescription' => 'Course reminders and notifications',
			'settings.navigation.coreDescription' => 'Logs, cached data and sign out',
			'settings.fontSizeSetting' => 'Font size & weight',
			'settings.fontSizePage.sizeTitle' => 'Font size',
			'settings.fontSizePage.weightTitle' => 'Font weight',
			'settings.fontSizePage.previewTitle' => 'Preview',
			'settings.fontSizePage.weightThin' => 'Thin',
			'settings.fontSizePage.weightRegular' => 'Regular',
			'settings.fontSizePage.weightMedium' => 'Medium',
			'settings.fontSizePage.weightSemibold' => 'Semi bold',
			'settings.fontSizePage.weightBold' => 'Bold',
			'settings.fontSizePage.summary' => ({required Object scale, required Object weight}) => '${scale}% · ${weight}',
			'settings.generalAccountSettings' => 'General accounts',
			'settings.undergraduateSystemAccounts' => 'Undergraduate system accounts',
			'settings.classTableBackgroundSection' => 'Class schedule background',
			'settings.backgroundBlur' => ({required Object value}) => 'Background blur: ${value}',
			'settings.backgroundBlurOff' => 'Off',
			'settings.classTableStyleSetting' => 'Class schedule display & style',
			'settings.classTableStyleDescription' => 'Time indicator and course card style',
			'settings.classTableStylePage.frostedSection' => 'Frosted backgrounds',
			'settings.classTableStylePage.frostedEnabled' => 'Enable frosted backgrounds',
			'settings.classTableStylePage.frostedEnabledHint' => 'When off, the controls keep their translucent tint and drop the blur',
			'settings.classTableStylePage.frostedCardSigma' => 'Course card blur',
			'settings.classTableStylePage.frostedTimeLineSigma' => 'Time line blur',
			'settings.classTableStylePage.frostedDateRowSigma' => 'Date row blur',
			'settings.classTableStylePage.frostedWeekBarSigma' => 'Week bar blur',
			'settings.classTableStylePage.frostedBannerSigma' => 'Status banner blur',
			'settings.classTableStylePage.frostedAppBarSigma' => 'Navigation bar blur',
			'settings.classTableStylePage.currentTimeSettingsTitle' => 'Time indicator settings',
			'settings.classTableStylePage.classColorSettingsTitle' => 'Class schedule style settings',
			'settings.classTableStylePage.currentTimeSection' => 'Time indicator settings',
			'settings.classTableStylePage.showCurrentTimeIndicator' => 'Show current time indicator',
			'settings.classTableStylePage.showCurrentTimeLabel' => 'Show mini time label',
			'settings.classTableStylePage.showTodayColumnHighlight' => 'Highlight today\'s column',
			'settings.classTableStylePage.activeSection' => 'Course card style',
			'settings.classTableStylePage.unfinishedSection' => 'Course card style',
			'settings.classTableStylePage.activeBrightnessFactor' => ({required Object value}) => 'Brightness: ${value}',
			'settings.classTableStylePage.activeBorderAlpha' => ({required Object value}) => 'Border opacity: ${value}',
			'settings.classTableStylePage.activeInnerAlpha' => ({required Object value}) => 'Fill opacity: ${value}',
			'settings.classTableStylePage.completedSection' => 'Completed class style',
			'settings.classTableStylePage.completedStyleEnabled' => 'Completed class styling distinction',
			'settings.classTableStylePage.completedSaturationFactor' => ({required Object value}) => 'Fill saturation: ${value}',
			'settings.classTableStylePage.completedBrightnessFactor' => ({required Object value}) => 'Brightness: ${value}',
			'settings.classTableStylePage.completedTextSaturationFactor' => ({required Object value}) => 'Text saturation: ${value}',
			'settings.classTableStylePage.completedBorderAlpha' => ({required Object value}) => 'Border opacity: ${value}',
			'settings.classTableStylePage.completedInnerAlpha' => ({required Object value}) => 'Fill opacity: ${value}',
			'settings.classSwiftExplain' => 'Positive number delays the start date, negative number advances the start date',
			_ => null,
		};
	}
}
