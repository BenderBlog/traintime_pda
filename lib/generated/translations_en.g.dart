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
class TranslationsEn with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsEn _root = this; // ignore: unused_field

	@override 
	TranslationsEn $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEn(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$classAttendance$en classAttendance = _Translations$classAttendance$en._(_root);
	@override late final _Translations$classtable$en classtable = _Translations$classtable$en._(_root);
	@override late final _Translations$clubPromotion$en clubPromotion = _Translations$clubPromotion$en._(_root);
	@override late final _Translations$common$en common = _Translations$common$en._(_root);
	@override late final _Translations$courseReminder$en courseReminder = _Translations$courseReminder$en._(_root);
	@override late final _Translations$dormWater$en dormWater = _Translations$dormWater$en._(_root);
	@override late final _Translations$easterEggRobot$en easterEggRobot = _Translations$easterEggRobot$en._(_root);
	@override late final _Translations$electricity$en electricity = _Translations$electricity$en._(_root);
	@override late final _Translations$electricityStatus$en electricityStatus = _Translations$electricityStatus$en._(_root);
	@override late final _Translations$emptyClassroom$en emptyClassroom = _Translations$emptyClassroom$en._(_root);
	@override late final _Translations$exam$en exam = _Translations$exam$en._(_root);
	@override late final _Translations$experiment$en experiment = _Translations$experiment$en._(_root);
	@override late final _Translations$experimentController$en experimentController = _Translations$experimentController$en._(_root);
	@override late final _Translations$homepage$en homepage = _Translations$homepage$en._(_root);
	@override late final _Translations$library$en library = _Translations$library$en._(_root);
	@override late final _Translations$libraryCard$en libraryCard = _Translations$libraryCard$en._(_root);
	@override late final _Translations$login$en login = _Translations$login$en._(_root);
	@override late final _Translations$loginProcess$en loginProcess = _Translations$loginProcess$en._(_root);
	@override late final _Translations$month$en month = _Translations$month$en._(_root);
	@override late final _Translations$restartApp$en restartApp = _Translations$restartApp$en._(_root);
	@override late final _Translations$ruisi$en ruisi = _Translations$ruisi$en._(_root);
	@override late final _Translations$schoolCardStatus$en schoolCardStatus = _Translations$schoolCardStatus$en._(_root);
	@override late final _Translations$schoolCardWindow$en schoolCardWindow = _Translations$schoolCardWindow$en._(_root);
	@override late final _Translations$schoolNet$en schoolNet = _Translations$schoolNet$en._(_root);
	@override late final _Translations$score$en score = _Translations$score$en._(_root);
	@override late final _Translations$setting$en setting = _Translations$setting$en._(_root);
	@override late final _Translations$sport$en sport = _Translations$sport$en._(_root);
	@override late final _Translations$toolbox$en toolbox = _Translations$toolbox$en._(_root);
	@override late final _Translations$weekday$en weekday = _Translations$weekday$en._(_root);
	@override late final _Translations$xduPlanet$en xduPlanet = _Translations$xduPlanet$en._(_root);
}

// Path: classAttendance
class _Translations$classAttendance$en implements Translations$classAttendance$zh_CN {
	_Translations$classAttendance$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Attendance Query';
	@override String detailTitle({required Object course_name}) => 'Attendance Detail - ${course_name}';
	@override String get noData => 'No course info';
	@override String get noAttendanceRecord => 'No attendance record';
	@override String get longLoad => 'It takes about half minute to load attendance data, pleace wait patiently';
	@override late final _Translations$classAttendance$courseState$en courseState = _Translations$classAttendance$courseState$en._(_root);
	@override late final _Translations$classAttendance$table$en table = _Translations$classAttendance$table$en._(_root);
	@override late final _Translations$classAttendance$card$en card = _Translations$classAttendance$card$en._(_root);
	@override late final _Translations$classAttendance$detailCard$en detailCard = _Translations$classAttendance$detailCard$en._(_root);
	@override late final _Translations$classAttendance$signType$en signType = _Translations$classAttendance$signType$en._(_root);
	@override late final _Translations$classAttendance$signStatus$en signStatus = _Translations$classAttendance$signStatus$en._(_root);
}

// Path: classtable
class _Translations$classtable$en implements Translations$classtable$zh_CN {
	_Translations$classtable$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$classtable$partnerClasstable$en partnerClasstable = _Translations$classtable$partnerClasstable$en._(_root);
	@override String get pageTitle => 'My Schedule';
	@override String partnerPageTitle({required Object partner_name}) => '${partner_name}\'s Schedule';
	@override late final _Translations$classtable$popupMenu$en popupMenu = _Translations$classtable$popupMenu$en._(_root);
	@override late final _Translations$classtable$visualSettings$en visualSettings = _Translations$classtable$visualSettings$en._(_root);
	@override late final _Translations$classtable$statusSource$en statusSource = _Translations$classtable$statusSource$en._(_root);
	@override String get errorDialogTitle => 'Error Info';
	@override late final _Translations$classtable$statusBanner$en statusBanner = _Translations$classtable$statusBanner$en._(_root);
	@override late final _Translations$classtable$emptyState$en emptyState = _Translations$classtable$emptyState$en._(_root);
	@override late final _Translations$classtable$emptyAction$en emptyAction = _Translations$classtable$emptyAction$en._(_root);
	@override late final _Translations$classtable$classChangePage$en classChangePage = _Translations$classtable$classChangePage$en._(_root);
	@override late final _Translations$classtable$notArrangedPage$en notArrangedPage = _Translations$classtable$notArrangedPage$en._(_root);
	@override String emptyClassMessage({required Object semester_code}) => 'Semester ${semester_code} has no class arranged';
	@override String emptyClassWithExam({required Object semester_code}) => 'Semester ${semester_code} has no class arranged\nbut we have exam info now!\nGo back to mainpage and goto the exam info page.';
	@override String weekTitle({required Object week}) => 'Week ${week}';
	@override String get noonBreak => 'Noon';
	@override String get supperBreak => 'Supper';
	@override String month({required Object month}) => '${month}\nmo';
	@override String get noClass => 'No schedule arranged in this week, please do not spend much of your time on bed.';
	@override late final _Translations$classtable$classCard$en classCard = _Translations$classtable$classCard$en._(_root);
	@override late final _Translations$classtable$classAdd$en classAdd = _Translations$classtable$classAdd$en._(_root);
	@override late final _Translations$classtable$courseDetailCard$en courseDetailCard = _Translations$classtable$courseDetailCard$en._(_root);
	@override late final _Translations$classtable$outputToSystem$en outputToSystem = _Translations$classtable$outputToSystem$en._(_root);
	@override late final _Translations$classtable$refreshClasstable$en refreshClasstable = _Translations$classtable$refreshClasstable$en._(_root);
	@override String get cacheHintPasswordWrong => 'IDS password is incorrect or expired.';
	@override String get cacheHintLoginFailed => 'Failed to log in to the classtable service.';
	@override String get cacheHintNetworkFailed => 'Classtable network request failed.';
	@override String get cacheHintUnknownError => 'Failed to fetch the latest classtable online. Check logs for details.';
	@override late final _Translations$classtable$semesterSwitcher$en semesterSwitcher = _Translations$classtable$semesterSwitcher$en._(_root);
}

// Path: clubPromotion
class _Translations$clubPromotion$en implements Translations$clubPromotion$zh_CN {
	_Translations$clubPromotion$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$clubPromotion$type$en type = _Translations$clubPromotion$type$en._(_root);
	@override String get wrongParam => 'Wrong Parameter';
	@override String get noGroupInfo => 'No Club info';
	@override String get loading => 'Loading';
	@override String get errorOutside => 'Error detected at the outside';
	@override String get error => 'Error detected';
	@override String get qqCopied => 'QQ Group Number have been copied to the clipboard';
	@override String get noLink => 'No group invite link provided';
	@override String get loadingProblem => 'Error on loading page';
	@override String get picturePreview => 'Picture';
}

// Path: common
class _Translations$common$en implements Translations$common$zh_CN {
	_Translations$common$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get dragText => 'Pull to request more';
	@override String get readyText => 'Loading...';
	@override String get processingText => 'Processing...';
	@override String get processedText => 'Successfully requested';
	@override String get noMoreText => 'No more data';
	@override String get failedText => 'Failed to load data';
	@override String get chooseSemester => 'Choose Semester';
	@override String get errorDetected => 'Ouch! An error occurred!';
	@override String get clickToRefresh => 'Click to refresh';
	@override String get confirmTitle => 'Confirm? (ゝ∀･)';
	@override String get cancel => 'Cancel';
	@override String get confirm => 'Okay';
	@override String get networkError => 'Network error, maybe you are not connected to the Internet, or the school server is down :P';
	@override String get errorDetect => 'An error has occurred,';
	@override String get queryFailed => 'Query failed';
	@override String get notSchoolNetwork => 'Not on the Campus Network';
	@override String get cancelExam => 'Disqualified to exam :P';
	@override String get noInfo => 'No information';
	@override String get catcherDetected => 'An error has occurred';
	@override String get catcherDescription => 'Details are shown as follows';
	@override String get newHomepageHint => 'A new homepage is developing here, the pigimg is a placeholder, have fun';
	@override String localCacheHint({required Object datetime}) => 'Local cache from ${datetime}';
	@override String inappCacheHint({required Object datetime}) => 'In-app cache from ${datetime}\nCache will be cleared once restart!';
	@override String get cacheReasonDefault => 'Showing cached data.';
	@override String get easterEggApple => '=== Fly Me To The Moon ===\nVocal: Frank Sintara, 1964\n\nFly me to the moon\nLet me play among the stars\n\nLet me see what\'s spring is like\non a Jupiter and Mars\n\nFill my heart with song\nand let me sing forever more\n\nYou are all I long for\nall I worship and I adore\n\nIn other words\nPlease, be true\n\nIn other words\nI love you\n\n=== Living Inside Your Love ===\nGuitar: Earl Klugh, 1976\n\nCan\'t get over the feeling\nLiving inside your love\n\nI never want to lose the feeling\nLiving inside your love\n\nBaby, you made my life so free\nLiving inside your love\n\nI\'m just where I want to be\nLiving inside your love\n\nAnd I never could say\nWhat I\'m feeling today\nFor you...\n';
	@override String get easterEggOthers => '=== Cardcaptor Sakura OP3 ===\nVocal: Maaya Sakamoto, 2000\nIn Japanese Roman Letters\n\nI\'m a dreamer\nhisomu PAWA-\n\nwatashi no sekai\nyume to koi to fuan de dekite\'ru\ndemo souzou wo shinai mono\nkakurete\'ru hazu\n\nsora ni mukau kiki no you ni anata wo\nmassugu mitsumete\'ru\nmitsuketai naa kanaetai naa\nshinjiru sore dake de\n\nkoerarenai mono wa nai\nutau you ni kiseki no you ni\n"omoi" ga subete wo kaete yuku yo\nkitto kitto\nodoroku kurai\n\n=== Living Inside Your Love ===\nGuitar: Earl Klugh, 1976\n\nCan\'t get over the feeling\nLiving inside your love\n\nI never want to lose the feeling\nLiving inside your love\n\nBaby, you made my life so free\nLiving inside your love\n\nI\'m just where I want to be\nLiving inside your love\n\nAnd I never could say\nWhat I\'m feeling today\nFor you...\n';
	@override String get loadError => 'Load Error';
}

// Path: courseReminder
class _Translations$courseReminder$en implements Translations$courseReminder$zh_CN {
	_Translations$courseReminder$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String title({required Object name}) => 'Pre-class Reminder: ${name}';
	@override String body({required Object time}) => 'Class starts in ${time} minutes';
	@override String location({required Object location}) => 'Location: ${location}';
	@override String teacher({required Object teacher}) => 'Teacher: ${teacher}';
}

// Path: dormWater
class _Translations$dormWater$en implements Translations$dormWater$zh_CN {
	_Translations$dormWater$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Dorm Water';
	@override String get phone => 'Phone';
	@override String get imageCode => 'Image code';
	@override String get smsCode => 'SMS code';
	@override String get sendSms => 'Send SMS';
	@override String get login => 'Login';
	@override String get logout => 'Logout';
	@override String get refreshCaptcha => 'Refresh Captcha';
	@override String get loadingCaptcha => 'Loading...';
	@override String get captchaError => 'Failed to load captcha';
	@override String get phoneRequired => 'Please enter phone number';
	@override String get imageCodeRequired => 'Please enter image code';
	@override String get smsSent => 'SMS sent successfully';
	@override String get smsFailed => 'Failed to send SMS';
	@override String get smsCodeRequired => 'Please enter SMS code';
	@override String get loginSuccess => 'Login successful';
	@override String get loginFailed => 'Login failed';
	@override String get logoutSuccess => 'Logged out successfully';
	@override String get devices => 'Device List';
	@override String get loadingDevices => 'Loading devices...';
	@override String get noDevices => 'No devices';
	@override String get selectDevice => 'Select Device';
	@override String get fetchDevicesFailed => 'Failed to fetch device list';
	@override String get retryLoadDevices => 'Retry Loading';
	@override String get startWater => 'Start Water';
	@override String get endWater => 'End Water';
	@override String get waterDispensing => 'Water Dispensing';
	@override String get waterStatus => 'Water Status';
	@override String get startWaterSuccess => 'Water dispensing started';
	@override String get endWaterSuccess => 'Water dispensing ended';
	@override String get startWaterFailed => 'Failed to start water';
	@override String get endWaterFailed => 'Failed to end water';
	@override String get deviceStatusChecking => 'Checking device status...';
	@override String get deviceStatusReady => 'Device ready';
	@override String get scanQrCode => 'Scan QR Code';
	@override String get deviceId => 'Device ID';
	@override String get addDeviceFailed => 'Failed to add device';
	@override String get deviceRemovedFromFavorites => 'Device removed from favorites';
	@override String get removeFromFavoritesFailed => 'Failed to remove from favorites';
}

// Path: easterEggRobot
class _Translations$easterEggRobot$en implements Translations$easterEggRobot$zh_CN {
	_Translations$easterEggRobot$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get appbar => 'Welcome Students!';
	@override String get title => 'Looking like you are worrying about opening semester?';
	@override String get contents => 'We are here to let our children have more pocket money.\n1. Robots may not injure a human being or, through inaction, allow a human being to come to harm.\n2. Robots are born from the ashes of the network running at the cloud.\n3. Robots are lovestruck, which cannot be annoyed, and loves merging programs!\n4. Robots sometimes can be controlled to avoid the attack from the Angles.\n5. Robots have shiny metal ass which should not be bitten.\nAnd they have a plan.';
	@override String get buttonOne => 'We are hanger for your help!';
	@override String get buttonTwo => 'Come on!';
	@override String get buttonNotice => '\o/\o/\o/\o/\o/\o/\o/\o/';
}

// Path: electricity
class _Translations$electricity$en implements Translations$electricity$zh_CN {
	_Translations$electricity$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Power Info';
	@override String get powerTitle => 'Infomation';
	@override String get cacheHintLoginFailed => 'Failed to log in to the electricity service, showing cached data.';
	@override String get cacheHintNetworkFailed => 'Electricity service network request failed, showing cached data.';
	@override String get cacheHintUnknownError => 'Failed to fetch the latest electricity data online, showing cached data. Check logs for details.';
	@override String get cacheNotice => 'Last fetched';
	@override String get account => 'Account';
	@override String get remainPower => 'Remain power';
	@override String get oweInfo => 'Arrears';
	@override String get history => 'Billing History';
	@override String get dailyUsage => 'Average usage per day';
	@override String get notEnoughData => 'Not enough data for rendering graph';
	@override String get info => 'Energy system can be only be accessed at schoolnet, do contact developers if have issue.\nHistory will be recorded locally while average usage is based on the electric meter\'s record.';
	@override String get fetchingHint => 'Fetching the latest electricity info.';
	@override String get fetchError => 'Failed to fetch electricity information. Please retry.';
	@override String get date => 'Date';
	@override String get power => 'Remaining';
	@override String get update => 'Refresh';
	@override String get waterUsageFetchDate => 'Fetch time';
	@override String get waterUsageReadBefore => 'Last time';
	@override String get waterUsageReadNow => 'This time';
	@override String get waterUsage => 'Bath water usage';
	@override String get waterTitle => 'Water usage';
	@override String get waterLoading => 'Loading water usage information';
	@override String get waterUnavailable => 'Water usage is unavailable. Retry from the electricity card.';
	@override String get waterEmpty => 'No water usage information';
	@override String get notSchoolNetwork => 'Not school network';
	@override String get airconTitle => 'Aircon Electricity';
	@override String get airconImei => 'Aircon IMEI';
	@override String get airconAmount => 'Platform usage';
	@override String get airconUpdateTime => 'Updated at';
	@override String get airconWaiting => 'Waiting to fetch aircon electricity data';
	@override String get airconError => 'Failed to fetch aircon electricity data';
	@override String get airconRetry => 'Retry';
	@override String get airconImeiMissing => 'Add the aircon IMEI to view its electricity usage.';
	@override String get airconAddImei => 'Add aircon IMEI';
	@override String airconCacheNotice({required Object time}) => 'Showing cached aircon data from ${time}';
}

// Path: electricityStatus
class _Translations$electricityStatus$en implements Translations$electricityStatus$zh_CN {
	_Translations$electricityStatus$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get pending => 'Pending';
	@override String get remainFetching => 'Fetching...';
	@override String get remainNetworkIssue => 'Network malfunction';
	@override String get remainNotFound => 'Query failed';
	@override String get remainOtherIssue => 'Query malfunction';
	@override String get oweFetching => 'Obtaining arrearage';
	@override String get oweIssue => 'Network malfunction of overdue information';
	@override String get oweNotFound => 'Cannot query arrearage, check log window for detail';
	@override String get oweNoNeed => 'None';
	@override String oweNeedPay({required Object due}) => 'Need to pay ${due} yuan';
	@override String get oweIssueUnable => 'Cannot query arrearage';
	@override String get needMoreInfo => 'Need to improve information on the payment platform';
	@override String get needAccount => 'Need to input electricity account';
	@override String get captchaFailed => 'Failed to check captcha';
	@override String get otherIssue => 'Program malfunction';
}

// Path: emptyClassroom
class _Translations$emptyClassroom$en implements Translations$emptyClassroom$zh_CN {
	_Translations$emptyClassroom$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Empty Classrooms';
	@override String date({required Object date}) => 'Date ${date}';
	@override String building({required Object building}) => 'Building ${building}';
	@override String get searchHint => 'Classroom name or code';
	@override String get classroom => 'Classroom';
	@override String get empty => 'Available';
	@override String get occupied => 'Occupied';
}

// Path: exam
class _Translations$exam$en implements Translations$exam$zh_CN {
	_Translations$exam$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Exam Schedule';
	@override String get cacheHint => 'Displaying cached exam schedule info';
	@override String get cacheHintPasswordWrong => 'IDS password is incorrect or expired.';
	@override String get cacheHintLoginFailed => 'Failed to log in to the exam service.';
	@override String get cacheHintNetworkFailed => 'Network request failed.';
	@override String get cacheHintUnknownError => 'Failed to fetch the latest exam schedule. Check logs for details.';
	@override String get fetchingHint => 'Fetching the latest exam schedule.';
	@override String get notFinished => 'Still there are some bad guys here.';
	@override String get allFinished => 'Say goodbye to all the exams.';
	@override String get unableToExam => 'Unable to exam';
	@override String get finished => 'All exams ';
	@override String get noneFinished => 'No exams have been completed';
	@override String get noExamArrangement => 'No exam has been arranged currently';
	@override late final _Translations$exam$noArrangement$en noArrangement = _Translations$exam$noArrangement$en._(_root);
}

// Path: experiment
class _Translations$experiment$en implements Translations$experiment$zh_CN {
	_Translations$experiment$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Experiment Info';
	@override String get ongoing => 'Ongoing experiment';
	@override String get notFinished => 'Experiments to be done';
	@override String get allFinished => 'All experiments have been completed';
	@override String get finished => 'Completed experiments';
	@override String scoreInfo({required Object score}) => '${score} (predicted)';
	@override String scoreSum({required Object sum}) => 'Total score: ${sum}';
	@override String get noneFinished => 'None of the experiments have been completed';
	@override String get notProvided => 'Not provided';
	@override String errorPhysics({required Object info}) => 'Error on fetching physics experiments: ${info}';
	@override String errorOther({required Object info}) => 'Error on fetching other experiments: ${info}';
	@override String cacheHint({required Object info}) => 'Loaded cache: ${info}';
	@override String get physicsCacheHintMissingPassword => 'Physics experiment password is not set.';
	@override String get physicsCacheHintLoginFailed => 'Physics experiment login failed.';
	@override String get physicsCacheHintNotSchoolNetwork => 'Not on the campus network.';
	@override String get physicsCacheHintNetworkFailed => 'Physics experiment network request failed.';
	@override String get physicsCacheHintUnknownError => 'Failed to fetch physics experiments online. Check logs for details.';
	@override String get otherCacheHintLoginFailed => 'Other experiment login failed.';
	@override String get otherCacheHintNotSchoolNetwork => 'Not on the campus network.';
	@override String get otherCacheHintNetworkFailed => 'Other experiment network request failed.';
	@override String get otherCacheHintUnknownError => 'Failed to fetch other experiments online. Check logs for details.';
	@override String get physicsExperiment => 'physics experiments';
	@override String get otherExperiment => 'other experiments';
	@override String get tapForScore => 'Failed to detect the score';
	@override String get yourScore => 'Your Score: ';
	@override String predictScore({required Object score}) => 'Predict score: ${score}';
	@override String get sendMail => 'Send';
	@override String get fetchingHint => 'The data you see is from cache. Updating is running in the background...';
	@override String get fetchingHintBoth => 'Physics experiments and other experiments are loading';
	@override String get fetchingHintPhysics => 'Physics experiments are loading';
	@override String get fetchingHintOther => 'Other experiments are loading';
	@override String get fetchingHintPhysicsWithOtherFailed => 'Physics experiments are loading, while other experiments failed to load';
	@override String get fetchingHintOtherWithPhysicsFailed => 'Other experiments are loading, while physics experiments failed to load';
	@override String get scoreHint0 => 'You can tap on the score info on the score card to check out the original score data';
	@override String get scoreHint1 => 'Your score is not in the XDYou score recognition database, so it was not recognized properly.';
	@override String get scoreHint2 => 'If you wish to contribute to the development of XDYou, you can click the send email button, and we will add your score to the recognition database!';
	@override String get scoreHint3 => 'Due to the lack of data for recognization, it is necessary to check twice.';
}

// Path: experimentController
class _Translations$experimentController$en implements Translations$experimentController$zh_CN {
	_Translations$experimentController$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get noPassword => 'Experiment password is not set, please set up one in the setting';
	@override String get loginFailed => 'Login failed';
}

// Path: homepage
class _Translations$homepage$en implements Translations$homepage$zh_CN {
	_Translations$homepage$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'School Info Center';
	@override String get loading => 'Loading';
	@override String get loaded => 'Message updated';
	@override String get loadError => 'Something wrong';
	@override String get onHoliday => 'Currently on holiday';
	@override String onWeekday({required Object current}) => 'Currently week ${current}';
	@override String get loadingMessage => 'Refreshing information...';
	@override String get postgraduateNotice => 'Postgraduate features activated!';
	@override String get linuxNotice => 'Linux version is under testing, feel free to feedback!';
	@override String get editMode => 'Edit Layout';
	@override String get editDone => 'Done';
	@override String get editReset => 'Reset Layout';
	@override String get editHint => 'Schedule and update cards cannot be edited';
	@override String get manageHidden => 'Manage hidden cards';
	@override String get hiddenTitle => 'Hidden cards';
	@override String get hiddenLabel => 'Hidden';
	@override String get hideEmpty => 'No hidden cards';
	@override String get homepage => 'Info';
	@override String get ruisi => 'Forum';
	@override String get club => 'Club';
	@override String get planet => 'Blog';
	@override String get dashboard => 'Pighub';
	@override String get setting => 'Settings';
	@override late final _Translations$homepage$inputPartnerData$en inputPartnerData = _Translations$homepage$inputPartnerData$en._(_root);
	@override String get loginMessage => 'Logging in, currently displaying cached data';
	@override String get successfulLoginMessage => 'Login successful';
	@override String get passwordWrongTitle => 'Wrong username or password';
	@override String get passwordWrongContent => 'Restart the app and log in manually?';
	@override String get passwordWrongDenial => 'No, enter offline mode';
	@override String get offlineModeTitle => 'Uniform Authentication Service offline mode activated';
	@override String get offlineModeContent => '"Unable to connect to the Unified Authentication Service server, all related services are temporarily unavailable.\nScore inquiry, exam information inquiry, overdue fee inquiry, campus card inquiry are closed. The schedule displays cached data. Other functions are temporarily not affected.\nWe apologize for any inconvenience caused."\n';
	@override String get offlineMode => 'In offline mode, all one-stop related functions are disabled';
	@override late final _Translations$homepage$noticeCard$en noticeCard = _Translations$homepage$noticeCard$en._(_root);
	@override late final _Translations$homepage$classTableCard$en classTableCard = _Translations$homepage$classTableCard$en._(_root);
	@override late final _Translations$homepage$electricityCard$en electricityCard = _Translations$homepage$electricityCard$en._(_root);
	@override late final _Translations$homepage$libraryCard$en libraryCard = _Translations$homepage$libraryCard$en._(_root);
	@override late final _Translations$homepage$schoolCardInfoCard$en schoolCardInfoCard = _Translations$homepage$schoolCardInfoCard$en._(_root);
	@override late final _Translations$homepage$toolbox$en toolbox = _Translations$homepage$toolbox$en._(_root);
	@override late final _Translations$homepage$schoolNet$en schoolNet = _Translations$homepage$schoolNet$en._(_root);
	@override late final _Translations$homepage$clubPromotion$en clubPromotion = _Translations$homepage$clubPromotion$en._(_root);
}

// Path: library
class _Translations$library$en implements Translations$library$zh_CN {
	_Translations$library$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Library Information';
	@override String get borrowStateTitle => 'Borrowing Status';
	@override String get searchBookTitle => 'Search Books';
	@override String get searchFieldTitle => 'Search Field';
	@override String get searchFieldKeywordOption => 'Any';
	@override String get searchFieldTitleOption => 'Title';
	@override String get searchFieldAuthorOption => 'Author';
	@override String get searchFieldIsbnOption => 'ISBN';
	@override String get searchFieldBarcodeOption => 'Bar Code';
	@override String get searchFieldCallnoOption => 'Call No';
	@override String get notProvided => 'No information provided';
	@override String get author => 'Author ';
	@override String get publishHouse => 'Publisher ';
	@override String get callNumber => 'Call Number ';
	@override String get publishDate => 'Publication Date';
	@override String get isbn => 'ISBN';
	@override String get arrangementCode => 'Arrangement Code ';
	@override String get avaliableBorrow => 'Available to borrow';
	@override String get storage => 'Storage';
	@override String get onShelve => 'On shelf';
	@override String bookCode({required Object bar_code}) => 'Book code: ${bar_code}';
	@override String get dueDate => ' Due date';
	@override String get borrowStr => ' Borrow';
	@override String get afterDueDate => ' day(s) overdue';
	@override String get beforeDueDate => ' day(s) left';
	@override String get canBeRenewable => 'Renewable';
	@override String get cannotBeRenewable => 'Not renewable';
	@override String get renewing => 'Renewing';
	@override String get emptyBorrowList => 'No borrowed books found';
	@override String borrowListInfo({required Object borrow, required Object dued}) => 'Borrowing ${borrow} book(s), among which ${dued} book(s) have expired';
	@override String get searchBookWindow => '';
	@override String get searchHere => 'Search here';
	@override String get normalSearch => 'Normal Search';
	@override String get advancedSearch => 'Advanced Search';
	@override String get search => 'Search';
	@override String get matchMode => 'Match Mode';
	@override String get matchExact => 'Exact';
	@override String get matchFuzzy => 'Fuzzy';
	@override String get matchPrefix => 'Prefix';
	@override String get documentType => 'Document Type';
	@override String get documentTypeAll => 'All';
	@override String get documentTypeBook => 'Book';
	@override String get onlyOnShelf => 'Only on shelf';
	@override String get publishYearBegin => 'Publish year from';
	@override String get publishYearEnd => 'Publish year to';
	@override String get bookDetail => 'Book details';
	@override String get noResult => 'No result, change parameter or start your search';
}

// Path: libraryCard
class _Translations$libraryCard$en implements Translations$libraryCard$zh_CN {
	_Translations$libraryCard$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Library status';
	@override String get fetching => 'Fetching';
	@override String get northernLibrary => 'Northern Library';
	@override String get southernLibrary => 'Southern Library';
	@override String people({required Object people}) => 'People: ${people}';
	@override String seat({required Object seat}) => 'Seats: ${seat}';
}

// Path: login
class _Translations$login$en implements Translations$login$zh_CN {
	_Translations$login$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get identityNumber => 'Student ID';
	@override String get password => 'IDS Login password';
	@override String get login => 'Login';
	@override String get incorrectPasswordPattern => 'Username or password does not meet requirements, student ID must be 11 digits and password cannot be empty';
	@override String get onLoginProgress => 'Logging in...';
	@override String get completeLogin => 'Login successful';
	@override String get failedLoginCannotConnectToServer => 'Cannot connect to server';
	@override String failedLoginWithCode({required Object code}) => 'Request failed, response status code: ${code}';
	@override String failedLoginWithMessage({required Object message}) => 'Request failed, error message: ${message}';
	@override String get failedLoginOther => 'Unknown error, please contact the developer';
	@override String get clearCache => 'Clear cache';
	@override String get completeClearCache => 'Cache cleared successfully';
	@override String get seeInspector => 'View network interaction';
	@override late final _Translations$login$captchaWindow$en captchaWindow = _Translations$login$captchaWindow$en._(_root);
	@override String get sliderTitle => 'Server authentication service';
}

// Path: loginProcess
class _Translations$loginProcess$en implements Translations$loginProcess$zh_CN {
	_Translations$loginProcess$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get readyPage => 'Prepare to obtain login environment';
	@override String get getEncrypt => 'Obtain password encryption key';
	@override String get readyLogin => 'Prepare to login';
	@override String get slider => 'Logging in';
	@override String get afterProcess => 'Post-login processing';
	@override String failed({required Object status_code}) => 'Login failed, response status code: ${status_code}';
}

// Path: month
class _Translations$month$en implements Translations$month$zh_CN {
	_Translations$month$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get january => 'Jan.';
	@override String get february => 'Feb.';
	@override String get march => 'Mar.';
	@override String get april => 'Apr.';
	@override String get may => 'May';
	@override String get june => 'Jun.';
	@override String get july => 'Jul.';
	@override String get august => 'Aug.';
	@override String get september => 'Sept.';
	@override String get october => 'Oct.';
	@override String get november => 'Nov.';
	@override String get december => 'Dec.';
}

// Path: restartApp
class _Translations$restartApp$en implements Translations$restartApp$zh_CN {
	_Translations$restartApp$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get titleCacheCleared => 'Cache Cleared';
	@override String get titleLoggedOut => 'Logged Out';
	@override String get titlePasswordWrong => 'Wrong Password';
	@override String get content => 'Tap to reopen the app';
}

// Path: ruisi
class _Translations$ruisi$en implements Translations$ruisi$zh_CN {
	_Translations$ruisi$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$ruisi$common$en common = _Translations$ruisi$common$en._(_root);
	@override late final _Translations$ruisi$about$en about = _Translations$ruisi$about$en._(_root);
	@override late final _Translations$ruisi$home$en home = _Translations$ruisi$home$en._(_root);
	@override late final _Translations$ruisi$login$en login = _Translations$ruisi$login$en._(_root);
	@override late final _Translations$ruisi$post$en post = _Translations$ruisi$post$en._(_root);
	@override late final _Translations$ruisi$topicDetail$en topicDetail = _Translations$ruisi$topicDetail$en._(_root);
	@override late final _Translations$ruisi$topicListItem$en topicListItem = _Translations$ruisi$topicListItem$en._(_root);
	@override late final _Translations$ruisi$forumList$en forumList = _Translations$ruisi$forumList$en._(_root);
	@override late final _Translations$ruisi$favorites$en favorites = _Translations$ruisi$favorites$en._(_root);
	@override late final _Translations$ruisi$messages$en messages = _Translations$ruisi$messages$en._(_root);
	@override late final _Translations$ruisi$search$en search = _Translations$ruisi$search$en._(_root);
	@override late final _Translations$ruisi$settings$en settings = _Translations$ruisi$settings$en._(_root);
	@override late final _Translations$ruisi$user$en user = _Translations$ruisi$user$en._(_root);
}

// Path: schoolCardStatus
class _Translations$schoolCardStatus$en implements Translations$schoolCardStatus$zh_CN {
	_Translations$schoolCardStatus$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get failedToFetch => 'Failed fetching';
	@override String get failedToQuery => 'Failed querying';
}

// Path: schoolCardWindow
class _Translations$schoolCardWindow$en implements Translations$schoolCardWindow$zh_CN {
	_Translations$schoolCardWindow$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Campus Card Transaction History';
	@override String income({required Object income}) => 'Income ￥${income}';
	@override String expense({required Object expense}) => 'Expense ￥${expense}';
	@override String selectRange({required Object start_day, required Object end_day}) => 'Select date: from ${start_day} to ${end_day}';
	@override String get storeName => 'Expense place';
	@override String get balance => 'Amount';
	@override String timeWithSum({required Object sum}) => 'Time (${sum})';
	@override String get noRecord => 'No records found, please try again with different dates';
	@override String get qrCode => 'Payment Code';
	@override String qrCodeError({required Object info}) => 'Get QR Code failed: ${info}';
	@override String get reload => 'Reload';
}

// Path: schoolNet
class _Translations$schoolNet$en implements Translations$schoolNet$zh_CN {
	_Translations$schoolNet$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'School Net Usage Query';
	@override late final _Translations$schoolNet$idsAccountNet$en idsAccountNet = _Translations$schoolNet$idsAccountNet$en._(_root);
	@override late final _Translations$schoolNet$currentLoginNet$en currentLoginNet = _Translations$schoolNet$currentLoginNet$en._(_root);
	@override late final _Translations$schoolNet$deviceList$en deviceList = _Translations$schoolNet$deviceList$en._(_root);
	@override String get fetching => 'Fetching schoolnet usage data';
	@override String get emptyPassword => 'You may forgot to enter the schoolnet password';
	@override String get notInitalized => 'It seems the backend is not open for query:P';
	@override String get captchaFailed => 'Failed to idenify captcha';
	@override String get captchaEmpty => 'Captcha is empty';
	@override String get cacheHintCaptchaFailed => 'Captcha recognition failed. Please try again.';
	@override String get cacheHintRequestFailed => 'The schoolnet request failed. Please try again later.';
	@override String get wrongPassword => 'Wrong schoolnet password';
	@override String errorFetch({required Object msg}) => 'Failed to fetch：${msg}';
	@override String errorOther({required Object msg}) => 'Other error：${msg}';
	@override String get refresh => 'Refresh';
}

// Path: score
class _Translations$score$en implements Translations$score$zh_CN {
	_Translations$score$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get cacheMessage => 'Cached score information is displayed';
	@override String summary({required Object chosen, required Object credit, required Object avg, required Object gpa}) => 'Selected subjects ${chosen}  Total credits ${credit}\nAverage ${avg} GPA ${gpa}';
	@override String get allPassed => 'All subjects have passed';
	@override String get cacheHintPasswordWrong => 'IDS password is incorrect or expired.';
	@override String get cacheHintLoginFailed => 'Failed to log in to the score service.';
	@override String get cacheHintNetworkFailed => 'Network request failed.';
	@override String get cacheHintUnknownError => 'Failed to fetch the latest score info. Check logs for details.';
	@override String get fetchingHint => 'Fetching the latest score info.';
	@override String get allSemester => 'All semesters';
	@override String chosenSemester({required Object chosen}) => '${chosen}';
	@override String get allType => 'All types';
	@override String chosenType({required Object type}) => '${type}';
	@override String get none => 'None';
	@override late final _Translations$score$scoreChoice$en scoreChoice = _Translations$score$scoreChoice$en._(_root);
	@override late final _Translations$score$scoreComposeCard$en scoreComposeCard = _Translations$score$scoreComposeCard$en._(_root);
	@override late final _Translations$score$scoreInfoCard$en scoreInfoCard = _Translations$score$scoreInfoCard$en._(_root);
	@override late final _Translations$score$scorePage$en scorePage = _Translations$score$scorePage$en._(_root);
}

// Path: setting
class _Translations$setting$en implements Translations$setting$zh_CN {
	_Translations$setting$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String acknowledgement({required Object developers}) => 'Made With Love From ${developers} People';
	@override String get about => 'About';
	@override String get aboutThisProgram => 'About this APP';
	@override String version({required Object version}) => 'Version：${version}';
	@override String get userInfo => 'User information';
	@override String get checkUpdate => 'Check for updates';
	@override String latestVersion({required Object latest}) => 'Latest version: ${latest}';
	@override String get waiting => 'Waiting for obtain';
	@override String get fetchingUpdate => 'Fetching update information';
	@override String get newVersion => 'New version released!';
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
	@override late final _Translations$setting$lowElectricityThresholdDialog$en lowElectricityThresholdDialog = _Translations$setting$lowElectricityThresholdDialog$en._(_root);
	@override String get accountSetting => 'Account Settings';
	@override String get sportPasswordSetting => 'PE system password';
	@override String get experimentPasswordSetting => 'Physics experiment password';
	@override String get electricityPasswordSetting => 'Electricity account password';
	@override String get electricityPasswordDescription => 'Please set if not default';
	@override String get electricityAccountSetting => 'Electricity account setting';
	@override String get schoolnetPasswordSetting => 'Campus net password';
	@override String get schoolnetPasswordDescription => 'If you have not setted it, you cannot query it.';
	@override String get airconImeiTitle => 'Aircon electricity data source';
	@override String get airconImei => 'Aircon IMEI';
	@override String get airconImeiNotSet => 'Not set. Aircon electricity will be hidden on the power page.';
	@override String airconImeiCurrent({required Object imei}) => 'Current IMEI: ${imei}';
	@override String get airconImeiSaved => 'Aircon IMEI saved';
	@override String get airconImeiCleared => 'Aircon IMEI cleared';
	@override String get airconImeiInvalid => 'No valid 15-digit IMEI found';
	@override String get airconImeiClear => 'Clear';
	@override String get scanAirconQr => 'Scan aircon QR code';
	@override String get pickAirconQrImage => 'Choose QR image';
	@override String get airconCameraUnavailable => 'Camera scanning is unavailable on this platform. Choose a QR image or enter the IMEI manually.';
	@override String get notificationSetting => 'Notification Settings';
	@override String get courseReminderSetting => 'Pre-class Reminder Settings';
	@override String get courseReminderDescription => 'Configure pre-class reminder notifications';
	@override late final _Translations$setting$notificationPage$en notificationPage = _Translations$setting$notificationPage$en._(_root);
	@override String get notificationDebugPage => 'Notification Services Debug Page';
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
	@override String classSwiftDescription({required Object swift}) => 'Positive number delays the start date, negative number advances the start date\nCurrently ${swift}\n';
	@override String get coreSetting => 'Cached login settings';
	@override String get checkLogger => 'View network interceptor and logs';
	@override String get clearAndRestart => 'Clear cache and restart';
	@override late final _Translations$setting$clearAndRestartDialog$en clearAndRestartDialog = _Translations$setting$clearAndRestartDialog$en._(_root);
	@override String get logout => 'Log out and restart the app';
	@override late final _Translations$setting$logoutDialog$en logoutDialog = _Translations$setting$logoutDialog$en._(_root);
	@override late final _Translations$setting$needCloseDialog$en needCloseDialog = _Translations$setting$needCloseDialog$en._(_root);
	@override late final _Translations$setting$changeColorDialog$en changeColorDialog = _Translations$setting$changeColorDialog$en._(_root);
	@override late final _Translations$setting$changeBrightnessDialog$en changeBrightnessDialog = _Translations$setting$changeBrightnessDialog$en._(_root);
	@override late final _Translations$setting$changeSwiftDialog$en changeSwiftDialog = _Translations$setting$changeSwiftDialog$en._(_root);
	@override String get changeElectricityTitle => 'Modify electricity account';
	@override late final _Translations$setting$changeElectricityAccount$en changeElectricityAccount = _Translations$setting$changeElectricityAccount$en._(_root);
	@override String get changeExperimentTitle => 'Modify physics experiment account password';
	@override String get changeSportTitle => 'Modify sports system account password';
	@override late final _Translations$setting$changePasswordDialog$en changePasswordDialog = _Translations$setting$changePasswordDialog$en._(_root);
	@override String get changeSchoolnetPasswordTitle => 'Modify the schoolnet query password';
	@override late final _Translations$setting$updateDialog$en updateDialog = _Translations$setting$updateDialog$en._(_root);
	@override late final _Translations$setting$localizationDialog$en localizationDialog = _Translations$setting$localizationDialog$en._(_root);
	@override String get semesterChange => 'Change semester';
	@override String semesterChangeDescription({required Object semester}) => 'Using semester ${semester}';
	@override String get semesterUpdateData => 'Applying new semester setting';
	@override String get easterEggPage => 'You found an Easter egg';
	@override late final _Translations$setting$aboutPage$en aboutPage = _Translations$setting$aboutPage$en._(_root);
}

// Path: sport
class _Translations$sport$en implements Translations$sport$zh_CN {
	_Translations$sport$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Sport Query';
	@override String get classInfo => 'Class information';
	@override String get emptyClassInfo => 'No class information found';
	@override String get testScore => 'Sport test score';
	@override String get totalScore => 'Four-year total score';
	@override String get totalScoreLabel => 'Total Score';
	@override String get rankLabel => 'Rank';
	@override String semester({required Object year, required Object grade_type}) => 'Semester ${year} ${grade_type}';
	@override String get subject => 'Subject';
	@override String get data => 'Data';
	@override String get score => 'Score';
	@override String get passed => 'Passed';
	@override String fromTo({required Object start, required Object stop}) => 'Period ${start} to ${stop}';
	@override String scoreString({required Object score}) => '${score} points';
	@override String get situationNopassword => 'No password';
	@override String get situationMaintain => 'System maintenance';
	@override String get situationFailedLogin => 'Login failed';
	@override String get situationQuery => 'Query failed';
	@override String get situationNetwork => 'Network malfunction';
	@override String situationUnknown({required Object situation}) => 'Unknown malfunction ${situation}';
	@override String get situationFetching => 'Fetching...';
	@override String situationError({required Object situation}) => 'Bad thing: ${situation}';
	@override String get cacheHintMissingPassword => 'Please set your PE password and try again.';
	@override String get cacheHintCredentialInvalid => 'The PE login has expired. Please update your PE password and try again.';
	@override String get cacheHintMaintain => 'The PE service is under maintenance. Please try again later.';
	@override String get cacheHintLoginFailed => 'Failed to log in to the PE service.';
	@override String get cacheHintQueryFailed => 'Failed to query PE information.';
	@override String get cacheHintNetwork => 'The PE service network request failed.';
	@override String get cacheHintUnknown => 'Failed to fetch PE information online. Check logs for details.';
	@override String get errorAuthExpired => 'The PE login has expired. Please try again.';
	@override String get errorMissingPassword => 'PE password is not set';
	@override String get errorCredentialInvalid => 'The PE login has expired. Please update your PE password and try again.';
}

// Path: toolbox
class _Translations$toolbox$en implements Translations$toolbox$zh_CN {
	_Translations$toolbox$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Other Functions';
	@override String get payment => 'Payment System';
	@override String get paymentDescription => 'Times to pay the electricity fee';
	@override String get drinkingwater => 'Drinking Water';
	@override String get drinkingwaterDescription => 'Is good for health';
	@override String get repair => 'Repair report';
	@override String get repairDescription => 'Don\'t let the water leak from the top';
	@override String get reserve => 'Space Reservation';
	@override String get reserveDescription => 'Find a place to gathering';
	@override String get mobile => 'Mobile Portal';
	@override String get mobileDescription => 'Specific for leaving';
	@override String get network => 'Network Query';
	@override String get networkDescription => 'Hope never charges (NO!)';
	@override String get physics => 'Physics Calculation';
	@override String get physicsDescription => 'Hope the operation goes smoothly';
	@override String get discover => 'Ruisi Navigation';
	@override String get discoverDescription => 'Lots other functions';
}

// Path: weekday
class _Translations$weekday$en implements Translations$weekday$zh_CN {
	_Translations$weekday$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get monday => 'Mon.';
	@override String get tuesday => 'Tue.';
	@override String get wednesday => 'Wed.';
	@override String get thursday => 'Thu.';
	@override String get friday => 'Fri.';
	@override String get saturday => 'Sat.';
	@override String get sunday => 'Sun.';
}

// Path: xduPlanet
class _Translations$xduPlanet$en implements Translations$xduPlanet$zh_CN {
	_Translations$xduPlanet$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get all => 'All';
	@override String get loading => 'Loading, please wait <(=ω=)>';
	@override String get unknownAuthor => 'Unknown author';
	@override String get loadFailedTitle => 'Failed to load';
	@override String get loadFailedBottom => 'Failed to load the article, you can click the button on the top right of the screen to open it in the browser.';
	@override String get noComment => 'No comments yet';
	@override String replyAudit({required Object reply_to}) => 'Reply comment #${reply_to} has been reported or deleted';
	@override String reply({required Object reply_to, required Object content}) => 'Reply to #${reply_to}: ${content}';
	@override String get haveBeenAudit => 'This comment has been reported';
	@override String get audit => 'Report';
	@override late final _Translations$xduPlanet$confirmAuditDialog$en confirmAuditDialog = _Translations$xduPlanet$confirmAuditDialog$en._(_root);
	@override String get comment => 'Reply';
	@override String get send => 'Send';
	@override String get sending => 'Sending comment';
	@override String get emptySend => 'Blank message sent';
	@override String get hintSendComment => 'Express yourself!';
	@override String get commentTitle => 'Comment on this article';
	@override String get commentSuccess => 'Successfully commenting';
	@override String get commentFailed => 'Comment failed, please check the log';
	@override String get commentCanceled => 'Nothing to say?';
	@override String get commentLoading => 'Loading comments...';
	@override String get block => 'Blocked';
	@override String get delete => 'Deleted';
	@override String get audio => 'Deleted';
}

// Path: classAttendance.courseState
class _Translations$classAttendance$courseState$en implements Translations$classAttendance$courseState$zh_CN {
	_Translations$classAttendance$courseState$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get unknown => 'unknown';
	@override String get ineligible => 'ineligible';
	@override String get eligible => 'eligible';
	@override String get warning => 'warning';
}

// Path: classAttendance.table
class _Translations$classAttendance$table$en implements Translations$classAttendance$table$zh_CN {
	_Translations$classAttendance$table$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get courseName => 'Course Name';
	@override String get status => 'Status';
	@override String get attendanceRate => 'Rate';
	@override String get checkIn => 'Check-in';
	@override String get absence => 'Absence';
	@override String get required => 'Required';
	@override String get leave => 'Leave(P/S/O)';
	@override String get filter => 'Filter';
	@override String get filterAll => 'All';
	@override String showingCount({required Object count, required Object total}) => 'Showing ${count}/${total} courses';
}

// Path: classAttendance.card
class _Translations$classAttendance$card$en implements Translations$classAttendance$card$zh_CN {
	_Translations$classAttendance$card$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get time => 'Attendances';
	@override String timeInfo({required Object check_in_count, required Object absence_count, required Object required_check_in}) => '${check_in_count} Checked / ${absence_count} Absences / ${required_check_in} Required';
	@override String get notAttend => 'Rebirths';
	@override String notAttendInfo({required Object time_to_have_error, required Object total_times}) => '${time_to_have_error} Times / ${total_times} Total';
	@override String get notAttendInfoError => 'Cannot match course in the classtable';
	@override String get leave => 'Leaves';
	@override String leaveInfo({required Object personal_leave, required Object sick_leave, required Object official_leave}) => 'Personal ${personal_leave} / Sick ${sick_leave} / Official ${official_leave}';
	@override String get study => 'Study';
	@override String studyInfo({required Object task_progress, required Object homework_progress, required Object exam_progress}) => 'Task ${task_progress} / Works ${homework_progress} / Exam ${exam_progress}';
}

// Path: classAttendance.detailCard
class _Translations$classAttendance$detailCard$en implements Translations$classAttendance$detailCard$zh_CN {
	_Translations$classAttendance$detailCard$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get creatorName => 'Creator';
	@override String get startTime => 'Start at';
	@override String get summitTime => 'Summit at';
}

// Path: classAttendance.signType
class _Translations$classAttendance$signType$en implements Translations$classAttendance$signType$zh_CN {
	_Translations$classAttendance$signType$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get qrCode => 'QR Code Checkin';
	@override String get gesture => 'Gesture Checkin';
	@override String get position => 'Position Checkin';
	@override String get kDefault => 'Normal Checkin';
}

// Path: classAttendance.signStatus
class _Translations$classAttendance$signStatus$en implements Translations$classAttendance$signStatus$zh_CN {
	_Translations$classAttendance$signStatus$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get absenceNotParticipating => 'Absence (Not participating)';
	@override String get signed => 'Signed';
	@override String get signedByTeacher => 'Signed by teacher';
	@override String get personalLeave2 => 'Personal Leave';
	@override String get absence => 'Absence';
	@override String get sickLeave => 'Sick Leave';
	@override String get personalLeave => 'Personal Leave';
	@override String get late => 'Late';
	@override String get leaveEarly => 'Leave Early';
	@override String get signExpiredy => 'Sign Expired';
	@override String get publicLeave => 'Public Leave';
}

// Path: classtable.partnerClasstable
class _Translations$classtable$partnerClasstable$en implements Translations$classtable$partnerClasstable$zh_CN {
	_Translations$classtable$partnerClasstable$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get overrideDialog => 'Currently there is a partner classtable data, do you want to overwrite?';
	@override String get noFile => 'Import file not found';
	@override String get noPermission => 'Storage permission denied , cannot read file';
	@override String get problem => 'Maybe there\'s a problem with the import file :P';
	@override String get success => 'Successfully imported';
	@override late final _Translations$classtable$partnerClasstable$shareDialog$en shareDialog = _Translations$classtable$partnerClasstable$shareDialog$en._(_root);
	@override late final _Translations$classtable$partnerClasstable$saveDialog$en saveDialog = _Translations$classtable$partnerClasstable$saveDialog$en._(_root);
	@override late final _Translations$classtable$partnerClasstable$deleteDialog$en deleteDialog = _Translations$classtable$partnerClasstable$deleteDialog$en._(_root);
	@override late final _Translations$classtable$partnerClasstable$nameDialog$en nameDialog = _Translations$classtable$partnerClasstable$nameDialog$en._(_root);
}

// Path: classtable.popupMenu
class _Translations$classtable$popupMenu$en implements Translations$classtable$popupMenu$zh_CN {
	_Translations$classtable$popupMenu$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get notArranged => 'View unarranged classes';
	@override String get classChanged => 'View schedule changes';
	@override String get addClass => 'Add class';
	@override String get generateIcal => 'Export calendar file';
	@override String get generatePartnerFile => 'Export partner classtable file';
	@override String get importPartnerFile => 'Import partner classtable file';
	@override String get deletePartnerFile => 'Delete partner classtable file';
	@override String get outputToSystem => 'Export to system calendar';
	@override String get refreshClasstable => 'Refresh schedule';
	@override String get switchSemester => 'Switch classtable semester';
	@override String get currentTimeSettings => 'Time indicator settings';
	@override String get classColorSettings => 'Class color settings';
}

// Path: classtable.visualSettings
class _Translations$classtable$visualSettings$en implements Translations$classtable$visualSettings$zh_CN {
	_Translations$classtable$visualSettings$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get currentTimeSettingsTitle => 'Time indicator settings';
	@override String get classColorSettingsTitle => 'Class color settings';
	@override String get completedStyleEnabled => 'Completed class styling distinction';
	@override String get currentTimeSection => 'Time indicators';
	@override String get showCurrentTimeIndicator => 'Show current time indicator';
	@override String get showCurrentTimeLabel => 'Show mini time label';
	@override String get showTodayColumnHighlight => 'Highlight today\'s column';
	@override String get unfinishedSection => 'Class style';
	@override String activeBrightnessFactor({required Object value}) => 'Brightness: ${value}';
	@override String activeBorderAlpha({required Object value}) => 'Border opacity: ${value}';
	@override String activeInnerAlpha({required Object value}) => 'Fill opacity: ${value}';
	@override String get completedSection => 'Completed class style';
	@override String completedSaturationFactor({required Object value}) => 'Fill saturation: ${value}';
	@override String completedBrightnessFactor({required Object value}) => 'Brightness: ${value}';
	@override String completedTextSaturationFactor({required Object value}) => 'Text saturation: ${value}';
	@override String completedBorderAlpha({required Object value}) => 'Border opacity: ${value}';
	@override String completedInnerAlpha({required Object value}) => 'Fill opacity: ${value}';
}

// Path: classtable.statusSource
class _Translations$classtable$statusSource$en implements Translations$classtable$statusSource$zh_CN {
	_Translations$classtable$statusSource$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get classTable => 'Class Table';
	@override String get exam => 'Exams';
	@override String get physicsExperiment => 'Physics Experiments';
	@override String get otherExperiment => 'Other Experiments';
}

// Path: classtable.statusBanner
class _Translations$classtable$statusBanner$en implements Translations$classtable$statusBanner$zh_CN {
	_Translations$classtable$statusBanner$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String loading({required Object sources}) => 'Updating: ${sources}';
	@override String cache({required Object sources}) => 'Using cached data: ${sources}';
	@override String errorSummary({required Object sources}) => 'Failed to load: ${sources}';
}

// Path: classtable.emptyState
class _Translations$classtable$emptyState$en implements Translations$classtable$emptyState$zh_CN {
	_Translations$classtable$emptyState$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String noCourse({required Object semester_code}) => 'No classes are arranged for semester ${semester_code}.';
	@override String withExam({required Object semester_code}) => 'No classes are arranged for semester ${semester_code}, but exam arrangements are available.';
	@override String withExperiment({required Object semester_code}) => 'No classes are arranged for semester ${semester_code}, but experiment arrangements are available.';
	@override String withExamAndExperiment({required Object semester_code}) => 'No classes are arranged for semester ${semester_code}, but exam and experiment arrangements are available.';
}

// Path: classtable.emptyAction
class _Translations$classtable$emptyAction$en implements Translations$classtable$emptyAction$zh_CN {
	_Translations$classtable$emptyAction$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get viewExam => 'View exams';
	@override String get viewExperiment => 'View experiments';
}

// Path: classtable.classChangePage
class _Translations$classtable$classChangePage$en implements Translations$classtable$classChangePage$zh_CN {
	_Translations$classtable$classChangePage$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Schedule Changes';
	@override String get emptyMessage => 'Currently there\'s no class schedule changes';
	@override String teacherChange({required Object previous_teacher, required Object new_teacher}) => 'Teacher has been changed from ${previous_teacher} to ${new_teacher}';
	@override String get noTeacherChange => 'Teacher kept unchanged';
	@override String get k1 => 'One';
	@override String get k2 => 'Two';
	@override String get k3 => 'Three';
	@override String get k4 => 'Four';
	@override String get k5 => 'Five';
	@override String get k6 => 'Six';
	@override String get k7 => 'Seven';
	@override String changeClassMessage({required Object original_class_range_start, required Object original_class_range_end, required Object week_char_original_week, required Object original_affected_weeks, required Object new_classroom, required Object new_class_range_start, required Object new_class_range_stop, required Object week_char_new_week, required Object new_affected_weeks_list_str}) => 'This is a course adjustment info，Originally scheduled on period ${original_class_range_start} to period ${original_class_range_end} at the ${week_char_original_week}th day of the ${original_affected_weeks}th week(s), now it is at the ${new_classroom} classroom, arranged at the period ${new_class_range_start} to period ${new_class_range_stop} at the ${week_char_new_week}th day of the ${new_affected_weeks_list_str} week(s).';
	@override String patchClassMessage({required Object new_classroom, required Object new_class_range_start, required Object new_class_range_stop, required Object week_char_new_week, required Object new_affected_weeks_list_str}) => 'This is a course reschedule info，The course have been rescheduled at the ${new_classroom}, on the period ${new_class_range_start} to period ${new_class_range_stop} at the ${week_char_new_week}th day of the ${new_affected_weeks_list_str} week(s).';
	@override String stopClassMessage({required Object original_class_range_start, required Object original_class_range_end, required Object week_char_original_week, required Object original_affected_weeks}) => 'This is a course suspension info. The class will be suspended at the period ${original_class_range_start} to period ${original_class_range_end} at the ${week_char_original_week} day of the ${original_affected_weeks} week(s).';
	@override String classInfo({required Object class_code, required Object class_number, required Object class_change, required Object teacher_change}) => 'Code: ${class_code} | Class ${class_number}\nSchedule change: ${class_change}\n${teacher_change}';
}

// Path: classtable.notArrangedPage
class _Translations$classtable$notArrangedPage$en implements Translations$classtable$notArrangedPage$zh_CN {
	_Translations$classtable$notArrangedPage$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Unscheduled Classes';
	@override String get emptyMessage => 'All courses have been scheduled';
	@override String content({required Object class_code, required Object class_number, required Object teacher}) => 'Code ${class_code} | Class ${class_number}\nTeacher: ${teacher}';
}

// Path: classtable.classCard
class _Translations$classtable$classCard$en implements Translations$classtable$classCard$zh_CN {
	_Translations$classtable$classCard$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Schedule Information';
	@override String get unknownClassroom => 'Unknown classroom';
	@override String remainsHint({required Object remain_count}) => 'There is/are ${remain_count} schedule(s) remaining';
}

// Path: classtable.classAdd
class _Translations$classtable$classAdd$en implements Translations$classtable$classAdd$zh_CN {
	_Translations$classtable$classAdd$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get addClassTitle => 'Add class information';
	@override String get changeClassTitle => 'Modify class info';
	@override String get classNameEmptyMessage => 'Class name cannot be empty';
	@override String get wrongTimeMessage => 'Incorrect time input';
	@override String get saveButton => 'Save';
	@override String get inputClassnameHint => 'Class name (required)';
	@override String get inputTeacherHint => 'Teacher\'s name (optional)';
	@override String get inputClassroomHint => 'Classroom location (optional)';
	@override String get inputWeekHint => 'Select weeks';
	@override String get inputTimeHint => 'Select time';
	@override String get inputTimeWeekdayHint => 'Weekday';
	@override String get inputStartTimeHint => 'Time start';
	@override String get inputEndTimeHint => 'Time end';
	@override String wheelChooseHint({required Object index}) => 'Period ${index}';
	@override String get chooseAtLeastOne => 'Please choose at least one time for class';
	@override String get repeatWeekly => 'Repeat Weekly';
	@override String get freeTime => 'Free Time';
	@override late final _Translations$classtable$classAdd$dateSelectorFree$en dateSelectorFree = _Translations$classtable$classAdd$dateSelectorFree$en._(_root);
}

// Path: classtable.courseDetailCard
class _Translations$classtable$courseDetailCard$en implements Translations$classtable$courseDetailCard$zh_CN {
	_Translations$classtable$courseDetailCard$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String classNumberString({required Object number}) => 'Class ${number}';
	@override String get unknownTeacher => 'Unknown teacher';
	@override String get unknownPlace => 'Unknown classroom';
	@override String classPeriod({required Object start, required Object stop}) => 'period ${start} to ${stop}';
	@override String get edit => 'Edit';
	@override String get delete => 'Delete';
	@override String get deleteSingle => 'Delete this one';
	@override String get deleteAll => 'Delete all';
	@override String get deleteContent => 'Everything will be excuted.';
	@override String get deleteContentSingle => 'Only the information within this time range of the class will be removed.';
	@override String get deleteTitle => 'Are you sure to delete this class information?';
}

// Path: classtable.outputToSystem
class _Translations$classtable$outputToSystem$en implements Translations$classtable$outputToSystem$zh_CN {
	_Translations$classtable$outputToSystem$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get success => 'Successfully output to the system calendar.';
	@override String get failure => 'Problem occurred while outputing to the system calendar.';
	@override String get requestAllTitle => 'Information on requesting permission';
	@override String get requestAll => 'Due to technical difficulties, users must grant both read calendar and write calendar permissions to this software in order to export schedules properly. However, this software will not read the calendar.';
}

// Path: classtable.refreshClasstable
class _Translations$classtable$refreshClasstable$en implements Translations$classtable$refreshClasstable$zh_CN {
	_Translations$classtable$refreshClasstable$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get ready => 'Ready to refresh the schedule';
	@override String get success => 'Successfully refresh the schedule';
}

// Path: classtable.semesterSwitcher
class _Translations$classtable$semesterSwitcher$en implements Translations$classtable$semesterSwitcher$zh_CN {
	_Translations$classtable$semesterSwitcher$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get chooseSemester => 'Choose a Semester';
	@override String get firstAcademicYear => 'Academic year 1';
	@override String get secondAcademicYear => 'Academic year 2';
	@override String get fetchRemoteSemester => 'Fetch Current Semester';
	@override String get fetchingRemoteSemester => 'Fetching...';
	@override String year({required Object year}) => '${year}';
	@override String get onlyFutureHint => 'This app only allows viewing course schedules for future semesters.';
}

// Path: clubPromotion.type
class _Translations$clubPromotion$type$en implements Translations$clubPromotion$type$zh_CN {
	_Translations$clubPromotion$type$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get tech => 'Tech';
	@override String get acg => 'ACG';
	@override String get union => 'Official';
	@override String get profit => 'Commercial';
	@override String get sport => 'Sport';
	@override String get art => 'Culture';
	@override String get unknown => 'Unknown';
	@override String get game => 'Game';
	@override String get all => 'All';
}

// Path: exam.noArrangement
class _Translations$exam$noArrangement$en implements Translations$exam$noArrangement$zh_CN {
	_Translations$exam$noArrangement$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Not arranged exams';
	@override String get allArranged => 'Exams have been scheduled for all subjects';
	@override String subtitle({required Object id}) => 'Code: ${id}';
}

// Path: homepage.inputPartnerData
class _Translations$homepage$inputPartnerData$en implements Translations$homepage$inputPartnerData$zh_CN {
	_Translations$homepage$inputPartnerData$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get routeNotExist => 'Import path does not exist:P';
	@override String get failedGetFile => 'Failed to import file';
	@override String get failedImport => 'Maybe there is a problem with the import file:P';
	@override String get successMessage => 'Import successful, if the class schedule page is open, please reopen it';
	@override String get notLoaded => 'Class schedule has not been loaded yet, please try again later...';
	@override String get confirmContent => 'There is currently partner class schedule data, do you want to overwrite?';
}

// Path: homepage.noticeCard
class _Translations$homepage$noticeCard$en implements Translations$homepage$noticeCard$zh_CN {
	_Translations$homepage$noticeCard$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get emptyNotice => 'No application announcements retrieved, please refresh';
	@override String get noNoticeAvaliable => 'Failed to fetch the application announcements';
	@override String get noticeListTitle => 'Notifications';
	@override String get openUrl => 'Open link';
	@override String get noticePageTitle => 'Notification List';
}

// Path: homepage.classTableCard
class _Translations$homepage$classTableCard$en implements Translations$homepage$classTableCard$zh_CN {
	_Translations$homepage$classTableCard$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Timetable';
	@override String today({required Object remain}) => '${remain} arrangment(s) today';
	@override String get todayFinished => 'Arrangements all done today';
	@override String tomorrow({required Object remain}) => '${remain} arrangment(s) tomorrow';
	@override String get tomorrowNone => 'No arrangement tomorrow';
	@override String weekInfo({required Object weekinfo}) => 'Week ${weekinfo}';
	@override String get onHoliday => 'On vacation';
	@override String errorMessage({required Object error}) => 'An error occurred: ${error}';
	@override String get fetchingMessage => 'Fetching class schedule';
	@override String get errorInfoText => 'An error occurred';
	@override String get fetchingInfoText => 'Loading';
	@override String get noArrangementInfoText => 'No schedule at the moment';
	@override String get scheduleFetchingMessage => 'Schedule is loading, please check again soon';
	@override String get scheduleErrorMessage => 'Failed to load schedule, please try again later';
	@override String get scheduleFetchingInfoText => 'Loading schedule';
	@override String get scheduleErrorInfoText => 'Failed to load schedule';
	@override String get scheduleNoneInfoText => 'No schedule available';
	@override String get updatingInfoText => 'Updating';
	@override String get allLoadingInfoText => 'All sources loading';
	@override String get partialLoadingInfoText => 'Partially loading';
	@override String get partialErrorInfoText => 'Some data failed to load';
	@override String failedChip({required Object source}) => '${source} failed';
	@override String get failedSourceClassInfo => 'Class info';
	@override String get failedSourceExamInfo => 'Exam info';
	@override String get failedSourcePhysicsExperiment => 'Physics experiment';
	@override String get failedSourceOtherExperiment => 'Other experiment';
	@override String get unknownPlace => 'Unknown place';
	@override String seat({required Object seatnum}) => 'Seat ${seatnum}';
}

// Path: homepage.electricityCard
class _Translations$homepage$electricityCard$en implements Translations$homepage$electricityCard$zh_CN {
	_Translations$homepage$electricityCard$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Electricity and Hydroenergy Information';
	@override String currentElectricity({required Object amount}) => '${amount} kWh remains';
	@override String cacheNotice({required Object date}) => 'Last fetch date: ${date}';
}

// Path: homepage.libraryCard
class _Translations$homepage$libraryCard$en implements Translations$homepage$libraryCard$zh_CN {
	_Translations$homepage$libraryCard$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Library Info';
	@override String currentBorrow({required Object count}) => 'Borrowing ${count} book(s)';
	@override String get errorOccured => 'Error occurred while retrieving borrowing information';
	@override String get fetching => 'Fetching borrowing information';
	@override String get noReturn => 'Currently there\'s no book to be returned';
	@override String needReturn({required Object dued}) => 'Need to return ${dued} books';
	@override String get noInfo => 'Cannot retrieve information at the moment';
	@override String get fetchingInfo => 'Fetching information...';
}

// Path: homepage.schoolCardInfoCard
class _Translations$homepage$schoolCardInfoCard$en implements Translations$homepage$schoolCardInfoCard$zh_CN {
	_Translations$homepage$schoolCardInfoCard$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get errorToast => 'An error occurred, please contact the developer';
	@override String get fetchingToast => 'Fetching information, please check later';
	@override String get bill => 'Bill';
	@override String balance({required Object amount}) => 'Remain ${amount} RMB';
	@override String get errorOccured => 'Error occurred while retrieving campus card information';
	@override String get fetching => 'Fetching campus card information';
	@override String get bottomTextSuccess => 'Query campus card bill';
	@override String get noInfo => 'Cannot retrieve information currently';
	@override String get fetchingInfo => 'Fetching information...';
}

// Path: homepage.toolbox
class _Translations$homepage$toolbox$en implements Translations$homepage$toolbox$zh_CN {
	_Translations$homepage$toolbox$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get classAttendance => 'Attendances';
	@override String get creative => 'Innovation and Entrepreneurship Competition';
	@override String get emptyClassroom => 'Classrooms';
	@override String get exam => 'Exams';
	@override String get experiment => 'Experiments';
	@override String get score => 'Grades';
	@override String get sport => 'PE Info';
	@override String get dormWater => 'Dorm Water';
	@override String get schoolnet => 'Schoolnet Usage';
	@override String get toolbox => 'Others';
	@override String get scoreCannotReach => 'Offline mode with no cached score data, unable to access';
	@override String get examFetching => 'Fetching exam information, please wait';
	@override String get examError => 'An error occurred, please contact the developer';
}

// Path: homepage.schoolNet
class _Translations$homepage$schoolNet$en implements Translations$homepage$schoolNet$zh_CN {
	_Translations$homepage$schoolNet$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String title({required Object usage}) => 'Used ${usage}';
	@override String get noPassword => 'The query password is not set, click to set up';
	@override String get failed => 'Failed to get the school net usage info';
	@override String get fetching => 'Fetching the school net usage info';
	@override String remaining({required Object remaining}) => 'Clearing at ${remaining}';
}

// Path: homepage.clubPromotion
class _Translations$homepage$clubPromotion$en implements Translations$homepage$clubPromotion$zh_CN {
	_Translations$homepage$clubPromotion$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get failed => 'Failed to fetch club info';
	@override String get fetching => 'Fetching club info';
}

// Path: login.captchaWindow
class _Translations$login$captchaWindow$en implements Translations$login$captchaWindow$zh_CN {
	_Translations$login$captchaWindow$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Please enter captcha';
	@override String get hint => 'Input captcha';
	@override String get messageOnEmpty => 'Please enter captcha';
	@override String refreshFailed({required Object error}) => 'Failed to refresh captcha: ${error}';
}

// Path: ruisi.common
class _Translations$ruisi$common$en implements Translations$ruisi$common$zh_CN {
	_Translations$ruisi$common$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get refresh => 'Refresh';
	@override String get confirm => 'OK';
	@override String get cancel => 'Cancel';
	@override String get retry => 'Retry';
	@override String get noTopics => 'No topics';
	@override String get noContent => 'No content';
	@override String get reply => 'Reply';
	@override String get favorite => 'Favorite';
	@override String get notImplemented => 'Not implemented';
	@override String get login => 'Login';
	@override String get logout => 'Log out';
	@override String get loggedOut => 'Logged out';
	@override String get submit => 'Submit';
}

// Path: ruisi.about
class _Translations$ruisi$about$en implements Translations$ruisi$about$zh_CN {
	_Translations$ruisi$about$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'About';
	@override String get appName => 'Ruisi';
	@override String get subtitle => 'Xidian University Campus Forum Client';
	@override String get version => 'Version';
	@override String get versionNumber => '2.0.0 (Bundled with XDYou 1.6.0)';
	@override String get sourceCode => 'Source Code';
	@override String get bugReport => 'Report Issue';
	@override String get bugReportSubtitle => 'Submit an issue on GitHub';
	@override String get privacyPolicy => 'Privacy Policy';
	@override String get license => 'Open-sourced under the BSD-3-Clause License Reimplemented based on Ruisi-iOS and Ruisi-Android with AI assistant';
	@override String get privacyPolicyContent => 'This app only operates on the Xidian University campus network, accessing data from the Ruisi Forum (rs.xidian.edu.cn).\n\nThis app does not collect, store, or transmit any personal information to third-party servers.\n\nUser login credentials are stored only on the local device, used for authentication with the Ruisi Forum server.\n\nThis app uses cookies to communicate with the Ruisi Forum server. All data exchange occurs directly between the user\'s device and the Ruisi Forum server.\n\nIf you have any questions, please contact the developer by submitting an issue on GitHub.';
}

// Path: ruisi.home
class _Translations$ruisi$home$en implements Translations$ruisi$home$zh_CN {
	_Translations$ruisi$home$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ruisi Forum';
	@override String get newPost => 'New Post';
	@override String get forumList => 'Forum List';
	@override String get tabHot => 'Hot';
	@override String get tabNewReply => 'Latest Replies';
	@override String get tabNewPost => 'Latest Posts';
	@override String get tabMy => 'Me';
	@override String get tabTrade => 'Trading';
	@override String get tabWater => 'Water Bar';
	@override String get tabLostFound => 'Lost & Found';
	@override String get tabEmployment => 'Employment';
	@override String get tabPhotography => 'Photography';
	@override String get pleaseLogin => 'Please log in first';
	@override String get myProfile => 'My Profile';
	@override String get myPosts => 'My Posts';
	@override String get myFavorites => 'My Favorites';
	@override String get messageCenter => 'Messages';
	@override String get dailyCheckin => 'Daily Check-in';
	@override String get settings => 'Settings';
	@override String get about => 'About';
	@override String get search => 'Search';
}

// Path: ruisi.login
class _Translations$ruisi$login$en implements Translations$ruisi$login$zh_CN {
	_Translations$ruisi$login$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Login to Ruisi';
	@override String get username => 'Username';
	@override String get usernameHint => 'Please enter username';
	@override String get password => 'Password';
	@override String get passwordHint => 'Please enter password';
	@override String get captcha => 'Captcha';
	@override String get captchaHint => 'Please enter captcha';
	@override String get back => 'Back';
	@override String get resetLoginState => 'Reset Login State';
	@override String get resetConfirmTitle => 'Confirm Reset';
	@override String get resetConfirmContent => 'Are you sure you want to reset the login state? This will clear all login information.';
	@override String get resetSuccess => 'Login state has been reset';
	@override String get viewLogs => 'View Logs';
}

// Path: ruisi.post
class _Translations$ruisi$post$en implements Translations$ruisi$post$zh_CN {
	_Translations$ruisi$post$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'New Post';
	@override String get publish => 'Publish';
	@override String get selectForum => 'Select Forum';
	@override String get selectForumHint => 'Please select a forum';
	@override String get subject => 'Title';
	@override String get subjectHint => 'Please enter a title';
	@override String get content => 'Content';
	@override String get contentHint => 'Please enter content';
	@override String get success => 'Post published';
	@override String get failure => 'Failed to publish';
	@override String get smiley => 'Smileys';
}

// Path: ruisi.topicDetail
class _Translations$ruisi$topicDetail$en implements Translations$ruisi$topicDetail$zh_CN {
	_Translations$ruisi$topicDetail$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Topic Detail';
	@override String get replyTooShort => 'Reply must be at least 13 characters';
	@override String get replySuccess => 'Reply sent';
	@override String get replyFailure => 'Failed to reply';
	@override String get favoriteSuccess => 'Added to favorites';
	@override String get favoriteFailure => 'Failed to add to favorites';
	@override String get noData => 'No data';
	@override String get replyHint => 'Write a reply...';
	@override late final _Translations$ruisi$topicDetail$vote$en vote = _Translations$ruisi$topicDetail$vote$en._(_root);
}

// Path: ruisi.topicListItem
class _Translations$ruisi$topicListItem$en implements Translations$ruisi$topicListItem$zh_CN {
	_Translations$ruisi$topicListItem$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get sticky => 'Pinned';
}

// Path: ruisi.forumList
class _Translations$ruisi$forumList$en implements Translations$ruisi$forumList$zh_CN {
	_Translations$ruisi$forumList$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Forum List';
	@override String get empty => 'Ruisi Forum section grouping is empty';
}

// Path: ruisi.favorites
class _Translations$ruisi$favorites$en implements Translations$ruisi$favorites$zh_CN {
	_Translations$ruisi$favorites$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'My Favorites';
	@override String get empty => 'No favorites';
}

// Path: ruisi.messages
class _Translations$ruisi$messages$en implements Translations$ruisi$messages$zh_CN {
	_Translations$ruisi$messages$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Messages';
	@override String get tabAt => '@Me';
	@override String get noReply => 'No reply notifications';
	@override String get noAt => 'No @ notifications';
}

// Path: ruisi.search
class _Translations$ruisi$search$en implements Translations$ruisi$search$zh_CN {
	_Translations$ruisi$search$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get hint => 'Search topics...';
	@override String get inputHint => 'Enter keywords to search';
	@override String get noResults => 'No results';
}

// Path: ruisi.settings
class _Translations$ruisi$settings$en implements Translations$ruisi$settings$zh_CN {
	_Translations$ruisi$settings$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Settings';
	@override String get sectionProxy => 'Proxy';
	@override String get proxyEnable => 'Enable Proxy';
	@override String get proxyDisabled => 'Disabled';
	@override String get proxyAddress => 'Proxy Address';
	@override String get sectionDebug => 'Debug';
	@override String get viewLogs => 'View Logs';
	@override String get proxyDialogTitle => 'Proxy Settings';
	@override String get proxyHost => 'Host';
	@override String get proxyHostHint => 'e.g. 127.0.0.1';
	@override String get proxyPort => 'Port';
	@override String get proxyPortHint => 'e.g. 7890';
}

// Path: ruisi.user
class _Translations$ruisi$user$en implements Translations$ruisi$user$zh_CN {
	_Translations$ruisi$user$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Me';
	@override String get tabProfile => 'Profile';
	@override String get unknown => 'Unknown User';
}

// Path: schoolNet.idsAccountNet
class _Translations$schoolNet$idsAccountNet$en implements Translations$schoolNet$idsAccountNet$zh_CN {
	_Translations$schoolNet$idsAccountNet$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Current user';
	@override String get notice => 'This is the current PDA user\'s information.\nNotice that network traffic is charged in GB (1GB = 1000MB).\nIf you cannot see any info, go to zfw.xidian.edu.cn for password reset';
	@override String get overview => 'Overview';
	@override String get account => 'Account';
	@override String get used => 'Data usage';
	@override String get remain => 'Balance';
	@override String currentOnline({required Object length}) => 'Online devices (currently ${length})';
	@override String get noDeviceOnline => 'No device is online at the moment';
}

// Path: schoolNet.currentLoginNet
class _Translations$schoolNet$currentLoginNet$en implements Translations$schoolNet$currentLoginNet$zh_CN {
	_Translations$schoolNet$currentLoginNet$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Current using';
	@override String get notice => 'This is the information of the current using account.\nIt may be different from the current user\'s, and DON\'T BE EVIL!\nNotice that network traffic is charged in GB (1GB=1000MB).';
	@override String get overview => 'Overview of the account';
	@override String get account => 'Account';
	@override String get planType => 'Type of the plan';
	@override String get remain => 'Balance';
	@override String get usageSituation => 'Traffic usage info';
	@override String usedPercent({required Object percent}) => 'Used ${percent}%';
	@override String get used => 'Data usage';
	@override String get remainCount => 'Data remaining';
	@override String get total => 'Total data';
	@override String get nonSchoolnet => 'Not in school net environment';
}

// Path: schoolNet.deviceList
class _Translations$schoolNet$deviceList$en implements Translations$schoolNet$deviceList$zh_CN {
	_Translations$schoolNet$deviceList$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get ip => 'Device IP';
	@override String get time => 'Online time';
	@override String get remain => 'Traffic used';
}

// Path: score.scoreChoice
class _Translations$score$scoreChoice$en implements Translations$score$scoreChoice$zh_CN {
	_Translations$score$scoreChoice$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Transcript';
	@override String get searchHint => 'Search for score records';
	@override String get emptyList => 'No courses from this semester is selected to be calculated';
	@override String get sumDialogTitle => 'Summary';
	@override String sumDialogContent({required Object gpa_all, required Object avg_all, required Object credit_all, required Object unpassed, required Object not_core_type}) => 'Overall GPA of all subjects：${gpa_all}\nOverall average：${avg_all}\nTotal credits：${credit_all}\nUnpassed subjects：${unpassed}\nPublic selective：${not_core_type}\nThe data provided by this program is for reference only, and the developer is not responsible for its accuracy';
}

// Path: score.scoreComposeCard
class _Translations$score$scoreComposeCard$en implements Translations$score$scoreComposeCard$zh_CN {
	_Translations$score$scoreComposeCard$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get noDetail => 'No detailed information provided';
	@override String get fetching => 'Fetching...';
	@override String get credit => 'Credits';
	@override String get gpa => 'GPA';
	@override String get score => 'Score';
}

// Path: score.scoreInfoCard
class _Translations$score$scoreInfoCard$en implements Translations$score$scoreInfoCard$zh_CN {
	_Translations$score$scoreInfoCard$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Score Details';
	@override String get originalCourse => 'Initial course';
	@override String get failed => '[Failed]';
	@override String credit({required Object credit}) => 'Credits ${credit}';
	@override String gpa({required Object gpa}) => 'GPA ${gpa}';
	@override String score({required Object score}) => 'Score ${score}';
}

// Path: score.scorePage
class _Translations$score$scorePage$en implements Translations$score$scorePage$zh_CN {
	_Translations$score$scorePage$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Score Query';
	@override String get searchHint => 'Search for score records';
	@override String get noRecord => 'No relevant information found';
	@override String get selectAll => 'Select all';
	@override String get selectNothing => 'Clear';
	@override String get resetSelect => 'Reset';
	@override String get summary => 'Summary';
	@override String get cet4 => 'College English Test Band 4';
	@override String get cet6 => 'College English Test Band 6';
}

// Path: setting.lowElectricityThresholdDialog
class _Translations$setting$lowElectricityThresholdDialog$en implements Translations$setting$lowElectricityThresholdDialog$zh_CN {
	_Translations$setting$lowElectricityThresholdDialog$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Set low electricity threshold';
	@override String get inputHint => 'Input remaining electricity';
}

// Path: setting.notificationPage
class _Translations$setting$notificationPage$en implements Translations$setting$notificationPage$zh_CN {
	_Translations$setting$notificationPage$en._(this._root);

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

// Path: setting.clearAndRestartDialog
class _Translations$setting$clearAndRestartDialog$en implements Translations$setting$clearAndRestartDialog$zh_CN {
	_Translations$setting$clearAndRestartDialog$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Restart confirmation';
	@override String get content => 'Are you sure to clear cache and restart the program?';
	@override String get cleaning => 'Clearing cache...';
	@override String get clear => 'Cache has been cleared';
}

// Path: setting.logoutDialog
class _Translations$setting$logoutDialog$en implements Translations$setting$logoutDialog$zh_CN {
	_Translations$setting$logoutDialog$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Logout confirmation';
	@override String get content => 'Are you want to log out? All your data will be completely deleted!';
	@override String get loggingOut => 'Logging out...';
}

// Path: setting.needCloseDialog
class _Translations$setting$needCloseDialog$en implements Translations$setting$needCloseDialog$zh_CN {
	_Translations$setting$needCloseDialog$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Crashed';
	@override String get content => 'Due to technical limitations, you need to close the window manually and then reopen the app.';
}

// Path: setting.changeColorDialog
class _Translations$setting$changeColorDialog$en implements Translations$setting$changeColorDialog$zh_CN {
	_Translations$setting$changeColorDialog$en._(this._root);

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

// Path: setting.changeBrightnessDialog
class _Translations$setting$changeBrightnessDialog$en implements Translations$setting$changeBrightnessDialog$zh_CN {
	_Translations$setting$changeBrightnessDialog$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Brightness settings';
	@override String get followSetting => 'Follow system';
	@override String get dayMode => 'Day mode';
	@override String get nightMode => 'Night mode';
}

// Path: setting.changeSwiftDialog
class _Translations$setting$changeSwiftDialog$en implements Translations$setting$changeSwiftDialog$zh_CN {
	_Translations$setting$changeSwiftDialog$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Class schedule offset setting';
	@override String get inputHint => 'Please input number here';
}

// Path: setting.changeElectricityAccount
class _Translations$setting$changeElectricityAccount$en implements Translations$setting$changeElectricityAccount$zh_CN {
	_Translations$setting$changeElectricityAccount$en._(this._root);

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

// Path: setting.changePasswordDialog
class _Translations$setting$changePasswordDialog$en implements Translations$setting$changePasswordDialog$zh_CN {
	_Translations$setting$changePasswordDialog$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get inputHint => 'Please input password here';
	@override String get blankInput => 'Blank input!';
}

// Path: setting.updateDialog
class _Translations$setting$updateDialog$en implements Translations$setting$updateDialog$zh_CN {
	_Translations$setting$updateDialog$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get newVersion => 'New version available';
	@override String get notNow => 'Not now';
	@override String get appStore => 'Update from App Store';
	@override String get downloadApk => 'Download APK';
	@override String get githubRelease => 'Go to Git Release';
	@override String newContent({required Object code}) => 'New features from version ${code}:\n';
}

// Path: setting.localizationDialog
class _Translations$setting$localizationDialog$en implements Translations$setting$localizationDialog$zh_CN {
	_Translations$setting$localizationDialog$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Languages';
	@override String get undefined => 'Follow system setting';
	@override String get simplifiedChinese => 'Simplified Chinese';
	@override String get traditionalChinese => 'Traditional Chinese';
	@override String get english => 'English';
}

// Path: setting.aboutPage
class _Translations$setting$aboutPage$en implements Translations$setting$aboutPage$zh_CN {
	_Translations$setting$aboutPage$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get benderblog => 'Main developer, iOS widget';
	@override String get alnair => 'Development: Library search and cover';
	@override String get aqqkad => 'Development: Class attandance history';
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
	@override String get imoscarz => 'Development: Homepage for software / Development: Checkin check for pad / Development: Sport UI Change';
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
	@override String get copyrightNotice => 'This software is compiled, or derived from the traintime_pda (a.k.a watermeter) codebase, which is licensed under Mozilla Public License v2.0.\n\nThis APP has no relation to Xidian University, Tishineng Service, Shuwow and other services.\n\nCopyright 2023-2025 BenderBlog Rodriguez and contributors.\nCopyright 2025-present Traintime PDA authors.\n\nThe Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, you can obtain one at https://mozilla.org/MPL/2.0/.';
	@override String get beian => 'ICP record code';
	@override String get signAndroid => 'Android signature';
	@override String get title => 'About this APP';
}

// Path: xduPlanet.confirmAuditDialog
class _Translations$xduPlanet$confirmAuditDialog$en implements Translations$xduPlanet$confirmAuditDialog$zh_CN {
	_Translations$xduPlanet$confirmAuditDialog$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Confirm reporting';
	@override String get content => 'Think twice. Reporting will tag the comment, but it may not be deleted.';
	@override String get cancel => 'Forget it';
	@override String get ongoing => 'Reporting...';
	@override String get failed => 'Failed to report';
	@override String get success => 'Successfully reporting';
}

// Path: classtable.partnerClasstable.shareDialog
class _Translations$classtable$partnerClasstable$shareDialog$en implements Translations$classtable$partnerClasstable$shareDialog$zh_CN {
	_Translations$classtable$partnerClasstable$shareDialog$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Caution!';
	@override String get content => 'The exported file may include your personal information, please DO NOT share casually';
}

// Path: classtable.partnerClasstable.saveDialog
class _Translations$classtable$partnerClasstable$saveDialog$en implements Translations$classtable$partnerClasstable$saveDialog$zh_CN {
	_Translations$classtable$partnerClasstable$saveDialog$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Save calendar file to...';
	@override String get successMessage => 'Should be saved';
	@override String get failureMessage => 'Can not create the file, save fails.';
}

// Path: classtable.partnerClasstable.deleteDialog
class _Translations$classtable$partnerClasstable$deleteDialog$en implements Translations$classtable$partnerClasstable$deleteDialog$zh_CN {
	_Translations$classtable$partnerClasstable$deleteDialog$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => '(｡í _ ì｡)For real?';
	@override String get message => 'Are you sure to delete the partner classtable?';
	@override String get successMessage => 'Done';
}

// Path: classtable.partnerClasstable.nameDialog
class _Translations$classtable$partnerClasstable$nameDialog$en implements Translations$classtable$partnerClasstable$nameDialog$zh_CN {
	_Translations$classtable$partnerClasstable$nameDialog$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Input the name of the partner classtable to be shown on your partner\'s screen';
	@override String get hint => 'Input here, otherwise it will be shown as \'Sweetie\'';
	@override String get cancel => 'There\'s nobody other than my sweetie';
	@override String get accept => 'Submit';
	@override String get blankInput => 'Input is blank!';
}

// Path: classtable.classAdd.dateSelectorFree
class _Translations$classtable$classAdd$dateSelectorFree$en implements Translations$classtable$classAdd$dateSelectorFree$zh_CN {
	_Translations$classtable$classAdd$dateSelectorFree$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get rule => 'Time must be between 8:30 and 21:25.';
	@override String get rule2 => 'The end time must be later than the start time.';
	@override String get classStartTime => 'Start time';
	@override String get classEndTime => 'End time';
	@override String get editClassTime => 'Edit the class time';
	@override String get chooseClassTime => 'Choose a class time';
}

// Path: ruisi.topicDetail.vote
class _Translations$ruisi$topicDetail$vote$en implements Translations$ruisi$topicDetail$vote$zh_CN {
	_Translations$ruisi$topicDetail$vote$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get singleSelect => 'Single choice';
	@override String multiSelect({required Object count}) => 'Multiple choice, up to ${count}';
	@override String get titlePrefix => 'Vote';
	@override String count({required Object count}) => '${count} people voted';
	@override String get open => 'Vote';
	@override String get sheetTitle => 'Vote';
	@override String maxSelection({required Object count}) => 'You can select up to ${count}';
	@override String get notSelected => 'Please select an option';
	@override String get success => 'Vote submitted';
	@override String get failure => 'Vote failed';
	@override String get paramError => 'Vote failed: invalid parameters';
	@override String get alreadyVoted => 'You have already voted. Thank you!';
	@override String get expired => 'This poll has expired or been closed';
	@override String get ended => 'This poll has ended';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEn {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'classAttendance.title' => 'Attendance Query',
			'classAttendance.detailTitle' => ({required Object course_name}) => 'Attendance Detail - ${course_name}',
			'classAttendance.noData' => 'No course info',
			'classAttendance.noAttendanceRecord' => 'No attendance record',
			'classAttendance.longLoad' => 'It takes about half minute to load attendance data, pleace wait patiently',
			'classAttendance.courseState.unknown' => 'unknown',
			'classAttendance.courseState.ineligible' => 'ineligible',
			'classAttendance.courseState.eligible' => 'eligible',
			'classAttendance.courseState.warning' => 'warning',
			'classAttendance.table.courseName' => 'Course Name',
			'classAttendance.table.status' => 'Status',
			'classAttendance.table.attendanceRate' => 'Rate',
			'classAttendance.table.checkIn' => 'Check-in',
			'classAttendance.table.absence' => 'Absence',
			'classAttendance.table.required' => 'Required',
			'classAttendance.table.leave' => 'Leave(P/S/O)',
			'classAttendance.table.filter' => 'Filter',
			'classAttendance.table.filterAll' => 'All',
			'classAttendance.table.showingCount' => ({required Object count, required Object total}) => 'Showing ${count}/${total} courses',
			'classAttendance.card.time' => 'Attendances',
			'classAttendance.card.timeInfo' => ({required Object check_in_count, required Object absence_count, required Object required_check_in}) => '${check_in_count} Checked / ${absence_count} Absences / ${required_check_in} Required',
			'classAttendance.card.notAttend' => 'Rebirths',
			'classAttendance.card.notAttendInfo' => ({required Object time_to_have_error, required Object total_times}) => '${time_to_have_error} Times / ${total_times} Total',
			'classAttendance.card.notAttendInfoError' => 'Cannot match course in the classtable',
			'classAttendance.card.leave' => 'Leaves',
			'classAttendance.card.leaveInfo' => ({required Object personal_leave, required Object sick_leave, required Object official_leave}) => 'Personal ${personal_leave} / Sick ${sick_leave} / Official ${official_leave}',
			'classAttendance.card.study' => 'Study',
			'classAttendance.card.studyInfo' => ({required Object task_progress, required Object homework_progress, required Object exam_progress}) => 'Task ${task_progress} / Works ${homework_progress} / Exam ${exam_progress}',
			'classAttendance.detailCard.creatorName' => 'Creator',
			'classAttendance.detailCard.startTime' => 'Start at',
			'classAttendance.detailCard.summitTime' => 'Summit at',
			'classAttendance.signType.qrCode' => 'QR Code Checkin',
			'classAttendance.signType.gesture' => 'Gesture Checkin',
			'classAttendance.signType.position' => 'Position Checkin',
			'classAttendance.signType.kDefault' => 'Normal Checkin',
			'classAttendance.signStatus.absenceNotParticipating' => 'Absence (Not participating)',
			'classAttendance.signStatus.signed' => 'Signed',
			'classAttendance.signStatus.signedByTeacher' => 'Signed by teacher',
			'classAttendance.signStatus.personalLeave2' => 'Personal Leave',
			'classAttendance.signStatus.absence' => 'Absence',
			'classAttendance.signStatus.sickLeave' => 'Sick Leave',
			'classAttendance.signStatus.personalLeave' => 'Personal Leave',
			'classAttendance.signStatus.late' => 'Late',
			'classAttendance.signStatus.leaveEarly' => 'Leave Early',
			'classAttendance.signStatus.signExpiredy' => 'Sign Expired',
			'classAttendance.signStatus.publicLeave' => 'Public Leave',
			'classtable.partnerClasstable.overrideDialog' => 'Currently there is a partner classtable data, do you want to overwrite?',
			'classtable.partnerClasstable.noFile' => 'Import file not found',
			'classtable.partnerClasstable.noPermission' => 'Storage permission denied , cannot read file',
			'classtable.partnerClasstable.problem' => 'Maybe there\'s a problem with the import file :P',
			'classtable.partnerClasstable.success' => 'Successfully imported',
			'classtable.partnerClasstable.shareDialog.title' => 'Caution!',
			'classtable.partnerClasstable.shareDialog.content' => 'The exported file may include your personal information, please DO NOT share casually',
			'classtable.partnerClasstable.saveDialog.title' => 'Save calendar file to...',
			'classtable.partnerClasstable.saveDialog.successMessage' => 'Should be saved',
			'classtable.partnerClasstable.saveDialog.failureMessage' => 'Can not create the file, save fails.',
			'classtable.partnerClasstable.deleteDialog.title' => '(｡í _ ì｡)For real?',
			'classtable.partnerClasstable.deleteDialog.message' => 'Are you sure to delete the partner classtable?',
			'classtable.partnerClasstable.deleteDialog.successMessage' => 'Done',
			'classtable.partnerClasstable.nameDialog.title' => 'Input the name of the partner classtable to be shown on your partner\'s screen',
			'classtable.partnerClasstable.nameDialog.hint' => 'Input here, otherwise it will be shown as \'Sweetie\'',
			'classtable.partnerClasstable.nameDialog.cancel' => 'There\'s nobody other than my sweetie',
			'classtable.partnerClasstable.nameDialog.accept' => 'Submit',
			'classtable.partnerClasstable.nameDialog.blankInput' => 'Input is blank!',
			'classtable.pageTitle' => 'My Schedule',
			'classtable.partnerPageTitle' => ({required Object partner_name}) => '${partner_name}\'s Schedule',
			'classtable.popupMenu.notArranged' => 'View unarranged classes',
			'classtable.popupMenu.classChanged' => 'View schedule changes',
			'classtable.popupMenu.addClass' => 'Add class',
			'classtable.popupMenu.generateIcal' => 'Export calendar file',
			'classtable.popupMenu.generatePartnerFile' => 'Export partner classtable file',
			'classtable.popupMenu.importPartnerFile' => 'Import partner classtable file',
			'classtable.popupMenu.deletePartnerFile' => 'Delete partner classtable file',
			'classtable.popupMenu.outputToSystem' => 'Export to system calendar',
			'classtable.popupMenu.refreshClasstable' => 'Refresh schedule',
			'classtable.popupMenu.switchSemester' => 'Switch classtable semester',
			'classtable.popupMenu.currentTimeSettings' => 'Time indicator settings',
			'classtable.popupMenu.classColorSettings' => 'Class color settings',
			'classtable.visualSettings.currentTimeSettingsTitle' => 'Time indicator settings',
			'classtable.visualSettings.classColorSettingsTitle' => 'Class color settings',
			'classtable.visualSettings.completedStyleEnabled' => 'Completed class styling distinction',
			'classtable.visualSettings.currentTimeSection' => 'Time indicators',
			'classtable.visualSettings.showCurrentTimeIndicator' => 'Show current time indicator',
			'classtable.visualSettings.showCurrentTimeLabel' => 'Show mini time label',
			'classtable.visualSettings.showTodayColumnHighlight' => 'Highlight today\'s column',
			'classtable.visualSettings.unfinishedSection' => 'Class style',
			'classtable.visualSettings.activeBrightnessFactor' => ({required Object value}) => 'Brightness: ${value}',
			'classtable.visualSettings.activeBorderAlpha' => ({required Object value}) => 'Border opacity: ${value}',
			'classtable.visualSettings.activeInnerAlpha' => ({required Object value}) => 'Fill opacity: ${value}',
			'classtable.visualSettings.completedSection' => 'Completed class style',
			'classtable.visualSettings.completedSaturationFactor' => ({required Object value}) => 'Fill saturation: ${value}',
			'classtable.visualSettings.completedBrightnessFactor' => ({required Object value}) => 'Brightness: ${value}',
			'classtable.visualSettings.completedTextSaturationFactor' => ({required Object value}) => 'Text saturation: ${value}',
			'classtable.visualSettings.completedBorderAlpha' => ({required Object value}) => 'Border opacity: ${value}',
			'classtable.visualSettings.completedInnerAlpha' => ({required Object value}) => 'Fill opacity: ${value}',
			'classtable.statusSource.classTable' => 'Class Table',
			'classtable.statusSource.exam' => 'Exams',
			'classtable.statusSource.physicsExperiment' => 'Physics Experiments',
			'classtable.statusSource.otherExperiment' => 'Other Experiments',
			'classtable.errorDialogTitle' => 'Error Info',
			'classtable.statusBanner.loading' => ({required Object sources}) => 'Updating: ${sources}',
			'classtable.statusBanner.cache' => ({required Object sources}) => 'Using cached data: ${sources}',
			'classtable.statusBanner.errorSummary' => ({required Object sources}) => 'Failed to load: ${sources}',
			'classtable.emptyState.noCourse' => ({required Object semester_code}) => 'No classes are arranged for semester ${semester_code}.',
			'classtable.emptyState.withExam' => ({required Object semester_code}) => 'No classes are arranged for semester ${semester_code}, but exam arrangements are available.',
			'classtable.emptyState.withExperiment' => ({required Object semester_code}) => 'No classes are arranged for semester ${semester_code}, but experiment arrangements are available.',
			'classtable.emptyState.withExamAndExperiment' => ({required Object semester_code}) => 'No classes are arranged for semester ${semester_code}, but exam and experiment arrangements are available.',
			'classtable.emptyAction.viewExam' => 'View exams',
			'classtable.emptyAction.viewExperiment' => 'View experiments',
			'classtable.classChangePage.title' => 'Schedule Changes',
			'classtable.classChangePage.emptyMessage' => 'Currently there\'s no class schedule changes',
			'classtable.classChangePage.teacherChange' => ({required Object previous_teacher, required Object new_teacher}) => 'Teacher has been changed from ${previous_teacher} to ${new_teacher}',
			'classtable.classChangePage.noTeacherChange' => 'Teacher kept unchanged',
			'classtable.classChangePage.k1' => 'One',
			'classtable.classChangePage.k2' => 'Two',
			'classtable.classChangePage.k3' => 'Three',
			'classtable.classChangePage.k4' => 'Four',
			'classtable.classChangePage.k5' => 'Five',
			'classtable.classChangePage.k6' => 'Six',
			'classtable.classChangePage.k7' => 'Seven',
			'classtable.classChangePage.changeClassMessage' => ({required Object original_class_range_start, required Object original_class_range_end, required Object week_char_original_week, required Object original_affected_weeks, required Object new_classroom, required Object new_class_range_start, required Object new_class_range_stop, required Object week_char_new_week, required Object new_affected_weeks_list_str}) => 'This is a course adjustment info，Originally scheduled on period ${original_class_range_start} to period ${original_class_range_end} at the ${week_char_original_week}th day of the ${original_affected_weeks}th week(s), now it is at the ${new_classroom} classroom, arranged at the period ${new_class_range_start} to period ${new_class_range_stop} at the ${week_char_new_week}th day of the ${new_affected_weeks_list_str} week(s).',
			'classtable.classChangePage.patchClassMessage' => ({required Object new_classroom, required Object new_class_range_start, required Object new_class_range_stop, required Object week_char_new_week, required Object new_affected_weeks_list_str}) => 'This is a course reschedule info，The course have been rescheduled at the ${new_classroom}, on the period ${new_class_range_start} to period ${new_class_range_stop} at the ${week_char_new_week}th day of the ${new_affected_weeks_list_str} week(s).',
			'classtable.classChangePage.stopClassMessage' => ({required Object original_class_range_start, required Object original_class_range_end, required Object week_char_original_week, required Object original_affected_weeks}) => 'This is a course suspension info. The class will be suspended at the period ${original_class_range_start} to period ${original_class_range_end} at the ${week_char_original_week} day of the ${original_affected_weeks} week(s).',
			'classtable.classChangePage.classInfo' => ({required Object class_code, required Object class_number, required Object class_change, required Object teacher_change}) => 'Code: ${class_code} | Class ${class_number}\nSchedule change: ${class_change}\n${teacher_change}',
			'classtable.notArrangedPage.title' => 'Unscheduled Classes',
			'classtable.notArrangedPage.emptyMessage' => 'All courses have been scheduled',
			'classtable.notArrangedPage.content' => ({required Object class_code, required Object class_number, required Object teacher}) => 'Code ${class_code} | Class ${class_number}\nTeacher: ${teacher}',
			'classtable.emptyClassMessage' => ({required Object semester_code}) => 'Semester ${semester_code} has no class arranged',
			'classtable.emptyClassWithExam' => ({required Object semester_code}) => 'Semester ${semester_code} has no class arranged\nbut we have exam info now!\nGo back to mainpage and goto the exam info page.',
			'classtable.weekTitle' => ({required Object week}) => 'Week ${week}',
			'classtable.noonBreak' => 'Noon',
			'classtable.supperBreak' => 'Supper',
			'classtable.month' => ({required Object month}) => '${month}\nmo',
			'classtable.noClass' => 'No schedule arranged in this week, please do not spend much of your time on bed.',
			'classtable.classCard.title' => 'Schedule Information',
			'classtable.classCard.unknownClassroom' => 'Unknown classroom',
			'classtable.classCard.remainsHint' => ({required Object remain_count}) => 'There is/are ${remain_count} schedule(s) remaining',
			'classtable.classAdd.addClassTitle' => 'Add class information',
			'classtable.classAdd.changeClassTitle' => 'Modify class info',
			'classtable.classAdd.classNameEmptyMessage' => 'Class name cannot be empty',
			'classtable.classAdd.wrongTimeMessage' => 'Incorrect time input',
			'classtable.classAdd.saveButton' => 'Save',
			'classtable.classAdd.inputClassnameHint' => 'Class name (required)',
			'classtable.classAdd.inputTeacherHint' => 'Teacher\'s name (optional)',
			'classtable.classAdd.inputClassroomHint' => 'Classroom location (optional)',
			'classtable.classAdd.inputWeekHint' => 'Select weeks',
			'classtable.classAdd.inputTimeHint' => 'Select time',
			'classtable.classAdd.inputTimeWeekdayHint' => 'Weekday',
			'classtable.classAdd.inputStartTimeHint' => 'Time start',
			'classtable.classAdd.inputEndTimeHint' => 'Time end',
			'classtable.classAdd.wheelChooseHint' => ({required Object index}) => 'Period ${index}',
			'classtable.classAdd.chooseAtLeastOne' => 'Please choose at least one time for class',
			'classtable.classAdd.repeatWeekly' => 'Repeat Weekly',
			'classtable.classAdd.freeTime' => 'Free Time',
			'classtable.classAdd.dateSelectorFree.rule' => 'Time must be between 8:30 and 21:25.',
			'classtable.classAdd.dateSelectorFree.rule2' => 'The end time must be later than the start time.',
			'classtable.classAdd.dateSelectorFree.classStartTime' => 'Start time',
			'classtable.classAdd.dateSelectorFree.classEndTime' => 'End time',
			'classtable.classAdd.dateSelectorFree.editClassTime' => 'Edit the class time',
			'classtable.classAdd.dateSelectorFree.chooseClassTime' => 'Choose a class time',
			'classtable.courseDetailCard.classNumberString' => ({required Object number}) => 'Class ${number}',
			'classtable.courseDetailCard.unknownTeacher' => 'Unknown teacher',
			'classtable.courseDetailCard.unknownPlace' => 'Unknown classroom',
			'classtable.courseDetailCard.classPeriod' => ({required Object start, required Object stop}) => 'period ${start} to ${stop}',
			'classtable.courseDetailCard.edit' => 'Edit',
			'classtable.courseDetailCard.delete' => 'Delete',
			'classtable.courseDetailCard.deleteSingle' => 'Delete this one',
			'classtable.courseDetailCard.deleteAll' => 'Delete all',
			'classtable.courseDetailCard.deleteContent' => 'Everything will be excuted.',
			'classtable.courseDetailCard.deleteContentSingle' => 'Only the information within this time range of the class will be removed.',
			'classtable.courseDetailCard.deleteTitle' => 'Are you sure to delete this class information?',
			'classtable.outputToSystem.success' => 'Successfully output to the system calendar.',
			'classtable.outputToSystem.failure' => 'Problem occurred while outputing to the system calendar.',
			'classtable.outputToSystem.requestAllTitle' => 'Information on requesting permission',
			'classtable.outputToSystem.requestAll' => 'Due to technical difficulties, users must grant both read calendar and write calendar permissions to this software in order to export schedules properly. However, this software will not read the calendar.',
			'classtable.refreshClasstable.ready' => 'Ready to refresh the schedule',
			'classtable.refreshClasstable.success' => 'Successfully refresh the schedule',
			'classtable.cacheHintPasswordWrong' => 'IDS password is incorrect or expired.',
			'classtable.cacheHintLoginFailed' => 'Failed to log in to the classtable service.',
			'classtable.cacheHintNetworkFailed' => 'Classtable network request failed.',
			'classtable.cacheHintUnknownError' => 'Failed to fetch the latest classtable online. Check logs for details.',
			'classtable.semesterSwitcher.chooseSemester' => 'Choose a Semester',
			'classtable.semesterSwitcher.firstAcademicYear' => 'Academic year 1',
			'classtable.semesterSwitcher.secondAcademicYear' => 'Academic year 2',
			'classtable.semesterSwitcher.fetchRemoteSemester' => 'Fetch Current Semester',
			'classtable.semesterSwitcher.fetchingRemoteSemester' => 'Fetching...',
			'classtable.semesterSwitcher.year' => ({required Object year}) => '${year}',
			'classtable.semesterSwitcher.onlyFutureHint' => 'This app only allows viewing course schedules for future semesters.',
			'clubPromotion.type.tech' => 'Tech',
			'clubPromotion.type.acg' => 'ACG',
			'clubPromotion.type.union' => 'Official',
			'clubPromotion.type.profit' => 'Commercial',
			'clubPromotion.type.sport' => 'Sport',
			'clubPromotion.type.art' => 'Culture',
			'clubPromotion.type.unknown' => 'Unknown',
			'clubPromotion.type.game' => 'Game',
			'clubPromotion.type.all' => 'All',
			'clubPromotion.wrongParam' => 'Wrong Parameter',
			'clubPromotion.noGroupInfo' => 'No Club info',
			'clubPromotion.loading' => 'Loading',
			'clubPromotion.errorOutside' => 'Error detected at the outside',
			'clubPromotion.error' => 'Error detected',
			'clubPromotion.qqCopied' => 'QQ Group Number have been copied to the clipboard',
			'clubPromotion.noLink' => 'No group invite link provided',
			'clubPromotion.loadingProblem' => 'Error on loading page',
			'clubPromotion.picturePreview' => 'Picture',
			'common.dragText' => 'Pull to request more',
			'common.readyText' => 'Loading...',
			'common.processingText' => 'Processing...',
			'common.processedText' => 'Successfully requested',
			'common.noMoreText' => 'No more data',
			'common.failedText' => 'Failed to load data',
			'common.chooseSemester' => 'Choose Semester',
			'common.errorDetected' => 'Ouch! An error occurred!',
			'common.clickToRefresh' => 'Click to refresh',
			'common.confirmTitle' => 'Confirm? (ゝ∀･)',
			'common.cancel' => 'Cancel',
			'common.confirm' => 'Okay',
			'common.networkError' => 'Network error, maybe you are not connected to the Internet, or the school server is down :P',
			'common.errorDetect' => 'An error has occurred,',
			'common.queryFailed' => 'Query failed',
			'common.notSchoolNetwork' => 'Not on the Campus Network',
			'common.cancelExam' => 'Disqualified to exam :P',
			'common.noInfo' => 'No information',
			'common.catcherDetected' => 'An error has occurred',
			'common.catcherDescription' => 'Details are shown as follows',
			'common.newHomepageHint' => 'A new homepage is developing here, the pigimg is a placeholder, have fun',
			'common.localCacheHint' => ({required Object datetime}) => 'Local cache from ${datetime}',
			'common.inappCacheHint' => ({required Object datetime}) => 'In-app cache from ${datetime}\nCache will be cleared once restart!',
			'common.cacheReasonDefault' => 'Showing cached data.',
			'common.easterEggApple' => '=== Fly Me To The Moon ===\nVocal: Frank Sintara, 1964\n\nFly me to the moon\nLet me play among the stars\n\nLet me see what\'s spring is like\non a Jupiter and Mars\n\nFill my heart with song\nand let me sing forever more\n\nYou are all I long for\nall I worship and I adore\n\nIn other words\nPlease, be true\n\nIn other words\nI love you\n\n=== Living Inside Your Love ===\nGuitar: Earl Klugh, 1976\n\nCan\'t get over the feeling\nLiving inside your love\n\nI never want to lose the feeling\nLiving inside your love\n\nBaby, you made my life so free\nLiving inside your love\n\nI\'m just where I want to be\nLiving inside your love\n\nAnd I never could say\nWhat I\'m feeling today\nFor you...\n',
			'common.easterEggOthers' => '=== Cardcaptor Sakura OP3 ===\nVocal: Maaya Sakamoto, 2000\nIn Japanese Roman Letters\n\nI\'m a dreamer\nhisomu PAWA-\n\nwatashi no sekai\nyume to koi to fuan de dekite\'ru\ndemo souzou wo shinai mono\nkakurete\'ru hazu\n\nsora ni mukau kiki no you ni anata wo\nmassugu mitsumete\'ru\nmitsuketai naa kanaetai naa\nshinjiru sore dake de\n\nkoerarenai mono wa nai\nutau you ni kiseki no you ni\n"omoi" ga subete wo kaete yuku yo\nkitto kitto\nodoroku kurai\n\n=== Living Inside Your Love ===\nGuitar: Earl Klugh, 1976\n\nCan\'t get over the feeling\nLiving inside your love\n\nI never want to lose the feeling\nLiving inside your love\n\nBaby, you made my life so free\nLiving inside your love\n\nI\'m just where I want to be\nLiving inside your love\n\nAnd I never could say\nWhat I\'m feeling today\nFor you...\n',
			'common.loadError' => 'Load Error',
			'courseReminder.title' => ({required Object name}) => 'Pre-class Reminder: ${name}',
			'courseReminder.body' => ({required Object time}) => 'Class starts in ${time} minutes',
			'courseReminder.location' => ({required Object location}) => 'Location: ${location}',
			'courseReminder.teacher' => ({required Object teacher}) => 'Teacher: ${teacher}',
			'dormWater.title' => 'Dorm Water',
			'dormWater.phone' => 'Phone',
			'dormWater.imageCode' => 'Image code',
			'dormWater.smsCode' => 'SMS code',
			'dormWater.sendSms' => 'Send SMS',
			'dormWater.login' => 'Login',
			'dormWater.logout' => 'Logout',
			'dormWater.refreshCaptcha' => 'Refresh Captcha',
			'dormWater.loadingCaptcha' => 'Loading...',
			'dormWater.captchaError' => 'Failed to load captcha',
			'dormWater.phoneRequired' => 'Please enter phone number',
			'dormWater.imageCodeRequired' => 'Please enter image code',
			'dormWater.smsSent' => 'SMS sent successfully',
			'dormWater.smsFailed' => 'Failed to send SMS',
			'dormWater.smsCodeRequired' => 'Please enter SMS code',
			'dormWater.loginSuccess' => 'Login successful',
			'dormWater.loginFailed' => 'Login failed',
			'dormWater.logoutSuccess' => 'Logged out successfully',
			'dormWater.devices' => 'Device List',
			'dormWater.loadingDevices' => 'Loading devices...',
			'dormWater.noDevices' => 'No devices',
			'dormWater.selectDevice' => 'Select Device',
			'dormWater.fetchDevicesFailed' => 'Failed to fetch device list',
			'dormWater.retryLoadDevices' => 'Retry Loading',
			'dormWater.startWater' => 'Start Water',
			'dormWater.endWater' => 'End Water',
			'dormWater.waterDispensing' => 'Water Dispensing',
			'dormWater.waterStatus' => 'Water Status',
			'dormWater.startWaterSuccess' => 'Water dispensing started',
			'dormWater.endWaterSuccess' => 'Water dispensing ended',
			'dormWater.startWaterFailed' => 'Failed to start water',
			'dormWater.endWaterFailed' => 'Failed to end water',
			'dormWater.deviceStatusChecking' => 'Checking device status...',
			'dormWater.deviceStatusReady' => 'Device ready',
			'dormWater.scanQrCode' => 'Scan QR Code',
			'dormWater.deviceId' => 'Device ID',
			'dormWater.addDeviceFailed' => 'Failed to add device',
			'dormWater.deviceRemovedFromFavorites' => 'Device removed from favorites',
			'dormWater.removeFromFavoritesFailed' => 'Failed to remove from favorites',
			'easterEggRobot.appbar' => 'Welcome Students!',
			'easterEggRobot.title' => 'Looking like you are worrying about opening semester?',
			'easterEggRobot.contents' => 'We are here to let our children have more pocket money.\n1. Robots may not injure a human being or, through inaction, allow a human being to come to harm.\n2. Robots are born from the ashes of the network running at the cloud.\n3. Robots are lovestruck, which cannot be annoyed, and loves merging programs!\n4. Robots sometimes can be controlled to avoid the attack from the Angles.\n5. Robots have shiny metal ass which should not be bitten.\nAnd they have a plan.',
			'easterEggRobot.buttonOne' => 'We are hanger for your help!',
			'easterEggRobot.buttonTwo' => 'Come on!',
			'easterEggRobot.buttonNotice' => '\o/\o/\o/\o/\o/\o/\o/\o/',
			'electricity.title' => 'Power Info',
			'electricity.powerTitle' => 'Infomation',
			'electricity.cacheHintLoginFailed' => 'Failed to log in to the electricity service, showing cached data.',
			'electricity.cacheHintNetworkFailed' => 'Electricity service network request failed, showing cached data.',
			'electricity.cacheHintUnknownError' => 'Failed to fetch the latest electricity data online, showing cached data. Check logs for details.',
			'electricity.cacheNotice' => 'Last fetched',
			'electricity.account' => 'Account',
			'electricity.remainPower' => 'Remain power',
			'electricity.oweInfo' => 'Arrears',
			'electricity.history' => 'Billing History',
			'electricity.dailyUsage' => 'Average usage per day',
			'electricity.notEnoughData' => 'Not enough data for rendering graph',
			'electricity.info' => 'Energy system can be only be accessed at schoolnet, do contact developers if have issue.\nHistory will be recorded locally while average usage is based on the electric meter\'s record.',
			'electricity.fetchingHint' => 'Fetching the latest electricity info.',
			'electricity.fetchError' => 'Failed to fetch electricity information. Please retry.',
			'electricity.date' => 'Date',
			'electricity.power' => 'Remaining',
			'electricity.update' => 'Refresh',
			'electricity.waterUsageFetchDate' => 'Fetch time',
			'electricity.waterUsageReadBefore' => 'Last time',
			'electricity.waterUsageReadNow' => 'This time',
			'electricity.waterUsage' => 'Bath water usage',
			'electricity.waterTitle' => 'Water usage',
			'electricity.waterLoading' => 'Loading water usage information',
			'electricity.waterUnavailable' => 'Water usage is unavailable. Retry from the electricity card.',
			'electricity.waterEmpty' => 'No water usage information',
			'electricity.notSchoolNetwork' => 'Not school network',
			'electricity.airconTitle' => 'Aircon Electricity',
			'electricity.airconImei' => 'Aircon IMEI',
			'electricity.airconAmount' => 'Platform usage',
			'electricity.airconUpdateTime' => 'Updated at',
			'electricity.airconWaiting' => 'Waiting to fetch aircon electricity data',
			'electricity.airconError' => 'Failed to fetch aircon electricity data',
			'electricity.airconRetry' => 'Retry',
			'electricity.airconImeiMissing' => 'Add the aircon IMEI to view its electricity usage.',
			'electricity.airconAddImei' => 'Add aircon IMEI',
			'electricity.airconCacheNotice' => ({required Object time}) => 'Showing cached aircon data from ${time}',
			'electricityStatus.pending' => 'Pending',
			'electricityStatus.remainFetching' => 'Fetching...',
			'electricityStatus.remainNetworkIssue' => 'Network malfunction',
			'electricityStatus.remainNotFound' => 'Query failed',
			'electricityStatus.remainOtherIssue' => 'Query malfunction',
			'electricityStatus.oweFetching' => 'Obtaining arrearage',
			'electricityStatus.oweIssue' => 'Network malfunction of overdue information',
			'electricityStatus.oweNotFound' => 'Cannot query arrearage, check log window for detail',
			'electricityStatus.oweNoNeed' => 'None',
			'electricityStatus.oweNeedPay' => ({required Object due}) => 'Need to pay ${due} yuan',
			'electricityStatus.oweIssueUnable' => 'Cannot query arrearage',
			'electricityStatus.needMoreInfo' => 'Need to improve information on the payment platform',
			'electricityStatus.needAccount' => 'Need to input electricity account',
			'electricityStatus.captchaFailed' => 'Failed to check captcha',
			'electricityStatus.otherIssue' => 'Program malfunction',
			'emptyClassroom.title' => 'Empty Classrooms',
			'emptyClassroom.date' => ({required Object date}) => 'Date ${date}',
			'emptyClassroom.building' => ({required Object building}) => 'Building ${building}',
			'emptyClassroom.searchHint' => 'Classroom name or code',
			'emptyClassroom.classroom' => 'Classroom',
			'emptyClassroom.empty' => 'Available',
			'emptyClassroom.occupied' => 'Occupied',
			'exam.title' => 'Exam Schedule',
			'exam.cacheHint' => 'Displaying cached exam schedule info',
			'exam.cacheHintPasswordWrong' => 'IDS password is incorrect or expired.',
			'exam.cacheHintLoginFailed' => 'Failed to log in to the exam service.',
			'exam.cacheHintNetworkFailed' => 'Network request failed.',
			'exam.cacheHintUnknownError' => 'Failed to fetch the latest exam schedule. Check logs for details.',
			'exam.fetchingHint' => 'Fetching the latest exam schedule.',
			'exam.notFinished' => 'Still there are some bad guys here.',
			'exam.allFinished' => 'Say goodbye to all the exams.',
			'exam.unableToExam' => 'Unable to exam',
			'exam.finished' => 'All exams ',
			'exam.noneFinished' => 'No exams have been completed',
			'exam.noExamArrangement' => 'No exam has been arranged currently',
			'exam.noArrangement.title' => 'Not arranged exams',
			'exam.noArrangement.allArranged' => 'Exams have been scheduled for all subjects',
			'exam.noArrangement.subtitle' => ({required Object id}) => 'Code: ${id}',
			'experiment.title' => 'Experiment Info',
			'experiment.ongoing' => 'Ongoing experiment',
			'experiment.notFinished' => 'Experiments to be done',
			'experiment.allFinished' => 'All experiments have been completed',
			'experiment.finished' => 'Completed experiments',
			'experiment.scoreInfo' => ({required Object score}) => '${score} (predicted)',
			'experiment.scoreSum' => ({required Object sum}) => 'Total score: ${sum}',
			'experiment.noneFinished' => 'None of the experiments have been completed',
			'experiment.notProvided' => 'Not provided',
			'experiment.errorPhysics' => ({required Object info}) => 'Error on fetching physics experiments: ${info}',
			'experiment.errorOther' => ({required Object info}) => 'Error on fetching other experiments: ${info}',
			'experiment.cacheHint' => ({required Object info}) => 'Loaded cache: ${info}',
			'experiment.physicsCacheHintMissingPassword' => 'Physics experiment password is not set.',
			'experiment.physicsCacheHintLoginFailed' => 'Physics experiment login failed.',
			'experiment.physicsCacheHintNotSchoolNetwork' => 'Not on the campus network.',
			'experiment.physicsCacheHintNetworkFailed' => 'Physics experiment network request failed.',
			'experiment.physicsCacheHintUnknownError' => 'Failed to fetch physics experiments online. Check logs for details.',
			'experiment.otherCacheHintLoginFailed' => 'Other experiment login failed.',
			'experiment.otherCacheHintNotSchoolNetwork' => 'Not on the campus network.',
			'experiment.otherCacheHintNetworkFailed' => 'Other experiment network request failed.',
			'experiment.otherCacheHintUnknownError' => 'Failed to fetch other experiments online. Check logs for details.',
			'experiment.physicsExperiment' => 'physics experiments',
			'experiment.otherExperiment' => 'other experiments',
			'experiment.tapForScore' => 'Failed to detect the score',
			'experiment.yourScore' => 'Your Score: ',
			'experiment.predictScore' => ({required Object score}) => 'Predict score: ${score}',
			'experiment.sendMail' => 'Send',
			'experiment.fetchingHint' => 'The data you see is from cache. Updating is running in the background...',
			'experiment.fetchingHintBoth' => 'Physics experiments and other experiments are loading',
			'experiment.fetchingHintPhysics' => 'Physics experiments are loading',
			'experiment.fetchingHintOther' => 'Other experiments are loading',
			'experiment.fetchingHintPhysicsWithOtherFailed' => 'Physics experiments are loading, while other experiments failed to load',
			'experiment.fetchingHintOtherWithPhysicsFailed' => 'Other experiments are loading, while physics experiments failed to load',
			'experiment.scoreHint0' => 'You can tap on the score info on the score card to check out the original score data',
			'experiment.scoreHint1' => 'Your score is not in the XDYou score recognition database, so it was not recognized properly.',
			'experiment.scoreHint2' => 'If you wish to contribute to the development of XDYou, you can click the send email button, and we will add your score to the recognition database!',
			'experiment.scoreHint3' => 'Due to the lack of data for recognization, it is necessary to check twice.',
			'experimentController.noPassword' => 'Experiment password is not set, please set up one in the setting',
			'experimentController.loginFailed' => 'Login failed',
			'homepage.title' => 'School Info Center',
			'homepage.loading' => 'Loading',
			'homepage.loaded' => 'Message updated',
			'homepage.loadError' => 'Something wrong',
			'homepage.onHoliday' => 'Currently on holiday',
			'homepage.onWeekday' => ({required Object current}) => 'Currently week ${current}',
			'homepage.loadingMessage' => 'Refreshing information...',
			'homepage.postgraduateNotice' => 'Postgraduate features activated!',
			'homepage.linuxNotice' => 'Linux version is under testing, feel free to feedback!',
			'homepage.editMode' => 'Edit Layout',
			'homepage.editDone' => 'Done',
			'homepage.editReset' => 'Reset Layout',
			'homepage.editHint' => 'Schedule and update cards cannot be edited',
			'homepage.manageHidden' => 'Manage hidden cards',
			'homepage.hiddenTitle' => 'Hidden cards',
			'homepage.hiddenLabel' => 'Hidden',
			'homepage.hideEmpty' => 'No hidden cards',
			'homepage.homepage' => 'Info',
			'homepage.ruisi' => 'Forum',
			'homepage.club' => 'Club',
			'homepage.planet' => 'Blog',
			'homepage.dashboard' => 'Pighub',
			'homepage.setting' => 'Settings',
			'homepage.inputPartnerData.routeNotExist' => 'Import path does not exist:P',
			'homepage.inputPartnerData.failedGetFile' => 'Failed to import file',
			'homepage.inputPartnerData.failedImport' => 'Maybe there is a problem with the import file:P',
			'homepage.inputPartnerData.successMessage' => 'Import successful, if the class schedule page is open, please reopen it',
			'homepage.inputPartnerData.notLoaded' => 'Class schedule has not been loaded yet, please try again later...',
			'homepage.inputPartnerData.confirmContent' => 'There is currently partner class schedule data, do you want to overwrite?',
			'homepage.loginMessage' => 'Logging in, currently displaying cached data',
			'homepage.successfulLoginMessage' => 'Login successful',
			'homepage.passwordWrongTitle' => 'Wrong username or password',
			'homepage.passwordWrongContent' => 'Restart the app and log in manually?',
			'homepage.passwordWrongDenial' => 'No, enter offline mode',
			'homepage.offlineModeTitle' => 'Uniform Authentication Service offline mode activated',
			'homepage.offlineModeContent' => '"Unable to connect to the Unified Authentication Service server, all related services are temporarily unavailable.\nScore inquiry, exam information inquiry, overdue fee inquiry, campus card inquiry are closed. The schedule displays cached data. Other functions are temporarily not affected.\nWe apologize for any inconvenience caused."\n',
			'homepage.offlineMode' => 'In offline mode, all one-stop related functions are disabled',
			'homepage.noticeCard.emptyNotice' => 'No application announcements retrieved, please refresh',
			'homepage.noticeCard.noNoticeAvaliable' => 'Failed to fetch the application announcements',
			'homepage.noticeCard.noticeListTitle' => 'Notifications',
			'homepage.noticeCard.openUrl' => 'Open link',
			'homepage.noticeCard.noticePageTitle' => 'Notification List',
			'homepage.classTableCard.title' => 'Timetable',
			'homepage.classTableCard.today' => ({required Object remain}) => '${remain} arrangment(s) today',
			'homepage.classTableCard.todayFinished' => 'Arrangements all done today',
			'homepage.classTableCard.tomorrow' => ({required Object remain}) => '${remain} arrangment(s) tomorrow',
			'homepage.classTableCard.tomorrowNone' => 'No arrangement tomorrow',
			'homepage.classTableCard.weekInfo' => ({required Object weekinfo}) => 'Week ${weekinfo}',
			'homepage.classTableCard.onHoliday' => 'On vacation',
			'homepage.classTableCard.errorMessage' => ({required Object error}) => 'An error occurred: ${error}',
			'homepage.classTableCard.fetchingMessage' => 'Fetching class schedule',
			'homepage.classTableCard.errorInfoText' => 'An error occurred',
			'homepage.classTableCard.fetchingInfoText' => 'Loading',
			'homepage.classTableCard.noArrangementInfoText' => 'No schedule at the moment',
			'homepage.classTableCard.scheduleFetchingMessage' => 'Schedule is loading, please check again soon',
			'homepage.classTableCard.scheduleErrorMessage' => 'Failed to load schedule, please try again later',
			'homepage.classTableCard.scheduleFetchingInfoText' => 'Loading schedule',
			'homepage.classTableCard.scheduleErrorInfoText' => 'Failed to load schedule',
			'homepage.classTableCard.scheduleNoneInfoText' => 'No schedule available',
			'homepage.classTableCard.updatingInfoText' => 'Updating',
			'homepage.classTableCard.allLoadingInfoText' => 'All sources loading',
			'homepage.classTableCard.partialLoadingInfoText' => 'Partially loading',
			'homepage.classTableCard.partialErrorInfoText' => 'Some data failed to load',
			'homepage.classTableCard.failedChip' => ({required Object source}) => '${source} failed',
			'homepage.classTableCard.failedSourceClassInfo' => 'Class info',
			'homepage.classTableCard.failedSourceExamInfo' => 'Exam info',
			'homepage.classTableCard.failedSourcePhysicsExperiment' => 'Physics experiment',
			'homepage.classTableCard.failedSourceOtherExperiment' => 'Other experiment',
			'homepage.classTableCard.unknownPlace' => 'Unknown place',
			'homepage.classTableCard.seat' => ({required Object seatnum}) => 'Seat ${seatnum}',
			'homepage.electricityCard.title' => 'Electricity and Hydroenergy Information',
			'homepage.electricityCard.currentElectricity' => ({required Object amount}) => '${amount} kWh remains',
			'homepage.electricityCard.cacheNotice' => ({required Object date}) => 'Last fetch date: ${date}',
			'homepage.libraryCard.title' => 'Library Info',
			'homepage.libraryCard.currentBorrow' => ({required Object count}) => 'Borrowing ${count} book(s)',
			'homepage.libraryCard.errorOccured' => 'Error occurred while retrieving borrowing information',
			'homepage.libraryCard.fetching' => 'Fetching borrowing information',
			'homepage.libraryCard.noReturn' => 'Currently there\'s no book to be returned',
			'homepage.libraryCard.needReturn' => ({required Object dued}) => 'Need to return ${dued} books',
			'homepage.libraryCard.noInfo' => 'Cannot retrieve information at the moment',
			'homepage.libraryCard.fetchingInfo' => 'Fetching information...',
			'homepage.schoolCardInfoCard.errorToast' => 'An error occurred, please contact the developer',
			'homepage.schoolCardInfoCard.fetchingToast' => 'Fetching information, please check later',
			'homepage.schoolCardInfoCard.bill' => 'Bill',
			'homepage.schoolCardInfoCard.balance' => ({required Object amount}) => 'Remain ${amount} RMB',
			'homepage.schoolCardInfoCard.errorOccured' => 'Error occurred while retrieving campus card information',
			'homepage.schoolCardInfoCard.fetching' => 'Fetching campus card information',
			'homepage.schoolCardInfoCard.bottomTextSuccess' => 'Query campus card bill',
			'homepage.schoolCardInfoCard.noInfo' => 'Cannot retrieve information currently',
			'homepage.schoolCardInfoCard.fetchingInfo' => 'Fetching information...',
			'homepage.toolbox.classAttendance' => 'Attendances',
			'homepage.toolbox.creative' => 'Innovation and Entrepreneurship Competition',
			'homepage.toolbox.emptyClassroom' => 'Classrooms',
			'homepage.toolbox.exam' => 'Exams',
			'homepage.toolbox.experiment' => 'Experiments',
			'homepage.toolbox.score' => 'Grades',
			'homepage.toolbox.sport' => 'PE Info',
			'homepage.toolbox.dormWater' => 'Dorm Water',
			'homepage.toolbox.schoolnet' => 'Schoolnet Usage',
			'homepage.toolbox.toolbox' => 'Others',
			'homepage.toolbox.scoreCannotReach' => 'Offline mode with no cached score data, unable to access',
			'homepage.toolbox.examFetching' => 'Fetching exam information, please wait',
			'homepage.toolbox.examError' => 'An error occurred, please contact the developer',
			'homepage.schoolNet.title' => ({required Object usage}) => 'Used ${usage}',
			'homepage.schoolNet.noPassword' => 'The query password is not set, click to set up',
			'homepage.schoolNet.failed' => 'Failed to get the school net usage info',
			'homepage.schoolNet.fetching' => 'Fetching the school net usage info',
			'homepage.schoolNet.remaining' => ({required Object remaining}) => 'Clearing at ${remaining}',
			'homepage.clubPromotion.failed' => 'Failed to fetch club info',
			'homepage.clubPromotion.fetching' => 'Fetching club info',
			'library.title' => 'Library Information',
			'library.borrowStateTitle' => 'Borrowing Status',
			'library.searchBookTitle' => 'Search Books',
			'library.searchFieldTitle' => 'Search Field',
			'library.searchFieldKeywordOption' => 'Any',
			'library.searchFieldTitleOption' => 'Title',
			_ => null,
		} ?? switch (path) {
			'library.searchFieldAuthorOption' => 'Author',
			'library.searchFieldIsbnOption' => 'ISBN',
			'library.searchFieldBarcodeOption' => 'Bar Code',
			'library.searchFieldCallnoOption' => 'Call No',
			'library.notProvided' => 'No information provided',
			'library.author' => 'Author ',
			'library.publishHouse' => 'Publisher ',
			'library.callNumber' => 'Call Number ',
			'library.publishDate' => 'Publication Date',
			'library.isbn' => 'ISBN',
			'library.arrangementCode' => 'Arrangement Code ',
			'library.avaliableBorrow' => 'Available to borrow',
			'library.storage' => 'Storage',
			'library.onShelve' => 'On shelf',
			'library.bookCode' => ({required Object bar_code}) => 'Book code: ${bar_code}',
			'library.dueDate' => ' Due date',
			'library.borrowStr' => ' Borrow',
			'library.afterDueDate' => ' day(s) overdue',
			'library.beforeDueDate' => ' day(s) left',
			'library.canBeRenewable' => 'Renewable',
			'library.cannotBeRenewable' => 'Not renewable',
			'library.renewing' => 'Renewing',
			'library.emptyBorrowList' => 'No borrowed books found',
			'library.borrowListInfo' => ({required Object borrow, required Object dued}) => 'Borrowing ${borrow} book(s), among which ${dued} book(s) have expired',
			'library.searchBookWindow' => '',
			'library.searchHere' => 'Search here',
			'library.normalSearch' => 'Normal Search',
			'library.advancedSearch' => 'Advanced Search',
			'library.search' => 'Search',
			'library.matchMode' => 'Match Mode',
			'library.matchExact' => 'Exact',
			'library.matchFuzzy' => 'Fuzzy',
			'library.matchPrefix' => 'Prefix',
			'library.documentType' => 'Document Type',
			'library.documentTypeAll' => 'All',
			'library.documentTypeBook' => 'Book',
			'library.onlyOnShelf' => 'Only on shelf',
			'library.publishYearBegin' => 'Publish year from',
			'library.publishYearEnd' => 'Publish year to',
			'library.bookDetail' => 'Book details',
			'library.noResult' => 'No result, change parameter or start your search',
			'libraryCard.title' => 'Library status',
			'libraryCard.fetching' => 'Fetching',
			'libraryCard.northernLibrary' => 'Northern Library',
			'libraryCard.southernLibrary' => 'Southern Library',
			'libraryCard.people' => ({required Object people}) => 'People: ${people}',
			'libraryCard.seat' => ({required Object seat}) => 'Seats: ${seat}',
			'login.identityNumber' => 'Student ID',
			'login.password' => 'IDS Login password',
			'login.login' => 'Login',
			'login.incorrectPasswordPattern' => 'Username or password does not meet requirements, student ID must be 11 digits and password cannot be empty',
			'login.onLoginProgress' => 'Logging in...',
			'login.completeLogin' => 'Login successful',
			'login.failedLoginCannotConnectToServer' => 'Cannot connect to server',
			'login.failedLoginWithCode' => ({required Object code}) => 'Request failed, response status code: ${code}',
			'login.failedLoginWithMessage' => ({required Object message}) => 'Request failed, error message: ${message}',
			'login.failedLoginOther' => 'Unknown error, please contact the developer',
			'login.clearCache' => 'Clear cache',
			'login.completeClearCache' => 'Cache cleared successfully',
			'login.seeInspector' => 'View network interaction',
			'login.captchaWindow.title' => 'Please enter captcha',
			'login.captchaWindow.hint' => 'Input captcha',
			'login.captchaWindow.messageOnEmpty' => 'Please enter captcha',
			'login.captchaWindow.refreshFailed' => ({required Object error}) => 'Failed to refresh captcha: ${error}',
			'login.sliderTitle' => 'Server authentication service',
			'loginProcess.readyPage' => 'Prepare to obtain login environment',
			'loginProcess.getEncrypt' => 'Obtain password encryption key',
			'loginProcess.readyLogin' => 'Prepare to login',
			'loginProcess.slider' => 'Logging in',
			'loginProcess.afterProcess' => 'Post-login processing',
			'loginProcess.failed' => ({required Object status_code}) => 'Login failed, response status code: ${status_code}',
			'month.january' => 'Jan.',
			'month.february' => 'Feb.',
			'month.march' => 'Mar.',
			'month.april' => 'Apr.',
			'month.may' => 'May',
			'month.june' => 'Jun.',
			'month.july' => 'Jul.',
			'month.august' => 'Aug.',
			'month.september' => 'Sept.',
			'month.october' => 'Oct.',
			'month.november' => 'Nov.',
			'month.december' => 'Dec.',
			'restartApp.titleCacheCleared' => 'Cache Cleared',
			'restartApp.titleLoggedOut' => 'Logged Out',
			'restartApp.titlePasswordWrong' => 'Wrong Password',
			'restartApp.content' => 'Tap to reopen the app',
			'ruisi.common.refresh' => 'Refresh',
			'ruisi.common.confirm' => 'OK',
			'ruisi.common.cancel' => 'Cancel',
			'ruisi.common.retry' => 'Retry',
			'ruisi.common.noTopics' => 'No topics',
			'ruisi.common.noContent' => 'No content',
			'ruisi.common.reply' => 'Reply',
			'ruisi.common.favorite' => 'Favorite',
			'ruisi.common.notImplemented' => 'Not implemented',
			'ruisi.common.login' => 'Login',
			'ruisi.common.logout' => 'Log out',
			'ruisi.common.loggedOut' => 'Logged out',
			'ruisi.common.submit' => 'Submit',
			'ruisi.about.title' => 'About',
			'ruisi.about.appName' => 'Ruisi',
			'ruisi.about.subtitle' => 'Xidian University Campus Forum Client',
			'ruisi.about.version' => 'Version',
			'ruisi.about.versionNumber' => '2.0.0 (Bundled with XDYou 1.6.0)',
			'ruisi.about.sourceCode' => 'Source Code',
			'ruisi.about.bugReport' => 'Report Issue',
			'ruisi.about.bugReportSubtitle' => 'Submit an issue on GitHub',
			'ruisi.about.privacyPolicy' => 'Privacy Policy',
			'ruisi.about.license' => 'Open-sourced under the BSD-3-Clause License Reimplemented based on Ruisi-iOS and Ruisi-Android with AI assistant',
			'ruisi.about.privacyPolicyContent' => 'This app only operates on the Xidian University campus network, accessing data from the Ruisi Forum (rs.xidian.edu.cn).\n\nThis app does not collect, store, or transmit any personal information to third-party servers.\n\nUser login credentials are stored only on the local device, used for authentication with the Ruisi Forum server.\n\nThis app uses cookies to communicate with the Ruisi Forum server. All data exchange occurs directly between the user\'s device and the Ruisi Forum server.\n\nIf you have any questions, please contact the developer by submitting an issue on GitHub.',
			'ruisi.home.title' => 'Ruisi Forum',
			'ruisi.home.newPost' => 'New Post',
			'ruisi.home.forumList' => 'Forum List',
			'ruisi.home.tabHot' => 'Hot',
			'ruisi.home.tabNewReply' => 'Latest Replies',
			'ruisi.home.tabNewPost' => 'Latest Posts',
			'ruisi.home.tabMy' => 'Me',
			'ruisi.home.tabTrade' => 'Trading',
			'ruisi.home.tabWater' => 'Water Bar',
			'ruisi.home.tabLostFound' => 'Lost & Found',
			'ruisi.home.tabEmployment' => 'Employment',
			'ruisi.home.tabPhotography' => 'Photography',
			'ruisi.home.pleaseLogin' => 'Please log in first',
			'ruisi.home.myProfile' => 'My Profile',
			'ruisi.home.myPosts' => 'My Posts',
			'ruisi.home.myFavorites' => 'My Favorites',
			'ruisi.home.messageCenter' => 'Messages',
			'ruisi.home.dailyCheckin' => 'Daily Check-in',
			'ruisi.home.settings' => 'Settings',
			'ruisi.home.about' => 'About',
			'ruisi.home.search' => 'Search',
			'ruisi.login.title' => 'Login to Ruisi',
			'ruisi.login.username' => 'Username',
			'ruisi.login.usernameHint' => 'Please enter username',
			'ruisi.login.password' => 'Password',
			'ruisi.login.passwordHint' => 'Please enter password',
			'ruisi.login.captcha' => 'Captcha',
			'ruisi.login.captchaHint' => 'Please enter captcha',
			'ruisi.login.back' => 'Back',
			'ruisi.login.resetLoginState' => 'Reset Login State',
			'ruisi.login.resetConfirmTitle' => 'Confirm Reset',
			'ruisi.login.resetConfirmContent' => 'Are you sure you want to reset the login state? This will clear all login information.',
			'ruisi.login.resetSuccess' => 'Login state has been reset',
			'ruisi.login.viewLogs' => 'View Logs',
			'ruisi.post.title' => 'New Post',
			'ruisi.post.publish' => 'Publish',
			'ruisi.post.selectForum' => 'Select Forum',
			'ruisi.post.selectForumHint' => 'Please select a forum',
			'ruisi.post.subject' => 'Title',
			'ruisi.post.subjectHint' => 'Please enter a title',
			'ruisi.post.content' => 'Content',
			'ruisi.post.contentHint' => 'Please enter content',
			'ruisi.post.success' => 'Post published',
			'ruisi.post.failure' => 'Failed to publish',
			'ruisi.post.smiley' => 'Smileys',
			'ruisi.topicDetail.title' => 'Topic Detail',
			'ruisi.topicDetail.replyTooShort' => 'Reply must be at least 13 characters',
			'ruisi.topicDetail.replySuccess' => 'Reply sent',
			'ruisi.topicDetail.replyFailure' => 'Failed to reply',
			'ruisi.topicDetail.favoriteSuccess' => 'Added to favorites',
			'ruisi.topicDetail.favoriteFailure' => 'Failed to add to favorites',
			'ruisi.topicDetail.noData' => 'No data',
			'ruisi.topicDetail.replyHint' => 'Write a reply...',
			'ruisi.topicDetail.vote.singleSelect' => 'Single choice',
			'ruisi.topicDetail.vote.multiSelect' => ({required Object count}) => 'Multiple choice, up to ${count}',
			'ruisi.topicDetail.vote.titlePrefix' => 'Vote',
			'ruisi.topicDetail.vote.count' => ({required Object count}) => '${count} people voted',
			'ruisi.topicDetail.vote.open' => 'Vote',
			'ruisi.topicDetail.vote.sheetTitle' => 'Vote',
			'ruisi.topicDetail.vote.maxSelection' => ({required Object count}) => 'You can select up to ${count}',
			'ruisi.topicDetail.vote.notSelected' => 'Please select an option',
			'ruisi.topicDetail.vote.success' => 'Vote submitted',
			'ruisi.topicDetail.vote.failure' => 'Vote failed',
			'ruisi.topicDetail.vote.paramError' => 'Vote failed: invalid parameters',
			'ruisi.topicDetail.vote.alreadyVoted' => 'You have already voted. Thank you!',
			'ruisi.topicDetail.vote.expired' => 'This poll has expired or been closed',
			'ruisi.topicDetail.vote.ended' => 'This poll has ended',
			'ruisi.topicListItem.sticky' => 'Pinned',
			'ruisi.forumList.title' => 'Forum List',
			'ruisi.forumList.empty' => 'Ruisi Forum section grouping is empty',
			'ruisi.favorites.title' => 'My Favorites',
			'ruisi.favorites.empty' => 'No favorites',
			'ruisi.messages.title' => 'Messages',
			'ruisi.messages.tabAt' => '@Me',
			'ruisi.messages.noReply' => 'No reply notifications',
			'ruisi.messages.noAt' => 'No @ notifications',
			'ruisi.search.hint' => 'Search topics...',
			'ruisi.search.inputHint' => 'Enter keywords to search',
			'ruisi.search.noResults' => 'No results',
			'ruisi.settings.title' => 'Settings',
			'ruisi.settings.sectionProxy' => 'Proxy',
			'ruisi.settings.proxyEnable' => 'Enable Proxy',
			'ruisi.settings.proxyDisabled' => 'Disabled',
			'ruisi.settings.proxyAddress' => 'Proxy Address',
			'ruisi.settings.sectionDebug' => 'Debug',
			'ruisi.settings.viewLogs' => 'View Logs',
			'ruisi.settings.proxyDialogTitle' => 'Proxy Settings',
			'ruisi.settings.proxyHost' => 'Host',
			'ruisi.settings.proxyHostHint' => 'e.g. 127.0.0.1',
			'ruisi.settings.proxyPort' => 'Port',
			'ruisi.settings.proxyPortHint' => 'e.g. 7890',
			'ruisi.user.title' => 'Me',
			'ruisi.user.tabProfile' => 'Profile',
			'ruisi.user.unknown' => 'Unknown User',
			'schoolCardStatus.failedToFetch' => 'Failed fetching',
			'schoolCardStatus.failedToQuery' => 'Failed querying',
			'schoolCardWindow.title' => 'Campus Card Transaction History',
			'schoolCardWindow.income' => ({required Object income}) => 'Income ￥${income}',
			'schoolCardWindow.expense' => ({required Object expense}) => 'Expense ￥${expense}',
			'schoolCardWindow.selectRange' => ({required Object start_day, required Object end_day}) => 'Select date: from ${start_day} to ${end_day}',
			'schoolCardWindow.storeName' => 'Expense place',
			'schoolCardWindow.balance' => 'Amount',
			'schoolCardWindow.timeWithSum' => ({required Object sum}) => 'Time (${sum})',
			'schoolCardWindow.noRecord' => 'No records found, please try again with different dates',
			'schoolCardWindow.qrCode' => 'Payment Code',
			'schoolCardWindow.qrCodeError' => ({required Object info}) => 'Get QR Code failed: ${info}',
			'schoolCardWindow.reload' => 'Reload',
			'schoolNet.title' => 'School Net Usage Query',
			'schoolNet.idsAccountNet.title' => 'Current user',
			'schoolNet.idsAccountNet.notice' => 'This is the current PDA user\'s information.\nNotice that network traffic is charged in GB (1GB = 1000MB).\nIf you cannot see any info, go to zfw.xidian.edu.cn for password reset',
			'schoolNet.idsAccountNet.overview' => 'Overview',
			'schoolNet.idsAccountNet.account' => 'Account',
			'schoolNet.idsAccountNet.used' => 'Data usage',
			'schoolNet.idsAccountNet.remain' => 'Balance',
			'schoolNet.idsAccountNet.currentOnline' => ({required Object length}) => 'Online devices (currently ${length})',
			'schoolNet.idsAccountNet.noDeviceOnline' => 'No device is online at the moment',
			'schoolNet.currentLoginNet.title' => 'Current using',
			'schoolNet.currentLoginNet.notice' => 'This is the information of the current using account.\nIt may be different from the current user\'s, and DON\'T BE EVIL!\nNotice that network traffic is charged in GB (1GB=1000MB).',
			'schoolNet.currentLoginNet.overview' => 'Overview of the account',
			'schoolNet.currentLoginNet.account' => 'Account',
			'schoolNet.currentLoginNet.planType' => 'Type of the plan',
			'schoolNet.currentLoginNet.remain' => 'Balance',
			'schoolNet.currentLoginNet.usageSituation' => 'Traffic usage info',
			'schoolNet.currentLoginNet.usedPercent' => ({required Object percent}) => 'Used ${percent}%',
			'schoolNet.currentLoginNet.used' => 'Data usage',
			'schoolNet.currentLoginNet.remainCount' => 'Data remaining',
			'schoolNet.currentLoginNet.total' => 'Total data',
			'schoolNet.currentLoginNet.nonSchoolnet' => 'Not in school net environment',
			'schoolNet.deviceList.ip' => 'Device IP',
			'schoolNet.deviceList.time' => 'Online time',
			'schoolNet.deviceList.remain' => 'Traffic used',
			'schoolNet.fetching' => 'Fetching schoolnet usage data',
			'schoolNet.emptyPassword' => 'You may forgot to enter the schoolnet password',
			'schoolNet.notInitalized' => 'It seems the backend is not open for query:P',
			'schoolNet.captchaFailed' => 'Failed to idenify captcha',
			'schoolNet.captchaEmpty' => 'Captcha is empty',
			'schoolNet.cacheHintCaptchaFailed' => 'Captcha recognition failed. Please try again.',
			'schoolNet.cacheHintRequestFailed' => 'The schoolnet request failed. Please try again later.',
			'schoolNet.wrongPassword' => 'Wrong schoolnet password',
			'schoolNet.errorFetch' => ({required Object msg}) => 'Failed to fetch：${msg}',
			'schoolNet.errorOther' => ({required Object msg}) => 'Other error：${msg}',
			'schoolNet.refresh' => 'Refresh',
			'score.cacheMessage' => 'Cached score information is displayed',
			'score.summary' => ({required Object chosen, required Object credit, required Object avg, required Object gpa}) => 'Selected subjects ${chosen}  Total credits ${credit}\nAverage ${avg} GPA ${gpa}',
			'score.allPassed' => 'All subjects have passed',
			'score.cacheHintPasswordWrong' => 'IDS password is incorrect or expired.',
			'score.cacheHintLoginFailed' => 'Failed to log in to the score service.',
			'score.cacheHintNetworkFailed' => 'Network request failed.',
			'score.cacheHintUnknownError' => 'Failed to fetch the latest score info. Check logs for details.',
			'score.fetchingHint' => 'Fetching the latest score info.',
			'score.allSemester' => 'All semesters',
			'score.chosenSemester' => ({required Object chosen}) => '${chosen}',
			'score.allType' => 'All types',
			'score.chosenType' => ({required Object type}) => '${type}',
			'score.none' => 'None',
			'score.scoreChoice.title' => 'Transcript',
			'score.scoreChoice.searchHint' => 'Search for score records',
			'score.scoreChoice.emptyList' => 'No courses from this semester is selected to be calculated',
			'score.scoreChoice.sumDialogTitle' => 'Summary',
			'score.scoreChoice.sumDialogContent' => ({required Object gpa_all, required Object avg_all, required Object credit_all, required Object unpassed, required Object not_core_type}) => 'Overall GPA of all subjects：${gpa_all}\nOverall average：${avg_all}\nTotal credits：${credit_all}\nUnpassed subjects：${unpassed}\nPublic selective：${not_core_type}\nThe data provided by this program is for reference only, and the developer is not responsible for its accuracy',
			'score.scoreComposeCard.noDetail' => 'No detailed information provided',
			'score.scoreComposeCard.fetching' => 'Fetching...',
			'score.scoreComposeCard.credit' => 'Credits',
			'score.scoreComposeCard.gpa' => 'GPA',
			'score.scoreComposeCard.score' => 'Score',
			'score.scoreInfoCard.title' => 'Score Details',
			'score.scoreInfoCard.originalCourse' => 'Initial course',
			'score.scoreInfoCard.failed' => '[Failed]',
			'score.scoreInfoCard.credit' => ({required Object credit}) => 'Credits ${credit}',
			'score.scoreInfoCard.gpa' => ({required Object gpa}) => 'GPA ${gpa}',
			'score.scoreInfoCard.score' => ({required Object score}) => 'Score ${score}',
			'score.scorePage.title' => 'Score Query',
			'score.scorePage.searchHint' => 'Search for score records',
			'score.scorePage.noRecord' => 'No relevant information found',
			'score.scorePage.selectAll' => 'Select all',
			'score.scorePage.selectNothing' => 'Clear',
			'score.scorePage.resetSelect' => 'Reset',
			'score.scorePage.summary' => 'Summary',
			'score.scorePage.cet4' => 'College English Test Band 4',
			'score.scorePage.cet6' => 'College English Test Band 6',
			'setting.acknowledgement' => ({required Object developers}) => 'Made With Love From ${developers} People',
			'setting.about' => 'About',
			'setting.aboutThisProgram' => 'About this APP',
			'setting.version' => ({required Object version}) => 'Version：${version}',
			'setting.userInfo' => 'User information',
			'setting.checkUpdate' => 'Check for updates',
			'setting.latestVersion' => ({required Object latest}) => 'Latest version: ${latest}',
			'setting.waiting' => 'Waiting for obtain',
			'setting.fetchingUpdate' => 'Fetching update information',
			'setting.newVersion' => 'New version released!',
			'setting.currentStable' => 'You are running the latest version',
			'setting.currentTesting' => 'You are running the testing version',
			'setting.fetchFailed' => 'Failed to fetch update information',
			'setting.uiSetting' => 'UI Settings',
			'setting.brightnessSetting' => 'Light/Dark mode',
			'setting.colorSetting' => 'Color theme',
			'setting.simplifyTimeline' => 'Simplify schedule timeline',
			'setting.simplifyTimelineDescription' => 'Reduce space occupation while no schedule',
			'setting.lowElectricityWarning' => 'Low electricity card color warning',
			'setting.lowElectricityWarningDescription' => 'Change the homepage electricity card color when remaining electricity is below the threshold',
			'setting.lowElectricityThreshold' => 'Low electricity threshold',
			'setting.lowElectricityThresholdDescription' => ({required Object threshold}) => 'Current: ${threshold} kWh',
			'setting.lowElectricityThresholdDialog.title' => 'Set low electricity threshold',
			'setting.lowElectricityThresholdDialog.inputHint' => 'Input remaining electricity',
			'setting.accountSetting' => 'Account Settings',
			'setting.sportPasswordSetting' => 'PE system password',
			'setting.experimentPasswordSetting' => 'Physics experiment password',
			'setting.electricityPasswordSetting' => 'Electricity account password',
			'setting.electricityPasswordDescription' => 'Please set if not default',
			'setting.electricityAccountSetting' => 'Electricity account setting',
			'setting.schoolnetPasswordSetting' => 'Campus net password',
			'setting.schoolnetPasswordDescription' => 'If you have not setted it, you cannot query it.',
			'setting.airconImeiTitle' => 'Aircon electricity data source',
			'setting.airconImei' => 'Aircon IMEI',
			'setting.airconImeiNotSet' => 'Not set. Aircon electricity will be hidden on the power page.',
			'setting.airconImeiCurrent' => ({required Object imei}) => 'Current IMEI: ${imei}',
			'setting.airconImeiSaved' => 'Aircon IMEI saved',
			'setting.airconImeiCleared' => 'Aircon IMEI cleared',
			'setting.airconImeiInvalid' => 'No valid 15-digit IMEI found',
			'setting.airconImeiClear' => 'Clear',
			'setting.scanAirconQr' => 'Scan aircon QR code',
			'setting.pickAirconQrImage' => 'Choose QR image',
			'setting.airconCameraUnavailable' => 'Camera scanning is unavailable on this platform. Choose a QR image or enter the IMEI manually.',
			'setting.notificationSetting' => 'Notification Settings',
			'setting.courseReminderSetting' => 'Pre-class Reminder Settings',
			'setting.courseReminderDescription' => 'Configure pre-class reminder notifications',
			'setting.notificationPage.title' => 'Pre-class Reminder Settings',
			'setting.notificationPage.loadFailed' => ({required Object error}) => 'Failed to load settings: ${error}',
			'setting.notificationPage.functionSection' => 'Notification Function',
			'setting.notificationPage.enableNotification' => 'Enable Pre-class Reminders',
			'setting.notificationPage.notificationScheduled' => ({required Object count}) => '${count} notifications scheduled',
			'setting.notificationPage.notificationDisabledHint' => 'All scheduled notifications will be cancelled when disabled',
			'setting.notificationPage.updateSchedule' => 'Update Notification Schedule',
			'setting.notificationPage.updateScheduleHint' => 'Reschedule notifications based on the latest course data',
			'setting.notificationPage.deleteAllSchedule' => 'Delete All Scheduled Reminder',
			'setting.notificationPage.deleteAllScheduleHint' => 'This action will delete all scheduled events, but you can click \'Update Notification Schedule\' again to re-add them.',
			'setting.notificationPage.deleteAllSuccess' => 'Delete successfully',
			'setting.notificationPage.viewTheInstructions' => 'View the instructions',
			'setting.notificationPage.viewTheInstructionsHint' => 'Check more instructions to ensure that you can see the notifications sent by the program',
			'setting.notificationPage.permissionSection' => 'Permission Status',
			'setting.notificationPage.notificationPermission' => 'Notification Permission',
			'setting.notificationPage.exactAlarmPermission' => 'Exact Alarm Permission',
			'setting.notificationPage.permissionGranted' => 'Granted',
			'setting.notificationPage.permissionDenied' => 'Denied',
			'setting.notificationPage.requestPermission' => 'Request Permission',
			'setting.notificationPage.systemSettings' => 'System Notification Settings',
			'setting.notificationPage.systemSettingsHint' => 'Open system settings to check notification configuration',
			'setting.notificationPage.permissionGrantedMsg' => 'Permission granted',
			'setting.notificationPage.permissionDeniedMsg' => 'Permission denied, please enable it in system settings',
			'setting.notificationPage.reminderSection' => 'Reminder Settings',
			'setting.notificationPage.experimentReminder' => 'Include the physics experiments',
			'setting.notificationPage.experimentReminderHint' => 'Enable this option to add the physics experiment to the Pre-class Reminder',
			'setting.notificationPage.minutesBefore' => 'Advance Reminder Time',
			'setting.notificationPage.minutesBeforeHint' => 'The time setting for pre-class reminders',
			'setting.notificationPage.minutesUnit' => 'minutes',
			'setting.notificationPage.daysToSchedule' => 'Schedule Duration',
			'setting.notificationPage.daysToScheduleHint' => 'This program writes course information into the planned schedule in advance. This setting can adjust the number of days for writing into the planned schedule',
			'setting.notificationPage.daysUnit' => 'days',
			'setting.notificationPage.settingsGuideTitle' => 'Notification Settings Guide',
			'setting.notificationPage.settingsGuideContent1' => 'To ensure you receive pre-class reminders in time, please make sure:\n1. App notification permission is enabled\n2. Notification sound is enabled\n3. Banner notifications are enabled\n4. Non-native Android users, enable auto-start and disable power optimization',
			'setting.notificationPage.settingsGuideContent2' => 'Pre-class Reminder Module Operating Mechanism:\n1. When first activated, it will automatically schedule pre-class reminders for the upcoming days\n2. Each time the app is opened, it will automatically check and update the notification schedule\n3. After modifying settings, it will automatically reschedule all notifications',
			'setting.notificationPage.gotIt' => 'Got it',
			'setting.notificationPage.openSettings' => 'Open System Settings',
			'setting.notificationPage.noClasstableData' => 'Please fetch course schedule, exam, or experiment data first',
			'setting.notificationPage.scheduleSuccess' => ({required Object count}) => 'Scheduled ${count} pre-class reminders',
			'setting.notificationPage.scheduleFailed' => ({required Object error}) => 'Failed to schedule notifications: ${error}',
			'setting.notificationPage.cancelAllSuccess' => 'All pre-class reminders cancelled',
			'setting.notificationPage.rescheduleSuccess' => ({required Object count}) => 'Rescheduled ${count} pre-class reminders',
			'setting.notificationPage.rescheduleFailed' => ({required Object error}) => 'Failed to reschedule notifications: ${error}',
			'setting.notificationDebugPage' => 'Notification Services Debug Page',
			'setting.classtableSetting' => 'Class Schedule Related',
			'setting.background' => 'Background image',
			'setting.noBackground' => 'You need to select an image first, it\'s at below',
			'setting.chooseBackground' => 'Choose background image',
			'setting.noPermission' => 'No storage permission obtained, cannot read files',
			'setting.successfulSetting' => 'Successfully set',
			'setting.failureSetting' => 'You did not select an image',
			'setting.clearUserClass' => 'Clear all customized courses',
			'setting.clearUserClassTitle' => 'Clear Confirmation',
			'setting.clearUserClassContent' => 'Do you want to clear all user-added courses? This function does not affect the schedule obtained from the school.',
			'setting.clearUserClassClear' => 'Already cleared',
			'setting.classRefresh' => 'Force refresh class schedule',
			'setting.classRefreshTitle' => 'Refresh Confirmation',
			'setting.classRefreshContent' => 'Do you want to force refreshing the class schedule? If you agree, we will fetch the schedule from the school, which may takes a long time.',
			'setting.classSwift' => 'Class schedule offset setting',
			'setting.classSwiftDescription' => ({required Object swift}) => 'Positive number delays the start date, negative number advances the start date\nCurrently ${swift}\n',
			'setting.coreSetting' => 'Cached login settings',
			'setting.checkLogger' => 'View network interceptor and logs',
			'setting.clearAndRestart' => 'Clear cache and restart',
			'setting.clearAndRestartDialog.title' => 'Restart confirmation',
			'setting.clearAndRestartDialog.content' => 'Are you sure to clear cache and restart the program?',
			'setting.clearAndRestartDialog.cleaning' => 'Clearing cache...',
			'setting.clearAndRestartDialog.clear' => 'Cache has been cleared',
			'setting.logout' => 'Log out and restart the app',
			'setting.logoutDialog.title' => 'Logout confirmation',
			'setting.logoutDialog.content' => 'Are you want to log out? All your data will be completely deleted!',
			'setting.logoutDialog.loggingOut' => 'Logging out...',
			'setting.needCloseDialog.title' => 'Crashed',
			'setting.needCloseDialog.content' => 'Due to technical limitations, you need to close the window manually and then reopen the app.',
			'setting.changeColorDialog.title' => 'Color setting',
			'setting.changeColorDialog.kDefault' => 'Default',
			'setting.changeColorDialog.blue' => 'Sky Blue',
			'setting.changeColorDialog.deepPurple' => 'Deep Purple',
			'setting.changeColorDialog.green' => 'Spring Green',
			'setting.changeColorDialog.orange' => 'Asuka Orange',
			'setting.changeColorDialog.pink' => 'Sakura Pink',
			'setting.changeBrightnessDialog.title' => 'Brightness settings',
			'setting.changeBrightnessDialog.followSetting' => 'Follow system',
			'setting.changeBrightnessDialog.dayMode' => 'Day mode',
			'setting.changeBrightnessDialog.nightMode' => 'Night mode',
			'setting.changeSwiftDialog.title' => 'Class schedule offset setting',
			'setting.changeSwiftDialog.inputHint' => 'Please input number here',
			'setting.changeElectricityTitle' => 'Modify electricity account',
			'setting.changeElectricityAccount.title' => 'Modify electricity account',
			'setting.changeElectricityAccount.campus' => 'Campus',
			'setting.changeElectricityAccount.northCampus' => 'Northern Campus',
			'setting.changeElectricityAccount.southCampus' => 'Southern Campus',
			'setting.changeElectricityAccount.unitOrZone' => 'Unit  / Zone',
			'setting.changeElectricityAccount.unitCode' => 'Unit',
			'setting.changeElectricityAccount.zoneCode' => 'Zone',
			'setting.changeElectricityAccount.pleaseInput' => ({required Object unit_or_zone_code}) => 'Please input ${unit_or_zone_code}',
			'setting.changeElectricityAccount.successfulFetch' => ({required Object account_number}) => 'Successful fetching account: ${account_number}',
			'setting.changeElectricityAccount.failedFetch' => ({required Object e}) => 'Failed to fetch: ${e}',
			'setting.changeElectricityAccount.accountSaved' => ({required Object account_number}) => 'Account saved：${account_number}',
			'setting.changeElectricityAccount.unknownCodingPattern' => 'Unknown coding pattern',
			'setting.changeElectricityAccount.selectBuilding' => 'Select Building',
			'setting.changeElectricityAccount.building' => 'Building',
			'setting.changeElectricityAccount.northernBuilding' => 'Northern Building',
			'setting.changeElectricityAccount.southernBuilding' => 'Southern Building',
			'setting.changeElectricityAccount.failedGenerate' => ({required Object e}) => 'Failed to generate: ${e}',
			'setting.changeElectricityAccount.buildingNumber' => 'Building number',
			'setting.changeElectricityAccount.buildingNumberHint' => 'eg: 16, 7, 55',
			'setting.changeElectricityAccount.buildingNumberQuery' => 'Please input building No.',
			'setting.changeElectricityAccount.yard' => 'Yard',
			'setting.changeElectricityAccount.yardHint' => 'Select Yard',
			'setting.changeElectricityAccount.northYard' => 'North Yard',
			'setting.changeElectricityAccount.southYard' => 'South Yard',
			'setting.changeElectricityAccount.yardQuery' => 'Please select yard',
			'setting.changeElectricityAccount.apartment' => 'Apartment',
			'setting.changeElectricityAccount.apartmentHint' => 'Select Apartment',
			'setting.changeElectricityAccount.northApartment' => 'North Apartment',
			'setting.changeElectricityAccount.southApartment' => 'South Apartment',
			'setting.changeElectricityAccount.apartmentQuery' => 'Please select apartment',
			'setting.changeElectricityAccount.levelCode' => 'Floor number',
			'setting.changeElectricityAccount.levelCodeQuery' => 'Floor number',
			'setting.changeElectricityAccount.roomCode' => 'Room code',
			'setting.changeElectricityAccount.roomCodeHint' => 'eg: 304, 508',
			'setting.changeElectricityAccount.roomCodeQuery' => 'Please input room code',
			'setting.changeElectricityAccount.account' => 'Electricity Account',
			'setting.changeElectricityAccount.accountHint' => 'Please enter your account',
			'setting.changeElectricityAccount.accountQuery' => 'Please input your account',
			'setting.changeElectricityAccount.accountLength' => 'Account length is larger than 10',
			'setting.changeElectricityAccount.fetching' => 'Fetching...',
			'setting.changeElectricityAccount.fetchFromInternet' => 'Sync from backend',
			'setting.changeElectricityAccount.saveAccount' => 'Save account',
			'setting.changeElectricityAccount.confirmSaving' => 'Confirm account',
			'setting.changeElectricityAccount.calculateAccount' => 'Calculate account',
			'setting.changeElectricityAccount.calculate' => 'Calculate',
			'setting.changeElectricityAccount.input' => 'Input',
			'setting.changeElectricityAccount.confirmAccount' => 'Confirm your account: ',
			'setting.changeElectricityAccount.change' => 'Edit',
			'setting.changeElectricityAccount.cancel' => 'Cancel',
			'setting.changeElectricityAccount.noSetting' => 'No new electricity account set',
			'setting.changeElectricityAccount.successfulSetting' => 'Successfully setting new electricity account',
			'setting.changeExperimentTitle' => 'Modify physics experiment account password',
			'setting.changeSportTitle' => 'Modify sports system account password',
			'setting.changePasswordDialog.inputHint' => 'Please input password here',
			'setting.changePasswordDialog.blankInput' => 'Blank input!',
			'setting.changeSchoolnetPasswordTitle' => 'Modify the schoolnet query password',
			'setting.updateDialog.newVersion' => 'New version available',
			'setting.updateDialog.notNow' => 'Not now',
			'setting.updateDialog.appStore' => 'Update from App Store',
			'setting.updateDialog.downloadApk' => 'Download APK',
			'setting.updateDialog.githubRelease' => 'Go to Git Release',
			'setting.updateDialog.newContent' => ({required Object code}) => 'New features from version ${code}:\n',
			'setting.localizationDialog.title' => 'Languages',
			'setting.localizationDialog.undefined' => 'Follow system setting',
			'setting.localizationDialog.simplifiedChinese' => 'Simplified Chinese',
			'setting.localizationDialog.traditionalChinese' => 'Traditional Chinese',
			'setting.localizationDialog.english' => 'English',
			'setting.semesterChange' => 'Change semester',
			'setting.semesterChangeDescription' => ({required Object semester}) => 'Using semester ${semester}',
			'setting.semesterUpdateData' => 'Applying new semester setting',
			'setting.easterEggPage' => 'You found an Easter egg',
			'setting.aboutPage.benderblog' => 'Main developer, iOS widget',
			'setting.aboutPage.alnair' => 'Development: Library search and cover',
			'setting.aboutPage.aqqkad' => 'Development: Class attandance history',
			'setting.aboutPage.bellssgit' => 'Support: best and longest feedback source',
			'setting.aboutPage.brackrat' => 'Design: homepage, login page, color scheme, iOS widgets, etc.',
			'setting.aboutPage.breezeline' => 'Support: valueless and meaningless product manager (from his own description)',
			'setting.aboutPage.cafebabe' => 'Support: provide Easter egg code / Development: Development: New Slider \'26',
			'setting.aboutPage.chitao1234' => 'Development: fix slider misalignment issue',
			'setting.aboutPage.copperkoi' => 'Development: latest time arrangement sync to calendar',
			'setting.aboutPage.dimole' => 'Development support: assist in fixing slider issue',
			'setting.aboutPage.elitewars' => 'Design: sports score page',
			'setting.aboutPage.elliot' => 'Internationalization: English translation / Development guidance: on partner classtable development (This function has been removed)',
			'setting.aboutPage.flyingpig' => 'Development: Fix null pointer exception at user defined class info',
			'setting.aboutPage.godhu777777' => 'Internationalization: Traditional Chinese conversion code & Easter egg code / Development: Optimize outputing arrangements to the calendar',
			'setting.aboutPage.hancl777' => 'Internationalization: Traditional Chinese conversion code',
			'setting.aboutPage.hazukiKeatsu' => 'Development: Physics experiment score query and recognization',
			'setting.aboutPage.hawa130' => 'Design: Class info card',
			_ => null,
		} ?? switch (path) {
			'setting.aboutPage.hhzm' => 'Development: electricity fee inquiry account calculation',
			'setting.aboutPage.imaginary17' => 'Developement: Ruisi navigator stack fix',
			'setting.aboutPage.imoscarz' => 'Development: Homepage for software / Development: Checkin check for pad / Development: Sport UI Change',
			'setting.aboutPage.kaMateKaOra' => 'Internationalization: English correction',
			'setting.aboutPage.lagrangeX' => 'Development: Class progress indicator (adopted) / Development: Gray cover on attended class and other classtable design',
			'setting.aboutPage.lhx666Cool' => 'Support: Windows and Linux build scripts / Development: New Slider \'26',
			'setting.aboutPage.lichtyy' => 'Design: color pattern and blank page picture / Development: HTML reader for the experiment system',
			'setting.aboutPage.lqsyH' => 'Support: Promotion Picture',
			'setting.aboutPage.lsy223622' => 'Design: iOS and Android icons / Support: titled XDYou',
			'setting.aboutPage.mrbrilliant2046' => 'Support: Provided the school net user guide / Internationalization: English correction',
			'setting.aboutPage.nancunchild' => 'Development: library search function / Internationalization: English correction',
			'setting.aboutPage.nkanf' => 'Development: Class progress indicator (original) / Support: MacOS build support',
			'setting.aboutPage.pairman' => 'Development: score cache and optimize slider algorithm / Internationalization: English correction',
			'setting.aboutPage.reverierxu' => 'Design: REX card for information display / Development support: on postgraduate class schedule',
			'setting.aboutPage.rrrilac' => 'Development support: electricity query',
			'setting.aboutPage.ray' => 'Design: splash screen / Support: iOS publisher / Development guidance: on partner classtable development (This function has been removed) / Internationalization: English correction',
			'setting.aboutPage.shadowyingyi' => 'Support: two times of pigeon house official account publicity',
			'setting.aboutPage.stalomeow' => 'Design: homepage timeline / Development: asynchronous login and captcha predict',
			'setting.aboutPage.xeonds' => 'Design: settings page / Development: XDU Planet / Development: Payment Code',
			'setting.aboutPage.xingshuyu' => 'Development: Fix physics experiment api and electricity graph',
			'setting.aboutPage.xiue233' => 'Development: Android applet',
			'setting.aboutPage.xizi' => 'Development support: on postgraduate version',
			'setting.aboutPage.wirsbf' => 'Development: fix course adjustment did not proceed as expected',
			'setting.aboutPage.zcwzy' => 'Development: fix Dingxiang apartment electricity fee / development support: on postgraduate version / design: blank page picture',
			'setting.aboutPage.zyarEr' => 'Development support: fix shortcut url',
			'setting.aboutPage.homepage' => 'Homepage',
			'setting.aboutPage.code' => 'Source code',
			'setting.aboutPage.knowMore' => 'Learn more',
			'setting.aboutPage.copyrightNotice' => 'This software is compiled, or derived from the traintime_pda (a.k.a watermeter) codebase, which is licensed under Mozilla Public License v2.0.\n\nThis APP has no relation to Xidian University, Tishineng Service, Shuwow and other services.\n\nCopyright 2023-2025 BenderBlog Rodriguez and contributors.\nCopyright 2025-present Traintime PDA authors.\n\nThe Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, you can obtain one at https://mozilla.org/MPL/2.0/.',
			'setting.aboutPage.beian' => 'ICP record code',
			'setting.aboutPage.signAndroid' => 'Android signature',
			'setting.aboutPage.title' => 'About this APP',
			'sport.title' => 'Sport Query',
			'sport.classInfo' => 'Class information',
			'sport.emptyClassInfo' => 'No class information found',
			'sport.testScore' => 'Sport test score',
			'sport.totalScore' => 'Four-year total score',
			'sport.totalScoreLabel' => 'Total Score',
			'sport.rankLabel' => 'Rank',
			'sport.semester' => ({required Object year, required Object grade_type}) => 'Semester ${year} ${grade_type}',
			'sport.subject' => 'Subject',
			'sport.data' => 'Data',
			'sport.score' => 'Score',
			'sport.passed' => 'Passed',
			'sport.fromTo' => ({required Object start, required Object stop}) => 'Period ${start} to ${stop}',
			'sport.scoreString' => ({required Object score}) => '${score} points',
			'sport.situationNopassword' => 'No password',
			'sport.situationMaintain' => 'System maintenance',
			'sport.situationFailedLogin' => 'Login failed',
			'sport.situationQuery' => 'Query failed',
			'sport.situationNetwork' => 'Network malfunction',
			'sport.situationUnknown' => ({required Object situation}) => 'Unknown malfunction ${situation}',
			'sport.situationFetching' => 'Fetching...',
			'sport.situationError' => ({required Object situation}) => 'Bad thing: ${situation}',
			'sport.cacheHintMissingPassword' => 'Please set your PE password and try again.',
			'sport.cacheHintCredentialInvalid' => 'The PE login has expired. Please update your PE password and try again.',
			'sport.cacheHintMaintain' => 'The PE service is under maintenance. Please try again later.',
			'sport.cacheHintLoginFailed' => 'Failed to log in to the PE service.',
			'sport.cacheHintQueryFailed' => 'Failed to query PE information.',
			'sport.cacheHintNetwork' => 'The PE service network request failed.',
			'sport.cacheHintUnknown' => 'Failed to fetch PE information online. Check logs for details.',
			'sport.errorAuthExpired' => 'The PE login has expired. Please try again.',
			'sport.errorMissingPassword' => 'PE password is not set',
			'sport.errorCredentialInvalid' => 'The PE login has expired. Please update your PE password and try again.',
			'toolbox.title' => 'Other Functions',
			'toolbox.payment' => 'Payment System',
			'toolbox.paymentDescription' => 'Times to pay the electricity fee',
			'toolbox.drinkingwater' => 'Drinking Water',
			'toolbox.drinkingwaterDescription' => 'Is good for health',
			'toolbox.repair' => 'Repair report',
			'toolbox.repairDescription' => 'Don\'t let the water leak from the top',
			'toolbox.reserve' => 'Space Reservation',
			'toolbox.reserveDescription' => 'Find a place to gathering',
			'toolbox.mobile' => 'Mobile Portal',
			'toolbox.mobileDescription' => 'Specific for leaving',
			'toolbox.network' => 'Network Query',
			'toolbox.networkDescription' => 'Hope never charges (NO!)',
			'toolbox.physics' => 'Physics Calculation',
			'toolbox.physicsDescription' => 'Hope the operation goes smoothly',
			'toolbox.discover' => 'Ruisi Navigation',
			'toolbox.discoverDescription' => 'Lots other functions',
			'weekday.monday' => 'Mon.',
			'weekday.tuesday' => 'Tue.',
			'weekday.wednesday' => 'Wed.',
			'weekday.thursday' => 'Thu.',
			'weekday.friday' => 'Fri.',
			'weekday.saturday' => 'Sat.',
			'weekday.sunday' => 'Sun.',
			'xduPlanet.all' => 'All',
			'xduPlanet.loading' => 'Loading, please wait <(=ω=)>',
			'xduPlanet.unknownAuthor' => 'Unknown author',
			'xduPlanet.loadFailedTitle' => 'Failed to load',
			'xduPlanet.loadFailedBottom' => 'Failed to load the article, you can click the button on the top right of the screen to open it in the browser.',
			'xduPlanet.noComment' => 'No comments yet',
			'xduPlanet.replyAudit' => ({required Object reply_to}) => 'Reply comment #${reply_to} has been reported or deleted',
			'xduPlanet.reply' => ({required Object reply_to, required Object content}) => 'Reply to #${reply_to}: ${content}',
			'xduPlanet.haveBeenAudit' => 'This comment has been reported',
			'xduPlanet.audit' => 'Report',
			'xduPlanet.confirmAuditDialog.title' => 'Confirm reporting',
			'xduPlanet.confirmAuditDialog.content' => 'Think twice. Reporting will tag the comment, but it may not be deleted.',
			'xduPlanet.confirmAuditDialog.cancel' => 'Forget it',
			'xduPlanet.confirmAuditDialog.ongoing' => 'Reporting...',
			'xduPlanet.confirmAuditDialog.failed' => 'Failed to report',
			'xduPlanet.confirmAuditDialog.success' => 'Successfully reporting',
			'xduPlanet.comment' => 'Reply',
			'xduPlanet.send' => 'Send',
			'xduPlanet.sending' => 'Sending comment',
			'xduPlanet.emptySend' => 'Blank message sent',
			'xduPlanet.hintSendComment' => 'Express yourself!',
			'xduPlanet.commentTitle' => 'Comment on this article',
			'xduPlanet.commentSuccess' => 'Successfully commenting',
			'xduPlanet.commentFailed' => 'Comment failed, please check the log',
			'xduPlanet.commentCanceled' => 'Nothing to say?',
			'xduPlanet.commentLoading' => 'Loading comments...',
			'xduPlanet.block' => 'Blocked',
			'xduPlanet.delete' => 'Deleted',
			'xduPlanet.audio' => 'Deleted',
			_ => null,
		};
	}
}
