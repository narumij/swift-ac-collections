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
// `NextPermutationsSequence.Permutation.subscript(position:)` (formerly
// `Permutations.SubSequenceN`; titles keep the old name for result continuity),
// so that the cost of a bounds precondition on that subscript can be compared before and after.
//
// Methodology (see Maintanance/PermutationModule/ProductReadinessAssessment.md):
// - The permutation and the index order are built outside the timed region.
// - Only valid indices in `startIndex..<endIndex` are accessed.
// - Shuffled indices use a fixed-seed generator so runs are reproducible.
// - The sum of all accessed elements is validated after the timed region, so
//   the optimizer cannot remove the work.

import CollectionsBenchmark
import PermutationModule

extension Bool: @retroactive Comparable {
  public static func < (lhs: Bool, rhs: Bool) -> Bool {
    lhs != rhs && !lhs
  }
}

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

/// Direct `Array` implementation retained as a performance peer. Returning an
/// `Array` lets the standard library's COW storage and optimizer handle the
/// yielded value's lifetime without a custom buffer wrapper.
private struct ArrayNextPermutationsSequence<Element: Comparable>: Sequence {
  let elements: [Element]

  func makeIterator() -> Iterator {
    Iterator(elements: elements)
  }

  struct Iterator: IteratorProtocol {
    var elements: [Element]
    var initial = true
    var finished = false

    mutating func next() -> [Element]? {
      if finished { return nil }
      if initial {
        initial = false
        return elements
      }
      guard elements.count >= 2 else {
        finished = true
        return nil
      }

      var i = elements.count - 2
      while elements[i] >= elements[i + 1] {
        if i == 0 {
          finished = true
          return nil
        }
        i -= 1
      }

      var j = elements.count - 1
      while elements[j] <= elements[i] {
        j -= 1
      }
      elements.swapAt(i, j)

      var lower = i + 1
      var upper = elements.count - 1
      while lower < upper {
        elements.swapAt(lower, upper)
        lower += 1
        upper -= 1
      }
      return elements
    }
  }
}

/// Experimental borrowing implementation for Swift 6.4's lifetime model.
///
/// The returned span borrows the iterator's current permutation. Calling
/// `next()` again requires exclusive access to the iterator, so the compiler
/// prevents the previous permutation from remaining live across the mutation.
/// Unlike a `Sequence` iterator, this can reuse one buffer without returning a
/// reference-counted value for every permutation.
@available(macOS 26.0, *)
private struct BorrowedNextPermutationsIterator<Element: Comparable>: ~Copyable {
  let elements: UnsafeMutablePointer<Element>
  let count: Int
  var initial = true
  var finished = false

  init(copying elements: Span<Element>) {
    count = elements.count
    self.elements = .allocate(capacity: count)
    for i in 0..<count {
      self.elements.advanced(by: i).initialize(to: elements[i])
    }
  }

  deinit {
    elements.deinitialize(count: count)
    elements.deallocate()
  }

  @_lifetime(&self)
  mutating func next() -> Span<Element>? {
    if finished { return nil }
    if initial {
      initial = false
      return unsafe Span(_unsafeStart: elements, count: count)
    }
    guard count >= 2 else {
      finished = true
      return nil
    }

    var i = count - 2
    while elements[i] >= elements[i + 1] {
      if i == 0 {
        finished = true
        return nil
      }
      i -= 1
    }

    var j = count - 1
    while elements[j] <= elements[i] {
      j -= 1
    }
    let buffer = UnsafeMutableBufferPointer(start: elements, count: count)
    buffer.swapAt(i, j)

    var lower = i + 1
    var upper = count - 1
    while lower < upper {
      buffer.swapAt(lower, upper)
      lower += 1
      upper -= 1
    }
    return unsafe Span(_unsafeStart: elements, count: count)
  }
}

/// Returns the first permutation yielded for `0..<size`, i.e. `0, 1, ..., size - 1`.
private func firstPermutation(_ size: Int) -> NextPermutationsSequence<[Int]>.Permutation {
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

    // Corrected variants (bounds-check validation, CLAUDE_TASK.md Task 1).
    //
    // The two cases above accumulate into `sum`, a variable captured by the
    // timed closure. It lives in a heap box, so every access also stores to
    // memory and the compiler cannot prove that store does not alias the
    // buffer header; `endIndex` is therefore reloaded on every iteration.
    // One pass over 1k elements also lasts only ~9 ticks of the 41.7 ns timer.
    // The variants below accumulate into a local, and repeat the same pass
    // `repetitions(size)` times inside one sample (~1M accesses per sample).
    // `identity(_:)` makes the collection opaque on each pass so the passes
    // cannot be merged. Both code states execute identical work.

    self.add(
      title: "Permutations.SubSequenceN subscript sequential access (batched)",
      input: Int.self
    ) { size in
      let p = firstPermutation(size)
      let reps = repetitions(size)
      return { timer in
        var sum = 0
        timer.measure {
          var total = 0
          for _ in 0..<reps {
            let q = identity(p)
            var s = 0
            var i = q.startIndex
            while i < q.endIndex {
              s &+= q[i]
              i += 1
            }
            total &+= s
          }
          sum = total
        }
        blackHole(sum)
        validate(sum, size: size, repetitions: reps)
      }
    }

    self.add(
      title: "Permutations.SubSequenceN subscript shuffled access (batched)",
      input: Int.self
    ) { size in
      let p = firstPermutation(size)
      let reps = repetitions(size)
      var rng = PermutationBenchmarkRNG(seed: 0x5EED_0000 &+ UInt64(size))
      let indices = Array(p.indices).shuffled(using: &rng)
      return { timer in
        var sum = 0
        timer.measure {
          var total = 0
          for _ in 0..<reps {
            let q = identity(p)
            var s = 0
            for i in indices {
              s &+= q[i]
            }
            total &+= s
          }
          sum = total
        }
        blackHole(sum)
        validate(sum, size: size, repetitions: reps)
      }
    }

    // End-to-end workload (CLAUDE_TASK.md Task 2).
    //
    // `size` is the element count n (bounded to 10, i.e. 3,628,800
    // permutations). Generates every lexicographic successor of `0..<n`
    // through `nextPermutations()` and reads each yielded order through the
    // public subscript, folding it into a position-weighted checksum. The
    // count and checksum are validated against closed forms outside the
    // timed region.
    self.add(
      title: "Permutations nextPermutations end-to-end checksum",
      input: Int.self
    ) { size in
      precondition(1 <= size && size <= 10, "end-to-end size must be in 1...10")
      let source = Array(0..<size)
      return { timer in
        var count = 0
        var checksum = 0
        timer.measure {
          var c = 0
          var s = 0
          for p in identity(source).nextPermutations() {
            for i in p.indices {
              s &+= p[i] &* (i &+ 1)
            }
            c &+= 1
          }
          count = c
          checksum = s
        }
        blackHole(checksum)
        validateEndToEnd(count: count, checksum: checksum, size: size)
      }
    }

    // Representative binary-selection workload: choose 7 positions from 28
    // by enumerating the distinct permutations of 21 zeroes and 7 ones.
    // Downstream processing is deliberately outside this benchmark.
    self.add(
      title: "Permutations binary selection checksum",
      input: Int.self
    ) { size in
      let selectedCount = 7
      precondition(7 <= size && size <= 32, "binary selection size must be in 7...32")
      let source = Array(repeating: 0, count: size - selectedCount)
        + Array(repeating: 1, count: selectedCount)
      return { timer in
        var count = 0
        var checksum = 0
        timer.measure {
          var c = 0
          var s = 0
          for p in identity(source).nextPermutations() {
            for i in p.indices {
              s &+= p[i] &* (i &+ 1)
            }
            c &+= 1
          }
          count = c
          checksum = s
        }
        blackHole(checksum)
        validateBinarySelection(
          count: count,
          checksum: checksum,
          size: size,
          selectedCount: selectedCount)
      }
    }

    self.add(
      title: "Array iterator binary selection checksum",
      input: Int.self
    ) { size in
      let selectedCount = 7
      precondition(7 <= size && size <= 32, "binary selection size must be in 7...32")
      let source = Array(repeating: 0, count: size - selectedCount)
        + Array(repeating: 1, count: selectedCount)
      return { timer in
        var count = 0
        var checksum = 0
        timer.measure {
          var c = 0
          var s = 0
          for permutation in ArrayNextPermutationsSequence(elements: identity(source)) {
            for i in permutation.indices {
              s &+= permutation[i] &* (i &+ 1)
            }
            c &+= 1
          }
          count = c
          checksum = s
        }
        blackHole(checksum)
        validateBinarySelection(
          count: count,
          checksum: checksum,
          size: size,
          selectedCount: selectedCount)
      }
    }

    if #available(macOS 26.0, *) {
      self.add(
        title: "Borrowed Span iterator binary selection checksum",
        input: Int.self
      ) { size in
        let selectedCount = 7
        precondition(7 <= size && size <= 32, "binary selection size must be in 7...32")
        let source = Array(repeating: 0, count: size - selectedCount)
          + Array(repeating: 1, count: selectedCount)
        return { timer in
          var count = 0
          var checksum = 0
          timer.measure {
            var c = 0
            var s = 0
            let input = identity(source)
            var iterator = BorrowedNextPermutationsIterator(copying: input.span)
            while let permutation = iterator.next() {
              var i = 0
              while i < permutation.count {
                s &+= permutation[i] &* (i &+ 1)
                i &+= 1
              }
              c &+= 1
            }
            count = c
            checksum = s
          }
          blackHole(checksum)
          validateBinarySelection(
            count: count,
            checksum: checksum,
            size: size,
            selectedCount: selectedCount)
        }
      }
    }

    self.add(
      title: "Permutations Bool binary selection checksum",
      input: Int.self
    ) { size in
      let selectedCount = 7
      precondition(7 <= size && size <= 32, "binary selection size must be in 7...32")
      let source = Array(repeating: false, count: size - selectedCount)
        + Array(repeating: true, count: selectedCount)
      return { timer in
        var count = 0
        var checksum = 0
        timer.measure {
          var c = 0
          var s = 0
          for permutation in identity(source).nextPermutations() {
            for i in permutation.indices where permutation[i] {
              s &+= i &+ 1
            }
            c &+= 1
          }
          count = c
          checksum = s
        }
        blackHole(checksum)
        validateBinarySelection(
          count: count,
          checksum: checksum,
          size: size,
          selectedCount: selectedCount)
      }
    }
  }
}

/// Number of passes per sample so that one sample performs about 2^20 accesses.
private func repetitions(_ size: Int) -> Int {
  max(1, (1 << 20) / max(1, size))
}

/// Validates the batched sum outside the timed region.
private func validate(_ sum: Int, size: Int, repetitions: Int) {
  precondition(
    sum == repetitions * (size * (size - 1) / 2),
    "Permutation benchmark produced an unexpected sum")
}

/// Validates the end-to-end result outside the timed region.
///
/// Every value appears at every position exactly (n-1)! times, so the
/// checksum is (n-1)! * (0 + ... + (n-1)) * (1 + ... + n).
private func validateEndToEnd(count: Int, checksum: Int, size n: Int) {
  let factorialNMinus1 = (1..<max(1, n)).reduce(1, *)
  precondition(count == factorialNMinus1 * n, "unexpected permutation count")
  precondition(
    checksum == factorialNMinus1 * (n * (n - 1) / 2) * (n * (n + 1) / 2),
    "unexpected permutation checksum")
}

/// Validates distinct binary permutations against closed-form combinations.
private func validateBinarySelection(
  count: Int,
  checksum: Int,
  size n: Int,
  selectedCount k: Int
) {
  precondition(count == binomial(n, k), "unexpected binary permutation count")
  precondition(
    checksum == binomial(n - 1, k - 1) * (n * (n + 1) / 2),
    "unexpected binary permutation checksum")
}

private func binomial(_ n: Int, _ k: Int) -> Int {
  let k = min(k, n - k)
  return (1...k).reduce(1) { result, i in
    result * (n - k + i) / i
  }
}
