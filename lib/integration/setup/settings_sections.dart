// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/core/presentation/settings_page/settings_page_section_interface.dart';
import 'package:watermeter/features/ids/ids.dart';
import 'package:watermeter/features/settings/presentation/tiles/about_tile.dart';
import 'package:watermeter/features/settings/presentation/tiles/talker_tile.dart';
import 'package:watermeter/features/update/update.dart';
import 'package:watermeter/generated/application_version.g.dart';

class AboutSection implements SettingsPageSectionInterface {
  const AboutSection({required this.updateFeature, required this.appInfo});

  final UpdateFeature updateFeature;
  final PackageApplicationInfo appInfo;

  @override
  IconData? icon() => null;

  @override
  List<SettingsPageSectionEntry> items(BuildContext context) => <ListTile>[
    aboutTile(context, appInfo),
    updateFeature.tile(context),
  ];

  @override
  String? title() => null;
}

class CoreSection implements SettingsPageSectionInterface {
  const CoreSection({required this.talker, required this.idsUseCase});

  final Talker talker;
  final IdsUseCase idsUseCase;

  @override
  IconData? icon() => null;

  @override
  List<SettingsPageSectionEntry> items(BuildContext context) => <ListTile>[
    talkerTile(context, talker),
    idsLogoutTile(context, idsUseCase),
  ];

  @override
  String? title() => null;
}
