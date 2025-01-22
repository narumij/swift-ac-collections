import Foundation

@usableFromInline
protocol PointerCompareProtocol: ValueProtocol {
  func ___ptr_comp(_ l: _NodePtr,_ r: _NodePtr) -> Bool
}

// 現状使っていない
@usableFromInline
protocol CompareUniqueProtocol: ValueProtocol {}

extension CompareUniqueProtocol {
  
  /// multisetでも、インデックス比較に関して不正な結果だが、レンジで使う限り落ちはしない
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

  // ノードの高さを数える
  @inlinable
  @inline(__always)
  func ___ptr_height(_ __p: _NodePtr) -> Int {
    assert(__p != .nullptr, "Node shouldn't be null")
    var __h = 0
    var __p = __p
    while __p != __root(), __p != end() {
      __p = __parent_(__p)
      __h += 1
    }
    return __h
  }
  
  // ノードの大小を比較する
  @inlinable
  @inline(__always)
  func ___ptr_comp_multi(_ __l: _NodePtr,_ __r: _NodePtr) -> Bool {
    assert(__l != .nullptr, "Left node shouldn't be null")
    assert(__r != .nullptr, "Right node shouldn't be null")
    guard
      __l != end(),
      __r != end(),
      __l != __r else {
      return __l != end() && __r == end()
    }
    var (__l, __lh) = (__l, ___ptr_height(__l))
    var (__r, __rh) = (__r, ___ptr_height(__r))
    // __lの高さを詰める
    while __lh > __rh {
      // 共通祖先が__rだった場合
      if __parent_(__l) == __r {
        // __lが左であれば、__lが小さい
        return __tree_is_left_child(__l)
      }
      (__l, __lh) = (__parent_(__l), __lh - 1)
    }
    // __rの高さを詰める
    while __lh < __rh {
      // 共通祖先が__lだった場合
      if __parent_(__r) == __l {
        // __rが右であれば(左ではない)、__lが小さい
        return !__tree_is_left_child(__r)
      }
      (__r, __rh) = (__parent_(__r), __rh - 1)
    }
    // 親が一致するまで、両方の高さを詰める
    while __parent_(__l) != __parent_(__r) {
      (__l, __r) = (__parent_(__l), __parent_(__r))
    }
    // 共通祖先が__lと__r以外だった場合
    // 共通祖先の左が__lであれば、__lが小さい
    return  __tree_is_left_child(__l)
  }
  
  @inlinable
  @inline(__always)
  func ___ptr_comp(_ l: _NodePtr,_ r: _NodePtr) -> Bool {
    ___ptr_comp_multi(l, r)
  }
}

@usableFromInline
protocol CompareProtocol: PointerCompareProtocol { }

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
