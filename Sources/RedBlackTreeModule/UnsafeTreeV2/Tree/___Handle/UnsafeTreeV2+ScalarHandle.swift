
@frozen
@usableFromInline
struct UnsafeTreeV2ScalarHandle<_Key: Comparable> {
  @inlinable
  internal init(header: UnsafeMutablePointer<UnsafeTreeV2Buffer<_Value>.Header>, origin: UnsafeMutablePointer<UnsafeTreeV2Origin>) {
    self.header = header
    self.origin = origin
    self.isMulti = false
  }
  public typealias _Key = _Key
  public typealias _Value = _Key
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  @usableFromInline let header: UnsafeMutablePointer<UnsafeTreeV2Buffer<_Value>.Header>
  @usableFromInline let origin: UnsafeMutablePointer<UnsafeTreeV2Origin>
  @usableFromInline var isMulti: Bool
}

extension UnsafeTreeV2 where _Key == _Value, _Key: Comparable {
  
  @usableFromInline
  typealias Handle = UnsafeTreeV2ScalarHandle<UnsafeTreeV2<Base>._Value>
  
  @inlinable
  @inline(__always)
  internal func read<R>(_ body: (Handle) throws -> R) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, elements in
      let handle = Handle(header: header, origin: elements)
      return try body(handle)
    }
  }
  
  @inlinable
  @inline(__always)
  internal func update<R>(_ body: (Handle) throws -> R) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, elements in
      let handle = Handle(header: header, origin: elements)
      return try body(handle)
    }
  }
}

extension UnsafeTreeV2ScalarHandle {
  
  @inlinable
  @inline(__always)
  public func __key(_ __v: _Value) -> _Key { __v }
  
  @inlinable
  @inline(__always)
  public func value_comp(_ __l: _Key, _ __r: _Key) -> Bool { __l < __r }
  
  @inlinable
  @inline(__always)
  public func value_equiv(_ __l: _Key, _ __r: _Key) -> Bool { __l == __r }
  
  @inlinable
  @inline(__always)
  func __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key) -> __eager_compare_result {
    .init(__default_three_way_comparator(__lhs, __rhs))
  }
}

// MARK: - TreeNodeValueProtocol

extension UnsafeTreeV2ScalarHandle {

  @inlinable
  @inline(__always)
  func __get_value(_ p: _NodePtr) -> _Key {
    UnsafePair<_Value>.valuePointer(p)!.pointee
  }
}

extension UnsafeTreeV2ScalarHandle {
  
  @inlinable
  @inline(__always)
  public var nullptr: _NodePtr { origin.pointee.nullptr }
  
  @inlinable
  @inline(__always)
  public var end: _NodePtr { origin.pointee.end_ptr }
}

// MARK: - TreeEndNodeProtocol

extension UnsafeTreeV2ScalarHandle {
  
  public typealias _Pointer = _NodePtr
  public typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>

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

extension UnsafeTreeV2ScalarHandle: TreeNodeProtocol {

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

extension UnsafeTreeV2ScalarHandle {

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

// MARK: - BeginNodeProtocol

extension UnsafeTreeV2ScalarHandle {

  @inlinable
  public var __begin_node_: _NodePtr {

    @inline(__always) get {
      origin.pointee.begin_ptr
    }

    @inline(__always)
    nonmutating set {
      origin.pointee.begin_ptr = newValue
    }
  }
}

// MARK: - EndNodeProtocol

extension UnsafeTreeV2ScalarHandle {

  @inlinable
  var __end_node: _NodePtr { end }
}

// MARK: - RootProtocol

extension UnsafeTreeV2ScalarHandle {

  #if !DEBUG
    @nonobjc
    @inlinable
    @inline(__always)
    internal var __root: _NodePtr {
      origin.pointee.end_node.__left_
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
    withUnsafeMutablePointer(to: &origin.pointee.end_node.__left_) { $0 }
  }
}

// MARK: - SizeProtocol

extension UnsafeTreeV2ScalarHandle {

  @inlinable
  var __size_: Int {
    @inline(__always) get {
      header.pointee.count
    }
    nonmutating set {
      /* NOP */
    }
  }
}

// MARK: - AllocatorProtocol

extension UnsafeTreeV2ScalarHandle {

  @inlinable
  @inline(__always)
  public func __construct_node(_ k: _Value) -> _NodePtr {
    header.pointee.__construct_node(k)
  }

  @inlinable
  @inline(__always)
  internal func destroy(_ p: _NodePtr) {
    header.pointee.___pushRecycle(p)
  }
}

extension UnsafeTreeV2ScalarHandle {

  @inlinable
  @inline(__always)
  internal func __value_(_ p: _NodePtr) -> _Value {
    UnsafePair<_Value>.valuePointer(p)!.pointee
  }

  @inlinable
  @inline(__always)
  internal func ___element(_ p: _NodePtr, _ __v: _Value) {
    UnsafePair<_Value>.valuePointer(p)!.pointee = __v
  }
}

extension UnsafeTreeV2ScalarHandle: FindProtocol, FindEqualProtocol_old {}
extension UnsafeTreeV2ScalarHandle: FindEqualProtocol {}
extension UnsafeTreeV2ScalarHandle: InsertNodeAtProtocol {}
extension UnsafeTreeV2ScalarHandle: InsertUniqueProtocol {}
extension UnsafeTreeV2ScalarHandle: BoundProtocol {}
extension UnsafeTreeV2ScalarHandle: RemoveProtocol {}
extension UnsafeTreeV2ScalarHandle: EraseProtocol {}
extension UnsafeTreeV2ScalarHandle: EraseUniqueProtocol {}
