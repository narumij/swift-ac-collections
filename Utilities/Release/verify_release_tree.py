#!/usr/bin/env python3
"""Verify structural invariants of a materialized release tree."""

from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys

from prepare_release_tree import REMOVE_GLOBS, REMOVE_PATHS


parser = argparse.ArgumentParser()
parser.add_argument("--root", type=Path, default=Path.cwd())
arguments = parser.parse_args()
root = arguments.root.resolve()
errors: list[str] = []

for relative in REMOVE_PATHS:
    if (root / relative).exists():
        errors.append(f"forbidden release path remains: {relative}")
for pattern in REMOVE_GLOBS:
    for path in root.glob(pattern):
        errors.append(f"forbidden release path remains: {path.relative_to(root)}")

condition = re.compile(r"^\s*#(?:if|elseif)\b.*\bCOMPATIBLE_ATCODER_2025\b", re.MULTILINE)
for base in (root / "Sources", root / "Tests", root / "Benchmarks"):
    for path in base.rglob("*.swift"):
        if ".build" in path.parts:
            continue
        if condition.search(path.read_text(encoding="utf-8")):
            errors.append(f"compatibility compilation condition remains: {path.relative_to(root)}")

manifest = (root / "Package.swift").read_text(encoding="utf-8")
active_manifest = "\n".join(
    line for line in manifest.splitlines() if not line.lstrip().startswith("//")
)
if re.search(r'\.define\(\s*"COMPATIBLE_ATCODER_2025"', active_manifest):
    errors.append("compatibility define remains in Package.swift")
if re.search(r"(?m)^\s*exclude:\s*\[", manifest):
    errors.append("Package.swift still contains an exclude block after pruned paths were removed")

if errors:
    print("\n".join(errors), file=sys.stderr)
    raise SystemExit(1)
print("release tree verification passed")
