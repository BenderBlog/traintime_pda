// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/generated/translations.g.dart';

class Developer {
  final String name;
  final String imageUrl;
  final String Function(Translations t) description;
  final String url;
  const Developer(this.name, this.imageUrl, this.description, this.url);
}
