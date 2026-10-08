# SortedPeer Phase 3 bounded measurement pilot

Pilot evidence only. Not a publishable result; not interpreted. See
`Maintanance/Archived/SORTED_COLLECTIONS_BENCHMARK_TASK.md` (Phase 3 result) for the review.

- Raw artifact: `results-20261004-020908-988aecaf.json` (harness format version 1,
  per task/size: five cycle samples, each the minimum over that cycle's iterations;
  encoded as `[seconds, attoseconds]`).
- Charts: `charts-p50/` (PNG, `Results.md` overview), rendered from the raw artifact.
- Date: 2026-10-04, run 02:09:08–02:09:28 JST (+0900).
- Commit: `988aecaf34b73a223259490f505171fea8caab25`, benchmark sources unmodified
  (only `Maintanance/` Markdown was dirty).
- Machine: Apple M1, 8 cores, 16 GiB, AC power; macOS 27.0 (26A428).
- Toolchain: Apple Swift 6.4 (swiftlang-6.4.0.34.1 clang-2100.3.34.1),
  arm64-apple-macosx27.0.0, Release (`-c release`).
- Dependencies (`Benchmarks/Package.resolved`): swift-collections 1.7.0
  `a66de878e87ef5a3d5d390e0f6d9002aa5541a43` with trait `UnstableSortedCollections`
  (upstream: source-unstable); swift-collections-benchmark 0.0.4; swift-ac-collections
  local path with trait `BENCHMARK` only (normal mode, not `COMPATIBLE_ATCODER_2025`).
- Inputs: `SortedPeerInput`, SplitMix64, base seed `0x5EED_5047_2026_1004`.

Commands (from `Benchmarks/`):

```sh
swift build -c release --disable-sandbox --product benchmark
swift run -c release --disable-sandbox --skip-build benchmark library run \
  --library ./Libraries/SortedPeer.json \
  ./Results/SortedPeerPilot/results-20261004-020908-988aecaf.json \
  --sizes 16 --sizes 256 --sizes 4096 --sizes 65536 \
  --cycles 5 --mode replace-all
swift run -c release --disable-sandbox --skip-build benchmark library render \
  --library ./Libraries/SortedPeer.json \
  ./Results/SortedPeerPilot/results-20261004-020908-988aecaf.json \
  --percentile 50 --format png --output ./Results/SortedPeerPilot/charts-p50
```

Other run options were harness defaults (3 iterations, 0.01 s min duration,
10 µs amortized cutoff). Render bands were defaults (bottom min, center mean,
top mean + 2σ). With five samples, `--percentile 50` keeps the lowest
⌈2.5⌉ = 3 samples, so the chart center line is the mean of the three fastest cycles,
not the median of five.
