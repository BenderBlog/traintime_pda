import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:watermeter/model/user.dart';
import 'package:watermeter/repository/electricity/electricity_session.dart';

class ElectricController extends GetxController {
  String? error;
  bool isGet = false;
  String number = "无法获取";

  @override
  void onReady() async {
    await updateData();
    update();
  }

  String electricityAccount() {
    RegExp numsExp = RegExp(r"[0-9]+");
    List<RegExpMatch> nums = numsExp.allMatches(user["dorm"]!).toList();
    // 校区，默认南校区
    String accountA = "2";
    // 楼号
    String accountB = "";
    // 区号
    String accountC = "";
    // 房间号
    String accountD = "";
    int building = -1;

    // 楼号
    accountB = nums[0][0]!.toString().padLeft(3, "0");
    building = int.parse(nums[0][0]!.toString());
    // 南校区1～4#公寓的房间分区编号，则C段首位按区编码，第二位按层编码；D段首位编码为0
    if ([1, 2, 3, 4].contains(building)) {
      // 层号
      accountC += nums[1][0]!.toString();
      // 区号
      accountC = nums[2][0]!.toString() + accountC;
      // 宿舍号
      accountD = nums[3][0]!.toString().padLeft(4, "0");
    }
    // 南校区5、8、9、10、11、12、14#公寓的房间分区编号
    // 则C段首位编码为0，第二位按区编码；D段首位编码同区号
    if ([5, 8, 9, 10, 11, 12, 14].contains(building)) {
      // 区号
      accountC = nums[2][0]!.toString().padLeft(2, "0");
      // 宿舍号
      accountD = nums[3][0]!.toString().padLeft(4, nums[2][0]!);
    }
    // 南校区6、7#公寓不分区，C段编码默认为00；D段首位编码默认为0
    if ([6, 7].contains(building)) {
      accountC == "00";
      accountD == nums[2][0]!.toString().padLeft(4, "0");
    }
    // 南校区13、15#公寓不分区，C段编码默认为01；D段首位编码默认为1
    if ([13, 15].contains(building)) {
      accountC == "01";
      accountD == nums[2][0]!.toString().padLeft(4, "1");
    }

    return accountA + accountB + accountC + accountD;
  }

  Future<void> updateData() async {
    isGet = false;
    error = null;
    try {
      developer.log(
        "Ready to update electricity data",
        name: "ElectricController",
      );

      number = await electricitySession(username: electricityAccount());
      if (number != "没有在校园网环境") {
        isGet = false;
        error = "没有在校园网环境";
      }
      if (number != "无法获取") {
        isGet = true;
        error = null;
      }
    } on DioError catch (e, s) {
      developer.log(
        "Network exception: ${e.message}\nStack: $s",
        name: "ElectricController",
      );
      error = "网络故障，无法使用";
    } catch (e, s) {
      developer.log(
        "Other exception: $e\nStack: $s",
        name: "ElectricController",
      );
      error = "未知错误，感兴趣的话，请接到电脑 adb 查看日志。";
    }
    update();
  }
}
