// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:pda_repository/pda_repository.dart';
import 'package:watermeter/features/update/presentation/update_tile.widget.dart';

import 'update_checker.case.dart';
import 'presentation/update_card.widget.dart';

final class UpdateFeature {
  UpdateFeature(UpdateRepository repository, {required String localVersion})
    : _checker = UpdateChecker(repository, localVersion: localVersion);

  final UpdateChecker _checker;

  UpdateCard get card => UpdateCard(_checker);
  ListTile tile(BuildContext context) => updateTile(context, _checker);

  Future<void> start() async => await _checker.check();

  void dispose() => _checker.dispose();
}
