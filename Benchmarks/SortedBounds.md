# SortedSet boundary API comparison

Compare the added Swift-style APIs directly against Apple's `SortedSet<Int>`:

- `firstIndex(after:)`: smallest member strictly **greater** than the query.
- `lastIndex(before:)`: largest member strictly **less** than the query.

The latter is a predecessor search, **not** the usual inclusive `lower_bound`.
Each API has separate charts for queries at existing keys and between keys.

```sh
cd Benchmarks
./generate-sorted-bounds.sh
```

The script builds Release, measures through **2,097,152 elements (2M)** with
three cycles and three minimum iterations, and renders four PNG charts.
Sizes are powers of two (`--smoothness 1`). No sanitizer instrumentation is used.
The read-only source-header path formerly selected by `RED_BLACK_TREE_TSAN_SAFE` is now unconditional.

Both containers are built by the same seeded shuffled insertion order using
`SortedPeerInput`. Keys are the even integers in `0..<2N`; hit queries shuffle
these keys and gap queries shuffle the odd integers. Every batch contains N
queries. Construction, input generation, per-query verification and destruction
are outside timing. Each timed query finds an optional index, reads its element
if present, and accumulates a checksum or missing-result count. Thus the chart
includes index dereferencing and result handling, not just tree traversal.

Before timing each size, every result is checked against the arithmetic oracle,
including queries below the minimum and above the maximum. The initial checks
warm the containers; this is not a cold-cache latency measurement. Different
insertion histories, key types and access distributions are not covered.

The framework keeps the best timing from the iterations in each cycle. Plotted
bands describe the cycle samples, not a statistical confidence interval. Results
are machine-specific. The result directory contains the raw JSON, dependency
revisions, environment information, logs and charts.
