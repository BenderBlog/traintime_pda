#!/usr/bin/env python3
"""
将 assets/i18n/{locale}.yaml 按顶层 key 拆分到各语言子目录。

顶层标量键 (str / int / float / bool / None / 多行字符串) → common.yaml
顶层映射键 (dict)                                         → <key>.yaml（内容直接为子树，不含顶层包装）

用法:
    python assets/i18n/breakdown.py
"""

import os
import sys

import yaml

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# RAW 文件名 → slang 语言目录名
LOCALE_MAP = {
    "en_US": "en",
    "zh_CN": "zh",
    "zh_TW": "zh_TW",
}


def _prune_nulls(data):
    """递归将 None 值替换为空字符串，slang 无法处理 null。"""
    if isinstance(data, dict):
        return {k: _prune_nulls(v) for k, v in data.items()}
    elif isinstance(data, list):
        return [_prune_nulls(item) for item in data]
    elif data is None:
        return ""
    return data


def split_by_top_key(data: dict):
    """将整个 YAML dict 拆成 {文件名: 内容字典}。"""
    files: dict[str, dict] = {}
    common: dict[str, object] = {}

    for key, value in data.items():
        if isinstance(value, dict):
            files[f"{key}.yaml"] = value
        else:
            common[key] = value

    if common:
        files["common.yaml"] = common

    return files


def write_yaml(filepath: str, data: dict) -> None:
    """以 block 风格写出 YAML，确保 unicode / 排序正确。"""
    with open(filepath, "w", encoding="utf-8") as f:
        yaml.dump(
            data,
            f,
            allow_unicode=True,
            default_flow_style=False,
            sort_keys=False,
        )


def main() -> int:
    exit_code = 0

    for raw_locale, locale_dir in LOCALE_MAP.items():
        src = os.path.join(SCRIPT_DIR, f"{raw_locale}.yaml")
        if not os.path.isfile(src):
            print(f"  [SKIP]  {src} 不存在")
            continue

        with open(src, "r", encoding="utf-8") as f:
            data = yaml.safe_load(f)

        if not isinstance(data, dict):
            print(f"  [WARN]  {src} 为空或非字典结构，跳过")
            continue

        # 输出目录
        out_dir = os.path.join(SCRIPT_DIR, locale_dir)
        os.makedirs(out_dir, exist_ok=True)

        # 拆分
        files = split_by_top_key(data)

        total_keys = 0
        for filename, content in files.items():
            dest = os.path.join(out_dir, filename)
            write_yaml(dest, _prune_nulls(content))
            key_count = _count_scalar_keys(content)
            total_keys += key_count
            print(f"  [OUT]   {dest}  ({key_count} keys)")

        print(f"  [DONE]  {locale_dir}: {len(files)} 个文件, {total_keys} 个键\n")

    return exit_code


def _count_scalar_keys(data: dict) -> int:
    """递归统计字典中有多少叶子标量值。"""
    count = 0
    for value in data.values():
        if isinstance(value, dict):
            count += _count_scalar_keys(value)
        else:
            count += 1
    return count


if __name__ == "__main__":
    sys.exit(main())
