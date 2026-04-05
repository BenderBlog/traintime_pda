// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:signals/signals_flutter.dart';
import 'package:watermeter/repository/xidian_sport_session.dart';

class SportController {
  static final i = SportController._();

  SportController._();

  late final sportScoreSignal = futureSignal(() => SportSession().getScore());
  late final sportClassSignal = futureSignal(() => SportSession().getClass());
}
