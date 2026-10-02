# Copyright 2026 Traintime PDA Authors.
# SPDX-License-Identifier: MPL-2.0

import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    'watch_localizations_audit', ROOT / 'tools/audit_watch_localizations.py'
)
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)


class WatchLocalizationsAuditTest(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory(prefix='traintime-localizations-')
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name)
        (self.root / 'watchOS').mkdir()
        root_patch = patch.object(audit, 'ROOT', self.root)
        root_patch.start()
        self.addCleanup(root_patch.stop)

    def write_source(self, source):
        (self.root / 'watchOS/Probe.swift').write_text(source, encoding='utf-8')

    def test_plain_chinese_keys_in_both_helpers(self):
        self.write_source(
            'let title = watchLocalizedString("课程名称")\n'
            'let detail = watchLocalizedFormat("剩余 %d 分钟", 3)\n'
        )
        self.assertEqual(audit.source_errors({'课程名称': {}, '剩余 %d 分钟': {}}), [])

    def test_swift_escapes_resolve_to_catalog_keys(self):
        cases = [
            (r'选择\"XDYou\"', '选择"XDYou"'),
            (r'第一行\n第二行', '第一行\n第二行'),
            (r'列\t值\r末尾\0', '列\t值\r末尾\0'),
            (r"单引号\'", "单引号'"),
            (r'路径\\new', r'路径\new'),
            (r'路径\\', '路径\\'),
            (r'文字\\u{4E2D}', r'文字\u{4E2D}'),
        ]
        for literal, key in cases:
            with self.subTest(literal=literal):
                self.write_source(f'let value = watchLocalizedString("{literal}")\n')
                self.assertEqual(audit.source_errors({key: {}}), [])

    def test_unicode_scalar_escapes_preserve_surrounding_chinese(self):
        self.write_source(r'let value = watchLocalizedString("课程\u{1F4DA}\u{4E2D}")')
        self.assertEqual(audit.source_errors({'课程📚中': {}}), [])

    def test_actual_interpolation_is_outside_static_key_audit(self):
        self.write_source(
            r'let title = watchLocalizedString("课程\(name)")' + '\n'
            r'let detail = watchLocalizedFormat("课程\(name) %d", 3)' + '\n'
        )
        self.assertEqual(audit.source_errors({}), [])

    def test_escaped_backslash_parenthesis_is_a_static_key(self):
        self.write_source(r'let value = watchLocalizedString("路径\\(名称)")')
        key = r'路径\(名称)'
        self.assertEqual(audit.source_errors({key: {}}), [])
        self.assertEqual(
            audit.source_errors({}),
            [f'watchOS/Probe.swift:1: missing resource {key!r}'],
        )

    def test_interpolation_depends_on_backslash_parity(self):
        for count in range(1, 9):
            with self.subTest(backslashes=count):
                literal = '课程' + '\\' * count + '(name)'
                self.write_source(f'let value = watchLocalizedString("{literal}")')
                if count % 2:
                    self.assertEqual(audit.source_errors({}), [])
                else:
                    key = '课程' + '\\' * (count // 2) + '(name)'
                    self.assertEqual(
                        audit.source_errors({}),
                        [f'watchOS/Probe.swift:1: missing resource {key!r}'],
                    )

    def test_missing_resource_reports_decoded_key_path_and_line(self):
        self.write_source(
            'let unrelated = 1\n'
            r'let value = watchLocalizedString("第一行\n\"第二行\"")' + '\n'
        )
        key = '第一行\n"第二行"'
        self.assertEqual(
            audit.source_errors({}),
            [f'watchOS/Probe.swift:2: missing resource {key!r}'],
        )

    def test_raw_and_multiline_literals_remain_outside_scanner_coverage(self):
        self.write_source(
            'let raw = watchLocalizedString(#"原始字符串"#)\n'
            'let multiline = watchLocalizedString("""\n多行字符串\n""")\n'
        )
        self.assertEqual(audit.source_errors({}), [])


if __name__ == '__main__':
    unittest.main()
