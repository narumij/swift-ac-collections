extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  public var nullptr: _NodePtr {
    nil
  }
}

extension UnsafeTree: TreeNodeProtocol {

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
    return
  }

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
  func __parent_(_ p: _NodePtr) -> _NodePtr {
    return p!.pointee.__parent_
  }

  @nonobjc
  @inlinable
  @inline(__always)
  func __parent_unsafe(_ p: _NodePtr) -> _NodePtr {
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
  func __is_black_(_ p: _NodePtr) -> Bool {
    return p!.pointee.__is_black_
  }

  @nonobjc
  @inlinable
  @inline(__always)
  func __is_black_(_ lhs: _NodePtr, _ rhs: Bool) {
    lhs!.pointee.__is_black_ = rhs
  }
}

extension UnsafeTree: TreeNodeRefProtocol {}

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal var __root: _NodePtr {
    _read { yield __left_ }
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func __root_ptr() -> _NodeRef {
    withUnsafeMutablePointer(to: &__left_) { $0 }
  }
}

extension UnsafeTree {

  @nonobjc
  @inlinable
  var __size_: Int {
    @inline(__always)
    _read { yield count }
    set { /* NOP */  }
  }
}

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal func __value_(_ p: _NodePtr) -> _Value {
    UnsafePair<Tree._Value>.__value_(p)!.pointee
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___element(_ p: _NodePtr, _ __v: _Value) {
    UnsafePair<Tree._Value>.__value_(p)!.pointee = __v
  }
}

extension UnsafeTree: ValueComparator {}
extension UnsafeTree: BoundProtocol {

  @nonobjc
  @inlinable
  @inline(__always)
  func __get_value(_ p: _NodePtr) -> _Key {
    Base.__key(UnsafePair<_Value>.__value_(p)!.pointee)
  }

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

  @nonobjc
  @inlinable
  @inline(__always)
  var __end_node: _NodePtr {
    _read { yield end }
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
