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
			_ => null,
		};
	}
}
