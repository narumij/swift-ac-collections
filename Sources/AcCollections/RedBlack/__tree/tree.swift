/*
 Copyright 2023 narumij

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0
 */

// Original : https://github.com/llvm/llvm-project/blob/main/libcxx/include/__tree
// OriginalLicence: https://github.com/llvm/llvm-project/blob/main/LICENSE.TXT

import Foundation

protocol ___tree_node_pointer_base_protocol: Equatable, ExpressibleByNilLiteral {
    associatedtype __node_ptr_type
    where __node_ptr_type == Self
    var __left_:   __node_ptr_type { get nonmutating set }
    var __right_:  __node_ptr_type { get nonmutating set }
    var __parent_: __node_ptr_type { get nonmutating set }
    var __is_black_: Bool  { get nonmutating set }
    func __parent_unsafe() -> __node_ptr_type
    static var nullptr: Self { get }
}

protocol ___tree_node_reference_protocol: Equatable, ExpressibleByNilLiteral {
    associatedtype Referencee
    var referencee: Referencee { get nonmutating set }
    static var nullptr: Self { get }
}

protocol ___tree_node_pointer_value_protocol: ___tree_node_pointer_base_protocol {
    associatedtype __node_value_type
    var __value_: __node_value_type { get nonmutating set }
}

protocol ___tree_node_pointer_ref_protocol: ___tree_node_pointer_base_protocol {
    associatedtype __node_ref_type
    where __node_ref_type: ___tree_node_reference_protocol,
          __node_ref_type.Referencee == __node_ptr_type
    var __self_ref: __node_ref_type { get }
    var __parent_ref: __node_ref_type { get }
    var __left_ref:   __node_ref_type { get }
    var __right_ref:  __node_ref_type { get }
}

protocol ___tree_node_pointer_protocol: ___tree_node_pointer_base_protocol & ___tree_node_pointer_value_protocol & ___tree_node_pointer_ref_protocol { }

protocol ___tree_base { }

protocol ___tree_find_base: ___tree_base {
    
    associatedtype Element
    
    associatedtype _NodePtr
    where _NodePtr: ___tree_node_pointer_protocol,
          _NodePtr.__node_value_type == Element

    associatedtype _NodeRef
    where _NodeRef == _NodePtr.__node_ref_type

    var __root: _NodePtr { get }
    var __root_ptr: _NodeRef { get }
    var __end_node: _NodePtr { get }
    
    static var value_comp: (Element, Element) -> Bool { get }
    
    func addressof(_ ptr: _NodeRef) -> _NodeRef
}

extension ___tree_find_base {
    func addressof(_ ptr: _NodeRef) -> _NodeRef {
        ptr
    }
    var __root_ptr: _NodeRef {
        __root.__self_ref
    }
}

protocol ___tree_clear_base: ___tree_base_find {
    func destroy(_: _NodePtr)
    var __begin_node: _NodePtr { get nonmutating set }
    var size: Int { get nonmutating set }
}

protocol ___tree_insert_base: ___tree_find_base {
    var __begin_node: _NodePtr { get nonmutating set }
    var size: Int { get nonmutating set }
}

protocol ___tree_construct_base: ___tree_insert_base {
    associatedtype __tree_iterator
    func __construct_node() -> _NodePtr
    func iterator(_ r: _NodeRef) -> __tree_iterator
}

extension ___tree_base {
    
    static func
    __tree_is_left_child<_NodePtr>(_ __x: _NodePtr) -> Bool
    where _NodePtr: ___tree_node_pointer_base_protocol
    {
        return __x == __x.__parent_.__left_
    }
    
    fileprivate static func
    __tree_sub_invariant<_NodePtr>(_ __x: _NodePtr) -> Int
    where _NodePtr: ___tree_node_pointer_base_protocol
    {
        if (__x == .nullptr) {
            return 1; }
          // parent consistency checked by caller
          // check __x->__left_ consistency
        if (__x.__left_ != .nullptr && __x.__left_.__parent_ != __x) {
            return 0; }
          // check __x->__right_ consistency
        if (__x.__right_ != .nullptr && __x.__right_.__parent_ != __x) {
            return 0; }
          // check __x->__left_ != __x->__right_ unless both are nullptr
        if (__x.__left_ == __x.__right_ && __x.__left_ != nil) {
            return 0; }
          // If this is red, neither child can be red
        if (!__x.__is_black_) {
            if (__x.__left_ != .nullptr && !__x.__left_.__is_black_) {
                return 0; }
            if (__x.__right_ != .nullptr && !__x.__right_.__is_black_) {
                return 0; }
          }
        let __h = __tree_sub_invariant(__x.__left_);
        if (__h == 0) {
            return 0; } // invalid left subtree
        if (__h != __tree_sub_invariant(__x.__right_)) {
            return 0; }                   // invalid or different height right subtree
        return __h + (__x.__is_black_ ? 1 : 0); // return black height of this node
    }
    
    static func
    __tree_invariant<_NodePtr>(_ __root: _NodePtr) -> Bool
    where _NodePtr: ___tree_node_pointer_base_protocol
    {
        if (__root == .nullptr) {
            return true; }
        // check __x->__parent_ consistency
        if (__root.__parent_ == .nullptr) {
            return false; }
        if (!__tree_is_left_child(__root)) {
            return false; }
        // root must be black
        if (!__root.__is_black_) {
            return false; }
        // do normal node checks
        return __tree_sub_invariant(__root) != 0;
    }
    
    static func
    __tree_min<_NodePtr>(_ __x: _NodePtr) -> _NodePtr
    where _NodePtr: ___tree_node_pointer_base_protocol
    {
        assert(__x != .nullptr, "Root node shouldn't be null");
        var __x = __x
        while (__x.__left_ != .nullptr) {
            __x = __x.__left_ }
        return __x
    }
    
    static func
    __tree_max<_NodePtr>(_ __x: _NodePtr) -> _NodePtr
    where _NodePtr: ___tree_node_pointer_base_protocol
    {
        assert(__x != .nullptr, "Root node shouldn't be null");
        var __x = __x
        while (__x.__right_ != .nullptr) {
            __x = __x.__right_ }
        return __x
    }
    
    static func
    __tree_next<_NodePtr>(_ __x: _NodePtr) -> _NodePtr
    where _NodePtr: ___tree_node_pointer_base_protocol
    {
        assert(__x != .nullptr, "node shouldn't be null");
        var __x = __x
        if (__x.__right_ != .nullptr) {
            return __tree_min(__x.__right_); }
        while (!__tree_is_left_child(__x)) {
            __x = __x.__parent_unsafe(); }
        return __x.__parent_unsafe();
    }
    
    static func static_cast_EndNodePtr<_NodePtr>(_ p: _NodePtr) -> _NodePtr { p }

    static func
    __tree_next_iter<_NodePtr>(_ __x: _NodePtr) -> _NodePtr
    where _NodePtr: ___tree_node_pointer_base_protocol
    {
        assert(__x != .nullptr, "node shouldn't be null")
        var __x = __x
        if (__x.__right_ != .nullptr) {
            return static_cast_EndNodePtr(__tree_min(__x.__right_)); }
        while (!__tree_is_left_child(__x)) {
            __x = __x.__parent_unsafe(); }
        return static_cast_EndNodePtr(__x.__parent_);
    }
    
    static func static_cast_NodePtr<_NodePtr>(_ p: _NodePtr) -> _NodePtr { p }
    
    static func
    __tree_prev_iter<_NodePtr>(_ __x: _NodePtr) -> _NodePtr
    where _NodePtr: ___tree_node_pointer_base_protocol
    {
        assert(__x != .nullptr, "node shouldn't be null")
        if (__x.__left_ != .nullptr) {
            return __tree_max(__x.__left_); }
        var __xx: _NodePtr = static_cast_NodePtr(__x);
        while (__tree_is_left_child(__xx)) {
            __xx = __xx.__parent_unsafe(); }
        return __xx.__parent_unsafe();
    }
    
    static func
    __tree_leaf<_NodePtr>(_ __x: _NodePtr) -> _NodePtr
    where _NodePtr: ___tree_node_pointer_base_protocol
    {
        assert(__x != .nullptr, "node shouldn't be null");
        var __x = __x
        while (true)
        {
            if (__x.__left_ != .nullptr)
            {
                __x = __x.__left_
                continue
            }
            if (__x.__right_ != .nullptr)
            {
                __x = __x.__right_
                continue
            }
            break
        }
        return __x
    }
    
    static func
    __tree_left_rotate<_NodePtr>(_ __x: _NodePtr)
    where _NodePtr: ___tree_node_pointer_base_protocol
    {
        assert(__x != .nullptr, "node shouldn't be null");
        assert(__x.__right_ != .nullptr, "node should have a right child");
        let __y = __x.__right_
        __x.__right_ = __y.__left_
        if (__x.__right_ != .nullptr) {
            __x.__right_.__parent_ = __x }
        __y.__parent_ = __x.__parent_
        if __tree_is_left_child(__x) {
            __x.__parent_.__left_ = __y }
        else {
            __x.__parent_.__right_ = __y }
        __y.__left_ = __x
        __x.__parent_ = __y
    }
    
    static func
    __tree_right_rotate<_NodePtr>(_ __x: _NodePtr)
    where _NodePtr: ___tree_node_pointer_base_protocol
    {
        assert(__x != .nullptr, "node shouldn't be null");
        assert(__x.__left_ != .nullptr, "node should have a left child");
        let __y = __x.__left_
        __x.__left_ = __y.__right_
        if (__x.__left_ != .nullptr) {
            __x.__left_.__parent_ = __x }
        __y.__parent_ = __x.__parent_
        if __tree_is_left_child(__x) {
            __x.__parent_.__left_ = __y }
        else {
            __x.__parent_.__right_ = __y }
        __y.__right_ = __x
        __x.__parent_ = __y
    }
    
    static func
    __tree_balance_after_insert<_NodePtr>(_ __root: _NodePtr, _ __x: _NodePtr)
    where _NodePtr: ___tree_node_pointer_base_protocol
    {
        assert(__root != .nullptr, "Root of the tree shouldn't be null");
        assert(__x != .nullptr, "Can't attach null node to a leaf");
        __x.__is_black_ = __x == __root;
        while (__x != __root && !__x.__parent_unsafe().__is_black_) {
            var __x = __x
          // __x->__parent_ != __root because __x->__parent_->__is_black == false
            if (__tree_is_left_child(__x.__parent_unsafe())) {
                let __y: _NodePtr = __x.__parent_unsafe().__parent_unsafe().__right_;
                if (__y != .nullptr && !__y.__is_black_) {
                    __x             = __x.__parent_unsafe();
                    __x.__is_black_ = true;
                    __x             = __x.__parent_unsafe();
                    __x.__is_black_ = __x == __root;
                    __y.__is_black_ = true;
                } else {
                    if (!__tree_is_left_child(__x)) {
                        __x = __x.__parent_unsafe();
                        __tree_left_rotate(__x);
                    }
                    __x             = __x.__parent_unsafe();
                    __x.__is_black_ = true;
                    __x             = __x.__parent_unsafe();
                    __x.__is_black_ = false;
                    __tree_right_rotate(__x);
                    break;
                }
            } else {
                let __y: _NodePtr = __x.__parent_unsafe().__parent_.__left_;
                if (__y != .nullptr && !__y.__is_black_) {
                    __x             = __x.__parent_unsafe();
                    __x.__is_black_ = true;
                    __x             = __x.__parent_unsafe();
                    __x.__is_black_ = __x == __root;
                    __y.__is_black_ = true;
                } else {
                    if (__tree_is_left_child(__x)) {
                        __x = __x.__parent_unsafe();
                        __tree_right_rotate(__x);
                    }
                    __x             = __x.__parent_unsafe();
                    __x.__is_black_ = true;
                    __x             = __x.__parent_unsafe();
                    __x.__is_black_ = false;
                    __tree_left_rotate(__x);
                    break;
                }
            }
        }
    }
    
    static func
    __tree_remove<_NodePtr>(_ __root: _NodePtr,_ __z: _NodePtr)
    where _NodePtr: ___tree_node_pointer_base_protocol
    {
        assert(__root != .nullptr, "Root node should not be null")
        assert(__z != .nullptr, "The node to remove should not be null")
        assert(__tree_invariant(__root), "The tree invariants should hold");
        var __root = __root
        // __z will be removed from the tree.  Client still needs to destruct/deallocate it
        // __y is either __z, or if __z has two children, __tree_next(__z).
        // __y will have at most one child.
        // __y will be the initial hole in the tree (make the hole at a leaf)
        let __y: _NodePtr = (__z.__left_ == .nullptr || __z.__right_ == .nullptr) ?
        __z : __tree_next(__z)
        // __x is __y's possibly null single child
        var __x: _NodePtr = __y.__left_ != .nullptr ? __y.__left_ : __y.__right_
        // __w is __x's possibly null uncle (will become __x's sibling)
        var __w: _NodePtr = .nullptr
        // link __x to __y's parent, and find __w
        if (__x != .nullptr) {
            __x.__parent_ = __y.__parent_ }
        if (__tree_is_left_child(__y))
        {
            __y.__parent_.__left_ = __x
            if (__y != __root) {
                __w = __y.__parent_.__right_ }
            else {
                __root = __x }  // __w == nullptr
        }
        else
        {
            __y.__parent_.__right_ = __x
            // __y can't be root if it is a right child
            __w = __y.__parent_.__left_
        }
        let __removed_black = __y.__is_black_
        // If we didn't remove __z, do so now by splicing in __y for __z,
        //    but copy __z's color.  This does not impact __x or __w.
        if (__y != __z)
        {
            // __z->__left_ != nulptr but __z->__right_ might == __x == nullptr
            __y.__parent_ = __z.__parent_
            if (__tree_is_left_child(__z)) {
                __y.__parent_.__left_ = __y }
            else {
                __y.__parent_.__right_ = __y }
            __y.__left_ = __z.__left_
            __y.__left_.__parent_ = __y
            __y.__right_ = __z.__right_
            if (__y.__right_ != .nullptr) {
                __y.__right_.__parent_ = __y }
            __y.__is_black_ = __z.__is_black_
            if (__root == __z) {
                __root = __y }
        }
        // There is no need to rebalance if we removed a red, or if we removed
        //     the last node.
        if (__removed_black && __root != .nullptr)
        {
            // Rebalance:
            // __x has an implicit black color (transferred from the removed __y)
            //    associated with it, no matter what its color is.
            // If __x is __root (in which case it can't be null), it is supposed
            //    to be black anyway, and if it is doubly black, then the double
            //    can just be ignored.
            // If __x is red (in which case it can't be null), then it can absorb
            //    the implicit black just by setting its color to black.
            // Since __y was black and only had one child (which __x points to), __x
            //   is either red with no children, else null, otherwise __y would have
            //   different black heights under left and right pointers.
            // if (__x == __root || __x != nullptr && !__x->__is_black_)
            if (__x != .nullptr) {
                __x.__is_black_ = true }
            else
            {
                //  Else __x isn't root, and is "doubly black", even though it may
                //     be null.  __w can not be null here, else the parent would
                //     see a black height >= 2 on the __x side and a black height
                //     of 1 on the __w side (__w must be a non-null black or a red
                //     with a non-null black child).
                while (true)
                {
                    if (!__tree_is_left_child(__w))  // if x is left child
                    {
                        if (!__w.__is_black_)
                        {
                            __w.__is_black_ = true
                            __w.__parent_.__is_black_ = false
                            __tree_left_rotate(__w.__parent_)
                            // __x is still valid
                            // reset __root only if necessary
                            if (__root == __w.__left_) {
                                __root = __w }
                            // reset sibling, and it still can't be null
                            __w = __w.__left_.__right_
                        }
                        // __w->__is_black_ is now true, __w may have null children
                        if ((__w.__left_  == .nullptr || __w.__left_.__is_black_) &&
                            (__w.__right_ == .nullptr || __w.__right_.__is_black_))
                        {
                            __w.__is_black_ = false
                            __x = __w.__parent_
                            // __x can no longer be null
                            if (__x == __root || !__x.__is_black_)
                            {
                                __x.__is_black_ = true
                                break
                            }
                            // reset sibling, and it still can't be null
                            __w = __tree_is_left_child(__x) ?
                            __x.__parent_.__right_ :
                            __x.__parent_.__left_
                            // continue;
                        }
                        else  // __w has a red child
                        {
                            if (__w.__right_ == .nullptr || __w.__right_.__is_black_)
                            {
                                // __w left child is non-null and red
                                __w.__left_.__is_black_ = true
                                __w.__is_black_ = false
                                __tree_right_rotate(__w)
                                // __w is known not to be root, so root hasn't changed
                                // reset sibling, and it still can't be null
                                __w = __w.__parent_
                            }
                            // __w has a right red child, left child may be null
                            __w.__is_black_ = __w.__parent_.__is_black_
                            __w.__parent_.__is_black_ = true
                            __w.__right_.__is_black_ = true
                            __tree_left_rotate(__w.__parent_)
                            break
                        }
                    }
                    else
                    {
                        if (!__w.__is_black_)
                        {
                            __w.__is_black_ = true
                            __w.__parent_.__is_black_ = false
                            __tree_right_rotate(__w.__parent_)
                            // __x is still valid
                            // reset __root only if necessary
                            if (__root == __w.__right_) {
                                __root = __w }
                            // reset sibling, and it still can't be null
                            __w = __w.__right_.__left_
                        }
                        // __w->__is_black_ is now true, __w may have null children
                        if ((__w.__left_  == .nullptr || __w.__left_.__is_black_) &&
                            (__w.__right_ == .nullptr || __w.__right_.__is_black_))
                        {
                            __w.__is_black_ = false
                            __x = __w.__parent_
                            // __x can no longer be null
                            if (!__x.__is_black_ || __x == __root)
                            {
                                __x.__is_black_ = true
                                break
                            }
                            // reset sibling, and it still can't be null
                            __w = __tree_is_left_child(__x) ?
                            __x.__parent_.__right_ :
                            __x.__parent_.__left_
                            // continue;
                        }
                        else  // __w has a red child
                        {
                            if (__w.__left_ == .nullptr || __w.__left_.__is_black_)
                            {
                                // __w right child is non-null and red
                                __w.__right_.__is_black_ = true
                                __w.__is_black_ = false
                                __tree_left_rotate(__w)
                                // __w is known not to be root, so root hasn't changed
                                // reset sibling, and it still can't be null
                                __w = __w.__parent_
                            }
                            // __w has a left red child, right child may be null
                            __w.__is_black_ = __w.__parent_.__is_black_
                            __w.__parent_.__is_black_ = true
                            __w.__left_.__is_black_ = true
                            __tree_right_rotate(__w.__parent_)
                            break
                        }
                    }
                }
            }
        }
    }
}

#if false
extension __RedBlackTree {
    
    // MARK: -
    
    func __insert_unique(_ x: Element)
    where _Node: __node_base_pointer & _node_value_ptr & _node_ref_ptr,
          _Node.__node_value_type == Self.Element,
          _NodeRef: _node_base_ref,
          _NodeRef == _Node.Ref
    {
        _ = __emplace_unique_key_args(x)
    }
}
#endif

extension ___tree_clear_base {
    
    func
    clear()
    {
        destroy(__root)
        size = 0
        __begin_node = __end_node
        __end_node.__left_ = nil
    }
}

extension ___tree_find_base {
    
    func
    __find_leaf_low(_ __parent: inout _NodePtr, _ __v: Element) -> _NodeRef
    {
        var __nd: _NodePtr = __root;
        if __nd != nil {
            while true {
                if Self.value_comp(__nd.__value_, __v) {
                    if __nd.__right_ != .nullptr {
                        __nd = __nd.__right_; }
                    else {
                        __parent = __nd;
                        return __nd.__right_ref;
                    }
                } else {
                    if __nd.__left_ != .nullptr {
                        __nd = __nd.__left_; }
                    else {
                        __parent = __nd;
                        return __parent.__left_ref;
                    }
                }
            }
        }
        __parent = __end_node;
        return __parent.__left_ref;
    }
    
    func
    __find_leaf_high(_ __parent: inout _NodePtr, _ __v: Element) -> _NodeRef
    {
        var __nd: _NodePtr = __root
        if __nd != nil {
            while true
            {
                if Self.value_comp(__v, __nd.__value_)
                {
                    if __nd.__left_ != .nullptr {
                        __nd = __nd.__left_ }
                    else
                    {
                        __parent = __nd
                        return __parent.__left_ref
                    }
                }
                else
                {
                    if __nd.__right_ != .nullptr {
                        __nd = __nd.__right_ }
                    else
                    {
                        __parent = __nd
                        return __nd.__right_ref
                    }
                }
            }
        }
        __parent = __end_node
        return __parent.__left_ref
    }
}

extension ___tree_find_base {

//    func
//    __find_leaf(_ __hint: Any,_ __parent: __parent_pointer,_ __v: key_type)
//    {
//      if (__hint == end() || !value_comp()(*__hint, __v)) // check before
//      {
//        // __v <= *__hint
//        const_iterator __prior = __hint;
//        if (__prior == begin() || !value_comp()(__v, *--__prior)) {
//          // *prev(__hint) <= __v <= *__hint
//          if (__hint.__ptr_->__left_ == nullptr) {
//            __parent = static_cast<__parent_pointer>(__hint.__ptr_);
//            return __parent->__left_;
//          } else {
//            __parent = static_cast<__parent_pointer>(__prior.__ptr_);
//            return static_cast<__node_base_pointer>(__prior.__ptr_)->__right_;
//          }
//        }
//        // __v < *prev(__hint)
//        return __find_leaf_high(__parent, __v);
//      }
//      // else __v > *__hint
//      return __find_leaf_low(__parent, __v);
//    }
    
    typealias __node_pointer = _NodePtr
    typealias __node_base_pointer = _NodeRef
    typealias __parent_pointer = _NodePtr
    
    func static_cast__node_pointer(_ p:_NodePtr) -> __node_pointer { p }
    func static_cast__parent_pointer(_ p:_NodePtr) -> __parent_pointer { p }

    func
    __find_equal(_ __parent: inout _NodePtr, _ __v: Element) -> _NodeRef
    {
        var __nd: __node_pointer          = __root;
        var __nd_ptr: __node_base_pointer = __root_ptr;
        if (__nd != .nullptr) {
          while (true) {
              if (Self.value_comp(__v, __nd.__value_)) {
                  if (__nd.__left_ != .nullptr) {
                      __nd_ptr = addressof(__nd.__left_ref);
                      __nd     = static_cast__node_pointer(__nd.__left_);
              } else {
                __parent = static_cast__parent_pointer(__nd);
                  return __parent.__left_ref;
              }
              } else if (Self.value_comp(__nd.__value_, __v)) {
                  if (__nd.__right_ != .nullptr) {
                      __nd_ptr = addressof(__nd.__right_ref);
                      __nd     = static_cast__node_pointer(__nd.__right_);
              } else {
                __parent = static_cast__parent_pointer(__nd);
                  return __nd.__right_ref;
              }
            } else {
              __parent = static_cast__parent_pointer(__nd);
              return __nd_ptr;
            }
          }
        }
        __parent = static_cast__parent_pointer(__end_node);
        return __parent.__left_ref;
    }
}

extension ___tree_insert_base {

    // __find_equal(...)
    
    typealias __iter_pointer = _NodePtr
    func static_cast__iter_pointer(_ p:_NodePtr) -> __iter_pointer { p }

    func
    __insert_node_at(
        _ __parent: _NodePtr, _ __child: _NodeRef,
        _ __new_node: _NodePtr)
    {
        __new_node.__left_   = .nullptr;
        __new_node.__right_  = .nullptr;
        __new_node.__parent_ = __parent;
        // __new_node->__is_black_ is initialized in __tree_balance_after_insert
        __child.referencee = __new_node;
        if (__begin_node.__left_ != .nullptr) {
            __begin_node = static_cast__iter_pointer(__begin_node.__left_);
        }
        Self.__tree_balance_after_insert(__end_node.__left_, __child.referencee);
        size += 1
    }
}

extension ___tree_construct_base {
    
    func
    __emplace_unique_key_args(_ __k: Element) -> (iterator: __tree_iterator, __inserted: Bool)
    {
        var __parent: _NodePtr = .nullptr
        let __child    = __find_equal(&__parent, __k)
        let __r        = __child
        var __inserted = false
        if __child == .nullptr {
            let __h = __construct_node()
            __insert_node_at(__parent, __child, __h)
            __inserted = true
        }
        return (iterator(__r), __inserted)
    }
    
    // __emplace_hint_unique_key_args(...)
    
    // __construct_node(...)
    
    // __emplace_unique_impl(...)
    
    // __emplace_hint_unique_impl(...)
    
    // __emplace_multi(...)
    
    // __emplace_hint_multi(...)
    
    // __node_assign_unique(...)
    
    // __node_insert_multi(...)
    
    // __node_insert_multi(...)
    
    // __remove_node_pointer(...)
    func
    __remove_node_pointer(_ __ptr: _NodePtr)
    {
        size -= 1
        Self.__tree_remove(__end_node.__left_,
                           __ptr)
    }
    
    // __node_handle_insert_unique(...)
    
    // __node_handle_insert_unique(...)
    
    // __node_handle_extract(...)
    
    // __node_handle_extract(...)
    
    // __node_handle_merge_unique(...)
    
    // __node_handle_insert_multi(...)
    
    // __node_handle_insert_multi(...)
    
    // __node_handle_merge_multi(...)
    
    // erase(...)
    
    // erase(...)
    
    // __erase_unique(...)
    
    // __erase_multi(...)
    
    // find(...)
    
    // find(...)
    
    // __count_unique(...)
    
    // __count_multi(...)
    
    // __lower_bound(...)
    
    // __lower_bound(...)
    
}

#if false
extension __RedBlackTree where _Node: __node_base_pointer, _Node.__node_value_type == Element {
    
    func
    __lower_bound(_ __v: Element,_ __root: inout _Node,_ __result: inout _Node) -> _Node
    {
        while (__root != nil)
        {
            if (!Self.value_comp(__root.__value_, __v))
            {
                __result = __root
                __root = __root.__left_
            }
            else {
                __root = __root.__right_ }
        }
        return __result
    }
    
    // __upper_bound(...)
    
    // __upper_bound(...)
    
    func
    __upper_bound(_ __v: Element,_ __root: inout _Node,_ __result: inout _Node) -> _Node
    {
        while (__root != nil)
        {
            if (Self.value_comp(__v, __root.__value_))
            {
                __result = __root
                __root = __root.__left_
            }
            else {
                __root = __root.__right_ }
        }
        return __result
    }
    
    // __equal_range_unique(...)
    
    // __equal_range_unique(...)
    
    // __equal_range_multi(...)
    
    // __equal_range_multi(...)
    
    // remove(...)
    
    // swap(...)
}
#endif
