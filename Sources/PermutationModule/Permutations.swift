extension Collection where Index == Int {

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
  @inlinable
  @inline(__always)
  public func nextPermutations() -> NextPermutationsSequence<Self>
  where Element: Comparable {
    .init(self)
  }
}

/// The sequence returned by `nextPermutations()`.
public struct NextPermutationsSequence<Base>: Sequence
where Base: Collection, Base.Index == Int, Base.Element: Comparable {
  @usableFromInline
  let base: Base

  @inlinable
  @inline(__always)
  internal init(_ base: Base) {
    self.base = base
  }

  @inlinable
  @inline(__always)
  public func makeIterator() -> Iterator {
    .init(elementBuffer: .prepare(source: base))
  }
}

extension NextPermutationsSequence {

  /// The iterator for `NextPermutationsSequence`.
  public
    struct Iterator: IteratorProtocol
  {
    @inlinable
    @inline(__always)
    internal init(
      elementBuffer: Buffer<Base.Element>
    ) {
      self.elementBuffer = elementBuffer
    }

    @usableFromInline
    var elementBuffer: Buffer<Base.Element>
    @usableFromInline
    var start = true
    @usableFromInline
    var end = false

    @inlinable
    @inline(__always)
    mutating func ensureUnique() {
      if !isKnownUniquelyReferenced(&elementBuffer) {
        elementBuffer = elementBuffer.copy()
      }
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> Permutation? {
      guard !end else { return nil }
      if start {
        start = false
      } else {
        ensureUnique()
        end = !elementBuffer.nextPermutation()
      }
      return end ? nil : Permutation(elementBuffer: elementBuffer)
    }
  }
}

extension NextPermutationsSequence: Sendable where Base: Sendable {}

// `Iterator` is the only mutation gateway for its buffer. Before advancing, it
// detaches whenever another iterator or a yielded `Permutation` shares storage.
extension NextPermutationsSequence.Iterator: @unchecked Sendable where Base.Element: Sendable {}

extension NextPermutationsSequence {

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
  final class Buffer<Element>: ManagedBuffer<Header, Element> {

    public typealias Element = Element

    @inlinable
    deinit {
      unsafe self.withUnsafeMutablePointers { header, elements in
        unsafe elements.deinitialize(count: header.pointee.count)
        unsafe header.deinitialize(count: 1)
      }
    }
  }

  /// One element order yielded by `NextPermutationsSequence`. Remains unchanged once
  /// yielded, even as the iterator advances further.
  public
    struct Permutation
  {
    @inlinable
    @inline(__always)
    internal init(
      elementBuffer: Buffer<Base.Element>
    ) {
      self.elementBuffer = elementBuffer
    }
    @usableFromInline
    let elementBuffer: Buffer<Base.Element>
  }

}

// A yielded subsequence only reads its buffer. Any iterator that still shares
// that buffer detaches before its next mutation, so an existing value is stable.
extension NextPermutationsSequence.Permutation: @unchecked Sendable where Base.Element: Sendable {}

extension NextPermutationsSequence.Permutation: RandomAccessCollection {
  @inlinable
  @inline(__always)
  public var startIndex: Int { elementBuffer.startIndex }
  @inlinable
  @inline(__always)
  public var endIndex: Int { elementBuffer.endIndex }
  public typealias Index = Int
  public typealias Element = Base.Element
  @inlinable
  @inline(__always)
  public subscript(position: Int) -> Base.Element {
    precondition(position >= startIndex && position < endIndex, "Index out of range")
    return elementBuffer[position]
  }
  #if AC_COLLECTIONS_INTERNAL_CHECKS
    public var _copyCount: UInt { elementBuffer.header.copyCount }
  #endif
}

extension NextPermutationsSequence.Buffer: NextPermutationProtocol where Element: Comparable {}

extension NextPermutationsSequence.Buffer {

  @inlinable
  @inline(__always)
  @unsafe var __storage_ptr: UnsafeMutablePointer<Element> {
    unsafe withUnsafeMutablePointerToElements({ unsafe $0 })
  }

  @usableFromInline
  typealias Index = Int

  @inlinable
  @inline(__always)
  var isEmpty: Bool { header.count == 0 }
  @inlinable
  @inline(__always)
  var startIndex: Index { 0 }
  @inlinable
  @inline(__always)
  var endIndex: Index { header.count }

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
    (startIndex..<endIndex).last { predicate(self[$0]) }
  }
  @inlinable
  subscript(position: Index) -> Element {
    @inline(__always)
    get { unsafe __storage_ptr[position] }
    @inline(__always)
    _modify {
      let storage = unsafe __storage_ptr
      yield unsafe &storage[position]
    }
  }
}

extension NextPermutationsSequence.Buffer {

  @inlinable
  @inline(__always)
  internal static func create(
    withCapacity capacity: Int
  ) -> Self {
    let storage = NextPermutationsSequence.Buffer<Element>.create(minimumCapacity: capacity) { _ in
      NextPermutationsSequence.Header(capacity: capacity, count: 0)
    }
    return unsafe unsafeDowncast(storage, to: Self.self)
  }

  @inlinable
  @inline(__always)
  internal func copy(newCapacity: Int? = nil) -> NextPermutationsSequence.Buffer<Element> {

    let capacity = newCapacity ?? self.header.capacity
    let count = self.header.count
    precondition(capacity >= count, "Capacity must accommodate initialized elements")
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      let copyCount = self.header.copyCount
    #endif

    let newStorage = NextPermutationsSequence.Buffer<Element>.create(withCapacity: capacity)

    newStorage.header.capacity = capacity
    newStorage.header.count = count
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      newStorage.header.copyCount = copyCount &+ 1
    #endif

    unsafe self.withUnsafeMutablePointerToElements { oldElements in
      unsafe newStorage.withUnsafeMutablePointerToElements { newElements in
        unsafe newElements.initialize(from: oldElements, count: count)
      }
    }

    return newStorage
  }
}

extension NextPermutationsSequence.Buffer {

  @inlinable
  @inline(__always)
  static func prepare<CC>(source: CC) -> NextPermutationsSequence.Buffer<Element>
  where CC: Collection, CC.Element == Element {

    let capacity = source.count
    let count = source.count

    let newStorage = NextPermutationsSequence.Buffer<Element>.create(withCapacity: capacity)
    newStorage.header.capacity = capacity
    newStorage.header.count = count
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      newStorage.header.copyCount = 0
    #endif

    unsafe newStorage.withUnsafeMutablePointerToElements { newElements in
      source.enumerated().forEach { i, v in
        unsafe (newElements + i).initialize(to: v)
      }
    }
    return newStorage
  }
}
