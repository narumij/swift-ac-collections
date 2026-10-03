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
  public func nextPermutations() -> Permutations<Self>.Nexts
  where Element: Comparable {
    .init(self)
  }
}

public
  enum Permutations<C> where C: Collection, C.Index == Int
{}

extension Permutations: Sendable {}

extension Permutations {

  /// The sequence returned by `nextPermutations()`.
  public struct Nexts: Sequence where C.Element: Comparable {
    @usableFromInline
    let source: C

    @inlinable
    @inline(__always)
    internal init(_ source: C) {
      self.source = source
    }

    @inlinable
    @inline(__always)
    public func makeIterator() -> IteratorN {
      .init(elementBuffer: .prepare(source: source))
    }
  }

  /// The iterator for `Nexts`.
  public
    struct IteratorN: IteratorProtocol where C.Element: Comparable
  {
    @inlinable
    @inline(__always)
    internal init(
      elementBuffer: Buffer<C.Element>
    ) {
      self.elementBuffer = elementBuffer
    }

    @usableFromInline
    var elementBuffer: Buffer<C.Element>
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
    public mutating func next() -> SubSequenceN? {
      guard !end else { return nil }
      if start {
        start = false
      } else {
        ensureUnique()
        end = !elementBuffer.nextPermutation()
      }
      return end ? nil : SubSequenceN(elementBuffer: elementBuffer)
    }
  }
}

extension Permutations.Nexts: Sendable where C: Sendable {}

extension Permutations {

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
  class Buffer<Element>: ManagedBuffer<Header, Element> {

    public typealias Element = Element

    @inlinable
    deinit {
      unsafe self.withUnsafeMutablePointers { header, elements in
        unsafe elements.deinitialize(count: header.pointee.count)
        unsafe header.deinitialize(count: 1)
      }
    }
  }

  /// One element order yielded by `Nexts`. Remains unchanged once yielded, even as the
  /// iterator advances further.
  public
    struct SubSequenceN
  {
    @inlinable
    @inline(__always)
    internal init(
      elementBuffer: Buffer<C.Element>
    ) {
      self.elementBuffer = elementBuffer
    }
    @usableFromInline
    let elementBuffer: Buffer<C.Element>
  }

}

extension Permutations.SubSequenceN: RandomAccessCollection {
  @inlinable
  @inline(__always)
  public var startIndex: Int { elementBuffer.startIndex }
  @inlinable
  @inline(__always)
  public var endIndex: Int { elementBuffer.endIndex }
  public typealias Index = Int
  public typealias Element = C.Element
  @inlinable
  @inline(__always)
  public subscript(position: Int) -> C.Element {
    precondition(position >= startIndex && position < endIndex, "Index out of range")
    return elementBuffer[position]
  }
  #if AC_COLLECTIONS_INTERNAL_CHECKS
    public var _copyCount: UInt { elementBuffer.header.copyCount }
  #endif
}

extension Permutations.Buffer: NextPermutationProtocol where Element: Comparable {}

extension Permutations.Buffer {

  @inlinable
  @inline(__always)
  var __header_ptr: UnsafeMutablePointer<Permutations.Header> {
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
    (startIndex..<endIndex).last { predicate(self[$0]) }
  }
  @inlinable
  subscript(position: Index) -> Element {
    @inline(__always)
    get { __storage_ptr[position] }
    @inline(__always)
    _modify { yield &__storage_ptr[position] }
  }
}

extension Permutations.Buffer {

  @inlinable
  @inline(__always)
  internal static func create(
    withCapacity capacity: Int
  ) -> Self {
    let storage = Permutations.Buffer<Element>.create(minimumCapacity: capacity) { _ in
      Permutations.Header(capacity: capacity, count: 0)
    }
    return unsafeDowncast(storage, to: Self.self)
  }

  @inlinable
  @inline(__always)
  internal func copy(newCapacity: Int? = nil) -> Permutations.Buffer<Element> {

    let capacity = newCapacity ?? self.header.capacity
    let count = self.header.count
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      let copyCount = self.header.copyCount
    #endif

    let newStorage = Permutations.Buffer<Element>.create(withCapacity: capacity)

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

extension Permutations.Buffer {

  @inlinable
  @inline(__always)
  static func prepare<CC>(source: CC) -> Permutations.Buffer<Element>
  where CC: Collection, CC.Element == Element {

    let capacity = source.count
    let count = source.count

    let newStorage = Permutations.Buffer<Element>.create(withCapacity: capacity)
    newStorage.header.capacity = capacity
    newStorage.header.count = count
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      newStorage.header.copyCount = 0
    #endif

    newStorage.withUnsafeMutablePointerToElements { newElements in
      source.enumerated().forEach { i, v in
        (newElements + i).initialize(to: v)
      }
    }
    return newStorage
  }
}
