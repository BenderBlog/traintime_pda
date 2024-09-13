// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

//import 'dart:convert';

//import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:watermeter/model/xdu_planet/xdu_planet.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as pref;
import 'package:watermeter/repository/xdu_planet_session.dart';

class CommentPopout extends StatelessWidget {
  final String id;
  final XDUPlanetComment? replyTo;

  static String get userIdGenerator {
    // Finalised, do not modify unless spelling problem!
    List<String> name = [
      "Homer",
      "Bart",
      "Cirno",
      "Rael",
      "Richard",
      "Lily",
      "Yuyuko",
      "Rick",
      "David",
      "Alice",
      "Tony",
      "Flandre",
      "Margaret",
      "Maggie",
      "Koishi",
      "Leela",
      "Amy",
      "Liz",
      "Michelle",
      "JKTrigger",
      "Elisabeth",
      "Isabel",
      "Chillet",
      "Marisa",
      "Patchouli",
      "Reimu",
    ];

    int account = int.parse(pref.getString(pref.Preference.idsAccount));

    return name[account % 1000 % name.length];
  }

  CommentPopout({
    super.key,
    required this.id,
    this.replyTo,
  });
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('评论该篇文章'),
      content: TextField(
        controller: _controller,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: replyTo == null
              ? '发表您的高见:)'
              : "回复评论 #${replyTo!.ID}：${replyTo!.content}",
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('取消'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text('发送'),
          onPressed: () async {
            if (_controller.text.isEmpty) {
              showToast(context: context, msg: "发送信息空白");
              return;
            }
            var pd = ProgressDialog(context: context);
            pd.show(msg: "正在发送评论");
            //var hashedUid = md5.convert(utf8.encode(
            //    "${pref.getString(pref.Preference.idsAccount)}#${pref.getString(pref.Preference.name)}"));
            await PlanetSession()
                .sendComments(
              id: id,
              content: _controller.text,
              userId: userIdGenerator, //hashedUid.toString(),
              replyto: replyTo?.ID.toString(),
            )
                .then((value) {
              if (context.mounted) {
                pd.close();
                Navigator.of(context).pop(true);
              }
            }).onError((e, s) {
              if (context.mounted) {
                log.error(e.toString());
                pd.close();
                Navigator.of(context).pop(false);
              }
            });
          },
        ),
      ],
    );
  }
}
