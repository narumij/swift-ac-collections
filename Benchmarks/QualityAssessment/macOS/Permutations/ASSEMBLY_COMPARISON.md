# Provisional Swift and C++ Assembly Comparison

This note compares the optimized assembly for the same 64-bit integer binary-selection workload.
It is diagnostic evidence, not a formal performance judgment.

## Toolchains

- Apple Swift 6.4 (`swiftlang-6.4.0.34.1`)
- Apple Clang 21.0.0 (`clang-2100.3.34.2`)
- Target: arm64 macOS 27

The Swift source was compiled together with the current `Permutations.swift` using
`swiftc -O -whole-module-optimization`. The C++ peer used
`clang++ -O2 -std=c++20`. Both functions accept runtime size and selected-count
arguments, enumerate all distinct permutations, and calculate the same
position-weighted checksum.

## Hot-loop result

Clang fully inlines `std::next_permutation`. Its per-permutation loop contains
no function calls: pivot search, successor search, swap, suffix reversal, and
checksum accumulation are direct ARM64 loads, stores, comparisons, and branches.

The Swift `-O` loop retains these runtime calls on each permutation:

1. `swift_isUniquelyReferenced_nonNull_native` once before mutation.
2. `swift_beginAccess` at least twice around managed-buffer header access and mutation.

The Swift loop also retains checked-arithmetic failure branches. The extracted
function contains six `b.vs` overflow branches; the C++ function contains none.
The checksum loops in both outputs process two 64-bit elements per iteration
using paired loads and multiply-add instructions, so checksum generation itself
is similarly optimized.

The Swift copy path remains available when the buffer is shared. It calls
`swift_allocObject`, `memcpy`, and `swift_release`. It is conditional rather than
part of the uniquely referenced hot path, but the uniqueness check is always
executed.

## `-Ounchecked` control

Compiling the Swift function with `-Ounchecked` removes the `swift_beginAccess`
calls and the six checked-arithmetic branches from the hot function. The
uniqueness runtime call remains once per permutation. This indicates that the
observed structural difference has two sources:

- safety and dynamic-access enforcement retained by normal release `-O`;
- the custom buffer's COW uniqueness check, which remains even without checks.

The product assessment uses normal release `-O`; `-Ounchecked` is only a control
for interpreting assembly and is not proposed as a deployment configuration.

## Interpretation

The assembly supports the measured result that the current Swift implementation
is slower than the C++ peer even though its core search and checksum loops are
well optimized. C++ reaches a call-free mutation loop, while Swift pays runtime
storage/access checks on every one of the millions of yielded permutations.
Assembly alone does not establish how much time each call contributes, and it
does not attribute whole-solution submission time to Permutations.
