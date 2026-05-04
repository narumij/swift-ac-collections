//
//  RedBlackTreeDictionary+Subscript.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

extension RedBlackTreeDictionary {

  /// - Complexity: O(log *n*)
  @inlinable
  public subscript(key: Key) -> Value? {

    @inline(__always) get {
      __tree_.lookup(key)
    }

    set(newValue) {
      if let x = newValue {
        __tree_.setValue(x, forKey: key)
      } else {
        _ = __tree_.___erase_unique(key)
      }
    }

    _modify {
      defer { _fixLifetime(__tree_) }
      yield &__tree_[key]
    }
  }

  /// - Complexity: O(log *n*)
  @inlinable
  public subscript(
    key: Key, default defaultValue: @autoclosure () -> Value
  ) -> Value {
    @inline(__always) get {
      __tree_.lookup(key) ?? defaultValue()
    }
    @inline(__always) _modify {
      defer { _fixLifetime(__tree_) }
      __tree_.ensureUnique()
      let (__parent, __child) = __tree_.__find_equal(key)
      if __child.pointee.___is_null {
        __tree_.ensureCapacity()
        assert(__tree_.capacity > __tree_.count)
        __tree_.update {
          let __h = $0.__construct_node(Base.__payload_((key, defaultValue())))
          $0.__insert_node_at(__parent, __child, __h)
        }
      }
      yield &__tree_[_unsafe_raw: __child.pointee].value
    }
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {

    /// - Complexity: O(1)
    @inlinable
    public subscript(position: Index) -> Element {
      @inline(__always) get {
        Base.__element_(__tree_[_unsafe: __tree_.__purified_(position)])
      }
    }
  }
#endif
