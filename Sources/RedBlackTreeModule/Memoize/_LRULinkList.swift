import Foundation

@usableFromInline
protocol _LRULinkList: ___RedBlackTreeBase
where Element == (key: _Key, prev: _NodePtr, next: _NodePtr, value: Value) {
  associatedtype Value
  var _tree: Tree { get }
  var _rankHighest: _NodePtr { get set }
  var _rankLowest: _NodePtr { get set }
  var _hits: Int { get set }
  var _miss: Int { get set }
  var maxCount: Int { get }
  var count: Int { get }
}

extension _LRULinkList {
  
  @inlinable @inline(__always)
  public static func __key(_ element: Element) -> _Key {
    element.key
  }
  
  @inlinable
  mutating func ___prepend(_ __p: _NodePtr) {
    if _rankHighest == .nullptr {
      _tree[__p].next = .nullptr
      _tree[__p].prev = .nullptr
      _rankLowest = __p
      _rankHighest = __p
    } else {
      _tree[_rankHighest].prev = __p
      _tree[__p].next = _rankHighest
      _tree[__p].prev = .nullptr
      _rankHighest = __p
    }
  }

  @inlinable
  mutating func ___pop(_ __p: _NodePtr) -> _NodePtr {

    assert(
      __p == _rankHighest || _tree[__p].next != .nullptr || _tree[__p].prev != .nullptr,
      "did not contain \(__p) ptr.")

    defer {
      let prev = _tree[__p].prev
      let next = _tree[__p].next
      if prev != .nullptr {
        _tree[prev].next = next
      } else {
        _rankHighest = next
      }
      if next != .nullptr {
        _tree[next].prev = prev
      } else {
        _rankLowest = prev
      }
    }

    return __p
  }

  @inlinable
  mutating func ___popRankLowest() -> _NodePtr {

    defer {
      if _rankLowest != .nullptr {
        _rankLowest = _tree[_rankLowest].prev
      }
      if _rankLowest != .nullptr {
        _tree[_rankLowest].next = .nullptr
      } else {
        _rankHighest = .nullptr
      }
    }

    return _rankLowest
  }
  
  @inlinable
  var ___info: (hits: Int, miss: Int, maxCount: Int?, currentCount: Int) {
    (_hits, _miss, maxCount != Int.max ? maxCount : nil, count)
  }

  @inlinable
  mutating func ___clear(keepingCapacity keepCapacity: Bool) {
    (_hits, _miss) = (0, 0)
    ___removeAll(keepingCapacity: keepCapacity)
  }
}
