///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'translations.g.dart';

// Path: <root>
typedef TranslationsZh = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.zh,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <zh>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$common$zh common = Translations$common$zh.internal(_root);
	late final Translations$core$zh core = Translations$core$zh.internal(_root);
	late final Translations$ids$zh ids = Translations$ids$zh.internal(_root);
	late final Translations$settings$zh settings = Translations$settings$zh.internal(_root);
	late final Translations$timetable$zh timetable = Translations$timetable$zh.internal(_root);
}

// Path: common
class Translations$common$zh {
	Translations$common$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '确认'
	String get confirm => '确认';

	/// zh: '取消'
	String get cancel => '取消';

	/// zh: '一个小问题 :P'
	String get unexpectProblemTitle => '一个小问题 :P';

	/// zh: '这里有一个没有被预料的问题发生了！'
	String get unexpectProblemHint => '这里有一个没有被预料的问题发生了！';

	/// zh: 'Ouch! 发生错误啦'
	String get errorDetected => 'Ouch! 发生错误啦';

	/// zh: '点我刷新'
	String get clickToRefresh => '点我刷新';
}

// Path: core
class Translations$core$zh {
	Translations$core$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$core$language$zh language = Translations$core$language$zh.internal(_root);
	late final Translations$core$theme$zh theme = Translations$core$theme$zh.internal(_root);
	late final Translations$core$gridPage$zh gridPage = Translations$core$gridPage$zh.internal(_root);
}

// Path: ids
class Translations$ids$zh {
	Translations$ids$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '学号或工号'
	String get username => '学号或工号';

	/// zh: '密码'
	String get password => '密码';

	/// zh: '请重新登录'
	String get reauthenticate => '请重新登录';

	/// zh: '保存的密码已被拒绝，请输入当前密码继续。'
	String get reauthenticateMessage => '保存的密码已被拒绝，请输入当前密码继续。';

	/// zh: '登录'
	String get login => '登录';

	/// zh: '登录中…'
	String get loggingIn => '登录中…';

	/// zh: '登录失败，请检查账号、密码或网络后重试'
	String get loginFailed => '登录失败，请检查账号、密码或网络后重试';

	/// zh: '账号或密码错误。'
	String get credentialsRejected => '账号或密码错误。';

	/// zh: '网络不可用，请重试。'
	String get networkUnavailable => '网络不可用，请重试。';

	/// zh: '已取消登录。'
	String get loginCancelled => '已取消登录。';

	/// zh: '退出账号'
	String get logout => '退出账号';

	/// zh: '滑块验证'
	String get sliderTitle => '滑块验证';

	/// zh: '验证失败，请使用新图片重试。'
	String get sliderRetry => '验证失败，请使用新图片重试。';

	/// zh: '选择二次认证方式'
	String get mfaMethodTitle => '选择二次认证方式';

	/// zh: '短信验证码'
	String get smsCode => '短信验证码';

	/// zh: '企业微信验证码'
	String get wechatCode => '企业微信验证码';

	/// zh: '二次认证'
	String get mfaTitle => '二次认证';

	/// zh: '验证码已发送'
	String get codeSent => '验证码已发送';

	/// zh: '请输入验证码'
	String get codeRequired => '请输入验证码';

	/// zh: '验证码错误，请重试'
	String get codeInvalid => '验证码错误，请重试';

	/// zh: '信任此设备'
	String get trustDevice => '信任此设备';

	/// zh: '提交'
	String get submit => '提交';

	/// zh: '发送验证码'
	String get sendCode => '发送验证码';

	/// zh: '{seconds} 秒后重发'
	String resendCountdown({required Object seconds}) => '${seconds} 秒后重发';

	/// zh: '下次可减少验证'
	String get trustDeviceHint => '下次可减少验证';

	/// zh: '验证码发送失败，请重试'
	String get codeSendFailed => '验证码发送失败，请重试';

	late final Translations$ids$logoutDialog$zh logoutDialog = Translations$ids$logoutDialog$zh.internal(_root);
}

// Path: settings
class Translations$settings$zh {
	Translations$settings$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '设置'
	String get title => '设置';

	/// zh: '程序信息'
	String get aboutInfo => '程序信息';

	/// zh: 'Made With Love From {developers} People'
	String acknowledgement({required Object developers}) => 'Made With Love From ${developers} People';

	/// zh: '关于'
	String get about => '关于';

	/// zh: '关于本程序'
	String get aboutThisProgram => '关于本程序';

	/// zh: '版本号：{version}'
	String version({required Object version}) => '版本号：${version}';

	/// zh: '用户信息'
	String get userInfo => '用户信息';

	/// zh: '检查软件更新'
	String get checkUpdate => '检查软件更新';

	/// zh: '最新版本: {latest}'
	String latestVersion({required Object latest}) => '最新版本: ${latest}';

	/// zh: '等待获取'
	String get waiting => '等待获取';

	/// zh: '正在获取更新信息'
	String get fetchingUpdate => '正在获取更新信息';

	/// zh: '有新版本发布，请立刻更新！'
	String get newVersion => '有新版本发布，请立刻更新！';

	/// zh: '目前您正在运行最新版'
	String get currentStable => '目前您正在运行最新版';

	/// zh: '目前您正在运行测试版'
	String get currentTesting => '目前您正在运行测试版';

	/// zh: '获取更新信息失败'
	String get fetchFailed => '获取更新信息失败';

	/// zh: '界面设置'
	String get uiSetting => '界面设置';

	/// zh: '深浅色模式'
	String get brightnessSetting => '深浅色模式';

	/// zh: '颜色设置'
	String get colorSetting => '颜色设置';

	/// zh: '简化日程时间轴'
	String get simplifyTimeline => '简化日程时间轴';

	/// zh: '没有日程时 减少空间占用'
	String get simplifyTimelineDescription => '没有日程时 减少空间占用';

	/// zh: '低电量卡片变色提醒'
	String get lowElectricityWarning => '低电量卡片变色提醒';

	/// zh: '电量小于阈值时 电量卡片变色提醒'
	String get lowElectricityWarningDescription => '电量小于阈值时 电量卡片变色提醒';

	/// zh: '低电量阈值'
	String get lowElectricityThreshold => '低电量阈值';

	/// zh: '当前为 {threshold} 度'
	String lowElectricityThresholdDescription({required Object threshold}) => '当前为 ${threshold} 度';

	late final Translations$settings$lowElectricityThresholdDialog$zh lowElectricityThresholdDialog = Translations$settings$lowElectricityThresholdDialog$zh.internal(_root);

	/// zh: '账号设置'
	String get accountSetting => '账号设置';

	/// zh: '体育系统密码设置'
	String get sportPasswordSetting => '体育系统密码设置';

	/// zh: '物理实验系统密码设置'
	String get experimentPasswordSetting => '物理实验系统密码设置';

	/// zh: '电费帐号密码设置'
	String get electricityPasswordSetting => '电费帐号密码设置';

	/// zh: '非 123456 请设置'
	String get electricityPasswordDescription => '非 123456 请设置';

	/// zh: '电费账号设置'
	String get electricityAccountSetting => '电费账号设置';

	/// zh: '校园网帐号密码设置'
	String get schoolnetPasswordSetting => '校园网帐号密码设置';

	/// zh: '不设置查看不了网费'
	String get schoolnetPasswordDescription => '不设置查看不了网费';

	/// zh: '空调设备'
	String get airconImeiTitle => '空调设备';

	/// zh: '空调 IMEI'
	String get airconImei => '空调 IMEI';

	/// zh: '未设置，无法查询或遥控空调'
	String get airconImeiNotSet => '未设置，无法查询或遥控空调';

	/// zh: '当前 IMEI：{imei}'
	String airconImeiCurrent({required Object imei}) => '当前 IMEI：${imei}';

	/// zh: '空调 IMEI 已保存'
	String get airconImeiSaved => '空调 IMEI 已保存';

	/// zh: '空调 IMEI 已清除'
	String get airconImeiCleared => '空调 IMEI 已清除';

	/// zh: '没有识别到有效的 15 位 IMEI'
	String get airconImeiInvalid => '没有识别到有效的 15 位 IMEI';

	/// zh: '清除'
	String get airconImeiClear => '清除';

	/// zh: '扫描空调二维码'
	String get scanAirconQr => '扫描空调二维码';

	/// zh: '从相册选择二维码图片'
	String get pickAirconQrImage => '从相册选择二维码图片';

	/// zh: '当前平台不支持相机扫码，请选择二维码图片或手动输入 IMEI'
	String get airconCameraUnavailable => '当前平台不支持相机扫码，请选择二维码图片或手动输入 IMEI';

	/// zh: '轻点画面可以对焦；空调离得远、放大后仍然模糊时，请用系统相机拍照识别'
	String get airconScanHint => '轻点画面可以对焦；空调离得远、放大后仍然模糊时，请用系统相机拍照识别';

	/// zh: '用系统相机拍照识别'
	String get airconTakePhoto => '用系统相机拍照识别';

	/// zh: '无法打开相机：{error}'
	String airconCameraError({required Object error}) => '无法打开相机：${error}';

	/// zh: '通知设置'
	String get notificationSetting => '通知设置';

	/// zh: '课前通知设置'
	String get courseReminderSetting => '课前通知设置';

	/// zh: '设置课前提醒通知'
	String get courseReminderDescription => '设置课前提醒通知';

	late final Translations$settings$notificationPage$zh notificationPage = Translations$settings$notificationPage$zh.internal(_root);

	/// zh: '通知状态与测试'
	String get notificationDebugPage => '通知状态与测试';

	/// zh: '课表相关设置'
	String get classtableSetting => '课表相关设置';

	/// zh: '开启课表背景图'
	String get background => '开启课表背景图';

	/// zh: '你先选个图片罢，就在下面'
	String get noBackground => '你先选个图片罢，就在下面';

	/// zh: '课表背景图选择'
	String get chooseBackground => '课表背景图选择';

	/// zh: '未获取存储权限，无法读取文件'
	String get noPermission => '未获取存储权限，无法读取文件';

	/// zh: '设定成功'
	String get successfulSetting => '设定成功';

	/// zh: '你没有选图片捏'
	String get failureSetting => '你没有选图片捏';

	/// zh: '清除所有用户添加课程'
	String get clearUserClass => '清除所有用户添加课程';

	/// zh: '确认对话框'
	String get clearUserClassTitle => '确认对话框';

	/// zh: '是否要清除所有用户添加课程？这个功能对从学校获取的日程没有影响。'
	String get clearUserClassContent => '是否要清除所有用户添加课程？这个功能对从学校获取的日程没有影响。';

	/// zh: '已经清除完毕'
	String get clearUserClassClear => '已经清除完毕';

	/// zh: '强制刷新课表'
	String get classRefresh => '强制刷新课表';

	/// zh: '确认对话框'
	String get classRefreshTitle => '确认对话框';

	/// zh: '是否要强制刷新课表？同意后，将会从学校一站式后端重新获取课表，耗时会比较久。'
	String get classRefreshContent => '是否要强制刷新课表？同意后，将会从学校一站式后端重新获取课表，耗时会比较久。';

	/// zh: '课程偏移设置'
	String get classSwift => '课程偏移设置';

	/// zh: '目前为 {swift}'
	String classSwiftDescription({required Object swift}) => '目前为 ${swift}';

	/// zh: '缓存登录设置'
	String get coreSetting => '缓存登录设置';

	/// zh: '查看网络拦截器和日志'
	String get checkLogger => '查看网络拦截器和日志';

	/// zh: '清除缓存后重启'
	String get clearAndRestart => '清除缓存后重启';

	late final Translations$settings$clearAndRestartDialog$zh clearAndRestartDialog = Translations$settings$clearAndRestartDialog$zh.internal(_root);

	/// zh: '退出登录并重启应用'
	String get logout => '退出登录并重启应用';

	late final Translations$settings$logoutDialog$zh logoutDialog = Translations$settings$logoutDialog$zh.internal(_root);
	late final Translations$settings$needCloseDialog$zh needCloseDialog = Translations$settings$needCloseDialog$zh.internal(_root);
	late final Translations$settings$changeColorDialog$zh changeColorDialog = Translations$settings$changeColorDialog$zh.internal(_root);
	late final Translations$settings$changeBrightnessDialog$zh changeBrightnessDialog = Translations$settings$changeBrightnessDialog$zh.internal(_root);
	late final Translations$settings$changeSwiftDialog$zh changeSwiftDialog = Translations$settings$changeSwiftDialog$zh.internal(_root);

	/// zh: '修改电费帐号'
	String get changeElectricityTitle => '修改电费帐号';

	late final Translations$settings$changeElectricityAccount$zh changeElectricityAccount = Translations$settings$changeElectricityAccount$zh.internal(_root);

	/// zh: '修改物理实验账号密码'
	String get changeExperimentTitle => '修改物理实验账号密码';

	/// zh: '修改体育系统账号密码'
	String get changeSportTitle => '修改体育系统账号密码';

	late final Translations$settings$changePasswordDialog$zh changePasswordDialog = Translations$settings$changePasswordDialog$zh.internal(_root);

	/// zh: '修改校园网查询帐号密码'
	String get changeSchoolnetPasswordTitle => '修改校园网查询帐号密码';

	late final Translations$settings$updateDialog$zh updateDialog = Translations$settings$updateDialog$zh.internal(_root);
	late final Translations$settings$localizationDialog$zh localizationDialog = Translations$settings$localizationDialog$zh.internal(_root);

	/// zh: '修改学期'
	String get semesterChange => '修改学期';

	/// zh: '使用学期 {semester}'
	String semesterChangeDescription({required Object semester}) => '使用学期 ${semester}';

	/// zh: '应用新学期设置中'
	String get semesterUpdateData => '应用新学期设置中';

	/// zh: '你找到了彩蛋'
	String get easterEggPage => '你找到了彩蛋';

	late final Translations$settings$aboutPage$zh aboutPage = Translations$settings$aboutPage$zh.internal(_root);
	late final Translations$settings$editor$zh editor = Translations$settings$editor$zh.internal(_root);
	late final Translations$settings$sections$zh sections = Translations$settings$sections$zh.internal(_root);
	late final Translations$settings$navigation$zh navigation = Translations$settings$navigation$zh.internal(_root);

	/// zh: '字体大小与粗细'
	String get fontSizeSetting => '字体大小与粗细';

	late final Translations$settings$fontSizePage$zh fontSizePage = Translations$settings$fontSizePage$zh.internal(_root);

	/// zh: '通用账号'
	String get generalAccountSettings => '通用账号';

	/// zh: '本科生系统账号'
	String get undergraduateSystemAccounts => '本科生系统账号';

	/// zh: '课表背景'
	String get classTableBackgroundSection => '课表背景';

	/// zh: '背景模糊: {value}'
	String backgroundBlur({required Object value}) => '背景模糊: ${value}';

	/// zh: '关闭'
	String get backgroundBlurOff => '关闭';

	/// zh: '课表显示与样式'
	String get classTableStyleSetting => '课表显示与样式';

	/// zh: '时间指示和课程卡片样式'
	String get classTableStyleDescription => '时间指示和课程卡片样式';

	late final Translations$settings$classTableStylePage$zh classTableStylePage = Translations$settings$classTableStylePage$zh.internal(_root);

	/// zh: '正数错后开学日期 负数提前开学日期'
	String get classSwiftExplain => '正数错后开学日期 负数提前开学日期';
}

// Path: timetable
class Translations$timetable$zh {
	Translations$timetable$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '课程表'
	String get title => '课程表';

	/// zh: '课程数据源尚未接入'
	String get unavailable => '课程数据源尚未接入';

	/// zh: '正在加载课程表'
	String get loading => '正在加载课程表';

	/// zh: '部分课程数据加载失败'
	String get error => '部分课程数据加载失败';

	/// zh: '正在显示已保存的课程数据'
	String get cache => '正在显示已保存的课程数据';

	/// zh: '本学期暂无安排'
	String get empty => '本学期暂无安排';

	/// zh: '第 {number} 周'
	String week({required Object number}) => '第 ${number} 周';

	/// zh: '刷新课程表'
	String get refresh => '刷新课程表';

	/// zh: '今天'
	String get today => '今天';

	/// zh: '明天'
	String get tomorrow => '明天';

	/// zh: '今天没有更多安排'
	String get noMoreToday => '今天没有更多安排';

	/// zh: '明天没有安排'
	String get noneTomorrow => '明天没有安排';
}

// Path: core.language
class Translations$core$language$zh {
	Translations$core$language$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '语言'
	String get title => '语言';

	/// zh: '应用语言'
	String get selection => '应用语言';

	/// zh: '跟随系统'
	String get system => '跟随系统';

	/// zh: '简体中文'
	String get simplifiedChinese => '简体中文';

	/// zh: '繁體中文'
	String get traditionalChinese => '繁體中文';

	/// zh: 'English'
	String get english => 'English';

	/// zh: '无法保存语言设置'
	String get saveFailed => '无法保存语言设置';
}

// Path: core.theme
class Translations$core$theme$zh {
	Translations$core$theme$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '无法保存主题设置'
	String get saveFailed => '无法保存主题设置';

	/// zh: '显示'
	String get display => '显示';

	/// zh: '文字'
	String get languageAndText => '文字';

	/// zh: '颜色设置'
	String get colorSetting => '颜色设置';

	/// zh: '深浅色模式'
	String get brightnessSetting => '深浅色模式';

	/// zh: '字体大小'
	String get sizeTitle => '字体大小';

	/// zh: '字体粗细'
	String get weightTitle => '字体粗细';

	late final Translations$core$theme$weight$zh weight = Translations$core$theme$weight$zh.internal(_root);
	late final Translations$core$theme$palette$zh palette = Translations$core$theme$palette$zh.internal(_root);
	late final Translations$core$theme$brightness$zh brightness = Translations$core$theme$brightness$zh.internal(_root);
}

// Path: core.gridPage
class Translations$core$gridPage$zh {
	Translations$core$gridPage$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '校园信息'
	String get label => '校园信息';

	/// zh: '校园信息查询'
	String get title => '校园信息查询';

	/// zh: '编辑布局'
	String get editMode => '编辑布局';

	/// zh: '完成'
	String get editDone => '完成';

	/// zh: '恢复默认布局'
	String get editReset => '恢复默认布局';

	/// zh: '管理隐藏卡片'
	String get manageHidden => '管理隐藏卡片';

	/// zh: '没有隐藏的卡片'
	String get hideEmpty => '没有隐藏的卡片';
}

// Path: ids.logoutDialog
class Translations$ids$logoutDialog$zh {
	Translations$ids$logoutDialog$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '确认对话框'
	String get title => '确认对话框';

	/// zh: '确定退出登录？保存的统一认证账号密码和会话 Cookie 将被删除。'
	String get content => '确定退出登录？保存的统一认证账号密码和会话 Cookie 将被删除。';

	/// zh: '退出失败，请重试。'
	String get failed => '退出失败，请重试。';
}

// Path: settings.lowElectricityThresholdDialog
class Translations$settings$lowElectricityThresholdDialog$zh {
	Translations$settings$lowElectricityThresholdDialog$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '设置低电量阈值'
	String get title => '设置低电量阈值';

	/// zh: '请输入电量度数'
	String get inputHint => '请输入电量度数';
}

// Path: settings.notificationPage
class Translations$settings$notificationPage$zh {
	Translations$settings$notificationPage$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '课前通知设置'
	String get title => '课前通知设置';

	/// zh: '加载设置失败: {error}'
	String loadFailed({required Object error}) => '加载设置失败: ${error}';

	/// zh: '通知功能'
	String get functionSection => '通知功能';

	/// zh: '启用课前通知'
	String get enableNotification => '启用课前通知';

	/// zh: '已安排 {count} 个通知'
	String notificationScheduled({required Object count}) => '已安排 ${count} 个通知';

	/// zh: '关闭后将取消所有已安排的通知'
	String get notificationDisabledHint => '关闭后将取消所有已安排的通知';

	/// zh: '更新通知日程'
	String get updateSchedule => '更新通知日程';

	/// zh: '根据最新的课程数据重新安排通知'
	String get updateScheduleHint => '根据最新的课程数据重新安排通知';

	/// zh: '查看使用说明'
	String get viewTheInstructions => '查看使用说明';

	/// zh: '查看更多使用说明确保您能看到程序发出的通知'
	String get viewTheInstructionsHint => '查看更多使用说明确保您能看到程序发出的通知';

	/// zh: '删除通知日程'
	String get deleteAllSchedule => '删除通知日程';

	/// zh: '这个操作会删除所有已经安排的日程，但是您可以再次点击更新通知日程来重新添加'
	String get deleteAllScheduleHint => '这个操作会删除所有已经安排的日程，但是您可以再次点击更新通知日程来重新添加';

	/// zh: '删除操作成功'
	String get deleteAllSuccess => '删除操作成功';

	/// zh: '权限状态'
	String get permissionSection => '权限状态';

	/// zh: '通知权限'
	String get notificationPermission => '通知权限';

	/// zh: '精确时钟权限'
	String get exactAlarmPermission => '精确时钟权限';

	/// zh: '已授予'
	String get permissionGranted => '已授予';

	/// zh: '未授予'
	String get permissionDenied => '未授予';

	/// zh: '请求权限'
	String get requestPermission => '请求权限';

	/// zh: '系统通知设置'
	String get systemSettings => '系统通知设置';

	/// zh: '打开系统设置检查通知配置'
	String get systemSettingsHint => '打开系统设置检查通知配置';

	/// zh: '权限已授予'
	String get permissionGrantedMsg => '权限已授予';

	/// zh: '权限被拒绝，请在系统设置中开启'
	String get permissionDeniedMsg => '权限被拒绝，请在系统设置中开启';

	/// zh: '提醒设置'
	String get reminderSection => '提醒设置';

	/// zh: '将物理实验加入课程提醒'
	String get experimentReminder => '将物理实验加入课程提醒';

	/// zh: '将物理实验的时间安排一并加入课前提醒系统'
	String get experimentReminderHint => '将物理实验的时间安排一并加入课前提醒系统';

	/// zh: '提前提醒时间'
	String get minutesBefore => '提前提醒时间';

	/// zh: '课前提前提醒的时间设置'
	String get minutesBeforeHint => '课前提前提醒的时间设置';

	/// zh: '分钟'
	String get minutesUnit => '分钟';

	/// zh: '计划通知天数'
	String get daysToSchedule => '计划通知天数';

	/// zh: '本程序是提前将课程信息写入计划日程，该设置可调整写入计划日程的天数'
	String get daysToScheduleHint => '本程序是提前将课程信息写入计划日程，该设置可调整写入计划日程的天数';

	/// zh: '天'
	String get daysUnit => '天';

	/// zh: '通知设置提示'
	String get settingsGuideTitle => '通知设置提示';

	/// zh: '为了确保您能及时收到课前提醒，请确保： 1. 开启了应用的通知权限 2. 开启了通知的声音提示 3. 开启了悬浮通知（横幅通知） 4. 非原生安卓用户，开启自启动和关闭电源优化'
	String get settingsGuideContent1 => '为了确保您能及时收到课前提醒，请确保：\n1. 开启了应用的通知权限\n2. 开启了通知的声音提示\n3. 开启了悬浮通知（横幅通知）\n4. 非原生安卓用户，开启自启动和关闭电源优化';

	/// zh: '课前提醒模块运行机制： 1. 首次开启时自动安排未来几天的课前提醒 2. 每次打开应用时自动检查并更新通知日程 3. 修改设置后自动重新安排所有通知'
	String get settingsGuideContent2 => '课前提醒模块运行机制：\n1. 首次开启时自动安排未来几天的课前提醒\n2. 每次打开应用时自动检查并更新通知日程\n3. 修改设置后自动重新安排所有通知';

	/// zh: '知道了'
	String get gotIt => '知道了';

	/// zh: '打开系统设置'
	String get openSettings => '打开系统设置';

	/// zh: '请先获取课程表、考试或实验数据'
	String get noClasstableData => '请先获取课程表、考试或实验数据';

	/// zh: '已安排 {count} 个课前提醒'
	String scheduleSuccess({required Object count}) => '已安排 ${count} 个课前提醒';

	/// zh: '安排通知失败: {error}'
	String scheduleFailed({required Object error}) => '安排通知失败: ${error}';

	/// zh: '已取消所有课前提醒'
	String get cancelAllSuccess => '已取消所有课前提醒';

	/// zh: '已重新安排 {count} 个课前提醒'
	String rescheduleSuccess({required Object count}) => '已重新安排 ${count} 个课前提醒';

	/// zh: '重新安排通知失败: {error}'
	String rescheduleFailed({required Object error}) => '重新安排通知失败: ${error}';
}

// Path: settings.clearAndRestartDialog
class Translations$settings$clearAndRestartDialog$zh {
	Translations$settings$clearAndRestartDialog$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '确认对话框'
	String get title => '确认对话框';

	/// zh: '确定清除缓存后重启程序？'
	String get content => '确定清除缓存后重启程序？';

	/// zh: '正在清理缓存'
	String get cleaning => '正在清理缓存';

	/// zh: '缓存已被清除'
	String get clear => '缓存已被清除';
}

// Path: settings.logoutDialog
class Translations$settings$logoutDialog$zh {
	Translations$settings$logoutDialog$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '确认对话框'
	String get title => '确认对话框';

	/// zh: '确定退出登录？你的所有数据将会被彻底删除！'
	String get content => '确定退出登录？你的所有数据将会被彻底删除！';

	/// zh: '正在退出登录'
	String get loggingOut => '正在退出登录';
}

// Path: settings.needCloseDialog
class Translations$settings$needCloseDialog$zh {
	Translations$settings$needCloseDialog$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '请关闭应用'
	String get title => '请关闭应用';

	/// zh: '因为技术限制，用户需要自行关闭窗口，然后重新打开应用。'
	String get content => '因为技术限制，用户需要自行关闭窗口，然后重新打开应用。';
}

// Path: settings.changeColorDialog
class Translations$settings$changeColorDialog$zh {
	Translations$settings$changeColorDialog$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '颜色设置'
	String get title => '颜色设置';

	/// zh: '默认颜色'
	String get kDefault => '默认颜色';

	/// zh: '聪明蓝'
	String get blue => '聪明蓝';

	/// zh: '基佬紫'
	String get deepPurple => '基佬紫';

	/// zh: '春风绿'
	String get green => '春风绿';

	/// zh: '明日香橙'
	String get orange => '明日香橙';

	/// zh: '樱花粉'
	String get pink => '樱花粉';
}

// Path: settings.changeBrightnessDialog
class Translations$settings$changeBrightnessDialog$zh {
	Translations$settings$changeBrightnessDialog$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '亮度设置'
	String get title => '亮度设置';

	/// zh: '跟随系统'
	String get followSetting => '跟随系统';

	/// zh: '浅色'
	String get dayMode => '浅色';

	/// zh: '深色'
	String get nightMode => '深色';
}

// Path: settings.changeSwiftDialog
class Translations$settings$changeSwiftDialog$zh {
	Translations$settings$changeSwiftDialog$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '课程偏移设置'
	String get title => '课程偏移设置';

	/// zh: '请在此输入数字'
	String get inputHint => '请在此输入数字';

	/// zh: '请输入有效的整数'
	String get invalidNumber => '请输入有效的整数';
}

// Path: settings.changeElectricityAccount
class Translations$settings$changeElectricityAccount$zh {
	Translations$settings$changeElectricityAccount$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '修改电费帐号'
	String get title => '修改电费帐号';

	/// zh: '校区'
	String get campus => '校区';

	/// zh: '北校区'
	String get northCampus => '北校区';

	/// zh: '南校区'
	String get southCampus => '南校区';

	/// zh: '单元/区号'
	String get unitOrZone => '单元/区号';

	/// zh: '单元号'
	String get unitCode => '单元号';

	/// zh: '区号'
	String get zoneCode => '区号';

	/// zh: '请输入{unitOrZoneCode}'
	String pleaseInput({required Object unit_or_zone_code}) => '请输入${unit_or_zone_code}';

	/// zh: '账号获取成功：{accountNumber}'
	String successfulFetch({required Object account_number}) => '账号获取成功：${account_number}';

	/// zh: '获取失败：{e}'
	String failedFetch({required Object e}) => '获取失败：${e}';

	/// zh: '账号已保存：{accountNumber}'
	String accountSaved({required Object account_number}) => '账号已保存：${account_number}';

	/// zh: '该楼号编码规则未知'
	String get unknownCodingPattern => '该楼号编码规则未知';

	/// zh: '选择楼栋'
	String get selectBuilding => '选择楼栋';

	/// zh: '楼栋'
	String get building => '楼栋';

	/// zh: '北栋'
	String get northernBuilding => '北栋';

	/// zh: '南栋'
	String get southernBuilding => '南栋';

	/// zh: '生成失败：{e}'
	String failedGenerate({required Object e}) => '生成失败：${e}';

	/// zh: '楼号'
	String get buildingNumber => '楼号';

	/// zh: '例如: 16, 7, 55'
	String get buildingNumberHint => '例如: 16, 7, 55';

	/// zh: '请输入楼号'
	String get buildingNumberQuery => '请输入楼号';

	/// zh: '院区'
	String get yard => '院区';

	/// zh: '选择院区'
	String get yardHint => '选择院区';

	/// zh: '北院'
	String get northYard => '北院';

	/// zh: '南院'
	String get southYard => '南院';

	/// zh: '请选择院区'
	String get yardQuery => '请选择院区';

	/// zh: '楼栋'
	String get apartment => '楼栋';

	/// zh: '选择楼栋'
	String get apartmentHint => '选择楼栋';

	/// zh: '北楼'
	String get northApartment => '北楼';

	/// zh: '南楼'
	String get southApartment => '南楼';

	/// zh: '请选择楼栋'
	String get apartmentQuery => '请选择楼栋';

	/// zh: '层号'
	String get levelCode => '层号';

	/// zh: '请输入层号'
	String get levelCodeQuery => '请输入层号';

	/// zh: '房间号'
	String get roomCode => '房间号';

	/// zh: '例如: 304, 508'
	String get roomCodeHint => '例如: 304, 508';

	/// zh: '请输入房间号'
	String get roomCodeQuery => '请输入房间号';

	/// zh: '电费账号'
	String get account => '电费账号';

	/// zh: '请输入或从网络获取'
	String get accountHint => '请输入或从网络获取';

	/// zh: '请输入电费账号'
	String get accountQuery => '请输入电费账号';

	/// zh: '账号长度通常不小于10位'
	String get accountLength => '账号长度通常不小于10位';

	/// zh: '正在获取...'
	String get fetching => '正在获取...';

	/// zh: '从网络同步'
	String get fetchFromInternet => '从网络同步';

	/// zh: '保存账号'
	String get saveAccount => '保存账号';

	/// zh: '确认保存'
	String get confirmSaving => '确认保存';

	/// zh: '计算账号'
	String get calculateAccount => '计算账号';

	/// zh: '计算'
	String get calculate => '计算';

	/// zh: '输入'
	String get input => '输入';

	/// zh: '请确认账号：'
	String get confirmAccount => '请确认账号：';

	/// zh: '修改'
	String get change => '修改';

	/// zh: '取消'
	String get cancel => '取消';

	/// zh: '未设置新的电费账号'
	String get noSetting => '未设置新的电费账号';

	/// zh: '已设置新的电费账号'
	String get successfulSetting => '已设置新的电费账号';
}

// Path: settings.changePasswordDialog
class Translations$settings$changePasswordDialog$zh {
	Translations$settings$changePasswordDialog$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '请在此输入密码'
	String get inputHint => '请在此输入密码';

	/// zh: '输入空白!'
	String get blankInput => '输入空白!';
}

// Path: settings.updateDialog
class Translations$settings$updateDialog$zh {
	Translations$settings$updateDialog$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '新版本发布'
	String get newVersion => '新版本发布';

	/// zh: '暂不更新'
	String get notNow => '暂不更新';

	/// zh: 'App Store 更新'
	String get appStore => 'App Store 更新';

	/// zh: '下载安装包'
	String get downloadApk => '下载安装包';

	/// zh: '去 Git Release'
	String get githubRelease => '去 Git Release';

	/// zh: '版本号 {code} 新增内容： '
	String newContent({required Object code}) => '版本号 ${code} 新增内容：\n';
}

// Path: settings.localizationDialog
class Translations$settings$localizationDialog$zh {
	Translations$settings$localizationDialog$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '修改语言'
	String get title => '修改语言';

	/// zh: '追随系统设置'
	String get undefined => '追随系统设置';

	/// zh: '简体中文'
	String get simplifiedChinese => '简体中文';

	/// zh: '繁体中文'
	String get traditionalChinese => '繁体中文';

	/// zh: '英语'
	String get english => '英语';
}

// Path: settings.aboutPage
class Translations$settings$aboutPage$zh {
	Translations$settings$aboutPage$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '主要开发者，iOS 小部件编写和拼接'
	String get benderblog => '主要开发者，iOS 小部件编写和拼接';

	/// zh: '开发：图书馆搜索和封面、图书馆布局修复、饮水机接水功能及接口适配'
	String get alnair => '开发：图书馆搜索和封面、图书馆布局修复、饮水机接水功能及接口适配';

	/// zh: '开发：考勤历史记录、空调遥控、空调电费数据接入、图书馆新接口适配'
	String get aqqkad => '开发：考勤历史记录、空调遥控、空调电费数据接入、图书馆新接口适配';

	/// zh: '支持：最佳&最久故障反馈者'
	String get bellssgit => '支持：最佳&最久故障反馈者';

	/// zh: '设计：主页，登录页，配色，iOS 小部件等'
	String get brackrat => '设计：主页，登录页，配色，iOS 小部件等';

	/// zh: '支持：无价值无意义的产品经理(他自己的描述)'
	String get breezeline => '支持：无价值无意义的产品经理(他自己的描述)';

	/// zh: '支持：提供彩蛋代码 / 开发：2026版本滑块验证码适配'
	String get cafebabe => '支持：提供彩蛋代码 / 开发：2026版本滑块验证码适配';

	/// zh: '开发：修复滑块不对齐问题'
	String get chitao1234 => '开发：修复滑块不对齐问题';

	/// zh: '开发：系统日历最新课表同步'
	String get copperkoi => '开发：系统日历最新课表同步';

	/// zh: '开发支持：辅助修复滑块问题'
	String get dimole => '开发支持：辅助修复滑块问题';

	/// zh: '设计：体育成绩页面'
	String get elitewars => '设计：体育成绩页面';

	/// zh: '国际化：软件英语翻译 / 开发指导：情侣课表功能开发指导（该功能已经被移除）'
	String get elliot => '国际化：软件英语翻译 / 开发指导：情侣课表功能开发指导（该功能已经被移除）';

	/// zh: '开发：修复自定义课程编辑页的空指针异常'
	String get flyingpig => '开发：修复自定义课程编辑页的空指针异常';

	/// zh: '国际化：繁体中文转换代码和彩蛋代码 / 开发：优化导出日历文件大小'
	String get godhu777777 => '国际化：繁体中文转换代码和彩蛋代码 / 开发：优化导出日历文件大小';

	/// zh: '国际化：繁体中文转换代码'
	String get hancl777 => '国际化：繁体中文转换代码';

	/// zh: '开发：物理实验成绩查询和识别'
	String get hazukiKeatsu => '开发：物理实验成绩查询和识别';

	/// zh: '设计：课程详情卡片'
	String get hawa130 => '设计：课程详情卡片';

	/// zh: '开发：电费查询账号计算'
	String get hhzm => '开发：电费查询账号计算';

	/// zh: '开发：睿思论坛路由修复'
	String get imaginary17 => '开发：睿思论坛路由修复';

	/// zh: '开发：设计软件主页 / 开发：平板考勤查询页面 / 开发：优化了体育查询界面的UI / 开发：设置页面分类重构及主从布局适配'
	String get imoscarz => '开发：设计软件主页 / 开发：平板考勤查询页面 / 开发：优化了体育查询界面的UI / 开发：设置页面分类重构及主从布局适配';

	/// zh: '国际化：软件英语翻译优化'
	String get kaMateKaOra => '国际化：软件英语翻译优化';

	/// zh: '开发：课程表时间进度展示（终版方案） / 开发：课程表上过课程灰度化和其他课程界面特性'
	String get lagrangeX => '开发：课程表时间进度展示（终版方案） / 开发：课程表上过课程灰度化和其他课程界面特性';

	/// zh: '支持：Windows 和 Linux 构建脚本 / 开发：2026版本滑块验证码适配'
	String get lhx666Cool => '支持：Windows 和 Linux 构建脚本 / 开发：2026版本滑块验证码适配';

	/// zh: '设计：配色，空白页面贴图 / 开发：实验系统页面读取代码'
	String get lichtyy => '设计：配色，空白页面贴图 / 开发：实验系统页面读取代码';

	/// zh: '支持：推文宣传图片制作'
	String get lqsyH => '支持：推文宣传图片制作';

	/// zh: '设计：iOS 和 Android 图标 / 支持：冠名 XDYou'
	String get lsy223622 => '设计：iOS 和 Android 图标 / 支持：冠名 XDYou';

	/// zh: '支持：提供网络服务使用说明文档 / 国际化：优化英语翻译'
	String get mrbrilliant2046 => '支持：提供网络服务使用说明文档 / 国际化：优化英语翻译';

	/// zh: '开发：图书馆搜索功能 / 国际化：优化英语翻译'
	String get nancunchild => '开发：图书馆搜索功能 / 国际化：优化英语翻译';

	/// zh: '开发：课程表时间进度展示（初版方案） / 支持：MacOS 构建支持'
	String get nkanf => '开发：课程表时间进度展示（初版方案） / 支持：MacOS 构建支持';

	/// zh: '开发：成绩缓存功能和优化滑块算法 / 国际化：优化英语翻译'
	String get pairman => '开发：成绩缓存功能和优化滑块算法 / 国际化：优化英语翻译';

	/// zh: '设计：用于信息展示的 ReX 卡片 / 开发支持：研究生课表'
	String get reverierxu => '设计：用于信息展示的 ReX 卡片 / 开发支持：研究生课表';

	/// zh: '开发支持：电费查询'
	String get rrrilac => '开发支持：电费查询';

	/// zh: '设计：开屏画面 / 支持：iOS 发行商 & 搭子课表 / 开发指导：情侣课表功能开发指导（该功能已经被移除） / 国际化：优化英语翻译'
	String get ray => '设计：开屏画面 / 支持：iOS 发行商 & 搭子课表 / 开发指导：情侣课表功能开发指导（该功能已经被移除） / 国际化：优化英语翻译';

	/// zh: '支持：两次鸽子公众号宣传'
	String get shadowyingyi => '支持：两次鸽子公众号宣传';

	/// zh: '设计：首页时间轴 / 开发：异步登录 & 验证码预测'
	String get stalomeow => '设计：首页时间轴 / 开发：异步登录 & 验证码预测';

	/// zh: '设计：设置页面 / 开发：XDU Planet / 开发：校园卡付款码'
	String get xeonds => '设计：设置页面 / 开发：XDU Planet / 开发：校园卡付款码';

	/// zh: '开发：修复物理实验获取问题和电费窗口问题'
	String get xingshuyu => '开发：修复物理实验获取问题和电费窗口问题';

	/// zh: '开发：Android 小部件和拼接'
	String get xiue233 => '开发：Android 小部件和拼接';

	/// zh: '开发支持：研究生版本开发'
	String get xizi => '开发支持：研究生版本开发';

	/// zh: '开发：修复调课未按预期进行'
	String get wirsbf => '开发：修复调课未按预期进行';

	/// zh: '开发：修复丁香电费 / 开发支持：研究生版本开发 / 设计：空白页面贴图'
	String get zcwzy => '开发：修复丁香电费 / 开发支持：研究生版本开发 / 设计：空白页面贴图';

	/// zh: '开发支持：小工具页面地址更新'
	String get zyarEr => '开发支持：小工具页面地址更新';

	/// zh: '主页'
	String get homepage => '主页';

	/// zh: '开源代码'
	String get code => '开源代码';

	/// zh: '知道更多'
	String get knowMore => '知道更多';

	/// zh: '本软件拷贝基于 traintime_pda 代码（或称 watermeter 代码）编译或修改，代码按照 Mozilla Public License, v. 2.0 授权。 本程序和西安电子科技大学，体适能服务，书蜗，电表等服务无关。 本程序代码版权受中国国家版权局保护，登记号2026SR0738647。 Copyright 2023-2025 BenderBlog Rodriguez and contributors. Copyright 2025-present Traintime PDA authors. The Copyright of the Software is protected by NCAC, register code is 2026SR0738647 The Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, you can obtain one at https://mozilla.org/MPL/2.0/.'
	String get copyrightNotice => '本软件拷贝基于 traintime_pda 代码（或称 watermeter 代码）编译或修改，代码按照 Mozilla Public License, v. 2.0 授权。\n本程序和西安电子科技大学，体适能服务，书蜗，电表等服务无关。\n本程序代码版权受中国国家版权局保护，登记号2026SR0738647。\nCopyright 2023-2025 BenderBlog Rodriguez and contributors. Copyright 2025-present Traintime PDA authors.\nThe Copyright of the Software is protected by NCAC, register code is 2026SR0738647\nThe Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, you can obtain one at https://mozilla.org/MPL/2.0/.';

	/// zh: '备案号'
	String get beian => '备案号';

	/// zh: '著作权登记号'
	String get copyrightRegisterCode => '著作权登记号';

	/// zh: '安卓签名'
	String get signAndroid => '安卓签名';

	/// zh: '关于本软件'
	String get title => '关于本软件';

	/// zh: '贡献者与致谢'
	String get contributors => '贡献者与致谢';

	/// zh: '开源许可'
	String get licenses => '开源许可';

	/// zh: '更多'
	String get extras => '更多';

	/// zh: '构建时间'
	String get buildTime => '构建时间';

	/// zh: '开发：修复 iOS 课程偏移负数输入及输入校验'
	String get dami => '开发：修复 iOS 课程偏移负数输入及输入校验';

	/// zh: '开发：空闲教室实时显示、课表背景模糊、课表布局与屏幕圆角适配；修复校园网数据展示'
	String get l1angyun => '开发：空闲教室实时显示、课表背景模糊、课表布局与屏幕圆角适配；修复校园网数据展示';

	/// zh: '开发：校园网验证码刷新及验证码输入对话框优化'
	String get littlestejan => '开发：校园网验证码刷新及验证码输入对话框优化';

	/// zh: '开发：HarmonyOS 移植'
	String get sixteenforever => '开发：HarmonyOS 移植';
}

// Path: settings.editor
class Translations$settings$editor$zh {
	Translations$settings$editor$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '保存'
	String get save => '保存';

	/// zh: '应用'
	String get apply => '应用';

	/// zh: '已设置'
	String get passwordSet => '已设置';

	/// zh: '未设置'
	String get passwordNotSet => '未设置';

	/// zh: '显示或隐藏密码'
	String get passwordVisibility => '显示或隐藏密码';

	/// zh: '切换正负号'
	String get toggleSign => '切换正负号';

	/// zh: '请输入大于 0 的整数'
	String get positiveNumber => '请输入大于 0 的整数';

	/// zh: '度'
	String get electricityUnit => '度';

	/// zh: '课程安排 · TrainTime PDA · 0123456789'
	String get textPreview => '课程安排 · TrainTime PDA · 0123456789';

	/// zh: '亮度'
	String get brightness => '亮度';

	/// zh: '边框不透明度'
	String get borderOpacity => '边框不透明度';

	/// zh: '底色不透明度'
	String get fillOpacity => '底色不透明度';

	/// zh: '底色饱和度'
	String get fillSaturation => '底色饱和度';

	/// zh: '文字饱和度'
	String get textSaturation => '文字饱和度';

	/// zh: '背景模糊程度'
	String get backgroundBlur => '背景模糊程度';

	/// zh: '年份'
	String get year => '年份';

	/// zh: '学期'
	String get semester => '学期';
}

// Path: settings.sections
class Translations$settings$sections$zh {
	Translations$settings$sections$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '显示'
	String get display => '显示';

	/// zh: '语言和文字'
	String get languageAndText => '语言和文字';

	/// zh: '首页'
	String get home => '首页';

	/// zh: '电量提醒'
	String get electricity => '电量提醒';

	/// zh: '课表外观'
	String get timetableAppearance => '课表外观';

	/// zh: '学期与周次'
	String get semester => '学期与周次';

	/// zh: '课程数据'
	String get courseData => '课程数据';
}

// Path: settings.navigation
class Translations$settings$navigation$zh {
	Translations$settings$navigation$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '主题、字体、语言与首页显示'
	String get uiDescription => '主题、字体、语言与首页显示';

	/// zh: '课表外观、学期与课程数据'
	String get classtableDescription => '课表外观、学期与课程数据';

	/// zh: '校园服务的账号与密码'
	String get accountDescription => '校园服务的账号与密码';

	/// zh: '课前提醒与通知管理'
	String get notificationsDescription => '课前提醒与通知管理';

	/// zh: '日志、缓存清理与退出登录'
	String get coreDescription => '日志、缓存清理与退出登录';
}

// Path: settings.fontSizePage
class Translations$settings$fontSizePage$zh {
	Translations$settings$fontSizePage$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '字体大小'
	String get sizeTitle => '字体大小';

	/// zh: '字体粗细'
	String get weightTitle => '字体粗细';

	/// zh: '预览'
	String get previewTitle => '预览';

	/// zh: '细'
	String get weightThin => '细';

	/// zh: '常规'
	String get weightRegular => '常规';

	/// zh: '中等'
	String get weightMedium => '中等';

	/// zh: '半粗'
	String get weightSemibold => '半粗';

	/// zh: '加粗'
	String get weightBold => '加粗';

	/// zh: '{scale}% · {weight}'
	String summary({required Object scale, required Object weight}) => '${scale}% · ${weight}';
}

// Path: settings.classTableStylePage
class Translations$settings$classTableStylePage$zh {
	Translations$settings$classTableStylePage$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '毛玻璃背景'
	String get frostedSection => '毛玻璃背景';

	/// zh: '启用毛玻璃背景'
	String get frostedEnabled => '启用毛玻璃背景';

	/// zh: '关闭后各控件只保留半透明底色，可省电、更流畅'
	String get frostedEnabledHint => '关闭后各控件只保留半透明底色，可省电、更流畅';

	/// zh: '课程卡片模糊'
	String get frostedCardSigma => '课程卡片模糊';

	/// zh: '时间轴模糊'
	String get frostedTimeLineSigma => '时间轴模糊';

	/// zh: '日期栏模糊'
	String get frostedDateRowSigma => '日期栏模糊';

	/// zh: '周次栏模糊'
	String get frostedWeekBarSigma => '周次栏模糊';

	/// zh: '状态横幅模糊'
	String get frostedBannerSigma => '状态横幅模糊';

	/// zh: '导航栏模糊'
	String get frostedAppBarSigma => '导航栏模糊';

	/// zh: '时间指示设置'
	String get currentTimeSettingsTitle => '时间指示设置';

	/// zh: '课表样式设置'
	String get classColorSettingsTitle => '课表样式设置';

	/// zh: '时间指示设置'
	String get currentTimeSection => '时间指示设置';

	/// zh: '显示当前时间指示线'
	String get showCurrentTimeIndicator => '显示当前时间指示线';

	/// zh: '显示迷你数字时钟'
	String get showCurrentTimeLabel => '显示迷你数字时钟';

	/// zh: '强调显示今天的纵列'
	String get showTodayColumnHighlight => '强调显示今天的纵列';

	/// zh: '课程卡片样式'
	String get activeSection => '课程卡片样式';

	/// zh: '课程卡片样式'
	String get unfinishedSection => '课程卡片样式';

	/// zh: '亮度: {value}'
	String activeBrightnessFactor({required Object value}) => '亮度: ${value}';

	/// zh: '边框不透明度: {value}'
	String activeBorderAlpha({required Object value}) => '边框不透明度: ${value}';

	/// zh: '底色不透明度: {value}'
	String activeInnerAlpha({required Object value}) => '底色不透明度: ${value}';

	/// zh: '已结束课程样式'
	String get completedSection => '已结束课程样式';

	/// zh: '已结束课程样式区分'
	String get completedStyleEnabled => '已结束课程样式区分';

	/// zh: '底色饱和度: {value}'
	String completedSaturationFactor({required Object value}) => '底色饱和度: ${value}';

	/// zh: '亮度: {value}'
	String completedBrightnessFactor({required Object value}) => '亮度: ${value}';

	/// zh: '文字饱和度: {value}'
	String completedTextSaturationFactor({required Object value}) => '文字饱和度: ${value}';

	/// zh: '边框不透明度: {value}'
	String completedBorderAlpha({required Object value}) => '边框不透明度: ${value}';

	/// zh: '底色不透明度: {value}'
	String completedInnerAlpha({required Object value}) => '底色不透明度: ${value}';
}

// Path: core.theme.weight
class Translations$core$theme$weight$zh {
	Translations$core$theme$weight$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '细'
	String get thin => '细';

	/// zh: '常规'
	String get regular => '常规';

	/// zh: '中等'
	String get medium => '中等';

	/// zh: '半粗'
	String get semibold => '半粗';

	/// zh: '加粗'
	String get bold => '加粗';
}

// Path: core.theme.palette
class Translations$core$theme$palette$zh {
	Translations$core$theme$palette$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '默认颜色'
	String get indigo => '默认颜色';

	/// zh: '聪明蓝'
	String get blue => '聪明蓝';

	/// zh: '基佬紫'
	String get deepPurple => '基佬紫';

	/// zh: '春风绿'
	String get green => '春风绿';

	/// zh: '明日香橙'
	String get orange => '明日香橙';

	/// zh: '樱花粉'
	String get pink => '樱花粉';
}

// Path: core.theme.brightness
class Translations$core$theme$brightness$zh {
	Translations$core$theme$brightness$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '跟随系统'
	String get system => '跟随系统';

	/// zh: '浅色'
	String get light => '浅色';

	/// zh: '深色'
	String get dark => '深色';
}

/// The flat map containing all translations for locale <zh>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.confirm' => '确认',
			'common.cancel' => '取消',
			'common.unexpectProblemTitle' => '一个小问题 :P',
			'common.unexpectProblemHint' => '这里有一个没有被预料的问题发生了！',
			'common.errorDetected' => 'Ouch! 发生错误啦',
			'common.clickToRefresh' => '点我刷新',
			'core.language.title' => '语言',
			'core.language.selection' => '应用语言',
			'core.language.system' => '跟随系统',
			'core.language.simplifiedChinese' => '简体中文',
			'core.language.traditionalChinese' => '繁體中文',
			'core.language.english' => 'English',
			'core.language.saveFailed' => '无法保存语言设置',
			'core.theme.saveFailed' => '无法保存主题设置',
			'core.theme.display' => '显示',
			'core.theme.languageAndText' => '文字',
			'core.theme.colorSetting' => '颜色设置',
			'core.theme.brightnessSetting' => '深浅色模式',
			'core.theme.sizeTitle' => '字体大小',
			'core.theme.weightTitle' => '字体粗细',
			'core.theme.weight.thin' => '细',
			'core.theme.weight.regular' => '常规',
			'core.theme.weight.medium' => '中等',
			'core.theme.weight.semibold' => '半粗',
			'core.theme.weight.bold' => '加粗',
			'core.theme.palette.indigo' => '默认颜色',
			'core.theme.palette.blue' => '聪明蓝',
			'core.theme.palette.deepPurple' => '基佬紫',
			'core.theme.palette.green' => '春风绿',
			'core.theme.palette.orange' => '明日香橙',
			'core.theme.palette.pink' => '樱花粉',
			'core.theme.brightness.system' => '跟随系统',
			'core.theme.brightness.light' => '浅色',
			'core.theme.brightness.dark' => '深色',
			'core.gridPage.label' => '校园信息',
			'core.gridPage.title' => '校园信息查询',
			'core.gridPage.editMode' => '编辑布局',
			'core.gridPage.editDone' => '完成',
			'core.gridPage.editReset' => '恢复默认布局',
			'core.gridPage.manageHidden' => '管理隐藏卡片',
			'core.gridPage.hideEmpty' => '没有隐藏的卡片',
			'ids.username' => '学号或工号',
			'ids.password' => '密码',
			'ids.reauthenticate' => '请重新登录',
			'ids.reauthenticateMessage' => '保存的密码已被拒绝，请输入当前密码继续。',
			'ids.login' => '登录',
			'ids.loggingIn' => '登录中…',
			'ids.loginFailed' => '登录失败，请检查账号、密码或网络后重试',
			'ids.credentialsRejected' => '账号或密码错误。',
			'ids.networkUnavailable' => '网络不可用，请重试。',
			'ids.loginCancelled' => '已取消登录。',
			'ids.logout' => '退出账号',
			'ids.sliderTitle' => '滑块验证',
			'ids.sliderRetry' => '验证失败，请使用新图片重试。',
			'ids.mfaMethodTitle' => '选择二次认证方式',
			'ids.smsCode' => '短信验证码',
			'ids.wechatCode' => '企业微信验证码',
			'ids.mfaTitle' => '二次认证',
			'ids.codeSent' => '验证码已发送',
			'ids.codeRequired' => '请输入验证码',
			'ids.codeInvalid' => '验证码错误，请重试',
			'ids.trustDevice' => '信任此设备',
			'ids.submit' => '提交',
			'ids.sendCode' => '发送验证码',
			'ids.resendCountdown' => ({required Object seconds}) => '${seconds} 秒后重发',
			'ids.trustDeviceHint' => '下次可减少验证',
			'ids.codeSendFailed' => '验证码发送失败，请重试',
			'ids.logoutDialog.title' => '确认对话框',
			'ids.logoutDialog.content' => '确定退出登录？保存的统一认证账号密码和会话 Cookie 将被删除。',
			'ids.logoutDialog.failed' => '退出失败，请重试。',
			'settings.title' => '设置',
			'settings.aboutInfo' => '程序信息',
			'settings.acknowledgement' => ({required Object developers}) => 'Made With Love From ${developers} People',
			'settings.about' => '关于',
			'settings.aboutThisProgram' => '关于本程序',
			'settings.version' => ({required Object version}) => '版本号：${version}',
			'settings.userInfo' => '用户信息',
			'settings.checkUpdate' => '检查软件更新',
			'settings.latestVersion' => ({required Object latest}) => '最新版本: ${latest}',
			'settings.waiting' => '等待获取',
			'settings.fetchingUpdate' => '正在获取更新信息',
			'settings.newVersion' => '有新版本发布，请立刻更新！',
			'settings.currentStable' => '目前您正在运行最新版',
			'settings.currentTesting' => '目前您正在运行测试版',
			'settings.fetchFailed' => '获取更新信息失败',
			'settings.uiSetting' => '界面设置',
			'settings.brightnessSetting' => '深浅色模式',
			'settings.colorSetting' => '颜色设置',
			'settings.simplifyTimeline' => '简化日程时间轴',
			'settings.simplifyTimelineDescription' => '没有日程时 减少空间占用',
			'settings.lowElectricityWarning' => '低电量卡片变色提醒',
			'settings.lowElectricityWarningDescription' => '电量小于阈值时 电量卡片变色提醒',
			'settings.lowElectricityThreshold' => '低电量阈值',
			'settings.lowElectricityThresholdDescription' => ({required Object threshold}) => '当前为 ${threshold} 度',
			'settings.lowElectricityThresholdDialog.title' => '设置低电量阈值',
			'settings.lowElectricityThresholdDialog.inputHint' => '请输入电量度数',
			'settings.accountSetting' => '账号设置',
			'settings.sportPasswordSetting' => '体育系统密码设置',
			'settings.experimentPasswordSetting' => '物理实验系统密码设置',
			'settings.electricityPasswordSetting' => '电费帐号密码设置',
			'settings.electricityPasswordDescription' => '非 123456 请设置',
			'settings.electricityAccountSetting' => '电费账号设置',
			'settings.schoolnetPasswordSetting' => '校园网帐号密码设置',
			'settings.schoolnetPasswordDescription' => '不设置查看不了网费',
			'settings.airconImeiTitle' => '空调设备',
			'settings.airconImei' => '空调 IMEI',
			'settings.airconImeiNotSet' => '未设置，无法查询或遥控空调',
			'settings.airconImeiCurrent' => ({required Object imei}) => '当前 IMEI：${imei}',
			'settings.airconImeiSaved' => '空调 IMEI 已保存',
			'settings.airconImeiCleared' => '空调 IMEI 已清除',
			'settings.airconImeiInvalid' => '没有识别到有效的 15 位 IMEI',
			'settings.airconImeiClear' => '清除',
			'settings.scanAirconQr' => '扫描空调二维码',
			'settings.pickAirconQrImage' => '从相册选择二维码图片',
			'settings.airconCameraUnavailable' => '当前平台不支持相机扫码，请选择二维码图片或手动输入 IMEI',
			'settings.airconScanHint' => '轻点画面可以对焦；空调离得远、放大后仍然模糊时，请用系统相机拍照识别',
			'settings.airconTakePhoto' => '用系统相机拍照识别',
			'settings.airconCameraError' => ({required Object error}) => '无法打开相机：${error}',
			'settings.notificationSetting' => '通知设置',
			'settings.courseReminderSetting' => '课前通知设置',
			'settings.courseReminderDescription' => '设置课前提醒通知',
			'settings.notificationPage.title' => '课前通知设置',
			'settings.notificationPage.loadFailed' => ({required Object error}) => '加载设置失败: ${error}',
			'settings.notificationPage.functionSection' => '通知功能',
			'settings.notificationPage.enableNotification' => '启用课前通知',
			'settings.notificationPage.notificationScheduled' => ({required Object count}) => '已安排 ${count} 个通知',
			'settings.notificationPage.notificationDisabledHint' => '关闭后将取消所有已安排的通知',
			'settings.notificationPage.updateSchedule' => '更新通知日程',
			'settings.notificationPage.updateScheduleHint' => '根据最新的课程数据重新安排通知',
			'settings.notificationPage.viewTheInstructions' => '查看使用说明',
			'settings.notificationPage.viewTheInstructionsHint' => '查看更多使用说明确保您能看到程序发出的通知',
			'settings.notificationPage.deleteAllSchedule' => '删除通知日程',
			'settings.notificationPage.deleteAllScheduleHint' => '这个操作会删除所有已经安排的日程，但是您可以再次点击更新通知日程来重新添加',
			'settings.notificationPage.deleteAllSuccess' => '删除操作成功',
			'settings.notificationPage.permissionSection' => '权限状态',
			'settings.notificationPage.notificationPermission' => '通知权限',
			'settings.notificationPage.exactAlarmPermission' => '精确时钟权限',
			'settings.notificationPage.permissionGranted' => '已授予',
			'settings.notificationPage.permissionDenied' => '未授予',
			'settings.notificationPage.requestPermission' => '请求权限',
			'settings.notificationPage.systemSettings' => '系统通知设置',
			'settings.notificationPage.systemSettingsHint' => '打开系统设置检查通知配置',
			'settings.notificationPage.permissionGrantedMsg' => '权限已授予',
			'settings.notificationPage.permissionDeniedMsg' => '权限被拒绝，请在系统设置中开启',
			'settings.notificationPage.reminderSection' => '提醒设置',
			'settings.notificationPage.experimentReminder' => '将物理实验加入课程提醒',
			'settings.notificationPage.experimentReminderHint' => '将物理实验的时间安排一并加入课前提醒系统',
			'settings.notificationPage.minutesBefore' => '提前提醒时间',
			'settings.notificationPage.minutesBeforeHint' => '课前提前提醒的时间设置',
			'settings.notificationPage.minutesUnit' => '分钟',
			'settings.notificationPage.daysToSchedule' => '计划通知天数',
			'settings.notificationPage.daysToScheduleHint' => '本程序是提前将课程信息写入计划日程，该设置可调整写入计划日程的天数',
			'settings.notificationPage.daysUnit' => '天',
			'settings.notificationPage.settingsGuideTitle' => '通知设置提示',
			'settings.notificationPage.settingsGuideContent1' => '为了确保您能及时收到课前提醒，请确保：\n1. 开启了应用的通知权限\n2. 开启了通知的声音提示\n3. 开启了悬浮通知（横幅通知）\n4. 非原生安卓用户，开启自启动和关闭电源优化',
			'settings.notificationPage.settingsGuideContent2' => '课前提醒模块运行机制：\n1. 首次开启时自动安排未来几天的课前提醒\n2. 每次打开应用时自动检查并更新通知日程\n3. 修改设置后自动重新安排所有通知',
			'settings.notificationPage.gotIt' => '知道了',
			'settings.notificationPage.openSettings' => '打开系统设置',
			'settings.notificationPage.noClasstableData' => '请先获取课程表、考试或实验数据',
			'settings.notificationPage.scheduleSuccess' => ({required Object count}) => '已安排 ${count} 个课前提醒',
			'settings.notificationPage.scheduleFailed' => ({required Object error}) => '安排通知失败: ${error}',
			'settings.notificationPage.cancelAllSuccess' => '已取消所有课前提醒',
			'settings.notificationPage.rescheduleSuccess' => ({required Object count}) => '已重新安排 ${count} 个课前提醒',
			'settings.notificationPage.rescheduleFailed' => ({required Object error}) => '重新安排通知失败: ${error}',
			'settings.notificationDebugPage' => '通知状态与测试',
			'settings.classtableSetting' => '课表相关设置',
			'settings.background' => '开启课表背景图',
			'settings.noBackground' => '你先选个图片罢，就在下面',
			'settings.chooseBackground' => '课表背景图选择',
			'settings.noPermission' => '未获取存储权限，无法读取文件',
			'settings.successfulSetting' => '设定成功',
			'settings.failureSetting' => '你没有选图片捏',
			'settings.clearUserClass' => '清除所有用户添加课程',
			'settings.clearUserClassTitle' => '确认对话框',
			'settings.clearUserClassContent' => '是否要清除所有用户添加课程？这个功能对从学校获取的日程没有影响。',
			'settings.clearUserClassClear' => '已经清除完毕',
			'settings.classRefresh' => '强制刷新课表',
			'settings.classRefreshTitle' => '确认对话框',
			'settings.classRefreshContent' => '是否要强制刷新课表？同意后，将会从学校一站式后端重新获取课表，耗时会比较久。',
			'settings.classSwift' => '课程偏移设置',
			'settings.classSwiftDescription' => ({required Object swift}) => '目前为 ${swift}',
			'settings.coreSetting' => '缓存登录设置',
			'settings.checkLogger' => '查看网络拦截器和日志',
			'settings.clearAndRestart' => '清除缓存后重启',
			'settings.clearAndRestartDialog.title' => '确认对话框',
			'settings.clearAndRestartDialog.content' => '确定清除缓存后重启程序？',
			'settings.clearAndRestartDialog.cleaning' => '正在清理缓存',
			'settings.clearAndRestartDialog.clear' => '缓存已被清除',
			'settings.logout' => '退出登录并重启应用',
			'settings.logoutDialog.title' => '确认对话框',
			'settings.logoutDialog.content' => '确定退出登录？你的所有数据将会被彻底删除！',
			'settings.logoutDialog.loggingOut' => '正在退出登录',
			'settings.needCloseDialog.title' => '请关闭应用',
			'settings.needCloseDialog.content' => '因为技术限制，用户需要自行关闭窗口，然后重新打开应用。',
			'settings.changeColorDialog.title' => '颜色设置',
			'settings.changeColorDialog.kDefault' => '默认颜色',
			'settings.changeColorDialog.blue' => '聪明蓝',
			'settings.changeColorDialog.deepPurple' => '基佬紫',
			'settings.changeColorDialog.green' => '春风绿',
			'settings.changeColorDialog.orange' => '明日香橙',
			'settings.changeColorDialog.pink' => '樱花粉',
			'settings.changeBrightnessDialog.title' => '亮度设置',
			'settings.changeBrightnessDialog.followSetting' => '跟随系统',
			'settings.changeBrightnessDialog.dayMode' => '浅色',
			'settings.changeBrightnessDialog.nightMode' => '深色',
			'settings.changeSwiftDialog.title' => '课程偏移设置',
			'settings.changeSwiftDialog.inputHint' => '请在此输入数字',
			'settings.changeSwiftDialog.invalidNumber' => '请输入有效的整数',
			'settings.changeElectricityTitle' => '修改电费帐号',
			'settings.changeElectricityAccount.title' => '修改电费帐号',
			'settings.changeElectricityAccount.campus' => '校区',
			'settings.changeElectricityAccount.northCampus' => '北校区',
			'settings.changeElectricityAccount.southCampus' => '南校区',
			'settings.changeElectricityAccount.unitOrZone' => '单元/区号',
			'settings.changeElectricityAccount.unitCode' => '单元号',
			'settings.changeElectricityAccount.zoneCode' => '区号',
			'settings.changeElectricityAccount.pleaseInput' => ({required Object unit_or_zone_code}) => '请输入${unit_or_zone_code}',
			'settings.changeElectricityAccount.successfulFetch' => ({required Object account_number}) => '账号获取成功：${account_number}',
			'settings.changeElectricityAccount.failedFetch' => ({required Object e}) => '获取失败：${e}',
			'settings.changeElectricityAccount.accountSaved' => ({required Object account_number}) => '账号已保存：${account_number}',
			'settings.changeElectricityAccount.unknownCodingPattern' => '该楼号编码规则未知',
			'settings.changeElectricityAccount.selectBuilding' => '选择楼栋',
			'settings.changeElectricityAccount.building' => '楼栋',
			'settings.changeElectricityAccount.northernBuilding' => '北栋',
			'settings.changeElectricityAccount.southernBuilding' => '南栋',
			'settings.changeElectricityAccount.failedGenerate' => ({required Object e}) => '生成失败：${e}',
			'settings.changeElectricityAccount.buildingNumber' => '楼号',
			'settings.changeElectricityAccount.buildingNumberHint' => '例如: 16, 7, 55',
			'settings.changeElectricityAccount.buildingNumberQuery' => '请输入楼号',
			'settings.changeElectricityAccount.yard' => '院区',
			'settings.changeElectricityAccount.yardHint' => '选择院区',
			'settings.changeElectricityAccount.northYard' => '北院',
			'settings.changeElectricityAccount.southYard' => '南院',
			'settings.changeElectricityAccount.yardQuery' => '请选择院区',
			'settings.changeElectricityAccount.apartment' => '楼栋',
			'settings.changeElectricityAccount.apartmentHint' => '选择楼栋',
			'settings.changeElectricityAccount.northApartment' => '北楼',
			'settings.changeElectricityAccount.southApartment' => '南楼',
			'settings.changeElectricityAccount.apartmentQuery' => '请选择楼栋',
			'settings.changeElectricityAccount.levelCode' => '层号',
			'settings.changeElectricityAccount.levelCodeQuery' => '请输入层号',
			'settings.changeElectricityAccount.roomCode' => '房间号',
			'settings.changeElectricityAccount.roomCodeHint' => '例如: 304, 508',
			'settings.changeElectricityAccount.roomCodeQuery' => '请输入房间号',
			'settings.changeElectricityAccount.account' => '电费账号',
			'settings.changeElectricityAccount.accountHint' => '请输入或从网络获取',
			'settings.changeElectricityAccount.accountQuery' => '请输入电费账号',
			'settings.changeElectricityAccount.accountLength' => '账号长度通常不小于10位',
			'settings.changeElectricityAccount.fetching' => '正在获取...',
			'settings.changeElectricityAccount.fetchFromInternet' => '从网络同步',
			'settings.changeElectricityAccount.saveAccount' => '保存账号',
			'settings.changeElectricityAccount.confirmSaving' => '确认保存',
			'settings.changeElectricityAccount.calculateAccount' => '计算账号',
			'settings.changeElectricityAccount.calculate' => '计算',
			'settings.changeElectricityAccount.input' => '输入',
			'settings.changeElectricityAccount.confirmAccount' => '请确认账号：',
			'settings.changeElectricityAccount.change' => '修改',
			'settings.changeElectricityAccount.cancel' => '取消',
			'settings.changeElectricityAccount.noSetting' => '未设置新的电费账号',
			'settings.changeElectricityAccount.successfulSetting' => '已设置新的电费账号',
			'settings.changeExperimentTitle' => '修改物理实验账号密码',
			'settings.changeSportTitle' => '修改体育系统账号密码',
			'settings.changePasswordDialog.inputHint' => '请在此输入密码',
			'settings.changePasswordDialog.blankInput' => '输入空白!',
			'settings.changeSchoolnetPasswordTitle' => '修改校园网查询帐号密码',
			'settings.updateDialog.newVersion' => '新版本发布',
			'settings.updateDialog.notNow' => '暂不更新',
			'settings.updateDialog.appStore' => 'App Store 更新',
			'settings.updateDialog.downloadApk' => '下载安装包',
			'settings.updateDialog.githubRelease' => '去 Git Release',
			'settings.updateDialog.newContent' => ({required Object code}) => '版本号 ${code} 新增内容：\n',
			'settings.localizationDialog.title' => '修改语言',
			'settings.localizationDialog.undefined' => '追随系统设置',
			'settings.localizationDialog.simplifiedChinese' => '简体中文',
			'settings.localizationDialog.traditionalChinese' => '繁体中文',
			'settings.localizationDialog.english' => '英语',
			'settings.semesterChange' => '修改学期',
			'settings.semesterChangeDescription' => ({required Object semester}) => '使用学期 ${semester}',
			'settings.semesterUpdateData' => '应用新学期设置中',
			'settings.easterEggPage' => '你找到了彩蛋',
			'settings.aboutPage.benderblog' => '主要开发者，iOS 小部件编写和拼接',
			'settings.aboutPage.alnair' => '开发：图书馆搜索和封面、图书馆布局修复、饮水机接水功能及接口适配',
			'settings.aboutPage.aqqkad' => '开发：考勤历史记录、空调遥控、空调电费数据接入、图书馆新接口适配',
			'settings.aboutPage.bellssgit' => '支持：最佳&最久故障反馈者',
			'settings.aboutPage.brackrat' => '设计：主页，登录页，配色，iOS 小部件等',
			'settings.aboutPage.breezeline' => '支持：无价值无意义的产品经理(他自己的描述)',
			'settings.aboutPage.cafebabe' => '支持：提供彩蛋代码 / 开发：2026版本滑块验证码适配',
			'settings.aboutPage.chitao1234' => '开发：修复滑块不对齐问题',
			'settings.aboutPage.copperkoi' => '开发：系统日历最新课表同步',
			'settings.aboutPage.dimole' => '开发支持：辅助修复滑块问题',
			'settings.aboutPage.elitewars' => '设计：体育成绩页面',
			'settings.aboutPage.elliot' => '国际化：软件英语翻译 / 开发指导：情侣课表功能开发指导（该功能已经被移除）',
			'settings.aboutPage.flyingpig' => '开发：修复自定义课程编辑页的空指针异常',
			'settings.aboutPage.godhu777777' => '国际化：繁体中文转换代码和彩蛋代码 / 开发：优化导出日历文件大小',
			'settings.aboutPage.hancl777' => '国际化：繁体中文转换代码',
			'settings.aboutPage.hazukiKeatsu' => '开发：物理实验成绩查询和识别',
			'settings.aboutPage.hawa130' => '设计：课程详情卡片',
			'settings.aboutPage.hhzm' => '开发：电费查询账号计算',
			'settings.aboutPage.imaginary17' => '开发：睿思论坛路由修复',
			'settings.aboutPage.imoscarz' => '开发：设计软件主页 / 开发：平板考勤查询页面 / 开发：优化了体育查询界面的UI / 开发：设置页面分类重构及主从布局适配',
			'settings.aboutPage.kaMateKaOra' => '国际化：软件英语翻译优化',
			'settings.aboutPage.lagrangeX' => '开发：课程表时间进度展示（终版方案） / 开发：课程表上过课程灰度化和其他课程界面特性',
			'settings.aboutPage.lhx666Cool' => '支持：Windows 和 Linux 构建脚本 / 开发：2026版本滑块验证码适配',
			'settings.aboutPage.lichtyy' => '设计：配色，空白页面贴图 / 开发：实验系统页面读取代码',
			'settings.aboutPage.lqsyH' => '支持：推文宣传图片制作',
			'settings.aboutPage.lsy223622' => '设计：iOS 和 Android 图标 / 支持：冠名 XDYou',
			'settings.aboutPage.mrbrilliant2046' => '支持：提供网络服务使用说明文档 / 国际化：优化英语翻译',
			'settings.aboutPage.nancunchild' => '开发：图书馆搜索功能 / 国际化：优化英语翻译',
			'settings.aboutPage.nkanf' => '开发：课程表时间进度展示（初版方案） / 支持：MacOS 构建支持',
			'settings.aboutPage.pairman' => '开发：成绩缓存功能和优化滑块算法 / 国际化：优化英语翻译',
			'settings.aboutPage.reverierxu' => '设计：用于信息展示的 ReX 卡片 / 开发支持：研究生课表',
			'settings.aboutPage.rrrilac' => '开发支持：电费查询',
			'settings.aboutPage.ray' => '设计：开屏画面 / 支持：iOS 发行商 & 搭子课表 / 开发指导：情侣课表功能开发指导（该功能已经被移除） / 国际化：优化英语翻译',
			'settings.aboutPage.shadowyingyi' => '支持：两次鸽子公众号宣传',
			'settings.aboutPage.stalomeow' => '设计：首页时间轴 / 开发：异步登录 & 验证码预测',
			'settings.aboutPage.xeonds' => '设计：设置页面 / 开发：XDU Planet / 开发：校园卡付款码',
			'settings.aboutPage.xingshuyu' => '开发：修复物理实验获取问题和电费窗口问题',
			'settings.aboutPage.xiue233' => '开发：Android 小部件和拼接',
			'settings.aboutPage.xizi' => '开发支持：研究生版本开发',
			'settings.aboutPage.wirsbf' => '开发：修复调课未按预期进行',
			'settings.aboutPage.zcwzy' => '开发：修复丁香电费 / 开发支持：研究生版本开发 / 设计：空白页面贴图',
			'settings.aboutPage.zyarEr' => '开发支持：小工具页面地址更新',
			'settings.aboutPage.homepage' => '主页',
			'settings.aboutPage.code' => '开源代码',
			'settings.aboutPage.knowMore' => '知道更多',
			'settings.aboutPage.copyrightNotice' => '本软件拷贝基于 traintime_pda 代码（或称 watermeter 代码）编译或修改，代码按照 Mozilla Public License, v. 2.0 授权。\n本程序和西安电子科技大学，体适能服务，书蜗，电表等服务无关。\n本程序代码版权受中国国家版权局保护，登记号2026SR0738647。\nCopyright 2023-2025 BenderBlog Rodriguez and contributors. Copyright 2025-present Traintime PDA authors.\nThe Copyright of the Software is protected by NCAC, register code is 2026SR0738647\nThe Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, you can obtain one at https://mozilla.org/MPL/2.0/.',
			'settings.aboutPage.beian' => '备案号',
			'settings.aboutPage.copyrightRegisterCode' => '著作权登记号',
			'settings.aboutPage.signAndroid' => '安卓签名',
			'settings.aboutPage.title' => '关于本软件',
			'settings.aboutPage.contributors' => '贡献者与致谢',
			'settings.aboutPage.licenses' => '开源许可',
			'settings.aboutPage.extras' => '更多',
			'settings.aboutPage.buildTime' => '构建时间',
			'settings.aboutPage.dami' => '开发：修复 iOS 课程偏移负数输入及输入校验',
			'settings.aboutPage.l1angyun' => '开发：空闲教室实时显示、课表背景模糊、课表布局与屏幕圆角适配；修复校园网数据展示',
			'settings.aboutPage.littlestejan' => '开发：校园网验证码刷新及验证码输入对话框优化',
			'settings.aboutPage.sixteenforever' => '开发：HarmonyOS 移植',
			'settings.editor.save' => '保存',
			'settings.editor.apply' => '应用',
			'settings.editor.passwordSet' => '已设置',
			'settings.editor.passwordNotSet' => '未设置',
			'settings.editor.passwordVisibility' => '显示或隐藏密码',
			'settings.editor.toggleSign' => '切换正负号',
			'settings.editor.positiveNumber' => '请输入大于 0 的整数',
			'settings.editor.electricityUnit' => '度',
			'settings.editor.textPreview' => '课程安排 · TrainTime PDA · 0123456789',
			'settings.editor.brightness' => '亮度',
			'settings.editor.borderOpacity' => '边框不透明度',
			'settings.editor.fillOpacity' => '底色不透明度',
			'settings.editor.fillSaturation' => '底色饱和度',
			'settings.editor.textSaturation' => '文字饱和度',
			'settings.editor.backgroundBlur' => '背景模糊程度',
			'settings.editor.year' => '年份',
			'settings.editor.semester' => '学期',
			'settings.sections.display' => '显示',
			'settings.sections.languageAndText' => '语言和文字',
			'settings.sections.home' => '首页',
			'settings.sections.electricity' => '电量提醒',
			'settings.sections.timetableAppearance' => '课表外观',
			'settings.sections.semester' => '学期与周次',
			'settings.sections.courseData' => '课程数据',
			'settings.navigation.uiDescription' => '主题、字体、语言与首页显示',
			'settings.navigation.classtableDescription' => '课表外观、学期与课程数据',
			'settings.navigation.accountDescription' => '校园服务的账号与密码',
			'settings.navigation.notificationsDescription' => '课前提醒与通知管理',
			'settings.navigation.coreDescription' => '日志、缓存清理与退出登录',
			'settings.fontSizeSetting' => '字体大小与粗细',
			'settings.fontSizePage.sizeTitle' => '字体大小',
			'settings.fontSizePage.weightTitle' => '字体粗细',
			'settings.fontSizePage.previewTitle' => '预览',
			'settings.fontSizePage.weightThin' => '细',
			'settings.fontSizePage.weightRegular' => '常规',
			'settings.fontSizePage.weightMedium' => '中等',
			'settings.fontSizePage.weightSemibold' => '半粗',
			'settings.fontSizePage.weightBold' => '加粗',
			'settings.fontSizePage.summary' => ({required Object scale, required Object weight}) => '${scale}% · ${weight}',
			'settings.generalAccountSettings' => '通用账号',
			'settings.undergraduateSystemAccounts' => '本科生系统账号',
			'settings.classTableBackgroundSection' => '课表背景',
			'settings.backgroundBlur' => ({required Object value}) => '背景模糊: ${value}',
			'settings.backgroundBlurOff' => '关闭',
			'settings.classTableStyleSetting' => '课表显示与样式',
			'settings.classTableStyleDescription' => '时间指示和课程卡片样式',
			'settings.classTableStylePage.frostedSection' => '毛玻璃背景',
			'settings.classTableStylePage.frostedEnabled' => '启用毛玻璃背景',
			'settings.classTableStylePage.frostedEnabledHint' => '关闭后各控件只保留半透明底色，可省电、更流畅',
			'settings.classTableStylePage.frostedCardSigma' => '课程卡片模糊',
			'settings.classTableStylePage.frostedTimeLineSigma' => '时间轴模糊',
			'settings.classTableStylePage.frostedDateRowSigma' => '日期栏模糊',
			'settings.classTableStylePage.frostedWeekBarSigma' => '周次栏模糊',
			'settings.classTableStylePage.frostedBannerSigma' => '状态横幅模糊',
			'settings.classTableStylePage.frostedAppBarSigma' => '导航栏模糊',
			'settings.classTableStylePage.currentTimeSettingsTitle' => '时间指示设置',
			'settings.classTableStylePage.classColorSettingsTitle' => '课表样式设置',
			'settings.classTableStylePage.currentTimeSection' => '时间指示设置',
			'settings.classTableStylePage.showCurrentTimeIndicator' => '显示当前时间指示线',
			'settings.classTableStylePage.showCurrentTimeLabel' => '显示迷你数字时钟',
			'settings.classTableStylePage.showTodayColumnHighlight' => '强调显示今天的纵列',
			'settings.classTableStylePage.activeSection' => '课程卡片样式',
			'settings.classTableStylePage.unfinishedSection' => '课程卡片样式',
			'settings.classTableStylePage.activeBrightnessFactor' => ({required Object value}) => '亮度: ${value}',
			'settings.classTableStylePage.activeBorderAlpha' => ({required Object value}) => '边框不透明度: ${value}',
			'settings.classTableStylePage.activeInnerAlpha' => ({required Object value}) => '底色不透明度: ${value}',
			'settings.classTableStylePage.completedSection' => '已结束课程样式',
			'settings.classTableStylePage.completedStyleEnabled' => '已结束课程样式区分',
			'settings.classTableStylePage.completedSaturationFactor' => ({required Object value}) => '底色饱和度: ${value}',
			'settings.classTableStylePage.completedBrightnessFactor' => ({required Object value}) => '亮度: ${value}',
			'settings.classTableStylePage.completedTextSaturationFactor' => ({required Object value}) => '文字饱和度: ${value}',
			'settings.classTableStylePage.completedBorderAlpha' => ({required Object value}) => '边框不透明度: ${value}',
			'settings.classTableStylePage.completedInnerAlpha' => ({required Object value}) => '底色不透明度: ${value}',
			'settings.classSwiftExplain' => '正数错后开学日期 负数提前开学日期',
			'timetable.title' => '课程表',
			'timetable.unavailable' => '课程数据源尚未接入',
			'timetable.loading' => '正在加载课程表',
			'timetable.error' => '部分课程数据加载失败',
			'timetable.cache' => '正在显示已保存的课程数据',
			'timetable.empty' => '本学期暂无安排',
			'timetable.week' => ({required Object number}) => '第 ${number} 周',
			'timetable.refresh' => '刷新课程表',
			'timetable.today' => '今天',
			'timetable.tomorrow' => '明天',
			'timetable.noMoreToday' => '今天没有更多安排',
			'timetable.noneTomorrow' => '明天没有安排',
			_ => null,
		};
	}
}
