// MARK: - Borrowed, noncopying implementation

extension Collection where Element: Comparable {

  /// Creates an iterator over this order and its lexicographic successors.
  ///
  /// The first call to ``NextPermutations/next()`` returns the collection's current element order.
  /// Later calls return only its lexicographic successors. This does not enumerate orders that
  /// precede the collection's starting order. Elements that compare equal do not produce duplicate
  /// value orderings.
  ///
  /// The iterator copies the elements into one owned buffer when it is created. Advancing mutates
  /// that buffer in place and lends its current contents as a `Span`; it does not allocate or copy
  /// all elements for every result.
  ///
  /// Consume each returned span before calling `next()` again. A span cannot escape the iterator's
  /// lifetime or remain live across its next mutating access.
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

/// An iterator that lends the current element order and its lexicographic successors.
///
/// `NextPermutations` owns a single mutable buffer initialized from its source collection. The
/// first result is the source's current order; each later result is the next lexicographic order.
/// An empty collection, a single element, an all-equal order, and an order with no successor each
/// produce their current order once.
///
/// This type is noncopyable and intentionally does not conform to `Sequence`.
/// `Sequence.Iterator.next()` cannot express that a result borrows the iterator and must not
/// survive its next mutation. Iterate manually with ``next()`` and finish using each returned
/// `Span` before advancing again.
///
/// Advancing by one step mutates the owned buffer in place. It performs no per-result allocation or
/// full-buffer copy.
@safe
public struct NextPermutations<Element: Comparable>: ~Copyable {

  @usableFromInline
  let elements: UnsafeMutablePointer<Element>

  @usableFromInline
  let count: Int

  @usableFromInline
  var initial = true

  @usableFromInline
  var finished = false

  @inlinable
  init<Base: Collection>(copying source: Base) where Base.Element == Element {
    count = source.count
    unsafe elements = .allocate(capacity: Swift.max(count, 1))

    var destination = unsafe elements
    for element in source {
      unsafe destination.initialize(to: element)
      unsafe destination += 1
    }
  }

  @inlinable
  deinit {
    unsafe elements.deinitialize(count: count)
    unsafe elements.deallocate()
  }

  /// Lends the current element order, then advances through its lexicographic successors.
  ///
  /// On the first call, this method returns the order copied from the source collection. On each
  /// subsequent call, it rearranges the same buffer to its next lexicographic order before returning
  /// it. After the last order has been returned, this method returns `nil`; later calls also return
  /// `nil`.
  ///
  /// The returned `Span` uses zero-based indices and borrows this iterator. Read or otherwise
  /// consume it before calling `next()` again. The compiler prevents it from escaping the iterator's
  /// lifetime or overlapping a later mutating access.
  ///
  /// - Returns: A borrowed view of the current order, or `nil` after the final order.
  /// - Complexity: O(n) in the worst case, where n is the number of elements.
  @_lifetime(&self)
  @inlinable
  public mutating func next() -> Span<Element>? {
    if finished {
      return nil
    }

    if initial {
      initial = false
      return unsafe Span(_unsafeStart: elements, count: count)
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

    return unsafe Span(_unsafeStart: elements, count: count)
  }
}
