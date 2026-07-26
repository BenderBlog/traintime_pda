// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class I18nEn extends I18n {
  I18nEn([String locale = 'en']) : super(locale);

  @override
  String get dragText => 'Pull to request more';

  @override
  String get readyText => 'Loading...';

  @override
  String get processingText => 'Processing...';

  @override
  String get processedText => 'Successfully requested';

  @override
  String get noMoreText => 'No more data';

  @override
  String get failedText => 'Failed to load data';

  @override
  String get chooseSemester => 'Choose Semester';

  @override
  String get errorDetected => 'Ouch! An error occurred!';

  @override
  String get clickToRefresh => 'Click to refresh';

  @override
  String get confirmTitle => 'Confirm? (ゝ∀･)';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Okay';

  @override
  String get networkError =>
      'Network error, maybe you are not connected to the Internet, or the school server is down :P';

  @override
  String get errorDetect => 'An error has occurred,';

  @override
  String get queryFailed => 'Query failed';

  @override
  String get notSchoolNetwork => 'Not on the Campus Network';

  @override
  String get experimentControllerNoPassword =>
      'Experiment password is not set, please set up one in the setting';

  @override
  String get experimentControllerLoginFailed => 'Login failed';

  @override
  String get cancelExam => 'Disqualified to exam :P';

  @override
  String get loginProcessReadyPage => 'Prepare to obtain login environment';

  @override
  String get loginProcessGetEncrypt => 'Obtain password encryption key';

  @override
  String get loginProcessReadyLogin => 'Prepare to login';

  @override
  String get loginProcessSlider => 'Logging in';

  @override
  String get loginProcessAfterProcess => 'Post-login processing';

  @override
  String loginProcessFailed(String statusCode) {
    return 'Login failed, response status code: $statusCode';
  }

  @override
  String get noInfo => 'No information';

  @override
  String get catcherDetected => 'An error has occurred';

  @override
  String get catcherDescription => 'Details are shown as follows';

  @override
  String get newHomepageHint =>
      'A new homepage is developing here, the pigimg is a placeholder, have fun';

  @override
  String localCacheHint(String datetime) {
    return 'Local cache from $datetime';
  }

  @override
  String inappCacheHint(String datetime) {
    return 'In-app cache from $datetime\nCache will be cleared once restart!';
  }

  @override
  String get cacheReasonDefault => 'Showing cached data.';

  @override
  String get weekdayMonday => 'Mon.';

  @override
  String get weekdayTuesday => 'Tue.';

  @override
  String get weekdayWednesday => 'Wed.';

  @override
  String get weekdayThursday => 'Thu.';

  @override
  String get weekdayFriday => 'Fri.';

  @override
  String get weekdaySaturday => 'Sat.';

  @override
  String get weekdaySunday => 'Sun.';

  @override
  String get monthJanuary => 'Jan.';

  @override
  String get monthFebruary => 'Feb.';

  @override
  String get monthMarch => 'Mar.';

  @override
  String get monthApril => 'Apr.';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'Jun.';

  @override
  String get monthJuly => 'Jul.';

  @override
  String get monthAugust => 'Aug.';

  @override
  String get monthSeptember => 'Sept.';

  @override
  String get monthOctober => 'Oct.';

  @override
  String get monthNovember => 'Nov.';

  @override
  String get monthDecember => 'Dec.';

  @override
  String get classAttendanceTitle => 'Attendance Query';

  @override
  String classAttendanceDetailTitle(String courseName) {
    return 'Attendance Detail - $courseName';
  }

  @override
  String get classAttendanceNoData => 'No course info';

  @override
  String get classAttendanceNoAttendanceRecord => 'No attendance record';

  @override
  String get classAttendanceLongLoad =>
      'It takes about half minute to load attendance data, pleace wait patiently';

  @override
  String get classAttendanceCourseStateUnknown => 'unknown';

  @override
  String get classAttendanceCourseStateIneligible => 'ineligible';

  @override
  String get classAttendanceCourseStateEligible => 'eligible';

  @override
  String get classAttendanceCourseStateWarning => 'warning';

  @override
  String get classAttendanceTableCourseName => 'Course Name';

  @override
  String get classAttendanceTableStatus => 'Status';

  @override
  String get classAttendanceTableAttendanceRate => 'Rate';

  @override
  String get classAttendanceTableCheckIn => 'Check-in';

  @override
  String get classAttendanceTableAbsence => 'Absence';

  @override
  String get classAttendanceTableRequired => 'Required';

  @override
  String get classAttendanceTableLeave => 'Leave(P/S/O)';

  @override
  String get classAttendanceTableFilter => 'Filter';

  @override
  String get classAttendanceTableFilterAll => 'All';

  @override
  String classAttendanceTableShowingCount(String count, String total) {
    return 'Showing $count/$total courses';
  }

  @override
  String get classAttendanceCardTime => 'Attendances';

  @override
  String classAttendanceCardTimeInfo(
    String checkInCount,
    String absenceCount,
    String requiredCheckIn,
  ) {
    return '$checkInCount Checked / $absenceCount Absences / $requiredCheckIn Required';
  }

  @override
  String get classAttendanceCardNotAttend => 'Rebirths';

  @override
  String classAttendanceCardNotAttendInfo(
    String timeToHaveError,
    String totalTimes,
  ) {
    return '$timeToHaveError Times / $totalTimes Total';
  }

  @override
  String get classAttendanceCardNotAttendInfoError =>
      'Cannot match course in the classtable';

  @override
  String get classAttendanceCardLeave => 'Leaves';

  @override
  String classAttendanceCardLeaveInfo(
    String personalLeave,
    String sickLeave,
    String officialLeave,
  ) {
    return 'Personal $personalLeave / Sick $sickLeave / Official $officialLeave';
  }

  @override
  String get classAttendanceCardStudy => 'Study';

  @override
  String classAttendanceCardStudyInfo(
    String taskProgress,
    String homeworkProgress,
    String examProgress,
  ) {
    return 'Task $taskProgress / Works $homeworkProgress / Exam $examProgress';
  }

  @override
  String get classAttendanceDetailCardCreatorName => 'Creator';

  @override
  String get classAttendanceDetailCardStartTime => 'Start at';

  @override
  String get classAttendanceDetailCardSummitTime => 'Summit at';

  @override
  String get classAttendanceSignTypeQrCode => 'QR Code Checkin';

  @override
  String get classAttendanceSignTypeGesture => 'Gesture Checkin';

  @override
  String get classAttendanceSignTypePosition => 'Position Checkin';

  @override
  String get classAttendanceSignTypeDefault => 'Normal Checkin';

  @override
  String get classAttendanceSignStatusAbsencenotparticipating =>
      'Absence (Not participating)';

  @override
  String get classAttendanceSignStatusSigned => 'Signed';

  @override
  String get classAttendanceSignStatusSignedbyteacher => 'Signed by teacher';

  @override
  String get classAttendanceSignStatusPersonalleave2 => 'Personal Leave';

  @override
  String get classAttendanceSignStatusAbsence => 'Absence';

  @override
  String get classAttendanceSignStatusSickleave => 'Sick Leave';

  @override
  String get classAttendanceSignStatusPersonalleave => 'Personal Leave';

  @override
  String get classAttendanceSignStatusLate => 'Late';

  @override
  String get classAttendanceSignStatusLeaveearly => 'Leave Early';

  @override
  String get classAttendanceSignStatusSignexpiredy => 'Sign Expired';

  @override
  String get classAttendanceSignStatusPublicleave => 'Public Leave';

  @override
  String get classtablePartnerClasstableOverrideDialog =>
      'Currently there is a partner classtable data, do you want to overwrite?';

  @override
  String get classtablePartnerClasstableNoFile => 'Import file not found';

  @override
  String get classtablePartnerClasstableNoPermission =>
      'Storage permission denied , cannot read file';

  @override
  String get classtablePartnerClasstableProblem =>
      'Maybe there\'s a problem with the import file :P';

  @override
  String get classtablePartnerClasstableSuccess => 'Successfully imported';

  @override
  String get classtablePartnerClasstableShareDialogTitle => 'Caution!';

  @override
  String get classtablePartnerClasstableShareDialogContent =>
      'The exported file may include your personal information, please DO NOT share casually';

  @override
  String get classtablePartnerClasstableSaveDialogTitle =>
      'Save calendar file to...';

  @override
  String get classtablePartnerClasstableSaveDialogSuccessMessage =>
      'Should be saved';

  @override
  String get classtablePartnerClasstableSaveDialogFailureMessage =>
      'Can not create the file, save fails.';

  @override
  String get classtablePartnerClasstableDeleteDialogTitle =>
      '(｡í _ ì｡)For real?';

  @override
  String get classtablePartnerClasstableDeleteDialogMessage =>
      'Are you sure to delete the partner classtable?';

  @override
  String get classtablePartnerClasstableDeleteDialogSuccessMessage => 'Done';

  @override
  String get classtablePartnerClasstableNameDialogTitle =>
      'Input the name of the partner classtable to be shown on your partner\'s screen';

  @override
  String get classtablePartnerClasstableNameDialogHint =>
      'Input here, otherwise it will be shown as \'Sweetie\'';

  @override
  String get classtablePartnerClasstableNameDialogCancel =>
      'There\'s nobody other than my sweetie';

  @override
  String get classtablePartnerClasstableNameDialogAccept => 'Submit';

  @override
  String get classtablePartnerClasstableNameDialogBlankInput =>
      'Input is blank!';

  @override
  String get classtablePageTitle => 'My Schedule';

  @override
  String classtablePartnerPageTitle(String partner_name) {
    return '$partner_name\'s Schedule';
  }

  @override
  String get classtablePopupMenuNotArranged => 'View unarranged classes';

  @override
  String get classtablePopupMenuClassChanged => 'View schedule changes';

  @override
  String get classtablePopupMenuAddClass => 'Add class';

  @override
  String get classtablePopupMenuGenerateIcal => 'Export calendar file';

  @override
  String get classtablePopupMenuGeneratePartnerFile =>
      'Export partner classtable file';

  @override
  String get classtablePopupMenuImportPartnerFile =>
      'Import partner classtable file';

  @override
  String get classtablePopupMenuDeletePartnerFile =>
      'Delete partner classtable file';

  @override
  String get classtablePopupMenuOutputToSystem => 'Export to system calendar';

  @override
  String get classtablePopupMenuRefreshClasstable => 'Refresh schedule';

  @override
  String get classtablePopupMenuSwitchSemester => 'Switch classtable semester';

  @override
  String get classtablePopupMenuCurrentTimeSettings =>
      'Time indicator settings';

  @override
  String get classtablePopupMenuClassColorSettings => 'Class color settings';

  @override
  String get classtableVisualSettingsCurrentTimeSettingsTitle =>
      'Time indicator settings';

  @override
  String get classtableVisualSettingsClassColorSettingsTitle =>
      'Class color settings';

  @override
  String get classtableVisualSettingsCompletedStyleEnabled =>
      'Completed class styling distinction';

  @override
  String get classtableVisualSettingsCurrentTimeSection => 'Time indicators';

  @override
  String get classtableVisualSettingsShowCurrentTimeIndicator =>
      'Show current time indicator';

  @override
  String get classtableVisualSettingsShowCurrentTimeLabel =>
      'Show mini time label';

  @override
  String get classtableVisualSettingsShowTodayColumnHighlight =>
      'Highlight today\'s column';

  @override
  String get classtableVisualSettingsUnfinishedSection => 'Class style';

  @override
  String classtableVisualSettingsActiveBrightnessFactor(String value) {
    return 'Brightness: $value';
  }

  @override
  String classtableVisualSettingsActiveBorderAlpha(String value) {
    return 'Border opacity: $value';
  }

  @override
  String classtableVisualSettingsActiveInnerAlpha(String value) {
    return 'Fill opacity: $value';
  }

  @override
  String get classtableVisualSettingsCompletedSection =>
      'Completed class style';

  @override
  String classtableVisualSettingsCompletedSaturationFactor(String value) {
    return 'Fill saturation: $value';
  }

  @override
  String classtableVisualSettingsCompletedBrightnessFactor(String value) {
    return 'Brightness: $value';
  }

  @override
  String classtableVisualSettingsCompletedTextSaturationFactor(String value) {
    return 'Text saturation: $value';
  }

  @override
  String classtableVisualSettingsCompletedBorderAlpha(String value) {
    return 'Border opacity: $value';
  }

  @override
  String classtableVisualSettingsCompletedInnerAlpha(String value) {
    return 'Fill opacity: $value';
  }

  @override
  String get classtableStatusSourceClassTable => 'Class Table';

  @override
  String get classtableStatusSourceExam => 'Exams';

  @override
  String get classtableStatusSourcePhysicsExperiment => 'Physics Experiments';

  @override
  String get classtableStatusSourceOtherExperiment => 'Other Experiments';

  @override
  String get classtableErrorDialogTitle => 'Error Info';

  @override
  String classtableStatusBannerLoading(String sources) {
    return 'Updating: $sources';
  }

  @override
  String classtableStatusBannerCache(String sources) {
    return 'Using cached data: $sources';
  }

  @override
  String classtableStatusBannerErrorSummary(String sources) {
    return 'Failed to load: $sources';
  }

  @override
  String classtableEmptyStateNoCourse(String semester_code) {
    return 'No classes are arranged for semester $semester_code.';
  }

  @override
  String classtableEmptyStateWithExam(String semester_code) {
    return 'No classes are arranged for semester $semester_code, but exam arrangements are available.';
  }

  @override
  String classtableEmptyStateWithExperiment(String semester_code) {
    return 'No classes are arranged for semester $semester_code, but experiment arrangements are available.';
  }

  @override
  String classtableEmptyStateWithExamAndExperiment(String semester_code) {
    return 'No classes are arranged for semester $semester_code, but exam and experiment arrangements are available.';
  }

  @override
  String get classtableEmptyActionViewExam => 'View exams';

  @override
  String get classtableEmptyActionViewExperiment => 'View experiments';

  @override
  String get classtableClassChangePageTitle => 'Schedule Changes';

  @override
  String get classtableClassChangePageEmptyMessage =>
      'Currently there\'s no class schedule changes';

  @override
  String classtableClassChangePageTeacherChange(
    String previous_teacher,
    String new_teacher,
  ) {
    return 'Teacher has been changed from $previous_teacher to $new_teacher';
  }

  @override
  String get classtableClassChangePageNoTeacherChange =>
      'Teacher kept unchanged';

  @override
  String get classtableClassChangePage1 => 'One';

  @override
  String get classtableClassChangePage2 => 'Two';

  @override
  String get classtableClassChangePage3 => 'Three';

  @override
  String get classtableClassChangePage4 => 'Four';

  @override
  String get classtableClassChangePage5 => 'Five';

  @override
  String get classtableClassChangePage6 => 'Six';

  @override
  String get classtableClassChangePage7 => 'Seven';

  @override
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
  ) {
    return 'This is a course adjustment info，Originally scheduled on period $originalClassRangeStart to period $originalClassRangeEnd at the ${weekChar_originalWeek}th day of the ${originalAffectedWeeks}th week(s), now it is at the $newClassroom classroom, arranged at the period $newClassRangeStart to period $newClassRangeStop at the ${weekChar_newWeek}th day of the $newAffectedWeeksListStr week(s).';
  }

  @override
  String classtableClassChangePagePatchClassMessage(
    String newClassroom,
    String newClassRangeStart,
    String newClassRangeStop,
    String weekChar_newWeek,
    String newAffectedWeeksListStr,
  ) {
    return 'This is a course reschedule info，The course have been rescheduled at the $newClassroom, on the period $newClassRangeStart to period $newClassRangeStop at the ${weekChar_newWeek}th day of the $newAffectedWeeksListStr week(s).';
  }

  @override
  String classtableClassChangePageStopClassMessage(
    String originalClassRangeStart,
    String originalClassRangeEnd,
    String weekChar_originalWeek,
    String originalAffectedWeeks,
  ) {
    return 'This is a course suspension info. The class will be suspended at the period $originalClassRangeStart to period $originalClassRangeEnd at the $weekChar_originalWeek day of the $originalAffectedWeeks week(s).';
  }

  @override
  String classtableClassChangePageClassInfo(
    String classCode,
    String classNumber,
    String classChange,
    String teacherChange,
  ) {
    return 'Code: $classCode | Class $classNumber\nSchedule change: $classChange\n$teacherChange';
  }

  @override
  String get classtableNotArrangedPageTitle => 'Unscheduled Classes';

  @override
  String get classtableNotArrangedPageEmptyMessage =>
      'All courses have been scheduled';

  @override
  String classtableNotArrangedPageContent(
    String classCode,
    String classNumber,
    String teacher,
  ) {
    return 'Code $classCode | Class $classNumber\nTeacher: $teacher';
  }

  @override
  String classtableEmptyClassMessage(String semester_code) {
    return 'Semester $semester_code has no class arranged';
  }

  @override
  String classtableEmptyClassWithExam(String semester_code) {
    return 'Semester $semester_code has no class arranged\nbut we have exam info now!\nGo back to mainpage and goto the exam info page.';
  }

  @override
  String classtableWeekTitle(String week) {
    return 'Week $week';
  }

  @override
  String get classtableNoonBreak => 'Noon';

  @override
  String get classtableSupperBreak => 'Supper';

  @override
  String classtableMonth(String month) {
    return '$month\nmo';
  }

  @override
  String get classtableNoClass =>
      'No schedule arranged in this week, please do not spend much of your time on bed.';

  @override
  String get classtableClassCardTitle => 'Schedule Information';

  @override
  String get classtableClassCardUnknownClassroom => 'Unknown classroom';

  @override
  String classtableClassCardRemainsHint(String remain_count) {
    return 'There is/are $remain_count schedule(s) remaining';
  }

  @override
  String get classtableClassAddAddClassTitle => 'Add class information';

  @override
  String get classtableClassAddChangeClassTitle => 'Modify class info';

  @override
  String get classtableClassAddClassNameEmptyMessage =>
      'Class name cannot be empty';

  @override
  String get classtableClassAddWrongTimeMessage => 'Incorrect time input';

  @override
  String get classtableClassAddSaveButton => 'Save';

  @override
  String get classtableClassAddInputClassnameHint => 'Class name (required)';

  @override
  String get classtableClassAddInputTeacherHint => 'Teacher\'s name (optional)';

  @override
  String get classtableClassAddInputClassroomHint =>
      'Classroom location (optional)';

  @override
  String get classtableClassAddInputWeekHint => 'Select weeks';

  @override
  String get classtableClassAddInputTimeHint => 'Select time';

  @override
  String get classtableClassAddInputTimeWeekdayHint => 'Weekday';

  @override
  String get classtableClassAddInputStartTimeHint => 'Time start';

  @override
  String get classtableClassAddInputEndTimeHint => 'Time end';

  @override
  String classtableClassAddWheelChooseHint(String index) {
    return 'Period $index';
  }

  @override
  String get classtableClassAddChooseAtLeastOne =>
      'Please choose at least one time for class';

  @override
  String get classtableClassAddRepeatWeekly => 'Repeat Weekly';

  @override
  String get classtableClassAddFreeTime => 'Free Time';

  @override
  String get classtableClassAddDateSelectorFreeRule =>
      'Time must be between 8:30 and 21:25.';

  @override
  String get classtableClassAddDateSelectorFreeRule2 =>
      'The end time must be later than the start time.';

  @override
  String get classtableClassAddDateSelectorFreeClassStartTime => 'Start time';

  @override
  String get classtableClassAddDateSelectorFreeClassEndTime => 'End time';

  @override
  String get classtableClassAddDateSelectorFreeEditClassTime =>
      'Edit the class time';

  @override
  String get classtableClassAddDateSelectorFreeChooseClassTime =>
      'Choose a class time';

  @override
  String classtableCourseDetailCardClassNumberString(String number) {
    return 'Class $number';
  }

  @override
  String get classtableCourseDetailCardUnknownTeacher => 'Unknown teacher';

  @override
  String get classtableCourseDetailCardUnknownPlace => 'Unknown classroom';

  @override
  String classtableCourseDetailCardClassPeriod(String start, String stop) {
    return 'period $start to $stop';
  }

  @override
  String get classtableCourseDetailCardEdit => 'Edit';

  @override
  String get classtableCourseDetailCardDelete => 'Delete';

  @override
  String get classtableCourseDetailCardDeleteSingle => 'Delete this one';

  @override
  String get classtableCourseDetailCardDeleteAll => 'Delete all';

  @override
  String get classtableCourseDetailCardDeleteContent =>
      'Everything will be excuted.';

  @override
  String get classtableCourseDetailCardDeleteContentSingle =>
      'Only the information within this time range of the class will be removed.';

  @override
  String get classtableCourseDetailCardDeleteTitle =>
      'Are you sure to delete this class information?';

  @override
  String get classtableOutputToSystemSuccess =>
      'Successfully output to the system calendar.';

  @override
  String get classtableOutputToSystemFailure =>
      'Problem occurred while outputing to the system calendar.';

  @override
  String get classtableOutputToSystemRequestAllTitle =>
      'Information on requesting permission';

  @override
  String get classtableOutputToSystemRequestAll =>
      'Due to technical difficulties, users must grant both read calendar and write calendar permissions to this software in order to export schedules properly. However, this software will not read the calendar.';

  @override
  String get classtableRefreshClasstableReady =>
      'Ready to refresh the schedule';

  @override
  String get classtableRefreshClasstableSuccess =>
      'Successfully refresh the schedule';

  @override
  String get classtableCacheHintPasswordWrong =>
      'IDS password is incorrect or expired.';

  @override
  String get classtableCacheHintLoginFailed =>
      'Failed to log in to the classtable service.';

  @override
  String get classtableCacheHintNetworkFailed =>
      'Classtable network request failed.';

  @override
  String get classtableCacheHintUnknownError =>
      'Failed to fetch the latest classtable online. Check logs for details.';

  @override
  String get classtableSemesterSwitcherChooseSemester => 'Choose a Semester';

  @override
  String get classtableSemesterSwitcherFirstAcademicYear => 'Academic year 1';

  @override
  String get classtableSemesterSwitcherSecondAcademicYear => 'Academic year 2';

  @override
  String get classtableSemesterSwitcherFetchRemoteSemester =>
      'Fetch Current Semester';

  @override
  String get classtableSemesterSwitcherFetchingRemoteSemester => 'Fetching...';

  @override
  String classtableSemesterSwitcherYear(String year) {
    return '$year';
  }

  @override
  String get classtableSemesterSwitcherOnlyFutureHint =>
      'This app only allows viewing course schedules for future semesters.';

  @override
  String get clubPromotionTypeTech => 'Tech';

  @override
  String get clubPromotionTypeAcg => 'ACG';

  @override
  String get clubPromotionTypeUnion => 'Official';

  @override
  String get clubPromotionTypeProfit => 'Commercial';

  @override
  String get clubPromotionTypeSport => 'Sport';

  @override
  String get clubPromotionTypeArt => 'Culture';

  @override
  String get clubPromotionTypeUnknown => 'Unknown';

  @override
  String get clubPromotionTypeGame => 'Game';

  @override
  String get clubPromotionTypeAll => 'All';

  @override
  String get clubPromotionWrongParam => 'Wrong Parameter';

  @override
  String get clubPromotionNoGroupInfo => 'No Club info';

  @override
  String get clubPromotionLoading => 'Loading';

  @override
  String get clubPromotionErrorOutside => 'Error detected at the outside';

  @override
  String get clubPromotionError => 'Error detected';

  @override
  String get clubPromotionQqCopied =>
      'QQ Group Number have been copied to the clipboard';

  @override
  String get clubPromotionNoLink => 'No group invite link provided';

  @override
  String get clubPromotionLoadingProblem => 'Error on loading page';

  @override
  String get clubPromotionPicturePreview => 'Picture';

  @override
  String get electricityTitle => 'Power Info';

  @override
  String get electricityPowerTitle => 'Infomation';

  @override
  String get electricityCacheHintLoginFailed =>
      'Failed to log in to the electricity service, showing cached data.';

  @override
  String get electricityCacheHintNetworkFailed =>
      'Electricity service network request failed, showing cached data.';

  @override
  String get electricityCacheHintUnknownError =>
      'Failed to fetch the latest electricity data online, showing cached data. Check logs for details.';

  @override
  String get electricityCacheNotice => 'Last fetched';

  @override
  String get electricityAccount => 'Account';

  @override
  String get electricityRemainPower => 'Remain power';

  @override
  String get electricityOweInfo => 'Arrears';

  @override
  String get electricityHistory => 'Billing History';

  @override
  String get electricityDailyUsage => 'Average usage per day';

  @override
  String get electricityNotEnoughData => 'Not enough data for rendering graph';

  @override
  String get electricityInfo =>
      'Energy system can be only be accessed at schoolnet, do contact developers if have issue.\nHistory will be recorded locally while average usage is based on the electric meter\'s record.';

  @override
  String get electricityFetchingHint => 'Fetching the latest electricity info.';

  @override
  String get electricityFetchError =>
      'Failed to fetch electricity information. Please retry.';

  @override
  String get electricityDate => 'Date';

  @override
  String get electricityPower => 'Remaining';

  @override
  String get electricityUpdate => 'Refresh';

  @override
  String get electricityWaterUsageFetchDate => 'Fetch time';

  @override
  String get electricityWaterUsageReadBefore => 'Last time';

  @override
  String get electricityWaterUsageReadNow => 'This time';

  @override
  String get electricityWaterUsage => 'Bath water usage';

  @override
  String get electricityWaterTitle => 'Water usage';

  @override
  String get electricityWaterLoading => 'Loading water usage information';

  @override
  String get electricityWaterUnavailable =>
      'Water usage is unavailable. Retry from the electricity card.';

  @override
  String get electricityWaterEmpty => 'No water usage information';

  @override
  String get electricityNotSchoolNetwork => 'Not school network';

  @override
  String get electricityAirconTitle => 'Aircon Electricity';

  @override
  String get electricityAirconImei => 'Aircon IMEI';

  @override
  String get electricityAirconAmount => 'Platform usage';

  @override
  String get electricityAirconUpdateTime => 'Updated at';

  @override
  String get electricityAirconWaiting =>
      'Waiting to fetch aircon electricity data';

  @override
  String get electricityAirconError =>
      'Failed to fetch aircon electricity data';

  @override
  String get electricityAirconRetry => 'Retry';

  @override
  String get electricityAirconImeiMissing =>
      'Add the aircon IMEI to view its electricity usage.';

  @override
  String get electricityAirconAddImei => 'Add aircon IMEI';

  @override
  String electricityAirconCacheNotice(String time) {
    return 'Showing cached aircon data from $time';
  }

  @override
  String get emptyClassroomTitle => 'Empty Classrooms';

  @override
  String emptyClassroomDate(String date) {
    return 'Date $date';
  }

  @override
  String emptyClassroomBuilding(String building) {
    return 'Building $building';
  }

  @override
  String get emptyClassroomSearchHint => 'Classroom name or code';

  @override
  String get emptyClassroomClassroom => 'Classroom';

  @override
  String get emptyClassroomEmpty => 'Available';

  @override
  String get emptyClassroomOccupied => 'Occupied';

  @override
  String get examTitle => 'Exam Schedule';

  @override
  String get examCacheHint => 'Displaying cached exam schedule info';

  @override
  String get examCacheHintPasswordWrong =>
      'IDS password is incorrect or expired.';

  @override
  String get examCacheHintLoginFailed =>
      'Failed to log in to the exam service.';

  @override
  String get examCacheHintNetworkFailed => 'Network request failed.';

  @override
  String get examCacheHintUnknownError =>
      'Failed to fetch the latest exam schedule. Check logs for details.';

  @override
  String get examFetchingHint => 'Fetching the latest exam schedule.';

  @override
  String get examNotFinished => 'Still there are some bad guys here.';

  @override
  String get examAllFinished => 'Say goodbye to all the exams.';

  @override
  String get examUnableToExam => 'Unable to exam';

  @override
  String get examFinished => 'All exams ';

  @override
  String get examNoneFinished => 'No exams have been completed';

  @override
  String get examNoExamArrangement => 'No exam has been arranged currently';

  @override
  String get examNoArrangementTitle => 'Not arranged exams';

  @override
  String get examNoArrangementAllArranged =>
      'Exams have been scheduled for all subjects';

  @override
  String examNoArrangementSubtitle(String id) {
    return 'Code: $id';
  }

  @override
  String get experimentTitle => 'Experiment Info';

  @override
  String get experimentOngoing => 'Ongoing experiment';

  @override
  String get experimentNotFinished => 'Experiments to be done';

  @override
  String get experimentAllFinished => 'All experiments have been completed';

  @override
  String get experimentFinished => 'Completed experiments';

  @override
  String experimentScoreInfo(String score) {
    return '$score (predicted)';
  }

  @override
  String experimentScoreSum(String sum) {
    return 'Total score: $sum';
  }

  @override
  String get experimentNoneFinished =>
      'None of the experiments have been completed';

  @override
  String get experimentNotProvided => 'Not provided';

  @override
  String experimentErrorPhysics(String info) {
    return 'Error on fetching physics experiments: $info';
  }

  @override
  String experimentErrorOther(String info) {
    return 'Error on fetching other experiments: $info';
  }

  @override
  String experimentCacheHint(String info) {
    return 'Loaded cache: $info';
  }

  @override
  String get experimentPhysicsCacheHintMissingPassword =>
      'Physics experiment password is not set.';

  @override
  String get experimentPhysicsCacheHintLoginFailed =>
      'Physics experiment login failed.';

  @override
  String get experimentPhysicsCacheHintNotSchoolNetwork =>
      'Not on the campus network.';

  @override
  String get experimentPhysicsCacheHintNetworkFailed =>
      'Physics experiment network request failed.';

  @override
  String get experimentPhysicsCacheHintUnknownError =>
      'Failed to fetch physics experiments online. Check logs for details.';

  @override
  String get experimentOtherCacheHintLoginFailed =>
      'Other experiment login failed.';

  @override
  String get experimentOtherCacheHintNotSchoolNetwork =>
      'Not on the campus network.';

  @override
  String get experimentOtherCacheHintNetworkFailed =>
      'Other experiment network request failed.';

  @override
  String get experimentOtherCacheHintUnknownError =>
      'Failed to fetch other experiments online. Check logs for details.';

  @override
  String get experimentPhysicsExperiment => 'physics experiments';

  @override
  String get experimentOtherExperiment => 'other experiments';

  @override
  String get experimentTapForScore => 'Failed to detect the score';

  @override
  String get experimentYourScore => 'Your Score: ';

  @override
  String experimentPredictScore(String score) {
    return 'Predict score: $score';
  }

  @override
  String get experimentSendMail => 'Send';

  @override
  String get experimentFetchingHint =>
      'The data you see is from cache. Updating is running in the background...';

  @override
  String get experimentFetchingHintBoth =>
      'Physics experiments and other experiments are loading';

  @override
  String get experimentFetchingHintPhysics => 'Physics experiments are loading';

  @override
  String get experimentFetchingHintOther => 'Other experiments are loading';

  @override
  String get experimentFetchingHintPhysicsWithOtherFailed =>
      'Physics experiments are loading, while other experiments failed to load';

  @override
  String get experimentFetchingHintOtherWithPhysicsFailed =>
      'Other experiments are loading, while physics experiments failed to load';

  @override
  String get experimentScoreHint0 =>
      'You can tap on the score info on the score card to check out the original score data';

  @override
  String get experimentScoreHint1 =>
      'Your score is not in the XDYou score recognition database, so it was not recognized properly.';

  @override
  String get experimentScoreHint2 =>
      'If you wish to contribute to the development of XDYou, you can click the send email button, and we will add your score to the recognition database!';

  @override
  String get experimentScoreHint3 =>
      'Due to the lack of data for recognization, it is necessary to check twice.';

  @override
  String get homepageTitle => 'School Info Center';

  @override
  String get homepageLoading => 'Loading';

  @override
  String get homepageLoaded => 'Message updated';

  @override
  String get homepageLoadError => 'Something wrong';

  @override
  String get homepageOnHoliday => 'Currently on holiday';

  @override
  String homepageOnWeekday(String current) {
    return 'Currently week $current';
  }

  @override
  String get homepageLoadingMessage => 'Refreshing information...';

  @override
  String get homepagePostgraduateNotice => 'Postgraduate features activated!';

  @override
  String get homepageLinuxNotice =>
      'Linux version is under testing, feel free to feedback!';

  @override
  String get homepageEditMode => 'Edit Layout';

  @override
  String get homepageEditDone => 'Done';

  @override
  String get homepageEditReset => 'Reset Layout';

  @override
  String get homepageEditHint => 'Schedule and update cards cannot be edited';

  @override
  String get homepageManageHidden => 'Manage hidden cards';

  @override
  String get homepageHiddenTitle => 'Hidden cards';

  @override
  String get homepageHiddenLabel => 'Hidden';

  @override
  String get homepageHideEmpty => 'No hidden cards';

  @override
  String get homepageHomepage => 'Info';

  @override
  String get homepageRuisi => 'Forum';

  @override
  String get homepageClub => 'Club';

  @override
  String get homepagePlanet => 'Blog';

  @override
  String get homepageDashboard => 'Pighub';

  @override
  String get homepageSetting => 'Settings';

  @override
  String get homepageInputPartnerDataRouteNotExist =>
      'Import path does not exist:P';

  @override
  String get homepageInputPartnerDataFailedGetFile => 'Failed to import file';

  @override
  String get homepageInputPartnerDataFailedImport =>
      'Maybe there is a problem with the import file:P';

  @override
  String get homepageInputPartnerDataSuccessMessage =>
      'Import successful, if the class schedule page is open, please reopen it';

  @override
  String get homepageInputPartnerDataNotLoaded =>
      'Class schedule has not been loaded yet, please try again later...';

  @override
  String get homepageInputPartnerDataConfirmContent =>
      'There is currently partner class schedule data, do you want to overwrite?';

  @override
  String get homepageLoginMessage =>
      'Logging in, currently displaying cached data';

  @override
  String get homepageSuccessfulLoginMessage => 'Login successful';

  @override
  String get homepagePasswordWrongTitle => 'Wrong username or password';

  @override
  String get homepagePasswordWrongContent =>
      'Restart the app and log in manually?';

  @override
  String get homepagePasswordWrongDenial => 'No, enter offline mode';

  @override
  String get homepageOfflineModeTitle =>
      'Uniform Authentication Service offline mode activated';

  @override
  String get homepageOfflineModeContent =>
      '\"Unable to connect to the Unified Authentication Service server, all related services are temporarily unavailable.\nScore inquiry, exam information inquiry, overdue fee inquiry, campus card inquiry are closed. The schedule displays cached data. Other functions are temporarily not affected.\nWe apologize for any inconvenience caused.\"\n';

  @override
  String get homepageOfflineMode =>
      'In offline mode, all one-stop related functions are disabled';

  @override
  String get homepageNoticeCardEmptyNotice =>
      'No application announcements retrieved, please refresh';

  @override
  String get homepageNoticeCardNoNoticeAvaliable =>
      'Failed to fetch the application announcements';

  @override
  String get homepageNoticeCardNoticeListTitle => 'Notifications';

  @override
  String get homepageNoticeCardOpenUrl => 'Open link';

  @override
  String get homepageNoticeCardNoticePageTitle => 'Notification List';

  @override
  String get homepageClassTableCardTitle => 'Timetable';

  @override
  String homepageClassTableCardToday(String remain) {
    return '$remain arrangment(s) today';
  }

  @override
  String get homepageClassTableCardTodayFinished =>
      'Arrangements all done today';

  @override
  String homepageClassTableCardTomorrow(String remain) {
    return '$remain arrangment(s) tomorrow';
  }

  @override
  String get homepageClassTableCardTomorrowNone => 'No arrangement tomorrow';

  @override
  String homepageClassTableCardWeekInfo(String weekinfo) {
    return 'Week $weekinfo';
  }

  @override
  String get homepageClassTableCardOnHoliday => 'On vacation';

  @override
  String homepageClassTableCardErrorMessage(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get homepageClassTableCardFetchingMessage => 'Fetching class schedule';

  @override
  String get homepageClassTableCardErrorInfotext => 'An error occurred';

  @override
  String get homepageClassTableCardFetchingInfotext => 'Loading';

  @override
  String get homepageClassTableCardNoArrangementInfotext =>
      'No schedule at the moment';

  @override
  String get homepageClassTableCardScheduleFetchingMessage =>
      'Schedule is loading, please check again soon';

  @override
  String get homepageClassTableCardScheduleErrorMessage =>
      'Failed to load schedule, please try again later';

  @override
  String get homepageClassTableCardScheduleFetchingInfotext =>
      'Loading schedule';

  @override
  String get homepageClassTableCardScheduleErrorInfotext =>
      'Failed to load schedule';

  @override
  String get homepageClassTableCardScheduleNoneInfotext =>
      'No schedule available';

  @override
  String get homepageClassTableCardUpdatingInfotext => 'Updating';

  @override
  String get homepageClassTableCardAllLoadingInfotext => 'All sources loading';

  @override
  String get homepageClassTableCardPartialLoadingInfotext =>
      'Partially loading';

  @override
  String get homepageClassTableCardPartialErrorInfotext =>
      'Some data failed to load';

  @override
  String homepageClassTableCardFailedChip(String source) {
    return '$source failed';
  }

  @override
  String get homepageClassTableCardFailedSourceClassInfo => 'Class info';

  @override
  String get homepageClassTableCardFailedSourceExamInfo => 'Exam info';

  @override
  String get homepageClassTableCardFailedSourcePhysicsExperiment =>
      'Physics experiment';

  @override
  String get homepageClassTableCardFailedSourceOtherExperiment =>
      'Other experiment';

  @override
  String get homepageClassTableCardUnknownPlace => 'Unknown place';

  @override
  String homepageClassTableCardSeat(String seatnum) {
    return 'Seat $seatnum';
  }

  @override
  String get homepageElectricityCardTitle =>
      'Electricity and Hydroenergy Information';

  @override
  String homepageElectricityCardCurrentElectricity(String amount) {
    return '$amount kWh remains';
  }

  @override
  String homepageElectricityCardCacheNotice(String date) {
    return 'Last fetch date: $date';
  }

  @override
  String get homepageLibraryCardTitle => 'Library Info';

  @override
  String homepageLibraryCardCurrentBorrow(String count) {
    return 'Borrowing $count book(s)';
  }

  @override
  String get homepageLibraryCardErrorOccured =>
      'Error occurred while retrieving borrowing information';

  @override
  String get homepageLibraryCardFetching => 'Fetching borrowing information';

  @override
  String get homepageLibraryCardNoReturn =>
      'Currently there\'s no book to be returned';

  @override
  String homepageLibraryCardNeedReturn(String dued) {
    return 'Need to return $dued books';
  }

  @override
  String get homepageLibraryCardNoInfo =>
      'Cannot retrieve information at the moment';

  @override
  String get homepageLibraryCardFetchingInfo => 'Fetching information...';

  @override
  String get homepageSchoolCardInfoCardErrorToast =>
      'An error occurred, please contact the developer';

  @override
  String get homepageSchoolCardInfoCardFetchingToast =>
      'Fetching information, please check later';

  @override
  String get homepageSchoolCardInfoCardBill => 'Bill';

  @override
  String homepageSchoolCardInfoCardBalance(String amount) {
    return 'Remain $amount RMB';
  }

  @override
  String get homepageSchoolCardInfoCardErrorOccured =>
      'Error occurred while retrieving campus card information';

  @override
  String get homepageSchoolCardInfoCardFetching =>
      'Fetching campus card information';

  @override
  String get homepageSchoolCardInfoCardBottomTextSuccess =>
      'Query campus card bill';

  @override
  String get homepageSchoolCardInfoCardNoInfo =>
      'Cannot retrieve information currently';

  @override
  String get homepageSchoolCardInfoCardFetchingInfo =>
      'Fetching information...';

  @override
  String get homepageToolboxClassAttendance => 'Attendances';

  @override
  String get homepageToolboxCreative =>
      'Innovation and Entrepreneurship Competition';

  @override
  String get homepageToolboxEmptyClassroom => 'Classrooms';

  @override
  String get homepageToolboxExam => 'Exams';

  @override
  String get homepageToolboxExperiment => 'Experiments';

  @override
  String get homepageToolboxScore => 'Grades';

  @override
  String get homepageToolboxSport => 'PE Info';

  @override
  String get homepageToolboxDormWater => 'Dorm Water';

  @override
  String get homepageToolboxSchoolnet => 'Schoolnet Usage';

  @override
  String get homepageToolboxToolbox => 'Others';

  @override
  String get homepageToolboxScoreCannotReach =>
      'Offline mode with no cached score data, unable to access';

  @override
  String get homepageToolboxExamFetching =>
      'Fetching exam information, please wait';

  @override
  String get homepageToolboxExamError =>
      'An error occurred, please contact the developer';

  @override
  String homepageSchoolNetTitle(String usage) {
    return 'Used $usage';
  }

  @override
  String get homepageSchoolNetNoPassword =>
      'The query password is not set, click to set up';

  @override
  String get homepageSchoolNetFailed =>
      'Failed to get the school net usage info';

  @override
  String get homepageSchoolNetFetching => 'Fetching the school net usage info';

  @override
  String homepageSchoolNetRemaining(String remaining) {
    return 'Clearing at $remaining';
  }

  @override
  String get homepageClubPromotionFailed => 'Failed to fetch club info';

  @override
  String get homepageClubPromotionFetching => 'Fetching club info';

  @override
  String get dormWaterTitle => 'Dorm Water';

  @override
  String get dormWaterPhone => 'Phone';

  @override
  String get dormWaterImageCode => 'Image code';

  @override
  String get dormWaterSmsCode => 'SMS code';

  @override
  String get dormWaterSendSms => 'Send SMS';

  @override
  String get dormWaterLogin => 'Login';

  @override
  String get dormWaterLogout => 'Logout';

  @override
  String get dormWaterRefreshCaptcha => 'Refresh Captcha';

  @override
  String get dormWaterLoadingCaptcha => 'Loading...';

  @override
  String get dormWaterCaptchaError => 'Failed to load captcha';

  @override
  String get dormWaterPhoneRequired => 'Please enter phone number';

  @override
  String get dormWaterImageCodeRequired => 'Please enter image code';

  @override
  String get dormWaterSmsSent => 'SMS sent successfully';

  @override
  String get dormWaterSmsFailed => 'Failed to send SMS';

  @override
  String get dormWaterSmsCodeRequired => 'Please enter SMS code';

  @override
  String get dormWaterLoginSuccess => 'Login successful';

  @override
  String get dormWaterLoginFailed => 'Login failed';

  @override
  String get dormWaterLogoutSuccess => 'Logged out successfully';

  @override
  String get dormWaterDevices => 'Device List';

  @override
  String get dormWaterLoadingDevices => 'Loading devices...';

  @override
  String get dormWaterNoDevices => 'No devices';

  @override
  String get dormWaterSelectDevice => 'Select Device';

  @override
  String get dormWaterFetchDevicesFailed => 'Failed to fetch device list';

  @override
  String get dormWaterRetryLoadDevices => 'Retry Loading';

  @override
  String get dormWaterStartWater => 'Start Water';

  @override
  String get dormWaterEndWater => 'End Water';

  @override
  String get dormWaterWaterDispensing => 'Water Dispensing';

  @override
  String get dormWaterWaterStatus => 'Water Status';

  @override
  String get dormWaterStartWaterSuccess => 'Water dispensing started';

  @override
  String get dormWaterEndWaterSuccess => 'Water dispensing ended';

  @override
  String get dormWaterStartWaterFailed => 'Failed to start water';

  @override
  String get dormWaterEndWaterFailed => 'Failed to end water';

  @override
  String get dormWaterDeviceStatusChecking => 'Checking device status...';

  @override
  String get dormWaterDeviceStatusReady => 'Device ready';

  @override
  String get dormWaterScanQrCode => 'Scan QR Code';

  @override
  String get dormWaterDeviceId => 'Device ID';

  @override
  String get dormWaterAddDeviceFailed => 'Failed to add device';

  @override
  String get dormWaterDeviceRemovedFromFavorites =>
      'Device removed from favorites';

  @override
  String get dormWaterRemoveFromFavoritesFailed =>
      'Failed to remove from favorites';

  @override
  String get libraryTitle => 'Library Information';

  @override
  String get libraryBorrowStateTitle => 'Borrowing Status';

  @override
  String get librarySearchBookTitle => 'Search Books';

  @override
  String get librarySearchFieldTitle => 'Search Field';

  @override
  String get librarySearchFieldKeywordOption => 'Any';

  @override
  String get librarySearchFieldTitleOption => 'Title';

  @override
  String get librarySearchFieldAuthorOption => 'Author';

  @override
  String get librarySearchFieldIsbnOption => 'ISBN';

  @override
  String get librarySearchFieldBarcodeOption => 'Bar Code';

  @override
  String get librarySearchFieldCallnoOption => 'Call No';

  @override
  String get libraryNotProvided => 'No information provided';

  @override
  String get libraryAuthor => 'Author ';

  @override
  String get libraryPublishHouse => 'Publisher ';

  @override
  String get libraryCallNumber => 'Call Number ';

  @override
  String get libraryPublishDate => 'Publication Date';

  @override
  String get libraryIsbn => 'ISBN';

  @override
  String get libraryArrangementCode => 'Arrangement Code ';

  @override
  String get libraryAvaliableBorrow => 'Available to borrow';

  @override
  String get libraryStorage => 'Storage';

  @override
  String get libraryOnShelve => 'On shelf';

  @override
  String libraryBookCode(String barCode) {
    return 'Book code: $barCode';
  }

  @override
  String get libraryDueDate => ' Due date';

  @override
  String get libraryBorrowStr => ' Borrow';

  @override
  String get libraryAfterDueDate => ' day(s) overdue';

  @override
  String get libraryBeforeDueDate => ' day(s) left';

  @override
  String get libraryCanBeRenewable => 'Renewable';

  @override
  String get libraryCannotBeRenewable => 'Not renewable';

  @override
  String get libraryRenewing => 'Renewing';

  @override
  String get libraryEmptyBorrowList => 'No borrowed books found';

  @override
  String libraryBorrowListInfo(String borrow, String dued) {
    return 'Borrowing $borrow book(s), among which $dued book(s) have expired';
  }

  @override
  String get librarySearchHere => 'Search here';

  @override
  String get libraryNormalSearch => 'Normal Search';

  @override
  String get libraryAdvancedSearch => 'Advanced Search';

  @override
  String get librarySearch => 'Search';

  @override
  String get libraryMatchMode => 'Match Mode';

  @override
  String get libraryMatchExact => 'Exact';

  @override
  String get libraryMatchFuzzy => 'Fuzzy';

  @override
  String get libraryMatchPrefix => 'Prefix';

  @override
  String get libraryDocumentType => 'Document Type';

  @override
  String get libraryDocumentTypeAll => 'All';

  @override
  String get libraryDocumentTypeBook => 'Book';

  @override
  String get libraryOnlyOnShelf => 'Only on shelf';

  @override
  String get libraryPublishYearBegin => 'Publish year from';

  @override
  String get libraryPublishYearEnd => 'Publish year to';

  @override
  String get libraryBookDetail => 'Book details';

  @override
  String get libraryNoResult =>
      'No result, change parameter or start your search';

  @override
  String get libraryCardTitle => 'Library status';

  @override
  String get libraryCardFetching => 'Fetching';

  @override
  String get libraryCardNorthernLibrary => 'Northern Library';

  @override
  String get libraryCardSouthernLibrary => 'Southern Library';

  @override
  String libraryCardPeople(String people) {
    return 'People: $people';
  }

  @override
  String libraryCardSeat(String seat) {
    return 'Seats: $seat';
  }

  @override
  String get loginIdentityNumber => 'Student ID';

  @override
  String get loginPassword => 'IDS Login password';

  @override
  String get loginLogin => 'Login';

  @override
  String get loginIncorrectPasswordPattern =>
      'Username or password does not meet requirements, student ID must be 11 digits and password cannot be empty';

  @override
  String get loginOnLoginProgress => 'Logging in...';

  @override
  String get loginCompleteLogin => 'Login successful';

  @override
  String get loginFailedLoginCannotConnectToServer =>
      'Cannot connect to server';

  @override
  String loginFailedLoginWithCode(String code) {
    return 'Request failed, response status code: $code';
  }

  @override
  String loginFailedLoginWithMessage(String message) {
    return 'Request failed, error message: $message';
  }

  @override
  String get loginFailedLoginOther =>
      'Unknown error, please contact the developer';

  @override
  String get loginClearCache => 'Clear cache';

  @override
  String get loginCompleteClearCache => 'Cache cleared successfully';

  @override
  String get loginSeeInspector => 'View network interaction';

  @override
  String get loginCaptchaWindowTitle => 'Please enter captcha';

  @override
  String get loginCaptchaWindowHint => 'Input captcha';

  @override
  String get loginCaptchaWindowMessageOnEmpty => 'Please enter captcha';

  @override
  String loginCaptchaWindowRefreshFailed(String error) {
    return 'Failed to refresh captcha: $error';
  }

  @override
  String get loginSliderTitle => 'Server authentication service';

  @override
  String get schoolNetTitle => 'School Net Usage Query';

  @override
  String get schoolNetIdsAccountNetTitle => 'Current user';

  @override
  String get schoolNetIdsAccountNetNotice =>
      'This is the current PDA user\'s information.\nNotice that network traffic is charged in GB (1GB = 1000MB).\nIf you cannot see any info, go to zfw.xidian.edu.cn for password reset';

  @override
  String get schoolNetIdsAccountNetOverview => 'Overview';

  @override
  String get schoolNetIdsAccountNetAccount => 'Account';

  @override
  String get schoolNetIdsAccountNetUsed => 'Data usage';

  @override
  String get schoolNetIdsAccountNetRemain => 'Balance';

  @override
  String schoolNetIdsAccountNetCurrentOnline(String length) {
    return 'Online devices (currently $length)';
  }

  @override
  String get schoolNetIdsAccountNetNoDeviceOnline =>
      'No device is online at the moment';

  @override
  String get schoolNetCurrentLoginNetTitle => 'Current using';

  @override
  String get schoolNetCurrentLoginNetNotice =>
      'This is the information of the current using account.\nIt may be different from the current user\'s, and DON\'T BE EVIL!\nNotice that network traffic is charged in GB (1GB=1000MB).';

  @override
  String get schoolNetCurrentLoginNetOverview => 'Overview of the account';

  @override
  String get schoolNetCurrentLoginNetAccount => 'Account';

  @override
  String get schoolNetCurrentLoginNetPlanType => 'Type of the plan';

  @override
  String get schoolNetCurrentLoginNetRemain => 'Balance';

  @override
  String get schoolNetCurrentLoginNetUsageSituation => 'Traffic usage info';

  @override
  String schoolNetCurrentLoginNetUsedPercent(String percent) {
    return 'Used $percent%';
  }

  @override
  String get schoolNetCurrentLoginNetUsed => 'Data usage';

  @override
  String get schoolNetCurrentLoginNetRemainCount => 'Data remaining';

  @override
  String get schoolNetCurrentLoginNetTotal => 'Total data';

  @override
  String get schoolNetCurrentLoginNetNonSchoolnet =>
      'Not in school net environment';

  @override
  String get schoolNetDeviceListIp => 'Device IP';

  @override
  String get schoolNetDeviceListTime => 'Online time';

  @override
  String get schoolNetDeviceListRemain => 'Traffic used';

  @override
  String get schoolNetFetching => 'Fetching schoolnet usage data';

  @override
  String get schoolNetEmptyPassword =>
      'You may forgot to enter the schoolnet password';

  @override
  String get schoolNetNotInitalized =>
      'It seems the backend is not open for query:P';

  @override
  String get schoolNetCaptchaFailed => 'Failed to idenify captcha';

  @override
  String get schoolNetCaptchaEmpty => 'Captcha is empty';

  @override
  String get schoolNetCacheHintCaptchaFailed =>
      'Captcha recognition failed. Please try again.';

  @override
  String get schoolNetCacheHintRequestFailed =>
      'The schoolnet request failed. Please try again later.';

  @override
  String get schoolNetWrongPassword => 'Wrong schoolnet password';

  @override
  String schoolNetErrorFetch(String msg) {
    return 'Failed to fetch：$msg';
  }

  @override
  String schoolNetErrorOther(String msg) {
    return 'Other error：$msg';
  }

  @override
  String get schoolNetRefresh => 'Refresh';

  @override
  String get schoolCardWindowTitle => 'Campus Card Transaction History';

  @override
  String schoolCardWindowIncome(String income) {
    return 'Income ￥$income';
  }

  @override
  String schoolCardWindowExpense(String expense) {
    return 'Expense ￥$expense';
  }

  @override
  String schoolCardWindowSelectRange(String startDay, String endDay) {
    return 'Select date: from $startDay to $endDay';
  }

  @override
  String get schoolCardWindowStoreName => 'Expense place';

  @override
  String get schoolCardWindowBalance => 'Amount';

  @override
  String schoolCardWindowTimeWithSum(String sum) {
    return 'Time ($sum)';
  }

  @override
  String get schoolCardWindowNoRecord =>
      'No records found, please try again with different dates';

  @override
  String get schoolCardWindowQrCode => 'Payment Code';

  @override
  String schoolCardWindowQrCodeError(String info) {
    return 'Get QR Code failed: $info';
  }

  @override
  String get schoolCardWindowReload => 'Reload';

  @override
  String get scoreCacheMessage => 'Cached score information is displayed';

  @override
  String scoreSummary(String chosen, String credit, String avg, String gpa) {
    return 'Selected subjects $chosen  Total credits $credit\nAverage $avg GPA $gpa';
  }

  @override
  String get scoreAllPassed => 'All subjects have passed';

  @override
  String get scoreCacheHintPasswordWrong =>
      'IDS password is incorrect or expired.';

  @override
  String get scoreCacheHintLoginFailed =>
      'Failed to log in to the score service.';

  @override
  String get scoreCacheHintNetworkFailed => 'Network request failed.';

  @override
  String get scoreCacheHintUnknownError =>
      'Failed to fetch the latest score info. Check logs for details.';

  @override
  String get scoreFetchingHint => 'Fetching the latest score info.';

  @override
  String get scoreAllSemester => 'All semesters';

  @override
  String scoreChosenSemester(String chosen) {
    return '$chosen';
  }

  @override
  String get scoreAllType => 'All types';

  @override
  String scoreChosenType(String type) {
    return '$type';
  }

  @override
  String get scoreNone => 'None';

  @override
  String get scoreScoreChoiceTitle => 'Transcript';

  @override
  String get scoreScoreChoiceSearchHint => 'Search for score records';

  @override
  String get scoreScoreChoiceEmptyList =>
      'No courses from this semester is selected to be calculated';

  @override
  String get scoreScoreChoiceSumDialogTitle => 'Summary';

  @override
  String scoreScoreChoiceSumDialogContent(
    String gpa_all,
    String avg_all,
    String credit_all,
    String unpassed,
    String not_core_type,
  ) {
    return 'Overall GPA of all subjects：$gpa_all\nOverall average：$avg_all\nTotal credits：$credit_all\nUnpassed subjects：$unpassed\nPublic selective：$not_core_type\nThe data provided by this program is for reference only, and the developer is not responsible for its accuracy';
  }

  @override
  String get scoreScoreComposeCardNoDetail =>
      'No detailed information provided';

  @override
  String get scoreScoreComposeCardFetching => 'Fetching...';

  @override
  String get scoreScoreComposeCardCredit => 'Credits';

  @override
  String get scoreScoreComposeCardGpa => 'GPA';

  @override
  String get scoreScoreComposeCardScore => 'Score';

  @override
  String get scoreScoreInfoCardTitle => 'Score Details';

  @override
  String get scoreScoreInfoCardOriginalCourse => 'Initial course';

  @override
  String get scoreScoreInfoCardFailed => '[Failed]';

  @override
  String scoreScoreInfoCardCredit(String credit) {
    return 'Credits $credit';
  }

  @override
  String scoreScoreInfoCardGpa(String gpa) {
    return 'GPA $gpa';
  }

  @override
  String scoreScoreInfoCardScore(String score) {
    return 'Score $score';
  }

  @override
  String get scoreScorePageTitle => 'Score Query';

  @override
  String get scoreScorePageSearchHint => 'Search for score records';

  @override
  String get scoreScorePageNoRecord => 'No relevant information found';

  @override
  String get scoreScorePageSelectAll => 'Select all';

  @override
  String get scoreScorePageSelectNothing => 'Clear';

  @override
  String get scoreScorePageResetSelect => 'Reset';

  @override
  String get scoreScorePageSummary => 'Summary';

  @override
  String get scoreScorePageCet4 => 'College English Test Band 4';

  @override
  String get scoreScorePageCet6 => 'College English Test Band 6';

  @override
  String settingAcknowledgement(String developers) {
    return 'Made With Love From $developers People';
  }

  @override
  String get settingAbout => 'About';

  @override
  String get settingAboutThisProgram => 'About this APP';

  @override
  String settingVersion(String version) {
    return 'Version：$version';
  }

  @override
  String get settingUserInfo => 'User information';

  @override
  String get settingCheckUpdate => 'Check for updates';

  @override
  String settingLatestVersion(String latest) {
    return 'Latest version: $latest';
  }

  @override
  String get settingWaiting => 'Waiting for obtain';

  @override
  String get settingFetchingUpdate => 'Fetching update information';

  @override
  String get settingNewVersion => 'New version released!';

  @override
  String get settingCurrentStable => 'You are running the latest version';

  @override
  String get settingCurrentTesting => 'You are running the testing version';

  @override
  String get settingFetchFailed => 'Failed to fetch update information';

  @override
  String get settingUiSetting => 'UI Settings';

  @override
  String get settingBrightnessSetting => 'Light/Dark mode';

  @override
  String get settingColorSetting => 'Color theme';

  @override
  String get settingSimplifyTimeline => 'Simplify schedule timeline';

  @override
  String get settingSimplifyTimelineDescription =>
      'Reduce space occupation while no schedule';

  @override
  String get settingLowElectricityWarning =>
      'Low electricity card color warning';

  @override
  String get settingLowElectricityWarningDescription =>
      'Change the homepage electricity card color when remaining electricity is below the threshold';

  @override
  String get settingLowElectricityThreshold => 'Low electricity threshold';

  @override
  String settingLowElectricityThresholdDescription(String threshold) {
    return 'Current: $threshold kWh';
  }

  @override
  String get settingLowElectricityThresholdDialogTitle =>
      'Set low electricity threshold';

  @override
  String get settingLowElectricityThresholdDialogInputHint =>
      'Input remaining electricity';

  @override
  String get settingAccountSetting => 'Account Settings';

  @override
  String get settingSportPasswordSetting => 'PE system password';

  @override
  String get settingExperimentPasswordSetting => 'Physics experiment password';

  @override
  String get settingElectricityPasswordSetting =>
      'Electricity account password';

  @override
  String get settingElectricityPasswordDescription =>
      'Please set if not default';

  @override
  String get settingElectricityAccountSetting => 'Electricity account setting';

  @override
  String get settingSchoolnetPasswordSetting => 'Campus net password';

  @override
  String get settingSchoolnetPasswordDescription =>
      'If you have not setted it, you cannot query it.';

  @override
  String get settingAirconImeiTitle => 'Aircon electricity data source';

  @override
  String get settingAirconImei => 'Aircon IMEI';

  @override
  String get settingAirconImeiNotSet =>
      'Not set. Aircon electricity will be hidden on the power page.';

  @override
  String settingAirconImeiCurrent(String imei) {
    return 'Current IMEI: $imei';
  }

  @override
  String get settingAirconImeiSaved => 'Aircon IMEI saved';

  @override
  String get settingAirconImeiCleared => 'Aircon IMEI cleared';

  @override
  String get settingAirconImeiInvalid => 'No valid 15-digit IMEI found';

  @override
  String get settingAirconImeiClear => 'Clear';

  @override
  String get settingScanAirconQr => 'Scan aircon QR code';

  @override
  String get settingPickAirconQrImage => 'Choose QR image';

  @override
  String get settingAirconCameraUnavailable =>
      'Camera scanning is unavailable on this platform. Choose a QR image or enter the IMEI manually.';

  @override
  String get settingNotificationSetting => 'Notification Settings';

  @override
  String get settingCourseReminderSetting => 'Pre-class Reminder Settings';

  @override
  String get settingCourseReminderDescription =>
      'Configure pre-class reminder notifications';

  @override
  String get settingNotificationPageTitle => 'Pre-class Reminder Settings';

  @override
  String settingNotificationPageLoadFailed(String error) {
    return 'Failed to load settings: $error';
  }

  @override
  String get settingNotificationPageFunctionSection => 'Notification Function';

  @override
  String get settingNotificationPageEnableNotification =>
      'Enable Pre-class Reminders';

  @override
  String settingNotificationPageNotificationScheduled(String count) {
    return '$count notifications scheduled';
  }

  @override
  String get settingNotificationPageNotificationDisabledHint =>
      'All scheduled notifications will be cancelled when disabled';

  @override
  String get settingNotificationPageUpdateSchedule =>
      'Update Notification Schedule';

  @override
  String get settingNotificationPageUpdateScheduleHint =>
      'Reschedule notifications based on the latest course data';

  @override
  String get settingNotificationPageDeleteAllSchedule =>
      'Delete All Scheduled Reminder';

  @override
  String get settingNotificationPageDeleteAllScheduleHint =>
      'This action will delete all scheduled events, but you can click \'Update Notification Schedule\' again to re-add them.';

  @override
  String get settingNotificationPageDeleteAllSuccess => 'Delete successfully';

  @override
  String get settingNotificationPageViewTheInstructions =>
      'View the instructions';

  @override
  String get settingNotificationPageViewTheInstructionsHint =>
      'Check more instructions to ensure that you can see the notifications sent by the program';

  @override
  String get settingNotificationPagePermissionSection => 'Permission Status';

  @override
  String get settingNotificationPageNotificationPermission =>
      'Notification Permission';

  @override
  String get settingNotificationPageExactAlarmPermission =>
      'Exact Alarm Permission';

  @override
  String get settingNotificationPagePermissionGranted => 'Granted';

  @override
  String get settingNotificationPagePermissionDenied => 'Denied';

  @override
  String get settingNotificationPageRequestPermission => 'Request Permission';

  @override
  String get settingNotificationPageSystemSettings =>
      'System Notification Settings';

  @override
  String get settingNotificationPageSystemSettingsHint =>
      'Open system settings to check notification configuration';

  @override
  String get settingNotificationPagePermissionGrantedMsg =>
      'Permission granted';

  @override
  String get settingNotificationPagePermissionDeniedMsg =>
      'Permission denied, please enable it in system settings';

  @override
  String get settingNotificationPageReminderSection => 'Reminder Settings';

  @override
  String get settingNotificationPageExperimentReminder =>
      'Include the physics experiments';

  @override
  String get settingNotificationPageExperimentReminderHint =>
      'Enable this option to add the physics experiment to the Pre-class Reminder';

  @override
  String get settingNotificationPageMinutesBefore => 'Advance Reminder Time';

  @override
  String get settingNotificationPageMinutesBeforeHint =>
      'The time setting for pre-class reminders';

  @override
  String get settingNotificationPageMinutesUnit => 'minutes';

  @override
  String get settingNotificationPageDaysToSchedule => 'Schedule Duration';

  @override
  String get settingNotificationPageDaysToScheduleHint =>
      'This program writes course information into the planned schedule in advance. This setting can adjust the number of days for writing into the planned schedule';

  @override
  String get settingNotificationPageDaysUnit => 'days';

  @override
  String get settingNotificationPageSettingsGuideTitle =>
      'Notification Settings Guide';

  @override
  String get settingNotificationPageSettingsGuideContent1 =>
      'To ensure you receive pre-class reminders in time, please make sure:\n1. App notification permission is enabled\n2. Notification sound is enabled\n3. Banner notifications are enabled\n4. Non-native Android users, enable auto-start and disable power optimization';

  @override
  String get settingNotificationPageSettingsGuideContent2 =>
      'Pre-class Reminder Module Operating Mechanism:\n1. When first activated, it will automatically schedule pre-class reminders for the upcoming days\n2. Each time the app is opened, it will automatically check and update the notification schedule\n3. After modifying settings, it will automatically reschedule all notifications';

  @override
  String get settingNotificationPageGotIt => 'Got it';

  @override
  String get settingNotificationPageOpenSettings => 'Open System Settings';

  @override
  String get settingNotificationPageNoClasstableData =>
      'Please fetch course schedule, exam, or experiment data first';

  @override
  String settingNotificationPageScheduleSuccess(String count) {
    return 'Scheduled $count pre-class reminders';
  }

  @override
  String settingNotificationPageScheduleFailed(String error) {
    return 'Failed to schedule notifications: $error';
  }

  @override
  String get settingNotificationPageCancelAllSuccess =>
      'All pre-class reminders cancelled';

  @override
  String settingNotificationPageRescheduleSuccess(String count) {
    return 'Rescheduled $count pre-class reminders';
  }

  @override
  String settingNotificationPageRescheduleFailed(String error) {
    return 'Failed to reschedule notifications: $error';
  }

  @override
  String get settingNotificationDebugPage => 'Notification Services Debug Page';

  @override
  String get settingClasstableSetting => 'Class Schedule Related';

  @override
  String get settingBackground => 'Background image';

  @override
  String get settingNoBackground =>
      'You need to select an image first, it\'s at below';

  @override
  String get settingChooseBackground => 'Choose background image';

  @override
  String get settingNoPermission =>
      'No storage permission obtained, cannot read files';

  @override
  String get settingSuccessfulSetting => 'Successfully set';

  @override
  String get settingFailureSetting => 'You did not select an image';

  @override
  String get settingClearUserClass => 'Clear all customized courses';

  @override
  String get settingClearUserClassTitle => 'Clear Confirmation';

  @override
  String get settingClearUserClassContent =>
      'Do you want to clear all user-added courses? This function does not affect the schedule obtained from the school.';

  @override
  String get settingClearUserClassClear => 'Already cleared';

  @override
  String get settingClassRefresh => 'Force refresh class schedule';

  @override
  String get settingClassRefreshTitle => 'Refresh Confirmation';

  @override
  String get settingClassRefreshContent =>
      'Do you want to force refreshing the class schedule? If you agree, we will fetch the schedule from the school, which may takes a long time.';

  @override
  String get settingClassSwift => 'Class schedule offset setting';

  @override
  String settingClassSwiftDescription(String swift) {
    return 'Positive number delays the start date, negative number advances the start date\nCurrently $swift\n';
  }

  @override
  String get settingCoreSetting => 'Cached login settings';

  @override
  String get settingCheckLogger => 'View network interceptor and logs';

  @override
  String get settingClearAndRestart => 'Clear cache and restart';

  @override
  String get settingClearAndRestartDialogTitle => 'Restart confirmation';

  @override
  String get settingClearAndRestartDialogContent =>
      'Are you sure to clear cache and restart the program?';

  @override
  String get settingClearAndRestartDialogCleaning => 'Clearing cache...';

  @override
  String get settingClearAndRestartDialogClear => 'Cache has been cleared';

  @override
  String get settingLogout => 'Log out and restart the app';

  @override
  String get settingLogoutDialogTitle => 'Logout confirmation';

  @override
  String get settingLogoutDialogContent =>
      'Are you want to log out? All your data will be completely deleted!';

  @override
  String get settingLogoutDialogLoggingOut => 'Logging out...';

  @override
  String get settingNeedCloseDialogTitle => 'Crashed';

  @override
  String get settingNeedCloseDialogContent =>
      'Due to technical limitations, you need to close the window manually and then reopen the app.';

  @override
  String get settingChangeColorDialogTitle => 'Color setting';

  @override
  String get settingChangeColorDialogDefault => 'Default';

  @override
  String get settingChangeColorDialogBlue => 'Sky Blue';

  @override
  String get settingChangeColorDialogDeeppurple => 'Deep Purple';

  @override
  String get settingChangeColorDialogGreen => 'Spring Green';

  @override
  String get settingChangeColorDialogOrange => 'Asuka Orange';

  @override
  String get settingChangeColorDialogPink => 'Sakura Pink';

  @override
  String get settingChangeBrightnessDialogTitle => 'Brightness settings';

  @override
  String get settingChangeBrightnessDialogFollowSetting => 'Follow system';

  @override
  String get settingChangeBrightnessDialogDayMode => 'Day mode';

  @override
  String get settingChangeBrightnessDialogNightMode => 'Night mode';

  @override
  String get settingChangeSwiftDialogTitle => 'Class schedule offset setting';

  @override
  String get settingChangeSwiftDialogInputHint => 'Please input number here';

  @override
  String get settingChangeElectricityTitle => 'Modify electricity account';

  @override
  String get settingChangeElectricityAccountTitle =>
      'Modify electricity account';

  @override
  String get settingChangeElectricityAccountCampus => 'Campus';

  @override
  String get settingChangeElectricityAccountNorthcampus => 'Northern Campus';

  @override
  String get settingChangeElectricityAccountSouthcampus => 'Southern Campus';

  @override
  String get settingChangeElectricityAccountUnitorzone => 'Unit  / Zone';

  @override
  String get settingChangeElectricityAccountUnitcode => 'Unit';

  @override
  String get settingChangeElectricityAccountZonecode => 'Zone';

  @override
  String settingChangeElectricityAccountPleaseinput(String unitOrZoneCode) {
    return 'Please input $unitOrZoneCode';
  }

  @override
  String settingChangeElectricityAccountSuccessfulFetch(String accountNumber) {
    return 'Successful fetching account: $accountNumber';
  }

  @override
  String settingChangeElectricityAccountFailedFetch(String e) {
    return 'Failed to fetch: $e';
  }

  @override
  String settingChangeElectricityAccountAccountSaved(String accountNumber) {
    return 'Account saved：$accountNumber';
  }

  @override
  String get settingChangeElectricityAccountUnknownCodingPattern =>
      'Unknown coding pattern';

  @override
  String get settingChangeElectricityAccountSelectBuilding => 'Select Building';

  @override
  String get settingChangeElectricityAccountBuilding => 'Building';

  @override
  String get settingChangeElectricityAccountNorthernBuilding =>
      'Northern Building';

  @override
  String get settingChangeElectricityAccountSouthernBuilding =>
      'Southern Building';

  @override
  String settingChangeElectricityAccountFailedGenerate(String e) {
    return 'Failed to generate: $e';
  }

  @override
  String get settingChangeElectricityAccountBuildingNumber => 'Building number';

  @override
  String get settingChangeElectricityAccountBuildingNumberHint =>
      'eg: 16, 7, 55';

  @override
  String get settingChangeElectricityAccountBuildingNumberQuery =>
      'Please input building No.';

  @override
  String get settingChangeElectricityAccountYard => 'Yard';

  @override
  String get settingChangeElectricityAccountYardHint => 'Select Yard';

  @override
  String get settingChangeElectricityAccountNorthyard => 'North Yard';

  @override
  String get settingChangeElectricityAccountSouthyard => 'South Yard';

  @override
  String get settingChangeElectricityAccountYardQuery => 'Please select yard';

  @override
  String get settingChangeElectricityAccountApartment => 'Apartment';

  @override
  String get settingChangeElectricityAccountApartmentHint => 'Select Apartment';

  @override
  String get settingChangeElectricityAccountNorthapartment => 'North Apartment';

  @override
  String get settingChangeElectricityAccountSouthapartment => 'South Apartment';

  @override
  String get settingChangeElectricityAccountApartmentQuery =>
      'Please select apartment';

  @override
  String get settingChangeElectricityAccountLevelcode => 'Floor number';

  @override
  String get settingChangeElectricityAccountLevelcodeQuery => 'Floor number';

  @override
  String get settingChangeElectricityAccountRoomcode => 'Room code';

  @override
  String get settingChangeElectricityAccountRoomcodeHint => 'eg: 304, 508';

  @override
  String get settingChangeElectricityAccountRoomcodeQuery =>
      'Please input room code';

  @override
  String get settingChangeElectricityAccountAccount => 'Electricity Account';

  @override
  String get settingChangeElectricityAccountAccountHint =>
      'Please enter your account';

  @override
  String get settingChangeElectricityAccountAccountQuery =>
      'Please input your account';

  @override
  String get settingChangeElectricityAccountAccountLength =>
      'Account length is larger than 10';

  @override
  String get settingChangeElectricityAccountFetching => 'Fetching...';

  @override
  String get settingChangeElectricityAccountFetchFromInternet =>
      'Sync from backend';

  @override
  String get settingChangeElectricityAccountSaveAccount => 'Save account';

  @override
  String get settingChangeElectricityAccountConfirmSaving => 'Confirm account';

  @override
  String get settingChangeElectricityAccountCalculateAccount =>
      'Calculate account';

  @override
  String get settingChangeElectricityAccountCalculate => 'Calculate';

  @override
  String get settingChangeElectricityAccountInput => 'Input';

  @override
  String get settingChangeElectricityAccountConfirmAccount =>
      'Confirm your account: ';

  @override
  String get settingChangeElectricityAccountChange => 'Edit';

  @override
  String get settingChangeElectricityAccountCancel => 'Cancel';

  @override
  String get settingChangeElectricityAccountNoSetting =>
      'No new electricity account set';

  @override
  String get settingChangeElectricityAccountSuccessfulSetting =>
      'Successfully setting new electricity account';

  @override
  String get settingChangeExperimentTitle =>
      'Modify physics experiment account password';

  @override
  String get settingChangeSportTitle => 'Modify sports system account password';

  @override
  String get settingChangePasswordDialogInputHint =>
      'Please input password here';

  @override
  String get settingChangePasswordDialogBlankInput => 'Blank input!';

  @override
  String get settingChangeSchoolnetPasswordTitle =>
      'Modify the schoolnet query password';

  @override
  String get settingUpdateDialogNewVersion => 'New version available';

  @override
  String get settingUpdateDialogNotNow => 'Not now';

  @override
  String get settingUpdateDialogAppStore => 'Update from App Store';

  @override
  String get settingUpdateDialogDownloadApk => 'Download APK';

  @override
  String get settingUpdateDialogGithubRelease => 'Go to Git Release';

  @override
  String settingUpdateDialogNewContent(String code) {
    return 'New features from version $code:\n';
  }

  @override
  String get settingLocalizationDialogTitle => 'Languages';

  @override
  String get settingLocalizationDialogUndefined => 'Follow system setting';

  @override
  String get settingLocalizationDialogSimplifiedchinese => 'Simplified Chinese';

  @override
  String get settingLocalizationDialogTraditionalchinese =>
      'Traditional Chinese';

  @override
  String get settingLocalizationDialogEnglish => 'English';

  @override
  String get settingSemesterChange => 'Change semester';

  @override
  String settingSemesterChangeDescription(String semester) {
    return 'Using semester $semester';
  }

  @override
  String get settingSemesterUpdateData => 'Applying new semester setting';

  @override
  String get settingEasterEggPage => 'You found an Easter egg';

  @override
  String get settingAboutPageBenderblog => 'Main developer, iOS widget';

  @override
  String get settingAboutPageAlnair => 'Development: Library search and cover';

  @override
  String get settingAboutPageAqqkad => 'Development: Class attandance history';

  @override
  String get settingAboutPageBellssgit =>
      'Support: best and longest feedback source';

  @override
  String get settingAboutPageBrackrat =>
      'Design: homepage, login page, color scheme, iOS widgets, etc.';

  @override
  String get settingAboutPageBreezeline =>
      'Support: valueless and meaningless product manager (from his own description)';

  @override
  String get settingAboutPageCafebabe =>
      'Support: provide Easter egg code / Development: Development: New Slider \'26';

  @override
  String get settingAboutPageChitao1234 =>
      'Development: fix slider misalignment issue';

  @override
  String get settingAboutPageCopperkoi =>
      'Development: latest time arrangement sync to calendar';

  @override
  String get settingAboutPageDimole =>
      'Development support: assist in fixing slider issue';

  @override
  String get settingAboutPageElitewars => 'Design: sports score page';

  @override
  String get settingAboutPageElliot =>
      'Internationalization: English translation / Development guidance: on partner classtable development (This function has been removed)';

  @override
  String get settingAboutPageFlyingpig =>
      'Development: Fix null pointer exception at user defined class info';

  @override
  String get settingAboutPageGodhu777777 =>
      'Internationalization: Traditional Chinese conversion code & Easter egg code / Development: Optimize outputing arrangements to the calendar';

  @override
  String get settingAboutPageHancl777 =>
      'Internationalization: Traditional Chinese conversion code';

  @override
  String get settingAboutPageHazukiKeatsu =>
      'Development: Physics experiment score query and recognization';

  @override
  String get settingAboutPageHawa130 => 'Design: Class info card';

  @override
  String get settingAboutPageHhzm =>
      'Development: electricity fee inquiry account calculation';

  @override
  String get settingAboutPageImaginary17 =>
      'Developement: Ruisi navigator stack fix';

  @override
  String get settingAboutPageImoscarz =>
      'Development: Homepage for software / Development: Checkin check for pad / Development: Sport UI Change';

  @override
  String get settingAboutPageKaMateKaOra =>
      'Internationalization: English correction';

  @override
  String get settingAboutPageLagrangeX =>
      'Development: Class progress indicator (adopted) / Development: Gray cover on attended class and other classtable design';

  @override
  String get settingAboutPageLhx666Cool =>
      'Support: Windows and Linux build scripts / Development: New Slider \'26';

  @override
  String get settingAboutPageLichtyy =>
      'Design: color pattern and blank page picture / Development: HTML reader for the experiment system';

  @override
  String get settingAboutPageLqsyH => 'Support: Promotion Picture';

  @override
  String get settingAboutPageLsy223622 =>
      'Design: iOS and Android icons / Support: titled XDYou';

  @override
  String get settingAboutPageMrbrilliant2046 =>
      'Support: Provided the school net user guide / Internationalization: English correction';

  @override
  String get settingAboutPageNancunchild =>
      'Development: library search function / Internationalization: English correction';

  @override
  String get settingAboutPageNkanf =>
      'Development: Class progress indicator (original) / Support: MacOS build support';

  @override
  String get settingAboutPagePairman =>
      'Development: score cache and optimize slider algorithm / Internationalization: English correction';

  @override
  String get settingAboutPageReverierxu =>
      'Design: REX card for information display / Development support: on postgraduate class schedule';

  @override
  String get settingAboutPageRrrilac =>
      'Development support: electricity query';

  @override
  String get settingAboutPageRay =>
      'Design: splash screen / Support: iOS publisher / Development guidance: on partner classtable development (This function has been removed) / Internationalization: English correction';

  @override
  String get settingAboutPageShadowyingyi =>
      'Support: two times of pigeon house official account publicity';

  @override
  String get settingAboutPageStalomeow =>
      'Design: homepage timeline / Development: asynchronous login and captcha predict';

  @override
  String get settingAboutPageXeonds =>
      'Design: settings page / Development: XDU Planet / Development: Payment Code';

  @override
  String get settingAboutPageXingshuyu =>
      'Development: Fix physics experiment api and electricity graph';

  @override
  String get settingAboutPageXiue233 => 'Development: Android applet';

  @override
  String get settingAboutPageXizi =>
      'Development support: on postgraduate version';

  @override
  String get settingAboutPageWirsbf =>
      'Development: fix course adjustment did not proceed as expected';

  @override
  String get settingAboutPageZcwzy =>
      'Development: fix Dingxiang apartment electricity fee / development support: on postgraduate version / design: blank page picture';

  @override
  String get settingAboutPageZyarEr => 'Development support: fix shortcut url';

  @override
  String get settingAboutPageHomepage => 'Homepage';

  @override
  String get settingAboutPageCode => 'Source code';

  @override
  String get settingAboutPageKnowMore => 'Learn more';

  @override
  String get settingAboutPageCopyrightNotice =>
      'This software is compiled, or derived from the traintime_pda (a.k.a watermeter) codebase, which is licensed under Mozilla Public License v2.0.\n\nThis APP has no relation to Xidian University, Tishineng Service, Shuwow and other services.\n\nCopyright 2023-2025 BenderBlog Rodriguez and contributors.\nCopyright 2025-present Traintime PDA authors.\n\nThe Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, you can obtain one at https://mozilla.org/MPL/2.0/.';

  @override
  String get settingAboutPageBeian => 'ICP record code';

  @override
  String get settingAboutPageSignAndroid => 'Android signature';

  @override
  String get settingAboutPageTitle => 'About this APP';

  @override
  String get sportTitle => 'Sport Query';

  @override
  String get sportClassInfo => 'Class information';

  @override
  String get sportEmptyClassInfo => 'No class information found';

  @override
  String get sportTestScore => 'Sport test score';

  @override
  String get sportTotalScore => 'Four-year total score';

  @override
  String get sportTotalScoreLabel => 'Total Score';

  @override
  String get sportRankLabel => 'Rank';

  @override
  String sportSemester(String year, String gradeType) {
    return 'Semester $year $gradeType';
  }

  @override
  String get sportSubject => 'Subject';

  @override
  String get sportData => 'Data';

  @override
  String get sportScore => 'Score';

  @override
  String get sportPassed => 'Passed';

  @override
  String sportFromTo(String start, String stop) {
    return 'Period $start to $stop';
  }

  @override
  String sportScoreString(String score) {
    return '$score points';
  }

  @override
  String get sportSituationNopassword => 'No password';

  @override
  String get sportSituationMaintain => 'System maintenance';

  @override
  String get sportSituationFailedLogin => 'Login failed';

  @override
  String get sportSituationQuery => 'Query failed';

  @override
  String get sportSituationNetwork => 'Network malfunction';

  @override
  String sportSituationUnknown(String situation) {
    return 'Unknown malfunction $situation';
  }

  @override
  String get sportSituationFetching => 'Fetching...';

  @override
  String sportSituationError(String situation) {
    return 'Bad thing: $situation';
  }

  @override
  String get sportCacheHintMissingPassword =>
      'Please set your PE password and try again.';

  @override
  String get sportCacheHintCredentialInvalid =>
      'The PE login has expired. Please update your PE password and try again.';

  @override
  String get sportCacheHintMaintain =>
      'The PE service is under maintenance. Please try again later.';

  @override
  String get sportCacheHintLoginFailed => 'Failed to log in to the PE service.';

  @override
  String get sportCacheHintQueryFailed => 'Failed to query PE information.';

  @override
  String get sportCacheHintNetwork => 'The PE service network request failed.';

  @override
  String get sportCacheHintUnknown =>
      'Failed to fetch PE information online. Check logs for details.';

  @override
  String get sportErrorAuthExpired =>
      'The PE login has expired. Please try again.';

  @override
  String get sportErrorMissingPassword => 'PE password is not set';

  @override
  String get sportErrorCredentialInvalid =>
      'The PE login has expired. Please update your PE password and try again.';

  @override
  String get toolboxTitle => 'Other Functions';

  @override
  String get toolboxPayment => 'Payment System';

  @override
  String get toolboxPaymentDescription => 'Times to pay the electricity fee';

  @override
  String get toolboxDrinkingwater => 'Drinking Water';

  @override
  String get toolboxDrinkingwaterDescription => 'Is good for health';

  @override
  String get toolboxRepair => 'Repair report';

  @override
  String get toolboxRepairDescription =>
      'Don\'t let the water leak from the top';

  @override
  String get toolboxReserve => 'Space Reservation';

  @override
  String get toolboxReserveDescription => 'Find a place to gathering';

  @override
  String get toolboxMobile => 'Mobile Portal';

  @override
  String get toolboxMobileDescription => 'Specific for leaving';

  @override
  String get toolboxNetwork => 'Network Query';

  @override
  String get toolboxNetworkDescription => 'Hope never charges (NO!)';

  @override
  String get toolboxPhysics => 'Physics Calculation';

  @override
  String get toolboxPhysicsDescription => 'Hope the operation goes smoothly';

  @override
  String get toolboxDiscover => 'Ruisi Navigation';

  @override
  String get toolboxDiscoverDescription => 'Lots other functions';

  @override
  String get xduPlanetAll => 'All';

  @override
  String get xduPlanetLoading => 'Loading, please wait <(=ω=)>';

  @override
  String get xduPlanetUnknownAuthor => 'Unknown author';

  @override
  String get xduPlanetLoadFailedTitle => 'Failed to load';

  @override
  String get xduPlanetLoadFailedBottom =>
      'Failed to load the article, you can click the button on the top right of the screen to open it in the browser.';

  @override
  String get xduPlanetNoComment => 'No comments yet';

  @override
  String xduPlanetReplyAudit(String reply_to) {
    return 'Reply comment #$reply_to has been reported or deleted';
  }

  @override
  String xduPlanetReply(String reply_to, String content) {
    return 'Reply to #$reply_to: $content';
  }

  @override
  String get xduPlanetHaveBeenAudit => 'This comment has been reported';

  @override
  String get xduPlanetAudit => 'Report';

  @override
  String get xduPlanetConfirmAuditDialogTitle => 'Confirm reporting';

  @override
  String get xduPlanetConfirmAuditDialogContent =>
      'Think twice. Reporting will tag the comment, but it may not be deleted.';

  @override
  String get xduPlanetConfirmAuditDialogCancel => 'Forget it';

  @override
  String get xduPlanetConfirmAuditDialogOngoing => 'Reporting...';

  @override
  String get xduPlanetConfirmAuditDialogFailed => 'Failed to report';

  @override
  String get xduPlanetConfirmAuditDialogSuccess => 'Successfully reporting';

  @override
  String get xduPlanetComment => 'Reply';

  @override
  String get xduPlanetSend => 'Send';

  @override
  String get xduPlanetSending => 'Sending comment';

  @override
  String get xduPlanetEmptySend => 'Blank message sent';

  @override
  String get xduPlanetHintSendComment => 'Express yourself!';

  @override
  String get xduPlanetCommentTitle => 'Comment on this article';

  @override
  String get xduPlanetCommentSuccess => 'Successfully commenting';

  @override
  String get xduPlanetCommentFailed => 'Comment failed, please check the log';

  @override
  String get xduPlanetCommentCanceled => 'Nothing to say?';

  @override
  String get xduPlanetCommentLoading => 'Loading comments...';

  @override
  String get xduPlanetBlock => 'Blocked';

  @override
  String get xduPlanetDelete => 'Deleted';

  @override
  String get xduPlanetAudio => 'Deleted';

  @override
  String get electricityStatusPending => 'Pending';

  @override
  String get electricityStatusRemainFetching => 'Fetching...';

  @override
  String get electricityStatusRemainNetworkIssue => 'Network malfunction';

  @override
  String get electricityStatusRemainNotFound => 'Query failed';

  @override
  String get electricityStatusRemainOtherIssue => 'Query malfunction';

  @override
  String get electricityStatusOweFetching => 'Obtaining arrearage';

  @override
  String get electricityStatusOweIssue =>
      'Network malfunction of overdue information';

  @override
  String get electricityStatusOweNotFound =>
      'Cannot query arrearage, check log window for detail';

  @override
  String get electricityStatusOweNoNeed => 'None';

  @override
  String electricityStatusOweNeedPay(String due) {
    return 'Need to pay $due yuan';
  }

  @override
  String get electricityStatusOweIssueUnable => 'Cannot query arrearage';

  @override
  String get electricityStatusNeedMoreInfo =>
      'Need to improve information on the payment platform';

  @override
  String get electricityStatusNeedAccount =>
      'Need to input electricity account';

  @override
  String get electricityStatusCaptchaFailed => 'Failed to check captcha';

  @override
  String get electricityStatusOtherIssue => 'Program malfunction';

  @override
  String get schoolCardStatusFailedToFetch => 'Failed fetching';

  @override
  String get schoolCardStatusFailedToQuery => 'Failed querying';

  @override
  String get easterEggApple =>
      '=== Fly Me To The Moon ===\nVocal: Frank Sintara, 1964\n\nFly me to the moon\nLet me play among the stars\n\nLet me see what\'s spring is like\non a Jupiter and Mars\n\nFill my heart with song\nand let me sing forever more\n\nYou are all I long for\nall I worship and I adore\n\nIn other words\nPlease, be true\n\nIn other words\nI love you\n\n=== Living Inside Your Love ===\nGuitar: Earl Klugh, 1976\n\nCan\'t get over the feeling\nLiving inside your love\n\nI never want to lose the feeling\nLiving inside your love\n\nBaby, you made my life so free\nLiving inside your love\n\nI\'m just where I want to be\nLiving inside your love\n\nAnd I never could say\nWhat I\'m feeling today\nFor you...\n';

  @override
  String get easterEggOthers =>
      '=== Cardcaptor Sakura OP3 ===\nVocal: Maaya Sakamoto, 2000\nIn Japanese Roman Letters\n\nI\'m a dreamer\nhisomu PAWA-\n\nwatashi no sekai\nyume to koi to fuan de dekite\'ru\ndemo souzou wo shinai mono\nkakurete\'ru hazu\n\nsora ni mukau kiki no you ni anata wo\nmassugu mitsumete\'ru\nmitsuketai naa kanaetai naa\nshinjiru sore dake de\n\nkoerarenai mono wa nai\nutau you ni kiseki no you ni\n\"omoi\" ga subete wo kaete yuku yo\nkitto kitto\nodoroku kurai\n\n=== Living Inside Your Love ===\nGuitar: Earl Klugh, 1976\n\nCan\'t get over the feeling\nLiving inside your love\n\nI never want to lose the feeling\nLiving inside your love\n\nBaby, you made my life so free\nLiving inside your love\n\nI\'m just where I want to be\nLiving inside your love\n\nAnd I never could say\nWhat I\'m feeling today\nFor you...\n';

  @override
  String get easterEggRobotAppbar => 'Welcome Students!';

  @override
  String get easterEggRobotTitle =>
      'Looking like you are worrying about opening semester?';

  @override
  String get easterEggRobotContents =>
      'We are here to let our children have more pocket money.\n1. Robots may not injure a human being or, through inaction, allow a human being to come to harm.\n2. Robots are born from the ashes of the network running at the cloud.\n3. Robots are lovestruck, which cannot be annoyed, and loves merging programs!\n4. Robots sometimes can be controlled to avoid the attack from the Angles.\n5. Robots have shiny metal ass which should not be bitten.\nAnd they have a plan.';

  @override
  String get easterEggRobotButtonOne => 'We are hanger for your help!';

  @override
  String get easterEggRobotButtonTwo => 'Come on!';

  @override
  String get easterEggRobotButtonNotice => '\\o/\\o/\\o/\\o/\\o/\\o/\\o/\\o/';

  @override
  String get restartAppTitleCacheCleared => 'Cache Cleared';

  @override
  String get restartAppTitleLoggedOut => 'Logged Out';

  @override
  String get restartAppTitlePasswordWrong => 'Wrong Password';

  @override
  String get restartAppContent => 'Tap to reopen the app';

  @override
  String get ruisiCommonRefresh => 'Refresh';

  @override
  String get ruisiCommonConfirm => 'OK';

  @override
  String get ruisiCommonCancel => 'Cancel';

  @override
  String get ruisiCommonRetry => 'Retry';

  @override
  String get ruisiCommonNoTopics => 'No topics';

  @override
  String get ruisiCommonNoContent => 'No content';

  @override
  String get ruisiCommonReply => 'Reply';

  @override
  String get ruisiCommonFavorite => 'Favorite';

  @override
  String get ruisiCommonNotImplemented => 'Not implemented';

  @override
  String get ruisiCommonLogin => 'Login';

  @override
  String get ruisiCommonLogout => 'Log out';

  @override
  String get ruisiCommonLoggedOut => 'Logged out';

  @override
  String get ruisiCommonSubmit => 'Submit';

  @override
  String get ruisiAboutTitle => 'About';

  @override
  String get ruisiAboutAppName => 'Ruisi';

  @override
  String get ruisiAboutSubtitle => 'Xidian University Campus Forum Client';

  @override
  String get ruisiAboutVersion => 'Version';

  @override
  String get ruisiAboutVersionNumber => '2.0.0 (Bundled with XDYou 1.6.0)';

  @override
  String get ruisiAboutSourceCode => 'Source Code';

  @override
  String get ruisiAboutBugReport => 'Report Issue';

  @override
  String get ruisiAboutBugReportSubtitle => 'Submit an issue on GitHub';

  @override
  String get ruisiAboutPrivacyPolicy => 'Privacy Policy';

  @override
  String get ruisiAboutLicense =>
      'Open-sourced under the BSD-3-Clause License Reimplemented based on Ruisi-iOS and Ruisi-Android with AI assistant';

  @override
  String get ruisiAboutPrivacyPolicyContent =>
      'This app only operates on the Xidian University campus network, accessing data from the Ruisi Forum (rs.xidian.edu.cn).\n\nThis app does not collect, store, or transmit any personal information to third-party servers.\n\nUser login credentials are stored only on the local device, used for authentication with the Ruisi Forum server.\n\nThis app uses cookies to communicate with the Ruisi Forum server. All data exchange occurs directly between the user\'s device and the Ruisi Forum server.\n\nIf you have any questions, please contact the developer by submitting an issue on GitHub.';

  @override
  String get ruisiHomeTitle => 'Ruisi Forum';

  @override
  String get ruisiHomeNewPost => 'New Post';

  @override
  String get ruisiHomeForumList => 'Forum List';

  @override
  String get ruisiHomeTabHot => 'Hot';

  @override
  String get ruisiHomeTabNewReply => 'Latest Replies';

  @override
  String get ruisiHomeTabNewPost => 'Latest Posts';

  @override
  String get ruisiHomeTabMy => 'Me';

  @override
  String get ruisiHomeTabTrade => 'Trading';

  @override
  String get ruisiHomeTabWater => 'Water Bar';

  @override
  String get ruisiHomeTabLostFound => 'Lost & Found';

  @override
  String get ruisiHomeTabEmployment => 'Employment';

  @override
  String get ruisiHomeTabPhotography => 'Photography';

  @override
  String get ruisiHomePleaseLogin => 'Please log in first';

  @override
  String get ruisiHomeMyProfile => 'My Profile';

  @override
  String get ruisiHomeMyPosts => 'My Posts';

  @override
  String get ruisiHomeMyFavorites => 'My Favorites';

  @override
  String get ruisiHomeMessageCenter => 'Messages';

  @override
  String get ruisiHomeDailyCheckin => 'Daily Check-in';

  @override
  String get ruisiHomeSettings => 'Settings';

  @override
  String get ruisiHomeAbout => 'About';

  @override
  String get ruisiHomeSearch => 'Search';

  @override
  String get ruisiLoginTitle => 'Login to Ruisi';

  @override
  String get ruisiLoginUsername => 'Username';

  @override
  String get ruisiLoginUsernameHint => 'Please enter username';

  @override
  String get ruisiLoginPassword => 'Password';

  @override
  String get ruisiLoginPasswordHint => 'Please enter password';

  @override
  String get ruisiLoginCaptcha => 'Captcha';

  @override
  String get ruisiLoginCaptchaHint => 'Please enter captcha';

  @override
  String get ruisiLoginBack => 'Back';

  @override
  String get ruisiLoginResetLoginState => 'Reset Login State';

  @override
  String get ruisiLoginResetConfirmTitle => 'Confirm Reset';

  @override
  String get ruisiLoginResetConfirmContent =>
      'Are you sure you want to reset the login state? This will clear all login information.';

  @override
  String get ruisiLoginResetSuccess => 'Login state has been reset';

  @override
  String get ruisiLoginViewLogs => 'View Logs';

  @override
  String get ruisiPostTitle => 'New Post';

  @override
  String get ruisiPostPublish => 'Publish';

  @override
  String get ruisiPostSelectForum => 'Select Forum';

  @override
  String get ruisiPostSelectForumHint => 'Please select a forum';

  @override
  String get ruisiPostSubject => 'Title';

  @override
  String get ruisiPostSubjectHint => 'Please enter a title';

  @override
  String get ruisiPostContent => 'Content';

  @override
  String get ruisiPostContentHint => 'Please enter content';

  @override
  String get ruisiPostSuccess => 'Post published';

  @override
  String get ruisiPostFailure => 'Failed to publish';

  @override
  String get ruisiPostSmiley => 'Smileys';

  @override
  String get ruisiTopicDetailTitle => 'Topic Detail';

  @override
  String get ruisiTopicDetailReplyTooShort =>
      'Reply must be at least 13 characters';

  @override
  String get ruisiTopicDetailReplySuccess => 'Reply sent';

  @override
  String get ruisiTopicDetailReplyFailure => 'Failed to reply';

  @override
  String get ruisiTopicDetailFavoriteSuccess => 'Added to favorites';

  @override
  String get ruisiTopicDetailFavoriteFailure => 'Failed to add to favorites';

  @override
  String get ruisiTopicDetailNoData => 'No data';

  @override
  String get ruisiTopicDetailReplyHint => 'Write a reply...';

  @override
  String get ruisiTopicDetailVoteSingleSelect => 'Single choice';

  @override
  String ruisiTopicDetailVoteMultiSelect(String count) {
    return 'Multiple choice, up to $count';
  }

  @override
  String get ruisiTopicDetailVoteTitlePrefix => 'Vote';

  @override
  String ruisiTopicDetailVoteCount(String count) {
    return '$count people voted';
  }

  @override
  String get ruisiTopicDetailVoteOpen => 'Vote';

  @override
  String get ruisiTopicDetailVoteSheetTitle => 'Vote';

  @override
  String ruisiTopicDetailVoteMaxSelection(String count) {
    return 'You can select up to $count';
  }

  @override
  String get ruisiTopicDetailVoteNotSelected => 'Please select an option';

  @override
  String get ruisiTopicDetailVoteSuccess => 'Vote submitted';

  @override
  String get ruisiTopicDetailVoteFailure => 'Vote failed';

  @override
  String get ruisiTopicDetailVoteParamError =>
      'Vote failed: invalid parameters';

  @override
  String get ruisiTopicDetailVoteAlreadyVoted =>
      'You have already voted. Thank you!';

  @override
  String get ruisiTopicDetailVoteExpired =>
      'This poll has expired or been closed';

  @override
  String get ruisiTopicDetailVoteEnded => 'This poll has ended';

  @override
  String get ruisiTopicListItemSticky => 'Pinned';

  @override
  String get ruisiForumListTitle => 'Forum List';

  @override
  String get ruisiForumListEmpty => 'Ruisi Forum section grouping is empty';

  @override
  String get ruisiFavoritesTitle => 'My Favorites';

  @override
  String get ruisiFavoritesEmpty => 'No favorites';

  @override
  String get ruisiMessagesTitle => 'Messages';

  @override
  String get ruisiMessagesTabAt => '@Me';

  @override
  String get ruisiMessagesNoReply => 'No reply notifications';

  @override
  String get ruisiMessagesNoAt => 'No @ notifications';

  @override
  String get ruisiSearchHint => 'Search topics...';

  @override
  String get ruisiSearchInputHint => 'Enter keywords to search';

  @override
  String get ruisiSearchNoResults => 'No results';

  @override
  String get ruisiSettingsTitle => 'Settings';

  @override
  String get ruisiSettingsSectionProxy => 'Proxy';

  @override
  String get ruisiSettingsProxyEnable => 'Enable Proxy';

  @override
  String get ruisiSettingsProxyDisabled => 'Disabled';

  @override
  String get ruisiSettingsProxyAddress => 'Proxy Address';

  @override
  String get ruisiSettingsSectionDebug => 'Debug';

  @override
  String get ruisiSettingsViewLogs => 'View Logs';

  @override
  String get ruisiSettingsProxyDialogTitle => 'Proxy Settings';

  @override
  String get ruisiSettingsProxyHost => 'Host';

  @override
  String get ruisiSettingsProxyHostHint => 'e.g. 127.0.0.1';

  @override
  String get ruisiSettingsProxyPort => 'Port';

  @override
  String get ruisiSettingsProxyPortHint => 'e.g. 7890';

  @override
  String get ruisiUserTitle => 'Me';

  @override
  String get ruisiUserTabProfile => 'Profile';

  @override
  String get ruisiUserUnknown => 'Unknown User';

  @override
  String get loadError => 'Load Error';

  @override
  String courseReminderTitle(String name) {
    return 'Pre-class Reminder: $name';
  }

  @override
  String courseReminderBody(String time) {
    return 'Class starts in $time minutes';
  }

  @override
  String courseReminderLocation(String location) {
    return 'Location: $location';
  }

  @override
  String courseReminderTeacher(String teacher) {
    return 'Teacher: $teacher';
  }
}
