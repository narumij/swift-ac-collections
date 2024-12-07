@usableFromInline
protocol RedBlackTreeSetUtil: ValueComparer
where Element == _Key, Element: Equatable {
  func _read<R>(_ body: (_UnsafeHandle<Self>) throws -> R) rethrows -> R
}

extension RedBlackTreeSetUtil {
  public typealias Pointer = _NodePtr
}

extension RedBlackTreeSetUtil {
  
  @inlinable
  public func _contains(_ p: Element) -> Bool {
    _read {
      let it = $0.__lower_bound(p, $0.__root(), $0.__left_)
      guard it >= 0 else { return false }
      return $0.__value_ptr[it] == p
    }
  }

  @inlinable
  func _min() -> Element? {
    _read {
      let p = $0.__tree_min($0.__root())
      return p == .end ? nil : $0.__value_(p)
    }
  }
  
  @inlinable
  func _max() -> Element? {
    _read {
      let p = $0.__tree_max($0.__root())
      return p == .end ? nil : $0.__value_(p)
    }
  }
}

extension RedBlackTreeSetUtil {

  @inlinable
  public func lower_bound(_ p: Element) -> _NodePtr {
    _read { $0.__lower_bound(p, $0.__root(), .end) }
  }
  
  @inlinable
  public func upper_bound(_ p: Element) -> _NodePtr {
    _read { $0.__upper_bound(p, $0.__root(), .end) }
  }
}

extension RedBlackTreeSetUtil {
  
  @inlinable
  public func lt(_ p: Element) -> Element? {
    _read {
      var it = $0.__lower_bound(p, $0.__root(), .end)
      if it == $0.__begin_node { return nil }
      it = $0.__tree_prev_iter(it)
      return it != .end ? $0.__value_ptr[it] : nil
    }
  }
  @inlinable
  public func gt(_ p: Element) -> Element? {
    _read {
      let it = $0.__upper_bound(p, $0.__root(), .end)
      return it != .end ? $0.__value_ptr[it] : nil
    }
  }
  @inlinable
  public func le(_ p: Element) -> Element? {
    _read {
      var __parent = _NodePtr.nullptr
      _ = $0.__find_equal(&__parent, p)
      if __parent == .nullptr {
        return nil
      }
      if __parent == $0.__begin_node,
        $0.value_comp(p, $0.__value_(__parent))
      {
        return nil
      }
      if $0.value_comp(p, $0.__value_(__parent)) {
        __parent = $0.__tree_prev_iter(__parent)
      }
      return __parent != .end ? $0.__value_(__parent) : nil
    }
  }
  @inlinable
  public func ge(_ p: Element) -> Element? {
    _read {
      var __parent = _NodePtr.nullptr
      _ = $0.__find_equal(&__parent, p)
      if __parent != .nullptr, __parent != .end, $0.value_comp($0.__value_(__parent), p) {
        __parent = $0.__tree_next_iter(__parent)
      }
      return __parent != .end ? $0.__value_(__parent) : nil
    }
  }
}

