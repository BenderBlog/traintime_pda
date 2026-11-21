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
	late final Translations$theme$zh theme = Translations$theme$zh.internal(_root);
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

// Path: theme
class Translations$theme$zh {
	Translations$theme$zh.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// zh: '无法保存主题设置'
	String get saveFailed => '无法保存主题设置';

	/// zh: '显示'
	String get display => '显示';

	/// zh: '语言和文字'
	String get languageAndText => '语言和文字';

	/// zh: '颜色设置'
	String get colorSetting => '颜色设置';

	/// zh: '深浅色模式'
	String get brightnessSetting => '深浅色模式';

	/// zh: '字体大小'
	String get sizeTitle => '字体大小';

	/// zh: '字体粗细'
	String get weightTitle => '字体粗细';

	late final Translations$theme$weight$zh weight = Translations$theme$weight$zh.internal(_root);
	late final Translations$theme$palette$zh palette = Translations$theme$palette$zh.internal(_root);
	late final Translations$theme$brightness$zh brightness = Translations$theme$brightness$zh.internal(_root);
}

// Path: theme.weight
class Translations$theme$weight$zh {
	Translations$theme$weight$zh.internal(this._root);

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

// Path: theme.palette
class Translations$theme$palette$zh {
	Translations$theme$palette$zh.internal(this._root);

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

// Path: theme.brightness
class Translations$theme$brightness$zh {
	Translations$theme$brightness$zh.internal(this._root);

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
			'theme.saveFailed' => '无法保存主题设置',
			'theme.display' => '显示',
			'theme.languageAndText' => '语言和文字',
			'theme.colorSetting' => '颜色设置',
			'theme.brightnessSetting' => '深浅色模式',
			'theme.sizeTitle' => '字体大小',
			'theme.weightTitle' => '字体粗细',
			'theme.weight.thin' => '细',
			'theme.weight.regular' => '常规',
			'theme.weight.medium' => '中等',
			'theme.weight.semibold' => '半粗',
			'theme.weight.bold' => '加粗',
			'theme.palette.indigo' => '默认颜色',
			'theme.palette.blue' => '聪明蓝',
			'theme.palette.deepPurple' => '基佬紫',
			'theme.palette.green' => '春风绿',
			'theme.palette.orange' => '明日香橙',
			'theme.palette.pink' => '樱花粉',
			'theme.brightness.system' => '跟随系统',
			'theme.brightness.light' => '浅色',
			'theme.brightness.dark' => '深色',
			_ => null,
		};
	}
}
