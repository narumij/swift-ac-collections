//
//  _NodePtrBitmap.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/09/27.
//

#if false
  @frozen
  public struct _ComparableNodePtr<Base: _BaseNode_KeyProtocol>
  where Base._NodePtr == UnsafeMutablePointer<UnsafeNode>, Base._Key: Comparable {

    @usableFromInline let pointer: Base._NodePtr

    @inlinable
    var key: Base._Key {
      Base.__get_value(pointer)
    }
  }

  extension _ComparableNodePtr: Equatable {

    @inlinable
    public static func == (lhs: _ComparableNodePtr, rhs: _ComparableNodePtr) -> Bool {
      lhs.pointer == rhs.pointer
    }
  }

  extension _ComparableNodePtr: Comparable {

    @inlinable
    public static func < (lhs: _ComparableNodePtr, rhs: _ComparableNodePtr) -> Bool {
      if lhs.key < rhs.key {
        return true
      }
      if lhs.key != rhs.key {
        return false
      }
      return lhs.pointer.___ptr_bitmap() < rhs.pointer.___ptr_bitmap()
    }
  }
#endif

