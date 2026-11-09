//
//  UnsafeTreeV2+Insert.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/11/09.
//

extension UnsafeTreeV2 where Base: ScalarValueTrait {

  @inlinable
  mutating func insertIfNotPresent(_ newMember: _Key) -> (
    inserted: Bool, memberAfterInsert: _PayloadValue
  ) where _Key == _PayloadValue {
    
    // 共有中に既存の要素を挿入しても、木をコピーしない（RBT-086）
    if !isUnique() {
      let __r = find(newMember)
      if __r != end {
        return (false, Base.__payload_(__r))
      }
    }
    ensureUniqueAndCapacity()
    let (__r, __inserted) = update { $0.__insert_unique(newMember) }
    return (__inserted, __inserted ? newMember : Base.__payload_(__r))
  }
}
