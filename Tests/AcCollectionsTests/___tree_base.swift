import Foundation
@testable import AcCollections

extension ___tree_base {
    
    static func
    __tree_sub_invariant__<_NodePtr>(_ __x: _NodePtr) throws -> Int
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
        let __h = try __tree_sub_invariant__(__x.__left_);
        if (__h == 0) {
            return 0; } // invalid left subtree
        if (try __h != __tree_sub_invariant__(__x.__right_)) {
            return 0; }                   // invalid or different height right subtree
        return __h + (__x.__is_black_ ? 1 : 0); // return black height of this node
    }
    
    static func
    __tree_invariant__<_NodePtr>(_ __root: _NodePtr) throws -> Bool
    where _NodePtr: ___tree_node_pointer_base_protocol
    {
        if (__root == .nullptr) {
            return true; }
        // check __x->__parent_ consistency
        if (__root.__parent_ == .nullptr) {
            throw __tree_error.error(#line,__root, "check __x->__parent_ consistency"); }
        if (!__tree_is_left_child(__root)) {
            throw __tree_error.error(#line,__root,"__tree_is_not_left_child"); }
        // root must be black
        if (!__root.__is_black_) {
            throw __tree_error.error(#line,__root,"__root_is_not_black"); }
        // do normal node checks
        if try __tree_sub_invariant__(__root) == 0 {
            throw __tree_error.error(#line,__root,"__tree_sub_invariant(__root) == 0");
        }
        return true
    }
}
