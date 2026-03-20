// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class DormWaterWindow extends StatelessWidget {
  const DormWaterWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "homepage.toolbox.dorm_water")),
      ),
      body: const SizedBox.shrink(),
    );
  }
}
