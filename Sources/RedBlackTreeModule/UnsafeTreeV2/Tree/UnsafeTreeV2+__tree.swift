//
//  UnsafeTreeV2+__tree.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/05.
//

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  public var nullptr: UnsafeMutablePointer<UnsafeNode> {
    UnsafeNode.nullptr
  }

  @inlinable
  @inline(__always)
  public var end: UnsafeMutablePointer<UnsafeNode> {
    _buffer.withUnsafeMutablePointerToElements { $0 }
  }
}

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
  func __get_value(_ p: _NodePtr) -> _Key {
    Base.__key(UnsafePair<_Value>.valuePointer(p)!.pointee)
  }
}

// MARK: - BeginNodeProtocol

extension UnsafeTreeV2 {

  @inlinable
  public var __begin_node_: _NodePtr {

    @inline(__always) get {
      _buffer.withUnsafeMutablePointerToHeader {
        $0.pointee.__begin_node_
      }
    }

    @inline(__always)
    nonmutating set {
      _buffer.withUnsafeMutablePointerToHeader {
        $0.pointee.__begin_node_ = newValue
      }
    }
  }
}

// MARK: - EndNodeProtocol

extension UnsafeTreeV2 {

  @inlinable
  var __end_node: _NodePtr {
    end
  }
}

// MARK: - RootProtocol

extension UnsafeTreeV2 {

  #if !DEBUG
    @nonobjc
    @inlinable
    @inline(__always)
    internal var __root: _NodePtr {
      _buffer.withUnsafeMutablePointerToElements { $0.pointee.__left_ }
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
    withUnsafeMutablePointer(to: &end.pointee.__left_) { $0 }
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
extension UnsafeTreeV2: FindEqualProtocol {}
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
