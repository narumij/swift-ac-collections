import Collections
import Foundation

@frozen
public struct RedBlackTreeSet<Element: Comparable> {

  public
    typealias Element = Element

  @usableFromInline
  typealias _Key = Element

  @usableFromInline
  var header: RedBlackTree.___Header
  
  @usableFromInline
  var nodes: [RedBlackTree.___Node]
  
  @usableFromInline
  var values: [Element]
  
  @usableFromInline
  var stock: Heap<_NodePtr> = []
}

extension RedBlackTreeSet {

  @inlinable @inline(__always)
  public init() {
    header = .zero
    nodes = []
    values = []
  }

  @inlinable @inline(__always)
  public init(minimumCapacity: Int) {
    header = .zero
    nodes = []
    values = []
    nodes.reserveCapacity(minimumCapacity)
    values.reserveCapacity(minimumCapacity)
  }

  @inlinable @inline(__always)
  public init<S>(_ _a: S) where S: Collection, S.Element == Element {
    var _values: [Element] = _a + []
    var _header: RedBlackTree.___Header = .zero
    self.nodes = [RedBlackTree.___Node](
      unsafeUninitializedCapacity: _values.count
    ) { _nodes, initializedCount in
      withUnsafeMutablePointer(to: &_header) { _header in
        _values.withUnsafeMutableBufferPointer { _values in
          var count = 0
          func ___construct_node(_ __k: Element) -> _NodePtr {
            _nodes[count] = .zero
            _values[count] = __k
            defer { count += 1 }
            return count
          }
          let tree = _UnsafeMutatingHandle<Self>(
            __header_ptr: _header,
            __node_ptr: _nodes.baseAddress!,
            __value_ptr: _values.baseAddress!)
          var i = 0
          while i < _a.count {
            let __k = _values[i]
            i += 1
            var __parent = _NodePtr.nullptr
            let __child = tree.__find_equal(&__parent, __k)
            if tree.__ref_(__child) == .nullptr {
              let __h = ___construct_node(__k)
              tree.__insert_node_at(__parent, __child, __h)
            }
          }
          initializedCount = count
        }
      }
    }
    self.header = _header
    self.values = _values
    self.stock = []
  }
}

extension RedBlackTreeSet {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    nodes.reserveCapacity(minimumCapacity)
    values.reserveCapacity(minimumCapacity)
  }
}

extension RedBlackTreeSet {

  @inlinable
  public var count: Int {
    ___count
  }

  @inlinable
  public var isEmpty: Bool {
    ___isEmpty
  }
}

extension RedBlackTreeSet {

  @inlinable
  public func begin() -> _NodePtr {
    ___begin()
  }

  @inlinable
  public func end() -> _NodePtr {
    ___end()
  }
}

extension RedBlackTreeSet: ValueComparer {

  @inlinable @inline(__always)
  static func __key(_ e: Element) -> Element { e }

  @inlinable
  static func value_comp(_ a: Element, _ b: Element) -> Bool {
    a < b
  }
}

extension RedBlackTreeSet: RedBlackTreeSetContainer {}
extension RedBlackTreeSet: _UnsafeHandleBase {}

extension RedBlackTreeSet: _UnsafeMutatingHandleBase {

  // プロトコルでupdateが書けなかったため、個別で実装している
  @inlinable
  @inline(__always)
  mutating func _update<R>(_ body: (_UnsafeMutatingHandle<Self>) throws -> R) rethrows -> R {
    return try withUnsafeMutablePointer(to: &header) { header in
      try nodes.withUnsafeMutableBufferPointer { nodes in
        try values.withUnsafeMutableBufferPointer { values in
          try body(
            _UnsafeMutatingHandle<Self>(
              __header_ptr: header,
              __node_ptr: nodes.baseAddress!,
              __value_ptr: values.baseAddress!))
        }
      }
    }
  }
}

extension RedBlackTreeSet: InsertUniqueProtocol {}

extension RedBlackTreeSet: RedBlackTreeEraseProtocol {}

extension RedBlackTreeSet: RedBlackTree.SetInternal {}

extension RedBlackTreeSet {

  @inlinable
  @discardableResult
  public mutating func insert(_ p: Element) -> Bool {
    __insert_unique(p).__inserted
  }

  @inlinable
  @discardableResult
  public mutating func remove(_ p: Element) -> Bool {
    __erase_unique(p)
  }
}

// Sequenceプロトコルとの衝突があるため、直接の実装が必要
extension RedBlackTreeSet {

  @inlinable public func contains(_ p: Element) -> Bool { ___contains(p) }
  @inlinable public func min() -> Element? { ___min() }
  @inlinable public func max() -> Element? { ___max() }
}

extension RedBlackTreeSet: Sequence, RedBlackTree.Iteratee {

  @inlinable
  public func makeIterator() -> RedBlackTree.Iterator<Self> {
    .init(container: self, ptr: header.__begin_node)
  }
}

extension RedBlackTreeSet: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}

extension RedBlackTreeSet {

  @inlinable
  public func lower_bound(_ p: Element) -> _NodePtr {
    ___lower_bound(p)
  }

  @inlinable
  public func upper_bound(_ p: Element) -> _NodePtr {
    ___upper_bound(p)
  }
}

extension RedBlackTreeSet {

  @inlinable
  public func lessThan(_ p: Element) -> Element? {
    ___lt(p)
  }
  @inlinable
  public func greatorThan(_ p: Element) -> Element? {
    ___gt(p)
  }
  @inlinable
  public func lessEqual(_ p: Element) -> Element? {
    ___le(p)
  }
  @inlinable
  public func greatorEqual(_ p: Element) -> Element? {
    ___ge(p)
  }
}
