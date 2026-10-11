# Permutation Quality Assessment on macOS

This directory keeps macOS performance-assessment evidence for Permutations.
Benchmark implementation and library definitions remain under `Sources/` and
`Libraries/`; this directory contains their generated evidence only.

## Layout

- `Results/`: raw benchmark JSON, named by measurement ID
- `Charts/`: PNG charts using the same measurement ID
- `Environments/`: commit, macOS, hardware, Swift, and Clang records for formal runs

The `provisional-2026-10-11` JSON and PNG are retained for visual inspection
while the formal performance threshold and assessment remain on hold. They do
not include the complete environment record required for a formal assessment.

Scenario:

- Seven `1` values in an otherwise zero-filled ascending binary sequence
- Sizes 8, 12, 16, 20, 24, 28, and 32
- Primary case: `C(28, 7) = 1,184,040` distinct permutations
- Supplemental headroom case: `C(32, 7) = 3,365,856` distinct permutations
- Release configuration, five cycles

Compared implementations:

- Public `Permutations` implementation with its stable yielded-value contract
- Direct Swift `Array` iterator returning `[Element]`
- Public `Permutations` over `[Bool]` with `false < true`
- C++ `std::next_permutation`
