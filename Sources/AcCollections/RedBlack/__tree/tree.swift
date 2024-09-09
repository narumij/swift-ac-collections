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

protocol __tree_end_node {
    associatedtype pointer
    var __left_: pointer { get nonmutating set }
}

protocol __tree_node_base: __tree_end_node {
    var __right_: pointer { get nonmutating set }
    associatedtype __parent_pointer
    var __parent_: __parent_pointer { get nonmutating set }
    var __is_black_: Bool { get nonmutating set }
    func __parent_unsafe() -> __parent_pointer
}

extension __tree_node_base {
    func __set_parent(_ __p: pointer) { __parent_ = __p as! __parent_pointer }
}

protocol __tree_node: __tree_node_base {
    associatedtype __node_value_type
    var __value_: __node_value_type { get nonmutating set }
    associatedtype __node_value_ptr_type
    var pointer: __node_value_ptr_type { get }
    associatedtype __node_value_ref_type
    var reference: __node_value_ref_type { get }
}

protocol __node_base_pointer: __tree_node_base, Equatable, ExpressibleByNilLiteral
where pointer == Self, __parent_pointer == Self
{ }

protocol __node_pointer: __node_base_pointer & __tree_node { }
#if false
protocol __end_node_pointer { }
protocol __iter_pointer { }

protocol __tree_iterator: Equatable {
    associatedtype _NodePtr: __node_pointer
//    associatedtype _node_base_pointer: __node_base_pointer
//    associatedtype _end_node_pointer: __end_node_pointer
//    associatedtype _iter_pointer: __iter_pointer
//    var __ptr_: _iter_pointer { get set }
    var pointer: pointer { get }
    var reference: reference { get }
    func next()
    func prev()
}

extension __tree_iterator {
    typealias reference = _NodePtr.__node_value_ref_type
    typealias pointer = _NodePtr.__node_value_ptr_type
}

protocol __const_iterator {
    associatedtype Iteratee
    var iteratee: Iteratee { get }
}

protocol __iterator: __const_iterator {
    var iteratee: Iteratee { get nonmutating set }
}

protocol __const_ref: Equatable, ExpressibleByNilLiteral {
    associatedtype Referencee
    var referencee: Referencee { get  }
}
#endif

protocol _node_value_ptr {
    associatedtype __node_value_type
    var __value_:  __node_value_type { get }
}

protocol __ref: Equatable, ExpressibleByNilLiteral {
    associatedtype Referencee
    var referencee: Referencee { get nonmutating set }
}

protocol _node_ref_ptr {
    associatedtype    Ref: __ref
    var __self_ref:   Ref { get }
    var __parent_ref: Ref { get }
    var __left_ref:   Ref { get }
    var __right_ref:  Ref { get }
}

protocol _node_base_ref: __ref where Referencee: __node_base_pointer { }

protocol ___tree_base { }

protocol ___tree_base_with_ptr: ___tree_base
where _NodePtr: __node_pointer
{
    associatedtype _NodePtr
}

protocol ___tree_base_with_ref: ___tree_base_with_ptr
where _NodePtr: _node_ref_ptr, _NodePtr.Ref == _NodeRef, _NodePtr == _NodeRef.Referencee
{
    associatedtype _NodePtr
    associatedtype _NodeRef
}

protocol ___tree_base_with_value: ___tree_base_with_ptr
where _NodePtr: _node_value_ptr, _NodePtr.__node_value_type == Element
{
    associatedtype Element
    static var value_comp: (Element, Element) -> Bool { get }
}

protocol ___tree_base_find: ___tree_base_with_ref & ___tree_base_with_value
{
    var __root: _NodePtr { get }
    var __end_node: _NodePtr { get }
}

protocol __RedBlackTree: ___tree_base & ___tree_base_find {
    var __root_ptr: _NodePtr { get }
    var __begin_node: _NodePtr { get nonmutating set }
    func __construct_node() -> __node_holder
    func destroy(_: _NodePtr)
    var size: Int { get nonmutating set }
    associatedtype __tree_iterator
    func iterator(_ : _NodeRef) -> __tree_iterator
}

extension __RedBlackTree {
    typealias __node_holder = _NodePtr
}

extension ___tree_base {
    
    static func
    __tree_is_left_child<_NodePtr>(_ __x: _NodePtr) -> Bool
    where _NodePtr: __node_base_pointer
    {
        return __x == __x.__parent_.__left_
    }
    
    fileprivate static func
    __tree_sub_invariant<_NodePtr>(_ __x: _NodePtr) -> Int
    where _NodePtr: __node_base_pointer
    {
        if (__x == nil) {
            return 1; }
          // parent consistency checked by caller
          // check __x->__left_ consistency
        if (__x.__left_ != nil && __x.__left_.__parent_ != __x) {
            return 0; }
          // check __x->__right_ consistency
        if (__x.__right_ != nil && __x.__right_.__parent_ != __x) {
            return 0; }
          // check __x->__left_ != __x->__right_ unless both are nullptr
        if (__x.__left_ == __x.__right_ && __x.__left_ != nil) {
            return 0; }
          // If this is red, neither child can be red
        if (!__x.__is_black_) {
            if (__x.__left_ != nil && !__x.__left_.__is_black_) {
                return 0; }
            if (__x.__right_ != nil && !__x.__right_.__is_black_) {
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
    where _NodePtr: __node_base_pointer
    {
        if (__root == nil) {
            return true; }
        // check __x->__parent_ consistency
        if (__root.__parent_ == nil) {
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
    where _NodePtr: __node_base_pointer
    {
        assert(__x != nil, "Root node shouldn't be null");
        var __x = __x
        while (__x.__left_ != nil) {
            __x = __x.__left_ }
        return __x
    }
    
    static func
    __tree_max<_NodePtr>(_ __x: _NodePtr) -> _NodePtr
    where _NodePtr: __node_base_pointer
    {
        assert(__x != nil, "Root node shouldn't be null");
        var __x = __x
        while (__x.__right_ != nil) {
            __x = __x.__right_ }
        return __x
    }
    
    static func
    __tree_next<_NodePtr>(_ __x: _NodePtr) -> _NodePtr
    where _NodePtr: __node_base_pointer
    {
        assert(__x != nil, "node shouldn't be null");
        var __x = __x
        if (__x.__right_ != nil) {
            return __tree_min(__x.__right_) }
        while (!__tree_is_left_child(__x)) {
            __x = __x.__parent_ }
        return __x.__parent_
    }
    
    static func
    __tree_next_iter<_NodePtr>(_ __x: _NodePtr) -> _NodePtr
    where _NodePtr: __node_base_pointer
    {
        assert(__x != nil, "node shouldn't be null")
        if (__x.__right_ != nil) {
            return __tree_min(__x.__right_) }
        var __x: _NodePtr! = __x
        while !__tree_is_left_child(__x) {
            __x = __x.__parent_ }
        return __x.__parent_
    }
    
    static func
    __tree_prev_iter<_NodePtr>(_ __x: _NodePtr) -> _NodePtr
    where _NodePtr: __node_base_pointer
    {
        assert(__x != nil, "node shouldn't be null")
        var __x = __x
        if (__x.__left_ != nil) {
            return __tree_max(__x.__left_) }
        while __tree_is_left_child(__x) {
            __x = __x.__parent_ }
        return __x.__parent_
    }
    
    static func
    __tree_leaf<_NodePtr>(_ __x: _NodePtr) -> _NodePtr
    where _NodePtr: __node_base_pointer
    {
        assert(__x != nil, "node shouldn't be null");
        var __x = __x
        while (true)
        {
            if (__x.__left_ != nil)
            {
                __x = __x.__left_
                continue
            }
            if (__x.__right_ != nil)
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
    where _NodePtr: __node_base_pointer
    {
        assert(__x != nil, "node shouldn't be null");
        assert(__x.__right_ != nil, "node should have a right child");
        let __y = __x.__right_
        __x.__right_ = __y.__left_
        if (__x.__right_ != nil) {
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
    where _NodePtr: __node_base_pointer
    {
        assert(__x != nil, "node shouldn't be null");
        assert(__x.__left_ != nil, "node should have a left child");
        let __y = __x.__left_
        __x.__left_ = __y.__right_
        if (__x.__left_ != nil) {
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
    where _NodePtr: __node_base_pointer
    {
        assert(__root != nil, "Root of the tree shouldn't be null");
        assert(__x != nil, "Can't attach null node to a leaf");
        __x.__is_black_ = __x == __root;
        while (__x != __root && !__x.__parent_unsafe().__is_black_) {
            var __x = __x
          // __x->__parent_ != __root because __x->__parent_->__is_black == false
            if (__tree_is_left_child(__x.__parent_unsafe())) {
                let __y: _NodePtr = __x.__parent_unsafe().__parent_unsafe().__right_;
                if (__y != nil && !__y.__is_black_) {
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
                if (__y != nil && !__y.__is_black_) {
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
    where _NodePtr: __node_base_pointer
    {
        assert(__root != nil, "Root node should not be null")
        assert(__z != nil, "The node to remove should not be null")
        assert(__tree_invariant(__root), "The tree invariants should hold");
        var __root = __root
        // __z will be removed from the tree.  Client still needs to destruct/deallocate it
        // __y is either __z, or if __z has two children, __tree_next(__z).
        // __y will have at most one child.
        // __y will be the initial hole in the tree (make the hole at a leaf)
        let __y: _NodePtr! = (__z.__left_ == nil || __z.__right_ == nil) ?
        __z : __tree_next(__z)
        // __x is __y's possibly null single child
        var __x: _NodePtr! = __y.__left_ != nil ? __y.__left_ : __y.__right_
        // __w is __x's possibly null uncle (will become __x's sibling)
        var __w: _NodePtr! = nil
        // link __x to __y's parent, and find __w
        if (__x != nil) {
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
            if (__y.__right_ != nil) {
                __y.__right_.__parent_ = __y }
            __y.__is_black_ = __z.__is_black_
            if (__root == __z) {
                __root = __y }
        }
        // There is no need to rebalance if we removed a red, or if we removed
        //     the last node.
        if (__removed_black && __root != nil)
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
            if (__x != nil) {
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
                        if ((__w.__left_  == nil || __w.__left_.__is_black_) &&
                            (__w.__right_ == nil || __w.__right_.__is_black_))
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
                            if (__w.__right_ == nil || __w.__right_.__is_black_)
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
                        if ((__w.__left_  == nil || __w.__left_.__is_black_) &&
                            (__w.__right_ == nil || __w.__right_.__is_black_))
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
                            if (__w.__left_ == nil || __w.__left_.__is_black_)
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

extension __RedBlackTree {
    
    // MARK: -
    
    func __insert_unique(_ x: Element)
    where _NodePtr: __node_base_pointer & _node_value_ptr & _node_ref_ptr,
          _NodePtr.__node_value_type == Self.Element,
          _NodeRef: _node_base_ref,
          _NodeRef == _NodePtr.Ref,
          _NodeRef.Referencee == _NodePtr
    {
        _ = __emplace_unique_key_args(x)
    }
}

extension __RedBlackTree where _NodePtr: __node_base_pointer {
    
    func
    clear()
    {
        destroy(__root)
        size = 0
        __begin_node = __end_node
        __end_node.__left_ = nil
    }
}

extension ___tree_base_find {
    
    func
    __find_leaf_low(_ __parent: inout _NodePtr, _ __v: Element) -> _NodeRef
    {
        var __nd: _NodePtr = __root;
        if __nd != nil {
            while true {
                if Self.value_comp(__nd.__value_, __v) {
                    if __nd.__right_ != nil {
                        __nd = __nd.__right_; }
                    else {
                        __parent = __nd;
                        return __nd.__right_ref;
                    }
                } else {
                    if __nd.__left_ != nil {
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
}

extension ___tree_base_find {
    
    func
    __find_leaf_high(_ __parent: inout _NodePtr, _ __v: Element) -> _NodeRef
    {
        var __nd: _NodePtr! = __root
        if __nd != nil {
            while true
            {
                if Self.value_comp(__v, __nd.__value_)
                {
                    if __nd.__left_ != nil {
                        __nd = __nd.__left_ }
                    else
                    {
                        __parent = __nd
                        return __parent.__left_ref
                    }
                }
                else
                {
                    if __nd.__right_ != nil {
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

extension ___tree_base_find {

    // __find_leaf(...)
    
    func addressof(_ ptr: _NodePtr) -> _NodePtr { ptr }
    
    func
    __find_equal(_ __parent: inout _NodePtr, _ __v: Element) -> _NodeRef
    {
        var __nd    = __root;
        //        var __nd_ptr = __root_ptr;
        if (__nd != nil) {
            while (true) {
                if (Self.value_comp(__v, __nd.__value_)) {
                    if (__nd.__left_ != nil) {
                        // __nd_ptr = addressof(__nd.__left_);
                        __nd     = __nd.__left_;
                    } else {
                        __parent = __nd;
                        return __parent.__left_ref;
                    }
                } else if (Self.value_comp(__nd.__value_, __v)) {
                    if (__nd.__right_ != nil) {
                        // __nd_ptr = addressof(__nd.__right_);
                        __nd     = __nd.__right_;
                    } else {
                        __parent = __nd;
                        return __nd.__right_ref;
                    }
                } else {
                    __parent = __nd;
                    return nil;
                }
            }
        }
        __parent = __end_node;
        return __parent.__left_ref;
        
    }
}

extension __RedBlackTree {

    // __find_equal(...)
    
    func
    __insert_node_at(
        _ __parent: _NodePtr, _ __child: _NodeRef,
        _ __new_node: _NodePtr)
    {
        __new_node.__left_   = nil;
        __new_node.__right_  = nil;
        __new_node.__parent_ = __parent;
        // __new_node->__is_black_ is initialized in __tree_balance_after_insert
        __child.referencee = __new_node;
        if (__begin_node.__left_ != nil) {
            // __begin_node() = static_cast<__iter_pointer>(__begin_node()->__left_);
            __begin_node = __begin_node.__left_;
        }
        Self.__tree_balance_after_insert(__end_node.__left_, __child.referencee);
        size += 1
    }
    
//    func
//    __insert_node_at<___node_base_pointer>(
//        __parent: __parent_pointer, __child: inout ___node_base_pointer, __new_node: ___node_base_pointer)
//    where _NodePtr: __node_base_pointer,
//          ___node_base_pointer == _NodePtr,
//          __parent_pointer == _NodePtr
//    {
//        __new_node.__left_   = nil;
//        __new_node.__right_  = nil;
//        __new_node.__parent_ = __parent;
//        // __new_node->__is_black_ is initialized in __tree_balance_after_insert
//        __child = __new_node;
//        if (__begin_node.__left_ != nil) {
//            // __begin_node() = static_cast<__iter_pointer>(__begin_node()->__left_);
//            __begin_node = __begin_node.__left_;
//        }
//        Self.__tree_balance_after_insert(__end_node.__left_, __child);
//        size += 1
//    }
    
    func
    __emplace_unique_key_args(_ __k: Element) -> (iterator: __tree_iterator,__inserted: Bool)
    {
        var __parent: _NodePtr = nil
        let __child    = __find_equal(&__parent, __k)
        let __r        = __child
        var __inserted = false
        if __child == nil {
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
    where _NodePtr: __node_base_pointer
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

extension __RedBlackTree where _NodePtr: __node_base_pointer, _NodePtr.__node_value_type == Element {
    
    func
    __lower_bound(_ __v: Element,_ __root: inout _NodePtr,_ __result: inout _NodePtr) -> _NodePtr
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
    __upper_bound(_ __v: Element,_ __root: inout _NodePtr,_ __result: inout _NodePtr) -> _NodePtr
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
