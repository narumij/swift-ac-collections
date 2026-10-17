#!/bin/sh
# RBT-049 exact commands (run inside an isolated mktemp directory; see README.md).
# Probe package: Package.swift = Probe-Package.swift, Tests/ProbeTests/Probe.swift = Probe.swift
swift test --sanitize address --build-system native
ASAN_OPTIONS=strip_env=0 swift test --sanitize address --build-system native
# Repository: git worktree add --detach <dir> 81204d227e14710c5e1732afcf421b4252899e79 ; default traits (no --traits)
swift build --build-tests --sanitize address --build-system native
swift test --skip-build --sanitize address --build-system native --filter DeathTests
ASAN_OPTIONS=strip_env=0 swift test --skip-build --sanitize address --build-system native --filter DeathTests
swift test --skip-build --sanitize address --build-system native --filter RedBlackTreeInternalCoverageTests
ASAN_OPTIONS=strip_env=0 swift test --skip-build --sanitize address --build-system native --filter RedBlackTreeInternalCoverageTests
