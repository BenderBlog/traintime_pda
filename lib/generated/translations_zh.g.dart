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
			_ => null,
		};
	}
}
