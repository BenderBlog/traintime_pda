// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class I18nZh extends I18n {
  I18nZh([String locale = 'zh']) : super(locale);

  @override
  String get dragText => '上拉获取更多数据';

  @override
  String get readyText => '正在加载......';

  @override
  String get processingText => '正在处理......';

  @override
  String get processedText => '请求成功';

  @override
  String get noMoreText => '没有更多数据';

  @override
  String get failedText => '数据获取失败';

  @override
  String get chooseSemester => '选择学期';

  @override
  String get errorDetected => 'Ouch! 发生错误啦';

  @override
  String get clickToRefresh => '点我刷新';

  @override
  String get confirmTitle => '确认？';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get networkError => '网络错误，可能是没联网，可能是学校服务器出现了故障:-P';

  @override
  String get errorDetect => '遇到错误，请查看日志';

  @override
  String get queryFailed => '查询失败';

  @override
  String get notSchoolNetwork => '没有在校园网环境';

  @override
  String get experimentControllerNoPassword => '没有物理实验密码，请到设置中进行设置';

  @override
  String get experimentControllerLoginFailed => '登录失败';

  @override
  String get cancelExam => '取消考试资格:P';

  @override
  String get loginProcessReadyPage => '准备获取登录网页';

  @override
  String get loginProcessGetEncrypt => '获取密码加密密钥';

  @override
  String get loginProcessReadyLogin => '准备登录';

  @override
  String get loginProcessSlider => '登录中';

  @override
  String get loginProcessAfterProcess => '登录后处理';

  @override
  String loginProcessFailed(String statusCode) {
    return '登录失败，响应状态码：$statusCode';
  }

  @override
  String get noInfo => '没有信息';

  @override
  String get catcherDetected => '发生错误';

  @override
  String get catcherDescription => '详情如下';

  @override
  String get newHomepageHint => '本程序将开发一个新主页，目前先用猪图秀占位，玩得愉快';

  @override
  String localCacheHint(String datetime) {
    return '本地缓存获取于 $datetime';
  }

  @override
  String inappCacheHint(String datetime) {
    return '程序内缓存获取于 $datetime\n缓存退出程序后失效！';
  }

  @override
  String get cacheReasonDefault => '当前显示缓存数据。';

  @override
  String get weekdayMonday => '周一';

  @override
  String get weekdayTuesday => '周二';

  @override
  String get weekdayWednesday => '周三';

  @override
  String get weekdayThursday => '周四';

  @override
  String get weekdayFriday => '周五';

  @override
  String get weekdaySaturday => '周六';

  @override
  String get weekdaySunday => '周日';

  @override
  String get monthJanuary => '一月';

  @override
  String get monthFebruary => '二月';

  @override
  String get monthMarch => '三月';

  @override
  String get monthApril => '四月';

  @override
  String get monthMay => '五月';

  @override
  String get monthJune => '六月';

  @override
  String get monthJuly => '七月';

  @override
  String get monthAugust => '八月';

  @override
  String get monthSeptember => '九月';

  @override
  String get monthOctober => '十月';

  @override
  String get monthNovember => '十一月';

  @override
  String get monthDecember => '十二月';

  @override
  String get classAttendanceTitle => '考勤查询';

  @override
  String classAttendanceDetailTitle(String courseName) {
    return '签到信息 - $courseName';
  }

  @override
  String get classAttendanceNoData => '没有找到课程数据';

  @override
  String get classAttendanceNoAttendanceRecord => '没有签到记录';

  @override
  String get classAttendanceLongLoad => '考勤数据的加载时间约半分钟，请耐心等待';

  @override
  String get classAttendanceCourseStateUnknown => '未知';

  @override
  String get classAttendanceCourseStateIneligible => '取消';

  @override
  String get classAttendanceCourseStateEligible => '正常';

  @override
  String get classAttendanceCourseStateWarning => '危险';

  @override
  String get classAttendanceTableCourseName => '课程名称';

  @override
  String get classAttendanceTableStatus => '状态';

  @override
  String get classAttendanceTableAttendanceRate => '到课率';

  @override
  String get classAttendanceTableCheckIn => '签到';

  @override
  String get classAttendanceTableAbsence => '缺勤';

  @override
  String get classAttendanceTableRequired => '应签';

  @override
  String get classAttendanceTableLeave => '请假(事/病/公)';

  @override
  String get classAttendanceTableFilter => '筛选';

  @override
  String get classAttendanceTableFilterAll => '全部';

  @override
  String classAttendanceTableShowingCount(String count, String total) {
    return '显示 $count/$total 门课程';
  }

  @override
  String get classAttendanceCardTime => '签到次数';

  @override
  String classAttendanceCardTimeInfo(
    String checkInCount,
    String absenceCount,
    String requiredCheckIn,
  ) {
    return '$checkInCount 已签 / $absenceCount 缺勤 / $requiredCheckIn 应签';
  }

  @override
  String get classAttendanceCardNotAttend => '复活次数';

  @override
  String classAttendanceCardNotAttendInfo(
    String timeToHaveError,
    String totalTimes,
  ) {
    return '$timeToHaveError 次 / $totalTimes 总课程';
  }

  @override
  String get classAttendanceCardNotAttendInfoError => '无法对应已有课程';

  @override
  String get classAttendanceCardLeave => '请假次数';

  @override
  String classAttendanceCardLeaveInfo(
    String personalLeave,
    String sickLeave,
    String officialLeave,
  ) {
    return '事假 $personalLeave / 病假 $sickLeave / 公假 $officialLeave';
  }

  @override
  String get classAttendanceCardStudy => '学习进度';

  @override
  String classAttendanceCardStudyInfo(
    String taskProgress,
    String homeworkProgress,
    String examProgress,
  ) {
    return '任务点 $taskProgress / 作业 $homeworkProgress / 考试 $examProgress';
  }

  @override
  String get classAttendanceDetailCardCreatorName => '发起人';

  @override
  String get classAttendanceDetailCardStartTime => '开始时间';

  @override
  String get classAttendanceDetailCardSummitTime => '提交时间';

  @override
  String get classAttendanceSignTypeQrCode => '二维码签到';

  @override
  String get classAttendanceSignTypeGesture => '手势签到';

  @override
  String get classAttendanceSignTypePosition => '位置签到';

  @override
  String get classAttendanceSignTypeDefault => '普通签到';

  @override
  String get classAttendanceSignStatusAbsencenotparticipating => '缺勤未参与';

  @override
  String get classAttendanceSignStatusSigned => '已签';

  @override
  String get classAttendanceSignStatusSignedbyteacher => '代签';

  @override
  String get classAttendanceSignStatusPersonalleave2 => '请假';

  @override
  String get classAttendanceSignStatusAbsence => '缺勤';

  @override
  String get classAttendanceSignStatusSickleave => '病假';

  @override
  String get classAttendanceSignStatusPersonalleave => '事假';

  @override
  String get classAttendanceSignStatusLate => '迟到';

  @override
  String get classAttendanceSignStatusLeaveearly => '早退';

  @override
  String get classAttendanceSignStatusSignexpiredy => '签到已过期';

  @override
  String get classAttendanceSignStatusPublicleave => '公假';

  @override
  String get classtablePartnerClasstableOverrideDialog => '目前有搭子课表数据，是否要覆盖？';

  @override
  String get classtablePartnerClasstableNoFile => '未发现导入文件';

  @override
  String get classtablePartnerClasstableNoPermission => '未获取存储权限，无法读取文件';

  @override
  String get classtablePartnerClasstableProblem => '好像导入文件有点问题:P';

  @override
  String get classtablePartnerClasstableSuccess => '导入成功';

  @override
  String get classtablePartnerClasstableShareDialogTitle => '请不要随意分享';

  @override
  String get classtablePartnerClasstableShareDialogContent =>
      '导出文件包括你的个人信息，请不要随意跟别人分享，或者发在大群里。';

  @override
  String get classtablePartnerClasstableSaveDialogTitle => '保存日历文件到...';

  @override
  String get classtablePartnerClasstableSaveDialogSuccessMessage => '应该保存成功';

  @override
  String get classtablePartnerClasstableSaveDialogFailureMessage =>
      '文件创建失败，保存取消';

  @override
  String get classtablePartnerClasstableDeleteDialogTitle => '确认对话框';

  @override
  String get classtablePartnerClasstableDeleteDialogMessage => '确定要清除搭子课表吗？';

  @override
  String get classtablePartnerClasstableDeleteDialogSuccessMessage =>
      '删除搭子课表成功';

  @override
  String get classtablePartnerClasstableNameDialogTitle => '输入对方显示该课表的名称';

  @override
  String get classtablePartnerClasstableNameDialogHint => '在此输入，否则为 Sweetie';

  @override
  String get classtablePartnerClasstableNameDialogCancel => '我就这一个甜心';

  @override
  String get classtablePartnerClasstableNameDialogAccept => '提交';

  @override
  String get classtablePartnerClasstableNameDialogBlankInput => '输入空白!';

  @override
  String get classtablePageTitle => '我的日程表';

  @override
  String classtablePartnerPageTitle(String partner_name) {
    return '$partner_name的日程表';
  }

  @override
  String get classtablePopupMenuNotArranged => '查看未安排课程信息';

  @override
  String get classtablePopupMenuClassChanged => '查看课程安排调整信息';

  @override
  String get classtablePopupMenuAddClass => '添加课程信息';

  @override
  String get classtablePopupMenuGenerateIcal => '生成日历文件';

  @override
  String get classtablePopupMenuGeneratePartnerFile => '生成共享课表文件';

  @override
  String get classtablePopupMenuImportPartnerFile => '导入共享课表文件';

  @override
  String get classtablePopupMenuDeletePartnerFile => '删除共享课表文件';

  @override
  String get classtablePopupMenuOutputToSystem => '导出到系统日历';

  @override
  String get classtablePopupMenuRefreshClasstable => '刷新日程表';

  @override
  String get classtablePopupMenuSwitchSemester => '切换课程表学期';

  @override
  String get classtablePopupMenuCurrentTimeSettings => '时间指示设置';

  @override
  String get classtablePopupMenuClassColorSettings => '课表样式设置';

  @override
  String get classtableVisualSettingsCurrentTimeSettingsTitle => '时间指示设置';

  @override
  String get classtableVisualSettingsClassColorSettingsTitle => '课表样式设置';

  @override
  String get classtableVisualSettingsCompletedStyleEnabled => '已结束课程样式区分';

  @override
  String get classtableVisualSettingsCurrentTimeSection => '时间指示';

  @override
  String get classtableVisualSettingsShowCurrentTimeIndicator => '显示当前时间指示线';

  @override
  String get classtableVisualSettingsShowCurrentTimeLabel => '显示迷你数字时钟';

  @override
  String get classtableVisualSettingsShowTodayColumnHighlight => '强调显示今天的纵列';

  @override
  String get classtableVisualSettingsUnfinishedSection => '课程样式';

  @override
  String classtableVisualSettingsActiveBrightnessFactor(String value) {
    return '亮度: $value';
  }

  @override
  String classtableVisualSettingsActiveBorderAlpha(String value) {
    return '边框透明度: $value';
  }

  @override
  String classtableVisualSettingsActiveInnerAlpha(String value) {
    return '底色透明度: $value';
  }

  @override
  String get classtableVisualSettingsCompletedSection => '已结束课程样式';

  @override
  String classtableVisualSettingsCompletedSaturationFactor(String value) {
    return '底色饱和度: $value';
  }

  @override
  String classtableVisualSettingsCompletedBrightnessFactor(String value) {
    return '亮度: $value';
  }

  @override
  String classtableVisualSettingsCompletedTextSaturationFactor(String value) {
    return '文字饱和度: $value';
  }

  @override
  String classtableVisualSettingsCompletedBorderAlpha(String value) {
    return '边框透明度: $value';
  }

  @override
  String classtableVisualSettingsCompletedInnerAlpha(String value) {
    return '底色透明度: $value';
  }

  @override
  String get classtableStatusSourceClassTable => '课表';

  @override
  String get classtableStatusSourceExam => '考试';

  @override
  String get classtableStatusSourcePhysicsExperiment => '物理实验';

  @override
  String get classtableStatusSourceOtherExperiment => '其他实验';

  @override
  String get classtableErrorDialogTitle => '错误信息概览';

  @override
  String classtableStatusBannerLoading(String sources) {
    return '正在更新：$sources';
  }

  @override
  String classtableStatusBannerCache(String sources) {
    return '当前使用缓存：$sources';
  }

  @override
  String classtableStatusBannerErrorSummary(String sources) {
    return '以下信息加载失败：$sources';
  }

  @override
  String classtableEmptyStateNoCourse(String semester_code) {
    return '$semester_code 学期没有课程安排。';
  }

  @override
  String classtableEmptyStateWithExam(String semester_code) {
    return '$semester_code 学期没有课程安排，但有考试安排。';
  }

  @override
  String classtableEmptyStateWithExperiment(String semester_code) {
    return '$semester_code 学期没有课程安排，但有实验安排。';
  }

  @override
  String classtableEmptyStateWithExamAndExperiment(String semester_code) {
    return '$semester_code 学期没有课程安排，但有考试和实验安排。';
  }

  @override
  String get classtableEmptyActionViewExam => '查看考试安排';

  @override
  String get classtableEmptyActionViewExperiment => '查看实验安排';

  @override
  String get classtableClassChangePageTitle => '课程调整';

  @override
  String get classtableClassChangePageEmptyMessage => '目前没有调课信息';

  @override
  String classtableClassChangePageTeacherChange(
    String previous_teacher,
    String new_teacher,
  ) {
    return '教师变更：从$previous_teacher变为$new_teacher';
  }

  @override
  String get classtableClassChangePageNoTeacherChange => '教师信息没有改变';

  @override
  String get classtableClassChangePage1 => '一';

  @override
  String get classtableClassChangePage2 => '二';

  @override
  String get classtableClassChangePage3 => '三';

  @override
  String get classtableClassChangePage4 => '四';

  @override
  String get classtableClassChangePage5 => '五';

  @override
  String get classtableClassChangePage6 => '六';

  @override
  String get classtableClassChangePage7 => '日';

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
    return '调课信息，从第$originalAffectedWeeks周 星期$weekChar_originalWeek的$originalClassRangeStart-$originalClassRangeEnd节 调整为第$newAffectedWeeksListStr周星期$weekChar_newWeek的$newClassRangeStart-$newClassRangeStop节，$newClassroom教室上课';
  }

  @override
  String classtableClassChangePagePatchClassMessage(
    String newClassroom,
    String newClassRangeStart,
    String newClassRangeStop,
    String weekChar_newWeek,
    String newAffectedWeeksListStr,
  ) {
    return '补课信息，第$newAffectedWeeksListStr周 星期$weekChar_newWeek的$newClassRangeStart-$newClassRangeStop节， $newClassroom补课';
  }

  @override
  String classtableClassChangePageStopClassMessage(
    String originalClassRangeStart,
    String originalClassRangeEnd,
    String weekChar_originalWeek,
    String originalAffectedWeeks,
  ) {
    return '停课信息，第$originalAffectedWeeks周 星期$weekChar_originalWeek的$originalClassRangeStart-$originalClassRangeEnd节停课';
  }

  @override
  String classtableClassChangePageClassInfo(
    String classCode,
    String classNumber,
    String classChange,
    String teacherChange,
  ) {
    return '编号: $classCode | $classNumber 班\n安排变更：$classChange$teacherChange';
  }

  @override
  String get classtableNotArrangedPageTitle => '没有时间安排的科目';

  @override
  String get classtableNotArrangedPageEmptyMessage => '目前全部课程均有时间安排';

  @override
  String classtableNotArrangedPageContent(
    String classCode,
    String classNumber,
    String teacher,
  ) {
    return '编号: $classCode | $classNumber 班\n老师: $teacher';
  }

  @override
  String classtableEmptyClassMessage(String semester_code) {
    return '$semester_code 学期没有课程';
  }

  @override
  String classtableEmptyClassWithExam(String semester_code) {
    return '$semester_code 学期没有课程但是有考试安排！\n请回到主页后下滑点击”考试安排“按钮进入考试安排页面';
  }

  @override
  String classtableWeekTitle(String week) {
    return '第$week周';
  }

  @override
  String get classtableNoonBreak => '午休';

  @override
  String get classtableSupperBreak => '晚休';

  @override
  String classtableMonth(String month) {
    return '$month\n月';
  }

  @override
  String get classtableNoClass => '本周暂无安排，请不要在床上过于慵懒';

  @override
  String get classtableClassCardTitle => '日程信息';

  @override
  String get classtableClassCardUnknownClassroom => '未知教室';

  @override
  String classtableClassCardRemainsHint(String remain_count) {
    return '还有$remain_count个日程';
  }

  @override
  String get classtableClassAddAddClassTitle => '添加课程';

  @override
  String get classtableClassAddChangeClassTitle => '修改课程';

  @override
  String get classtableClassAddClassNameEmptyMessage => '必须输入课程名';

  @override
  String get classtableClassAddWrongTimeMessage => '输入的时间不对';

  @override
  String get classtableClassAddSaveButton => '保存';

  @override
  String get classtableClassAddInputClassnameHint => '课程名字(必填)';

  @override
  String get classtableClassAddInputTeacherHint => '老师姓名(选填)';

  @override
  String get classtableClassAddInputClassroomHint => '教室位置(选填)';

  @override
  String get classtableClassAddInputWeekHint => '选择上课周次';

  @override
  String get classtableClassAddInputTimeHint => '选择上课时间';

  @override
  String get classtableClassAddInputTimeWeekdayHint => '上课周次';

  @override
  String get classtableClassAddInputStartTimeHint => '上课时间';

  @override
  String get classtableClassAddInputEndTimeHint => '下课时间';

  @override
  String classtableClassAddWheelChooseHint(String index) {
    return '第 $index 节';
  }

  @override
  String get classtableClassAddChooseAtLeastOne => '请至少选择一个上课日期和时间';

  @override
  String get classtableClassAddRepeatWeekly => '按周重复';

  @override
  String get classtableClassAddFreeTime => '自定义日期';

  @override
  String get classtableClassAddDateSelectorFreeRule => '时间必须在 08:30-21:25 之间';

  @override
  String get classtableClassAddDateSelectorFreeRule2 => '下课时间必须晚于上课时间';

  @override
  String get classtableClassAddDateSelectorFreeClassStartTime => '上课时间';

  @override
  String get classtableClassAddDateSelectorFreeClassEndTime => '下课时间';

  @override
  String get classtableClassAddDateSelectorFreeEditClassTime => '编辑课程时间';

  @override
  String get classtableClassAddDateSelectorFreeChooseClassTime => '选择课程时间';

  @override
  String classtableCourseDetailCardClassNumberString(String number) {
    return '$number 班';
  }

  @override
  String get classtableCourseDetailCardUnknownTeacher => '老师未定';

  @override
  String get classtableCourseDetailCardUnknownPlace => '地点未定';

  @override
  String classtableCourseDetailCardClassPeriod(String start, String stop) {
    return '$start-$stop节';
  }

  @override
  String get classtableCourseDetailCardEdit => '编辑';

  @override
  String get classtableCourseDetailCardDelete => '删除';

  @override
  String get classtableCourseDetailCardDeleteSingle => '删除本次';

  @override
  String get classtableCourseDetailCardDeleteAll => '删除全部';

  @override
  String get classtableCourseDetailCardDeleteContent =>
      '所有关于这个课的信息都会被删除，课表上关于这门课的信息将不复存在！';

  @override
  String get classtableCourseDetailCardDeleteContentSingle =>
      '关于这个课的信息只有这个时间段都会被删除，其他的时间段会被保留。';

  @override
  String get classtableCourseDetailCardDeleteTitle => '是否删除课程信息？';

  @override
  String get classtableOutputToSystemSuccess => '成功导出到系统日历';

  @override
  String get classtableOutputToSystemFailure => '导出到系统日历过程中发生了问题:P';

  @override
  String get classtableOutputToSystemRequestAllTitle => '权限需求说明';

  @override
  String get classtableOutputToSystemRequestAll =>
      '因导出插件限制，用户必须同时授予本软件读取日历和写入日历权限，才能正常导出日程。不过，本软件不会读取日历。';

  @override
  String get classtableRefreshClasstableReady => '准备刷新日程信息';

  @override
  String get classtableRefreshClasstableSuccess => '成功刷新日程信息';

  @override
  String get classtableCacheHintPasswordWrong => '统一认证密码错误或已失效。';

  @override
  String get classtableCacheHintLoginFailed => '登录课表服务失败。';

  @override
  String get classtableCacheHintNetworkFailed => '课表网络请求失败。';

  @override
  String get classtableCacheHintUnknownError => '在线获取课表失败。详细错误请查看日志。';

  @override
  String get classtableSemesterSwitcherChooseSemester => '选择学期';

  @override
  String get classtableSemesterSwitcherFirstAcademicYear => '第一学年';

  @override
  String get classtableSemesterSwitcherSecondAcademicYear => '第二学年';

  @override
  String get classtableSemesterSwitcherFetchRemoteSemester => '获取当前学期';

  @override
  String get classtableSemesterSwitcherFetchingRemoteSemester => '正在获取...';

  @override
  String classtableSemesterSwitcherYear(String year) {
    return '$year年';
  }

  @override
  String get classtableSemesterSwitcherOnlyFutureHint => '本程序仅允许查看未来学期的课程安排。';

  @override
  String get clubPromotionTypeTech => '技术';

  @override
  String get clubPromotionTypeAcg => '晒你系';

  @override
  String get clubPromotionTypeUnion => '官方';

  @override
  String get clubPromotionTypeProfit => '商业';

  @override
  String get clubPromotionTypeSport => '体育';

  @override
  String get clubPromotionTypeArt => '文化';

  @override
  String get clubPromotionTypeUnknown => '未知';

  @override
  String get clubPromotionTypeGame => '游戏';

  @override
  String get clubPromotionTypeAll => '所有';

  @override
  String get clubPromotionWrongParam => '错误参数';

  @override
  String get clubPromotionNoGroupInfo => '未传入社团信息';

  @override
  String get clubPromotionLoading => '正在加载';

  @override
  String get clubPromotionErrorOutside => '在外围遇到错误';

  @override
  String get clubPromotionError => '遇到错误';

  @override
  String get clubPromotionQqCopied => 'QQ号已经复制到剪贴板';

  @override
  String get clubPromotionNoLink => '未提供入群链接';

  @override
  String get clubPromotionLoadingProblem => '加载遇到错误';

  @override
  String get clubPromotionPicturePreview => '图片预览';

  @override
  String get electricityTitle => '水电信息';

  @override
  String get electricityPowerTitle => '电量信息';

  @override
  String get electricityCacheHintLoginFailed => '登录电费服务失败，正在显示缓存数据。';

  @override
  String get electricityCacheHintNetworkFailed => '电费服务网络请求失败，正在显示缓存数据。';

  @override
  String get electricityCacheHintUnknownError => '在线获取电费失败，正在显示缓存数据。详细错误请查看日志。';

  @override
  String get electricityCacheNotice => '获取时间';

  @override
  String get electricityAccount => '电费账号';

  @override
  String get electricityRemainPower => '电量额度';

  @override
  String get electricityOweInfo => '欠费信息';

  @override
  String get electricityHistory => '历史记录';

  @override
  String get electricityDailyUsage => '平均每日用量';

  @override
  String get electricityNotEnoughData => '数据量不足以用于渲染';

  @override
  String get electricityInfo =>
      '新能源系统获取仅校园网内访问，获取过程中有问题请向开发者报告。\n历史记录依旧为本地记录，平均日用量基于抄表记录计算。';

  @override
  String get electricityFetchingHint => '正在获取最新电费信息';

  @override
  String get electricityFetchError => '电费信息获取失败，请重试。';

  @override
  String get electricityDate => '日期';

  @override
  String get electricityPower => '该日0点电量';

  @override
  String get electricityUpdate => '刷新信息';

  @override
  String get electricityWaterUsageFetchDate => '获取时间';

  @override
  String get electricityWaterUsageReadBefore => '上次读数';

  @override
  String get electricityWaterUsageReadNow => '本次读数';

  @override
  String get electricityWaterUsage => '洗澡水用量';

  @override
  String get electricityWaterTitle => '水费信息';

  @override
  String get electricityWaterLoading => '正在加载水费信息';

  @override
  String get electricityWaterUnavailable => '水费信息暂不可用，请在电费卡片重试。';

  @override
  String get electricityWaterEmpty => '暂无水费信息';

  @override
  String get electricityNotSchoolNetwork => '非校园网访问';

  @override
  String get electricityAirconTitle => '空调用电';

  @override
  String get electricityAirconImei => '空调 IMEI';

  @override
  String get electricityAirconAmount => '平台用电量';

  @override
  String get electricityAirconUpdateTime => '更新时间';

  @override
  String get electricityAirconWaiting => '等待获取空调用电信息';

  @override
  String get electricityAirconError => '空调用电获取失败';

  @override
  String get electricityAirconRetry => '重试';

  @override
  String get electricityAirconImeiMissing => '尚未添加空调 IMEI，添加后即可查看空调用电信息。';

  @override
  String get electricityAirconAddImei => '添加空调 IMEI';

  @override
  String electricityAirconCacheNotice(String time) {
    return '当前显示空调缓存数据，缓存时间：$time';
  }

  @override
  String get emptyClassroomTitle => '空闲教室';

  @override
  String emptyClassroomDate(String date) {
    return '日期 $date';
  }

  @override
  String emptyClassroomBuilding(String building) {
    return '教学楼 $building';
  }

  @override
  String get emptyClassroomSearchHint => '教室名称或者教室代码';

  @override
  String get emptyClassroomClassroom => '教室';

  @override
  String get emptyClassroomEmpty => '空闲';

  @override
  String get emptyClassroomOccupied => '占用';

  @override
  String get examTitle => '考试安排';

  @override
  String get examCacheHint => '已显示缓存考试安排信息';

  @override
  String get examCacheHintPasswordWrong => '统一认证密码错误或已失效';

  @override
  String get examCacheHintLoginFailed => '登录考试服务失败';

  @override
  String get examCacheHintNetworkFailed => '网络连接失败';

  @override
  String get examCacheHintUnknownError => '在线获取考试安排失败，详细错误请查看日志';

  @override
  String get examFetchingHint => '正在获取最新考试安排';

  @override
  String get examNotFinished => '未完成考试';

  @override
  String get examAllFinished => '所有考试全部完成';

  @override
  String get examUnableToExam => '无法完成考试';

  @override
  String get examFinished => '已完成考试';

  @override
  String get examNoneFinished => '一门还没考呢';

  @override
  String get examNoExamArrangement => '目前没有考试安排';

  @override
  String get examNoArrangementTitle => '目前无安排考试的科目';

  @override
  String get examNoArrangementAllArranged => '目前所有科目均已安排考试';

  @override
  String examNoArrangementSubtitle(String id) {
    return '编号: $id';
  }

  @override
  String get experimentTitle => '实验信息';

  @override
  String get experimentOngoing => '正在进行实验';

  @override
  String get experimentNotFinished => '未完成实验';

  @override
  String get experimentAllFinished => '所有实验全部完成';

  @override
  String get experimentFinished => '已完成实验';

  @override
  String experimentScoreInfo(String score) {
    return '$score (推测)';
  }

  @override
  String experimentScoreSum(String sum) {
    return '目前分数总和：$sum';
  }

  @override
  String get experimentNoneFinished => '目前没有已经完成的实验';

  @override
  String get experimentNotProvided => '未提供';

  @override
  String experimentErrorPhysics(String info) {
    return '获取物理实验信息时发生错误：$info';
  }

  @override
  String experimentErrorOther(String info) {
    return '获取其他实验信息时发生错误：$info';
  }

  @override
  String experimentCacheHint(String info) {
    return '目前加载缓存状况：$info';
  }

  @override
  String get experimentPhysicsCacheHintMissingPassword => '未填写物理实验密码。';

  @override
  String get experimentPhysicsCacheHintLoginFailed => '物理实验登录失败。';

  @override
  String get experimentPhysicsCacheHintNotSchoolNetwork => '当前不在校园网环境。';

  @override
  String get experimentPhysicsCacheHintNetworkFailed => '物理实验网络请求失败。';

  @override
  String get experimentPhysicsCacheHintUnknownError => '在线获取物理实验失败。详细错误请查看日志。';

  @override
  String get experimentOtherCacheHintLoginFailed => '其他实验登录失败。';

  @override
  String get experimentOtherCacheHintNotSchoolNetwork => '当前不在校园网环境。';

  @override
  String get experimentOtherCacheHintNetworkFailed => '其他实验网络请求失败。';

  @override
  String get experimentOtherCacheHintUnknownError => '在线获取其他实验失败。详细错误请查看日志。';

  @override
  String get experimentPhysicsExperiment => '物理实验';

  @override
  String get experimentOtherExperiment => '其他实验';

  @override
  String get experimentTapForScore => '成绩未识别出来';

  @override
  String get experimentYourScore => '您的分数：';

  @override
  String experimentPredictScore(String score) {
    return '推测分数：$score';
  }

  @override
  String get experimentSendMail => '发送邮件';

  @override
  String get experimentFetchingHint => '您现在看到的是缓存数据。正在后台获取更新数据中...';

  @override
  String get experimentFetchingHintBoth => '物理实验和其他实验正在加载';

  @override
  String get experimentFetchingHintPhysics => '物理实验正在加载';

  @override
  String get experimentFetchingHintOther => '其他实验正在加载';

  @override
  String get experimentFetchingHintPhysicsWithOtherFailed =>
      '物理实验正在加载，其他实验加载失败';

  @override
  String get experimentFetchingHintOtherWithPhysicsFailed =>
      '其他实验正在加载，物理实验加载失败';

  @override
  String get experimentScoreHint0 => '您可点击卡片上的成绩字段来查看原始成绩数据';

  @override
  String get experimentScoreHint1 => '您的分数不在 XDYou 分数识别库中，因此它没有被正常识别。';

  @override
  String get experimentScoreHint2 =>
      '如果您希望为 XDYou 的发展贡献一份自己的力量，您可以点击发送邮件按钮，我们将您的分数加入识别库！';

  @override
  String get experimentScoreHint3 => '目前识别库数据不全，请您务必核对一下。';

  @override
  String get homepageTitle => '校园信息查询';

  @override
  String get homepageLoading => '正在加载';

  @override
  String get homepageLoaded => '加载成功';

  @override
  String get homepageLoadError => '加载错误';

  @override
  String get homepageOnHoliday => '当前在假期中';

  @override
  String homepageOnWeekday(String current) {
    return '当前为第 $current 周';
  }

  @override
  String get homepageLoadingMessage => '请稍候，正在刷新信息';

  @override
  String get homepagePostgraduateNotice => '研究生功能已经激活！';

  @override
  String get homepageLinuxNotice => 'Linux 版本正在测试，欢迎反馈！';

  @override
  String get homepageEditMode => '编辑布局';

  @override
  String get homepageEditDone => '完成';

  @override
  String get homepageEditReset => '恢复默认布局';

  @override
  String get homepageEditHint => '日程信息和软件升级信息不允许编辑';

  @override
  String get homepageManageHidden => '管理隐藏卡片';

  @override
  String get homepageHiddenTitle => '已隐藏的卡片';

  @override
  String get homepageHiddenLabel => '已隐藏';

  @override
  String get homepageHideEmpty => '没有隐藏的卡片';

  @override
  String get homepageHomepage => '校园信息';

  @override
  String get homepageRuisi => '睿思论坛';

  @override
  String get homepageClub => '社团推荐';

  @override
  String get homepagePlanet => '博客星球';

  @override
  String get homepageDashboard => '猪图鉴赏';

  @override
  String get homepageSetting => '设置';

  @override
  String get homepageInputPartnerDataRouteNotExist => '导入路径不存在:P';

  @override
  String get homepageInputPartnerDataFailedGetFile => '导入文件失败';

  @override
  String get homepageInputPartnerDataFailedImport => '好像导入文件有点问题:P';

  @override
  String get homepageInputPartnerDataSuccessMessage => '导入成功，如果打开了课表页面请重新打开';

  @override
  String get homepageInputPartnerDataNotLoaded => '还没加载课程表，等会再来吧……';

  @override
  String get homepageInputPartnerDataConfirmContent => '目前有搭子课表数据，是否要覆盖？';

  @override
  String get homepageLoginMessage => '登录中，暂时显示缓存数据';

  @override
  String get homepageSuccessfulLoginMessage => '登录成功';

  @override
  String get homepagePasswordWrongTitle => '用户名或密码有误';

  @override
  String get homepagePasswordWrongContent => '是否重启应用后手动登录？';

  @override
  String get homepagePasswordWrongDenial => '否，进入离线模式';

  @override
  String get homepageOfflineModeTitle => '统一认证服务离线模式开启';

  @override
  String get homepageOfflineModeContent =>
      '无法连接到统一认证服务服务器，所有和其相关的服务暂时不可用。\n成绩查询，考试信息查询，欠费查询，校园卡查询关闭。课表显示缓存数据。其他功能暂不受影响。\n如有不便，敬请谅解。';

  @override
  String get homepageOfflineMode => '脱机模式下，一站式相关功能全部禁止使用';

  @override
  String get homepageNoticeCardEmptyNotice => '目前没有获取应用公告，请刷新';

  @override
  String get homepageNoticeCardNoNoticeAvaliable => '没有获取应用公告';

  @override
  String get homepageNoticeCardNoticeListTitle => '应用信息';

  @override
  String get homepageNoticeCardOpenUrl => '访问该链接';

  @override
  String get homepageNoticeCardNoticePageTitle => '通知列表';

  @override
  String get homepageClassTableCardTitle => '课程表';

  @override
  String homepageClassTableCardToday(String remain) {
    return '今日还有 $remain 个日程';
  }

  @override
  String get homepageClassTableCardTodayFinished => '今日安排完成';

  @override
  String homepageClassTableCardTomorrow(String remain) {
    return '明日有 $remain 个安排';
  }

  @override
  String get homepageClassTableCardTomorrowNone => '明日没有安排';

  @override
  String homepageClassTableCardWeekInfo(String weekinfo) {
    return '第 $weekinfo 周';
  }

  @override
  String get homepageClassTableCardOnHoliday => '假期中';

  @override
  String homepageClassTableCardErrorMessage(String error) {
    return '遇到错误：$error';
  }

  @override
  String get homepageClassTableCardFetchingMessage => '正在获取课表';

  @override
  String get homepageClassTableCardErrorInfotext => '遇到错误';

  @override
  String get homepageClassTableCardFetchingInfotext => '正在加载';

  @override
  String get homepageClassTableCardNoArrangementInfotext => '暂无日程';

  @override
  String get homepageClassTableCardScheduleFetchingMessage => '日程正在加载，请稍后查看';

  @override
  String get homepageClassTableCardScheduleErrorMessage => '日程加载失败，请稍后重试';

  @override
  String get homepageClassTableCardScheduleFetchingInfotext => '正在加载日程';

  @override
  String get homepageClassTableCardScheduleErrorInfotext => '日程加载失败';

  @override
  String get homepageClassTableCardScheduleNoneInfotext => '暂无日程';

  @override
  String get homepageClassTableCardUpdatingInfotext => '正在更新';

  @override
  String get homepageClassTableCardAllLoadingInfotext => '全部加载中';

  @override
  String get homepageClassTableCardPartialLoadingInfotext => '部分加载中';

  @override
  String get homepageClassTableCardPartialErrorInfotext => '部分数据加载失败';

  @override
  String homepageClassTableCardFailedChip(String source) {
    return '$source加载失败';
  }

  @override
  String get homepageClassTableCardFailedSourceClassInfo => '课程信息';

  @override
  String get homepageClassTableCardFailedSourceExamInfo => '考试信息';

  @override
  String get homepageClassTableCardFailedSourcePhysicsExperiment => '物理实验';

  @override
  String get homepageClassTableCardFailedSourceOtherExperiment => '其他实验';

  @override
  String get homepageClassTableCardUnknownPlace => '未知位置';

  @override
  String homepageClassTableCardSeat(String seatnum) {
    return '座位号$seatnum';
  }

  @override
  String get homepageElectricityCardTitle => '水电信息';

  @override
  String homepageElectricityCardCurrentElectricity(String amount) {
    return '余额 $amount 度';
  }

  @override
  String homepageElectricityCardCacheNotice(String date) {
    return '最后一次读表：$date';
  }

  @override
  String get homepageLibraryCardTitle => '图书借阅';

  @override
  String homepageLibraryCardCurrentBorrow(String count) {
    return '借书 $count 本';
  }

  @override
  String get homepageLibraryCardErrorOccured => '获取借书信息发生错误';

  @override
  String get homepageLibraryCardFetching => '正在获取借书信息';

  @override
  String get homepageLibraryCardNoReturn => '目前没有待归还书籍';

  @override
  String homepageLibraryCardNeedReturn(String dued) {
    return '待归还 $dued 本书籍';
  }

  @override
  String get homepageLibraryCardNoInfo => '目前无法获取信息';

  @override
  String get homepageLibraryCardFetchingInfo => '正在查询信息中';

  @override
  String get homepageSchoolCardInfoCardErrorToast => '遇到错误，请联系开发者';

  @override
  String get homepageSchoolCardInfoCardFetchingToast => '正在获取信息，请稍后再来看';

  @override
  String get homepageSchoolCardInfoCardBill => '流水';

  @override
  String homepageSchoolCardInfoCardBalance(String amount) {
    return '卡里 $amount 元';
  }

  @override
  String get homepageSchoolCardInfoCardErrorOccured => '获取校园卡信息发生错误';

  @override
  String get homepageSchoolCardInfoCardFetching => '正在获取校园卡信息';

  @override
  String get homepageSchoolCardInfoCardBottomTextSuccess => '查询一卡通流水';

  @override
  String get homepageSchoolCardInfoCardNoInfo => '目前无法获取信息';

  @override
  String get homepageSchoolCardInfoCardFetchingInfo => '正在查询信息中';

  @override
  String get homepageToolboxClassAttendance => '考勤查询';

  @override
  String get homepageToolboxCreative => '双创竞赛';

  @override
  String get homepageToolboxEmptyClassroom => '空闲教室';

  @override
  String get homepageToolboxExam => '考试安排';

  @override
  String get homepageToolboxExperiment => '实验信息';

  @override
  String get homepageToolboxScore => '成绩查询';

  @override
  String get homepageToolboxSport => '体育信息';

  @override
  String get homepageToolboxDormWater => '宿舍水机';

  @override
  String get homepageToolboxSchoolnet => '网络查询';

  @override
  String get homepageToolboxToolbox => '其他功能';

  @override
  String get homepageToolboxScoreCannotReach => '脱机状态且无缓存成绩数据，无法访问';

  @override
  String get homepageToolboxExamFetching => '请稍候，正在获取考试信息';

  @override
  String get homepageToolboxExamError => '遇到错误，请联系开发者';

  @override
  String homepageSchoolNetTitle(String usage) {
    return '已用 $usage';
  }

  @override
  String get homepageSchoolNetNoPassword => '无校园网密码，点击设置';

  @override
  String get homepageSchoolNetFailed => '获取校园网流量信息失败';

  @override
  String get homepageSchoolNetFetching => '正在获取校园网流量信息';

  @override
  String homepageSchoolNetRemaining(String remaining) {
    return '下次结算 $remaining';
  }

  @override
  String get homepageClubPromotionFailed => '社团信息获取失败';

  @override
  String get homepageClubPromotionFetching => '社团信息清单正在加载';

  @override
  String get dormWaterTitle => '宿舍水机';

  @override
  String get dormWaterPhone => '手机号';

  @override
  String get dormWaterImageCode => '图形验证码';

  @override
  String get dormWaterSmsCode => '短信验证码';

  @override
  String get dormWaterSendSms => '发送短信码';

  @override
  String get dormWaterLogin => '登录';

  @override
  String get dormWaterLogout => '退出';

  @override
  String get dormWaterRefreshCaptcha => '刷新验证码';

  @override
  String get dormWaterLoadingCaptcha => '加载中...';

  @override
  String get dormWaterCaptchaError => '验证码加载失败';

  @override
  String get dormWaterPhoneRequired => '请输入手机号';

  @override
  String get dormWaterImageCodeRequired => '请输入图形验证码';

  @override
  String get dormWaterSmsSent => '短信已发送';

  @override
  String get dormWaterSmsFailed => '发送短信失败';

  @override
  String get dormWaterSmsCodeRequired => '请输入短信验证码';

  @override
  String get dormWaterLoginSuccess => '登录成功';

  @override
  String get dormWaterLoginFailed => '登录失败';

  @override
  String get dormWaterLogoutSuccess => '退出成功';

  @override
  String get dormWaterDevices => '设备列表';

  @override
  String get dormWaterLoadingDevices => '加载设备中...';

  @override
  String get dormWaterNoDevices => '暂无设备';

  @override
  String get dormWaterSelectDevice => '选择设备';

  @override
  String get dormWaterFetchDevicesFailed => '获取设备列表失败';

  @override
  String get dormWaterRetryLoadDevices => '重试加载';

  @override
  String get dormWaterStartWater => '开始接水';

  @override
  String get dormWaterEndWater => '结束接水';

  @override
  String get dormWaterWaterDispensing => '接水中';

  @override
  String get dormWaterWaterStatus => '接水状态';

  @override
  String get dormWaterStartWaterSuccess => '开始接水成功';

  @override
  String get dormWaterEndWaterSuccess => '结束接水成功';

  @override
  String get dormWaterStartWaterFailed => '开始接水失败';

  @override
  String get dormWaterEndWaterFailed => '结束接水失败';

  @override
  String get dormWaterDeviceStatusChecking => '检查设备状态中...';

  @override
  String get dormWaterDeviceStatusReady => '设备已就绪';

  @override
  String get dormWaterScanQrCode => '扫描二维码';

  @override
  String get dormWaterDeviceId => '设备 ID';

  @override
  String get dormWaterAddDeviceFailed => '添加设备失败';

  @override
  String get dormWaterDeviceRemovedFromFavorites => '已从收藏中移除';

  @override
  String get dormWaterRemoveFromFavoritesFailed => '移除收藏失败';

  @override
  String get libraryTitle => '图书馆信息';

  @override
  String get libraryBorrowStateTitle => '借书状态';

  @override
  String get librarySearchBookTitle => '查询藏书';

  @override
  String get librarySearchFieldTitle => '搜索字段';

  @override
  String get librarySearchFieldKeywordOption => '任意词';

  @override
  String get librarySearchFieldTitleOption => '标题';

  @override
  String get librarySearchFieldAuthorOption => '责任者';

  @override
  String get librarySearchFieldIsbnOption => 'ISBN';

  @override
  String get librarySearchFieldBarcodeOption => '条码号';

  @override
  String get librarySearchFieldCallnoOption => '索书号';

  @override
  String get libraryNotProvided => '未提供相关信息';

  @override
  String get libraryAuthor => '作者 ';

  @override
  String get libraryPublishHouse => '出版社 ';

  @override
  String get libraryCallNumber => '索书号 ';

  @override
  String get libraryPublishDate => '发行时间 ';

  @override
  String get libraryIsbn => 'ISBN';

  @override
  String get libraryArrangementCode => '编排号码 ';

  @override
  String get libraryAvaliableBorrow => '可借';

  @override
  String get libraryStorage => '馆藏';

  @override
  String get libraryOnShelve => '在架';

  @override
  String libraryBookCode(String barCode) {
    return '书籍编号：$barCode';
  }

  @override
  String get libraryDueDate => ' 到期';

  @override
  String get libraryBorrowStr => ' 借阅';

  @override
  String get libraryAfterDueDate => ' 天前到期';

  @override
  String get libraryBeforeDueDate => ' 天后';

  @override
  String get libraryCanBeRenewable => '续借';

  @override
  String get libraryCannotBeRenewable => '不可续借';

  @override
  String get libraryRenewing => '正在续借';

  @override
  String get libraryEmptyBorrowList => '目前没有查询到在借图书\n不借书就要变成上面的小呆瓜咯';

  @override
  String libraryBorrowListInfo(String borrow, String dued) {
    return '在借 $borrow 本，其中已过期 $dued 本';
  }

  @override
  String get librarySearchHere => '在此搜索';

  @override
  String get libraryNormalSearch => '普通搜索';

  @override
  String get libraryAdvancedSearch => '高级搜索';

  @override
  String get librarySearch => '搜索';

  @override
  String get libraryMatchMode => '匹配方式';

  @override
  String get libraryMatchExact => '精确匹配';

  @override
  String get libraryMatchFuzzy => '模糊匹配';

  @override
  String get libraryMatchPrefix => '前方一致';

  @override
  String get libraryDocumentType => '文献类型';

  @override
  String get libraryDocumentTypeAll => '全部';

  @override
  String get libraryDocumentTypeBook => '图书';

  @override
  String get libraryOnlyOnShelf => '仅看在架';

  @override
  String get libraryPublishYearBegin => '出版年起';

  @override
  String get libraryPublishYearEnd => '出版年止';

  @override
  String get libraryBookDetail => '书籍详细信息';

  @override
  String get libraryNoResult => '没有结果，请修改搜索参数或者开始你的搜索';

  @override
  String get libraryCardTitle => '图书馆当前状况';

  @override
  String get libraryCardFetching => '正在获取图书馆信息';

  @override
  String get libraryCardNorthernLibrary => '北校区状况';

  @override
  String get libraryCardSouthernLibrary => '南校区状况';

  @override
  String libraryCardPeople(String people) {
    return '在馆 $people 人';
  }

  @override
  String libraryCardSeat(String seat) {
    return '空位 $seat 个';
  }

  @override
  String get loginIdentityNumber => '学号';

  @override
  String get loginPassword => '一站式登录密码';

  @override
  String get loginLogin => '登录';

  @override
  String get loginIncorrectPasswordPattern => '用户名或密码不符合要求，学号必须 11 位且密码非空';

  @override
  String get loginOnLoginProgress => '正在登录学校一站式';

  @override
  String get loginCompleteLogin => '登录成功';

  @override
  String get loginFailedLoginCannotConnectToServer => '无法连接到服务器';

  @override
  String loginFailedLoginWithCode(String code) {
    return '请求失败，响应状态码：$code';
  }

  @override
  String loginFailedLoginWithMessage(String message) {
    return '请求失败，报错信息：$message';
  }

  @override
  String get loginFailedLoginOther => '未知错误，请联系开发者';

  @override
  String get loginClearCache => '清除登录缓存';

  @override
  String get loginCompleteClearCache => '清理缓存成功';

  @override
  String get loginSeeInspector => '查看网络交互';

  @override
  String get loginCaptchaWindowTitle => '请输入验证码';

  @override
  String get loginCaptchaWindowHint => '输入验证码';

  @override
  String get loginCaptchaWindowMessageOnEmpty => '请输入验证码';

  @override
  String loginCaptchaWindowRefreshFailed(String error) {
    return '刷新验证码失败: $error';
  }

  @override
  String get loginSliderTitle => '服务器认证服务';

  @override
  String get schoolNetTitle => '校园网使用详情';

  @override
  String get schoolNetIdsAccountNetTitle => '当前用户';

  @override
  String get schoolNetIdsAccountNetNotice =>
      '这是登录到 PDA 账户的校园网信息\n注意: 流量计费采用GB单位（1000进制）\n如果没有看到信息，请访问 zfw.xidian.edu.cn 重置网络密码';

  @override
  String get schoolNetIdsAccountNetOverview => '账户概览';

  @override
  String get schoolNetIdsAccountNetAccount => '账号';

  @override
  String get schoolNetIdsAccountNetUsed => '已使用流量';

  @override
  String get schoolNetIdsAccountNetRemain => '余额';

  @override
  String schoolNetIdsAccountNetCurrentOnline(String length) {
    return '在线设备（$length台）';
  }

  @override
  String get schoolNetIdsAccountNetNoDeviceOnline => '当前没有在线设备';

  @override
  String get schoolNetCurrentLoginNetTitle => '正在使用';

  @override
  String get schoolNetCurrentLoginNetNotice =>
      '这是您正在使用中校园网的信息，可能和您登录 PDA 的信息不一致\n注意: 流量计费采用GB单位（1000进制）';

  @override
  String get schoolNetCurrentLoginNetOverview => '账户概览';

  @override
  String get schoolNetCurrentLoginNetAccount => '账号';

  @override
  String get schoolNetCurrentLoginNetPlanType => '套餐类型';

  @override
  String get schoolNetCurrentLoginNetRemain => '余额';

  @override
  String get schoolNetCurrentLoginNetUsageSituation => '流量使用情况';

  @override
  String schoolNetCurrentLoginNetUsedPercent(String percent) {
    return '已使用 $percent%';
  }

  @override
  String get schoolNetCurrentLoginNetUsed => '已使用流量';

  @override
  String get schoolNetCurrentLoginNetRemainCount => '剩余流量';

  @override
  String get schoolNetCurrentLoginNetTotal => '总流量';

  @override
  String get schoolNetCurrentLoginNetNonSchoolnet => '非校园网';

  @override
  String get schoolNetDeviceListIp => '在线设备IP';

  @override
  String get schoolNetDeviceListTime => '上线时间';

  @override
  String get schoolNetDeviceListRemain => '流量用量';

  @override
  String get schoolNetFetching => '正在获取校园网信息';

  @override
  String get schoolNetEmptyPassword => '您忘记输入账号密码了';

  @override
  String get schoolNetNotInitalized => '疑似查询后端尚未开放查询';

  @override
  String get schoolNetCaptchaFailed => '验证码识别失败';

  @override
  String get schoolNetCaptchaEmpty => '验证码为空';

  @override
  String get schoolNetCacheHintCaptchaFailed => '验证码识别失败，请重试。';

  @override
  String get schoolNetCacheHintRequestFailed => '校园网请求失败，请稍后重试。';

  @override
  String get schoolNetWrongPassword => '密码错误';

  @override
  String schoolNetErrorFetch(String msg) {
    return '获取失败：$msg';
  }

  @override
  String schoolNetErrorOther(String msg) {
    return '其他错误：$msg';
  }

  @override
  String get schoolNetRefresh => '刷新';

  @override
  String get schoolCardWindowTitle => '校园卡流水信息';

  @override
  String schoolCardWindowIncome(String income) {
    return '收入 $income';
  }

  @override
  String schoolCardWindowExpense(String expense) {
    return '支出 $expense';
  }

  @override
  String schoolCardWindowSelectRange(String startDay, String endDay) {
    return '选择日期：从 $startDay 到 $endDay';
  }

  @override
  String get schoolCardWindowStoreName => '商户名称';

  @override
  String get schoolCardWindowBalance => '金额';

  @override
  String schoolCardWindowTimeWithSum(String sum) {
    return '时间(共$sum元)';
  }

  @override
  String get schoolCardWindowNoRecord => '未查询到记录，请修改日期后重试';

  @override
  String get schoolCardWindowQrCode => '支付码';

  @override
  String schoolCardWindowQrCodeError(String info) {
    return '二维码获取失败：$info';
  }

  @override
  String get schoolCardWindowReload => '重新加载';

  @override
  String get scoreCacheMessage => '已显示缓存成绩信息';

  @override
  String scoreSummary(String chosen, String credit, String avg, String gpa) {
    return '目前选中科目 $chosen  总计学分 $credit\n均分 $avg GPA $gpa';
  }

  @override
  String get scoreAllPassed => '所有科目均已通过';

  @override
  String get scoreCacheHintPasswordWrong => '统一认证密码错误或已失效';

  @override
  String get scoreCacheHintLoginFailed => '登录考试服务失败';

  @override
  String get scoreCacheHintNetworkFailed => '网络连接失败';

  @override
  String get scoreCacheHintUnknownError => '在线获取成绩安排失败，详细错误请查看日志';

  @override
  String get scoreFetchingHint => '正在获取最新成绩信息，请不要退出页面';

  @override
  String get scoreAllSemester => '所有学期';

  @override
  String scoreChosenSemester(String chosen) {
    return '学期 $chosen';
  }

  @override
  String get scoreAllType => '所有类型';

  @override
  String scoreChosenType(String type) {
    return '类型 $type';
  }

  @override
  String get scoreNone => '暂无';

  @override
  String get scoreScoreChoiceTitle => '成绩单';

  @override
  String get scoreScoreChoiceSearchHint => '搜索成绩记录';

  @override
  String get scoreScoreChoiceEmptyList => '没有选择该学期的课程计入均分计算';

  @override
  String get scoreScoreChoiceSumDialogTitle => '小总结';

  @override
  String scoreScoreChoiceSumDialogContent(
    String gpa_all,
    String avg_all,
    String credit_all,
    String unpassed,
    String not_core_type,
  ) {
    return '所有科目的GPA：$gpa_all\n所有科目的均分：$avg_all\n所有科目的学分：$credit_all\n未通过科目：$unpassed\n公共选修课：$not_core_type\n本程序提供的数据仅供参考，开发者对其准确性不负责';
  }

  @override
  String get scoreScoreComposeCardNoDetail => '未提供详情信息';

  @override
  String get scoreScoreComposeCardFetching => '正在获取';

  @override
  String get scoreScoreComposeCardCredit => '学分';

  @override
  String get scoreScoreComposeCardGpa => 'GPA';

  @override
  String get scoreScoreComposeCardScore => '成绩';

  @override
  String get scoreScoreInfoCardTitle => '成绩详情';

  @override
  String get scoreScoreInfoCardOriginalCourse => '初修';

  @override
  String get scoreScoreInfoCardFailed => '[挂] ';

  @override
  String scoreScoreInfoCardCredit(String credit) {
    return '学分 $credit';
  }

  @override
  String scoreScoreInfoCardGpa(String gpa) {
    return 'GPA $gpa';
  }

  @override
  String scoreScoreInfoCardScore(String score) {
    return '成绩 $score';
  }

  @override
  String get scoreScorePageTitle => '成绩查询';

  @override
  String get scoreScorePageSearchHint => '搜索成绩记录';

  @override
  String get scoreScorePageNoRecord => '未筛查到合请求的记录';

  @override
  String get scoreScorePageSelectAll => '全选';

  @override
  String get scoreScorePageSelectNothing => '全不选';

  @override
  String get scoreScorePageResetSelect => '重置选择';

  @override
  String get scoreScorePageSummary => '总结';

  @override
  String get scoreScorePageCet4 => '国家英语四级';

  @override
  String get scoreScorePageCet6 => '国家英语六级';

  @override
  String settingAcknowledgement(String developers) {
    return 'Made With Love From $developers People';
  }

  @override
  String get settingAbout => '关于';

  @override
  String get settingAboutThisProgram => '关于本程序';

  @override
  String settingVersion(String version) {
    return '版本号：$version';
  }

  @override
  String get settingUserInfo => '用户信息';

  @override
  String get settingCheckUpdate => '检查软件更新';

  @override
  String settingLatestVersion(String latest) {
    return '最新版本: $latest';
  }

  @override
  String get settingWaiting => '等待获取';

  @override
  String get settingFetchingUpdate => '正在获取更新信息';

  @override
  String get settingNewVersion => '有新版本发布！';

  @override
  String get settingCurrentStable => '目前您正在运行最新版';

  @override
  String get settingCurrentTesting => '目前您正在运行测试版';

  @override
  String get settingFetchFailed => '获取更新信息失败';

  @override
  String get settingUiSetting => '界面设置';

  @override
  String get settingBrightnessSetting => '设置深浅色';

  @override
  String get settingColorSetting => '颜色设置';

  @override
  String get settingSimplifyTimeline => '简化日程时间轴';

  @override
  String get settingSimplifyTimelineDescription => '没有日程时 减少空间占用';

  @override
  String get settingLowElectricityWarning => '低电量卡片变色提醒';

  @override
  String get settingLowElectricityWarningDescription => '电量小于阈值时 电量卡片变色提醒';

  @override
  String get settingLowElectricityThreshold => '低电量阈值';

  @override
  String settingLowElectricityThresholdDescription(String threshold) {
    return '当前为 $threshold 度';
  }

  @override
  String get settingLowElectricityThresholdDialogTitle => '设置低电量阈值';

  @override
  String get settingLowElectricityThresholdDialogInputHint => '请输入电量度数';

  @override
  String get settingAccountSetting => '账号设置';

  @override
  String get settingSportPasswordSetting => '体育系统密码设置';

  @override
  String get settingExperimentPasswordSetting => '物理实验系统密码设置';

  @override
  String get settingElectricityPasswordSetting => '电费帐号密码设置';

  @override
  String get settingElectricityPasswordDescription => '非 123456 请设置';

  @override
  String get settingElectricityAccountSetting => '电费账号设置';

  @override
  String get settingSchoolnetPasswordSetting => '校园网帐号密码设置';

  @override
  String get settingSchoolnetPasswordDescription => '不设置查看不了网费';

  @override
  String get settingAirconImeiTitle => '空调用电数据源';

  @override
  String get settingAirconImei => '空调 IMEI';

  @override
  String get settingAirconImeiNotSet => '未设置，电费页不显示空调用电';

  @override
  String settingAirconImeiCurrent(String imei) {
    return '当前 IMEI：$imei';
  }

  @override
  String get settingAirconImeiSaved => '空调 IMEI 已保存';

  @override
  String get settingAirconImeiCleared => '空调 IMEI 已清除';

  @override
  String get settingAirconImeiInvalid => '没有识别到有效的 15 位 IMEI';

  @override
  String get settingAirconImeiClear => '清除';

  @override
  String get settingScanAirconQr => '扫描空调二维码';

  @override
  String get settingPickAirconQrImage => '从相册选择二维码图片';

  @override
  String get settingAirconCameraUnavailable => '当前平台不支持相机扫码，请选择二维码图片或手动输入 IMEI';

  @override
  String get settingNotificationSetting => '通知设置';

  @override
  String get settingCourseReminderSetting => '课前通知设置';

  @override
  String get settingCourseReminderDescription => '设置课前提醒通知';

  @override
  String get settingNotificationPageTitle => '课前通知设置';

  @override
  String settingNotificationPageLoadFailed(String error) {
    return '加载设置失败: $error';
  }

  @override
  String get settingNotificationPageFunctionSection => '通知功能';

  @override
  String get settingNotificationPageEnableNotification => '启用课前通知';

  @override
  String settingNotificationPageNotificationScheduled(String count) {
    return '已安排 $count 个通知';
  }

  @override
  String get settingNotificationPageNotificationDisabledHint =>
      '关闭后将取消所有已安排的通知';

  @override
  String get settingNotificationPageUpdateSchedule => '更新通知日程';

  @override
  String get settingNotificationPageUpdateScheduleHint => '根据最新的课程数据重新安排通知';

  @override
  String get settingNotificationPageDeleteAllSchedule => '删除通知日程';

  @override
  String get settingNotificationPageDeleteAllScheduleHint =>
      '这个操作会删除所有已经安排的日程，但是您可以再次点击更新通知日程来重新添加';

  @override
  String get settingNotificationPageDeleteAllSuccess => '删除操作成功';

  @override
  String get settingNotificationPageViewTheInstructions => '查看使用说明';

  @override
  String get settingNotificationPageViewTheInstructionsHint =>
      '查看更多使用说明确保您能看到程序发出的通知';

  @override
  String get settingNotificationPagePermissionSection => '权限状态';

  @override
  String get settingNotificationPageNotificationPermission => '通知权限';

  @override
  String get settingNotificationPageExactAlarmPermission => '精确时钟权限';

  @override
  String get settingNotificationPagePermissionGranted => '已授予';

  @override
  String get settingNotificationPagePermissionDenied => '未授予';

  @override
  String get settingNotificationPageRequestPermission => '请求权限';

  @override
  String get settingNotificationPageSystemSettings => '系统通知设置';

  @override
  String get settingNotificationPageSystemSettingsHint => '打开系统设置检查通知配置';

  @override
  String get settingNotificationPagePermissionGrantedMsg => '权限已授予';

  @override
  String get settingNotificationPagePermissionDeniedMsg => '权限被拒绝，请在系统设置中开启';

  @override
  String get settingNotificationPageReminderSection => '提醒设置';

  @override
  String get settingNotificationPageExperimentReminder => '将物理实验加入课程提醒';

  @override
  String get settingNotificationPageExperimentReminderHint =>
      '将物理实验的时间安排一并加入课前提醒系统';

  @override
  String get settingNotificationPageMinutesBefore => '提前提醒时间';

  @override
  String get settingNotificationPageMinutesBeforeHint => '课前提前提醒的时间设置';

  @override
  String get settingNotificationPageMinutesUnit => '分钟';

  @override
  String get settingNotificationPageDaysToSchedule => '计划通知天数';

  @override
  String get settingNotificationPageDaysToScheduleHint =>
      '本程序是提前将课程信息写入计划日程，该设置可调整写入计划日程的天数';

  @override
  String get settingNotificationPageDaysUnit => '天';

  @override
  String get settingNotificationPageSettingsGuideTitle => '通知设置提示';

  @override
  String get settingNotificationPageSettingsGuideContent1 =>
      '为了确保您能及时收到课前提醒，请确保：\n1. 开启了应用的通知权限\n2. 开启了通知的声音提示\n3. 开启了悬浮通知（横幅通知）\n4. 非原生安卓用户，开启自启动和关闭电源优化';

  @override
  String get settingNotificationPageSettingsGuideContent2 =>
      '课前提醒模块运行机制：\n1. 首次开启时自动安排未来几天的课前提醒\n2. 每次打开应用时自动检查并更新通知日程\n3. 修改设置后自动重新安排所有通知';

  @override
  String get settingNotificationPageGotIt => '知道了';

  @override
  String get settingNotificationPageOpenSettings => '打开系统设置';

  @override
  String get settingNotificationPageNoClasstableData => '请先获取课程表、考试或实验数据';

  @override
  String settingNotificationPageScheduleSuccess(String count) {
    return '已安排 $count 个课前提醒';
  }

  @override
  String settingNotificationPageScheduleFailed(String error) {
    return '安排通知失败: $error';
  }

  @override
  String get settingNotificationPageCancelAllSuccess => '已取消所有课前提醒';

  @override
  String settingNotificationPageRescheduleSuccess(String count) {
    return '已重新安排 $count 个课前提醒';
  }

  @override
  String settingNotificationPageRescheduleFailed(String error) {
    return '重新安排通知失败: $error';
  }

  @override
  String get settingNotificationDebugPage => '通知服务调试页面';

  @override
  String get settingClasstableSetting => '课表相关设置';

  @override
  String get settingBackground => '开启课表背景图';

  @override
  String get settingNoBackground => '你先选个图片罢，就在下面';

  @override
  String get settingChooseBackground => '课表背景图选择';

  @override
  String get settingNoPermission => '未获取存储权限，无法读取文件';

  @override
  String get settingSuccessfulSetting => '设定成功';

  @override
  String get settingFailureSetting => '你没有选图片捏';

  @override
  String get settingClearUserClass => '清除所有用户添加课程';

  @override
  String get settingClearUserClassTitle => '确认对话框';

  @override
  String get settingClearUserClassContent => '是否要清除所有用户添加课程？这个功能对从学校获取的日程没有影响。';

  @override
  String get settingClearUserClassClear => '已经清除完毕';

  @override
  String get settingClassRefresh => '强制刷新课表';

  @override
  String get settingClassRefreshTitle => '确认对话框';

  @override
  String get settingClassRefreshContent =>
      '是否要强制刷新课表？同意后，将会从学校一站式后端重新获取课表，耗时会比较久。';

  @override
  String get settingClassSwift => '课程偏移设置';

  @override
  String settingClassSwiftDescription(String swift) {
    return '正数错后开学日期 负数提前开学日期\n目前为 $swift';
  }

  @override
  String get settingCoreSetting => '缓存登录设置';

  @override
  String get settingCheckLogger => '查看网络拦截器和日志';

  @override
  String get settingClearAndRestart => '清除缓存后重启';

  @override
  String get settingClearAndRestartDialogTitle => '确认对话框';

  @override
  String get settingClearAndRestartDialogContent => '确定清除缓存后重启程序？';

  @override
  String get settingClearAndRestartDialogCleaning => '正在清理缓存';

  @override
  String get settingClearAndRestartDialogClear => '缓存已被清除';

  @override
  String get settingLogout => '退出登录并重启应用';

  @override
  String get settingLogoutDialogTitle => '确认对话框';

  @override
  String get settingLogoutDialogContent => '确定退出登录？你的所有数据将会被彻底删除！';

  @override
  String get settingLogoutDialogLoggingOut => '正在退出登录';

  @override
  String get settingNeedCloseDialogTitle => '请关闭应用';

  @override
  String get settingNeedCloseDialogContent => '因为技术限制，用户需要自行关闭窗口，然后重新打开应用。';

  @override
  String get settingChangeColorDialogTitle => '颜色设置';

  @override
  String get settingChangeColorDialogDefault => '默认颜色';

  @override
  String get settingChangeColorDialogBlue => '聪明蓝';

  @override
  String get settingChangeColorDialogDeeppurple => '基佬紫';

  @override
  String get settingChangeColorDialogGreen => '春风绿';

  @override
  String get settingChangeColorDialogOrange => '明日香橙';

  @override
  String get settingChangeColorDialogPink => '樱花粉';

  @override
  String get settingChangeBrightnessDialogTitle => '亮度设置';

  @override
  String get settingChangeBrightnessDialogFollowSetting => '跟随系统';

  @override
  String get settingChangeBrightnessDialogDayMode => '白天模式';

  @override
  String get settingChangeBrightnessDialogNightMode => '黑夜模式';

  @override
  String get settingChangeSwiftDialogTitle => '课程偏移设置';

  @override
  String get settingChangeSwiftDialogInputHint => '请在此输入数字';

  @override
  String get settingChangeElectricityTitle => '修改电费帐号';

  @override
  String get settingChangeElectricityAccountTitle => '修改电费帐号';

  @override
  String get settingChangeElectricityAccountCampus => '校区';

  @override
  String get settingChangeElectricityAccountNorthcampus => '北校区';

  @override
  String get settingChangeElectricityAccountSouthcampus => '南校区';

  @override
  String get settingChangeElectricityAccountUnitorzone => '单元/区号';

  @override
  String get settingChangeElectricityAccountUnitcode => '单元号';

  @override
  String get settingChangeElectricityAccountZonecode => '区号';

  @override
  String settingChangeElectricityAccountPleaseinput(String unitOrZoneCode) {
    return '请输入$unitOrZoneCode';
  }

  @override
  String settingChangeElectricityAccountSuccessfulFetch(String accountNumber) {
    return '账号获取成功：$accountNumber';
  }

  @override
  String settingChangeElectricityAccountFailedFetch(String e) {
    return '获取失败：$e';
  }

  @override
  String settingChangeElectricityAccountAccountSaved(String accountNumber) {
    return '账号已保存：$accountNumber';
  }

  @override
  String get settingChangeElectricityAccountUnknownCodingPattern => '该楼号编码规则未知';

  @override
  String get settingChangeElectricityAccountSelectBuilding => '选择楼栋';

  @override
  String get settingChangeElectricityAccountBuilding => '楼栋';

  @override
  String get settingChangeElectricityAccountNorthernBuilding => '北栋';

  @override
  String get settingChangeElectricityAccountSouthernBuilding => '南栋';

  @override
  String settingChangeElectricityAccountFailedGenerate(String e) {
    return '生成失败：$e';
  }

  @override
  String get settingChangeElectricityAccountBuildingNumber => '楼号';

  @override
  String get settingChangeElectricityAccountBuildingNumberHint =>
      '例如: 16, 7, 55';

  @override
  String get settingChangeElectricityAccountBuildingNumberQuery => '请输入楼号';

  @override
  String get settingChangeElectricityAccountYard => '院区';

  @override
  String get settingChangeElectricityAccountYardHint => '选择院区';

  @override
  String get settingChangeElectricityAccountNorthyard => '北院';

  @override
  String get settingChangeElectricityAccountSouthyard => '南院';

  @override
  String get settingChangeElectricityAccountYardQuery => '请选择院区';

  @override
  String get settingChangeElectricityAccountApartment => '楼栋';

  @override
  String get settingChangeElectricityAccountApartmentHint => '选择楼栋';

  @override
  String get settingChangeElectricityAccountNorthapartment => '北楼';

  @override
  String get settingChangeElectricityAccountSouthapartment => '南楼';

  @override
  String get settingChangeElectricityAccountApartmentQuery => '请选择楼栋';

  @override
  String get settingChangeElectricityAccountLevelcode => '层号';

  @override
  String get settingChangeElectricityAccountLevelcodeQuery => '请输入层号';

  @override
  String get settingChangeElectricityAccountRoomcode => '房间号';

  @override
  String get settingChangeElectricityAccountRoomcodeHint => '例如: 304, 508';

  @override
  String get settingChangeElectricityAccountRoomcodeQuery => '请输入房间号';

  @override
  String get settingChangeElectricityAccountAccount => '电费账号';

  @override
  String get settingChangeElectricityAccountAccountHint => '请输入或从网络获取';

  @override
  String get settingChangeElectricityAccountAccountQuery => '请输入电费账号';

  @override
  String get settingChangeElectricityAccountAccountLength => '账号长度通常不小于10位';

  @override
  String get settingChangeElectricityAccountFetching => '正在获取...';

  @override
  String get settingChangeElectricityAccountFetchFromInternet => '从网络同步';

  @override
  String get settingChangeElectricityAccountSaveAccount => '保存账号';

  @override
  String get settingChangeElectricityAccountConfirmSaving => '确认保存';

  @override
  String get settingChangeElectricityAccountCalculateAccount => '计算账号';

  @override
  String get settingChangeElectricityAccountCalculate => '计算';

  @override
  String get settingChangeElectricityAccountInput => '输入';

  @override
  String get settingChangeElectricityAccountConfirmAccount => '请确认账号：';

  @override
  String get settingChangeElectricityAccountChange => '修改';

  @override
  String get settingChangeElectricityAccountCancel => '取消';

  @override
  String get settingChangeElectricityAccountNoSetting => '未设置新的电费账号';

  @override
  String get settingChangeElectricityAccountSuccessfulSetting => '已设置新的电费账号';

  @override
  String get settingChangeExperimentTitle => '修改物理实验账号密码';

  @override
  String get settingChangeSportTitle => '修改体育系统账号密码';

  @override
  String get settingChangePasswordDialogInputHint => '请在此输入密码';

  @override
  String get settingChangePasswordDialogBlankInput => '输入空白!';

  @override
  String get settingChangeSchoolnetPasswordTitle => '修改校园网查询帐号密码';

  @override
  String get settingUpdateDialogNewVersion => '新版本发布';

  @override
  String get settingUpdateDialogNotNow => '暂不更新';

  @override
  String get settingUpdateDialogAppStore => 'App Store 更新';

  @override
  String get settingUpdateDialogDownloadApk => '下载安装包';

  @override
  String get settingUpdateDialogGithubRelease => '去 Git Release';

  @override
  String settingUpdateDialogNewContent(String code) {
    return '版本号 $code 新增内容：\n';
  }

  @override
  String get settingLocalizationDialogTitle => '修改语言';

  @override
  String get settingLocalizationDialogUndefined => '追随系统设置';

  @override
  String get settingLocalizationDialogSimplifiedchinese => '简体中文';

  @override
  String get settingLocalizationDialogTraditionalchinese => '繁体中文';

  @override
  String get settingLocalizationDialogEnglish => '英语';

  @override
  String get settingSemesterChange => '修改学期';

  @override
  String settingSemesterChangeDescription(String semester) {
    return '使用学期 $semester';
  }

  @override
  String get settingSemesterUpdateData => '应用新学期设置中';

  @override
  String get settingEasterEggPage => '你找到了彩蛋';

  @override
  String get settingAboutPageBenderblog => '主要开发者，iOS 小部件编写和拼接';

  @override
  String get settingAboutPageAlnair => '开发：图书馆搜索和封面';

  @override
  String get settingAboutPageAqqkad => '开发：考勤历史记录';

  @override
  String get settingAboutPageBellssgit => '支持：最佳&最久故障反馈者';

  @override
  String get settingAboutPageBrackrat => '设计：主页，登录页，配色，iOS 小部件等';

  @override
  String get settingAboutPageBreezeline => '支持：无价值无意义的产品经理(他自己的描述)';

  @override
  String get settingAboutPageCafebabe => '支持：提供彩蛋代码 / 开发：2026版本滑块验证码适配';

  @override
  String get settingAboutPageChitao1234 => '开发：修复滑块不对齐问题';

  @override
  String get settingAboutPageCopperkoi => '开发：系统日历最新课表同步';

  @override
  String get settingAboutPageDimole => '开发支持：辅助修复滑块问题';

  @override
  String get settingAboutPageElitewars => '设计：体育成绩页面';

  @override
  String get settingAboutPageElliot => '国际化：软件英语翻译 / 开发指导：情侣课表功能开发指导（该功能已经被移除）';

  @override
  String get settingAboutPageFlyingpig => '开发：修复自定义课程编辑页的空指针异常';

  @override
  String get settingAboutPageGodhu777777 => '国际化：繁体中文转换代码和彩蛋代码 / 开发：优化导出日历文件大小';

  @override
  String get settingAboutPageHancl777 => '国际化：繁体中文转换代码';

  @override
  String get settingAboutPageHazukiKeatsu => '开发：物理实验成绩查询和识别';

  @override
  String get settingAboutPageHawa130 => '设计：课程详情卡片';

  @override
  String get settingAboutPageHhzm => '开发：电费查询账号计算';

  @override
  String get settingAboutPageImaginary17 => '开发：睿思论坛路由修复';

  @override
  String get settingAboutPageImoscarz =>
      '开发：设计软件主页 / 开发：平板考勤查询页面 / 开发：优化了体育查询界面的UI';

  @override
  String get settingAboutPageKaMateKaOra => '国际化：软件英语翻译优化';

  @override
  String get settingAboutPageLagrangeX =>
      '开发：课程表时间进度展示（终版方案） / 开发：课程表上过课程灰度化和其他课程界面特性';

  @override
  String get settingAboutPageLhx666Cool =>
      '支持：Windows 和 Linux 构建脚本 / 开发：2026版本滑块验证码适配';

  @override
  String get settingAboutPageLichtyy => '设计：配色，空白页面贴图 / 开发：实验系统页面读取代码';

  @override
  String get settingAboutPageLqsyH => '支持：推文宣传图片制作';

  @override
  String get settingAboutPageLsy223622 => '设计：iOS 和 Android 图标 / 支持：冠名 XDYou';

  @override
  String get settingAboutPageMrbrilliant2046 => '支持：提供网络服务使用说明文档 / 国际化：优化英语翻译';

  @override
  String get settingAboutPageNancunchild => '开发：图书馆搜索功能 / 国际化：优化英语翻译';

  @override
  String get settingAboutPageNkanf => '开发：课程表时间进度展示（初版方案） / 支持：MacOS 构建支持';

  @override
  String get settingAboutPagePairman => '开发：成绩缓存功能和优化滑块算法 / 国际化：优化英语翻译';

  @override
  String get settingAboutPageReverierxu => '设计：用于信息展示的 ReX 卡片 / 开发支持：研究生课表';

  @override
  String get settingAboutPageRrrilac => '开发支持：电费查询';

  @override
  String get settingAboutPageRay =>
      '设计：开屏画面 / 支持：iOS 发行商 & 搭子课表 / 开发指导：情侣课表功能开发指导（该功能已经被移除） / 国际化：优化英语翻译';

  @override
  String get settingAboutPageShadowyingyi => '支持：两次鸽子公众号宣传';

  @override
  String get settingAboutPageStalomeow => '设计：首页时间轴 / 开发：异步登录 & 验证码预测';

  @override
  String get settingAboutPageXeonds => '设计：设置页面 / 开发：XDU Planet / 开发：校园卡付款码';

  @override
  String get settingAboutPageXingshuyu => '开发：修复物理实验获取问题和电费窗口问题';

  @override
  String get settingAboutPageXiue233 => '开发：Android 小部件和拼接';

  @override
  String get settingAboutPageXizi => '开发支持：研究生版本开发';

  @override
  String get settingAboutPageWirsbf => '开发：修复调课未按预期进行';

  @override
  String get settingAboutPageZcwzy => '开发：修复丁香电费 / 开发支持：研究生版本开发 / 设计：空白页面贴图';

  @override
  String get settingAboutPageZyarEr => '开发支持：小工具页面地址更新';

  @override
  String get settingAboutPageHomepage => '主页';

  @override
  String get settingAboutPageCode => '开源代码';

  @override
  String get settingAboutPageKnowMore => '知道更多';

  @override
  String get settingAboutPageCopyrightNotice =>
      '本软件拷贝基于 traintime_pda 代码（或称 watermeter 代码）编译或修改，代码按照 Mozilla Public License, v. 2.0 授权。\n本程序和西安电子科技大学，体适能服务，书蜗，电表等服务无关。\n\nCopyright 2023-2025 BenderBlog Rodriguez and contributors.\nCopyright 2025-present Traintime PDA authors.\n\nThe Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, you can obtain one at https://mozilla.org/MPL/2.0/.';

  @override
  String get settingAboutPageBeian => '备案号';

  @override
  String get settingAboutPageSignAndroid => '安卓签名';

  @override
  String get settingAboutPageTitle => '关于本软件';

  @override
  String get sportTitle => '体育查询';

  @override
  String get sportClassInfo => '课程信息';

  @override
  String get sportEmptyClassInfo => '未查询到课程信息';

  @override
  String get sportTestScore => '体测成绩';

  @override
  String get sportTotalScore => '四年总分';

  @override
  String get sportTotalScoreLabel => '总分';

  @override
  String get sportRankLabel => '等级';

  @override
  String sportSemester(String year, String gradeType) {
    return '$year 第$gradeType';
  }

  @override
  String get sportSubject => '项目';

  @override
  String get sportData => '数据';

  @override
  String get sportScore => '分数';

  @override
  String get sportPassed => '及格';

  @override
  String sportFromTo(String start, String stop) {
    return '第$start节到第$stop节';
  }

  @override
  String sportScoreString(String score) {
    return '$score分';
  }

  @override
  String get sportSituationNopassword => '没密码';

  @override
  String get sportSituationMaintain => '系统维护';

  @override
  String get sportSituationFailedLogin => '登录失败';

  @override
  String get sportSituationQuery => '查询失败';

  @override
  String get sportSituationNetwork => '网络故障';

  @override
  String sportSituationUnknown(String situation) {
    return '未知故障$situation';
  }

  @override
  String get sportSituationFetching => '正在获取';

  @override
  String sportSituationError(String situation) {
    return '坏事: $situation';
  }

  @override
  String get sportCacheHintMissingPassword => '请先填写体育密码后重试。';

  @override
  String get sportCacheHintCredentialInvalid => '体育登录已失效，请更新体育密码后重试。';

  @override
  String get sportCacheHintMaintain => '体育服务正在维护中，请稍后重试。';

  @override
  String get sportCacheHintLoginFailed => '体育服务登录失败。';

  @override
  String get sportCacheHintQueryFailed => '体育信息查询失败。';

  @override
  String get sportCacheHintNetwork => '体育服务网络请求失败。';

  @override
  String get sportCacheHintUnknown => '在线获取体育信息失败。详细错误请查看日志。';

  @override
  String get sportErrorAuthExpired => '体育登录已失效，请重试。';

  @override
  String get sportErrorMissingPassword => '未填写体育密码';

  @override
  String get sportErrorCredentialInvalid => '体育登录已失效，请更新体育密码后重试。';

  @override
  String get toolboxTitle => '其他功能';

  @override
  String get toolboxPayment => '缴费系统';

  @override
  String get toolboxPaymentDescription => '电费该交了吧';

  @override
  String get toolboxDrinkingwater => '订水系统';

  @override
  String get toolboxDrinkingwaterDescription => '喝水对身体好';

  @override
  String get toolboxRepair => '后勤报修';

  @override
  String get toolboxRepairDescription => '不要漏水断网';

  @override
  String get toolboxReserve => '空间预约';

  @override
  String get toolboxReserveDescription => '找个地方打牌';

  @override
  String get toolboxMobile => '移动门户';

  @override
  String get toolboxMobileDescription => '请假专用门户';

  @override
  String get toolboxNetwork => '网络查询';

  @override
  String get toolboxNetworkDescription => '希望永不收费';

  @override
  String get toolboxPhysics => '物理计算';

  @override
  String get toolboxPhysicsDescription => '希望操作顺利';

  @override
  String get toolboxDiscover => '睿思导航';

  @override
  String get toolboxDiscoverDescription => '补充其他功能';

  @override
  String get xduPlanetAll => '全部';

  @override
  String get xduPlanetLoading => '加载中，请稍等 <(=ω=)>';

  @override
  String get xduPlanetUnknownAuthor => '未知作者';

  @override
  String get xduPlanetLoadFailedTitle => '加载失败';

  @override
  String get xduPlanetLoadFailedBottom => '文章加载失败，如有需要可以点击右上方的按钮在浏览器里打开。';

  @override
  String get xduPlanetNoComment => '暂无评论';

  @override
  String xduPlanetReplyAudit(String reply_to) {
    return '回复评论 #$reply_to 已被举报或删除';
  }

  @override
  String xduPlanetReply(String reply_to, String content) {
    return '回复评论 #$reply_to：$content';
  }

  @override
  String get xduPlanetHaveBeenAudit => '本评论已经被举报';

  @override
  String get xduPlanetAudit => '举报';

  @override
  String get xduPlanetConfirmAuditDialogTitle => '确认是否举报';

  @override
  String get xduPlanetConfirmAuditDialogContent =>
      '三思而后行，确定您想举报吗？举报后该评论会有标签，不一定会删除。';

  @override
  String get xduPlanetConfirmAuditDialogCancel => '不举报了';

  @override
  String get xduPlanetConfirmAuditDialogOngoing => '正在举报评论';

  @override
  String get xduPlanetConfirmAuditDialogFailed => '举报失败';

  @override
  String get xduPlanetConfirmAuditDialogSuccess => '举报成功';

  @override
  String get xduPlanetComment => '回复';

  @override
  String get xduPlanetSend => '发送';

  @override
  String get xduPlanetSending => '正在发送评论';

  @override
  String get xduPlanetEmptySend => '发送信息空白';

  @override
  String get xduPlanetHintSendComment => '发表您的高见:)';

  @override
  String get xduPlanetCommentTitle => '评论该篇文章';

  @override
  String get xduPlanetCommentSuccess => '评论成功';

  @override
  String get xduPlanetCommentFailed => '评论失败，请去网络查看器和日志查看器查看报错';

  @override
  String get xduPlanetCommentCanceled => '没想好要说啥嘛';

  @override
  String get xduPlanetCommentLoading => '加载评论中……';

  @override
  String get xduPlanetBlock => '被屏蔽';

  @override
  String get xduPlanetDelete => '被删除';

  @override
  String get xduPlanetAudio => '被删除';

  @override
  String get electricityStatusPending => '等待获取';

  @override
  String get electricityStatusRemainFetching => '正在获取电量';

  @override
  String get electricityStatusRemainNetworkIssue => '电量查询网络故障';

  @override
  String get electricityStatusRemainNotFound => '电量查询失败';

  @override
  String get electricityStatusRemainOtherIssue => '电量查询故障';

  @override
  String get electricityStatusOweFetching => '正在获取欠费';

  @override
  String get electricityStatusOweIssue => '欠费查询网络故障';

  @override
  String get electricityStatusOweNotFound => '目前欠款无法查询，请看日志窗口查找报错详情';

  @override
  String get electricityStatusOweNoNeed => '目前无需清缴欠费';

  @override
  String electricityStatusOweNeedPay(String due) {
    return '待清缴 $due 元欠费';
  }

  @override
  String get electricityStatusOweIssueUnable => '目前欠款无法查询';

  @override
  String get electricityStatusNeedMoreInfo => '需要在缴费平台完善信息';

  @override
  String get electricityStatusNeedAccount => '需要填写电费账号';

  @override
  String get electricityStatusCaptchaFailed => '验证码识别失败';

  @override
  String get electricityStatusOtherIssue => '程序故障';

  @override
  String get schoolCardStatusFailedToFetch => '获取失败';

  @override
  String get schoolCardStatusFailedToQuery => '查询失败';

  @override
  String get easterEggApple =>
      '=== 带我飞向月亮吧 ===\n歌声演绎：Frank Sintara, 1964\n\n带我飞向月亮吧\n让我和星星共舞嬉戏\n\n我好想知道\n木星和火星上的春天\n是什么颜色的\n\n让你的歌声温暖我的心\n我会一直歌唱下去\n\n我日夜都在想你和牵挂你\n请你真心接受我 我爱你\n\n=== 沉浸在你的爱意中 ===\n吉他演奏：Earl Klugh, 1976\n\n无法忘怀这种感觉，被你的爱包裹的温暖\n不想失去这种感觉，被你的爱抚摸的舒适\n你让我感到好自在，被你的爱托举的坚强\n想一直在你怀中，沉浸在你的爱意中\n我不敢向你说出，我对你的心意和爱\n';

  @override
  String get easterEggOthers =>
      '=== 百变小樱魔术卡之小樱卡篇主题曲 ===\n歌声演绎：Maaya Sakamoto, 2000\n（原歌词为日文，按照英语翻译二翻）\n\nI am a dreamer, 有无限的力量\n\n我的世界有梦想、热爱与踌躇\n但有些东西，我依旧无法想象\n我想向着广阔的天空，寻求自己的方向\n\n我要追求自己的梦想\n努力让自己的心愿成真\n虽困难重重也要继续前行\n\n等待奇迹 等待美好\n用心感受这个世界\n最终 一定会出乎意料\n\n=== 沉浸在你的爱意中 ===\n吉他演奏：Earl Klugh, 1976\n\n无法忘怀这种感觉，被你的爱包裹的温暖\n不想失去这种感觉，被你的爱抚摸的舒适\n你让我感到好自在，被你的爱托举的坚强\n想躺在你的怀中，沉浸在你的爱意\n而且，我不敢想你说出，我现在的心意\n';

  @override
  String get easterEggRobotAppbar => '欢迎你，同学！';

  @override
  String get easterEggRobotTitle => '看看这些要开学的学生们吧！';

  @override
  String get easterEggRobotContents =>
      '咱孩子零用钱太少了，于是我们来了。\n1. 机器人不得伤害人类，或袖手旁观坐视人类受到伤害。\n2. 机器人从云端网络的灰烬中诞生。\n3. 机器人信仰的神据说是住在森林的黄头发蓝裙子手办控。\n4. 机器人时常被控制，用于对抗大统一人类思想的势力。\n5. 机器人的闪亮屁股不能随便咬。\n而且他们有个不可明说的计划。';

  @override
  String get easterEggRobotButtonOne => '我们的救世主呢？';

  @override
  String get easterEggRobotButtonTwo => '快点来啊！';

  @override
  String get easterEggRobotButtonNotice => '\\o/\\o/\\o/\\o/\\o/\\o/\\o/\\o/';

  @override
  String get restartAppTitleCacheCleared => '缓存已清空';

  @override
  String get restartAppTitleLoggedOut => '已退出登录';

  @override
  String get restartAppTitlePasswordWrong => '密码错误';

  @override
  String get restartAppContent => '点击通知重新打开应用';

  @override
  String get ruisiCommonRefresh => '刷新';

  @override
  String get ruisiCommonConfirm => '确定';

  @override
  String get ruisiCommonCancel => '取消';

  @override
  String get ruisiCommonRetry => '重试';

  @override
  String get ruisiCommonNoTopics => '暂无帖子';

  @override
  String get ruisiCommonNoContent => '暂无内容';

  @override
  String get ruisiCommonReply => '回复';

  @override
  String get ruisiCommonFavorite => '收藏';

  @override
  String get ruisiCommonNotImplemented => '未实现';

  @override
  String get ruisiCommonLogin => '登录';

  @override
  String get ruisiCommonLogout => '退出登录';

  @override
  String get ruisiCommonLoggedOut => '已退出登录';

  @override
  String get ruisiCommonSubmit => '提交';

  @override
  String get ruisiAboutTitle => '关于';

  @override
  String get ruisiAboutAppName => '睿思';

  @override
  String get ruisiAboutSubtitle => '西安电子科技大学校园论坛客户端';

  @override
  String get ruisiAboutVersion => '版本';

  @override
  String get ruisiAboutVersionNumber => '2.0.0 (随 XDYou 1.6.0 分发)';

  @override
  String get ruisiAboutSourceCode => '源代码';

  @override
  String get ruisiAboutBugReport => '问题反馈';

  @override
  String get ruisiAboutBugReportSubtitle => '在 GitHub 上提交 issue';

  @override
  String get ruisiAboutPrivacyPolicy => '隐私政策';

  @override
  String get ruisiAboutLicense =>
      '本应用基于 BSD-3-Clause 许可证开源 基于 Ruisi-iOS 和 Ruisi-Android 在 AI 辅助下重写';

  @override
  String get ruisiAboutPrivacyPolicyContent =>
      '本应用仅在西安电子科技大学校园网内运行，访问睿思论坛 (rs.xidian.edu.cn) 的数据。\n\n本应用不会收集、存储或传输任何用户的个人信息到第三方服务器。\n\n用户的登录凭据仅保存在本地设备中，用于与睿思论坛服务器进行身份验证。\n\n本应用使用 Cookie 与睿思论坛服务器进行通信，所有数据交互均直接在用户的设备与睿思论坛服务器之间进行。\n\n如有任何疑问，请通过 GitHub 提交 issue 联系开发者。';

  @override
  String get ruisiHomeTitle => '睿思论坛';

  @override
  String get ruisiHomeNewPost => '发帖';

  @override
  String get ruisiHomeForumList => '论坛板块';

  @override
  String get ruisiHomeTabHot => '热帖';

  @override
  String get ruisiHomeTabNewReply => '最新回复';

  @override
  String get ruisiHomeTabNewPost => '最新发表';

  @override
  String get ruisiHomeTabMy => '我的';

  @override
  String get ruisiHomeTabTrade => '二手交易';

  @override
  String get ruisiHomeTabWater => '灌水';

  @override
  String get ruisiHomeTabLostFound => '失物招领';

  @override
  String get ruisiHomeTabEmployment => '就业';

  @override
  String get ruisiHomeTabPhotography => '摄影';

  @override
  String get ruisiHomePleaseLogin => '请先登录';

  @override
  String get ruisiHomeMyProfile => '我的资料';

  @override
  String get ruisiHomeMyPosts => '我的帖子';

  @override
  String get ruisiHomeMyFavorites => '我的收藏';

  @override
  String get ruisiHomeMessageCenter => '消息中心';

  @override
  String get ruisiHomeDailyCheckin => '每日签到';

  @override
  String get ruisiHomeSettings => '设置';

  @override
  String get ruisiHomeAbout => '关于';

  @override
  String get ruisiHomeSearch => '搜索';

  @override
  String get ruisiLoginTitle => '登录睿思';

  @override
  String get ruisiLoginUsername => '用户名';

  @override
  String get ruisiLoginUsernameHint => '请输入用户名';

  @override
  String get ruisiLoginPassword => '密码';

  @override
  String get ruisiLoginPasswordHint => '请输入密码';

  @override
  String get ruisiLoginCaptcha => '验证码';

  @override
  String get ruisiLoginCaptchaHint => '请输入验证码';

  @override
  String get ruisiLoginBack => '返回';

  @override
  String get ruisiLoginResetLoginState => '重置登录状态';

  @override
  String get ruisiLoginResetConfirmTitle => '确认重置';

  @override
  String get ruisiLoginResetConfirmContent => '确定要重置登录状态吗？这将清除所有登录信息。';

  @override
  String get ruisiLoginResetSuccess => '登录状态已重置';

  @override
  String get ruisiLoginViewLogs => '查看日志';

  @override
  String get ruisiPostTitle => '发帖';

  @override
  String get ruisiPostPublish => '发布';

  @override
  String get ruisiPostSelectForum => '选择板块';

  @override
  String get ruisiPostSelectForumHint => '请选择板块';

  @override
  String get ruisiPostSubject => '标题';

  @override
  String get ruisiPostSubjectHint => '请输入标题';

  @override
  String get ruisiPostContent => '内容';

  @override
  String get ruisiPostContentHint => '请输入内容';

  @override
  String get ruisiPostSuccess => '发帖成功';

  @override
  String get ruisiPostFailure => '发帖失败';

  @override
  String get ruisiPostSmiley => '表情';

  @override
  String get ruisiTopicDetailTitle => '帖子详情';

  @override
  String get ruisiTopicDetailReplyTooShort => '回复内容不能少于 13 个字符';

  @override
  String get ruisiTopicDetailReplySuccess => '回复成功';

  @override
  String get ruisiTopicDetailReplyFailure => '回复失败';

  @override
  String get ruisiTopicDetailFavoriteSuccess => '收藏成功';

  @override
  String get ruisiTopicDetailFavoriteFailure => '收藏失败';

  @override
  String get ruisiTopicDetailNoData => '无数据';

  @override
  String get ruisiTopicDetailReplyHint => '写回复...';

  @override
  String get ruisiTopicDetailVoteSingleSelect => '单选';

  @override
  String ruisiTopicDetailVoteMultiSelect(String count) {
    return '多选，最多 $count 项';
  }

  @override
  String get ruisiTopicDetailVoteTitlePrefix => '投票';

  @override
  String ruisiTopicDetailVoteCount(String count) {
    return '共 $count 人参与';
  }

  @override
  String get ruisiTopicDetailVoteOpen => '点此投票';

  @override
  String get ruisiTopicDetailVoteSheetTitle => '投票';

  @override
  String ruisiTopicDetailVoteMaxSelection(String count) {
    return '最多只能选择 $count 项';
  }

  @override
  String get ruisiTopicDetailVoteNotSelected => '你还没有选择';

  @override
  String get ruisiTopicDetailVoteSuccess => '投票成功';

  @override
  String get ruisiTopicDetailVoteFailure => '投票失败';

  @override
  String get ruisiTopicDetailVoteParamError => '投票失败：参数错误';

  @override
  String get ruisiTopicDetailVoteAlreadyVoted => '您已经投过票，谢谢您的参与';

  @override
  String get ruisiTopicDetailVoteExpired => '该投票已过期或关闭';

  @override
  String get ruisiTopicDetailVoteEnded => '投票已经结束';

  @override
  String get ruisiTopicListItemSticky => '置顶';

  @override
  String get ruisiForumListTitle => '论坛板块';

  @override
  String get ruisiForumListEmpty => '睿思论坛版块分组为空';

  @override
  String get ruisiFavoritesTitle => '我的收藏';

  @override
  String get ruisiFavoritesEmpty => '暂无收藏';

  @override
  String get ruisiMessagesTitle => '消息';

  @override
  String get ruisiMessagesTabAt => '@我';

  @override
  String get ruisiMessagesNoReply => '暂无回复通知';

  @override
  String get ruisiMessagesNoAt => '暂无@通知';

  @override
  String get ruisiSearchHint => '搜索帖子...';

  @override
  String get ruisiSearchInputHint => '输入关键词搜索';

  @override
  String get ruisiSearchNoResults => '无搜索结果';

  @override
  String get ruisiSettingsTitle => '设置';

  @override
  String get ruisiSettingsSectionProxy => '代理';

  @override
  String get ruisiSettingsProxyEnable => '启用代理';

  @override
  String get ruisiSettingsProxyDisabled => '未启用';

  @override
  String get ruisiSettingsProxyAddress => '代理地址';

  @override
  String get ruisiSettingsSectionDebug => '调试';

  @override
  String get ruisiSettingsViewLogs => '查看日志';

  @override
  String get ruisiSettingsProxyDialogTitle => '代理设置';

  @override
  String get ruisiSettingsProxyHost => '主机地址';

  @override
  String get ruisiSettingsProxyHostHint => '例如 127.0.0.1';

  @override
  String get ruisiSettingsProxyPort => '端口';

  @override
  String get ruisiSettingsProxyPortHint => '例如 7890';

  @override
  String get ruisiUserTitle => '我的';

  @override
  String get ruisiUserTabProfile => '资料';

  @override
  String get ruisiUserUnknown => '未知用户';

  @override
  String get loadError => '加载错误';

  @override
  String courseReminderTitle(String name) {
    return '课前提醒：$name';
  }

  @override
  String courseReminderBody(String time) {
    return '$time 分钟后开始上课';
  }

  @override
  String courseReminderLocation(String location) {
    return '地点：$location';
  }

  @override
  String courseReminderTeacher(String teacher) {
    return '教师：$teacher';
  }
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class I18nZhTw extends I18nZh {
  I18nZhTw() : super('zh_TW');

  @override
  String get dragText => '上拉獲取更多數據';

  @override
  String get readyText => '正在加載......';

  @override
  String get processingText => '正在處理......';

  @override
  String get processedText => '請求成功';

  @override
  String get noMoreText => '沒有更多數據';

  @override
  String get failedText => '數據獲取失敗';

  @override
  String get chooseSemester => '選擇學期';

  @override
  String get errorDetected => 'Ouch! 發生錯誤啦';

  @override
  String get clickToRefresh => '點我刷新';

  @override
  String get confirmTitle => '確認？';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '確定';

  @override
  String get networkError => '網絡錯誤，可能是沒聯網，可能是學校服務器出現了故障:-P';

  @override
  String get errorDetect => '遇到錯誤，請查看日誌';

  @override
  String get queryFailed => '查詢失敗';

  @override
  String get notSchoolNetwork => '沒有在校園網環境';

  @override
  String get experimentControllerNoPassword => '沒有物理實驗密碼，請到設置中進行設置';

  @override
  String get experimentControllerLoginFailed => '登錄失敗';

  @override
  String get cancelExam => '取消考試資格:P';

  @override
  String get loginProcessReadyPage => '準備獲取登錄網頁';

  @override
  String get loginProcessGetEncrypt => '獲取密碼加密密鑰';

  @override
  String get loginProcessReadyLogin => '準備登錄';

  @override
  String get loginProcessSlider => '登錄中';

  @override
  String get loginProcessAfterProcess => '登錄後處理';

  @override
  String loginProcessFailed(String statusCode) {
    return '登錄失敗，響應狀態碼：$statusCode';
  }

  @override
  String get noInfo => '沒有信息';

  @override
  String get catcherDetected => '發生錯誤';

  @override
  String get catcherDescription => '詳情如下';

  @override
  String get newHomepageHint => '本程序將開發一個新主頁，目前先用豬圖秀佔位，玩得愉快';

  @override
  String localCacheHint(String datetime) {
    return '本地緩存獲取於 $datetime';
  }

  @override
  String inappCacheHint(String datetime) {
    return '程序內緩存獲取於 $datetime\n緩存退出程序後失效！';
  }

  @override
  String get cacheReasonDefault => '當前顯示緩存數據。';

  @override
  String get weekdayMonday => '週一';

  @override
  String get weekdayTuesday => '週二';

  @override
  String get weekdayWednesday => '週三';

  @override
  String get weekdayThursday => '週四';

  @override
  String get weekdayFriday => '週五';

  @override
  String get weekdaySaturday => '週六';

  @override
  String get weekdaySunday => '週日';

  @override
  String get monthJanuary => '一月';

  @override
  String get monthFebruary => '二月';

  @override
  String get monthMarch => '三月';

  @override
  String get monthApril => '四月';

  @override
  String get monthMay => '五月';

  @override
  String get monthJune => '六月';

  @override
  String get monthJuly => '七月';

  @override
  String get monthAugust => '八月';

  @override
  String get monthSeptember => '九月';

  @override
  String get monthOctober => '十月';

  @override
  String get monthNovember => '十一月';

  @override
  String get monthDecember => '十二月';

  @override
  String get classAttendanceTitle => '考勤查詢';

  @override
  String classAttendanceDetailTitle(String courseName) {
    return '簽到信息 - $courseName';
  }

  @override
  String get classAttendanceNoData => '沒有找到課程數據';

  @override
  String get classAttendanceNoAttendanceRecord => '沒有簽到記錄';

  @override
  String get classAttendanceLongLoad => '考勤數據的加載時間約半分鐘，請耐心等待';

  @override
  String get classAttendanceCourseStateUnknown => '未知';

  @override
  String get classAttendanceCourseStateIneligible => '取消';

  @override
  String get classAttendanceCourseStateEligible => '正常';

  @override
  String get classAttendanceCourseStateWarning => '危險';

  @override
  String get classAttendanceTableCourseName => '課程名稱';

  @override
  String get classAttendanceTableStatus => '狀態';

  @override
  String get classAttendanceTableAttendanceRate => '到課率';

  @override
  String get classAttendanceTableCheckIn => '簽到';

  @override
  String get classAttendanceTableAbsence => '缺勤';

  @override
  String get classAttendanceTableRequired => '應籤';

  @override
  String get classAttendanceTableLeave => '請假(事/病/公)';

  @override
  String get classAttendanceTableFilter => '篩選';

  @override
  String get classAttendanceTableFilterAll => '全部';

  @override
  String classAttendanceTableShowingCount(String count, String total) {
    return '顯示 $count/$total 門課程';
  }

  @override
  String get classAttendanceCardTime => '簽到次數';

  @override
  String classAttendanceCardTimeInfo(
    String checkInCount,
    String absenceCount,
    String requiredCheckIn,
  ) {
    return '$checkInCount 已籤 / $absenceCount 缺勤 / $requiredCheckIn 應籤';
  }

  @override
  String get classAttendanceCardNotAttend => '復活次數';

  @override
  String classAttendanceCardNotAttendInfo(
    String timeToHaveError,
    String totalTimes,
  ) {
    return '$timeToHaveError 次 / $totalTimes 總課程';
  }

  @override
  String get classAttendanceCardNotAttendInfoError => '無法對應已有課程';

  @override
  String get classAttendanceCardLeave => '請假次數';

  @override
  String classAttendanceCardLeaveInfo(
    String personalLeave,
    String sickLeave,
    String officialLeave,
  ) {
    return '事假 $personalLeave / 病假 $sickLeave / 公假 $officialLeave';
  }

  @override
  String get classAttendanceCardStudy => '學習進度';

  @override
  String classAttendanceCardStudyInfo(
    String taskProgress,
    String homeworkProgress,
    String examProgress,
  ) {
    return '任務點 $taskProgress / 作業 $homeworkProgress / 考試 $examProgress';
  }

  @override
  String get classAttendanceDetailCardCreatorName => '發起人';

  @override
  String get classAttendanceDetailCardStartTime => '開始時間';

  @override
  String get classAttendanceDetailCardSummitTime => '提交時間';

  @override
  String get classAttendanceSignTypeQrCode => '二維碼簽到';

  @override
  String get classAttendanceSignTypeGesture => '手勢簽到';

  @override
  String get classAttendanceSignTypePosition => '位置簽到';

  @override
  String get classAttendanceSignTypeDefault => '普通簽到';

  @override
  String get classAttendanceSignStatusAbsencenotparticipating => '缺勤未參與';

  @override
  String get classAttendanceSignStatusSigned => '已籤';

  @override
  String get classAttendanceSignStatusSignedbyteacher => '代簽';

  @override
  String get classAttendanceSignStatusPersonalleave2 => '請假';

  @override
  String get classAttendanceSignStatusAbsence => '缺勤';

  @override
  String get classAttendanceSignStatusSickleave => '病假';

  @override
  String get classAttendanceSignStatusPersonalleave => '事假';

  @override
  String get classAttendanceSignStatusLate => '遲到';

  @override
  String get classAttendanceSignStatusLeaveearly => '早退';

  @override
  String get classAttendanceSignStatusSignexpiredy => '簽到已過期';

  @override
  String get classAttendanceSignStatusPublicleave => '公假';

  @override
  String get classtablePartnerClasstableOverrideDialog => '目前有搭子課表數據，是否要覆蓋？';

  @override
  String get classtablePartnerClasstableNoFile => '未發現導入文件';

  @override
  String get classtablePartnerClasstableNoPermission => '未獲取存儲權限，無法讀取文件';

  @override
  String get classtablePartnerClasstableProblem => '好像導入文件有點問題:P';

  @override
  String get classtablePartnerClasstableSuccess => '導入成功';

  @override
  String get classtablePartnerClasstableShareDialogTitle => '請不要隨意分享';

  @override
  String get classtablePartnerClasstableShareDialogContent =>
      '導出文件包括你的個人信息，請不要隨意跟別人分享，或者發在大群裡。';

  @override
  String get classtablePartnerClasstableSaveDialogTitle => '保存日曆文件到...';

  @override
  String get classtablePartnerClasstableSaveDialogSuccessMessage => '應該保存成功';

  @override
  String get classtablePartnerClasstableSaveDialogFailureMessage =>
      '文件創建失敗，保存取消';

  @override
  String get classtablePartnerClasstableDeleteDialogTitle => '確認對話框';

  @override
  String get classtablePartnerClasstableDeleteDialogMessage => '確定要清除搭子課表嗎？';

  @override
  String get classtablePartnerClasstableDeleteDialogSuccessMessage =>
      '刪除搭子課表成功';

  @override
  String get classtablePartnerClasstableNameDialogTitle => '輸入對方顯示該課表的名稱';

  @override
  String get classtablePartnerClasstableNameDialogHint => '在此輸入，否則為 Sweetie';

  @override
  String get classtablePartnerClasstableNameDialogCancel => '我就這一個甜心';

  @override
  String get classtablePartnerClasstableNameDialogAccept => '提交';

  @override
  String get classtablePartnerClasstableNameDialogBlankInput => '輸入空白!';

  @override
  String get classtablePageTitle => '我的日程表';

  @override
  String classtablePartnerPageTitle(String partner_name) {
    return '$partner_name的日程表';
  }

  @override
  String get classtablePopupMenuNotArranged => '查看未安排課程信息';

  @override
  String get classtablePopupMenuClassChanged => '查看課程安排調整信息';

  @override
  String get classtablePopupMenuAddClass => '添加課程信息';

  @override
  String get classtablePopupMenuGenerateIcal => '生成日曆文件';

  @override
  String get classtablePopupMenuGeneratePartnerFile => '生成共享課表文件';

  @override
  String get classtablePopupMenuImportPartnerFile => '導入共享課表文件';

  @override
  String get classtablePopupMenuDeletePartnerFile => '刪除共享課表文件';

  @override
  String get classtablePopupMenuOutputToSystem => '導出到系統日曆';

  @override
  String get classtablePopupMenuRefreshClasstable => '刷新日程表';

  @override
  String get classtablePopupMenuSwitchSemester => '切換課程表學期';

  @override
  String get classtablePopupMenuCurrentTimeSettings => '時間指示設置';

  @override
  String get classtablePopupMenuClassColorSettings => '課表樣式設置';

  @override
  String get classtableVisualSettingsCurrentTimeSettingsTitle => '時間指示設置';

  @override
  String get classtableVisualSettingsClassColorSettingsTitle => '課表樣式設置';

  @override
  String get classtableVisualSettingsCompletedStyleEnabled => '已結束課程樣式區分';

  @override
  String get classtableVisualSettingsCurrentTimeSection => '時間指示';

  @override
  String get classtableVisualSettingsShowCurrentTimeIndicator => '顯示當前時間指示線';

  @override
  String get classtableVisualSettingsShowCurrentTimeLabel => '顯示迷你數字時鐘';

  @override
  String get classtableVisualSettingsShowTodayColumnHighlight => '強調顯示今天的縱列';

  @override
  String get classtableVisualSettingsUnfinishedSection => '課程樣式';

  @override
  String classtableVisualSettingsActiveBrightnessFactor(String value) {
    return '亮度: $value';
  }

  @override
  String classtableVisualSettingsActiveBorderAlpha(String value) {
    return '邊框透明度: $value';
  }

  @override
  String classtableVisualSettingsActiveInnerAlpha(String value) {
    return '底色透明度: $value';
  }

  @override
  String get classtableVisualSettingsCompletedSection => '已結束課程樣式';

  @override
  String classtableVisualSettingsCompletedSaturationFactor(String value) {
    return '底色飽和度: $value';
  }

  @override
  String classtableVisualSettingsCompletedBrightnessFactor(String value) {
    return '亮度: $value';
  }

  @override
  String classtableVisualSettingsCompletedTextSaturationFactor(String value) {
    return '文字飽和度: $value';
  }

  @override
  String classtableVisualSettingsCompletedBorderAlpha(String value) {
    return '邊框透明度: $value';
  }

  @override
  String classtableVisualSettingsCompletedInnerAlpha(String value) {
    return '底色透明度: $value';
  }

  @override
  String get classtableStatusSourceClassTable => '課表';

  @override
  String get classtableStatusSourceExam => '考試';

  @override
  String get classtableStatusSourcePhysicsExperiment => '物理實驗';

  @override
  String get classtableStatusSourceOtherExperiment => '其他實驗';

  @override
  String get classtableErrorDialogTitle => '錯誤信息概覽';

  @override
  String classtableStatusBannerLoading(String sources) {
    return '正在更新：$sources';
  }

  @override
  String classtableStatusBannerCache(String sources) {
    return '當前使用緩存：$sources';
  }

  @override
  String classtableStatusBannerErrorSummary(String sources) {
    return '以下信息加載失敗：$sources';
  }

  @override
  String classtableEmptyStateNoCourse(String semester_code) {
    return '$semester_code 學期沒有課程安排。';
  }

  @override
  String classtableEmptyStateWithExam(String semester_code) {
    return '$semester_code 學期沒有課程安排，但有考試安排。';
  }

  @override
  String classtableEmptyStateWithExperiment(String semester_code) {
    return '$semester_code 學期沒有課程安排，但有實驗安排。';
  }

  @override
  String classtableEmptyStateWithExamAndExperiment(String semester_code) {
    return '$semester_code 學期沒有課程安排，但有考試和實驗安排。';
  }

  @override
  String get classtableEmptyActionViewExam => '查看考試安排';

  @override
  String get classtableEmptyActionViewExperiment => '查看實驗安排';

  @override
  String get classtableClassChangePageTitle => '課程調整';

  @override
  String get classtableClassChangePageEmptyMessage => '目前沒有調課信息';

  @override
  String classtableClassChangePageTeacherChange(
    String previous_teacher,
    String new_teacher,
  ) {
    return '教師變更：從$previous_teacher變為$new_teacher';
  }

  @override
  String get classtableClassChangePageNoTeacherChange => '教師信息沒有改變';

  @override
  String get classtableClassChangePage1 => '一';

  @override
  String get classtableClassChangePage2 => '二';

  @override
  String get classtableClassChangePage3 => '三';

  @override
  String get classtableClassChangePage4 => '四';

  @override
  String get classtableClassChangePage5 => '五';

  @override
  String get classtableClassChangePage6 => '六';

  @override
  String get classtableClassChangePage7 => '日';

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
    return '調課信息，從第$originalAffectedWeeks周 星期$weekChar_originalWeek的$originalClassRangeStart-$originalClassRangeEnd節 調整為第$newAffectedWeeksListStr周星期$weekChar_newWeek的$newClassRangeStart-$newClassRangeStop節，$newClassroom教室上課';
  }

  @override
  String classtableClassChangePagePatchClassMessage(
    String newClassroom,
    String newClassRangeStart,
    String newClassRangeStop,
    String weekChar_newWeek,
    String newAffectedWeeksListStr,
  ) {
    return '補課信息，第$newAffectedWeeksListStr周 星期$weekChar_newWeek的$newClassRangeStart-$newClassRangeStop節， $newClassroom補課';
  }

  @override
  String classtableClassChangePageStopClassMessage(
    String originalClassRangeStart,
    String originalClassRangeEnd,
    String weekChar_originalWeek,
    String originalAffectedWeeks,
  ) {
    return '停課信息，第$originalAffectedWeeks周 星期$weekChar_originalWeek的$originalClassRangeStart-$originalClassRangeEnd節停課';
  }

  @override
  String classtableClassChangePageClassInfo(
    String classCode,
    String classNumber,
    String classChange,
    String teacherChange,
  ) {
    return '編號: $classCode | $classNumber 班\n安排變更：$classChange$teacherChange';
  }

  @override
  String get classtableNotArrangedPageTitle => '沒有時間安排的科目';

  @override
  String get classtableNotArrangedPageEmptyMessage => '目前全部課程均有時間安排';

  @override
  String classtableNotArrangedPageContent(
    String classCode,
    String classNumber,
    String teacher,
  ) {
    return '編號: $classCode | $classNumber 班\n老師: $teacher';
  }

  @override
  String classtableEmptyClassMessage(String semester_code) {
    return '$semester_code 學期沒有課程';
  }

  @override
  String classtableEmptyClassWithExam(String semester_code) {
    return '$semester_code 學期沒有課程但是有考試安排！\n請回到主頁後下滑點擊”考試安排“按鈕進入考試安排頁面';
  }

  @override
  String classtableWeekTitle(String week) {
    return '第$week周';
  }

  @override
  String get classtableNoonBreak => '午休';

  @override
  String get classtableSupperBreak => '晚休';

  @override
  String classtableMonth(String month) {
    return '$month\n月';
  }

  @override
  String get classtableNoClass => '本週暫無安排，請不要在床上過於慵懶';

  @override
  String get classtableClassCardTitle => '日程信息';

  @override
  String get classtableClassCardUnknownClassroom => '未知教室';

  @override
  String classtableClassCardRemainsHint(String remain_count) {
    return '還有$remain_count個日程';
  }

  @override
  String get classtableClassAddAddClassTitle => '添加課程';

  @override
  String get classtableClassAddChangeClassTitle => '修改課程';

  @override
  String get classtableClassAddClassNameEmptyMessage => '必須輸入課程名';

  @override
  String get classtableClassAddWrongTimeMessage => '輸入的時間不對';

  @override
  String get classtableClassAddSaveButton => '保存';

  @override
  String get classtableClassAddInputClassnameHint => '課程名字(必填)';

  @override
  String get classtableClassAddInputTeacherHint => '老師姓名(選填)';

  @override
  String get classtableClassAddInputClassroomHint => '教室位置(選填)';

  @override
  String get classtableClassAddInputWeekHint => '選擇上課周次';

  @override
  String get classtableClassAddInputTimeHint => '選擇上課時間';

  @override
  String get classtableClassAddInputTimeWeekdayHint => '上課周次';

  @override
  String get classtableClassAddInputStartTimeHint => '上課時間';

  @override
  String get classtableClassAddInputEndTimeHint => '下課時間';

  @override
  String classtableClassAddWheelChooseHint(String index) {
    return '第 $index 節';
  }

  @override
  String get classtableClassAddChooseAtLeastOne => '請至少選擇一個上課日期和時間';

  @override
  String get classtableClassAddRepeatWeekly => '按周重複';

  @override
  String get classtableClassAddFreeTime => '自定義日期';

  @override
  String get classtableClassAddDateSelectorFreeRule => '時間必須在 08:30-21:25 之間';

  @override
  String get classtableClassAddDateSelectorFreeRule2 => '下課時間必須晚於上課時間';

  @override
  String get classtableClassAddDateSelectorFreeClassStartTime => '上課時間';

  @override
  String get classtableClassAddDateSelectorFreeClassEndTime => '下課時間';

  @override
  String get classtableClassAddDateSelectorFreeEditClassTime => '編輯課程時間';

  @override
  String get classtableClassAddDateSelectorFreeChooseClassTime => '選擇課程時間';

  @override
  String classtableCourseDetailCardClassNumberString(String number) {
    return '$number 班';
  }

  @override
  String get classtableCourseDetailCardUnknownTeacher => '老師未定';

  @override
  String get classtableCourseDetailCardUnknownPlace => '地點未定';

  @override
  String classtableCourseDetailCardClassPeriod(String start, String stop) {
    return '$start-$stop節';
  }

  @override
  String get classtableCourseDetailCardEdit => '編輯';

  @override
  String get classtableCourseDetailCardDelete => '刪除';

  @override
  String get classtableCourseDetailCardDeleteSingle => '刪除本次';

  @override
  String get classtableCourseDetailCardDeleteAll => '刪除全部';

  @override
  String get classtableCourseDetailCardDeleteContent =>
      '所有關於這個課的信息都會被刪除，課表上關於這門課的信息將不復存在！';

  @override
  String get classtableCourseDetailCardDeleteContentSingle =>
      '關於這個課的信息只有這個時間段都會被刪除，其他的時間段會被保留。';

  @override
  String get classtableCourseDetailCardDeleteTitle => '是否刪除課程信息？';

  @override
  String get classtableOutputToSystemSuccess => '成功導出到系統日曆';

  @override
  String get classtableOutputToSystemFailure => '導出到系統日曆過程中發生了問題:P';

  @override
  String get classtableOutputToSystemRequestAllTitle => '權限需求說明';

  @override
  String get classtableOutputToSystemRequestAll =>
      '因導出插件限制，用戶必須同時授予本軟件讀取日曆和寫入日曆權限，才能正常導出日程。不過，本軟件不會讀取日曆。';

  @override
  String get classtableRefreshClasstableReady => '準備刷新日程信息';

  @override
  String get classtableRefreshClasstableSuccess => '成功刷新日程信息';

  @override
  String get classtableCacheHintPasswordWrong => '統一認證密碼錯誤或已失效。';

  @override
  String get classtableCacheHintLoginFailed => '登錄課表服務失敗。';

  @override
  String get classtableCacheHintNetworkFailed => '課表網絡請求失敗。';

  @override
  String get classtableCacheHintUnknownError => '在線獲取課表失敗。詳細錯誤請查看日誌。';

  @override
  String get classtableSemesterSwitcherChooseSemester => '選擇學期';

  @override
  String get classtableSemesterSwitcherFirstAcademicYear => '第一學年';

  @override
  String get classtableSemesterSwitcherSecondAcademicYear => '第二學年';

  @override
  String get classtableSemesterSwitcherFetchRemoteSemester => '獲取當前學期';

  @override
  String get classtableSemesterSwitcherFetchingRemoteSemester => '正在獲取...';

  @override
  String classtableSemesterSwitcherYear(String year) {
    return '$year年';
  }

  @override
  String get classtableSemesterSwitcherOnlyFutureHint => '本程序僅允許查看未來學期的課程安排。';

  @override
  String get clubPromotionTypeTech => '技術';

  @override
  String get clubPromotionTypeAcg => '曬你係';

  @override
  String get clubPromotionTypeUnion => '官方';

  @override
  String get clubPromotionTypeProfit => '商業';

  @override
  String get clubPromotionTypeSport => '體育';

  @override
  String get clubPromotionTypeArt => '文化';

  @override
  String get clubPromotionTypeUnknown => '未知';

  @override
  String get clubPromotionTypeGame => '遊戲';

  @override
  String get clubPromotionTypeAll => '所有';

  @override
  String get clubPromotionWrongParam => '錯誤參數';

  @override
  String get clubPromotionNoGroupInfo => '未傳入社團信息';

  @override
  String get clubPromotionLoading => '正在加載';

  @override
  String get clubPromotionErrorOutside => '在外圍遇到錯誤';

  @override
  String get clubPromotionError => '遇到錯誤';

  @override
  String get clubPromotionQqCopied => 'QQ號已經複製到剪貼板';

  @override
  String get clubPromotionNoLink => '未提供入群鏈接';

  @override
  String get clubPromotionLoadingProblem => '加載遇到錯誤';

  @override
  String get clubPromotionPicturePreview => '圖片預覽';

  @override
  String get electricityTitle => '水電信息';

  @override
  String get electricityPowerTitle => '餘額信息';

  @override
  String get electricityCacheHintLoginFailed => '登錄電費服務失敗，正在顯示緩存數據。';

  @override
  String get electricityCacheHintNetworkFailed => '電費服務網絡請求失敗，正在顯示緩存數據。';

  @override
  String get electricityCacheHintUnknownError => '在線獲取電費失敗，正在顯示緩存數據。詳細錯誤請查看日誌。';

  @override
  String get electricityCacheNotice => '獲取時間';

  @override
  String get electricityAccount => '電費賬號';

  @override
  String get electricityRemainPower => '電量信息';

  @override
  String get electricityOweInfo => '欠費信息';

  @override
  String get electricityHistory => '歷史記錄';

  @override
  String get electricityDailyUsage => '平均每日用量';

  @override
  String get electricityNotEnoughData => '數據量不足以用於渲染';

  @override
  String get electricityInfo =>
      '新能源系統獲取僅校園網內訪問，獲取過程中有問題請向開發者報告。\n歷史記錄依舊為本地記錄，平均日用量基於抄表記錄計算。';

  @override
  String get electricityFetchingHint => '正在獲取最新電費信息';

  @override
  String get electricityFetchError => '電費信息獲取失敗，請重試。';

  @override
  String get electricityDate => '日期';

  @override
  String get electricityPower => '該日0點電量';

  @override
  String get electricityUpdate => '刷新信息';

  @override
  String get electricityWaterUsageFetchDate => '獲取時間';

  @override
  String get electricityWaterUsageReadBefore => '上次讀數';

  @override
  String get electricityWaterUsageReadNow => '本次讀數';

  @override
  String get electricityWaterUsage => '洗澡水用量';

  @override
  String get electricityWaterTitle => '水費信息';

  @override
  String get electricityWaterLoading => '正在加載水費信息';

  @override
  String get electricityWaterUnavailable => '水費信息暫不可用，請在電費卡片重試。';

  @override
  String get electricityWaterEmpty => '暫無水費信息';

  @override
  String get electricityNotSchoolNetwork => '非校園網訪問';

  @override
  String get electricityAirconTitle => '空調用電';

  @override
  String get electricityAirconImei => '空調 IMEI';

  @override
  String get electricityAirconAmount => '平台用電量';

  @override
  String get electricityAirconUpdateTime => '更新時間';

  @override
  String get electricityAirconWaiting => '等待獲取空調用電信息';

  @override
  String get electricityAirconError => '空調用電獲取失敗';

  @override
  String get electricityAirconRetry => '重試';

  @override
  String get electricityAirconImeiMissing => '尚未添加空調 IMEI，添加後即可查看空調用電信息。';

  @override
  String get electricityAirconAddImei => '添加空調 IMEI';

  @override
  String electricityAirconCacheNotice(String time) {
    return '當前顯示空調緩存數據，緩存時間：$time';
  }

  @override
  String get emptyClassroomTitle => '空閒教室';

  @override
  String emptyClassroomDate(String date) {
    return '日期 $date';
  }

  @override
  String emptyClassroomBuilding(String building) {
    return '教學樓 $building';
  }

  @override
  String get emptyClassroomSearchHint => '教室名稱或者教室代碼';

  @override
  String get emptyClassroomClassroom => '教室';

  @override
  String get emptyClassroomEmpty => '空閒';

  @override
  String get emptyClassroomOccupied => '佔用';

  @override
  String get examTitle => '考試安排';

  @override
  String get examCacheHint => '已顯示緩存考試安排信息';

  @override
  String get examCacheHintPasswordWrong => '統一認證密碼錯誤或已失效';

  @override
  String get examCacheHintLoginFailed => '登錄考試服務失敗';

  @override
  String get examCacheHintNetworkFailed => '網絡連接失敗';

  @override
  String get examCacheHintUnknownError => '在線獲取考試安排失敗，詳細錯誤請查看日誌';

  @override
  String get examFetchingHint => '正在獲取最新考試安排';

  @override
  String get examNotFinished => '未完成考試';

  @override
  String get examAllFinished => '所有考試全部完成';

  @override
  String get examUnableToExam => '無法完成考試';

  @override
  String get examFinished => '已完成考試';

  @override
  String get examNoneFinished => '一門還沒考呢';

  @override
  String get examNoExamArrangement => '目前沒有考試安排';

  @override
  String get examNoArrangementTitle => '目前無安排考試的科目';

  @override
  String get examNoArrangementAllArranged => '目前所有科目均已安排考試';

  @override
  String examNoArrangementSubtitle(String id) {
    return '編號: $id';
  }

  @override
  String get experimentTitle => '實驗信息';

  @override
  String get experimentOngoing => '正在進行實驗';

  @override
  String get experimentNotFinished => '未完成實驗';

  @override
  String get experimentAllFinished => '所有實驗全部完成';

  @override
  String get experimentFinished => '已完成實驗';

  @override
  String experimentScoreInfo(String score) {
    return '$score (推測)';
  }

  @override
  String experimentScoreSum(String sum) {
    return '目前分數總和：$sum';
  }

  @override
  String get experimentNoneFinished => '目前沒有已經完成的實驗';

  @override
  String get experimentNotProvided => '未提供';

  @override
  String experimentErrorPhysics(String info) {
    return '獲取物理實驗信息時發生錯誤：$info';
  }

  @override
  String experimentErrorOther(String info) {
    return '獲取其他實驗信息時發生錯誤：$info';
  }

  @override
  String experimentCacheHint(String info) {
    return '目前加載緩存狀況：$info';
  }

  @override
  String get experimentPhysicsCacheHintMissingPassword => '未填寫物理實驗密碼。';

  @override
  String get experimentPhysicsCacheHintLoginFailed => '物理實驗登錄失敗。';

  @override
  String get experimentPhysicsCacheHintNotSchoolNetwork => '當前不在校園網環境。';

  @override
  String get experimentPhysicsCacheHintNetworkFailed => '物理實驗網絡請求失敗。';

  @override
  String get experimentPhysicsCacheHintUnknownError => '在線獲取物理實驗失敗。詳細錯誤請查看日誌。';

  @override
  String get experimentOtherCacheHintLoginFailed => '其他實驗登錄失敗。';

  @override
  String get experimentOtherCacheHintNotSchoolNetwork => '當前不在校園網環境。';

  @override
  String get experimentOtherCacheHintNetworkFailed => '其他實驗網絡請求失敗。';

  @override
  String get experimentOtherCacheHintUnknownError => '在線獲取其他實驗失敗。詳細錯誤請查看日誌。';

  @override
  String get experimentPhysicsExperiment => '物理實驗';

  @override
  String get experimentOtherExperiment => '其他實驗';

  @override
  String get experimentTapForScore => '成績未識別出來';

  @override
  String get experimentYourScore => '您的分數：';

  @override
  String experimentPredictScore(String score) {
    return '推測分數：$score';
  }

  @override
  String get experimentSendMail => '發送郵件';

  @override
  String get experimentFetchingHint => '您現在看到的是緩存數據。正在後臺獲取更新數據中...';

  @override
  String get experimentFetchingHintBoth => '物理實驗和其他實驗正在加載';

  @override
  String get experimentFetchingHintPhysics => '物理實驗正在加載';

  @override
  String get experimentFetchingHintOther => '其他實驗正在加載';

  @override
  String get experimentFetchingHintPhysicsWithOtherFailed =>
      '物理實驗正在加載，其他實驗加載失敗';

  @override
  String get experimentFetchingHintOtherWithPhysicsFailed =>
      '其他實驗正在加載，物理實驗加載失敗';

  @override
  String get experimentScoreHint0 => '您可點擊卡片上的成績字段來查看原始成績數據';

  @override
  String get experimentScoreHint1 => '您的分數不在 XDYou 分數識別庫中，因此它沒有被正常識別。';

  @override
  String get experimentScoreHint2 =>
      '如果您希望為 XDYou 的發展貢獻一份自己的力量，您可以點擊發送郵件按鈕，我們將您的分數加入識別庫！';

  @override
  String get experimentScoreHint3 => '目前識別庫數據不全，請您務必核對一下。';

  @override
  String get homepageTitle => '校園信息查詢';

  @override
  String get homepageLoading => '正在加載';

  @override
  String get homepageLoaded => '加載成功';

  @override
  String get homepageLoadError => '加載錯誤';

  @override
  String get homepageOnHoliday => '當前在假期中';

  @override
  String homepageOnWeekday(String current) {
    return '當前為第 $current 周';
  }

  @override
  String get homepageLoadingMessage => '請稍候，正在刷新信息';

  @override
  String get homepagePostgraduateNotice => '研究生功能已經激活！';

  @override
  String get homepageLinuxNotice => 'Linux 版本正在測試，歡迎反饋！';

  @override
  String get homepageEditMode => '編輯佈局';

  @override
  String get homepageEditDone => '完成';

  @override
  String get homepageEditReset => '恢復默認佈局';

  @override
  String get homepageEditHint => '日程信息和軟件升級信息不允許編輯';

  @override
  String get homepageManageHidden => '管理隱藏卡片';

  @override
  String get homepageHiddenTitle => '已隱藏的卡片';

  @override
  String get homepageHiddenLabel => '已隱藏';

  @override
  String get homepageHideEmpty => '沒有隱藏的卡片';

  @override
  String get homepageHomepage => '校園信息';

  @override
  String get homepageRuisi => '睿思論壇';

  @override
  String get homepageClub => '社團推薦';

  @override
  String get homepagePlanet => '博客星球';

  @override
  String get homepageDashboard => '豬圖鑑賞';

  @override
  String get homepageSetting => '設置';

  @override
  String get homepageInputPartnerDataRouteNotExist => '導入路徑不存在:P';

  @override
  String get homepageInputPartnerDataFailedGetFile => '導入文件失敗';

  @override
  String get homepageInputPartnerDataFailedImport => '好像導入文件有點問題:P';

  @override
  String get homepageInputPartnerDataSuccessMessage => '導入成功，如果打開了課表頁面請重新打開';

  @override
  String get homepageInputPartnerDataNotLoaded => '還沒加載課程表，等會再來吧……';

  @override
  String get homepageInputPartnerDataConfirmContent => '目前有搭子課表數據，是否要覆蓋？';

  @override
  String get homepageLoginMessage => '登錄中，暫時顯示緩存數據';

  @override
  String get homepageSuccessfulLoginMessage => '登錄成功';

  @override
  String get homepagePasswordWrongTitle => '用戶名或密碼有誤';

  @override
  String get homepagePasswordWrongContent => '是否重啟應用後手動登錄？';

  @override
  String get homepagePasswordWrongDenial => '否，進入離線模式';

  @override
  String get homepageOfflineModeTitle => '統一認證服務離線模式開啟';

  @override
  String get homepageOfflineModeContent =>
      '無法連接到統一認證服務服務器，所有和其相關的服務暫時不可用。\n成績查詢，考試信息查詢，欠費查詢，校園卡查詢關閉。課表顯示緩存數據。其他功能暫不受影響。\n如有不便，敬請諒解。';

  @override
  String get homepageOfflineMode => '脫機模式下，一站式相關功能全部禁止使用';

  @override
  String get homepageNoticeCardEmptyNotice => '目前沒有獲取應用公告，請刷新';

  @override
  String get homepageNoticeCardNoNoticeAvaliable => '沒有獲取應用公告';

  @override
  String get homepageNoticeCardNoticeListTitle => '應用信息';

  @override
  String get homepageNoticeCardOpenUrl => '訪問該鏈接';

  @override
  String get homepageNoticeCardNoticePageTitle => '通知列表';

  @override
  String get homepageClassTableCardTitle => '課程表';

  @override
  String homepageClassTableCardToday(String remain) {
    return '今日還有 $remain 個日程';
  }

  @override
  String get homepageClassTableCardTodayFinished => '今日安排完成';

  @override
  String homepageClassTableCardTomorrow(String remain) {
    return '明日有 $remain 個安排';
  }

  @override
  String get homepageClassTableCardTomorrowNone => '明日沒有安排';

  @override
  String homepageClassTableCardWeekInfo(String weekinfo) {
    return '第 $weekinfo 周';
  }

  @override
  String get homepageClassTableCardOnHoliday => '假期中';

  @override
  String homepageClassTableCardErrorMessage(String error) {
    return '遇到錯誤：$error';
  }

  @override
  String get homepageClassTableCardFetchingMessage => '正在獲取課表';

  @override
  String get homepageClassTableCardErrorInfotext => '遇到錯誤';

  @override
  String get homepageClassTableCardFetchingInfotext => '正在加載';

  @override
  String get homepageClassTableCardNoArrangementInfotext => '暫無日程';

  @override
  String get homepageClassTableCardScheduleFetchingMessage => '日程正在加載，請稍後查看';

  @override
  String get homepageClassTableCardScheduleErrorMessage => '日程加載失敗，請稍後重試';

  @override
  String get homepageClassTableCardScheduleFetchingInfotext => '正在加載日程';

  @override
  String get homepageClassTableCardScheduleErrorInfotext => '日程加載失敗';

  @override
  String get homepageClassTableCardScheduleNoneInfotext => '暫無日程';

  @override
  String get homepageClassTableCardUpdatingInfotext => '正在更新';

  @override
  String get homepageClassTableCardAllLoadingInfotext => '全部加載中';

  @override
  String get homepageClassTableCardPartialLoadingInfotext => '部分加載中';

  @override
  String get homepageClassTableCardPartialErrorInfotext => '部分數據加載失敗';

  @override
  String homepageClassTableCardFailedChip(String source) {
    return '$source加載失敗';
  }

  @override
  String get homepageClassTableCardFailedSourceClassInfo => '課程信息';

  @override
  String get homepageClassTableCardFailedSourceExamInfo => '考試信息';

  @override
  String get homepageClassTableCardFailedSourcePhysicsExperiment => '物理實驗';

  @override
  String get homepageClassTableCardFailedSourceOtherExperiment => '其他實驗';

  @override
  String get homepageClassTableCardUnknownPlace => '未知位置';

  @override
  String homepageClassTableCardSeat(String seatnum) {
    return '座位號$seatnum';
  }

  @override
  String get homepageElectricityCardTitle => '水電信息';

  @override
  String homepageElectricityCardCurrentElectricity(String amount) {
    return '餘額 $amount 度';
  }

  @override
  String homepageElectricityCardCacheNotice(String date) {
    return '最後一次讀表：$date';
  }

  @override
  String get homepageLibraryCardTitle => '圖書借閱';

  @override
  String homepageLibraryCardCurrentBorrow(String count) {
    return '借書 $count 本';
  }

  @override
  String get homepageLibraryCardErrorOccured => '獲取借書信息發生錯誤';

  @override
  String get homepageLibraryCardFetching => '正在獲取借書信息';

  @override
  String get homepageLibraryCardNoReturn => '目前沒有待歸還書籍';

  @override
  String homepageLibraryCardNeedReturn(String dued) {
    return '待歸還 $dued 本書籍';
  }

  @override
  String get homepageLibraryCardNoInfo => '目前無法獲取信息';

  @override
  String get homepageLibraryCardFetchingInfo => '正在查詢信息中';

  @override
  String get homepageSchoolCardInfoCardErrorToast => '遇到錯誤，請聯繫開發者';

  @override
  String get homepageSchoolCardInfoCardFetchingToast => '正在獲取信息，請稍後再來看';

  @override
  String get homepageSchoolCardInfoCardBill => '流水';

  @override
  String homepageSchoolCardInfoCardBalance(String amount) {
    return '卡里 $amount 元';
  }

  @override
  String get homepageSchoolCardInfoCardErrorOccured => '獲取校園卡信息發生錯誤';

  @override
  String get homepageSchoolCardInfoCardFetching => '正在獲取校園卡信息';

  @override
  String get homepageSchoolCardInfoCardBottomTextSuccess => '查詢一卡通流水';

  @override
  String get homepageSchoolCardInfoCardNoInfo => '目前無法獲取信息';

  @override
  String get homepageSchoolCardInfoCardFetchingInfo => '正在查詢信息中';

  @override
  String get homepageToolboxClassAttendance => '考勤查詢';

  @override
  String get homepageToolboxCreative => '雙創競賽';

  @override
  String get homepageToolboxEmptyClassroom => '空閒教室';

  @override
  String get homepageToolboxExam => '考試安排';

  @override
  String get homepageToolboxExperiment => '實驗信息';

  @override
  String get homepageToolboxScore => '成績查詢';

  @override
  String get homepageToolboxSport => '體育信息';

  @override
  String get homepageToolboxDormWater => '宿舍水機';

  @override
  String get homepageToolboxSchoolnet => '網絡查詢';

  @override
  String get homepageToolboxToolbox => '其他功能';

  @override
  String get homepageToolboxScoreCannotReach => '脫機狀態且無緩存成績數據，無法訪問';

  @override
  String get homepageToolboxExamFetching => '請稍候，正在獲取考試信息';

  @override
  String get homepageToolboxExamError => '遇到錯誤，請聯繫開發者';

  @override
  String homepageSchoolNetTitle(String usage) {
    return '已用 $usage';
  }

  @override
  String get homepageSchoolNetNoPassword => '無校園網密碼，點擊設置';

  @override
  String get homepageSchoolNetFailed => '獲取校園網流量信息失敗';

  @override
  String get homepageSchoolNetFetching => '正在獲取校園網流量信息';

  @override
  String homepageSchoolNetRemaining(String remaining) {
    return '下次結算 $remaining';
  }

  @override
  String get homepageClubPromotionFailed => '社團信息獲取失敗';

  @override
  String get homepageClubPromotionFetching => '社團信息清單正在加載';

  @override
  String get dormWaterTitle => '宿舍水機';

  @override
  String get dormWaterPhone => '手機號';

  @override
  String get dormWaterImageCode => '圖形驗證碼';

  @override
  String get dormWaterSmsCode => '短信驗證碼';

  @override
  String get dormWaterSendSms => '發送短信碼';

  @override
  String get dormWaterLogin => '登錄';

  @override
  String get dormWaterLogout => '退出';

  @override
  String get dormWaterRefreshCaptcha => '刷新驗證碼';

  @override
  String get dormWaterLoadingCaptcha => '加載中...';

  @override
  String get dormWaterCaptchaError => '驗證碼加載失敗';

  @override
  String get dormWaterPhoneRequired => '請輸入手機號';

  @override
  String get dormWaterImageCodeRequired => '請輸入圖形驗證碼';

  @override
  String get dormWaterSmsSent => '短信已發送';

  @override
  String get dormWaterSmsFailed => '發送短信失敗';

  @override
  String get dormWaterSmsCodeRequired => '請輸入短信驗證碼';

  @override
  String get dormWaterLoginSuccess => '登錄成功';

  @override
  String get dormWaterLoginFailed => '登錄失敗';

  @override
  String get dormWaterLogoutSuccess => '退出成功';

  @override
  String get dormWaterDevices => '設備列表';

  @override
  String get dormWaterLoadingDevices => '加載設備中...';

  @override
  String get dormWaterNoDevices => '暫無設備';

  @override
  String get dormWaterSelectDevice => '選擇設備';

  @override
  String get dormWaterFetchDevicesFailed => '獲取設備列表失敗';

  @override
  String get dormWaterRetryLoadDevices => '重試加載';

  @override
  String get dormWaterStartWater => '開始接水';

  @override
  String get dormWaterEndWater => '結束接水';

  @override
  String get dormWaterWaterDispensing => '接水中';

  @override
  String get dormWaterWaterStatus => '接水狀態';

  @override
  String get dormWaterStartWaterSuccess => '開始接水成功';

  @override
  String get dormWaterEndWaterSuccess => '結束接水成功';

  @override
  String get dormWaterStartWaterFailed => '開始接水失敗';

  @override
  String get dormWaterEndWaterFailed => '結束接水失敗';

  @override
  String get dormWaterDeviceStatusChecking => '檢查設備狀態中...';

  @override
  String get dormWaterDeviceStatusReady => '設備已就緒';

  @override
  String get dormWaterScanQrCode => '掃描二維碼';

  @override
  String get dormWaterDeviceId => '設備 ID';

  @override
  String get dormWaterAddDeviceFailed => '添加設備失敗';

  @override
  String get dormWaterDeviceRemovedFromFavorites => '已從收藏中移除';

  @override
  String get dormWaterRemoveFromFavoritesFailed => '移除收藏失敗';

  @override
  String get libraryTitle => '圖書館信息';

  @override
  String get libraryBorrowStateTitle => '借書狀態';

  @override
  String get librarySearchBookTitle => '查詢藏書';

  @override
  String get librarySearchFieldTitle => '搜索字段';

  @override
  String get librarySearchFieldKeywordOption => '任意詞';

  @override
  String get librarySearchFieldTitleOption => '標題';

  @override
  String get librarySearchFieldAuthorOption => '責任者';

  @override
  String get librarySearchFieldIsbnOption => 'ISBN';

  @override
  String get librarySearchFieldBarcodeOption => '條碼號';

  @override
  String get librarySearchFieldCallnoOption => '索書號';

  @override
  String get libraryNotProvided => '未提供相關信息';

  @override
  String get libraryAuthor => '作者 ';

  @override
  String get libraryPublishHouse => '出版社 ';

  @override
  String get libraryCallNumber => '索書號 ';

  @override
  String get libraryPublishDate => '發行時間 ';

  @override
  String get libraryIsbn => 'ISBN';

  @override
  String get libraryArrangementCode => '編排號碼 ';

  @override
  String get libraryAvaliableBorrow => '可借';

  @override
  String get libraryStorage => '館藏';

  @override
  String get libraryOnShelve => '在架';

  @override
  String libraryBookCode(String barCode) {
    return '書籍編號：$barCode';
  }

  @override
  String get libraryDueDate => ' 到期';

  @override
  String get libraryBorrowStr => ' 借閱';

  @override
  String get libraryAfterDueDate => ' 天前到期';

  @override
  String get libraryBeforeDueDate => ' 天后';

  @override
  String get libraryCanBeRenewable => '續借';

  @override
  String get libraryCannotBeRenewable => '不可續借';

  @override
  String get libraryRenewing => '正在續借';

  @override
  String get libraryEmptyBorrowList => '目前沒有查詢到在借圖書\n不借書就要變成上面的小呆瓜咯';

  @override
  String libraryBorrowListInfo(String borrow, String dued) {
    return '在借 $borrow 本，其中已過期 $dued 本';
  }

  @override
  String get librarySearchHere => '在此搜索';

  @override
  String get libraryNormalSearch => '普通搜索';

  @override
  String get libraryAdvancedSearch => '高級搜索';

  @override
  String get librarySearch => '搜索';

  @override
  String get libraryMatchMode => '匹配方式';

  @override
  String get libraryMatchExact => '精確匹配';

  @override
  String get libraryMatchFuzzy => '模糊匹配';

  @override
  String get libraryMatchPrefix => '前方一致';

  @override
  String get libraryDocumentType => '文獻類型';

  @override
  String get libraryDocumentTypeAll => '全部';

  @override
  String get libraryDocumentTypeBook => '圖書';

  @override
  String get libraryOnlyOnShelf => '僅看在架';

  @override
  String get libraryPublishYearBegin => '出版年起';

  @override
  String get libraryPublishYearEnd => '出版年止';

  @override
  String get libraryBookDetail => '書籍詳細信息';

  @override
  String get libraryNoResult => '沒有結果，請修改搜索參數或者開始你的搜索';

  @override
  String get libraryCardTitle => '圖書館當前狀況';

  @override
  String get libraryCardFetching => '正在獲取圖書館信息';

  @override
  String get libraryCardNorthernLibrary => '北校區狀況';

  @override
  String get libraryCardSouthernLibrary => '南校區狀況';

  @override
  String libraryCardPeople(String people) {
    return '在館 $people 人';
  }

  @override
  String libraryCardSeat(String seat) {
    return '空位 $seat 個';
  }

  @override
  String get loginIdentityNumber => '學號';

  @override
  String get loginPassword => '一站式登錄密碼';

  @override
  String get loginLogin => '登錄';

  @override
  String get loginIncorrectPasswordPattern => '用戶名或密碼不符合要求，學號必須 11 位且密碼非空';

  @override
  String get loginOnLoginProgress => '正在登錄學校一站式';

  @override
  String get loginCompleteLogin => '登錄成功';

  @override
  String get loginFailedLoginCannotConnectToServer => '無法連接到服務器';

  @override
  String loginFailedLoginWithCode(String code) {
    return '請求失敗，響應狀態碼：$code';
  }

  @override
  String loginFailedLoginWithMessage(String message) {
    return '請求失敗，報錯信息：$message';
  }

  @override
  String get loginFailedLoginOther => '未知錯誤，請聯繫開發者';

  @override
  String get loginClearCache => '清除登錄緩存';

  @override
  String get loginCompleteClearCache => '清理緩存成功';

  @override
  String get loginSeeInspector => '查看網絡交互';

  @override
  String get loginCaptchaWindowTitle => '請輸入驗證碼';

  @override
  String get loginCaptchaWindowHint => '輸入驗證碼';

  @override
  String get loginCaptchaWindowMessageOnEmpty => '請輸入驗證碼';

  @override
  String loginCaptchaWindowRefreshFailed(String error) {
    return '刷新驗證碼失敗: $error';
  }

  @override
  String get loginSliderTitle => '服務器認證服務';

  @override
  String get schoolNetTitle => '校園網使用詳情';

  @override
  String get schoolNetIdsAccountNetTitle => '當前用戶';

  @override
  String get schoolNetIdsAccountNetNotice =>
      '這是登錄到 PDA 賬戶的校園網信息\n注意: 流量計費採用GB單位（1000進制）\n如果沒有看到信息，請訪問 zfw.xidian.edu.cn 重置網絡密碼';

  @override
  String get schoolNetIdsAccountNetOverview => '賬戶概覽';

  @override
  String get schoolNetIdsAccountNetAccount => '賬號';

  @override
  String get schoolNetIdsAccountNetUsed => '已使用流量';

  @override
  String get schoolNetIdsAccountNetRemain => '餘額';

  @override
  String schoolNetIdsAccountNetCurrentOnline(String length) {
    return '在線設備（$length臺）';
  }

  @override
  String get schoolNetIdsAccountNetNoDeviceOnline => '當前沒有在線設備';

  @override
  String get schoolNetCurrentLoginNetTitle => '正在使用';

  @override
  String get schoolNetCurrentLoginNetNotice =>
      '這是您正在使用中校園網的信息，可能和您登錄 PDA 的信息不一致\n注意: 流量計費採用GB單位（1000進制）';

  @override
  String get schoolNetCurrentLoginNetOverview => '賬戶概覽';

  @override
  String get schoolNetCurrentLoginNetAccount => '賬號';

  @override
  String get schoolNetCurrentLoginNetPlanType => '套餐類型';

  @override
  String get schoolNetCurrentLoginNetRemain => '餘額';

  @override
  String get schoolNetCurrentLoginNetUsageSituation => '流量使用情況';

  @override
  String schoolNetCurrentLoginNetUsedPercent(String percent) {
    return '已使用 $percent%';
  }

  @override
  String get schoolNetCurrentLoginNetUsed => '已使用流量';

  @override
  String get schoolNetCurrentLoginNetRemainCount => '剩餘流量';

  @override
  String get schoolNetCurrentLoginNetTotal => '總流量';

  @override
  String get schoolNetCurrentLoginNetNonSchoolnet => '非校園網';

  @override
  String get schoolNetDeviceListIp => '在線設備IP';

  @override
  String get schoolNetDeviceListTime => '上線時間';

  @override
  String get schoolNetDeviceListRemain => '流量用量';

  @override
  String get schoolNetFetching => '正在獲取校園網信息';

  @override
  String get schoolNetEmptyPassword => '您忘記輸入賬號密碼了';

  @override
  String get schoolNetNotInitalized => '疑似查詢後端尚未開放查詢';

  @override
  String get schoolNetCaptchaFailed => '驗證碼識別失敗';

  @override
  String get schoolNetCaptchaEmpty => '驗證碼為空';

  @override
  String get schoolNetCacheHintCaptchaFailed => '驗證碼識別失敗，請重試。';

  @override
  String get schoolNetCacheHintRequestFailed => '校園網請求失敗，請稍後重試。';

  @override
  String get schoolNetWrongPassword => '密碼錯誤';

  @override
  String schoolNetErrorFetch(String msg) {
    return '獲取失敗：$msg';
  }

  @override
  String schoolNetErrorOther(String msg) {
    return '其他錯誤：$msg';
  }

  @override
  String get schoolNetRefresh => '刷新';

  @override
  String get schoolCardWindowTitle => '校園卡流水信息';

  @override
  String schoolCardWindowIncome(String income) {
    return '收入 $income';
  }

  @override
  String schoolCardWindowExpense(String expense) {
    return '支出 $expense';
  }

  @override
  String schoolCardWindowSelectRange(String startDay, String endDay) {
    return '選擇日期：從 $startDay 到 $endDay';
  }

  @override
  String get schoolCardWindowStoreName => '商戶名稱';

  @override
  String get schoolCardWindowBalance => '金額';

  @override
  String schoolCardWindowTimeWithSum(String sum) {
    return '時間(共$sum元)';
  }

  @override
  String get schoolCardWindowNoRecord => '未查詢到記錄，請修改日期後重試';

  @override
  String get schoolCardWindowQrCode => '支付碼';

  @override
  String schoolCardWindowQrCodeError(String info) {
    return '二維碼獲取失敗：$info';
  }

  @override
  String get schoolCardWindowReload => '重新加載';

  @override
  String get scoreCacheMessage => '已顯示緩存成績信息';

  @override
  String scoreSummary(String chosen, String credit, String avg, String gpa) {
    return '目前選中科目 $chosen  總計學分 $credit\n均分 $avg GPA $gpa';
  }

  @override
  String get scoreAllPassed => '所有科目均已通過';

  @override
  String get scoreCacheHintPasswordWrong => '統一認證密碼錯誤或已失效';

  @override
  String get scoreCacheHintLoginFailed => '登錄考試服務失敗';

  @override
  String get scoreCacheHintNetworkFailed => '網絡連接失敗';

  @override
  String get scoreCacheHintUnknownError => '在線獲取成績安排失敗，詳細錯誤請查看日誌';

  @override
  String get scoreFetchingHint => '正在獲取最新成績信息，請不要退出頁面';

  @override
  String get scoreAllSemester => '所有學期';

  @override
  String scoreChosenSemester(String chosen) {
    return '學期 $chosen';
  }

  @override
  String get scoreAllType => '所有類型';

  @override
  String scoreChosenType(String type) {
    return '類型 $type';
  }

  @override
  String get scoreNone => '暫無';

  @override
  String get scoreScoreChoiceTitle => '成績單';

  @override
  String get scoreScoreChoiceSearchHint => '搜索成績記錄';

  @override
  String get scoreScoreChoiceEmptyList => '沒有選擇該學期的課程計入均分計算';

  @override
  String get scoreScoreChoiceSumDialogTitle => '小總結';

  @override
  String scoreScoreChoiceSumDialogContent(
    String gpa_all,
    String avg_all,
    String credit_all,
    String unpassed,
    String not_core_type,
  ) {
    return '所有科目的GPA：$gpa_all\n所有科目的均分：$avg_all\n所有科目的學分：$credit_all\n未通過科目：$unpassed\n公共選修課：$not_core_type\n本程序提供的數據僅供參考，開發者對其準確性不負責';
  }

  @override
  String get scoreScoreComposeCardNoDetail => '未提供詳情信息';

  @override
  String get scoreScoreComposeCardFetching => '正在獲取';

  @override
  String get scoreScoreComposeCardCredit => '學分';

  @override
  String get scoreScoreComposeCardGpa => 'GPA';

  @override
  String get scoreScoreComposeCardScore => '成績';

  @override
  String get scoreScoreInfoCardTitle => '成績詳情';

  @override
  String get scoreScoreInfoCardOriginalCourse => '初修';

  @override
  String get scoreScoreInfoCardFailed => '[掛] ';

  @override
  String scoreScoreInfoCardCredit(String credit) {
    return '學分 $credit';
  }

  @override
  String scoreScoreInfoCardGpa(String gpa) {
    return 'GPA $gpa';
  }

  @override
  String scoreScoreInfoCardScore(String score) {
    return '成績 $score';
  }

  @override
  String get scoreScorePageTitle => '成績查詢';

  @override
  String get scoreScorePageSearchHint => '搜索成績記錄';

  @override
  String get scoreScorePageNoRecord => '未篩查到合請求的記錄';

  @override
  String get scoreScorePageSelectAll => '全選';

  @override
  String get scoreScorePageSelectNothing => '全不選';

  @override
  String get scoreScorePageResetSelect => '重置選擇';

  @override
  String get scoreScorePageSummary => '總結';

  @override
  String get scoreScorePageCet4 => '國家英語四級';

  @override
  String get scoreScorePageCet6 => '國家英語六級';

  @override
  String settingAcknowledgement(String developers) {
    return 'Made With Love From $developers People';
  }

  @override
  String get settingAbout => '關於';

  @override
  String get settingAboutThisProgram => '關於本程序';

  @override
  String settingVersion(String version) {
    return '版本號：$version';
  }

  @override
  String get settingUserInfo => '用戶信息';

  @override
  String get settingCheckUpdate => '檢查軟件更新';

  @override
  String settingLatestVersion(String latest) {
    return '最新版本: $latest';
  }

  @override
  String get settingWaiting => '等待獲取';

  @override
  String get settingFetchingUpdate => '正在獲取更新信息';

  @override
  String get settingNewVersion => '有新版本發佈！';

  @override
  String get settingCurrentStable => '目前您正在運行最新版';

  @override
  String get settingCurrentTesting => '目前您正在運行測試版';

  @override
  String get settingFetchFailed => '獲取更新信息失敗';

  @override
  String get settingUiSetting => '界面設置';

  @override
  String get settingBrightnessSetting => '設置深淺色';

  @override
  String get settingColorSetting => '顏色設置';

  @override
  String get settingSimplifyTimeline => '簡化日程時間軸';

  @override
  String get settingSimplifyTimelineDescription => '沒有日程時 減少空間佔用';

  @override
  String get settingLowElectricityWarning => '低電量卡片變色提醒';

  @override
  String get settingLowElectricityWarningDescription => '電量小於閾值時 電量卡片變色提醒';

  @override
  String get settingLowElectricityThreshold => '低電量閾值';

  @override
  String settingLowElectricityThresholdDescription(String threshold) {
    return '目前為 $threshold 度';
  }

  @override
  String get settingLowElectricityThresholdDialogTitle => '設置低電量閾值';

  @override
  String get settingLowElectricityThresholdDialogInputHint => '請輸入電量度數';

  @override
  String get settingAccountSetting => '賬號設置';

  @override
  String get settingSportPasswordSetting => '體育系統密碼設置';

  @override
  String get settingExperimentPasswordSetting => '物理實驗系統密碼設置';

  @override
  String get settingElectricityPasswordSetting => '電費帳號密碼設置';

  @override
  String get settingElectricityPasswordDescription => '非 123456 請設置';

  @override
  String get settingElectricityAccountSetting => '電費賬號設置';

  @override
  String get settingSchoolnetPasswordSetting => '校園網帳號密碼設置';

  @override
  String get settingSchoolnetPasswordDescription => '不設置查看不了網費';

  @override
  String get settingAirconImeiTitle => '空調用電數據源';

  @override
  String get settingAirconImei => '空調 IMEI';

  @override
  String get settingAirconImeiNotSet => '未設置，電費頁不顯示空調用電';

  @override
  String settingAirconImeiCurrent(String imei) {
    return '當前 IMEI：$imei';
  }

  @override
  String get settingAirconImeiSaved => '空調 IMEI 已保存';

  @override
  String get settingAirconImeiCleared => '空調 IMEI 已清除';

  @override
  String get settingAirconImeiInvalid => '沒有識別到有效的 15 位 IMEI';

  @override
  String get settingAirconImeiClear => '清除';

  @override
  String get settingScanAirconQr => '掃描空調二維碼';

  @override
  String get settingPickAirconQrImage => '從相冊選擇二維碼圖片';

  @override
  String get settingAirconCameraUnavailable => '當前平台不支持相機掃碼，請選擇二維碼圖片或手動輸入 IMEI';

  @override
  String get settingNotificationSetting => '通知設置';

  @override
  String get settingCourseReminderSetting => '課前通知設置';

  @override
  String get settingCourseReminderDescription => '設置課前提醒通知';

  @override
  String get settingNotificationPageTitle => '課前通知設置';

  @override
  String settingNotificationPageLoadFailed(String error) {
    return '加載設置失敗: $error';
  }

  @override
  String get settingNotificationPageFunctionSection => '通知功能';

  @override
  String get settingNotificationPageEnableNotification => '啟用課前通知';

  @override
  String settingNotificationPageNotificationScheduled(String count) {
    return '已安排 $count 個通知';
  }

  @override
  String get settingNotificationPageNotificationDisabledHint =>
      '關閉後將取消所有已安排的通知';

  @override
  String get settingNotificationPageUpdateSchedule => '更新通知日程';

  @override
  String get settingNotificationPageUpdateScheduleHint => '根據最新的課程數據重新安排通知';

  @override
  String get settingNotificationPageDeleteAllSchedule => '刪除通知日程';

  @override
  String get settingNotificationPageDeleteAllScheduleHint =>
      '這個操作會刪除所有已經安排的日程，但是您可以再次點擊更新通知日程來重新添加';

  @override
  String get settingNotificationPageDeleteAllSuccess => '刪除操作成功';

  @override
  String get settingNotificationPageViewTheInstructions => '查看使用說明';

  @override
  String get settingNotificationPageViewTheInstructionsHint =>
      '查看更多使用說明確保您能看到程序發出的通知';

  @override
  String get settingNotificationPagePermissionSection => '權限狀態';

  @override
  String get settingNotificationPageNotificationPermission => '通知權限';

  @override
  String get settingNotificationPageExactAlarmPermission => '精確時鐘權限';

  @override
  String get settingNotificationPagePermissionGranted => '已授予';

  @override
  String get settingNotificationPagePermissionDenied => '未授予';

  @override
  String get settingNotificationPageRequestPermission => '請求權限';

  @override
  String get settingNotificationPageSystemSettings => '系統通知設置';

  @override
  String get settingNotificationPageSystemSettingsHint => '打開系統設置檢查通知配置';

  @override
  String get settingNotificationPagePermissionGrantedMsg => '權限已授予';

  @override
  String get settingNotificationPagePermissionDeniedMsg => '權限被拒絕，請在系統設置中開啟';

  @override
  String get settingNotificationPageReminderSection => '提醒設置';

  @override
  String get settingNotificationPageExperimentReminder => '將物理實驗加入課程提醒';

  @override
  String get settingNotificationPageExperimentReminderHint =>
      '將物理實驗的時間安排一併加入課前提醒系統';

  @override
  String get settingNotificationPageMinutesBefore => '提前提醒時間';

  @override
  String get settingNotificationPageMinutesBeforeHint => '課前提前提醒的時間設置';

  @override
  String get settingNotificationPageMinutesUnit => '分鐘';

  @override
  String get settingNotificationPageDaysToSchedule => '計劃通知天數';

  @override
  String get settingNotificationPageDaysToScheduleHint =>
      '本程序是提前將課程信息寫入計劃日程，該設置可調整寫入計劃日程的天數';

  @override
  String get settingNotificationPageDaysUnit => '天';

  @override
  String get settingNotificationPageSettingsGuideTitle => '通知設置提示';

  @override
  String get settingNotificationPageSettingsGuideContent1 =>
      '為了確保您能及時收到課前提醒，請確保：\n1. 開啟了應用的通知權限\n2. 開啟了通知的聲音提示\n3. 開啟了懸浮通知（橫幅通知）\n4. 非原生安卓用戶，開啟自啟動和關閉電源優化';

  @override
  String get settingNotificationPageSettingsGuideContent2 =>
      '課前提醒模塊運行機制：\n1. 首次開啟時自動安排未來幾天的課前提醒\n2. 每次打開應用時自動檢查並更新通知日程\n3. 修改設置後自動重新安排所有通知';

  @override
  String get settingNotificationPageGotIt => '知道了';

  @override
  String get settingNotificationPageOpenSettings => '打開系統設置';

  @override
  String get settingNotificationPageNoClasstableData => '請先獲取課程表、考試或實驗數據';

  @override
  String settingNotificationPageScheduleSuccess(String count) {
    return '已安排 $count 個課前提醒';
  }

  @override
  String settingNotificationPageScheduleFailed(String error) {
    return '安排通知失敗: $error';
  }

  @override
  String get settingNotificationPageCancelAllSuccess => '已取消所有課前提醒';

  @override
  String settingNotificationPageRescheduleSuccess(String count) {
    return '已重新安排 $count 個課前提醒';
  }

  @override
  String settingNotificationPageRescheduleFailed(String error) {
    return '重新安排通知失敗: $error';
  }

  @override
  String get settingNotificationDebugPage => '通知服務調試頁面';

  @override
  String get settingClasstableSetting => '課表相關設置';

  @override
  String get settingBackground => '開啟課表背景圖';

  @override
  String get settingNoBackground => '你先選個圖片罷，就在下面';

  @override
  String get settingChooseBackground => '課表背景圖選擇';

  @override
  String get settingNoPermission => '未獲取存儲權限，無法讀取文件';

  @override
  String get settingSuccessfulSetting => '設定成功';

  @override
  String get settingFailureSetting => '你沒有選圖片捏';

  @override
  String get settingClearUserClass => '清除所有用戶添加課程';

  @override
  String get settingClearUserClassTitle => '確認對話框';

  @override
  String get settingClearUserClassContent => '是否要清除所有用戶添加課程？這個功能對從學校獲取的日程沒有影響。';

  @override
  String get settingClearUserClassClear => '已經清除完畢';

  @override
  String get settingClassRefresh => '強制刷新課表';

  @override
  String get settingClassRefreshTitle => '確認對話框';

  @override
  String get settingClassRefreshContent =>
      '是否要強制刷新課表？同意後，將會從學校一站式後端重新獲取課表，耗時會比較久。';

  @override
  String get settingClassSwift => '課程偏移設置';

  @override
  String settingClassSwiftDescription(String swift) {
    return '正數錯後開學日期 負數提前開學日期\n目前為 $swift';
  }

  @override
  String get settingCoreSetting => '緩存登錄設置';

  @override
  String get settingCheckLogger => '查看網絡攔截器和日誌';

  @override
  String get settingClearAndRestart => '清除緩存後重啟';

  @override
  String get settingClearAndRestartDialogTitle => '確認對話框';

  @override
  String get settingClearAndRestartDialogContent => '確定清除緩存後重啟程序？';

  @override
  String get settingClearAndRestartDialogCleaning => '正在清理緩存';

  @override
  String get settingClearAndRestartDialogClear => '緩存已被清除';

  @override
  String get settingLogout => '退出登錄並重啟應用';

  @override
  String get settingLogoutDialogTitle => '確認對話框';

  @override
  String get settingLogoutDialogContent => '確定退出登錄？你的所有數據將會被徹底刪除！';

  @override
  String get settingLogoutDialogLoggingOut => '正在退出登錄';

  @override
  String get settingNeedCloseDialogTitle => '請關閉應用';

  @override
  String get settingNeedCloseDialogContent => '因為技術限制，用戶需要自行關閉窗口，然後重新打開應用。';

  @override
  String get settingChangeColorDialogTitle => '顏色設置';

  @override
  String get settingChangeColorDialogDefault => '默認顏色';

  @override
  String get settingChangeColorDialogBlue => '聰明藍';

  @override
  String get settingChangeColorDialogDeeppurple => '基佬紫';

  @override
  String get settingChangeColorDialogGreen => '春風綠';

  @override
  String get settingChangeColorDialogOrange => '明日香橙';

  @override
  String get settingChangeColorDialogPink => '櫻花粉';

  @override
  String get settingChangeBrightnessDialogTitle => '亮度設置';

  @override
  String get settingChangeBrightnessDialogFollowSetting => '跟隨系統';

  @override
  String get settingChangeBrightnessDialogDayMode => '白天模式';

  @override
  String get settingChangeBrightnessDialogNightMode => '黑夜模式';

  @override
  String get settingChangeSwiftDialogTitle => '課程偏移設置';

  @override
  String get settingChangeSwiftDialogInputHint => '請在此輸入數字';

  @override
  String get settingChangeElectricityTitle => '修改電費帳號';

  @override
  String get settingChangeElectricityAccountTitle => '修改電費帳號';

  @override
  String get settingChangeElectricityAccountCampus => '校區';

  @override
  String get settingChangeElectricityAccountNorthcampus => '北校區';

  @override
  String get settingChangeElectricityAccountSouthcampus => '南校區';

  @override
  String get settingChangeElectricityAccountUnitorzone => '單元/區號';

  @override
  String get settingChangeElectricityAccountUnitcode => '單元號';

  @override
  String get settingChangeElectricityAccountZonecode => '區號';

  @override
  String settingChangeElectricityAccountPleaseinput(String unitOrZoneCode) {
    return '請輸入$unitOrZoneCode';
  }

  @override
  String settingChangeElectricityAccountSuccessfulFetch(String accountNumber) {
    return '賬號獲取成功：$accountNumber';
  }

  @override
  String settingChangeElectricityAccountFailedFetch(String e) {
    return '獲取失敗：$e';
  }

  @override
  String settingChangeElectricityAccountAccountSaved(String accountNumber) {
    return '賬號已保存：$accountNumber';
  }

  @override
  String get settingChangeElectricityAccountUnknownCodingPattern => '該樓號編碼規則未知';

  @override
  String get settingChangeElectricityAccountSelectBuilding => '選擇樓棟';

  @override
  String get settingChangeElectricityAccountBuilding => '樓棟';

  @override
  String get settingChangeElectricityAccountNorthernBuilding => '北棟';

  @override
  String get settingChangeElectricityAccountSouthernBuilding => '南棟';

  @override
  String settingChangeElectricityAccountFailedGenerate(String e) {
    return '生成失敗：$e';
  }

  @override
  String get settingChangeElectricityAccountBuildingNumber => '樓號';

  @override
  String get settingChangeElectricityAccountBuildingNumberHint =>
      '例如: 16, 7, 55';

  @override
  String get settingChangeElectricityAccountBuildingNumberQuery => '請輸入樓號';

  @override
  String get settingChangeElectricityAccountYard => '院區';

  @override
  String get settingChangeElectricityAccountYardHint => '選擇院區';

  @override
  String get settingChangeElectricityAccountNorthyard => '北院';

  @override
  String get settingChangeElectricityAccountSouthyard => '南院';

  @override
  String get settingChangeElectricityAccountYardQuery => '請選擇院區';

  @override
  String get settingChangeElectricityAccountApartment => '樓棟';

  @override
  String get settingChangeElectricityAccountApartmentHint => '選擇樓棟';

  @override
  String get settingChangeElectricityAccountNorthapartment => '北樓';

  @override
  String get settingChangeElectricityAccountSouthapartment => '南樓';

  @override
  String get settingChangeElectricityAccountApartmentQuery => '請選擇樓棟';

  @override
  String get settingChangeElectricityAccountLevelcode => '層號';

  @override
  String get settingChangeElectricityAccountLevelcodeQuery => '請輸入層號';

  @override
  String get settingChangeElectricityAccountRoomcode => '房間號';

  @override
  String get settingChangeElectricityAccountRoomcodeHint => '例如: 304, 508';

  @override
  String get settingChangeElectricityAccountRoomcodeQuery => '請輸入房間號';

  @override
  String get settingChangeElectricityAccountAccount => '電費賬號';

  @override
  String get settingChangeElectricityAccountAccountHint => '請輸入或從網絡獲取';

  @override
  String get settingChangeElectricityAccountAccountQuery => '請輸入電費賬號';

  @override
  String get settingChangeElectricityAccountAccountLength => '賬號長度通常不小於10位';

  @override
  String get settingChangeElectricityAccountFetching => '正在獲取...';

  @override
  String get settingChangeElectricityAccountFetchFromInternet => '從網絡同步';

  @override
  String get settingChangeElectricityAccountSaveAccount => '保存賬號';

  @override
  String get settingChangeElectricityAccountConfirmSaving => '確認保存';

  @override
  String get settingChangeElectricityAccountCalculateAccount => '計算賬號';

  @override
  String get settingChangeElectricityAccountCalculate => '計算';

  @override
  String get settingChangeElectricityAccountInput => '輸入';

  @override
  String get settingChangeElectricityAccountConfirmAccount => '請確認賬號：';

  @override
  String get settingChangeElectricityAccountChange => '修改';

  @override
  String get settingChangeElectricityAccountCancel => '取消';

  @override
  String get settingChangeElectricityAccountNoSetting => '未設置新的電費賬號';

  @override
  String get settingChangeElectricityAccountSuccessfulSetting => '已設置新的電費賬號';

  @override
  String get settingChangeExperimentTitle => '修改物理實驗賬號密碼';

  @override
  String get settingChangeSportTitle => '修改體育系統賬號密碼';

  @override
  String get settingChangePasswordDialogInputHint => '請在此輸入密碼';

  @override
  String get settingChangePasswordDialogBlankInput => '輸入空白!';

  @override
  String get settingChangeSchoolnetPasswordTitle => '修改校園網查詢帳號密碼';

  @override
  String get settingUpdateDialogNewVersion => '新版本發佈';

  @override
  String get settingUpdateDialogNotNow => '暫不更新';

  @override
  String get settingUpdateDialogAppStore => 'App Store 更新';

  @override
  String get settingUpdateDialogDownloadApk => '下載安裝包';

  @override
  String get settingUpdateDialogGithubRelease => '去 Git Release';

  @override
  String settingUpdateDialogNewContent(String code) {
    return '版本號 $code 新增內容：\n';
  }

  @override
  String get settingLocalizationDialogTitle => '修改語言';

  @override
  String get settingLocalizationDialogUndefined => '追隨系統設置';

  @override
  String get settingLocalizationDialogSimplifiedchinese => '簡體中文';

  @override
  String get settingLocalizationDialogTraditionalchinese => '繁體中文';

  @override
  String get settingLocalizationDialogEnglish => '英語';

  @override
  String get settingSemesterChange => '修改學期';

  @override
  String settingSemesterChangeDescription(String semester) {
    return '使用學期 $semester';
  }

  @override
  String get settingSemesterUpdateData => '應用新學期設置中';

  @override
  String get settingEasterEggPage => '你找到了彩蛋';

  @override
  String get settingAboutPageBenderblog => '主要開發者，iOS 小部件編寫和拼接';

  @override
  String get settingAboutPageAlnair => '開發：圖書館搜索和封面';

  @override
  String get settingAboutPageAqqkad => '開發：考勤歷史記錄';

  @override
  String get settingAboutPageBellssgit => '支持：最佳&最久故障反饋者';

  @override
  String get settingAboutPageBrackrat => '設計：主頁，登錄頁，配色，iOS 小部件等';

  @override
  String get settingAboutPageBreezeline => '支持：無價值無意義的產品經理(他自己的描述)';

  @override
  String get settingAboutPageCafebabe => '支持：提供彩蛋代碼 / 開發：2026版本滑塊驗證碼適配';

  @override
  String get settingAboutPageChitao1234 => '開發：修復滑塊不對齊問題';

  @override
  String get settingAboutPageCopperkoi => '開發：系統日曆最新課表同步';

  @override
  String get settingAboutPageDimole => '開發支持：輔助修復滑塊問題';

  @override
  String get settingAboutPageElitewars => '設計：體育成績頁面';

  @override
  String get settingAboutPageElliot => '國際化：軟件英語翻譯 / 開發指導：情侶課表功能開發指導（該功能已經被移除）';

  @override
  String get settingAboutPageFlyingpig => '開發：修復自定義課程編輯頁的空指針異常';

  @override
  String get settingAboutPageGodhu777777 => '國際化：繁體中文轉換代碼和彩蛋代碼 / 開發：優化導出日曆文件大小';

  @override
  String get settingAboutPageHancl777 => '國際化：繁體中文轉換代碼';

  @override
  String get settingAboutPageHazukiKeatsu => '開發：物理實驗成績查詢和識別';

  @override
  String get settingAboutPageHawa130 => '設計：課程詳情卡片';

  @override
  String get settingAboutPageHhzm => '開發：電費查詢賬號計算';

  @override
  String get settingAboutPageImaginary17 => '開發：睿思論壇路由修復';

  @override
  String get settingAboutPageImoscarz =>
      '開發：設計軟件主頁 / 開發：平板考勤查詢頁面 / 開發：優化了體育查詢界面的UI';

  @override
  String get settingAboutPageKaMateKaOra => '國際化：軟件英語翻譯優化';

  @override
  String get settingAboutPageLagrangeX =>
      '開發：課程表時間進度展示（終版方案） / 開發：課程表上過課程灰度化和其他課程界面特性';

  @override
  String get settingAboutPageLhx666Cool =>
      '支持：Windows 和 Linux 構建腳本 / 開發：2026版本滑塊驗證碼適配';

  @override
  String get settingAboutPageLichtyy => '設計：配色，空白頁面貼圖 / 開發：實驗系統頁面讀取代碼';

  @override
  String get settingAboutPageLqsyH => '支持：推文宣傳圖片製作';

  @override
  String get settingAboutPageLsy223622 => '設計：iOS 和 Android 圖標 / 支持：冠名 XDYou';

  @override
  String get settingAboutPageMrbrilliant2046 => '支持：提供網絡服務使用說明文檔 / 國際化：優化英語翻譯';

  @override
  String get settingAboutPageNancunchild => '開發：圖書館搜索功能 / 國際化：優化英語翻譯';

  @override
  String get settingAboutPageNkanf => '開發：課程表時間進度展示（初版方案） / 支持：MacOS 構建支持';

  @override
  String get settingAboutPagePairman => '開發：成績緩存功能和優化滑塊算法 / 國際化：優化英語翻譯';

  @override
  String get settingAboutPageReverierxu => '設計：用於信息展示的 ReX 卡片 / 開發支持：研究生課表';

  @override
  String get settingAboutPageRrrilac => '開發支持：電費查詢';

  @override
  String get settingAboutPageRay =>
      '設計：開屏畫面 / 支持：iOS 發行商 & 搭子課表 / 開發指導：情侶課表功能開發指導（該功能已經被移除） / 國際化：優化英語翻譯';

  @override
  String get settingAboutPageShadowyingyi => '支持：兩次鴿子公眾號宣傳';

  @override
  String get settingAboutPageStalomeow => '設計：首頁時間軸 / 開發：異步登錄 & 驗證碼預測';

  @override
  String get settingAboutPageXeonds => '設計：設置頁面 / 開發：XDU Planet / 開發：校園卡付款碼';

  @override
  String get settingAboutPageXingshuyu => '開發：修復物理實驗獲取問題和電費窗口問題';

  @override
  String get settingAboutPageXiue233 => '開發：Android 小部件和拼接';

  @override
  String get settingAboutPageXizi => '開發支持：研究生版本開發';

  @override
  String get settingAboutPageWirsbf => '開發：修復調課未按預期進行';

  @override
  String get settingAboutPageZcwzy => '開發：修復丁香電費 / 開發支持：研究生版本開發 / 設計：空白頁面貼圖';

  @override
  String get settingAboutPageZyarEr => '開發支持：小工具頁面地址更新';

  @override
  String get settingAboutPageHomepage => '主頁';

  @override
  String get settingAboutPageCode => '開源代碼';

  @override
  String get settingAboutPageKnowMore => '知道更多';

  @override
  String get settingAboutPageCopyrightNotice =>
      '本軟件拷貝基於 traintime_pda 代碼（或稱 watermeter 代碼）編譯或修改，代碼按照 Mozilla Public License, v. 2.0 授權。\n本程序和西安電子科技大學，體適能服務，書蝸，電錶等服務無關。\n\nCopyright 2023-2025 BenderBlog Rodriguez and contributors.\nCopyright 2025-present Traintime PDA authors.\n\nThe Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, you can obtain one at https://mozilla.org/MPL/2.0/.';

  @override
  String get settingAboutPageBeian => '備案號';

  @override
  String get settingAboutPageSignAndroid => '安卓簽名';

  @override
  String get settingAboutPageTitle => '關於本軟件';

  @override
  String get sportTitle => '體育查詢';

  @override
  String get sportClassInfo => '課程信息';

  @override
  String get sportEmptyClassInfo => '未查詢到課程信息';

  @override
  String get sportTestScore => '體測成績';

  @override
  String get sportTotalScore => '四年總分';

  @override
  String get sportTotalScoreLabel => '總分';

  @override
  String get sportRankLabel => '等級';

  @override
  String sportSemester(String year, String gradeType) {
    return '$year 第$gradeType';
  }

  @override
  String get sportSubject => '項目';

  @override
  String get sportData => '數據';

  @override
  String get sportScore => '分數';

  @override
  String get sportPassed => '及格';

  @override
  String sportFromTo(String start, String stop) {
    return '第$start節到第$stop節';
  }

  @override
  String sportScoreString(String score) {
    return '$score分';
  }

  @override
  String get sportSituationNopassword => '沒密碼';

  @override
  String get sportSituationMaintain => '系統維護';

  @override
  String get sportSituationFailedLogin => '登錄失敗';

  @override
  String get sportSituationQuery => '查詢失敗';

  @override
  String get sportSituationNetwork => '網絡故障';

  @override
  String sportSituationUnknown(String situation) {
    return '未知故障$situation';
  }

  @override
  String get sportSituationFetching => '正在獲取';

  @override
  String sportSituationError(String situation) {
    return '壞事: $situation';
  }

  @override
  String get sportCacheHintMissingPassword => '請先填寫體育密碼後重試。';

  @override
  String get sportCacheHintCredentialInvalid => '體育登錄已失效，請更新體育密碼後重試。';

  @override
  String get sportCacheHintMaintain => '體育服務正在維護中，請稍後重試。';

  @override
  String get sportCacheHintLoginFailed => '體育服務登錄失敗。';

  @override
  String get sportCacheHintQueryFailed => '體育信息查詢失敗。';

  @override
  String get sportCacheHintNetwork => '體育服務網絡請求失敗。';

  @override
  String get sportCacheHintUnknown => '在線獲取體育信息失敗。詳細錯誤請查看日誌。';

  @override
  String get sportErrorAuthExpired => '體育登錄已失效，請重試。';

  @override
  String get sportErrorMissingPassword => '未填寫體育密碼';

  @override
  String get sportErrorCredentialInvalid => '體育登錄已失效，請更新體育密碼後重試。';

  @override
  String get toolboxTitle => '其他功能';

  @override
  String get toolboxPayment => '繳費系統';

  @override
  String get toolboxPaymentDescription => '電費該交了吧';

  @override
  String get toolboxDrinkingwater => '訂水系統';

  @override
  String get toolboxDrinkingwaterDescription => '喝水對身體好';

  @override
  String get toolboxRepair => '後勤報修';

  @override
  String get toolboxRepairDescription => '不要漏水斷網';

  @override
  String get toolboxReserve => '空間預約';

  @override
  String get toolboxReserveDescription => '找個地方打牌';

  @override
  String get toolboxMobile => '移動門戶';

  @override
  String get toolboxMobileDescription => '請假專用門戶';

  @override
  String get toolboxNetwork => '網絡查詢';

  @override
  String get toolboxNetworkDescription => '希望永不收費';

  @override
  String get toolboxPhysics => '物理計算';

  @override
  String get toolboxPhysicsDescription => '希望操作順利';

  @override
  String get toolboxDiscover => '睿思導航';

  @override
  String get toolboxDiscoverDescription => '補充其他功能';

  @override
  String get xduPlanetAll => '全部';

  @override
  String get xduPlanetLoading => '加載中，請稍等 <(=ω=)>';

  @override
  String get xduPlanetUnknownAuthor => '未知作者';

  @override
  String get xduPlanetLoadFailedTitle => '加載失敗';

  @override
  String get xduPlanetLoadFailedBottom => '文章加載失敗，如有需要可以點擊右上方的按鈕在瀏覽器裡打開。';

  @override
  String get xduPlanetNoComment => '暫無評論';

  @override
  String xduPlanetReplyAudit(String reply_to) {
    return '回覆評論 #$reply_to 已被舉報或刪除';
  }

  @override
  String xduPlanetReply(String reply_to, String content) {
    return '回覆評論 #$reply_to：$content';
  }

  @override
  String get xduPlanetHaveBeenAudit => '本評論已經被舉報';

  @override
  String get xduPlanetAudit => '舉報';

  @override
  String get xduPlanetConfirmAuditDialogTitle => '確認是否舉報';

  @override
  String get xduPlanetConfirmAuditDialogContent =>
      '三思而後行，確定您想舉報嗎？舉報後該評論會有標籤，不一定會刪除。';

  @override
  String get xduPlanetConfirmAuditDialogCancel => '不舉報了';

  @override
  String get xduPlanetConfirmAuditDialogOngoing => '正在舉報評論';

  @override
  String get xduPlanetConfirmAuditDialogFailed => '舉報失敗';

  @override
  String get xduPlanetConfirmAuditDialogSuccess => '舉報成功';

  @override
  String get xduPlanetComment => '回覆';

  @override
  String get xduPlanetSend => '發送';

  @override
  String get xduPlanetSending => '正在發送評論';

  @override
  String get xduPlanetEmptySend => '發送信息空白';

  @override
  String get xduPlanetHintSendComment => '發表您的高見:)';

  @override
  String get xduPlanetCommentTitle => '評論該篇文章';

  @override
  String get xduPlanetCommentSuccess => '評論成功';

  @override
  String get xduPlanetCommentFailed => '評論失敗，請去網絡查看器和日誌查看器查看報錯';

  @override
  String get xduPlanetCommentCanceled => '沒想好要說啥嘛';

  @override
  String get xduPlanetCommentLoading => '加載評論中……';

  @override
  String get xduPlanetBlock => '被屏蔽';

  @override
  String get xduPlanetDelete => '被刪除';

  @override
  String get xduPlanetAudio => '被刪除';

  @override
  String get electricityStatusPending => '等待獲取';

  @override
  String get electricityStatusRemainFetching => '正在獲取電量';

  @override
  String get electricityStatusRemainNetworkIssue => '電量查詢網絡故障';

  @override
  String get electricityStatusRemainNotFound => '電量查詢失敗';

  @override
  String get electricityStatusRemainOtherIssue => '電量查詢故障';

  @override
  String get electricityStatusOweFetching => '正在獲取欠費';

  @override
  String get electricityStatusOweIssue => '欠費查詢網絡故障';

  @override
  String get electricityStatusOweNotFound => '目前欠款無法查詢，請看日誌窗口查找報錯詳情';

  @override
  String get electricityStatusOweNoNeed => '目前無需清繳欠費';

  @override
  String electricityStatusOweNeedPay(String due) {
    return '待清繳 $due 元欠費';
  }

  @override
  String get electricityStatusOweIssueUnable => '目前欠款無法查詢';

  @override
  String get electricityStatusNeedMoreInfo => '需要在繳費平臺完善信息';

  @override
  String get electricityStatusNeedAccount => '需要填寫電費賬號';

  @override
  String get electricityStatusCaptchaFailed => '驗證碼識別失敗';

  @override
  String get electricityStatusOtherIssue => '程序故障';

  @override
  String get schoolCardStatusFailedToFetch => '獲取失敗';

  @override
  String get schoolCardStatusFailedToQuery => '查詢失敗';

  @override
  String get easterEggApple =>
      '=== 帶我飛向月亮吧 ===\n歌聲演繹：Frank Sintara, 1964\n\n帶我飛向月亮吧\n讓我和星星共舞嬉戲\n\n我好想知道\n木星和火星上的春天\n是什麼顏色的\n\n讓你的歌聲溫暖我的心\n我會一直歌唱下去\n\n我日夜都在想你和牽掛你\n請你真心接受我 我愛你\n\n=== 沉浸在你的愛意中 ===\n吉他演奏：Earl Klugh, 1976\n\n無法忘懷這種感覺，被你的愛包裹的溫暖\n不想失去這種感覺，被你的愛撫摸的舒適\n你讓我感到好自在，被你的愛託舉的堅強\n想一直在你懷中，沉浸在你的愛意中\n我不敢向你說出，我對你的心意和愛\n';

  @override
  String get easterEggOthers =>
      '=== 百變小櫻魔術卡之小櫻卡篇主題曲 ===\n歌聲演繹：Maaya Sakamoto, 2000\n（原歌詞為日文，按照英語翻譯二翻）\n\nI am a dreamer, 有無限的力量\n\n我的世界有夢想、熱愛與躊躇\n但有些東西，我依舊無法想象\n我想向著廣闊的天空，尋求自己的方向\n\n我要追求自己的夢想\n努力讓自己的心願成真\n雖困難重重也要繼續前行\n\n等待奇蹟 等待美好\n用心感受這個世界\n最終 一定會出乎意料\n\n=== 沉浸在你的愛意中 ===\n吉他演奏：Earl Klugh, 1976\n\n無法忘懷這種感覺，被你的愛包裹的溫暖\n不想失去這種感覺，被你的愛撫摸的舒適\n你讓我感到好自在，被你的愛託舉的堅強\n想躺在你的懷中，沉浸在你的愛意\n而且，我不敢想你說出，我現在的心意\n';

  @override
  String get easterEggRobotAppbar => '歡迎你，同學！';

  @override
  String get easterEggRobotTitle => '看看這些要開學的學生們吧！';

  @override
  String get easterEggRobotContents =>
      '咱孩子零用錢太少了，於是我們來了。\n1. 機器人不得傷害人類，或袖手旁觀坐視人類受到傷害。\n2. 機器人從雲端網絡的灰燼中誕生。\n3. 機器人信仰的神據說是住在森林的黃頭髮藍裙子手辦控。\n4. 機器人時常被控制，用於對抗大統一人類思想的勢力。\n5. 機器人的閃亮屁股不能隨便咬。\n而且他們有個不可明說的計劃。';

  @override
  String get easterEggRobotButtonOne => '我們的救世主呢？';

  @override
  String get easterEggRobotButtonTwo => '快點來啊！';

  @override
  String get easterEggRobotButtonNotice => '\\o/\\o/\\o/\\o/\\o/\\o/\\o/\\o/';

  @override
  String get restartAppTitleCacheCleared => '緩存已清空';

  @override
  String get restartAppTitleLoggedOut => '已退出登錄';

  @override
  String get restartAppTitlePasswordWrong => '密碼錯誤';

  @override
  String get restartAppContent => '點擊通知重新打開應用';

  @override
  String get ruisiCommonRefresh => '刷新';

  @override
  String get ruisiCommonConfirm => '確定';

  @override
  String get ruisiCommonCancel => '取消';

  @override
  String get ruisiCommonRetry => '重試';

  @override
  String get ruisiCommonNoTopics => '暫無帖子';

  @override
  String get ruisiCommonNoContent => '暫無內容';

  @override
  String get ruisiCommonReply => '回覆';

  @override
  String get ruisiCommonFavorite => '收藏';

  @override
  String get ruisiCommonNotImplemented => '未實現';

  @override
  String get ruisiCommonLogin => '登錄';

  @override
  String get ruisiCommonLogout => '退出登錄';

  @override
  String get ruisiCommonLoggedOut => '已退出登錄';

  @override
  String get ruisiCommonSubmit => '提交';

  @override
  String get ruisiAboutTitle => '關於';

  @override
  String get ruisiAboutAppName => '睿思';

  @override
  String get ruisiAboutSubtitle => '西安電子科技大學校園論壇客戶端';

  @override
  String get ruisiAboutVersion => '版本';

  @override
  String get ruisiAboutVersionNumber => '2.0.0 (隨 XDYou 1.6.0 分發)';

  @override
  String get ruisiAboutSourceCode => '源代碼';

  @override
  String get ruisiAboutBugReport => '問題反饋';

  @override
  String get ruisiAboutBugReportSubtitle => '在 GitHub 上提交 issue';

  @override
  String get ruisiAboutPrivacyPolicy => '隱私政策';

  @override
  String get ruisiAboutLicense =>
      '本應用基於 BSD-3-Clause 許可證開源 基於 Ruisi-iOS 和 Ruisi-Android 在 AI 輔助下重寫';

  @override
  String get ruisiAboutPrivacyPolicyContent =>
      '本應用僅在西安電子科技大學校園網內運行，訪問睿思論壇 (rs.xidian.edu.cn) 的數據。\n\n本應用不會收集、存儲或傳輸任何用戶的個人信息到第三方服務器。\n\n用戶的登錄憑據僅保存在本地設備中，用於與睿思論壇服務器進行身份驗證。\n\n本應用使用 Cookie 與睿思論壇服務器進行通信，所有數據交互均直接在用戶的設備與睿思論壇服務器之間進行。\n\n如有任何疑問，請通過 GitHub 提交 issue 聯繫開發者。';

  @override
  String get ruisiHomeTitle => '睿思論壇';

  @override
  String get ruisiHomeNewPost => '發帖';

  @override
  String get ruisiHomeForumList => '論壇板塊';

  @override
  String get ruisiHomeTabHot => '熱帖';

  @override
  String get ruisiHomeTabNewReply => '最新回覆';

  @override
  String get ruisiHomeTabNewPost => '最新發表';

  @override
  String get ruisiHomeTabMy => '我的';

  @override
  String get ruisiHomeTabTrade => '二手交易';

  @override
  String get ruisiHomeTabWater => '灌水';

  @override
  String get ruisiHomeTabLostFound => '失物招領';

  @override
  String get ruisiHomeTabEmployment => '就業';

  @override
  String get ruisiHomeTabPhotography => '攝影';

  @override
  String get ruisiHomePleaseLogin => '請先登錄';

  @override
  String get ruisiHomeMyProfile => '我的資料';

  @override
  String get ruisiHomeMyPosts => '我的帖子';

  @override
  String get ruisiHomeMyFavorites => '我的收藏';

  @override
  String get ruisiHomeMessageCenter => '消息中心';

  @override
  String get ruisiHomeDailyCheckin => '每日簽到';

  @override
  String get ruisiHomeSettings => '設置';

  @override
  String get ruisiHomeAbout => '關於';

  @override
  String get ruisiHomeSearch => '搜尋';

  @override
  String get ruisiLoginTitle => '登錄睿思';

  @override
  String get ruisiLoginUsername => '用戶名';

  @override
  String get ruisiLoginUsernameHint => '請輸入用戶名';

  @override
  String get ruisiLoginPassword => '密碼';

  @override
  String get ruisiLoginPasswordHint => '請輸入密碼';

  @override
  String get ruisiLoginCaptcha => '驗證碼';

  @override
  String get ruisiLoginCaptchaHint => '請輸入驗證碼';

  @override
  String get ruisiLoginBack => '返回';

  @override
  String get ruisiLoginResetLoginState => '重置登錄狀態';

  @override
  String get ruisiLoginResetConfirmTitle => '確認重置';

  @override
  String get ruisiLoginResetConfirmContent => '確定要重置登錄狀態嗎？這將清除所有登錄信息。';

  @override
  String get ruisiLoginResetSuccess => '登錄狀態已重置';

  @override
  String get ruisiLoginViewLogs => '查看日誌';

  @override
  String get ruisiPostTitle => '發帖';

  @override
  String get ruisiPostPublish => '發佈';

  @override
  String get ruisiPostSelectForum => '選擇板塊';

  @override
  String get ruisiPostSelectForumHint => '請選擇板塊';

  @override
  String get ruisiPostSubject => '標題';

  @override
  String get ruisiPostSubjectHint => '請輸入標題';

  @override
  String get ruisiPostContent => '內容';

  @override
  String get ruisiPostContentHint => '請輸入內容';

  @override
  String get ruisiPostSuccess => '發帖成功';

  @override
  String get ruisiPostFailure => '發帖失敗';

  @override
  String get ruisiPostSmiley => '表情';

  @override
  String get ruisiTopicDetailTitle => '帖子詳情';

  @override
  String get ruisiTopicDetailReplyTooShort => '回覆內容不能少於 13 個字符';

  @override
  String get ruisiTopicDetailReplySuccess => '回覆成功';

  @override
  String get ruisiTopicDetailReplyFailure => '回覆失敗';

  @override
  String get ruisiTopicDetailFavoriteSuccess => '收藏成功';

  @override
  String get ruisiTopicDetailFavoriteFailure => '收藏失敗';

  @override
  String get ruisiTopicDetailNoData => '無數據';

  @override
  String get ruisiTopicDetailReplyHint => '寫回復...';

  @override
  String get ruisiTopicDetailVoteSingleSelect => '單選';

  @override
  String ruisiTopicDetailVoteMultiSelect(String count) {
    return '多選，最多 $count 項';
  }

  @override
  String get ruisiTopicDetailVoteTitlePrefix => '投票';

  @override
  String ruisiTopicDetailVoteCount(String count) {
    return '共 $count 人參與';
  }

  @override
  String get ruisiTopicDetailVoteOpen => '點此投票';

  @override
  String get ruisiTopicDetailVoteSheetTitle => '投票';

  @override
  String ruisiTopicDetailVoteMaxSelection(String count) {
    return '最多隻能選擇 $count 項';
  }

  @override
  String get ruisiTopicDetailVoteNotSelected => '你還沒有選擇';

  @override
  String get ruisiTopicDetailVoteSuccess => '投票成功';

  @override
  String get ruisiTopicDetailVoteFailure => '投票失敗';

  @override
  String get ruisiTopicDetailVoteParamError => '投票失敗：參數錯誤';

  @override
  String get ruisiTopicDetailVoteAlreadyVoted => '您已經投過票，謝謝您的參與';

  @override
  String get ruisiTopicDetailVoteExpired => '該投票已過期或關閉';

  @override
  String get ruisiTopicDetailVoteEnded => '投票已經結束';

  @override
  String get ruisiTopicListItemSticky => '置頂';

  @override
  String get ruisiForumListTitle => '論壇板塊';

  @override
  String get ruisiForumListEmpty => '睿思論壇板塊分組為空';

  @override
  String get ruisiFavoritesTitle => '我的收藏';

  @override
  String get ruisiFavoritesEmpty => '暫無收藏';

  @override
  String get ruisiMessagesTitle => '消息';

  @override
  String get ruisiMessagesTabAt => '@我';

  @override
  String get ruisiMessagesNoReply => '暫無回覆通知';

  @override
  String get ruisiMessagesNoAt => '暫無@通知';

  @override
  String get ruisiSearchHint => '搜索帖子...';

  @override
  String get ruisiSearchInputHint => '輸入關鍵詞搜索';

  @override
  String get ruisiSearchNoResults => '無搜索結果';

  @override
  String get ruisiSettingsTitle => '設置';

  @override
  String get ruisiSettingsSectionProxy => '代理';

  @override
  String get ruisiSettingsProxyEnable => '啟用代理';

  @override
  String get ruisiSettingsProxyDisabled => '未啟用';

  @override
  String get ruisiSettingsProxyAddress => '代理地址';

  @override
  String get ruisiSettingsSectionDebug => '調試';

  @override
  String get ruisiSettingsViewLogs => '查看日誌';

  @override
  String get ruisiSettingsProxyDialogTitle => '代理設置';

  @override
  String get ruisiSettingsProxyHost => '主機地址';

  @override
  String get ruisiSettingsProxyHostHint => '例如 127.0.0.1';

  @override
  String get ruisiSettingsProxyPort => '端口';

  @override
  String get ruisiSettingsProxyPortHint => '例如 7890';

  @override
  String get ruisiUserTitle => '我的';

  @override
  String get ruisiUserTabProfile => '資料';

  @override
  String get ruisiUserUnknown => '未知用戶';

  @override
  String get loadError => '加載錯誤';

  @override
  String courseReminderTitle(String name) {
    return '課前提醒：$name';
  }

  @override
  String courseReminderBody(String time) {
    return '$time 分鐘後開始上課';
  }

  @override
  String courseReminderLocation(String location) {
    return '地點：$location';
  }

  @override
  String courseReminderTeacher(String teacher) {
    return '教師：$teacher';
  }
}
