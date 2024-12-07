import Foundation
import Collections

// AC https://atcoder.jp/contests/abc358/submissions/59018223

@frozen
public struct RedBlackTreeMultiset<Element: Comparable> {

  public
  typealias Element = Element

  @usableFromInline
  typealias _Key = Element

  @inlinable @inline(__always)
  public init() {
    header = .zero
    nodes = []
    values = []
    stock = []
  }

  @inlinable
  public init(minimumCapacity: Int) {
    header = .zero
    nodes = []
    values = []
    stock = []
    nodes.reserveCapacity(minimumCapacity)
    values.reserveCapacity(minimumCapacity)
  }

  @usableFromInline
  var header: RedBlackTree.Header
  @usableFromInline
  var nodes: [RedBlackTree.Node]
  @usableFromInline
  var values: [Element]
  @usableFromInline
  var stock: Heap<_NodePtr>

  #if false
    @usableFromInline
    var stock: [_NodePtr] = []
  #endif

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    nodes.reserveCapacity(minimumCapacity)
    values.reserveCapacity(minimumCapacity)
  }
}

extension RedBlackTreeMultiset: ValueComparer {

  @inlinable @inline(__always)
  static func __key(_ e: Element) -> Element { e }

  @inlinable
  static func value_comp(_ a: Element, _ b: Element) -> Bool {
    a < b
  }
}

extension RedBlackTreeMultiset: RedBlackTreeSetContainer {}
extension RedBlackTreeMultiset: _UnsafeHandleBase {}

extension RedBlackTreeMultiset: _UnsafeMutatingHandleBase {

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

extension RedBlackTreeMultiset: InsertMultiProtocol {}
extension RedBlackTreeMultiset: EraseProtocol2 {}

extension RedBlackTreeMultiset {
  @inlinable @inline(__always)
  public init<S>(_ _a: S) where S: Collection, S.Element == Element {
    self.nodes = []
    self.header = .zero
    self.values = []
    self.stock = []
    for a in _a {
      _ = insert(a)
    }
  }
}

extension RedBlackTreeMultiset: RedBlackTreeSetUtil {}
extension RedBlackTreeMultiset: RedBlackTreeRemoveProtocol {}

extension RedBlackTreeMultiset {
  @inlinable
  @discardableResult
  public mutating func insert(_ p: Element) -> Bool {
    _ = __insert_multi(p)
    return true
  }

  @inlinable
  @discardableResult
  public mutating func remove(_ p: Element) -> Bool {
    return __erase_multi(p) != 0
  }
}

// Sequenceプロトコルとの衝突があるため、直接の実装が必要
extension RedBlackTreeMultiset {

  @inlinable public func contains(_ p: Element) -> Bool { _contains(p) }
  @inlinable public func min() -> Element? { _min() }
  @inlinable public func max() -> Element? { _max() }
}

extension RedBlackTreeMultiset: Sequence, RedBlackTree.Iteratee {

  @inlinable
  public func makeIterator() -> RedBlackTree.Iterator<Self> {
    .init(container: self, ptr: header.__begin_node)
  }
}

extension RedBlackTreeMultiset: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}
