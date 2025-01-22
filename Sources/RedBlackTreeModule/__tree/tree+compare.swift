import Foundation

// 現状使っていない
// multiと比べて速いため、multiset以外ではこちらを使いたい
// だが、インジェクションが難しいので一旦保留にしている
@usableFromInline
protocol CompareUniqueProtocol: ValueProtocol {}

extension CompareUniqueProtocol {
  
  @inlinable
  @inline(__always)
  func ___ptr_comp_unique(_ l: _NodePtr,_ r: _NodePtr) -> Bool {
    guard
      l != r,
      r != .end,
      l != .end
    else {
      return l != .end && r == .end
    }
    return value_comp(__value_(l), __value_(r))
  }
  
  @inlinable
  @inline(__always)
  func ___ptr_comp(_ l: _NodePtr,_ r: _NodePtr) -> Bool {
    ___ptr_comp_unique(l, r)
  }
}

@usableFromInline
protocol CompareMultiProtocol: MemberProtocol & RootProtocol & EndProtocol {}

extension CompareMultiProtocol {

  @inlinable
  @inline(__always)
  func ___ptr_height(_ __p: _NodePtr) -> Int {
    var height = 0
    var __p = __p
    while __p != __root(), __p != end() {
      __p = __parent_(__p)
      height += 1
    }
    return height
  }
  
  @inlinable
  @inline(__always)
  func ___ptr_comp_multi(_ l: _NodePtr,_ r: _NodePtr) -> Bool {
    guard
      l != end(),
      r != end(),
      l != r else {
      return l != end() && r == end()
    }
    var (l, lh) = (l, ___ptr_height(l))
    var (r, rh) = (r, ___ptr_height(r))
    while lh > rh {
      if __parent_(l) == r {
        return __tree_is_left_child(l)
      }
      (l, lh) = (__parent_(l), lh - 1)
    }
    while lh < rh {
      if __parent_(r) == l {
        return !__tree_is_left_child(r)
      }
      (r, rh) = (__parent_(r), rh - 1)
    }
    while __parent_(l) != __parent_(r) {
      (l, r) = (__parent_(l), __parent_(r))
    }
    return  __tree_is_left_child(l)
  }
  
  @inlinable
  @inline(__always)
  func ___ptr_comp(_ l: _NodePtr,_ r: _NodePtr) -> Bool {
    ___ptr_comp_multi(l, r)
  }
}

@usableFromInline
protocol CompareProtocol {
  func ___ptr_comp(_ l: _NodePtr,_ r: _NodePtr) -> Bool
}

extension CompareProtocol {
  
  @inlinable
  @inline(__always)
  func ___ptr_less_than(_ l: _NodePtr,_ r: _NodePtr) -> Bool {
    ___ptr_comp(l, r)
  }

  @inlinable
  @inline(__always)
  func ___ptr_less_than_or_equal(_ l: _NodePtr,_ r: _NodePtr) -> Bool {
    return l == r || ___ptr_comp(l, r)
  }
  
  @inlinable
  @inline(__always)
  func ___ptr_greator_than(_ l: _NodePtr,_ r: _NodePtr) -> Bool {
    return l != r && !___ptr_comp(l, r)
  }

  @inlinable
  @inline(__always)
  func ___ptr_greator_than_or_equal(_ l: _NodePtr,_ r: _NodePtr) -> Bool {
    return !___ptr_comp(l, r)
  }

  @inlinable
  @inline(__always)
  func ___ptr_closed_range_contains(_ l: _NodePtr,_ r: _NodePtr,_ p: _NodePtr) -> Bool {
    l == p || r == p || (___ptr_comp(l, p) && ___ptr_comp(p, r))
  }
}
