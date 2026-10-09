#!/usr/bin/env python3
"""Apply the normal-release tree transformation to a release branch checkout."""

from __future__ import annotations

import argparse
from pathlib import Path
import re
import shutil
import sys

from materialize_normal_release import swift_files, transform_lines


REMOVE_PATHS = (
    "Maintanance",
    "AGENTS.md",
    "CLAUDE.md",
    "Utilities/Maintenance",
    "Utilities/Permutation",
    "Documentation/Compatibility",
    "Tests/CLAUDE.md",
    "Tests/TESTING.md",
    "Tests/Archived",
    "Tests/RedBlackTreeFixture/Fixtures.md",
    "Benchmarks/Results",
    "Benchmarks/Results.md",
    "Benchmarks/result.json",
    "Benchmarks/diff.sh",
    "Benchmarks/diff-dict.html",
    "Benchmarks/diff-set.html",
    "Benchmarks/RedBlackTreeDictionary",
    "Benchmarks/RedBlackTreeSet",
    "Benchmarks/versus STL 16M",
    "Sources/PermutationModule/Compatibility/AtCoder2025",
    "Sources/RedBlackTreeCollections/Implements/Index/index_stale_check.md",
)

REMOVE_GLOBS = (
    "Sources/*/Documentation",
    "Tests/**/*AtCoder2025*",
    "Tests/**/AtCoder2025Compatibility",
    "Benchmarks/Libraries/AdHoc*.json",
    "Benchmarks/generate-adhoc*.sh",
)

EXPECTED_EXCLUDES = {
    ("Documentation", "Implements/Index/index_stale_check.md"),
    ("Fixtures.md",),
    ("Documentation",),
}


def remove_path(path: Path, dry_run: bool) -> None:
    if not path.exists() and not path.is_symlink():
        return
    print(f"remove {path}")
    if dry_run:
        return
    if path.is_dir() and not path.is_symlink():
        shutil.rmtree(path)
    else:
        path.unlink()


def remove_manifest_excludes(path: Path, dry_run: bool) -> None:
    source = path.read_text(encoding="utf-8")
    pattern = re.compile(r"(?m)^\s{6}exclude: \[\n(?P<body>(?:\s{8}\"[^\"]+\",?\n)+)\s{6}\],\n")
    found: list[tuple[str, ...]] = []

    def replacement(match: re.Match[str]) -> str:
        entries = tuple(re.findall(r'"([^"]+)"', match.group("body")))
        found.append(entries)
        if entries not in EXPECTED_EXCLUDES:
            raise ValueError(f"unexpected Package.swift exclude block: {entries}")
        return ""

    transformed = pattern.sub(replacement, source)
    if not found:
        raise ValueError("Package.swift exclude blocks were not found")
    print(f"rewrite {path}: remove {len(found)} exclude blocks")
    if not dry_run:
        path.write_text(transformed, encoding="utf-8")


def only_comments_and_whitespace(source: str) -> bool:
    without_blocks = re.sub(r"/\*.*?\*/", "", source, flags=re.DOTALL)
    without_lines = re.sub(r"//.*", "", without_blocks)
    return not without_lines.strip()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--apply", action="store_true")
    arguments = parser.parse_args()
    root = arguments.root.resolve()
    dry_run = not arguments.apply

    if not (root / "Package.swift").is_file() or not (root / "Sources").is_dir():
        print(f"not a package root: {root}", file=sys.stderr)
        return 2

    try:
        for path in swift_files([root / "Sources", root / "Tests", root / "Benchmarks"]):
            original = path.read_text(encoding="utf-8").splitlines(keepends=True)
            transformed = transform_lines(original, path)
            if transformed != original:
                print(f"rewrite {path}")
                if not dry_run:
                    path.write_text("".join(transformed), encoding="utf-8")

        for relative in REMOVE_PATHS:
            remove_path(root / relative, dry_run)
        for pattern in REMOVE_GLOBS:
            for path in sorted(root.glob(pattern)):
                remove_path(path, dry_run)

        remove_manifest_excludes(root / "Package.swift", dry_run)

        if not dry_run:
            for path in swift_files([root / "Sources", root / "Tests"]):
                if only_comments_and_whitespace(path.read_text(encoding="utf-8")):
                    remove_path(path, False)
    except ValueError as error:
        print(error, file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
