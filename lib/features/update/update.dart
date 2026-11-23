// Copyright 2026 Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:pda_repository/pda_repository.dart';

import 'application/update_checker.dart';
import 'presentation/update_card.dart';
import 'presentation/update_section.dart';

final class UpdateFeature {
  UpdateFeature(UpdateRepository repository, {required String localVersion})
    : _checker = UpdateChecker(repository, localVersion: localVersion);

  final UpdateChecker _checker;

  UpdateCard get card => UpdateCard(_checker);
  UpdateSection get section => UpdateSection(_checker);

  Future<void> start() async => await _checker.check();

  void dispose() => _checker.dispose();
}
