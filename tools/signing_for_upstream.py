#!/usr/bin/env python3
"""切换至作者签名；--check 校验工作区，--check --staged 校验待提交内容。"""

from __future__ import annotations

import argparse
from pathlib import Path
import plistlib
import re
import subprocess
import sys

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
REPLACEMENTS = (
    (f"{LOCAL_BUNDLE_ID}.RunnerTests", UPSTREAM_TEST_BUNDLE_ID),
    (f"group.{LOCAL_BUNDLE_ID}", UPSTREAM_GROUP_ID),
    (LOCAL_BUNDLE_ID, UPSTREAM_BUNDLE_ID),
    (LOCAL_TEAM_ID, UPSTREAM_TEAM_ID),
)
AUDIT_ROOTS = ("ios", "watchOS", "lib")
AUDIT_SUFFIXES = {".dart", ".entitlements", ".pbxproj", ".plist", ".swift", ".xcconfig"}
# 保留 Flutter 下的源 xcconfig，只跳过依赖和生成目录。
AUDIT_SKIP_PARTS = {".symlinks", "build", "Pods", ".ephemeral", "ephemeral"}


def transformed(text: str, target: str = "upstream") -> tuple[str, int]:
    replacements = REPLACEMENTS if target == "upstream" else tuple((b, a) for a, b in REPLACEMENTS)
    count = 0
    for source, destination in replacements:
        count += text.count(source)
        text = text.replace(source, destination)
    return text, count


def read_sources(root: Path, staged: bool) -> dict[str, str]:
    if staged:
        listing = subprocess.run(["git", "ls-files", "-z", "--", *AUDIT_ROOTS], cwd=root,
                                 check=True, capture_output=True).stdout.decode().split("\0")
        names = [name for name in listing if name]
    else:
        names = [str(path.relative_to(root)) for base in AUDIT_ROOTS for path in (root / base).rglob("*") if path.is_file()]
    sources = {}
    for name in names:
        path = Path(name)
        if path.suffix not in AUDIT_SUFFIXES or any(part in AUDIT_SKIP_PARTS for part in path.parts):
            continue
        if staged:
            sources[name] = subprocess.run(["git", "show", f":{name}"], cwd=root, check=True,
                                           capture_output=True).stdout.decode("utf-8")
        else:
            sources[name] = (root / path).read_text(encoding="utf-8")
    missing = [name for name in FILES if name not in sources]
    if missing:
        raise ValueError("找不到预期文件：" + ", ".join(missing))
    return sources


def validate(sources: dict[str, str], target: str) -> None:
    base = UPSTREAM_BUNDLE_ID if target == "upstream" else LOCAL_BUNDLE_ID
    team = UPSTREAM_TEAM_ID if target == "upstream" else LOCAL_TEAM_ID
    group = f"group.{base}"
    test_id = UPSTREAM_TEST_BUNDLE_ID if target == "upstream" else f"{base}.RunnerTests"
    forbidden = (LOCAL_BUNDLE_ID, LOCAL_TEAM_ID) if target == "upstream" else (UPSTREAM_BUNDLE_ID, UPSTREAM_TEAM_ID, UPSTREAM_TEST_BUNDLE_ID)
    for name, content in sources.items():
        if any(marker in content for marker in forbidden):
            raise ValueError(f"{name} 仍含另一套签名，或出现未纳入白名单的配置")
    project = sources[FILES[0]]
    bundles = re.findall(r'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*"?([^;"\n]+)"?;', project)
    expected = {base, f"{base}.ClasstableWidget", f"{base}.watchkitapp", f"{base}.watchkitapp.widget", test_id}
    if set(bundles) != expected or any(bundles.count(value) != 3 for value in expected):
        raise ValueError("Xcode 各 target 的 Debug/Release/Profile Bundle ID 不一致")
    for setting, value in [("DEVELOPMENT_TEAM", team), ("CUSTOM_GROUP_ID", group)]:
        values = re.findall(rf'{setting}\s*=\s*"?([^;"\n]+)"?;', project)
        if not values or set(values) != {value}:
            raise ValueError(f"Xcode {setting} 未统一为 {value}")
    if f"INFOPLIST_KEY_WKCompanionAppBundleIdentifier = {base};" not in project:
        raise ValueError("Watch Companion Bundle ID 不匹配")
    # 不允许误删引用或重复对象 ID；重复 ID 会把 Swift 文件当成资源处理。
    object_ids = re.findall(r'^\s*([A-F0-9]{24}) /\*.*?\*/ = ', project, re.MULTILINE)
    if len(object_ids) != len(set(object_ids)):
        raise ValueError("Xcode 工程存在重复对象 ID")
    for name in FILES:
        if name.endswith(".entitlements"):
            data = plistlib.loads(sources[name].encode())
            if data.get("com.apple.security.application-groups") != [group]:
                raise ValueError(f"{name} 的 App Group 不一致")
    info = plistlib.loads(sources["ios/Runner/Info.plist"].encode())
    if info.get("AppGroupId") != "$(CUSTOM_GROUP_ID)":
        raise ValueError("Runner AppGroupId 未引用 CUSTOM_GROUP_ID")
    for name, expression in [
        ("lib/repository/preference.dart", rf"appId\s*=\s*['\"]{re.escape(group)}['\"]"),
        ("watchOS/Shared/WatchWidgetShared.swift", rf'appGroupIdentifier\s*=\s*"{re.escape(group)}"'),
        ("ios/ClasstableWidget/ClasstableWidget.swift", rf'widgetGroupId\s*=\s*"{re.escape(group)}"'),
    ]:
        if not re.search(expression, sources[name]):
            raise ValueError(f"{name} 的共享容器配置不一致")


def switch(root: Path, target: str, *, check: bool = False, staged: bool = False) -> int:
    sources = read_sources(root, staged)
    proposed = dict(sources)
    changes = {}
    for name in FILES:
        updated, count = transformed(sources[name], target)
        proposed[name] = updated
        if updated != sources[name]:
            changes[name] = count
    # 先校验所有文件及变换后的整体一致性，任何错误发生前均不写文件。
    validate(proposed, target)
    if staged or check:
        if changes:
            print("签名尚未切换：" + ", ".join(changes))
            return 1
        print("暂存区签名检查通过。" if staged else "工作区签名检查通过。")
        return 0
    originals = {name: (root / name).read_bytes() for name in changes}
    written = []
    try:
        for name in changes:
            written.append(name)
            (root / name).write_bytes(proposed[name].encode("utf-8"))
    except OSError:
        for name in written:
            (root / name).write_bytes(originals[name])
        raise
    print(f"已切换为{'作者' if target == 'upstream' else '本地'}配置，修改 {len(changes)} 个文件；未执行 git add 或 commit。")
    return 0


def main(target: str = "upstream") -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="只检查，不写入；需要切换时返回 1")
    if target == "upstream":
        parser.add_argument("--staged", action="store_true", help="只检查 Git 暂存区，可在本地签名状态下检查提交")
    args = parser.parse_args()
    try:
        return switch(REPO_ROOT, target, check=args.check, staged=getattr(args, "staged", False))
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        print(f"签名检查失败：{error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
