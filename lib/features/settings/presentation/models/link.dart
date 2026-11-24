// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/generated/translations.g.dart';

enum LinkName { homepage, code }

class Link {
  final LinkName name;
  final IconData icon;
  final String url;

  const Link({required this.name, required this.icon, required this.url});

  String resolve(Translations t) {
    switch (name) {
      case LinkName.homepage:
        return t.settings.aboutPage.homepage;
      case LinkName.code:
        return t.settings.aboutPage.code;
    }
  }
}
