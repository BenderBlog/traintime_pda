#!/bin/bash
# Copyright 2026 Traintime PDA Authors.
# SPDX-License-Identifier: MPL-2.0
set -euo pipefail
cd "$(dirname "$0")/.."

# 仅编译共享模型、状态机和缓存，不依赖模拟器，也不读写真实 App Group。
watch_test_dir=$(mktemp -d "${TMPDIR:-/tmp}/traintime-watch-tests.XXXXXX")
trap 'rm -rf "$watch_test_dir"' EXIT
watch_common_sources=(
    watchOS/Shared/WatchSyncSupport.swift
    watchOS/Models/WatchScheduleSnapshot.swift
    watchOS/Shared/WatchWidgetShared.swift
    watchOS/Shared/WatchSchedulePresentation.swift
)
xcrun swiftc -parse-as-library "${watch_common_sources[@]}" \
    test/watch/schedule_regression.swift \
    -module-cache-path "$watch_test_dir/modules" -o "$watch_test_dir/schedule"
"$watch_test_dir/schedule"

xcrun swiftc -parse-as-library "${watch_common_sources[@]}" \
    watchOS/Views/WatchInteractionSupport.swift \
    watchOS/Views/MonthCalendarData.swift \
    watchOS/Storage/WatchScheduleStore.swift \
    watchOS/Storage/DayCourseLayoutCache.swift \
    test/watch/interaction_regression.swift \
    -module-cache-path "$watch_test_dir/modules" -o "$watch_test_dir/interaction"
"$watch_test_dir/interaction"
