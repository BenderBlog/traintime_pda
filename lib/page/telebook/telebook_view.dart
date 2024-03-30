// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/model/telephone.dart';
import 'package:watermeter/page/public_widget/split_view.dart';
import 'package:watermeter/repository/telephone.dart';
import 'package:url_launcher/url_launcher_string.dart';

var list = getTelephoneData();

/// Intro of the telephone book (address book if you want).
class TeleBookWindow extends StatelessWidget {
  const TeleBookWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("电话本"),
        leading: IconButton(
          icon: Icon(
            Platform.isIOS || Platform.isMacOS
                ? Icons.arrow_back_ios
                : Icons.arrow_back,
          ),
          onPressed: () => SplitView.of(context).pop(),
        ),
      ),
      body: DataList(
        list: list,
        initFormula: (a) => DepartmentWindow(toUse: a),
      ),
    );
  }
}

/// Each entry of the telephone book is shown in a card,
/// which stored in an information class called [TeleyInformation].
class DepartmentWindow extends StatelessWidget {
  final TeleyInformation toUse;
  final List<Widget> mainCourse = [];

  DepartmentWindow({super.key, required this.toUse}) {
    if (toUse.isNorth == true) {
      mainCourse.add(InsideWindow(
        address: toUse.northAddress,
        phone: toUse.northTeley,
      ));
    }
    if (toUse.isSouth == true) {
      mainCourse.add(
        InsideWindow(
          address: toUse.southAddress,
          phone: toUse.southTeley,
          isSouth: true,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int crossItems = max(MediaQuery.sizeOf(context).width ~/ 376, 1);

    int rowItem(int length) {
      int rowItem = length ~/ crossItems;
      if (crossItems * rowItem < length) {
        rowItem += 1;
      }
      return rowItem;
    }

    return Card(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              toUse.title,
              textAlign: TextAlign.left,
              textScaler: const TextScaler.linear(1.4),
            ),
            const Divider(),
            LayoutGrid(
              columnSizes: repeat(
                crossItems,
                [auto],
              ),
              rowSizes: repeat(
                rowItem(mainCourse.length),
                [auto],
              ),
              columnGap: 10,
              rowGap: 10,
              children: List<Widget>.generate(
                mainCourse.length,
                (index) => mainCourse[index],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Each element of the card is created in here.
/// Needs the information, I am tired to tell.
class InsideWindow extends StatelessWidget {
  final String? address;
  final String? phone;
  final bool isSouth;

  const InsideWindow({
    super.key,
    required this.address,
    required this.phone,
    this.isSouth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (phone != null) {
          launchUrlString("tel:$phone");
        }
      },
      child: InfoDetailBox(
        child: Column(
          children: [
            Text(
              isSouth ? "南校区" : "北校区",
              textAlign: TextAlign.left,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (address != null)
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        const Icon(Icons.house),
                        const SizedBox(width: 5),
                        Text(address!)
                      ],
                    ),
                  if (phone != null)
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        const Icon(Icons.phone),
                        const SizedBox(width: 5),
                        Text(phone!)
                      ],
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
