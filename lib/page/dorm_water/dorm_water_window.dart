// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class DormWaterWindow extends StatefulWidget {
  const DormWaterWindow({super.key});

  @override
  State<DormWaterWindow> createState() => _DormWaterWindowState();
}

class _DormWaterWindowState extends State<DormWaterWindow> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _imageCodeController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _imageCodeController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "dorm_water.title")),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            FlutterI18n.translate(context, "dorm_water.login_hint"),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: FlutterI18n.translate(context, "dorm_water.phone"),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _imageCodeController,
            decoration: InputDecoration(
              labelText: FlutterI18n.translate(context, "dorm_water.image_code"),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _smsCodeController,
            decoration: InputDecoration(
              labelText: FlutterI18n.translate(context, "dorm_water.sms_code"),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () {},
                  child: Text(
                    FlutterI18n.translate(context, "dorm_water.send_sms"),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: () {},
                  child: Text(
                    FlutterI18n.translate(context, "dorm_water.login"),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
