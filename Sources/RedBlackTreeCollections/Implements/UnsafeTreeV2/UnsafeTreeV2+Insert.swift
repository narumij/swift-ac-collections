//
//  UnsafeTreeV2+Insert.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/11/09.
//

extension UnsafeTreeV2 {
  @inlinable
  func ___retrieve(
    _ __parent: _NodePtr,
    _ __child: _NodeRef
  ) -> (__parent: _NodePtr, __child: _NodeRef) {
    let __p =
      __parent.___is_end ? __end_node : _buffer.header[__parent.trackingTag]
    if __parent.__left_ref == __child {
      return (__p, __p.__left_ref)
    } else if __parent.__right_ref == __child {
      return (__p, __p.__right_ref)
    } else {
      fatalError("Invalid parent child pair.")
    }
  }
}

extension UnsafeTreeV2 where Base: ScalarValueTrait {

  @inlinable
  mutating func ___insert_unique_if_not_present(
    _ newMember: _Key
  ) -> (inserted: Bool, memberAfterInsert: _PayloadValue)
  where _Key == _PayloadValue {
    var (__parent, __child) = update { $0.__find_equal(__key(newMember)) }
    let __e = __end_node
    if __child.pointee != nullptr {
      return (false, Base.__payload_(__child.pointee))
    }
    ensureUniqueAndCapacity()
    if __e != __end_node {  // 木の不一致判定
      (__parent, __child) = ___retrieve(__parent, __child)
    }
    return update {
      let __h = $0.__construct_node(newMember)
      $0.__insert_node_at(__parent, __child, __h)
      return (true, Base.__payload_(__h))
    }
  }
}
