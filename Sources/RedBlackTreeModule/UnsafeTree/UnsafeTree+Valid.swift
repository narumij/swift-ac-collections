extension UnsafeTree {
  
  @inlinable
  @inline(__always)
  internal func ___is_null_or_end(_ ptr: _NodePtr) -> Bool {
    ptr == nil || ptr == end
  }

  /// - Complexity: O(1)
  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___is_begin(_ p: _NodePtr) -> Bool {
    p == __begin_node_
  }

  /// - Complexity: O(1)
  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___is_end(_ p: _NodePtr) -> Bool {
    p == end
  }

  /// - Complexity: O(1)
  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___is_root(_ p: _NodePtr) -> Bool {
    p == __root
  }

  /// - Complexity: O(1)
  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___initialized_contains(_ p: _NodePtr) -> Bool {
    0..<_header.initializedCount ~= p!.pointee.___node_id_
  }

  /// 真の場合、操作は失敗する
  ///
  /// 添え字アクセスチェック用
  ///
  /// endを無効として扱う
  /// - Complexity: O(1)
  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___is_subscript_null(_ p: _NodePtr) -> Bool {

    // 初期化済みチェックでnullptrとendは除外される
    //    return !___initialized_contains(p) || ___is_garbaged(p)
    // begin -> false
    // end -> true
    return ___is_null_or_end(p) || _header.initializedCount <= p!.pointee.___node_id_ || ___is_garbaged(p)
  }

  /// 真の場合、操作は失敗する
  ///
  /// beginを有効として扱う
  ///
  /// endを無効として扱う
  /// - Complexity: O(1)
  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___is_next_null(_ p: _NodePtr) -> Bool {
    ___is_subscript_null(p)
  }

  /// 真の場合、操作は失敗する
  ///
  /// beginを無効として扱う
  ///
  /// endを有効として扱う
  /// - Complexity: O(1)
  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___is_prev_null(_ p: _NodePtr) -> Bool {

    // begin -> true
    // end -> false
    return p == nullptr || _header.initializedCount <= p!.pointee.___node_id_ || ___is_begin(p) || ___is_garbaged(p)
  }

  /// 真の場合、操作は失敗する
  ///
  /// 範囲チェック用
  ///
  /// endを有効として扱う
  /// - Complexity: O(1)
  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___is_offset_null(_ p: _NodePtr) -> Bool {
    return p == nullptr || _header.initializedCount <= p!.pointee.___node_id_ || ___is_garbaged(p)
  }

  /// 真の場合、操作は失敗する
  ///
  /// `end..<end`のケースを有効として扱う
  ///
  /// ベースコレクションの場合、回収済みでさえなければ、`start..<end`に必ず含まれているので、範囲チェックを省略している
  /// - Complexity: O(1)
  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___is_range_null(_ p: _NodePtr, _ l: _NodePtr) -> Bool {
    // end..<endのケースを許可するため、左辺を___is_offset_nullとしている
    ___is_offset_null(p) || ___is_offset_null(l)
  }
}

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___ensureValid(after i: _NodePtr) {
    if ___is_next_null(i) {
      fatalError(.invalidIndex)
    }
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___ensureValid(before i: _NodePtr) {
    if ___is_prev_null(i) {
      fatalError(.invalidIndex)
    }
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___ensureValid(offset i: _NodePtr) {
    if ___is_offset_null(i) {
      fatalError(.invalidIndex)
    }
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___ensureValid(subscript i: _NodePtr) {
    if ___is_subscript_null(i) {
      fatalError(.invalidIndex)
    }
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___ensureValid(begin i: _NodePtr, end j: _NodePtr) {
    if ___is_range_null(i, j) {
      fatalError(.invalidIndex)
    }
  }
}
