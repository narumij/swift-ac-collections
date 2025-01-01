import Foundation

public
  struct PermutationSequence<Element: Comparable>
{

  var source: [Element]
  public init<S>(_ s: S) where S: Sequence, S.Element == Element {
    source = s.sorted()
  }
}

extension PermutationSequence: Sequence {

  public func makeIterator() -> Iterator {
    .init(buffer: .prepare(source))
  }

  public
    struct Iterator: IteratorProtocol
  {
    var buffer: Buffer
    var start = true
    var end = false
    public mutating func next() -> SubSequence? {
      guard !end else { return nil }
      if start {
        start = false
      } else {
        end = !buffer.nextPermutation()
      }
      return end ? nil : SubSequence(buffer: buffer)
    }
  }
}

extension PermutationSequence {

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
    @usableFromInline
    var buffer: PermutationSequence.Buffer
  }
}

extension PermutationSequence.SubSequence: RandomAccessCollection {
  public var startIndex: Int { buffer.startIndex }
  public var endIndex: Int { buffer.endIndex }
  public typealias Index = Int
  public typealias Element = Element
  public subscript(position: Int) -> Element { buffer[position] }
}

extension PermutationSequence.Buffer {

  @inlinable
  internal static func create(
    withCapacity capacity: Int
  ) -> Self {
    let storage = PermutationSequence.Buffer.create(minimumCapacity: capacity) { _ in
      PermutationSequence.Header(capacity: capacity, count: 0)
    }
    return unsafeDowncast(storage, to: Self.self)
  }

  @inlinable
  internal func copy(newCapacity: Int? = nil) -> PermutationSequence.Buffer {

    let capacity = newCapacity ?? self.header.capacity
    let count = self.header.count
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      let copyCount = self.header.copyCount
    #endif

    let newStorage = PermutationSequence.Buffer.create(withCapacity: capacity)

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

extension PermutationSequence.Buffer {

  @inlinable
  static func prepare(_ source: [Element]) -> PermutationSequence.Buffer {

    let capacity = source.count
    let count = source.count

    let newStorage = PermutationSequence.Buffer.create(withCapacity: capacity)
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

extension PermutationSequence.Buffer {

  @inlinable
  var __storage_ptr: UnsafeMutablePointer<Element> {
    withUnsafeMutablePointerToElements({ $0 })
  }

  @usableFromInline
  typealias Index = Int

  @usableFromInline
  var isEmpty: Bool { header.count == 0 }
  @usableFromInline
  var startIndex: Index { 0 }
  @usableFromInline
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
    (startIndex..<endIndex).last(where: { predicate(self[$0]) })
  }
  @inlinable
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
