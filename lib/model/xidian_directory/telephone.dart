/*
School department contact data structure.
Copyright (C) 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/

class TeleyInformation {
  TeleyInformation({
    required this.title,
    this.northAddress,
    this.southAddress,
    this.northTeley,
    this.southTeley,
    this.isNorth = false,
    this.isSouth = false,
  });

  String title;
  bool? isNorth;
  bool? isSouth;
  String? northAddress;
  String? southAddress;
  String? northTeley;
  String? southTeley;
}
/*
List<TeleyInformation> emmm = [
  TeleyInformation(title: "WTF"),
  TeleyInformation(
      title: "WithNorth",
      northAddress: "博丽灵社",
      northTeley: "幻想乡还没通电话",
      isNorth: true),
  TeleyInformation(
      title: "WithSouth",
      southAddress: "阿琳娜",
      southTeley: "他们租的地方没有电话",
      isSouth: true),
  TeleyInformation(
      title: "WithBoth",
      southAddress: "星球快递",
      southTeley: "你不能拨打一千年后的电话",
      isSouth: true,
      northAddress: "春田镇",
      northTeley: "Bart把他们家电话线绞了",
      isNorth: true),
];
*/
