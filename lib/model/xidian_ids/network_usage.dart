// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

class NetworkUsage {
  // (ip, online_time, used_t)
  final List<(String, String, String)> ipList;
  final String used;
  final String rest;
  final String charged;

  /// Provide by xenode, "blackbox"...
  final NetworkInfo networkInfo;

  const NetworkUsage({
    required this.ipList,
    required this.used,
    required this.rest,
    required this.charged,
    required this.networkInfo,
  });
}

class NetworkInfo {
  late int serverFlag;
  late int addTime;
  late int allBytes;
  late String billingName;
  late int bytesIn;
  late int bytesOut;
  late int checkoutDate;
  late String domain;
  late String error;
  late String groupId;
  late int keepaliveTime;
  late String onlineDeviceDetail;
  late String onlineDeviceTotal;
  late String onlineIp;
  late String onlineIp6;
  late String packageId;
  late String pppoeDial;
  late String productsId;
  late String productsName;
  late String realName;
  late int remainBytes;
  late int remainSeconds;
  late int sumBytes;
  late int sumSeconds;
  late String sysver;
  late int userBalance;
  late int userCharge;
  late String userMac;
  late String userName;
  late int walletBalance;

  NetworkInfo(
      {required this.serverFlag,
      required this.addTime,
      required this.allBytes,
      required this.billingName,
      required this.bytesIn,
      required this.bytesOut,
      required this.checkoutDate,
      required this.domain,
      required this.error,
      required this.groupId,
      required this.keepaliveTime,
      required this.onlineDeviceDetail,
      required this.onlineDeviceTotal,
      required this.onlineIp,
      required this.onlineIp6,
      required this.packageId,
      required this.pppoeDial,
      required this.productsId,
      required this.productsName,
      required this.realName,
      required this.remainBytes,
      required this.remainSeconds,
      required this.sumBytes,
      required this.sumSeconds,
      required this.sysver,
      required this.userBalance,
      required this.userCharge,
      required this.userMac,
      required this.userName,
      required this.walletBalance});

  NetworkInfo.fromJson(Map<String, dynamic> json) {
    serverFlag = json['ServerFlag'];
    addTime = json['add_time'];
    allBytes = json['all_bytes'];
    billingName = json['billing_name'];
    bytesIn = json['bytes_in'];
    bytesOut = json['bytes_out'];
    checkoutDate = json['checkout_date'];
    domain = json['domain'];
    error = json['error'];
    groupId = json['group_id'];
    keepaliveTime = json['keepalive_time'];
    onlineDeviceDetail = json['online_device_detail'];
    onlineDeviceTotal = json['online_device_total'];
    onlineIp = json['online_ip'];
    onlineIp6 = json['online_ip6'];
    packageId = json['package_id'];
    pppoeDial = json['pppoe_dial'];
    productsId = json['products_id'];
    productsName = json['products_name'];
    realName = json['real_name'];
    remainBytes = json['remain_bytes'];
    remainSeconds = json['remain_seconds'];
    sumBytes = json['sum_bytes'];
    sumSeconds = json['sum_seconds'];
    sysver = json['sysver'];
    userBalance = json['user_balance'];
    userCharge = json['user_charge'];
    userMac = json['user_mac'];
    userName = json['user_name'];
    walletBalance = json['wallet_balance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ServerFlag'] = serverFlag;
    data['add_time'] = addTime;
    data['all_bytes'] = allBytes;
    data['billing_name'] = billingName;
    data['bytes_in'] = bytesIn;
    data['bytes_out'] = bytesOut;
    data['checkout_date'] = checkoutDate;
    data['domain'] = domain;
    data['error'] = error;
    data['group_id'] = groupId;
    data['keepalive_time'] = keepaliveTime;
    data['online_device_detail'] = onlineDeviceDetail;
    data['online_device_total'] = onlineDeviceTotal;
    data['online_ip'] = onlineIp;
    data['online_ip6'] = onlineIp6;
    data['package_id'] = packageId;
    data['pppoe_dial'] = pppoeDial;
    data['products_id'] = productsId;
    data['products_name'] = productsName;
    data['real_name'] = realName;
    data['remain_bytes'] = remainBytes;
    data['remain_seconds'] = remainSeconds;
    data['sum_bytes'] = sumBytes;
    data['sum_seconds'] = sumSeconds;
    data['sysver'] = sysver;
    data['user_balance'] = userBalance;
    data['user_charge'] = userCharge;
    data['user_mac'] = userMac;
    data['user_name'] = userName;
    data['wallet_balance'] = walletBalance;
    return data;
  }
}
