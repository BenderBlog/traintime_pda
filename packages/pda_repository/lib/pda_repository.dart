// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

typedef UpdateReleaseData = ({
  String code,
  List<String> changes,
  String iosUrl,
  String androidUrl,
  String githubUrl,
});

abstract interface class UpdateRepository {
  Future<UpdateReleaseData> fetchLatest();
}
