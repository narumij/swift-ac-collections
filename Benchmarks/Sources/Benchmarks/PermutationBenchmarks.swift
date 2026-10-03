//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

// Added for Maintanance/CLAUDE_TASK.md (Permutation boundary fix).
// Measures repeated valid element access through the public
// `Permutations.SubSequenceN.subscript(position:)`, so that the cost of a
// bounds precondition on that subscript can be compared before and after.
//
// Methodology (see Maintanance/PermutationModule/ProductReadinessAssessment.md):
// - The permutation and the index order are built outside the timed region.
// - Only valid indices in `startIndex..<endIndex` are accessed.
// - Shuffled indices use a fixed-seed generator so runs are reproducible.
// - The sum of all accessed elements is validated after the timed region, so
//   the optimizer cannot remove the work.

import CollectionsBenchmark
import PermutationModule

/// SplitMix64. Deterministic generator for reproducible shuffled indices.
private struct PermutationBenchmarkRNG: RandomNumberGenerator {
  var state: UInt64

  init(seed: UInt64) { state = seed }

  mutating func next() -> UInt64 {
    state &+= 0x9E37_79B9_7F4A_7C15
    var z = state
    z = (z ^ (z &>> 30)) &* 0xBF58_476D_1CE4_E5B9
    z = (z ^ (z &>> 27)) &* 0x94D0_49BB_1331_11EB
    return z ^ (z &>> 31)
  }
}

/// Returns the first permutation yielded for `0..<size`, i.e. `0, 1, ..., size - 1`.
private func firstPermutation(_ size: Int) -> Permutations<[Int]>.SubSequenceN {
  var iterator = Array(0..<size).nextPermutations().makeIterator()
  return iterator.next()!
}

/// Validates the accessed sum outside the timed region.
private func validate(_ sum: Int, size: Int) {
  precondition(
    sum == size * (size - 1) / 2,
    "Permutation benchmark produced an unexpected sum")
}

extension Benchmark {
  public mutating func addPermutationBenchmarks() {

    self.add(
      title: "Permutations.SubSequenceN subscript sequential access",
      input: Int.self
    ) { size in
      let p = firstPermutation(size)
      return { timer in
        var sum = 0
        timer.measure {
          var i = p.startIndex
          while i < p.endIndex {
            sum &+= p[i]
            i += 1
          }
        }
        blackHole(sum)
        validate(sum, size: size)
      }
    }

    self.add(
      title: "Permutations.SubSequenceN subscript shuffled access",
      input: Int.self
    ) { size in
      let p = firstPermutation(size)
      var rng = PermutationBenchmarkRNG(seed: 0x5EED_0000 &+ UInt64(size))
      let indices = Array(p.indices).shuffled(using: &rng)
      return { timer in
        var sum = 0
        timer.measure {
          for i in indices {
            sum &+= p[i]
          }
        }
        blackHole(sum)
        validate(sum, size: size)
      }
    }
  }
}
