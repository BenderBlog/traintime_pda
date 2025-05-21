// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/bridge/save_to_groupid.g.dart',
  dartOptions: DartOptions(),
  swiftOut: 'ios/Runner/SaveToGroupID.g.swift',
  swiftOptions: SwiftOptions(),
  copyrightHeader: "pigeon_bridge/copyright_header.txt",
))
class FileToGroupID {
  FileToGroupID({
    required this.appid,
    required this.fileName,
    required this.data,
  });
  String appid;
  String fileName;
  String data;
}

@HostApi()
abstract class SaveToGroupIdSwiftApi {
  String getHostLanguage();

  @async
  bool saveToGroupId(FileToGroupID data);
}

abstract class SaveToGroupIdFlutterApi {
  bool saveToGroupId(FileToGroupID data);
}
