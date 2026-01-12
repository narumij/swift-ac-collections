//
//  File.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/13.
//

#if DEBUG

extension RedBlackTreeSet: ___UnsafeCopyOnWriteV2 { }
extension RedBlackTreeMultiSet: ___UnsafeCopyOnWriteV2 { }
extension RedBlackTreeDictionary: ___UnsafeCopyOnWriteV2 { }
extension RedBlackTreeMultiMap: ___UnsafeCopyOnWriteV2 { }

@usableFromInline
protocol ___UnsafeCopyOnWriteV2 {
  associatedtype Base: ___TreeBase
  var __tree_: UnsafeTreeV2<Base> { get set }
}

extension ___UnsafeCopyOnWriteV2 {

  @inlinable
  @inline(__always)
  internal mutating func _isBaseKnownUnique() -> Bool {
    #if true
    return __tree_._buffer.isUniqueReference()
    #else
      return true
    #endif
  }

  @inlinable
  @inline(__always)
  internal mutating func _isKnownUniquelyReferenced_LV1() -> Bool {
    #if !DISABLE_COPY_ON_WRITE
      #if !USE_SIMPLE_COPY_ON_WRITE || COMPATIBLE_ATCODER_2025
        return !__tree_.isReadOnly && _isBaseKnownUnique()
      #else
        return __tree_.isUniqueReference()
      #endif
    #else
      return true
    #endif
  }

  @inlinable
  @inline(__always)
  internal mutating func _isKnownUniquelyReferenced_LV2() -> Bool {
    #if !DISABLE_COPY_ON_WRITE
      if !_isKnownUniquelyReferenced_LV1() {
        return false
      }
    if !__tree_._buffer.isUniqueReference() {
        return false
      }
    #endif
    return true
  }
}
#endif
