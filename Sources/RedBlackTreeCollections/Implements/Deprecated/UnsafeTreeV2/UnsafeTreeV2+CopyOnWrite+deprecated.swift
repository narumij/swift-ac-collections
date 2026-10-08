//
//  UnsafeTreeV2+CopyOnWrite+deprecated.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/06/01.
//

extension UnsafeTreeV2 {

  #if COMPATIBLE_ATCODER_2025
    @inlinable
    internal mutating func _strongEnsureUnique() {
      let isTreeUnique = isUnique()
      let isPoolUnique =
        _buffer.header._tied == nil
        ? true : isKnownUniquelyReferenced(&_buffer.header._tied!)

      if isTreeUnique, isPoolUnique {
        /* NOP */
      } else {
        self = self.copy()
      }
    }
  #endif
}
