// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/xidian_ids/library_session.dart';

class TransferQRCode extends StatelessWidget {
  final BorrowData data;
  const TransferQRCode({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          QrImageView(
            data: jsonEncode({
              "id": LibrarySession.userId,
              "cardNumber":
                  preference.getString(preference.Preference.idsAccount),
              "barCode": data.barcode.toString(),
              "bookName": data.title.toString(),
              "author": data.author.toString(),
            }).toString(),
            version: QrVersions.auto,
            size: 250.0,
            backgroundColor: Colors.white,
          ),
          const Divider(color: Colors.transparent),
          const Text("转借码，请让转借人扫码来实现\n" "书蜗小程序上的转借功能，电表应该也支持"),
        ],
      ),
    );
  }
}
