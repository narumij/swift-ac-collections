//
//  unsafe_tree+erase.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

// 主流のeraseはsafe_treeのものをつかう

@usableFromInline
protocol ___EraseProtocol: RemoveProtocol_ptr, RemoveInteface, DellocationInterface {
}

extension ___EraseProtocol {

  @inlinable
  @inline(__always)
  internal func
    ___erase(_ __p: _NodePtr)
  {
    // 差がつかないどころか逆に負ける不思議
    ___remove_node_pointer(__p)
    destroy(__p)
  }
}

@usableFromInline
protocol ___EraseUniqueProtocol: ___EraseProtocol, FindInteface, EndInterface, EraseInterface { }

extension ___EraseUniqueProtocol {
  
  @inlinable
  @inline(never)
  internal func ___erase_unique_(_ __k: _Key) -> Bool {
    let __i = find(__k)
    if __i == end {
      return false
    }
    ___erase(__i)
    return true
  }
}
