// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/library_controller.dart';
import 'package:watermeter/controller/school_card_controller.dart';
import 'package:watermeter/controller/score_controller.dart';
import 'package:watermeter/page/homepage/pad_main_page.dart';
import 'package:watermeter/page/homepage/phone_main_page.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ScoreController());
    Get.put(ClassTableController());
    Get.put(ExamController());
    Get.put(LibraryController());
    Get.put(SchoolCardController());
    return isPhone(context) ? const PhoneMainPage() : const PadMainPage();
  }
}
