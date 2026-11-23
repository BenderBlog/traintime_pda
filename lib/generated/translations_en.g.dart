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
class TranslationsEn extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final TranslationsEn _root = this; // ignore: unused_field

	@override 
	TranslationsEn $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEn(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$common$en common = _Translations$common$en._(_root);
	@override late final _Translations$core$en core = _Translations$core$en._(_root);
}

// Path: common
class _Translations$common$en extends Translations$common$zh {
	_Translations$common$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get confirm => 'Confirm';
	@override String get cancel => 'Cancel';
	@override String get unexpectProblemTitle => 'Unexpected problem :P';
	@override String get unexpectProblemHint => 'An unexpected behavior occurred!';
}

// Path: core
class _Translations$core$en extends Translations$core$zh {
	_Translations$core$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$core$language$en language = _Translations$core$language$en._(_root);
	@override late final _Translations$core$theme$en theme = _Translations$core$theme$en._(_root);
	@override late final _Translations$core$gridPage$en gridPage = _Translations$core$gridPage$en._(_root);
}

// Path: core.language
class _Translations$core$language$en extends Translations$core$language$zh {
	_Translations$core$language$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Language';
	@override String get selection => 'App language';
	@override String get system => 'Follow system';
	@override String get simplifiedChinese => '简体中文';
	@override String get traditionalChinese => '繁體中文';
	@override String get english => 'English';
	@override String get saveFailed => 'Unable to save language setting';
}

// Path: core.theme
class _Translations$core$theme$en extends Translations$core$theme$zh {
	_Translations$core$theme$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get saveFailed => 'Unable to save theme settings';
	@override String get display => 'Display';
	@override String get languageAndText => 'Text';
	@override String get colorSetting => 'Color theme';
	@override String get brightnessSetting => 'Light/Dark mode';
	@override String get sizeTitle => 'Font size';
	@override String get weightTitle => 'Font weight';
	@override late final _Translations$core$theme$weight$en weight = _Translations$core$theme$weight$en._(_root);
	@override late final _Translations$core$theme$palette$en palette = _Translations$core$theme$palette$en._(_root);
	@override late final _Translations$core$theme$brightness$en brightness = _Translations$core$theme$brightness$en._(_root);
}

// Path: core.gridPage
class _Translations$core$gridPage$en extends Translations$core$gridPage$zh {
	_Translations$core$gridPage$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get label => 'Info';
	@override String get title => 'School Info Center';
	@override String get editMode => 'Edit Layout';
	@override String get editDone => 'Done';
	@override String get editReset => 'Reset Layout';
	@override String get manageHidden => 'Manage hidden cards';
	@override String get hideEmpty => 'No hidden cards';
}

// Path: core.theme.weight
class _Translations$core$theme$weight$en extends Translations$core$theme$weight$zh {
	_Translations$core$theme$weight$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get thin => 'Thin';
	@override String get regular => 'Regular';
	@override String get medium => 'Medium';
	@override String get semibold => 'Semi bold';
	@override String get bold => 'Bold';
}

// Path: core.theme.palette
class _Translations$core$theme$palette$en extends Translations$core$theme$palette$zh {
	_Translations$core$theme$palette$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get indigo => 'Default';
	@override String get blue => 'Sky Blue';
	@override String get deepPurple => 'Deep Purple';
	@override String get green => 'Spring Green';
	@override String get orange => 'Asuka Orange';
	@override String get pink => 'Sakura Pink';
}

// Path: core.theme.brightness
class _Translations$core$theme$brightness$en extends Translations$core$theme$brightness$zh {
	_Translations$core$theme$brightness$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get system => 'Follow system';
	@override String get light => 'Light';
	@override String get dark => 'Dark';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEn {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.confirm' => 'Confirm',
			'common.cancel' => 'Cancel',
			'common.unexpectProblemTitle' => 'Unexpected problem :P',
			'common.unexpectProblemHint' => 'An unexpected behavior occurred!',
			'core.language.title' => 'Language',
			'core.language.selection' => 'App language',
			'core.language.system' => 'Follow system',
			'core.language.simplifiedChinese' => '简体中文',
			'core.language.traditionalChinese' => '繁體中文',
			'core.language.english' => 'English',
			'core.language.saveFailed' => 'Unable to save language setting',
			'core.theme.saveFailed' => 'Unable to save theme settings',
			'core.theme.display' => 'Display',
			'core.theme.languageAndText' => 'Text',
			'core.theme.colorSetting' => 'Color theme',
			'core.theme.brightnessSetting' => 'Light/Dark mode',
			'core.theme.sizeTitle' => 'Font size',
			'core.theme.weightTitle' => 'Font weight',
			'core.theme.weight.thin' => 'Thin',
			'core.theme.weight.regular' => 'Regular',
			'core.theme.weight.medium' => 'Medium',
			'core.theme.weight.semibold' => 'Semi bold',
			'core.theme.weight.bold' => 'Bold',
			'core.theme.palette.indigo' => 'Default',
			'core.theme.palette.blue' => 'Sky Blue',
			'core.theme.palette.deepPurple' => 'Deep Purple',
			'core.theme.palette.green' => 'Spring Green',
			'core.theme.palette.orange' => 'Asuka Orange',
			'core.theme.palette.pink' => 'Sakura Pink',
			'core.theme.brightness.system' => 'Follow system',
			'core.theme.brightness.light' => 'Light',
			'core.theme.brightness.dark' => 'Dark',
			'core.gridPage.label' => 'Info',
			'core.gridPage.title' => 'School Info Center',
			'core.gridPage.editMode' => 'Edit Layout',
			'core.gridPage.editDone' => 'Done',
			'core.gridPage.editReset' => 'Reset Layout',
			'core.gridPage.manageHidden' => 'Manage hidden cards',
			'core.gridPage.hideEmpty' => 'No hidden cards',
			_ => null,
		};
	}
}
