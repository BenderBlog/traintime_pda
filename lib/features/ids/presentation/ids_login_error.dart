// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/widgets.dart';
import 'package:pda_repository/pda_repository.dart';
import 'package:watermeter/generated/translations.g.dart';

String idsLoginErrorMessage(BuildContext context, Object? error) =>
    switch (error) {
      IdsCredentialsRejected() => context.t.ids.credentialsRejected,
      IdsServiceUnavailable() => context.t.ids.networkUnavailable,
      IdsInteractionCancelled() => context.t.ids.loginCancelled,
      _ => context.t.ids.loginFailed,
    };
