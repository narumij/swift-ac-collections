//
//  UnsafeIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/12.
//


@usableFromInline
struct UnsafeIterator: UnsafeTreeNodeProtocol {
  
  internal init(_ __ptr_: UnsafeIterator._NodePtr) {
    self.__ptr_ = __ptr_
  }
  
  var __ptr_: _NodePtr
  
  public func advanced(by n: Int) -> UnsafeIterator {
    var n = n
    var ___ptr = __ptr_
    while n != 0 {
      if n < 0 {
        ___ptr = __tree_prev_iter(__ptr_)
        n += 1
      } else {
        ___ptr = __tree_next_iter(__ptr_)
        n -= 1
      }
    }
    return .init(___ptr)
  }
  
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  public typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
  public var nullptr: UnsafeMutablePointer<UnsafeNode> { UnsafeNode.nullptr }
  
  // 邪魔くさいので取り除けるようにする
  @usableFromInline var end: UnsafeMutablePointer<UnsafeNode> { UnsafeNode.nullptr }
}


extension UnsafeMutablePointer<UnsafeNode> {
  
  func __tree_prev_iter() -> UnsafeMutablePointer {
    UnsafeIterator(self).advanced(by: -1).__ptr_
  }
  
  func __tree_next_iter() -> UnsafeMutablePointer {
    UnsafeIterator(self).advanced(by: 1).__ptr_
  }
}

