// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:signals/signals.dart';

enum AppLanguage { system, simplifiedChinese, traditionalChinese, english }

abstract interface class LanguageStoreInterface {
  ReadonlySignal<AppLanguage> get language;
  Future<void> setLanguage(AppLanguage language);
  void dispose();
}
