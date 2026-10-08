# RedBlackTreeCollections and Swift Collections SortedCollections

Status: Archived after Phase 3 pilot acceptance (2026-10-06) — publishable run intentionally
deferred. Reopen only when a concrete adoption or release decision needs an equal-condition public
comparison and the upstream API/toolchain can be fixed for a reproducible run.

## Why this task exists

`Archived/AdoptionReadinessAssessment.md` (titled "Adoption Readiness and Quality Evidence")
identifies a missing external reference point. A valuable
Swift peer is Apple's experimental `SortedCollections` module: `SortedSet` and
`SortedDictionary`, implemented over an in-memory B-tree.

This task should clarify the workloads and capabilities for which each design is a
natural fit, while learning from the upstream project's design and documentation.
It is not authorized to manufacture a favorable chart or reduce adoption readiness to
a single timing result.

The intended position is modest and provisional. RedBlackTreeCollections is not
presented as a replacement for Swift Collections. It may serve as a practical bridge
while upstream sorted collections remain experimental, especially for users who need
C++-like ordered-container semantics, hinted insertion, or multi containers today.
If the upstream API matures or covers these needs, this package's role should be
re-evaluated rather than defended by inertia.

The project has moved from broad feature expansion to focused refinement. The
priority is therefore credibility for an adoption decision: reproducible evidence,
explicit limitations, and a respectful peer comparison take precedence over adding more
benchmark cases or producing a favorable conclusion.

For the first session, complete Phase 1 and propose the matched matrix only. Do not
start the large measurement run until the user or Codex has reviewed the symmetry of
that matrix. A smaller, reviewable evidence step is preferable to a broad run whose
results cannot be defended.

Official upstream context:

- <https://github.com/apple/swift-collections>
- <https://github.com/apple/swift-collections/issues/1>
- <https://github.com/apple/swift-collections-benchmark>

As of 2026-10-04, upstream documents `SortedCollections` behind the
`UnstableSortedCollections` package trait and explicitly describes its API as
source-unstable. Record the exact resolved dependency revision/version used by any
result; do not generalize one run to every release.

## Scope and separation

Implement and run the comparison in the existing `Benchmarks` auxiliary package.
Do not move performance code into the root package. Do not change production
collection implementations while collecting a baseline.

The first implementation compares only:

- `RedBlackTreeSet<Int>` and `SortedSet<Int>`;
- `RedBlackTreeDictionary<Int, Int>` and `SortedDictionary<Int, Int>`.

MultiSet and MultiMap have no currently exposed like-for-like SortedCollections
counterparts. Record that as a capability distinction; do not compare them to an
unrelated type or simulate them with arrays.

`std::set`/`std::map` results may be retained as context, but the primary comparison
is Swift-to-Swift. C++ ABI overhead must never be mixed into a Swift operation chart.

## Phase 1 — Audit the existing benchmark before adding cases

The repository already registers `SortedSetBenchmarks.swift` and
`RedBlackTreeSetBenchmarks.swift`. Before writing code:

1. inventory existing task names, generators, setup placement, validation, and JSON
   chart definitions;
2. identify cases that look similar but do not measure identical work;
3. confirm the exact `swift-collections` resolution and enabled trait;
4. run a very small smoke benchmark to prove the existing harness works;
5. report the proposed matched matrix before a large measurement run.

Do not treat the existing charts as fair merely because both type names appear.

### Phase 1 result (2026-10-04 01:46 JST, Claude Opus 5.5) — awaiting matrix review

No benchmark source was changed. No timing below is a result.

**Environment and resolution.** Root commit `f838e3b7`; Apple M1, macOS 27.0
(26A428), Swift 6.4 (swiftlang-6.4.0.34.1). `Benchmarks/Package.resolved`:
swift-collections **1.7.0** (`a66de878e87ef5a3d5d390e0f6d9002aa5541a43`) with trait
`UnstableSortedCollections` (upstream marks it source-unstable, "not ready for use in
production"); swift-collections-benchmark 0.0.4 (`69cd5b45…`). swift-ac-collections is
the local path with trait `BENCHMARK`, which only adds `__raw_find`/`__raw_end` and an
index iterator; it changes no existing code path. The root package declares no default
traits, so naming `BENCHMARK` disables nothing.

**Harness facts (from swift-collections-benchmark 0.0.4 source).**

- H1. The `[Int]` and `([Int], [Int])` generators use `shuffled()` with
  `SystemRandomNumberGenerator`. One input per (cycle, size, input type) is cached and
  shared by every task, so paired tasks see identical values within a cycle, but inputs
  differ between cycles and runs and cannot be reproduced.
- H2. Each cycle records the minimum over its iterations; `render --percentile` then
  aggregates across cycles. The recorded commands use `--cycles 1 --percentile 90`,
  which makes the percentile meaningless.
- H3. `AdHoc5.json` ("versus SortedSet") puts `std::set` tasks in the same charts as
  the Swift pair, against the Scope rule.

**Existing SortedSet pairs (`SortedSetBenchmarks.swift` ↔ `RedBlackTreeSetBenchmarks.swift`).**

| Existing title | Assessment |
| --- | --- |
| `init from range` | **Not matched.** RedBlackTreeSet uses its specialized O(n) `init(_: Range)`; `SortedSet(0..<n)` uses the general `init(_:)`, which inserts element by element and ignores sortedness. SortedSet's O(n) counterpart is `init(sortedElements:)`. |
| `init from unsafe buffer` | Matched (general initializer, same shuffled buffer). Note: RedBlackTreeSet's general initializer also has a sorted-append fast path, which matters only for sorted input. |
| `sequential iteration` | **Confounded.** Both iterate `0..<n`, but the trees come from different construction paths (bulk vs per-element insertion), so layout differs by construction method rather than by data structure. |
| `successful contains` / `successful find` | Matched (`contains`; `find(_:) != endIndex` ↔ `index(of:) != nil`). `precondition` sits inside the timed region on both sides. |
| `unsuccessful contains` / `unsuccessful find` | Symmetric but **biased**: every miss is `key + n`, above the maximum, so every query follows the rightmost path. This differs from the hit distribution. |
| `remove` | Matched (setup outside `timer.measure` on both sides). |
| (none) | SortedSet has no insertion, copy-on-write, or bound tasks, and **SortedDictionary has no tasks at all**. |

Existing RedBlackTree-only tasks (`init from sorted` with sorting inside the timed
region, `alternating extremes`, `insert, reserving capacity`, `insert, shared`,
`__raw_find`, `[.find(:)]`) have no SortedSet counterpart and stay out of paired charts.

**Smoke check.** `swift build -c release --disable-sandbox --product benchmark`, then
`swift run -c release --disable-sandbox --skip-build benchmark run <tmp>/smoke.json`
with the three existing pairs `init from unsafe buffer`, `successful contains`, and
`remove`, `--sizes 16 --sizes 1k --cycles 1`. All 6 tasks × 2 sizes produced one
sample each (82 ms). The output went to a temporary directory and was deleted; the
numbers are deliberately not interpreted.

**Proposed matched matrix (for review; nothing implemented).** All rows use `Int` (and
`Int` values), new distinctly named tasks in `Benchmarks/`, inputs from a new seeded
generator type (fixing H1 without replacing the global `[Int]` generator used by
existing tasks), setup and validation outside the timed region, and `blackHole` on
results. Charts contain only the Swift pair (fixing H3).

| ID | Workload | RedBlackTreeSet<Int> | SortedSet<Int> | Note |
| --- | --- | --- | --- | --- |
| S1 | Build from sorted unique ints, sorted-specialized path | `init(_: Range)` | `init(sortedElements:)` | Both O(n) bulk builds |
| S2 | Build from sorted buffer, general initializer | `init(_:)` | `init(_:)` | Labeled capability difference: only RedBlackTreeSet's general path exploits sortedness |
| S3 | Build from shuffled buffer, general initializer | `init(_:)` | `init(_:)` | |
| S4 | Incremental insert, shuffled, unique storage | `insert(_:)` loop from empty | same | No reservation on either side |
| S5 | Successful `contains`, shuffled order | `contains` | `contains` | |
| S6 | Unsuccessful `contains`, interleaved misses | `contains` | `contains` | Store even keys `2i`, query odd `2i+1` |
| S7 | Exact index lookup, hit / interleaved miss | `find(_:)` vs `endIndex` | `index(of:)` vs `nil` | |
| S8 | Strict upper bound | `upperBound(_:)` | `firstIndex(after:)` | `endIndex` ↔ `nil`; `lowerBound`/`equalRange` have no direct SortedSet API → capability row |
| S9 | Ascending iteration after the same sorted bulk build | build via S1 | build via S1 | |
| S10 | Ascending iteration after the same shuffled insertion history | build via S4 | build via S4 | Exposes layout effects |
| S11 | Remove every element, shuffled order | `remove(_:)` | `remove(_:)` | |
| S12 | One insert after O(1) copy | `var c = s; c.insert(x)` | same | Separate from S4 |
| S13 | One remove after O(1) copy | `var c = s; c.remove(x)` | same | |

| ID | Workload | RedBlackTreeDictionary<Int, Int> | SortedDictionary<Int, Int> | Note |
| --- | --- | --- | --- | --- |
| D1 | Build from sorted unique pairs | `init(uniqueKeysWithValues:)` | `init(sortedKeysWithValues:)` | Capability difference: no sorted-only RedBlackTree API; RedBlackTree's Collection overload also reserves capacity |
| D2 | Build from shuffled unique pairs, general initializer | `init(uniqueKeysWithValues:)` | `init(keysWithValues:)` | Unique input: same result. Duplicates: RedBlackTree traps, SortedDictionary keeps the last value |
| D3 | Insert new keys, shuffled | `updateValue(_:forKey:)` | `updateValue(_:forKey:)` | Both insert or replace and return the old value |
| D4 | Update existing keys, shuffled | `updateValue(_:forKey:)` | `updateValue(_:forKey:)` | Both replace |
| D5 | Lookup hit / interleaved miss | `subscript(key:)` get | same | |
| D6 | Index lookup hit / interleaved miss | `index(forKey:)` | `index(forKey:)` | |
| D7 | Defaulted-subscript increment | `d[k, default: 0] += 1` | same | Both have a mutating accessor (RedBlackTree `unsafeMutableAddress`, SortedDictionary `_modify`) |
| D8 | Remove every key, shuffled order | `removeValue(forKey:)` | `removeValue(forKey:)` | |
| D9 | Ascending iteration, sorted bulk build / shuffled insertion history | as S9/S10 | same | |
| D10 | One insert / one remove after O(1) copy | `updateValue` / `removeValue` on a copy | same | |

Not timed (capability or not comparable): RedBlackTree preserve-existing
`insert(key:value:)` (SortedDictionary has no preserving insert), hinted insertion,
`lowerBound`/`equalRange`, `reserveCapacity`, MultiSet/MultiMap (RedBlackTree only);
sorted-only bulk initializers (SortedCollections only). Mixed insert/remove/lookup
traces are deferred until S/D single-operation pairs are validated.

**Measurement proposal.** Release; harness default doubling sizes 1…1M, plus a
separately labeled 4M–16M large-size run if total duration allows; ≥ 5 cycles;
p50 across cycles fixed before measuring (H2). Before timing, each pair gets an
outside-the-timer check that both sides produce the same observable result.

**Review questions.** (1) Is S2/D1's labeled capability-difference framing
acceptable, or should those rows be dropped? (2) Should the seeded generator replace
the existing pairs' inputs, or only feed the new tasks (proposed: new tasks only)?
(3) Is p50 the agreed statistic?

### Codex matrix review and Phase 2 authorization (2026-10-04)

Phase 1 and constraints N1–N4 are accepted with these decisions:

1. Retain S2 and D1 only as clearly labeled capability-difference rows. Do not place
   them in headline matched-performance charts or combine their ratios with matched
   rows. Their value is to explain available construction paths, not to imply equal
   algorithms.
2. Add a benchmark-local seeded generator for the new matrix only. Do not mechanically
   change inputs or historical meaning of existing tasks in this phase. Record the
   seed and generator algorithm with results.
3. Use p50 across at least five cycles for the later publishable run. This choice is
   fixed before seeing results.
4. S8 remains matched at the observable-operation level, with N3's implementation
   difference disclosed in the report.
5. D1/D2 must use the same unlabeled `[(Int, Int)]` input and explicitly pin or verify
   the intended SortedDictionary overload as required by N2.

Phase 2 is authorized only to implement the reviewed matrix, correctness checks, and
neutral Swift-only chart definitions under `Benchmarks/`, followed by a small Release
smoke run. Do not perform the large/publishable measurement run, interpret timings,
change production collection code, or update AdoptionReadinessAssessment in this phase.

**Independent re-verification (2026-10-04 01:55 JST, Claude Opus 5.5, separate
session).** Re-read both existing Set benchmark files, `AdHoc5.json`,
`generate-adhoc5.sh`, `Benchmarks/Package.swift`/`Package.resolved`, and the
SortedCollections 1.7.0 checkout. The resolution, H2/H3, and existing-pair assessment
above are confirmed. Re-ran the same smoke command into a fresh `mktemp -d` directory:
6 tasks × sizes {16, 1024}, one sample each (82.9 ms); directory deleted, numbers not
interpreted. Additional constraints for implementing the matrix:

- N1. RedBlackTreeSet's general `init(_:)` and RedBlackTreeDictionary's
  `init(uniqueKeysWithValues:)` exist only under `#if !COMPATIBLE_ATCODER_2025`. The
  matrix applies to normal mode only; `Benchmarks/Package.swift` enables only
  `BENCHMARK`, so this holds for the current harness. Record the mode with results.
- N2. SortedDictionary has two overloads each of `init(keysWithValues:)` and
  `init(sortedKeysWithValues:)`: labeled `(key:value:)` elements call
  `updateAnyValue(_:forKey:updatingKey: true)`, unlabeled `(Key, Value)` elements do
  not. RedBlackTree `init(uniqueKeysWithValues:)` takes unlabeled `(Key, Value)`.
  D1/D2 must feed the same unlabeled `[(Int, Int)]` array to both sides and record
  which SortedDictionary overload is selected.
- N3. `SortedSet.firstIndex(after:)` is implemented as `startIndex(forKey:)`, a key
  equality check, and possibly one `index(after:)`; RedBlackTree `upperBound(_:)` is a
  direct search. Observable results are equivalent for a unique set (`endIndex` ↔
  `nil`), so S8 stays a matched row; the extra step is an implementation property to
  mention, not a semantic difference.
- N4. `SortedSet.init(_:)` and `init(keysWithValues:)` insert one element at a time
  with no sortedness check (O(n log n) per upstream docs), confirming the S2/D2
  capability-difference labels. `init(sortedElements:)`/`init(sortedKeysWithValues:)`
  `precondition` strict ascending order, so S1/D1 inputs must be strictly increasing.

### Phase 2 result (2026-10-04, Claude Opus 5.5) — awaiting review

Implemented the reviewed matrix only. No production code, `Package.swift`, existing
task, generator, or chart was changed. No timing was interpreted; no large run was
made. Root commit `40d9a115` (uncommitted changes below), Swift 6.4
(swiftlang-6.4.0.34.1), swift-collections 1.7.0 `a66de878…` with
`UnstableSortedCollections`, normal mode (`BENCHMARK` trait only; N1).

**Changed files (all under `Benchmarks/`).**

- `Sources/Benchmarks/SortedPeerInput.swift` (new): seeded input type, reference
  expectations, `addSortedPeerBenchmarks()` registration, `peerCheck`.
- `Sources/Benchmarks/SortedPeerSetBenchmarks.swift` (new): S01–S13.
- `Sources/Benchmarks/SortedPeerDictionaryBenchmarks.swift` (new): D01–D10.
- `Sources/benchmark-tool/main.swift`: one added line, `benchmark.addSortedPeerBenchmarks()`.
- `Libraries/SortedPeer.json` (new): chart library.

**Seeded input (`SortedPeerInput`, new tasks only; decision 2).** Generator:
SplitMix64, base seed `0x5EED_5047_2026_1004`; each array uses state
`seed ^ (size &* 0x100000001B3) ^ (stream &* 0xD6E8FEB86659FD93)`; Fisher–Yates from
the last index down with `j = high64(next() * (i + 1))` (multiply-high, no rejection).
Implemented locally so it does not depend on stdlib `shuffle`/`random(in:)`
algorithms. Contents for size `n`: stored keys `0, 2, …, 2(n−1)`; `insertionOrder`
(stream 1), `hitQueries` (2), `missQueries` = shuffled odd keys `2i+1` (3),
`removalOrder` (4); `sortedPairs`/`shuffledPairs` = unlabeled `(k, k + 1)`. Input is
fully determined by size, so cycles and runs see the same values (fixes H1 for these
tasks). `newKey = missQueries[0]`, `existingKey = hitQueries[0]`.

**Task naming.** `<Type> peer <ID> <workload>`, e.g.
`RedBlackTreeSet<Int> peer S05 contains, hit` ↔ `SortedSet<Int> peer S05 contains, hit`.
Each side is a separate function written as a line-by-line mirror; only the API call
differs. 58 tasks (Set 15 pairs, Dictionary 14 pairs).

| ID | RedBlackTree side | SortedCollections side | Timed region |
| --- | --- | --- | --- |
| S01 | `RedBlackTreeSet(0..<n)` | `SortedSet(sortedElements: 0..<n)` | build only |
| S02 (capability) | `init(sortedKeys)` | `init(sortedKeys)` | build only |
| S03 | `init(insertionOrder)` | `init(insertionOrder)` | build only |
| S04 | `insert` loop from empty | same | loop only |
| S05 / S06 | `contains` over hits / misses | same | whole query loop |
| S07a / S07b | `find(k) != endIndex` | `index(of: k) != nil` | whole query loop |
| S08a / S08b | `upperBound(k)`, then `s[i]` if not end | `firstIndex(after: k)`, then `s[i]` | whole query loop |
| S09 | iterate after `init(0..<n)` | iterate after `init(sortedElements:)` | iteration |
| S10 | iterate after S04 history | same | iteration |
| S11 | `remove` every key, `removalOrder` | same | loop only |
| S12 / S13 | `var c = base` then one `insert(newKey)` / `remove(existingKey)` | same | the one mutation |
| D01 (capability) | `init(uniqueKeysWithValues: sortedPairs)` | `init(sortedKeysWithValues: sortedPairs)` | build only |
| D02 | `init(uniqueKeysWithValues: shuffledPairs)` | `init(keysWithValues: shuffledPairs)` | build only |
| D03 | `updateValue` loop from empty | same | loop only |
| D04 | `updateValue(k + 2, forKey:)` over `hitQueries` | same | loop only |
| D05a / D05b | `d[k]` get, hits / misses | same | whole query loop |
| D06a / D06b | `index(forKey:)`, hits / misses | same | whole query loop |
| D07 | `d[k, default: 0] += 1` over existing keys | same | loop only |
| D08 | `removeValue(forKey:)` every key | same | loop only |
| D09a / D09b | iterate after D01 build / D03 history | same | iteration |
| D10a / D10b | copy, then one `updateValue(newKey)` / `removeValue(existingKey)` | same | the one mutation |

All lookup/iteration/copy structures are built outside the timer through the same
explicit per-element insertion history (`insertionOrder` via `insert`/`updateValue`).
Mutating tasks use `timer.measure` so construction, the per-run copy assignment, and
deallocation stay outside the timed region; build tasks also measure only the
initializer (result deallocated afterwards). Results go to `blackHole`; iteration uses
`blackHole` per element (per key and value for dictionaries), as in existing tasks.

**Correctness validation (outside the timer).** Every task validates once in its
prepare step, before returning the timed closure, against a reference computed from
the input — not against the other library — so both sides are held to the same
expectation: full ordered contents (and values for dictionaries) for builds and
mutations; hit count `n` / miss count `0`; value sums; upper-bound
`(sum of successors, end count)` from the closed form "next even key or end"; copy
tasks verify the copy changed and the base did not. Mutating tasks additionally check
the count and the operation-derived accumulator after every timed run.

**Overload pinning (N2).** Both initializers receive `[(Int, Int)]`. The labeled
SortedDictionary overloads require `(key: Key, value: Value)` elements and cannot
match, so the unlabeled `init(keysWithValues:)`/`init(sortedKeysWithValues:)` are
selected statically. RedBlackTree selects its `Collection` overload of
`init(uniqueKeysWithValues:)`, which reserves `count` capacity first.

**Charts (`Libraries/SortedPeer.json`).** Three groups, each chart contains exactly
the Swift pair and no `std::` task (fixes H3): `Set matched` (S01, S03–S13),
`Dictionary matched` (D02–D10), `Capability differences` (S02, D01 only; decision 1).

**Smoke check.** `swift build -c release --disable-sandbox --product benchmark`
(no warnings in the new files), then
`swift run -c release --disable-sandbox --skip-build benchmark library run --library ./Libraries/SortedPeer.json <mktemp -d>/smoke.json --max-size 4k --cycles 1 --mode replace-all`:
58 tasks registered, every task produced a sample at all 44 sizes 1…4096 (12.8 s), and
no prepare-time or per-run `precondition` fired (Release keeps `precondition`). The
temporary directory was deleted; numbers were not inspected or interpreted.

**Disclosures for the review.**

- D02 is placed in matched charts per the matrix, but RedBlackTree's `Collection`
  overload reserves capacity while SortedDictionary's initializer does not; the
  report must state this allocation difference. (S03 has no such difference:
  RedBlackTreeSet has only a `Sequence` general initializer.)
- S01/S09 use `0..<n` (contiguous) because `RedBlackTreeSet.init(_: Range)` requires a
  range; all other Set tasks use the even keys. D01/D09a use the even `sortedPairs`.
- S08 includes one element read (`s[i]`) per non-end result on both sides to make the
  result observable; N3's extra `firstIndex(after:)` step remains a disclosed
  implementation property.
- D07 covers existing keys only; a new-key defaulted-subscript variant was not added
  (it would duplicate D03's insertion and was not in the reviewed row).
- Mixed insert/remove/lookup traces remain deferred as decided.

**Next step (not started).** The publishable run (Release, sizes 1…1M doubling plus an
optional labeled 4M–16M run, ≥ 5 cycles, p50) and the capability matrix need Codex/user
authorization after this review.

### Codex Phase 2 review and Phase 3 authorization (2026-10-04)

Phase 2 is accepted. The paired source structure, independent reference checks,
seeded inputs, chart separation, overload choice, timed-region boundaries, and Release
smoke result are sufficient to proceed to a bounded measurement pilot. D02's allocator
preparation difference and S08's implementation-path difference remain mandatory
disclosures; they are not reasons to discard the observable-operation pairs.

Phase 3 is limited to validating the measurement procedure before a publishable run:

1. Build the existing benchmark product in Release without source changes.
2. Run `Libraries/SortedPeer.json` at fixed sizes `16`, `256`, `4096`, and `65536`,
   with exactly five cycles and p50 selected before inspecting results.
3. Retain the raw result artifact and rendered charts under a clearly named
   `Benchmarks/Results/SortedPeerPilot/` directory. Record the exact command, commit,
   OS, CPU, Swift version, dependency resolution, traits, date, and timezone.
4. Verify mechanically that all 58 tasks produced five samples at every requested
   size and that matched/capability charts remain separated.
5. Record per-task cycle spread or another harness-supported variability indicator.
   Flag noisy or suspicious rows without attributing a data-structure cause.

Do not run sizes above 65536, change source after seeing results, omit unfavorable
rows, infer cache/allocation causes from wall-clock timing, rank either package, or
update AdoptionReadinessAssessment. Stop for Codex review after the pilot.

### Phase 3 result (2026-10-04 02:09 JST, Claude Opus 5.5) — awaiting review

Pilot only; timings are not interpreted, packages are not ranked, and no source was
changed before or after the run.

**Artifacts (new, retained, under `Benchmarks/Results/SortedPeerPilot/`).**
`results-20261004-020908-988aecaf.json` (raw), `charts-p50/` (29 PNG + `Results.md`),
`README.md` (environment and exact commands, duplicated below).

**Environment.** Commit `988aecaf34b73a223259490f505171fea8caab25` (benchmark sources
clean; only `Maintanance/` Markdown dirty). Run 02:09:08–02:09:28 JST (+0900), 18.5 s
collection. Apple M1, 8 cores, 16 GiB, AC power, no thermal/performance warning recorded
by `pmset -g therm`; macOS 27.0 (26A428); Apple Swift 6.4 (swiftlang-6.4.0.34.1,
clang-2100.3.34.1), arm64-apple-macosx27.0.0, Release. swift-collections 1.7.0
`a66de878…` with `UnstableSortedCollections`; swift-collections-benchmark 0.0.4;
swift-ac-collections local path with `BENCHMARK` only (normal mode, N1). Inputs: SplitMix64
seed `0x5EED_5047_2026_1004` as in Phase 2.

**Commands (from `Benchmarks/`).**

```sh
swift build -c release --disable-sandbox --product benchmark   # up to date, no rebuild
swift run -c release --disable-sandbox --skip-build benchmark library run \
  --library ./Libraries/SortedPeer.json \
  ./Results/SortedPeerPilot/results-20261004-020908-988aecaf.json \
  --sizes 16 --sizes 256 --sizes 4096 --sizes 65536 --cycles 5 --mode replace-all
swift run -c release --disable-sandbox --skip-build benchmark library render \
  --library ./Libraries/SortedPeer.json \
  ./Results/SortedPeerPilot/results-20261004-020908-988aecaf.json \
  --percentile 50 --format png --output ./Results/SortedPeerPilot/charts-p50
```

Other options were harness defaults (3 iterations, 0.01 s min duration, 10 µs amortized
cutoff; default bands min / mean / mean + 2σ).

**Statistic disclosure (must be decided before the publishable run).** In
swift-collections-benchmark 0.0.4, `--percentile p` is `Sample.discardingPercentile`:
it keeps the lowest ⌈p/100 · count⌉ sorted samples. With five cycles, "p50" keeps the
three fastest cycle minima, and the chart center line is their **mean**, not the median
of five. The raw JSON preserves all five samples, so a true median can be computed
from it; the rendered charts do not show it. Whether to keep the harness p50 as
configured or report a separately computed median needs Codex/user decision.

**Mechanical completeness check (Python over the raw JSON and `SortedPeer.json`).**

- 58 distinct task titles; every task has exactly sizes {16, 256, 4096, 65536}, and
  exactly 5 samples at each size (0 missing/extra). The amortized cutoff did not drop
  any size.
- 29 charts, each exactly 2 tasks with the same peer ID, no `std::` task; the 58 chart
  tasks equal the 58 result titles. Only S02/D01 appear in `Capability differences`,
  and neither appears in a matched group.

**Variability (spread = (max − min) / median of the five cycle samples).** Flag
threshold 10%, chosen when writing the check. 62 of 232 cells are flagged.

| Side | 16 | 256 | 4096 | 65536 |
| --- | --- | --- | --- | --- |
| RedBlackTree (29 tasks) | 12 | 10 | 8 | 17 |
| SortedCollections (29 tasks) | 12 | 2 | 0 | 1 |

Mechanical observations, without cause attribution:

- At size 16, 51 of 58 medians are below 1 µs, and many sub-µs values are exact
  multiples of ~41.7 ns (125, 166, 208, 250 ns). Size-16 spreads therefore reflect
  timer quantization at least in part, and size-16 cells are resolution-limited on
  both sides.
- At 4096/65536, flagged cells are concentrated on the RedBlackTree side (25 vs 1).
  Largest: D09b @65536 51.0% (685–1054 µs), D05b @65536 34.7%, D10a @65536 33.6%,
  D06a @65536 32.5%, S05 @4096 27.3%, S07b @65536 26.3%, D05a @65536 25.6%,
  D06b @65536 24.9%, D07 @65536 21.9%, D08 @65536 21.2%, S08b @65536 20.7%,
  S06 @65536 18.7%. The single SortedCollections flag above 256 is S13 @65536 15.9%
  (917–1083 ns). This asymmetry is a measurement-stability finding to be re-checked by
  repetition (protocol item 8), not evidence of a structural cause.
- Per-task spreads (all 58 × 4) can be regenerated from the raw JSON; the table was
  printed to the terminal and not stored separately.

**Open points for Codex.** (1) Harness-p50 vs computed median (above). (2) Whether to
repeat the pilot (e.g., a second identical run, or interleaved re-runs of the flagged
RedBlackTree rows) before the publishable run, given the one-sided spread at 4096/65536.
(3) Whether size 16 should be reported as resolution-limited or measured with more
iterations per sample. No 1M or multi-million run was made.

### Codex Phase 3 review and pause decision (2026-10-04)

The pilot is accepted as evidence that the matrix, artifact pipeline, completeness
checks, and chart separation work. It is not accepted as publishable comparative
performance evidence: 62 of 232 cells exceeded the predeclared 10% spread threshold,
with a strong one-sided concentration at sizes 4096 and 65536.

Decisions for a future resumption:

1. Compute and report the true median of all five raw cycle samples. Do not call the
   harness's mean of the fastest three samples a median; rendered harness-p50 charts
   may be retained only with that statistic stated exactly.
2. Treat size 16 as resolution-limited rather than drawing comparative conclusions.
   A future run may increase duration/iterations symmetrically if small-size evidence
   is important.
3. Before any 1M or multi-million run, repeat the identical pilot and interleave
   focused repetitions of the flagged rows. Establish a stability rule before looking
   at the repeated timings.
4. Preserve every row and the D02/S08 disclosures. Do not update either
   AdoptionReadinessAssessment from this pilot.

The benchmark line is intentionally paused here so work can return to C++ behavioral
correctness, which remains the higher completion priority.

## Fairness rules

Every paired task must satisfy all of these:

- identical element/key/value types;
- identical pre-generated input values and operation order;
- identical collection size before the timed region;
- setup, shuffling, expected-result construction, and correctness validation outside
  the timed region whenever the harness permits;
- matching mutation semantics and matching unique/shared storage state;
- the same Release toolchain, optimization mode, traits, machine, thermal conditions,
  size sequence, cycle count, and benchmark framework;
- observable use of results through `blackHole` or equivalent;
- correctness checks that are equivalent and do not dominate only one timed path;
- warm-up and multiple cycles for reported results;
- raw result artifacts retained alongside any summary.

If APIs do not express the same operation, classify the row as “not comparable” or
“capability difference.” Do not time a substitute and label it equivalent.

## Required matched workloads

### Construction

- construction from already sorted unique integers;
- construction from a deterministically shuffled unique buffer;
- incremental insertion of deterministically shuffled unique integers.

Do not mix a specialized sorted-input initializer on one side with a general
sequence initializer on the other unless the chart explicitly says it measures that
capability difference.

### Lookup and bounds

- successful membership queries in deterministic shuffled order;
- unsuccessful membership queries with the same count and key-cost distribution;
- successful and unsuccessful exact-index lookup, when both APIs expose it;
- lower/upper-bound style queries only where observably equivalent APIs exist.

### Traversal

- complete ascending sequential iteration;
- iteration after the same shuffled insertion history, to expose layout effects.

### Mutation

- incremental insertion into unique storage;
- removal of every element in the same deterministic randomized order;
- one insertion and one removal after an O(1) value copy, measured separately from
  unique storage to expose copy-on-write behavior;
- mixed deterministic insert/remove/lookup traces only after the single-operation
  pairs are validated.

### Dictionary

Repeat the meaningful matched construction, lookup, update-existing, insert-new,
remove, traversal, and copied-then-mutated workloads for integer keys and values.
State precisely whether an API preserves or replaces an existing value.

## Capability matrix (not timing)

Alongside performance results, record whether each package currently provides:

- Set and Dictionary;
- MultiSet and MultiMap;
- hinted insertion;
- lower/upper/equal-range APIs;
- rank/distance and range views;
- documented index invalidation behavior;
- stable or explicitly unstable public API status.

This matrix must cite source/API evidence. Missing functionality is not a zero-time
benchmark and performance cannot compensate for a missing required capability.

## Measurements that require a separate method

Wall-clock operation benchmarks do not establish memory efficiency, allocation
count, node fanout, or cache misses. Do not infer those from timing alone.

If this task measures any of the following, first document a separate reproducible
method and its overhead:

- peak/resident memory;
- bytes per element;
- allocation counts;
- hardware cache misses or branch misses;
- code size.

Otherwise mark these axes unmeasured. In particular, do not repeat the upstream
general claim that B-trees have better locality as if it were a result for the exact
versions and workloads tested here.

## Execution protocol

1. Preserve an unmodified baseline result artifact.
2. Build and run in Release.
3. Use at least five measured cycles for the publishable run unless total duration
   makes this impractical; record any reduction.
4. Cover small, medium, and large sizes rather than reporting one favorable size.
5. Save the exact command, date/timezone, machine/CPU, OS, Swift version, resolved
   package versions, enabled traits, and Git commit.
6. Render paired charts with neutral titles and consistent axes.
7. Report median/selected benchmark statistic exactly as configured by the harness;
   do not silently choose a different percentile after seeing results.
8. Repeat surprising results before interpreting them.

## Interpretation rules

The report must include relative advantages, disadvantages, crossovers, and
inconclusive/noisy results.
Separate at least these explanations:

- high-fanout B-tree locality;
- pointer-heavy red-black-tree traversal;
- bulk/sorted construction algorithms;
- copy-on-write detachment strategy;
- allocation/reservation effects;
- API capability differences such as hints or multi containers.

These are hypotheses until supported by an independent measurement or direct code
evidence. Do not infer a structural cause from a timing curve alone.

An acceptable conclusion may be that SortedCollections provides better broad
throughput for some workloads while RedBlackTreeCollections offers C++ migration
semantics, hints, multi containers, or specialized index/view behavior for different
needs. Adoption readiness does not require outperforming a peer everywhere; it
requires an evidence-backed reason to choose the package for significant real use
cases during the period in which it fills those gaps. Credit upstream design choices
and documentation where they inform the method, and state clearly when upstream
maturity would narrow or end this bridging role.

## Stop conditions

- Stop if a paired workload produces different observable results.
- Stop if setup or validation cannot be removed symmetrically from the timed region.
- Stop before changing either production implementation to improve a measured result.
- Stop before publishing a chart whose task names hide different semantics.
- Do not edit `AdoptionReadinessAssessment` conclusions until the result artifacts and
  methodology have been independently reviewed.

## Deliverables

- a reviewed matched-workload matrix;
- benchmark source changes limited to `Benchmarks/`;
- exact run commands and environment metadata;
- raw result artifacts and paired charts;
- a concise methodology and results report containing relative advantages,
  disadvantages, crossovers, and unmeasured axes;
- a proposed evidence-only update to both AdoptionReadinessAssessment language versions,
  applied only after user approval.

## Acceptance criteria

- Every published pair measures demonstrably equivalent work.
- Existing benchmark tasks remain available unless explicitly shown invalid.
- Set and Dictionary both have matched coverage.
- No production collection code changes are mixed into the baseline comparison.
- The report names the upstream version and unstable trait status.
- At least one independent review checks task symmetry before conclusions are added
  to the adoption-readiness evidence document (`Archived/AdoptionReadinessAssessment.md`).
