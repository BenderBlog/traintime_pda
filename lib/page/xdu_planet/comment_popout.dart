// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

//import 'dart:convert';

//import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
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
      "Elliot",
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
      title: Text(FlutterI18n.translate(
        context,
        "xdu_planet.comment_title",
      )),
      content: TextField(
        controller: _controller,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: replyTo == null
              ? FlutterI18n.translate(
                  context,
                  "xdu_planet.hint_send_comment",
                )
              : FlutterI18n.translate(
                  context,
                  "xdu_planet.reply",
                  translationParams: {
                    "reply_to": replyTo!.ID.toString(),
                    "content": replyTo!.content,
                  },
                ),
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          child: Text(FlutterI18n.translate(
            context,
            "cancel",
          )),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text(FlutterI18n.translate(
            context,
            "xdu_planet.sent",
          )),
          onPressed: () async {
            if (_controller.text.isEmpty) {
              showToast(
                context: context,
                msg: FlutterI18n.translate(
                  context,
                  "xdu_planet.empty_send",
                ),
              );
              return;
            }
            var pd = ProgressDialog(context: context);
            pd.show(
              msg: FlutterI18n.translate(
                context,
                "xdu_planet.sending",
              ),
            );
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
