//
//  tree+ref.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

/// 赤黒木の参照型を表す内部enum
///
/// (現在はプロトコルのテスト用に使っている)
//@available(*, deprecated, message: "もうつかっていない。配列インデックス方式の名残。")
public
  enum _PointerIndexRef: Equatable
{
  /// 右ノードへの参照
  case __right_(_PointerIndex)
  /// 左ノードへの参照
  case __left_(_PointerIndex)
}

extension TreeAlgorithmProtocol_std where _NodePtr == Int, _NodeRef == _PointerIndexRef {

  @inlinable
  @inline(__always)
  internal func __ptr_(_ rhs: _NodeRef) -> _NodePtr {
    switch rhs {
    case .__right_(let basePtr):
      return __right_(basePtr)
    case .__left_(let basePtr):
      return __left_(basePtr)
    }
  }

  @inlinable
  @inline(__always)
  internal func __left_ref(_ p: _NodePtr) -> _NodeRef {
    assert(p != .nullptr)
    return .__left_(p)
  }

  @inlinable
  @inline(__always)
  internal func __right_ref(_ p: _NodePtr) -> _NodeRef {
    assert(p != .nullptr)
    return .__right_(p)
  }
}

extension TreeAlgorithmProtocol_std where _NodePtr == Int, _NodeRef == _PointerIndexRef {

  @inlinable
  @inline(__always)
  internal func __ptr_(_ lhs: _NodeRef, _ rhs: _NodePtr) {
    switch lhs {
    case .__right_(let basePtr):
      return __right_(basePtr, rhs)
    case .__left_(let basePtr):
      return __left_(basePtr, rhs)
    }
  }
}
