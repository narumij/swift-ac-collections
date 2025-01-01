//===----------------------------------------------------------------------===//
//
// This source file references a portion of swift-collections' Permutations.swift
// (https://github.com/apple/swift-collections) from a past version, originally
// licensed under the Apache License, Version 2.0 with a Runtime Library Exception.
//
// The only referenced portion is `NextPermutationUnsafeHandle`, which was adapted
// by replacing it with `ManagedBuffer` usage.
//
// Copyright (c) 2025 narumij
// All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Runtime Library Exception to the Apache 2.0 License:
//
// As an exception, if you use this Software to compile your source code and
// portions of this Software are embedded into the binary product as a result,
// you may redistribute such product without providing attribution as would
// otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
//
//===----------------------------------------------------------------------===//

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
