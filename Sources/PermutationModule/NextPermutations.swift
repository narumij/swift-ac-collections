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

// The iterator owns one mutable element buffer. Each yielded permutation is a view into that
// buffer and remains valid only until the iterator advances or is destroyed.

extension Collection where Element: Comparable {

  @inlinable
  public func nextPermutations() -> NextPermutations<Element> {
    .init(copying: self)
  }
}

@safe
public struct NextPermutations<Value: Comparable>: ~Copyable {

  @usableFromInline
  let elements: UnsafeMutablePointer<Value>

  @usableFromInline
  let count: Int

  @usableFromInline
  let gateKeeper: GateKeeper

  @usableFromInline
  var initial = true

  @usableFromInline
  var finished = false

  @inlinable
  init<Base: Collection>(copying source: Base) where Base.Element == Value {
    count = source.count
    unsafe elements = .allocate(capacity: Swift.max(count, 1))
    gateKeeper = GateKeeper.create()

    var destination = unsafe elements
    for element in source {
      unsafe destination.initialize(to: element)
      unsafe destination += 1
    }
  }

  @inlinable
  deinit {
    gateKeeper.closeCurrentView()
    unsafe elements.deinitialize(count: count)
    unsafe elements.deallocate()
  }

  @inlinable
  public mutating func next() -> Permutation? {
    gateKeeper.closeCurrentView()

    if finished {
      return nil
    }

    if initial {
      initial = false
      return makePermutation()
    }

    guard count >= 2 else {
      finished = true
      return nil
    }

    var i = count - 2
    while unsafe elements[i] >= elements[i + 1] {
      if i == 0 {
        finished = true
        return nil
      }
      i -= 1
    }

    var j = count - 1
    while unsafe elements[j] <= elements[i] {
      j -= 1
    }

    let buffer = unsafe UnsafeMutableBufferPointer(start: elements, count: count)
    unsafe buffer.swapAt(i, j)

    var lower = i + 1
    var upper = count - 1
    while lower < upper {
      unsafe buffer.swapAt(lower, upper)
      lower += 1
      upper -= 1
    }

    return makePermutation()
  }

  @inlinable
  mutating func makePermutation() -> Permutation {
    return unsafe Permutation(
      elements: elements,
      count: count,
      gateKeeper: gateKeeper,
      generation: gateKeeper.generation)
  }

}

extension NextPermutations {

  @safe
  public struct Permutation: RandomAccessCollection {
    public typealias Element = Value
    public typealias Index = Int

    @usableFromInline
    let elements: UnsafeMutablePointer<Element>

    @usableFromInline
    let _count: Int

    @usableFromInline
    let gateKeeper: GateKeeper

    @usableFromInline
    let generation: UInt

    @inlinable
    init(
      elements: UnsafeMutablePointer<Element>,
      count: Int,
      gateKeeper: GateKeeper,
      generation: UInt
    ) {
      unsafe self.elements = elements
      self._count = count
      self.gateKeeper = gateKeeper
      self.generation = generation
    }

    @inlinable
    public var startIndex: Int {
      precondition(!gateKeeper.isClosed(generation: generation), "Permutation view is no longer valid")
      return 0
    }

    @inlinable
    public var endIndex: Int {
      precondition(!gateKeeper.isClosed(generation: generation), "Permutation view is no longer valid")
      return _count
    }

    @inlinable
    public subscript(position: Int) -> Element {
      precondition(!gateKeeper.isClosed(generation: generation), "Permutation view is no longer valid")
      precondition(position >= 0 && position < _count, "Index out of range")
      return unsafe elements[position]
    }
  }
}
