/*
School department contact data structure.
Copyright (C) 2022 SuperBart

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
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