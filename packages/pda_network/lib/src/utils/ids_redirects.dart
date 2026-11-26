// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

void validateIdsService(Uri uri) {
  if (uri.scheme != 'https' ||
      uri.userInfo.isNotEmpty ||
      uri.hasPort && uri.port != 443 ||
      !(uri.host == 'xidian.edu.cn' || uri.host.endsWith('.xidian.edu.cn'))) {
    throw const FormatException('目标服务必须是校内 HTTPS 地址');
  }
}

void validateIdsRedirect(Uri next, Uri? service, Uri ids) {
  if (next.scheme != 'https' ||
      next.userInfo.isNotEmpty ||
      next.hasPort && next.port != 443 ||
      (next.host != ids.host && next.host != service?.host)) {
    throw const FormatException('统一认证跳转到了意外地址');
  }
}

void validateIdsTicket(Uri destination, Uri service) {
  final query = Map<String, String>.from(destination.queryParameters)
    ..remove('ticket');
  if (destination.scheme != service.scheme ||
      destination.host != service.host ||
      destination.port != service.port ||
      destination.path != service.path ||
      destination.fragment != service.fragment ||
      !_sameQuery(query, service.queryParameters) ||
      destination.queryParametersAll['ticket']?.length != 1) {
    throw const FormatException('目标服务票据与请求地址不匹配');
  }
}

bool _sameQuery(Map<String, String> left, Map<String, String> right) {
  if (left.length != right.length) return false;
  for (final entry in left.entries) {
    if (right[entry.key] != entry.value) return false;
  }
  return true;
}
