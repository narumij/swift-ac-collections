// Copyright 2024-2026 narumij
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

// MARK: - TreeEndNodeProtocol

extension UnsafeTreeV2: TreeEndNodeProtocol {

  @inlinable
  @inline(__always)
  func __left_(_ p: _NodePtr) -> _NodePtr {
    return p.pointee.__left_
  }

  @inlinable
  @inline(__always)
  func __left_unsafe(_ p: _NodePtr) -> _NodePtr {
    return p.pointee.__left_
  }

  @inlinable
  @inline(__always)
  func __left_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    lhs.pointee.__left_ = rhs
  }
}

// MARK: - TreeNodeProtocol

extension UnsafeTreeV2: TreeNodeProtocol {

  @inlinable
  @inline(__always)
  func __right_(_ p: _NodePtr) -> _NodePtr {
    return p.pointee.__right_
  }

  @inlinable
  @inline(__always)
  func __right_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    lhs.pointee.__right_ = rhs
  }

  @inlinable
  @inline(__always)
  func __is_black_(_ p: _NodePtr) -> Bool {
    return p.pointee.__is_black_
  }

  @inlinable
  @inline(__always)
  func __is_black_(_ lhs: _NodePtr, _ rhs: Bool) {
    lhs.pointee.__is_black_ = rhs
  }

  @inlinable
  @inline(__always)
  func __parent_(_ p: _NodePtr) -> _NodePtr {
    return p.pointee.__parent_
  }

  @inlinable
  @inline(__always)
  func __parent_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    lhs.pointee.__parent_ = rhs
  }

  @inlinable
  @inline(__always)
  func __parent_unsafe(_ p: _NodePtr) -> _NodePtr {
    return p.pointee.__parent_
  }
}

// MARK: -

extension UnsafeTreeV2: TreeNodeRefProtocol {

  @inlinable
  @inline(__always)
  func __left_ref(_ p: _NodePtr) -> _NodeRef {
    return withUnsafeMutablePointer(to: &p.pointee.__left_) { $0 }
  }

  @inlinable
  @inline(__always)
  func __right_ref(_ p: _NodePtr) -> _NodeRef {
    return withUnsafeMutablePointer(to: &p.pointee.__right_) { $0 }
  }

  @inlinable
  @inline(__always)
  public func __ptr_(_ rhs: _NodeRef) -> _NodePtr {
    rhs.pointee
  }

  @inlinable
  @inline(__always)
  func __ptr_(_ lhs: _NodeRef, _ rhs: _NodePtr) {
    lhs.pointee = rhs
  }
}

// MARK: - TreeNodeValueProtocol

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  func __get_value(_ p: _NodePtr) -> K {
    Base.__key(UnsafePair<_Value>.valuePointer(p)!.pointee)
  }
}

// MARK: - BeginNodeProtocol

extension UnsafeTreeV2 {

  @inlinable
  public var __begin_node_: _NodePtr {

    @inline(__always) get {
      _buffer.withUnsafeMutablePointerToElements { $0.pointee.begin_ptr }
    }

    @inline(__always)
    nonmutating set {
      _buffer.withUnsafeMutablePointerToElements { $0.pointee.begin_ptr = newValue }
    }
  }
}

// MARK: - EndNodeProtocol

extension UnsafeTreeV2 {

  @inlinable
  var __end_node: _NodePtr {
    end
//    _buffer.withUnsafeMutablePointerToElements { $0.pointee.end_ptr }
  }
}

// MARK: - RootProtocol

extension UnsafeTreeV2 {

  #if !DEBUG
    @nonobjc
    @inlinable
    @inline(__always)
    internal var __root: _NodePtr {
      _buffer.withUnsafeMutablePointerToElements { $0.pointee.end_node.__left_ }
    }
  #else
    @inlinable
    @inline(__always)
    internal var __root: _NodePtr {
      get { end.pointee.__left_ }
      set { end.pointee.__left_ = newValue }
    }
  #endif

  // MARK: - RootPtrProtocol

  @inlinable
  @inline(__always)
  internal func __root_ptr() -> _NodeRef {
    _buffer.withUnsafeMutablePointerToElements {
      withUnsafeMutablePointer(to: &$0.pointee.end_node.__left_) { $0 }
    }
  }
}

// MARK: - SizeProtocol

extension UnsafeTreeV2 {

  @inlinable
  var __size_: Int {
    @inline(__always) get {
      _buffer.withUnsafeMutablePointerToHeader { $0.pointee.count }
    }    
    nonmutating set {
      /* NOP */
    }
  }
}

// MARK: - AllocatorProtocol

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  public func __construct_node(_ k: _Value) -> _NodePtr {
    _buffer.withUnsafeMutablePointerToHeader { header in
      header.pointee.__construct_node(k)
    }
  }

  @inlinable
  @inline(__always)
  internal func destroy(_ p: _NodePtr) {
    _buffer.withUnsafeMutablePointerToHeader {
      $0.pointee.___pushRecycle(p)
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func __value_(_ p: _NodePtr) -> _Value {
    UnsafePair<Tree._Value>.valuePointer(p)!.pointee
  }

  @inlinable
  @inline(__always)
  internal func ___element(_ p: _NodePtr, _ __v: _Value) {
    UnsafePair<Tree._Value>.valuePointer(p)!.pointee = __v
  }
}

extension UnsafeTreeV2: ValueComparator {}
extension UnsafeTreeV2: BoundProtocol {

  @inlinable
  @inline(__always)
  public static var isMulti: Bool {
    Base.isMulti
  }

  @inlinable
  @inline(__always)
  var isMulti: Bool {
    Base.isMulti
  }
}

extension UnsafeTreeV2: FindProtocol {}
extension UnsafeTreeV2: FindEqualProtocol, FindEqualProtocol_std {}
extension UnsafeTreeV2: FindLeafProtocol {}
extension UnsafeTreeV2: InsertNodeAtProtocol {}
extension UnsafeTreeV2: InsertUniqueProtocol {}
extension UnsafeTreeV2: InsertMultiProtocol {}
extension UnsafeTreeV2: EqualProtocol {}
extension UnsafeTreeV2: RemoveProtocol {}
extension UnsafeTreeV2: EraseProtocol {}
extension UnsafeTreeV2: EraseUniqueProtocol {}
extension UnsafeTreeV2: EraseMultiProtocol {}
extension UnsafeTreeV2: CompareBothProtocol {}
extension UnsafeTreeV2: CountProtocol {}
extension UnsafeTreeV2: InsertLastProtocol {}
extension UnsafeTreeV2: CompareProtocol {}

extension UnsafeTreeV2 {
  
//  @inlinable
//  @inline(__always)
//  func __comp(_ __lhs: _Key, _ __rhs: _Key)
//  -> __compare_result where C == __eager_compare_result {
//    Base.__lazy_synth_three_way_comparator(__lhs, __rhs)
////    __eager_compare_result(__default_three_way_comparator(__lhs, __rhs))
//  }
  
//  @inlinable
//  @inline(__always)
//  internal func
//    __lazy_synth_three_way_comparator(_ __lhs: Base._Key, _ __rhs: Base._Key)
//    -> Base.__compare_result
//  {
//    Base.__lazy_synth_three_way_comparator(__lhs, __rhs)
//  }
}

//extension UnsafeTreeV2 {
//  
//  @inlinable
//  @inline(__always)
//  func
//  __find_equal(_ __v: _Key) -> (__parent: _NodePtr, __child: _NodeRef)
//  {
//    var __parent: _NodePtr = end
//    var __nd = __root
//    var __nd_ptr = __root_ptr()
//    if __nd != nullptr {
//      while true {
//        if value_comp(__v, __get_value(__nd)) {
//          if __left_unsafe(__nd) != nullptr {
//            __nd_ptr = __left_ref(__nd)
//            __nd = __left_unsafe(__nd)
//          } else {
//            __parent = __nd
//            return (__parent, __left_ref(__parent))
//          }
//        } else if value_comp(__get_value(__nd), __v) {
//          if __right_(__nd) != nullptr {
//            __nd_ptr = __right_ref(__nd)
//            __nd = __right_(__nd)
//          } else {
//            __parent = __nd
//            return (__parent,__right_ref(__nd))
//          }
//        } else {
//          __parent = __nd
//          return (__parent,__nd_ptr)
//        }
//      }
//    }
//    __parent = __end_node
//    return (__parent, __left_ref(__parent))
//  }
//}

extension UnsafeTreeV2 {
  
  @inlinable
  @inline(__always)
  internal func
    __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key)
    -> __compare_result
  {
//    Base.__lazy_synth_three_way_comparator(__lhs, __rhs)
    __comp(__lhs, __rhs)
  }
  
  @inlinable
  @inline(__always)
  internal func
  __comp(_ __lhs: _Key, _ __rhs: _Key)
    -> __compare_result
  {
    let res = if value_comp(__lhs, __rhs) {
      -1
    } else if value_comp(__rhs, __lhs)  {
      1
    } else {
      0
    }
    return __eager_compare_result(res)
  }
  
//  @inlinable
//  @inline(__always)
//  internal func
//    __find_equal(_ __v: _Key) -> (__parent: _NodePtr, __child: _NodeRef)
//  {
//    var __nd = __root
//    if __nd == nullptr {
//      return (__end_node, __left_ref(end))
//    }
//    var __nd_ptr = __root_ptr()
////    let __comp = __lazy_synth_three_way_comparator
//
//    while true {
//
//      let __comp_res = __comp(__v, __get_value(__nd))
//
//      if __comp_res.__less() {
//        if __left_unsafe(__nd) == nullptr {
//          return (__nd, __left_ref(__nd))
//        }
//
//        __nd_ptr = __left_ref(__nd)
//        __nd = __left_unsafe(__nd)
//      } else if __comp_res.__greater() {
//        if __right_(__nd) == nullptr {
//          return (__nd, __right_ref(__nd))
//        }
//
//        __nd_ptr = __right_ref(__nd)
//        __nd = __right_(__nd)
//      } else {
//        return (__nd, __nd_ptr)
//      }
//    }
//  }
}
