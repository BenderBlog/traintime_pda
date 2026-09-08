#!/usr/bin/env python3
# Copyright 2026 Traintime PDA Authors.
# SPDX-License-Identifier: MPL-2.0

"""Audit Watch string resources without building or launching either app."""

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PLACEHOLDER = re.compile(r"%(?:(\d+)\$)?(lld|ld|d|@)")
LOCALIZED_LITERAL = re.compile(
    r'(?:watchLocalizedString|watchLocalizedFormat)\(\s*"(?!"")((?:\\.|[^"\\\n])*)"'
)
# An odd run of backslashes opens interpolation; escaped pairs stay literal.
SWIFT_INTERPOLATION = re.compile(r'(?<!\\)(?:\\\\)*\\\(')
SWIFT_ESCAPE = re.compile(r'\\(u\{[0-9a-fA-F]{1,8}\}|[0tnr"\'\\])')
SIMPLE_ESCAPES = {"0": "\0", "t": "\t", "n": "\n", "r": "\r",
                  '"': '"', "'": "'", "\\": "\\"}


def swift_literal_value(literal: str) -> str:
    """Decode Swift escapes without re-decoding UTF-8 Chinese characters.

    This scanner handles ordinary, non-interpolated single-line literals.
    Raw and multiline Swift strings remain outside its source coverage.
    """
    def replace(match: re.Match[str]) -> str:
        escape = match[1]
        if escape.startswith("u{"):
            return chr(int(escape[2:-1], 16))
        return SIMPLE_ESCAPES[escape]

    return SWIFT_ESCAPE.sub(replace, literal)


def placeholders(value: str) -> list[tuple[int, str]]:
    """Compare argument positions and types, allowing reordered translations."""
    result = []
    position = 0
    for match in PLACEHOLDER.finditer(value.replace("%%", "")):
        position += 1
        result.append((int(match[1]) if match[1] else position, match[2]))
    return sorted(result)


def catalog_errors(strings: dict) -> list[str]:
    errors = []
    for key, entry in strings.items():
        if entry.get("shouldTranslate") is False:
            continue
        for language in ("en", "zh-Hant"):
            unit = entry.get("localizations", {}).get(language, {}).get("stringUnit", {})
            value = unit.get("value")
            if unit.get("state") != "translated" or not value:
                errors.append(f"{language}: missing translation for {key!r}")
            elif placeholders(value) != placeholders(key):
                errors.append(f"{language}: incompatible format arguments for {key!r}")
        source_unit = entry.get("localizations", {}).get("zh-Hans", {}).get("stringUnit")
        if source_unit and placeholders(source_unit.get("value", "")) != placeholders(key):
            errors.append(f"zh-Hans: incompatible format arguments for {key!r}")
    return errors


def source_errors(strings: dict) -> list[str]:
    errors = []
    for path in sorted((ROOT / "watchOS").rglob("*.swift")):
        source = path.read_text(encoding="utf-8")
        for match in LOCALIZED_LITERAL.finditer(source):
            literal = match[1]
            if SWIFT_INTERPOLATION.search(literal):
                continue
            key = swift_literal_value(literal)
            if key not in strings:
                line = source.count("\n", 0, match.start()) + 1
                errors.append(f"{path.relative_to(ROOT)}:{line}: missing resource {key!r}")
    return errors


def main() -> int:
    catalog = json.loads((ROOT / "watchOS/Localizable.xcstrings").read_text(encoding="utf-8"))
    strings = catalog["strings"]
    errors = catalog_errors(strings) + source_errors(strings)
    if catalog.get("sourceLanguage") != "zh-Hans":
        errors.append("The Watch source language must remain zh-Hans")
    if errors:
        print("\n".join(errors))
        return 1
    count = sum(entry.get("shouldTranslate") is not False for entry in strings.values())
    print(f"Watch localization resources: {count} translatable entries; zh-Hans, zh-Hant and en complete")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
