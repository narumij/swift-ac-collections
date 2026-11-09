//
//  UnsafeTreeV2+Insert.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/11/09.
//

extension UnsafeTreeV2 where Base: ScalarValueTrait {

  @inlinable
  mutating func insertIfNotPresent(
    _ newMember: _Key
  ) -> (inserted: Bool, memberAfterInsert: _PayloadValue)
  where _Key == _PayloadValue {
    #if false
    // 共有中に既存の要素を挿入しても、木をコピーしない（RBT-086）
    if !isUnique() {
      let __r = find(newMember)
      if __r != end { return (false, Base.__payload_(__r)) }
    }
    ensureUniqueAndCapacity()
    let (__r, __inserted) = update { $0.__insert_unique(newMember) }
    return (__inserted, __inserted ? newMember : Base.__payload_(__r))
    #else
    var (__parent, __child) = __find_equal(__key(newMember))
    let e = __end_node
    if __child.pointee != nullptr {
      return (false, Base.__payload_(__child.pointee))
    }
    ensureUniqueAndCapacity()
    
    if e != __end_node {
      if __parent.__left_ref == __child {
        __parent = __parent.___is_end ? __end_node : _buffer.header[__parent.trackingTag]
        __child = __parent.__left_ref
      } else {
        __parent = __parent.___is_end ? __end_node : _buffer.header[__parent.trackingTag]
        __child = __parent.__right_ref
      }
    }

    let __h = __construct_node(newMember)
    __insert_node_at(__parent, __child, __h)
    
    return (true, Base.__payload_(__h))
    #endif
  }
}
