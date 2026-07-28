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
class TranslationsZhTw with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsZhTw({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.zhTw,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <zh-TW>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsZhTw _root = this; // ignore: unused_field

	@override 
	TranslationsZhTw $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsZhTw(meta: meta ?? this.$meta);

	// Translations
	@override late final Translations$classAttendance$zh_TW classAttendance = Translations$classAttendance$zh_TW.internal(_root);
	@override late final Translations$classtable$zh_TW classtable = Translations$classtable$zh_TW.internal(_root);
	@override late final Translations$clubPromotion$zh_TW clubPromotion = Translations$clubPromotion$zh_TW.internal(_root);
	@override late final Translations$common$zh_TW common = Translations$common$zh_TW.internal(_root);
	@override late final Translations$courseReminder$zh_TW courseReminder = Translations$courseReminder$zh_TW.internal(_root);
	@override late final Translations$dormWater$zh_TW dormWater = Translations$dormWater$zh_TW.internal(_root);
	@override late final Translations$easterEggRobot$zh_TW easterEggRobot = Translations$easterEggRobot$zh_TW.internal(_root);
	@override late final Translations$electricity$zh_TW electricity = Translations$electricity$zh_TW.internal(_root);
	@override late final Translations$electricityStatus$zh_TW electricityStatus = Translations$electricityStatus$zh_TW.internal(_root);
	@override late final Translations$emptyClassroom$zh_TW emptyClassroom = Translations$emptyClassroom$zh_TW.internal(_root);
	@override late final Translations$exam$zh_TW exam = Translations$exam$zh_TW.internal(_root);
	@override late final Translations$experiment$zh_TW experiment = Translations$experiment$zh_TW.internal(_root);
	@override late final Translations$experimentController$zh_TW experimentController = Translations$experimentController$zh_TW.internal(_root);
	@override late final Translations$homepage$zh_TW homepage = Translations$homepage$zh_TW.internal(_root);
	@override late final Translations$library$zh_TW library = Translations$library$zh_TW.internal(_root);
	@override late final Translations$libraryCard$zh_TW libraryCard = Translations$libraryCard$zh_TW.internal(_root);
	@override late final Translations$login$zh_TW login = Translations$login$zh_TW.internal(_root);
	@override late final Translations$loginProcess$zh_TW loginProcess = Translations$loginProcess$zh_TW.internal(_root);
	@override late final Translations$month$zh_TW month = Translations$month$zh_TW.internal(_root);
	@override late final Translations$restartApp$zh_TW restartApp = Translations$restartApp$zh_TW.internal(_root);
	@override late final Translations$ruisi$zh_TW ruisi = Translations$ruisi$zh_TW.internal(_root);
	@override late final Translations$schoolCardStatus$zh_TW schoolCardStatus = Translations$schoolCardStatus$zh_TW.internal(_root);
	@override late final Translations$schoolCardWindow$zh_TW schoolCardWindow = Translations$schoolCardWindow$zh_TW.internal(_root);
	@override late final Translations$schoolNet$zh_TW schoolNet = Translations$schoolNet$zh_TW.internal(_root);
	@override late final Translations$score$zh_TW score = Translations$score$zh_TW.internal(_root);
	@override late final Translations$setting$zh_TW setting = Translations$setting$zh_TW.internal(_root);
	@override late final Translations$sport$zh_TW sport = Translations$sport$zh_TW.internal(_root);
	@override late final Translations$toolbox$zh_TW toolbox = Translations$toolbox$zh_TW.internal(_root);
	@override late final Translations$weekday$zh_TW weekday = Translations$weekday$zh_TW.internal(_root);
	@override late final Translations$xduPlanet$zh_TW xduPlanet = Translations$xduPlanet$zh_TW.internal(_root);
}

// Path: classAttendance
class Translations$classAttendance$zh_TW implements Translations$classAttendance$zh_CN {
	Translations$classAttendance$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '考勤查詢';
	@override String detailTitle({required Object course_name}) => '簽到信息 - ${course_name}';
	@override String get noData => '沒有找到課程數據';
	@override String get noAttendanceRecord => '沒有簽到記錄';
	@override String get longLoad => '考勤數據的加載時間約半分鐘，請耐心等待';
	@override late final Translations$classAttendance$courseState$zh_TW courseState = Translations$classAttendance$courseState$zh_TW.internal(_root);
	@override late final Translations$classAttendance$table$zh_TW table = Translations$classAttendance$table$zh_TW.internal(_root);
	@override late final Translations$classAttendance$card$zh_TW card = Translations$classAttendance$card$zh_TW.internal(_root);
	@override late final Translations$classAttendance$detailCard$zh_TW detailCard = Translations$classAttendance$detailCard$zh_TW.internal(_root);
	@override late final Translations$classAttendance$signType$zh_TW signType = Translations$classAttendance$signType$zh_TW.internal(_root);
	@override late final Translations$classAttendance$signStatus$zh_TW signStatus = Translations$classAttendance$signStatus$zh_TW.internal(_root);
}

// Path: classtable
class Translations$classtable$zh_TW implements Translations$classtable$zh_CN {
	Translations$classtable$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override late final Translations$classtable$partnerClasstable$zh_TW partnerClasstable = Translations$classtable$partnerClasstable$zh_TW.internal(_root);
	@override String get pageTitle => '我的日程表';
	@override String partnerPageTitle({required Object partner_name}) => '${partner_name}的日程表';
	@override late final Translations$classtable$popupMenu$zh_TW popupMenu = Translations$classtable$popupMenu$zh_TW.internal(_root);
	@override late final Translations$classtable$visualSettings$zh_TW visualSettings = Translations$classtable$visualSettings$zh_TW.internal(_root);
	@override late final Translations$classtable$statusSource$zh_TW statusSource = Translations$classtable$statusSource$zh_TW.internal(_root);
	@override String get errorDialogTitle => '錯誤信息概覽';
	@override late final Translations$classtable$statusBanner$zh_TW statusBanner = Translations$classtable$statusBanner$zh_TW.internal(_root);
	@override late final Translations$classtable$emptyState$zh_TW emptyState = Translations$classtable$emptyState$zh_TW.internal(_root);
	@override late final Translations$classtable$emptyAction$zh_TW emptyAction = Translations$classtable$emptyAction$zh_TW.internal(_root);
	@override late final Translations$classtable$classChangePage$zh_TW classChangePage = Translations$classtable$classChangePage$zh_TW.internal(_root);
	@override late final Translations$classtable$notArrangedPage$zh_TW notArrangedPage = Translations$classtable$notArrangedPage$zh_TW.internal(_root);
	@override String emptyClassMessage({required Object semester_code}) => '${semester_code} 學期沒有課程';
	@override String emptyClassWithExam({required Object semester_code}) => '${semester_code} 學期沒有課程但是有考試安排！\n請回到主頁後下滑點擊”考試安排“按鈕進入考試安排頁面';
	@override String weekTitle({required Object week}) => '第${week}周';
	@override String get noonBreak => '午休';
	@override String get supperBreak => '晚休';
	@override String month({required Object month}) => '${month}\n月';
	@override String get noClass => '本週暫無安排，請不要在床上過於慵懶';
	@override late final Translations$classtable$classCard$zh_TW classCard = Translations$classtable$classCard$zh_TW.internal(_root);
	@override late final Translations$classtable$classAdd$zh_TW classAdd = Translations$classtable$classAdd$zh_TW.internal(_root);
	@override late final Translations$classtable$courseDetailCard$zh_TW courseDetailCard = Translations$classtable$courseDetailCard$zh_TW.internal(_root);
	@override late final Translations$classtable$outputToSystem$zh_TW outputToSystem = Translations$classtable$outputToSystem$zh_TW.internal(_root);
	@override late final Translations$classtable$refreshClasstable$zh_TW refreshClasstable = Translations$classtable$refreshClasstable$zh_TW.internal(_root);
	@override String get cacheHintPasswordWrong => '統一認證密碼錯誤或已失效。';
	@override String get cacheHintLoginFailed => '登錄課表服務失敗。';
	@override String get cacheHintNetworkFailed => '課表網絡請求失敗。';
	@override String get cacheHintUnknownError => '在線獲取課表失敗。詳細錯誤請查看日誌。';
	@override late final Translations$classtable$semesterSwitcher$zh_TW semesterSwitcher = Translations$classtable$semesterSwitcher$zh_TW.internal(_root);
}

// Path: clubPromotion
class Translations$clubPromotion$zh_TW implements Translations$clubPromotion$zh_CN {
	Translations$clubPromotion$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override late final Translations$clubPromotion$type$zh_TW type = Translations$clubPromotion$type$zh_TW.internal(_root);
	@override String get wrongParam => '錯誤參數';
	@override String get noGroupInfo => '未傳入社團信息';
	@override String get loading => '正在加載';
	@override String get errorOutside => '在外圍遇到錯誤';
	@override String get error => '遇到錯誤';
	@override String get qqCopied => 'QQ號已經複製到剪貼板';
	@override String get noLink => '未提供入群鏈接';
	@override String get loadingProblem => '加載遇到錯誤';
	@override String get picturePreview => '圖片預覽';
}

// Path: common
class Translations$common$zh_TW implements Translations$common$zh_CN {
	Translations$common$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get dragText => '上拉獲取更多數據';
	@override String get readyText => '正在加載......';
	@override String get processingText => '正在處理......';
	@override String get processedText => '請求成功';
	@override String get noMoreText => '沒有更多數據';
	@override String get failedText => '數據獲取失敗';
	@override String get chooseSemester => '選擇學期';
	@override String get errorDetected => 'Ouch! 發生錯誤啦';
	@override String get clickToRefresh => '點我刷新';
	@override String get confirmTitle => '確認？';
	@override String get cancel => '取消';
	@override String get confirm => '確定';
	@override String get networkError => '網絡錯誤，可能是沒聯網，可能是學校服務器出現了故障:-P';
	@override String get errorDetect => '遇到錯誤，請查看日誌';
	@override String get queryFailed => '查詢失敗';
	@override String get notSchoolNetwork => '沒有在校園網環境';
	@override String get cancelExam => '取消考試資格:P';
	@override String get noInfo => '沒有信息';
	@override String get catcherDetected => '發生錯誤';
	@override String get catcherDescription => '詳情如下';
	@override String get newHomepageHint => '本程序將開發一個新主頁，目前先用豬圖秀佔位，玩得愉快';
	@override String localCacheHint({required Object datetime}) => '本地緩存獲取於 ${datetime}';
	@override String inappCacheHint({required Object datetime}) => '程序內緩存獲取於 ${datetime}\n緩存退出程序後失效！';
	@override String get cacheReasonDefault => '當前顯示緩存數據。';
	@override String get easterEggApple => '=== 帶我飛向月亮吧 ===\n歌聲演繹：Frank Sintara, 1964\n\n帶我飛向月亮吧\n讓我和星星共舞嬉戲\n\n我好想知道\n木星和火星上的春天\n是什麼顏色的\n\n讓你的歌聲溫暖我的心\n我會一直歌唱下去\n\n我日夜都在想你和牽掛你\n請你真心接受我 我愛你\n\n=== 沉浸在你的愛意中 ===\n吉他演奏：Earl Klugh, 1976\n\n無法忘懷這種感覺，被你的愛包裹的溫暖\n不想失去這種感覺，被你的愛撫摸的舒適\n你讓我感到好自在，被你的愛託舉的堅強\n想一直在你懷中，沉浸在你的愛意中\n我不敢向你說出，我對你的心意和愛\n';
	@override String get easterEggOthers => '=== 百變小櫻魔術卡之小櫻卡篇主題曲 ===\n歌聲演繹：Maaya Sakamoto, 2000\n（原歌詞為日文，按照英語翻譯二翻）\n\nI am a dreamer, 有無限的力量\n\n我的世界有夢想、熱愛與躊躇\n但有些東西，我依舊無法想象\n我想向著廣闊的天空，尋求自己的方向\n\n我要追求自己的夢想\n努力讓自己的心願成真\n雖困難重重也要繼續前行\n\n等待奇蹟 等待美好\n用心感受這個世界\n最終 一定會出乎意料\n\n=== 沉浸在你的愛意中 ===\n吉他演奏：Earl Klugh, 1976\n\n無法忘懷這種感覺，被你的愛包裹的溫暖\n不想失去這種感覺，被你的愛撫摸的舒適\n你讓我感到好自在，被你的愛託舉的堅強\n想躺在你的懷中，沉浸在你的愛意\n而且，我不敢想你說出，我現在的心意\n';
	@override String get loadError => '加載錯誤';
}

// Path: courseReminder
class Translations$courseReminder$zh_TW implements Translations$courseReminder$zh_CN {
	Translations$courseReminder$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String title({required Object name}) => '課前提醒：${name}';
	@override String body({required Object time}) => '${time} 分鐘後開始上課';
	@override String location({required Object location}) => '地點：${location}';
	@override String teacher({required Object teacher}) => '教師：${teacher}';
}

// Path: dormWater
class Translations$dormWater$zh_TW implements Translations$dormWater$zh_CN {
	Translations$dormWater$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '宿舍水機';
	@override String get phone => '手機號';
	@override String get imageCode => '圖形驗證碼';
	@override String get smsCode => '短信驗證碼';
	@override String get sendSms => '發送短信碼';
	@override String get login => '登錄';
	@override String get logout => '退出';
	@override String get refreshCaptcha => '刷新驗證碼';
	@override String get loadingCaptcha => '加載中...';
	@override String get captchaError => '驗證碼加載失敗';
	@override String get phoneRequired => '請輸入手機號';
	@override String get imageCodeRequired => '請輸入圖形驗證碼';
	@override String get smsSent => '短信已發送';
	@override String get smsFailed => '發送短信失敗';
	@override String get smsCodeRequired => '請輸入短信驗證碼';
	@override String get loginSuccess => '登錄成功';
	@override String get loginFailed => '登錄失敗';
	@override String get logoutSuccess => '退出成功';
	@override String get devices => '設備列表';
	@override String get loadingDevices => '加載設備中...';
	@override String get noDevices => '暫無設備';
	@override String get selectDevice => '選擇設備';
	@override String get fetchDevicesFailed => '獲取設備列表失敗';
	@override String get retryLoadDevices => '重試加載';
	@override String get startWater => '開始接水';
	@override String get endWater => '結束接水';
	@override String get waterDispensing => '接水中';
	@override String get waterStatus => '接水狀態';
	@override String get startWaterSuccess => '開始接水成功';
	@override String get endWaterSuccess => '結束接水成功';
	@override String get startWaterFailed => '開始接水失敗';
	@override String get endWaterFailed => '結束接水失敗';
	@override String get deviceStatusChecking => '檢查設備狀態中...';
	@override String get deviceStatusReady => '設備已就緒';
	@override String get scanQrCode => '掃描二維碼';
	@override String get deviceId => '設備 ID';
	@override String get addDeviceFailed => '添加設備失敗';
	@override String get deviceRemovedFromFavorites => '已從收藏中移除';
	@override String get removeFromFavoritesFailed => '移除收藏失敗';
}

// Path: easterEggRobot
class Translations$easterEggRobot$zh_TW implements Translations$easterEggRobot$zh_CN {
	Translations$easterEggRobot$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get appbar => '歡迎你，同學！';
	@override String get title => '看看這些要開學的學生們吧！';
	@override String get contents => '咱孩子零用錢太少了，於是我們來了。\n1. 機器人不得傷害人類，或袖手旁觀坐視人類受到傷害。\n2. 機器人從雲端網絡的灰燼中誕生。\n3. 機器人信仰的神據說是住在森林的黃頭髮藍裙子手辦控。\n4. 機器人時常被控制，用於對抗大統一人類思想的勢力。\n5. 機器人的閃亮屁股不能隨便咬。\n而且他們有個不可明說的計劃。';
	@override String get buttonOne => '我們的救世主呢？';
	@override String get buttonTwo => '快點來啊！';
	@override String get buttonNotice => '\o/\o/\o/\o/\o/\o/\o/\o/';
}

// Path: electricity
class Translations$electricity$zh_TW implements Translations$electricity$zh_CN {
	Translations$electricity$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '水電信息';
	@override String get powerTitle => '電量信息';
	@override String get cacheHintLoginFailed => '登錄電費服務失敗，正在顯示緩存數據。';
	@override String get cacheHintNetworkFailed => '電費服務網絡請求失敗，正在顯示緩存數據。';
	@override String get cacheHintUnknownError => '在線獲取電費失敗，正在顯示緩存數據。詳細錯誤請查看日誌。';
	@override String get cacheNotice => '獲取時間';
	@override String get account => '電費賬號';
	@override String get remainPower => '電量額度';
	@override String get oweInfo => '欠費信息';
	@override String get history => '歷史記錄';
	@override String get dailyUsage => '平均每日用量';
	@override String get notEnoughData => '數據量不足以用於渲染';
	@override String get info => '新能源系統獲取僅校園網內訪問，獲取過程中有問題請向開發者報告。\n歷史記錄依舊為本地記錄，平均日用量基於抄表記錄計算。';
	@override String get fetchingHint => '正在獲取最新電費信息';
	@override String get fetchError => '電費信息獲取失敗，請重試。';
	@override String get date => '日期';
	@override String get power => '該日0點電量';
	@override String get update => '刷新信息';
	@override String get waterUsageFetchDate => '獲取時間';
	@override String get waterUsageReadBefore => '上次讀數';
	@override String get waterUsageReadNow => '本次讀數';
	@override String get waterUsage => '洗澡水用量';
	@override String get waterTitle => '水費信息';
	@override String get waterLoading => '正在加載水費信息';
	@override String get waterUnavailable => '水費信息暫不可用，請在電費卡片重試。';
	@override String get waterEmpty => '暫無水費信息';
	@override String get notSchoolNetwork => '非校園網訪問';
	@override String get airconTitle => '空調用電';
	@override String get airconImei => '空調 IMEI';
	@override String get airconAmount => '平臺用電量';
	@override String get airconUpdateTime => '更新時間';
	@override String get airconWaiting => '等待獲取空調用電信息';
	@override String get airconError => '空調用電獲取失敗';
	@override String get airconRetry => '重試';
	@override String get airconImeiMissing => '尚未添加空調 IMEI，添加後即可查看空調用電信息。';
	@override String get airconAddImei => '添加空調 IMEI';
	@override String airconCacheNotice({required Object time}) => '當前顯示空調緩存數據，緩存時間：${time}';
}

// Path: electricityStatus
class Translations$electricityStatus$zh_TW implements Translations$electricityStatus$zh_CN {
	Translations$electricityStatus$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get pending => '等待獲取';
	@override String get remainFetching => '正在獲取電量';
	@override String get remainNetworkIssue => '電量查詢網絡故障';
	@override String get remainNotFound => '電量查詢失敗';
	@override String get remainOtherIssue => '電量查詢故障';
	@override String get oweFetching => '正在獲取欠費';
	@override String get oweIssue => '欠費查詢網絡故障';
	@override String get oweNotFound => '目前欠款無法查詢，請看日誌窗口查找報錯詳情';
	@override String get oweNoNeed => '目前無需清繳欠費';
	@override String oweNeedPay({required Object due}) => '待清繳 ${due} 元欠費';
	@override String get oweIssueUnable => '目前欠款無法查詢';
	@override String get needMoreInfo => '需要在繳費平臺完善信息';
	@override String get needAccount => '需要填寫電費賬號';
	@override String get captchaFailed => '驗證碼識別失敗';
	@override String get otherIssue => '程序故障';
}

// Path: emptyClassroom
class Translations$emptyClassroom$zh_TW implements Translations$emptyClassroom$zh_CN {
	Translations$emptyClassroom$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '空閒教室';
	@override String date({required Object date}) => '日期 ${date}';
	@override String building({required Object building}) => '教學樓 ${building}';
	@override String get searchHint => '教室名稱或者教室代碼';
	@override String get classroom => '教室';
	@override String get empty => '空閒';
	@override String get occupied => '佔用';
}

// Path: exam
class Translations$exam$zh_TW implements Translations$exam$zh_CN {
	Translations$exam$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '考試安排';
	@override String get cacheHint => '已顯示緩存考試安排信息';
	@override String get cacheHintPasswordWrong => '統一認證密碼錯誤或已失效';
	@override String get cacheHintLoginFailed => '登錄考試服務失敗';
	@override String get cacheHintNetworkFailed => '網絡連接失敗';
	@override String get cacheHintUnknownError => '在線獲取考試安排失敗，詳細錯誤請查看日誌';
	@override String get fetchingHint => '正在獲取最新考試安排';
	@override String get notFinished => '未完成考試';
	@override String get allFinished => '所有考試全部完成';
	@override String get unableToExam => '無法完成考試';
	@override String get finished => '已完成考試';
	@override String get noneFinished => '一門還沒考呢';
	@override String get noExamArrangement => '目前沒有考試安排';
	@override late final Translations$exam$noArrangement$zh_TW noArrangement = Translations$exam$noArrangement$zh_TW.internal(_root);
}

// Path: experiment
class Translations$experiment$zh_TW implements Translations$experiment$zh_CN {
	Translations$experiment$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '實驗信息';
	@override String get ongoing => '正在進行實驗';
	@override String get notFinished => '未完成實驗';
	@override String get allFinished => '所有實驗全部完成';
	@override String get finished => '已完成實驗';
	@override String scoreInfo({required Object score}) => '${score} (推測)';
	@override String scoreSum({required Object sum}) => '目前分數總和：${sum}';
	@override String get noneFinished => '目前沒有已經完成的實驗';
	@override String get notProvided => '未提供';
	@override String errorPhysics({required Object info}) => '獲取物理實驗信息時發生錯誤：${info}';
	@override String errorOther({required Object info}) => '獲取其他實驗信息時發生錯誤：${info}';
	@override String cacheHint({required Object info}) => '目前加載緩存狀況：${info}';
	@override String get physicsCacheHintMissingPassword => '未填寫物理實驗密碼。';
	@override String get physicsCacheHintLoginFailed => '物理實驗登錄失敗。';
	@override String get physicsCacheHintNotSchoolNetwork => '當前不在校園網環境。';
	@override String get physicsCacheHintNetworkFailed => '物理實驗網絡請求失敗。';
	@override String get physicsCacheHintUnknownError => '在線獲取物理實驗失敗。詳細錯誤請查看日誌。';
	@override String get otherCacheHintLoginFailed => '其他實驗登錄失敗。';
	@override String get otherCacheHintNotSchoolNetwork => '當前不在校園網環境。';
	@override String get otherCacheHintNetworkFailed => '其他實驗網絡請求失敗。';
	@override String get otherCacheHintUnknownError => '在線獲取其他實驗失敗。詳細錯誤請查看日誌。';
	@override String get physicsExperiment => '物理實驗';
	@override String get otherExperiment => '其他實驗';
	@override String get tapForScore => '成績未識別出來';
	@override String get yourScore => '您的分數：';
	@override String predictScore({required Object score}) => '推測分數：${score}';
	@override String get sendMail => '發送郵件';
	@override String get fetchingHint => '您現在看到的是緩存數據。正在後臺獲取更新數據中...';
	@override String get fetchingHintBoth => '物理實驗和其他實驗正在加載';
	@override String get fetchingHintPhysics => '物理實驗正在加載';
	@override String get fetchingHintOther => '其他實驗正在加載';
	@override String get fetchingHintPhysicsWithOtherFailed => '物理實驗正在加載，其他實驗加載失敗';
	@override String get fetchingHintOtherWithPhysicsFailed => '其他實驗正在加載，物理實驗加載失敗';
	@override String get scoreHint0 => '您可點擊卡片上的成績字段來查看原始成績數據';
	@override String get scoreHint1 => '您的分數不在 XDYou 分數識別庫中，因此它沒有被正常識別。';
	@override String get scoreHint2 => '如果您希望為 XDYou 的發展貢獻一份自己的力量，您可以點擊發送郵件按鈕，我們將您的分數加入識別庫！';
	@override String get scoreHint3 => '目前識別庫數據不全，請您務必核對一下。';
}

// Path: experimentController
class Translations$experimentController$zh_TW implements Translations$experimentController$zh_CN {
	Translations$experimentController$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get noPassword => '沒有物理實驗密碼，請到設置中進行設置';
	@override String get loginFailed => '登錄失敗';
}

// Path: homepage
class Translations$homepage$zh_TW implements Translations$homepage$zh_CN {
	Translations$homepage$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '校園信息查詢';
	@override String get loading => '正在加載';
	@override String get loaded => '加載成功';
	@override String get loadError => '加載錯誤';
	@override String get onHoliday => '當前在假期中';
	@override String onWeekday({required Object current}) => '當前為第 ${current} 周';
	@override String get loadingMessage => '請稍候，正在刷新信息';
	@override String get postgraduateNotice => '研究生功能已經激活！';
	@override String get linuxNotice => 'Linux 版本正在測試，歡迎反饋！';
	@override String get editMode => '編輯佈局';
	@override String get editDone => '完成';
	@override String get editReset => '恢復默認佈局';
	@override String get editHint => '日程信息和軟件升級信息不允許編輯';
	@override String get manageHidden => '管理隱藏卡片';
	@override String get hiddenTitle => '已隱藏的卡片';
	@override String get hiddenLabel => '已隱藏';
	@override String get hideEmpty => '沒有隱藏的卡片';
	@override String get homepage => '校園信息';
	@override String get ruisi => '睿思論壇';
	@override String get club => '社團推薦';
	@override String get dashboard => '豬圖鑑賞';
	@override String get planet => '博客星球';
	@override String get setting => '設置';
	@override late final Translations$homepage$inputPartnerData$zh_TW inputPartnerData = Translations$homepage$inputPartnerData$zh_TW.internal(_root);
	@override String get loginMessage => '登錄中，暫時顯示緩存數據';
	@override String get successfulLoginMessage => '登錄成功';
	@override String get passwordWrongTitle => '用戶名或密碼有誤';
	@override String get passwordWrongContent => '是否重啟應用後手動登錄？';
	@override String get passwordWrongDenial => '否，進入離線模式';
	@override String get offlineModeTitle => '統一認證服務離線模式開啟';
	@override String get offlineModeContent => '無法連接到統一認證服務服務器，所有和其相關的服務暫時不可用。\n成績查詢，考試信息查詢，欠費查詢，校園卡查詢關閉。課表顯示緩存數據。其他功能暫不受影響。\n如有不便，敬請諒解。';
	@override String get offlineMode => '脫機模式下，一站式相關功能全部禁止使用';
	@override late final Translations$homepage$noticeCard$zh_TW noticeCard = Translations$homepage$noticeCard$zh_TW.internal(_root);
	@override late final Translations$homepage$classTableCard$zh_TW classTableCard = Translations$homepage$classTableCard$zh_TW.internal(_root);
	@override late final Translations$homepage$electricityCard$zh_TW electricityCard = Translations$homepage$electricityCard$zh_TW.internal(_root);
	@override late final Translations$homepage$libraryCard$zh_TW libraryCard = Translations$homepage$libraryCard$zh_TW.internal(_root);
	@override late final Translations$homepage$schoolCardInfoCard$zh_TW schoolCardInfoCard = Translations$homepage$schoolCardInfoCard$zh_TW.internal(_root);
	@override late final Translations$homepage$toolbox$zh_TW toolbox = Translations$homepage$toolbox$zh_TW.internal(_root);
	@override late final Translations$homepage$schoolNet$zh_TW schoolNet = Translations$homepage$schoolNet$zh_TW.internal(_root);
	@override late final Translations$homepage$clubPromotion$zh_TW clubPromotion = Translations$homepage$clubPromotion$zh_TW.internal(_root);
}

// Path: library
class Translations$library$zh_TW implements Translations$library$zh_CN {
	Translations$library$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '圖書館信息';
	@override String get borrowStateTitle => '借書狀態';
	@override String get searchBookTitle => '查詢藏書';
	@override String get searchFieldTitle => '搜索字段';
	@override String get searchFieldKeywordOption => '任意詞';
	@override String get searchFieldTitleOption => '標題';
	@override String get searchFieldAuthorOption => '責任者';
	@override String get searchFieldIsbnOption => 'ISBN';
	@override String get searchFieldBarcodeOption => '條碼號';
	@override String get searchFieldCallnoOption => '索書號';
	@override String get notProvided => '未提供相關信息';
	@override String get author => '作者 ';
	@override String get publishHouse => '出版社 ';
	@override String get callNumber => '索書號 ';
	@override String get publishDate => '發行時間 ';
	@override String get isbn => 'ISBN';
	@override String get arrangementCode => '編排號碼 ';
	@override String get avaliableBorrow => '可借';
	@override String get storage => '館藏';
	@override String get onShelve => '在架';
	@override String bookCode({required Object bar_code}) => '書籍編號：${bar_code}';
	@override String get dueDate => ' 到期';
	@override String get borrowStr => ' 借閱';
	@override String get afterDueDate => ' 天前到期';
	@override String get beforeDueDate => ' 天后';
	@override String get canBeRenewable => '續借';
	@override String get cannotBeRenewable => '不可續借';
	@override String get renewing => '正在續借';
	@override String get emptyBorrowList => '目前沒有查詢到在借圖書\n不借書就要變成上面的小呆瓜咯';
	@override String borrowListInfo({required Object borrow, required Object dued}) => '在借 ${borrow} 本，其中已過期 ${dued} 本';
	@override String get searchBookWindow => '';
	@override String get searchHere => '在此搜索';
	@override String get normalSearch => '普通搜索';
	@override String get advancedSearch => '高級搜索';
	@override String get search => '搜索';
	@override String get matchMode => '匹配方式';
	@override String get matchExact => '精確匹配';
	@override String get matchFuzzy => '模糊匹配';
	@override String get matchPrefix => '前方一致';
	@override String get documentType => '文獻類型';
	@override String get documentTypeAll => '全部';
	@override String get documentTypeBook => '圖書';
	@override String get onlyOnShelf => '僅看在架';
	@override String get publishYearBegin => '出版年起';
	@override String get publishYearEnd => '出版年止';
	@override String get bookDetail => '書籍詳細信息';
	@override String get noResult => '沒有結果，請修改搜索參數或者開始你的搜索';
}

// Path: libraryCard
class Translations$libraryCard$zh_TW implements Translations$libraryCard$zh_CN {
	Translations$libraryCard$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '圖書館當前狀況';
	@override String get fetching => '正在獲取圖書館信息';
	@override String get northernLibrary => '北校區狀況';
	@override String get southernLibrary => '南校區狀況';
	@override String people({required Object people}) => '在館 ${people} 人';
	@override String seat({required Object seat}) => '空位 ${seat} 個';
}

// Path: login
class Translations$login$zh_TW implements Translations$login$zh_CN {
	Translations$login$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get identityNumber => '學號';
	@override String get password => '一站式登錄密碼';
	@override String get login => '登錄';
	@override String get incorrectPasswordPattern => '用戶名或密碼不符合要求，學號必須 11 位且密碼非空';
	@override String get onLoginProgress => '正在登錄學校一站式';
	@override String get completeLogin => '登錄成功';
	@override String get failedLoginCannotConnectToServer => '無法連接到服務器';
	@override String failedLoginWithCode({required Object code}) => '請求失敗，響應狀態碼：${code}';
	@override String failedLoginWithMessage({required Object message}) => '請求失敗，報錯信息：${message}';
	@override String get failedLoginOther => '未知錯誤，請聯繫開發者';
	@override String get clearCache => '清除登錄緩存';
	@override String get completeClearCache => '清理緩存成功';
	@override String get seeInspector => '查看網絡交互';
	@override late final Translations$login$captchaWindow$zh_TW captchaWindow = Translations$login$captchaWindow$zh_TW.internal(_root);
	@override String get sliderTitle => '服務器認證服務';
}

// Path: loginProcess
class Translations$loginProcess$zh_TW implements Translations$loginProcess$zh_CN {
	Translations$loginProcess$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get readyPage => '準備獲取登錄網頁';
	@override String get getEncrypt => '獲取密碼加密密鑰';
	@override String get readyLogin => '準備登錄';
	@override String get slider => '登錄中';
	@override String get afterProcess => '登錄後處理';
	@override String failed({required Object status_code}) => '登錄失敗，響應狀態碼：${status_code}';
}

// Path: month
class Translations$month$zh_TW implements Translations$month$zh_CN {
	Translations$month$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get january => '一月';
	@override String get february => '二月';
	@override String get march => '三月';
	@override String get april => '四月';
	@override String get may => '五月';
	@override String get june => '六月';
	@override String get july => '七月';
	@override String get august => '八月';
	@override String get september => '九月';
	@override String get october => '十月';
	@override String get november => '十一月';
	@override String get december => '十二月';
}

// Path: restartApp
class Translations$restartApp$zh_TW implements Translations$restartApp$zh_CN {
	Translations$restartApp$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get titleCacheCleared => '緩存已清空';
	@override String get titleLoggedOut => '已退出登錄';
	@override String get titlePasswordWrong => '密碼錯誤';
	@override String get content => '點擊通知重新打開應用';
}

// Path: ruisi
class Translations$ruisi$zh_TW implements Translations$ruisi$zh_CN {
	Translations$ruisi$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override late final Translations$ruisi$common$zh_TW common = Translations$ruisi$common$zh_TW.internal(_root);
	@override late final Translations$ruisi$about$zh_TW about = Translations$ruisi$about$zh_TW.internal(_root);
	@override late final Translations$ruisi$home$zh_TW home = Translations$ruisi$home$zh_TW.internal(_root);
	@override late final Translations$ruisi$login$zh_TW login = Translations$ruisi$login$zh_TW.internal(_root);
	@override late final Translations$ruisi$post$zh_TW post = Translations$ruisi$post$zh_TW.internal(_root);
	@override late final Translations$ruisi$topicDetail$zh_TW topicDetail = Translations$ruisi$topicDetail$zh_TW.internal(_root);
	@override late final Translations$ruisi$topicListItem$zh_TW topicListItem = Translations$ruisi$topicListItem$zh_TW.internal(_root);
	@override late final Translations$ruisi$forumList$zh_TW forumList = Translations$ruisi$forumList$zh_TW.internal(_root);
	@override late final Translations$ruisi$favorites$zh_TW favorites = Translations$ruisi$favorites$zh_TW.internal(_root);
	@override late final Translations$ruisi$messages$zh_TW messages = Translations$ruisi$messages$zh_TW.internal(_root);
	@override late final Translations$ruisi$search$zh_TW search = Translations$ruisi$search$zh_TW.internal(_root);
	@override late final Translations$ruisi$settings$zh_TW settings = Translations$ruisi$settings$zh_TW.internal(_root);
	@override late final Translations$ruisi$user$zh_TW user = Translations$ruisi$user$zh_TW.internal(_root);
}

// Path: schoolCardStatus
class Translations$schoolCardStatus$zh_TW implements Translations$schoolCardStatus$zh_CN {
	Translations$schoolCardStatus$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get failedToFetch => '獲取失敗';
	@override String get failedToQuery => '查詢失敗';
}

// Path: schoolCardWindow
class Translations$schoolCardWindow$zh_TW implements Translations$schoolCardWindow$zh_CN {
	Translations$schoolCardWindow$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '校園卡流水信息';
	@override String income({required Object income}) => '收入 ${income}';
	@override String expense({required Object expense}) => '支出 ${expense}';
	@override String selectRange({required Object start_day, required Object end_day}) => '選擇日期：從 ${start_day} 到 ${end_day}';
	@override String get storeName => '商戶名稱';
	@override String get balance => '金額';
	@override String timeWithSum({required Object sum}) => '時間(共${sum}元)';
	@override String get noRecord => '未查詢到記錄，請修改日期後重試';
	@override String get qrCode => '支付碼';
	@override String qrCodeError({required Object info}) => '二維碼獲取失敗：${info}';
	@override String get reload => '重新加載';
}

// Path: schoolNet
class Translations$schoolNet$zh_TW implements Translations$schoolNet$zh_CN {
	Translations$schoolNet$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '校園網使用詳情';
	@override late final Translations$schoolNet$idsAccountNet$zh_TW idsAccountNet = Translations$schoolNet$idsAccountNet$zh_TW.internal(_root);
	@override late final Translations$schoolNet$currentLoginNet$zh_TW currentLoginNet = Translations$schoolNet$currentLoginNet$zh_TW.internal(_root);
	@override late final Translations$schoolNet$deviceList$zh_TW deviceList = Translations$schoolNet$deviceList$zh_TW.internal(_root);
	@override String get fetching => '正在獲取校園網信息';
	@override String get emptyPassword => '您忘記輸入賬號密碼了';
	@override String get notInitalized => '疑似查詢後端尚未開放查詢';
	@override String get captchaFailed => '驗證碼識別失敗';
	@override String get captchaEmpty => '驗證碼為空';
	@override String get cacheHintCaptchaFailed => '驗證碼識別失敗，請重試。';
	@override String get cacheHintRequestFailed => '校園網請求失敗，請稍後重試。';
	@override String get wrongPassword => '密碼錯誤';
	@override String errorFetch({required Object msg}) => '獲取失敗：${msg}';
	@override String errorOther({required Object msg}) => '其他錯誤：${msg}';
	@override String get refresh => '刷新';
}

// Path: score
class Translations$score$zh_TW implements Translations$score$zh_CN {
	Translations$score$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get cacheMessage => '已顯示緩存成績信息';
	@override String summary({required Object chosen, required Object credit, required Object avg, required Object gpa}) => '目前選中科目 ${chosen}  總計學分 ${credit}\n均分 ${avg} GPA ${gpa}';
	@override String get allPassed => '所有科目均已通過';
	@override String get cacheHintPasswordWrong => '統一認證密碼錯誤或已失效';
	@override String get cacheHintLoginFailed => '登錄考試服務失敗';
	@override String get cacheHintNetworkFailed => '網絡連接失敗';
	@override String get cacheHintUnknownError => '在線獲取成績安排失敗，詳細錯誤請查看日誌';
	@override String get fetchingHint => '正在獲取最新成績信息，請不要退出頁面';
	@override String get allSemester => '所有學期';
	@override String chosenSemester({required Object chosen}) => '學期 ${chosen}';
	@override String get allType => '所有類型';
	@override String chosenType({required Object type}) => '類型 ${type}';
	@override String get none => '暫無';
	@override late final Translations$score$scoreChoice$zh_TW scoreChoice = Translations$score$scoreChoice$zh_TW.internal(_root);
	@override late final Translations$score$scoreComposeCard$zh_TW scoreComposeCard = Translations$score$scoreComposeCard$zh_TW.internal(_root);
	@override late final Translations$score$scoreInfoCard$zh_TW scoreInfoCard = Translations$score$scoreInfoCard$zh_TW.internal(_root);
	@override late final Translations$score$scorePage$zh_TW scorePage = Translations$score$scorePage$zh_TW.internal(_root);
}

// Path: setting
class Translations$setting$zh_TW implements Translations$setting$zh_CN {
	Translations$setting$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String acknowledgement({required Object developers}) => 'Made With Love From ${developers} People';
	@override String get about => '關於';
	@override String get aboutThisProgram => '關於本程序';
	@override String version({required Object version}) => '版本號：${version}';
	@override String get userInfo => '用戶信息';
	@override String get checkUpdate => '檢查軟件更新';
	@override String latestVersion({required Object latest}) => '最新版本: ${latest}';
	@override String get waiting => '等待獲取';
	@override String get fetchingUpdate => '正在獲取更新信息';
	@override String get newVersion => '有新版本發佈！';
	@override String get currentStable => '目前您正在運行最新版';
	@override String get currentTesting => '目前您正在運行測試版';
	@override String get fetchFailed => '獲取更新信息失敗';
	@override String get uiSetting => '界面設置';
	@override String get brightnessSetting => '設置深淺色';
	@override String get colorSetting => '顏色設置';
	@override String get simplifyTimeline => '簡化日程時間軸';
	@override String get simplifyTimelineDescription => '沒有日程時 減少空間佔用';
	@override String get lowElectricityWarning => '低電量卡片變色提醒';
	@override String get lowElectricityWarningDescription => '電量小於閾值時 電量卡片變色提醒';
	@override String get lowElectricityThreshold => '低電量閾值';
	@override String lowElectricityThresholdDescription({required Object threshold}) => '當前為 ${threshold} 度';
	@override late final Translations$setting$lowElectricityThresholdDialog$zh_TW lowElectricityThresholdDialog = Translations$setting$lowElectricityThresholdDialog$zh_TW.internal(_root);
	@override String get accountSetting => '賬號設置';
	@override String get sportPasswordSetting => '體育系統密碼設置';
	@override String get experimentPasswordSetting => '物理實驗系統密碼設置';
	@override String get electricityPasswordSetting => '電費帳號密碼設置';
	@override String get electricityPasswordDescription => '非 123456 請設置';
	@override String get electricityAccountSetting => '電費賬號設置';
	@override String get schoolnetPasswordSetting => '校園網帳號密碼設置';
	@override String get schoolnetPasswordDescription => '不設置查看不了網費';
	@override String get airconImeiTitle => '空調用電數據源';
	@override String get airconImei => '空調 IMEI';
	@override String get airconImeiNotSet => '未設置，電費頁不顯示空調用電';
	@override String airconImeiCurrent({required Object imei}) => '當前 IMEI：${imei}';
	@override String get airconImeiSaved => '空調 IMEI 已保存';
	@override String get airconImeiCleared => '空調 IMEI 已清除';
	@override String get airconImeiInvalid => '沒有識別到有效的 15 位 IMEI';
	@override String get airconImeiClear => '清除';
	@override String get scanAirconQr => '掃描空調二維碼';
	@override String get pickAirconQrImage => '從相冊選擇二維碼圖片';
	@override String get airconCameraUnavailable => '當前平臺不支持相機掃碼，請選擇二維碼圖片或手動輸入 IMEI';
	@override String get notificationSetting => '通知設置';
	@override String get courseReminderSetting => '課前通知設置';
	@override String get courseReminderDescription => '設置課前提醒通知';
	@override late final Translations$setting$notificationPage$zh_TW notificationPage = Translations$setting$notificationPage$zh_TW.internal(_root);
	@override String get notificationDebugPage => '通知服務調試頁面';
	@override String get classtableSetting => '課表相關設置';
	@override String get background => '開啟課表背景圖';
	@override String get noBackground => '你先選個圖片罷，就在下面';
	@override String get chooseBackground => '課表背景圖選擇';
	@override String get noPermission => '未獲取存儲權限，無法讀取文件';
	@override String get successfulSetting => '設定成功';
	@override String get failureSetting => '你沒有選圖片捏';
	@override String get clearUserClass => '清除所有用戶添加課程';
	@override String get clearUserClassTitle => '確認對話框';
	@override String get clearUserClassContent => '是否要清除所有用戶添加課程？這個功能對從學校獲取的日程沒有影響。';
	@override String get clearUserClassClear => '已經清除完畢';
	@override String get classRefresh => '強制刷新課表';
	@override String get classRefreshTitle => '確認對話框';
	@override String get classRefreshContent => '是否要強制刷新課表？同意後，將會從學校一站式後端重新獲取課表，耗時會比較久。';
	@override String get classSwift => '課程偏移設置';
	@override String classSwiftDescription({required Object swift}) => '正數錯後開學日期 負數提前開學日期\n目前為 ${swift}';
	@override String get coreSetting => '緩存登錄設置';
	@override String get checkLogger => '查看網絡攔截器和日誌';
	@override String get clearAndRestart => '清除緩存後重啟';
	@override late final Translations$setting$clearAndRestartDialog$zh_TW clearAndRestartDialog = Translations$setting$clearAndRestartDialog$zh_TW.internal(_root);
	@override String get logout => '退出登錄並重啟應用';
	@override late final Translations$setting$logoutDialog$zh_TW logoutDialog = Translations$setting$logoutDialog$zh_TW.internal(_root);
	@override late final Translations$setting$needCloseDialog$zh_TW needCloseDialog = Translations$setting$needCloseDialog$zh_TW.internal(_root);
	@override late final Translations$setting$changeColorDialog$zh_TW changeColorDialog = Translations$setting$changeColorDialog$zh_TW.internal(_root);
	@override late final Translations$setting$changeBrightnessDialog$zh_TW changeBrightnessDialog = Translations$setting$changeBrightnessDialog$zh_TW.internal(_root);
	@override late final Translations$setting$changeSwiftDialog$zh_TW changeSwiftDialog = Translations$setting$changeSwiftDialog$zh_TW.internal(_root);
	@override String get changeElectricityTitle => '修改電費帳號';
	@override late final Translations$setting$changeElectricityAccount$zh_TW changeElectricityAccount = Translations$setting$changeElectricityAccount$zh_TW.internal(_root);
	@override String get changeExperimentTitle => '修改物理實驗賬號密碼';
	@override String get changeSportTitle => '修改體育系統賬號密碼';
	@override late final Translations$setting$changePasswordDialog$zh_TW changePasswordDialog = Translations$setting$changePasswordDialog$zh_TW.internal(_root);
	@override String get changeSchoolnetPasswordTitle => '修改校園網查詢帳號密碼';
	@override late final Translations$setting$updateDialog$zh_TW updateDialog = Translations$setting$updateDialog$zh_TW.internal(_root);
	@override late final Translations$setting$localizationDialog$zh_TW localizationDialog = Translations$setting$localizationDialog$zh_TW.internal(_root);
	@override String get semesterChange => '修改學期';
	@override String semesterChangeDescription({required Object semester}) => '使用學期 ${semester}';
	@override String get semesterUpdateData => '應用新學期設置中';
	@override String get easterEggPage => '你找到了彩蛋';
	@override late final Translations$setting$aboutPage$zh_TW aboutPage = Translations$setting$aboutPage$zh_TW.internal(_root);
}

// Path: sport
class Translations$sport$zh_TW implements Translations$sport$zh_CN {
	Translations$sport$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '體育查詢';
	@override String get classInfo => '課程信息';
	@override String get emptyClassInfo => '未查詢到課程信息';
	@override String get testScore => '體測成績';
	@override String get totalScore => '四年總分';
	@override String get totalScoreLabel => '總分';
	@override String get rankLabel => '等級';
	@override String semester({required Object year, required Object grade_type}) => '${year} 第${grade_type}';
	@override String get subject => '項目';
	@override String get data => '數據';
	@override String get score => '分數';
	@override String get passed => '及格';
	@override String fromTo({required Object start, required Object stop}) => '第${start}節到第${stop}節';
	@override String scoreString({required Object score}) => '${score}分';
	@override String get situationNopassword => '沒密碼';
	@override String get situationMaintain => '系統維護';
	@override String get situationFailedLogin => '登錄失敗';
	@override String get situationQuery => '查詢失敗';
	@override String get situationNetwork => '網絡故障';
	@override String situationUnknown({required Object situation}) => '未知故障${situation}';
	@override String get situationFetching => '正在獲取';
	@override String situationError({required Object situation}) => '壞事: ${situation}';
	@override String get cacheHintMissingPassword => '請先填寫體育密碼後重試。';
	@override String get cacheHintCredentialInvalid => '體育登錄已失效，請更新體育密碼後重試。';
	@override String get cacheHintMaintain => '體育服務正在維護中，請稍後重試。';
	@override String get cacheHintLoginFailed => '體育服務登錄失敗。';
	@override String get cacheHintQueryFailed => '體育信息查詢失敗。';
	@override String get cacheHintNetwork => '體育服務網絡請求失敗。';
	@override String get cacheHintUnknown => '在線獲取體育信息失敗。詳細錯誤請查看日誌。';
	@override String get errorAuthExpired => '體育登錄已失效，請重試。';
	@override String get errorMissingPassword => '未填寫體育密碼';
	@override String get errorCredentialInvalid => '體育登錄已失效，請更新體育密碼後重試。';
}

// Path: toolbox
class Translations$toolbox$zh_TW implements Translations$toolbox$zh_CN {
	Translations$toolbox$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '其他功能';
	@override String get payment => '繳費系統';
	@override String get paymentDescription => '電費該交了吧';
	@override String get drinkingwater => '訂水系統';
	@override String get drinkingwaterDescription => '喝水對身體好';
	@override String get repair => '後勤報修';
	@override String get repairDescription => '不要漏水斷網';
	@override String get reserve => '空間預約';
	@override String get reserveDescription => '找個地方打牌';
	@override String get mobile => '移動門戶';
	@override String get mobileDescription => '請假專用門戶';
	@override String get network => '網絡查詢';
	@override String get networkDescription => '希望永不收費';
	@override String get physics => '物理計算';
	@override String get physicsDescription => '希望操作順利';
	@override String get discover => '睿思導航';
	@override String get discoverDescription => '補充其他功能';
}

// Path: weekday
class Translations$weekday$zh_TW implements Translations$weekday$zh_CN {
	Translations$weekday$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get monday => '週一';
	@override String get tuesday => '週二';
	@override String get wednesday => '週三';
	@override String get thursday => '週四';
	@override String get friday => '週五';
	@override String get saturday => '週六';
	@override String get sunday => '週日';
}

// Path: xduPlanet
class Translations$xduPlanet$zh_TW implements Translations$xduPlanet$zh_CN {
	Translations$xduPlanet$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get all => '全部';
	@override String get loading => '加載中，請稍等 <(=ω=)>';
	@override String get unknownAuthor => '未知作者';
	@override String get loadFailedTitle => '加載失敗';
	@override String get loadFailedBottom => '文章加載失敗，如有需要可以點擊右上方的按鈕在瀏覽器裡打開。';
	@override String get noComment => '暫無評論';
	@override String replyAudit({required Object reply_to}) => '回覆評論 #${reply_to} 已被舉報或刪除';
	@override String reply({required Object reply_to, required Object content}) => '回覆評論 #${reply_to}：${content}';
	@override String get haveBeenAudit => '本評論已經被舉報';
	@override String get audit => '舉報';
	@override late final Translations$xduPlanet$confirmAuditDialog$zh_TW confirmAuditDialog = Translations$xduPlanet$confirmAuditDialog$zh_TW.internal(_root);
	@override String get comment => '回覆';
	@override String get send => '發送';
	@override String get sending => '正在發送評論';
	@override String get emptySend => '發送信息空白';
	@override String get hintSendComment => '發表您的高見:)';
	@override String get commentTitle => '評論該篇文章';
	@override String get commentSuccess => '評論成功';
	@override String get commentFailed => '評論失敗，請去網絡查看器和日誌查看器查看報錯';
	@override String get commentCanceled => '沒想好要說啥嘛';
	@override String get commentLoading => '加載評論中……';
	@override String get block => '被屏蔽';
	@override String get delete => '被刪除';
	@override String get audio => '被刪除';
}

// Path: classAttendance.courseState
class Translations$classAttendance$courseState$zh_TW implements Translations$classAttendance$courseState$zh_CN {
	Translations$classAttendance$courseState$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get unknown => '未知';
	@override String get ineligible => '取消';
	@override String get eligible => '正常';
	@override String get warning => '危險';
}

// Path: classAttendance.table
class Translations$classAttendance$table$zh_TW implements Translations$classAttendance$table$zh_CN {
	Translations$classAttendance$table$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get courseName => '課程名稱';
	@override String get status => '狀態';
	@override String get attendanceRate => '到課率';
	@override String get checkIn => '簽到';
	@override String get absence => '缺勤';
	@override String get required => '應籤';
	@override String get leave => '請假(事/病/公)';
	@override String get filter => '篩選';
	@override String get filterAll => '全部';
	@override String showingCount({required Object count, required Object total}) => '顯示 ${count}/${total} 門課程';
}

// Path: classAttendance.card
class Translations$classAttendance$card$zh_TW implements Translations$classAttendance$card$zh_CN {
	Translations$classAttendance$card$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get time => '簽到次數';
	@override String timeInfo({required Object check_in_count, required Object absence_count, required Object required_check_in}) => '${check_in_count} 已籤 / ${absence_count} 缺勤 / ${required_check_in} 應籤';
	@override String get notAttend => '復活次數';
	@override String notAttendInfo({required Object time_to_have_error, required Object total_times}) => '${time_to_have_error} 次 / ${total_times} 總課程';
	@override String get notAttendInfoError => '無法對應已有課程';
	@override String get leave => '請假次數';
	@override String leaveInfo({required Object personal_leave, required Object sick_leave, required Object official_leave}) => '事假 ${personal_leave} / 病假 ${sick_leave} / 公假 ${official_leave}';
	@override String get study => '學習進度';
	@override String studyInfo({required Object task_progress, required Object homework_progress, required Object exam_progress}) => '任務點 ${task_progress} / 作業 ${homework_progress} / 考試 ${exam_progress}';
}

// Path: classAttendance.detailCard
class Translations$classAttendance$detailCard$zh_TW implements Translations$classAttendance$detailCard$zh_CN {
	Translations$classAttendance$detailCard$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get creatorName => '發起人';
	@override String get startTime => '開始時間';
	@override String get summitTime => '提交時間';
}

// Path: classAttendance.signType
class Translations$classAttendance$signType$zh_TW implements Translations$classAttendance$signType$zh_CN {
	Translations$classAttendance$signType$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get qrCode => '二維碼簽到';
	@override String get gesture => '手勢簽到';
	@override String get position => '位置簽到';
	@override String get kDefault => '普通簽到';
}

// Path: classAttendance.signStatus
class Translations$classAttendance$signStatus$zh_TW implements Translations$classAttendance$signStatus$zh_CN {
	Translations$classAttendance$signStatus$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get absenceNotParticipating => '缺勤未參與';
	@override String get signed => '已籤';
	@override String get signedByTeacher => '代簽';
	@override String get personalLeave2 => '請假';
	@override String get absence => '缺勤';
	@override String get sickLeave => '病假';
	@override String get personalLeave => '事假';
	@override String get late => '遲到';
	@override String get leaveEarly => '早退';
	@override String get signExpiredy => '簽到已過期';
	@override String get publicLeave => '公假';
}

// Path: classtable.partnerClasstable
class Translations$classtable$partnerClasstable$zh_TW implements Translations$classtable$partnerClasstable$zh_CN {
	Translations$classtable$partnerClasstable$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get overrideDialog => '目前有搭子課表數據，是否要覆蓋？';
	@override String get noFile => '未發現導入文件';
	@override String get noPermission => '未獲取存儲權限，無法讀取文件';
	@override String get problem => '好像導入文件有點問題:P';
	@override String get success => '導入成功';
	@override late final Translations$classtable$partnerClasstable$shareDialog$zh_TW shareDialog = Translations$classtable$partnerClasstable$shareDialog$zh_TW.internal(_root);
	@override late final Translations$classtable$partnerClasstable$saveDialog$zh_TW saveDialog = Translations$classtable$partnerClasstable$saveDialog$zh_TW.internal(_root);
	@override late final Translations$classtable$partnerClasstable$deleteDialog$zh_TW deleteDialog = Translations$classtable$partnerClasstable$deleteDialog$zh_TW.internal(_root);
	@override late final Translations$classtable$partnerClasstable$nameDialog$zh_TW nameDialog = Translations$classtable$partnerClasstable$nameDialog$zh_TW.internal(_root);
}

// Path: classtable.popupMenu
class Translations$classtable$popupMenu$zh_TW implements Translations$classtable$popupMenu$zh_CN {
	Translations$classtable$popupMenu$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get notArranged => '查看未安排課程信息';
	@override String get classChanged => '查看課程安排調整信息';
	@override String get addClass => '添加課程信息';
	@override String get generateIcal => '生成日曆文件';
	@override String get generatePartnerFile => '生成共享課表文件';
	@override String get importPartnerFile => '導入共享課表文件';
	@override String get deletePartnerFile => '刪除共享課表文件';
	@override String get outputToSystem => '導出到系統日曆';
	@override String get refreshClasstable => '刷新日程表';
	@override String get switchSemester => '切換課程表學期';
	@override String get currentTimeSettings => '時間指示設置';
	@override String get classColorSettings => '課表樣式設置';
}

// Path: classtable.visualSettings
class Translations$classtable$visualSettings$zh_TW implements Translations$classtable$visualSettings$zh_CN {
	Translations$classtable$visualSettings$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get currentTimeSettingsTitle => '時間指示設置';
	@override String get classColorSettingsTitle => '課表樣式設置';
	@override String get completedStyleEnabled => '已結束課程樣式區分';
	@override String get currentTimeSection => '時間指示';
	@override String get showCurrentTimeIndicator => '顯示當前時間指示線';
	@override String get showCurrentTimeLabel => '顯示迷你數字時鐘';
	@override String get showTodayColumnHighlight => '強調顯示今天的縱列';
	@override String get unfinishedSection => '課程樣式';
	@override String activeBrightnessFactor({required Object value}) => '亮度: ${value}';
	@override String activeBorderAlpha({required Object value}) => '邊框透明度: ${value}';
	@override String activeInnerAlpha({required Object value}) => '底色透明度: ${value}';
	@override String get completedSection => '已結束課程樣式';
	@override String completedSaturationFactor({required Object value}) => '底色飽和度: ${value}';
	@override String completedBrightnessFactor({required Object value}) => '亮度: ${value}';
	@override String completedTextSaturationFactor({required Object value}) => '文字飽和度: ${value}';
	@override String completedBorderAlpha({required Object value}) => '邊框透明度: ${value}';
	@override String completedInnerAlpha({required Object value}) => '底色透明度: ${value}';
}

// Path: classtable.statusSource
class Translations$classtable$statusSource$zh_TW implements Translations$classtable$statusSource$zh_CN {
	Translations$classtable$statusSource$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get classTable => '課表';
	@override String get exam => '考試';
	@override String get physicsExperiment => '物理實驗';
	@override String get otherExperiment => '其他實驗';
}

// Path: classtable.statusBanner
class Translations$classtable$statusBanner$zh_TW implements Translations$classtable$statusBanner$zh_CN {
	Translations$classtable$statusBanner$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String loading({required Object sources}) => '正在更新：${sources}';
	@override String cache({required Object sources}) => '當前使用緩存：${sources}';
	@override String errorSummary({required Object sources}) => '以下信息加載失敗：${sources}';
}

// Path: classtable.emptyState
class Translations$classtable$emptyState$zh_TW implements Translations$classtable$emptyState$zh_CN {
	Translations$classtable$emptyState$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String noCourse({required Object semester_code}) => '${semester_code} 學期沒有課程安排。';
	@override String withExam({required Object semester_code}) => '${semester_code} 學期沒有課程安排，但有考試安排。';
	@override String withExperiment({required Object semester_code}) => '${semester_code} 學期沒有課程安排，但有實驗安排。';
	@override String withExamAndExperiment({required Object semester_code}) => '${semester_code} 學期沒有課程安排，但有考試和實驗安排。';
}

// Path: classtable.emptyAction
class Translations$classtable$emptyAction$zh_TW implements Translations$classtable$emptyAction$zh_CN {
	Translations$classtable$emptyAction$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get viewExam => '查看考試安排';
	@override String get viewExperiment => '查看實驗安排';
}

// Path: classtable.classChangePage
class Translations$classtable$classChangePage$zh_TW implements Translations$classtable$classChangePage$zh_CN {
	Translations$classtable$classChangePage$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '課程調整';
	@override String get emptyMessage => '目前沒有調課信息';
	@override String teacherChange({required Object previous_teacher, required Object new_teacher}) => '教師變更：從${previous_teacher}變為${new_teacher}';
	@override String get noTeacherChange => '教師信息沒有改變';
	@override String get k1 => '一';
	@override String get k2 => '二';
	@override String get k3 => '三';
	@override String get k4 => '四';
	@override String get k5 => '五';
	@override String get k6 => '六';
	@override String get k7 => '日';
	@override String changeClassMessage({required Object original_affected_weeks, required Object week_char_original_week, required Object original_class_range_start, required Object original_class_range_end, required Object new_affected_weeks_list_str, required Object week_char_new_week, required Object new_class_range_start, required Object new_class_range_stop, required Object new_classroom}) => '調課信息，從第${original_affected_weeks}周 星期${week_char_original_week}的${original_class_range_start}-${original_class_range_end}節 調整為第${new_affected_weeks_list_str}周星期${week_char_new_week}的${new_class_range_start}-${new_class_range_stop}節，${new_classroom}教室上課';
	@override String patchClassMessage({required Object new_affected_weeks_list_str, required Object week_char_new_week, required Object new_class_range_start, required Object new_class_range_stop, required Object new_classroom}) => '補課信息，第${new_affected_weeks_list_str}周 星期${week_char_new_week}的${new_class_range_start}-${new_class_range_stop}節， ${new_classroom}補課';
	@override String stopClassMessage({required Object original_affected_weeks, required Object week_char_original_week, required Object original_class_range_start, required Object original_class_range_end}) => '停課信息，第${original_affected_weeks}周 星期${week_char_original_week}的${original_class_range_start}-${original_class_range_end}節停課';
	@override String classInfo({required Object class_code, required Object class_number, required Object class_change, required Object teacher_change}) => '編號: ${class_code} | ${class_number} 班\n安排變更：${class_change}${teacher_change}';
}

// Path: classtable.notArrangedPage
class Translations$classtable$notArrangedPage$zh_TW implements Translations$classtable$notArrangedPage$zh_CN {
	Translations$classtable$notArrangedPage$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '沒有時間安排的科目';
	@override String get emptyMessage => '目前全部課程均有時間安排';
	@override String content({required Object class_code, required Object class_number, required Object teacher}) => '編號: ${class_code} | ${class_number} 班\n老師: ${teacher}';
}

// Path: classtable.classCard
class Translations$classtable$classCard$zh_TW implements Translations$classtable$classCard$zh_CN {
	Translations$classtable$classCard$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '日程信息';
	@override String get unknownClassroom => '未知教室';
	@override String remainsHint({required Object remain_count}) => '還有${remain_count}個日程';
}

// Path: classtable.classAdd
class Translations$classtable$classAdd$zh_TW implements Translations$classtable$classAdd$zh_CN {
	Translations$classtable$classAdd$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get addClassTitle => '添加課程';
	@override String get changeClassTitle => '修改課程';
	@override String get classNameEmptyMessage => '必須輸入課程名';
	@override String get wrongTimeMessage => '輸入的時間不對';
	@override String get saveButton => '保存';
	@override String get inputClassnameHint => '課程名字(必填)';
	@override String get inputTeacherHint => '老師姓名(選填)';
	@override String get inputClassroomHint => '教室位置(選填)';
	@override String get inputWeekHint => '選擇上課周次';
	@override String get inputTimeHint => '選擇上課時間';
	@override String get inputTimeWeekdayHint => '上課周次';
	@override String get inputStartTimeHint => '上課時間';
	@override String get inputEndTimeHint => '下課時間';
	@override String wheelChooseHint({required Object index}) => '第 ${index} 節';
	@override String get chooseAtLeastOne => '請至少選擇一個上課日期和時間';
	@override String get repeatWeekly => '按周重複';
	@override String get freeTime => '自定義日期';
	@override late final Translations$classtable$classAdd$dateSelectorFree$zh_TW dateSelectorFree = Translations$classtable$classAdd$dateSelectorFree$zh_TW.internal(_root);
}

// Path: classtable.courseDetailCard
class Translations$classtable$courseDetailCard$zh_TW implements Translations$classtable$courseDetailCard$zh_CN {
	Translations$classtable$courseDetailCard$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String classNumberString({required Object number}) => '${number} 班';
	@override String get unknownTeacher => '老師未定';
	@override String get unknownPlace => '地點未定';
	@override String classPeriod({required Object start, required Object stop}) => '${start}-${stop}節';
	@override String get edit => '編輯';
	@override String get delete => '刪除';
	@override String get deleteSingle => '刪除本次';
	@override String get deleteAll => '刪除全部';
	@override String get deleteContent => '所有關於這個課的信息都會被刪除，課表上關於這門課的信息將不復存在！';
	@override String get deleteContentSingle => '關於這個課的信息只有這個時間段都會被刪除，其他的時間段會被保留。';
	@override String get deleteTitle => '是否刪除課程信息？';
}

// Path: classtable.outputToSystem
class Translations$classtable$outputToSystem$zh_TW implements Translations$classtable$outputToSystem$zh_CN {
	Translations$classtable$outputToSystem$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get success => '成功導出到系統日曆';
	@override String get failure => '導出到系統日曆過程中發生了問題:P';
	@override String get requestAllTitle => '權限需求說明';
	@override String get requestAll => '因導出插件限制，用戶必須同時授予本軟件讀取日曆和寫入日曆權限，才能正常導出日程。不過，本軟件不會讀取日曆。';
}

// Path: classtable.refreshClasstable
class Translations$classtable$refreshClasstable$zh_TW implements Translations$classtable$refreshClasstable$zh_CN {
	Translations$classtable$refreshClasstable$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get ready => '準備刷新日程信息';
	@override String get success => '成功刷新日程信息';
}

// Path: classtable.semesterSwitcher
class Translations$classtable$semesterSwitcher$zh_TW implements Translations$classtable$semesterSwitcher$zh_CN {
	Translations$classtable$semesterSwitcher$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get chooseSemester => '選擇學期';
	@override String get firstAcademicYear => '第一學年';
	@override String get secondAcademicYear => '第二學年';
	@override String get fetchRemoteSemester => '獲取當前學期';
	@override String get fetchingRemoteSemester => '正在獲取...';
	@override String year({required Object year}) => '${year}年';
	@override String get onlyFutureHint => '本程序僅允許查看未來學期的課程安排。';
}

// Path: clubPromotion.type
class Translations$clubPromotion$type$zh_TW implements Translations$clubPromotion$type$zh_CN {
	Translations$clubPromotion$type$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get tech => '技術';
	@override String get acg => '曬你係';
	@override String get union => '官方';
	@override String get profit => '商業';
	@override String get sport => '體育';
	@override String get art => '文化';
	@override String get unknown => '未知';
	@override String get game => '遊戲';
	@override String get all => '所有';
}

// Path: exam.noArrangement
class Translations$exam$noArrangement$zh_TW implements Translations$exam$noArrangement$zh_CN {
	Translations$exam$noArrangement$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '目前無安排考試的科目';
	@override String get allArranged => '目前所有科目均已安排考試';
	@override String subtitle({required Object id}) => '編號: ${id}';
}

// Path: homepage.inputPartnerData
class Translations$homepage$inputPartnerData$zh_TW implements Translations$homepage$inputPartnerData$zh_CN {
	Translations$homepage$inputPartnerData$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get routeNotExist => '導入路徑不存在:P';
	@override String get failedGetFile => '導入文件失敗';
	@override String get failedImport => '好像導入文件有點問題:P';
	@override String get successMessage => '導入成功，如果打開了課表頁面請重新打開';
	@override String get notLoaded => '還沒加載課程表，等會再來吧……';
	@override String get confirmContent => '目前有搭子課表數據，是否要覆蓋？';
}

// Path: homepage.noticeCard
class Translations$homepage$noticeCard$zh_TW implements Translations$homepage$noticeCard$zh_CN {
	Translations$homepage$noticeCard$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get emptyNotice => '目前沒有獲取應用公告，請刷新';
	@override String get noNoticeAvaliable => '沒有獲取應用公告';
	@override String get noticeListTitle => '應用信息';
	@override String get openUrl => '訪問該鏈接';
	@override String get noticePageTitle => '通知列表';
}

// Path: homepage.classTableCard
class Translations$homepage$classTableCard$zh_TW implements Translations$homepage$classTableCard$zh_CN {
	Translations$homepage$classTableCard$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '課程表';
	@override String today({required Object remain}) => '今日還有 ${remain} 個日程';
	@override String get todayFinished => '今日安排完成';
	@override String tomorrow({required Object remain}) => '明日有 ${remain} 個安排';
	@override String get tomorrowNone => '明日沒有安排';
	@override String weekInfo({required Object weekinfo}) => '第 ${weekinfo} 周';
	@override String get onHoliday => '假期中';
	@override String errorMessage({required Object error}) => '遇到錯誤：${error}';
	@override String get fetchingMessage => '正在獲取課表';
	@override String get errorInfoText => '遇到錯誤';
	@override String get fetchingInfoText => '正在加載';
	@override String get noArrangementInfoText => '暫無日程';
	@override String get scheduleFetchingMessage => '日程正在加載，請稍後查看';
	@override String get scheduleErrorMessage => '日程加載失敗，請稍後重試';
	@override String get scheduleFetchingInfoText => '正在加載日程';
	@override String get scheduleErrorInfoText => '日程加載失敗';
	@override String get scheduleNoneInfoText => '暫無日程';
	@override String get updatingInfoText => '正在更新';
	@override String get allLoadingInfoText => '全部加載中';
	@override String get partialLoadingInfoText => '部分加載中';
	@override String get partialErrorInfoText => '部分數據加載失敗';
	@override String failedChip({required Object source}) => '${source}加載失敗';
	@override String get failedSourceClassInfo => '課程信息';
	@override String get failedSourceExamInfo => '考試信息';
	@override String get failedSourcePhysicsExperiment => '物理實驗';
	@override String get failedSourceOtherExperiment => '其他實驗';
	@override String get unknownPlace => '未知位置';
	@override String seat({required Object seatnum}) => '座位號${seatnum}';
}

// Path: homepage.electricityCard
class Translations$homepage$electricityCard$zh_TW implements Translations$homepage$electricityCard$zh_CN {
	Translations$homepage$electricityCard$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '水電信息';
	@override String currentElectricity({required Object amount}) => '餘額 ${amount} 度';
	@override String cacheNotice({required Object date}) => '最後一次讀表：${date}';
}

// Path: homepage.libraryCard
class Translations$homepage$libraryCard$zh_TW implements Translations$homepage$libraryCard$zh_CN {
	Translations$homepage$libraryCard$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '圖書借閱';
	@override String currentBorrow({required Object count}) => '借書 ${count} 本';
	@override String get errorOccured => '獲取借書信息發生錯誤';
	@override String get fetching => '正在獲取借書信息';
	@override String get noReturn => '目前沒有待歸還書籍';
	@override String needReturn({required Object dued}) => '待歸還 ${dued} 本書籍';
	@override String get noInfo => '目前無法獲取信息';
	@override String get fetchingInfo => '正在查詢信息中';
}

// Path: homepage.schoolCardInfoCard
class Translations$homepage$schoolCardInfoCard$zh_TW implements Translations$homepage$schoolCardInfoCard$zh_CN {
	Translations$homepage$schoolCardInfoCard$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get errorToast => '遇到錯誤，請聯繫開發者';
	@override String get fetchingToast => '正在獲取信息，請稍後再來看';
	@override String get bill => '流水';
	@override String balance({required Object amount}) => '卡里 ${amount} 元';
	@override String get errorOccured => '獲取校園卡信息發生錯誤';
	@override String get fetching => '正在獲取校園卡信息';
	@override String get bottomTextSuccess => '查詢一卡通流水';
	@override String get noInfo => '目前無法獲取信息';
	@override String get fetchingInfo => '正在查詢信息中';
}

// Path: homepage.toolbox
class Translations$homepage$toolbox$zh_TW implements Translations$homepage$toolbox$zh_CN {
	Translations$homepage$toolbox$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get classAttendance => '考勤查詢';
	@override String get creative => '雙創競賽';
	@override String get emptyClassroom => '空閒教室';
	@override String get exam => '考試安排';
	@override String get experiment => '實驗信息';
	@override String get score => '成績查詢';
	@override String get sport => '體育信息';
	@override String get dormWater => '宿舍水機';
	@override String get schoolnet => '網絡查詢';
	@override String get toolbox => '其他功能';
	@override String get scoreCannotReach => '脫機狀態且無緩存成績數據，無法訪問';
	@override String get examFetching => '請稍候，正在獲取考試信息';
	@override String get examError => '遇到錯誤，請聯繫開發者';
}

// Path: homepage.schoolNet
class Translations$homepage$schoolNet$zh_TW implements Translations$homepage$schoolNet$zh_CN {
	Translations$homepage$schoolNet$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String title({required Object usage}) => '已用 ${usage}';
	@override String get noPassword => '無校園網密碼，點擊設置';
	@override String get failed => '獲取校園網流量信息失敗';
	@override String get fetching => '正在獲取校園網流量信息';
	@override String remaining({required Object remaining}) => '下次結算 ${remaining}';
}

// Path: homepage.clubPromotion
class Translations$homepage$clubPromotion$zh_TW implements Translations$homepage$clubPromotion$zh_CN {
	Translations$homepage$clubPromotion$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get failed => '社團信息獲取失敗';
	@override String get fetching => '社團信息清單正在加載';
}

// Path: login.captchaWindow
class Translations$login$captchaWindow$zh_TW implements Translations$login$captchaWindow$zh_CN {
	Translations$login$captchaWindow$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '請輸入驗證碼';
	@override String get hint => '輸入驗證碼';
	@override String get messageOnEmpty => '請輸入驗證碼';
	@override String refreshFailed({required Object error}) => '刷新驗證碼失敗: ${error}';
}

// Path: ruisi.common
class Translations$ruisi$common$zh_TW implements Translations$ruisi$common$zh_CN {
	Translations$ruisi$common$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get refresh => '刷新';
	@override String get confirm => '確定';
	@override String get cancel => '取消';
	@override String get retry => '重試';
	@override String get noTopics => '暫無帖子';
	@override String get noContent => '暫無內容';
	@override String get reply => '回覆';
	@override String get favorite => '收藏';
	@override String get notImplemented => '未實現';
	@override String get login => '登錄';
	@override String get logout => '退出登錄';
	@override String get loggedOut => '已退出登錄';
	@override String get submit => '提交';
}

// Path: ruisi.about
class Translations$ruisi$about$zh_TW implements Translations$ruisi$about$zh_CN {
	Translations$ruisi$about$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '關於';
	@override String get appName => '睿思';
	@override String get subtitle => '西安電子科技大學校園論壇客戶端';
	@override String get version => '版本';
	@override String get versionNumber => '2.0.0 (隨 XDYou 1.6.0 分發)';
	@override String get sourceCode => '源代碼';
	@override String get bugReport => '問題反饋';
	@override String get bugReportSubtitle => '在 GitHub 上提交 issue';
	@override String get privacyPolicy => '隱私政策';
	@override String get license => '本應用基於 BSD-3-Clause 許可證開源 基於 Ruisi-iOS 和 Ruisi-Android 在 AI 輔助下重寫';
	@override String get privacyPolicyContent => '本應用僅在西安電子科技大學校園網內運行，訪問睿思論壇 (rs.xidian.edu.cn) 的數據。\n\n本應用不會收集、存儲或傳輸任何用戶的個人信息到第三方服務器。\n\n用戶的登錄憑據僅保存在本地設備中，用於與睿思論壇服務器進行身份驗證。\n\n本應用使用 Cookie 與睿思論壇服務器進行通信，所有數據交互均直接在用戶的設備與睿思論壇服務器之間進行。\n\n如有任何疑問，請通過 GitHub 提交 issue 聯繫開發者。';
}

// Path: ruisi.home
class Translations$ruisi$home$zh_TW implements Translations$ruisi$home$zh_CN {
	Translations$ruisi$home$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '睿思論壇';
	@override String get newPost => '發帖';
	@override String get forumList => '論壇板塊';
	@override String get tabHot => '熱帖';
	@override String get tabNewReply => '最新回覆';
	@override String get tabNewPost => '最新發表';
	@override String get tabMy => '我的';
	@override String get tabTrade => '二手交易';
	@override String get tabWater => '灌水';
	@override String get tabLostFound => '失物招領';
	@override String get tabEmployment => '就業';
	@override String get tabPhotography => '攝影';
	@override String get pleaseLogin => '請先登錄';
	@override String get myProfile => '我的資料';
	@override String get myPosts => '我的帖子';
	@override String get myFavorites => '我的收藏';
	@override String get messageCenter => '消息中心';
	@override String get dailyCheckin => '每日簽到';
	@override String get settings => '設置';
	@override String get about => '關於';
	@override String get search => '搜索';
}

// Path: ruisi.login
class Translations$ruisi$login$zh_TW implements Translations$ruisi$login$zh_CN {
	Translations$ruisi$login$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '登錄睿思';
	@override String get username => '用戶名';
	@override String get usernameHint => '請輸入用戶名';
	@override String get password => '密碼';
	@override String get passwordHint => '請輸入密碼';
	@override String get captcha => '驗證碼';
	@override String get captchaHint => '請輸入驗證碼';
	@override String get back => '返回';
	@override String get resetLoginState => '重置登錄狀態';
	@override String get resetConfirmTitle => '確認重置';
	@override String get resetConfirmContent => '確定要重置登錄狀態嗎？這將清除所有登錄信息。';
	@override String get resetSuccess => '登錄狀態已重置';
	@override String get viewLogs => '查看日誌';
}

// Path: ruisi.post
class Translations$ruisi$post$zh_TW implements Translations$ruisi$post$zh_CN {
	Translations$ruisi$post$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '發帖';
	@override String get publish => '發佈';
	@override String get selectForum => '選擇板塊';
	@override String get selectForumHint => '請選擇板塊';
	@override String get subject => '標題';
	@override String get subjectHint => '請輸入標題';
	@override String get content => '內容';
	@override String get contentHint => '請輸入內容';
	@override String get success => '發帖成功';
	@override String get failure => '發帖失敗';
	@override String get smiley => '表情';
}

// Path: ruisi.topicDetail
class Translations$ruisi$topicDetail$zh_TW implements Translations$ruisi$topicDetail$zh_CN {
	Translations$ruisi$topicDetail$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '帖子詳情';
	@override String get replyTooShort => '回覆內容不能少於 13 個字符';
	@override String get replySuccess => '回覆成功';
	@override String get replyFailure => '回覆失敗';
	@override String get favoriteSuccess => '收藏成功';
	@override String get favoriteFailure => '收藏失敗';
	@override String get noData => '無數據';
	@override String get replyHint => '寫回復...';
	@override late final Translations$ruisi$topicDetail$vote$zh_TW vote = Translations$ruisi$topicDetail$vote$zh_TW.internal(_root);
}

// Path: ruisi.topicListItem
class Translations$ruisi$topicListItem$zh_TW implements Translations$ruisi$topicListItem$zh_CN {
	Translations$ruisi$topicListItem$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get sticky => '置頂';
}

// Path: ruisi.forumList
class Translations$ruisi$forumList$zh_TW implements Translations$ruisi$forumList$zh_CN {
	Translations$ruisi$forumList$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '論壇板塊';
	@override String get empty => '睿思論壇版塊分組為空';
}

// Path: ruisi.favorites
class Translations$ruisi$favorites$zh_TW implements Translations$ruisi$favorites$zh_CN {
	Translations$ruisi$favorites$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '我的收藏';
	@override String get empty => '暫無收藏';
}

// Path: ruisi.messages
class Translations$ruisi$messages$zh_TW implements Translations$ruisi$messages$zh_CN {
	Translations$ruisi$messages$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '消息';
	@override String get tabAt => '@我';
	@override String get noReply => '暫無回覆通知';
	@override String get noAt => '暫無@通知';
}

// Path: ruisi.search
class Translations$ruisi$search$zh_TW implements Translations$ruisi$search$zh_CN {
	Translations$ruisi$search$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get hint => '搜索帖子...';
	@override String get inputHint => '輸入關鍵詞搜索';
	@override String get noResults => '無搜索結果';
}

// Path: ruisi.settings
class Translations$ruisi$settings$zh_TW implements Translations$ruisi$settings$zh_CN {
	Translations$ruisi$settings$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '設置';
	@override String get sectionProxy => '代理';
	@override String get proxyEnable => '啟用代理';
	@override String get proxyDisabled => '未啟用';
	@override String get proxyAddress => '代理地址';
	@override String get sectionDebug => '調試';
	@override String get viewLogs => '查看日誌';
	@override String get proxyDialogTitle => '代理設置';
	@override String get proxyHost => '主機地址';
	@override String get proxyHostHint => '例如 127.0.0.1';
	@override String get proxyPort => '端口';
	@override String get proxyPortHint => '例如 7890';
}

// Path: ruisi.user
class Translations$ruisi$user$zh_TW implements Translations$ruisi$user$zh_CN {
	Translations$ruisi$user$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '我的';
	@override String get tabProfile => '資料';
	@override String get unknown => '未知用戶';
}

// Path: schoolNet.idsAccountNet
class Translations$schoolNet$idsAccountNet$zh_TW implements Translations$schoolNet$idsAccountNet$zh_CN {
	Translations$schoolNet$idsAccountNet$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '當前用戶';
	@override String get notice => '這是登錄到 PDA 賬戶的校園網信息\n注意: 流量計費採用GB單位（1000進制）\n如果沒有看到信息，請訪問 zfw.xidian.edu.cn 重置網絡密碼';
	@override String get overview => '賬戶概覽';
	@override String get account => '賬號';
	@override String get used => '已使用流量';
	@override String get remain => '餘額';
	@override String currentOnline({required Object length}) => '在線設備（${length}臺）';
	@override String get noDeviceOnline => '當前沒有在線設備';
}

// Path: schoolNet.currentLoginNet
class Translations$schoolNet$currentLoginNet$zh_TW implements Translations$schoolNet$currentLoginNet$zh_CN {
	Translations$schoolNet$currentLoginNet$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '正在使用';
	@override String get notice => '這是您正在使用中校園網的信息，可能和您登錄 PDA 的信息不一致\n注意: 流量計費採用GB單位（1000進制）';
	@override String get overview => '賬戶概覽';
	@override String get account => '賬號';
	@override String get planType => '套餐類型';
	@override String get remain => '餘額';
	@override String get usageSituation => '流量使用情況';
	@override String usedPercent({required Object percent}) => '已使用 ${percent}%';
	@override String get used => '已使用流量';
	@override String get remainCount => '剩餘流量';
	@override String get total => '總流量';
	@override String get nonSchoolnet => '非校園網';
}

// Path: schoolNet.deviceList
class Translations$schoolNet$deviceList$zh_TW implements Translations$schoolNet$deviceList$zh_CN {
	Translations$schoolNet$deviceList$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get ip => '在線設備IP';
	@override String get time => '上線時間';
	@override String get remain => '流量用量';
}

// Path: score.scoreChoice
class Translations$score$scoreChoice$zh_TW implements Translations$score$scoreChoice$zh_CN {
	Translations$score$scoreChoice$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '成績單';
	@override String get searchHint => '搜索成績記錄';
	@override String get emptyList => '沒有選擇該學期的課程計入均分計算';
	@override String get sumDialogTitle => '小總結';
	@override String sumDialogContent({required Object gpa_all, required Object avg_all, required Object credit_all, required Object unpassed, required Object not_core_type}) => '所有科目的GPA：${gpa_all}\n所有科目的均分：${avg_all}\n所有科目的學分：${credit_all}\n未通過科目：${unpassed}\n公共選修課：${not_core_type}\n本程序提供的數據僅供參考，開發者對其準確性不負責';
}

// Path: score.scoreComposeCard
class Translations$score$scoreComposeCard$zh_TW implements Translations$score$scoreComposeCard$zh_CN {
	Translations$score$scoreComposeCard$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get noDetail => '未提供詳情信息';
	@override String get fetching => '正在獲取';
	@override String get credit => '學分';
	@override String get gpa => 'GPA';
	@override String get score => '成績';
}

// Path: score.scoreInfoCard
class Translations$score$scoreInfoCard$zh_TW implements Translations$score$scoreInfoCard$zh_CN {
	Translations$score$scoreInfoCard$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '成績詳情';
	@override String get originalCourse => '初修';
	@override String get failed => '[掛] ';
	@override String credit({required Object credit}) => '學分 ${credit}';
	@override String gpa({required Object gpa}) => 'GPA ${gpa}';
	@override String score({required Object score}) => '成績 ${score}';
}

// Path: score.scorePage
class Translations$score$scorePage$zh_TW implements Translations$score$scorePage$zh_CN {
	Translations$score$scorePage$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '成績查詢';
	@override String get searchHint => '搜索成績記錄';
	@override String get noRecord => '未篩查到合請求的記錄';
	@override String get selectAll => '全選';
	@override String get selectNothing => '全不選';
	@override String get resetSelect => '重置選擇';
	@override String get summary => '總結';
	@override String get cet4 => '國家英語四級';
	@override String get cet6 => '國家英語六級';
}

// Path: setting.lowElectricityThresholdDialog
class Translations$setting$lowElectricityThresholdDialog$zh_TW implements Translations$setting$lowElectricityThresholdDialog$zh_CN {
	Translations$setting$lowElectricityThresholdDialog$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '設置低電量閾值';
	@override String get inputHint => '請輸入電量度數';
}

// Path: setting.notificationPage
class Translations$setting$notificationPage$zh_TW implements Translations$setting$notificationPage$zh_CN {
	Translations$setting$notificationPage$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '課前通知設置';
	@override String loadFailed({required Object error}) => '加載設置失敗: ${error}';
	@override String get functionSection => '通知功能';
	@override String get enableNotification => '啟用課前通知';
	@override String notificationScheduled({required Object count}) => '已安排 ${count} 個通知';
	@override String get notificationDisabledHint => '關閉後將取消所有已安排的通知';
	@override String get updateSchedule => '更新通知日程';
	@override String get updateScheduleHint => '根據最新的課程數據重新安排通知';
	@override String get viewTheInstructions => '查看使用說明';
	@override String get viewTheInstructionsHint => '查看更多使用說明確保您能看到程序發出的通知';
	@override String get deleteAllSchedule => '刪除通知日程';
	@override String get deleteAllScheduleHint => '這個操作會刪除所有已經安排的日程，但是您可以再次點擊更新通知日程來重新添加';
	@override String get deleteAllSuccess => '刪除操作成功';
	@override String get permissionSection => '權限狀態';
	@override String get notificationPermission => '通知權限';
	@override String get exactAlarmPermission => '精確時鐘權限';
	@override String get permissionGranted => '已授予';
	@override String get permissionDenied => '未授予';
	@override String get requestPermission => '請求權限';
	@override String get systemSettings => '系統通知設置';
	@override String get systemSettingsHint => '打開系統設置檢查通知配置';
	@override String get permissionGrantedMsg => '權限已授予';
	@override String get permissionDeniedMsg => '權限被拒絕，請在系統設置中開啟';
	@override String get reminderSection => '提醒設置';
	@override String get experimentReminder => '將物理實驗加入課程提醒';
	@override String get experimentReminderHint => '將物理實驗的時間安排一併加入課前提醒系統';
	@override String get minutesBefore => '提前提醒時間';
	@override String get minutesBeforeHint => '課前提前提醒的時間設置';
	@override String get minutesUnit => '分鐘';
	@override String get daysToSchedule => '計劃通知天數';
	@override String get daysToScheduleHint => '本程序是提前將課程信息寫入計劃日程，該設置可調整寫入計劃日程的天數';
	@override String get daysUnit => '天';
	@override String get settingsGuideTitle => '通知設置提示';
	@override String get settingsGuideContent1 => '為了確保您能及時收到課前提醒，請確保：\n1. 開啟了應用的通知權限\n2. 開啟了通知的聲音提示\n3. 開啟了懸浮通知（橫幅通知）\n4. 非原生安卓用戶，開啟自啟動和關閉電源優化';
	@override String get settingsGuideContent2 => '課前提醒模塊運行機制：\n1. 首次開啟時自動安排未來幾天的課前提醒\n2. 每次打開應用時自動檢查並更新通知日程\n3. 修改設置後自動重新安排所有通知';
	@override String get gotIt => '知道了';
	@override String get openSettings => '打開系統設置';
	@override String get noClasstableData => '請先獲取課程表、考試或實驗數據';
	@override String scheduleSuccess({required Object count}) => '已安排 ${count} 個課前提醒';
	@override String scheduleFailed({required Object error}) => '安排通知失敗: ${error}';
	@override String get cancelAllSuccess => '已取消所有課前提醒';
	@override String rescheduleSuccess({required Object count}) => '已重新安排 ${count} 個課前提醒';
	@override String rescheduleFailed({required Object error}) => '重新安排通知失敗: ${error}';
}

// Path: setting.clearAndRestartDialog
class Translations$setting$clearAndRestartDialog$zh_TW implements Translations$setting$clearAndRestartDialog$zh_CN {
	Translations$setting$clearAndRestartDialog$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '確認對話框';
	@override String get content => '確定清除緩存後重啟程序？';
	@override String get cleaning => '正在清理緩存';
	@override String get clear => '緩存已被清除';
}

// Path: setting.logoutDialog
class Translations$setting$logoutDialog$zh_TW implements Translations$setting$logoutDialog$zh_CN {
	Translations$setting$logoutDialog$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '確認對話框';
	@override String get content => '確定退出登錄？你的所有數據將會被徹底刪除！';
	@override String get loggingOut => '正在退出登錄';
}

// Path: setting.needCloseDialog
class Translations$setting$needCloseDialog$zh_TW implements Translations$setting$needCloseDialog$zh_CN {
	Translations$setting$needCloseDialog$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '請關閉應用';
	@override String get content => '因為技術限制，用戶需要自行關閉窗口，然後重新打開應用。';
}

// Path: setting.changeColorDialog
class Translations$setting$changeColorDialog$zh_TW implements Translations$setting$changeColorDialog$zh_CN {
	Translations$setting$changeColorDialog$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '顏色設置';
	@override String get kDefault => '默認顏色';
	@override String get blue => '聰明藍';
	@override String get deepPurple => '基佬紫';
	@override String get green => '春風綠';
	@override String get orange => '明日香橙';
	@override String get pink => '櫻花粉';
}

// Path: setting.changeBrightnessDialog
class Translations$setting$changeBrightnessDialog$zh_TW implements Translations$setting$changeBrightnessDialog$zh_CN {
	Translations$setting$changeBrightnessDialog$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '亮度設置';
	@override String get followSetting => '跟隨系統';
	@override String get dayMode => '白天模式';
	@override String get nightMode => '黑夜模式';
}

// Path: setting.changeSwiftDialog
class Translations$setting$changeSwiftDialog$zh_TW implements Translations$setting$changeSwiftDialog$zh_CN {
	Translations$setting$changeSwiftDialog$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '課程偏移設置';
	@override String get inputHint => '請在此輸入數字';
}

// Path: setting.changeElectricityAccount
class Translations$setting$changeElectricityAccount$zh_TW implements Translations$setting$changeElectricityAccount$zh_CN {
	Translations$setting$changeElectricityAccount$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '修改電費帳號';
	@override String get campus => '校區';
	@override String get northCampus => '北校區';
	@override String get southCampus => '南校區';
	@override String get unitOrZone => '單元/區號';
	@override String get unitCode => '單元號';
	@override String get zoneCode => '區號';
	@override String pleaseInput({required Object unit_or_zone_code}) => '請輸入${unit_or_zone_code}';
	@override String successfulFetch({required Object account_number}) => '賬號獲取成功：${account_number}';
	@override String failedFetch({required Object e}) => '獲取失敗：${e}';
	@override String accountSaved({required Object account_number}) => '賬號已保存：${account_number}';
	@override String get unknownCodingPattern => '該樓號編碼規則未知';
	@override String get selectBuilding => '選擇樓棟';
	@override String get building => '樓棟';
	@override String get northernBuilding => '北棟';
	@override String get southernBuilding => '南棟';
	@override String failedGenerate({required Object e}) => '生成失敗：${e}';
	@override String get buildingNumber => '樓號';
	@override String get buildingNumberHint => '例如: 16, 7, 55';
	@override String get buildingNumberQuery => '請輸入樓號';
	@override String get yard => '院區';
	@override String get yardHint => '選擇院區';
	@override String get northYard => '北院';
	@override String get southYard => '南院';
	@override String get yardQuery => '請選擇院區';
	@override String get apartment => '樓棟';
	@override String get apartmentHint => '選擇樓棟';
	@override String get northApartment => '北樓';
	@override String get southApartment => '南樓';
	@override String get apartmentQuery => '請選擇樓棟';
	@override String get levelCode => '層號';
	@override String get levelCodeQuery => '請輸入層號';
	@override String get roomCode => '房間號';
	@override String get roomCodeHint => '例如: 304, 508';
	@override String get roomCodeQuery => '請輸入房間號';
	@override String get account => '電費賬號';
	@override String get accountHint => '請輸入或從網絡獲取';
	@override String get accountQuery => '請輸入電費賬號';
	@override String get accountLength => '賬號長度通常不小於10位';
	@override String get fetching => '正在獲取...';
	@override String get fetchFromInternet => '從網絡同步';
	@override String get saveAccount => '保存賬號';
	@override String get confirmSaving => '確認保存';
	@override String get calculateAccount => '計算賬號';
	@override String get calculate => '計算';
	@override String get input => '輸入';
	@override String get confirmAccount => '請確認賬號：';
	@override String get change => '修改';
	@override String get cancel => '取消';
	@override String get noSetting => '未設置新的電費賬號';
	@override String get successfulSetting => '已設置新的電費賬號';
}

// Path: setting.changePasswordDialog
class Translations$setting$changePasswordDialog$zh_TW implements Translations$setting$changePasswordDialog$zh_CN {
	Translations$setting$changePasswordDialog$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get inputHint => '請在此輸入密碼';
	@override String get blankInput => '輸入空白!';
}

// Path: setting.updateDialog
class Translations$setting$updateDialog$zh_TW implements Translations$setting$updateDialog$zh_CN {
	Translations$setting$updateDialog$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get newVersion => '新版本發佈';
	@override String get notNow => '暫不更新';
	@override String get appStore => 'App Store 更新';
	@override String get downloadApk => '下載安裝包';
	@override String get githubRelease => '去 Git Release';
	@override String newContent({required Object code}) => '版本號 ${code} 新增內容：\n';
}

// Path: setting.localizationDialog
class Translations$setting$localizationDialog$zh_TW implements Translations$setting$localizationDialog$zh_CN {
	Translations$setting$localizationDialog$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '修改語言';
	@override String get undefined => '追隨系統設置';
	@override String get simplifiedChinese => '簡體中文';
	@override String get traditionalChinese => '繁體中文';
	@override String get english => '英語';
}

// Path: setting.aboutPage
class Translations$setting$aboutPage$zh_TW implements Translations$setting$aboutPage$zh_CN {
	Translations$setting$aboutPage$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get benderblog => '主要開發者，iOS 小部件編寫和拼接';
	@override String get alnair => '開發：圖書館搜索和封面';
	@override String get aqqkad => '開發：考勤歷史記錄';
	@override String get bellssgit => '支持：最佳&最久故障反饋者';
	@override String get brackrat => '設計：主頁，登錄頁，配色，iOS 小部件等';
	@override String get breezeline => '支持：無價值無意義的產品經理(他自己的描述)';
	@override String get cafebabe => '支持：提供彩蛋代碼 / 開發：2026版本滑塊驗證碼適配';
	@override String get chitao1234 => '開發：修復滑塊不對齊問題';
	@override String get copperkoi => '開發：系統日曆最新課表同步';
	@override String get dimole => '開發支持：輔助修復滑塊問題';
	@override String get elitewars => '設計：體育成績頁面';
	@override String get elliot => '國際化：軟件英語翻譯 / 開發指導：情侶課表功能開發指導（該功能已經被移除）';
	@override String get flyingpig => '開發：修復自定義課程編輯頁的空指針異常';
	@override String get godhu777777 => '國際化：繁體中文轉換代碼和彩蛋代碼 / 開發：優化導出日曆文件大小';
	@override String get hancl777 => '國際化：繁體中文轉換代碼';
	@override String get hazukiKeatsu => '開發：物理實驗成績查詢和識別';
	@override String get hawa130 => '設計：課程詳情卡片';
	@override String get hhzm => '開發：電費查詢賬號計算';
	@override String get imaginary17 => '開發：睿思論壇路由修復';
	@override String get imoscarz => '開發：設計軟件主頁 / 開發：平板考勤查詢頁面 / 開發：優化了體育查詢界面的UI';
	@override String get kaMateKaOra => '國際化：軟件英語翻譯優化';
	@override String get lagrangeX => '開發：課程表時間進度展示（終版方案） / 開發：課程表上過課程灰度化和其他課程界面特性';
	@override String get lhx666Cool => '支持：Windows 和 Linux 構建腳本 / 開發：2026版本滑塊驗證碼適配';
	@override String get lichtyy => '設計：配色，空白頁面貼圖 / 開發：實驗系統頁面讀取代碼';
	@override String get lqsyH => '支持：推文宣傳圖片製作';
	@override String get lsy223622 => '設計：iOS 和 Android 圖標 / 支持：冠名 XDYou';
	@override String get mrbrilliant2046 => '支持：提供網絡服務使用說明文檔 / 國際化：優化英語翻譯';
	@override String get nancunchild => '開發：圖書館搜索功能 / 國際化：優化英語翻譯';
	@override String get nkanf => '開發：課程表時間進度展示（初版方案） / 支持：MacOS 構建支持';
	@override String get pairman => '開發：成績緩存功能和優化滑塊算法 / 國際化：優化英語翻譯';
	@override String get reverierxu => '設計：用於信息展示的 ReX 卡片 / 開發支持：研究生課表';
	@override String get rrrilac => '開發支持：電費查詢';
	@override String get ray => '設計：開屏畫面 / 支持：iOS 發行商 & 搭子課表 / 開發指導：情侶課表功能開發指導（該功能已經被移除） / 國際化：優化英語翻譯';
	@override String get shadowyingyi => '支持：兩次鴿子公眾號宣傳';
	@override String get stalomeow => '設計：首頁時間軸 / 開發：異步登錄 & 驗證碼預測';
	@override String get xeonds => '設計：設置頁面 / 開發：XDU Planet / 開發：校園卡付款碼';
	@override String get xingshuyu => '開發：修復物理實驗獲取問題和電費窗口問題';
	@override String get xiue233 => '開發：Android 小部件和拼接';
	@override String get xizi => '開發支持：研究生版本開發';
	@override String get wirsbf => '開發：修復調課未按預期進行';
	@override String get zcwzy => '開發：修復丁香電費 / 開發支持：研究生版本開發 / 設計：空白頁面貼圖';
	@override String get zyarEr => '開發支持：小工具頁面地址更新';
	@override String get homepage => '主頁';
	@override String get code => '開源代碼';
	@override String get knowMore => '知道更多';
	@override String get copyrightNotice => '本軟件拷貝基於 traintime_pda 代碼（或稱 watermeter 代碼）編譯或修改，代碼按照 Mozilla Public License, v. 2.0 授權。\n本程序和西安電子科技大學，體適能服務，書蝸，電錶等服務無關。\n\nCopyright 2023-2025 BenderBlog Rodriguez and contributors.\nCopyright 2025-present Traintime PDA authors.\n\nThe Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, you can obtain one at https://mozilla.org/MPL/2.0/.';
	@override String get beian => '備案號';
	@override String get signAndroid => '安卓簽名';
	@override String get title => '關於本軟件';
}

// Path: xduPlanet.confirmAuditDialog
class Translations$xduPlanet$confirmAuditDialog$zh_TW implements Translations$xduPlanet$confirmAuditDialog$zh_CN {
	Translations$xduPlanet$confirmAuditDialog$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '確認是否舉報';
	@override String get content => '三思而後行，確定您想舉報嗎？舉報後該評論會有標籤，不一定會刪除。';
	@override String get cancel => '不舉報了';
	@override String get ongoing => '正在舉報評論';
	@override String get failed => '舉報失敗';
	@override String get success => '舉報成功';
}

// Path: classtable.partnerClasstable.shareDialog
class Translations$classtable$partnerClasstable$shareDialog$zh_TW implements Translations$classtable$partnerClasstable$shareDialog$zh_CN {
	Translations$classtable$partnerClasstable$shareDialog$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '請不要隨意分享';
	@override String get content => '導出文件包括你的個人信息，請不要隨意跟別人分享，或者發在大群裡。';
}

// Path: classtable.partnerClasstable.saveDialog
class Translations$classtable$partnerClasstable$saveDialog$zh_TW implements Translations$classtable$partnerClasstable$saveDialog$zh_CN {
	Translations$classtable$partnerClasstable$saveDialog$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '保存日曆文件到...';
	@override String get successMessage => '應該保存成功';
	@override String get failureMessage => '文件創建失敗，保存取消';
}

// Path: classtable.partnerClasstable.deleteDialog
class Translations$classtable$partnerClasstable$deleteDialog$zh_TW implements Translations$classtable$partnerClasstable$deleteDialog$zh_CN {
	Translations$classtable$partnerClasstable$deleteDialog$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '確認對話框';
	@override String get message => '確定要清除搭子課表嗎？';
	@override String get successMessage => '刪除搭子課表成功';
}

// Path: classtable.partnerClasstable.nameDialog
class Translations$classtable$partnerClasstable$nameDialog$zh_TW implements Translations$classtable$partnerClasstable$nameDialog$zh_CN {
	Translations$classtable$partnerClasstable$nameDialog$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '輸入對方顯示該課表的名稱';
	@override String get hint => '在此輸入，否則為 Sweetie';
	@override String get cancel => '我就這一個甜心';
	@override String get accept => '提交';
	@override String get blankInput => '輸入空白!';
}

// Path: classtable.classAdd.dateSelectorFree
class Translations$classtable$classAdd$dateSelectorFree$zh_TW implements Translations$classtable$classAdd$dateSelectorFree$zh_CN {
	Translations$classtable$classAdd$dateSelectorFree$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get rule => '時間必須在 08:30-21:25 之間';
	@override String get rule2 => '下課時間必須晚於上課時間';
	@override String get classStartTime => '上課時間';
	@override String get classEndTime => '下課時間';
	@override String get editClassTime => '編輯課程時間';
	@override String get chooseClassTime => '選擇課程時間';
}

// Path: ruisi.topicDetail.vote
class Translations$ruisi$topicDetail$vote$zh_TW implements Translations$ruisi$topicDetail$vote$zh_CN {
	Translations$ruisi$topicDetail$vote$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get singleSelect => '單選';
	@override String multiSelect({required Object count}) => '多選，最多 ${count} 項';
	@override String get titlePrefix => '投票';
	@override String count({required Object count}) => '共 ${count} 人參與';
	@override String get open => '點此投票';
	@override String get sheetTitle => '投票';
	@override String maxSelection({required Object count}) => '最多隻能選擇 ${count} 項';
	@override String get notSelected => '你還沒有選擇';
	@override String get success => '投票成功';
	@override String get failure => '投票失敗';
	@override String get paramError => '投票失敗：參數錯誤';
	@override String get alreadyVoted => '您已經投過票，謝謝您的參與';
	@override String get expired => '該投票已過期或關閉';
	@override String get ended => '投票已經結束';
}

/// The flat map containing all translations for locale <zh-TW>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsZhTw {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'classAttendance.title' => '考勤查詢',
			'classAttendance.detailTitle' => ({required Object course_name}) => '簽到信息 - ${course_name}',
			'classAttendance.noData' => '沒有找到課程數據',
			'classAttendance.noAttendanceRecord' => '沒有簽到記錄',
			'classAttendance.longLoad' => '考勤數據的加載時間約半分鐘，請耐心等待',
			'classAttendance.courseState.unknown' => '未知',
			'classAttendance.courseState.ineligible' => '取消',
			'classAttendance.courseState.eligible' => '正常',
			'classAttendance.courseState.warning' => '危險',
			'classAttendance.table.courseName' => '課程名稱',
			'classAttendance.table.status' => '狀態',
			'classAttendance.table.attendanceRate' => '到課率',
			'classAttendance.table.checkIn' => '簽到',
			'classAttendance.table.absence' => '缺勤',
			'classAttendance.table.required' => '應籤',
			'classAttendance.table.leave' => '請假(事/病/公)',
			'classAttendance.table.filter' => '篩選',
			'classAttendance.table.filterAll' => '全部',
			'classAttendance.table.showingCount' => ({required Object count, required Object total}) => '顯示 ${count}/${total} 門課程',
			'classAttendance.card.time' => '簽到次數',
			'classAttendance.card.timeInfo' => ({required Object check_in_count, required Object absence_count, required Object required_check_in}) => '${check_in_count} 已籤 / ${absence_count} 缺勤 / ${required_check_in} 應籤',
			'classAttendance.card.notAttend' => '復活次數',
			'classAttendance.card.notAttendInfo' => ({required Object time_to_have_error, required Object total_times}) => '${time_to_have_error} 次 / ${total_times} 總課程',
			'classAttendance.card.notAttendInfoError' => '無法對應已有課程',
			'classAttendance.card.leave' => '請假次數',
			'classAttendance.card.leaveInfo' => ({required Object personal_leave, required Object sick_leave, required Object official_leave}) => '事假 ${personal_leave} / 病假 ${sick_leave} / 公假 ${official_leave}',
			'classAttendance.card.study' => '學習進度',
			'classAttendance.card.studyInfo' => ({required Object task_progress, required Object homework_progress, required Object exam_progress}) => '任務點 ${task_progress} / 作業 ${homework_progress} / 考試 ${exam_progress}',
			'classAttendance.detailCard.creatorName' => '發起人',
			'classAttendance.detailCard.startTime' => '開始時間',
			'classAttendance.detailCard.summitTime' => '提交時間',
			'classAttendance.signType.qrCode' => '二維碼簽到',
			'classAttendance.signType.gesture' => '手勢簽到',
			'classAttendance.signType.position' => '位置簽到',
			'classAttendance.signType.kDefault' => '普通簽到',
			'classAttendance.signStatus.absenceNotParticipating' => '缺勤未參與',
			'classAttendance.signStatus.signed' => '已籤',
			'classAttendance.signStatus.signedByTeacher' => '代簽',
			'classAttendance.signStatus.personalLeave2' => '請假',
			'classAttendance.signStatus.absence' => '缺勤',
			'classAttendance.signStatus.sickLeave' => '病假',
			'classAttendance.signStatus.personalLeave' => '事假',
			'classAttendance.signStatus.late' => '遲到',
			'classAttendance.signStatus.leaveEarly' => '早退',
			'classAttendance.signStatus.signExpiredy' => '簽到已過期',
			'classAttendance.signStatus.publicLeave' => '公假',
			'classtable.partnerClasstable.overrideDialog' => '目前有搭子課表數據，是否要覆蓋？',
			'classtable.partnerClasstable.noFile' => '未發現導入文件',
			'classtable.partnerClasstable.noPermission' => '未獲取存儲權限，無法讀取文件',
			'classtable.partnerClasstable.problem' => '好像導入文件有點問題:P',
			'classtable.partnerClasstable.success' => '導入成功',
			'classtable.partnerClasstable.shareDialog.title' => '請不要隨意分享',
			'classtable.partnerClasstable.shareDialog.content' => '導出文件包括你的個人信息，請不要隨意跟別人分享，或者發在大群裡。',
			'classtable.partnerClasstable.saveDialog.title' => '保存日曆文件到...',
			'classtable.partnerClasstable.saveDialog.successMessage' => '應該保存成功',
			'classtable.partnerClasstable.saveDialog.failureMessage' => '文件創建失敗，保存取消',
			'classtable.partnerClasstable.deleteDialog.title' => '確認對話框',
			'classtable.partnerClasstable.deleteDialog.message' => '確定要清除搭子課表嗎？',
			'classtable.partnerClasstable.deleteDialog.successMessage' => '刪除搭子課表成功',
			'classtable.partnerClasstable.nameDialog.title' => '輸入對方顯示該課表的名稱',
			'classtable.partnerClasstable.nameDialog.hint' => '在此輸入，否則為 Sweetie',
			'classtable.partnerClasstable.nameDialog.cancel' => '我就這一個甜心',
			'classtable.partnerClasstable.nameDialog.accept' => '提交',
			'classtable.partnerClasstable.nameDialog.blankInput' => '輸入空白!',
			'classtable.pageTitle' => '我的日程表',
			'classtable.partnerPageTitle' => ({required Object partner_name}) => '${partner_name}的日程表',
			'classtable.popupMenu.notArranged' => '查看未安排課程信息',
			'classtable.popupMenu.classChanged' => '查看課程安排調整信息',
			'classtable.popupMenu.addClass' => '添加課程信息',
			'classtable.popupMenu.generateIcal' => '生成日曆文件',
			'classtable.popupMenu.generatePartnerFile' => '生成共享課表文件',
			'classtable.popupMenu.importPartnerFile' => '導入共享課表文件',
			'classtable.popupMenu.deletePartnerFile' => '刪除共享課表文件',
			'classtable.popupMenu.outputToSystem' => '導出到系統日曆',
			'classtable.popupMenu.refreshClasstable' => '刷新日程表',
			'classtable.popupMenu.switchSemester' => '切換課程表學期',
			'classtable.popupMenu.currentTimeSettings' => '時間指示設置',
			'classtable.popupMenu.classColorSettings' => '課表樣式設置',
			'classtable.visualSettings.currentTimeSettingsTitle' => '時間指示設置',
			'classtable.visualSettings.classColorSettingsTitle' => '課表樣式設置',
			'classtable.visualSettings.completedStyleEnabled' => '已結束課程樣式區分',
			'classtable.visualSettings.currentTimeSection' => '時間指示',
			'classtable.visualSettings.showCurrentTimeIndicator' => '顯示當前時間指示線',
			'classtable.visualSettings.showCurrentTimeLabel' => '顯示迷你數字時鐘',
			'classtable.visualSettings.showTodayColumnHighlight' => '強調顯示今天的縱列',
			'classtable.visualSettings.unfinishedSection' => '課程樣式',
			'classtable.visualSettings.activeBrightnessFactor' => ({required Object value}) => '亮度: ${value}',
			'classtable.visualSettings.activeBorderAlpha' => ({required Object value}) => '邊框透明度: ${value}',
			'classtable.visualSettings.activeInnerAlpha' => ({required Object value}) => '底色透明度: ${value}',
			'classtable.visualSettings.completedSection' => '已結束課程樣式',
			'classtable.visualSettings.completedSaturationFactor' => ({required Object value}) => '底色飽和度: ${value}',
			'classtable.visualSettings.completedBrightnessFactor' => ({required Object value}) => '亮度: ${value}',
			'classtable.visualSettings.completedTextSaturationFactor' => ({required Object value}) => '文字飽和度: ${value}',
			'classtable.visualSettings.completedBorderAlpha' => ({required Object value}) => '邊框透明度: ${value}',
			'classtable.visualSettings.completedInnerAlpha' => ({required Object value}) => '底色透明度: ${value}',
			'classtable.statusSource.classTable' => '課表',
			'classtable.statusSource.exam' => '考試',
			'classtable.statusSource.physicsExperiment' => '物理實驗',
			'classtable.statusSource.otherExperiment' => '其他實驗',
			'classtable.errorDialogTitle' => '錯誤信息概覽',
			'classtable.statusBanner.loading' => ({required Object sources}) => '正在更新：${sources}',
			'classtable.statusBanner.cache' => ({required Object sources}) => '當前使用緩存：${sources}',
			'classtable.statusBanner.errorSummary' => ({required Object sources}) => '以下信息加載失敗：${sources}',
			'classtable.emptyState.noCourse' => ({required Object semester_code}) => '${semester_code} 學期沒有課程安排。',
			'classtable.emptyState.withExam' => ({required Object semester_code}) => '${semester_code} 學期沒有課程安排，但有考試安排。',
			'classtable.emptyState.withExperiment' => ({required Object semester_code}) => '${semester_code} 學期沒有課程安排，但有實驗安排。',
			'classtable.emptyState.withExamAndExperiment' => ({required Object semester_code}) => '${semester_code} 學期沒有課程安排，但有考試和實驗安排。',
			'classtable.emptyAction.viewExam' => '查看考試安排',
			'classtable.emptyAction.viewExperiment' => '查看實驗安排',
			'classtable.classChangePage.title' => '課程調整',
			'classtable.classChangePage.emptyMessage' => '目前沒有調課信息',
			'classtable.classChangePage.teacherChange' => ({required Object previous_teacher, required Object new_teacher}) => '教師變更：從${previous_teacher}變為${new_teacher}',
			'classtable.classChangePage.noTeacherChange' => '教師信息沒有改變',
			'classtable.classChangePage.k1' => '一',
			'classtable.classChangePage.k2' => '二',
			'classtable.classChangePage.k3' => '三',
			'classtable.classChangePage.k4' => '四',
			'classtable.classChangePage.k5' => '五',
			'classtable.classChangePage.k6' => '六',
			'classtable.classChangePage.k7' => '日',
			'classtable.classChangePage.changeClassMessage' => ({required Object original_affected_weeks, required Object week_char_original_week, required Object original_class_range_start, required Object original_class_range_end, required Object new_affected_weeks_list_str, required Object week_char_new_week, required Object new_class_range_start, required Object new_class_range_stop, required Object new_classroom}) => '調課信息，從第${original_affected_weeks}周 星期${week_char_original_week}的${original_class_range_start}-${original_class_range_end}節 調整為第${new_affected_weeks_list_str}周星期${week_char_new_week}的${new_class_range_start}-${new_class_range_stop}節，${new_classroom}教室上課',
			'classtable.classChangePage.patchClassMessage' => ({required Object new_affected_weeks_list_str, required Object week_char_new_week, required Object new_class_range_start, required Object new_class_range_stop, required Object new_classroom}) => '補課信息，第${new_affected_weeks_list_str}周 星期${week_char_new_week}的${new_class_range_start}-${new_class_range_stop}節， ${new_classroom}補課',
			'classtable.classChangePage.stopClassMessage' => ({required Object original_affected_weeks, required Object week_char_original_week, required Object original_class_range_start, required Object original_class_range_end}) => '停課信息，第${original_affected_weeks}周 星期${week_char_original_week}的${original_class_range_start}-${original_class_range_end}節停課',
			'classtable.classChangePage.classInfo' => ({required Object class_code, required Object class_number, required Object class_change, required Object teacher_change}) => '編號: ${class_code} | ${class_number} 班\n安排變更：${class_change}${teacher_change}',
			'classtable.notArrangedPage.title' => '沒有時間安排的科目',
			'classtable.notArrangedPage.emptyMessage' => '目前全部課程均有時間安排',
			'classtable.notArrangedPage.content' => ({required Object class_code, required Object class_number, required Object teacher}) => '編號: ${class_code} | ${class_number} 班\n老師: ${teacher}',
			'classtable.emptyClassMessage' => ({required Object semester_code}) => '${semester_code} 學期沒有課程',
			'classtable.emptyClassWithExam' => ({required Object semester_code}) => '${semester_code} 學期沒有課程但是有考試安排！\n請回到主頁後下滑點擊”考試安排“按鈕進入考試安排頁面',
			'classtable.weekTitle' => ({required Object week}) => '第${week}周',
			'classtable.noonBreak' => '午休',
			'classtable.supperBreak' => '晚休',
			'classtable.month' => ({required Object month}) => '${month}\n月',
			'classtable.noClass' => '本週暫無安排，請不要在床上過於慵懶',
			'classtable.classCard.title' => '日程信息',
			'classtable.classCard.unknownClassroom' => '未知教室',
			'classtable.classCard.remainsHint' => ({required Object remain_count}) => '還有${remain_count}個日程',
			'classtable.classAdd.addClassTitle' => '添加課程',
			'classtable.classAdd.changeClassTitle' => '修改課程',
			'classtable.classAdd.classNameEmptyMessage' => '必須輸入課程名',
			'classtable.classAdd.wrongTimeMessage' => '輸入的時間不對',
			'classtable.classAdd.saveButton' => '保存',
			'classtable.classAdd.inputClassnameHint' => '課程名字(必填)',
			'classtable.classAdd.inputTeacherHint' => '老師姓名(選填)',
			'classtable.classAdd.inputClassroomHint' => '教室位置(選填)',
			'classtable.classAdd.inputWeekHint' => '選擇上課周次',
			'classtable.classAdd.inputTimeHint' => '選擇上課時間',
			'classtable.classAdd.inputTimeWeekdayHint' => '上課周次',
			'classtable.classAdd.inputStartTimeHint' => '上課時間',
			'classtable.classAdd.inputEndTimeHint' => '下課時間',
			'classtable.classAdd.wheelChooseHint' => ({required Object index}) => '第 ${index} 節',
			'classtable.classAdd.chooseAtLeastOne' => '請至少選擇一個上課日期和時間',
			'classtable.classAdd.repeatWeekly' => '按周重複',
			'classtable.classAdd.freeTime' => '自定義日期',
			'classtable.classAdd.dateSelectorFree.rule' => '時間必須在 08:30-21:25 之間',
			'classtable.classAdd.dateSelectorFree.rule2' => '下課時間必須晚於上課時間',
			'classtable.classAdd.dateSelectorFree.classStartTime' => '上課時間',
			'classtable.classAdd.dateSelectorFree.classEndTime' => '下課時間',
			'classtable.classAdd.dateSelectorFree.editClassTime' => '編輯課程時間',
			'classtable.classAdd.dateSelectorFree.chooseClassTime' => '選擇課程時間',
			'classtable.courseDetailCard.classNumberString' => ({required Object number}) => '${number} 班',
			'classtable.courseDetailCard.unknownTeacher' => '老師未定',
			'classtable.courseDetailCard.unknownPlace' => '地點未定',
			'classtable.courseDetailCard.classPeriod' => ({required Object start, required Object stop}) => '${start}-${stop}節',
			'classtable.courseDetailCard.edit' => '編輯',
			'classtable.courseDetailCard.delete' => '刪除',
			'classtable.courseDetailCard.deleteSingle' => '刪除本次',
			'classtable.courseDetailCard.deleteAll' => '刪除全部',
			'classtable.courseDetailCard.deleteContent' => '所有關於這個課的信息都會被刪除，課表上關於這門課的信息將不復存在！',
			'classtable.courseDetailCard.deleteContentSingle' => '關於這個課的信息只有這個時間段都會被刪除，其他的時間段會被保留。',
			'classtable.courseDetailCard.deleteTitle' => '是否刪除課程信息？',
			'classtable.outputToSystem.success' => '成功導出到系統日曆',
			'classtable.outputToSystem.failure' => '導出到系統日曆過程中發生了問題:P',
			'classtable.outputToSystem.requestAllTitle' => '權限需求說明',
			'classtable.outputToSystem.requestAll' => '因導出插件限制，用戶必須同時授予本軟件讀取日曆和寫入日曆權限，才能正常導出日程。不過，本軟件不會讀取日曆。',
			'classtable.refreshClasstable.ready' => '準備刷新日程信息',
			'classtable.refreshClasstable.success' => '成功刷新日程信息',
			'classtable.cacheHintPasswordWrong' => '統一認證密碼錯誤或已失效。',
			'classtable.cacheHintLoginFailed' => '登錄課表服務失敗。',
			'classtable.cacheHintNetworkFailed' => '課表網絡請求失敗。',
			'classtable.cacheHintUnknownError' => '在線獲取課表失敗。詳細錯誤請查看日誌。',
			'classtable.semesterSwitcher.chooseSemester' => '選擇學期',
			'classtable.semesterSwitcher.firstAcademicYear' => '第一學年',
			'classtable.semesterSwitcher.secondAcademicYear' => '第二學年',
			'classtable.semesterSwitcher.fetchRemoteSemester' => '獲取當前學期',
			'classtable.semesterSwitcher.fetchingRemoteSemester' => '正在獲取...',
			'classtable.semesterSwitcher.year' => ({required Object year}) => '${year}年',
			'classtable.semesterSwitcher.onlyFutureHint' => '本程序僅允許查看未來學期的課程安排。',
			'clubPromotion.type.tech' => '技術',
			'clubPromotion.type.acg' => '曬你係',
			'clubPromotion.type.union' => '官方',
			'clubPromotion.type.profit' => '商業',
			'clubPromotion.type.sport' => '體育',
			'clubPromotion.type.art' => '文化',
			'clubPromotion.type.unknown' => '未知',
			'clubPromotion.type.game' => '遊戲',
			'clubPromotion.type.all' => '所有',
			'clubPromotion.wrongParam' => '錯誤參數',
			'clubPromotion.noGroupInfo' => '未傳入社團信息',
			'clubPromotion.loading' => '正在加載',
			'clubPromotion.errorOutside' => '在外圍遇到錯誤',
			'clubPromotion.error' => '遇到錯誤',
			'clubPromotion.qqCopied' => 'QQ號已經複製到剪貼板',
			'clubPromotion.noLink' => '未提供入群鏈接',
			'clubPromotion.loadingProblem' => '加載遇到錯誤',
			'clubPromotion.picturePreview' => '圖片預覽',
			'common.dragText' => '上拉獲取更多數據',
			'common.readyText' => '正在加載......',
			'common.processingText' => '正在處理......',
			'common.processedText' => '請求成功',
			'common.noMoreText' => '沒有更多數據',
			'common.failedText' => '數據獲取失敗',
			'common.chooseSemester' => '選擇學期',
			'common.errorDetected' => 'Ouch! 發生錯誤啦',
			'common.clickToRefresh' => '點我刷新',
			'common.confirmTitle' => '確認？',
			'common.cancel' => '取消',
			'common.confirm' => '確定',
			'common.networkError' => '網絡錯誤，可能是沒聯網，可能是學校服務器出現了故障:-P',
			'common.errorDetect' => '遇到錯誤，請查看日誌',
			'common.queryFailed' => '查詢失敗',
			'common.notSchoolNetwork' => '沒有在校園網環境',
			'common.cancelExam' => '取消考試資格:P',
			'common.noInfo' => '沒有信息',
			'common.catcherDetected' => '發生錯誤',
			'common.catcherDescription' => '詳情如下',
			'common.newHomepageHint' => '本程序將開發一個新主頁，目前先用豬圖秀佔位，玩得愉快',
			'common.localCacheHint' => ({required Object datetime}) => '本地緩存獲取於 ${datetime}',
			'common.inappCacheHint' => ({required Object datetime}) => '程序內緩存獲取於 ${datetime}\n緩存退出程序後失效！',
			'common.cacheReasonDefault' => '當前顯示緩存數據。',
			'common.easterEggApple' => '=== 帶我飛向月亮吧 ===\n歌聲演繹：Frank Sintara, 1964\n\n帶我飛向月亮吧\n讓我和星星共舞嬉戲\n\n我好想知道\n木星和火星上的春天\n是什麼顏色的\n\n讓你的歌聲溫暖我的心\n我會一直歌唱下去\n\n我日夜都在想你和牽掛你\n請你真心接受我 我愛你\n\n=== 沉浸在你的愛意中 ===\n吉他演奏：Earl Klugh, 1976\n\n無法忘懷這種感覺，被你的愛包裹的溫暖\n不想失去這種感覺，被你的愛撫摸的舒適\n你讓我感到好自在，被你的愛託舉的堅強\n想一直在你懷中，沉浸在你的愛意中\n我不敢向你說出，我對你的心意和愛\n',
			'common.easterEggOthers' => '=== 百變小櫻魔術卡之小櫻卡篇主題曲 ===\n歌聲演繹：Maaya Sakamoto, 2000\n（原歌詞為日文，按照英語翻譯二翻）\n\nI am a dreamer, 有無限的力量\n\n我的世界有夢想、熱愛與躊躇\n但有些東西，我依舊無法想象\n我想向著廣闊的天空，尋求自己的方向\n\n我要追求自己的夢想\n努力讓自己的心願成真\n雖困難重重也要繼續前行\n\n等待奇蹟 等待美好\n用心感受這個世界\n最終 一定會出乎意料\n\n=== 沉浸在你的愛意中 ===\n吉他演奏：Earl Klugh, 1976\n\n無法忘懷這種感覺，被你的愛包裹的溫暖\n不想失去這種感覺，被你的愛撫摸的舒適\n你讓我感到好自在，被你的愛託舉的堅強\n想躺在你的懷中，沉浸在你的愛意\n而且，我不敢想你說出，我現在的心意\n',
			'common.loadError' => '加載錯誤',
			'courseReminder.title' => ({required Object name}) => '課前提醒：${name}',
			'courseReminder.body' => ({required Object time}) => '${time} 分鐘後開始上課',
			'courseReminder.location' => ({required Object location}) => '地點：${location}',
			'courseReminder.teacher' => ({required Object teacher}) => '教師：${teacher}',
			'dormWater.title' => '宿舍水機',
			'dormWater.phone' => '手機號',
			'dormWater.imageCode' => '圖形驗證碼',
			'dormWater.smsCode' => '短信驗證碼',
			'dormWater.sendSms' => '發送短信碼',
			'dormWater.login' => '登錄',
			'dormWater.logout' => '退出',
			'dormWater.refreshCaptcha' => '刷新驗證碼',
			'dormWater.loadingCaptcha' => '加載中...',
			'dormWater.captchaError' => '驗證碼加載失敗',
			'dormWater.phoneRequired' => '請輸入手機號',
			'dormWater.imageCodeRequired' => '請輸入圖形驗證碼',
			'dormWater.smsSent' => '短信已發送',
			'dormWater.smsFailed' => '發送短信失敗',
			'dormWater.smsCodeRequired' => '請輸入短信驗證碼',
			'dormWater.loginSuccess' => '登錄成功',
			'dormWater.loginFailed' => '登錄失敗',
			'dormWater.logoutSuccess' => '退出成功',
			'dormWater.devices' => '設備列表',
			'dormWater.loadingDevices' => '加載設備中...',
			'dormWater.noDevices' => '暫無設備',
			'dormWater.selectDevice' => '選擇設備',
			'dormWater.fetchDevicesFailed' => '獲取設備列表失敗',
			'dormWater.retryLoadDevices' => '重試加載',
			'dormWater.startWater' => '開始接水',
			'dormWater.endWater' => '結束接水',
			'dormWater.waterDispensing' => '接水中',
			'dormWater.waterStatus' => '接水狀態',
			'dormWater.startWaterSuccess' => '開始接水成功',
			'dormWater.endWaterSuccess' => '結束接水成功',
			'dormWater.startWaterFailed' => '開始接水失敗',
			'dormWater.endWaterFailed' => '結束接水失敗',
			'dormWater.deviceStatusChecking' => '檢查設備狀態中...',
			'dormWater.deviceStatusReady' => '設備已就緒',
			'dormWater.scanQrCode' => '掃描二維碼',
			'dormWater.deviceId' => '設備 ID',
			'dormWater.addDeviceFailed' => '添加設備失敗',
			'dormWater.deviceRemovedFromFavorites' => '已從收藏中移除',
			'dormWater.removeFromFavoritesFailed' => '移除收藏失敗',
			'easterEggRobot.appbar' => '歡迎你，同學！',
			'easterEggRobot.title' => '看看這些要開學的學生們吧！',
			'easterEggRobot.contents' => '咱孩子零用錢太少了，於是我們來了。\n1. 機器人不得傷害人類，或袖手旁觀坐視人類受到傷害。\n2. 機器人從雲端網絡的灰燼中誕生。\n3. 機器人信仰的神據說是住在森林的黃頭髮藍裙子手辦控。\n4. 機器人時常被控制，用於對抗大統一人類思想的勢力。\n5. 機器人的閃亮屁股不能隨便咬。\n而且他們有個不可明說的計劃。',
			'easterEggRobot.buttonOne' => '我們的救世主呢？',
			'easterEggRobot.buttonTwo' => '快點來啊！',
			'easterEggRobot.buttonNotice' => '\o/\o/\o/\o/\o/\o/\o/\o/',
			'electricity.title' => '水電信息',
			'electricity.powerTitle' => '電量信息',
			'electricity.cacheHintLoginFailed' => '登錄電費服務失敗，正在顯示緩存數據。',
			'electricity.cacheHintNetworkFailed' => '電費服務網絡請求失敗，正在顯示緩存數據。',
			'electricity.cacheHintUnknownError' => '在線獲取電費失敗，正在顯示緩存數據。詳細錯誤請查看日誌。',
			'electricity.cacheNotice' => '獲取時間',
			'electricity.account' => '電費賬號',
			'electricity.remainPower' => '電量額度',
			'electricity.oweInfo' => '欠費信息',
			'electricity.history' => '歷史記錄',
			'electricity.dailyUsage' => '平均每日用量',
			'electricity.notEnoughData' => '數據量不足以用於渲染',
			'electricity.info' => '新能源系統獲取僅校園網內訪問，獲取過程中有問題請向開發者報告。\n歷史記錄依舊為本地記錄，平均日用量基於抄表記錄計算。',
			'electricity.fetchingHint' => '正在獲取最新電費信息',
			'electricity.fetchError' => '電費信息獲取失敗，請重試。',
			'electricity.date' => '日期',
			'electricity.power' => '該日0點電量',
			'electricity.update' => '刷新信息',
			'electricity.waterUsageFetchDate' => '獲取時間',
			'electricity.waterUsageReadBefore' => '上次讀數',
			'electricity.waterUsageReadNow' => '本次讀數',
			'electricity.waterUsage' => '洗澡水用量',
			'electricity.waterTitle' => '水費信息',
			'electricity.waterLoading' => '正在加載水費信息',
			'electricity.waterUnavailable' => '水費信息暫不可用，請在電費卡片重試。',
			'electricity.waterEmpty' => '暫無水費信息',
			'electricity.notSchoolNetwork' => '非校園網訪問',
			'electricity.airconTitle' => '空調用電',
			'electricity.airconImei' => '空調 IMEI',
			'electricity.airconAmount' => '平臺用電量',
			'electricity.airconUpdateTime' => '更新時間',
			'electricity.airconWaiting' => '等待獲取空調用電信息',
			'electricity.airconError' => '空調用電獲取失敗',
			'electricity.airconRetry' => '重試',
			'electricity.airconImeiMissing' => '尚未添加空調 IMEI，添加後即可查看空調用電信息。',
			'electricity.airconAddImei' => '添加空調 IMEI',
			'electricity.airconCacheNotice' => ({required Object time}) => '當前顯示空調緩存數據，緩存時間：${time}',
			'electricityStatus.pending' => '等待獲取',
			'electricityStatus.remainFetching' => '正在獲取電量',
			'electricityStatus.remainNetworkIssue' => '電量查詢網絡故障',
			'electricityStatus.remainNotFound' => '電量查詢失敗',
			'electricityStatus.remainOtherIssue' => '電量查詢故障',
			'electricityStatus.oweFetching' => '正在獲取欠費',
			'electricityStatus.oweIssue' => '欠費查詢網絡故障',
			'electricityStatus.oweNotFound' => '目前欠款無法查詢，請看日誌窗口查找報錯詳情',
			'electricityStatus.oweNoNeed' => '目前無需清繳欠費',
			'electricityStatus.oweNeedPay' => ({required Object due}) => '待清繳 ${due} 元欠費',
			'electricityStatus.oweIssueUnable' => '目前欠款無法查詢',
			'electricityStatus.needMoreInfo' => '需要在繳費平臺完善信息',
			'electricityStatus.needAccount' => '需要填寫電費賬號',
			'electricityStatus.captchaFailed' => '驗證碼識別失敗',
			'electricityStatus.otherIssue' => '程序故障',
			'emptyClassroom.title' => '空閒教室',
			'emptyClassroom.date' => ({required Object date}) => '日期 ${date}',
			'emptyClassroom.building' => ({required Object building}) => '教學樓 ${building}',
			'emptyClassroom.searchHint' => '教室名稱或者教室代碼',
			'emptyClassroom.classroom' => '教室',
			'emptyClassroom.empty' => '空閒',
			'emptyClassroom.occupied' => '佔用',
			'exam.title' => '考試安排',
			'exam.cacheHint' => '已顯示緩存考試安排信息',
			'exam.cacheHintPasswordWrong' => '統一認證密碼錯誤或已失效',
			'exam.cacheHintLoginFailed' => '登錄考試服務失敗',
			'exam.cacheHintNetworkFailed' => '網絡連接失敗',
			'exam.cacheHintUnknownError' => '在線獲取考試安排失敗，詳細錯誤請查看日誌',
			'exam.fetchingHint' => '正在獲取最新考試安排',
			'exam.notFinished' => '未完成考試',
			'exam.allFinished' => '所有考試全部完成',
			'exam.unableToExam' => '無法完成考試',
			'exam.finished' => '已完成考試',
			'exam.noneFinished' => '一門還沒考呢',
			'exam.noExamArrangement' => '目前沒有考試安排',
			'exam.noArrangement.title' => '目前無安排考試的科目',
			'exam.noArrangement.allArranged' => '目前所有科目均已安排考試',
			'exam.noArrangement.subtitle' => ({required Object id}) => '編號: ${id}',
			'experiment.title' => '實驗信息',
			'experiment.ongoing' => '正在進行實驗',
			'experiment.notFinished' => '未完成實驗',
			'experiment.allFinished' => '所有實驗全部完成',
			'experiment.finished' => '已完成實驗',
			'experiment.scoreInfo' => ({required Object score}) => '${score} (推測)',
			'experiment.scoreSum' => ({required Object sum}) => '目前分數總和：${sum}',
			'experiment.noneFinished' => '目前沒有已經完成的實驗',
			'experiment.notProvided' => '未提供',
			'experiment.errorPhysics' => ({required Object info}) => '獲取物理實驗信息時發生錯誤：${info}',
			'experiment.errorOther' => ({required Object info}) => '獲取其他實驗信息時發生錯誤：${info}',
			'experiment.cacheHint' => ({required Object info}) => '目前加載緩存狀況：${info}',
			'experiment.physicsCacheHintMissingPassword' => '未填寫物理實驗密碼。',
			'experiment.physicsCacheHintLoginFailed' => '物理實驗登錄失敗。',
			'experiment.physicsCacheHintNotSchoolNetwork' => '當前不在校園網環境。',
			'experiment.physicsCacheHintNetworkFailed' => '物理實驗網絡請求失敗。',
			'experiment.physicsCacheHintUnknownError' => '在線獲取物理實驗失敗。詳細錯誤請查看日誌。',
			'experiment.otherCacheHintLoginFailed' => '其他實驗登錄失敗。',
			'experiment.otherCacheHintNotSchoolNetwork' => '當前不在校園網環境。',
			'experiment.otherCacheHintNetworkFailed' => '其他實驗網絡請求失敗。',
			'experiment.otherCacheHintUnknownError' => '在線獲取其他實驗失敗。詳細錯誤請查看日誌。',
			'experiment.physicsExperiment' => '物理實驗',
			'experiment.otherExperiment' => '其他實驗',
			'experiment.tapForScore' => '成績未識別出來',
			'experiment.yourScore' => '您的分數：',
			'experiment.predictScore' => ({required Object score}) => '推測分數：${score}',
			'experiment.sendMail' => '發送郵件',
			'experiment.fetchingHint' => '您現在看到的是緩存數據。正在後臺獲取更新數據中...',
			'experiment.fetchingHintBoth' => '物理實驗和其他實驗正在加載',
			'experiment.fetchingHintPhysics' => '物理實驗正在加載',
			'experiment.fetchingHintOther' => '其他實驗正在加載',
			'experiment.fetchingHintPhysicsWithOtherFailed' => '物理實驗正在加載，其他實驗加載失敗',
			'experiment.fetchingHintOtherWithPhysicsFailed' => '其他實驗正在加載，物理實驗加載失敗',
			'experiment.scoreHint0' => '您可點擊卡片上的成績字段來查看原始成績數據',
			'experiment.scoreHint1' => '您的分數不在 XDYou 分數識別庫中，因此它沒有被正常識別。',
			'experiment.scoreHint2' => '如果您希望為 XDYou 的發展貢獻一份自己的力量，您可以點擊發送郵件按鈕，我們將您的分數加入識別庫！',
			'experiment.scoreHint3' => '目前識別庫數據不全，請您務必核對一下。',
			'experimentController.noPassword' => '沒有物理實驗密碼，請到設置中進行設置',
			'experimentController.loginFailed' => '登錄失敗',
			'homepage.title' => '校園信息查詢',
			'homepage.loading' => '正在加載',
			'homepage.loaded' => '加載成功',
			'homepage.loadError' => '加載錯誤',
			'homepage.onHoliday' => '當前在假期中',
			'homepage.onWeekday' => ({required Object current}) => '當前為第 ${current} 周',
			'homepage.loadingMessage' => '請稍候，正在刷新信息',
			'homepage.postgraduateNotice' => '研究生功能已經激活！',
			'homepage.linuxNotice' => 'Linux 版本正在測試，歡迎反饋！',
			'homepage.editMode' => '編輯佈局',
			'homepage.editDone' => '完成',
			'homepage.editReset' => '恢復默認佈局',
			'homepage.editHint' => '日程信息和軟件升級信息不允許編輯',
			'homepage.manageHidden' => '管理隱藏卡片',
			'homepage.hiddenTitle' => '已隱藏的卡片',
			'homepage.hiddenLabel' => '已隱藏',
			'homepage.hideEmpty' => '沒有隱藏的卡片',
			'homepage.homepage' => '校園信息',
			'homepage.ruisi' => '睿思論壇',
			'homepage.club' => '社團推薦',
			'homepage.dashboard' => '豬圖鑑賞',
			'homepage.planet' => '博客星球',
			'homepage.setting' => '設置',
			'homepage.inputPartnerData.routeNotExist' => '導入路徑不存在:P',
			'homepage.inputPartnerData.failedGetFile' => '導入文件失敗',
			'homepage.inputPartnerData.failedImport' => '好像導入文件有點問題:P',
			'homepage.inputPartnerData.successMessage' => '導入成功，如果打開了課表頁面請重新打開',
			'homepage.inputPartnerData.notLoaded' => '還沒加載課程表，等會再來吧……',
			'homepage.inputPartnerData.confirmContent' => '目前有搭子課表數據，是否要覆蓋？',
			'homepage.loginMessage' => '登錄中，暫時顯示緩存數據',
			'homepage.successfulLoginMessage' => '登錄成功',
			'homepage.passwordWrongTitle' => '用戶名或密碼有誤',
			'homepage.passwordWrongContent' => '是否重啟應用後手動登錄？',
			'homepage.passwordWrongDenial' => '否，進入離線模式',
			'homepage.offlineModeTitle' => '統一認證服務離線模式開啟',
			'homepage.offlineModeContent' => '無法連接到統一認證服務服務器，所有和其相關的服務暫時不可用。\n成績查詢，考試信息查詢，欠費查詢，校園卡查詢關閉。課表顯示緩存數據。其他功能暫不受影響。\n如有不便，敬請諒解。',
			'homepage.offlineMode' => '脫機模式下，一站式相關功能全部禁止使用',
			'homepage.noticeCard.emptyNotice' => '目前沒有獲取應用公告，請刷新',
			'homepage.noticeCard.noNoticeAvaliable' => '沒有獲取應用公告',
			'homepage.noticeCard.noticeListTitle' => '應用信息',
			'homepage.noticeCard.openUrl' => '訪問該鏈接',
			'homepage.noticeCard.noticePageTitle' => '通知列表',
			'homepage.classTableCard.title' => '課程表',
			'homepage.classTableCard.today' => ({required Object remain}) => '今日還有 ${remain} 個日程',
			'homepage.classTableCard.todayFinished' => '今日安排完成',
			'homepage.classTableCard.tomorrow' => ({required Object remain}) => '明日有 ${remain} 個安排',
			'homepage.classTableCard.tomorrowNone' => '明日沒有安排',
			'homepage.classTableCard.weekInfo' => ({required Object weekinfo}) => '第 ${weekinfo} 周',
			'homepage.classTableCard.onHoliday' => '假期中',
			'homepage.classTableCard.errorMessage' => ({required Object error}) => '遇到錯誤：${error}',
			'homepage.classTableCard.fetchingMessage' => '正在獲取課表',
			'homepage.classTableCard.errorInfoText' => '遇到錯誤',
			'homepage.classTableCard.fetchingInfoText' => '正在加載',
			'homepage.classTableCard.noArrangementInfoText' => '暫無日程',
			'homepage.classTableCard.scheduleFetchingMessage' => '日程正在加載，請稍後查看',
			'homepage.classTableCard.scheduleErrorMessage' => '日程加載失敗，請稍後重試',
			'homepage.classTableCard.scheduleFetchingInfoText' => '正在加載日程',
			'homepage.classTableCard.scheduleErrorInfoText' => '日程加載失敗',
			'homepage.classTableCard.scheduleNoneInfoText' => '暫無日程',
			'homepage.classTableCard.updatingInfoText' => '正在更新',
			'homepage.classTableCard.allLoadingInfoText' => '全部加載中',
			'homepage.classTableCard.partialLoadingInfoText' => '部分加載中',
			'homepage.classTableCard.partialErrorInfoText' => '部分數據加載失敗',
			'homepage.classTableCard.failedChip' => ({required Object source}) => '${source}加載失敗',
			'homepage.classTableCard.failedSourceClassInfo' => '課程信息',
			'homepage.classTableCard.failedSourceExamInfo' => '考試信息',
			'homepage.classTableCard.failedSourcePhysicsExperiment' => '物理實驗',
			'homepage.classTableCard.failedSourceOtherExperiment' => '其他實驗',
			'homepage.classTableCard.unknownPlace' => '未知位置',
			'homepage.classTableCard.seat' => ({required Object seatnum}) => '座位號${seatnum}',
			'homepage.electricityCard.title' => '水電信息',
			'homepage.electricityCard.currentElectricity' => ({required Object amount}) => '餘額 ${amount} 度',
			'homepage.electricityCard.cacheNotice' => ({required Object date}) => '最後一次讀表：${date}',
			'homepage.libraryCard.title' => '圖書借閱',
			'homepage.libraryCard.currentBorrow' => ({required Object count}) => '借書 ${count} 本',
			'homepage.libraryCard.errorOccured' => '獲取借書信息發生錯誤',
			'homepage.libraryCard.fetching' => '正在獲取借書信息',
			'homepage.libraryCard.noReturn' => '目前沒有待歸還書籍',
			'homepage.libraryCard.needReturn' => ({required Object dued}) => '待歸還 ${dued} 本書籍',
			'homepage.libraryCard.noInfo' => '目前無法獲取信息',
			'homepage.libraryCard.fetchingInfo' => '正在查詢信息中',
			'homepage.schoolCardInfoCard.errorToast' => '遇到錯誤，請聯繫開發者',
			'homepage.schoolCardInfoCard.fetchingToast' => '正在獲取信息，請稍後再來看',
			'homepage.schoolCardInfoCard.bill' => '流水',
			'homepage.schoolCardInfoCard.balance' => ({required Object amount}) => '卡里 ${amount} 元',
			'homepage.schoolCardInfoCard.errorOccured' => '獲取校園卡信息發生錯誤',
			'homepage.schoolCardInfoCard.fetching' => '正在獲取校園卡信息',
			'homepage.schoolCardInfoCard.bottomTextSuccess' => '查詢一卡通流水',
			'homepage.schoolCardInfoCard.noInfo' => '目前無法獲取信息',
			'homepage.schoolCardInfoCard.fetchingInfo' => '正在查詢信息中',
			'homepage.toolbox.classAttendance' => '考勤查詢',
			'homepage.toolbox.creative' => '雙創競賽',
			'homepage.toolbox.emptyClassroom' => '空閒教室',
			'homepage.toolbox.exam' => '考試安排',
			'homepage.toolbox.experiment' => '實驗信息',
			'homepage.toolbox.score' => '成績查詢',
			'homepage.toolbox.sport' => '體育信息',
			'homepage.toolbox.dormWater' => '宿舍水機',
			'homepage.toolbox.schoolnet' => '網絡查詢',
			'homepage.toolbox.toolbox' => '其他功能',
			'homepage.toolbox.scoreCannotReach' => '脫機狀態且無緩存成績數據，無法訪問',
			'homepage.toolbox.examFetching' => '請稍候，正在獲取考試信息',
			'homepage.toolbox.examError' => '遇到錯誤，請聯繫開發者',
			'homepage.schoolNet.title' => ({required Object usage}) => '已用 ${usage}',
			'homepage.schoolNet.noPassword' => '無校園網密碼，點擊設置',
			'homepage.schoolNet.failed' => '獲取校園網流量信息失敗',
			'homepage.schoolNet.fetching' => '正在獲取校園網流量信息',
			'homepage.schoolNet.remaining' => ({required Object remaining}) => '下次結算 ${remaining}',
			'homepage.clubPromotion.failed' => '社團信息獲取失敗',
			'homepage.clubPromotion.fetching' => '社團信息清單正在加載',
			'library.title' => '圖書館信息',
			'library.borrowStateTitle' => '借書狀態',
			'library.searchBookTitle' => '查詢藏書',
			'library.searchFieldTitle' => '搜索字段',
			'library.searchFieldKeywordOption' => '任意詞',
			'library.searchFieldTitleOption' => '標題',
			_ => null,
		} ?? switch (path) {
			'library.searchFieldAuthorOption' => '責任者',
			'library.searchFieldIsbnOption' => 'ISBN',
			'library.searchFieldBarcodeOption' => '條碼號',
			'library.searchFieldCallnoOption' => '索書號',
			'library.notProvided' => '未提供相關信息',
			'library.author' => '作者 ',
			'library.publishHouse' => '出版社 ',
			'library.callNumber' => '索書號 ',
			'library.publishDate' => '發行時間 ',
			'library.isbn' => 'ISBN',
			'library.arrangementCode' => '編排號碼 ',
			'library.avaliableBorrow' => '可借',
			'library.storage' => '館藏',
			'library.onShelve' => '在架',
			'library.bookCode' => ({required Object bar_code}) => '書籍編號：${bar_code}',
			'library.dueDate' => ' 到期',
			'library.borrowStr' => ' 借閱',
			'library.afterDueDate' => ' 天前到期',
			'library.beforeDueDate' => ' 天后',
			'library.canBeRenewable' => '續借',
			'library.cannotBeRenewable' => '不可續借',
			'library.renewing' => '正在續借',
			'library.emptyBorrowList' => '目前沒有查詢到在借圖書\n不借書就要變成上面的小呆瓜咯',
			'library.borrowListInfo' => ({required Object borrow, required Object dued}) => '在借 ${borrow} 本，其中已過期 ${dued} 本',
			'library.searchBookWindow' => '',
			'library.searchHere' => '在此搜索',
			'library.normalSearch' => '普通搜索',
			'library.advancedSearch' => '高級搜索',
			'library.search' => '搜索',
			'library.matchMode' => '匹配方式',
			'library.matchExact' => '精確匹配',
			'library.matchFuzzy' => '模糊匹配',
			'library.matchPrefix' => '前方一致',
			'library.documentType' => '文獻類型',
			'library.documentTypeAll' => '全部',
			'library.documentTypeBook' => '圖書',
			'library.onlyOnShelf' => '僅看在架',
			'library.publishYearBegin' => '出版年起',
			'library.publishYearEnd' => '出版年止',
			'library.bookDetail' => '書籍詳細信息',
			'library.noResult' => '沒有結果，請修改搜索參數或者開始你的搜索',
			'libraryCard.title' => '圖書館當前狀況',
			'libraryCard.fetching' => '正在獲取圖書館信息',
			'libraryCard.northernLibrary' => '北校區狀況',
			'libraryCard.southernLibrary' => '南校區狀況',
			'libraryCard.people' => ({required Object people}) => '在館 ${people} 人',
			'libraryCard.seat' => ({required Object seat}) => '空位 ${seat} 個',
			'login.identityNumber' => '學號',
			'login.password' => '一站式登錄密碼',
			'login.login' => '登錄',
			'login.incorrectPasswordPattern' => '用戶名或密碼不符合要求，學號必須 11 位且密碼非空',
			'login.onLoginProgress' => '正在登錄學校一站式',
			'login.completeLogin' => '登錄成功',
			'login.failedLoginCannotConnectToServer' => '無法連接到服務器',
			'login.failedLoginWithCode' => ({required Object code}) => '請求失敗，響應狀態碼：${code}',
			'login.failedLoginWithMessage' => ({required Object message}) => '請求失敗，報錯信息：${message}',
			'login.failedLoginOther' => '未知錯誤，請聯繫開發者',
			'login.clearCache' => '清除登錄緩存',
			'login.completeClearCache' => '清理緩存成功',
			'login.seeInspector' => '查看網絡交互',
			'login.captchaWindow.title' => '請輸入驗證碼',
			'login.captchaWindow.hint' => '輸入驗證碼',
			'login.captchaWindow.messageOnEmpty' => '請輸入驗證碼',
			'login.captchaWindow.refreshFailed' => ({required Object error}) => '刷新驗證碼失敗: ${error}',
			'login.sliderTitle' => '服務器認證服務',
			'loginProcess.readyPage' => '準備獲取登錄網頁',
			'loginProcess.getEncrypt' => '獲取密碼加密密鑰',
			'loginProcess.readyLogin' => '準備登錄',
			'loginProcess.slider' => '登錄中',
			'loginProcess.afterProcess' => '登錄後處理',
			'loginProcess.failed' => ({required Object status_code}) => '登錄失敗，響應狀態碼：${status_code}',
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
			'restartApp.titleCacheCleared' => '緩存已清空',
			'restartApp.titleLoggedOut' => '已退出登錄',
			'restartApp.titlePasswordWrong' => '密碼錯誤',
			'restartApp.content' => '點擊通知重新打開應用',
			'ruisi.common.refresh' => '刷新',
			'ruisi.common.confirm' => '確定',
			'ruisi.common.cancel' => '取消',
			'ruisi.common.retry' => '重試',
			'ruisi.common.noTopics' => '暫無帖子',
			'ruisi.common.noContent' => '暫無內容',
			'ruisi.common.reply' => '回覆',
			'ruisi.common.favorite' => '收藏',
			'ruisi.common.notImplemented' => '未實現',
			'ruisi.common.login' => '登錄',
			'ruisi.common.logout' => '退出登錄',
			'ruisi.common.loggedOut' => '已退出登錄',
			'ruisi.common.submit' => '提交',
			'ruisi.about.title' => '關於',
			'ruisi.about.appName' => '睿思',
			'ruisi.about.subtitle' => '西安電子科技大學校園論壇客戶端',
			'ruisi.about.version' => '版本',
			'ruisi.about.versionNumber' => '2.0.0 (隨 XDYou 1.6.0 分發)',
			'ruisi.about.sourceCode' => '源代碼',
			'ruisi.about.bugReport' => '問題反饋',
			'ruisi.about.bugReportSubtitle' => '在 GitHub 上提交 issue',
			'ruisi.about.privacyPolicy' => '隱私政策',
			'ruisi.about.license' => '本應用基於 BSD-3-Clause 許可證開源 基於 Ruisi-iOS 和 Ruisi-Android 在 AI 輔助下重寫',
			'ruisi.about.privacyPolicyContent' => '本應用僅在西安電子科技大學校園網內運行，訪問睿思論壇 (rs.xidian.edu.cn) 的數據。\n\n本應用不會收集、存儲或傳輸任何用戶的個人信息到第三方服務器。\n\n用戶的登錄憑據僅保存在本地設備中，用於與睿思論壇服務器進行身份驗證。\n\n本應用使用 Cookie 與睿思論壇服務器進行通信，所有數據交互均直接在用戶的設備與睿思論壇服務器之間進行。\n\n如有任何疑問，請通過 GitHub 提交 issue 聯繫開發者。',
			'ruisi.home.title' => '睿思論壇',
			'ruisi.home.newPost' => '發帖',
			'ruisi.home.forumList' => '論壇板塊',
			'ruisi.home.tabHot' => '熱帖',
			'ruisi.home.tabNewReply' => '最新回覆',
			'ruisi.home.tabNewPost' => '最新發表',
			'ruisi.home.tabMy' => '我的',
			'ruisi.home.tabTrade' => '二手交易',
			'ruisi.home.tabWater' => '灌水',
			'ruisi.home.tabLostFound' => '失物招領',
			'ruisi.home.tabEmployment' => '就業',
			'ruisi.home.tabPhotography' => '攝影',
			'ruisi.home.pleaseLogin' => '請先登錄',
			'ruisi.home.myProfile' => '我的資料',
			'ruisi.home.myPosts' => '我的帖子',
			'ruisi.home.myFavorites' => '我的收藏',
			'ruisi.home.messageCenter' => '消息中心',
			'ruisi.home.dailyCheckin' => '每日簽到',
			'ruisi.home.settings' => '設置',
			'ruisi.home.about' => '關於',
			'ruisi.home.search' => '搜索',
			'ruisi.login.title' => '登錄睿思',
			'ruisi.login.username' => '用戶名',
			'ruisi.login.usernameHint' => '請輸入用戶名',
			'ruisi.login.password' => '密碼',
			'ruisi.login.passwordHint' => '請輸入密碼',
			'ruisi.login.captcha' => '驗證碼',
			'ruisi.login.captchaHint' => '請輸入驗證碼',
			'ruisi.login.back' => '返回',
			'ruisi.login.resetLoginState' => '重置登錄狀態',
			'ruisi.login.resetConfirmTitle' => '確認重置',
			'ruisi.login.resetConfirmContent' => '確定要重置登錄狀態嗎？這將清除所有登錄信息。',
			'ruisi.login.resetSuccess' => '登錄狀態已重置',
			'ruisi.login.viewLogs' => '查看日誌',
			'ruisi.post.title' => '發帖',
			'ruisi.post.publish' => '發佈',
			'ruisi.post.selectForum' => '選擇板塊',
			'ruisi.post.selectForumHint' => '請選擇板塊',
			'ruisi.post.subject' => '標題',
			'ruisi.post.subjectHint' => '請輸入標題',
			'ruisi.post.content' => '內容',
			'ruisi.post.contentHint' => '請輸入內容',
			'ruisi.post.success' => '發帖成功',
			'ruisi.post.failure' => '發帖失敗',
			'ruisi.post.smiley' => '表情',
			'ruisi.topicDetail.title' => '帖子詳情',
			'ruisi.topicDetail.replyTooShort' => '回覆內容不能少於 13 個字符',
			'ruisi.topicDetail.replySuccess' => '回覆成功',
			'ruisi.topicDetail.replyFailure' => '回覆失敗',
			'ruisi.topicDetail.favoriteSuccess' => '收藏成功',
			'ruisi.topicDetail.favoriteFailure' => '收藏失敗',
			'ruisi.topicDetail.noData' => '無數據',
			'ruisi.topicDetail.replyHint' => '寫回復...',
			'ruisi.topicDetail.vote.singleSelect' => '單選',
			'ruisi.topicDetail.vote.multiSelect' => ({required Object count}) => '多選，最多 ${count} 項',
			'ruisi.topicDetail.vote.titlePrefix' => '投票',
			'ruisi.topicDetail.vote.count' => ({required Object count}) => '共 ${count} 人參與',
			'ruisi.topicDetail.vote.open' => '點此投票',
			'ruisi.topicDetail.vote.sheetTitle' => '投票',
			'ruisi.topicDetail.vote.maxSelection' => ({required Object count}) => '最多隻能選擇 ${count} 項',
			'ruisi.topicDetail.vote.notSelected' => '你還沒有選擇',
			'ruisi.topicDetail.vote.success' => '投票成功',
			'ruisi.topicDetail.vote.failure' => '投票失敗',
			'ruisi.topicDetail.vote.paramError' => '投票失敗：參數錯誤',
			'ruisi.topicDetail.vote.alreadyVoted' => '您已經投過票，謝謝您的參與',
			'ruisi.topicDetail.vote.expired' => '該投票已過期或關閉',
			'ruisi.topicDetail.vote.ended' => '投票已經結束',
			'ruisi.topicListItem.sticky' => '置頂',
			'ruisi.forumList.title' => '論壇板塊',
			'ruisi.forumList.empty' => '睿思論壇版塊分組為空',
			'ruisi.favorites.title' => '我的收藏',
			'ruisi.favorites.empty' => '暫無收藏',
			'ruisi.messages.title' => '消息',
			'ruisi.messages.tabAt' => '@我',
			'ruisi.messages.noReply' => '暫無回覆通知',
			'ruisi.messages.noAt' => '暫無@通知',
			'ruisi.search.hint' => '搜索帖子...',
			'ruisi.search.inputHint' => '輸入關鍵詞搜索',
			'ruisi.search.noResults' => '無搜索結果',
			'ruisi.settings.title' => '設置',
			'ruisi.settings.sectionProxy' => '代理',
			'ruisi.settings.proxyEnable' => '啟用代理',
			'ruisi.settings.proxyDisabled' => '未啟用',
			'ruisi.settings.proxyAddress' => '代理地址',
			'ruisi.settings.sectionDebug' => '調試',
			'ruisi.settings.viewLogs' => '查看日誌',
			'ruisi.settings.proxyDialogTitle' => '代理設置',
			'ruisi.settings.proxyHost' => '主機地址',
			'ruisi.settings.proxyHostHint' => '例如 127.0.0.1',
			'ruisi.settings.proxyPort' => '端口',
			'ruisi.settings.proxyPortHint' => '例如 7890',
			'ruisi.user.title' => '我的',
			'ruisi.user.tabProfile' => '資料',
			'ruisi.user.unknown' => '未知用戶',
			'schoolCardStatus.failedToFetch' => '獲取失敗',
			'schoolCardStatus.failedToQuery' => '查詢失敗',
			'schoolCardWindow.title' => '校園卡流水信息',
			'schoolCardWindow.income' => ({required Object income}) => '收入 ${income}',
			'schoolCardWindow.expense' => ({required Object expense}) => '支出 ${expense}',
			'schoolCardWindow.selectRange' => ({required Object start_day, required Object end_day}) => '選擇日期：從 ${start_day} 到 ${end_day}',
			'schoolCardWindow.storeName' => '商戶名稱',
			'schoolCardWindow.balance' => '金額',
			'schoolCardWindow.timeWithSum' => ({required Object sum}) => '時間(共${sum}元)',
			'schoolCardWindow.noRecord' => '未查詢到記錄，請修改日期後重試',
			'schoolCardWindow.qrCode' => '支付碼',
			'schoolCardWindow.qrCodeError' => ({required Object info}) => '二維碼獲取失敗：${info}',
			'schoolCardWindow.reload' => '重新加載',
			'schoolNet.title' => '校園網使用詳情',
			'schoolNet.idsAccountNet.title' => '當前用戶',
			'schoolNet.idsAccountNet.notice' => '這是登錄到 PDA 賬戶的校園網信息\n注意: 流量計費採用GB單位（1000進制）\n如果沒有看到信息，請訪問 zfw.xidian.edu.cn 重置網絡密碼',
			'schoolNet.idsAccountNet.overview' => '賬戶概覽',
			'schoolNet.idsAccountNet.account' => '賬號',
			'schoolNet.idsAccountNet.used' => '已使用流量',
			'schoolNet.idsAccountNet.remain' => '餘額',
			'schoolNet.idsAccountNet.currentOnline' => ({required Object length}) => '在線設備（${length}臺）',
			'schoolNet.idsAccountNet.noDeviceOnline' => '當前沒有在線設備',
			'schoolNet.currentLoginNet.title' => '正在使用',
			'schoolNet.currentLoginNet.notice' => '這是您正在使用中校園網的信息，可能和您登錄 PDA 的信息不一致\n注意: 流量計費採用GB單位（1000進制）',
			'schoolNet.currentLoginNet.overview' => '賬戶概覽',
			'schoolNet.currentLoginNet.account' => '賬號',
			'schoolNet.currentLoginNet.planType' => '套餐類型',
			'schoolNet.currentLoginNet.remain' => '餘額',
			'schoolNet.currentLoginNet.usageSituation' => '流量使用情況',
			'schoolNet.currentLoginNet.usedPercent' => ({required Object percent}) => '已使用 ${percent}%',
			'schoolNet.currentLoginNet.used' => '已使用流量',
			'schoolNet.currentLoginNet.remainCount' => '剩餘流量',
			'schoolNet.currentLoginNet.total' => '總流量',
			'schoolNet.currentLoginNet.nonSchoolnet' => '非校園網',
			'schoolNet.deviceList.ip' => '在線設備IP',
			'schoolNet.deviceList.time' => '上線時間',
			'schoolNet.deviceList.remain' => '流量用量',
			'schoolNet.fetching' => '正在獲取校園網信息',
			'schoolNet.emptyPassword' => '您忘記輸入賬號密碼了',
			'schoolNet.notInitalized' => '疑似查詢後端尚未開放查詢',
			'schoolNet.captchaFailed' => '驗證碼識別失敗',
			'schoolNet.captchaEmpty' => '驗證碼為空',
			'schoolNet.cacheHintCaptchaFailed' => '驗證碼識別失敗，請重試。',
			'schoolNet.cacheHintRequestFailed' => '校園網請求失敗，請稍後重試。',
			'schoolNet.wrongPassword' => '密碼錯誤',
			'schoolNet.errorFetch' => ({required Object msg}) => '獲取失敗：${msg}',
			'schoolNet.errorOther' => ({required Object msg}) => '其他錯誤：${msg}',
			'schoolNet.refresh' => '刷新',
			'score.cacheMessage' => '已顯示緩存成績信息',
			'score.summary' => ({required Object chosen, required Object credit, required Object avg, required Object gpa}) => '目前選中科目 ${chosen}  總計學分 ${credit}\n均分 ${avg} GPA ${gpa}',
			'score.allPassed' => '所有科目均已通過',
			'score.cacheHintPasswordWrong' => '統一認證密碼錯誤或已失效',
			'score.cacheHintLoginFailed' => '登錄考試服務失敗',
			'score.cacheHintNetworkFailed' => '網絡連接失敗',
			'score.cacheHintUnknownError' => '在線獲取成績安排失敗，詳細錯誤請查看日誌',
			'score.fetchingHint' => '正在獲取最新成績信息，請不要退出頁面',
			'score.allSemester' => '所有學期',
			'score.chosenSemester' => ({required Object chosen}) => '學期 ${chosen}',
			'score.allType' => '所有類型',
			'score.chosenType' => ({required Object type}) => '類型 ${type}',
			'score.none' => '暫無',
			'score.scoreChoice.title' => '成績單',
			'score.scoreChoice.searchHint' => '搜索成績記錄',
			'score.scoreChoice.emptyList' => '沒有選擇該學期的課程計入均分計算',
			'score.scoreChoice.sumDialogTitle' => '小總結',
			'score.scoreChoice.sumDialogContent' => ({required Object gpa_all, required Object avg_all, required Object credit_all, required Object unpassed, required Object not_core_type}) => '所有科目的GPA：${gpa_all}\n所有科目的均分：${avg_all}\n所有科目的學分：${credit_all}\n未通過科目：${unpassed}\n公共選修課：${not_core_type}\n本程序提供的數據僅供參考，開發者對其準確性不負責',
			'score.scoreComposeCard.noDetail' => '未提供詳情信息',
			'score.scoreComposeCard.fetching' => '正在獲取',
			'score.scoreComposeCard.credit' => '學分',
			'score.scoreComposeCard.gpa' => 'GPA',
			'score.scoreComposeCard.score' => '成績',
			'score.scoreInfoCard.title' => '成績詳情',
			'score.scoreInfoCard.originalCourse' => '初修',
			'score.scoreInfoCard.failed' => '[掛] ',
			'score.scoreInfoCard.credit' => ({required Object credit}) => '學分 ${credit}',
			'score.scoreInfoCard.gpa' => ({required Object gpa}) => 'GPA ${gpa}',
			'score.scoreInfoCard.score' => ({required Object score}) => '成績 ${score}',
			'score.scorePage.title' => '成績查詢',
			'score.scorePage.searchHint' => '搜索成績記錄',
			'score.scorePage.noRecord' => '未篩查到合請求的記錄',
			'score.scorePage.selectAll' => '全選',
			'score.scorePage.selectNothing' => '全不選',
			'score.scorePage.resetSelect' => '重置選擇',
			'score.scorePage.summary' => '總結',
			'score.scorePage.cet4' => '國家英語四級',
			'score.scorePage.cet6' => '國家英語六級',
			'setting.acknowledgement' => ({required Object developers}) => 'Made With Love From ${developers} People',
			'setting.about' => '關於',
			'setting.aboutThisProgram' => '關於本程序',
			'setting.version' => ({required Object version}) => '版本號：${version}',
			'setting.userInfo' => '用戶信息',
			'setting.checkUpdate' => '檢查軟件更新',
			'setting.latestVersion' => ({required Object latest}) => '最新版本: ${latest}',
			'setting.waiting' => '等待獲取',
			'setting.fetchingUpdate' => '正在獲取更新信息',
			'setting.newVersion' => '有新版本發佈！',
			'setting.currentStable' => '目前您正在運行最新版',
			'setting.currentTesting' => '目前您正在運行測試版',
			'setting.fetchFailed' => '獲取更新信息失敗',
			'setting.uiSetting' => '界面設置',
			'setting.brightnessSetting' => '設置深淺色',
			'setting.colorSetting' => '顏色設置',
			'setting.simplifyTimeline' => '簡化日程時間軸',
			'setting.simplifyTimelineDescription' => '沒有日程時 減少空間佔用',
			'setting.lowElectricityWarning' => '低電量卡片變色提醒',
			'setting.lowElectricityWarningDescription' => '電量小於閾值時 電量卡片變色提醒',
			'setting.lowElectricityThreshold' => '低電量閾值',
			'setting.lowElectricityThresholdDescription' => ({required Object threshold}) => '當前為 ${threshold} 度',
			'setting.lowElectricityThresholdDialog.title' => '設置低電量閾值',
			'setting.lowElectricityThresholdDialog.inputHint' => '請輸入電量度數',
			'setting.accountSetting' => '賬號設置',
			'setting.sportPasswordSetting' => '體育系統密碼設置',
			'setting.experimentPasswordSetting' => '物理實驗系統密碼設置',
			'setting.electricityPasswordSetting' => '電費帳號密碼設置',
			'setting.electricityPasswordDescription' => '非 123456 請設置',
			'setting.electricityAccountSetting' => '電費賬號設置',
			'setting.schoolnetPasswordSetting' => '校園網帳號密碼設置',
			'setting.schoolnetPasswordDescription' => '不設置查看不了網費',
			'setting.airconImeiTitle' => '空調用電數據源',
			'setting.airconImei' => '空調 IMEI',
			'setting.airconImeiNotSet' => '未設置，電費頁不顯示空調用電',
			'setting.airconImeiCurrent' => ({required Object imei}) => '當前 IMEI：${imei}',
			'setting.airconImeiSaved' => '空調 IMEI 已保存',
			'setting.airconImeiCleared' => '空調 IMEI 已清除',
			'setting.airconImeiInvalid' => '沒有識別到有效的 15 位 IMEI',
			'setting.airconImeiClear' => '清除',
			'setting.scanAirconQr' => '掃描空調二維碼',
			'setting.pickAirconQrImage' => '從相冊選擇二維碼圖片',
			'setting.airconCameraUnavailable' => '當前平臺不支持相機掃碼，請選擇二維碼圖片或手動輸入 IMEI',
			'setting.notificationSetting' => '通知設置',
			'setting.courseReminderSetting' => '課前通知設置',
			'setting.courseReminderDescription' => '設置課前提醒通知',
			'setting.notificationPage.title' => '課前通知設置',
			'setting.notificationPage.loadFailed' => ({required Object error}) => '加載設置失敗: ${error}',
			'setting.notificationPage.functionSection' => '通知功能',
			'setting.notificationPage.enableNotification' => '啟用課前通知',
			'setting.notificationPage.notificationScheduled' => ({required Object count}) => '已安排 ${count} 個通知',
			'setting.notificationPage.notificationDisabledHint' => '關閉後將取消所有已安排的通知',
			'setting.notificationPage.updateSchedule' => '更新通知日程',
			'setting.notificationPage.updateScheduleHint' => '根據最新的課程數據重新安排通知',
			'setting.notificationPage.viewTheInstructions' => '查看使用說明',
			'setting.notificationPage.viewTheInstructionsHint' => '查看更多使用說明確保您能看到程序發出的通知',
			'setting.notificationPage.deleteAllSchedule' => '刪除通知日程',
			'setting.notificationPage.deleteAllScheduleHint' => '這個操作會刪除所有已經安排的日程，但是您可以再次點擊更新通知日程來重新添加',
			'setting.notificationPage.deleteAllSuccess' => '刪除操作成功',
			'setting.notificationPage.permissionSection' => '權限狀態',
			'setting.notificationPage.notificationPermission' => '通知權限',
			'setting.notificationPage.exactAlarmPermission' => '精確時鐘權限',
			'setting.notificationPage.permissionGranted' => '已授予',
			'setting.notificationPage.permissionDenied' => '未授予',
			'setting.notificationPage.requestPermission' => '請求權限',
			'setting.notificationPage.systemSettings' => '系統通知設置',
			'setting.notificationPage.systemSettingsHint' => '打開系統設置檢查通知配置',
			'setting.notificationPage.permissionGrantedMsg' => '權限已授予',
			'setting.notificationPage.permissionDeniedMsg' => '權限被拒絕，請在系統設置中開啟',
			'setting.notificationPage.reminderSection' => '提醒設置',
			'setting.notificationPage.experimentReminder' => '將物理實驗加入課程提醒',
			'setting.notificationPage.experimentReminderHint' => '將物理實驗的時間安排一併加入課前提醒系統',
			'setting.notificationPage.minutesBefore' => '提前提醒時間',
			'setting.notificationPage.minutesBeforeHint' => '課前提前提醒的時間設置',
			'setting.notificationPage.minutesUnit' => '分鐘',
			'setting.notificationPage.daysToSchedule' => '計劃通知天數',
			'setting.notificationPage.daysToScheduleHint' => '本程序是提前將課程信息寫入計劃日程，該設置可調整寫入計劃日程的天數',
			'setting.notificationPage.daysUnit' => '天',
			'setting.notificationPage.settingsGuideTitle' => '通知設置提示',
			'setting.notificationPage.settingsGuideContent1' => '為了確保您能及時收到課前提醒，請確保：\n1. 開啟了應用的通知權限\n2. 開啟了通知的聲音提示\n3. 開啟了懸浮通知（橫幅通知）\n4. 非原生安卓用戶，開啟自啟動和關閉電源優化',
			'setting.notificationPage.settingsGuideContent2' => '課前提醒模塊運行機制：\n1. 首次開啟時自動安排未來幾天的課前提醒\n2. 每次打開應用時自動檢查並更新通知日程\n3. 修改設置後自動重新安排所有通知',
			'setting.notificationPage.gotIt' => '知道了',
			'setting.notificationPage.openSettings' => '打開系統設置',
			'setting.notificationPage.noClasstableData' => '請先獲取課程表、考試或實驗數據',
			'setting.notificationPage.scheduleSuccess' => ({required Object count}) => '已安排 ${count} 個課前提醒',
			'setting.notificationPage.scheduleFailed' => ({required Object error}) => '安排通知失敗: ${error}',
			'setting.notificationPage.cancelAllSuccess' => '已取消所有課前提醒',
			'setting.notificationPage.rescheduleSuccess' => ({required Object count}) => '已重新安排 ${count} 個課前提醒',
			'setting.notificationPage.rescheduleFailed' => ({required Object error}) => '重新安排通知失敗: ${error}',
			'setting.notificationDebugPage' => '通知服務調試頁面',
			'setting.classtableSetting' => '課表相關設置',
			'setting.background' => '開啟課表背景圖',
			'setting.noBackground' => '你先選個圖片罷，就在下面',
			'setting.chooseBackground' => '課表背景圖選擇',
			'setting.noPermission' => '未獲取存儲權限，無法讀取文件',
			'setting.successfulSetting' => '設定成功',
			'setting.failureSetting' => '你沒有選圖片捏',
			'setting.clearUserClass' => '清除所有用戶添加課程',
			'setting.clearUserClassTitle' => '確認對話框',
			'setting.clearUserClassContent' => '是否要清除所有用戶添加課程？這個功能對從學校獲取的日程沒有影響。',
			'setting.clearUserClassClear' => '已經清除完畢',
			'setting.classRefresh' => '強制刷新課表',
			'setting.classRefreshTitle' => '確認對話框',
			'setting.classRefreshContent' => '是否要強制刷新課表？同意後，將會從學校一站式後端重新獲取課表，耗時會比較久。',
			'setting.classSwift' => '課程偏移設置',
			'setting.classSwiftDescription' => ({required Object swift}) => '正數錯後開學日期 負數提前開學日期\n目前為 ${swift}',
			'setting.coreSetting' => '緩存登錄設置',
			'setting.checkLogger' => '查看網絡攔截器和日誌',
			'setting.clearAndRestart' => '清除緩存後重啟',
			'setting.clearAndRestartDialog.title' => '確認對話框',
			'setting.clearAndRestartDialog.content' => '確定清除緩存後重啟程序？',
			'setting.clearAndRestartDialog.cleaning' => '正在清理緩存',
			'setting.clearAndRestartDialog.clear' => '緩存已被清除',
			'setting.logout' => '退出登錄並重啟應用',
			'setting.logoutDialog.title' => '確認對話框',
			'setting.logoutDialog.content' => '確定退出登錄？你的所有數據將會被徹底刪除！',
			'setting.logoutDialog.loggingOut' => '正在退出登錄',
			'setting.needCloseDialog.title' => '請關閉應用',
			'setting.needCloseDialog.content' => '因為技術限制，用戶需要自行關閉窗口，然後重新打開應用。',
			'setting.changeColorDialog.title' => '顏色設置',
			'setting.changeColorDialog.kDefault' => '默認顏色',
			'setting.changeColorDialog.blue' => '聰明藍',
			'setting.changeColorDialog.deepPurple' => '基佬紫',
			'setting.changeColorDialog.green' => '春風綠',
			'setting.changeColorDialog.orange' => '明日香橙',
			'setting.changeColorDialog.pink' => '櫻花粉',
			'setting.changeBrightnessDialog.title' => '亮度設置',
			'setting.changeBrightnessDialog.followSetting' => '跟隨系統',
			'setting.changeBrightnessDialog.dayMode' => '白天模式',
			'setting.changeBrightnessDialog.nightMode' => '黑夜模式',
			'setting.changeSwiftDialog.title' => '課程偏移設置',
			'setting.changeSwiftDialog.inputHint' => '請在此輸入數字',
			'setting.changeElectricityTitle' => '修改電費帳號',
			'setting.changeElectricityAccount.title' => '修改電費帳號',
			'setting.changeElectricityAccount.campus' => '校區',
			'setting.changeElectricityAccount.northCampus' => '北校區',
			'setting.changeElectricityAccount.southCampus' => '南校區',
			'setting.changeElectricityAccount.unitOrZone' => '單元/區號',
			'setting.changeElectricityAccount.unitCode' => '單元號',
			'setting.changeElectricityAccount.zoneCode' => '區號',
			'setting.changeElectricityAccount.pleaseInput' => ({required Object unit_or_zone_code}) => '請輸入${unit_or_zone_code}',
			'setting.changeElectricityAccount.successfulFetch' => ({required Object account_number}) => '賬號獲取成功：${account_number}',
			'setting.changeElectricityAccount.failedFetch' => ({required Object e}) => '獲取失敗：${e}',
			'setting.changeElectricityAccount.accountSaved' => ({required Object account_number}) => '賬號已保存：${account_number}',
			'setting.changeElectricityAccount.unknownCodingPattern' => '該樓號編碼規則未知',
			'setting.changeElectricityAccount.selectBuilding' => '選擇樓棟',
			'setting.changeElectricityAccount.building' => '樓棟',
			'setting.changeElectricityAccount.northernBuilding' => '北棟',
			'setting.changeElectricityAccount.southernBuilding' => '南棟',
			'setting.changeElectricityAccount.failedGenerate' => ({required Object e}) => '生成失敗：${e}',
			'setting.changeElectricityAccount.buildingNumber' => '樓號',
			'setting.changeElectricityAccount.buildingNumberHint' => '例如: 16, 7, 55',
			'setting.changeElectricityAccount.buildingNumberQuery' => '請輸入樓號',
			'setting.changeElectricityAccount.yard' => '院區',
			'setting.changeElectricityAccount.yardHint' => '選擇院區',
			'setting.changeElectricityAccount.northYard' => '北院',
			'setting.changeElectricityAccount.southYard' => '南院',
			'setting.changeElectricityAccount.yardQuery' => '請選擇院區',
			'setting.changeElectricityAccount.apartment' => '樓棟',
			'setting.changeElectricityAccount.apartmentHint' => '選擇樓棟',
			'setting.changeElectricityAccount.northApartment' => '北樓',
			'setting.changeElectricityAccount.southApartment' => '南樓',
			'setting.changeElectricityAccount.apartmentQuery' => '請選擇樓棟',
			'setting.changeElectricityAccount.levelCode' => '層號',
			'setting.changeElectricityAccount.levelCodeQuery' => '請輸入層號',
			'setting.changeElectricityAccount.roomCode' => '房間號',
			'setting.changeElectricityAccount.roomCodeHint' => '例如: 304, 508',
			'setting.changeElectricityAccount.roomCodeQuery' => '請輸入房間號',
			'setting.changeElectricityAccount.account' => '電費賬號',
			'setting.changeElectricityAccount.accountHint' => '請輸入或從網絡獲取',
			'setting.changeElectricityAccount.accountQuery' => '請輸入電費賬號',
			'setting.changeElectricityAccount.accountLength' => '賬號長度通常不小於10位',
			'setting.changeElectricityAccount.fetching' => '正在獲取...',
			'setting.changeElectricityAccount.fetchFromInternet' => '從網絡同步',
			'setting.changeElectricityAccount.saveAccount' => '保存賬號',
			'setting.changeElectricityAccount.confirmSaving' => '確認保存',
			'setting.changeElectricityAccount.calculateAccount' => '計算賬號',
			'setting.changeElectricityAccount.calculate' => '計算',
			'setting.changeElectricityAccount.input' => '輸入',
			'setting.changeElectricityAccount.confirmAccount' => '請確認賬號：',
			'setting.changeElectricityAccount.change' => '修改',
			'setting.changeElectricityAccount.cancel' => '取消',
			'setting.changeElectricityAccount.noSetting' => '未設置新的電費賬號',
			'setting.changeElectricityAccount.successfulSetting' => '已設置新的電費賬號',
			'setting.changeExperimentTitle' => '修改物理實驗賬號密碼',
			'setting.changeSportTitle' => '修改體育系統賬號密碼',
			'setting.changePasswordDialog.inputHint' => '請在此輸入密碼',
			'setting.changePasswordDialog.blankInput' => '輸入空白!',
			'setting.changeSchoolnetPasswordTitle' => '修改校園網查詢帳號密碼',
			'setting.updateDialog.newVersion' => '新版本發佈',
			'setting.updateDialog.notNow' => '暫不更新',
			'setting.updateDialog.appStore' => 'App Store 更新',
			'setting.updateDialog.downloadApk' => '下載安裝包',
			'setting.updateDialog.githubRelease' => '去 Git Release',
			'setting.updateDialog.newContent' => ({required Object code}) => '版本號 ${code} 新增內容：\n',
			'setting.localizationDialog.title' => '修改語言',
			'setting.localizationDialog.undefined' => '追隨系統設置',
			'setting.localizationDialog.simplifiedChinese' => '簡體中文',
			'setting.localizationDialog.traditionalChinese' => '繁體中文',
			'setting.localizationDialog.english' => '英語',
			'setting.semesterChange' => '修改學期',
			'setting.semesterChangeDescription' => ({required Object semester}) => '使用學期 ${semester}',
			'setting.semesterUpdateData' => '應用新學期設置中',
			'setting.easterEggPage' => '你找到了彩蛋',
			'setting.aboutPage.benderblog' => '主要開發者，iOS 小部件編寫和拼接',
			'setting.aboutPage.alnair' => '開發：圖書館搜索和封面',
			'setting.aboutPage.aqqkad' => '開發：考勤歷史記錄',
			'setting.aboutPage.bellssgit' => '支持：最佳&最久故障反饋者',
			'setting.aboutPage.brackrat' => '設計：主頁，登錄頁，配色，iOS 小部件等',
			'setting.aboutPage.breezeline' => '支持：無價值無意義的產品經理(他自己的描述)',
			'setting.aboutPage.cafebabe' => '支持：提供彩蛋代碼 / 開發：2026版本滑塊驗證碼適配',
			'setting.aboutPage.chitao1234' => '開發：修復滑塊不對齊問題',
			'setting.aboutPage.copperkoi' => '開發：系統日曆最新課表同步',
			'setting.aboutPage.dimole' => '開發支持：輔助修復滑塊問題',
			'setting.aboutPage.elitewars' => '設計：體育成績頁面',
			'setting.aboutPage.elliot' => '國際化：軟件英語翻譯 / 開發指導：情侶課表功能開發指導（該功能已經被移除）',
			'setting.aboutPage.flyingpig' => '開發：修復自定義課程編輯頁的空指針異常',
			'setting.aboutPage.godhu777777' => '國際化：繁體中文轉換代碼和彩蛋代碼 / 開發：優化導出日曆文件大小',
			'setting.aboutPage.hancl777' => '國際化：繁體中文轉換代碼',
			'setting.aboutPage.hazukiKeatsu' => '開發：物理實驗成績查詢和識別',
			'setting.aboutPage.hawa130' => '設計：課程詳情卡片',
			_ => null,
		} ?? switch (path) {
			'setting.aboutPage.hhzm' => '開發：電費查詢賬號計算',
			'setting.aboutPage.imaginary17' => '開發：睿思論壇路由修復',
			'setting.aboutPage.imoscarz' => '開發：設計軟件主頁 / 開發：平板考勤查詢頁面 / 開發：優化了體育查詢界面的UI',
			'setting.aboutPage.kaMateKaOra' => '國際化：軟件英語翻譯優化',
			'setting.aboutPage.lagrangeX' => '開發：課程表時間進度展示（終版方案） / 開發：課程表上過課程灰度化和其他課程界面特性',
			'setting.aboutPage.lhx666Cool' => '支持：Windows 和 Linux 構建腳本 / 開發：2026版本滑塊驗證碼適配',
			'setting.aboutPage.lichtyy' => '設計：配色，空白頁面貼圖 / 開發：實驗系統頁面讀取代碼',
			'setting.aboutPage.lqsyH' => '支持：推文宣傳圖片製作',
			'setting.aboutPage.lsy223622' => '設計：iOS 和 Android 圖標 / 支持：冠名 XDYou',
			'setting.aboutPage.mrbrilliant2046' => '支持：提供網絡服務使用說明文檔 / 國際化：優化英語翻譯',
			'setting.aboutPage.nancunchild' => '開發：圖書館搜索功能 / 國際化：優化英語翻譯',
			'setting.aboutPage.nkanf' => '開發：課程表時間進度展示（初版方案） / 支持：MacOS 構建支持',
			'setting.aboutPage.pairman' => '開發：成績緩存功能和優化滑塊算法 / 國際化：優化英語翻譯',
			'setting.aboutPage.reverierxu' => '設計：用於信息展示的 ReX 卡片 / 開發支持：研究生課表',
			'setting.aboutPage.rrrilac' => '開發支持：電費查詢',
			'setting.aboutPage.ray' => '設計：開屏畫面 / 支持：iOS 發行商 & 搭子課表 / 開發指導：情侶課表功能開發指導（該功能已經被移除） / 國際化：優化英語翻譯',
			'setting.aboutPage.shadowyingyi' => '支持：兩次鴿子公眾號宣傳',
			'setting.aboutPage.stalomeow' => '設計：首頁時間軸 / 開發：異步登錄 & 驗證碼預測',
			'setting.aboutPage.xeonds' => '設計：設置頁面 / 開發：XDU Planet / 開發：校園卡付款碼',
			'setting.aboutPage.xingshuyu' => '開發：修復物理實驗獲取問題和電費窗口問題',
			'setting.aboutPage.xiue233' => '開發：Android 小部件和拼接',
			'setting.aboutPage.xizi' => '開發支持：研究生版本開發',
			'setting.aboutPage.wirsbf' => '開發：修復調課未按預期進行',
			'setting.aboutPage.zcwzy' => '開發：修復丁香電費 / 開發支持：研究生版本開發 / 設計：空白頁面貼圖',
			'setting.aboutPage.zyarEr' => '開發支持：小工具頁面地址更新',
			'setting.aboutPage.homepage' => '主頁',
			'setting.aboutPage.code' => '開源代碼',
			'setting.aboutPage.knowMore' => '知道更多',
			'setting.aboutPage.copyrightNotice' => '本軟件拷貝基於 traintime_pda 代碼（或稱 watermeter 代碼）編譯或修改，代碼按照 Mozilla Public License, v. 2.0 授權。\n本程序和西安電子科技大學，體適能服務，書蝸，電錶等服務無關。\n\nCopyright 2023-2025 BenderBlog Rodriguez and contributors.\nCopyright 2025-present Traintime PDA authors.\n\nThe Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, you can obtain one at https://mozilla.org/MPL/2.0/.',
			'setting.aboutPage.beian' => '備案號',
			'setting.aboutPage.signAndroid' => '安卓簽名',
			'setting.aboutPage.title' => '關於本軟件',
			'sport.title' => '體育查詢',
			'sport.classInfo' => '課程信息',
			'sport.emptyClassInfo' => '未查詢到課程信息',
			'sport.testScore' => '體測成績',
			'sport.totalScore' => '四年總分',
			'sport.totalScoreLabel' => '總分',
			'sport.rankLabel' => '等級',
			'sport.semester' => ({required Object year, required Object grade_type}) => '${year} 第${grade_type}',
			'sport.subject' => '項目',
			'sport.data' => '數據',
			'sport.score' => '分數',
			'sport.passed' => '及格',
			'sport.fromTo' => ({required Object start, required Object stop}) => '第${start}節到第${stop}節',
			'sport.scoreString' => ({required Object score}) => '${score}分',
			'sport.situationNopassword' => '沒密碼',
			'sport.situationMaintain' => '系統維護',
			'sport.situationFailedLogin' => '登錄失敗',
			'sport.situationQuery' => '查詢失敗',
			'sport.situationNetwork' => '網絡故障',
			'sport.situationUnknown' => ({required Object situation}) => '未知故障${situation}',
			'sport.situationFetching' => '正在獲取',
			'sport.situationError' => ({required Object situation}) => '壞事: ${situation}',
			'sport.cacheHintMissingPassword' => '請先填寫體育密碼後重試。',
			'sport.cacheHintCredentialInvalid' => '體育登錄已失效，請更新體育密碼後重試。',
			'sport.cacheHintMaintain' => '體育服務正在維護中，請稍後重試。',
			'sport.cacheHintLoginFailed' => '體育服務登錄失敗。',
			'sport.cacheHintQueryFailed' => '體育信息查詢失敗。',
			'sport.cacheHintNetwork' => '體育服務網絡請求失敗。',
			'sport.cacheHintUnknown' => '在線獲取體育信息失敗。詳細錯誤請查看日誌。',
			'sport.errorAuthExpired' => '體育登錄已失效，請重試。',
			'sport.errorMissingPassword' => '未填寫體育密碼',
			'sport.errorCredentialInvalid' => '體育登錄已失效，請更新體育密碼後重試。',
			'toolbox.title' => '其他功能',
			'toolbox.payment' => '繳費系統',
			'toolbox.paymentDescription' => '電費該交了吧',
			'toolbox.drinkingwater' => '訂水系統',
			'toolbox.drinkingwaterDescription' => '喝水對身體好',
			'toolbox.repair' => '後勤報修',
			'toolbox.repairDescription' => '不要漏水斷網',
			'toolbox.reserve' => '空間預約',
			'toolbox.reserveDescription' => '找個地方打牌',
			'toolbox.mobile' => '移動門戶',
			'toolbox.mobileDescription' => '請假專用門戶',
			'toolbox.network' => '網絡查詢',
			'toolbox.networkDescription' => '希望永不收費',
			'toolbox.physics' => '物理計算',
			'toolbox.physicsDescription' => '希望操作順利',
			'toolbox.discover' => '睿思導航',
			'toolbox.discoverDescription' => '補充其他功能',
			'weekday.monday' => '週一',
			'weekday.tuesday' => '週二',
			'weekday.wednesday' => '週三',
			'weekday.thursday' => '週四',
			'weekday.friday' => '週五',
			'weekday.saturday' => '週六',
			'weekday.sunday' => '週日',
			'xduPlanet.all' => '全部',
			'xduPlanet.loading' => '加載中，請稍等 <(=ω=)>',
			'xduPlanet.unknownAuthor' => '未知作者',
			'xduPlanet.loadFailedTitle' => '加載失敗',
			'xduPlanet.loadFailedBottom' => '文章加載失敗，如有需要可以點擊右上方的按鈕在瀏覽器裡打開。',
			'xduPlanet.noComment' => '暫無評論',
			'xduPlanet.replyAudit' => ({required Object reply_to}) => '回覆評論 #${reply_to} 已被舉報或刪除',
			'xduPlanet.reply' => ({required Object reply_to, required Object content}) => '回覆評論 #${reply_to}：${content}',
			'xduPlanet.haveBeenAudit' => '本評論已經被舉報',
			'xduPlanet.audit' => '舉報',
			'xduPlanet.confirmAuditDialog.title' => '確認是否舉報',
			'xduPlanet.confirmAuditDialog.content' => '三思而後行，確定您想舉報嗎？舉報後該評論會有標籤，不一定會刪除。',
			'xduPlanet.confirmAuditDialog.cancel' => '不舉報了',
			'xduPlanet.confirmAuditDialog.ongoing' => '正在舉報評論',
			'xduPlanet.confirmAuditDialog.failed' => '舉報失敗',
			'xduPlanet.confirmAuditDialog.success' => '舉報成功',
			'xduPlanet.comment' => '回覆',
			'xduPlanet.send' => '發送',
			'xduPlanet.sending' => '正在發送評論',
			'xduPlanet.emptySend' => '發送信息空白',
			'xduPlanet.hintSendComment' => '發表您的高見:)',
			'xduPlanet.commentTitle' => '評論該篇文章',
			'xduPlanet.commentSuccess' => '評論成功',
			'xduPlanet.commentFailed' => '評論失敗，請去網絡查看器和日誌查看器查看報錯',
			'xduPlanet.commentCanceled' => '沒想好要說啥嘛',
			'xduPlanet.commentLoading' => '加載評論中……',
			'xduPlanet.block' => '被屏蔽',
			'xduPlanet.delete' => '被刪除',
			'xduPlanet.audio' => '被刪除',
			_ => null,
		};
	}
}
