
@usableFromInline
struct UnsafeTreeV2ScalarHandle<_Key: Comparable> {
  @inlinable
  internal init(header: UnsafeMutablePointer<UnsafeTreeV2Buffer<_Key>.Header>, origin: UnsafeMutablePointer<UnsafeTreeV2Origin>) {
    self.header = header
    self.origin = origin
  }
  public typealias _Key = _Key
  public typealias _Value = _Key
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  @usableFromInline let header: UnsafeMutablePointer<UnsafeTreeV2Buffer<_Key>.Header>
  @usableFromInline let origin: UnsafeMutablePointer<UnsafeTreeV2Origin>
}

extension UnsafeTreeV2ScalarHandle: UnsafeTreeHandleBase { }

@usableFromInline
protocol UnsafeTreeHandleBase {
  associatedtype _Key
  associatedtype _Value
  var header: UnsafeMutablePointer<UnsafeTreeV2Buffer<_Value>.Header> { get }
  var origin: UnsafeMutablePointer<UnsafeTreeV2Origin> { get }
}

extension UnsafeTreeV2 where _Key == _Value, _Key: Comparable {
  
  @inlinable
  @inline(__always)
  internal func
    __insert_unique_(_ x: _Value) -> (__r: _NodePtr, __inserted: Bool)
  {
    _buffer.withUnsafeMutablePointers { header, origin in
      Handle(header: header, origin: origin).__insert_unique(x)
    }
  }
  
  @inlinable
  @inline(__always)
  internal func ___erase_unique_(_ __k: _Key) -> Bool {
    _buffer.withUnsafeMutablePointers { header, origin in
      Handle(header: header, origin: origin).___erase_unique(__k)
    }
  }
  
  @usableFromInline
  typealias Handle = UnsafeTreeV2ScalarHandle<UnsafeTreeV2<Base>._Value>
  
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
    __key(UnsafePair<_Value>.valuePointer(p)!.pointee)
  }
}

extension UnsafeTreeHandleBase {
  
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

  @inlinable
  @inline(__always)
  public var nullptr: _NodePtr { origin.pointee.nullptr }
  
  @inlinable
  @inline(__always)
  public var end: _NodePtr { origin.pointee.end_ptr }
}

// MARK: - TreeEndNodeProtocol

extension UnsafeTreeHandleBase {
  
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

extension UnsafeTreeHandleBase {

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

extension UnsafeTreeHandleBase {

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

extension UnsafeTreeHandleBase {

  @inlinable
  var __end_node: _NodePtr {
    end
//    _buffer.withUnsafeMutablePointerToElements { $0.pointee.end_ptr }
  }
}

// MARK: - RootProtocol

extension UnsafeTreeHandleBase {

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

extension UnsafeTreeHandleBase {

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

extension UnsafeTreeHandleBase {

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

extension UnsafeTreeHandleBase {

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

extension UnsafeTreeV2ScalarHandle: FindEqualProtocol {}
extension UnsafeTreeV2ScalarHandle: InsertNodeAtProtocol {}
extension UnsafeTreeV2ScalarHandle: InsertUniqueProtocol {}

extension UnsafeTreeV2ScalarHandle: CompareTrait {
  @inlinable
  @inline(__always)
  static var isMulti: Bool { false }
}
extension UnsafeTreeV2ScalarHandle: BoundProtocol {}

extension UnsafeTreeV2ScalarHandle: FindProtocol {}
extension UnsafeTreeV2ScalarHandle: RemoveProtocol {}
extension UnsafeTreeV2ScalarHandle: EraseProtocol {}
extension UnsafeTreeV2ScalarHandle: EraseUniqueProtocol {}

extension UnsafeTreeV2ScalarHandle {

  @inlinable
  @inline(never)
  func
  __find_equal(_ __v: _Key) -> (__parent: _NodePtr, __child: _NodeRef)
  {
    var __parent: _NodePtr = end
    var __nd = __root
    var __nd_ptr = __root_ptr()
    if __nd != nullptr {
      while true {
        if value_comp(__v, __get_value(__nd)) {
          if __left_unsafe(__nd) != nullptr {
            __nd_ptr = __left_ref(__nd)
            __nd = __left_unsafe(__nd)
          } else {
            __parent = __nd
            return (__parent, __left_ref(__parent))
          }
        } else if value_comp(__get_value(__nd), __v) {
          if __right_(__nd) != nullptr {
            __nd_ptr = __right_ref(__nd)
            __nd = __right_(__nd)
          } else {
            __parent = __nd
            return (__parent,__right_ref(__nd))
          }
        } else {
          __parent = __nd
          return (__parent,__nd_ptr)
        }
      }
    }
    __parent = __end_node
    return (__parent, __left_ref(__parent))
  }
}
