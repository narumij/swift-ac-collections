//
//  _reserveCapacity.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/17.
//

#if RESERVE_CAPACITY_BENCH
  extension UnsafeTreeV2BufferHeader {

    @inlinable
    internal func _requestCapacity(_capacity cap: Int) -> (require: Int, request: Int) {
      let require = cap &+ 1
      return (require, growth(from: freshPoolCapacity, to: require))
    }

    @usableFromInline  // 呼び出し元の命令キャッシュ圧低下を狙っている
    internal mutating func _ensureCapacitySlow(_capacity cap: Int) {
      let cap = _requestCapacity(_capacity: cap)
      guard freshPoolCapacity < cap.require else {
        return
      }
      grow(cap.request)
    }

    @usableFromInline  // 呼び出し元の命令キャッシュ圧低下を狙っている
    internal func _ensureUniqueSlow<Base>(_capacity cap: Int) -> UnsafeTreeV2<Base> {
      copy(minimumCapacity: _requestCapacity(_capacity: cap).request)
    }
  }
#endif

#if RESERVE_CAPACITY_BENCH
  extension UnsafeTreeV2 {

    @inlinable
    internal mutating func ensureUniqueAndCapacity(_capacity minimumCapacity: Int) {

      if !isUnique() {
        self = withMutableHeader { $0._ensureUniqueSlow(_capacity: minimumCapacity) }
      } else {
        withMutableHeader { $0._ensureCapacitySlow(_capacity: minimumCapacity) }
      }
    }
  }

  extension RedBlackTreeSet {

    @inlinable
    public mutating func _reserveCapacity(force minimumCapacity: Int) {
      __tree_.ensureUniqueAndCapacity(_capacity: minimumCapacity)
    }
  }

  extension RedBlackTreeDictionary {

    @inlinable
    public mutating func _reserveCapacity(force minimumCapacity: Int) {
      __tree_.ensureUniqueAndCapacity(_capacity: minimumCapacity)
    }
  }
#endif
