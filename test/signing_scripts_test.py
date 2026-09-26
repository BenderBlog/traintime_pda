# Copyright 2026 Traintime PDA Authors.
# SPDX-License-Identifier: MPL-2.0

import importlib.util
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('signing', ROOT / 'tools/signing_for_upstream.py')
signing = importlib.util.module_from_spec(spec)
spec.loader.exec_module(signing)


class SigningTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix='traintime-signing-')
        self.root = Path(self.directory.name)
        for name in signing.FILES:
            path = self.root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(signing.transformed((ROOT / name).read_text())[0])
        self.original = self.contents()

    def tearDown(self):
        self.directory.cleanup()

    def contents(self):
        return {name: (self.root / name).read_bytes() for name in signing.FILES if (self.root / name).is_file()}

    def test_round_trip_and_idempotence(self):
        self.assertEqual(signing.switch(self.root, 'upstream', check=True), 0)
        self.assertEqual(signing.switch(self.root, 'local', check=True), 1)
        self.assertEqual(self.contents(), self.original)
        signing.switch(self.root, 'local')
        local = self.contents()
        signing.switch(self.root, 'local')
        self.assertEqual(self.contents(), local)
        self.assertEqual(signing.switch(self.root, 'upstream', check=True), 1)
        signing.switch(self.root, 'upstream')
        self.assertEqual(self.contents(), self.original)

    def test_missing_file_does_not_partially_switch(self):
        (self.root / signing.FILES[-1]).unlink()
        before = self.contents()
        with self.assertRaises(ValueError):
            signing.switch(self.root, 'local')
        self.assertEqual(self.contents(), before)

    def test_unmanaged_flutter_source_is_checked(self):
        signing.switch(self.root, 'local')
        path = self.root / 'ios/Flutter/Local.xcconfig'
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(f'DEVELOPMENT_TEAM = {signing.LOCAL_TEAM_ID}')
        before = self.contents()
        with self.assertRaises(ValueError):
            signing.switch(self.root, 'upstream')
        self.assertEqual(self.contents(), before)

    def test_mismatched_group_fails_before_write(self):
        path = self.root / 'watchOS/TraintimeWatch.entitlements'
        path.write_text(path.read_text().replace(signing.UPSTREAM_GROUP_ID, 'group.invalid'))
        before = self.contents()
        with self.assertRaises(ValueError):
            signing.switch(self.root, 'local')
        self.assertEqual(self.contents(), before)

    def test_write_failure_rolls_back(self):
        write = Path.write_bytes
        counter = 0
        def fail_once(path, content):
            nonlocal counter
            counter += 1
            if counter == 3:
                raise OSError('simulated write failure')
            return write(path, content)
        with patch.object(Path, 'write_bytes', fail_once):
            with self.assertRaises(OSError):
                signing.switch(self.root, 'local')
        self.assertEqual(self.contents(), self.original)

    def test_staged_check_reads_index_even_with_local_worktree(self):
        def git(*args):
            return subprocess.run(['git', *args], cwd=self.root, check=True, capture_output=True)
        git('init', '-q')
        git('add', 'ios', 'watchOS', 'lib')
        signing.switch(self.root, 'local')
        self.assertEqual(signing.switch(self.root, 'upstream', staged=True), 0)
        git('add', 'ios', 'watchOS', 'lib')
        self.assertEqual(signing.switch(self.root, 'upstream', staged=True), 1)


if __name__ == '__main__':
    unittest.main()
