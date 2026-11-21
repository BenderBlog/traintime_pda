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
	@override late final _Translations$theme$en theme = _Translations$theme$en._(_root);
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

// Path: theme
class _Translations$theme$en extends Translations$theme$zh {
	_Translations$theme$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get saveFailed => 'Unable to save theme settings';
	@override String get display => 'Display';
	@override String get languageAndText => 'Language and text';
	@override String get colorSetting => 'Color theme';
	@override String get brightnessSetting => 'Light/Dark mode';
	@override String get sizeTitle => 'Font size';
	@override String get weightTitle => 'Font weight';
	@override late final _Translations$theme$weight$en weight = _Translations$theme$weight$en._(_root);
	@override late final _Translations$theme$palette$en palette = _Translations$theme$palette$en._(_root);
	@override late final _Translations$theme$brightness$en brightness = _Translations$theme$brightness$en._(_root);
}

// Path: theme.weight
class _Translations$theme$weight$en extends Translations$theme$weight$zh {
	_Translations$theme$weight$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get thin => 'Thin';
	@override String get regular => 'Regular';
	@override String get medium => 'Medium';
	@override String get semibold => 'Semi bold';
	@override String get bold => 'Bold';
}

// Path: theme.palette
class _Translations$theme$palette$en extends Translations$theme$palette$zh {
	_Translations$theme$palette$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get indigo => 'Default';
	@override String get blue => 'Sky Blue';
	@override String get deepPurple => 'Deep Purple';
	@override String get green => 'Spring Green';
	@override String get orange => 'Asuka Orange';
	@override String get pink => 'Sakura Pink';
}

// Path: theme.brightness
class _Translations$theme$brightness$en extends Translations$theme$brightness$zh {
	_Translations$theme$brightness$en._(TranslationsEn root) : this._root = root, super.internal(root);

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
			'theme.saveFailed' => 'Unable to save theme settings',
			'theme.display' => 'Display',
			'theme.languageAndText' => 'Language and text',
			'theme.colorSetting' => 'Color theme',
			'theme.brightnessSetting' => 'Light/Dark mode',
			'theme.sizeTitle' => 'Font size',
			'theme.weightTitle' => 'Font weight',
			'theme.weight.thin' => 'Thin',
			'theme.weight.regular' => 'Regular',
			'theme.weight.medium' => 'Medium',
			'theme.weight.semibold' => 'Semi bold',
			'theme.weight.bold' => 'Bold',
			'theme.palette.indigo' => 'Default',
			'theme.palette.blue' => 'Sky Blue',
			'theme.palette.deepPurple' => 'Deep Purple',
			'theme.palette.green' => 'Spring Green',
			'theme.palette.orange' => 'Asuka Orange',
			'theme.palette.pink' => 'Sakura Pink',
			'theme.brightness.system' => 'Follow system',
			'theme.brightness.light' => 'Light',
			'theme.brightness.dark' => 'Dark',
			_ => null,
		};
	}
}
