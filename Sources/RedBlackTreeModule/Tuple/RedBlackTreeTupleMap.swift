//
//  Untitled.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/06/16.
//

@frozen
public struct RedBlackTreeTupleMap<each A: Comparable, Value> {

  public
    typealias Key = (repeat each A)

  /// - Important:
  ///  要素及びノードが削除された場合、インデックスは無効になります。
  /// 無効なインデックスを使用するとランタイムエラーや不正な参照が発生する可能性があるため注意してください。
  public
    typealias Index = Tree.Index

  public
    typealias KeyValue = (key: Key, value: Value)

  public
    typealias Element = KeyValue

  public
    typealias Keys = KeyIterator<Tree, Key, Value>

  public
    typealias Values = ValueIterator<Tree, Key, Value>

  public
    typealias _Key = Key

  public
    typealias _Value = Value

  @usableFromInline
  var _storage: Tree.Storage

  @inlinable @inline(__always)
  init(_storage: Tree.Storage) {
    self._storage = _storage
  }
}

extension RedBlackTreeTupleMap: ___RedBlackTreeBase {
  public static func __key(_ v: Element) -> _Key {
    v.key
  }
  public static func value_comp(_ lhs: _Key, _ rhs: _Key) -> Bool {
    for (l, r) in repeat (each lhs, each rhs) {
      if l != r {
        return l < r
      }
    }
    return false
  }
}
extension RedBlackTreeTupleMap: ___RedBlackTreeCopyOnWrite {}
extension RedBlackTreeTupleMap: ___RedBlackTreeUnique {}
extension RedBlackTreeTupleMap: KeyValueComparer {}

// MARK: - Creating a Dictionay

extension RedBlackTreeTupleMap {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public init() {
    self.init(minimumCapacity: 0)
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public init(minimumCapacity: Int) {
    _storage = .create(withCapacity: minimumCapacity)
  }
}

#if true
// Compiler Crash
extension RedBlackTreeTupleMap {

  /// - Complexity: O(log *n*)
  @inlinable
  public subscript(key: Key) -> Value? {
    get {
      fatalError()
    }
    set {
      fatalError()
    }
  }
}
#else
// Compiler No Crash
extension RedBlackTreeTupleMap {

  /// - Complexity: O(log *n*)
  @inlinable
  public subscript(key: Key) -> Value? {
    get {
      fatalError()
    }
  }
}
#endif
