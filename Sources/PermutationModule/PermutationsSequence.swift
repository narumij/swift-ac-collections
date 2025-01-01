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

import Foundation

extension Sequence where Element: Comparable {

  /// CoWが一切発動しないpermutations
  ///
  /// 重複のないシーケンスであることが利用する上での条件です。
  /// 重複がある場合の動作は未定義です。
  @inlinable
  @inline(__always)
  public func unsafePermutations() -> PermutationsSequence<Element> {
    .init(unsafe: self)
  }
}

public
  struct PermutationsSequence<Element: Comparable>
{
  @usableFromInline
  var _source: [Element]

  @usableFromInline
  var _unsafe: Bool

  @inlinable
  @inline(__always)
  public init<S>(unsafe uniqueSequence: S) where S: Sequence, S.Element == Element {
    _source = uniqueSequence.sorted()
    _unsafe = true
  }

  @inlinable
  @inline(__always)
  public init<S>(safe uniqueSequence: S) where S: Sequence, S.Element == Element {
    _source = uniqueSequence.sorted()
    _unsafe = false
  }
}

extension PermutationsSequence: Sequence {

  @inlinable
  @inline(__always)
  public __consuming func makeIterator() -> Iterator {
    .init(buffer: .prepare(_source), _unsafe: _unsafe)
  }

  public
    struct Iterator: IteratorProtocol
  {
    @inlinable
    @inline(__always)
    internal init(
      buffer: PermutationsSequence<Element>.Buffer,
      _unsafe: Bool
    ) {
      self.buffer = buffer
      self._unsafe = _unsafe
    }

    @usableFromInline
    var buffer: Buffer
    @usableFromInline
    var start = true
    @usableFromInline
    var end = false
    @usableFromInline
    var _unsafe: Bool

    @inlinable
    @inline(__always)
    mutating func ensureUnique() {
      if !isKnownUniquelyReferenced(&buffer) {
        buffer = buffer.copy()
      }
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> SubSequence? {
      guard !end else { return nil }
      if start {
        start = false
      } else {
        if !_unsafe {
          ensureUnique()
        }
        end = !buffer.nextPermutation()
      }
      return end ? nil : SubSequence(buffer: buffer)
    }
  }
}

extension PermutationsSequence {

  @usableFromInline
  struct Header {
    @usableFromInline
    internal init(capacity: Int, count: Int) {
      self.capacity = capacity
      self.count = count
    }
    @usableFromInline
    var capacity: Int
    @usableFromInline
    var count: Int
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      @usableFromInline
      var copyCount: UInt = 0
    #endif
  }

  @usableFromInline
  class Buffer: ManagedBuffer<Header, Element> {

    @inlinable
    deinit {
      self.withUnsafeMutablePointers { header, elements in
        elements.deinitialize(count: header.pointee.count)
        header.deinitialize(count: 1)
      }
    }
  }

  public
    struct SubSequence
  {
    @inlinable
    @inline(__always)
    internal init(
      buffer: PermutationsSequence<Element>.Buffer
    ) {
      self.buffer = buffer
    }

    @usableFromInline
    var buffer: PermutationsSequence.Buffer
  }
}

extension PermutationsSequence.SubSequence: RandomAccessCollection {
  @inlinable
  @inline(__always)
  public var startIndex: Int { buffer.startIndex }
  @inlinable
  @inline(__always)
  public var endIndex: Int { buffer.endIndex }
  public typealias Index = Int
  public typealias Element = Element
  @inlinable
  @inline(__always)
  public subscript(position: Int) -> Element { buffer[position] }
  #if AC_COLLECTIONS_INTERNAL_CHECKS
    public var _copyCount: UInt { buffer.header.copyCount }
  #endif
}

extension PermutationsSequence.Buffer {

  @inlinable
  internal static func create(
    withCapacity capacity: Int
  ) -> Self {
    let storage = PermutationsSequence.Buffer.create(minimumCapacity: capacity) { _ in
      PermutationsSequence.Header(capacity: capacity, count: 0)
    }
    return unsafeDowncast(storage, to: Self.self)
  }

  @inlinable
  internal func copy(newCapacity: Int? = nil) -> PermutationsSequence.Buffer {

    let capacity = newCapacity ?? self.header.capacity
    let count = self.header.count
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      let copyCount = self.header.copyCount
    #endif

    let newStorage = PermutationsSequence.Buffer.create(withCapacity: capacity)

    newStorage.header.capacity = capacity
    newStorage.header.count = count
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      newStorage.header.copyCount = copyCount &+ 1
    #endif

    self.withUnsafeMutablePointerToElements { oldElements in
      newStorage.withUnsafeMutablePointerToElements { newElements in
        newElements.initialize(from: oldElements, count: count)
      }
    }

    return newStorage
  }
}

extension PermutationsSequence.Buffer {

  @inlinable
  @inline(__always)
  static func prepare(_ source: [Element]) -> PermutationsSequence.Buffer {

    let capacity = source.count
    let count = source.count

    let newStorage = PermutationsSequence.Buffer.create(withCapacity: capacity)
    newStorage.header.capacity = capacity
    newStorage.header.count = count
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      newStorage.header.copyCount = 0
    #endif
    source.withUnsafeBufferPointer { sourceElements in
      newStorage.withUnsafeMutablePointerToElements { newElements in
        newElements.initialize(from: sourceElements.baseAddress!, count: count)
      }
    }
    return newStorage
  }
}

extension PermutationsSequence.Buffer {

  @inlinable
  @inline(__always)
  var __header_ptr: UnsafeMutablePointer<PermutationsSequence.Header> {
    withUnsafeMutablePointerToHeader({ $0 })
  }

  @inlinable
  @inline(__always)
  var __storage_ptr: UnsafeMutablePointer<Element> {
    withUnsafeMutablePointerToElements({ $0 })
  }

  @usableFromInline
  typealias Index = Int

  @inlinable
  @inline(__always)
  var isEmpty: Bool { __header_ptr.pointee.count == 0 }
  @inlinable
  @inline(__always)
  var startIndex: Index { 0 }
  @inlinable
  @inline(__always)
  var endIndex: Index { __header_ptr.pointee.count }

  @inlinable
  @inline(__always)
  func formIndex(before i: inout Index) { i -= 1 }
  @inlinable
  @inline(__always)
  func formIndex(after i: inout Index) { i += 1 }
  @inlinable
  @inline(__always)
  func index(before i: Index) -> Index { i - 1 }
  @inlinable
  @inline(__always)
  func swapAt(_ a: Index, _ b: Index) { swap(&self[a], &self[b]) }
  @inlinable
  @inline(__always)
  func lastIndex(where predicate: (Element) -> Bool) -> Index? {
    (startIndex..<endIndex).last(where: { predicate(self[$0]) })
  }
  @inlinable
  @inline(__always)
  subscript(position: Index) -> Element {
    get { __storage_ptr[position] }
    _modify { yield &__storage_ptr[position] }
  }

  // オリジナルはhttps://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Permutations.swift
  @inlinable
  internal func nextPermutation(upperBound: Index? = nil) -> Bool {
    guard !isEmpty else { return false }
    var i = index(before: endIndex)
    if i == startIndex { return false }

    let upperBound = upperBound ?? endIndex

    while true {
      let ip1 = i
      formIndex(before: &i)

      if self[i] < self[ip1] {
        let j = lastIndex(where: { self[i] < $0 })!
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