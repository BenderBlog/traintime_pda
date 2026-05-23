// Copyright 2026 Hazuki Keatsu.
// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:watermeter/bridge/save_to_groupid.g.dart';
import 'package:watermeter/model/pda_service/custom_class.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart' as pref;

class CustomClassRepository {
  static const String fileName = 'CustomClassesV2.json';

  File get file => File('${supportPath.path}/$fileName');

  List<CustomClass> load() {
    if (!file.existsSync()) {
      file.writeAsStringSync('[]');
    }
    final dynamic decoded = jsonDecode(file.readAsStringSync());
    return (decoded as List<dynamic>)
        .map((e) => CustomClass.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void save(List<CustomClass> data) {
    final encoded = jsonEncode(data.map((e) => e.toJson()).toList());
    file.writeAsStringSync(encoded);
    _syncToWidget(encoded);
  }

  void delete() {
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  void _syncToWidget(String data) {
    if (!Platform.isIOS) return;
    final api = SaveToGroupIdSwiftApi();
    api
        .saveToGroupId(
          FileToGroupID(appid: pref.appId, fileName: fileName, data: data),
        )
        .then((result) {
          log.info(
            "[CustomClassRepository][_syncToWidget] "
            "ios sync $fileName status: $result.",
          );
        })
        .catchError((e, s) {
          log.handle(e, s);
        });
  }
}
