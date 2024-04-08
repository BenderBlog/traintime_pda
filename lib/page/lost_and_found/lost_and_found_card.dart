// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/lost_and_found.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';

class LostAndFoundCard extends StatelessWidget {
  final LostAndFoundInfo toUse;

  const LostAndFoundCard({
    super.key,
    required this.toUse,
  });

  @override
  Widget build(BuildContext context) {
    return ReXCard(
      title: Text(toUse.title),
      remaining: [ReXCardRemaining(toUse.getType)],
      bottomRow: [
        Text.rich(TextSpan(children: [
          TextSpan(text: "时间：${toUse.ftime}\n"),
          TextSpan(text: "位置：${toUse.postitionString}\n"),
          TextSpan(text: "详细信息：${toUse.content}\n"),
          TextSpan(text: "发布人：${toUse.user_info.nickname ?? "未提供"}\n"),
          TextSpan(text: "联系方式：${toUse.contact ?? "未提供"}\n"),
        ])),
        [
          if (toUse.picture.isNotEmpty)
            CachedNetworkImage(
              imageUrl: toUse.picture.first,
              height: 120,
              width: 120,
              fit: BoxFit.fill,
            ),
          const Spacer(),
          [
            if (toUse.sms_record_id != null)
              const Text(
                "已发短信通知",
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            if (toUse.wxpushnotice != 0)
              const Text(
                "已发微信通知",
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
          ].toColumn(),
        ].toRow(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
        )
      ].toColumn(crossAxisAlignment: CrossAxisAlignment.start),
    ).gestures(
      onTap: () async {
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("复制联系方式？"),
            content: Text.rich(TextSpan(children: [
              TextSpan(text: "时间：${toUse.ftime}\n"),
              TextSpan(text: "位置：${toUse.position ?? "未提供"}\n"),
              TextSpan(text: "详细信息：${toUse.content}\n"),
              TextSpan(text: "发布人：${toUse.user_info.nickname ?? "未提供"}\n"),
              TextSpan(text: "联系方式：${toUse.contact ?? "未提供"}\n"),
            ])),
            actions: <Widget>[
              TextButton(
                child: const Text("取消"),
                onPressed: () => Navigator.of(context).pop(false), //关闭对话框
              ),
              TextButton(
                child: const Text("确认"),
                onPressed: () {
                  // ... 执行删除操作
                  Navigator.of(context).pop(true); //关闭对话框
                },
              ),
            ],
          ),
        );
        if (confirm == true && toUse.contact != null) {
          Clipboard.setData(ClipboardData(text: toUse.contact!)).then(
            (value) => showToast(msg: "联系方式已经复制"),
          );
        }
      },
    );
  }
}
