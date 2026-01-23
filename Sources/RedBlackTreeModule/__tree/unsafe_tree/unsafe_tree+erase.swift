//
//  unsafe_tree+erase.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

// 主流のeraseはsafe_treeのものをつかう

@usableFromInline
protocol FaultTorelantEraseProtocol: _UnsafeNodePtrType, EraseInterface, EndNodeInterface {}

extension FaultTorelantEraseProtocol {
  
  /// 最悪でもnullかendで止まる
  @inlinable
  @inline(__always)
  internal func
  ___fault_torelant_erase(_ __f: _NodePtr, _ __l: _NodePtr) -> _NodePtr
  {
    var __f = __f
    while __f != __l, !__f.___is_null_or_end {
      __f = erase(__f)
    }
    return __l
  }
}

@usableFromInline
protocol FaultTorelantEraseMultiProtocol: _UnsafeNodePtrType, _KeyType, EqualInterface, EraseInterface, EndNodeInterface {}

extension FaultTorelantEraseMultiProtocol {

  /// 最悪でもnullかendで止まる
  @inlinable
  @inline(__always)
  internal func ___fault_torelant_erase_multi(_ __k: _Key) -> Int {
    var __p = __equal_range_multi(__k)
    var __r = 0
    while __p.0 != __p.1, !__p.0.___is_null_or_end {
      defer { __r += 1 }
      __p.0 = erase(__p.0)
    }
    return __r
  }
}
