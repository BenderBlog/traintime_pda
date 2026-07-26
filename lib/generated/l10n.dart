import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of I18n
/// returned by `I18n.of(context)`.
///
/// Applications need to include `I18n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: I18n.localizationsDelegates,
///   supportedLocales: I18n.supportedLocales,
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
/// be consistent with the languages listed in the I18n.supportedLocales
/// property.
abstract class I18n {
  I18n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static I18n? of(BuildContext context) {
    return Localizations.of<I18n>(context, I18n);
  }

  static const LocalizationsDelegate<I18n> delegate = _I18nDelegate();

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
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @dragText.
  ///
  /// In en, this message translates to:
  /// **'Pull to request more'**
  String get dragText;

  /// No description provided for @readyText.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get readyText;

  /// No description provided for @processingText.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processingText;

  /// No description provided for @processedText.
  ///
  /// In en, this message translates to:
  /// **'Successfully requested'**
  String get processedText;

  /// No description provided for @noMoreText.
  ///
  /// In en, this message translates to:
  /// **'No more data'**
  String get noMoreText;

  /// No description provided for @failedText.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get failedText;

  /// No description provided for @chooseSemester.
  ///
  /// In en, this message translates to:
  /// **'Choose Semester'**
  String get chooseSemester;

  /// No description provided for @errorDetected.
  ///
  /// In en, this message translates to:
  /// **'Ouch! An error occurred!'**
  String get errorDetected;

  /// No description provided for @clickToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Click to refresh'**
  String get clickToRefresh;

  /// No description provided for @confirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm? (ゝ∀･)'**
  String get confirmTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get confirm;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error, maybe you are not connected to the Internet, or the school server is down :P'**
  String get networkError;

  /// No description provided for @errorDetect.
  ///
  /// In en, this message translates to:
  /// **'An error has occurred,'**
  String get errorDetect;

  /// No description provided for @queryFailed.
  ///
  /// In en, this message translates to:
  /// **'Query failed'**
  String get queryFailed;

  /// No description provided for @notSchoolNetwork.
  ///
  /// In en, this message translates to:
  /// **'Not on the Campus Network'**
  String get notSchoolNetwork;

  /// No description provided for @experimentControllerNoPassword.
  ///
  /// In en, this message translates to:
  /// **'Experiment password is not set, please set up one in the setting'**
  String get experimentControllerNoPassword;

  /// No description provided for @experimentControllerLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get experimentControllerLoginFailed;

  /// No description provided for @cancelExam.
  ///
  /// In en, this message translates to:
  /// **'Disqualified to exam :P'**
  String get cancelExam;

  /// No description provided for @loginProcessReadyPage.
  ///
  /// In en, this message translates to:
  /// **'Prepare to obtain login environment'**
  String get loginProcessReadyPage;

  /// No description provided for @loginProcessGetEncrypt.
  ///
  /// In en, this message translates to:
  /// **'Obtain password encryption key'**
  String get loginProcessGetEncrypt;

  /// No description provided for @loginProcessReadyLogin.
  ///
  /// In en, this message translates to:
  /// **'Prepare to login'**
  String get loginProcessReadyLogin;

  /// No description provided for @loginProcessSlider.
  ///
  /// In en, this message translates to:
  /// **'Logging in'**
  String get loginProcessSlider;

  /// No description provided for @loginProcessAfterProcess.
  ///
  /// In en, this message translates to:
  /// **'Post-login processing'**
  String get loginProcessAfterProcess;

  /// No description provided for @loginProcessFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed, response status code: {statusCode}'**
  String loginProcessFailed(String statusCode);

  /// No description provided for @noInfo.
  ///
  /// In en, this message translates to:
  /// **'No information'**
  String get noInfo;

  /// No description provided for @catcherDetected.
  ///
  /// In en, this message translates to:
  /// **'An error has occurred'**
  String get catcherDetected;

  /// No description provided for @catcherDescription.
  ///
  /// In en, this message translates to:
  /// **'Details are shown as follows'**
  String get catcherDescription;

  /// No description provided for @newHomepageHint.
  ///
  /// In en, this message translates to:
  /// **'A new homepage is developing here, the pigimg is a placeholder, have fun'**
  String get newHomepageHint;

  /// No description provided for @localCacheHint.
  ///
  /// In en, this message translates to:
  /// **'Local cache from {datetime}'**
  String localCacheHint(String datetime);

  /// No description provided for @inappCacheHint.
  ///
  /// In en, this message translates to:
  /// **'In-app cache from {datetime}\nCache will be cleared once restart!'**
  String inappCacheHint(String datetime);

  /// No description provided for @cacheReasonDefault.
  ///
  /// In en, this message translates to:
  /// **'Showing cached data.'**
  String get cacheReasonDefault;

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Mon.'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue.'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed.'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thu.'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Fri.'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Sat.'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sun.'**
  String get weekdaySunday;

  /// No description provided for @monthJanuary.
  ///
  /// In en, this message translates to:
  /// **'Jan.'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In en, this message translates to:
  /// **'Feb.'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In en, this message translates to:
  /// **'Mar.'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In en, this message translates to:
  /// **'Apr.'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In en, this message translates to:
  /// **'Jun.'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In en, this message translates to:
  /// **'Jul.'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In en, this message translates to:
  /// **'Aug.'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In en, this message translates to:
  /// **'Sept.'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In en, this message translates to:
  /// **'Oct.'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In en, this message translates to:
  /// **'Nov.'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In en, this message translates to:
  /// **'Dec.'**
  String get monthDecember;

  /// No description provided for @classAttendanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance Query'**
  String get classAttendanceTitle;

  /// No description provided for @classAttendanceDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance Detail - {courseName}'**
  String classAttendanceDetailTitle(String courseName);

  /// No description provided for @classAttendanceNoData.
  ///
  /// In en, this message translates to:
  /// **'No course info'**
  String get classAttendanceNoData;

  /// No description provided for @classAttendanceNoAttendanceRecord.
  ///
  /// In en, this message translates to:
  /// **'No attendance record'**
  String get classAttendanceNoAttendanceRecord;

  /// No description provided for @classAttendanceLongLoad.
  ///
  /// In en, this message translates to:
  /// **'It takes about half minute to load attendance data, pleace wait patiently'**
  String get classAttendanceLongLoad;

  /// No description provided for @classAttendanceCourseStateUnknown.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get classAttendanceCourseStateUnknown;

  /// No description provided for @classAttendanceCourseStateIneligible.
  ///
  /// In en, this message translates to:
  /// **'ineligible'**
  String get classAttendanceCourseStateIneligible;

  /// No description provided for @classAttendanceCourseStateEligible.
  ///
  /// In en, this message translates to:
  /// **'eligible'**
  String get classAttendanceCourseStateEligible;

  /// No description provided for @classAttendanceCourseStateWarning.
  ///
  /// In en, this message translates to:
  /// **'warning'**
  String get classAttendanceCourseStateWarning;

  /// No description provided for @classAttendanceTableCourseName.
  ///
  /// In en, this message translates to:
  /// **'Course Name'**
  String get classAttendanceTableCourseName;

  /// No description provided for @classAttendanceTableStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get classAttendanceTableStatus;

  /// No description provided for @classAttendanceTableAttendanceRate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get classAttendanceTableAttendanceRate;

  /// No description provided for @classAttendanceTableCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get classAttendanceTableCheckIn;

  /// No description provided for @classAttendanceTableAbsence.
  ///
  /// In en, this message translates to:
  /// **'Absence'**
  String get classAttendanceTableAbsence;

  /// No description provided for @classAttendanceTableRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get classAttendanceTableRequired;

  /// No description provided for @classAttendanceTableLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave(P/S/O)'**
  String get classAttendanceTableLeave;

  /// No description provided for @classAttendanceTableFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get classAttendanceTableFilter;

  /// No description provided for @classAttendanceTableFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get classAttendanceTableFilterAll;

  /// No description provided for @classAttendanceTableShowingCount.
  ///
  /// In en, this message translates to:
  /// **'Showing {count}/{total} courses'**
  String classAttendanceTableShowingCount(String count, String total);

  /// No description provided for @classAttendanceCardTime.
  ///
  /// In en, this message translates to:
  /// **'Attendances'**
  String get classAttendanceCardTime;

  /// No description provided for @classAttendanceCardTimeInfo.
  ///
  /// In en, this message translates to:
  /// **'{checkInCount} Checked / {absenceCount} Absences / {requiredCheckIn} Required'**
  String classAttendanceCardTimeInfo(
    String checkInCount,
    String absenceCount,
    String requiredCheckIn,
  );

  /// No description provided for @classAttendanceCardNotAttend.
  ///
  /// In en, this message translates to:
  /// **'Rebirths'**
  String get classAttendanceCardNotAttend;

  /// No description provided for @classAttendanceCardNotAttendInfo.
  ///
  /// In en, this message translates to:
  /// **'{timeToHaveError} Times / {totalTimes} Total'**
  String classAttendanceCardNotAttendInfo(
    String timeToHaveError,
    String totalTimes,
  );

  /// No description provided for @classAttendanceCardNotAttendInfoError.
  ///
  /// In en, this message translates to:
  /// **'Cannot match course in the classtable'**
  String get classAttendanceCardNotAttendInfoError;

  /// No description provided for @classAttendanceCardLeave.
  ///
  /// In en, this message translates to:
  /// **'Leaves'**
  String get classAttendanceCardLeave;

  /// No description provided for @classAttendanceCardLeaveInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal {personalLeave} / Sick {sickLeave} / Official {officialLeave}'**
  String classAttendanceCardLeaveInfo(
    String personalLeave,
    String sickLeave,
    String officialLeave,
  );

  /// No description provided for @classAttendanceCardStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get classAttendanceCardStudy;

  /// No description provided for @classAttendanceCardStudyInfo.
  ///
  /// In en, this message translates to:
  /// **'Task {taskProgress} / Works {homeworkProgress} / Exam {examProgress}'**
  String classAttendanceCardStudyInfo(
    String taskProgress,
    String homeworkProgress,
    String examProgress,
  );

  /// No description provided for @classAttendanceDetailCardCreatorName.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get classAttendanceDetailCardCreatorName;

  /// No description provided for @classAttendanceDetailCardStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start at'**
  String get classAttendanceDetailCardStartTime;

  /// No description provided for @classAttendanceDetailCardSummitTime.
  ///
  /// In en, this message translates to:
  /// **'Summit at'**
  String get classAttendanceDetailCardSummitTime;

  /// No description provided for @classAttendanceSignTypeQrCode.
  ///
  /// In en, this message translates to:
  /// **'QR Code Checkin'**
  String get classAttendanceSignTypeQrCode;

  /// No description provided for @classAttendanceSignTypeGesture.
  ///
  /// In en, this message translates to:
  /// **'Gesture Checkin'**
  String get classAttendanceSignTypeGesture;

  /// No description provided for @classAttendanceSignTypePosition.
  ///
  /// In en, this message translates to:
  /// **'Position Checkin'**
  String get classAttendanceSignTypePosition;

  /// No description provided for @classAttendanceSignTypeDefault.
  ///
  /// In en, this message translates to:
  /// **'Normal Checkin'**
  String get classAttendanceSignTypeDefault;

  /// No description provided for @classAttendanceSignStatusAbsencenotparticipating.
  ///
  /// In en, this message translates to:
  /// **'Absence (Not participating)'**
  String get classAttendanceSignStatusAbsencenotparticipating;

  /// No description provided for @classAttendanceSignStatusSigned.
  ///
  /// In en, this message translates to:
  /// **'Signed'**
  String get classAttendanceSignStatusSigned;

  /// No description provided for @classAttendanceSignStatusSignedbyteacher.
  ///
  /// In en, this message translates to:
  /// **'Signed by teacher'**
  String get classAttendanceSignStatusSignedbyteacher;

  /// No description provided for @classAttendanceSignStatusPersonalleave2.
  ///
  /// In en, this message translates to:
  /// **'Personal Leave'**
  String get classAttendanceSignStatusPersonalleave2;

  /// No description provided for @classAttendanceSignStatusAbsence.
  ///
  /// In en, this message translates to:
  /// **'Absence'**
  String get classAttendanceSignStatusAbsence;

  /// No description provided for @classAttendanceSignStatusSickleave.
  ///
  /// In en, this message translates to:
  /// **'Sick Leave'**
  String get classAttendanceSignStatusSickleave;

  /// No description provided for @classAttendanceSignStatusPersonalleave.
  ///
  /// In en, this message translates to:
  /// **'Personal Leave'**
  String get classAttendanceSignStatusPersonalleave;

  /// No description provided for @classAttendanceSignStatusLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get classAttendanceSignStatusLate;

  /// No description provided for @classAttendanceSignStatusLeaveearly.
  ///
  /// In en, this message translates to:
  /// **'Leave Early'**
  String get classAttendanceSignStatusLeaveearly;

  /// No description provided for @classAttendanceSignStatusSignexpiredy.
  ///
  /// In en, this message translates to:
  /// **'Sign Expired'**
  String get classAttendanceSignStatusSignexpiredy;

  /// No description provided for @classAttendanceSignStatusPublicleave.
  ///
  /// In en, this message translates to:
  /// **'Public Leave'**
  String get classAttendanceSignStatusPublicleave;

  /// No description provided for @classtablePartnerClasstableOverrideDialog.
  ///
  /// In en, this message translates to:
  /// **'Currently there is a partner classtable data, do you want to overwrite?'**
  String get classtablePartnerClasstableOverrideDialog;

  /// No description provided for @classtablePartnerClasstableNoFile.
  ///
  /// In en, this message translates to:
  /// **'Import file not found'**
  String get classtablePartnerClasstableNoFile;

  /// No description provided for @classtablePartnerClasstableNoPermission.
  ///
  /// In en, this message translates to:
  /// **'Storage permission denied , cannot read file'**
  String get classtablePartnerClasstableNoPermission;

  /// No description provided for @classtablePartnerClasstableProblem.
  ///
  /// In en, this message translates to:
  /// **'Maybe there\'s a problem with the import file :P'**
  String get classtablePartnerClasstableProblem;

  /// No description provided for @classtablePartnerClasstableSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully imported'**
  String get classtablePartnerClasstableSuccess;

  /// No description provided for @classtablePartnerClasstableShareDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Caution!'**
  String get classtablePartnerClasstableShareDialogTitle;

  /// No description provided for @classtablePartnerClasstableShareDialogContent.
  ///
  /// In en, this message translates to:
  /// **'The exported file may include your personal information, please DO NOT share casually'**
  String get classtablePartnerClasstableShareDialogContent;

  /// No description provided for @classtablePartnerClasstableSaveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save calendar file to...'**
  String get classtablePartnerClasstableSaveDialogTitle;

  /// No description provided for @classtablePartnerClasstableSaveDialogSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Should be saved'**
  String get classtablePartnerClasstableSaveDialogSuccessMessage;

  /// No description provided for @classtablePartnerClasstableSaveDialogFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Can not create the file, save fails.'**
  String get classtablePartnerClasstableSaveDialogFailureMessage;

  /// No description provided for @classtablePartnerClasstableDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'(｡í _ ì｡)For real?'**
  String get classtablePartnerClasstableDeleteDialogTitle;

  /// No description provided for @classtablePartnerClasstableDeleteDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to delete the partner classtable?'**
  String get classtablePartnerClasstableDeleteDialogMessage;

  /// No description provided for @classtablePartnerClasstableDeleteDialogSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get classtablePartnerClasstableDeleteDialogSuccessMessage;

  /// No description provided for @classtablePartnerClasstableNameDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Input the name of the partner classtable to be shown on your partner\'s screen'**
  String get classtablePartnerClasstableNameDialogTitle;

  /// No description provided for @classtablePartnerClasstableNameDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Input here, otherwise it will be shown as \'Sweetie\''**
  String get classtablePartnerClasstableNameDialogHint;

  /// No description provided for @classtablePartnerClasstableNameDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'There\'s nobody other than my sweetie'**
  String get classtablePartnerClasstableNameDialogCancel;

  /// No description provided for @classtablePartnerClasstableNameDialogAccept.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get classtablePartnerClasstableNameDialogAccept;

  /// No description provided for @classtablePartnerClasstableNameDialogBlankInput.
  ///
  /// In en, this message translates to:
  /// **'Input is blank!'**
  String get classtablePartnerClasstableNameDialogBlankInput;

  /// No description provided for @classtablePageTitle.
  ///
  /// In en, this message translates to:
  /// **'My Schedule'**
  String get classtablePageTitle;

  /// No description provided for @classtablePartnerPageTitle.
  ///
  /// In en, this message translates to:
  /// **'{partner_name}\'s Schedule'**
  String classtablePartnerPageTitle(String partner_name);

  /// No description provided for @classtablePopupMenuNotArranged.
  ///
  /// In en, this message translates to:
  /// **'View unarranged classes'**
  String get classtablePopupMenuNotArranged;

  /// No description provided for @classtablePopupMenuClassChanged.
  ///
  /// In en, this message translates to:
  /// **'View schedule changes'**
  String get classtablePopupMenuClassChanged;

  /// No description provided for @classtablePopupMenuAddClass.
  ///
  /// In en, this message translates to:
  /// **'Add class'**
  String get classtablePopupMenuAddClass;

  /// No description provided for @classtablePopupMenuGenerateIcal.
  ///
  /// In en, this message translates to:
  /// **'Export calendar file'**
  String get classtablePopupMenuGenerateIcal;

  /// No description provided for @classtablePopupMenuGeneratePartnerFile.
  ///
  /// In en, this message translates to:
  /// **'Export partner classtable file'**
  String get classtablePopupMenuGeneratePartnerFile;

  /// No description provided for @classtablePopupMenuImportPartnerFile.
  ///
  /// In en, this message translates to:
  /// **'Import partner classtable file'**
  String get classtablePopupMenuImportPartnerFile;

  /// No description provided for @classtablePopupMenuDeletePartnerFile.
  ///
  /// In en, this message translates to:
  /// **'Delete partner classtable file'**
  String get classtablePopupMenuDeletePartnerFile;

  /// No description provided for @classtablePopupMenuOutputToSystem.
  ///
  /// In en, this message translates to:
  /// **'Export to system calendar'**
  String get classtablePopupMenuOutputToSystem;

  /// No description provided for @classtablePopupMenuRefreshClasstable.
  ///
  /// In en, this message translates to:
  /// **'Refresh schedule'**
  String get classtablePopupMenuRefreshClasstable;

  /// No description provided for @classtablePopupMenuSwitchSemester.
  ///
  /// In en, this message translates to:
  /// **'Switch classtable semester'**
  String get classtablePopupMenuSwitchSemester;

  /// No description provided for @classtablePopupMenuCurrentTimeSettings.
  ///
  /// In en, this message translates to:
  /// **'Time indicator settings'**
  String get classtablePopupMenuCurrentTimeSettings;

  /// No description provided for @classtablePopupMenuClassColorSettings.
  ///
  /// In en, this message translates to:
  /// **'Class color settings'**
  String get classtablePopupMenuClassColorSettings;

  /// No description provided for @classtableVisualSettingsCurrentTimeSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Time indicator settings'**
  String get classtableVisualSettingsCurrentTimeSettingsTitle;

  /// No description provided for @classtableVisualSettingsClassColorSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Class color settings'**
  String get classtableVisualSettingsClassColorSettingsTitle;

  /// No description provided for @classtableVisualSettingsCompletedStyleEnabled.
  ///
  /// In en, this message translates to:
  /// **'Completed class styling distinction'**
  String get classtableVisualSettingsCompletedStyleEnabled;

  /// No description provided for @classtableVisualSettingsCurrentTimeSection.
  ///
  /// In en, this message translates to:
  /// **'Time indicators'**
  String get classtableVisualSettingsCurrentTimeSection;

  /// No description provided for @classtableVisualSettingsShowCurrentTimeIndicator.
  ///
  /// In en, this message translates to:
  /// **'Show current time indicator'**
  String get classtableVisualSettingsShowCurrentTimeIndicator;

  /// No description provided for @classtableVisualSettingsShowCurrentTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Show mini time label'**
  String get classtableVisualSettingsShowCurrentTimeLabel;

  /// No description provided for @classtableVisualSettingsShowTodayColumnHighlight.
  ///
  /// In en, this message translates to:
  /// **'Highlight today\'s column'**
  String get classtableVisualSettingsShowTodayColumnHighlight;

  /// No description provided for @classtableVisualSettingsUnfinishedSection.
  ///
  /// In en, this message translates to:
  /// **'Class style'**
  String get classtableVisualSettingsUnfinishedSection;

  /// No description provided for @classtableVisualSettingsActiveBrightnessFactor.
  ///
  /// In en, this message translates to:
  /// **'Brightness: {value}'**
  String classtableVisualSettingsActiveBrightnessFactor(String value);

  /// No description provided for @classtableVisualSettingsActiveBorderAlpha.
  ///
  /// In en, this message translates to:
  /// **'Border opacity: {value}'**
  String classtableVisualSettingsActiveBorderAlpha(String value);

  /// No description provided for @classtableVisualSettingsActiveInnerAlpha.
  ///
  /// In en, this message translates to:
  /// **'Fill opacity: {value}'**
  String classtableVisualSettingsActiveInnerAlpha(String value);

  /// No description provided for @classtableVisualSettingsCompletedSection.
  ///
  /// In en, this message translates to:
  /// **'Completed class style'**
  String get classtableVisualSettingsCompletedSection;

  /// No description provided for @classtableVisualSettingsCompletedSaturationFactor.
  ///
  /// In en, this message translates to:
  /// **'Fill saturation: {value}'**
  String classtableVisualSettingsCompletedSaturationFactor(String value);

  /// No description provided for @classtableVisualSettingsCompletedBrightnessFactor.
  ///
  /// In en, this message translates to:
  /// **'Brightness: {value}'**
  String classtableVisualSettingsCompletedBrightnessFactor(String value);

  /// No description provided for @classtableVisualSettingsCompletedTextSaturationFactor.
  ///
  /// In en, this message translates to:
  /// **'Text saturation: {value}'**
  String classtableVisualSettingsCompletedTextSaturationFactor(String value);

  /// No description provided for @classtableVisualSettingsCompletedBorderAlpha.
  ///
  /// In en, this message translates to:
  /// **'Border opacity: {value}'**
  String classtableVisualSettingsCompletedBorderAlpha(String value);

  /// No description provided for @classtableVisualSettingsCompletedInnerAlpha.
  ///
  /// In en, this message translates to:
  /// **'Fill opacity: {value}'**
  String classtableVisualSettingsCompletedInnerAlpha(String value);

  /// No description provided for @classtableStatusSourceClassTable.
  ///
  /// In en, this message translates to:
  /// **'Class Table'**
  String get classtableStatusSourceClassTable;

  /// No description provided for @classtableStatusSourceExam.
  ///
  /// In en, this message translates to:
  /// **'Exams'**
  String get classtableStatusSourceExam;

  /// No description provided for @classtableStatusSourcePhysicsExperiment.
  ///
  /// In en, this message translates to:
  /// **'Physics Experiments'**
  String get classtableStatusSourcePhysicsExperiment;

  /// No description provided for @classtableStatusSourceOtherExperiment.
  ///
  /// In en, this message translates to:
  /// **'Other Experiments'**
  String get classtableStatusSourceOtherExperiment;

  /// No description provided for @classtableErrorDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Error Info'**
  String get classtableErrorDialogTitle;

  /// No description provided for @classtableStatusBannerLoading.
  ///
  /// In en, this message translates to:
  /// **'Updating: {sources}'**
  String classtableStatusBannerLoading(String sources);

  /// No description provided for @classtableStatusBannerCache.
  ///
  /// In en, this message translates to:
  /// **'Using cached data: {sources}'**
  String classtableStatusBannerCache(String sources);

  /// No description provided for @classtableStatusBannerErrorSummary.
  ///
  /// In en, this message translates to:
  /// **'Failed to load: {sources}'**
  String classtableStatusBannerErrorSummary(String sources);

  /// No description provided for @classtableEmptyStateNoCourse.
  ///
  /// In en, this message translates to:
  /// **'No classes are arranged for semester {semester_code}.'**
  String classtableEmptyStateNoCourse(String semester_code);

  /// No description provided for @classtableEmptyStateWithExam.
  ///
  /// In en, this message translates to:
  /// **'No classes are arranged for semester {semester_code}, but exam arrangements are available.'**
  String classtableEmptyStateWithExam(String semester_code);

  /// No description provided for @classtableEmptyStateWithExperiment.
  ///
  /// In en, this message translates to:
  /// **'No classes are arranged for semester {semester_code}, but experiment arrangements are available.'**
  String classtableEmptyStateWithExperiment(String semester_code);

  /// No description provided for @classtableEmptyStateWithExamAndExperiment.
  ///
  /// In en, this message translates to:
  /// **'No classes are arranged for semester {semester_code}, but exam and experiment arrangements are available.'**
  String classtableEmptyStateWithExamAndExperiment(String semester_code);

  /// No description provided for @classtableEmptyActionViewExam.
  ///
  /// In en, this message translates to:
  /// **'View exams'**
  String get classtableEmptyActionViewExam;

  /// No description provided for @classtableEmptyActionViewExperiment.
  ///
  /// In en, this message translates to:
  /// **'View experiments'**
  String get classtableEmptyActionViewExperiment;

  /// No description provided for @classtableClassChangePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule Changes'**
  String get classtableClassChangePageTitle;

  /// No description provided for @classtableClassChangePageEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Currently there\'s no class schedule changes'**
  String get classtableClassChangePageEmptyMessage;

  /// No description provided for @classtableClassChangePageTeacherChange.
  ///
  /// In en, this message translates to:
  /// **'Teacher has been changed from {previous_teacher} to {new_teacher}'**
  String classtableClassChangePageTeacherChange(
    String previous_teacher,
    String new_teacher,
  );

  /// No description provided for @classtableClassChangePageNoTeacherChange.
  ///
  /// In en, this message translates to:
  /// **'Teacher kept unchanged'**
  String get classtableClassChangePageNoTeacherChange;

  /// No description provided for @classtableClassChangePage1.
  ///
  /// In en, this message translates to:
  /// **'One'**
  String get classtableClassChangePage1;

  /// No description provided for @classtableClassChangePage2.
  ///
  /// In en, this message translates to:
  /// **'Two'**
  String get classtableClassChangePage2;

  /// No description provided for @classtableClassChangePage3.
  ///
  /// In en, this message translates to:
  /// **'Three'**
  String get classtableClassChangePage3;

  /// No description provided for @classtableClassChangePage4.
  ///
  /// In en, this message translates to:
  /// **'Four'**
  String get classtableClassChangePage4;

  /// No description provided for @classtableClassChangePage5.
  ///
  /// In en, this message translates to:
  /// **'Five'**
  String get classtableClassChangePage5;

  /// No description provided for @classtableClassChangePage6.
  ///
  /// In en, this message translates to:
  /// **'Six'**
  String get classtableClassChangePage6;

  /// No description provided for @classtableClassChangePage7.
  ///
  /// In en, this message translates to:
  /// **'Seven'**
  String get classtableClassChangePage7;

  /// No description provided for @classtableClassChangePageChangeClassMessage.
  ///
  /// In en, this message translates to:
  /// **'This is a course adjustment info，Originally scheduled on period {originalClassRangeStart} to period {originalClassRangeEnd} at the {weekChar_originalWeek}th day of the {originalAffectedWeeks}th week(s), now it is at the {newClassroom} classroom, arranged at the period {newClassRangeStart} to period {newClassRangeStop} at the {weekChar_newWeek}th day of the {newAffectedWeeksListStr} week(s).'**
  String classtableClassChangePageChangeClassMessage(
    String originalClassRangeStart,
    String originalClassRangeEnd,
    String weekChar_originalWeek,
    String originalAffectedWeeks,
    String newClassroom,
    String newClassRangeStart,
    String newClassRangeStop,
    String weekChar_newWeek,
    String newAffectedWeeksListStr,
  );

  /// No description provided for @classtableClassChangePagePatchClassMessage.
  ///
  /// In en, this message translates to:
  /// **'This is a course reschedule info，The course have been rescheduled at the {newClassroom}, on the period {newClassRangeStart} to period {newClassRangeStop} at the {weekChar_newWeek}th day of the {newAffectedWeeksListStr} week(s).'**
  String classtableClassChangePagePatchClassMessage(
    String newClassroom,
    String newClassRangeStart,
    String newClassRangeStop,
    String weekChar_newWeek,
    String newAffectedWeeksListStr,
  );

  /// No description provided for @classtableClassChangePageStopClassMessage.
  ///
  /// In en, this message translates to:
  /// **'This is a course suspension info. The class will be suspended at the period {originalClassRangeStart} to period {originalClassRangeEnd} at the {weekChar_originalWeek} day of the {originalAffectedWeeks} week(s).'**
  String classtableClassChangePageStopClassMessage(
    String originalClassRangeStart,
    String originalClassRangeEnd,
    String weekChar_originalWeek,
    String originalAffectedWeeks,
  );

  /// No description provided for @classtableClassChangePageClassInfo.
  ///
  /// In en, this message translates to:
  /// **'Code: {classCode} | Class {classNumber}\nSchedule change: {classChange}\n{teacherChange}'**
  String classtableClassChangePageClassInfo(
    String classCode,
    String classNumber,
    String classChange,
    String teacherChange,
  );

  /// No description provided for @classtableNotArrangedPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Unscheduled Classes'**
  String get classtableNotArrangedPageTitle;

  /// No description provided for @classtableNotArrangedPageEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'All courses have been scheduled'**
  String get classtableNotArrangedPageEmptyMessage;

  /// No description provided for @classtableNotArrangedPageContent.
  ///
  /// In en, this message translates to:
  /// **'Code {classCode} | Class {classNumber}\nTeacher: {teacher}'**
  String classtableNotArrangedPageContent(
    String classCode,
    String classNumber,
    String teacher,
  );

  /// No description provided for @classtableEmptyClassMessage.
  ///
  /// In en, this message translates to:
  /// **'Semester {semester_code} has no class arranged'**
  String classtableEmptyClassMessage(String semester_code);

  /// No description provided for @classtableEmptyClassWithExam.
  ///
  /// In en, this message translates to:
  /// **'Semester {semester_code} has no class arranged\nbut we have exam info now!\nGo back to mainpage and goto the exam info page.'**
  String classtableEmptyClassWithExam(String semester_code);

  /// No description provided for @classtableWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'Week {week}'**
  String classtableWeekTitle(String week);

  /// No description provided for @classtableNoonBreak.
  ///
  /// In en, this message translates to:
  /// **'Noon'**
  String get classtableNoonBreak;

  /// No description provided for @classtableSupperBreak.
  ///
  /// In en, this message translates to:
  /// **'Supper'**
  String get classtableSupperBreak;

  /// No description provided for @classtableMonth.
  ///
  /// In en, this message translates to:
  /// **'{month}\nmo'**
  String classtableMonth(String month);

  /// No description provided for @classtableNoClass.
  ///
  /// In en, this message translates to:
  /// **'No schedule arranged in this week, please do not spend much of your time on bed.'**
  String get classtableNoClass;

  /// No description provided for @classtableClassCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule Information'**
  String get classtableClassCardTitle;

  /// No description provided for @classtableClassCardUnknownClassroom.
  ///
  /// In en, this message translates to:
  /// **'Unknown classroom'**
  String get classtableClassCardUnknownClassroom;

  /// No description provided for @classtableClassCardRemainsHint.
  ///
  /// In en, this message translates to:
  /// **'There is/are {remain_count} schedule(s) remaining'**
  String classtableClassCardRemainsHint(String remain_count);

  /// No description provided for @classtableClassAddAddClassTitle.
  ///
  /// In en, this message translates to:
  /// **'Add class information'**
  String get classtableClassAddAddClassTitle;

  /// No description provided for @classtableClassAddChangeClassTitle.
  ///
  /// In en, this message translates to:
  /// **'Modify class info'**
  String get classtableClassAddChangeClassTitle;

  /// No description provided for @classtableClassAddClassNameEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Class name cannot be empty'**
  String get classtableClassAddClassNameEmptyMessage;

  /// No description provided for @classtableClassAddWrongTimeMessage.
  ///
  /// In en, this message translates to:
  /// **'Incorrect time input'**
  String get classtableClassAddWrongTimeMessage;

  /// No description provided for @classtableClassAddSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get classtableClassAddSaveButton;

  /// No description provided for @classtableClassAddInputClassnameHint.
  ///
  /// In en, this message translates to:
  /// **'Class name (required)'**
  String get classtableClassAddInputClassnameHint;

  /// No description provided for @classtableClassAddInputTeacherHint.
  ///
  /// In en, this message translates to:
  /// **'Teacher\'s name (optional)'**
  String get classtableClassAddInputTeacherHint;

  /// No description provided for @classtableClassAddInputClassroomHint.
  ///
  /// In en, this message translates to:
  /// **'Classroom location (optional)'**
  String get classtableClassAddInputClassroomHint;

  /// No description provided for @classtableClassAddInputWeekHint.
  ///
  /// In en, this message translates to:
  /// **'Select weeks'**
  String get classtableClassAddInputWeekHint;

  /// No description provided for @classtableClassAddInputTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get classtableClassAddInputTimeHint;

  /// No description provided for @classtableClassAddInputTimeWeekdayHint.
  ///
  /// In en, this message translates to:
  /// **'Weekday'**
  String get classtableClassAddInputTimeWeekdayHint;

  /// No description provided for @classtableClassAddInputStartTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Time start'**
  String get classtableClassAddInputStartTimeHint;

  /// No description provided for @classtableClassAddInputEndTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Time end'**
  String get classtableClassAddInputEndTimeHint;

  /// No description provided for @classtableClassAddWheelChooseHint.
  ///
  /// In en, this message translates to:
  /// **'Period {index}'**
  String classtableClassAddWheelChooseHint(String index);

  /// No description provided for @classtableClassAddChooseAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Please choose at least one time for class'**
  String get classtableClassAddChooseAtLeastOne;

  /// No description provided for @classtableClassAddRepeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Repeat Weekly'**
  String get classtableClassAddRepeatWeekly;

  /// No description provided for @classtableClassAddFreeTime.
  ///
  /// In en, this message translates to:
  /// **'Free Time'**
  String get classtableClassAddFreeTime;

  /// No description provided for @classtableClassAddDateSelectorFreeRule.
  ///
  /// In en, this message translates to:
  /// **'Time must be between 8:30 and 21:25.'**
  String get classtableClassAddDateSelectorFreeRule;

  /// No description provided for @classtableClassAddDateSelectorFreeRule2.
  ///
  /// In en, this message translates to:
  /// **'The end time must be later than the start time.'**
  String get classtableClassAddDateSelectorFreeRule2;

  /// No description provided for @classtableClassAddDateSelectorFreeClassStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get classtableClassAddDateSelectorFreeClassStartTime;

  /// No description provided for @classtableClassAddDateSelectorFreeClassEndTime.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get classtableClassAddDateSelectorFreeClassEndTime;

  /// No description provided for @classtableClassAddDateSelectorFreeEditClassTime.
  ///
  /// In en, this message translates to:
  /// **'Edit the class time'**
  String get classtableClassAddDateSelectorFreeEditClassTime;

  /// No description provided for @classtableClassAddDateSelectorFreeChooseClassTime.
  ///
  /// In en, this message translates to:
  /// **'Choose a class time'**
  String get classtableClassAddDateSelectorFreeChooseClassTime;

  /// No description provided for @classtableCourseDetailCardClassNumberString.
  ///
  /// In en, this message translates to:
  /// **'Class {number}'**
  String classtableCourseDetailCardClassNumberString(String number);

  /// No description provided for @classtableCourseDetailCardUnknownTeacher.
  ///
  /// In en, this message translates to:
  /// **'Unknown teacher'**
  String get classtableCourseDetailCardUnknownTeacher;

  /// No description provided for @classtableCourseDetailCardUnknownPlace.
  ///
  /// In en, this message translates to:
  /// **'Unknown classroom'**
  String get classtableCourseDetailCardUnknownPlace;

  /// No description provided for @classtableCourseDetailCardClassPeriod.
  ///
  /// In en, this message translates to:
  /// **'period {start} to {stop}'**
  String classtableCourseDetailCardClassPeriod(String start, String stop);

  /// No description provided for @classtableCourseDetailCardEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get classtableCourseDetailCardEdit;

  /// No description provided for @classtableCourseDetailCardDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get classtableCourseDetailCardDelete;

  /// No description provided for @classtableCourseDetailCardDeleteSingle.
  ///
  /// In en, this message translates to:
  /// **'Delete this one'**
  String get classtableCourseDetailCardDeleteSingle;

  /// No description provided for @classtableCourseDetailCardDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get classtableCourseDetailCardDeleteAll;

  /// No description provided for @classtableCourseDetailCardDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Everything will be excuted.'**
  String get classtableCourseDetailCardDeleteContent;

  /// No description provided for @classtableCourseDetailCardDeleteContentSingle.
  ///
  /// In en, this message translates to:
  /// **'Only the information within this time range of the class will be removed.'**
  String get classtableCourseDetailCardDeleteContentSingle;

  /// No description provided for @classtableCourseDetailCardDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to delete this class information?'**
  String get classtableCourseDetailCardDeleteTitle;

  /// No description provided for @classtableOutputToSystemSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully output to the system calendar.'**
  String get classtableOutputToSystemSuccess;

  /// No description provided for @classtableOutputToSystemFailure.
  ///
  /// In en, this message translates to:
  /// **'Problem occurred while outputing to the system calendar.'**
  String get classtableOutputToSystemFailure;

  /// No description provided for @classtableOutputToSystemRequestAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Information on requesting permission'**
  String get classtableOutputToSystemRequestAllTitle;

  /// No description provided for @classtableOutputToSystemRequestAll.
  ///
  /// In en, this message translates to:
  /// **'Due to technical difficulties, users must grant both read calendar and write calendar permissions to this software in order to export schedules properly. However, this software will not read the calendar.'**
  String get classtableOutputToSystemRequestAll;

  /// No description provided for @classtableRefreshClasstableReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to refresh the schedule'**
  String get classtableRefreshClasstableReady;

  /// No description provided for @classtableRefreshClasstableSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully refresh the schedule'**
  String get classtableRefreshClasstableSuccess;

  /// No description provided for @classtableCacheHintPasswordWrong.
  ///
  /// In en, this message translates to:
  /// **'IDS password is incorrect or expired.'**
  String get classtableCacheHintPasswordWrong;

  /// No description provided for @classtableCacheHintLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to log in to the classtable service.'**
  String get classtableCacheHintLoginFailed;

  /// No description provided for @classtableCacheHintNetworkFailed.
  ///
  /// In en, this message translates to:
  /// **'Classtable network request failed.'**
  String get classtableCacheHintNetworkFailed;

  /// No description provided for @classtableCacheHintUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch the latest classtable online. Check logs for details.'**
  String get classtableCacheHintUnknownError;

  /// No description provided for @classtableSemesterSwitcherChooseSemester.
  ///
  /// In en, this message translates to:
  /// **'Choose a Semester'**
  String get classtableSemesterSwitcherChooseSemester;

  /// No description provided for @classtableSemesterSwitcherFirstAcademicYear.
  ///
  /// In en, this message translates to:
  /// **'Academic year 1'**
  String get classtableSemesterSwitcherFirstAcademicYear;

  /// No description provided for @classtableSemesterSwitcherSecondAcademicYear.
  ///
  /// In en, this message translates to:
  /// **'Academic year 2'**
  String get classtableSemesterSwitcherSecondAcademicYear;

  /// No description provided for @classtableSemesterSwitcherFetchRemoteSemester.
  ///
  /// In en, this message translates to:
  /// **'Fetch Current Semester'**
  String get classtableSemesterSwitcherFetchRemoteSemester;

  /// No description provided for @classtableSemesterSwitcherFetchingRemoteSemester.
  ///
  /// In en, this message translates to:
  /// **'Fetching...'**
  String get classtableSemesterSwitcherFetchingRemoteSemester;

  /// No description provided for @classtableSemesterSwitcherYear.
  ///
  /// In en, this message translates to:
  /// **'{year}'**
  String classtableSemesterSwitcherYear(String year);

  /// No description provided for @classtableSemesterSwitcherOnlyFutureHint.
  ///
  /// In en, this message translates to:
  /// **'This app only allows viewing course schedules for future semesters.'**
  String get classtableSemesterSwitcherOnlyFutureHint;

  /// No description provided for @clubPromotionTypeTech.
  ///
  /// In en, this message translates to:
  /// **'Tech'**
  String get clubPromotionTypeTech;

  /// No description provided for @clubPromotionTypeAcg.
  ///
  /// In en, this message translates to:
  /// **'ACG'**
  String get clubPromotionTypeAcg;

  /// No description provided for @clubPromotionTypeUnion.
  ///
  /// In en, this message translates to:
  /// **'Official'**
  String get clubPromotionTypeUnion;

  /// No description provided for @clubPromotionTypeProfit.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get clubPromotionTypeProfit;

  /// No description provided for @clubPromotionTypeSport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get clubPromotionTypeSport;

  /// No description provided for @clubPromotionTypeArt.
  ///
  /// In en, this message translates to:
  /// **'Culture'**
  String get clubPromotionTypeArt;

  /// No description provided for @clubPromotionTypeUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get clubPromotionTypeUnknown;

  /// No description provided for @clubPromotionTypeGame.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get clubPromotionTypeGame;

  /// No description provided for @clubPromotionTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get clubPromotionTypeAll;

  /// No description provided for @clubPromotionWrongParam.
  ///
  /// In en, this message translates to:
  /// **'Wrong Parameter'**
  String get clubPromotionWrongParam;

  /// No description provided for @clubPromotionNoGroupInfo.
  ///
  /// In en, this message translates to:
  /// **'No Club info'**
  String get clubPromotionNoGroupInfo;

  /// No description provided for @clubPromotionLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get clubPromotionLoading;

  /// No description provided for @clubPromotionErrorOutside.
  ///
  /// In en, this message translates to:
  /// **'Error detected at the outside'**
  String get clubPromotionErrorOutside;

  /// No description provided for @clubPromotionError.
  ///
  /// In en, this message translates to:
  /// **'Error detected'**
  String get clubPromotionError;

  /// No description provided for @clubPromotionQqCopied.
  ///
  /// In en, this message translates to:
  /// **'QQ Group Number have been copied to the clipboard'**
  String get clubPromotionQqCopied;

  /// No description provided for @clubPromotionNoLink.
  ///
  /// In en, this message translates to:
  /// **'No group invite link provided'**
  String get clubPromotionNoLink;

  /// No description provided for @clubPromotionLoadingProblem.
  ///
  /// In en, this message translates to:
  /// **'Error on loading page'**
  String get clubPromotionLoadingProblem;

  /// No description provided for @clubPromotionPicturePreview.
  ///
  /// In en, this message translates to:
  /// **'Picture'**
  String get clubPromotionPicturePreview;

  /// No description provided for @electricityTitle.
  ///
  /// In en, this message translates to:
  /// **'Power Info'**
  String get electricityTitle;

  /// No description provided for @electricityPowerTitle.
  ///
  /// In en, this message translates to:
  /// **'Infomation'**
  String get electricityPowerTitle;

  /// No description provided for @electricityCacheHintLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to log in to the electricity service, showing cached data.'**
  String get electricityCacheHintLoginFailed;

  /// No description provided for @electricityCacheHintNetworkFailed.
  ///
  /// In en, this message translates to:
  /// **'Electricity service network request failed, showing cached data.'**
  String get electricityCacheHintNetworkFailed;

  /// No description provided for @electricityCacheHintUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch the latest electricity data online, showing cached data. Check logs for details.'**
  String get electricityCacheHintUnknownError;

  /// No description provided for @electricityCacheNotice.
  ///
  /// In en, this message translates to:
  /// **'Last fetched'**
  String get electricityCacheNotice;

  /// No description provided for @electricityAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get electricityAccount;

  /// No description provided for @electricityRemainPower.
  ///
  /// In en, this message translates to:
  /// **'Remain power'**
  String get electricityRemainPower;

  /// No description provided for @electricityOweInfo.
  ///
  /// In en, this message translates to:
  /// **'Arrears'**
  String get electricityOweInfo;

  /// No description provided for @electricityHistory.
  ///
  /// In en, this message translates to:
  /// **'Billing History'**
  String get electricityHistory;

  /// No description provided for @electricityDailyUsage.
  ///
  /// In en, this message translates to:
  /// **'Average usage per day'**
  String get electricityDailyUsage;

  /// No description provided for @electricityNotEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data for rendering graph'**
  String get electricityNotEnoughData;

  /// No description provided for @electricityInfo.
  ///
  /// In en, this message translates to:
  /// **'Energy system can be only be accessed at schoolnet, do contact developers if have issue.\nHistory will be recorded locally while average usage is based on the electric meter\'s record.'**
  String get electricityInfo;

  /// No description provided for @electricityFetchingHint.
  ///
  /// In en, this message translates to:
  /// **'Fetching the latest electricity info.'**
  String get electricityFetchingHint;

  /// No description provided for @electricityFetchError.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch electricity information. Please retry.'**
  String get electricityFetchError;

  /// No description provided for @electricityDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get electricityDate;

  /// No description provided for @electricityPower.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get electricityPower;

  /// No description provided for @electricityUpdate.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get electricityUpdate;

  /// No description provided for @electricityWaterUsageFetchDate.
  ///
  /// In en, this message translates to:
  /// **'Fetch time'**
  String get electricityWaterUsageFetchDate;

  /// No description provided for @electricityWaterUsageReadBefore.
  ///
  /// In en, this message translates to:
  /// **'Last time'**
  String get electricityWaterUsageReadBefore;

  /// No description provided for @electricityWaterUsageReadNow.
  ///
  /// In en, this message translates to:
  /// **'This time'**
  String get electricityWaterUsageReadNow;

  /// No description provided for @electricityWaterUsage.
  ///
  /// In en, this message translates to:
  /// **'Bath water usage'**
  String get electricityWaterUsage;

  /// No description provided for @electricityWaterTitle.
  ///
  /// In en, this message translates to:
  /// **'Water usage'**
  String get electricityWaterTitle;

  /// No description provided for @electricityWaterLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading water usage information'**
  String get electricityWaterLoading;

  /// No description provided for @electricityWaterUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Water usage is unavailable. Retry from the electricity card.'**
  String get electricityWaterUnavailable;

  /// No description provided for @electricityWaterEmpty.
  ///
  /// In en, this message translates to:
  /// **'No water usage information'**
  String get electricityWaterEmpty;

  /// No description provided for @electricityNotSchoolNetwork.
  ///
  /// In en, this message translates to:
  /// **'Not school network'**
  String get electricityNotSchoolNetwork;

  /// No description provided for @electricityAirconTitle.
  ///
  /// In en, this message translates to:
  /// **'Aircon Electricity'**
  String get electricityAirconTitle;

  /// No description provided for @electricityAirconImei.
  ///
  /// In en, this message translates to:
  /// **'Aircon IMEI'**
  String get electricityAirconImei;

  /// No description provided for @electricityAirconAmount.
  ///
  /// In en, this message translates to:
  /// **'Platform usage'**
  String get electricityAirconAmount;

  /// No description provided for @electricityAirconUpdateTime.
  ///
  /// In en, this message translates to:
  /// **'Updated at'**
  String get electricityAirconUpdateTime;

  /// No description provided for @electricityAirconWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting to fetch aircon electricity data'**
  String get electricityAirconWaiting;

  /// No description provided for @electricityAirconError.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch aircon electricity data'**
  String get electricityAirconError;

  /// No description provided for @electricityAirconRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get electricityAirconRetry;

  /// No description provided for @electricityAirconImeiMissing.
  ///
  /// In en, this message translates to:
  /// **'Add the aircon IMEI to view its electricity usage.'**
  String get electricityAirconImeiMissing;

  /// No description provided for @electricityAirconAddImei.
  ///
  /// In en, this message translates to:
  /// **'Add aircon IMEI'**
  String get electricityAirconAddImei;

  /// No description provided for @electricityAirconCacheNotice.
  ///
  /// In en, this message translates to:
  /// **'Showing cached aircon data from {time}'**
  String electricityAirconCacheNotice(String time);

  /// No description provided for @emptyClassroomTitle.
  ///
  /// In en, this message translates to:
  /// **'Empty Classrooms'**
  String get emptyClassroomTitle;

  /// No description provided for @emptyClassroomDate.
  ///
  /// In en, this message translates to:
  /// **'Date {date}'**
  String emptyClassroomDate(String date);

  /// No description provided for @emptyClassroomBuilding.
  ///
  /// In en, this message translates to:
  /// **'Building {building}'**
  String emptyClassroomBuilding(String building);

  /// No description provided for @emptyClassroomSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Classroom name or code'**
  String get emptyClassroomSearchHint;

  /// No description provided for @emptyClassroomClassroom.
  ///
  /// In en, this message translates to:
  /// **'Classroom'**
  String get emptyClassroomClassroom;

  /// No description provided for @emptyClassroomEmpty.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get emptyClassroomEmpty;

  /// No description provided for @emptyClassroomOccupied.
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get emptyClassroomOccupied;

  /// No description provided for @examTitle.
  ///
  /// In en, this message translates to:
  /// **'Exam Schedule'**
  String get examTitle;

  /// No description provided for @examCacheHint.
  ///
  /// In en, this message translates to:
  /// **'Displaying cached exam schedule info'**
  String get examCacheHint;

  /// No description provided for @examCacheHintPasswordWrong.
  ///
  /// In en, this message translates to:
  /// **'IDS password is incorrect or expired.'**
  String get examCacheHintPasswordWrong;

  /// No description provided for @examCacheHintLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to log in to the exam service.'**
  String get examCacheHintLoginFailed;

  /// No description provided for @examCacheHintNetworkFailed.
  ///
  /// In en, this message translates to:
  /// **'Network request failed.'**
  String get examCacheHintNetworkFailed;

  /// No description provided for @examCacheHintUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch the latest exam schedule. Check logs for details.'**
  String get examCacheHintUnknownError;

  /// No description provided for @examFetchingHint.
  ///
  /// In en, this message translates to:
  /// **'Fetching the latest exam schedule.'**
  String get examFetchingHint;

  /// No description provided for @examNotFinished.
  ///
  /// In en, this message translates to:
  /// **'Still there are some bad guys here.'**
  String get examNotFinished;

  /// No description provided for @examAllFinished.
  ///
  /// In en, this message translates to:
  /// **'Say goodbye to all the exams.'**
  String get examAllFinished;

  /// No description provided for @examUnableToExam.
  ///
  /// In en, this message translates to:
  /// **'Unable to exam'**
  String get examUnableToExam;

  /// No description provided for @examFinished.
  ///
  /// In en, this message translates to:
  /// **'All exams '**
  String get examFinished;

  /// No description provided for @examNoneFinished.
  ///
  /// In en, this message translates to:
  /// **'No exams have been completed'**
  String get examNoneFinished;

  /// No description provided for @examNoExamArrangement.
  ///
  /// In en, this message translates to:
  /// **'No exam has been arranged currently'**
  String get examNoExamArrangement;

  /// No description provided for @examNoArrangementTitle.
  ///
  /// In en, this message translates to:
  /// **'Not arranged exams'**
  String get examNoArrangementTitle;

  /// No description provided for @examNoArrangementAllArranged.
  ///
  /// In en, this message translates to:
  /// **'Exams have been scheduled for all subjects'**
  String get examNoArrangementAllArranged;

  /// No description provided for @examNoArrangementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Code: {id}'**
  String examNoArrangementSubtitle(String id);

  /// No description provided for @experimentTitle.
  ///
  /// In en, this message translates to:
  /// **'Experiment Info'**
  String get experimentTitle;

  /// No description provided for @experimentOngoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing experiment'**
  String get experimentOngoing;

  /// No description provided for @experimentNotFinished.
  ///
  /// In en, this message translates to:
  /// **'Experiments to be done'**
  String get experimentNotFinished;

  /// No description provided for @experimentAllFinished.
  ///
  /// In en, this message translates to:
  /// **'All experiments have been completed'**
  String get experimentAllFinished;

  /// No description provided for @experimentFinished.
  ///
  /// In en, this message translates to:
  /// **'Completed experiments'**
  String get experimentFinished;

  /// No description provided for @experimentScoreInfo.
  ///
  /// In en, this message translates to:
  /// **'{score} (predicted)'**
  String experimentScoreInfo(String score);

  /// No description provided for @experimentScoreSum.
  ///
  /// In en, this message translates to:
  /// **'Total score: {sum}'**
  String experimentScoreSum(String sum);

  /// No description provided for @experimentNoneFinished.
  ///
  /// In en, this message translates to:
  /// **'None of the experiments have been completed'**
  String get experimentNoneFinished;

  /// No description provided for @experimentNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get experimentNotProvided;

  /// No description provided for @experimentErrorPhysics.
  ///
  /// In en, this message translates to:
  /// **'Error on fetching physics experiments: {info}'**
  String experimentErrorPhysics(String info);

  /// No description provided for @experimentErrorOther.
  ///
  /// In en, this message translates to:
  /// **'Error on fetching other experiments: {info}'**
  String experimentErrorOther(String info);

  /// No description provided for @experimentCacheHint.
  ///
  /// In en, this message translates to:
  /// **'Loaded cache: {info}'**
  String experimentCacheHint(String info);

  /// No description provided for @experimentPhysicsCacheHintMissingPassword.
  ///
  /// In en, this message translates to:
  /// **'Physics experiment password is not set.'**
  String get experimentPhysicsCacheHintMissingPassword;

  /// No description provided for @experimentPhysicsCacheHintLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Physics experiment login failed.'**
  String get experimentPhysicsCacheHintLoginFailed;

  /// No description provided for @experimentPhysicsCacheHintNotSchoolNetwork.
  ///
  /// In en, this message translates to:
  /// **'Not on the campus network.'**
  String get experimentPhysicsCacheHintNotSchoolNetwork;

  /// No description provided for @experimentPhysicsCacheHintNetworkFailed.
  ///
  /// In en, this message translates to:
  /// **'Physics experiment network request failed.'**
  String get experimentPhysicsCacheHintNetworkFailed;

  /// No description provided for @experimentPhysicsCacheHintUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch physics experiments online. Check logs for details.'**
  String get experimentPhysicsCacheHintUnknownError;

  /// No description provided for @experimentOtherCacheHintLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Other experiment login failed.'**
  String get experimentOtherCacheHintLoginFailed;

  /// No description provided for @experimentOtherCacheHintNotSchoolNetwork.
  ///
  /// In en, this message translates to:
  /// **'Not on the campus network.'**
  String get experimentOtherCacheHintNotSchoolNetwork;

  /// No description provided for @experimentOtherCacheHintNetworkFailed.
  ///
  /// In en, this message translates to:
  /// **'Other experiment network request failed.'**
  String get experimentOtherCacheHintNetworkFailed;

  /// No description provided for @experimentOtherCacheHintUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch other experiments online. Check logs for details.'**
  String get experimentOtherCacheHintUnknownError;

  /// No description provided for @experimentPhysicsExperiment.
  ///
  /// In en, this message translates to:
  /// **'physics experiments'**
  String get experimentPhysicsExperiment;

  /// No description provided for @experimentOtherExperiment.
  ///
  /// In en, this message translates to:
  /// **'other experiments'**
  String get experimentOtherExperiment;

  /// No description provided for @experimentTapForScore.
  ///
  /// In en, this message translates to:
  /// **'Failed to detect the score'**
  String get experimentTapForScore;

  /// No description provided for @experimentYourScore.
  ///
  /// In en, this message translates to:
  /// **'Your Score: '**
  String get experimentYourScore;

  /// No description provided for @experimentPredictScore.
  ///
  /// In en, this message translates to:
  /// **'Predict score: {score}'**
  String experimentPredictScore(String score);

  /// No description provided for @experimentSendMail.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get experimentSendMail;

  /// No description provided for @experimentFetchingHint.
  ///
  /// In en, this message translates to:
  /// **'The data you see is from cache. Updating is running in the background...'**
  String get experimentFetchingHint;

  /// No description provided for @experimentFetchingHintBoth.
  ///
  /// In en, this message translates to:
  /// **'Physics experiments and other experiments are loading'**
  String get experimentFetchingHintBoth;

  /// No description provided for @experimentFetchingHintPhysics.
  ///
  /// In en, this message translates to:
  /// **'Physics experiments are loading'**
  String get experimentFetchingHintPhysics;

  /// No description provided for @experimentFetchingHintOther.
  ///
  /// In en, this message translates to:
  /// **'Other experiments are loading'**
  String get experimentFetchingHintOther;

  /// No description provided for @experimentFetchingHintPhysicsWithOtherFailed.
  ///
  /// In en, this message translates to:
  /// **'Physics experiments are loading, while other experiments failed to load'**
  String get experimentFetchingHintPhysicsWithOtherFailed;

  /// No description provided for @experimentFetchingHintOtherWithPhysicsFailed.
  ///
  /// In en, this message translates to:
  /// **'Other experiments are loading, while physics experiments failed to load'**
  String get experimentFetchingHintOtherWithPhysicsFailed;

  /// No description provided for @experimentScoreHint0.
  ///
  /// In en, this message translates to:
  /// **'You can tap on the score info on the score card to check out the original score data'**
  String get experimentScoreHint0;

  /// No description provided for @experimentScoreHint1.
  ///
  /// In en, this message translates to:
  /// **'Your score is not in the XDYou score recognition database, so it was not recognized properly.'**
  String get experimentScoreHint1;

  /// No description provided for @experimentScoreHint2.
  ///
  /// In en, this message translates to:
  /// **'If you wish to contribute to the development of XDYou, you can click the send email button, and we will add your score to the recognition database!'**
  String get experimentScoreHint2;

  /// No description provided for @experimentScoreHint3.
  ///
  /// In en, this message translates to:
  /// **'Due to the lack of data for recognization, it is necessary to check twice.'**
  String get experimentScoreHint3;

  /// No description provided for @homepageTitle.
  ///
  /// In en, this message translates to:
  /// **'School Info Center'**
  String get homepageTitle;

  /// No description provided for @homepageLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get homepageLoading;

  /// No description provided for @homepageLoaded.
  ///
  /// In en, this message translates to:
  /// **'Message updated'**
  String get homepageLoaded;

  /// No description provided for @homepageLoadError.
  ///
  /// In en, this message translates to:
  /// **'Something wrong'**
  String get homepageLoadError;

  /// No description provided for @homepageOnHoliday.
  ///
  /// In en, this message translates to:
  /// **'Currently on holiday'**
  String get homepageOnHoliday;

  /// No description provided for @homepageOnWeekday.
  ///
  /// In en, this message translates to:
  /// **'Currently week {current}'**
  String homepageOnWeekday(String current);

  /// No description provided for @homepageLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Refreshing information...'**
  String get homepageLoadingMessage;

  /// No description provided for @homepagePostgraduateNotice.
  ///
  /// In en, this message translates to:
  /// **'Postgraduate features activated!'**
  String get homepagePostgraduateNotice;

  /// No description provided for @homepageLinuxNotice.
  ///
  /// In en, this message translates to:
  /// **'Linux version is under testing, feel free to feedback!'**
  String get homepageLinuxNotice;

  /// No description provided for @homepageEditMode.
  ///
  /// In en, this message translates to:
  /// **'Edit Layout'**
  String get homepageEditMode;

  /// No description provided for @homepageEditDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get homepageEditDone;

  /// No description provided for @homepageEditReset.
  ///
  /// In en, this message translates to:
  /// **'Reset Layout'**
  String get homepageEditReset;

  /// No description provided for @homepageEditHint.
  ///
  /// In en, this message translates to:
  /// **'Schedule and update cards cannot be edited'**
  String get homepageEditHint;

  /// No description provided for @homepageManageHidden.
  ///
  /// In en, this message translates to:
  /// **'Manage hidden cards'**
  String get homepageManageHidden;

  /// No description provided for @homepageHiddenTitle.
  ///
  /// In en, this message translates to:
  /// **'Hidden cards'**
  String get homepageHiddenTitle;

  /// No description provided for @homepageHiddenLabel.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get homepageHiddenLabel;

  /// No description provided for @homepageHideEmpty.
  ///
  /// In en, this message translates to:
  /// **'No hidden cards'**
  String get homepageHideEmpty;

  /// No description provided for @homepageHomepage.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get homepageHomepage;

  /// No description provided for @homepageRuisi.
  ///
  /// In en, this message translates to:
  /// **'Forum'**
  String get homepageRuisi;

  /// No description provided for @homepageClub.
  ///
  /// In en, this message translates to:
  /// **'Club'**
  String get homepageClub;

  /// No description provided for @homepagePlanet.
  ///
  /// In en, this message translates to:
  /// **'Blog'**
  String get homepagePlanet;

  /// No description provided for @homepageDashboard.
  ///
  /// In en, this message translates to:
  /// **'Pighub'**
  String get homepageDashboard;

  /// No description provided for @homepageSetting.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homepageSetting;

  /// No description provided for @homepageInputPartnerDataRouteNotExist.
  ///
  /// In en, this message translates to:
  /// **'Import path does not exist:P'**
  String get homepageInputPartnerDataRouteNotExist;

  /// No description provided for @homepageInputPartnerDataFailedGetFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to import file'**
  String get homepageInputPartnerDataFailedGetFile;

  /// No description provided for @homepageInputPartnerDataFailedImport.
  ///
  /// In en, this message translates to:
  /// **'Maybe there is a problem with the import file:P'**
  String get homepageInputPartnerDataFailedImport;

  /// No description provided for @homepageInputPartnerDataSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Import successful, if the class schedule page is open, please reopen it'**
  String get homepageInputPartnerDataSuccessMessage;

  /// No description provided for @homepageInputPartnerDataNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Class schedule has not been loaded yet, please try again later...'**
  String get homepageInputPartnerDataNotLoaded;

  /// No description provided for @homepageInputPartnerDataConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'There is currently partner class schedule data, do you want to overwrite?'**
  String get homepageInputPartnerDataConfirmContent;

  /// No description provided for @homepageLoginMessage.
  ///
  /// In en, this message translates to:
  /// **'Logging in, currently displaying cached data'**
  String get homepageLoginMessage;

  /// No description provided for @homepageSuccessfulLoginMessage.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get homepageSuccessfulLoginMessage;

  /// No description provided for @homepagePasswordWrongTitle.
  ///
  /// In en, this message translates to:
  /// **'Wrong username or password'**
  String get homepagePasswordWrongTitle;

  /// No description provided for @homepagePasswordWrongContent.
  ///
  /// In en, this message translates to:
  /// **'Restart the app and log in manually?'**
  String get homepagePasswordWrongContent;

  /// No description provided for @homepagePasswordWrongDenial.
  ///
  /// In en, this message translates to:
  /// **'No, enter offline mode'**
  String get homepagePasswordWrongDenial;

  /// No description provided for @homepageOfflineModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Uniform Authentication Service offline mode activated'**
  String get homepageOfflineModeTitle;

  /// No description provided for @homepageOfflineModeContent.
  ///
  /// In en, this message translates to:
  /// **'\"Unable to connect to the Unified Authentication Service server, all related services are temporarily unavailable.\nScore inquiry, exam information inquiry, overdue fee inquiry, campus card inquiry are closed. The schedule displays cached data. Other functions are temporarily not affected.\nWe apologize for any inconvenience caused.\"\n'**
  String get homepageOfflineModeContent;

  /// No description provided for @homepageOfflineMode.
  ///
  /// In en, this message translates to:
  /// **'In offline mode, all one-stop related functions are disabled'**
  String get homepageOfflineMode;

  /// No description provided for @homepageNoticeCardEmptyNotice.
  ///
  /// In en, this message translates to:
  /// **'No application announcements retrieved, please refresh'**
  String get homepageNoticeCardEmptyNotice;

  /// No description provided for @homepageNoticeCardNoNoticeAvaliable.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch the application announcements'**
  String get homepageNoticeCardNoNoticeAvaliable;

  /// No description provided for @homepageNoticeCardNoticeListTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get homepageNoticeCardNoticeListTitle;

  /// No description provided for @homepageNoticeCardOpenUrl.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get homepageNoticeCardOpenUrl;

  /// No description provided for @homepageNoticeCardNoticePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification List'**
  String get homepageNoticeCardNoticePageTitle;

  /// No description provided for @homepageClassTableCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Timetable'**
  String get homepageClassTableCardTitle;

  /// No description provided for @homepageClassTableCardToday.
  ///
  /// In en, this message translates to:
  /// **'{remain} arrangment(s) today'**
  String homepageClassTableCardToday(String remain);

  /// No description provided for @homepageClassTableCardTodayFinished.
  ///
  /// In en, this message translates to:
  /// **'Arrangements all done today'**
  String get homepageClassTableCardTodayFinished;

  /// No description provided for @homepageClassTableCardTomorrow.
  ///
  /// In en, this message translates to:
  /// **'{remain} arrangment(s) tomorrow'**
  String homepageClassTableCardTomorrow(String remain);

  /// No description provided for @homepageClassTableCardTomorrowNone.
  ///
  /// In en, this message translates to:
  /// **'No arrangement tomorrow'**
  String get homepageClassTableCardTomorrowNone;

  /// No description provided for @homepageClassTableCardWeekInfo.
  ///
  /// In en, this message translates to:
  /// **'Week {weekinfo}'**
  String homepageClassTableCardWeekInfo(String weekinfo);

  /// No description provided for @homepageClassTableCardOnHoliday.
  ///
  /// In en, this message translates to:
  /// **'On vacation'**
  String get homepageClassTableCardOnHoliday;

  /// No description provided for @homepageClassTableCardErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String homepageClassTableCardErrorMessage(String error);

  /// No description provided for @homepageClassTableCardFetchingMessage.
  ///
  /// In en, this message translates to:
  /// **'Fetching class schedule'**
  String get homepageClassTableCardFetchingMessage;

  /// No description provided for @homepageClassTableCardErrorInfotext.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get homepageClassTableCardErrorInfotext;

  /// No description provided for @homepageClassTableCardFetchingInfotext.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get homepageClassTableCardFetchingInfotext;

  /// No description provided for @homepageClassTableCardNoArrangementInfotext.
  ///
  /// In en, this message translates to:
  /// **'No schedule at the moment'**
  String get homepageClassTableCardNoArrangementInfotext;

  /// No description provided for @homepageClassTableCardScheduleFetchingMessage.
  ///
  /// In en, this message translates to:
  /// **'Schedule is loading, please check again soon'**
  String get homepageClassTableCardScheduleFetchingMessage;

  /// No description provided for @homepageClassTableCardScheduleErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load schedule, please try again later'**
  String get homepageClassTableCardScheduleErrorMessage;

  /// No description provided for @homepageClassTableCardScheduleFetchingInfotext.
  ///
  /// In en, this message translates to:
  /// **'Loading schedule'**
  String get homepageClassTableCardScheduleFetchingInfotext;

  /// No description provided for @homepageClassTableCardScheduleErrorInfotext.
  ///
  /// In en, this message translates to:
  /// **'Failed to load schedule'**
  String get homepageClassTableCardScheduleErrorInfotext;

  /// No description provided for @homepageClassTableCardScheduleNoneInfotext.
  ///
  /// In en, this message translates to:
  /// **'No schedule available'**
  String get homepageClassTableCardScheduleNoneInfotext;

  /// No description provided for @homepageClassTableCardUpdatingInfotext.
  ///
  /// In en, this message translates to:
  /// **'Updating'**
  String get homepageClassTableCardUpdatingInfotext;

  /// No description provided for @homepageClassTableCardAllLoadingInfotext.
  ///
  /// In en, this message translates to:
  /// **'All sources loading'**
  String get homepageClassTableCardAllLoadingInfotext;

  /// No description provided for @homepageClassTableCardPartialLoadingInfotext.
  ///
  /// In en, this message translates to:
  /// **'Partially loading'**
  String get homepageClassTableCardPartialLoadingInfotext;

  /// No description provided for @homepageClassTableCardPartialErrorInfotext.
  ///
  /// In en, this message translates to:
  /// **'Some data failed to load'**
  String get homepageClassTableCardPartialErrorInfotext;

  /// No description provided for @homepageClassTableCardFailedChip.
  ///
  /// In en, this message translates to:
  /// **'{source} failed'**
  String homepageClassTableCardFailedChip(String source);

  /// No description provided for @homepageClassTableCardFailedSourceClassInfo.
  ///
  /// In en, this message translates to:
  /// **'Class info'**
  String get homepageClassTableCardFailedSourceClassInfo;

  /// No description provided for @homepageClassTableCardFailedSourceExamInfo.
  ///
  /// In en, this message translates to:
  /// **'Exam info'**
  String get homepageClassTableCardFailedSourceExamInfo;

  /// No description provided for @homepageClassTableCardFailedSourcePhysicsExperiment.
  ///
  /// In en, this message translates to:
  /// **'Physics experiment'**
  String get homepageClassTableCardFailedSourcePhysicsExperiment;

  /// No description provided for @homepageClassTableCardFailedSourceOtherExperiment.
  ///
  /// In en, this message translates to:
  /// **'Other experiment'**
  String get homepageClassTableCardFailedSourceOtherExperiment;

  /// No description provided for @homepageClassTableCardUnknownPlace.
  ///
  /// In en, this message translates to:
  /// **'Unknown place'**
  String get homepageClassTableCardUnknownPlace;

  /// No description provided for @homepageClassTableCardSeat.
  ///
  /// In en, this message translates to:
  /// **'Seat {seatnum}'**
  String homepageClassTableCardSeat(String seatnum);

  /// No description provided for @homepageElectricityCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Electricity and Hydroenergy Information'**
  String get homepageElectricityCardTitle;

  /// No description provided for @homepageElectricityCardCurrentElectricity.
  ///
  /// In en, this message translates to:
  /// **'{amount} kWh remains'**
  String homepageElectricityCardCurrentElectricity(String amount);

  /// No description provided for @homepageElectricityCardCacheNotice.
  ///
  /// In en, this message translates to:
  /// **'Last fetch date: {date}'**
  String homepageElectricityCardCacheNotice(String date);

  /// No description provided for @homepageLibraryCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Library Info'**
  String get homepageLibraryCardTitle;

  /// No description provided for @homepageLibraryCardCurrentBorrow.
  ///
  /// In en, this message translates to:
  /// **'Borrowing {count} book(s)'**
  String homepageLibraryCardCurrentBorrow(String count);

  /// No description provided for @homepageLibraryCardErrorOccured.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while retrieving borrowing information'**
  String get homepageLibraryCardErrorOccured;

  /// No description provided for @homepageLibraryCardFetching.
  ///
  /// In en, this message translates to:
  /// **'Fetching borrowing information'**
  String get homepageLibraryCardFetching;

  /// No description provided for @homepageLibraryCardNoReturn.
  ///
  /// In en, this message translates to:
  /// **'Currently there\'s no book to be returned'**
  String get homepageLibraryCardNoReturn;

  /// No description provided for @homepageLibraryCardNeedReturn.
  ///
  /// In en, this message translates to:
  /// **'Need to return {dued} books'**
  String homepageLibraryCardNeedReturn(String dued);

  /// No description provided for @homepageLibraryCardNoInfo.
  ///
  /// In en, this message translates to:
  /// **'Cannot retrieve information at the moment'**
  String get homepageLibraryCardNoInfo;

  /// No description provided for @homepageLibraryCardFetchingInfo.
  ///
  /// In en, this message translates to:
  /// **'Fetching information...'**
  String get homepageLibraryCardFetchingInfo;

  /// No description provided for @homepageSchoolCardInfoCardErrorToast.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, please contact the developer'**
  String get homepageSchoolCardInfoCardErrorToast;

  /// No description provided for @homepageSchoolCardInfoCardFetchingToast.
  ///
  /// In en, this message translates to:
  /// **'Fetching information, please check later'**
  String get homepageSchoolCardInfoCardFetchingToast;

  /// No description provided for @homepageSchoolCardInfoCardBill.
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get homepageSchoolCardInfoCardBill;

  /// No description provided for @homepageSchoolCardInfoCardBalance.
  ///
  /// In en, this message translates to:
  /// **'Remain {amount} RMB'**
  String homepageSchoolCardInfoCardBalance(String amount);

  /// No description provided for @homepageSchoolCardInfoCardErrorOccured.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while retrieving campus card information'**
  String get homepageSchoolCardInfoCardErrorOccured;

  /// No description provided for @homepageSchoolCardInfoCardFetching.
  ///
  /// In en, this message translates to:
  /// **'Fetching campus card information'**
  String get homepageSchoolCardInfoCardFetching;

  /// No description provided for @homepageSchoolCardInfoCardBottomTextSuccess.
  ///
  /// In en, this message translates to:
  /// **'Query campus card bill'**
  String get homepageSchoolCardInfoCardBottomTextSuccess;

  /// No description provided for @homepageSchoolCardInfoCardNoInfo.
  ///
  /// In en, this message translates to:
  /// **'Cannot retrieve information currently'**
  String get homepageSchoolCardInfoCardNoInfo;

  /// No description provided for @homepageSchoolCardInfoCardFetchingInfo.
  ///
  /// In en, this message translates to:
  /// **'Fetching information...'**
  String get homepageSchoolCardInfoCardFetchingInfo;

  /// No description provided for @homepageToolboxClassAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendances'**
  String get homepageToolboxClassAttendance;

  /// No description provided for @homepageToolboxCreative.
  ///
  /// In en, this message translates to:
  /// **'Innovation and Entrepreneurship Competition'**
  String get homepageToolboxCreative;

  /// No description provided for @homepageToolboxEmptyClassroom.
  ///
  /// In en, this message translates to:
  /// **'Classrooms'**
  String get homepageToolboxEmptyClassroom;

  /// No description provided for @homepageToolboxExam.
  ///
  /// In en, this message translates to:
  /// **'Exams'**
  String get homepageToolboxExam;

  /// No description provided for @homepageToolboxExperiment.
  ///
  /// In en, this message translates to:
  /// **'Experiments'**
  String get homepageToolboxExperiment;

  /// No description provided for @homepageToolboxScore.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get homepageToolboxScore;

  /// No description provided for @homepageToolboxSport.
  ///
  /// In en, this message translates to:
  /// **'PE Info'**
  String get homepageToolboxSport;

  /// No description provided for @homepageToolboxDormWater.
  ///
  /// In en, this message translates to:
  /// **'Dorm Water'**
  String get homepageToolboxDormWater;

  /// No description provided for @homepageToolboxSchoolnet.
  ///
  /// In en, this message translates to:
  /// **'Schoolnet Usage'**
  String get homepageToolboxSchoolnet;

  /// No description provided for @homepageToolboxToolbox.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get homepageToolboxToolbox;

  /// No description provided for @homepageToolboxScoreCannotReach.
  ///
  /// In en, this message translates to:
  /// **'Offline mode with no cached score data, unable to access'**
  String get homepageToolboxScoreCannotReach;

  /// No description provided for @homepageToolboxExamFetching.
  ///
  /// In en, this message translates to:
  /// **'Fetching exam information, please wait'**
  String get homepageToolboxExamFetching;

  /// No description provided for @homepageToolboxExamError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, please contact the developer'**
  String get homepageToolboxExamError;

  /// No description provided for @homepageSchoolNetTitle.
  ///
  /// In en, this message translates to:
  /// **'Used {usage}'**
  String homepageSchoolNetTitle(String usage);

  /// No description provided for @homepageSchoolNetNoPassword.
  ///
  /// In en, this message translates to:
  /// **'The query password is not set, click to set up'**
  String get homepageSchoolNetNoPassword;

  /// No description provided for @homepageSchoolNetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to get the school net usage info'**
  String get homepageSchoolNetFailed;

  /// No description provided for @homepageSchoolNetFetching.
  ///
  /// In en, this message translates to:
  /// **'Fetching the school net usage info'**
  String get homepageSchoolNetFetching;

  /// No description provided for @homepageSchoolNetRemaining.
  ///
  /// In en, this message translates to:
  /// **'Clearing at {remaining}'**
  String homepageSchoolNetRemaining(String remaining);

  /// No description provided for @homepageClubPromotionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch club info'**
  String get homepageClubPromotionFailed;

  /// No description provided for @homepageClubPromotionFetching.
  ///
  /// In en, this message translates to:
  /// **'Fetching club info'**
  String get homepageClubPromotionFetching;

  /// No description provided for @dormWaterTitle.
  ///
  /// In en, this message translates to:
  /// **'Dorm Water'**
  String get dormWaterTitle;

  /// No description provided for @dormWaterPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get dormWaterPhone;

  /// No description provided for @dormWaterImageCode.
  ///
  /// In en, this message translates to:
  /// **'Image code'**
  String get dormWaterImageCode;

  /// No description provided for @dormWaterSmsCode.
  ///
  /// In en, this message translates to:
  /// **'SMS code'**
  String get dormWaterSmsCode;

  /// No description provided for @dormWaterSendSms.
  ///
  /// In en, this message translates to:
  /// **'Send SMS'**
  String get dormWaterSendSms;

  /// No description provided for @dormWaterLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get dormWaterLogin;

  /// No description provided for @dormWaterLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get dormWaterLogout;

  /// No description provided for @dormWaterRefreshCaptcha.
  ///
  /// In en, this message translates to:
  /// **'Refresh Captcha'**
  String get dormWaterRefreshCaptcha;

  /// No description provided for @dormWaterLoadingCaptcha.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get dormWaterLoadingCaptcha;

  /// No description provided for @dormWaterCaptchaError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load captcha'**
  String get dormWaterCaptchaError;

  /// No description provided for @dormWaterPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get dormWaterPhoneRequired;

  /// No description provided for @dormWaterImageCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter image code'**
  String get dormWaterImageCodeRequired;

  /// No description provided for @dormWaterSmsSent.
  ///
  /// In en, this message translates to:
  /// **'SMS sent successfully'**
  String get dormWaterSmsSent;

  /// No description provided for @dormWaterSmsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send SMS'**
  String get dormWaterSmsFailed;

  /// No description provided for @dormWaterSmsCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter SMS code'**
  String get dormWaterSmsCodeRequired;

  /// No description provided for @dormWaterLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get dormWaterLoginSuccess;

  /// No description provided for @dormWaterLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get dormWaterLoginFailed;

  /// No description provided for @dormWaterLogoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get dormWaterLogoutSuccess;

  /// No description provided for @dormWaterDevices.
  ///
  /// In en, this message translates to:
  /// **'Device List'**
  String get dormWaterDevices;

  /// No description provided for @dormWaterLoadingDevices.
  ///
  /// In en, this message translates to:
  /// **'Loading devices...'**
  String get dormWaterLoadingDevices;

  /// No description provided for @dormWaterNoDevices.
  ///
  /// In en, this message translates to:
  /// **'No devices'**
  String get dormWaterNoDevices;

  /// No description provided for @dormWaterSelectDevice.
  ///
  /// In en, this message translates to:
  /// **'Select Device'**
  String get dormWaterSelectDevice;

  /// No description provided for @dormWaterFetchDevicesFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch device list'**
  String get dormWaterFetchDevicesFailed;

  /// No description provided for @dormWaterRetryLoadDevices.
  ///
  /// In en, this message translates to:
  /// **'Retry Loading'**
  String get dormWaterRetryLoadDevices;

  /// No description provided for @dormWaterStartWater.
  ///
  /// In en, this message translates to:
  /// **'Start Water'**
  String get dormWaterStartWater;

  /// No description provided for @dormWaterEndWater.
  ///
  /// In en, this message translates to:
  /// **'End Water'**
  String get dormWaterEndWater;

  /// No description provided for @dormWaterWaterDispensing.
  ///
  /// In en, this message translates to:
  /// **'Water Dispensing'**
  String get dormWaterWaterDispensing;

  /// No description provided for @dormWaterWaterStatus.
  ///
  /// In en, this message translates to:
  /// **'Water Status'**
  String get dormWaterWaterStatus;

  /// No description provided for @dormWaterStartWaterSuccess.
  ///
  /// In en, this message translates to:
  /// **'Water dispensing started'**
  String get dormWaterStartWaterSuccess;

  /// No description provided for @dormWaterEndWaterSuccess.
  ///
  /// In en, this message translates to:
  /// **'Water dispensing ended'**
  String get dormWaterEndWaterSuccess;

  /// No description provided for @dormWaterStartWaterFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to start water'**
  String get dormWaterStartWaterFailed;

  /// No description provided for @dormWaterEndWaterFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to end water'**
  String get dormWaterEndWaterFailed;

  /// No description provided for @dormWaterDeviceStatusChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking device status...'**
  String get dormWaterDeviceStatusChecking;

  /// No description provided for @dormWaterDeviceStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Device ready'**
  String get dormWaterDeviceStatusReady;

  /// No description provided for @dormWaterScanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get dormWaterScanQrCode;

  /// No description provided for @dormWaterDeviceId.
  ///
  /// In en, this message translates to:
  /// **'Device ID'**
  String get dormWaterDeviceId;

  /// No description provided for @dormWaterAddDeviceFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add device'**
  String get dormWaterAddDeviceFailed;

  /// No description provided for @dormWaterDeviceRemovedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Device removed from favorites'**
  String get dormWaterDeviceRemovedFromFavorites;

  /// No description provided for @dormWaterRemoveFromFavoritesFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove from favorites'**
  String get dormWaterRemoveFromFavoritesFailed;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library Information'**
  String get libraryTitle;

  /// No description provided for @libraryBorrowStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Borrowing Status'**
  String get libraryBorrowStateTitle;

  /// No description provided for @librarySearchBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Books'**
  String get librarySearchBookTitle;

  /// No description provided for @librarySearchFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Field'**
  String get librarySearchFieldTitle;

  /// No description provided for @librarySearchFieldKeywordOption.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get librarySearchFieldKeywordOption;

  /// No description provided for @librarySearchFieldTitleOption.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get librarySearchFieldTitleOption;

  /// No description provided for @librarySearchFieldAuthorOption.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get librarySearchFieldAuthorOption;

  /// No description provided for @librarySearchFieldIsbnOption.
  ///
  /// In en, this message translates to:
  /// **'ISBN'**
  String get librarySearchFieldIsbnOption;

  /// No description provided for @librarySearchFieldBarcodeOption.
  ///
  /// In en, this message translates to:
  /// **'Bar Code'**
  String get librarySearchFieldBarcodeOption;

  /// No description provided for @librarySearchFieldCallnoOption.
  ///
  /// In en, this message translates to:
  /// **'Call No'**
  String get librarySearchFieldCallnoOption;

  /// No description provided for @libraryNotProvided.
  ///
  /// In en, this message translates to:
  /// **'No information provided'**
  String get libraryNotProvided;

  /// No description provided for @libraryAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author '**
  String get libraryAuthor;

  /// No description provided for @libraryPublishHouse.
  ///
  /// In en, this message translates to:
  /// **'Publisher '**
  String get libraryPublishHouse;

  /// No description provided for @libraryCallNumber.
  ///
  /// In en, this message translates to:
  /// **'Call Number '**
  String get libraryCallNumber;

  /// No description provided for @libraryPublishDate.
  ///
  /// In en, this message translates to:
  /// **'Publication Date'**
  String get libraryPublishDate;

  /// No description provided for @libraryIsbn.
  ///
  /// In en, this message translates to:
  /// **'ISBN'**
  String get libraryIsbn;

  /// No description provided for @libraryArrangementCode.
  ///
  /// In en, this message translates to:
  /// **'Arrangement Code '**
  String get libraryArrangementCode;

  /// No description provided for @libraryAvaliableBorrow.
  ///
  /// In en, this message translates to:
  /// **'Available to borrow'**
  String get libraryAvaliableBorrow;

  /// No description provided for @libraryStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get libraryStorage;

  /// No description provided for @libraryOnShelve.
  ///
  /// In en, this message translates to:
  /// **'On shelf'**
  String get libraryOnShelve;

  /// No description provided for @libraryBookCode.
  ///
  /// In en, this message translates to:
  /// **'Book code: {barCode}'**
  String libraryBookCode(String barCode);

  /// No description provided for @libraryDueDate.
  ///
  /// In en, this message translates to:
  /// **' Due date'**
  String get libraryDueDate;

  /// No description provided for @libraryBorrowStr.
  ///
  /// In en, this message translates to:
  /// **' Borrow'**
  String get libraryBorrowStr;

  /// No description provided for @libraryAfterDueDate.
  ///
  /// In en, this message translates to:
  /// **' day(s) overdue'**
  String get libraryAfterDueDate;

  /// No description provided for @libraryBeforeDueDate.
  ///
  /// In en, this message translates to:
  /// **' day(s) left'**
  String get libraryBeforeDueDate;

  /// No description provided for @libraryCanBeRenewable.
  ///
  /// In en, this message translates to:
  /// **'Renewable'**
  String get libraryCanBeRenewable;

  /// No description provided for @libraryCannotBeRenewable.
  ///
  /// In en, this message translates to:
  /// **'Not renewable'**
  String get libraryCannotBeRenewable;

  /// No description provided for @libraryRenewing.
  ///
  /// In en, this message translates to:
  /// **'Renewing'**
  String get libraryRenewing;

  /// No description provided for @libraryEmptyBorrowList.
  ///
  /// In en, this message translates to:
  /// **'No borrowed books found'**
  String get libraryEmptyBorrowList;

  /// No description provided for @libraryBorrowListInfo.
  ///
  /// In en, this message translates to:
  /// **'Borrowing {borrow} book(s), among which {dued} book(s) have expired'**
  String libraryBorrowListInfo(String borrow, String dued);

  /// No description provided for @librarySearchHere.
  ///
  /// In en, this message translates to:
  /// **'Search here'**
  String get librarySearchHere;

  /// No description provided for @libraryNormalSearch.
  ///
  /// In en, this message translates to:
  /// **'Normal Search'**
  String get libraryNormalSearch;

  /// No description provided for @libraryAdvancedSearch.
  ///
  /// In en, this message translates to:
  /// **'Advanced Search'**
  String get libraryAdvancedSearch;

  /// No description provided for @librarySearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get librarySearch;

  /// No description provided for @libraryMatchMode.
  ///
  /// In en, this message translates to:
  /// **'Match Mode'**
  String get libraryMatchMode;

  /// No description provided for @libraryMatchExact.
  ///
  /// In en, this message translates to:
  /// **'Exact'**
  String get libraryMatchExact;

  /// No description provided for @libraryMatchFuzzy.
  ///
  /// In en, this message translates to:
  /// **'Fuzzy'**
  String get libraryMatchFuzzy;

  /// No description provided for @libraryMatchPrefix.
  ///
  /// In en, this message translates to:
  /// **'Prefix'**
  String get libraryMatchPrefix;

  /// No description provided for @libraryDocumentType.
  ///
  /// In en, this message translates to:
  /// **'Document Type'**
  String get libraryDocumentType;

  /// No description provided for @libraryDocumentTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get libraryDocumentTypeAll;

  /// No description provided for @libraryDocumentTypeBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get libraryDocumentTypeBook;

  /// No description provided for @libraryOnlyOnShelf.
  ///
  /// In en, this message translates to:
  /// **'Only on shelf'**
  String get libraryOnlyOnShelf;

  /// No description provided for @libraryPublishYearBegin.
  ///
  /// In en, this message translates to:
  /// **'Publish year from'**
  String get libraryPublishYearBegin;

  /// No description provided for @libraryPublishYearEnd.
  ///
  /// In en, this message translates to:
  /// **'Publish year to'**
  String get libraryPublishYearEnd;

  /// No description provided for @libraryBookDetail.
  ///
  /// In en, this message translates to:
  /// **'Book details'**
  String get libraryBookDetail;

  /// No description provided for @libraryNoResult.
  ///
  /// In en, this message translates to:
  /// **'No result, change parameter or start your search'**
  String get libraryNoResult;

  /// No description provided for @libraryCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Library status'**
  String get libraryCardTitle;

  /// No description provided for @libraryCardFetching.
  ///
  /// In en, this message translates to:
  /// **'Fetching'**
  String get libraryCardFetching;

  /// No description provided for @libraryCardNorthernLibrary.
  ///
  /// In en, this message translates to:
  /// **'Northern Library'**
  String get libraryCardNorthernLibrary;

  /// No description provided for @libraryCardSouthernLibrary.
  ///
  /// In en, this message translates to:
  /// **'Southern Library'**
  String get libraryCardSouthernLibrary;

  /// No description provided for @libraryCardPeople.
  ///
  /// In en, this message translates to:
  /// **'People: {people}'**
  String libraryCardPeople(String people);

  /// No description provided for @libraryCardSeat.
  ///
  /// In en, this message translates to:
  /// **'Seats: {seat}'**
  String libraryCardSeat(String seat);

  /// No description provided for @loginIdentityNumber.
  ///
  /// In en, this message translates to:
  /// **'Student ID'**
  String get loginIdentityNumber;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'IDS Login password'**
  String get loginPassword;

  /// No description provided for @loginLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginLogin;

  /// No description provided for @loginIncorrectPasswordPattern.
  ///
  /// In en, this message translates to:
  /// **'Username or password does not meet requirements, student ID must be 11 digits and password cannot be empty'**
  String get loginIncorrectPasswordPattern;

  /// No description provided for @loginOnLoginProgress.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loginOnLoginProgress;

  /// No description provided for @loginCompleteLogin.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginCompleteLogin;

  /// No description provided for @loginFailedLoginCannotConnectToServer.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to server'**
  String get loginFailedLoginCannotConnectToServer;

  /// No description provided for @loginFailedLoginWithCode.
  ///
  /// In en, this message translates to:
  /// **'Request failed, response status code: {code}'**
  String loginFailedLoginWithCode(String code);

  /// No description provided for @loginFailedLoginWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Request failed, error message: {message}'**
  String loginFailedLoginWithMessage(String message);

  /// No description provided for @loginFailedLoginOther.
  ///
  /// In en, this message translates to:
  /// **'Unknown error, please contact the developer'**
  String get loginFailedLoginOther;

  /// No description provided for @loginClearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get loginClearCache;

  /// No description provided for @loginCompleteClearCache.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get loginCompleteClearCache;

  /// No description provided for @loginSeeInspector.
  ///
  /// In en, this message translates to:
  /// **'View network interaction'**
  String get loginSeeInspector;

  /// No description provided for @loginCaptchaWindowTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter captcha'**
  String get loginCaptchaWindowTitle;

  /// No description provided for @loginCaptchaWindowHint.
  ///
  /// In en, this message translates to:
  /// **'Input captcha'**
  String get loginCaptchaWindowHint;

  /// No description provided for @loginCaptchaWindowMessageOnEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter captcha'**
  String get loginCaptchaWindowMessageOnEmpty;

  /// No description provided for @loginCaptchaWindowRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh captcha: {error}'**
  String loginCaptchaWindowRefreshFailed(String error);

  /// No description provided for @loginSliderTitle.
  ///
  /// In en, this message translates to:
  /// **'Server authentication service'**
  String get loginSliderTitle;

  /// No description provided for @schoolNetTitle.
  ///
  /// In en, this message translates to:
  /// **'School Net Usage Query'**
  String get schoolNetTitle;

  /// No description provided for @schoolNetIdsAccountNetTitle.
  ///
  /// In en, this message translates to:
  /// **'Current user'**
  String get schoolNetIdsAccountNetTitle;

  /// No description provided for @schoolNetIdsAccountNetNotice.
  ///
  /// In en, this message translates to:
  /// **'This is the current PDA user\'s information.\nNotice that network traffic is charged in GB (1GB = 1000MB).\nIf you cannot see any info, go to zfw.xidian.edu.cn for password reset'**
  String get schoolNetIdsAccountNetNotice;

  /// No description provided for @schoolNetIdsAccountNetOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get schoolNetIdsAccountNetOverview;

  /// No description provided for @schoolNetIdsAccountNetAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get schoolNetIdsAccountNetAccount;

  /// No description provided for @schoolNetIdsAccountNetUsed.
  ///
  /// In en, this message translates to:
  /// **'Data usage'**
  String get schoolNetIdsAccountNetUsed;

  /// No description provided for @schoolNetIdsAccountNetRemain.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get schoolNetIdsAccountNetRemain;

  /// No description provided for @schoolNetIdsAccountNetCurrentOnline.
  ///
  /// In en, this message translates to:
  /// **'Online devices (currently {length})'**
  String schoolNetIdsAccountNetCurrentOnline(String length);

  /// No description provided for @schoolNetIdsAccountNetNoDeviceOnline.
  ///
  /// In en, this message translates to:
  /// **'No device is online at the moment'**
  String get schoolNetIdsAccountNetNoDeviceOnline;

  /// No description provided for @schoolNetCurrentLoginNetTitle.
  ///
  /// In en, this message translates to:
  /// **'Current using'**
  String get schoolNetCurrentLoginNetTitle;

  /// No description provided for @schoolNetCurrentLoginNetNotice.
  ///
  /// In en, this message translates to:
  /// **'This is the information of the current using account.\nIt may be different from the current user\'s, and DON\'T BE EVIL!\nNotice that network traffic is charged in GB (1GB=1000MB).'**
  String get schoolNetCurrentLoginNetNotice;

  /// No description provided for @schoolNetCurrentLoginNetOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview of the account'**
  String get schoolNetCurrentLoginNetOverview;

  /// No description provided for @schoolNetCurrentLoginNetAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get schoolNetCurrentLoginNetAccount;

  /// No description provided for @schoolNetCurrentLoginNetPlanType.
  ///
  /// In en, this message translates to:
  /// **'Type of the plan'**
  String get schoolNetCurrentLoginNetPlanType;

  /// No description provided for @schoolNetCurrentLoginNetRemain.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get schoolNetCurrentLoginNetRemain;

  /// No description provided for @schoolNetCurrentLoginNetUsageSituation.
  ///
  /// In en, this message translates to:
  /// **'Traffic usage info'**
  String get schoolNetCurrentLoginNetUsageSituation;

  /// No description provided for @schoolNetCurrentLoginNetUsedPercent.
  ///
  /// In en, this message translates to:
  /// **'Used {percent}%'**
  String schoolNetCurrentLoginNetUsedPercent(String percent);

  /// No description provided for @schoolNetCurrentLoginNetUsed.
  ///
  /// In en, this message translates to:
  /// **'Data usage'**
  String get schoolNetCurrentLoginNetUsed;

  /// No description provided for @schoolNetCurrentLoginNetRemainCount.
  ///
  /// In en, this message translates to:
  /// **'Data remaining'**
  String get schoolNetCurrentLoginNetRemainCount;

  /// No description provided for @schoolNetCurrentLoginNetTotal.
  ///
  /// In en, this message translates to:
  /// **'Total data'**
  String get schoolNetCurrentLoginNetTotal;

  /// No description provided for @schoolNetCurrentLoginNetNonSchoolnet.
  ///
  /// In en, this message translates to:
  /// **'Not in school net environment'**
  String get schoolNetCurrentLoginNetNonSchoolnet;

  /// No description provided for @schoolNetDeviceListIp.
  ///
  /// In en, this message translates to:
  /// **'Device IP'**
  String get schoolNetDeviceListIp;

  /// No description provided for @schoolNetDeviceListTime.
  ///
  /// In en, this message translates to:
  /// **'Online time'**
  String get schoolNetDeviceListTime;

  /// No description provided for @schoolNetDeviceListRemain.
  ///
  /// In en, this message translates to:
  /// **'Traffic used'**
  String get schoolNetDeviceListRemain;

  /// No description provided for @schoolNetFetching.
  ///
  /// In en, this message translates to:
  /// **'Fetching schoolnet usage data'**
  String get schoolNetFetching;

  /// No description provided for @schoolNetEmptyPassword.
  ///
  /// In en, this message translates to:
  /// **'You may forgot to enter the schoolnet password'**
  String get schoolNetEmptyPassword;

  /// No description provided for @schoolNetNotInitalized.
  ///
  /// In en, this message translates to:
  /// **'It seems the backend is not open for query:P'**
  String get schoolNetNotInitalized;

  /// No description provided for @schoolNetCaptchaFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to idenify captcha'**
  String get schoolNetCaptchaFailed;

  /// No description provided for @schoolNetCaptchaEmpty.
  ///
  /// In en, this message translates to:
  /// **'Captcha is empty'**
  String get schoolNetCaptchaEmpty;

  /// No description provided for @schoolNetCacheHintCaptchaFailed.
  ///
  /// In en, this message translates to:
  /// **'Captcha recognition failed. Please try again.'**
  String get schoolNetCacheHintCaptchaFailed;

  /// No description provided for @schoolNetCacheHintRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'The schoolnet request failed. Please try again later.'**
  String get schoolNetCacheHintRequestFailed;

  /// No description provided for @schoolNetWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong schoolnet password'**
  String get schoolNetWrongPassword;

  /// No description provided for @schoolNetErrorFetch.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch：{msg}'**
  String schoolNetErrorFetch(String msg);

  /// No description provided for @schoolNetErrorOther.
  ///
  /// In en, this message translates to:
  /// **'Other error：{msg}'**
  String schoolNetErrorOther(String msg);

  /// No description provided for @schoolNetRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get schoolNetRefresh;

  /// No description provided for @schoolCardWindowTitle.
  ///
  /// In en, this message translates to:
  /// **'Campus Card Transaction History'**
  String get schoolCardWindowTitle;

  /// No description provided for @schoolCardWindowIncome.
  ///
  /// In en, this message translates to:
  /// **'Income ￥{income}'**
  String schoolCardWindowIncome(String income);

  /// No description provided for @schoolCardWindowExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense ￥{expense}'**
  String schoolCardWindowExpense(String expense);

  /// No description provided for @schoolCardWindowSelectRange.
  ///
  /// In en, this message translates to:
  /// **'Select date: from {startDay} to {endDay}'**
  String schoolCardWindowSelectRange(String startDay, String endDay);

  /// No description provided for @schoolCardWindowStoreName.
  ///
  /// In en, this message translates to:
  /// **'Expense place'**
  String get schoolCardWindowStoreName;

  /// No description provided for @schoolCardWindowBalance.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get schoolCardWindowBalance;

  /// No description provided for @schoolCardWindowTimeWithSum.
  ///
  /// In en, this message translates to:
  /// **'Time ({sum})'**
  String schoolCardWindowTimeWithSum(String sum);

  /// No description provided for @schoolCardWindowNoRecord.
  ///
  /// In en, this message translates to:
  /// **'No records found, please try again with different dates'**
  String get schoolCardWindowNoRecord;

  /// No description provided for @schoolCardWindowQrCode.
  ///
  /// In en, this message translates to:
  /// **'Payment Code'**
  String get schoolCardWindowQrCode;

  /// No description provided for @schoolCardWindowQrCodeError.
  ///
  /// In en, this message translates to:
  /// **'Get QR Code failed: {info}'**
  String schoolCardWindowQrCodeError(String info);

  /// No description provided for @schoolCardWindowReload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get schoolCardWindowReload;

  /// No description provided for @scoreCacheMessage.
  ///
  /// In en, this message translates to:
  /// **'Cached score information is displayed'**
  String get scoreCacheMessage;

  /// No description provided for @scoreSummary.
  ///
  /// In en, this message translates to:
  /// **'Selected subjects {chosen}  Total credits {credit}\nAverage {avg} GPA {gpa}'**
  String scoreSummary(String chosen, String credit, String avg, String gpa);

  /// No description provided for @scoreAllPassed.
  ///
  /// In en, this message translates to:
  /// **'All subjects have passed'**
  String get scoreAllPassed;

  /// No description provided for @scoreCacheHintPasswordWrong.
  ///
  /// In en, this message translates to:
  /// **'IDS password is incorrect or expired.'**
  String get scoreCacheHintPasswordWrong;

  /// No description provided for @scoreCacheHintLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to log in to the score service.'**
  String get scoreCacheHintLoginFailed;

  /// No description provided for @scoreCacheHintNetworkFailed.
  ///
  /// In en, this message translates to:
  /// **'Network request failed.'**
  String get scoreCacheHintNetworkFailed;

  /// No description provided for @scoreCacheHintUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch the latest score info. Check logs for details.'**
  String get scoreCacheHintUnknownError;

  /// No description provided for @scoreFetchingHint.
  ///
  /// In en, this message translates to:
  /// **'Fetching the latest score info.'**
  String get scoreFetchingHint;

  /// No description provided for @scoreAllSemester.
  ///
  /// In en, this message translates to:
  /// **'All semesters'**
  String get scoreAllSemester;

  /// No description provided for @scoreChosenSemester.
  ///
  /// In en, this message translates to:
  /// **'{chosen}'**
  String scoreChosenSemester(String chosen);

  /// No description provided for @scoreAllType.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get scoreAllType;

  /// No description provided for @scoreChosenType.
  ///
  /// In en, this message translates to:
  /// **'{type}'**
  String scoreChosenType(String type);

  /// No description provided for @scoreNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get scoreNone;

  /// No description provided for @scoreScoreChoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Transcript'**
  String get scoreScoreChoiceTitle;

  /// No description provided for @scoreScoreChoiceSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for score records'**
  String get scoreScoreChoiceSearchHint;

  /// No description provided for @scoreScoreChoiceEmptyList.
  ///
  /// In en, this message translates to:
  /// **'No courses from this semester is selected to be calculated'**
  String get scoreScoreChoiceEmptyList;

  /// No description provided for @scoreScoreChoiceSumDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get scoreScoreChoiceSumDialogTitle;

  /// No description provided for @scoreScoreChoiceSumDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Overall GPA of all subjects：{gpa_all}\nOverall average：{avg_all}\nTotal credits：{credit_all}\nUnpassed subjects：{unpassed}\nPublic selective：{not_core_type}\nThe data provided by this program is for reference only, and the developer is not responsible for its accuracy'**
  String scoreScoreChoiceSumDialogContent(
    String gpa_all,
    String avg_all,
    String credit_all,
    String unpassed,
    String not_core_type,
  );

  /// No description provided for @scoreScoreComposeCardNoDetail.
  ///
  /// In en, this message translates to:
  /// **'No detailed information provided'**
  String get scoreScoreComposeCardNoDetail;

  /// No description provided for @scoreScoreComposeCardFetching.
  ///
  /// In en, this message translates to:
  /// **'Fetching...'**
  String get scoreScoreComposeCardFetching;

  /// No description provided for @scoreScoreComposeCardCredit.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get scoreScoreComposeCardCredit;

  /// No description provided for @scoreScoreComposeCardGpa.
  ///
  /// In en, this message translates to:
  /// **'GPA'**
  String get scoreScoreComposeCardGpa;

  /// No description provided for @scoreScoreComposeCardScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get scoreScoreComposeCardScore;

  /// No description provided for @scoreScoreInfoCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Score Details'**
  String get scoreScoreInfoCardTitle;

  /// No description provided for @scoreScoreInfoCardOriginalCourse.
  ///
  /// In en, this message translates to:
  /// **'Initial course'**
  String get scoreScoreInfoCardOriginalCourse;

  /// No description provided for @scoreScoreInfoCardFailed.
  ///
  /// In en, this message translates to:
  /// **'[Failed]'**
  String get scoreScoreInfoCardFailed;

  /// No description provided for @scoreScoreInfoCardCredit.
  ///
  /// In en, this message translates to:
  /// **'Credits {credit}'**
  String scoreScoreInfoCardCredit(String credit);

  /// No description provided for @scoreScoreInfoCardGpa.
  ///
  /// In en, this message translates to:
  /// **'GPA {gpa}'**
  String scoreScoreInfoCardGpa(String gpa);

  /// No description provided for @scoreScoreInfoCardScore.
  ///
  /// In en, this message translates to:
  /// **'Score {score}'**
  String scoreScoreInfoCardScore(String score);

  /// No description provided for @scoreScorePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Score Query'**
  String get scoreScorePageTitle;

  /// No description provided for @scoreScorePageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for score records'**
  String get scoreScorePageSearchHint;

  /// No description provided for @scoreScorePageNoRecord.
  ///
  /// In en, this message translates to:
  /// **'No relevant information found'**
  String get scoreScorePageNoRecord;

  /// No description provided for @scoreScorePageSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get scoreScorePageSelectAll;

  /// No description provided for @scoreScorePageSelectNothing.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get scoreScorePageSelectNothing;

  /// No description provided for @scoreScorePageResetSelect.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get scoreScorePageResetSelect;

  /// No description provided for @scoreScorePageSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get scoreScorePageSummary;

  /// No description provided for @scoreScorePageCet4.
  ///
  /// In en, this message translates to:
  /// **'College English Test Band 4'**
  String get scoreScorePageCet4;

  /// No description provided for @scoreScorePageCet6.
  ///
  /// In en, this message translates to:
  /// **'College English Test Band 6'**
  String get scoreScorePageCet6;

  /// No description provided for @settingAcknowledgement.
  ///
  /// In en, this message translates to:
  /// **'Made With Love From {developers} People'**
  String settingAcknowledgement(String developers);

  /// No description provided for @settingAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingAbout;

  /// No description provided for @settingAboutThisProgram.
  ///
  /// In en, this message translates to:
  /// **'About this APP'**
  String get settingAboutThisProgram;

  /// No description provided for @settingVersion.
  ///
  /// In en, this message translates to:
  /// **'Version：{version}'**
  String settingVersion(String version);

  /// No description provided for @settingUserInfo.
  ///
  /// In en, this message translates to:
  /// **'User information'**
  String get settingUserInfo;

  /// No description provided for @settingCheckUpdate.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get settingCheckUpdate;

  /// No description provided for @settingLatestVersion.
  ///
  /// In en, this message translates to:
  /// **'Latest version: {latest}'**
  String settingLatestVersion(String latest);

  /// No description provided for @settingWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for obtain'**
  String get settingWaiting;

  /// No description provided for @settingFetchingUpdate.
  ///
  /// In en, this message translates to:
  /// **'Fetching update information'**
  String get settingFetchingUpdate;

  /// No description provided for @settingNewVersion.
  ///
  /// In en, this message translates to:
  /// **'New version released!'**
  String get settingNewVersion;

  /// No description provided for @settingCurrentStable.
  ///
  /// In en, this message translates to:
  /// **'You are running the latest version'**
  String get settingCurrentStable;

  /// No description provided for @settingCurrentTesting.
  ///
  /// In en, this message translates to:
  /// **'You are running the testing version'**
  String get settingCurrentTesting;

  /// No description provided for @settingFetchFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch update information'**
  String get settingFetchFailed;

  /// No description provided for @settingUiSetting.
  ///
  /// In en, this message translates to:
  /// **'UI Settings'**
  String get settingUiSetting;

  /// No description provided for @settingBrightnessSetting.
  ///
  /// In en, this message translates to:
  /// **'Light/Dark mode'**
  String get settingBrightnessSetting;

  /// No description provided for @settingColorSetting.
  ///
  /// In en, this message translates to:
  /// **'Color theme'**
  String get settingColorSetting;

  /// No description provided for @settingSimplifyTimeline.
  ///
  /// In en, this message translates to:
  /// **'Simplify schedule timeline'**
  String get settingSimplifyTimeline;

  /// No description provided for @settingSimplifyTimelineDescription.
  ///
  /// In en, this message translates to:
  /// **'Reduce space occupation while no schedule'**
  String get settingSimplifyTimelineDescription;

  /// No description provided for @settingLowElectricityWarning.
  ///
  /// In en, this message translates to:
  /// **'Low electricity card color warning'**
  String get settingLowElectricityWarning;

  /// No description provided for @settingLowElectricityWarningDescription.
  ///
  /// In en, this message translates to:
  /// **'Change the homepage electricity card color when remaining electricity is below the threshold'**
  String get settingLowElectricityWarningDescription;

  /// No description provided for @settingLowElectricityThreshold.
  ///
  /// In en, this message translates to:
  /// **'Low electricity threshold'**
  String get settingLowElectricityThreshold;

  /// No description provided for @settingLowElectricityThresholdDescription.
  ///
  /// In en, this message translates to:
  /// **'Current: {threshold} kWh'**
  String settingLowElectricityThresholdDescription(String threshold);

  /// No description provided for @settingLowElectricityThresholdDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Set low electricity threshold'**
  String get settingLowElectricityThresholdDialogTitle;

  /// No description provided for @settingLowElectricityThresholdDialogInputHint.
  ///
  /// In en, this message translates to:
  /// **'Input remaining electricity'**
  String get settingLowElectricityThresholdDialogInputHint;

  /// No description provided for @settingAccountSetting.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get settingAccountSetting;

  /// No description provided for @settingSportPasswordSetting.
  ///
  /// In en, this message translates to:
  /// **'PE system password'**
  String get settingSportPasswordSetting;

  /// No description provided for @settingExperimentPasswordSetting.
  ///
  /// In en, this message translates to:
  /// **'Physics experiment password'**
  String get settingExperimentPasswordSetting;

  /// No description provided for @settingElectricityPasswordSetting.
  ///
  /// In en, this message translates to:
  /// **'Electricity account password'**
  String get settingElectricityPasswordSetting;

  /// No description provided for @settingElectricityPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Please set if not default'**
  String get settingElectricityPasswordDescription;

  /// No description provided for @settingElectricityAccountSetting.
  ///
  /// In en, this message translates to:
  /// **'Electricity account setting'**
  String get settingElectricityAccountSetting;

  /// No description provided for @settingSchoolnetPasswordSetting.
  ///
  /// In en, this message translates to:
  /// **'Campus net password'**
  String get settingSchoolnetPasswordSetting;

  /// No description provided for @settingSchoolnetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'If you have not setted it, you cannot query it.'**
  String get settingSchoolnetPasswordDescription;

  /// No description provided for @settingAirconImeiTitle.
  ///
  /// In en, this message translates to:
  /// **'Aircon electricity data source'**
  String get settingAirconImeiTitle;

  /// No description provided for @settingAirconImei.
  ///
  /// In en, this message translates to:
  /// **'Aircon IMEI'**
  String get settingAirconImei;

  /// No description provided for @settingAirconImeiNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set. Aircon electricity will be hidden on the power page.'**
  String get settingAirconImeiNotSet;

  /// No description provided for @settingAirconImeiCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current IMEI: {imei}'**
  String settingAirconImeiCurrent(String imei);

  /// No description provided for @settingAirconImeiSaved.
  ///
  /// In en, this message translates to:
  /// **'Aircon IMEI saved'**
  String get settingAirconImeiSaved;

  /// No description provided for @settingAirconImeiCleared.
  ///
  /// In en, this message translates to:
  /// **'Aircon IMEI cleared'**
  String get settingAirconImeiCleared;

  /// No description provided for @settingAirconImeiInvalid.
  ///
  /// In en, this message translates to:
  /// **'No valid 15-digit IMEI found'**
  String get settingAirconImeiInvalid;

  /// No description provided for @settingAirconImeiClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get settingAirconImeiClear;

  /// No description provided for @settingScanAirconQr.
  ///
  /// In en, this message translates to:
  /// **'Scan aircon QR code'**
  String get settingScanAirconQr;

  /// No description provided for @settingPickAirconQrImage.
  ///
  /// In en, this message translates to:
  /// **'Choose QR image'**
  String get settingPickAirconQrImage;

  /// No description provided for @settingAirconCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera scanning is unavailable on this platform. Choose a QR image or enter the IMEI manually.'**
  String get settingAirconCameraUnavailable;

  /// No description provided for @settingNotificationSetting.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get settingNotificationSetting;

  /// No description provided for @settingCourseReminderSetting.
  ///
  /// In en, this message translates to:
  /// **'Pre-class Reminder Settings'**
  String get settingCourseReminderSetting;

  /// No description provided for @settingCourseReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Configure pre-class reminder notifications'**
  String get settingCourseReminderDescription;

  /// No description provided for @settingNotificationPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Pre-class Reminder Settings'**
  String get settingNotificationPageTitle;

  /// No description provided for @settingNotificationPageLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load settings: {error}'**
  String settingNotificationPageLoadFailed(String error);

  /// No description provided for @settingNotificationPageFunctionSection.
  ///
  /// In en, this message translates to:
  /// **'Notification Function'**
  String get settingNotificationPageFunctionSection;

  /// No description provided for @settingNotificationPageEnableNotification.
  ///
  /// In en, this message translates to:
  /// **'Enable Pre-class Reminders'**
  String get settingNotificationPageEnableNotification;

  /// No description provided for @settingNotificationPageNotificationScheduled.
  ///
  /// In en, this message translates to:
  /// **'{count} notifications scheduled'**
  String settingNotificationPageNotificationScheduled(String count);

  /// No description provided for @settingNotificationPageNotificationDisabledHint.
  ///
  /// In en, this message translates to:
  /// **'All scheduled notifications will be cancelled when disabled'**
  String get settingNotificationPageNotificationDisabledHint;

  /// No description provided for @settingNotificationPageUpdateSchedule.
  ///
  /// In en, this message translates to:
  /// **'Update Notification Schedule'**
  String get settingNotificationPageUpdateSchedule;

  /// No description provided for @settingNotificationPageUpdateScheduleHint.
  ///
  /// In en, this message translates to:
  /// **'Reschedule notifications based on the latest course data'**
  String get settingNotificationPageUpdateScheduleHint;

  /// No description provided for @settingNotificationPageDeleteAllSchedule.
  ///
  /// In en, this message translates to:
  /// **'Delete All Scheduled Reminder'**
  String get settingNotificationPageDeleteAllSchedule;

  /// No description provided for @settingNotificationPageDeleteAllScheduleHint.
  ///
  /// In en, this message translates to:
  /// **'This action will delete all scheduled events, but you can click \'Update Notification Schedule\' again to re-add them.'**
  String get settingNotificationPageDeleteAllScheduleHint;

  /// No description provided for @settingNotificationPageDeleteAllSuccess.
  ///
  /// In en, this message translates to:
  /// **'Delete successfully'**
  String get settingNotificationPageDeleteAllSuccess;

  /// No description provided for @settingNotificationPageViewTheInstructions.
  ///
  /// In en, this message translates to:
  /// **'View the instructions'**
  String get settingNotificationPageViewTheInstructions;

  /// No description provided for @settingNotificationPageViewTheInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'Check more instructions to ensure that you can see the notifications sent by the program'**
  String get settingNotificationPageViewTheInstructionsHint;

  /// No description provided for @settingNotificationPagePermissionSection.
  ///
  /// In en, this message translates to:
  /// **'Permission Status'**
  String get settingNotificationPagePermissionSection;

  /// No description provided for @settingNotificationPageNotificationPermission.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get settingNotificationPageNotificationPermission;

  /// No description provided for @settingNotificationPageExactAlarmPermission.
  ///
  /// In en, this message translates to:
  /// **'Exact Alarm Permission'**
  String get settingNotificationPageExactAlarmPermission;

  /// No description provided for @settingNotificationPagePermissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get settingNotificationPagePermissionGranted;

  /// No description provided for @settingNotificationPagePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get settingNotificationPagePermissionDenied;

  /// No description provided for @settingNotificationPageRequestPermission.
  ///
  /// In en, this message translates to:
  /// **'Request Permission'**
  String get settingNotificationPageRequestPermission;

  /// No description provided for @settingNotificationPageSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'System Notification Settings'**
  String get settingNotificationPageSystemSettings;

  /// No description provided for @settingNotificationPageSystemSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Open system settings to check notification configuration'**
  String get settingNotificationPageSystemSettingsHint;

  /// No description provided for @settingNotificationPagePermissionGrantedMsg.
  ///
  /// In en, this message translates to:
  /// **'Permission granted'**
  String get settingNotificationPagePermissionGrantedMsg;

  /// No description provided for @settingNotificationPagePermissionDeniedMsg.
  ///
  /// In en, this message translates to:
  /// **'Permission denied, please enable it in system settings'**
  String get settingNotificationPagePermissionDeniedMsg;

  /// No description provided for @settingNotificationPageReminderSection.
  ///
  /// In en, this message translates to:
  /// **'Reminder Settings'**
  String get settingNotificationPageReminderSection;

  /// No description provided for @settingNotificationPageExperimentReminder.
  ///
  /// In en, this message translates to:
  /// **'Include the physics experiments'**
  String get settingNotificationPageExperimentReminder;

  /// No description provided for @settingNotificationPageExperimentReminderHint.
  ///
  /// In en, this message translates to:
  /// **'Enable this option to add the physics experiment to the Pre-class Reminder'**
  String get settingNotificationPageExperimentReminderHint;

  /// No description provided for @settingNotificationPageMinutesBefore.
  ///
  /// In en, this message translates to:
  /// **'Advance Reminder Time'**
  String get settingNotificationPageMinutesBefore;

  /// No description provided for @settingNotificationPageMinutesBeforeHint.
  ///
  /// In en, this message translates to:
  /// **'The time setting for pre-class reminders'**
  String get settingNotificationPageMinutesBeforeHint;

  /// No description provided for @settingNotificationPageMinutesUnit.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get settingNotificationPageMinutesUnit;

  /// No description provided for @settingNotificationPageDaysToSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule Duration'**
  String get settingNotificationPageDaysToSchedule;

  /// No description provided for @settingNotificationPageDaysToScheduleHint.
  ///
  /// In en, this message translates to:
  /// **'This program writes course information into the planned schedule in advance. This setting can adjust the number of days for writing into the planned schedule'**
  String get settingNotificationPageDaysToScheduleHint;

  /// No description provided for @settingNotificationPageDaysUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get settingNotificationPageDaysUnit;

  /// No description provided for @settingNotificationPageSettingsGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings Guide'**
  String get settingNotificationPageSettingsGuideTitle;

  /// No description provided for @settingNotificationPageSettingsGuideContent1.
  ///
  /// In en, this message translates to:
  /// **'To ensure you receive pre-class reminders in time, please make sure:\n1. App notification permission is enabled\n2. Notification sound is enabled\n3. Banner notifications are enabled\n4. Non-native Android users, enable auto-start and disable power optimization'**
  String get settingNotificationPageSettingsGuideContent1;

  /// No description provided for @settingNotificationPageSettingsGuideContent2.
  ///
  /// In en, this message translates to:
  /// **'Pre-class Reminder Module Operating Mechanism:\n1. When first activated, it will automatically schedule pre-class reminders for the upcoming days\n2. Each time the app is opened, it will automatically check and update the notification schedule\n3. After modifying settings, it will automatically reschedule all notifications'**
  String get settingNotificationPageSettingsGuideContent2;

  /// No description provided for @settingNotificationPageGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get settingNotificationPageGotIt;

  /// No description provided for @settingNotificationPageOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open System Settings'**
  String get settingNotificationPageOpenSettings;

  /// No description provided for @settingNotificationPageNoClasstableData.
  ///
  /// In en, this message translates to:
  /// **'Please fetch course schedule, exam, or experiment data first'**
  String get settingNotificationPageNoClasstableData;

  /// No description provided for @settingNotificationPageScheduleSuccess.
  ///
  /// In en, this message translates to:
  /// **'Scheduled {count} pre-class reminders'**
  String settingNotificationPageScheduleSuccess(String count);

  /// No description provided for @settingNotificationPageScheduleFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to schedule notifications: {error}'**
  String settingNotificationPageScheduleFailed(String error);

  /// No description provided for @settingNotificationPageCancelAllSuccess.
  ///
  /// In en, this message translates to:
  /// **'All pre-class reminders cancelled'**
  String get settingNotificationPageCancelAllSuccess;

  /// No description provided for @settingNotificationPageRescheduleSuccess.
  ///
  /// In en, this message translates to:
  /// **'Rescheduled {count} pre-class reminders'**
  String settingNotificationPageRescheduleSuccess(String count);

  /// No description provided for @settingNotificationPageRescheduleFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to reschedule notifications: {error}'**
  String settingNotificationPageRescheduleFailed(String error);

  /// No description provided for @settingNotificationDebugPage.
  ///
  /// In en, this message translates to:
  /// **'Notification Services Debug Page'**
  String get settingNotificationDebugPage;

  /// No description provided for @settingClasstableSetting.
  ///
  /// In en, this message translates to:
  /// **'Class Schedule Related'**
  String get settingClasstableSetting;

  /// No description provided for @settingBackground.
  ///
  /// In en, this message translates to:
  /// **'Background image'**
  String get settingBackground;

  /// No description provided for @settingNoBackground.
  ///
  /// In en, this message translates to:
  /// **'You need to select an image first, it\'s at below'**
  String get settingNoBackground;

  /// No description provided for @settingChooseBackground.
  ///
  /// In en, this message translates to:
  /// **'Choose background image'**
  String get settingChooseBackground;

  /// No description provided for @settingNoPermission.
  ///
  /// In en, this message translates to:
  /// **'No storage permission obtained, cannot read files'**
  String get settingNoPermission;

  /// No description provided for @settingSuccessfulSetting.
  ///
  /// In en, this message translates to:
  /// **'Successfully set'**
  String get settingSuccessfulSetting;

  /// No description provided for @settingFailureSetting.
  ///
  /// In en, this message translates to:
  /// **'You did not select an image'**
  String get settingFailureSetting;

  /// No description provided for @settingClearUserClass.
  ///
  /// In en, this message translates to:
  /// **'Clear all customized courses'**
  String get settingClearUserClass;

  /// No description provided for @settingClearUserClassTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Confirmation'**
  String get settingClearUserClassTitle;

  /// No description provided for @settingClearUserClassContent.
  ///
  /// In en, this message translates to:
  /// **'Do you want to clear all user-added courses? This function does not affect the schedule obtained from the school.'**
  String get settingClearUserClassContent;

  /// No description provided for @settingClearUserClassClear.
  ///
  /// In en, this message translates to:
  /// **'Already cleared'**
  String get settingClearUserClassClear;

  /// No description provided for @settingClassRefresh.
  ///
  /// In en, this message translates to:
  /// **'Force refresh class schedule'**
  String get settingClassRefresh;

  /// No description provided for @settingClassRefreshTitle.
  ///
  /// In en, this message translates to:
  /// **'Refresh Confirmation'**
  String get settingClassRefreshTitle;

  /// No description provided for @settingClassRefreshContent.
  ///
  /// In en, this message translates to:
  /// **'Do you want to force refreshing the class schedule? If you agree, we will fetch the schedule from the school, which may takes a long time.'**
  String get settingClassRefreshContent;

  /// No description provided for @settingClassSwift.
  ///
  /// In en, this message translates to:
  /// **'Class schedule offset setting'**
  String get settingClassSwift;

  /// No description provided for @settingClassSwiftDescription.
  ///
  /// In en, this message translates to:
  /// **'Positive number delays the start date, negative number advances the start date\nCurrently {swift}\n'**
  String settingClassSwiftDescription(String swift);

  /// No description provided for @settingCoreSetting.
  ///
  /// In en, this message translates to:
  /// **'Cached login settings'**
  String get settingCoreSetting;

  /// No description provided for @settingCheckLogger.
  ///
  /// In en, this message translates to:
  /// **'View network interceptor and logs'**
  String get settingCheckLogger;

  /// No description provided for @settingClearAndRestart.
  ///
  /// In en, this message translates to:
  /// **'Clear cache and restart'**
  String get settingClearAndRestart;

  /// No description provided for @settingClearAndRestartDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Restart confirmation'**
  String get settingClearAndRestartDialogTitle;

  /// No description provided for @settingClearAndRestartDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to clear cache and restart the program?'**
  String get settingClearAndRestartDialogContent;

  /// No description provided for @settingClearAndRestartDialogCleaning.
  ///
  /// In en, this message translates to:
  /// **'Clearing cache...'**
  String get settingClearAndRestartDialogCleaning;

  /// No description provided for @settingClearAndRestartDialogClear.
  ///
  /// In en, this message translates to:
  /// **'Cache has been cleared'**
  String get settingClearAndRestartDialogClear;

  /// No description provided for @settingLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out and restart the app'**
  String get settingLogout;

  /// No description provided for @settingLogoutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout confirmation'**
  String get settingLogoutDialogTitle;

  /// No description provided for @settingLogoutDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you want to log out? All your data will be completely deleted!'**
  String get settingLogoutDialogContent;

  /// No description provided for @settingLogoutDialogLoggingOut.
  ///
  /// In en, this message translates to:
  /// **'Logging out...'**
  String get settingLogoutDialogLoggingOut;

  /// No description provided for @settingNeedCloseDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Crashed'**
  String get settingNeedCloseDialogTitle;

  /// No description provided for @settingNeedCloseDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Due to technical limitations, you need to close the window manually and then reopen the app.'**
  String get settingNeedCloseDialogContent;

  /// No description provided for @settingChangeColorDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Color setting'**
  String get settingChangeColorDialogTitle;

  /// No description provided for @settingChangeColorDialogDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get settingChangeColorDialogDefault;

  /// No description provided for @settingChangeColorDialogBlue.
  ///
  /// In en, this message translates to:
  /// **'Sky Blue'**
  String get settingChangeColorDialogBlue;

  /// No description provided for @settingChangeColorDialogDeeppurple.
  ///
  /// In en, this message translates to:
  /// **'Deep Purple'**
  String get settingChangeColorDialogDeeppurple;

  /// No description provided for @settingChangeColorDialogGreen.
  ///
  /// In en, this message translates to:
  /// **'Spring Green'**
  String get settingChangeColorDialogGreen;

  /// No description provided for @settingChangeColorDialogOrange.
  ///
  /// In en, this message translates to:
  /// **'Asuka Orange'**
  String get settingChangeColorDialogOrange;

  /// No description provided for @settingChangeColorDialogPink.
  ///
  /// In en, this message translates to:
  /// **'Sakura Pink'**
  String get settingChangeColorDialogPink;

  /// No description provided for @settingChangeBrightnessDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Brightness settings'**
  String get settingChangeBrightnessDialogTitle;

  /// No description provided for @settingChangeBrightnessDialogFollowSetting.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get settingChangeBrightnessDialogFollowSetting;

  /// No description provided for @settingChangeBrightnessDialogDayMode.
  ///
  /// In en, this message translates to:
  /// **'Day mode'**
  String get settingChangeBrightnessDialogDayMode;

  /// No description provided for @settingChangeBrightnessDialogNightMode.
  ///
  /// In en, this message translates to:
  /// **'Night mode'**
  String get settingChangeBrightnessDialogNightMode;

  /// No description provided for @settingChangeSwiftDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Class schedule offset setting'**
  String get settingChangeSwiftDialogTitle;

  /// No description provided for @settingChangeSwiftDialogInputHint.
  ///
  /// In en, this message translates to:
  /// **'Please input number here'**
  String get settingChangeSwiftDialogInputHint;

  /// No description provided for @settingChangeElectricityTitle.
  ///
  /// In en, this message translates to:
  /// **'Modify electricity account'**
  String get settingChangeElectricityTitle;

  /// No description provided for @settingChangeElectricityAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Modify electricity account'**
  String get settingChangeElectricityAccountTitle;

  /// No description provided for @settingChangeElectricityAccountCampus.
  ///
  /// In en, this message translates to:
  /// **'Campus'**
  String get settingChangeElectricityAccountCampus;

  /// No description provided for @settingChangeElectricityAccountNorthcampus.
  ///
  /// In en, this message translates to:
  /// **'Northern Campus'**
  String get settingChangeElectricityAccountNorthcampus;

  /// No description provided for @settingChangeElectricityAccountSouthcampus.
  ///
  /// In en, this message translates to:
  /// **'Southern Campus'**
  String get settingChangeElectricityAccountSouthcampus;

  /// No description provided for @settingChangeElectricityAccountUnitorzone.
  ///
  /// In en, this message translates to:
  /// **'Unit  / Zone'**
  String get settingChangeElectricityAccountUnitorzone;

  /// No description provided for @settingChangeElectricityAccountUnitcode.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get settingChangeElectricityAccountUnitcode;

  /// No description provided for @settingChangeElectricityAccountZonecode.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get settingChangeElectricityAccountZonecode;

  /// No description provided for @settingChangeElectricityAccountPleaseinput.
  ///
  /// In en, this message translates to:
  /// **'Please input {unitOrZoneCode}'**
  String settingChangeElectricityAccountPleaseinput(String unitOrZoneCode);

  /// No description provided for @settingChangeElectricityAccountSuccessfulFetch.
  ///
  /// In en, this message translates to:
  /// **'Successful fetching account: {accountNumber}'**
  String settingChangeElectricityAccountSuccessfulFetch(String accountNumber);

  /// No description provided for @settingChangeElectricityAccountFailedFetch.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch: {e}'**
  String settingChangeElectricityAccountFailedFetch(String e);

  /// No description provided for @settingChangeElectricityAccountAccountSaved.
  ///
  /// In en, this message translates to:
  /// **'Account saved：{accountNumber}'**
  String settingChangeElectricityAccountAccountSaved(String accountNumber);

  /// No description provided for @settingChangeElectricityAccountUnknownCodingPattern.
  ///
  /// In en, this message translates to:
  /// **'Unknown coding pattern'**
  String get settingChangeElectricityAccountUnknownCodingPattern;

  /// No description provided for @settingChangeElectricityAccountSelectBuilding.
  ///
  /// In en, this message translates to:
  /// **'Select Building'**
  String get settingChangeElectricityAccountSelectBuilding;

  /// No description provided for @settingChangeElectricityAccountBuilding.
  ///
  /// In en, this message translates to:
  /// **'Building'**
  String get settingChangeElectricityAccountBuilding;

  /// No description provided for @settingChangeElectricityAccountNorthernBuilding.
  ///
  /// In en, this message translates to:
  /// **'Northern Building'**
  String get settingChangeElectricityAccountNorthernBuilding;

  /// No description provided for @settingChangeElectricityAccountSouthernBuilding.
  ///
  /// In en, this message translates to:
  /// **'Southern Building'**
  String get settingChangeElectricityAccountSouthernBuilding;

  /// No description provided for @settingChangeElectricityAccountFailedGenerate.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate: {e}'**
  String settingChangeElectricityAccountFailedGenerate(String e);

  /// No description provided for @settingChangeElectricityAccountBuildingNumber.
  ///
  /// In en, this message translates to:
  /// **'Building number'**
  String get settingChangeElectricityAccountBuildingNumber;

  /// No description provided for @settingChangeElectricityAccountBuildingNumberHint.
  ///
  /// In en, this message translates to:
  /// **'eg: 16, 7, 55'**
  String get settingChangeElectricityAccountBuildingNumberHint;

  /// No description provided for @settingChangeElectricityAccountBuildingNumberQuery.
  ///
  /// In en, this message translates to:
  /// **'Please input building No.'**
  String get settingChangeElectricityAccountBuildingNumberQuery;

  /// No description provided for @settingChangeElectricityAccountYard.
  ///
  /// In en, this message translates to:
  /// **'Yard'**
  String get settingChangeElectricityAccountYard;

  /// No description provided for @settingChangeElectricityAccountYardHint.
  ///
  /// In en, this message translates to:
  /// **'Select Yard'**
  String get settingChangeElectricityAccountYardHint;

  /// No description provided for @settingChangeElectricityAccountNorthyard.
  ///
  /// In en, this message translates to:
  /// **'North Yard'**
  String get settingChangeElectricityAccountNorthyard;

  /// No description provided for @settingChangeElectricityAccountSouthyard.
  ///
  /// In en, this message translates to:
  /// **'South Yard'**
  String get settingChangeElectricityAccountSouthyard;

  /// No description provided for @settingChangeElectricityAccountYardQuery.
  ///
  /// In en, this message translates to:
  /// **'Please select yard'**
  String get settingChangeElectricityAccountYardQuery;

  /// No description provided for @settingChangeElectricityAccountApartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get settingChangeElectricityAccountApartment;

  /// No description provided for @settingChangeElectricityAccountApartmentHint.
  ///
  /// In en, this message translates to:
  /// **'Select Apartment'**
  String get settingChangeElectricityAccountApartmentHint;

  /// No description provided for @settingChangeElectricityAccountNorthapartment.
  ///
  /// In en, this message translates to:
  /// **'North Apartment'**
  String get settingChangeElectricityAccountNorthapartment;

  /// No description provided for @settingChangeElectricityAccountSouthapartment.
  ///
  /// In en, this message translates to:
  /// **'South Apartment'**
  String get settingChangeElectricityAccountSouthapartment;

  /// No description provided for @settingChangeElectricityAccountApartmentQuery.
  ///
  /// In en, this message translates to:
  /// **'Please select apartment'**
  String get settingChangeElectricityAccountApartmentQuery;

  /// No description provided for @settingChangeElectricityAccountLevelcode.
  ///
  /// In en, this message translates to:
  /// **'Floor number'**
  String get settingChangeElectricityAccountLevelcode;

  /// No description provided for @settingChangeElectricityAccountLevelcodeQuery.
  ///
  /// In en, this message translates to:
  /// **'Floor number'**
  String get settingChangeElectricityAccountLevelcodeQuery;

  /// No description provided for @settingChangeElectricityAccountRoomcode.
  ///
  /// In en, this message translates to:
  /// **'Room code'**
  String get settingChangeElectricityAccountRoomcode;

  /// No description provided for @settingChangeElectricityAccountRoomcodeHint.
  ///
  /// In en, this message translates to:
  /// **'eg: 304, 508'**
  String get settingChangeElectricityAccountRoomcodeHint;

  /// No description provided for @settingChangeElectricityAccountRoomcodeQuery.
  ///
  /// In en, this message translates to:
  /// **'Please input room code'**
  String get settingChangeElectricityAccountRoomcodeQuery;

  /// No description provided for @settingChangeElectricityAccountAccount.
  ///
  /// In en, this message translates to:
  /// **'Electricity Account'**
  String get settingChangeElectricityAccountAccount;

  /// No description provided for @settingChangeElectricityAccountAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter your account'**
  String get settingChangeElectricityAccountAccountHint;

  /// No description provided for @settingChangeElectricityAccountAccountQuery.
  ///
  /// In en, this message translates to:
  /// **'Please input your account'**
  String get settingChangeElectricityAccountAccountQuery;

  /// No description provided for @settingChangeElectricityAccountAccountLength.
  ///
  /// In en, this message translates to:
  /// **'Account length is larger than 10'**
  String get settingChangeElectricityAccountAccountLength;

  /// No description provided for @settingChangeElectricityAccountFetching.
  ///
  /// In en, this message translates to:
  /// **'Fetching...'**
  String get settingChangeElectricityAccountFetching;

  /// No description provided for @settingChangeElectricityAccountFetchFromInternet.
  ///
  /// In en, this message translates to:
  /// **'Sync from backend'**
  String get settingChangeElectricityAccountFetchFromInternet;

  /// No description provided for @settingChangeElectricityAccountSaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Save account'**
  String get settingChangeElectricityAccountSaveAccount;

  /// No description provided for @settingChangeElectricityAccountConfirmSaving.
  ///
  /// In en, this message translates to:
  /// **'Confirm account'**
  String get settingChangeElectricityAccountConfirmSaving;

  /// No description provided for @settingChangeElectricityAccountCalculateAccount.
  ///
  /// In en, this message translates to:
  /// **'Calculate account'**
  String get settingChangeElectricityAccountCalculateAccount;

  /// No description provided for @settingChangeElectricityAccountCalculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get settingChangeElectricityAccountCalculate;

  /// No description provided for @settingChangeElectricityAccountInput.
  ///
  /// In en, this message translates to:
  /// **'Input'**
  String get settingChangeElectricityAccountInput;

  /// No description provided for @settingChangeElectricityAccountConfirmAccount.
  ///
  /// In en, this message translates to:
  /// **'Confirm your account: '**
  String get settingChangeElectricityAccountConfirmAccount;

  /// No description provided for @settingChangeElectricityAccountChange.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get settingChangeElectricityAccountChange;

  /// No description provided for @settingChangeElectricityAccountCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingChangeElectricityAccountCancel;

  /// No description provided for @settingChangeElectricityAccountNoSetting.
  ///
  /// In en, this message translates to:
  /// **'No new electricity account set'**
  String get settingChangeElectricityAccountNoSetting;

  /// No description provided for @settingChangeElectricityAccountSuccessfulSetting.
  ///
  /// In en, this message translates to:
  /// **'Successfully setting new electricity account'**
  String get settingChangeElectricityAccountSuccessfulSetting;

  /// No description provided for @settingChangeExperimentTitle.
  ///
  /// In en, this message translates to:
  /// **'Modify physics experiment account password'**
  String get settingChangeExperimentTitle;

  /// No description provided for @settingChangeSportTitle.
  ///
  /// In en, this message translates to:
  /// **'Modify sports system account password'**
  String get settingChangeSportTitle;

  /// No description provided for @settingChangePasswordDialogInputHint.
  ///
  /// In en, this message translates to:
  /// **'Please input password here'**
  String get settingChangePasswordDialogInputHint;

  /// No description provided for @settingChangePasswordDialogBlankInput.
  ///
  /// In en, this message translates to:
  /// **'Blank input!'**
  String get settingChangePasswordDialogBlankInput;

  /// No description provided for @settingChangeSchoolnetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Modify the schoolnet query password'**
  String get settingChangeSchoolnetPasswordTitle;

  /// No description provided for @settingUpdateDialogNewVersion.
  ///
  /// In en, this message translates to:
  /// **'New version available'**
  String get settingUpdateDialogNewVersion;

  /// No description provided for @settingUpdateDialogNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get settingUpdateDialogNotNow;

  /// No description provided for @settingUpdateDialogAppStore.
  ///
  /// In en, this message translates to:
  /// **'Update from App Store'**
  String get settingUpdateDialogAppStore;

  /// No description provided for @settingUpdateDialogDownloadApk.
  ///
  /// In en, this message translates to:
  /// **'Download APK'**
  String get settingUpdateDialogDownloadApk;

  /// No description provided for @settingUpdateDialogGithubRelease.
  ///
  /// In en, this message translates to:
  /// **'Go to Git Release'**
  String get settingUpdateDialogGithubRelease;

  /// No description provided for @settingUpdateDialogNewContent.
  ///
  /// In en, this message translates to:
  /// **'New features from version {code}:\n'**
  String settingUpdateDialogNewContent(String code);

  /// No description provided for @settingLocalizationDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get settingLocalizationDialogTitle;

  /// No description provided for @settingLocalizationDialogUndefined.
  ///
  /// In en, this message translates to:
  /// **'Follow system setting'**
  String get settingLocalizationDialogUndefined;

  /// No description provided for @settingLocalizationDialogSimplifiedchinese.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get settingLocalizationDialogSimplifiedchinese;

  /// No description provided for @settingLocalizationDialogTraditionalchinese.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get settingLocalizationDialogTraditionalchinese;

  /// No description provided for @settingLocalizationDialogEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingLocalizationDialogEnglish;

  /// No description provided for @settingSemesterChange.
  ///
  /// In en, this message translates to:
  /// **'Change semester'**
  String get settingSemesterChange;

  /// No description provided for @settingSemesterChangeDescription.
  ///
  /// In en, this message translates to:
  /// **'Using semester {semester}'**
  String settingSemesterChangeDescription(String semester);

  /// No description provided for @settingSemesterUpdateData.
  ///
  /// In en, this message translates to:
  /// **'Applying new semester setting'**
  String get settingSemesterUpdateData;

  /// No description provided for @settingEasterEggPage.
  ///
  /// In en, this message translates to:
  /// **'You found an Easter egg'**
  String get settingEasterEggPage;

  /// No description provided for @settingAboutPageBenderblog.
  ///
  /// In en, this message translates to:
  /// **'Main developer, iOS widget'**
  String get settingAboutPageBenderblog;

  /// No description provided for @settingAboutPageAlnair.
  ///
  /// In en, this message translates to:
  /// **'Development: Library search and cover'**
  String get settingAboutPageAlnair;

  /// No description provided for @settingAboutPageAqqkad.
  ///
  /// In en, this message translates to:
  /// **'Development: Class attandance history'**
  String get settingAboutPageAqqkad;

  /// No description provided for @settingAboutPageBellssgit.
  ///
  /// In en, this message translates to:
  /// **'Support: best and longest feedback source'**
  String get settingAboutPageBellssgit;

  /// No description provided for @settingAboutPageBrackrat.
  ///
  /// In en, this message translates to:
  /// **'Design: homepage, login page, color scheme, iOS widgets, etc.'**
  String get settingAboutPageBrackrat;

  /// No description provided for @settingAboutPageBreezeline.
  ///
  /// In en, this message translates to:
  /// **'Support: valueless and meaningless product manager (from his own description)'**
  String get settingAboutPageBreezeline;

  /// No description provided for @settingAboutPageCafebabe.
  ///
  /// In en, this message translates to:
  /// **'Support: provide Easter egg code / Development: Development: New Slider \'26'**
  String get settingAboutPageCafebabe;

  /// No description provided for @settingAboutPageChitao1234.
  ///
  /// In en, this message translates to:
  /// **'Development: fix slider misalignment issue'**
  String get settingAboutPageChitao1234;

  /// No description provided for @settingAboutPageCopperkoi.
  ///
  /// In en, this message translates to:
  /// **'Development: latest time arrangement sync to calendar'**
  String get settingAboutPageCopperkoi;

  /// No description provided for @settingAboutPageDimole.
  ///
  /// In en, this message translates to:
  /// **'Development support: assist in fixing slider issue'**
  String get settingAboutPageDimole;

  /// No description provided for @settingAboutPageElitewars.
  ///
  /// In en, this message translates to:
  /// **'Design: sports score page'**
  String get settingAboutPageElitewars;

  /// No description provided for @settingAboutPageElliot.
  ///
  /// In en, this message translates to:
  /// **'Internationalization: English translation / Development guidance: on partner classtable development (This function has been removed)'**
  String get settingAboutPageElliot;

  /// No description provided for @settingAboutPageFlyingpig.
  ///
  /// In en, this message translates to:
  /// **'Development: Fix null pointer exception at user defined class info'**
  String get settingAboutPageFlyingpig;

  /// No description provided for @settingAboutPageGodhu777777.
  ///
  /// In en, this message translates to:
  /// **'Internationalization: Traditional Chinese conversion code & Easter egg code / Development: Optimize outputing arrangements to the calendar'**
  String get settingAboutPageGodhu777777;

  /// No description provided for @settingAboutPageHancl777.
  ///
  /// In en, this message translates to:
  /// **'Internationalization: Traditional Chinese conversion code'**
  String get settingAboutPageHancl777;

  /// No description provided for @settingAboutPageHazukiKeatsu.
  ///
  /// In en, this message translates to:
  /// **'Development: Physics experiment score query and recognization'**
  String get settingAboutPageHazukiKeatsu;

  /// No description provided for @settingAboutPageHawa130.
  ///
  /// In en, this message translates to:
  /// **'Design: Class info card'**
  String get settingAboutPageHawa130;

  /// No description provided for @settingAboutPageHhzm.
  ///
  /// In en, this message translates to:
  /// **'Development: electricity fee inquiry account calculation'**
  String get settingAboutPageHhzm;

  /// No description provided for @settingAboutPageImaginary17.
  ///
  /// In en, this message translates to:
  /// **'Developement: Ruisi navigator stack fix'**
  String get settingAboutPageImaginary17;

  /// No description provided for @settingAboutPageImoscarz.
  ///
  /// In en, this message translates to:
  /// **'Development: Homepage for software / Development: Checkin check for pad / Development: Sport UI Change'**
  String get settingAboutPageImoscarz;

  /// No description provided for @settingAboutPageKaMateKaOra.
  ///
  /// In en, this message translates to:
  /// **'Internationalization: English correction'**
  String get settingAboutPageKaMateKaOra;

  /// No description provided for @settingAboutPageLagrangeX.
  ///
  /// In en, this message translates to:
  /// **'Development: Class progress indicator (adopted) / Development: Gray cover on attended class and other classtable design'**
  String get settingAboutPageLagrangeX;

  /// No description provided for @settingAboutPageLhx666Cool.
  ///
  /// In en, this message translates to:
  /// **'Support: Windows and Linux build scripts / Development: New Slider \'26'**
  String get settingAboutPageLhx666Cool;

  /// No description provided for @settingAboutPageLichtyy.
  ///
  /// In en, this message translates to:
  /// **'Design: color pattern and blank page picture / Development: HTML reader for the experiment system'**
  String get settingAboutPageLichtyy;

  /// No description provided for @settingAboutPageLqsyH.
  ///
  /// In en, this message translates to:
  /// **'Support: Promotion Picture'**
  String get settingAboutPageLqsyH;

  /// No description provided for @settingAboutPageLsy223622.
  ///
  /// In en, this message translates to:
  /// **'Design: iOS and Android icons / Support: titled XDYou'**
  String get settingAboutPageLsy223622;

  /// No description provided for @settingAboutPageMrbrilliant2046.
  ///
  /// In en, this message translates to:
  /// **'Support: Provided the school net user guide / Internationalization: English correction'**
  String get settingAboutPageMrbrilliant2046;

  /// No description provided for @settingAboutPageNancunchild.
  ///
  /// In en, this message translates to:
  /// **'Development: library search function / Internationalization: English correction'**
  String get settingAboutPageNancunchild;

  /// No description provided for @settingAboutPageNkanf.
  ///
  /// In en, this message translates to:
  /// **'Development: Class progress indicator (original) / Support: MacOS build support'**
  String get settingAboutPageNkanf;

  /// No description provided for @settingAboutPagePairman.
  ///
  /// In en, this message translates to:
  /// **'Development: score cache and optimize slider algorithm / Internationalization: English correction'**
  String get settingAboutPagePairman;

  /// No description provided for @settingAboutPageReverierxu.
  ///
  /// In en, this message translates to:
  /// **'Design: REX card for information display / Development support: on postgraduate class schedule'**
  String get settingAboutPageReverierxu;

  /// No description provided for @settingAboutPageRrrilac.
  ///
  /// In en, this message translates to:
  /// **'Development support: electricity query'**
  String get settingAboutPageRrrilac;

  /// No description provided for @settingAboutPageRay.
  ///
  /// In en, this message translates to:
  /// **'Design: splash screen / Support: iOS publisher / Development guidance: on partner classtable development (This function has been removed) / Internationalization: English correction'**
  String get settingAboutPageRay;

  /// No description provided for @settingAboutPageShadowyingyi.
  ///
  /// In en, this message translates to:
  /// **'Support: two times of pigeon house official account publicity'**
  String get settingAboutPageShadowyingyi;

  /// No description provided for @settingAboutPageStalomeow.
  ///
  /// In en, this message translates to:
  /// **'Design: homepage timeline / Development: asynchronous login and captcha predict'**
  String get settingAboutPageStalomeow;

  /// No description provided for @settingAboutPageXeonds.
  ///
  /// In en, this message translates to:
  /// **'Design: settings page / Development: XDU Planet / Development: Payment Code'**
  String get settingAboutPageXeonds;

  /// No description provided for @settingAboutPageXingshuyu.
  ///
  /// In en, this message translates to:
  /// **'Development: Fix physics experiment api and electricity graph'**
  String get settingAboutPageXingshuyu;

  /// No description provided for @settingAboutPageXiue233.
  ///
  /// In en, this message translates to:
  /// **'Development: Android applet'**
  String get settingAboutPageXiue233;

  /// No description provided for @settingAboutPageXizi.
  ///
  /// In en, this message translates to:
  /// **'Development support: on postgraduate version'**
  String get settingAboutPageXizi;

  /// No description provided for @settingAboutPageWirsbf.
  ///
  /// In en, this message translates to:
  /// **'Development: fix course adjustment did not proceed as expected'**
  String get settingAboutPageWirsbf;

  /// No description provided for @settingAboutPageZcwzy.
  ///
  /// In en, this message translates to:
  /// **'Development: fix Dingxiang apartment electricity fee / development support: on postgraduate version / design: blank page picture'**
  String get settingAboutPageZcwzy;

  /// No description provided for @settingAboutPageZyarEr.
  ///
  /// In en, this message translates to:
  /// **'Development support: fix shortcut url'**
  String get settingAboutPageZyarEr;

  /// No description provided for @settingAboutPageHomepage.
  ///
  /// In en, this message translates to:
  /// **'Homepage'**
  String get settingAboutPageHomepage;

  /// No description provided for @settingAboutPageCode.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get settingAboutPageCode;

  /// No description provided for @settingAboutPageKnowMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get settingAboutPageKnowMore;

  /// No description provided for @settingAboutPageCopyrightNotice.
  ///
  /// In en, this message translates to:
  /// **'This software is compiled, or derived from the traintime_pda (a.k.a watermeter) codebase, which is licensed under Mozilla Public License v2.0.\n\nThis APP has no relation to Xidian University, Tishineng Service, Shuwow and other services.\n\nCopyright 2023-2025 BenderBlog Rodriguez and contributors.\nCopyright 2025-present Traintime PDA authors.\n\nThe Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, you can obtain one at https://mozilla.org/MPL/2.0/.'**
  String get settingAboutPageCopyrightNotice;

  /// No description provided for @settingAboutPageBeian.
  ///
  /// In en, this message translates to:
  /// **'ICP record code'**
  String get settingAboutPageBeian;

  /// No description provided for @settingAboutPageSignAndroid.
  ///
  /// In en, this message translates to:
  /// **'Android signature'**
  String get settingAboutPageSignAndroid;

  /// No description provided for @settingAboutPageTitle.
  ///
  /// In en, this message translates to:
  /// **'About this APP'**
  String get settingAboutPageTitle;

  /// No description provided for @sportTitle.
  ///
  /// In en, this message translates to:
  /// **'Sport Query'**
  String get sportTitle;

  /// No description provided for @sportClassInfo.
  ///
  /// In en, this message translates to:
  /// **'Class information'**
  String get sportClassInfo;

  /// No description provided for @sportEmptyClassInfo.
  ///
  /// In en, this message translates to:
  /// **'No class information found'**
  String get sportEmptyClassInfo;

  /// No description provided for @sportTestScore.
  ///
  /// In en, this message translates to:
  /// **'Sport test score'**
  String get sportTestScore;

  /// No description provided for @sportTotalScore.
  ///
  /// In en, this message translates to:
  /// **'Four-year total score'**
  String get sportTotalScore;

  /// No description provided for @sportTotalScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Score'**
  String get sportTotalScoreLabel;

  /// No description provided for @sportRankLabel.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get sportRankLabel;

  /// No description provided for @sportSemester.
  ///
  /// In en, this message translates to:
  /// **'Semester {year} {gradeType}'**
  String sportSemester(String year, String gradeType);

  /// No description provided for @sportSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get sportSubject;

  /// No description provided for @sportData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get sportData;

  /// No description provided for @sportScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get sportScore;

  /// No description provided for @sportPassed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get sportPassed;

  /// No description provided for @sportFromTo.
  ///
  /// In en, this message translates to:
  /// **'Period {start} to {stop}'**
  String sportFromTo(String start, String stop);

  /// No description provided for @sportScoreString.
  ///
  /// In en, this message translates to:
  /// **'{score} points'**
  String sportScoreString(String score);

  /// No description provided for @sportSituationNopassword.
  ///
  /// In en, this message translates to:
  /// **'No password'**
  String get sportSituationNopassword;

  /// No description provided for @sportSituationMaintain.
  ///
  /// In en, this message translates to:
  /// **'System maintenance'**
  String get sportSituationMaintain;

  /// No description provided for @sportSituationFailedLogin.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get sportSituationFailedLogin;

  /// No description provided for @sportSituationQuery.
  ///
  /// In en, this message translates to:
  /// **'Query failed'**
  String get sportSituationQuery;

  /// No description provided for @sportSituationNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network malfunction'**
  String get sportSituationNetwork;

  /// No description provided for @sportSituationUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown malfunction {situation}'**
  String sportSituationUnknown(String situation);

  /// No description provided for @sportSituationFetching.
  ///
  /// In en, this message translates to:
  /// **'Fetching...'**
  String get sportSituationFetching;

  /// No description provided for @sportSituationError.
  ///
  /// In en, this message translates to:
  /// **'Bad thing: {situation}'**
  String sportSituationError(String situation);

  /// No description provided for @sportCacheHintMissingPassword.
  ///
  /// In en, this message translates to:
  /// **'Please set your PE password and try again.'**
  String get sportCacheHintMissingPassword;

  /// No description provided for @sportCacheHintCredentialInvalid.
  ///
  /// In en, this message translates to:
  /// **'The PE login has expired. Please update your PE password and try again.'**
  String get sportCacheHintCredentialInvalid;

  /// No description provided for @sportCacheHintMaintain.
  ///
  /// In en, this message translates to:
  /// **'The PE service is under maintenance. Please try again later.'**
  String get sportCacheHintMaintain;

  /// No description provided for @sportCacheHintLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to log in to the PE service.'**
  String get sportCacheHintLoginFailed;

  /// No description provided for @sportCacheHintQueryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to query PE information.'**
  String get sportCacheHintQueryFailed;

  /// No description provided for @sportCacheHintNetwork.
  ///
  /// In en, this message translates to:
  /// **'The PE service network request failed.'**
  String get sportCacheHintNetwork;

  /// No description provided for @sportCacheHintUnknown.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch PE information online. Check logs for details.'**
  String get sportCacheHintUnknown;

  /// No description provided for @sportErrorAuthExpired.
  ///
  /// In en, this message translates to:
  /// **'The PE login has expired. Please try again.'**
  String get sportErrorAuthExpired;

  /// No description provided for @sportErrorMissingPassword.
  ///
  /// In en, this message translates to:
  /// **'PE password is not set'**
  String get sportErrorMissingPassword;

  /// No description provided for @sportErrorCredentialInvalid.
  ///
  /// In en, this message translates to:
  /// **'The PE login has expired. Please update your PE password and try again.'**
  String get sportErrorCredentialInvalid;

  /// No description provided for @toolboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Other Functions'**
  String get toolboxTitle;

  /// No description provided for @toolboxPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment System'**
  String get toolboxPayment;

  /// No description provided for @toolboxPaymentDescription.
  ///
  /// In en, this message translates to:
  /// **'Times to pay the electricity fee'**
  String get toolboxPaymentDescription;

  /// No description provided for @toolboxDrinkingwater.
  ///
  /// In en, this message translates to:
  /// **'Drinking Water'**
  String get toolboxDrinkingwater;

  /// No description provided for @toolboxDrinkingwaterDescription.
  ///
  /// In en, this message translates to:
  /// **'Is good for health'**
  String get toolboxDrinkingwaterDescription;

  /// No description provided for @toolboxRepair.
  ///
  /// In en, this message translates to:
  /// **'Repair report'**
  String get toolboxRepair;

  /// No description provided for @toolboxRepairDescription.
  ///
  /// In en, this message translates to:
  /// **'Don\'t let the water leak from the top'**
  String get toolboxRepairDescription;

  /// No description provided for @toolboxReserve.
  ///
  /// In en, this message translates to:
  /// **'Space Reservation'**
  String get toolboxReserve;

  /// No description provided for @toolboxReserveDescription.
  ///
  /// In en, this message translates to:
  /// **'Find a place to gathering'**
  String get toolboxReserveDescription;

  /// No description provided for @toolboxMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile Portal'**
  String get toolboxMobile;

  /// No description provided for @toolboxMobileDescription.
  ///
  /// In en, this message translates to:
  /// **'Specific for leaving'**
  String get toolboxMobileDescription;

  /// No description provided for @toolboxNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network Query'**
  String get toolboxNetwork;

  /// No description provided for @toolboxNetworkDescription.
  ///
  /// In en, this message translates to:
  /// **'Hope never charges (NO!)'**
  String get toolboxNetworkDescription;

  /// No description provided for @toolboxPhysics.
  ///
  /// In en, this message translates to:
  /// **'Physics Calculation'**
  String get toolboxPhysics;

  /// No description provided for @toolboxPhysicsDescription.
  ///
  /// In en, this message translates to:
  /// **'Hope the operation goes smoothly'**
  String get toolboxPhysicsDescription;

  /// No description provided for @toolboxDiscover.
  ///
  /// In en, this message translates to:
  /// **'Ruisi Navigation'**
  String get toolboxDiscover;

  /// No description provided for @toolboxDiscoverDescription.
  ///
  /// In en, this message translates to:
  /// **'Lots other functions'**
  String get toolboxDiscoverDescription;

  /// No description provided for @xduPlanetAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get xduPlanetAll;

  /// No description provided for @xduPlanetLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading, please wait <(=ω=)>'**
  String get xduPlanetLoading;

  /// No description provided for @xduPlanetUnknownAuthor.
  ///
  /// In en, this message translates to:
  /// **'Unknown author'**
  String get xduPlanetUnknownAuthor;

  /// No description provided for @xduPlanetLoadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get xduPlanetLoadFailedTitle;

  /// No description provided for @xduPlanetLoadFailedBottom.
  ///
  /// In en, this message translates to:
  /// **'Failed to load the article, you can click the button on the top right of the screen to open it in the browser.'**
  String get xduPlanetLoadFailedBottom;

  /// No description provided for @xduPlanetNoComment.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get xduPlanetNoComment;

  /// No description provided for @xduPlanetReplyAudit.
  ///
  /// In en, this message translates to:
  /// **'Reply comment #{reply_to} has been reported or deleted'**
  String xduPlanetReplyAudit(String reply_to);

  /// No description provided for @xduPlanetReply.
  ///
  /// In en, this message translates to:
  /// **'Reply to #{reply_to}: {content}'**
  String xduPlanetReply(String reply_to, String content);

  /// No description provided for @xduPlanetHaveBeenAudit.
  ///
  /// In en, this message translates to:
  /// **'This comment has been reported'**
  String get xduPlanetHaveBeenAudit;

  /// No description provided for @xduPlanetAudit.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get xduPlanetAudit;

  /// No description provided for @xduPlanetConfirmAuditDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm reporting'**
  String get xduPlanetConfirmAuditDialogTitle;

  /// No description provided for @xduPlanetConfirmAuditDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Think twice. Reporting will tag the comment, but it may not be deleted.'**
  String get xduPlanetConfirmAuditDialogContent;

  /// No description provided for @xduPlanetConfirmAuditDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Forget it'**
  String get xduPlanetConfirmAuditDialogCancel;

  /// No description provided for @xduPlanetConfirmAuditDialogOngoing.
  ///
  /// In en, this message translates to:
  /// **'Reporting...'**
  String get xduPlanetConfirmAuditDialogOngoing;

  /// No description provided for @xduPlanetConfirmAuditDialogFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to report'**
  String get xduPlanetConfirmAuditDialogFailed;

  /// No description provided for @xduPlanetConfirmAuditDialogSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully reporting'**
  String get xduPlanetConfirmAuditDialogSuccess;

  /// No description provided for @xduPlanetComment.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get xduPlanetComment;

  /// No description provided for @xduPlanetSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get xduPlanetSend;

  /// No description provided for @xduPlanetSending.
  ///
  /// In en, this message translates to:
  /// **'Sending comment'**
  String get xduPlanetSending;

  /// No description provided for @xduPlanetEmptySend.
  ///
  /// In en, this message translates to:
  /// **'Blank message sent'**
  String get xduPlanetEmptySend;

  /// No description provided for @xduPlanetHintSendComment.
  ///
  /// In en, this message translates to:
  /// **'Express yourself!'**
  String get xduPlanetHintSendComment;

  /// No description provided for @xduPlanetCommentTitle.
  ///
  /// In en, this message translates to:
  /// **'Comment on this article'**
  String get xduPlanetCommentTitle;

  /// No description provided for @xduPlanetCommentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully commenting'**
  String get xduPlanetCommentSuccess;

  /// No description provided for @xduPlanetCommentFailed.
  ///
  /// In en, this message translates to:
  /// **'Comment failed, please check the log'**
  String get xduPlanetCommentFailed;

  /// No description provided for @xduPlanetCommentCanceled.
  ///
  /// In en, this message translates to:
  /// **'Nothing to say?'**
  String get xduPlanetCommentCanceled;

  /// No description provided for @xduPlanetCommentLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading comments...'**
  String get xduPlanetCommentLoading;

  /// No description provided for @xduPlanetBlock.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get xduPlanetBlock;

  /// No description provided for @xduPlanetDelete.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get xduPlanetDelete;

  /// No description provided for @xduPlanetAudio.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get xduPlanetAudio;

  /// No description provided for @electricityStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get electricityStatusPending;

  /// No description provided for @electricityStatusRemainFetching.
  ///
  /// In en, this message translates to:
  /// **'Fetching...'**
  String get electricityStatusRemainFetching;

  /// No description provided for @electricityStatusRemainNetworkIssue.
  ///
  /// In en, this message translates to:
  /// **'Network malfunction'**
  String get electricityStatusRemainNetworkIssue;

  /// No description provided for @electricityStatusRemainNotFound.
  ///
  /// In en, this message translates to:
  /// **'Query failed'**
  String get electricityStatusRemainNotFound;

  /// No description provided for @electricityStatusRemainOtherIssue.
  ///
  /// In en, this message translates to:
  /// **'Query malfunction'**
  String get electricityStatusRemainOtherIssue;

  /// No description provided for @electricityStatusOweFetching.
  ///
  /// In en, this message translates to:
  /// **'Obtaining arrearage'**
  String get electricityStatusOweFetching;

  /// No description provided for @electricityStatusOweIssue.
  ///
  /// In en, this message translates to:
  /// **'Network malfunction of overdue information'**
  String get electricityStatusOweIssue;

  /// No description provided for @electricityStatusOweNotFound.
  ///
  /// In en, this message translates to:
  /// **'Cannot query arrearage, check log window for detail'**
  String get electricityStatusOweNotFound;

  /// No description provided for @electricityStatusOweNoNeed.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get electricityStatusOweNoNeed;

  /// No description provided for @electricityStatusOweNeedPay.
  ///
  /// In en, this message translates to:
  /// **'Need to pay {due} yuan'**
  String electricityStatusOweNeedPay(String due);

  /// No description provided for @electricityStatusOweIssueUnable.
  ///
  /// In en, this message translates to:
  /// **'Cannot query arrearage'**
  String get electricityStatusOweIssueUnable;

  /// No description provided for @electricityStatusNeedMoreInfo.
  ///
  /// In en, this message translates to:
  /// **'Need to improve information on the payment platform'**
  String get electricityStatusNeedMoreInfo;

  /// No description provided for @electricityStatusNeedAccount.
  ///
  /// In en, this message translates to:
  /// **'Need to input electricity account'**
  String get electricityStatusNeedAccount;

  /// No description provided for @electricityStatusCaptchaFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to check captcha'**
  String get electricityStatusCaptchaFailed;

  /// No description provided for @electricityStatusOtherIssue.
  ///
  /// In en, this message translates to:
  /// **'Program malfunction'**
  String get electricityStatusOtherIssue;

  /// No description provided for @schoolCardStatusFailedToFetch.
  ///
  /// In en, this message translates to:
  /// **'Failed fetching'**
  String get schoolCardStatusFailedToFetch;

  /// No description provided for @schoolCardStatusFailedToQuery.
  ///
  /// In en, this message translates to:
  /// **'Failed querying'**
  String get schoolCardStatusFailedToQuery;

  /// No description provided for @easterEggApple.
  ///
  /// In en, this message translates to:
  /// **'=== Fly Me To The Moon ===\nVocal: Frank Sintara, 1964\n\nFly me to the moon\nLet me play among the stars\n\nLet me see what\'s spring is like\non a Jupiter and Mars\n\nFill my heart with song\nand let me sing forever more\n\nYou are all I long for\nall I worship and I adore\n\nIn other words\nPlease, be true\n\nIn other words\nI love you\n\n=== Living Inside Your Love ===\nGuitar: Earl Klugh, 1976\n\nCan\'t get over the feeling\nLiving inside your love\n\nI never want to lose the feeling\nLiving inside your love\n\nBaby, you made my life so free\nLiving inside your love\n\nI\'m just where I want to be\nLiving inside your love\n\nAnd I never could say\nWhat I\'m feeling today\nFor you...\n'**
  String get easterEggApple;

  /// No description provided for @easterEggOthers.
  ///
  /// In en, this message translates to:
  /// **'=== Cardcaptor Sakura OP3 ===\nVocal: Maaya Sakamoto, 2000\nIn Japanese Roman Letters\n\nI\'m a dreamer\nhisomu PAWA-\n\nwatashi no sekai\nyume to koi to fuan de dekite\'ru\ndemo souzou wo shinai mono\nkakurete\'ru hazu\n\nsora ni mukau kiki no you ni anata wo\nmassugu mitsumete\'ru\nmitsuketai naa kanaetai naa\nshinjiru sore dake de\n\nkoerarenai mono wa nai\nutau you ni kiseki no you ni\n\"omoi\" ga subete wo kaete yuku yo\nkitto kitto\nodoroku kurai\n\n=== Living Inside Your Love ===\nGuitar: Earl Klugh, 1976\n\nCan\'t get over the feeling\nLiving inside your love\n\nI never want to lose the feeling\nLiving inside your love\n\nBaby, you made my life so free\nLiving inside your love\n\nI\'m just where I want to be\nLiving inside your love\n\nAnd I never could say\nWhat I\'m feeling today\nFor you...\n'**
  String get easterEggOthers;

  /// No description provided for @easterEggRobotAppbar.
  ///
  /// In en, this message translates to:
  /// **'Welcome Students!'**
  String get easterEggRobotAppbar;

  /// No description provided for @easterEggRobotTitle.
  ///
  /// In en, this message translates to:
  /// **'Looking like you are worrying about opening semester?'**
  String get easterEggRobotTitle;

  /// No description provided for @easterEggRobotContents.
  ///
  /// In en, this message translates to:
  /// **'We are here to let our children have more pocket money.\n1. Robots may not injure a human being or, through inaction, allow a human being to come to harm.\n2. Robots are born from the ashes of the network running at the cloud.\n3. Robots are lovestruck, which cannot be annoyed, and loves merging programs!\n4. Robots sometimes can be controlled to avoid the attack from the Angles.\n5. Robots have shiny metal ass which should not be bitten.\nAnd they have a plan.'**
  String get easterEggRobotContents;

  /// No description provided for @easterEggRobotButtonOne.
  ///
  /// In en, this message translates to:
  /// **'We are hanger for your help!'**
  String get easterEggRobotButtonOne;

  /// No description provided for @easterEggRobotButtonTwo.
  ///
  /// In en, this message translates to:
  /// **'Come on!'**
  String get easterEggRobotButtonTwo;

  /// No description provided for @easterEggRobotButtonNotice.
  ///
  /// In en, this message translates to:
  /// **'\\o/\\o/\\o/\\o/\\o/\\o/\\o/\\o/'**
  String get easterEggRobotButtonNotice;

  /// No description provided for @restartAppTitleCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache Cleared'**
  String get restartAppTitleCacheCleared;

  /// No description provided for @restartAppTitleLoggedOut.
  ///
  /// In en, this message translates to:
  /// **'Logged Out'**
  String get restartAppTitleLoggedOut;

  /// No description provided for @restartAppTitlePasswordWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong Password'**
  String get restartAppTitlePasswordWrong;

  /// No description provided for @restartAppContent.
  ///
  /// In en, this message translates to:
  /// **'Tap to reopen the app'**
  String get restartAppContent;

  /// No description provided for @ruisiCommonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get ruisiCommonRefresh;

  /// No description provided for @ruisiCommonConfirm.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ruisiCommonConfirm;

  /// No description provided for @ruisiCommonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get ruisiCommonCancel;

  /// No description provided for @ruisiCommonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get ruisiCommonRetry;

  /// No description provided for @ruisiCommonNoTopics.
  ///
  /// In en, this message translates to:
  /// **'No topics'**
  String get ruisiCommonNoTopics;

  /// No description provided for @ruisiCommonNoContent.
  ///
  /// In en, this message translates to:
  /// **'No content'**
  String get ruisiCommonNoContent;

  /// No description provided for @ruisiCommonReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get ruisiCommonReply;

  /// No description provided for @ruisiCommonFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get ruisiCommonFavorite;

  /// No description provided for @ruisiCommonNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Not implemented'**
  String get ruisiCommonNotImplemented;

  /// No description provided for @ruisiCommonLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get ruisiCommonLogin;

  /// No description provided for @ruisiCommonLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get ruisiCommonLogout;

  /// No description provided for @ruisiCommonLoggedOut.
  ///
  /// In en, this message translates to:
  /// **'Logged out'**
  String get ruisiCommonLoggedOut;

  /// No description provided for @ruisiCommonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get ruisiCommonSubmit;

  /// No description provided for @ruisiAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get ruisiAboutTitle;

  /// No description provided for @ruisiAboutAppName.
  ///
  /// In en, this message translates to:
  /// **'Ruisi'**
  String get ruisiAboutAppName;

  /// No description provided for @ruisiAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Xidian University Campus Forum Client'**
  String get ruisiAboutSubtitle;

  /// No description provided for @ruisiAboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get ruisiAboutVersion;

  /// No description provided for @ruisiAboutVersionNumber.
  ///
  /// In en, this message translates to:
  /// **'2.0.0 (Bundled with XDYou 1.6.0)'**
  String get ruisiAboutVersionNumber;

  /// No description provided for @ruisiAboutSourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source Code'**
  String get ruisiAboutSourceCode;

  /// No description provided for @ruisiAboutBugReport.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get ruisiAboutBugReport;

  /// No description provided for @ruisiAboutBugReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Submit an issue on GitHub'**
  String get ruisiAboutBugReportSubtitle;

  /// No description provided for @ruisiAboutPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get ruisiAboutPrivacyPolicy;

  /// No description provided for @ruisiAboutLicense.
  ///
  /// In en, this message translates to:
  /// **'Open-sourced under the BSD-3-Clause License Reimplemented based on Ruisi-iOS and Ruisi-Android with AI assistant'**
  String get ruisiAboutLicense;

  /// No description provided for @ruisiAboutPrivacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'This app only operates on the Xidian University campus network, accessing data from the Ruisi Forum (rs.xidian.edu.cn).\n\nThis app does not collect, store, or transmit any personal information to third-party servers.\n\nUser login credentials are stored only on the local device, used for authentication with the Ruisi Forum server.\n\nThis app uses cookies to communicate with the Ruisi Forum server. All data exchange occurs directly between the user\'s device and the Ruisi Forum server.\n\nIf you have any questions, please contact the developer by submitting an issue on GitHub.'**
  String get ruisiAboutPrivacyPolicyContent;

  /// No description provided for @ruisiHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Ruisi Forum'**
  String get ruisiHomeTitle;

  /// No description provided for @ruisiHomeNewPost.
  ///
  /// In en, this message translates to:
  /// **'New Post'**
  String get ruisiHomeNewPost;

  /// No description provided for @ruisiHomeForumList.
  ///
  /// In en, this message translates to:
  /// **'Forum List'**
  String get ruisiHomeForumList;

  /// No description provided for @ruisiHomeTabHot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get ruisiHomeTabHot;

  /// No description provided for @ruisiHomeTabNewReply.
  ///
  /// In en, this message translates to:
  /// **'Latest Replies'**
  String get ruisiHomeTabNewReply;

  /// No description provided for @ruisiHomeTabNewPost.
  ///
  /// In en, this message translates to:
  /// **'Latest Posts'**
  String get ruisiHomeTabNewPost;

  /// No description provided for @ruisiHomeTabMy.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get ruisiHomeTabMy;

  /// No description provided for @ruisiHomeTabTrade.
  ///
  /// In en, this message translates to:
  /// **'Trading'**
  String get ruisiHomeTabTrade;

  /// No description provided for @ruisiHomeTabWater.
  ///
  /// In en, this message translates to:
  /// **'Water Bar'**
  String get ruisiHomeTabWater;

  /// No description provided for @ruisiHomeTabLostFound.
  ///
  /// In en, this message translates to:
  /// **'Lost & Found'**
  String get ruisiHomeTabLostFound;

  /// No description provided for @ruisiHomeTabEmployment.
  ///
  /// In en, this message translates to:
  /// **'Employment'**
  String get ruisiHomeTabEmployment;

  /// No description provided for @ruisiHomeTabPhotography.
  ///
  /// In en, this message translates to:
  /// **'Photography'**
  String get ruisiHomeTabPhotography;

  /// No description provided for @ruisiHomePleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Please log in first'**
  String get ruisiHomePleaseLogin;

  /// No description provided for @ruisiHomeMyProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get ruisiHomeMyProfile;

  /// No description provided for @ruisiHomeMyPosts.
  ///
  /// In en, this message translates to:
  /// **'My Posts'**
  String get ruisiHomeMyPosts;

  /// No description provided for @ruisiHomeMyFavorites.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get ruisiHomeMyFavorites;

  /// No description provided for @ruisiHomeMessageCenter.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get ruisiHomeMessageCenter;

  /// No description provided for @ruisiHomeDailyCheckin.
  ///
  /// In en, this message translates to:
  /// **'Daily Check-in'**
  String get ruisiHomeDailyCheckin;

  /// No description provided for @ruisiHomeSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get ruisiHomeSettings;

  /// No description provided for @ruisiHomeAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get ruisiHomeAbout;

  /// No description provided for @ruisiHomeSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get ruisiHomeSearch;

  /// No description provided for @ruisiLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login to Ruisi'**
  String get ruisiLoginTitle;

  /// No description provided for @ruisiLoginUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get ruisiLoginUsername;

  /// No description provided for @ruisiLoginUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get ruisiLoginUsernameHint;

  /// No description provided for @ruisiLoginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get ruisiLoginPassword;

  /// No description provided for @ruisiLoginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get ruisiLoginPasswordHint;

  /// No description provided for @ruisiLoginCaptcha.
  ///
  /// In en, this message translates to:
  /// **'Captcha'**
  String get ruisiLoginCaptcha;

  /// No description provided for @ruisiLoginCaptchaHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter captcha'**
  String get ruisiLoginCaptchaHint;

  /// No description provided for @ruisiLoginBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get ruisiLoginBack;

  /// No description provided for @ruisiLoginResetLoginState.
  ///
  /// In en, this message translates to:
  /// **'Reset Login State'**
  String get ruisiLoginResetLoginState;

  /// No description provided for @ruisiLoginResetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Reset'**
  String get ruisiLoginResetConfirmTitle;

  /// No description provided for @ruisiLoginResetConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset the login state? This will clear all login information.'**
  String get ruisiLoginResetConfirmContent;

  /// No description provided for @ruisiLoginResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login state has been reset'**
  String get ruisiLoginResetSuccess;

  /// No description provided for @ruisiLoginViewLogs.
  ///
  /// In en, this message translates to:
  /// **'View Logs'**
  String get ruisiLoginViewLogs;

  /// No description provided for @ruisiPostTitle.
  ///
  /// In en, this message translates to:
  /// **'New Post'**
  String get ruisiPostTitle;

  /// No description provided for @ruisiPostPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get ruisiPostPublish;

  /// No description provided for @ruisiPostSelectForum.
  ///
  /// In en, this message translates to:
  /// **'Select Forum'**
  String get ruisiPostSelectForum;

  /// No description provided for @ruisiPostSelectForumHint.
  ///
  /// In en, this message translates to:
  /// **'Please select a forum'**
  String get ruisiPostSelectForumHint;

  /// No description provided for @ruisiPostSubject.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get ruisiPostSubject;

  /// No description provided for @ruisiPostSubjectHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get ruisiPostSubjectHint;

  /// No description provided for @ruisiPostContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get ruisiPostContent;

  /// No description provided for @ruisiPostContentHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter content'**
  String get ruisiPostContentHint;

  /// No description provided for @ruisiPostSuccess.
  ///
  /// In en, this message translates to:
  /// **'Post published'**
  String get ruisiPostSuccess;

  /// No description provided for @ruisiPostFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to publish'**
  String get ruisiPostFailure;

  /// No description provided for @ruisiPostSmiley.
  ///
  /// In en, this message translates to:
  /// **'Smileys'**
  String get ruisiPostSmiley;

  /// No description provided for @ruisiTopicDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Topic Detail'**
  String get ruisiTopicDetailTitle;

  /// No description provided for @ruisiTopicDetailReplyTooShort.
  ///
  /// In en, this message translates to:
  /// **'Reply must be at least 13 characters'**
  String get ruisiTopicDetailReplyTooShort;

  /// No description provided for @ruisiTopicDetailReplySuccess.
  ///
  /// In en, this message translates to:
  /// **'Reply sent'**
  String get ruisiTopicDetailReplySuccess;

  /// No description provided for @ruisiTopicDetailReplyFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to reply'**
  String get ruisiTopicDetailReplyFailure;

  /// No description provided for @ruisiTopicDetailFavoriteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get ruisiTopicDetailFavoriteSuccess;

  /// No description provided for @ruisiTopicDetailFavoriteFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to add to favorites'**
  String get ruisiTopicDetailFavoriteFailure;

  /// No description provided for @ruisiTopicDetailNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get ruisiTopicDetailNoData;

  /// No description provided for @ruisiTopicDetailReplyHint.
  ///
  /// In en, this message translates to:
  /// **'Write a reply...'**
  String get ruisiTopicDetailReplyHint;

  /// No description provided for @ruisiTopicDetailVoteSingleSelect.
  ///
  /// In en, this message translates to:
  /// **'Single choice'**
  String get ruisiTopicDetailVoteSingleSelect;

  /// No description provided for @ruisiTopicDetailVoteMultiSelect.
  ///
  /// In en, this message translates to:
  /// **'Multiple choice, up to {count}'**
  String ruisiTopicDetailVoteMultiSelect(String count);

  /// No description provided for @ruisiTopicDetailVoteTitlePrefix.
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get ruisiTopicDetailVoteTitlePrefix;

  /// No description provided for @ruisiTopicDetailVoteCount.
  ///
  /// In en, this message translates to:
  /// **'{count} people voted'**
  String ruisiTopicDetailVoteCount(String count);

  /// No description provided for @ruisiTopicDetailVoteOpen.
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get ruisiTopicDetailVoteOpen;

  /// No description provided for @ruisiTopicDetailVoteSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get ruisiTopicDetailVoteSheetTitle;

  /// No description provided for @ruisiTopicDetailVoteMaxSelection.
  ///
  /// In en, this message translates to:
  /// **'You can select up to {count}'**
  String ruisiTopicDetailVoteMaxSelection(String count);

  /// No description provided for @ruisiTopicDetailVoteNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Please select an option'**
  String get ruisiTopicDetailVoteNotSelected;

  /// No description provided for @ruisiTopicDetailVoteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Vote submitted'**
  String get ruisiTopicDetailVoteSuccess;

  /// No description provided for @ruisiTopicDetailVoteFailure.
  ///
  /// In en, this message translates to:
  /// **'Vote failed'**
  String get ruisiTopicDetailVoteFailure;

  /// No description provided for @ruisiTopicDetailVoteParamError.
  ///
  /// In en, this message translates to:
  /// **'Vote failed: invalid parameters'**
  String get ruisiTopicDetailVoteParamError;

  /// No description provided for @ruisiTopicDetailVoteAlreadyVoted.
  ///
  /// In en, this message translates to:
  /// **'You have already voted. Thank you!'**
  String get ruisiTopicDetailVoteAlreadyVoted;

  /// No description provided for @ruisiTopicDetailVoteExpired.
  ///
  /// In en, this message translates to:
  /// **'This poll has expired or been closed'**
  String get ruisiTopicDetailVoteExpired;

  /// No description provided for @ruisiTopicDetailVoteEnded.
  ///
  /// In en, this message translates to:
  /// **'This poll has ended'**
  String get ruisiTopicDetailVoteEnded;

  /// No description provided for @ruisiTopicListItemSticky.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get ruisiTopicListItemSticky;

  /// No description provided for @ruisiForumListTitle.
  ///
  /// In en, this message translates to:
  /// **'Forum List'**
  String get ruisiForumListTitle;

  /// No description provided for @ruisiForumListEmpty.
  ///
  /// In en, this message translates to:
  /// **'Ruisi Forum section grouping is empty'**
  String get ruisiForumListEmpty;

  /// No description provided for @ruisiFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get ruisiFavoritesTitle;

  /// No description provided for @ruisiFavoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No favorites'**
  String get ruisiFavoritesEmpty;

  /// No description provided for @ruisiMessagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get ruisiMessagesTitle;

  /// No description provided for @ruisiMessagesTabAt.
  ///
  /// In en, this message translates to:
  /// **'@Me'**
  String get ruisiMessagesTabAt;

  /// No description provided for @ruisiMessagesNoReply.
  ///
  /// In en, this message translates to:
  /// **'No reply notifications'**
  String get ruisiMessagesNoReply;

  /// No description provided for @ruisiMessagesNoAt.
  ///
  /// In en, this message translates to:
  /// **'No @ notifications'**
  String get ruisiMessagesNoAt;

  /// No description provided for @ruisiSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search topics...'**
  String get ruisiSearchHint;

  /// No description provided for @ruisiSearchInputHint.
  ///
  /// In en, this message translates to:
  /// **'Enter keywords to search'**
  String get ruisiSearchInputHint;

  /// No description provided for @ruisiSearchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get ruisiSearchNoResults;

  /// No description provided for @ruisiSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get ruisiSettingsTitle;

  /// No description provided for @ruisiSettingsSectionProxy.
  ///
  /// In en, this message translates to:
  /// **'Proxy'**
  String get ruisiSettingsSectionProxy;

  /// No description provided for @ruisiSettingsProxyEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable Proxy'**
  String get ruisiSettingsProxyEnable;

  /// No description provided for @ruisiSettingsProxyDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get ruisiSettingsProxyDisabled;

  /// No description provided for @ruisiSettingsProxyAddress.
  ///
  /// In en, this message translates to:
  /// **'Proxy Address'**
  String get ruisiSettingsProxyAddress;

  /// No description provided for @ruisiSettingsSectionDebug.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get ruisiSettingsSectionDebug;

  /// No description provided for @ruisiSettingsViewLogs.
  ///
  /// In en, this message translates to:
  /// **'View Logs'**
  String get ruisiSettingsViewLogs;

  /// No description provided for @ruisiSettingsProxyDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Proxy Settings'**
  String get ruisiSettingsProxyDialogTitle;

  /// No description provided for @ruisiSettingsProxyHost.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get ruisiSettingsProxyHost;

  /// No description provided for @ruisiSettingsProxyHostHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 127.0.0.1'**
  String get ruisiSettingsProxyHostHint;

  /// No description provided for @ruisiSettingsProxyPort.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get ruisiSettingsProxyPort;

  /// No description provided for @ruisiSettingsProxyPortHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 7890'**
  String get ruisiSettingsProxyPortHint;

  /// No description provided for @ruisiUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get ruisiUserTitle;

  /// No description provided for @ruisiUserTabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get ruisiUserTabProfile;

  /// No description provided for @ruisiUserUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get ruisiUserUnknown;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Load Error'**
  String get loadError;

  /// No description provided for @courseReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Pre-class Reminder: {name}'**
  String courseReminderTitle(String name);

  /// No description provided for @courseReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Class starts in {time} minutes'**
  String courseReminderBody(String time);

  /// No description provided for @courseReminderLocation.
  ///
  /// In en, this message translates to:
  /// **'Location: {location}'**
  String courseReminderLocation(String location);

  /// No description provided for @courseReminderTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher: {teacher}'**
  String courseReminderTeacher(String teacher);
}

class _I18nDelegate extends LocalizationsDelegate<I18n> {
  const _I18nDelegate();

  @override
  Future<I18n> load(Locale locale) {
    return SynchronousFuture<I18n>(lookupI18n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_I18nDelegate old) => false;
}

I18n lookupI18n(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return I18nZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return I18nEn();
    case 'zh':
      return I18nZh();
  }

  throw FlutterError(
    'I18n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
