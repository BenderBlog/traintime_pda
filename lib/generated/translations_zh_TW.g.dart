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
class TranslationsZhTw extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsZhTw({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.zhTw,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <zh-TW>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final TranslationsZhTw _root = this; // ignore: unused_field

	@override 
	TranslationsZhTw $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsZhTw(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$common$zh_TW common = _Translations$common$zh_TW._(_root);
	@override late final _Translations$core$zh_TW core = _Translations$core$zh_TW._(_root);
	@override late final _Translations$settings$zh_TW settings = _Translations$settings$zh_TW._(_root);
}

// Path: common
class _Translations$common$zh_TW extends Translations$common$zh {
	_Translations$common$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get confirm => '確認';
	@override String get cancel => '取消';
	@override String get unexpectProblemTitle => '一個小問題 :P';
	@override String get unexpectProblemHint => '這裡有一個沒有被預料的問題發生了！';
	@override String get errorDetected => 'Ouch! 發生錯誤啦';
	@override String get clickToRefresh => '點我刷新';
}

// Path: core
class _Translations$core$zh_TW extends Translations$core$zh {
	_Translations$core$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override late final _Translations$core$language$zh_TW language = _Translations$core$language$zh_TW._(_root);
	@override late final _Translations$core$theme$zh_TW theme = _Translations$core$theme$zh_TW._(_root);
	@override late final _Translations$core$gridPage$zh_TW gridPage = _Translations$core$gridPage$zh_TW._(_root);
}

// Path: settings
class _Translations$settings$zh_TW extends Translations$settings$zh {
	_Translations$settings$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '設置';
	@override String get aboutInfo => '程序信息';
	@override String acknowledgement({required Object developers}) => 'Made With Love From ${developers} People';
	@override String get about => '關於';
	@override String get aboutThisProgram => '關於本程序';
	@override String version({required Object version}) => '版本號：${version}';
	@override String get userInfo => '用戶信息';
	@override String get checkUpdate => '檢查軟件更新';
	@override String latestVersion({required Object latest}) => '最新版本: ${latest}';
	@override String get waiting => '等待獲取';
	@override String get fetchingUpdate => '正在獲取更新信息';
	@override String get newVersion => '有新版本發佈，請立刻更新！';
	@override String get currentStable => '目前您正在運行最新版';
	@override String get currentTesting => '目前您正在運行測試版';
	@override String get fetchFailed => '獲取更新信息失敗';
	@override String get uiSetting => '界面設置';
	@override String get brightnessSetting => '深淺色模式';
	@override String get colorSetting => '顏色設置';
	@override String get simplifyTimeline => '簡化日程時間軸';
	@override String get simplifyTimelineDescription => '沒有日程時 減少空間佔用';
	@override String get lowElectricityWarning => '低電量卡片變色提醒';
	@override String get lowElectricityWarningDescription => '電量小於閾值時 電量卡片變色提醒';
	@override String get lowElectricityThreshold => '低電量閾值';
	@override String lowElectricityThresholdDescription({required Object threshold}) => '當前為 ${threshold} 度';
	@override late final _Translations$settings$lowElectricityThresholdDialog$zh_TW lowElectricityThresholdDialog = _Translations$settings$lowElectricityThresholdDialog$zh_TW._(_root);
	@override String get accountSetting => '賬號設置';
	@override String get sportPasswordSetting => '體育系統密碼設置';
	@override String get experimentPasswordSetting => '物理實驗系統密碼設置';
	@override String get electricityPasswordSetting => '電費帳號密碼設置';
	@override String get electricityPasswordDescription => '非 123456 請設置';
	@override String get electricityAccountSetting => '電費賬號設置';
	@override String get schoolnetPasswordSetting => '校園網帳號密碼設置';
	@override String get schoolnetPasswordDescription => '不設置查看不了網費';
	@override String get airconImeiTitle => '空調設備';
	@override String get airconImei => '空調 IMEI';
	@override String get airconImeiNotSet => '未設置，無法查詢或遙控空調';
	@override String airconImeiCurrent({required Object imei}) => '當前 IMEI：${imei}';
	@override String get airconImeiSaved => '空調 IMEI 已保存';
	@override String get airconImeiCleared => '空調 IMEI 已清除';
	@override String get airconImeiInvalid => '沒有識別到有效的 15 位 IMEI';
	@override String get airconImeiClear => '清除';
	@override String get scanAirconQr => '掃描空調二維碼';
	@override String get pickAirconQrImage => '從相冊選擇二維碼圖片';
	@override String get airconCameraUnavailable => '當前平臺不支持相機掃碼，請選擇二維碼圖片或手動輸入 IMEI';
	@override String get airconScanHint => '輕點畫面可以對焦；空調離得遠、放大後仍然模糊時，請用系統相機拍照識別';
	@override String get airconTakePhoto => '用系統相機拍照識別';
	@override String airconCameraError({required Object error}) => '無法打開相機：${error}';
	@override String get notificationSetting => '通知設置';
	@override String get courseReminderSetting => '課前通知設置';
	@override String get courseReminderDescription => '設置課前提醒通知';
	@override late final _Translations$settings$notificationPage$zh_TW notificationPage = _Translations$settings$notificationPage$zh_TW._(_root);
	@override String get notificationDebugPage => '通知狀態與測試';
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
	@override String classSwiftDescription({required Object swift}) => '目前為 ${swift}';
	@override String get coreSetting => '緩存登錄設置';
	@override String get checkLogger => '查看網絡攔截器和日誌';
	@override String get clearAndRestart => '清除緩存後重啟';
	@override late final _Translations$settings$clearAndRestartDialog$zh_TW clearAndRestartDialog = _Translations$settings$clearAndRestartDialog$zh_TW._(_root);
	@override String get logout => '退出登錄並重啟應用';
	@override late final _Translations$settings$logoutDialog$zh_TW logoutDialog = _Translations$settings$logoutDialog$zh_TW._(_root);
	@override late final _Translations$settings$needCloseDialog$zh_TW needCloseDialog = _Translations$settings$needCloseDialog$zh_TW._(_root);
	@override late final _Translations$settings$changeColorDialog$zh_TW changeColorDialog = _Translations$settings$changeColorDialog$zh_TW._(_root);
	@override late final _Translations$settings$changeBrightnessDialog$zh_TW changeBrightnessDialog = _Translations$settings$changeBrightnessDialog$zh_TW._(_root);
	@override late final _Translations$settings$changeSwiftDialog$zh_TW changeSwiftDialog = _Translations$settings$changeSwiftDialog$zh_TW._(_root);
	@override String get changeElectricityTitle => '修改電費帳號';
	@override late final _Translations$settings$changeElectricityAccount$zh_TW changeElectricityAccount = _Translations$settings$changeElectricityAccount$zh_TW._(_root);
	@override String get changeExperimentTitle => '修改物理實驗賬號密碼';
	@override String get changeSportTitle => '修改體育系統賬號密碼';
	@override late final _Translations$settings$changePasswordDialog$zh_TW changePasswordDialog = _Translations$settings$changePasswordDialog$zh_TW._(_root);
	@override String get changeSchoolnetPasswordTitle => '修改校園網查詢帳號密碼';
	@override late final _Translations$settings$updateDialog$zh_TW updateDialog = _Translations$settings$updateDialog$zh_TW._(_root);
	@override late final _Translations$settings$localizationDialog$zh_TW localizationDialog = _Translations$settings$localizationDialog$zh_TW._(_root);
	@override String get semesterChange => '修改學期';
	@override String semesterChangeDescription({required Object semester}) => '使用學期 ${semester}';
	@override String get semesterUpdateData => '應用新學期設置中';
	@override String get easterEggPage => '你找到了彩蛋';
	@override late final _Translations$settings$aboutPage$zh_TW aboutPage = _Translations$settings$aboutPage$zh_TW._(_root);
	@override late final _Translations$settings$editor$zh_TW editor = _Translations$settings$editor$zh_TW._(_root);
	@override late final _Translations$settings$sections$zh_TW sections = _Translations$settings$sections$zh_TW._(_root);
	@override late final _Translations$settings$navigation$zh_TW navigation = _Translations$settings$navigation$zh_TW._(_root);
	@override String get fontSizeSetting => '字體大小與粗細';
	@override late final _Translations$settings$fontSizePage$zh_TW fontSizePage = _Translations$settings$fontSizePage$zh_TW._(_root);
	@override String get generalAccountSettings => '通用賬號';
	@override String get undergraduateSystemAccounts => '本科生系統賬號';
	@override String get classTableBackgroundSection => '課表背景';
	@override String backgroundBlur({required Object value}) => '背景模糊: ${value}';
	@override String get backgroundBlurOff => '關閉';
	@override String get classTableStyleSetting => '課表顯示與樣式';
	@override String get classTableStyleDescription => '時間指示和課程卡片樣式';
	@override late final _Translations$settings$classTableStylePage$zh_TW classTableStylePage = _Translations$settings$classTableStylePage$zh_TW._(_root);
	@override String get classSwiftExplain => '正數錯後開學日期 負數提前開學日期';
}

// Path: core.language
class _Translations$core$language$zh_TW extends Translations$core$language$zh {
	_Translations$core$language$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '語言';
	@override String get selection => '應用語言';
	@override String get system => '跟隨系統';
	@override String get simplifiedChinese => '簡體中文';
	@override String get traditionalChinese => '繁體中文';
	@override String get english => 'English';
	@override String get saveFailed => '無法保存語言設置';
}

// Path: core.theme
class _Translations$core$theme$zh_TW extends Translations$core$theme$zh {
	_Translations$core$theme$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get saveFailed => '無法保存主題設置';
	@override String get display => '顯示';
	@override String get languageAndText => '文字';
	@override String get colorSetting => '顏色設置';
	@override String get brightnessSetting => '深淺色模式';
	@override String get sizeTitle => '字體大小';
	@override String get weightTitle => '字體粗細';
	@override late final _Translations$core$theme$weight$zh_TW weight = _Translations$core$theme$weight$zh_TW._(_root);
	@override late final _Translations$core$theme$palette$zh_TW palette = _Translations$core$theme$palette$zh_TW._(_root);
	@override late final _Translations$core$theme$brightness$zh_TW brightness = _Translations$core$theme$brightness$zh_TW._(_root);
}

// Path: core.gridPage
class _Translations$core$gridPage$zh_TW extends Translations$core$gridPage$zh {
	_Translations$core$gridPage$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get label => '校園信息';
	@override String get title => '校園信息查詢';
	@override String get editMode => '編輯佈局';
	@override String get editDone => '完成';
	@override String get editReset => '恢復默認佈局';
	@override String get manageHidden => '管理隱藏卡片';
	@override String get hideEmpty => '沒有隱藏的卡片';
}

// Path: settings.lowElectricityThresholdDialog
class _Translations$settings$lowElectricityThresholdDialog$zh_TW extends Translations$settings$lowElectricityThresholdDialog$zh {
	_Translations$settings$lowElectricityThresholdDialog$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '設置低電量閾值';
	@override String get inputHint => '請輸入電量度數';
}

// Path: settings.notificationPage
class _Translations$settings$notificationPage$zh_TW extends Translations$settings$notificationPage$zh {
	_Translations$settings$notificationPage$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

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

// Path: settings.clearAndRestartDialog
class _Translations$settings$clearAndRestartDialog$zh_TW extends Translations$settings$clearAndRestartDialog$zh {
	_Translations$settings$clearAndRestartDialog$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '確認對話框';
	@override String get content => '確定清除緩存後重啟程序？';
	@override String get cleaning => '正在清理緩存';
	@override String get clear => '緩存已被清除';
}

// Path: settings.logoutDialog
class _Translations$settings$logoutDialog$zh_TW extends Translations$settings$logoutDialog$zh {
	_Translations$settings$logoutDialog$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '確認對話框';
	@override String get content => '確定退出登錄？你的所有數據將會被徹底刪除！';
	@override String get loggingOut => '正在退出登錄';
}

// Path: settings.needCloseDialog
class _Translations$settings$needCloseDialog$zh_TW extends Translations$settings$needCloseDialog$zh {
	_Translations$settings$needCloseDialog$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '請關閉應用';
	@override String get content => '因為技術限制，用戶需要自行關閉窗口，然後重新打開應用。';
}

// Path: settings.changeColorDialog
class _Translations$settings$changeColorDialog$zh_TW extends Translations$settings$changeColorDialog$zh {
	_Translations$settings$changeColorDialog$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

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

// Path: settings.changeBrightnessDialog
class _Translations$settings$changeBrightnessDialog$zh_TW extends Translations$settings$changeBrightnessDialog$zh {
	_Translations$settings$changeBrightnessDialog$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '亮度設置';
	@override String get followSetting => '跟隨系統';
	@override String get dayMode => '淺色';
	@override String get nightMode => '深色';
}

// Path: settings.changeSwiftDialog
class _Translations$settings$changeSwiftDialog$zh_TW extends Translations$settings$changeSwiftDialog$zh {
	_Translations$settings$changeSwiftDialog$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '課程偏移設置';
	@override String get inputHint => '請在此輸入數字';
	@override String get invalidNumber => '請輸入有效的整數';
}

// Path: settings.changeElectricityAccount
class _Translations$settings$changeElectricityAccount$zh_TW extends Translations$settings$changeElectricityAccount$zh {
	_Translations$settings$changeElectricityAccount$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

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

// Path: settings.changePasswordDialog
class _Translations$settings$changePasswordDialog$zh_TW extends Translations$settings$changePasswordDialog$zh {
	_Translations$settings$changePasswordDialog$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get inputHint => '請在此輸入密碼';
	@override String get blankInput => '輸入空白!';
}

// Path: settings.updateDialog
class _Translations$settings$updateDialog$zh_TW extends Translations$settings$updateDialog$zh {
	_Translations$settings$updateDialog$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get newVersion => '新版本發佈';
	@override String get notNow => '暫不更新';
	@override String get appStore => 'App Store 更新';
	@override String get downloadApk => '下載安裝包';
	@override String get githubRelease => '去 Git Release';
	@override String newContent({required Object code}) => '版本號 ${code} 新增內容：\n';
}

// Path: settings.localizationDialog
class _Translations$settings$localizationDialog$zh_TW extends Translations$settings$localizationDialog$zh {
	_Translations$settings$localizationDialog$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '修改語言';
	@override String get undefined => '追隨系統設置';
	@override String get simplifiedChinese => '簡體中文';
	@override String get traditionalChinese => '繁體中文';
	@override String get english => '英語';
}

// Path: settings.aboutPage
class _Translations$settings$aboutPage$zh_TW extends Translations$settings$aboutPage$zh {
	_Translations$settings$aboutPage$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get benderblog => '主要開發者，iOS 小部件編寫和拼接';
	@override String get alnair => '開發：圖書館搜索和封面、圖書館佈局修復、飲水機接水功能及接口適配';
	@override String get aqqkad => '開發：考勤歷史記錄、空調遙控、空調電費數據接入、圖書館新接口適配';
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
	@override String get imoscarz => '開發：設計軟件主頁 / 開發：平板考勤查詢頁面 / 開發：優化了體育查詢界面的UI / 開發：設置頁面分類重構及主從佈局適配';
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
	@override String get copyrightNotice => '本軟件拷貝基於 traintime_pda 代碼（或稱 watermeter 代碼）編譯或修改，代碼按照 Mozilla Public License, v. 2.0 授權。\n本程序和西安電子科技大學，體適能服務，書蝸，電錶等服務無關。\n本程序代碼版權受中國國家版權局保護，登記號2026SR0738647。\nCopyright 2023-2025 BenderBlog Rodriguez and contributors. Copyright 2025-present Traintime PDA authors.\nThe Copyright of the Software is protected by NCAC, register code is 2026SR0738647\nThe Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, you can obtain one at https://mozilla.org/MPL/2.0/.';
	@override String get beian => '備案號';
	@override String get copyrightRegisterCode => '著作權登記號';
	@override String get signAndroid => '安卓簽名';
	@override String get title => '關於本軟件';
	@override String get contributors => '貢獻者與致謝';
	@override String get licenses => '開源許可';
	@override String get extras => '更多';
	@override String get buildTime => '構建時間';
	@override String get dami => '開發：修復 iOS 課程偏移負數輸入及輸入校驗';
	@override String get l1angyun => '開發：空閒教室實時顯示、課表背景模糊、課表佈局與屏幕圓角適配；修復校園網數據展示';
	@override String get littlestejan => '開發：校園網驗證碼刷新及驗證碼輸入對話框優化';
	@override String get sixteenforever => '開發：HarmonyOS 移植';
}

// Path: settings.editor
class _Translations$settings$editor$zh_TW extends Translations$settings$editor$zh {
	_Translations$settings$editor$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get save => '保存';
	@override String get apply => '應用';
	@override String get passwordSet => '已設置';
	@override String get passwordNotSet => '未設置';
	@override String get passwordVisibility => '顯示或隱藏密碼';
	@override String get toggleSign => '切換正負號';
	@override String get positiveNumber => '請輸入大於 0 的整數';
	@override String get electricityUnit => '度';
	@override String get textPreview => '課程安排 · TrainTime PDA · 0123456789';
	@override String get brightness => '亮度';
	@override String get borderOpacity => '邊框不透明度';
	@override String get fillOpacity => '底色不透明度';
	@override String get fillSaturation => '底色飽和度';
	@override String get textSaturation => '文字飽和度';
	@override String get backgroundBlur => '背景模糊程度';
	@override String get year => '年份';
	@override String get semester => '學期';
}

// Path: settings.sections
class _Translations$settings$sections$zh_TW extends Translations$settings$sections$zh {
	_Translations$settings$sections$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get display => '顯示';
	@override String get languageAndText => '語言和文字';
	@override String get home => '首頁';
	@override String get electricity => '電量提醒';
	@override String get timetableAppearance => '課表外觀';
	@override String get semester => '學期與周次';
	@override String get courseData => '課程數據';
}

// Path: settings.navigation
class _Translations$settings$navigation$zh_TW extends Translations$settings$navigation$zh {
	_Translations$settings$navigation$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get uiDescription => '主題、字體、語言與首頁顯示';
	@override String get classtableDescription => '課表外觀、學期與課程數據';
	@override String get accountDescription => '校園服務的賬號與密碼';
	@override String get notificationsDescription => '課前提醒與通知管理';
	@override String get coreDescription => '日誌、緩存清理與退出登錄';
}

// Path: settings.fontSizePage
class _Translations$settings$fontSizePage$zh_TW extends Translations$settings$fontSizePage$zh {
	_Translations$settings$fontSizePage$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get sizeTitle => '字體大小';
	@override String get weightTitle => '字體粗細';
	@override String get previewTitle => '預覽';
	@override String get weightThin => '細';
	@override String get weightRegular => '常規';
	@override String get weightMedium => '中等';
	@override String get weightSemibold => '半粗';
	@override String get weightBold => '加粗';
	@override String summary({required Object scale, required Object weight}) => '${scale}% · ${weight}';
}

// Path: settings.classTableStylePage
class _Translations$settings$classTableStylePage$zh_TW extends Translations$settings$classTableStylePage$zh {
	_Translations$settings$classTableStylePage$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get frostedSection => '毛玻璃背景';
	@override String get frostedEnabled => '啟用毛玻璃背景';
	@override String get frostedEnabledHint => '關閉後各控件只保留半透明底色，可省電、更流暢';
	@override String get frostedCardSigma => '課程卡片模糊';
	@override String get frostedTimeLineSigma => '時間軸模糊';
	@override String get frostedDateRowSigma => '日期欄模糊';
	@override String get frostedWeekBarSigma => '周次欄模糊';
	@override String get frostedBannerSigma => '狀態橫幅模糊';
	@override String get frostedAppBarSigma => '導航欄模糊';
	@override String get currentTimeSettingsTitle => '時間指示設置';
	@override String get classColorSettingsTitle => '課表樣式設置';
	@override String get currentTimeSection => '時間指示設置';
	@override String get showCurrentTimeIndicator => '顯示當前時間指示線';
	@override String get showCurrentTimeLabel => '顯示迷你數字時鐘';
	@override String get showTodayColumnHighlight => '強調顯示今天的縱列';
	@override String get activeSection => '課程卡片樣式';
	@override String get unfinishedSection => '課程卡片樣式';
	@override String activeBrightnessFactor({required Object value}) => '亮度: ${value}';
	@override String activeBorderAlpha({required Object value}) => '邊框不透明度: ${value}';
	@override String activeInnerAlpha({required Object value}) => '底色不透明度: ${value}';
	@override String get completedSection => '已結束課程樣式';
	@override String get completedStyleEnabled => '已結束課程樣式區分';
	@override String completedSaturationFactor({required Object value}) => '底色飽和度: ${value}';
	@override String completedBrightnessFactor({required Object value}) => '亮度: ${value}';
	@override String completedTextSaturationFactor({required Object value}) => '文字飽和度: ${value}';
	@override String completedBorderAlpha({required Object value}) => '邊框不透明度: ${value}';
	@override String completedInnerAlpha({required Object value}) => '底色不透明度: ${value}';
}

// Path: core.theme.weight
class _Translations$core$theme$weight$zh_TW extends Translations$core$theme$weight$zh {
	_Translations$core$theme$weight$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get thin => '細';
	@override String get regular => '常規';
	@override String get medium => '中等';
	@override String get semibold => '半粗';
	@override String get bold => '加粗';
}

// Path: core.theme.palette
class _Translations$core$theme$palette$zh_TW extends Translations$core$theme$palette$zh {
	_Translations$core$theme$palette$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get indigo => '默認顏色';
	@override String get blue => '聰明藍';
	@override String get deepPurple => '基佬紫';
	@override String get green => '春風綠';
	@override String get orange => '明日香橙';
	@override String get pink => '櫻花粉';
}

// Path: core.theme.brightness
class _Translations$core$theme$brightness$zh_TW extends Translations$core$theme$brightness$zh {
	_Translations$core$theme$brightness$zh_TW._(TranslationsZhTw root) : this._root = root, super.internal(root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get system => '跟隨系統';
	@override String get light => '淺色';
	@override String get dark => '深色';
}

/// The flat map containing all translations for locale <zh-TW>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsZhTw {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.confirm' => '確認',
			'common.cancel' => '取消',
			'common.unexpectProblemTitle' => '一個小問題 :P',
			'common.unexpectProblemHint' => '這裡有一個沒有被預料的問題發生了！',
			'common.errorDetected' => 'Ouch! 發生錯誤啦',
			'common.clickToRefresh' => '點我刷新',
			'core.language.title' => '語言',
			'core.language.selection' => '應用語言',
			'core.language.system' => '跟隨系統',
			'core.language.simplifiedChinese' => '簡體中文',
			'core.language.traditionalChinese' => '繁體中文',
			'core.language.english' => 'English',
			'core.language.saveFailed' => '無法保存語言設置',
			'core.theme.saveFailed' => '無法保存主題設置',
			'core.theme.display' => '顯示',
			'core.theme.languageAndText' => '文字',
			'core.theme.colorSetting' => '顏色設置',
			'core.theme.brightnessSetting' => '深淺色模式',
			'core.theme.sizeTitle' => '字體大小',
			'core.theme.weightTitle' => '字體粗細',
			'core.theme.weight.thin' => '細',
			'core.theme.weight.regular' => '常規',
			'core.theme.weight.medium' => '中等',
			'core.theme.weight.semibold' => '半粗',
			'core.theme.weight.bold' => '加粗',
			'core.theme.palette.indigo' => '默認顏色',
			'core.theme.palette.blue' => '聰明藍',
			'core.theme.palette.deepPurple' => '基佬紫',
			'core.theme.palette.green' => '春風綠',
			'core.theme.palette.orange' => '明日香橙',
			'core.theme.palette.pink' => '櫻花粉',
			'core.theme.brightness.system' => '跟隨系統',
			'core.theme.brightness.light' => '淺色',
			'core.theme.brightness.dark' => '深色',
			'core.gridPage.label' => '校園信息',
			'core.gridPage.title' => '校園信息查詢',
			'core.gridPage.editMode' => '編輯佈局',
			'core.gridPage.editDone' => '完成',
			'core.gridPage.editReset' => '恢復默認佈局',
			'core.gridPage.manageHidden' => '管理隱藏卡片',
			'core.gridPage.hideEmpty' => '沒有隱藏的卡片',
			'settings.title' => '設置',
			'settings.aboutInfo' => '程序信息',
			'settings.acknowledgement' => ({required Object developers}) => 'Made With Love From ${developers} People',
			'settings.about' => '關於',
			'settings.aboutThisProgram' => '關於本程序',
			'settings.version' => ({required Object version}) => '版本號：${version}',
			'settings.userInfo' => '用戶信息',
			'settings.checkUpdate' => '檢查軟件更新',
			'settings.latestVersion' => ({required Object latest}) => '最新版本: ${latest}',
			'settings.waiting' => '等待獲取',
			'settings.fetchingUpdate' => '正在獲取更新信息',
			'settings.newVersion' => '有新版本發佈，請立刻更新！',
			'settings.currentStable' => '目前您正在運行最新版',
			'settings.currentTesting' => '目前您正在運行測試版',
			'settings.fetchFailed' => '獲取更新信息失敗',
			'settings.uiSetting' => '界面設置',
			'settings.brightnessSetting' => '深淺色模式',
			'settings.colorSetting' => '顏色設置',
			'settings.simplifyTimeline' => '簡化日程時間軸',
			'settings.simplifyTimelineDescription' => '沒有日程時 減少空間佔用',
			'settings.lowElectricityWarning' => '低電量卡片變色提醒',
			'settings.lowElectricityWarningDescription' => '電量小於閾值時 電量卡片變色提醒',
			'settings.lowElectricityThreshold' => '低電量閾值',
			'settings.lowElectricityThresholdDescription' => ({required Object threshold}) => '當前為 ${threshold} 度',
			'settings.lowElectricityThresholdDialog.title' => '設置低電量閾值',
			'settings.lowElectricityThresholdDialog.inputHint' => '請輸入電量度數',
			'settings.accountSetting' => '賬號設置',
			'settings.sportPasswordSetting' => '體育系統密碼設置',
			'settings.experimentPasswordSetting' => '物理實驗系統密碼設置',
			'settings.electricityPasswordSetting' => '電費帳號密碼設置',
			'settings.electricityPasswordDescription' => '非 123456 請設置',
			'settings.electricityAccountSetting' => '電費賬號設置',
			'settings.schoolnetPasswordSetting' => '校園網帳號密碼設置',
			'settings.schoolnetPasswordDescription' => '不設置查看不了網費',
			'settings.airconImeiTitle' => '空調設備',
			'settings.airconImei' => '空調 IMEI',
			'settings.airconImeiNotSet' => '未設置，無法查詢或遙控空調',
			'settings.airconImeiCurrent' => ({required Object imei}) => '當前 IMEI：${imei}',
			'settings.airconImeiSaved' => '空調 IMEI 已保存',
			'settings.airconImeiCleared' => '空調 IMEI 已清除',
			'settings.airconImeiInvalid' => '沒有識別到有效的 15 位 IMEI',
			'settings.airconImeiClear' => '清除',
			'settings.scanAirconQr' => '掃描空調二維碼',
			'settings.pickAirconQrImage' => '從相冊選擇二維碼圖片',
			'settings.airconCameraUnavailable' => '當前平臺不支持相機掃碼，請選擇二維碼圖片或手動輸入 IMEI',
			'settings.airconScanHint' => '輕點畫面可以對焦；空調離得遠、放大後仍然模糊時，請用系統相機拍照識別',
			'settings.airconTakePhoto' => '用系統相機拍照識別',
			'settings.airconCameraError' => ({required Object error}) => '無法打開相機：${error}',
			'settings.notificationSetting' => '通知設置',
			'settings.courseReminderSetting' => '課前通知設置',
			'settings.courseReminderDescription' => '設置課前提醒通知',
			'settings.notificationPage.title' => '課前通知設置',
			'settings.notificationPage.loadFailed' => ({required Object error}) => '加載設置失敗: ${error}',
			'settings.notificationPage.functionSection' => '通知功能',
			'settings.notificationPage.enableNotification' => '啟用課前通知',
			'settings.notificationPage.notificationScheduled' => ({required Object count}) => '已安排 ${count} 個通知',
			'settings.notificationPage.notificationDisabledHint' => '關閉後將取消所有已安排的通知',
			'settings.notificationPage.updateSchedule' => '更新通知日程',
			'settings.notificationPage.updateScheduleHint' => '根據最新的課程數據重新安排通知',
			'settings.notificationPage.viewTheInstructions' => '查看使用說明',
			'settings.notificationPage.viewTheInstructionsHint' => '查看更多使用說明確保您能看到程序發出的通知',
			'settings.notificationPage.deleteAllSchedule' => '刪除通知日程',
			'settings.notificationPage.deleteAllScheduleHint' => '這個操作會刪除所有已經安排的日程，但是您可以再次點擊更新通知日程來重新添加',
			'settings.notificationPage.deleteAllSuccess' => '刪除操作成功',
			'settings.notificationPage.permissionSection' => '權限狀態',
			'settings.notificationPage.notificationPermission' => '通知權限',
			'settings.notificationPage.exactAlarmPermission' => '精確時鐘權限',
			'settings.notificationPage.permissionGranted' => '已授予',
			'settings.notificationPage.permissionDenied' => '未授予',
			'settings.notificationPage.requestPermission' => '請求權限',
			'settings.notificationPage.systemSettings' => '系統通知設置',
			'settings.notificationPage.systemSettingsHint' => '打開系統設置檢查通知配置',
			'settings.notificationPage.permissionGrantedMsg' => '權限已授予',
			'settings.notificationPage.permissionDeniedMsg' => '權限被拒絕，請在系統設置中開啟',
			'settings.notificationPage.reminderSection' => '提醒設置',
			'settings.notificationPage.experimentReminder' => '將物理實驗加入課程提醒',
			'settings.notificationPage.experimentReminderHint' => '將物理實驗的時間安排一併加入課前提醒系統',
			'settings.notificationPage.minutesBefore' => '提前提醒時間',
			'settings.notificationPage.minutesBeforeHint' => '課前提前提醒的時間設置',
			'settings.notificationPage.minutesUnit' => '分鐘',
			'settings.notificationPage.daysToSchedule' => '計劃通知天數',
			'settings.notificationPage.daysToScheduleHint' => '本程序是提前將課程信息寫入計劃日程，該設置可調整寫入計劃日程的天數',
			'settings.notificationPage.daysUnit' => '天',
			'settings.notificationPage.settingsGuideTitle' => '通知設置提示',
			'settings.notificationPage.settingsGuideContent1' => '為了確保您能及時收到課前提醒，請確保：\n1. 開啟了應用的通知權限\n2. 開啟了通知的聲音提示\n3. 開啟了懸浮通知（橫幅通知）\n4. 非原生安卓用戶，開啟自啟動和關閉電源優化',
			'settings.notificationPage.settingsGuideContent2' => '課前提醒模塊運行機制：\n1. 首次開啟時自動安排未來幾天的課前提醒\n2. 每次打開應用時自動檢查並更新通知日程\n3. 修改設置後自動重新安排所有通知',
			'settings.notificationPage.gotIt' => '知道了',
			'settings.notificationPage.openSettings' => '打開系統設置',
			'settings.notificationPage.noClasstableData' => '請先獲取課程表、考試或實驗數據',
			'settings.notificationPage.scheduleSuccess' => ({required Object count}) => '已安排 ${count} 個課前提醒',
			'settings.notificationPage.scheduleFailed' => ({required Object error}) => '安排通知失敗: ${error}',
			'settings.notificationPage.cancelAllSuccess' => '已取消所有課前提醒',
			'settings.notificationPage.rescheduleSuccess' => ({required Object count}) => '已重新安排 ${count} 個課前提醒',
			'settings.notificationPage.rescheduleFailed' => ({required Object error}) => '重新安排通知失敗: ${error}',
			'settings.notificationDebugPage' => '通知狀態與測試',
			'settings.classtableSetting' => '課表相關設置',
			'settings.background' => '開啟課表背景圖',
			'settings.noBackground' => '你先選個圖片罷，就在下面',
			'settings.chooseBackground' => '課表背景圖選擇',
			'settings.noPermission' => '未獲取存儲權限，無法讀取文件',
			'settings.successfulSetting' => '設定成功',
			'settings.failureSetting' => '你沒有選圖片捏',
			'settings.clearUserClass' => '清除所有用戶添加課程',
			'settings.clearUserClassTitle' => '確認對話框',
			'settings.clearUserClassContent' => '是否要清除所有用戶添加課程？這個功能對從學校獲取的日程沒有影響。',
			'settings.clearUserClassClear' => '已經清除完畢',
			'settings.classRefresh' => '強制刷新課表',
			'settings.classRefreshTitle' => '確認對話框',
			'settings.classRefreshContent' => '是否要強制刷新課表？同意後，將會從學校一站式後端重新獲取課表，耗時會比較久。',
			'settings.classSwift' => '課程偏移設置',
			'settings.classSwiftDescription' => ({required Object swift}) => '目前為 ${swift}',
			'settings.coreSetting' => '緩存登錄設置',
			'settings.checkLogger' => '查看網絡攔截器和日誌',
			'settings.clearAndRestart' => '清除緩存後重啟',
			'settings.clearAndRestartDialog.title' => '確認對話框',
			'settings.clearAndRestartDialog.content' => '確定清除緩存後重啟程序？',
			'settings.clearAndRestartDialog.cleaning' => '正在清理緩存',
			'settings.clearAndRestartDialog.clear' => '緩存已被清除',
			'settings.logout' => '退出登錄並重啟應用',
			'settings.logoutDialog.title' => '確認對話框',
			'settings.logoutDialog.content' => '確定退出登錄？你的所有數據將會被徹底刪除！',
			'settings.logoutDialog.loggingOut' => '正在退出登錄',
			'settings.needCloseDialog.title' => '請關閉應用',
			'settings.needCloseDialog.content' => '因為技術限制，用戶需要自行關閉窗口，然後重新打開應用。',
			'settings.changeColorDialog.title' => '顏色設置',
			'settings.changeColorDialog.kDefault' => '默認顏色',
			'settings.changeColorDialog.blue' => '聰明藍',
			'settings.changeColorDialog.deepPurple' => '基佬紫',
			'settings.changeColorDialog.green' => '春風綠',
			'settings.changeColorDialog.orange' => '明日香橙',
			'settings.changeColorDialog.pink' => '櫻花粉',
			'settings.changeBrightnessDialog.title' => '亮度設置',
			'settings.changeBrightnessDialog.followSetting' => '跟隨系統',
			'settings.changeBrightnessDialog.dayMode' => '淺色',
			'settings.changeBrightnessDialog.nightMode' => '深色',
			'settings.changeSwiftDialog.title' => '課程偏移設置',
			'settings.changeSwiftDialog.inputHint' => '請在此輸入數字',
			'settings.changeSwiftDialog.invalidNumber' => '請輸入有效的整數',
			'settings.changeElectricityTitle' => '修改電費帳號',
			'settings.changeElectricityAccount.title' => '修改電費帳號',
			'settings.changeElectricityAccount.campus' => '校區',
			'settings.changeElectricityAccount.northCampus' => '北校區',
			'settings.changeElectricityAccount.southCampus' => '南校區',
			'settings.changeElectricityAccount.unitOrZone' => '單元/區號',
			'settings.changeElectricityAccount.unitCode' => '單元號',
			'settings.changeElectricityAccount.zoneCode' => '區號',
			'settings.changeElectricityAccount.pleaseInput' => ({required Object unit_or_zone_code}) => '請輸入${unit_or_zone_code}',
			'settings.changeElectricityAccount.successfulFetch' => ({required Object account_number}) => '賬號獲取成功：${account_number}',
			'settings.changeElectricityAccount.failedFetch' => ({required Object e}) => '獲取失敗：${e}',
			'settings.changeElectricityAccount.accountSaved' => ({required Object account_number}) => '賬號已保存：${account_number}',
			'settings.changeElectricityAccount.unknownCodingPattern' => '該樓號編碼規則未知',
			'settings.changeElectricityAccount.selectBuilding' => '選擇樓棟',
			'settings.changeElectricityAccount.building' => '樓棟',
			'settings.changeElectricityAccount.northernBuilding' => '北棟',
			'settings.changeElectricityAccount.southernBuilding' => '南棟',
			'settings.changeElectricityAccount.failedGenerate' => ({required Object e}) => '生成失敗：${e}',
			'settings.changeElectricityAccount.buildingNumber' => '樓號',
			'settings.changeElectricityAccount.buildingNumberHint' => '例如: 16, 7, 55',
			'settings.changeElectricityAccount.buildingNumberQuery' => '請輸入樓號',
			'settings.changeElectricityAccount.yard' => '院區',
			'settings.changeElectricityAccount.yardHint' => '選擇院區',
			'settings.changeElectricityAccount.northYard' => '北院',
			'settings.changeElectricityAccount.southYard' => '南院',
			'settings.changeElectricityAccount.yardQuery' => '請選擇院區',
			'settings.changeElectricityAccount.apartment' => '樓棟',
			'settings.changeElectricityAccount.apartmentHint' => '選擇樓棟',
			'settings.changeElectricityAccount.northApartment' => '北樓',
			'settings.changeElectricityAccount.southApartment' => '南樓',
			'settings.changeElectricityAccount.apartmentQuery' => '請選擇樓棟',
			'settings.changeElectricityAccount.levelCode' => '層號',
			'settings.changeElectricityAccount.levelCodeQuery' => '請輸入層號',
			'settings.changeElectricityAccount.roomCode' => '房間號',
			'settings.changeElectricityAccount.roomCodeHint' => '例如: 304, 508',
			'settings.changeElectricityAccount.roomCodeQuery' => '請輸入房間號',
			'settings.changeElectricityAccount.account' => '電費賬號',
			'settings.changeElectricityAccount.accountHint' => '請輸入或從網絡獲取',
			'settings.changeElectricityAccount.accountQuery' => '請輸入電費賬號',
			'settings.changeElectricityAccount.accountLength' => '賬號長度通常不小於10位',
			'settings.changeElectricityAccount.fetching' => '正在獲取...',
			'settings.changeElectricityAccount.fetchFromInternet' => '從網絡同步',
			'settings.changeElectricityAccount.saveAccount' => '保存賬號',
			'settings.changeElectricityAccount.confirmSaving' => '確認保存',
			'settings.changeElectricityAccount.calculateAccount' => '計算賬號',
			'settings.changeElectricityAccount.calculate' => '計算',
			'settings.changeElectricityAccount.input' => '輸入',
			'settings.changeElectricityAccount.confirmAccount' => '請確認賬號：',
			'settings.changeElectricityAccount.change' => '修改',
			'settings.changeElectricityAccount.cancel' => '取消',
			'settings.changeElectricityAccount.noSetting' => '未設置新的電費賬號',
			'settings.changeElectricityAccount.successfulSetting' => '已設置新的電費賬號',
			'settings.changeExperimentTitle' => '修改物理實驗賬號密碼',
			'settings.changeSportTitle' => '修改體育系統賬號密碼',
			'settings.changePasswordDialog.inputHint' => '請在此輸入密碼',
			'settings.changePasswordDialog.blankInput' => '輸入空白!',
			'settings.changeSchoolnetPasswordTitle' => '修改校園網查詢帳號密碼',
			'settings.updateDialog.newVersion' => '新版本發佈',
			'settings.updateDialog.notNow' => '暫不更新',
			'settings.updateDialog.appStore' => 'App Store 更新',
			'settings.updateDialog.downloadApk' => '下載安裝包',
			'settings.updateDialog.githubRelease' => '去 Git Release',
			'settings.updateDialog.newContent' => ({required Object code}) => '版本號 ${code} 新增內容：\n',
			'settings.localizationDialog.title' => '修改語言',
			'settings.localizationDialog.undefined' => '追隨系統設置',
			'settings.localizationDialog.simplifiedChinese' => '簡體中文',
			'settings.localizationDialog.traditionalChinese' => '繁體中文',
			'settings.localizationDialog.english' => '英語',
			'settings.semesterChange' => '修改學期',
			'settings.semesterChangeDescription' => ({required Object semester}) => '使用學期 ${semester}',
			'settings.semesterUpdateData' => '應用新學期設置中',
			'settings.easterEggPage' => '你找到了彩蛋',
			'settings.aboutPage.benderblog' => '主要開發者，iOS 小部件編寫和拼接',
			'settings.aboutPage.alnair' => '開發：圖書館搜索和封面、圖書館佈局修復、飲水機接水功能及接口適配',
			'settings.aboutPage.aqqkad' => '開發：考勤歷史記錄、空調遙控、空調電費數據接入、圖書館新接口適配',
			'settings.aboutPage.bellssgit' => '支持：最佳&最久故障反饋者',
			'settings.aboutPage.brackrat' => '設計：主頁，登錄頁，配色，iOS 小部件等',
			'settings.aboutPage.breezeline' => '支持：無價值無意義的產品經理(他自己的描述)',
			'settings.aboutPage.cafebabe' => '支持：提供彩蛋代碼 / 開發：2026版本滑塊驗證碼適配',
			'settings.aboutPage.chitao1234' => '開發：修復滑塊不對齊問題',
			'settings.aboutPage.copperkoi' => '開發：系統日曆最新課表同步',
			'settings.aboutPage.dimole' => '開發支持：輔助修復滑塊問題',
			'settings.aboutPage.elitewars' => '設計：體育成績頁面',
			'settings.aboutPage.elliot' => '國際化：軟件英語翻譯 / 開發指導：情侶課表功能開發指導（該功能已經被移除）',
			'settings.aboutPage.flyingpig' => '開發：修復自定義課程編輯頁的空指針異常',
			'settings.aboutPage.godhu777777' => '國際化：繁體中文轉換代碼和彩蛋代碼 / 開發：優化導出日曆文件大小',
			'settings.aboutPage.hancl777' => '國際化：繁體中文轉換代碼',
			'settings.aboutPage.hazukiKeatsu' => '開發：物理實驗成績查詢和識別',
			'settings.aboutPage.hawa130' => '設計：課程詳情卡片',
			'settings.aboutPage.hhzm' => '開發：電費查詢賬號計算',
			'settings.aboutPage.imaginary17' => '開發：睿思論壇路由修復',
			'settings.aboutPage.imoscarz' => '開發：設計軟件主頁 / 開發：平板考勤查詢頁面 / 開發：優化了體育查詢界面的UI / 開發：設置頁面分類重構及主從佈局適配',
			'settings.aboutPage.kaMateKaOra' => '國際化：軟件英語翻譯優化',
			'settings.aboutPage.lagrangeX' => '開發：課程表時間進度展示（終版方案） / 開發：課程表上過課程灰度化和其他課程界面特性',
			'settings.aboutPage.lhx666Cool' => '支持：Windows 和 Linux 構建腳本 / 開發：2026版本滑塊驗證碼適配',
			'settings.aboutPage.lichtyy' => '設計：配色，空白頁面貼圖 / 開發：實驗系統頁面讀取代碼',
			'settings.aboutPage.lqsyH' => '支持：推文宣傳圖片製作',
			'settings.aboutPage.lsy223622' => '設計：iOS 和 Android 圖標 / 支持：冠名 XDYou',
			'settings.aboutPage.mrbrilliant2046' => '支持：提供網絡服務使用說明文檔 / 國際化：優化英語翻譯',
			'settings.aboutPage.nancunchild' => '開發：圖書館搜索功能 / 國際化：優化英語翻譯',
			'settings.aboutPage.nkanf' => '開發：課程表時間進度展示（初版方案） / 支持：MacOS 構建支持',
			'settings.aboutPage.pairman' => '開發：成績緩存功能和優化滑塊算法 / 國際化：優化英語翻譯',
			'settings.aboutPage.reverierxu' => '設計：用於信息展示的 ReX 卡片 / 開發支持：研究生課表',
			'settings.aboutPage.rrrilac' => '開發支持：電費查詢',
			'settings.aboutPage.ray' => '設計：開屏畫面 / 支持：iOS 發行商 & 搭子課表 / 開發指導：情侶課表功能開發指導（該功能已經被移除） / 國際化：優化英語翻譯',
			'settings.aboutPage.shadowyingyi' => '支持：兩次鴿子公眾號宣傳',
			'settings.aboutPage.stalomeow' => '設計：首頁時間軸 / 開發：異步登錄 & 驗證碼預測',
			'settings.aboutPage.xeonds' => '設計：設置頁面 / 開發：XDU Planet / 開發：校園卡付款碼',
			'settings.aboutPage.xingshuyu' => '開發：修復物理實驗獲取問題和電費窗口問題',
			'settings.aboutPage.xiue233' => '開發：Android 小部件和拼接',
			'settings.aboutPage.xizi' => '開發支持：研究生版本開發',
			'settings.aboutPage.wirsbf' => '開發：修復調課未按預期進行',
			'settings.aboutPage.zcwzy' => '開發：修復丁香電費 / 開發支持：研究生版本開發 / 設計：空白頁面貼圖',
			'settings.aboutPage.zyarEr' => '開發支持：小工具頁面地址更新',
			'settings.aboutPage.homepage' => '主頁',
			'settings.aboutPage.code' => '開源代碼',
			'settings.aboutPage.knowMore' => '知道更多',
			'settings.aboutPage.copyrightNotice' => '本軟件拷貝基於 traintime_pda 代碼（或稱 watermeter 代碼）編譯或修改，代碼按照 Mozilla Public License, v. 2.0 授權。\n本程序和西安電子科技大學，體適能服務，書蝸，電錶等服務無關。\n本程序代碼版權受中國國家版權局保護，登記號2026SR0738647。\nCopyright 2023-2025 BenderBlog Rodriguez and contributors. Copyright 2025-present Traintime PDA authors.\nThe Copyright of the Software is protected by NCAC, register code is 2026SR0738647\nThe Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, you can obtain one at https://mozilla.org/MPL/2.0/.',
			'settings.aboutPage.beian' => '備案號',
			'settings.aboutPage.copyrightRegisterCode' => '著作權登記號',
			'settings.aboutPage.signAndroid' => '安卓簽名',
			'settings.aboutPage.title' => '關於本軟件',
			'settings.aboutPage.contributors' => '貢獻者與致謝',
			'settings.aboutPage.licenses' => '開源許可',
			'settings.aboutPage.extras' => '更多',
			'settings.aboutPage.buildTime' => '構建時間',
			'settings.aboutPage.dami' => '開發：修復 iOS 課程偏移負數輸入及輸入校驗',
			'settings.aboutPage.l1angyun' => '開發：空閒教室實時顯示、課表背景模糊、課表佈局與屏幕圓角適配；修復校園網數據展示',
			'settings.aboutPage.littlestejan' => '開發：校園網驗證碼刷新及驗證碼輸入對話框優化',
			'settings.aboutPage.sixteenforever' => '開發：HarmonyOS 移植',
			'settings.editor.save' => '保存',
			'settings.editor.apply' => '應用',
			'settings.editor.passwordSet' => '已設置',
			'settings.editor.passwordNotSet' => '未設置',
			'settings.editor.passwordVisibility' => '顯示或隱藏密碼',
			'settings.editor.toggleSign' => '切換正負號',
			'settings.editor.positiveNumber' => '請輸入大於 0 的整數',
			'settings.editor.electricityUnit' => '度',
			'settings.editor.textPreview' => '課程安排 · TrainTime PDA · 0123456789',
			'settings.editor.brightness' => '亮度',
			'settings.editor.borderOpacity' => '邊框不透明度',
			'settings.editor.fillOpacity' => '底色不透明度',
			'settings.editor.fillSaturation' => '底色飽和度',
			'settings.editor.textSaturation' => '文字飽和度',
			'settings.editor.backgroundBlur' => '背景模糊程度',
			'settings.editor.year' => '年份',
			'settings.editor.semester' => '學期',
			'settings.sections.display' => '顯示',
			'settings.sections.languageAndText' => '語言和文字',
			'settings.sections.home' => '首頁',
			'settings.sections.electricity' => '電量提醒',
			'settings.sections.timetableAppearance' => '課表外觀',
			'settings.sections.semester' => '學期與周次',
			'settings.sections.courseData' => '課程數據',
			'settings.navigation.uiDescription' => '主題、字體、語言與首頁顯示',
			'settings.navigation.classtableDescription' => '課表外觀、學期與課程數據',
			'settings.navigation.accountDescription' => '校園服務的賬號與密碼',
			'settings.navigation.notificationsDescription' => '課前提醒與通知管理',
			'settings.navigation.coreDescription' => '日誌、緩存清理與退出登錄',
			'settings.fontSizeSetting' => '字體大小與粗細',
			'settings.fontSizePage.sizeTitle' => '字體大小',
			'settings.fontSizePage.weightTitle' => '字體粗細',
			'settings.fontSizePage.previewTitle' => '預覽',
			'settings.fontSizePage.weightThin' => '細',
			'settings.fontSizePage.weightRegular' => '常規',
			'settings.fontSizePage.weightMedium' => '中等',
			'settings.fontSizePage.weightSemibold' => '半粗',
			'settings.fontSizePage.weightBold' => '加粗',
			'settings.fontSizePage.summary' => ({required Object scale, required Object weight}) => '${scale}% · ${weight}',
			'settings.generalAccountSettings' => '通用賬號',
			'settings.undergraduateSystemAccounts' => '本科生系統賬號',
			'settings.classTableBackgroundSection' => '課表背景',
			'settings.backgroundBlur' => ({required Object value}) => '背景模糊: ${value}',
			'settings.backgroundBlurOff' => '關閉',
			'settings.classTableStyleSetting' => '課表顯示與樣式',
			'settings.classTableStyleDescription' => '時間指示和課程卡片樣式',
			'settings.classTableStylePage.frostedSection' => '毛玻璃背景',
			'settings.classTableStylePage.frostedEnabled' => '啟用毛玻璃背景',
			'settings.classTableStylePage.frostedEnabledHint' => '關閉後各控件只保留半透明底色，可省電、更流暢',
			'settings.classTableStylePage.frostedCardSigma' => '課程卡片模糊',
			'settings.classTableStylePage.frostedTimeLineSigma' => '時間軸模糊',
			'settings.classTableStylePage.frostedDateRowSigma' => '日期欄模糊',
			'settings.classTableStylePage.frostedWeekBarSigma' => '周次欄模糊',
			'settings.classTableStylePage.frostedBannerSigma' => '狀態橫幅模糊',
			'settings.classTableStylePage.frostedAppBarSigma' => '導航欄模糊',
			'settings.classTableStylePage.currentTimeSettingsTitle' => '時間指示設置',
			'settings.classTableStylePage.classColorSettingsTitle' => '課表樣式設置',
			'settings.classTableStylePage.currentTimeSection' => '時間指示設置',
			'settings.classTableStylePage.showCurrentTimeIndicator' => '顯示當前時間指示線',
			'settings.classTableStylePage.showCurrentTimeLabel' => '顯示迷你數字時鐘',
			'settings.classTableStylePage.showTodayColumnHighlight' => '強調顯示今天的縱列',
			'settings.classTableStylePage.activeSection' => '課程卡片樣式',
			'settings.classTableStylePage.unfinishedSection' => '課程卡片樣式',
			'settings.classTableStylePage.activeBrightnessFactor' => ({required Object value}) => '亮度: ${value}',
			'settings.classTableStylePage.activeBorderAlpha' => ({required Object value}) => '邊框不透明度: ${value}',
			'settings.classTableStylePage.activeInnerAlpha' => ({required Object value}) => '底色不透明度: ${value}',
			'settings.classTableStylePage.completedSection' => '已結束課程樣式',
			'settings.classTableStylePage.completedStyleEnabled' => '已結束課程樣式區分',
			'settings.classTableStylePage.completedSaturationFactor' => ({required Object value}) => '底色飽和度: ${value}',
			'settings.classTableStylePage.completedBrightnessFactor' => ({required Object value}) => '亮度: ${value}',
			'settings.classTableStylePage.completedTextSaturationFactor' => ({required Object value}) => '文字飽和度: ${value}',
			'settings.classTableStylePage.completedBorderAlpha' => ({required Object value}) => '邊框不透明度: ${value}',
			'settings.classTableStylePage.completedInnerAlpha' => ({required Object value}) => '底色不透明度: ${value}',
			'settings.classSwiftExplain' => '正數錯後開學日期 負數提前開學日期',
			_ => null,
		};
	}
}
