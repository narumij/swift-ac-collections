//
//  UnsafeTreeV2+Debug.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/12.
//

extension UnsafeTreeV2 {

  #if AC_COLLECTIONS_INTERNAL_CHECKS
    /// CoWの発火回数を観察するためのプロパティ
    @usableFromInline
    internal var copyCount: UInt {
      get { _buffer.header.copyCount }
      set {
        _buffer.withUnsafeMutablePointerToHeader {
          $0.pointee.copyCount = newValue
        }
      }
    }
  #endif
}

// MARK: -

extension UnsafeTreeV2 {

  #if DEBUG
    @inlinable
    func _nodeID(_ p: _NodePtr) -> Int? {
      return p.pointee.___raw_index
    }
  #endif
}

extension UnsafeTreeV2 {

  #if DEBUG
    func dumpTree(label: String = "") {
      print("==== UnsafeTree \(label) ====")
      print(" count:", count)
      print(" freshPool:", _buffer.header.freshPoolActualCount, "/", capacity)
      print(" destroyCount:", _buffer.header.recycleCount)
      print(" root:", __root.pointee.___raw_index as Any)
      print(" begin:", __begin_node_.pointee.___raw_index as Any)

      var it = makeUsedNodeIterator()
      while let p = it.next() {
        print(
          p.pointee.debugDescription { self._nodeID($0!) }
        )
      }
      print("============================")
    }
  #endif
}
