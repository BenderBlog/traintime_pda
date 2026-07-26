#!/usr/bin/env python3
"""
将 assets/flutter_i18n/*.yaml 批量转换为 Flutter Intl Extension 格式的 ARB 文件。

用法：
    python assets/flutter_i18n/yaml_to_arb.py

输出到 lib/l10n/ 目录：
    intl_en.arb      (English, 匹配 extension 已创建的 intl_en.arb)
    intl_zh_CN.arb   (简体中文)
    intl_zh_TW.arb   (繁体中文)
"""

import json
import os
import re
from collections import OrderedDict
import yaml

# 脚本在 tool/scripts/ 下，repo 根目录是它上两级
REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
FLUTTER_I18N_DIR = os.path.join(REPO_ROOT, "assets", "flutter_i18n")
ARB_OUTPUT_DIR = os.path.join(REPO_ROOT, "lib", "l10n")

# YAML locale filename -> ARB locale code
LOCALE_MAP = {
    "zh_CN": "zh",
    "zh_TW": "zh_TW",
    "en_US": "en",
}


def _sanitize_key(key):
    """清洗 YAML key：连字符转下划线，保证可转为合法 Dart 标识符。"""
    # 替换不能出现在 Dart 标识符中的字符
    return key.replace("-", "_").replace(".", "_")


def flatten_yaml(data, parent_key=""):
    """将嵌套 YAML 扁平化为 {flat_key: value}，保留顺序。"""
    items = OrderedDict()
    for key, value in data.items():
        str_key = _sanitize_key(str(key))
        new_key = f"{parent_key}.{str_key}" if parent_key else str_key
        if isinstance(value, dict):
            items.update(flatten_yaml(value, new_key))
        elif value is None:
            # null 值跳过（如 search_book_window: null）
            continue
        elif isinstance(value, (bool, int, float)):
            items[new_key] = str(value)
        else:
            items[new_key] = str(value)
    return items


def yaml_key_to_arb_key(yaml_key):
    """
    将 YAML 点分路径转为驼峰 ARB key。

    所有段（包括第一段）中的下划线都转为驼峰。
    """
    parts = yaml_key.split(".")
    # 第一段也做驼峰转换
    first_words = parts[0].split("_")
    result = first_words[0] + "".join(w.capitalize() for w in first_words[1:])
    for part in parts[1:]:
        words = part.split("_")
        camel = "".join(w.capitalize() for w in words)
        result += camel
    return result


def extract_placeholders(template):
    """从模板字符串中提取 {param} 占位符，返回有序列表。"""
    return re.findall(r"\{(\w+)\}", template)


def infer_param_type(param_name):
    """推断参数类型，默认 String"""
    return "String"


def convert_yaml_to_arb(yaml_path, locale):
    """转换单个 YAML 文件为 ARB 字典。"""
    with open(yaml_path, "r", encoding="utf-8") as f:
        yaml_content = yaml.safe_load(f)

    if yaml_content is None:
        print(f"  [WARN] Empty file: {yaml_path}")
        return {"@@locale": locale}

    flat = flatten_yaml(yaml_content)
    arb = OrderedDict()
    arb["@@locale"] = locale

    for yaml_key, value in flat.items():
        arb_key = yaml_key_to_arb_key(yaml_key)

        # 处理值中的转义
        value = value.replace("\\n", "\n")

        # 写入值
        arb[arb_key] = value

        # 只有带 {param} 占位符的 key 才需要 @ 元数据声明参数类型
        placeholders = extract_placeholders(value)
        if placeholders:
            ph = OrderedDict()
            for p in placeholders:
                ph[p] = {"type": infer_param_type(p)}
            arb[f"@{arb_key}"] = {"placeholders": ph}

    return arb


def main():
    os.makedirs(ARB_OUTPUT_DIR, exist_ok=True)
    total_keys = 0

    for yaml_locale, arb_locale in LOCALE_MAP.items():
        flutter_i18n_yaml_file = os.path.join(FLUTTER_I18N_DIR, f"{yaml_locale}.yaml")
        if not os.path.exists(flutter_i18n_yaml_file):
            print(f"  [SKIP] Fail to find out {flutter_i18n_yaml_file}")
            continue

        arb_data = convert_yaml_to_arb(flutter_i18n_yaml_file, arb_locale)
        arb_filename = f"intl_{arb_locale}.arb"
        output_file = os.path.join(ARB_OUTPUT_DIR, arb_filename)

        with open(output_file, "w", encoding="utf-8") as f:
            json.dump(arb_data, f, ensure_ascii=False, indent=2)

        key_count = len(arb_data) - 1
        total_keys += key_count
        print(f"  [OK] {output_file} ({key_count} keys) was generated")

    print(f"\nGenerate {total_keys} keys.")


if __name__ == "__main__":
    main()
