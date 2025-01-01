import Foundation

extension Collection where Index == Int {

  /// 全通りをしっかりpermutationsするが、CoWをさっぱりしないもの
  @inlinable
  @inline(__always)
  public __consuming func unsafePermutations() -> Permutations<Self>.All {
    .init(unsafe: self)
  }

  /// 単に辞書順の操作をするだけのもの
  ///
  /// C++のnext_permutationの挙動が欲しい場合はこちら。
  @inlinable
  @inline(__always)
  public __consuming func nextPermutations() -> Permutations<Self>.Resume
  where Element: Comparable {
    .init(unsafe: self)
  }
}

public
  enum Permutations<C> where C: Collection, C.Index == Int
{}

extension Permutations {

  public struct All: Sequence {
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

    @inlinable
    @inline(__always)
    public __consuming func makeIterator() -> IteratorA {
      .init(
        elementBuffer: .prepare(source: source),
        buffer: .prepare(count: source.count),
        _unsafe: _unsafe)
    }
  }

  public struct Resume: Sequence where C.Element: Comparable {
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

    @inlinable
    @inline(__always)
    public __consuming func makeIterator() -> IteratorR {
      .init(
        elementBuffer: .prepare(source: source),
        _unsafe: _unsafe)
    }
  }

  public
    struct IteratorA: IteratorProtocol
  {
    @inlinable
    @inline(__always)
    internal init(
      elementBuffer: Buffer<C.Element>,
      buffer: Buffer<Int>,
      _unsafe: Bool
    ) {
      self.elementBuffer = elementBuffer
      self.indexBuffer = buffer
      self._unsafe = _unsafe
    }

    @usableFromInline
    let elementBuffer: Buffer<C.Element>
    @usableFromInline
    var indexBuffer: Buffer<Int>
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
    public mutating func next() -> SubSequenceA? {
      guard !end else { return nil }
      if start {
        start = false
      } else {
        if !_unsafe {
          ensureUnique()
        }
        end = !indexBuffer.nextPermutation()
      }
      return end ? nil : SubSequenceA(elementBuffer: elementBuffer, buffer: indexBuffer)
    }
  }

  public
    struct IteratorR: IteratorProtocol where C.Element: Comparable
  {
    @inlinable
    @inline(__always)
    internal init(
      elementBuffer: Buffer<C.Element>,
      _unsafe: Bool
    ) {
      self.elementBuffer = elementBuffer
      self._unsafe = _unsafe
    }

    @usableFromInline
    var elementBuffer: Buffer<C.Element>
    @usableFromInline
    var start = true
    @usableFromInline
    var end = false
    @usableFromInline
    var _unsafe: Bool

    @inlinable
    @inline(__always)
    mutating func ensureUnique() {
      if !isKnownUniquelyReferenced(&elementBuffer) {
        elementBuffer = elementBuffer.copy()
      }
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> SubSequenceR? {
      guard !end else { return nil }
      if start {
        start = false
      } else {
        if !_unsafe {
          ensureUnique()
        }
        end = !elementBuffer.nextPermutation()
      }
      return end ? nil : SubSequenceR(elementBuffer: elementBuffer)
    }
  }
}

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
      self.withUnsafeMutablePointers { header, elements in
        elements.deinitialize(count: header.pointee.count)
        header.deinitialize(count: 1)
      }
    }
  }

  public
    struct SubSequenceA
  {
    @inlinable
    @inline(__always)
    internal init(
      elementBuffer: Buffer<C.Element>,
      buffer: Buffer<Int>
    ) {
      self.elementBuffer = elementBuffer
      self.indexBuffer = buffer
    }
    @usableFromInline
    let elementBuffer: Buffer<C.Element>
    @usableFromInline
    var indexBuffer: Buffer<Int>
  }

  public
    struct SubSequenceR
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

extension Permutations.SubSequenceA: RandomAccessCollection {
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

extension Permutations.SubSequenceR: RandomAccessCollection {
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
    elementBuffer[position]
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
  static func prepare(count: Int) -> Permutations.Buffer<Element>
  where Element == Int {

    let capacity = count
    let count = count

    let newStorage = Permutations.Buffer<Element>.create(withCapacity: capacity)
    newStorage.header.capacity = capacity
    newStorage.header.count = count
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      newStorage.header.copyCount = 0
    #endif
    newStorage.withUnsafeMutablePointerToElements { newElements in
      for i in 0..<count {
        (newElements + Int(i)).initialize(to: i)
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
