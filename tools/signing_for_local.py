#!/usr/bin/env python3
"""将原作者 Apple 签名与标识恢复为本地配置。

脚本只修改 FILES 中列出的文件，不执行 git add 或 git commit。
使用 --check 可以只预览将发生的替换。
"""

from __future__ import annotations

import argparse
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]

LOCAL_BUNDLE_ID = "com.littlestar.traintimepda"
LOCAL_TEAM_ID = "RW37L3W23K"
UPSTREAM_BUNDLE_ID = "xyz.superbart.xdyou"
UPSTREAM_GROUP_ID = f"group.{UPSTREAM_BUNDLE_ID}"
UPSTREAM_TEST_BUNDLE_ID = "io.github.benderblog.traintimePda.RunnerTests"
UPSTREAM_TEAM_ID = "YXS6PA6787"

FILES = (
    "ios/Runner.xcodeproj/project.pbxproj",
    "ios/Runner/Info.plist",
    "ios/Runner/Runner.entitlements",
    "ios/ClasstableWidgetExtension.entitlements",
    "ios/ClasstableWidget/ClasstableWidget.swift",
    "lib/repository/preference.dart",
    "watchOS/Shared/WatchWidgetShared.swift",
    "watchOS/TraintimeWatch.entitlements",
    "watchOS/Widget/TraintimeWatchWidgetExtension.entitlements",
)

AUDIT_ROOTS = ("ios", "watchOS", "lib")
AUDIT_SUFFIXES = {
    ".dart",
    ".entitlements",
    ".pbxproj",
    ".plist",
    ".swift",
    ".xcconfig",
}
AUDIT_SKIP_PARTS = {".symlinks", "build", "Flutter", "Pods"}

# 与 signing_for_upstream.py 的映射完全相反。
REPLACEMENTS = (
    (
        UPSTREAM_TEST_BUNDLE_ID,
        f"{LOCAL_BUNDLE_ID}.RunnerTests",
    ),
    (
        UPSTREAM_GROUP_ID,
        f"group.{LOCAL_BUNDLE_ID}",
    ),
    (
        UPSTREAM_BUNDLE_ID,
        LOCAL_BUNDLE_ID,
    ),
    (UPSTREAM_TEAM_ID, LOCAL_TEAM_ID),
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="将原作者签名配置恢复为本地配置（不会提交）"
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="只显示将修改的文件，不写入磁盘",
    )
    return parser.parse_args()


def transformed(text: str) -> tuple[str, int]:
    total = 0
    for upstream_value, local_value in REPLACEMENTS:
        count = text.count(upstream_value)
        if count:
            text = text.replace(upstream_value, local_value)
            total += count
    return text, total


def find_unmanaged_values(markers: tuple[str, ...]) -> list[str]:
    """找出白名单外可能包含签名值的源码文件。"""
    managed_paths = {(REPO_ROOT / item).resolve() for item in FILES}
    unmanaged: list[str] = []

    for root_name in AUDIT_ROOTS:
        root = REPO_ROOT / root_name
        for path in root.rglob("*"):
            if not path.is_file() or path.suffix not in AUDIT_SUFFIXES:
                continue
            if any(part in AUDIT_SKIP_PARTS for part in path.parts):
                continue
            if path.resolve() in managed_paths:
                continue

            try:
                text = path.read_text(encoding="utf-8")
            except UnicodeDecodeError:
                continue
            if any(marker in text for marker in markers):
                unmanaged.append(str(path.relative_to(REPO_ROOT)))

    return sorted(unmanaged)


def main() -> int:
    args = parse_args()
    unmanaged = find_unmanaged_values(
        (
            UPSTREAM_BUNDLE_ID,
            UPSTREAM_TEST_BUNDLE_ID,
            UPSTREAM_TEAM_ID,
        )
    )
    if unmanaged:
        print("错误：以下白名单外文件也包含原作者签名值：")
        for relative_path in unmanaged:
            print(f"  {relative_path}")
        print("\n请先把这些文件加入脚本 FILES，避免恢复时遗漏。")
        return 2

    changed: list[tuple[str, int]] = []

    for relative_path in FILES:
        path = REPO_ROOT / relative_path
        if not path.is_file():
            raise SystemExit(f"错误：找不到预期文件：{relative_path}")

        original = path.read_text(encoding="utf-8")
        updated, count = transformed(original)
        if updated == original:
            continue

        changed.append((relative_path, count))
        if not args.check:
            path.write_text(updated, encoding="utf-8")

    action = "将修改" if args.check else "已修改"
    if not changed:
        print("未发现原作者签名值；当前文件可能已经是本地配置。")
        return 0

    print(f"{action} {len(changed)} 个文件：")
    for relative_path, count in changed:
        print(f"  {relative_path}（{count} 处）")

    if args.check:
        print("\n这是预览，没有写入任何文件。")
    else:
        print("\n已恢复为本地配置。脚本没有执行 git add 或 git commit。")
        print("这些恢复内容会保留为未提交的工作区修改。")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
