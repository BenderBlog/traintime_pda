// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:styled_widget/styled_widget.dart';
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
      "Rael",
      "Richard",
      "Rick",
      "David",
      "Tony",
      "Louis",
      "Luis",
      "Antonio",
      "Anthony",
      "Margaret",
      "Maggie",
      "Leela",
      "Amy",
      "Liz",
      "Michelle",
      "Elisabeth",
      "Isabel",
      "Cindy",
      "Katherine",
      "Kate",
      "Rodriguez",
      "Simpson",
      "Fry",
      "Carter",
      "Lennon",
      "McDonald",
      "Starmer",
      "Hackett",
      "Anderson",
      "Johnson",
      "Harrison",
      "Murray",
    ];

    // Finalized, do not modify unless spelling problem!
    List<String> nameTouhou = [
      "Alice",
      "Marisa",
      "Lily",
      "Yuyuko",
      "Patchouli",
      "Flandre",
      "Reimu",
    ];

    int account = int.parse(pref.getString(pref.Preference.idsAccount));
    int lastNumer = account % 1000;

    if (lastNumer % 25 == 0) return nameTouhou[lastNumer % nameTouhou.length];
    return name[lastNumer % name.length];
  }

  CommentPopout({
    super.key,
    required this.id,
    this.replyTo,
  });
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: [
        TextField(
          controller: _controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: replyTo == null
                ? '发表您的高见:)'
                : "回复评论 #${replyTo!.ID}：${replyTo!.content}",
            border: const OutlineInputBorder(),
          ),
        ).padding(all: 8).expanded(),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () async {
            if (_controller.text.isEmpty) {
              showToast(context: context, msg: "发送信息空白");
              return;
            }
            var pd = ProgressDialog(context: context);
            pd.show(msg: "正在发送评论");
            await PlanetSession()
                .sendComments(
              id: id,
              content: _controller.text,
              userId: CommentPopout.userIdGenerator,
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
      ].toRow().padding(horizontal: 12, top: 15).safeArea(),
    );
  }
}
