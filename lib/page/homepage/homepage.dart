/*
Home window.
Copyright 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

*/

import 'package:flutter/material.dart';
import 'package:watermeter/page/homepage/pad_main_page.dart';
import 'package:watermeter/page/homepage/phone_main_page.dart';
import 'package:watermeter/page/widget.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return isPhone(context) ? const PhoneMainPage() : const PadMainPage();
  }
}
