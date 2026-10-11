# BareArray Quality Assessment on macOS

This directory keeps macOS performance-assessment evidence for BareArray.
Benchmark implementation and library definitions remain under `Sources/` and
`Libraries/`; this directory contains their generated evidence only.

## Layout

- `Results/`: raw benchmark JSON
- `Charts/`: rendered PNG charts
- `Environments/`: environment records for formal runs

Files whose names begin with `provisional-` are retained for visual inspection
before the performance threshold and formal assessment are complete. They are
not formal assessment evidence.

The provisional comparison uses equal-product balanced 2D and 3D shapes and
sequential innermost-axis traversal. Allocation and construction are outside
the measured region. Swift `BareArray` is compared with Swift nested `Array`
and C++ nested `std::vector<intptr_t>` for read-checksum and write workloads.

Run `./run-bare-array-assessment.sh` from the `Benchmarks` directory to create
one timestamped raw result, four charts with the same measurement ID, and the
corresponding commit, macOS, hardware, Swift, and Clang environment record.
The script records the evidence needed by a formal run, but running it does not
decide the performance threshold or turn its output into an accepted assessment.
