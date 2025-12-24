//
//  ___BaseSequence.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/12/24.
//

@usableFromInline
protocol ___BaseSequence: ___Base {
  func ___index_or_nil(_ p: _NodePtr) -> Index?
}

extension ___BaseSequence {
  
  @inlinable
  @inline(__always)
  func ___contains(_ __k: _Key) -> Bool {
    __tree_.__count_unique(__k) != 0
  }
}

extension ___BaseSequence {
  
  @inlinable
  @inline(__always)
  func ___min() -> _Value? {
    __tree_.__root() == .nullptr ? nil : __tree_[__tree_.__tree_min(__tree_.__root())]
  }

  @inlinable
  @inline(__always)
  func ___max() -> _Value? {
    __tree_.__root() == .nullptr ? nil : __tree_[__tree_.__tree_max(__tree_.__root())]
  }
}

extension ___BaseSequence {
  
  @inlinable
  @inline(__always)
  public func ___lower_bound(_ __k: _Key) -> _NodePtr {
    __tree_.lower_bound(__k)
  }

  @inlinable
  @inline(__always)
  public func ___upper_bound(_ __k: _Key) -> _NodePtr {
    __tree_.upper_bound(__k)
  }

  @inlinable
  @inline(__always)
  func ___index_lower_bound(_ __k: _Key) -> Index {
    ___index(___lower_bound(__k))
  }

  @inlinable
  @inline(__always)
  func ___index_upper_bound(_ __k: _Key) -> Index {
    ___index(___upper_bound(__k))
  }
}

extension ___BaseSequence {
  
  @inlinable
  @inline(__always)
  func ___first_index(of member: _Key) -> Index? {
    let ptr = __tree_.__ptr_(__tree_.__find_equal(member).__child)
    return ___index_or_nil(ptr)
  }
}
