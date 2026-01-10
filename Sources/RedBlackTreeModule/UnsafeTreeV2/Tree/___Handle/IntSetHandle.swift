@usableFromInline
struct IntSetHandle {
  @inlinable
  internal init(header: UnsafeMutableRawPointer, origin: UnsafeMutablePointer<UnsafeTreeV2Origin>) {
    self.header = header.assumingMemoryBound(to: UnsafeTreeV2Buffer<Int>.Header.self)
    self.origin = origin
  }
  public typealias _Key = Int
  public typealias _Value = _Key
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  public typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
  public typealias _Pointer = _NodePtr
  @usableFromInline let header: UnsafeMutablePointer<UnsafeTreeV2Buffer<_Value>.Header>
  @usableFromInline let origin: UnsafeMutablePointer<UnsafeTreeV2Origin>
}

extension IntSetHandle {
  
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

extension IntSetHandle {

  @inlinable
  @inline(__always)
  func __get_value(_ p: _NodePtr) -> _Key {
//    __key(UnsafePair<_Value>.valuePointer(p)!.pointee)
    UnsafePair<_Value>.valuePointer(p)!.pointee
  }
}

extension IntSetHandle: TreeNodeProtocol & UnsafeTreeHandleBase { }

//extension IntSetHandle: FindEqualProtocol, FindEqualProtocol_old {}
extension IntSetHandle: InsertNodeAtProtocol {}
//extension IntSetHandle: InsertUniqueProtocol {}

extension IntSetHandle: CompareTrait {
  @inlinable
  @inline(__always)
  static var isMulti: Bool { false }
}
extension IntSetHandle: BoundProtocol {}

extension IntSetHandle: FindProtocol {}
extension IntSetHandle: RemoveProtocol {}
extension IntSetHandle: EraseProtocol {}
extension IntSetHandle: EraseUniqueProtocol {}

extension UnsafeTreeV2 {
  
  @inlinable
  @inline(__always)
  internal func updateWithInt<R>(_ body: (IntSetHandle) throws -> R) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, elements in
      let handle = IntSetHandle(header: header, origin: elements)
      return try body(handle)
    }
  }
}

extension IntSetHandle {

  @inlinable
  @inline(__always)
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
  
  @inlinable
  @inline(__always)
  internal func
    __insert_unique(_ x: _Value) -> (__r: _NodePtr, __inserted: Bool)
  {
    __emplace_unique_key_args(x)
  }

  #if true
    @inlinable
    @inline(__always)
    internal func
      __emplace_unique_key_args(_ __k: _Value)
      -> (__r: _NodePtr, __inserted: Bool)
    {
      let (__parent, __child) = __find_equal(__key(__k))
      let __r = __child
      if __ptr_(__child) == nullptr {
        let __h = __construct_node(__k)
        __insert_node_at(__parent, __child, __h)
        return (__h, true)
      } else {
        // __insert_node_atで挿入した場合、__rが破損する
        // 既存コードの後続で使用しているのが実質Ptrなので、そちらを返すよう一旦修正
        // 今回初めて破損したrefを使用したようで既存コードでの破損ref使用は大丈夫そう
        return (__ptr_(__r), false)
      }
    }
  #else
    @inlinable
    internal func
      __emplace_unique_key_args(_ __k: _Value)
      -> (__r: _NodeRef, __inserted: Bool)
    {
      var __parent = _NodePtr.nullptr
      let __child = __find_equal(&__parent, __key(__k))
      let __r = __child
      var __inserted = false
      if __ref_(__child) == .nullptr {
        let __h = __construct_node(__k)
        __insert_node_at(__parent, __child, __h)
        __inserted = true
      }
      return (__r, __inserted)
    }
  #endif
}
