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

extension Collection where Index == Int {

  /// CoWが一切発動しないpermutations
  ///
  /// 重複のないシーケンスであることが利用する上での条件です。
  /// 重複がある場合の動作は未定義です。
  @inlinable
  @inline(__always)
  public __consuming func unsafePermutations() -> PermutationsSequence<Self> {
    .init(unsafe: self)
  }
}

public
  struct PermutationsSequence<C> where C: Collection, C.Index == Int
{
  @usableFromInline
  let source: C

  @usableFromInline
  var _unsafe: Bool

  @inlinable
  @inline(__always)
  public init(unsafe source: C) {
    self.source = source
    _unsafe = true
  }

  @inlinable
  @inline(__always)
  public init(safe source: C) {
    self.source = source
    _unsafe = false
  }
}

extension PermutationsSequence: Sequence {

  @inlinable
  @inline(__always)
  public __consuming func makeIterator() -> Iterator {
    .init(
      elementBuffer: .prepare(source: source),
      buffer: .prepare(count: source.count),
      _unsafe: _unsafe)
  }

  public
    struct Iterator: IteratorProtocol
  {
    @inlinable
    @inline(__always)
    internal init(
      elementBuffer: ElementBuffer,
      buffer: IndexBuffer,
      _unsafe: Bool
    ) {
      self.elementBuffer = elementBuffer
      self.indexBuffer = buffer
      self._unsafe = _unsafe
    }

    @usableFromInline
    let elementBuffer: ElementBuffer
    @usableFromInline
    var indexBuffer: IndexBuffer
    @usableFromInline
    var start = true
    @usableFromInline
    var end = false
    @usableFromInline
    var _unsafe: Bool

    @inlinable
    @inline(__always)
    mutating func ensureUnique() {
      if !isKnownUniquelyReferenced(&indexBuffer) {
        indexBuffer = indexBuffer.copy()
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
        end = !indexBuffer.nextPermutation()
      }
      return end ? nil : SubSequence(elementBuffer: elementBuffer, buffer: indexBuffer)
    }
  }
}

extension PermutationsSequence {

  @usableFromInline
  struct Header {
    @usableFromInline
    @inline(__always)
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
  class IndexBuffer: ManagedBuffer<Header, Int> {

    @inlinable
    deinit {
      self.withUnsafeMutablePointers { header, elements in
        elements.deinitialize(count: header.pointee.count)
        header.deinitialize(count: 1)
      }
    }
  }

  @usableFromInline
  class ElementBuffer: ManagedBuffer<Header, C.Element> {

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
      elementBuffer: ElementBuffer,
      buffer: IndexBuffer
    ) {
      self.elementBuffer = elementBuffer
      self.indexBuffer = buffer
    }
    @usableFromInline
    let elementBuffer: ElementBuffer
    @usableFromInline
    var indexBuffer: IndexBuffer
  }
}

extension PermutationsSequence.SubSequence: RandomAccessCollection {
  @inlinable
  @inline(__always)
  public var startIndex: Int { indexBuffer.startIndex }
  @inlinable
  @inline(__always)
  public var endIndex: Int { indexBuffer.endIndex }
  public typealias Index = Int
  public typealias Element = C.Element
  @inlinable
  @inline(__always)
  public subscript(position: Int) -> C.Element {
    elementBuffer[indexBuffer[position]]
  }
  #if AC_COLLECTIONS_INTERNAL_CHECKS
    public var _copyCount: UInt { indexBuffer.header.copyCount }
  #endif
}

extension PermutationsSequence.IndexBuffer {

  @inlinable
  @inline(__always)
  internal static func create(
    withCapacity capacity: Int
  ) -> Self {
    let storage = PermutationsSequence.IndexBuffer.create(minimumCapacity: capacity) { _ in
      PermutationsSequence.Header(capacity: capacity, count: 0)
    }
    return unsafeDowncast(storage, to: Self.self)
  }

  @inlinable
  @inline(__always)
  internal func copy(newCapacity: Int? = nil) -> PermutationsSequence.IndexBuffer {

    let capacity = newCapacity ?? self.header.capacity
    let count = self.header.count
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      let copyCount = self.header.copyCount
    #endif

    let newStorage = PermutationsSequence.IndexBuffer.create(withCapacity: capacity)

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

extension PermutationsSequence.IndexBuffer {

  @inlinable
  @inline(__always)
  static func prepare(count: Int) -> PermutationsSequence.IndexBuffer {

    let capacity = count
    let count = count

    let newStorage = PermutationsSequence.IndexBuffer.create(withCapacity: capacity)
    newStorage.header.capacity = capacity
    newStorage.header.count = count
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      newStorage.header.copyCount = 0
    #endif
    newStorage.withUnsafeMutablePointerToElements { newElements in
      for i in 0 ..< count {
        (newElements + Int(i)).initialize(to: i)
      }
    }
    return newStorage
  }
}

extension PermutationsSequence.IndexBuffer {

  @inlinable
  @inline(__always)
  var __header_ptr: UnsafeMutablePointer<PermutationsSequence.Header> {
    withUnsafeMutablePointerToHeader({ $0 })
  }

  @inlinable
  @inline(__always)
  var __storage_ptr: UnsafeMutablePointer<Int> {
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
  func lastIndex(where predicate: (Int) -> Bool) -> Index? {
    (startIndex..<endIndex).last { predicate(self[$0]) }
  }
  @inlinable
  subscript(position: Index) -> Int {
    @inline(__always)
    get { __storage_ptr[position] }
    @inline(__always)
    _modify { yield &__storage_ptr[position] }
  }

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

extension PermutationsSequence.ElementBuffer {

  @inlinable
  @inline(__always)
  internal static func create(
    withCapacity capacity: Int
  ) -> Self {
    let storage = PermutationsSequence.ElementBuffer.create(minimumCapacity: capacity) { _ in
      PermutationsSequence.Header(capacity: capacity, count: 0)
    }
    return unsafeDowncast(storage, to: Self.self)
  }

  @inlinable
  @inline(__always)
  static func prepare(source: C) -> PermutationsSequence.ElementBuffer {

    let capacity = source.count
    let count = source.count

    let newStorage = PermutationsSequence.ElementBuffer.create(withCapacity: capacity)
    newStorage.header.capacity = capacity
    newStorage.header.count = count
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      newStorage.header.copyCount = 0
    #endif

    #if false
      source.withUnsafeBufferPointer { sourceElements in
        newStorage.withUnsafeMutablePointerToElements { newElements in
          newElements.initialize(from: sourceElements.baseAddress!, count: count)
        }
      }
    #else
      newStorage.withUnsafeMutablePointerToElements { newElements in
        source.enumerated().forEach { i, v in
          (newElements + i).initialize(to: v)
        }
      }
    #endif
    return newStorage
  }
}

extension PermutationsSequence.ElementBuffer {
  @inlinable
  @inline(__always)
  var __storage_ptr: UnsafeMutablePointer<C.Element> {
    withUnsafeMutablePointerToElements({ $0 })
  }
  @inlinable
  subscript(position: Int) -> C.Element {
    @inline(__always)
    get { __storage_ptr[position] }
    @inline(__always)
    _modify { yield &__storage_ptr[position] }
  }
}
