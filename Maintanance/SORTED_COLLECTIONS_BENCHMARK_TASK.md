# RedBlackTreeCollections vs. Swift Collections SortedCollections

Status: Ready — next evidence-priority assignment; begin with Phase 1 only

## Why this task exists

`WorldClassAssessment.md` identifies a missing external comparison. The most direct
Swift peer is Apple's experimental `SortedCollections` module: `SortedSet` and
`SortedDictionary`, implemented over an in-memory B-tree.

This task must discover where each design wins and loses. It is not authorized to
manufacture a favorable chart or reduce “world-class” to a single timing result.

The project has moved from broad feature expansion to focused refinement. The
priority is therefore credibility for an adoption decision: reproducible evidence,
explicit limitations, and fair external comparison take precedence over adding more
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

The report must include wins, losses, crossovers, and inconclusive/noisy results.
Separate at least these explanations:

- high-fanout B-tree locality;
- pointer-heavy red-black-tree traversal;
- bulk/sorted construction algorithms;
- copy-on-write detachment strategy;
- allocation/reservation effects;
- API capability differences such as hints or multi containers.

These are hypotheses until supported by an independent measurement or direct code
evidence. Do not infer a structural cause from a timing curve alone.

The acceptable conclusion may be that SortedCollections wins broad throughput while
RedBlackTreeCollections offers stronger C++ migration semantics, hints, multi
containers, or specialized index/view behavior. “World-class candidate” does not
require winning every workload; it requires an evidence-backed reason to choose the
package for significant real use cases.

## Stop conditions

- Stop if a paired workload produces different observable results.
- Stop if setup or validation cannot be removed symmetrically from the timed region.
- Stop before changing either production implementation to improve a measured result.
- Stop before publishing a chart whose task names hide different semantics.
- Do not edit `WorldClassAssessment` conclusions until the result artifacts and
  methodology have been independently reviewed.

## Deliverables

- a reviewed matched-workload matrix;
- benchmark source changes limited to `Benchmarks/`;
- exact run commands and environment metadata;
- raw result artifacts and paired charts;
- a concise methodology and results report containing wins, losses, crossovers, and
  unmeasured axes;
- a proposed evidence-only update to both WorldClassAssessment language versions,
  applied only after user approval.

## Acceptance criteria

- Every published pair measures demonstrably equivalent work.
- Existing benchmark tasks remain available unless explicitly shown invalid.
- Set and Dictionary both have matched coverage.
- No production collection code changes are mixed into the baseline comparison.
- The report names the upstream version and unstable trait status.
- At least one independent review checks task symmetry before conclusions are added
  to the world-class assessment.
