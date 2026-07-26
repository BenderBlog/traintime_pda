// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

//import 'dart:convert';
/*
//import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:watermeter/model/xdu_planet/xdu_planet.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as pref;
import 'package:watermeter/repository/xdu_planet_session.dart';
import 'package:watermeter/generated/l10n.dart';

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

  CommentPopout({super.key, required this.id, this.replyTo});
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(I18n.of(context)!.xduPlanetCommentTitle),
      content: TextField(
        controller: _controller,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: replyTo == null
              ? I18n.of(context)!.xduPlanetHintSendComment
              : I18n.of(context)!.xduPlanetReply(replyTo!.ID.toString(), replyTo!.content),
        ),
      ),
      actions: [
        TextButton(
          child: Text(I18n.of(context)!.cancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text(I18n.of(context)!.xduPlanetSend),
          onPressed: () async {
            if (_controller.text.isEmpty) {
              showToast(
                context: context,
                msg: I18n.of(context)!.xduPlanetEmptySend,
              );
              return;
            }
            var pd = ProgressDialog(context: context);
            pd.show(msg: I18n.of(context)!.xduPlanetSending);
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
                })
                .onError((e, s) {
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
*/
