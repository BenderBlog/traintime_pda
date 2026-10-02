#!/usr/bin/env python3
"""恢复本地 Apple 签名；--check 只校验，需切换时返回 1。"""

import signing_for_upstream as signing

REPO_ROOT = signing.REPO_ROOT
FILES = signing.FILES
REPLACEMENTS = tuple((destination, source) for source, destination in signing.REPLACEMENTS)


def transformed(text: str) -> tuple[str, int]:
    return signing.transformed(text, target="local")


if __name__ == "__main__":
    raise SystemExit(signing.main(target="local"))
