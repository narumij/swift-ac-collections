TSan-safe Trait benchmark, 2026-10-29
Release, Apple Swift 6.4 (swiftlang-6.4.0.34.1), arm64 macOS.
RED_BLACK_TREE_TSAN_SAFE enabled explicitly in benchmark dependency traits, alongside BENCHMARK and ENABLE_OPTIONAL_ELEMENT_BUFFER.
Thread Sanitizer instrumentation OFF. This measures the safe-access implementation, not sanitizer overhead.
Current working-tree sources include the 16 TODO call-site flag changes.
Four tasks, default size progression through 16M, 1 complete cycle retained, default iterations/durations. Initially requested 3 cycles; additional cycles stopped after the first complete 16M run (~2316 seconds). One cycle does not estimate between-cycle variance.
C++ std::set baseline measured in the same run.
Rendering: 1ns to 10us, 90th percentile, default min/mean/mean+2sigma bands.
Original charts preserved; no claim of controlled trait ON/OFF comparison against historical images.
Build plan retained in build-plan.yaml. Temporary benchmark manifest edit restored after building.
