//
//  RedBlackTreeMultidictionary.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/24.
//

@testable import RedBlackTreeModule

struct RedBlackTreeMultiDictionary<Key: Comparable, Value> {
  
  public
    typealias Index = Tree.Pointer

  public
    typealias KeyValue = (key: Key, value: Value)

  public
    typealias Element = KeyValue

  public
    typealias Keys = [Key]

  public
    typealias Values = [Value]

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

extension RedBlackTreeMultiDictionary {
  public typealias RawIndex = Tree.RawPointer
}

extension RedBlackTreeMultiDictionary: ___RedBlackTreeBase {}
extension RedBlackTreeMultiDictionary: ___RedBlackTreeStorageLifetime {}
extension RedBlackTreeMultiDictionary: ___RedBlackTreeEqualRangeMulti {}
extension RedBlackTreeMultiDictionary: KeyValueComparer {}

extension RedBlackTreeMultiDictionary {

  @inlinable @inline(__always)
  public init() {
    self.init(minimumCapacity: 0)
  }

  @inlinable @inline(__always)
  public init(minimumCapacity: Int) {
    _storage = .create(withCapacity: minimumCapacity)
  }
}

extension RedBlackTreeMultiDictionary {
  
  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func insert(key: _Key, value: Value) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    _ensureUniqueAndCapacity()
    _ = _tree.__insert_multi((key, value))
    return (true, (key, value))
  }
}

extension RedBlackTreeMultiDictionary {

  @inlinable
  public func count(forKey key: Key) -> Int {
    _tree.__count_multi(key)
  }
}

extension RedBlackTreeMultiDictionary {

  @inlinable
  public func values(forKey key: Key) -> [Value] {
    var (lo,hi) = _tree.__equal_range_multi(key)
    var result = [Value]()
    while lo != hi {
      result.append(_tree.___element(lo).value)
      lo = _tree.__tree_next(lo)
    }
    return result
  }
  
  @inlinable
  public func value(at ptr: Index) -> Value? {
    return _tree[ptr.rawValue].value
  }
}

extension RedBlackTreeMultiDictionary {
  
  @inlinable
  @inline(__always)
  public var startIndex: Index {
    ___index_start()
  }
  
  @inlinable
  @inline(__always)
  public var endIndex: Index {
    ___index_end()
  }
  
  @inlinable
  @inline(__always)
  public var count: Int {
    ___count
  }
  
  @inlinable
  @inline(__always)
  public func distance(from start: Index, to end: Index) -> Int {
    ___distance(from: start.rawValue, to: end.rawValue)
  }
  
  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    ___index(after: i.rawValue)
  }
  
  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    ___form_index(after: &i.rawValue)
  }
  
  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    ___index(before: i.rawValue)
  }
  
  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    ___form_index(before: &i.rawValue)
  }
  
  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    ___index(i.rawValue, offsetBy: distance)
  }
  
  @inlinable
  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy distance: Int) {
    ___form_index(&i.rawValue, offsetBy: distance)
  }
  
  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    ___index(i.rawValue, offsetBy: distance, limitedBy: limit.rawValue)
  }
  
  @inlinable
  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
  -> Bool
  {
    ___form_index(&i.rawValue, offsetBy: distance, limitedBy: limit.rawValue)
  }
  
  @inlinable
  @inline(__always)
  public subscript(position: Index) -> Element {
    return _tree[position.rawValue]
  }
  
  @inlinable
  @inline(__always)
  public subscript(position: RawIndex) -> Element {
    return _tree[position.rawValue]
  }
}
