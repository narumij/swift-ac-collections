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

// MARK: - TreePointer

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  public var nullptr: _NodePtr {
    nil
  }
  
  @nonobjc
  @inlinable
  @inline(__always)
  public var end: _NodePtr {
    _read { yield _end_ptr }
  }
}

// MARK: - TreeEndNodeProtocol

extension UnsafeTree: TreeEndNodeProtocol {
  
  @nonobjc
  @inlinable
  @inline(__always)
  func __left_(_ p: _NodePtr) -> _NodePtr {
    return p!.pointee.__left_
  }
  
  @nonobjc
  @inlinable
  @inline(__always)
  func __left_unsafe(_ p: _NodePtr) -> _NodePtr {
    return p!.pointee.__left_
  }
  
  @nonobjc
  @inlinable
  @inline(__always)
  func __left_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    lhs!.pointee.__left_ = rhs
  }
}

// MARK: - TreeNodeProtocol

extension UnsafeTree: TreeNodeProtocol {

  @nonobjc
  @inlinable
  @inline(__always)
  func __right_(_ p: _NodePtr) -> _NodePtr {
    return p!.pointee.__right_
  }

  @nonobjc
  @inlinable
  @inline(__always)
  func __right_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    lhs!.pointee.__right_ = rhs
  }

  @nonobjc
  @inlinable
  @inline(__always)
  func __is_black_(_ p: _NodePtr) -> Bool {
    return p!.pointee.__is_black_
  }

  @nonobjc
  @inlinable
  @inline(__always)
  func __is_black_(_ lhs: _NodePtr, _ rhs: Bool) {
    lhs!.pointee.__is_black_ = rhs
  }
  
  @nonobjc
  @inlinable
  @inline(__always)
  func __parent_(_ p: _NodePtr) -> _NodePtr {
    return p!.pointee.__parent_
  }

  @nonobjc
  @inlinable
  @inline(__always)
  func __parent_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    lhs!.pointee.__parent_ = rhs
  }
  
  @nonobjc
  @inlinable
  @inline(__always)
  func __parent_unsafe(_ p: _NodePtr) -> _NodePtr {
    return p!.pointee.__parent_
  }
}

// MARK: - TreeNodeValueProtocol

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  func __get_value(_ p: _NodePtr) -> _Key {
    Base.__key(UnsafePair<_Value>.__value_ptr(p)!.pointee)
  }
}

// MARK: - BeginNodeProtocol

extension UnsafeTree {
  
  @nonobjc
  @inlinable
  @inline(__always)
  public var __begin_node_: _NodePtr {
    _read { yield _header_ptr.pointee.__begin_node_ }
    _modify { yield &_header_ptr.pointee.__begin_node_ }
  }
}

// MARK: - EndNodeProtocol

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  var __end_node: _NodePtr {
    _read { yield end }
  }
}

// MARK: - RootProtocol

extension UnsafeTree {

#if !DEBUG
  @nonobjc
  @inlinable
  @inline(__always)
  internal var __root: _NodePtr {
    _read { yield _end.__left_ }
  }
#else
  @nonobjc
  @inlinable
  @inline(__always)
  internal var __root: _NodePtr {
    get { _end.__left_ }
    set { _end.__left_ = newValue }
  }
#endif

  // MARK: - RootPtrProtocol

  @nonobjc
  @inlinable
  @inline(__always)
  internal func __root_ptr() -> _NodeRef {
    withUnsafeMutablePointer(to: &_end.__left_) { $0 }
  }
}

// MARK: - SizeProtocol

extension UnsafeTree {

  @nonobjc
  @inlinable
  var __size_: Int {
    @inline(__always)
    _read { yield count }
    set { /* NOP */  }
  }
}

// MARK: - AllocatorProtocol

extension UnsafeTree {
  
  @nonobjc
  @inlinable
  @inline(__always)
  public func __construct_node(_ k: _Value) -> _NodePtr {
    if _header.destroyCount > 0 {
      let p = _header.___popRecycle()
      UnsafePair<_Value>.__value_ptr(p)!.initialize(to: k)
      p?.pointee.___needs_deinitialize = true
      return p
    }
    assert(_header.initializedCount < freshPoolCapacity)
    let p = ___node_alloc()
    assert(p != nil)
    assert(p?.pointee.___node_id_ == -2)
    // ナンバリングとノード初期化の責務は移動できる(freshPoolUsedCountは使えない）
    p?.initialize(to: UnsafeNode(___node_id_: _header.initializedCount))
    UnsafePair<_Value>.__value_ptr(p)!.initialize(to: k)
    assert(p!.pointee.___node_id_ >= 0)
    _header.initializedCount += 1
    return p
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func destroy(_ p: _NodePtr) {
    _header.___pushRecycle(p)
  }
}

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal func __value_(_ p: _NodePtr) -> _Value {
    UnsafePair<Tree._Value>.__value_ptr(p)!.pointee
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___element(_ p: _NodePtr, _ __v: _Value) {
    UnsafePair<Tree._Value>.__value_ptr(p)!.pointee = __v
  }
}

extension UnsafeTree: ValueComparator {}
extension UnsafeTree: BoundProtocol {

  @nonobjc
  @inlinable
  @inline(__always)
  public static var isMulti: Bool {
    Base.isMulti
  }

  @nonobjc
  @inlinable
  @inline(__always)
  var isMulti: Bool {
    Base.isMulti
  }
}

extension UnsafeTree: FindProtocol {}
extension UnsafeTree: FindEqualProtocol {}
extension UnsafeTree: FindLeafProtocol {}
extension UnsafeTree: InsertNodeAtProtocol {}
extension UnsafeTree: InsertUniqueProtocol {}
extension UnsafeTree: InsertMultiProtocol {}
extension UnsafeTree: EqualProtocol {}
extension UnsafeTree: RemoveProtocol {}
extension UnsafeTree: EraseProtocol {}
extension UnsafeTree: EraseUniqueProtocol {}
extension UnsafeTree: EraseMultiProtocol {}
extension UnsafeTree: CompareBothProtocol {}
extension UnsafeTree: CountProtocol {}
extension UnsafeTree: InsertLastProtocol {}
extension UnsafeTree: CompareProtocol {}
