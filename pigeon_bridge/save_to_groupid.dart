// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/bridge/save_to_groupid.g.dart',
    dartOptions: DartOptions(),
    swiftOut: 'ios/Runner/SaveToGroupID.g.swift',
    swiftOptions: SwiftOptions(),
    copyrightHeader: "pigeon_bridge/copyright_header.txt",
  ),
)
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

/// Flutter 发送给 iOS 原生层的自包含课表 JSON。
///
/// 使用单一载荷对象而不是散落参数，后续协议增加压缩或校验字段时可以保持
/// Host API 方法签名稳定。
class WatchSchedulePayload {
  WatchSchedulePayload({required this.json});

  String json;
}

@HostApi()
abstract class SaveToGroupIdSwiftApi {
  String getHostLanguage();

  @async
  bool saveToGroupId(FileToGroupID data);

  @async
  bool deleteFromGroupId(FileToGroupID data);
}

abstract class SaveToGroupIdFlutterApi {
  bool saveToGroupId(FileToGroupID data);
}

@HostApi()
abstract class WatchSyncSwiftApi {
  /// 将手机 App 当前实际使用的语言同步给 Apple Watch。
  @async
  bool syncPreferredLanguage(String localeIdentifier);

  /// 保存最新学期快照，并通过 WatchConnectivity 发布给 Apple Watch。
  @async
  bool syncSchedule(WatchSchedulePayload payload);

  /// 清除手机端持久化课表并向手表发布空上下文。
  @async
  bool clearSchedule();
}
