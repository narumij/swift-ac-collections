extension Collection {

  /// Yields the current element order, then its lexicographic successors one at a time.
  ///
  /// This mirrors the behavior of C++'s `next_permutation`:
  ///
  /// - The current order is always yielded first.
  /// - Only the lexicographic successors of that starting order are yielded afterward; this is
  ///   not a full enumeration of every permutation.
  /// - Elements that compare equal do not produce duplicate value orderings.
  /// - A descending order, all-equal elements, a single element, and an empty collection each
  ///   yield only the current order once.
  /// - Results already yielded by the iterator remain unchanged as iteration advances.
  ///
  /// Advancing by one step is worst-case O(n).
  ///
  /// If you need every permutation rather than only the lexicographic successors of the
  /// current order, use `swift-algorithms`'s `permutations()` instead.
  ///
  /// - Complexity: O(1). Creating an iterator copies the elements in O(n) time.
  @inlinable
  public func nextPermutations() -> NextPermutationsSequence<Self>
  where Element: Comparable {
    .init(self)
  }
}

/// A sequence of the current element order followed by its lexicographic successors.
///
/// Create this sequence by calling `nextPermutations()`. The source elements are
/// copied when an iterator is created, so iteration does not modify the source collection.
///
/// Each iterator advances independently, including iterators made by copying an existing
/// iterator. Previously yielded values also remain unchanged as iteration advances.
///
/// ```swift
/// let orders = [2, 1, 3].nextPermutations().map(Array.init)
/// // [[2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
/// ```
public struct NextPermutationsSequence<Base>: Sequence
where Base: Collection, Base.Element: Comparable {
  @usableFromInline
  let base: Base

  @inlinable
  internal init(_ base: Base) {
    self.base = base
  }

  /// Creates an iterator that starts at the source collection's current element order.
  ///
  /// - Complexity: O(n), where n is the number of elements.
  @inlinable
  public func makeIterator() -> Iterator {
    .init(elementBuffer: .prepare(source: base))
  }
}

extension NextPermutationsSequence {

  /// An iterator over the current element order and its lexicographic successors.
  ///
  /// Copies of an iterator advance independently. A yielded ``Permutation`` remains unchanged
  /// when this iterator advances.
  public
    struct Iterator: IteratorProtocol
  {
    @inlinable
    internal init(
      elementBuffer: Buffer
    ) {
      self.elementBuffer = elementBuffer
    }

    @usableFromInline
    enum State {
      /// The current order has not been yielded yet.
      case initial
      /// The next call advances to the lexicographic successor.
      case advancing
      /// The last order has been yielded.
      case finished
    }

    @usableFromInline
    var elementBuffer: Buffer
    @usableFromInline
    var state = State.initial

    // TODO: Swift 6.4の`swift test -c release`では、コピーしたiteratorの元の側をクロージャ内で
    // 進めて結果を読むと、コピー側も進んだ状態になる(2026-10-07発見)。2026-10-08の再調査では
    // このiteratorでだけ再現し、ライブラリなしの再現は作れなかった。原因(コンパイラか本実装か)は
    // 未確定。1.0直前に、まだ起きるかを確認する。
    /// Makes the buffer unique before advancing. Returns `false` without copying when the
    /// buffer is shared and has no successor, because such a copy would only be discarded.
    @inlinable
    mutating func ensureUnique() -> Bool {
      if !isKnownUniquelyReferenced(&elementBuffer) {
        guard elementBuffer.hasNextPermutation else { return false }
        elementBuffer = elementBuffer.copy()
      }
      return true
    }

    /// Returns the current order on the first call, then each lexicographic successor.
    ///
    /// Returns `nil` after the lexicographically last order has been returned. Further calls also
    /// return `nil`.
    ///
    /// - Complexity: O(n) in the worst case, where n is the number of elements.
    @inlinable
    public mutating func next() -> Permutation? {
      switch state {
      case .finished:
        return nil
      case .initial:
        state = .advancing
      case .advancing:
        guard ensureUnique(), elementBuffer.nextPermutation() else {
          state = .finished
          return nil
        }
      }
      return Permutation(elementBuffer: elementBuffer)
    }
  }
}

extension NextPermutationsSequence: Sendable where Base: Sendable {}

// `Iterator` is the only mutation gateway for its buffer. Before advancing, it
// detaches whenever another iterator or a yielded `Permutation` shares storage.
extension NextPermutationsSequence.Iterator: @unchecked Sendable where Base.Element: Sendable {}

/// The header of `NextPermutationsSequence.Buffer`. It does not depend on `Base`, so it is not
/// nested in the generic sequence type.
@usableFromInline
struct NextPermutationsBufferHeader {
  @inlinable
  internal init(count: Int) {
    self.count = count
  }
  @usableFromInline
  var count: Int
  #if DEBUG
    @usableFromInline
    var copyCount: UInt = 0
    @usableFromInline
    var probe = NextPermutationsHeaderProbe()
  #endif
}

#if DEBUG
  /// A reference owned by the header, so that how many times a header is destroyed is
  /// observable from tests. Not thread-safe: count only in single-threaded tests.
  @usableFromInline
  package final class NextPermutationsHeaderProbe {
    nonisolated(unsafe) package static var deinitCount = 0
    @inlinable
    init() {}
    deinit { Self.deinitCount += 1 }
  }
#endif

extension NextPermutationsSequence {

  @usableFromInline
  final class Buffer: ManagedBuffer<NextPermutationsBufferHeader, Base.Element> {

    // `header`は`ManagedBuffer`のstored propertyなので、Swiftが自動で破棄する。
    // ここでは要素だけを破棄する。
    @inlinable
    deinit {
      unsafe self.withUnsafeMutablePointers { header, elements in
        unsafe elements.deinitialize(count: header.pointee.count)
      }
    }
  }

  /// One element order yielded by ``NextPermutationsSequence``.
  ///
  /// A permutation is a zero-based random-access collection. Its indices are independent of the
  /// source collection's index type and starting index. The value remains unchanged once yielded,
  /// even as the iterator advances further.
  public
    struct Permutation
  {
    @inlinable
    internal init(
      elementBuffer: Buffer
    ) {
      self.elementBuffer = elementBuffer
    }
    @usableFromInline
    let elementBuffer: Buffer
  }

}

// A yielded permutation only reads its buffer. Any iterator that still shares
// that buffer detaches before its next mutation, so an existing value is stable.
extension NextPermutationsSequence.Permutation: @unchecked Sendable where Base.Element: Sendable {}

extension NextPermutationsSequence.Permutation: RandomAccessCollection {
  /// The position of the first element, always zero.
  ///
  /// - Complexity: O(1).
  @inlinable
  public var startIndex: Int { elementBuffer.startIndex }
  /// The position one past the last element.
  ///
  /// - Complexity: O(1).
  @inlinable
  public var endIndex: Int { elementBuffer.endIndex }
  /// The integer type used to index a permutation.
  public typealias Index = Int
  /// The type of element stored in a permutation.
  public typealias Element = Base.Element
  /// Accesses the element at `position`.
  ///
  /// - Precondition: `position` is in `startIndex..<endIndex`. An out-of-range position stops
  ///   execution in Debug and Release builds; `-Ounchecked` builds may omit this check.
  /// - Complexity: O(1).
  @inlinable
  public subscript(position: Int) -> Base.Element {
    precondition(position >= startIndex && position < endIndex, "Index out of range")
    return elementBuffer[position]
  }
  #if DEBUG
    package var _copyCount: UInt { elementBuffer.header.copyCount }
  #endif
}

// Equality, hashing, and description depend only on the element order.
extension NextPermutationsSequence.Permutation: Equatable {
  /// Returns whether two permutations contain equal elements in the same order.
  ///
  /// - Complexity: O(n) in the worst case, where n is the number of elements.
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.elementBuffer === rhs.elementBuffer || lhs.elementsEqual(rhs)
  }
}

extension NextPermutationsSequence.Permutation: Hashable where Base.Element: Hashable {
  /// Hashes the number and order of the permutation's elements.
  ///
  /// - Complexity: O(n), where n is the number of elements.
  @inlinable
  public func hash(into hasher: inout Hasher) {
    hasher.combine(count)
    for element in self {
      hasher.combine(element)
    }
  }
}

extension NextPermutationsSequence.Permutation: CustomStringConvertible {
  /// A representation of the elements using array syntax.
  ///
  /// - Complexity: O(n), where n is the number of elements, excluding the cost of each
  ///   element's description.
  public var description: String { Array(self).description }
}

extension NextPermutationsSequence.Buffer {

  @usableFromInline
  typealias Element = Base.Element

  @inlinable
  @unsafe var __storage_ptr: UnsafeMutablePointer<Element> {
    unsafe withUnsafeMutablePointerToElements({ unsafe $0 })
  }

  @usableFromInline
  typealias Index = Int

  @inlinable
  var isEmpty: Bool { header.count == 0 }
  @inlinable
  var startIndex: Index { 0 }
  @inlinable
  var endIndex: Index { header.count }

  @inlinable
  func formIndex(before i: inout Index) { i -= 1 }
  @inlinable
  func formIndex(after i: inout Index) { i += 1 }
  @inlinable
  func index(before i: Index) -> Index { i - 1 }
  @inlinable
  func swapAt(_ a: Index, _ b: Index) { swap(&self[a], &self[b]) }
  @inlinable
  func lastIndex(where predicate: (Element) -> Bool) -> Index? {
    (startIndex..<endIndex).last { predicate(self[$0]) }
  }
  @inlinable
  subscript(position: Index) -> Element {
    @inline(__always)
    get { unsafe __storage_ptr[position] }
    _modify {
      let storage = unsafe __storage_ptr
      yield unsafe &storage[position]
    }
  }
}

extension NextPermutationsSequence.Buffer {

  /// Creates a buffer whose header records `count` initialized elements. The caller must
  /// initialize exactly that many elements before the buffer is used.
  @inlinable
  internal static func create(count: Int) -> NextPermutationsSequence.Buffer {
    let storage = NextPermutationsSequence.Buffer.create(minimumCapacity: count) { _ in
      NextPermutationsBufferHeader(count: count)
    }
    return unsafe unsafeDowncast(storage, to: NextPermutationsSequence.Buffer.self)
  }

  @inlinable
  internal func copy() -> NextPermutationsSequence.Buffer {
    let count = header.count
    let newStorage = NextPermutationsSequence.Buffer.create(count: count)
    #if DEBUG
      newStorage.header.copyCount = header.copyCount &+ 1
    #endif
    unsafe self.withUnsafeMutablePointerToElements { oldElements in
      unsafe newStorage.withUnsafeMutablePointerToElements { newElements in
        unsafe newElements.initialize(from: oldElements, count: count)
      }
    }
    return newStorage
  }

  // `source.count`と実際の要素数が一致することは、`Collection`の契約として信じる。
  // 契約に違反するCollectionへの防御はしない(2026-10-07、ユーザー判断)。
  @inlinable
  static func prepare(source: Base) -> NextPermutationsSequence.Buffer {
    let newStorage = NextPermutationsSequence.Buffer.create(count: source.count)
    unsafe newStorage.withUnsafeMutablePointerToElements { newElements in
      source.enumerated().forEach { i, v in
        unsafe (newElements + i).initialize(to: v)
      }
    }
    return newStorage
  }
}

extension NextPermutationsSequence.Buffer where Element: Comparable {

  /// The last index `i` where `self[i] < self[i + 1]`, or `nil` when the current order has no
  /// lexicographic successor. Reads only.
  @inlinable
  internal var lastAscentIndex: Index? {
    guard !isEmpty else { return nil }
    var i = index(before: endIndex)
    while i != startIndex {
      let ip1 = i
      formIndex(before: &i)
      if self[i] < self[ip1] { return i }
    }
    return nil
  }

  /// Whether a lexicographic successor exists. Reads only.
  @inlinable
  internal var hasNextPermutation: Bool { lastAscentIndex != nil }

  // オリジナルはhttps://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Permutations.swift
  @inlinable
  internal func nextPermutation() -> Bool {
    guard let i = lastAscentIndex else {
      reverse(subrange: startIndex..<endIndex)
      return false
    }
    // `self[i + 1]`が`self[i]`より大きいので、必ず見つかる
    let j = lastIndex { self[i] < $0 }!
    swapAt(i, j)
    reverse(subrange: (i + 1)..<endIndex)
    return true
  }

  // オリジナルはhttps://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Rotate.swift
  @inlinable
  internal func reverse(subrange: Range<Index>) {
    var lower = subrange.lowerBound
    var upper = subrange.upperBound
    while lower < upper {
      formIndex(before: &upper)
      swapAt(lower, upper)
      formIndex(after: &lower)
    }
  }
}
