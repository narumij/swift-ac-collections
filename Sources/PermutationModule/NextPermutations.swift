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

  /// Creates an iterator over this order and its lexicographic successors.
  ///
  /// The first call to ``NextPermutations/next()`` returns the collection's current element order.
  /// Later calls return only its lexicographic successors. This does not enumerate orders that
  /// precede the collection's starting order. Elements that compare equal do not produce duplicate
  /// value orderings.
  ///
  /// The iterator copies the elements into one owned buffer when it is created. Advancing mutates
  /// that buffer in place and returns a temporary view of its current contents; it does not allocate
  /// or copy all elements for every result.
  ///
  /// Consume each returned view before calling `next()` again. To preserve a result, copy it into
  /// an owning collection such as `Array` while the view is valid.
  ///
  /// ```swift
  /// var permutations = [2, 1, 3].nextPermutations()
  /// while let permutation = permutations.next() {
  ///   print(Array(permutation))
  /// }
  /// // [2, 1, 3]
  /// // [2, 3, 1]
  /// // [3, 1, 2]
  /// // [3, 2, 1]
  /// ```
  ///
  /// - Returns: A noncopyable iterator that owns a copy of this collection's elements.
  /// - Complexity: O(n), where n is the number of elements in the collection.
  @inlinable
  public func nextPermutations() -> NextPermutations<Element> {
    .init(copying: self)
  }
}

/// An iterator over an element order and its lexicographic successors.
///
/// `NextPermutations` owns a single mutable buffer initialized from its source collection. The
/// first result is the source's current order; each later result is the next lexicographic order.
/// An empty collection, a single element, an all-equal order, and an order with no successor each
/// produce their current order once.
///
/// This type is noncopyable and intentionally does not conform to `Sequence`. Iterate manually
/// with ``next()`` and finish using each returned ``Permutation`` before advancing again. Calling
/// `next()` invalidates every previously returned view, including when the call returns `nil`.
/// Destroying the iterator also invalidates its views. Accessing an invalid view stops execution
/// with a precondition failure.
///
/// Advancing by one step mutates the owned buffer in place. It performs no per-result allocation or
/// full-buffer copy.
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

  /// Returns the current element order, then advances through its lexicographic successors.
  ///
  /// On the first call, this method returns the order copied from the source collection. On each
  /// subsequent call, it rearranges the same buffer to its next lexicographic order before returning
  /// it. After the last order has been returned, this method returns `nil`; later calls also return
  /// `nil`.
  ///
  /// Calling this method invalidates all previously returned views before producing its result. Read
  /// or otherwise consume a view before advancing. To retain an order, create an owning copy such as
  /// `Array(permutation)` while the view is still valid.
  ///
  /// - Returns: A temporary view of the current order, or `nil` after the final order.
  /// - Complexity: O(n) in the worst case, where n is the number of elements.
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

  /// A temporary random-access view of one permutation.
  ///
  /// The view uses zero-based integer indices and refers to its iterator's mutable element buffer.
  /// Copying a view does not copy its elements: all copies share the same validity period. The view
  /// remains valid only until the iterator's next mutating `next()` call or until the iterator is
  /// destroyed. Accessing ``startIndex``, ``endIndex``, or a subscript after invalidation stops
  /// execution with a precondition failure.
  ///
  /// To preserve the element order beyond that boundary, copy it into an owning collection such as
  /// `Array` while it is valid.
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

    /// The position of the first element, always zero.
    ///
    /// Accessing this property after the view is invalidated stops execution with a precondition
    /// failure.
    ///
    /// - Complexity: O(1).
    @inlinable
    public var startIndex: Int {
      precondition(!gateKeeper.isClosed(generation: generation), "Permutation view is no longer valid")
      return 0
    }

    /// The position one past the last element.
    ///
    /// Accessing this property after the view is invalidated stops execution with a precondition
    /// failure.
    ///
    /// - Complexity: O(1).
    @inlinable
    public var endIndex: Int {
      precondition(!gateKeeper.isClosed(generation: generation), "Permutation view is no longer valid")
      return _count
    }

    /// Returns the element at the given zero-based position.
    ///
    /// Accessing this subscript after the view is invalidated, or with a position outside
    /// `startIndex..<endIndex`, stops execution with a precondition failure.
    ///
    /// - Complexity: O(1).
    @inlinable
    public subscript(position: Int) -> Element {
      precondition(!gateKeeper.isClosed(generation: generation), "Permutation view is no longer valid")
      precondition(position >= 0 && position < _count, "Index out of range")
      return unsafe elements[position]
    }
  }
}
