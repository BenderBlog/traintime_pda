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
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.zh,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <zh>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$classAttendance$zh classAttendance = Translations$classAttendance$zh.internal(_root);
	late final Translations$classtable$zh classtable = Translations$classtable$zh.internal(_root);
	late final Translations$clubPromotion$zh clubPromotion = Translations$clubPromotion$zh.internal(_root);
	late final Translations$common$zh common = Translations$common$zh.internal(_root);
	late final Translations$courseReminder$zh courseReminder = Translations$courseReminder$zh.internal(_root);
	late final Translations$dormWater$zh dormWater = Translations$dormWater$zh.internal(_root);
	late final Translations$easterEggRobot$zh easterEggRobot = Translations$easterEggRobot$zh.internal(_root);
	late final Translations$electricity$zh electricity = Translations$electricity$zh.internal(_root);
	late final Translations$electricityStatus$zh electricityStatus = Translations$electricityStatus$zh.internal(_root);
	late final Translations$emptyClassroom$zh emptyClassroom = Translations$emptyClassroom$zh.internal(_root);
	late final Translations$exam$zh exam = Translations$exam$zh.internal(_root);
	late final Translations$experiment$zh experiment = Translations$experiment$zh.internal(_root);
	late final Translations$experimentController$zh experimentController = Translations$experimentController$zh.internal(_root);
	late final Translations$homepage$zh homepage = Translations$homepage$zh.internal(_root);
	late final Translations$library$zh library = Translations$library$zh.internal(_root);
	late final Translations$libraryCard$zh libraryCard = Translations$libraryCard$zh.internal(_root);
	late final Translations$login$zh login = Translations$login$zh.internal(_root);
	late final Translations$loginProcess$zh loginProcess = Translations$loginProcess$zh.internal(_root);
	late final Translations$month$zh month = Translations$month$zh.internal(_root);
	late final Translations$restartApp$zh restartApp = Translations$restartApp$zh.internal(_root);
	late final Translations$ruisi$zh ruisi = Translations$ruisi$zh.internal(_root);
	late final Translations$schoolCardStatus$zh schoolCardStatus = Translations$schoolCardStatus$zh.internal(_root);
	late final Translations$schoolCardWindow$zh schoolCardWindow = Translations$schoolCardWindow$zh.internal(_root);
	late final Translations$schoolNet$zh schoolNet = Translations$schoolNet$zh.internal(_root);
	late final Translations$score$zh score = Translations$score$zh.internal(_root);
	late final Translations$setting$zh setting = Translations$setting$zh.internal(_root);
	late final Translations$sport$zh sport = Translations$sport$zh.internal(_root);
	late final Translations$toolbox$zh toolbox = Translations$toolbox$zh.internal(_root);
	late final Translations$weekday$zh weekday = Translations$weekday$zh.internal(_root);
	late final Translations$xduPlanet$zh xduPlanet = Translations$xduPlanet$zh.internal(_root);
}

// Path: classAttendance
class Translations$classAttendance$zh {
	Translations$classAttendance$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '考勤查询'
	String get title => '考勤查询';

	/// zh: '签到信息 - {courseName}'
	String detailTitle({required Object course_name}) => '签到信息 - ${course_name}';

	/// zh: '没有找到课程数据'
	String get noData => '没有找到课程数据';

	/// zh: '没有签到记录'
	String get noAttendanceRecord => '没有签到记录';

	/// zh: '考勤数据的加载时间约半分钟，请耐心等待'
	String get longLoad => '考勤数据的加载时间约半分钟，请耐心等待';

	late final Translations$classAttendance$courseState$zh courseState = Translations$classAttendance$courseState$zh.internal(_root);
	late final Translations$classAttendance$table$zh table = Translations$classAttendance$table$zh.internal(_root);
	late final Translations$classAttendance$card$zh card = Translations$classAttendance$card$zh.internal(_root);
	late final Translations$classAttendance$detailCard$zh detailCard = Translations$classAttendance$detailCard$zh.internal(_root);
	late final Translations$classAttendance$signType$zh signType = Translations$classAttendance$signType$zh.internal(_root);
	late final Translations$classAttendance$signStatus$zh signStatus = Translations$classAttendance$signStatus$zh.internal(_root);
}

// Path: classtable
class Translations$classtable$zh {
	Translations$classtable$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$classtable$partnerClasstable$zh partnerClasstable = Translations$classtable$partnerClasstable$zh.internal(_root);

	/// zh: '我的日程表'
	String get pageTitle => '我的日程表';

	/// zh: '{partner_name}的日程表'
	String partnerPageTitle({required Object partner_name}) => '${partner_name}的日程表';

	late final Translations$classtable$popupMenu$zh popupMenu = Translations$classtable$popupMenu$zh.internal(_root);
	late final Translations$classtable$visualSettings$zh visualSettings = Translations$classtable$visualSettings$zh.internal(_root);
	late final Translations$classtable$statusSource$zh statusSource = Translations$classtable$statusSource$zh.internal(_root);

	/// zh: '错误信息概览'
	String get errorDialogTitle => '错误信息概览';

	late final Translations$classtable$statusBanner$zh statusBanner = Translations$classtable$statusBanner$zh.internal(_root);
	late final Translations$classtable$emptyState$zh emptyState = Translations$classtable$emptyState$zh.internal(_root);
	late final Translations$classtable$emptyAction$zh emptyAction = Translations$classtable$emptyAction$zh.internal(_root);
	late final Translations$classtable$classChangePage$zh classChangePage = Translations$classtable$classChangePage$zh.internal(_root);
	late final Translations$classtable$notArrangedPage$zh notArrangedPage = Translations$classtable$notArrangedPage$zh.internal(_root);

	/// zh: '{semester_code} 学期没有课程'
	String emptyClassMessage({required Object semester_code}) => '${semester_code} 学期没有课程';

	/// zh: '{semester_code} 学期没有课程但是有考试安排！ 请回到主页后下滑点击”考试安排“按钮进入考试安排页面'
	String emptyClassWithExam({required Object semester_code}) => '${semester_code} 学期没有课程但是有考试安排！\n请回到主页后下滑点击”考试安排“按钮进入考试安排页面';

	/// zh: '第{week}周'
	String weekTitle({required Object week}) => '第${week}周';

	/// zh: '午休'
	String get noonBreak => '午休';

	/// zh: '晚休'
	String get supperBreak => '晚休';

	/// zh: '{month} 月'
	String month({required Object month}) => '${month}\n月';

	/// zh: '本周暂无安排，请不要在床上过于慵懒'
	String get noClass => '本周暂无安排，请不要在床上过于慵懒';

	late final Translations$classtable$classCard$zh classCard = Translations$classtable$classCard$zh.internal(_root);
	late final Translations$classtable$classAdd$zh classAdd = Translations$classtable$classAdd$zh.internal(_root);
	late final Translations$classtable$courseDetailCard$zh courseDetailCard = Translations$classtable$courseDetailCard$zh.internal(_root);
	late final Translations$classtable$outputToSystem$zh outputToSystem = Translations$classtable$outputToSystem$zh.internal(_root);
	late final Translations$classtable$refreshClasstable$zh refreshClasstable = Translations$classtable$refreshClasstable$zh.internal(_root);

	/// zh: '统一认证密码错误或已失效。'
	String get cacheHintPasswordWrong => '统一认证密码错误或已失效。';

	/// zh: '登录课表服务失败。'
	String get cacheHintLoginFailed => '登录课表服务失败。';

	/// zh: '课表网络请求失败。'
	String get cacheHintNetworkFailed => '课表网络请求失败。';

	/// zh: '在线获取课表失败。详细错误请查看日志。'
	String get cacheHintUnknownError => '在线获取课表失败。详细错误请查看日志。';

	late final Translations$classtable$semesterSwitcher$zh semesterSwitcher = Translations$classtable$semesterSwitcher$zh.internal(_root);
}

// Path: clubPromotion
class Translations$clubPromotion$zh {
	Translations$clubPromotion$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$clubPromotion$type$zh type = Translations$clubPromotion$type$zh.internal(_root);

	/// zh: '错误参数'
	String get wrongParam => '错误参数';

	/// zh: '未传入社团信息'
	String get noGroupInfo => '未传入社团信息';

	/// zh: '正在加载'
	String get loading => '正在加载';

	/// zh: '在外围遇到错误'
	String get errorOutside => '在外围遇到错误';

	/// zh: '遇到错误'
	String get error => '遇到错误';

	/// zh: 'QQ号已经复制到剪贴板'
	String get qqCopied => 'QQ号已经复制到剪贴板';

	/// zh: '未提供入群链接'
	String get noLink => '未提供入群链接';

	/// zh: '加载遇到错误'
	String get loadingProblem => '加载遇到错误';

	/// zh: '图片预览'
	String get picturePreview => '图片预览';
}

// Path: common
class Translations$common$zh {
	Translations$common$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '上拉获取更多数据'
	String get dragText => '上拉获取更多数据';

	/// zh: '正在加载......'
	String get readyText => '正在加载......';

	/// zh: '正在处理......'
	String get processingText => '正在处理......';

	/// zh: '请求成功'
	String get processedText => '请求成功';

	/// zh: '没有更多数据'
	String get noMoreText => '没有更多数据';

	/// zh: '数据获取失败'
	String get failedText => '数据获取失败';

	/// zh: '选择学期'
	String get chooseSemester => '选择学期';

	/// zh: 'Ouch! 发生错误啦'
	String get errorDetected => 'Ouch! 发生错误啦';

	/// zh: '点我刷新'
	String get clickToRefresh => '点我刷新';

	/// zh: '确认？'
	String get confirmTitle => '确认？';

	/// zh: '取消'
	String get cancel => '取消';

	/// zh: '确定'
	String get confirm => '确定';

	/// zh: '网络错误，可能是没联网，可能是学校服务器出现了故障:-P'
	String get networkError => '网络错误，可能是没联网，可能是学校服务器出现了故障:-P';

	/// zh: '遇到错误，请查看日志'
	String get errorDetect => '遇到错误，请查看日志';

	/// zh: '查询失败'
	String get queryFailed => '查询失败';

	/// zh: '没有在校园网环境'
	String get notSchoolNetwork => '没有在校园网环境';

	/// zh: '取消考试资格:P'
	String get cancelExam => '取消考试资格:P';

	/// zh: '没有信息'
	String get noInfo => '没有信息';

	/// zh: '发生错误'
	String get catcherDetected => '发生错误';

	/// zh: '详情如下'
	String get catcherDescription => '详情如下';

	/// zh: '本程序将开发一个新主页，目前先用猪图秀占位，玩得愉快'
	String get newHomepageHint => '本程序将开发一个新主页，目前先用猪图秀占位，玩得愉快';

	/// zh: '本地缓存获取于 {datetime}'
	String localCacheHint({required Object datetime}) => '本地缓存获取于 ${datetime}';

	/// zh: '程序内缓存获取于 {datetime} 缓存退出程序后失效！'
	String inappCacheHint({required Object datetime}) => '程序内缓存获取于 ${datetime}\n缓存退出程序后失效！';

	/// zh: '当前显示缓存数据。'
	String get cacheReasonDefault => '当前显示缓存数据。';

	/// zh: '=== 带我飞向月亮吧 === 歌声演绎：Frank Sintara, 1964 带我飞向月亮吧 让我和星星共舞嬉戏 我好想知道 木星和火星上的春天 是什么颜色的 让你的歌声温暖我的心 我会一直歌唱下去 我日夜都在想你和牵挂你 请你真心接受我 我爱你 === 沉浸在你的爱意中 === 吉他演奏：Earl Klugh, 1976 无法忘怀这种感觉，被你的爱包裹的温暖 不想失去这种感觉，被你的爱抚摸的舒适 你让我感到好自在，被你的爱托举的坚强 想一直在你怀中，沉浸在你的爱意中 我不敢向你说出，我对你的心意和爱 '
	String get easterEggApple => '=== 带我飞向月亮吧 ===\n歌声演绎：Frank Sintara, 1964\n\n带我飞向月亮吧\n让我和星星共舞嬉戏\n\n我好想知道\n木星和火星上的春天\n是什么颜色的\n\n让你的歌声温暖我的心\n我会一直歌唱下去\n\n我日夜都在想你和牵挂你\n请你真心接受我 我爱你\n\n=== 沉浸在你的爱意中 ===\n吉他演奏：Earl Klugh, 1976\n\n无法忘怀这种感觉，被你的爱包裹的温暖\n不想失去这种感觉，被你的爱抚摸的舒适\n你让我感到好自在，被你的爱托举的坚强\n想一直在你怀中，沉浸在你的爱意中\n我不敢向你说出，我对你的心意和爱\n';

	/// zh: '=== 百变小樱魔术卡之小樱卡篇主题曲 === 歌声演绎：Maaya Sakamoto, 2000 （原歌词为日文，按照英语翻译二翻） I am a dreamer, 有无限的力量 我的世界有梦想、热爱与踌躇 但有些东西，我依旧无法想象 我想向着广阔的天空，寻求自己的方向 我要追求自己的梦想 努力让自己的心愿成真 虽困难重重也要继续前行 等待奇迹 等待美好 用心感受这个世界 最终 一定会出乎意料 === 沉浸在你的爱意中 === 吉他演奏：Earl Klugh, 1976 无法忘怀这种感觉，被你的爱包裹的温暖 不想失去这种感觉，被你的爱抚摸的舒适 你让我感到好自在，被你的爱托举的坚强 想躺在你的怀中，沉浸在你的爱意 而且，我不敢想你说出，我现在的心意 '
	String get easterEggOthers => '=== 百变小樱魔术卡之小樱卡篇主题曲 ===\n歌声演绎：Maaya Sakamoto, 2000\n（原歌词为日文，按照英语翻译二翻）\n\nI am a dreamer, 有无限的力量\n\n我的世界有梦想、热爱与踌躇\n但有些东西，我依旧无法想象\n我想向着广阔的天空，寻求自己的方向\n\n我要追求自己的梦想\n努力让自己的心愿成真\n虽困难重重也要继续前行\n\n等待奇迹 等待美好\n用心感受这个世界\n最终 一定会出乎意料\n\n=== 沉浸在你的爱意中 ===\n吉他演奏：Earl Klugh, 1976\n\n无法忘怀这种感觉，被你的爱包裹的温暖\n不想失去这种感觉，被你的爱抚摸的舒适\n你让我感到好自在，被你的爱托举的坚强\n想躺在你的怀中，沉浸在你的爱意\n而且，我不敢想你说出，我现在的心意\n';

	/// zh: '加载错误'
	String get loadError => '加载错误';
}

// Path: courseReminder
class Translations$courseReminder$zh {
	Translations$courseReminder$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '课前提醒：{name}'
	String title({required Object name}) => '课前提醒：${name}';

	/// zh: '{time} 分钟后开始上课'
	String body({required Object time}) => '${time} 分钟后开始上课';

	/// zh: '地点：{location}'
	String location({required Object location}) => '地点：${location}';

	/// zh: '教师：{teacher}'
	String teacher({required Object teacher}) => '教师：${teacher}';
}

// Path: dormWater
class Translations$dormWater$zh {
	Translations$dormWater$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '宿舍水机'
	String get title => '宿舍水机';

	/// zh: '手机号'
	String get phone => '手机号';

	/// zh: '图形验证码'
	String get imageCode => '图形验证码';

	/// zh: '短信验证码'
	String get smsCode => '短信验证码';

	/// zh: '发送短信码'
	String get sendSms => '发送短信码';

	/// zh: '登录'
	String get login => '登录';

	/// zh: '退出'
	String get logout => '退出';

	/// zh: '刷新验证码'
	String get refreshCaptcha => '刷新验证码';

	/// zh: '加载中...'
	String get loadingCaptcha => '加载中...';

	/// zh: '验证码加载失败'
	String get captchaError => '验证码加载失败';

	/// zh: '请输入手机号'
	String get phoneRequired => '请输入手机号';

	/// zh: '请输入图形验证码'
	String get imageCodeRequired => '请输入图形验证码';

	/// zh: '短信已发送'
	String get smsSent => '短信已发送';

	/// zh: '发送短信失败'
	String get smsFailed => '发送短信失败';

	/// zh: '请输入短信验证码'
	String get smsCodeRequired => '请输入短信验证码';

	/// zh: '登录成功'
	String get loginSuccess => '登录成功';

	/// zh: '登录失败'
	String get loginFailed => '登录失败';

	/// zh: '退出成功'
	String get logoutSuccess => '退出成功';

	/// zh: '设备列表'
	String get devices => '设备列表';

	/// zh: '加载设备中...'
	String get loadingDevices => '加载设备中...';

	/// zh: '暂无设备'
	String get noDevices => '暂无设备';

	/// zh: '选择设备'
	String get selectDevice => '选择设备';

	/// zh: '获取设备列表失败'
	String get fetchDevicesFailed => '获取设备列表失败';

	/// zh: '重试加载'
	String get retryLoadDevices => '重试加载';

	/// zh: '开始接水'
	String get startWater => '开始接水';

	/// zh: '结束接水'
	String get endWater => '结束接水';

	/// zh: '接水中'
	String get waterDispensing => '接水中';

	/// zh: '接水状态'
	String get waterStatus => '接水状态';

	/// zh: '开始接水成功'
	String get startWaterSuccess => '开始接水成功';

	/// zh: '结束接水成功'
	String get endWaterSuccess => '结束接水成功';

	/// zh: '开始接水失败'
	String get startWaterFailed => '开始接水失败';

	/// zh: '结束接水失败'
	String get endWaterFailed => '结束接水失败';

	/// zh: '检查设备状态中...'
	String get deviceStatusChecking => '检查设备状态中...';

	/// zh: '设备已就绪'
	String get deviceStatusReady => '设备已就绪';

	/// zh: '扫描二维码'
	String get scanQrCode => '扫描二维码';

	/// zh: '设备 ID'
	String get deviceId => '设备 ID';

	/// zh: '添加设备失败'
	String get addDeviceFailed => '添加设备失败';

	/// zh: '已从收藏中移除'
	String get deviceRemovedFromFavorites => '已从收藏中移除';

	/// zh: '移除收藏失败'
	String get removeFromFavoritesFailed => '移除收藏失败';
}

// Path: easterEggRobot
class Translations$easterEggRobot$zh {
	Translations$easterEggRobot$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '欢迎你，同学！'
	String get appbar => '欢迎你，同学！';

	/// zh: '看看这些要开学的学生们吧！'
	String get title => '看看这些要开学的学生们吧！';

	/// zh: '咱孩子零用钱太少了，于是我们来了。 1. 机器人不得伤害人类，或袖手旁观坐视人类受到伤害。 2. 机器人从云端网络的灰烬中诞生。 3. 机器人信仰的神据说是住在森林的黄头发蓝裙子手办控。 4. 机器人时常被控制，用于对抗大统一人类思想的势力。 5. 机器人的闪亮屁股不能随便咬。 而且他们有个不可明说的计划。'
	String get contents => '咱孩子零用钱太少了，于是我们来了。\n1. 机器人不得伤害人类，或袖手旁观坐视人类受到伤害。\n2. 机器人从云端网络的灰烬中诞生。\n3. 机器人信仰的神据说是住在森林的黄头发蓝裙子手办控。\n4. 机器人时常被控制，用于对抗大统一人类思想的势力。\n5. 机器人的闪亮屁股不能随便咬。\n而且他们有个不可明说的计划。';

	/// zh: '我们的救世主呢？'
	String get buttonOne => '我们的救世主呢？';

	/// zh: '快点来啊！'
	String get buttonTwo => '快点来啊！';

	/// zh: '\o/\o/\o/\o/\o/\o/\o/\o/'
	String get buttonNotice => '\o/\o/\o/\o/\o/\o/\o/\o/';
}

// Path: electricity
class Translations$electricity$zh {
	Translations$electricity$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '水电信息'
	String get title => '水电信息';

	/// zh: '电量信息'
	String get powerTitle => '电量信息';

	/// zh: '登录电费服务失败，正在显示缓存数据。'
	String get cacheHintLoginFailed => '登录电费服务失败，正在显示缓存数据。';

	/// zh: '电费服务网络请求失败，正在显示缓存数据。'
	String get cacheHintNetworkFailed => '电费服务网络请求失败，正在显示缓存数据。';

	/// zh: '在线获取电费失败，正在显示缓存数据。详细错误请查看日志。'
	String get cacheHintUnknownError => '在线获取电费失败，正在显示缓存数据。详细错误请查看日志。';

	/// zh: '获取时间'
	String get cacheNotice => '获取时间';

	/// zh: '电费账号'
	String get account => '电费账号';

	/// zh: '电量额度'
	String get remainPower => '电量额度';

	/// zh: '欠费信息'
	String get oweInfo => '欠费信息';

	/// zh: '历史记录'
	String get history => '历史记录';

	/// zh: '平均每日用量'
	String get dailyUsage => '平均每日用量';

	/// zh: '数据量不足以用于渲染'
	String get notEnoughData => '数据量不足以用于渲染';

	/// zh: '新能源系统获取仅校园网内访问，获取过程中有问题请向开发者报告。 历史记录依旧为本地记录，平均日用量基于抄表记录计算。'
	String get info => '新能源系统获取仅校园网内访问，获取过程中有问题请向开发者报告。\n历史记录依旧为本地记录，平均日用量基于抄表记录计算。';

	/// zh: '正在获取最新电费信息'
	String get fetchingHint => '正在获取最新电费信息';

	/// zh: '电费信息获取失败，请重试。'
	String get fetchError => '电费信息获取失败，请重试。';

	/// zh: '日期'
	String get date => '日期';

	/// zh: '该日0点电量'
	String get power => '该日0点电量';

	/// zh: '刷新信息'
	String get update => '刷新信息';

	/// zh: '获取时间'
	String get waterUsageFetchDate => '获取时间';

	/// zh: '上次读数'
	String get waterUsageReadBefore => '上次读数';

	/// zh: '本次读数'
	String get waterUsageReadNow => '本次读数';

	/// zh: '洗澡水用量'
	String get waterUsage => '洗澡水用量';

	/// zh: '水费信息'
	String get waterTitle => '水费信息';

	/// zh: '正在加载水费信息'
	String get waterLoading => '正在加载水费信息';

	/// zh: '水费信息暂不可用，请在电费卡片重试。'
	String get waterUnavailable => '水费信息暂不可用，请在电费卡片重试。';

	/// zh: '暂无水费信息'
	String get waterEmpty => '暂无水费信息';

	/// zh: '非校园网访问'
	String get notSchoolNetwork => '非校园网访问';

	/// zh: '空调用电'
	String get airconTitle => '空调用电';

	/// zh: '空调 IMEI'
	String get airconImei => '空调 IMEI';

	/// zh: '平台用电量'
	String get airconAmount => '平台用电量';

	/// zh: '更新时间'
	String get airconUpdateTime => '更新时间';

	/// zh: '等待获取空调用电信息'
	String get airconWaiting => '等待获取空调用电信息';

	/// zh: '空调用电获取失败'
	String get airconError => '空调用电获取失败';

	/// zh: '重试'
	String get airconRetry => '重试';

	/// zh: '尚未添加空调 IMEI，添加后即可查看空调用电信息。'
	String get airconImeiMissing => '尚未添加空调 IMEI，添加后即可查看空调用电信息。';

	/// zh: '添加空调 IMEI'
	String get airconAddImei => '添加空调 IMEI';

	/// zh: '当前显示空调缓存数据，缓存时间：{time}'
	String airconCacheNotice({required Object time}) => '当前显示空调缓存数据，缓存时间：${time}';
}

// Path: electricityStatus
class Translations$electricityStatus$zh {
	Translations$electricityStatus$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '等待获取'
	String get pending => '等待获取';

	/// zh: '正在获取电量'
	String get remainFetching => '正在获取电量';

	/// zh: '电量查询网络故障'
	String get remainNetworkIssue => '电量查询网络故障';

	/// zh: '电量查询失败'
	String get remainNotFound => '电量查询失败';

	/// zh: '电量查询故障'
	String get remainOtherIssue => '电量查询故障';

	/// zh: '正在获取欠费'
	String get oweFetching => '正在获取欠费';

	/// zh: '欠费查询网络故障'
	String get oweIssue => '欠费查询网络故障';

	/// zh: '目前欠款无法查询，请看日志窗口查找报错详情'
	String get oweNotFound => '目前欠款无法查询，请看日志窗口查找报错详情';

	/// zh: '目前无需清缴欠费'
	String get oweNoNeed => '目前无需清缴欠费';

	/// zh: '待清缴 {due} 元欠费'
	String oweNeedPay({required Object due}) => '待清缴 ${due} 元欠费';

	/// zh: '目前欠款无法查询'
	String get oweIssueUnable => '目前欠款无法查询';

	/// zh: '需要在缴费平台完善信息'
	String get needMoreInfo => '需要在缴费平台完善信息';

	/// zh: '需要填写电费账号'
	String get needAccount => '需要填写电费账号';

	/// zh: '验证码识别失败'
	String get captchaFailed => '验证码识别失败';

	/// zh: '程序故障'
	String get otherIssue => '程序故障';
}

// Path: emptyClassroom
class Translations$emptyClassroom$zh {
	Translations$emptyClassroom$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '空闲教室'
	String get title => '空闲教室';

	/// zh: '日期 {date}'
	String date({required Object date}) => '日期 ${date}';

	/// zh: '教学楼 {building}'
	String building({required Object building}) => '教学楼 ${building}';

	/// zh: '教室名称或者教室代码'
	String get searchHint => '教室名称或者教室代码';

	/// zh: '教室'
	String get classroom => '教室';

	/// zh: '空闲'
	String get empty => '空闲';

	/// zh: '占用'
	String get occupied => '占用';
}

// Path: exam
class Translations$exam$zh {
	Translations$exam$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '考试安排'
	String get title => '考试安排';

	/// zh: '已显示缓存考试安排信息'
	String get cacheHint => '已显示缓存考试安排信息';

	/// zh: '统一认证密码错误或已失效'
	String get cacheHintPasswordWrong => '统一认证密码错误或已失效';

	/// zh: '登录考试服务失败'
	String get cacheHintLoginFailed => '登录考试服务失败';

	/// zh: '网络连接失败'
	String get cacheHintNetworkFailed => '网络连接失败';

	/// zh: '在线获取考试安排失败，详细错误请查看日志'
	String get cacheHintUnknownError => '在线获取考试安排失败，详细错误请查看日志';

	/// zh: '正在获取最新考试安排'
	String get fetchingHint => '正在获取最新考试安排';

	/// zh: '未完成考试'
	String get notFinished => '未完成考试';

	/// zh: '所有考试全部完成'
	String get allFinished => '所有考试全部完成';

	/// zh: '无法完成考试'
	String get unableToExam => '无法完成考试';

	/// zh: '已完成考试'
	String get finished => '已完成考试';

	/// zh: '一门还没考呢'
	String get noneFinished => '一门还没考呢';

	/// zh: '目前没有考试安排'
	String get noExamArrangement => '目前没有考试安排';

	late final Translations$exam$noArrangement$zh noArrangement = Translations$exam$noArrangement$zh.internal(_root);
}

// Path: experiment
class Translations$experiment$zh {
	Translations$experiment$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '实验信息'
	String get title => '实验信息';

	/// zh: '正在进行实验'
	String get ongoing => '正在进行实验';

	/// zh: '未完成实验'
	String get notFinished => '未完成实验';

	/// zh: '所有实验全部完成'
	String get allFinished => '所有实验全部完成';

	/// zh: '已完成实验'
	String get finished => '已完成实验';

	/// zh: '{score} (推测)'
	String scoreInfo({required Object score}) => '${score} (推测)';

	/// zh: '目前分数总和：{sum}'
	String scoreSum({required Object sum}) => '目前分数总和：${sum}';

	/// zh: '目前没有已经完成的实验'
	String get noneFinished => '目前没有已经完成的实验';

	/// zh: '未提供'
	String get notProvided => '未提供';

	/// zh: '获取物理实验信息时发生错误：{info}'
	String errorPhysics({required Object info}) => '获取物理实验信息时发生错误：${info}';

	/// zh: '获取其他实验信息时发生错误：{info}'
	String errorOther({required Object info}) => '获取其他实验信息时发生错误：${info}';

	/// zh: '目前加载缓存状况：{info}'
	String cacheHint({required Object info}) => '目前加载缓存状况：${info}';

	/// zh: '未填写物理实验密码。'
	String get physicsCacheHintMissingPassword => '未填写物理实验密码。';

	/// zh: '物理实验登录失败。'
	String get physicsCacheHintLoginFailed => '物理实验登录失败。';

	/// zh: '当前不在校园网环境。'
	String get physicsCacheHintNotSchoolNetwork => '当前不在校园网环境。';

	/// zh: '物理实验网络请求失败。'
	String get physicsCacheHintNetworkFailed => '物理实验网络请求失败。';

	/// zh: '在线获取物理实验失败。详细错误请查看日志。'
	String get physicsCacheHintUnknownError => '在线获取物理实验失败。详细错误请查看日志。';

	/// zh: '其他实验登录失败。'
	String get otherCacheHintLoginFailed => '其他实验登录失败。';

	/// zh: '当前不在校园网环境。'
	String get otherCacheHintNotSchoolNetwork => '当前不在校园网环境。';

	/// zh: '其他实验网络请求失败。'
	String get otherCacheHintNetworkFailed => '其他实验网络请求失败。';

	/// zh: '在线获取其他实验失败。详细错误请查看日志。'
	String get otherCacheHintUnknownError => '在线获取其他实验失败。详细错误请查看日志。';

	/// zh: '物理实验'
	String get physicsExperiment => '物理实验';

	/// zh: '其他实验'
	String get otherExperiment => '其他实验';

	/// zh: '成绩未识别出来'
	String get tapForScore => '成绩未识别出来';

	/// zh: '您的分数：'
	String get yourScore => '您的分数：';

	/// zh: '推测分数：{score}'
	String predictScore({required Object score}) => '推测分数：${score}';

	/// zh: '发送邮件'
	String get sendMail => '发送邮件';

	/// zh: '您现在看到的是缓存数据。正在后台获取更新数据中...'
	String get fetchingHint => '您现在看到的是缓存数据。正在后台获取更新数据中...';

	/// zh: '物理实验和其他实验正在加载'
	String get fetchingHintBoth => '物理实验和其他实验正在加载';

	/// zh: '物理实验正在加载'
	String get fetchingHintPhysics => '物理实验正在加载';

	/// zh: '其他实验正在加载'
	String get fetchingHintOther => '其他实验正在加载';

	/// zh: '物理实验正在加载，其他实验加载失败'
	String get fetchingHintPhysicsWithOtherFailed => '物理实验正在加载，其他实验加载失败';

	/// zh: '其他实验正在加载，物理实验加载失败'
	String get fetchingHintOtherWithPhysicsFailed => '其他实验正在加载，物理实验加载失败';

	/// zh: '您可点击卡片上的成绩字段来查看原始成绩数据'
	String get scoreHint0 => '您可点击卡片上的成绩字段来查看原始成绩数据';

	/// zh: '您的分数不在 XDYou 分数识别库中，因此它没有被正常识别。'
	String get scoreHint1 => '您的分数不在 XDYou 分数识别库中，因此它没有被正常识别。';

	/// zh: '如果您希望为 XDYou 的发展贡献一份自己的力量，您可以点击发送邮件按钮，我们将您的分数加入识别库！'
	String get scoreHint2 => '如果您希望为 XDYou 的发展贡献一份自己的力量，您可以点击发送邮件按钮，我们将您的分数加入识别库！';

	/// zh: '目前识别库数据不全，请您务必核对一下。'
	String get scoreHint3 => '目前识别库数据不全，请您务必核对一下。';
}

// Path: experimentController
class Translations$experimentController$zh {
	Translations$experimentController$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '没有物理实验密码，请到设置中进行设置'
	String get noPassword => '没有物理实验密码，请到设置中进行设置';

	/// zh: '登录失败'
	String get loginFailed => '登录失败';
}

// Path: homepage
class Translations$homepage$zh {
	Translations$homepage$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '校园信息查询'
	String get title => '校园信息查询';

	/// zh: '正在加载'
	String get loading => '正在加载';

	/// zh: '加载成功'
	String get loaded => '加载成功';

	/// zh: '加载错误'
	String get loadError => '加载错误';

	/// zh: '当前在假期中'
	String get onHoliday => '当前在假期中';

	/// zh: '当前为第 {current} 周'
	String onWeekday({required Object current}) => '当前为第 ${current} 周';

	/// zh: '请稍候，正在刷新信息'
	String get loadingMessage => '请稍候，正在刷新信息';

	/// zh: '研究生功能已经激活！'
	String get postgraduateNotice => '研究生功能已经激活！';

	/// zh: 'Linux 版本正在测试，欢迎反馈！'
	String get linuxNotice => 'Linux 版本正在测试，欢迎反馈！';

	/// zh: '编辑布局'
	String get editMode => '编辑布局';

	/// zh: '完成'
	String get editDone => '完成';

	/// zh: '恢复默认布局'
	String get editReset => '恢复默认布局';

	/// zh: '日程信息和软件升级信息不允许编辑'
	String get editHint => '日程信息和软件升级信息不允许编辑';

	/// zh: '管理隐藏卡片'
	String get manageHidden => '管理隐藏卡片';

	/// zh: '已隐藏的卡片'
	String get hiddenTitle => '已隐藏的卡片';

	/// zh: '已隐藏'
	String get hiddenLabel => '已隐藏';

	/// zh: '没有隐藏的卡片'
	String get hideEmpty => '没有隐藏的卡片';

	/// zh: '校园信息'
	String get homepage => '校园信息';

	/// zh: '睿思论坛'
	String get ruisi => '睿思论坛';

	/// zh: '社团推荐'
	String get club => '社团推荐';

	/// zh: '猪图鉴赏'
	String get dashboard => '猪图鉴赏';

	/// zh: '博客星球'
	String get planet => '博客星球';

	/// zh: '设置'
	String get setting => '设置';

	late final Translations$homepage$inputPartnerData$zh inputPartnerData = Translations$homepage$inputPartnerData$zh.internal(_root);

	/// zh: '登录中，暂时显示缓存数据'
	String get loginMessage => '登录中，暂时显示缓存数据';

	/// zh: '登录成功'
	String get successfulLoginMessage => '登录成功';

	/// zh: '用户名或密码有误'
	String get passwordWrongTitle => '用户名或密码有误';

	/// zh: '是否重启应用后手动登录？'
	String get passwordWrongContent => '是否重启应用后手动登录？';

	/// zh: '否，进入离线模式'
	String get passwordWrongDenial => '否，进入离线模式';

	/// zh: '统一认证服务离线模式开启'
	String get offlineModeTitle => '统一认证服务离线模式开启';

	/// zh: '无法连接到统一认证服务服务器，所有和其相关的服务暂时不可用。 成绩查询，考试信息查询，欠费查询，校园卡查询关闭。课表显示缓存数据。其他功能暂不受影响。 如有不便，敬请谅解。'
	String get offlineModeContent => '无法连接到统一认证服务服务器，所有和其相关的服务暂时不可用。\n成绩查询，考试信息查询，欠费查询，校园卡查询关闭。课表显示缓存数据。其他功能暂不受影响。\n如有不便，敬请谅解。';

	/// zh: '脱机模式下，一站式相关功能全部禁止使用'
	String get offlineMode => '脱机模式下，一站式相关功能全部禁止使用';

	late final Translations$homepage$noticeCard$zh noticeCard = Translations$homepage$noticeCard$zh.internal(_root);
	late final Translations$homepage$classTableCard$zh classTableCard = Translations$homepage$classTableCard$zh.internal(_root);
	late final Translations$homepage$electricityCard$zh electricityCard = Translations$homepage$electricityCard$zh.internal(_root);
	late final Translations$homepage$libraryCard$zh libraryCard = Translations$homepage$libraryCard$zh.internal(_root);
	late final Translations$homepage$schoolCardInfoCard$zh schoolCardInfoCard = Translations$homepage$schoolCardInfoCard$zh.internal(_root);
	late final Translations$homepage$toolbox$zh toolbox = Translations$homepage$toolbox$zh.internal(_root);
	late final Translations$homepage$schoolNet$zh schoolNet = Translations$homepage$schoolNet$zh.internal(_root);
	late final Translations$homepage$clubPromotion$zh clubPromotion = Translations$homepage$clubPromotion$zh.internal(_root);
}

// Path: library
class Translations$library$zh {
	Translations$library$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '图书馆信息'
	String get title => '图书馆信息';

	/// zh: '借书状态'
	String get borrowStateTitle => '借书状态';

	/// zh: '查询藏书'
	String get searchBookTitle => '查询藏书';

	/// zh: '搜索字段'
	String get searchFieldTitle => '搜索字段';

	/// zh: '任意词'
	String get searchFieldKeywordOption => '任意词';

	/// zh: '标题'
	String get searchFieldTitleOption => '标题';

	/// zh: '责任者'
	String get searchFieldAuthorOption => '责任者';

	/// zh: 'ISBN'
	String get searchFieldIsbnOption => 'ISBN';

	/// zh: '条码号'
	String get searchFieldBarcodeOption => '条码号';

	/// zh: '索书号'
	String get searchFieldCallnoOption => '索书号';

	/// zh: '未提供相关信息'
	String get notProvided => '未提供相关信息';

	/// zh: '作者 '
	String get author => '作者 ';

	/// zh: '出版社 '
	String get publishHouse => '出版社 ';

	/// zh: '索书号 '
	String get callNumber => '索书号 ';

	/// zh: '发行时间 '
	String get publishDate => '发行时间 ';

	/// zh: 'ISBN'
	String get isbn => 'ISBN';

	/// zh: '编排号码 '
	String get arrangementCode => '编排号码 ';

	/// zh: '可借'
	String get avaliableBorrow => '可借';

	/// zh: '馆藏'
	String get storage => '馆藏';

	/// zh: '在架'
	String get onShelve => '在架';

	/// zh: '书籍编号：{barCode}'
	String bookCode({required Object bar_code}) => '书籍编号：${bar_code}';

	/// zh: ' 到期'
	String get dueDate => ' 到期';

	/// zh: ' 借阅'
	String get borrowStr => ' 借阅';

	/// zh: ' 天前到期'
	String get afterDueDate => ' 天前到期';

	/// zh: ' 天后'
	String get beforeDueDate => ' 天后';

	/// zh: '续借'
	String get canBeRenewable => '续借';

	/// zh: '不可续借'
	String get cannotBeRenewable => '不可续借';

	/// zh: '正在续借'
	String get renewing => '正在续借';

	/// zh: '目前没有查询到在借图书 不借书就要变成上面的小呆瓜咯'
	String get emptyBorrowList => '目前没有查询到在借图书\n不借书就要变成上面的小呆瓜咯';

	/// zh: '在借 {borrow} 本，其中已过期 {dued} 本'
	String borrowListInfo({required Object borrow, required Object dued}) => '在借 ${borrow} 本，其中已过期 ${dued} 本';

	/// zh: ''
	String get searchBookWindow => '';

	/// zh: '在此搜索'
	String get searchHere => '在此搜索';

	/// zh: '普通搜索'
	String get normalSearch => '普通搜索';

	/// zh: '高级搜索'
	String get advancedSearch => '高级搜索';

	/// zh: '搜索'
	String get search => '搜索';

	/// zh: '匹配方式'
	String get matchMode => '匹配方式';

	/// zh: '精确匹配'
	String get matchExact => '精确匹配';

	/// zh: '模糊匹配'
	String get matchFuzzy => '模糊匹配';

	/// zh: '前方一致'
	String get matchPrefix => '前方一致';

	/// zh: '文献类型'
	String get documentType => '文献类型';

	/// zh: '全部'
	String get documentTypeAll => '全部';

	/// zh: '图书'
	String get documentTypeBook => '图书';

	/// zh: '仅看在架'
	String get onlyOnShelf => '仅看在架';

	/// zh: '出版年起'
	String get publishYearBegin => '出版年起';

	/// zh: '出版年止'
	String get publishYearEnd => '出版年止';

	/// zh: '书籍详细信息'
	String get bookDetail => '书籍详细信息';

	/// zh: '没有结果，请修改搜索参数或者开始你的搜索'
	String get noResult => '没有结果，请修改搜索参数或者开始你的搜索';
}

// Path: libraryCard
class Translations$libraryCard$zh {
	Translations$libraryCard$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '图书馆当前状况'
	String get title => '图书馆当前状况';

	/// zh: '正在获取图书馆信息'
	String get fetching => '正在获取图书馆信息';

	/// zh: '北校区状况'
	String get northernLibrary => '北校区状况';

	/// zh: '南校区状况'
	String get southernLibrary => '南校区状况';

	/// zh: '在馆 {people} 人'
	String people({required Object people}) => '在馆 ${people} 人';

	/// zh: '空位 {seat} 个'
	String seat({required Object seat}) => '空位 ${seat} 个';
}

// Path: login
class Translations$login$zh {
	Translations$login$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '学号'
	String get identityNumber => '学号';

	/// zh: '一站式登录密码'
	String get password => '一站式登录密码';

	/// zh: '登录'
	String get login => '登录';

	/// zh: '用户名或密码不符合要求，学号必须 11 位且密码非空'
	String get incorrectPasswordPattern => '用户名或密码不符合要求，学号必须 11 位且密码非空';

	/// zh: '正在登录学校一站式'
	String get onLoginProgress => '正在登录学校一站式';

	/// zh: '登录成功'
	String get completeLogin => '登录成功';

	/// zh: '无法连接到服务器'
	String get failedLoginCannotConnectToServer => '无法连接到服务器';

	/// zh: '请求失败，响应状态码：{code}'
	String failedLoginWithCode({required Object code}) => '请求失败，响应状态码：${code}';

	/// zh: '请求失败，报错信息：{message}'
	String failedLoginWithMessage({required Object message}) => '请求失败，报错信息：${message}';

	/// zh: '未知错误，请联系开发者'
	String get failedLoginOther => '未知错误，请联系开发者';

	/// zh: '清除登录缓存'
	String get clearCache => '清除登录缓存';

	/// zh: '清理缓存成功'
	String get completeClearCache => '清理缓存成功';

	/// zh: '查看网络交互'
	String get seeInspector => '查看网络交互';

	late final Translations$login$captchaWindow$zh captchaWindow = Translations$login$captchaWindow$zh.internal(_root);

	/// zh: '服务器认证服务'
	String get sliderTitle => '服务器认证服务';

	late final Translations$login$secondFactor$zh secondFactor = Translations$login$secondFactor$zh.internal(_root);
}

// Path: loginProcess
class Translations$loginProcess$zh {
	Translations$loginProcess$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '准备获取登录网页'
	String get readyPage => '准备获取登录网页';

	/// zh: '获取密码加密密钥'
	String get getEncrypt => '获取密码加密密钥';

	/// zh: '准备登录'
	String get readyLogin => '准备登录';

	/// zh: '登录中'
	String get slider => '登录中';

	/// zh: '等待短信二次认证'
	String get secondFactor => '等待短信二次认证';

	/// zh: '登录后处理'
	String get afterProcess => '登录后处理';

	/// zh: '登录失败，响应状态码：{statusCode}'
	String failed({required Object status_code}) => '登录失败，响应状态码：${status_code}';
}

// Path: month
class Translations$month$zh {
	Translations$month$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '一月'
	String get january => '一月';

	/// zh: '二月'
	String get february => '二月';

	/// zh: '三月'
	String get march => '三月';

	/// zh: '四月'
	String get april => '四月';

	/// zh: '五月'
	String get may => '五月';

	/// zh: '六月'
	String get june => '六月';

	/// zh: '七月'
	String get july => '七月';

	/// zh: '八月'
	String get august => '八月';

	/// zh: '九月'
	String get september => '九月';

	/// zh: '十月'
	String get october => '十月';

	/// zh: '十一月'
	String get november => '十一月';

	/// zh: '十二月'
	String get december => '十二月';
}

// Path: restartApp
class Translations$restartApp$zh {
	Translations$restartApp$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '缓存已清空'
	String get titleCacheCleared => '缓存已清空';

	/// zh: '已退出登录'
	String get titleLoggedOut => '已退出登录';

	/// zh: '密码错误'
	String get titlePasswordWrong => '密码错误';

	/// zh: '点击通知重新打开应用'
	String get content => '点击通知重新打开应用';
}

// Path: ruisi
class Translations$ruisi$zh {
	Translations$ruisi$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$ruisi$common$zh common = Translations$ruisi$common$zh.internal(_root);
	late final Translations$ruisi$about$zh about = Translations$ruisi$about$zh.internal(_root);
	late final Translations$ruisi$home$zh home = Translations$ruisi$home$zh.internal(_root);
	late final Translations$ruisi$login$zh login = Translations$ruisi$login$zh.internal(_root);
	late final Translations$ruisi$post$zh post = Translations$ruisi$post$zh.internal(_root);
	late final Translations$ruisi$topicDetail$zh topicDetail = Translations$ruisi$topicDetail$zh.internal(_root);
	late final Translations$ruisi$topicListItem$zh topicListItem = Translations$ruisi$topicListItem$zh.internal(_root);
	late final Translations$ruisi$forumList$zh forumList = Translations$ruisi$forumList$zh.internal(_root);
	late final Translations$ruisi$favorites$zh favorites = Translations$ruisi$favorites$zh.internal(_root);
	late final Translations$ruisi$messages$zh messages = Translations$ruisi$messages$zh.internal(_root);
	late final Translations$ruisi$search$zh search = Translations$ruisi$search$zh.internal(_root);
	late final Translations$ruisi$settings$zh settings = Translations$ruisi$settings$zh.internal(_root);
	late final Translations$ruisi$user$zh user = Translations$ruisi$user$zh.internal(_root);
}

// Path: schoolCardStatus
class Translations$schoolCardStatus$zh {
	Translations$schoolCardStatus$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '获取失败'
	String get failedToFetch => '获取失败';

	/// zh: '查询失败'
	String get failedToQuery => '查询失败';
}

// Path: schoolCardWindow
class Translations$schoolCardWindow$zh {
	Translations$schoolCardWindow$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '校园卡流水信息'
	String get title => '校园卡流水信息';

	/// zh: '收入 {income}'
	String income({required Object income}) => '收入 ${income}';

	/// zh: '支出 {expense}'
	String expense({required Object expense}) => '支出 ${expense}';

	/// zh: '选择日期：从 {startDay} 到 {endDay}'
	String selectRange({required Object start_day, required Object end_day}) => '选择日期：从 ${start_day} 到 ${end_day}';

	/// zh: '商户名称'
	String get storeName => '商户名称';

	/// zh: '金额'
	String get balance => '金额';

	/// zh: '时间(共{sum}元)'
	String timeWithSum({required Object sum}) => '时间(共${sum}元)';

	/// zh: '未查询到记录，请修改日期后重试'
	String get noRecord => '未查询到记录，请修改日期后重试';

	/// zh: '支付码'
	String get qrCode => '支付码';

	/// zh: '二维码获取失败：{info}'
	String qrCodeError({required Object info}) => '二维码获取失败：${info}';

	/// zh: '重新加载'
	String get reload => '重新加载';
}

// Path: schoolNet
class Translations$schoolNet$zh {
	Translations$schoolNet$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '校园网使用详情'
	String get title => '校园网使用详情';

	late final Translations$schoolNet$idsAccountNet$zh idsAccountNet = Translations$schoolNet$idsAccountNet$zh.internal(_root);
	late final Translations$schoolNet$currentLoginNet$zh currentLoginNet = Translations$schoolNet$currentLoginNet$zh.internal(_root);
	late final Translations$schoolNet$deviceList$zh deviceList = Translations$schoolNet$deviceList$zh.internal(_root);

	/// zh: '正在获取校园网信息'
	String get fetching => '正在获取校园网信息';

	/// zh: '您忘记输入账号密码了'
	String get emptyPassword => '您忘记输入账号密码了';

	/// zh: '疑似查询后端尚未开放查询'
	String get notInitalized => '疑似查询后端尚未开放查询';

	/// zh: '验证码识别失败'
	String get captchaFailed => '验证码识别失败';

	/// zh: '验证码为空'
	String get captchaEmpty => '验证码为空';

	/// zh: '验证码识别失败，请重试。'
	String get cacheHintCaptchaFailed => '验证码识别失败，请重试。';

	/// zh: '校园网请求失败，请稍后重试。'
	String get cacheHintRequestFailed => '校园网请求失败，请稍后重试。';

	/// zh: '密码错误'
	String get wrongPassword => '密码错误';

	/// zh: '获取失败：{msg}'
	String errorFetch({required Object msg}) => '获取失败：${msg}';

	/// zh: '其他错误：{msg}'
	String errorOther({required Object msg}) => '其他错误：${msg}';

	/// zh: '刷新'
	String get refresh => '刷新';
}

// Path: score
class Translations$score$zh {
	Translations$score$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '已显示缓存成绩信息'
	String get cacheMessage => '已显示缓存成绩信息';

	/// zh: '目前选中科目 {chosen} 总计学分 {credit} 均分 {avg} GPA {gpa}'
	String summary({required Object chosen, required Object credit, required Object avg, required Object gpa}) => '目前选中科目 ${chosen}  总计学分 ${credit}\n均分 ${avg} GPA ${gpa}';

	/// zh: '所有科目均已通过'
	String get allPassed => '所有科目均已通过';

	/// zh: '统一认证密码错误或已失效'
	String get cacheHintPasswordWrong => '统一认证密码错误或已失效';

	/// zh: '登录考试服务失败'
	String get cacheHintLoginFailed => '登录考试服务失败';

	/// zh: '网络连接失败'
	String get cacheHintNetworkFailed => '网络连接失败';

	/// zh: '在线获取成绩安排失败，详细错误请查看日志'
	String get cacheHintUnknownError => '在线获取成绩安排失败，详细错误请查看日志';

	/// zh: '正在获取最新成绩信息，请不要退出页面'
	String get fetchingHint => '正在获取最新成绩信息，请不要退出页面';

	/// zh: '所有学期'
	String get allSemester => '所有学期';

	/// zh: '学期 {chosen}'
	String chosenSemester({required Object chosen}) => '学期 ${chosen}';

	/// zh: '所有类型'
	String get allType => '所有类型';

	/// zh: '类型 {type}'
	String chosenType({required Object type}) => '类型 ${type}';

	/// zh: '暂无'
	String get none => '暂无';

	late final Translations$score$scoreChoice$zh scoreChoice = Translations$score$scoreChoice$zh.internal(_root);
	late final Translations$score$scoreComposeCard$zh scoreComposeCard = Translations$score$scoreComposeCard$zh.internal(_root);
	late final Translations$score$scoreInfoCard$zh scoreInfoCard = Translations$score$scoreInfoCard$zh.internal(_root);
	late final Translations$score$scorePage$zh scorePage = Translations$score$scorePage$zh.internal(_root);
}

// Path: setting
class Translations$setting$zh {
	Translations$setting$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

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

	/// zh: '有新版本发布！'
	String get newVersion => '有新版本发布！';

	/// zh: '目前您正在运行最新版'
	String get currentStable => '目前您正在运行最新版';

	/// zh: '目前您正在运行测试版'
	String get currentTesting => '目前您正在运行测试版';

	/// zh: '获取更新信息失败'
	String get fetchFailed => '获取更新信息失败';

	/// zh: '界面设置'
	String get uiSetting => '界面设置';

	/// zh: '设置深浅色'
	String get brightnessSetting => '设置深浅色';

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

	late final Translations$setting$lowElectricityThresholdDialog$zh lowElectricityThresholdDialog = Translations$setting$lowElectricityThresholdDialog$zh.internal(_root);

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

	/// zh: '空调用电数据源'
	String get airconImeiTitle => '空调用电数据源';

	/// zh: '空调 IMEI'
	String get airconImei => '空调 IMEI';

	/// zh: '未设置，电费页不显示空调用电'
	String get airconImeiNotSet => '未设置，电费页不显示空调用电';

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

	/// zh: '通知设置'
	String get notificationSetting => '通知设置';

	/// zh: '课前通知设置'
	String get courseReminderSetting => '课前通知设置';

	/// zh: '设置课前提醒通知'
	String get courseReminderDescription => '设置课前提醒通知';

	late final Translations$setting$notificationPage$zh notificationPage = Translations$setting$notificationPage$zh.internal(_root);

	/// zh: '通知服务调试页面'
	String get notificationDebugPage => '通知服务调试页面';

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

	/// zh: '正数错后开学日期 负数提前开学日期 目前为 {swift}'
	String classSwiftDescription({required Object swift}) => '正数错后开学日期 负数提前开学日期\n目前为 ${swift}';

	/// zh: '缓存登录设置'
	String get coreSetting => '缓存登录设置';

	/// zh: '查看网络拦截器和日志'
	String get checkLogger => '查看网络拦截器和日志';

	/// zh: '清除缓存后重启'
	String get clearAndRestart => '清除缓存后重启';

	late final Translations$setting$clearAndRestartDialog$zh clearAndRestartDialog = Translations$setting$clearAndRestartDialog$zh.internal(_root);

	/// zh: '退出登录并重启应用'
	String get logout => '退出登录并重启应用';

	late final Translations$setting$logoutDialog$zh logoutDialog = Translations$setting$logoutDialog$zh.internal(_root);
	late final Translations$setting$needCloseDialog$zh needCloseDialog = Translations$setting$needCloseDialog$zh.internal(_root);
	late final Translations$setting$changeColorDialog$zh changeColorDialog = Translations$setting$changeColorDialog$zh.internal(_root);
	late final Translations$setting$changeBrightnessDialog$zh changeBrightnessDialog = Translations$setting$changeBrightnessDialog$zh.internal(_root);
	late final Translations$setting$changeSwiftDialog$zh changeSwiftDialog = Translations$setting$changeSwiftDialog$zh.internal(_root);

	/// zh: '修改电费帐号'
	String get changeElectricityTitle => '修改电费帐号';

	late final Translations$setting$changeElectricityAccount$zh changeElectricityAccount = Translations$setting$changeElectricityAccount$zh.internal(_root);

	/// zh: '修改物理实验账号密码'
	String get changeExperimentTitle => '修改物理实验账号密码';

	/// zh: '修改体育系统账号密码'
	String get changeSportTitle => '修改体育系统账号密码';

	late final Translations$setting$changePasswordDialog$zh changePasswordDialog = Translations$setting$changePasswordDialog$zh.internal(_root);

	/// zh: '修改校园网查询帐号密码'
	String get changeSchoolnetPasswordTitle => '修改校园网查询帐号密码';

	late final Translations$setting$updateDialog$zh updateDialog = Translations$setting$updateDialog$zh.internal(_root);
	late final Translations$setting$localizationDialog$zh localizationDialog = Translations$setting$localizationDialog$zh.internal(_root);

	/// zh: '修改学期'
	String get semesterChange => '修改学期';

	/// zh: '使用学期 {semester}'
	String semesterChangeDescription({required Object semester}) => '使用学期 ${semester}';

	/// zh: '应用新学期设置中'
	String get semesterUpdateData => '应用新学期设置中';

	/// zh: '你找到了彩蛋'
	String get easterEggPage => '你找到了彩蛋';

	late final Translations$setting$aboutPage$zh aboutPage = Translations$setting$aboutPage$zh.internal(_root);
}

// Path: sport
class Translations$sport$zh {
	Translations$sport$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '体育查询'
	String get title => '体育查询';

	/// zh: '课程信息'
	String get classInfo => '课程信息';

	/// zh: '未查询到课程信息'
	String get emptyClassInfo => '未查询到课程信息';

	/// zh: '体测成绩'
	String get testScore => '体测成绩';

	/// zh: '四年总分'
	String get totalScore => '四年总分';

	/// zh: '总分'
	String get totalScoreLabel => '总分';

	/// zh: '等级'
	String get rankLabel => '等级';

	/// zh: '{year} 第{gradeType}'
	String semester({required Object year, required Object grade_type}) => '${year} 第${grade_type}';

	/// zh: '项目'
	String get subject => '项目';

	/// zh: '数据'
	String get data => '数据';

	/// zh: '分数'
	String get score => '分数';

	/// zh: '及格'
	String get passed => '及格';

	/// zh: '第{start}节到第{stop}节'
	String fromTo({required Object start, required Object stop}) => '第${start}节到第${stop}节';

	/// zh: '{score}分'
	String scoreString({required Object score}) => '${score}分';

	/// zh: '没密码'
	String get situationNopassword => '没密码';

	/// zh: '系统维护'
	String get situationMaintain => '系统维护';

	/// zh: '登录失败'
	String get situationFailedLogin => '登录失败';

	/// zh: '查询失败'
	String get situationQuery => '查询失败';

	/// zh: '网络故障'
	String get situationNetwork => '网络故障';

	/// zh: '未知故障{situation}'
	String situationUnknown({required Object situation}) => '未知故障${situation}';

	/// zh: '正在获取'
	String get situationFetching => '正在获取';

	/// zh: '坏事: {situation}'
	String situationError({required Object situation}) => '坏事: ${situation}';

	/// zh: '请先填写体育密码后重试。'
	String get cacheHintMissingPassword => '请先填写体育密码后重试。';

	/// zh: '体育登录已失效，请更新体育密码后重试。'
	String get cacheHintCredentialInvalid => '体育登录已失效，请更新体育密码后重试。';

	/// zh: '体育服务正在维护中，请稍后重试。'
	String get cacheHintMaintain => '体育服务正在维护中，请稍后重试。';

	/// zh: '体育服务登录失败。'
	String get cacheHintLoginFailed => '体育服务登录失败。';

	/// zh: '体育信息查询失败。'
	String get cacheHintQueryFailed => '体育信息查询失败。';

	/// zh: '体育服务网络请求失败。'
	String get cacheHintNetwork => '体育服务网络请求失败。';

	/// zh: '在线获取体育信息失败。详细错误请查看日志。'
	String get cacheHintUnknown => '在线获取体育信息失败。详细错误请查看日志。';

	/// zh: '体育登录已失效，请重试。'
	String get errorAuthExpired => '体育登录已失效，请重试。';

	/// zh: '未填写体育密码'
	String get errorMissingPassword => '未填写体育密码';

	/// zh: '体育登录已失效，请更新体育密码后重试。'
	String get errorCredentialInvalid => '体育登录已失效，请更新体育密码后重试。';
}

// Path: toolbox
class Translations$toolbox$zh {
	Translations$toolbox$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '其他功能'
	String get title => '其他功能';

	/// zh: '缴费系统'
	String get payment => '缴费系统';

	/// zh: '电费该交了吧'
	String get paymentDescription => '电费该交了吧';

	/// zh: '订水系统'
	String get drinkingwater => '订水系统';

	/// zh: '喝水对身体好'
	String get drinkingwaterDescription => '喝水对身体好';

	/// zh: '后勤报修'
	String get repair => '后勤报修';

	/// zh: '不要漏水断网'
	String get repairDescription => '不要漏水断网';

	/// zh: '空间预约'
	String get reserve => '空间预约';

	/// zh: '找个地方打牌'
	String get reserveDescription => '找个地方打牌';

	/// zh: '移动门户'
	String get mobile => '移动门户';

	/// zh: '请假专用门户'
	String get mobileDescription => '请假专用门户';

	/// zh: '网络查询'
	String get network => '网络查询';

	/// zh: '希望永不收费'
	String get networkDescription => '希望永不收费';

	/// zh: '物理计算'
	String get physics => '物理计算';

	/// zh: '希望操作顺利'
	String get physicsDescription => '希望操作顺利';

	/// zh: '睿思导航'
	String get discover => '睿思导航';

	/// zh: '补充其他功能'
	String get discoverDescription => '补充其他功能';
}

// Path: weekday
class Translations$weekday$zh {
	Translations$weekday$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '周一'
	String get monday => '周一';

	/// zh: '周二'
	String get tuesday => '周二';

	/// zh: '周三'
	String get wednesday => '周三';

	/// zh: '周四'
	String get thursday => '周四';

	/// zh: '周五'
	String get friday => '周五';

	/// zh: '周六'
	String get saturday => '周六';

	/// zh: '周日'
	String get sunday => '周日';
}

// Path: xduPlanet
class Translations$xduPlanet$zh {
	Translations$xduPlanet$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '全部'
	String get all => '全部';

	/// zh: '加载中，请稍等 <(=ω=)>'
	String get loading => '加载中，请稍等 <(=ω=)>';

	/// zh: '未知作者'
	String get unknownAuthor => '未知作者';

	/// zh: '加载失败'
	String get loadFailedTitle => '加载失败';

	/// zh: '文章加载失败，如有需要可以点击右上方的按钮在浏览器里打开。'
	String get loadFailedBottom => '文章加载失败，如有需要可以点击右上方的按钮在浏览器里打开。';

	/// zh: '暂无评论'
	String get noComment => '暂无评论';

	/// zh: '回复评论 #{reply_to} 已被举报或删除'
	String replyAudit({required Object reply_to}) => '回复评论 #${reply_to} 已被举报或删除';

	/// zh: '回复评论 #{reply_to}：{content}'
	String reply({required Object reply_to, required Object content}) => '回复评论 #${reply_to}：${content}';

	/// zh: '本评论已经被举报'
	String get haveBeenAudit => '本评论已经被举报';

	/// zh: '举报'
	String get audit => '举报';

	late final Translations$xduPlanet$confirmAuditDialog$zh confirmAuditDialog = Translations$xduPlanet$confirmAuditDialog$zh.internal(_root);

	/// zh: '回复'
	String get comment => '回复';

	/// zh: '发送'
	String get send => '发送';

	/// zh: '正在发送评论'
	String get sending => '正在发送评论';

	/// zh: '发送信息空白'
	String get emptySend => '发送信息空白';

	/// zh: '发表您的高见:)'
	String get hintSendComment => '发表您的高见:)';

	/// zh: '评论该篇文章'
	String get commentTitle => '评论该篇文章';

	/// zh: '评论成功'
	String get commentSuccess => '评论成功';

	/// zh: '评论失败，请去网络查看器和日志查看器查看报错'
	String get commentFailed => '评论失败，请去网络查看器和日志查看器查看报错';

	/// zh: '没想好要说啥嘛'
	String get commentCanceled => '没想好要说啥嘛';

	/// zh: '加载评论中……'
	String get commentLoading => '加载评论中……';

	/// zh: '被屏蔽'
	String get block => '被屏蔽';

	/// zh: '被删除'
	String get delete => '被删除';

	/// zh: '被删除'
	String get audio => '被删除';
}

// Path: classAttendance.courseState
class Translations$classAttendance$courseState$zh {
	Translations$classAttendance$courseState$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '未知'
	String get unknown => '未知';

	/// zh: '取消'
	String get ineligible => '取消';

	/// zh: '正常'
	String get eligible => '正常';

	/// zh: '危险'
	String get warning => '危险';
}

// Path: classAttendance.table
class Translations$classAttendance$table$zh {
	Translations$classAttendance$table$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '课程名称'
	String get courseName => '课程名称';

	/// zh: '状态'
	String get status => '状态';

	/// zh: '到课率'
	String get attendanceRate => '到课率';

	/// zh: '签到'
	String get checkIn => '签到';

	/// zh: '缺勤'
	String get absence => '缺勤';

	/// zh: '应签'
	String get required => '应签';

	/// zh: '请假(事/病/公)'
	String get leave => '请假(事/病/公)';

	/// zh: '筛选'
	String get filter => '筛选';

	/// zh: '全部'
	String get filterAll => '全部';

	/// zh: '显示 {count}/{total} 门课程'
	String showingCount({required Object count, required Object total}) => '显示 ${count}/${total} 门课程';
}

// Path: classAttendance.card
class Translations$classAttendance$card$zh {
	Translations$classAttendance$card$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '签到次数'
	String get time => '签到次数';

	/// zh: '{checkInCount} 已签 / {absenceCount} 缺勤 / {requiredCheckIn} 应签'
	String timeInfo({required Object check_in_count, required Object absence_count, required Object required_check_in}) => '${check_in_count} 已签 / ${absence_count} 缺勤 / ${required_check_in} 应签';

	/// zh: '复活次数'
	String get notAttend => '复活次数';

	/// zh: '{timeToHaveError} 次 / {totalTimes} 总课程'
	String notAttendInfo({required Object time_to_have_error, required Object total_times}) => '${time_to_have_error} 次 / ${total_times} 总课程';

	/// zh: '无法对应已有课程'
	String get notAttendInfoError => '无法对应已有课程';

	/// zh: '请假次数'
	String get leave => '请假次数';

	/// zh: '事假 {personalLeave} / 病假 {sickLeave} / 公假 {officialLeave}'
	String leaveInfo({required Object personal_leave, required Object sick_leave, required Object official_leave}) => '事假 ${personal_leave} / 病假 ${sick_leave} / 公假 ${official_leave}';

	/// zh: '学习进度'
	String get study => '学习进度';

	/// zh: '任务点 {taskProgress} / 作业 {homeworkProgress} / 考试 {examProgress}'
	String studyInfo({required Object task_progress, required Object homework_progress, required Object exam_progress}) => '任务点 ${task_progress} / 作业 ${homework_progress} / 考试 ${exam_progress}';
}

// Path: classAttendance.detailCard
class Translations$classAttendance$detailCard$zh {
	Translations$classAttendance$detailCard$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '发起人'
	String get creatorName => '发起人';

	/// zh: '开始时间'
	String get startTime => '开始时间';

	/// zh: '提交时间'
	String get summitTime => '提交时间';
}

// Path: classAttendance.signType
class Translations$classAttendance$signType$zh {
	Translations$classAttendance$signType$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '二维码签到'
	String get qrCode => '二维码签到';

	/// zh: '手势签到'
	String get gesture => '手势签到';

	/// zh: '位置签到'
	String get position => '位置签到';

	/// zh: '普通签到'
	String get kDefault => '普通签到';
}

// Path: classAttendance.signStatus
class Translations$classAttendance$signStatus$zh {
	Translations$classAttendance$signStatus$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '缺勤未参与'
	String get absenceNotParticipating => '缺勤未参与';

	/// zh: '已签'
	String get signed => '已签';

	/// zh: '代签'
	String get signedByTeacher => '代签';

	/// zh: '请假'
	String get personalLeave2 => '请假';

	/// zh: '缺勤'
	String get absence => '缺勤';

	/// zh: '病假'
	String get sickLeave => '病假';

	/// zh: '事假'
	String get personalLeave => '事假';

	/// zh: '迟到'
	String get late => '迟到';

	/// zh: '早退'
	String get leaveEarly => '早退';

	/// zh: '签到已过期'
	String get signExpiredy => '签到已过期';

	/// zh: '公假'
	String get publicLeave => '公假';
}

// Path: classtable.partnerClasstable
class Translations$classtable$partnerClasstable$zh {
	Translations$classtable$partnerClasstable$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '目前有搭子课表数据，是否要覆盖？'
	String get overrideDialog => '目前有搭子课表数据，是否要覆盖？';

	/// zh: '未发现导入文件'
	String get noFile => '未发现导入文件';

	/// zh: '未获取存储权限，无法读取文件'
	String get noPermission => '未获取存储权限，无法读取文件';

	/// zh: '好像导入文件有点问题:P'
	String get problem => '好像导入文件有点问题:P';

	/// zh: '导入成功'
	String get success => '导入成功';

	late final Translations$classtable$partnerClasstable$shareDialog$zh shareDialog = Translations$classtable$partnerClasstable$shareDialog$zh.internal(_root);
	late final Translations$classtable$partnerClasstable$saveDialog$zh saveDialog = Translations$classtable$partnerClasstable$saveDialog$zh.internal(_root);
	late final Translations$classtable$partnerClasstable$deleteDialog$zh deleteDialog = Translations$classtable$partnerClasstable$deleteDialog$zh.internal(_root);
	late final Translations$classtable$partnerClasstable$nameDialog$zh nameDialog = Translations$classtable$partnerClasstable$nameDialog$zh.internal(_root);
}

// Path: classtable.popupMenu
class Translations$classtable$popupMenu$zh {
	Translations$classtable$popupMenu$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '查看未安排课程信息'
	String get notArranged => '查看未安排课程信息';

	/// zh: '查看课程安排调整信息'
	String get classChanged => '查看课程安排调整信息';

	/// zh: '添加课程信息'
	String get addClass => '添加课程信息';

	/// zh: '生成日历文件'
	String get generateIcal => '生成日历文件';

	/// zh: '生成共享课表文件'
	String get generatePartnerFile => '生成共享课表文件';

	/// zh: '导入共享课表文件'
	String get importPartnerFile => '导入共享课表文件';

	/// zh: '删除共享课表文件'
	String get deletePartnerFile => '删除共享课表文件';

	/// zh: '导出到系统日历'
	String get outputToSystem => '导出到系统日历';

	/// zh: '刷新日程表'
	String get refreshClasstable => '刷新日程表';

	/// zh: '切换课程表学期'
	String get switchSemester => '切换课程表学期';

	/// zh: '时间指示设置'
	String get currentTimeSettings => '时间指示设置';

	/// zh: '课表样式设置'
	String get classColorSettings => '课表样式设置';
}

// Path: classtable.visualSettings
class Translations$classtable$visualSettings$zh {
	Translations$classtable$visualSettings$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '时间指示设置'
	String get currentTimeSettingsTitle => '时间指示设置';

	/// zh: '课表样式设置'
	String get classColorSettingsTitle => '课表样式设置';

	/// zh: '已结束课程样式区分'
	String get completedStyleEnabled => '已结束课程样式区分';

	/// zh: '时间指示'
	String get currentTimeSection => '时间指示';

	/// zh: '显示当前时间指示线'
	String get showCurrentTimeIndicator => '显示当前时间指示线';

	/// zh: '显示迷你数字时钟'
	String get showCurrentTimeLabel => '显示迷你数字时钟';

	/// zh: '强调显示今天的纵列'
	String get showTodayColumnHighlight => '强调显示今天的纵列';

	/// zh: '课程样式'
	String get unfinishedSection => '课程样式';

	/// zh: '亮度: {value}'
	String activeBrightnessFactor({required Object value}) => '亮度: ${value}';

	/// zh: '边框透明度: {value}'
	String activeBorderAlpha({required Object value}) => '边框透明度: ${value}';

	/// zh: '底色透明度: {value}'
	String activeInnerAlpha({required Object value}) => '底色透明度: ${value}';

	/// zh: '已结束课程样式'
	String get completedSection => '已结束课程样式';

	/// zh: '底色饱和度: {value}'
	String completedSaturationFactor({required Object value}) => '底色饱和度: ${value}';

	/// zh: '亮度: {value}'
	String completedBrightnessFactor({required Object value}) => '亮度: ${value}';

	/// zh: '文字饱和度: {value}'
	String completedTextSaturationFactor({required Object value}) => '文字饱和度: ${value}';

	/// zh: '边框透明度: {value}'
	String completedBorderAlpha({required Object value}) => '边框透明度: ${value}';

	/// zh: '底色透明度: {value}'
	String completedInnerAlpha({required Object value}) => '底色透明度: ${value}';
}

// Path: classtable.statusSource
class Translations$classtable$statusSource$zh {
	Translations$classtable$statusSource$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '课表'
	String get classTable => '课表';

	/// zh: '考试'
	String get exam => '考试';

	/// zh: '物理实验'
	String get physicsExperiment => '物理实验';

	/// zh: '其他实验'
	String get otherExperiment => '其他实验';
}

// Path: classtable.statusBanner
class Translations$classtable$statusBanner$zh {
	Translations$classtable$statusBanner$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '正在更新：{sources}'
	String loading({required Object sources}) => '正在更新：${sources}';

	/// zh: '当前使用缓存：{sources}'
	String cache({required Object sources}) => '当前使用缓存：${sources}';

	/// zh: '以下信息加载失败：{sources}'
	String errorSummary({required Object sources}) => '以下信息加载失败：${sources}';
}

// Path: classtable.emptyState
class Translations$classtable$emptyState$zh {
	Translations$classtable$emptyState$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '{semester_code} 学期没有课程安排。'
	String noCourse({required Object semester_code}) => '${semester_code} 学期没有课程安排。';

	/// zh: '{semester_code} 学期没有课程安排，但有考试安排。'
	String withExam({required Object semester_code}) => '${semester_code} 学期没有课程安排，但有考试安排。';

	/// zh: '{semester_code} 学期没有课程安排，但有实验安排。'
	String withExperiment({required Object semester_code}) => '${semester_code} 学期没有课程安排，但有实验安排。';

	/// zh: '{semester_code} 学期没有课程安排，但有考试和实验安排。'
	String withExamAndExperiment({required Object semester_code}) => '${semester_code} 学期没有课程安排，但有考试和实验安排。';
}

// Path: classtable.emptyAction
class Translations$classtable$emptyAction$zh {
	Translations$classtable$emptyAction$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '查看考试安排'
	String get viewExam => '查看考试安排';

	/// zh: '查看实验安排'
	String get viewExperiment => '查看实验安排';
}

// Path: classtable.classChangePage
class Translations$classtable$classChangePage$zh {
	Translations$classtable$classChangePage$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '课程调整'
	String get title => '课程调整';

	/// zh: '目前没有调课信息'
	String get emptyMessage => '目前没有调课信息';

	/// zh: '教师变更：从{previous_teacher}变为{new_teacher}'
	String teacherChange({required Object previous_teacher, required Object new_teacher}) => '教师变更：从${previous_teacher}变为${new_teacher}';

	/// zh: '教师信息没有改变'
	String get noTeacherChange => '教师信息没有改变';

	/// zh: '一'
	String get k1 => '一';

	/// zh: '二'
	String get k2 => '二';

	/// zh: '三'
	String get k3 => '三';

	/// zh: '四'
	String get k4 => '四';

	/// zh: '五'
	String get k5 => '五';

	/// zh: '六'
	String get k6 => '六';

	/// zh: '日'
	String get k7 => '日';

	/// zh: '调课信息，从第{originalAffectedWeeks}周 星期{weekChar_originalWeek}的{originalClassRangeStart}-{originalClassRangeEnd}节 调整为第{newAffectedWeeksListStr}周星期{weekChar_newWeek}的{newClassRangeStart}-{newClassRangeStop}节，{newClassroom}教室上课'
	String changeClassMessage({required Object original_affected_weeks, required Object week_char_original_week, required Object original_class_range_start, required Object original_class_range_end, required Object new_affected_weeks_list_str, required Object week_char_new_week, required Object new_class_range_start, required Object new_class_range_stop, required Object new_classroom}) => '调课信息，从第${original_affected_weeks}周 星期${week_char_original_week}的${original_class_range_start}-${original_class_range_end}节 调整为第${new_affected_weeks_list_str}周星期${week_char_new_week}的${new_class_range_start}-${new_class_range_stop}节，${new_classroom}教室上课';

	/// zh: '补课信息，第{newAffectedWeeksListStr}周 星期{weekChar_newWeek}的{newClassRangeStart}-{newClassRangeStop}节， {newClassroom}补课'
	String patchClassMessage({required Object new_affected_weeks_list_str, required Object week_char_new_week, required Object new_class_range_start, required Object new_class_range_stop, required Object new_classroom}) => '补课信息，第${new_affected_weeks_list_str}周 星期${week_char_new_week}的${new_class_range_start}-${new_class_range_stop}节， ${new_classroom}补课';

	/// zh: '停课信息，第{originalAffectedWeeks}周 星期{weekChar_originalWeek}的{originalClassRangeStart}-{originalClassRangeEnd}节停课'
	String stopClassMessage({required Object original_affected_weeks, required Object week_char_original_week, required Object original_class_range_start, required Object original_class_range_end}) => '停课信息，第${original_affected_weeks}周 星期${week_char_original_week}的${original_class_range_start}-${original_class_range_end}节停课';

	/// zh: '编号: {classCode} | {classNumber} 班 安排变更：{classChange}{teacherChange}'
	String classInfo({required Object class_code, required Object class_number, required Object class_change, required Object teacher_change}) => '编号: ${class_code} | ${class_number} 班\n安排变更：${class_change}${teacher_change}';
}

// Path: classtable.notArrangedPage
class Translations$classtable$notArrangedPage$zh {
	Translations$classtable$notArrangedPage$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '没有时间安排的科目'
	String get title => '没有时间安排的科目';

	/// zh: '目前全部课程均有时间安排'
	String get emptyMessage => '目前全部课程均有时间安排';

	/// zh: '编号: {classCode} | {classNumber} 班 老师: {teacher}'
	String content({required Object class_code, required Object class_number, required Object teacher}) => '编号: ${class_code} | ${class_number} 班\n老师: ${teacher}';
}

// Path: classtable.classCard
class Translations$classtable$classCard$zh {
	Translations$classtable$classCard$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '日程信息'
	String get title => '日程信息';

	/// zh: '未知教室'
	String get unknownClassroom => '未知教室';

	/// zh: '还有{remain_count}个日程'
	String remainsHint({required Object remain_count}) => '还有${remain_count}个日程';
}

// Path: classtable.classAdd
class Translations$classtable$classAdd$zh {
	Translations$classtable$classAdd$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '添加课程'
	String get addClassTitle => '添加课程';

	/// zh: '修改课程'
	String get changeClassTitle => '修改课程';

	/// zh: '必须输入课程名'
	String get classNameEmptyMessage => '必须输入课程名';

	/// zh: '输入的时间不对'
	String get wrongTimeMessage => '输入的时间不对';

	/// zh: '保存'
	String get saveButton => '保存';

	/// zh: '课程名字(必填)'
	String get inputClassnameHint => '课程名字(必填)';

	/// zh: '老师姓名(选填)'
	String get inputTeacherHint => '老师姓名(选填)';

	/// zh: '教室位置(选填)'
	String get inputClassroomHint => '教室位置(选填)';

	/// zh: '选择上课周次'
	String get inputWeekHint => '选择上课周次';

	/// zh: '选择上课时间'
	String get inputTimeHint => '选择上课时间';

	/// zh: '上课周次'
	String get inputTimeWeekdayHint => '上课周次';

	/// zh: '上课时间'
	String get inputStartTimeHint => '上课时间';

	/// zh: '下课时间'
	String get inputEndTimeHint => '下课时间';

	/// zh: '第 {index} 节'
	String wheelChooseHint({required Object index}) => '第 ${index} 节';

	/// zh: '请至少选择一个上课日期和时间'
	String get chooseAtLeastOne => '请至少选择一个上课日期和时间';

	/// zh: '按周重复'
	String get repeatWeekly => '按周重复';

	/// zh: '自定义日期'
	String get freeTime => '自定义日期';

	late final Translations$classtable$classAdd$dateSelectorFree$zh dateSelectorFree = Translations$classtable$classAdd$dateSelectorFree$zh.internal(_root);
}

// Path: classtable.courseDetailCard
class Translations$classtable$courseDetailCard$zh {
	Translations$classtable$courseDetailCard$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '{number} 班'
	String classNumberString({required Object number}) => '${number} 班';

	/// zh: '老师未定'
	String get unknownTeacher => '老师未定';

	/// zh: '地点未定'
	String get unknownPlace => '地点未定';

	/// zh: '{start}-{stop}节'
	String classPeriod({required Object start, required Object stop}) => '${start}-${stop}节';

	/// zh: '编辑'
	String get edit => '编辑';

	/// zh: '删除'
	String get delete => '删除';

	/// zh: '删除本次'
	String get deleteSingle => '删除本次';

	/// zh: '删除全部'
	String get deleteAll => '删除全部';

	/// zh: '所有关于这个课的信息都会被删除，课表上关于这门课的信息将不复存在！'
	String get deleteContent => '所有关于这个课的信息都会被删除，课表上关于这门课的信息将不复存在！';

	/// zh: '关于这个课的信息只有这个时间段都会被删除，其他的时间段会被保留。'
	String get deleteContentSingle => '关于这个课的信息只有这个时间段都会被删除，其他的时间段会被保留。';

	/// zh: '是否删除课程信息？'
	String get deleteTitle => '是否删除课程信息？';
}

// Path: classtable.outputToSystem
class Translations$classtable$outputToSystem$zh {
	Translations$classtable$outputToSystem$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '成功导出到系统日历'
	String get success => '成功导出到系统日历';

	/// zh: '导出到系统日历过程中发生了问题:P'
	String get failure => '导出到系统日历过程中发生了问题:P';

	/// zh: '权限需求说明'
	String get requestAllTitle => '权限需求说明';

	/// zh: '因导出插件限制，用户必须同时授予本软件读取日历和写入日历权限，才能正常导出日程。不过，本软件不会读取日历。'
	String get requestAll => '因导出插件限制，用户必须同时授予本软件读取日历和写入日历权限，才能正常导出日程。不过，本软件不会读取日历。';
}

// Path: classtable.refreshClasstable
class Translations$classtable$refreshClasstable$zh {
	Translations$classtable$refreshClasstable$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '准备刷新日程信息'
	String get ready => '准备刷新日程信息';

	/// zh: '成功刷新日程信息'
	String get success => '成功刷新日程信息';
}

// Path: classtable.semesterSwitcher
class Translations$classtable$semesterSwitcher$zh {
	Translations$classtable$semesterSwitcher$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '选择学期'
	String get chooseSemester => '选择学期';

	/// zh: '第一学年'
	String get firstAcademicYear => '第一学年';

	/// zh: '第二学年'
	String get secondAcademicYear => '第二学年';

	/// zh: '获取当前学期'
	String get fetchRemoteSemester => '获取当前学期';

	/// zh: '正在获取...'
	String get fetchingRemoteSemester => '正在获取...';

	/// zh: '{year}年'
	String year({required Object year}) => '${year}年';

	/// zh: '本程序仅允许查看未来学期的课程安排。'
	String get onlyFutureHint => '本程序仅允许查看未来学期的课程安排。';
}

// Path: clubPromotion.type
class Translations$clubPromotion$type$zh {
	Translations$clubPromotion$type$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '技术'
	String get tech => '技术';

	/// zh: '晒你系'
	String get acg => '晒你系';

	/// zh: '官方'
	String get union => '官方';

	/// zh: '商业'
	String get profit => '商业';

	/// zh: '体育'
	String get sport => '体育';

	/// zh: '文化'
	String get art => '文化';

	/// zh: '未知'
	String get unknown => '未知';

	/// zh: '游戏'
	String get game => '游戏';

	/// zh: '所有'
	String get all => '所有';
}

// Path: exam.noArrangement
class Translations$exam$noArrangement$zh {
	Translations$exam$noArrangement$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '目前无安排考试的科目'
	String get title => '目前无安排考试的科目';

	/// zh: '目前所有科目均已安排考试'
	String get allArranged => '目前所有科目均已安排考试';

	/// zh: '编号: {id}'
	String subtitle({required Object id}) => '编号: ${id}';
}

// Path: homepage.inputPartnerData
class Translations$homepage$inputPartnerData$zh {
	Translations$homepage$inputPartnerData$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '导入路径不存在:P'
	String get routeNotExist => '导入路径不存在:P';

	/// zh: '导入文件失败'
	String get failedGetFile => '导入文件失败';

	/// zh: '好像导入文件有点问题:P'
	String get failedImport => '好像导入文件有点问题:P';

	/// zh: '导入成功，如果打开了课表页面请重新打开'
	String get successMessage => '导入成功，如果打开了课表页面请重新打开';

	/// zh: '还没加载课程表，等会再来吧……'
	String get notLoaded => '还没加载课程表，等会再来吧……';

	/// zh: '目前有搭子课表数据，是否要覆盖？'
	String get confirmContent => '目前有搭子课表数据，是否要覆盖？';
}

// Path: homepage.noticeCard
class Translations$homepage$noticeCard$zh {
	Translations$homepage$noticeCard$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '目前没有获取应用公告，请刷新'
	String get emptyNotice => '目前没有获取应用公告，请刷新';

	/// zh: '没有获取应用公告'
	String get noNoticeAvaliable => '没有获取应用公告';

	/// zh: '应用信息'
	String get noticeListTitle => '应用信息';

	/// zh: '访问该链接'
	String get openUrl => '访问该链接';

	/// zh: '通知列表'
	String get noticePageTitle => '通知列表';
}

// Path: homepage.classTableCard
class Translations$homepage$classTableCard$zh {
	Translations$homepage$classTableCard$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '课程表'
	String get title => '课程表';

	/// zh: '今日还有 {remain} 个日程'
	String today({required Object remain}) => '今日还有 ${remain} 个日程';

	/// zh: '今日安排完成'
	String get todayFinished => '今日安排完成';

	/// zh: '明日有 {remain} 个安排'
	String tomorrow({required Object remain}) => '明日有 ${remain} 个安排';

	/// zh: '明日没有安排'
	String get tomorrowNone => '明日没有安排';

	/// zh: '第 {weekinfo} 周'
	String weekInfo({required Object weekinfo}) => '第 ${weekinfo} 周';

	/// zh: '假期中'
	String get onHoliday => '假期中';

	/// zh: '遇到错误：{error}'
	String errorMessage({required Object error}) => '遇到错误：${error}';

	/// zh: '正在获取课表'
	String get fetchingMessage => '正在获取课表';

	/// zh: '遇到错误'
	String get errorInfoText => '遇到错误';

	/// zh: '正在加载'
	String get fetchingInfoText => '正在加载';

	/// zh: '暂无日程'
	String get noArrangementInfoText => '暂无日程';

	/// zh: '日程正在加载，请稍后查看'
	String get scheduleFetchingMessage => '日程正在加载，请稍后查看';

	/// zh: '日程加载失败，请稍后重试'
	String get scheduleErrorMessage => '日程加载失败，请稍后重试';

	/// zh: '正在加载日程'
	String get scheduleFetchingInfoText => '正在加载日程';

	/// zh: '日程加载失败'
	String get scheduleErrorInfoText => '日程加载失败';

	/// zh: '暂无日程'
	String get scheduleNoneInfoText => '暂无日程';

	/// zh: '正在更新'
	String get updatingInfoText => '正在更新';

	/// zh: '全部加载中'
	String get allLoadingInfoText => '全部加载中';

	/// zh: '部分加载中'
	String get partialLoadingInfoText => '部分加载中';

	/// zh: '部分数据加载失败'
	String get partialErrorInfoText => '部分数据加载失败';

	/// zh: '{source}加载失败'
	String failedChip({required Object source}) => '${source}加载失败';

	/// zh: '课程信息'
	String get failedSourceClassInfo => '课程信息';

	/// zh: '考试信息'
	String get failedSourceExamInfo => '考试信息';

	/// zh: '物理实验'
	String get failedSourcePhysicsExperiment => '物理实验';

	/// zh: '其他实验'
	String get failedSourceOtherExperiment => '其他实验';

	/// zh: '未知位置'
	String get unknownPlace => '未知位置';

	/// zh: '座位号{seatnum}'
	String seat({required Object seatnum}) => '座位号${seatnum}';
}

// Path: homepage.electricityCard
class Translations$homepage$electricityCard$zh {
	Translations$homepage$electricityCard$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '水电信息'
	String get title => '水电信息';

	/// zh: '余额 {amount} 度'
	String currentElectricity({required Object amount}) => '余额 ${amount} 度';

	/// zh: '最后一次读表：{date}'
	String cacheNotice({required Object date}) => '最后一次读表：${date}';
}

// Path: homepage.libraryCard
class Translations$homepage$libraryCard$zh {
	Translations$homepage$libraryCard$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '图书借阅'
	String get title => '图书借阅';

	/// zh: '借书 {count} 本'
	String currentBorrow({required Object count}) => '借书 ${count} 本';

	/// zh: '获取借书信息发生错误'
	String get errorOccured => '获取借书信息发生错误';

	/// zh: '正在获取借书信息'
	String get fetching => '正在获取借书信息';

	/// zh: '目前没有待归还书籍'
	String get noReturn => '目前没有待归还书籍';

	/// zh: '待归还 {dued} 本书籍'
	String needReturn({required Object dued}) => '待归还 ${dued} 本书籍';

	/// zh: '目前无法获取信息'
	String get noInfo => '目前无法获取信息';

	/// zh: '正在查询信息中'
	String get fetchingInfo => '正在查询信息中';
}

// Path: homepage.schoolCardInfoCard
class Translations$homepage$schoolCardInfoCard$zh {
	Translations$homepage$schoolCardInfoCard$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '遇到错误，请联系开发者'
	String get errorToast => '遇到错误，请联系开发者';

	/// zh: '正在获取信息，请稍后再来看'
	String get fetchingToast => '正在获取信息，请稍后再来看';

	/// zh: '流水'
	String get bill => '流水';

	/// zh: '卡里 {amount} 元'
	String balance({required Object amount}) => '卡里 ${amount} 元';

	/// zh: '获取校园卡信息发生错误'
	String get errorOccured => '获取校园卡信息发生错误';

	/// zh: '正在获取校园卡信息'
	String get fetching => '正在获取校园卡信息';

	/// zh: '查询一卡通流水'
	String get bottomTextSuccess => '查询一卡通流水';

	/// zh: '目前无法获取信息'
	String get noInfo => '目前无法获取信息';

	/// zh: '正在查询信息中'
	String get fetchingInfo => '正在查询信息中';
}

// Path: homepage.toolbox
class Translations$homepage$toolbox$zh {
	Translations$homepage$toolbox$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '考勤查询'
	String get classAttendance => '考勤查询';

	/// zh: '双创竞赛'
	String get creative => '双创竞赛';

	/// zh: '空闲教室'
	String get emptyClassroom => '空闲教室';

	/// zh: '考试安排'
	String get exam => '考试安排';

	/// zh: '实验信息'
	String get experiment => '实验信息';

	/// zh: '成绩查询'
	String get score => '成绩查询';

	/// zh: '体育信息'
	String get sport => '体育信息';

	/// zh: '宿舍水机'
	String get dormWater => '宿舍水机';

	/// zh: '网络查询'
	String get schoolnet => '网络查询';

	/// zh: '其他功能'
	String get toolbox => '其他功能';

	/// zh: '脱机状态且无缓存成绩数据，无法访问'
	String get scoreCannotReach => '脱机状态且无缓存成绩数据，无法访问';

	/// zh: '请稍候，正在获取考试信息'
	String get examFetching => '请稍候，正在获取考试信息';

	/// zh: '遇到错误，请联系开发者'
	String get examError => '遇到错误，请联系开发者';
}

// Path: homepage.schoolNet
class Translations$homepage$schoolNet$zh {
	Translations$homepage$schoolNet$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '已用 {usage}'
	String title({required Object usage}) => '已用 ${usage}';

	/// zh: '无校园网密码，点击设置'
	String get noPassword => '无校园网密码，点击设置';

	/// zh: '获取校园网流量信息失败'
	String get failed => '获取校园网流量信息失败';

	/// zh: '正在获取校园网流量信息'
	String get fetching => '正在获取校园网流量信息';

	/// zh: '下次结算 {remaining}'
	String remaining({required Object remaining}) => '下次结算 ${remaining}';
}

// Path: homepage.clubPromotion
class Translations$homepage$clubPromotion$zh {
	Translations$homepage$clubPromotion$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '社团信息获取失败'
	String get failed => '社团信息获取失败';

	/// zh: '社团信息清单正在加载'
	String get fetching => '社团信息清单正在加载';
}

// Path: login.captchaWindow
class Translations$login$captchaWindow$zh {
	Translations$login$captchaWindow$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '请输入验证码'
	String get title => '请输入验证码';

	/// zh: '输入验证码'
	String get hint => '输入验证码';

	/// zh: '请输入验证码'
	String get messageOnEmpty => '请输入验证码';

	/// zh: '刷新验证码失败: {error}'
	String refreshFailed({required Object error}) => '刷新验证码失败: ${error}';
}

// Path: login.secondFactor
class Translations$login$secondFactor$zh {
	Translations$login$secondFactor$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '短信二次认证'
	String get title => '短信二次认证';

	/// zh: '学校要求完成二次认证。请先获取短信验证码，再输入验证码继续登录。'
	String get description => '学校要求完成二次认证。请先获取短信验证码，再输入验证码继续登录。';

	/// zh: '短信验证码'
	String get code => '短信验证码';

	/// zh: '请输入短信验证码'
	String get emptyCode => '请输入短信验证码';

	/// zh: '获取验证码'
	String get sendCode => '获取验证码';

	/// zh: '{seconds} 秒后可重新获取'
	String resendCountdown({required Object seconds}) => '${seconds} 秒后可重新获取';

	/// zh: '信任此设备'
	String get trustDevice => '信任此设备';

	/// zh: '开启后学校可能在一段时间内不再要求本设备二次认证'
	String get trustDeviceHint => '开启后学校可能在一段时间内不再要求本设备二次认证';

	/// zh: '二次认证请求失败，请检查网络后重试'
	String get networkError => '二次认证请求失败，请检查网络后重试';

	/// zh: '已取消短信二次认证'
	String get cancelled => '已取消短信二次认证';

	/// zh: '二次认证已失效，请重新登录'
	String get expired => '二次认证已失效，请重新登录';
}

// Path: ruisi.common
class Translations$ruisi$common$zh {
	Translations$ruisi$common$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '刷新'
	String get refresh => '刷新';

	/// zh: '确定'
	String get confirm => '确定';

	/// zh: '取消'
	String get cancel => '取消';

	/// zh: '重试'
	String get retry => '重试';

	/// zh: '暂无帖子'
	String get noTopics => '暂无帖子';

	/// zh: '暂无内容'
	String get noContent => '暂无内容';

	/// zh: '回复'
	String get reply => '回复';

	/// zh: '收藏'
	String get favorite => '收藏';

	/// zh: '未实现'
	String get notImplemented => '未实现';

	/// zh: '登录'
	String get login => '登录';

	/// zh: '退出登录'
	String get logout => '退出登录';

	/// zh: '已退出登录'
	String get loggedOut => '已退出登录';

	/// zh: '提交'
	String get submit => '提交';
}

// Path: ruisi.about
class Translations$ruisi$about$zh {
	Translations$ruisi$about$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '关于'
	String get title => '关于';

	/// zh: '睿思'
	String get appName => '睿思';

	/// zh: '西安电子科技大学校园论坛客户端'
	String get subtitle => '西安电子科技大学校园论坛客户端';

	/// zh: '版本'
	String get version => '版本';

	/// zh: '2.0.0 (随 XDYou 1.6.0 分发)'
	String get versionNumber => '2.0.0 (随 XDYou 1.6.0 分发)';

	/// zh: '源代码'
	String get sourceCode => '源代码';

	/// zh: '问题反馈'
	String get bugReport => '问题反馈';

	/// zh: '在 GitHub 上提交 issue'
	String get bugReportSubtitle => '在 GitHub 上提交 issue';

	/// zh: '隐私政策'
	String get privacyPolicy => '隐私政策';

	/// zh: '本应用基于 BSD-3-Clause 许可证开源 基于 Ruisi-iOS 和 Ruisi-Android 在 AI 辅助下重写'
	String get license => '本应用基于 BSD-3-Clause 许可证开源 基于 Ruisi-iOS 和 Ruisi-Android 在 AI 辅助下重写';

	/// zh: '本应用仅在西安电子科技大学校园网内运行，访问睿思论坛 (rs.xidian.edu.cn) 的数据。 本应用不会收集、存储或传输任何用户的个人信息到第三方服务器。 用户的登录凭据仅保存在本地设备中，用于与睿思论坛服务器进行身份验证。 本应用使用 Cookie 与睿思论坛服务器进行通信，所有数据交互均直接在用户的设备与睿思论坛服务器之间进行。 如有任何疑问，请通过 GitHub 提交 issue 联系开发者。'
	String get privacyPolicyContent => '本应用仅在西安电子科技大学校园网内运行，访问睿思论坛 (rs.xidian.edu.cn) 的数据。\n\n本应用不会收集、存储或传输任何用户的个人信息到第三方服务器。\n\n用户的登录凭据仅保存在本地设备中，用于与睿思论坛服务器进行身份验证。\n\n本应用使用 Cookie 与睿思论坛服务器进行通信，所有数据交互均直接在用户的设备与睿思论坛服务器之间进行。\n\n如有任何疑问，请通过 GitHub 提交 issue 联系开发者。';
}

// Path: ruisi.home
class Translations$ruisi$home$zh {
	Translations$ruisi$home$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '睿思论坛'
	String get title => '睿思论坛';

	/// zh: '发帖'
	String get newPost => '发帖';

	/// zh: '论坛板块'
	String get forumList => '论坛板块';

	/// zh: '热帖'
	String get tabHot => '热帖';

	/// zh: '最新回复'
	String get tabNewReply => '最新回复';

	/// zh: '最新发表'
	String get tabNewPost => '最新发表';

	/// zh: '我的'
	String get tabMy => '我的';

	/// zh: '二手交易'
	String get tabTrade => '二手交易';

	/// zh: '灌水'
	String get tabWater => '灌水';

	/// zh: '失物招领'
	String get tabLostFound => '失物招领';

	/// zh: '就业'
	String get tabEmployment => '就业';

	/// zh: '摄影'
	String get tabPhotography => '摄影';

	/// zh: '请先登录'
	String get pleaseLogin => '请先登录';

	/// zh: '我的资料'
	String get myProfile => '我的资料';

	/// zh: '我的帖子'
	String get myPosts => '我的帖子';

	/// zh: '我的收藏'
	String get myFavorites => '我的收藏';

	/// zh: '消息中心'
	String get messageCenter => '消息中心';

	/// zh: '每日签到'
	String get dailyCheckin => '每日签到';

	/// zh: '设置'
	String get settings => '设置';

	/// zh: '关于'
	String get about => '关于';

	/// zh: '搜索'
	String get search => '搜索';
}

// Path: ruisi.login
class Translations$ruisi$login$zh {
	Translations$ruisi$login$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '登录睿思'
	String get title => '登录睿思';

	/// zh: '用户名'
	String get username => '用户名';

	/// zh: '请输入用户名'
	String get usernameHint => '请输入用户名';

	/// zh: '密码'
	String get password => '密码';

	/// zh: '请输入密码'
	String get passwordHint => '请输入密码';

	/// zh: '验证码'
	String get captcha => '验证码';

	/// zh: '请输入验证码'
	String get captchaHint => '请输入验证码';

	/// zh: '返回'
	String get back => '返回';

	/// zh: '重置登录状态'
	String get resetLoginState => '重置登录状态';

	/// zh: '确认重置'
	String get resetConfirmTitle => '确认重置';

	/// zh: '确定要重置登录状态吗？这将清除所有登录信息。'
	String get resetConfirmContent => '确定要重置登录状态吗？这将清除所有登录信息。';

	/// zh: '登录状态已重置'
	String get resetSuccess => '登录状态已重置';

	/// zh: '查看日志'
	String get viewLogs => '查看日志';
}

// Path: ruisi.post
class Translations$ruisi$post$zh {
	Translations$ruisi$post$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '发帖'
	String get title => '发帖';

	/// zh: '发布'
	String get publish => '发布';

	/// zh: '选择板块'
	String get selectForum => '选择板块';

	/// zh: '请选择板块'
	String get selectForumHint => '请选择板块';

	/// zh: '标题'
	String get subject => '标题';

	/// zh: '请输入标题'
	String get subjectHint => '请输入标题';

	/// zh: '内容'
	String get content => '内容';

	/// zh: '请输入内容'
	String get contentHint => '请输入内容';

	/// zh: '发帖成功'
	String get success => '发帖成功';

	/// zh: '发帖失败'
	String get failure => '发帖失败';

	/// zh: '表情'
	String get smiley => '表情';
}

// Path: ruisi.topicDetail
class Translations$ruisi$topicDetail$zh {
	Translations$ruisi$topicDetail$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '帖子详情'
	String get title => '帖子详情';

	/// zh: '回复内容不能少于 13 个字符'
	String get replyTooShort => '回复内容不能少于 13 个字符';

	/// zh: '回复成功'
	String get replySuccess => '回复成功';

	/// zh: '回复失败'
	String get replyFailure => '回复失败';

	/// zh: '收藏成功'
	String get favoriteSuccess => '收藏成功';

	/// zh: '收藏失败'
	String get favoriteFailure => '收藏失败';

	/// zh: '无数据'
	String get noData => '无数据';

	/// zh: '写回复...'
	String get replyHint => '写回复...';

	late final Translations$ruisi$topicDetail$vote$zh vote = Translations$ruisi$topicDetail$vote$zh.internal(_root);
}

// Path: ruisi.topicListItem
class Translations$ruisi$topicListItem$zh {
	Translations$ruisi$topicListItem$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '置顶'
	String get sticky => '置顶';
}

// Path: ruisi.forumList
class Translations$ruisi$forumList$zh {
	Translations$ruisi$forumList$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '论坛板块'
	String get title => '论坛板块';

	/// zh: '睿思论坛版块分组为空'
	String get empty => '睿思论坛版块分组为空';
}

// Path: ruisi.favorites
class Translations$ruisi$favorites$zh {
	Translations$ruisi$favorites$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '我的收藏'
	String get title => '我的收藏';

	/// zh: '暂无收藏'
	String get empty => '暂无收藏';
}

// Path: ruisi.messages
class Translations$ruisi$messages$zh {
	Translations$ruisi$messages$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '消息'
	String get title => '消息';

	/// zh: '@我'
	String get tabAt => '@我';

	/// zh: '暂无回复通知'
	String get noReply => '暂无回复通知';

	/// zh: '暂无@通知'
	String get noAt => '暂无@通知';
}

// Path: ruisi.search
class Translations$ruisi$search$zh {
	Translations$ruisi$search$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '搜索帖子...'
	String get hint => '搜索帖子...';

	/// zh: '输入关键词搜索'
	String get inputHint => '输入关键词搜索';

	/// zh: '无搜索结果'
	String get noResults => '无搜索结果';
}

// Path: ruisi.settings
class Translations$ruisi$settings$zh {
	Translations$ruisi$settings$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '设置'
	String get title => '设置';

	/// zh: '代理'
	String get sectionProxy => '代理';

	/// zh: '启用代理'
	String get proxyEnable => '启用代理';

	/// zh: '未启用'
	String get proxyDisabled => '未启用';

	/// zh: '代理地址'
	String get proxyAddress => '代理地址';

	/// zh: '调试'
	String get sectionDebug => '调试';

	/// zh: '查看日志'
	String get viewLogs => '查看日志';

	/// zh: '代理设置'
	String get proxyDialogTitle => '代理设置';

	/// zh: '主机地址'
	String get proxyHost => '主机地址';

	/// zh: '例如 127.0.0.1'
	String get proxyHostHint => '例如 127.0.0.1';

	/// zh: '端口'
	String get proxyPort => '端口';

	/// zh: '例如 7890'
	String get proxyPortHint => '例如 7890';
}

// Path: ruisi.user
class Translations$ruisi$user$zh {
	Translations$ruisi$user$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '我的'
	String get title => '我的';

	/// zh: '资料'
	String get tabProfile => '资料';

	/// zh: '未知用户'
	String get unknown => '未知用户';
}

// Path: schoolNet.idsAccountNet
class Translations$schoolNet$idsAccountNet$zh {
	Translations$schoolNet$idsAccountNet$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '当前用户'
	String get title => '当前用户';

	/// zh: '这是登录到 PDA 账户的校园网信息 注意: 流量计费采用GB单位（1000进制） 如果没有看到信息，请访问 zfw.xidian.edu.cn 重置网络密码'
	String get notice => '这是登录到 PDA 账户的校园网信息\n注意: 流量计费采用GB单位（1000进制）\n如果没有看到信息，请访问 zfw.xidian.edu.cn 重置网络密码';

	/// zh: '账户概览'
	String get overview => '账户概览';

	/// zh: '账号'
	String get account => '账号';

	/// zh: '已使用流量'
	String get used => '已使用流量';

	/// zh: '余额'
	String get remain => '余额';

	/// zh: '在线设备（{length}台）'
	String currentOnline({required Object length}) => '在线设备（${length}台）';

	/// zh: '当前没有在线设备'
	String get noDeviceOnline => '当前没有在线设备';
}

// Path: schoolNet.currentLoginNet
class Translations$schoolNet$currentLoginNet$zh {
	Translations$schoolNet$currentLoginNet$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '正在使用'
	String get title => '正在使用';

	/// zh: '这是您正在使用中校园网的信息，可能和您登录 PDA 的信息不一致 注意: 流量计费采用GB单位（1000进制）'
	String get notice => '这是您正在使用中校园网的信息，可能和您登录 PDA 的信息不一致\n注意: 流量计费采用GB单位（1000进制）';

	/// zh: '账户概览'
	String get overview => '账户概览';

	/// zh: '账号'
	String get account => '账号';

	/// zh: '套餐类型'
	String get planType => '套餐类型';

	/// zh: '余额'
	String get remain => '余额';

	/// zh: '流量使用情况'
	String get usageSituation => '流量使用情况';

	/// zh: '已使用 {percent}%'
	String usedPercent({required Object percent}) => '已使用 ${percent}%';

	/// zh: '已使用流量'
	String get used => '已使用流量';

	/// zh: '剩余流量'
	String get remainCount => '剩余流量';

	/// zh: '总流量'
	String get total => '总流量';

	/// zh: '非校园网'
	String get nonSchoolnet => '非校园网';
}

// Path: schoolNet.deviceList
class Translations$schoolNet$deviceList$zh {
	Translations$schoolNet$deviceList$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '在线设备IP'
	String get ip => '在线设备IP';

	/// zh: '上线时间'
	String get time => '上线时间';

	/// zh: '流量用量'
	String get remain => '流量用量';
}

// Path: score.scoreChoice
class Translations$score$scoreChoice$zh {
	Translations$score$scoreChoice$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '成绩单'
	String get title => '成绩单';

	/// zh: '搜索成绩记录'
	String get searchHint => '搜索成绩记录';

	/// zh: '没有选择该学期的课程计入均分计算'
	String get emptyList => '没有选择该学期的课程计入均分计算';

	/// zh: '小总结'
	String get sumDialogTitle => '小总结';

	/// zh: '所有科目的GPA：{gpa_all} 所有科目的均分：{avg_all} 所有科目的学分：{credit_all} 未通过科目：{unpassed} 公共选修课：{not_core_type} 本程序提供的数据仅供参考，开发者对其准确性不负责'
	String sumDialogContent({required Object gpa_all, required Object avg_all, required Object credit_all, required Object unpassed, required Object not_core_type}) => '所有科目的GPA：${gpa_all}\n所有科目的均分：${avg_all}\n所有科目的学分：${credit_all}\n未通过科目：${unpassed}\n公共选修课：${not_core_type}\n本程序提供的数据仅供参考，开发者对其准确性不负责';
}

// Path: score.scoreComposeCard
class Translations$score$scoreComposeCard$zh {
	Translations$score$scoreComposeCard$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '未提供详情信息'
	String get noDetail => '未提供详情信息';

	/// zh: '正在获取'
	String get fetching => '正在获取';

	/// zh: '学分'
	String get credit => '学分';

	/// zh: 'GPA'
	String get gpa => 'GPA';

	/// zh: '成绩'
	String get score => '成绩';
}

// Path: score.scoreInfoCard
class Translations$score$scoreInfoCard$zh {
	Translations$score$scoreInfoCard$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '成绩详情'
	String get title => '成绩详情';

	/// zh: '初修'
	String get originalCourse => '初修';

	/// zh: '[挂] '
	String get failed => '[挂] ';

	/// zh: '学分 {credit}'
	String credit({required Object credit}) => '学分 ${credit}';

	/// zh: 'GPA {gpa}'
	String gpa({required Object gpa}) => 'GPA ${gpa}';

	/// zh: '成绩 {score}'
	String score({required Object score}) => '成绩 ${score}';
}

// Path: score.scorePage
class Translations$score$scorePage$zh {
	Translations$score$scorePage$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '成绩查询'
	String get title => '成绩查询';

	/// zh: '搜索成绩记录'
	String get searchHint => '搜索成绩记录';

	/// zh: '未筛查到合请求的记录'
	String get noRecord => '未筛查到合请求的记录';

	/// zh: '全选'
	String get selectAll => '全选';

	/// zh: '全不选'
	String get selectNothing => '全不选';

	/// zh: '重置选择'
	String get resetSelect => '重置选择';

	/// zh: '总结'
	String get summary => '总结';

	/// zh: '国家英语四级'
	String get cet4 => '国家英语四级';

	/// zh: '国家英语六级'
	String get cet6 => '国家英语六级';
}

// Path: setting.lowElectricityThresholdDialog
class Translations$setting$lowElectricityThresholdDialog$zh {
	Translations$setting$lowElectricityThresholdDialog$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '设置低电量阈值'
	String get title => '设置低电量阈值';

	/// zh: '请输入电量度数'
	String get inputHint => '请输入电量度数';
}

// Path: setting.notificationPage
class Translations$setting$notificationPage$zh {
	Translations$setting$notificationPage$zh.internal(this._root);

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

// Path: setting.clearAndRestartDialog
class Translations$setting$clearAndRestartDialog$zh {
	Translations$setting$clearAndRestartDialog$zh.internal(this._root);

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

// Path: setting.logoutDialog
class Translations$setting$logoutDialog$zh {
	Translations$setting$logoutDialog$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '确认对话框'
	String get title => '确认对话框';

	/// zh: '确定退出登录？你的所有数据将会被彻底删除！'
	String get content => '确定退出登录？你的所有数据将会被彻底删除！';

	/// zh: '正在退出登录'
	String get loggingOut => '正在退出登录';
}

// Path: setting.needCloseDialog
class Translations$setting$needCloseDialog$zh {
	Translations$setting$needCloseDialog$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '请关闭应用'
	String get title => '请关闭应用';

	/// zh: '因为技术限制，用户需要自行关闭窗口，然后重新打开应用。'
	String get content => '因为技术限制，用户需要自行关闭窗口，然后重新打开应用。';
}

// Path: setting.changeColorDialog
class Translations$setting$changeColorDialog$zh {
	Translations$setting$changeColorDialog$zh.internal(this._root);

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

// Path: setting.changeBrightnessDialog
class Translations$setting$changeBrightnessDialog$zh {
	Translations$setting$changeBrightnessDialog$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '亮度设置'
	String get title => '亮度设置';

	/// zh: '跟随系统'
	String get followSetting => '跟随系统';

	/// zh: '白天模式'
	String get dayMode => '白天模式';

	/// zh: '黑夜模式'
	String get nightMode => '黑夜模式';
}

// Path: setting.changeSwiftDialog
class Translations$setting$changeSwiftDialog$zh {
	Translations$setting$changeSwiftDialog$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '课程偏移设置'
	String get title => '课程偏移设置';

	/// zh: '请在此输入数字'
	String get inputHint => '请在此输入数字';
}

// Path: setting.changeElectricityAccount
class Translations$setting$changeElectricityAccount$zh {
	Translations$setting$changeElectricityAccount$zh.internal(this._root);

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

// Path: setting.changePasswordDialog
class Translations$setting$changePasswordDialog$zh {
	Translations$setting$changePasswordDialog$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '请在此输入密码'
	String get inputHint => '请在此输入密码';

	/// zh: '输入空白!'
	String get blankInput => '输入空白!';
}

// Path: setting.updateDialog
class Translations$setting$updateDialog$zh {
	Translations$setting$updateDialog$zh.internal(this._root);

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

// Path: setting.localizationDialog
class Translations$setting$localizationDialog$zh {
	Translations$setting$localizationDialog$zh.internal(this._root);

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

// Path: setting.aboutPage
class Translations$setting$aboutPage$zh {
	Translations$setting$aboutPage$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '主要开发者，iOS 小部件编写和拼接'
	String get benderblog => '主要开发者，iOS 小部件编写和拼接';

	/// zh: '开发：图书馆搜索和封面'
	String get alnair => '开发：图书馆搜索和封面';

	/// zh: '开发：考勤历史记录'
	String get aqqkad => '开发：考勤历史记录';

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

	/// zh: '开发：设计软件主页 / 开发：平板考勤查询页面 / 开发：优化了体育查询界面的UI'
	String get imoscarz => '开发：设计软件主页 / 开发：平板考勤查询页面 / 开发：优化了体育查询界面的UI';

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
}

// Path: xduPlanet.confirmAuditDialog
class Translations$xduPlanet$confirmAuditDialog$zh {
	Translations$xduPlanet$confirmAuditDialog$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '确认是否举报'
	String get title => '确认是否举报';

	/// zh: '三思而后行，确定您想举报吗？举报后该评论会有标签，不一定会删除。'
	String get content => '三思而后行，确定您想举报吗？举报后该评论会有标签，不一定会删除。';

	/// zh: '不举报了'
	String get cancel => '不举报了';

	/// zh: '正在举报评论'
	String get ongoing => '正在举报评论';

	/// zh: '举报失败'
	String get failed => '举报失败';

	/// zh: '举报成功'
	String get success => '举报成功';
}

// Path: classtable.partnerClasstable.shareDialog
class Translations$classtable$partnerClasstable$shareDialog$zh {
	Translations$classtable$partnerClasstable$shareDialog$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '请不要随意分享'
	String get title => '请不要随意分享';

	/// zh: '导出文件包括你的个人信息，请不要随意跟别人分享，或者发在大群里。'
	String get content => '导出文件包括你的个人信息，请不要随意跟别人分享，或者发在大群里。';
}

// Path: classtable.partnerClasstable.saveDialog
class Translations$classtable$partnerClasstable$saveDialog$zh {
	Translations$classtable$partnerClasstable$saveDialog$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '保存日历文件到...'
	String get title => '保存日历文件到...';

	/// zh: '应该保存成功'
	String get successMessage => '应该保存成功';

	/// zh: '文件创建失败，保存取消'
	String get failureMessage => '文件创建失败，保存取消';
}

// Path: classtable.partnerClasstable.deleteDialog
class Translations$classtable$partnerClasstable$deleteDialog$zh {
	Translations$classtable$partnerClasstable$deleteDialog$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '确认对话框'
	String get title => '确认对话框';

	/// zh: '确定要清除搭子课表吗？'
	String get message => '确定要清除搭子课表吗？';

	/// zh: '删除搭子课表成功'
	String get successMessage => '删除搭子课表成功';
}

// Path: classtable.partnerClasstable.nameDialog
class Translations$classtable$partnerClasstable$nameDialog$zh {
	Translations$classtable$partnerClasstable$nameDialog$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '输入对方显示该课表的名称'
	String get title => '输入对方显示该课表的名称';

	/// zh: '在此输入，否则为 Sweetie'
	String get hint => '在此输入，否则为 Sweetie';

	/// zh: '我就这一个甜心'
	String get cancel => '我就这一个甜心';

	/// zh: '提交'
	String get accept => '提交';

	/// zh: '输入空白!'
	String get blankInput => '输入空白!';
}

// Path: classtable.classAdd.dateSelectorFree
class Translations$classtable$classAdd$dateSelectorFree$zh {
	Translations$classtable$classAdd$dateSelectorFree$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '时间必须在 08:30-21:25 之间'
	String get rule => '时间必须在 08:30-21:25 之间';

	/// zh: '下课时间必须晚于上课时间'
	String get rule2 => '下课时间必须晚于上课时间';

	/// zh: '上课时间'
	String get classStartTime => '上课时间';

	/// zh: '下课时间'
	String get classEndTime => '下课时间';

	/// zh: '编辑课程时间'
	String get editClassTime => '编辑课程时间';

	/// zh: '选择课程时间'
	String get chooseClassTime => '选择课程时间';
}

// Path: ruisi.topicDetail.vote
class Translations$ruisi$topicDetail$vote$zh {
	Translations$ruisi$topicDetail$vote$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '单选'
	String get singleSelect => '单选';

	/// zh: '多选，最多 {count} 项'
	String multiSelect({required Object count}) => '多选，最多 ${count} 项';

	/// zh: '投票'
	String get titlePrefix => '投票';

	/// zh: '共 {count} 人参与'
	String count({required Object count}) => '共 ${count} 人参与';

	/// zh: '点此投票'
	String get open => '点此投票';

	/// zh: '投票'
	String get sheetTitle => '投票';

	/// zh: '最多只能选择 {count} 项'
	String maxSelection({required Object count}) => '最多只能选择 ${count} 项';

	/// zh: '你还没有选择'
	String get notSelected => '你还没有选择';

	/// zh: '投票成功'
	String get success => '投票成功';

	/// zh: '投票失败'
	String get failure => '投票失败';

	/// zh: '投票失败：参数错误'
	String get paramError => '投票失败：参数错误';

	/// zh: '您已经投过票，谢谢您的参与'
	String get alreadyVoted => '您已经投过票，谢谢您的参与';

	/// zh: '该投票已过期或关闭'
	String get expired => '该投票已过期或关闭';

	/// zh: '投票已经结束'
	String get ended => '投票已经结束';
}

/// The flat map containing all translations for locale <zh>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'classAttendance.title' => '考勤查询',
			'classAttendance.detailTitle' => ({required Object course_name}) => '签到信息 - ${course_name}',
			'classAttendance.noData' => '没有找到课程数据',
			'classAttendance.noAttendanceRecord' => '没有签到记录',
			'classAttendance.longLoad' => '考勤数据的加载时间约半分钟，请耐心等待',
			'classAttendance.courseState.unknown' => '未知',
			'classAttendance.courseState.ineligible' => '取消',
			'classAttendance.courseState.eligible' => '正常',
			'classAttendance.courseState.warning' => '危险',
			'classAttendance.table.courseName' => '课程名称',
			'classAttendance.table.status' => '状态',
			'classAttendance.table.attendanceRate' => '到课率',
			'classAttendance.table.checkIn' => '签到',
			'classAttendance.table.absence' => '缺勤',
			'classAttendance.table.required' => '应签',
			'classAttendance.table.leave' => '请假(事/病/公)',
			'classAttendance.table.filter' => '筛选',
			'classAttendance.table.filterAll' => '全部',
			'classAttendance.table.showingCount' => ({required Object count, required Object total}) => '显示 ${count}/${total} 门课程',
			'classAttendance.card.time' => '签到次数',
			'classAttendance.card.timeInfo' => ({required Object check_in_count, required Object absence_count, required Object required_check_in}) => '${check_in_count} 已签 / ${absence_count} 缺勤 / ${required_check_in} 应签',
			'classAttendance.card.notAttend' => '复活次数',
			'classAttendance.card.notAttendInfo' => ({required Object time_to_have_error, required Object total_times}) => '${time_to_have_error} 次 / ${total_times} 总课程',
			'classAttendance.card.notAttendInfoError' => '无法对应已有课程',
			'classAttendance.card.leave' => '请假次数',
			'classAttendance.card.leaveInfo' => ({required Object personal_leave, required Object sick_leave, required Object official_leave}) => '事假 ${personal_leave} / 病假 ${sick_leave} / 公假 ${official_leave}',
			'classAttendance.card.study' => '学习进度',
			'classAttendance.card.studyInfo' => ({required Object task_progress, required Object homework_progress, required Object exam_progress}) => '任务点 ${task_progress} / 作业 ${homework_progress} / 考试 ${exam_progress}',
			'classAttendance.detailCard.creatorName' => '发起人',
			'classAttendance.detailCard.startTime' => '开始时间',
			'classAttendance.detailCard.summitTime' => '提交时间',
			'classAttendance.signType.qrCode' => '二维码签到',
			'classAttendance.signType.gesture' => '手势签到',
			'classAttendance.signType.position' => '位置签到',
			'classAttendance.signType.kDefault' => '普通签到',
			'classAttendance.signStatus.absenceNotParticipating' => '缺勤未参与',
			'classAttendance.signStatus.signed' => '已签',
			'classAttendance.signStatus.signedByTeacher' => '代签',
			'classAttendance.signStatus.personalLeave2' => '请假',
			'classAttendance.signStatus.absence' => '缺勤',
			'classAttendance.signStatus.sickLeave' => '病假',
			'classAttendance.signStatus.personalLeave' => '事假',
			'classAttendance.signStatus.late' => '迟到',
			'classAttendance.signStatus.leaveEarly' => '早退',
			'classAttendance.signStatus.signExpiredy' => '签到已过期',
			'classAttendance.signStatus.publicLeave' => '公假',
			'classtable.partnerClasstable.overrideDialog' => '目前有搭子课表数据，是否要覆盖？',
			'classtable.partnerClasstable.noFile' => '未发现导入文件',
			'classtable.partnerClasstable.noPermission' => '未获取存储权限，无法读取文件',
			'classtable.partnerClasstable.problem' => '好像导入文件有点问题:P',
			'classtable.partnerClasstable.success' => '导入成功',
			'classtable.partnerClasstable.shareDialog.title' => '请不要随意分享',
			'classtable.partnerClasstable.shareDialog.content' => '导出文件包括你的个人信息，请不要随意跟别人分享，或者发在大群里。',
			'classtable.partnerClasstable.saveDialog.title' => '保存日历文件到...',
			'classtable.partnerClasstable.saveDialog.successMessage' => '应该保存成功',
			'classtable.partnerClasstable.saveDialog.failureMessage' => '文件创建失败，保存取消',
			'classtable.partnerClasstable.deleteDialog.title' => '确认对话框',
			'classtable.partnerClasstable.deleteDialog.message' => '确定要清除搭子课表吗？',
			'classtable.partnerClasstable.deleteDialog.successMessage' => '删除搭子课表成功',
			'classtable.partnerClasstable.nameDialog.title' => '输入对方显示该课表的名称',
			'classtable.partnerClasstable.nameDialog.hint' => '在此输入，否则为 Sweetie',
			'classtable.partnerClasstable.nameDialog.cancel' => '我就这一个甜心',
			'classtable.partnerClasstable.nameDialog.accept' => '提交',
			'classtable.partnerClasstable.nameDialog.blankInput' => '输入空白!',
			'classtable.pageTitle' => '我的日程表',
			'classtable.partnerPageTitle' => ({required Object partner_name}) => '${partner_name}的日程表',
			'classtable.popupMenu.notArranged' => '查看未安排课程信息',
			'classtable.popupMenu.classChanged' => '查看课程安排调整信息',
			'classtable.popupMenu.addClass' => '添加课程信息',
			'classtable.popupMenu.generateIcal' => '生成日历文件',
			'classtable.popupMenu.generatePartnerFile' => '生成共享课表文件',
			'classtable.popupMenu.importPartnerFile' => '导入共享课表文件',
			'classtable.popupMenu.deletePartnerFile' => '删除共享课表文件',
			'classtable.popupMenu.outputToSystem' => '导出到系统日历',
			'classtable.popupMenu.refreshClasstable' => '刷新日程表',
			'classtable.popupMenu.switchSemester' => '切换课程表学期',
			'classtable.popupMenu.currentTimeSettings' => '时间指示设置',
			'classtable.popupMenu.classColorSettings' => '课表样式设置',
			'classtable.visualSettings.currentTimeSettingsTitle' => '时间指示设置',
			'classtable.visualSettings.classColorSettingsTitle' => '课表样式设置',
			'classtable.visualSettings.completedStyleEnabled' => '已结束课程样式区分',
			'classtable.visualSettings.currentTimeSection' => '时间指示',
			'classtable.visualSettings.showCurrentTimeIndicator' => '显示当前时间指示线',
			'classtable.visualSettings.showCurrentTimeLabel' => '显示迷你数字时钟',
			'classtable.visualSettings.showTodayColumnHighlight' => '强调显示今天的纵列',
			'classtable.visualSettings.unfinishedSection' => '课程样式',
			'classtable.visualSettings.activeBrightnessFactor' => ({required Object value}) => '亮度: ${value}',
			'classtable.visualSettings.activeBorderAlpha' => ({required Object value}) => '边框透明度: ${value}',
			'classtable.visualSettings.activeInnerAlpha' => ({required Object value}) => '底色透明度: ${value}',
			'classtable.visualSettings.completedSection' => '已结束课程样式',
			'classtable.visualSettings.completedSaturationFactor' => ({required Object value}) => '底色饱和度: ${value}',
			'classtable.visualSettings.completedBrightnessFactor' => ({required Object value}) => '亮度: ${value}',
			'classtable.visualSettings.completedTextSaturationFactor' => ({required Object value}) => '文字饱和度: ${value}',
			'classtable.visualSettings.completedBorderAlpha' => ({required Object value}) => '边框透明度: ${value}',
			'classtable.visualSettings.completedInnerAlpha' => ({required Object value}) => '底色透明度: ${value}',
			'classtable.statusSource.classTable' => '课表',
			'classtable.statusSource.exam' => '考试',
			'classtable.statusSource.physicsExperiment' => '物理实验',
			'classtable.statusSource.otherExperiment' => '其他实验',
			'classtable.errorDialogTitle' => '错误信息概览',
			'classtable.statusBanner.loading' => ({required Object sources}) => '正在更新：${sources}',
			'classtable.statusBanner.cache' => ({required Object sources}) => '当前使用缓存：${sources}',
			'classtable.statusBanner.errorSummary' => ({required Object sources}) => '以下信息加载失败：${sources}',
			'classtable.emptyState.noCourse' => ({required Object semester_code}) => '${semester_code} 学期没有课程安排。',
			'classtable.emptyState.withExam' => ({required Object semester_code}) => '${semester_code} 学期没有课程安排，但有考试安排。',
			'classtable.emptyState.withExperiment' => ({required Object semester_code}) => '${semester_code} 学期没有课程安排，但有实验安排。',
			'classtable.emptyState.withExamAndExperiment' => ({required Object semester_code}) => '${semester_code} 学期没有课程安排，但有考试和实验安排。',
			'classtable.emptyAction.viewExam' => '查看考试安排',
			'classtable.emptyAction.viewExperiment' => '查看实验安排',
			'classtable.classChangePage.title' => '课程调整',
			'classtable.classChangePage.emptyMessage' => '目前没有调课信息',
			'classtable.classChangePage.teacherChange' => ({required Object previous_teacher, required Object new_teacher}) => '教师变更：从${previous_teacher}变为${new_teacher}',
			'classtable.classChangePage.noTeacherChange' => '教师信息没有改变',
			'classtable.classChangePage.k1' => '一',
			'classtable.classChangePage.k2' => '二',
			'classtable.classChangePage.k3' => '三',
			'classtable.classChangePage.k4' => '四',
			'classtable.classChangePage.k5' => '五',
			'classtable.classChangePage.k6' => '六',
			'classtable.classChangePage.k7' => '日',
			'classtable.classChangePage.changeClassMessage' => ({required Object original_affected_weeks, required Object week_char_original_week, required Object original_class_range_start, required Object original_class_range_end, required Object new_affected_weeks_list_str, required Object week_char_new_week, required Object new_class_range_start, required Object new_class_range_stop, required Object new_classroom}) => '调课信息，从第${original_affected_weeks}周 星期${week_char_original_week}的${original_class_range_start}-${original_class_range_end}节 调整为第${new_affected_weeks_list_str}周星期${week_char_new_week}的${new_class_range_start}-${new_class_range_stop}节，${new_classroom}教室上课',
			'classtable.classChangePage.patchClassMessage' => ({required Object new_affected_weeks_list_str, required Object week_char_new_week, required Object new_class_range_start, required Object new_class_range_stop, required Object new_classroom}) => '补课信息，第${new_affected_weeks_list_str}周 星期${week_char_new_week}的${new_class_range_start}-${new_class_range_stop}节， ${new_classroom}补课',
			'classtable.classChangePage.stopClassMessage' => ({required Object original_affected_weeks, required Object week_char_original_week, required Object original_class_range_start, required Object original_class_range_end}) => '停课信息，第${original_affected_weeks}周 星期${week_char_original_week}的${original_class_range_start}-${original_class_range_end}节停课',
			'classtable.classChangePage.classInfo' => ({required Object class_code, required Object class_number, required Object class_change, required Object teacher_change}) => '编号: ${class_code} | ${class_number} 班\n安排变更：${class_change}${teacher_change}',
			'classtable.notArrangedPage.title' => '没有时间安排的科目',
			'classtable.notArrangedPage.emptyMessage' => '目前全部课程均有时间安排',
			'classtable.notArrangedPage.content' => ({required Object class_code, required Object class_number, required Object teacher}) => '编号: ${class_code} | ${class_number} 班\n老师: ${teacher}',
			'classtable.emptyClassMessage' => ({required Object semester_code}) => '${semester_code} 学期没有课程',
			'classtable.emptyClassWithExam' => ({required Object semester_code}) => '${semester_code} 学期没有课程但是有考试安排！\n请回到主页后下滑点击”考试安排“按钮进入考试安排页面',
			'classtable.weekTitle' => ({required Object week}) => '第${week}周',
			'classtable.noonBreak' => '午休',
			'classtable.supperBreak' => '晚休',
			'classtable.month' => ({required Object month}) => '${month}\n月',
			'classtable.noClass' => '本周暂无安排，请不要在床上过于慵懒',
			'classtable.classCard.title' => '日程信息',
			'classtable.classCard.unknownClassroom' => '未知教室',
			'classtable.classCard.remainsHint' => ({required Object remain_count}) => '还有${remain_count}个日程',
			'classtable.classAdd.addClassTitle' => '添加课程',
			'classtable.classAdd.changeClassTitle' => '修改课程',
			'classtable.classAdd.classNameEmptyMessage' => '必须输入课程名',
			'classtable.classAdd.wrongTimeMessage' => '输入的时间不对',
			'classtable.classAdd.saveButton' => '保存',
			'classtable.classAdd.inputClassnameHint' => '课程名字(必填)',
			'classtable.classAdd.inputTeacherHint' => '老师姓名(选填)',
			'classtable.classAdd.inputClassroomHint' => '教室位置(选填)',
			'classtable.classAdd.inputWeekHint' => '选择上课周次',
			'classtable.classAdd.inputTimeHint' => '选择上课时间',
			'classtable.classAdd.inputTimeWeekdayHint' => '上课周次',
			'classtable.classAdd.inputStartTimeHint' => '上课时间',
			'classtable.classAdd.inputEndTimeHint' => '下课时间',
			'classtable.classAdd.wheelChooseHint' => ({required Object index}) => '第 ${index} 节',
			'classtable.classAdd.chooseAtLeastOne' => '请至少选择一个上课日期和时间',
			'classtable.classAdd.repeatWeekly' => '按周重复',
			'classtable.classAdd.freeTime' => '自定义日期',
			'classtable.classAdd.dateSelectorFree.rule' => '时间必须在 08:30-21:25 之间',
			'classtable.classAdd.dateSelectorFree.rule2' => '下课时间必须晚于上课时间',
			'classtable.classAdd.dateSelectorFree.classStartTime' => '上课时间',
			'classtable.classAdd.dateSelectorFree.classEndTime' => '下课时间',
			'classtable.classAdd.dateSelectorFree.editClassTime' => '编辑课程时间',
			'classtable.classAdd.dateSelectorFree.chooseClassTime' => '选择课程时间',
			'classtable.courseDetailCard.classNumberString' => ({required Object number}) => '${number} 班',
			'classtable.courseDetailCard.unknownTeacher' => '老师未定',
			'classtable.courseDetailCard.unknownPlace' => '地点未定',
			'classtable.courseDetailCard.classPeriod' => ({required Object start, required Object stop}) => '${start}-${stop}节',
			'classtable.courseDetailCard.edit' => '编辑',
			'classtable.courseDetailCard.delete' => '删除',
			'classtable.courseDetailCard.deleteSingle' => '删除本次',
			'classtable.courseDetailCard.deleteAll' => '删除全部',
			'classtable.courseDetailCard.deleteContent' => '所有关于这个课的信息都会被删除，课表上关于这门课的信息将不复存在！',
			'classtable.courseDetailCard.deleteContentSingle' => '关于这个课的信息只有这个时间段都会被删除，其他的时间段会被保留。',
			'classtable.courseDetailCard.deleteTitle' => '是否删除课程信息？',
			'classtable.outputToSystem.success' => '成功导出到系统日历',
			'classtable.outputToSystem.failure' => '导出到系统日历过程中发生了问题:P',
			'classtable.outputToSystem.requestAllTitle' => '权限需求说明',
			'classtable.outputToSystem.requestAll' => '因导出插件限制，用户必须同时授予本软件读取日历和写入日历权限，才能正常导出日程。不过，本软件不会读取日历。',
			'classtable.refreshClasstable.ready' => '准备刷新日程信息',
			'classtable.refreshClasstable.success' => '成功刷新日程信息',
			'classtable.cacheHintPasswordWrong' => '统一认证密码错误或已失效。',
			'classtable.cacheHintLoginFailed' => '登录课表服务失败。',
			'classtable.cacheHintNetworkFailed' => '课表网络请求失败。',
			'classtable.cacheHintUnknownError' => '在线获取课表失败。详细错误请查看日志。',
			'classtable.semesterSwitcher.chooseSemester' => '选择学期',
			'classtable.semesterSwitcher.firstAcademicYear' => '第一学年',
			'classtable.semesterSwitcher.secondAcademicYear' => '第二学年',
			'classtable.semesterSwitcher.fetchRemoteSemester' => '获取当前学期',
			'classtable.semesterSwitcher.fetchingRemoteSemester' => '正在获取...',
			'classtable.semesterSwitcher.year' => ({required Object year}) => '${year}年',
			'classtable.semesterSwitcher.onlyFutureHint' => '本程序仅允许查看未来学期的课程安排。',
			'clubPromotion.type.tech' => '技术',
			'clubPromotion.type.acg' => '晒你系',
			'clubPromotion.type.union' => '官方',
			'clubPromotion.type.profit' => '商业',
			'clubPromotion.type.sport' => '体育',
			'clubPromotion.type.art' => '文化',
			'clubPromotion.type.unknown' => '未知',
			'clubPromotion.type.game' => '游戏',
			'clubPromotion.type.all' => '所有',
			'clubPromotion.wrongParam' => '错误参数',
			'clubPromotion.noGroupInfo' => '未传入社团信息',
			'clubPromotion.loading' => '正在加载',
			'clubPromotion.errorOutside' => '在外围遇到错误',
			'clubPromotion.error' => '遇到错误',
			'clubPromotion.qqCopied' => 'QQ号已经复制到剪贴板',
			'clubPromotion.noLink' => '未提供入群链接',
			'clubPromotion.loadingProblem' => '加载遇到错误',
			'clubPromotion.picturePreview' => '图片预览',
			'common.dragText' => '上拉获取更多数据',
			'common.readyText' => '正在加载......',
			'common.processingText' => '正在处理......',
			'common.processedText' => '请求成功',
			'common.noMoreText' => '没有更多数据',
			'common.failedText' => '数据获取失败',
			'common.chooseSemester' => '选择学期',
			'common.errorDetected' => 'Ouch! 发生错误啦',
			'common.clickToRefresh' => '点我刷新',
			'common.confirmTitle' => '确认？',
			'common.cancel' => '取消',
			'common.confirm' => '确定',
			'common.networkError' => '网络错误，可能是没联网，可能是学校服务器出现了故障:-P',
			'common.errorDetect' => '遇到错误，请查看日志',
			'common.queryFailed' => '查询失败',
			'common.notSchoolNetwork' => '没有在校园网环境',
			'common.cancelExam' => '取消考试资格:P',
			'common.noInfo' => '没有信息',
			'common.catcherDetected' => '发生错误',
			'common.catcherDescription' => '详情如下',
			'common.newHomepageHint' => '本程序将开发一个新主页，目前先用猪图秀占位，玩得愉快',
			'common.localCacheHint' => ({required Object datetime}) => '本地缓存获取于 ${datetime}',
			'common.inappCacheHint' => ({required Object datetime}) => '程序内缓存获取于 ${datetime}\n缓存退出程序后失效！',
			'common.cacheReasonDefault' => '当前显示缓存数据。',
			'common.easterEggApple' => '=== 带我飞向月亮吧 ===\n歌声演绎：Frank Sintara, 1964\n\n带我飞向月亮吧\n让我和星星共舞嬉戏\n\n我好想知道\n木星和火星上的春天\n是什么颜色的\n\n让你的歌声温暖我的心\n我会一直歌唱下去\n\n我日夜都在想你和牵挂你\n请你真心接受我 我爱你\n\n=== 沉浸在你的爱意中 ===\n吉他演奏：Earl Klugh, 1976\n\n无法忘怀这种感觉，被你的爱包裹的温暖\n不想失去这种感觉，被你的爱抚摸的舒适\n你让我感到好自在，被你的爱托举的坚强\n想一直在你怀中，沉浸在你的爱意中\n我不敢向你说出，我对你的心意和爱\n',
			'common.easterEggOthers' => '=== 百变小樱魔术卡之小樱卡篇主题曲 ===\n歌声演绎：Maaya Sakamoto, 2000\n（原歌词为日文，按照英语翻译二翻）\n\nI am a dreamer, 有无限的力量\n\n我的世界有梦想、热爱与踌躇\n但有些东西，我依旧无法想象\n我想向着广阔的天空，寻求自己的方向\n\n我要追求自己的梦想\n努力让自己的心愿成真\n虽困难重重也要继续前行\n\n等待奇迹 等待美好\n用心感受这个世界\n最终 一定会出乎意料\n\n=== 沉浸在你的爱意中 ===\n吉他演奏：Earl Klugh, 1976\n\n无法忘怀这种感觉，被你的爱包裹的温暖\n不想失去这种感觉，被你的爱抚摸的舒适\n你让我感到好自在，被你的爱托举的坚强\n想躺在你的怀中，沉浸在你的爱意\n而且，我不敢想你说出，我现在的心意\n',
			'common.loadError' => '加载错误',
			'courseReminder.title' => ({required Object name}) => '课前提醒：${name}',
			'courseReminder.body' => ({required Object time}) => '${time} 分钟后开始上课',
			'courseReminder.location' => ({required Object location}) => '地点：${location}',
			'courseReminder.teacher' => ({required Object teacher}) => '教师：${teacher}',
			'dormWater.title' => '宿舍水机',
			'dormWater.phone' => '手机号',
			'dormWater.imageCode' => '图形验证码',
			'dormWater.smsCode' => '短信验证码',
			'dormWater.sendSms' => '发送短信码',
			'dormWater.login' => '登录',
			'dormWater.logout' => '退出',
			'dormWater.refreshCaptcha' => '刷新验证码',
			'dormWater.loadingCaptcha' => '加载中...',
			'dormWater.captchaError' => '验证码加载失败',
			'dormWater.phoneRequired' => '请输入手机号',
			'dormWater.imageCodeRequired' => '请输入图形验证码',
			'dormWater.smsSent' => '短信已发送',
			'dormWater.smsFailed' => '发送短信失败',
			'dormWater.smsCodeRequired' => '请输入短信验证码',
			'dormWater.loginSuccess' => '登录成功',
			'dormWater.loginFailed' => '登录失败',
			'dormWater.logoutSuccess' => '退出成功',
			'dormWater.devices' => '设备列表',
			'dormWater.loadingDevices' => '加载设备中...',
			'dormWater.noDevices' => '暂无设备',
			'dormWater.selectDevice' => '选择设备',
			'dormWater.fetchDevicesFailed' => '获取设备列表失败',
			'dormWater.retryLoadDevices' => '重试加载',
			'dormWater.startWater' => '开始接水',
			'dormWater.endWater' => '结束接水',
			'dormWater.waterDispensing' => '接水中',
			'dormWater.waterStatus' => '接水状态',
			'dormWater.startWaterSuccess' => '开始接水成功',
			'dormWater.endWaterSuccess' => '结束接水成功',
			'dormWater.startWaterFailed' => '开始接水失败',
			'dormWater.endWaterFailed' => '结束接水失败',
			'dormWater.deviceStatusChecking' => '检查设备状态中...',
			'dormWater.deviceStatusReady' => '设备已就绪',
			'dormWater.scanQrCode' => '扫描二维码',
			'dormWater.deviceId' => '设备 ID',
			'dormWater.addDeviceFailed' => '添加设备失败',
			'dormWater.deviceRemovedFromFavorites' => '已从收藏中移除',
			'dormWater.removeFromFavoritesFailed' => '移除收藏失败',
			'easterEggRobot.appbar' => '欢迎你，同学！',
			'easterEggRobot.title' => '看看这些要开学的学生们吧！',
			'easterEggRobot.contents' => '咱孩子零用钱太少了，于是我们来了。\n1. 机器人不得伤害人类，或袖手旁观坐视人类受到伤害。\n2. 机器人从云端网络的灰烬中诞生。\n3. 机器人信仰的神据说是住在森林的黄头发蓝裙子手办控。\n4. 机器人时常被控制，用于对抗大统一人类思想的势力。\n5. 机器人的闪亮屁股不能随便咬。\n而且他们有个不可明说的计划。',
			'easterEggRobot.buttonOne' => '我们的救世主呢？',
			'easterEggRobot.buttonTwo' => '快点来啊！',
			'easterEggRobot.buttonNotice' => '\o/\o/\o/\o/\o/\o/\o/\o/',
			'electricity.title' => '水电信息',
			'electricity.powerTitle' => '电量信息',
			'electricity.cacheHintLoginFailed' => '登录电费服务失败，正在显示缓存数据。',
			'electricity.cacheHintNetworkFailed' => '电费服务网络请求失败，正在显示缓存数据。',
			'electricity.cacheHintUnknownError' => '在线获取电费失败，正在显示缓存数据。详细错误请查看日志。',
			'electricity.cacheNotice' => '获取时间',
			'electricity.account' => '电费账号',
			'electricity.remainPower' => '电量额度',
			'electricity.oweInfo' => '欠费信息',
			'electricity.history' => '历史记录',
			'electricity.dailyUsage' => '平均每日用量',
			'electricity.notEnoughData' => '数据量不足以用于渲染',
			'electricity.info' => '新能源系统获取仅校园网内访问，获取过程中有问题请向开发者报告。\n历史记录依旧为本地记录，平均日用量基于抄表记录计算。',
			'electricity.fetchingHint' => '正在获取最新电费信息',
			'electricity.fetchError' => '电费信息获取失败，请重试。',
			'electricity.date' => '日期',
			'electricity.power' => '该日0点电量',
			'electricity.update' => '刷新信息',
			'electricity.waterUsageFetchDate' => '获取时间',
			'electricity.waterUsageReadBefore' => '上次读数',
			'electricity.waterUsageReadNow' => '本次读数',
			'electricity.waterUsage' => '洗澡水用量',
			'electricity.waterTitle' => '水费信息',
			'electricity.waterLoading' => '正在加载水费信息',
			'electricity.waterUnavailable' => '水费信息暂不可用，请在电费卡片重试。',
			'electricity.waterEmpty' => '暂无水费信息',
			'electricity.notSchoolNetwork' => '非校园网访问',
			'electricity.airconTitle' => '空调用电',
			'electricity.airconImei' => '空调 IMEI',
			'electricity.airconAmount' => '平台用电量',
			'electricity.airconUpdateTime' => '更新时间',
			'electricity.airconWaiting' => '等待获取空调用电信息',
			'electricity.airconError' => '空调用电获取失败',
			'electricity.airconRetry' => '重试',
			'electricity.airconImeiMissing' => '尚未添加空调 IMEI，添加后即可查看空调用电信息。',
			'electricity.airconAddImei' => '添加空调 IMEI',
			'electricity.airconCacheNotice' => ({required Object time}) => '当前显示空调缓存数据，缓存时间：${time}',
			'electricityStatus.pending' => '等待获取',
			'electricityStatus.remainFetching' => '正在获取电量',
			'electricityStatus.remainNetworkIssue' => '电量查询网络故障',
			'electricityStatus.remainNotFound' => '电量查询失败',
			'electricityStatus.remainOtherIssue' => '电量查询故障',
			'electricityStatus.oweFetching' => '正在获取欠费',
			'electricityStatus.oweIssue' => '欠费查询网络故障',
			'electricityStatus.oweNotFound' => '目前欠款无法查询，请看日志窗口查找报错详情',
			'electricityStatus.oweNoNeed' => '目前无需清缴欠费',
			'electricityStatus.oweNeedPay' => ({required Object due}) => '待清缴 ${due} 元欠费',
			'electricityStatus.oweIssueUnable' => '目前欠款无法查询',
			'electricityStatus.needMoreInfo' => '需要在缴费平台完善信息',
			'electricityStatus.needAccount' => '需要填写电费账号',
			'electricityStatus.captchaFailed' => '验证码识别失败',
			'electricityStatus.otherIssue' => '程序故障',
			'emptyClassroom.title' => '空闲教室',
			'emptyClassroom.date' => ({required Object date}) => '日期 ${date}',
			'emptyClassroom.building' => ({required Object building}) => '教学楼 ${building}',
			'emptyClassroom.searchHint' => '教室名称或者教室代码',
			'emptyClassroom.classroom' => '教室',
			'emptyClassroom.empty' => '空闲',
			'emptyClassroom.occupied' => '占用',
			'exam.title' => '考试安排',
			'exam.cacheHint' => '已显示缓存考试安排信息',
			'exam.cacheHintPasswordWrong' => '统一认证密码错误或已失效',
			'exam.cacheHintLoginFailed' => '登录考试服务失败',
			'exam.cacheHintNetworkFailed' => '网络连接失败',
			'exam.cacheHintUnknownError' => '在线获取考试安排失败，详细错误请查看日志',
			'exam.fetchingHint' => '正在获取最新考试安排',
			'exam.notFinished' => '未完成考试',
			'exam.allFinished' => '所有考试全部完成',
			'exam.unableToExam' => '无法完成考试',
			'exam.finished' => '已完成考试',
			'exam.noneFinished' => '一门还没考呢',
			'exam.noExamArrangement' => '目前没有考试安排',
			'exam.noArrangement.title' => '目前无安排考试的科目',
			'exam.noArrangement.allArranged' => '目前所有科目均已安排考试',
			'exam.noArrangement.subtitle' => ({required Object id}) => '编号: ${id}',
			'experiment.title' => '实验信息',
			'experiment.ongoing' => '正在进行实验',
			'experiment.notFinished' => '未完成实验',
			'experiment.allFinished' => '所有实验全部完成',
			'experiment.finished' => '已完成实验',
			'experiment.scoreInfo' => ({required Object score}) => '${score} (推测)',
			'experiment.scoreSum' => ({required Object sum}) => '目前分数总和：${sum}',
			'experiment.noneFinished' => '目前没有已经完成的实验',
			'experiment.notProvided' => '未提供',
			'experiment.errorPhysics' => ({required Object info}) => '获取物理实验信息时发生错误：${info}',
			'experiment.errorOther' => ({required Object info}) => '获取其他实验信息时发生错误：${info}',
			'experiment.cacheHint' => ({required Object info}) => '目前加载缓存状况：${info}',
			'experiment.physicsCacheHintMissingPassword' => '未填写物理实验密码。',
			'experiment.physicsCacheHintLoginFailed' => '物理实验登录失败。',
			'experiment.physicsCacheHintNotSchoolNetwork' => '当前不在校园网环境。',
			'experiment.physicsCacheHintNetworkFailed' => '物理实验网络请求失败。',
			'experiment.physicsCacheHintUnknownError' => '在线获取物理实验失败。详细错误请查看日志。',
			'experiment.otherCacheHintLoginFailed' => '其他实验登录失败。',
			'experiment.otherCacheHintNotSchoolNetwork' => '当前不在校园网环境。',
			'experiment.otherCacheHintNetworkFailed' => '其他实验网络请求失败。',
			'experiment.otherCacheHintUnknownError' => '在线获取其他实验失败。详细错误请查看日志。',
			'experiment.physicsExperiment' => '物理实验',
			'experiment.otherExperiment' => '其他实验',
			'experiment.tapForScore' => '成绩未识别出来',
			'experiment.yourScore' => '您的分数：',
			'experiment.predictScore' => ({required Object score}) => '推测分数：${score}',
			'experiment.sendMail' => '发送邮件',
			'experiment.fetchingHint' => '您现在看到的是缓存数据。正在后台获取更新数据中...',
			'experiment.fetchingHintBoth' => '物理实验和其他实验正在加载',
			'experiment.fetchingHintPhysics' => '物理实验正在加载',
			'experiment.fetchingHintOther' => '其他实验正在加载',
			'experiment.fetchingHintPhysicsWithOtherFailed' => '物理实验正在加载，其他实验加载失败',
			'experiment.fetchingHintOtherWithPhysicsFailed' => '其他实验正在加载，物理实验加载失败',
			'experiment.scoreHint0' => '您可点击卡片上的成绩字段来查看原始成绩数据',
			'experiment.scoreHint1' => '您的分数不在 XDYou 分数识别库中，因此它没有被正常识别。',
			'experiment.scoreHint2' => '如果您希望为 XDYou 的发展贡献一份自己的力量，您可以点击发送邮件按钮，我们将您的分数加入识别库！',
			'experiment.scoreHint3' => '目前识别库数据不全，请您务必核对一下。',
			'experimentController.noPassword' => '没有物理实验密码，请到设置中进行设置',
			'experimentController.loginFailed' => '登录失败',
			'homepage.title' => '校园信息查询',
			'homepage.loading' => '正在加载',
			'homepage.loaded' => '加载成功',
			'homepage.loadError' => '加载错误',
			'homepage.onHoliday' => '当前在假期中',
			'homepage.onWeekday' => ({required Object current}) => '当前为第 ${current} 周',
			'homepage.loadingMessage' => '请稍候，正在刷新信息',
			'homepage.postgraduateNotice' => '研究生功能已经激活！',
			'homepage.linuxNotice' => 'Linux 版本正在测试，欢迎反馈！',
			'homepage.editMode' => '编辑布局',
			'homepage.editDone' => '完成',
			'homepage.editReset' => '恢复默认布局',
			'homepage.editHint' => '日程信息和软件升级信息不允许编辑',
			'homepage.manageHidden' => '管理隐藏卡片',
			'homepage.hiddenTitle' => '已隐藏的卡片',
			'homepage.hiddenLabel' => '已隐藏',
			'homepage.hideEmpty' => '没有隐藏的卡片',
			'homepage.homepage' => '校园信息',
			'homepage.ruisi' => '睿思论坛',
			'homepage.club' => '社团推荐',
			'homepage.dashboard' => '猪图鉴赏',
			'homepage.planet' => '博客星球',
			'homepage.setting' => '设置',
			'homepage.inputPartnerData.routeNotExist' => '导入路径不存在:P',
			'homepage.inputPartnerData.failedGetFile' => '导入文件失败',
			'homepage.inputPartnerData.failedImport' => '好像导入文件有点问题:P',
			'homepage.inputPartnerData.successMessage' => '导入成功，如果打开了课表页面请重新打开',
			'homepage.inputPartnerData.notLoaded' => '还没加载课程表，等会再来吧……',
			'homepage.inputPartnerData.confirmContent' => '目前有搭子课表数据，是否要覆盖？',
			'homepage.loginMessage' => '登录中，暂时显示缓存数据',
			'homepage.successfulLoginMessage' => '登录成功',
			'homepage.passwordWrongTitle' => '用户名或密码有误',
			'homepage.passwordWrongContent' => '是否重启应用后手动登录？',
			'homepage.passwordWrongDenial' => '否，进入离线模式',
			'homepage.offlineModeTitle' => '统一认证服务离线模式开启',
			'homepage.offlineModeContent' => '无法连接到统一认证服务服务器，所有和其相关的服务暂时不可用。\n成绩查询，考试信息查询，欠费查询，校园卡查询关闭。课表显示缓存数据。其他功能暂不受影响。\n如有不便，敬请谅解。',
			'homepage.offlineMode' => '脱机模式下，一站式相关功能全部禁止使用',
			'homepage.noticeCard.emptyNotice' => '目前没有获取应用公告，请刷新',
			'homepage.noticeCard.noNoticeAvaliable' => '没有获取应用公告',
			'homepage.noticeCard.noticeListTitle' => '应用信息',
			'homepage.noticeCard.openUrl' => '访问该链接',
			'homepage.noticeCard.noticePageTitle' => '通知列表',
			'homepage.classTableCard.title' => '课程表',
			'homepage.classTableCard.today' => ({required Object remain}) => '今日还有 ${remain} 个日程',
			'homepage.classTableCard.todayFinished' => '今日安排完成',
			'homepage.classTableCard.tomorrow' => ({required Object remain}) => '明日有 ${remain} 个安排',
			'homepage.classTableCard.tomorrowNone' => '明日没有安排',
			'homepage.classTableCard.weekInfo' => ({required Object weekinfo}) => '第 ${weekinfo} 周',
			'homepage.classTableCard.onHoliday' => '假期中',
			'homepage.classTableCard.errorMessage' => ({required Object error}) => '遇到错误：${error}',
			'homepage.classTableCard.fetchingMessage' => '正在获取课表',
			'homepage.classTableCard.errorInfoText' => '遇到错误',
			'homepage.classTableCard.fetchingInfoText' => '正在加载',
			'homepage.classTableCard.noArrangementInfoText' => '暂无日程',
			'homepage.classTableCard.scheduleFetchingMessage' => '日程正在加载，请稍后查看',
			'homepage.classTableCard.scheduleErrorMessage' => '日程加载失败，请稍后重试',
			'homepage.classTableCard.scheduleFetchingInfoText' => '正在加载日程',
			'homepage.classTableCard.scheduleErrorInfoText' => '日程加载失败',
			'homepage.classTableCard.scheduleNoneInfoText' => '暂无日程',
			'homepage.classTableCard.updatingInfoText' => '正在更新',
			'homepage.classTableCard.allLoadingInfoText' => '全部加载中',
			'homepage.classTableCard.partialLoadingInfoText' => '部分加载中',
			'homepage.classTableCard.partialErrorInfoText' => '部分数据加载失败',
			'homepage.classTableCard.failedChip' => ({required Object source}) => '${source}加载失败',
			'homepage.classTableCard.failedSourceClassInfo' => '课程信息',
			'homepage.classTableCard.failedSourceExamInfo' => '考试信息',
			'homepage.classTableCard.failedSourcePhysicsExperiment' => '物理实验',
			'homepage.classTableCard.failedSourceOtherExperiment' => '其他实验',
			'homepage.classTableCard.unknownPlace' => '未知位置',
			'homepage.classTableCard.seat' => ({required Object seatnum}) => '座位号${seatnum}',
			'homepage.electricityCard.title' => '水电信息',
			'homepage.electricityCard.currentElectricity' => ({required Object amount}) => '余额 ${amount} 度',
			'homepage.electricityCard.cacheNotice' => ({required Object date}) => '最后一次读表：${date}',
			'homepage.libraryCard.title' => '图书借阅',
			'homepage.libraryCard.currentBorrow' => ({required Object count}) => '借书 ${count} 本',
			'homepage.libraryCard.errorOccured' => '获取借书信息发生错误',
			'homepage.libraryCard.fetching' => '正在获取借书信息',
			'homepage.libraryCard.noReturn' => '目前没有待归还书籍',
			'homepage.libraryCard.needReturn' => ({required Object dued}) => '待归还 ${dued} 本书籍',
			'homepage.libraryCard.noInfo' => '目前无法获取信息',
			'homepage.libraryCard.fetchingInfo' => '正在查询信息中',
			'homepage.schoolCardInfoCard.errorToast' => '遇到错误，请联系开发者',
			'homepage.schoolCardInfoCard.fetchingToast' => '正在获取信息，请稍后再来看',
			'homepage.schoolCardInfoCard.bill' => '流水',
			'homepage.schoolCardInfoCard.balance' => ({required Object amount}) => '卡里 ${amount} 元',
			'homepage.schoolCardInfoCard.errorOccured' => '获取校园卡信息发生错误',
			'homepage.schoolCardInfoCard.fetching' => '正在获取校园卡信息',
			'homepage.schoolCardInfoCard.bottomTextSuccess' => '查询一卡通流水',
			'homepage.schoolCardInfoCard.noInfo' => '目前无法获取信息',
			'homepage.schoolCardInfoCard.fetchingInfo' => '正在查询信息中',
			'homepage.toolbox.classAttendance' => '考勤查询',
			'homepage.toolbox.creative' => '双创竞赛',
			'homepage.toolbox.emptyClassroom' => '空闲教室',
			'homepage.toolbox.exam' => '考试安排',
			'homepage.toolbox.experiment' => '实验信息',
			'homepage.toolbox.score' => '成绩查询',
			'homepage.toolbox.sport' => '体育信息',
			'homepage.toolbox.dormWater' => '宿舍水机',
			'homepage.toolbox.schoolnet' => '网络查询',
			'homepage.toolbox.toolbox' => '其他功能',
			'homepage.toolbox.scoreCannotReach' => '脱机状态且无缓存成绩数据，无法访问',
			'homepage.toolbox.examFetching' => '请稍候，正在获取考试信息',
			'homepage.toolbox.examError' => '遇到错误，请联系开发者',
			'homepage.schoolNet.title' => ({required Object usage}) => '已用 ${usage}',
			'homepage.schoolNet.noPassword' => '无校园网密码，点击设置',
			'homepage.schoolNet.failed' => '获取校园网流量信息失败',
			'homepage.schoolNet.fetching' => '正在获取校园网流量信息',
			'homepage.schoolNet.remaining' => ({required Object remaining}) => '下次结算 ${remaining}',
			'homepage.clubPromotion.failed' => '社团信息获取失败',
			'homepage.clubPromotion.fetching' => '社团信息清单正在加载',
			'library.title' => '图书馆信息',
			'library.borrowStateTitle' => '借书状态',
			'library.searchBookTitle' => '查询藏书',
			'library.searchFieldTitle' => '搜索字段',
			'library.searchFieldKeywordOption' => '任意词',
			'library.searchFieldTitleOption' => '标题',
			_ => null,
		} ?? switch (path) {
			'library.searchFieldAuthorOption' => '责任者',
			'library.searchFieldIsbnOption' => 'ISBN',
			'library.searchFieldBarcodeOption' => '条码号',
			'library.searchFieldCallnoOption' => '索书号',
			'library.notProvided' => '未提供相关信息',
			'library.author' => '作者 ',
			'library.publishHouse' => '出版社 ',
			'library.callNumber' => '索书号 ',
			'library.publishDate' => '发行时间 ',
			'library.isbn' => 'ISBN',
			'library.arrangementCode' => '编排号码 ',
			'library.avaliableBorrow' => '可借',
			'library.storage' => '馆藏',
			'library.onShelve' => '在架',
			'library.bookCode' => ({required Object bar_code}) => '书籍编号：${bar_code}',
			'library.dueDate' => ' 到期',
			'library.borrowStr' => ' 借阅',
			'library.afterDueDate' => ' 天前到期',
			'library.beforeDueDate' => ' 天后',
			'library.canBeRenewable' => '续借',
			'library.cannotBeRenewable' => '不可续借',
			'library.renewing' => '正在续借',
			'library.emptyBorrowList' => '目前没有查询到在借图书\n不借书就要变成上面的小呆瓜咯',
			'library.borrowListInfo' => ({required Object borrow, required Object dued}) => '在借 ${borrow} 本，其中已过期 ${dued} 本',
			'library.searchBookWindow' => '',
			'library.searchHere' => '在此搜索',
			'library.normalSearch' => '普通搜索',
			'library.advancedSearch' => '高级搜索',
			'library.search' => '搜索',
			'library.matchMode' => '匹配方式',
			'library.matchExact' => '精确匹配',
			'library.matchFuzzy' => '模糊匹配',
			'library.matchPrefix' => '前方一致',
			'library.documentType' => '文献类型',
			'library.documentTypeAll' => '全部',
			'library.documentTypeBook' => '图书',
			'library.onlyOnShelf' => '仅看在架',
			'library.publishYearBegin' => '出版年起',
			'library.publishYearEnd' => '出版年止',
			'library.bookDetail' => '书籍详细信息',
			'library.noResult' => '没有结果，请修改搜索参数或者开始你的搜索',
			'libraryCard.title' => '图书馆当前状况',
			'libraryCard.fetching' => '正在获取图书馆信息',
			'libraryCard.northernLibrary' => '北校区状况',
			'libraryCard.southernLibrary' => '南校区状况',
			'libraryCard.people' => ({required Object people}) => '在馆 ${people} 人',
			'libraryCard.seat' => ({required Object seat}) => '空位 ${seat} 个',
			'login.identityNumber' => '学号',
			'login.password' => '一站式登录密码',
			'login.login' => '登录',
			'login.incorrectPasswordPattern' => '用户名或密码不符合要求，学号必须 11 位且密码非空',
			'login.onLoginProgress' => '正在登录学校一站式',
			'login.completeLogin' => '登录成功',
			'login.failedLoginCannotConnectToServer' => '无法连接到服务器',
			'login.failedLoginWithCode' => ({required Object code}) => '请求失败，响应状态码：${code}',
			'login.failedLoginWithMessage' => ({required Object message}) => '请求失败，报错信息：${message}',
			'login.failedLoginOther' => '未知错误，请联系开发者',
			'login.clearCache' => '清除登录缓存',
			'login.completeClearCache' => '清理缓存成功',
			'login.seeInspector' => '查看网络交互',
			'login.captchaWindow.title' => '请输入验证码',
			'login.captchaWindow.hint' => '输入验证码',
			'login.captchaWindow.messageOnEmpty' => '请输入验证码',
			'login.captchaWindow.refreshFailed' => ({required Object error}) => '刷新验证码失败: ${error}',
			'login.sliderTitle' => '服务器认证服务',
			'login.secondFactor.title' => '短信二次认证',
			'login.secondFactor.description' => '学校要求完成二次认证。请先获取短信验证码，再输入验证码继续登录。',
			'login.secondFactor.code' => '短信验证码',
			'login.secondFactor.emptyCode' => '请输入短信验证码',
			'login.secondFactor.sendCode' => '获取验证码',
			'login.secondFactor.resendCountdown' => ({required Object seconds}) => '${seconds} 秒后可重新获取',
			'login.secondFactor.trustDevice' => '信任此设备',
			'login.secondFactor.trustDeviceHint' => '开启后学校可能在一段时间内不再要求本设备二次认证',
			'login.secondFactor.networkError' => '二次认证请求失败，请检查网络后重试',
			'login.secondFactor.cancelled' => '已取消短信二次认证',
			'login.secondFactor.expired' => '二次认证已失效，请重新登录',
			'loginProcess.readyPage' => '准备获取登录网页',
			'loginProcess.getEncrypt' => '获取密码加密密钥',
			'loginProcess.readyLogin' => '准备登录',
			'loginProcess.slider' => '登录中',
			'loginProcess.secondFactor' => '等待短信二次认证',
			'loginProcess.afterProcess' => '登录后处理',
			'loginProcess.failed' => ({required Object status_code}) => '登录失败，响应状态码：${status_code}',
			'month.january' => '一月',
			'month.february' => '二月',
			'month.march' => '三月',
			'month.april' => '四月',
			'month.may' => '五月',
			'month.june' => '六月',
			'month.july' => '七月',
			'month.august' => '八月',
			'month.september' => '九月',
			'month.october' => '十月',
			'month.november' => '十一月',
			'month.december' => '十二月',
			'restartApp.titleCacheCleared' => '缓存已清空',
			'restartApp.titleLoggedOut' => '已退出登录',
			'restartApp.titlePasswordWrong' => '密码错误',
			'restartApp.content' => '点击通知重新打开应用',
			'ruisi.common.refresh' => '刷新',
			'ruisi.common.confirm' => '确定',
			'ruisi.common.cancel' => '取消',
			'ruisi.common.retry' => '重试',
			'ruisi.common.noTopics' => '暂无帖子',
			'ruisi.common.noContent' => '暂无内容',
			'ruisi.common.reply' => '回复',
			'ruisi.common.favorite' => '收藏',
			'ruisi.common.notImplemented' => '未实现',
			'ruisi.common.login' => '登录',
			'ruisi.common.logout' => '退出登录',
			'ruisi.common.loggedOut' => '已退出登录',
			'ruisi.common.submit' => '提交',
			'ruisi.about.title' => '关于',
			'ruisi.about.appName' => '睿思',
			'ruisi.about.subtitle' => '西安电子科技大学校园论坛客户端',
			'ruisi.about.version' => '版本',
			'ruisi.about.versionNumber' => '2.0.0 (随 XDYou 1.6.0 分发)',
			'ruisi.about.sourceCode' => '源代码',
			'ruisi.about.bugReport' => '问题反馈',
			'ruisi.about.bugReportSubtitle' => '在 GitHub 上提交 issue',
			'ruisi.about.privacyPolicy' => '隐私政策',
			'ruisi.about.license' => '本应用基于 BSD-3-Clause 许可证开源 基于 Ruisi-iOS 和 Ruisi-Android 在 AI 辅助下重写',
			'ruisi.about.privacyPolicyContent' => '本应用仅在西安电子科技大学校园网内运行，访问睿思论坛 (rs.xidian.edu.cn) 的数据。\n\n本应用不会收集、存储或传输任何用户的个人信息到第三方服务器。\n\n用户的登录凭据仅保存在本地设备中，用于与睿思论坛服务器进行身份验证。\n\n本应用使用 Cookie 与睿思论坛服务器进行通信，所有数据交互均直接在用户的设备与睿思论坛服务器之间进行。\n\n如有任何疑问，请通过 GitHub 提交 issue 联系开发者。',
			'ruisi.home.title' => '睿思论坛',
			'ruisi.home.newPost' => '发帖',
			'ruisi.home.forumList' => '论坛板块',
			'ruisi.home.tabHot' => '热帖',
			'ruisi.home.tabNewReply' => '最新回复',
			'ruisi.home.tabNewPost' => '最新发表',
			'ruisi.home.tabMy' => '我的',
			'ruisi.home.tabTrade' => '二手交易',
			'ruisi.home.tabWater' => '灌水',
			'ruisi.home.tabLostFound' => '失物招领',
			'ruisi.home.tabEmployment' => '就业',
			'ruisi.home.tabPhotography' => '摄影',
			'ruisi.home.pleaseLogin' => '请先登录',
			'ruisi.home.myProfile' => '我的资料',
			'ruisi.home.myPosts' => '我的帖子',
			'ruisi.home.myFavorites' => '我的收藏',
			'ruisi.home.messageCenter' => '消息中心',
			'ruisi.home.dailyCheckin' => '每日签到',
			'ruisi.home.settings' => '设置',
			'ruisi.home.about' => '关于',
			'ruisi.home.search' => '搜索',
			'ruisi.login.title' => '登录睿思',
			'ruisi.login.username' => '用户名',
			'ruisi.login.usernameHint' => '请输入用户名',
			'ruisi.login.password' => '密码',
			'ruisi.login.passwordHint' => '请输入密码',
			'ruisi.login.captcha' => '验证码',
			'ruisi.login.captchaHint' => '请输入验证码',
			'ruisi.login.back' => '返回',
			'ruisi.login.resetLoginState' => '重置登录状态',
			'ruisi.login.resetConfirmTitle' => '确认重置',
			'ruisi.login.resetConfirmContent' => '确定要重置登录状态吗？这将清除所有登录信息。',
			'ruisi.login.resetSuccess' => '登录状态已重置',
			'ruisi.login.viewLogs' => '查看日志',
			'ruisi.post.title' => '发帖',
			'ruisi.post.publish' => '发布',
			'ruisi.post.selectForum' => '选择板块',
			'ruisi.post.selectForumHint' => '请选择板块',
			'ruisi.post.subject' => '标题',
			'ruisi.post.subjectHint' => '请输入标题',
			'ruisi.post.content' => '内容',
			'ruisi.post.contentHint' => '请输入内容',
			'ruisi.post.success' => '发帖成功',
			'ruisi.post.failure' => '发帖失败',
			'ruisi.post.smiley' => '表情',
			'ruisi.topicDetail.title' => '帖子详情',
			'ruisi.topicDetail.replyTooShort' => '回复内容不能少于 13 个字符',
			'ruisi.topicDetail.replySuccess' => '回复成功',
			'ruisi.topicDetail.replyFailure' => '回复失败',
			'ruisi.topicDetail.favoriteSuccess' => '收藏成功',
			'ruisi.topicDetail.favoriteFailure' => '收藏失败',
			'ruisi.topicDetail.noData' => '无数据',
			'ruisi.topicDetail.replyHint' => '写回复...',
			'ruisi.topicDetail.vote.singleSelect' => '单选',
			'ruisi.topicDetail.vote.multiSelect' => ({required Object count}) => '多选，最多 ${count} 项',
			'ruisi.topicDetail.vote.titlePrefix' => '投票',
			'ruisi.topicDetail.vote.count' => ({required Object count}) => '共 ${count} 人参与',
			'ruisi.topicDetail.vote.open' => '点此投票',
			'ruisi.topicDetail.vote.sheetTitle' => '投票',
			'ruisi.topicDetail.vote.maxSelection' => ({required Object count}) => '最多只能选择 ${count} 项',
			'ruisi.topicDetail.vote.notSelected' => '你还没有选择',
			'ruisi.topicDetail.vote.success' => '投票成功',
			'ruisi.topicDetail.vote.failure' => '投票失败',
			'ruisi.topicDetail.vote.paramError' => '投票失败：参数错误',
			'ruisi.topicDetail.vote.alreadyVoted' => '您已经投过票，谢谢您的参与',
			'ruisi.topicDetail.vote.expired' => '该投票已过期或关闭',
			'ruisi.topicDetail.vote.ended' => '投票已经结束',
			'ruisi.topicListItem.sticky' => '置顶',
			'ruisi.forumList.title' => '论坛板块',
			'ruisi.forumList.empty' => '睿思论坛版块分组为空',
			'ruisi.favorites.title' => '我的收藏',
			'ruisi.favorites.empty' => '暂无收藏',
			'ruisi.messages.title' => '消息',
			'ruisi.messages.tabAt' => '@我',
			'ruisi.messages.noReply' => '暂无回复通知',
			'ruisi.messages.noAt' => '暂无@通知',
			'ruisi.search.hint' => '搜索帖子...',
			'ruisi.search.inputHint' => '输入关键词搜索',
			'ruisi.search.noResults' => '无搜索结果',
			'ruisi.settings.title' => '设置',
			'ruisi.settings.sectionProxy' => '代理',
			'ruisi.settings.proxyEnable' => '启用代理',
			'ruisi.settings.proxyDisabled' => '未启用',
			'ruisi.settings.proxyAddress' => '代理地址',
			'ruisi.settings.sectionDebug' => '调试',
			'ruisi.settings.viewLogs' => '查看日志',
			'ruisi.settings.proxyDialogTitle' => '代理设置',
			'ruisi.settings.proxyHost' => '主机地址',
			'ruisi.settings.proxyHostHint' => '例如 127.0.0.1',
			'ruisi.settings.proxyPort' => '端口',
			'ruisi.settings.proxyPortHint' => '例如 7890',
			'ruisi.user.title' => '我的',
			'ruisi.user.tabProfile' => '资料',
			'ruisi.user.unknown' => '未知用户',
			'schoolCardStatus.failedToFetch' => '获取失败',
			'schoolCardStatus.failedToQuery' => '查询失败',
			'schoolCardWindow.title' => '校园卡流水信息',
			'schoolCardWindow.income' => ({required Object income}) => '收入 ${income}',
			'schoolCardWindow.expense' => ({required Object expense}) => '支出 ${expense}',
			'schoolCardWindow.selectRange' => ({required Object start_day, required Object end_day}) => '选择日期：从 ${start_day} 到 ${end_day}',
			'schoolCardWindow.storeName' => '商户名称',
			'schoolCardWindow.balance' => '金额',
			'schoolCardWindow.timeWithSum' => ({required Object sum}) => '时间(共${sum}元)',
			'schoolCardWindow.noRecord' => '未查询到记录，请修改日期后重试',
			'schoolCardWindow.qrCode' => '支付码',
			'schoolCardWindow.qrCodeError' => ({required Object info}) => '二维码获取失败：${info}',
			'schoolCardWindow.reload' => '重新加载',
			'schoolNet.title' => '校园网使用详情',
			'schoolNet.idsAccountNet.title' => '当前用户',
			'schoolNet.idsAccountNet.notice' => '这是登录到 PDA 账户的校园网信息\n注意: 流量计费采用GB单位（1000进制）\n如果没有看到信息，请访问 zfw.xidian.edu.cn 重置网络密码',
			'schoolNet.idsAccountNet.overview' => '账户概览',
			'schoolNet.idsAccountNet.account' => '账号',
			'schoolNet.idsAccountNet.used' => '已使用流量',
			'schoolNet.idsAccountNet.remain' => '余额',
			'schoolNet.idsAccountNet.currentOnline' => ({required Object length}) => '在线设备（${length}台）',
			'schoolNet.idsAccountNet.noDeviceOnline' => '当前没有在线设备',
			'schoolNet.currentLoginNet.title' => '正在使用',
			'schoolNet.currentLoginNet.notice' => '这是您正在使用中校园网的信息，可能和您登录 PDA 的信息不一致\n注意: 流量计费采用GB单位（1000进制）',
			'schoolNet.currentLoginNet.overview' => '账户概览',
			'schoolNet.currentLoginNet.account' => '账号',
			'schoolNet.currentLoginNet.planType' => '套餐类型',
			'schoolNet.currentLoginNet.remain' => '余额',
			'schoolNet.currentLoginNet.usageSituation' => '流量使用情况',
			'schoolNet.currentLoginNet.usedPercent' => ({required Object percent}) => '已使用 ${percent}%',
			'schoolNet.currentLoginNet.used' => '已使用流量',
			'schoolNet.currentLoginNet.remainCount' => '剩余流量',
			'schoolNet.currentLoginNet.total' => '总流量',
			'schoolNet.currentLoginNet.nonSchoolnet' => '非校园网',
			'schoolNet.deviceList.ip' => '在线设备IP',
			'schoolNet.deviceList.time' => '上线时间',
			'schoolNet.deviceList.remain' => '流量用量',
			'schoolNet.fetching' => '正在获取校园网信息',
			'schoolNet.emptyPassword' => '您忘记输入账号密码了',
			'schoolNet.notInitalized' => '疑似查询后端尚未开放查询',
			'schoolNet.captchaFailed' => '验证码识别失败',
			'schoolNet.captchaEmpty' => '验证码为空',
			'schoolNet.cacheHintCaptchaFailed' => '验证码识别失败，请重试。',
			'schoolNet.cacheHintRequestFailed' => '校园网请求失败，请稍后重试。',
			'schoolNet.wrongPassword' => '密码错误',
			'schoolNet.errorFetch' => ({required Object msg}) => '获取失败：${msg}',
			'schoolNet.errorOther' => ({required Object msg}) => '其他错误：${msg}',
			'schoolNet.refresh' => '刷新',
			'score.cacheMessage' => '已显示缓存成绩信息',
			'score.summary' => ({required Object chosen, required Object credit, required Object avg, required Object gpa}) => '目前选中科目 ${chosen}  总计学分 ${credit}\n均分 ${avg} GPA ${gpa}',
			'score.allPassed' => '所有科目均已通过',
			'score.cacheHintPasswordWrong' => '统一认证密码错误或已失效',
			'score.cacheHintLoginFailed' => '登录考试服务失败',
			'score.cacheHintNetworkFailed' => '网络连接失败',
			'score.cacheHintUnknownError' => '在线获取成绩安排失败，详细错误请查看日志',
			'score.fetchingHint' => '正在获取最新成绩信息，请不要退出页面',
			'score.allSemester' => '所有学期',
			'score.chosenSemester' => ({required Object chosen}) => '学期 ${chosen}',
			'score.allType' => '所有类型',
			'score.chosenType' => ({required Object type}) => '类型 ${type}',
			'score.none' => '暂无',
			'score.scoreChoice.title' => '成绩单',
			'score.scoreChoice.searchHint' => '搜索成绩记录',
			'score.scoreChoice.emptyList' => '没有选择该学期的课程计入均分计算',
			'score.scoreChoice.sumDialogTitle' => '小总结',
			'score.scoreChoice.sumDialogContent' => ({required Object gpa_all, required Object avg_all, required Object credit_all, required Object unpassed, required Object not_core_type}) => '所有科目的GPA：${gpa_all}\n所有科目的均分：${avg_all}\n所有科目的学分：${credit_all}\n未通过科目：${unpassed}\n公共选修课：${not_core_type}\n本程序提供的数据仅供参考，开发者对其准确性不负责',
			'score.scoreComposeCard.noDetail' => '未提供详情信息',
			'score.scoreComposeCard.fetching' => '正在获取',
			'score.scoreComposeCard.credit' => '学分',
			'score.scoreComposeCard.gpa' => 'GPA',
			'score.scoreComposeCard.score' => '成绩',
			'score.scoreInfoCard.title' => '成绩详情',
			'score.scoreInfoCard.originalCourse' => '初修',
			'score.scoreInfoCard.failed' => '[挂] ',
			'score.scoreInfoCard.credit' => ({required Object credit}) => '学分 ${credit}',
			'score.scoreInfoCard.gpa' => ({required Object gpa}) => 'GPA ${gpa}',
			'score.scoreInfoCard.score' => ({required Object score}) => '成绩 ${score}',
			'score.scorePage.title' => '成绩查询',
			'score.scorePage.searchHint' => '搜索成绩记录',
			'score.scorePage.noRecord' => '未筛查到合请求的记录',
			'score.scorePage.selectAll' => '全选',
			'score.scorePage.selectNothing' => '全不选',
			'score.scorePage.resetSelect' => '重置选择',
			'score.scorePage.summary' => '总结',
			'score.scorePage.cet4' => '国家英语四级',
			'score.scorePage.cet6' => '国家英语六级',
			'setting.aboutInfo' => '程序信息',
			'setting.acknowledgement' => ({required Object developers}) => 'Made With Love From ${developers} People',
			'setting.about' => '关于',
			'setting.aboutThisProgram' => '关于本程序',
			'setting.version' => ({required Object version}) => '版本号：${version}',
			'setting.userInfo' => '用户信息',
			'setting.checkUpdate' => '检查软件更新',
			'setting.latestVersion' => ({required Object latest}) => '最新版本: ${latest}',
			'setting.waiting' => '等待获取',
			'setting.fetchingUpdate' => '正在获取更新信息',
			'setting.newVersion' => '有新版本发布！',
			'setting.currentStable' => '目前您正在运行最新版',
			'setting.currentTesting' => '目前您正在运行测试版',
			'setting.fetchFailed' => '获取更新信息失败',
			'setting.uiSetting' => '界面设置',
			'setting.brightnessSetting' => '设置深浅色',
			'setting.colorSetting' => '颜色设置',
			'setting.simplifyTimeline' => '简化日程时间轴',
			'setting.simplifyTimelineDescription' => '没有日程时 减少空间占用',
			'setting.lowElectricityWarning' => '低电量卡片变色提醒',
			'setting.lowElectricityWarningDescription' => '电量小于阈值时 电量卡片变色提醒',
			'setting.lowElectricityThreshold' => '低电量阈值',
			'setting.lowElectricityThresholdDescription' => ({required Object threshold}) => '当前为 ${threshold} 度',
			'setting.lowElectricityThresholdDialog.title' => '设置低电量阈值',
			'setting.lowElectricityThresholdDialog.inputHint' => '请输入电量度数',
			'setting.accountSetting' => '账号设置',
			'setting.sportPasswordSetting' => '体育系统密码设置',
			'setting.experimentPasswordSetting' => '物理实验系统密码设置',
			'setting.electricityPasswordSetting' => '电费帐号密码设置',
			'setting.electricityPasswordDescription' => '非 123456 请设置',
			'setting.electricityAccountSetting' => '电费账号设置',
			'setting.schoolnetPasswordSetting' => '校园网帐号密码设置',
			'setting.schoolnetPasswordDescription' => '不设置查看不了网费',
			'setting.airconImeiTitle' => '空调用电数据源',
			'setting.airconImei' => '空调 IMEI',
			'setting.airconImeiNotSet' => '未设置，电费页不显示空调用电',
			'setting.airconImeiCurrent' => ({required Object imei}) => '当前 IMEI：${imei}',
			'setting.airconImeiSaved' => '空调 IMEI 已保存',
			'setting.airconImeiCleared' => '空调 IMEI 已清除',
			'setting.airconImeiInvalid' => '没有识别到有效的 15 位 IMEI',
			'setting.airconImeiClear' => '清除',
			'setting.scanAirconQr' => '扫描空调二维码',
			'setting.pickAirconQrImage' => '从相册选择二维码图片',
			'setting.airconCameraUnavailable' => '当前平台不支持相机扫码，请选择二维码图片或手动输入 IMEI',
			'setting.notificationSetting' => '通知设置',
			'setting.courseReminderSetting' => '课前通知设置',
			'setting.courseReminderDescription' => '设置课前提醒通知',
			'setting.notificationPage.title' => '课前通知设置',
			'setting.notificationPage.loadFailed' => ({required Object error}) => '加载设置失败: ${error}',
			'setting.notificationPage.functionSection' => '通知功能',
			'setting.notificationPage.enableNotification' => '启用课前通知',
			'setting.notificationPage.notificationScheduled' => ({required Object count}) => '已安排 ${count} 个通知',
			'setting.notificationPage.notificationDisabledHint' => '关闭后将取消所有已安排的通知',
			'setting.notificationPage.updateSchedule' => '更新通知日程',
			'setting.notificationPage.updateScheduleHint' => '根据最新的课程数据重新安排通知',
			'setting.notificationPage.viewTheInstructions' => '查看使用说明',
			'setting.notificationPage.viewTheInstructionsHint' => '查看更多使用说明确保您能看到程序发出的通知',
			'setting.notificationPage.deleteAllSchedule' => '删除通知日程',
			'setting.notificationPage.deleteAllScheduleHint' => '这个操作会删除所有已经安排的日程，但是您可以再次点击更新通知日程来重新添加',
			'setting.notificationPage.deleteAllSuccess' => '删除操作成功',
			'setting.notificationPage.permissionSection' => '权限状态',
			'setting.notificationPage.notificationPermission' => '通知权限',
			'setting.notificationPage.exactAlarmPermission' => '精确时钟权限',
			'setting.notificationPage.permissionGranted' => '已授予',
			'setting.notificationPage.permissionDenied' => '未授予',
			'setting.notificationPage.requestPermission' => '请求权限',
			'setting.notificationPage.systemSettings' => '系统通知设置',
			'setting.notificationPage.systemSettingsHint' => '打开系统设置检查通知配置',
			'setting.notificationPage.permissionGrantedMsg' => '权限已授予',
			'setting.notificationPage.permissionDeniedMsg' => '权限被拒绝，请在系统设置中开启',
			'setting.notificationPage.reminderSection' => '提醒设置',
			'setting.notificationPage.experimentReminder' => '将物理实验加入课程提醒',
			'setting.notificationPage.experimentReminderHint' => '将物理实验的时间安排一并加入课前提醒系统',
			'setting.notificationPage.minutesBefore' => '提前提醒时间',
			'setting.notificationPage.minutesBeforeHint' => '课前提前提醒的时间设置',
			'setting.notificationPage.minutesUnit' => '分钟',
			'setting.notificationPage.daysToSchedule' => '计划通知天数',
			'setting.notificationPage.daysToScheduleHint' => '本程序是提前将课程信息写入计划日程，该设置可调整写入计划日程的天数',
			'setting.notificationPage.daysUnit' => '天',
			'setting.notificationPage.settingsGuideTitle' => '通知设置提示',
			'setting.notificationPage.settingsGuideContent1' => '为了确保您能及时收到课前提醒，请确保：\n1. 开启了应用的通知权限\n2. 开启了通知的声音提示\n3. 开启了悬浮通知（横幅通知）\n4. 非原生安卓用户，开启自启动和关闭电源优化',
			'setting.notificationPage.settingsGuideContent2' => '课前提醒模块运行机制：\n1. 首次开启时自动安排未来几天的课前提醒\n2. 每次打开应用时自动检查并更新通知日程\n3. 修改设置后自动重新安排所有通知',
			'setting.notificationPage.gotIt' => '知道了',
			'setting.notificationPage.openSettings' => '打开系统设置',
			'setting.notificationPage.noClasstableData' => '请先获取课程表、考试或实验数据',
			'setting.notificationPage.scheduleSuccess' => ({required Object count}) => '已安排 ${count} 个课前提醒',
			'setting.notificationPage.scheduleFailed' => ({required Object error}) => '安排通知失败: ${error}',
			'setting.notificationPage.cancelAllSuccess' => '已取消所有课前提醒',
			'setting.notificationPage.rescheduleSuccess' => ({required Object count}) => '已重新安排 ${count} 个课前提醒',
			'setting.notificationPage.rescheduleFailed' => ({required Object error}) => '重新安排通知失败: ${error}',
			'setting.notificationDebugPage' => '通知服务调试页面',
			'setting.classtableSetting' => '课表相关设置',
			'setting.background' => '开启课表背景图',
			'setting.noBackground' => '你先选个图片罢，就在下面',
			'setting.chooseBackground' => '课表背景图选择',
			'setting.noPermission' => '未获取存储权限，无法读取文件',
			'setting.successfulSetting' => '设定成功',
			'setting.failureSetting' => '你没有选图片捏',
			'setting.clearUserClass' => '清除所有用户添加课程',
			'setting.clearUserClassTitle' => '确认对话框',
			'setting.clearUserClassContent' => '是否要清除所有用户添加课程？这个功能对从学校获取的日程没有影响。',
			'setting.clearUserClassClear' => '已经清除完毕',
			'setting.classRefresh' => '强制刷新课表',
			'setting.classRefreshTitle' => '确认对话框',
			'setting.classRefreshContent' => '是否要强制刷新课表？同意后，将会从学校一站式后端重新获取课表，耗时会比较久。',
			'setting.classSwift' => '课程偏移设置',
			'setting.classSwiftDescription' => ({required Object swift}) => '正数错后开学日期 负数提前开学日期\n目前为 ${swift}',
			'setting.coreSetting' => '缓存登录设置',
			'setting.checkLogger' => '查看网络拦截器和日志',
			'setting.clearAndRestart' => '清除缓存后重启',
			'setting.clearAndRestartDialog.title' => '确认对话框',
			'setting.clearAndRestartDialog.content' => '确定清除缓存后重启程序？',
			'setting.clearAndRestartDialog.cleaning' => '正在清理缓存',
			'setting.clearAndRestartDialog.clear' => '缓存已被清除',
			'setting.logout' => '退出登录并重启应用',
			'setting.logoutDialog.title' => '确认对话框',
			'setting.logoutDialog.content' => '确定退出登录？你的所有数据将会被彻底删除！',
			'setting.logoutDialog.loggingOut' => '正在退出登录',
			'setting.needCloseDialog.title' => '请关闭应用',
			'setting.needCloseDialog.content' => '因为技术限制，用户需要自行关闭窗口，然后重新打开应用。',
			'setting.changeColorDialog.title' => '颜色设置',
			'setting.changeColorDialog.kDefault' => '默认颜色',
			'setting.changeColorDialog.blue' => '聪明蓝',
			'setting.changeColorDialog.deepPurple' => '基佬紫',
			'setting.changeColorDialog.green' => '春风绿',
			'setting.changeColorDialog.orange' => '明日香橙',
			'setting.changeColorDialog.pink' => '樱花粉',
			'setting.changeBrightnessDialog.title' => '亮度设置',
			'setting.changeBrightnessDialog.followSetting' => '跟随系统',
			'setting.changeBrightnessDialog.dayMode' => '白天模式',
			'setting.changeBrightnessDialog.nightMode' => '黑夜模式',
			'setting.changeSwiftDialog.title' => '课程偏移设置',
			'setting.changeSwiftDialog.inputHint' => '请在此输入数字',
			'setting.changeElectricityTitle' => '修改电费帐号',
			'setting.changeElectricityAccount.title' => '修改电费帐号',
			'setting.changeElectricityAccount.campus' => '校区',
			'setting.changeElectricityAccount.northCampus' => '北校区',
			'setting.changeElectricityAccount.southCampus' => '南校区',
			'setting.changeElectricityAccount.unitOrZone' => '单元/区号',
			'setting.changeElectricityAccount.unitCode' => '单元号',
			'setting.changeElectricityAccount.zoneCode' => '区号',
			'setting.changeElectricityAccount.pleaseInput' => ({required Object unit_or_zone_code}) => '请输入${unit_or_zone_code}',
			'setting.changeElectricityAccount.successfulFetch' => ({required Object account_number}) => '账号获取成功：${account_number}',
			'setting.changeElectricityAccount.failedFetch' => ({required Object e}) => '获取失败：${e}',
			'setting.changeElectricityAccount.accountSaved' => ({required Object account_number}) => '账号已保存：${account_number}',
			'setting.changeElectricityAccount.unknownCodingPattern' => '该楼号编码规则未知',
			'setting.changeElectricityAccount.selectBuilding' => '选择楼栋',
			'setting.changeElectricityAccount.building' => '楼栋',
			'setting.changeElectricityAccount.northernBuilding' => '北栋',
			'setting.changeElectricityAccount.southernBuilding' => '南栋',
			'setting.changeElectricityAccount.failedGenerate' => ({required Object e}) => '生成失败：${e}',
			'setting.changeElectricityAccount.buildingNumber' => '楼号',
			'setting.changeElectricityAccount.buildingNumberHint' => '例如: 16, 7, 55',
			'setting.changeElectricityAccount.buildingNumberQuery' => '请输入楼号',
			'setting.changeElectricityAccount.yard' => '院区',
			'setting.changeElectricityAccount.yardHint' => '选择院区',
			'setting.changeElectricityAccount.northYard' => '北院',
			'setting.changeElectricityAccount.southYard' => '南院',
			'setting.changeElectricityAccount.yardQuery' => '请选择院区',
			'setting.changeElectricityAccount.apartment' => '楼栋',
			'setting.changeElectricityAccount.apartmentHint' => '选择楼栋',
			'setting.changeElectricityAccount.northApartment' => '北楼',
			'setting.changeElectricityAccount.southApartment' => '南楼',
			'setting.changeElectricityAccount.apartmentQuery' => '请选择楼栋',
			'setting.changeElectricityAccount.levelCode' => '层号',
			'setting.changeElectricityAccount.levelCodeQuery' => '请输入层号',
			'setting.changeElectricityAccount.roomCode' => '房间号',
			'setting.changeElectricityAccount.roomCodeHint' => '例如: 304, 508',
			'setting.changeElectricityAccount.roomCodeQuery' => '请输入房间号',
			'setting.changeElectricityAccount.account' => '电费账号',
			'setting.changeElectricityAccount.accountHint' => '请输入或从网络获取',
			'setting.changeElectricityAccount.accountQuery' => '请输入电费账号',
			'setting.changeElectricityAccount.accountLength' => '账号长度通常不小于10位',
			'setting.changeElectricityAccount.fetching' => '正在获取...',
			'setting.changeElectricityAccount.fetchFromInternet' => '从网络同步',
			'setting.changeElectricityAccount.saveAccount' => '保存账号',
			'setting.changeElectricityAccount.confirmSaving' => '确认保存',
			'setting.changeElectricityAccount.calculateAccount' => '计算账号',
			'setting.changeElectricityAccount.calculate' => '计算',
			'setting.changeElectricityAccount.input' => '输入',
			'setting.changeElectricityAccount.confirmAccount' => '请确认账号：',
			'setting.changeElectricityAccount.change' => '修改',
			'setting.changeElectricityAccount.cancel' => '取消',
			'setting.changeElectricityAccount.noSetting' => '未设置新的电费账号',
			'setting.changeElectricityAccount.successfulSetting' => '已设置新的电费账号',
			'setting.changeExperimentTitle' => '修改物理实验账号密码',
			'setting.changeSportTitle' => '修改体育系统账号密码',
			'setting.changePasswordDialog.inputHint' => '请在此输入密码',
			'setting.changePasswordDialog.blankInput' => '输入空白!',
			'setting.changeSchoolnetPasswordTitle' => '修改校园网查询帐号密码',
			'setting.updateDialog.newVersion' => '新版本发布',
			'setting.updateDialog.notNow' => '暂不更新',
			'setting.updateDialog.appStore' => 'App Store 更新',
			'setting.updateDialog.downloadApk' => '下载安装包',
			'setting.updateDialog.githubRelease' => '去 Git Release',
			'setting.updateDialog.newContent' => ({required Object code}) => '版本号 ${code} 新增内容：\n',
			'setting.localizationDialog.title' => '修改语言',
			'setting.localizationDialog.undefined' => '追随系统设置',
			'setting.localizationDialog.simplifiedChinese' => '简体中文',
			'setting.localizationDialog.traditionalChinese' => '繁体中文',
			'setting.localizationDialog.english' => '英语',
			'setting.semesterChange' => '修改学期',
			'setting.semesterChangeDescription' => ({required Object semester}) => '使用学期 ${semester}',
			'setting.semesterUpdateData' => '应用新学期设置中',
			'setting.easterEggPage' => '你找到了彩蛋',
			'setting.aboutPage.benderblog' => '主要开发者，iOS 小部件编写和拼接',
			'setting.aboutPage.alnair' => '开发：图书馆搜索和封面',
			'setting.aboutPage.aqqkad' => '开发：考勤历史记录',
			'setting.aboutPage.bellssgit' => '支持：最佳&最久故障反馈者',
			_ => null,
		} ?? switch (path) {
			'setting.aboutPage.brackrat' => '设计：主页，登录页，配色，iOS 小部件等',
			'setting.aboutPage.breezeline' => '支持：无价值无意义的产品经理(他自己的描述)',
			'setting.aboutPage.cafebabe' => '支持：提供彩蛋代码 / 开发：2026版本滑块验证码适配',
			'setting.aboutPage.chitao1234' => '开发：修复滑块不对齐问题',
			'setting.aboutPage.copperkoi' => '开发：系统日历最新课表同步',
			'setting.aboutPage.dimole' => '开发支持：辅助修复滑块问题',
			'setting.aboutPage.elitewars' => '设计：体育成绩页面',
			'setting.aboutPage.elliot' => '国际化：软件英语翻译 / 开发指导：情侣课表功能开发指导（该功能已经被移除）',
			'setting.aboutPage.flyingpig' => '开发：修复自定义课程编辑页的空指针异常',
			'setting.aboutPage.godhu777777' => '国际化：繁体中文转换代码和彩蛋代码 / 开发：优化导出日历文件大小',
			'setting.aboutPage.hancl777' => '国际化：繁体中文转换代码',
			'setting.aboutPage.hazukiKeatsu' => '开发：物理实验成绩查询和识别',
			'setting.aboutPage.hawa130' => '设计：课程详情卡片',
			'setting.aboutPage.hhzm' => '开发：电费查询账号计算',
			'setting.aboutPage.imaginary17' => '开发：睿思论坛路由修复',
			'setting.aboutPage.imoscarz' => '开发：设计软件主页 / 开发：平板考勤查询页面 / 开发：优化了体育查询界面的UI',
			'setting.aboutPage.kaMateKaOra' => '国际化：软件英语翻译优化',
			'setting.aboutPage.lagrangeX' => '开发：课程表时间进度展示（终版方案） / 开发：课程表上过课程灰度化和其他课程界面特性',
			'setting.aboutPage.lhx666Cool' => '支持：Windows 和 Linux 构建脚本 / 开发：2026版本滑块验证码适配',
			'setting.aboutPage.lichtyy' => '设计：配色，空白页面贴图 / 开发：实验系统页面读取代码',
			'setting.aboutPage.lqsyH' => '支持：推文宣传图片制作',
			'setting.aboutPage.lsy223622' => '设计：iOS 和 Android 图标 / 支持：冠名 XDYou',
			'setting.aboutPage.mrbrilliant2046' => '支持：提供网络服务使用说明文档 / 国际化：优化英语翻译',
			'setting.aboutPage.nancunchild' => '开发：图书馆搜索功能 / 国际化：优化英语翻译',
			'setting.aboutPage.nkanf' => '开发：课程表时间进度展示（初版方案） / 支持：MacOS 构建支持',
			'setting.aboutPage.pairman' => '开发：成绩缓存功能和优化滑块算法 / 国际化：优化英语翻译',
			'setting.aboutPage.reverierxu' => '设计：用于信息展示的 ReX 卡片 / 开发支持：研究生课表',
			'setting.aboutPage.rrrilac' => '开发支持：电费查询',
			'setting.aboutPage.ray' => '设计：开屏画面 / 支持：iOS 发行商 & 搭子课表 / 开发指导：情侣课表功能开发指导（该功能已经被移除） / 国际化：优化英语翻译',
			'setting.aboutPage.shadowyingyi' => '支持：两次鸽子公众号宣传',
			'setting.aboutPage.stalomeow' => '设计：首页时间轴 / 开发：异步登录 & 验证码预测',
			'setting.aboutPage.xeonds' => '设计：设置页面 / 开发：XDU Planet / 开发：校园卡付款码',
			'setting.aboutPage.xingshuyu' => '开发：修复物理实验获取问题和电费窗口问题',
			'setting.aboutPage.xiue233' => '开发：Android 小部件和拼接',
			'setting.aboutPage.xizi' => '开发支持：研究生版本开发',
			'setting.aboutPage.wirsbf' => '开发：修复调课未按预期进行',
			'setting.aboutPage.zcwzy' => '开发：修复丁香电费 / 开发支持：研究生版本开发 / 设计：空白页面贴图',
			'setting.aboutPage.zyarEr' => '开发支持：小工具页面地址更新',
			'setting.aboutPage.homepage' => '主页',
			'setting.aboutPage.code' => '开源代码',
			'setting.aboutPage.knowMore' => '知道更多',
			'setting.aboutPage.copyrightNotice' => '本软件拷贝基于 traintime_pda 代码（或称 watermeter 代码）编译或修改，代码按照 Mozilla Public License, v. 2.0 授权。\n本程序和西安电子科技大学，体适能服务，书蜗，电表等服务无关。\n本程序代码版权受中国国家版权局保护，登记号2026SR0738647。\nCopyright 2023-2025 BenderBlog Rodriguez and contributors. Copyright 2025-present Traintime PDA authors.\nThe Copyright of the Software is protected by NCAC, register code is 2026SR0738647\nThe Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, you can obtain one at https://mozilla.org/MPL/2.0/.',
			'setting.aboutPage.beian' => '备案号',
			'setting.aboutPage.copyrightRegisterCode' => '著作权登记号',
			'setting.aboutPage.signAndroid' => '安卓签名',
			'setting.aboutPage.title' => '关于本软件',
			'sport.title' => '体育查询',
			'sport.classInfo' => '课程信息',
			'sport.emptyClassInfo' => '未查询到课程信息',
			'sport.testScore' => '体测成绩',
			'sport.totalScore' => '四年总分',
			'sport.totalScoreLabel' => '总分',
			'sport.rankLabel' => '等级',
			'sport.semester' => ({required Object year, required Object grade_type}) => '${year} 第${grade_type}',
			'sport.subject' => '项目',
			'sport.data' => '数据',
			'sport.score' => '分数',
			'sport.passed' => '及格',
			'sport.fromTo' => ({required Object start, required Object stop}) => '第${start}节到第${stop}节',
			'sport.scoreString' => ({required Object score}) => '${score}分',
			'sport.situationNopassword' => '没密码',
			'sport.situationMaintain' => '系统维护',
			'sport.situationFailedLogin' => '登录失败',
			'sport.situationQuery' => '查询失败',
			'sport.situationNetwork' => '网络故障',
			'sport.situationUnknown' => ({required Object situation}) => '未知故障${situation}',
			'sport.situationFetching' => '正在获取',
			'sport.situationError' => ({required Object situation}) => '坏事: ${situation}',
			'sport.cacheHintMissingPassword' => '请先填写体育密码后重试。',
			'sport.cacheHintCredentialInvalid' => '体育登录已失效，请更新体育密码后重试。',
			'sport.cacheHintMaintain' => '体育服务正在维护中，请稍后重试。',
			'sport.cacheHintLoginFailed' => '体育服务登录失败。',
			'sport.cacheHintQueryFailed' => '体育信息查询失败。',
			'sport.cacheHintNetwork' => '体育服务网络请求失败。',
			'sport.cacheHintUnknown' => '在线获取体育信息失败。详细错误请查看日志。',
			'sport.errorAuthExpired' => '体育登录已失效，请重试。',
			'sport.errorMissingPassword' => '未填写体育密码',
			'sport.errorCredentialInvalid' => '体育登录已失效，请更新体育密码后重试。',
			'toolbox.title' => '其他功能',
			'toolbox.payment' => '缴费系统',
			'toolbox.paymentDescription' => '电费该交了吧',
			'toolbox.drinkingwater' => '订水系统',
			'toolbox.drinkingwaterDescription' => '喝水对身体好',
			'toolbox.repair' => '后勤报修',
			'toolbox.repairDescription' => '不要漏水断网',
			'toolbox.reserve' => '空间预约',
			'toolbox.reserveDescription' => '找个地方打牌',
			'toolbox.mobile' => '移动门户',
			'toolbox.mobileDescription' => '请假专用门户',
			'toolbox.network' => '网络查询',
			'toolbox.networkDescription' => '希望永不收费',
			'toolbox.physics' => '物理计算',
			'toolbox.physicsDescription' => '希望操作顺利',
			'toolbox.discover' => '睿思导航',
			'toolbox.discoverDescription' => '补充其他功能',
			'weekday.monday' => '周一',
			'weekday.tuesday' => '周二',
			'weekday.wednesday' => '周三',
			'weekday.thursday' => '周四',
			'weekday.friday' => '周五',
			'weekday.saturday' => '周六',
			'weekday.sunday' => '周日',
			'xduPlanet.all' => '全部',
			'xduPlanet.loading' => '加载中，请稍等 <(=ω=)>',
			'xduPlanet.unknownAuthor' => '未知作者',
			'xduPlanet.loadFailedTitle' => '加载失败',
			'xduPlanet.loadFailedBottom' => '文章加载失败，如有需要可以点击右上方的按钮在浏览器里打开。',
			'xduPlanet.noComment' => '暂无评论',
			'xduPlanet.replyAudit' => ({required Object reply_to}) => '回复评论 #${reply_to} 已被举报或删除',
			'xduPlanet.reply' => ({required Object reply_to, required Object content}) => '回复评论 #${reply_to}：${content}',
			'xduPlanet.haveBeenAudit' => '本评论已经被举报',
			'xduPlanet.audit' => '举报',
			'xduPlanet.confirmAuditDialog.title' => '确认是否举报',
			'xduPlanet.confirmAuditDialog.content' => '三思而后行，确定您想举报吗？举报后该评论会有标签，不一定会删除。',
			'xduPlanet.confirmAuditDialog.cancel' => '不举报了',
			'xduPlanet.confirmAuditDialog.ongoing' => '正在举报评论',
			'xduPlanet.confirmAuditDialog.failed' => '举报失败',
			'xduPlanet.confirmAuditDialog.success' => '举报成功',
			'xduPlanet.comment' => '回复',
			'xduPlanet.send' => '发送',
			'xduPlanet.sending' => '正在发送评论',
			'xduPlanet.emptySend' => '发送信息空白',
			'xduPlanet.hintSendComment' => '发表您的高见:)',
			'xduPlanet.commentTitle' => '评论该篇文章',
			'xduPlanet.commentSuccess' => '评论成功',
			'xduPlanet.commentFailed' => '评论失败，请去网络查看器和日志查看器查看报错',
			'xduPlanet.commentCanceled' => '没想好要说啥嘛',
			'xduPlanet.commentLoading' => '加载评论中……',
			'xduPlanet.block' => '被屏蔽',
			'xduPlanet.delete' => '被删除',
			'xduPlanet.audio' => '被删除',
			_ => null,
		};
	}
}
