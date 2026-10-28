//===----------------------------------------------------------------------===//
// Portions adapted from the Swift Algorithms open source project:
// Sources/Algorithms/Permutations.swift and Sources/Algorithms/Rotate.swift.
// Source URLs are retained beside the adapted methods below.
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception.
// See Licenses/swift-algorithms.txt in the repository root for the full license.
//
// Copyright (c) 2025 narumij
// Adapted and modified for the integer-indexed NextPermutationProtocol used
// by swift-ac-collections. Project modifications are licensed under Apache
// License v2.0; see LICENSE in the repository root.
//===----------------------------------------------------------------------===//

#if COMPATIBLE_ATCODER_2025
@usableFromInline
protocol NextPermutationProtocol where Element: Comparable {
  associatedtype Element
  var isEmpty: Bool { get }
  var startIndex: Index { get }
  var endIndex: Index { get }
  func formIndex(before i: inout Index)
  func formIndex(after i: inout Index)
  func index(before i: Index) -> Index
  func swapAt(_ a: Index, _ b: Index)
  func lastIndex(where predicate: (Element) -> Bool) -> Index?
  subscript(position: Index) -> Element { get set }
}

extension NextPermutationProtocol {

  public typealias Index = Int

  // オリジナルはhttps://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Permutations.swift
  @inlinable
  @inline(__always)
  internal func nextPermutation(upperBound: Index? = nil) -> Bool {
    guard !isEmpty else { return false }
    var i = index(before: endIndex)
    if i == startIndex { return false }

    let upperBound = upperBound ?? endIndex

    while true {
      let ip1 = i
      formIndex(before: &i)

      if self[i] < self[ip1] {
        let j = lastIndex { self[i] < $0 }!
        swapAt(i, j)
        reverse(subrange: ip1..<endIndex)
        if i < upperBound {
          return true
        } else {
          i = index(before: endIndex)
          continue
        }
      }

      if i == startIndex {
        reverse(subrange: startIndex..<endIndex)
        return false
      }
    }
  }

  // オリジナルはhttps://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Rotate.swift
  @inlinable
  @inline(__always)
  internal func reverse(subrange: Range<Index>) {
    if subrange.isEmpty { return }
    var lower = subrange.lowerBound
    var upper = subrange.upperBound
    while lower < upper {
      formIndex(before: &upper)
      swapAt(lower, upper)
      formIndex(after: &lower)
    }
  }
}
#endif
