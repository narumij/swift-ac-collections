# OptionalArray Quality Assessment on macOS

This directory keeps macOS performance-assessment evidence for OptionalArray.
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
sequential innermost-axis traversal. Allocation, cold-state reset, and warm-state
preparation are outside the measured region. Swift `OptionalArray` is compared
with Swift nested `Array` and C++ nested `std::vector<intptr_t>`, both using
`-1` as their empty-slot sentinel.
