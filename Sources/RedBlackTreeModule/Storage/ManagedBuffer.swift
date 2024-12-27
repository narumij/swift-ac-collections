import Foundation

extension ___RedBlackTree {

  public struct ___Node_<Element> {

    @usableFromInline
    var __right_: _NodePtr
    @usableFromInline
    var __left_: _NodePtr
    @usableFromInline
    var __parent_: _NodePtr
    @usableFromInline
    var __is_black_: Bool
    @usableFromInline
    var __value_: Element

    @inlinable
    init(
      __is_black_: Bool = false,
      __left_: _NodePtr = .nullptr,
      __right_: _NodePtr = .nullptr,
      __parent_: _NodePtr = .nullptr,
      __value_: Element
    ) {
      self.__right_ = __right_
      self.__left_ = __left_
      self.__parent_ = __parent_
      self.__is_black_ = __is_black_
      self.__value_ = __value_
    }
  }
}

extension ___RedBlackTree {

  @usableFromInline
  class ___Storage<VC,Element>: ManagedBuffer<
    ___RedBlackTree.___Storage<VC,Element>.Header, ___RedBlackTree.___Node_<Element>
  >
  where Element: Comparable, VC: ValueComparer, Element == VC.Element
  {
    @usableFromInline
    static var empty: Storage { create(withCapacity: 0) }

    @inlinable
    deinit {
      self.withUnsafeMutablePointers { header, elements in
        elements.deinitialize(count: header.pointee.___initialized_count)
        header.deinitialize(count: 1)
      }
    }
  }
}

extension ___RedBlackTree.___Storage {

  @usableFromInline
  typealias Storage = ___RedBlackTree.___Storage<VC,Element>

  @usableFromInline
  typealias Component = ___RedBlackTree.___Node_<Element>

  @usableFromInline
  typealias Manager = ManagedBufferPointer<Header, Component>
}

extension ___RedBlackTree.___Storage {

  @usableFromInline
  struct Header {

    @inlinable
    init(
      capacity: Int,
      __left_: _NodePtr,
      __begin_node: _NodePtr,
      __initialized_count: Int,
      __destroy_count: Int,
      __destroy_node: _NodePtr
    ) {
      self.capacity = capacity
      self.__left_ = __left_
      self.__begin_node = __begin_node
      self.___initialized_count = __initialized_count
      self.___destroy_count = __destroy_count
      self.___destroy_node = __destroy_node
    }

    @usableFromInline
    var capacity: Int

    @usableFromInline
    var __left_: _NodePtr = .nullptr

    @usableFromInline
    var __begin_node: _NodePtr = .end

    @usableFromInline
    var ___initialized_count: Int

    @usableFromInline
    var ___destroy_count: Int

    @usableFromInline
    var ___destroy_node: _NodePtr = .end
  }
}

extension ___RedBlackTree.___Storage.Header {
}

extension ___RedBlackTree.___Storage {

  @inlinable
  var __header_ptr: UnsafeMutablePointer<Header> {
    withUnsafeMutablePointerToHeader({ $0 })
  }

  @inlinable
  var __node_ptr: UnsafeMutablePointer<Component> {
    withUnsafeMutablePointerToElements({ $0 })
  }

  @inlinable
  subscript(pointer: _NodePtr) -> Component {
    get {
      assert(0 <= pointer && pointer < ___initialized_count)
      return __node_ptr[pointer]
    }
    _modify {
      assert(0 <= pointer && pointer < ___initialized_count)
      yield &__node_ptr[pointer]
    }
  }
}

extension ___RedBlackTree.___Storage {
  
  @inlinable
  func ___pushDestroy(_ p: _NodePtr) {
    assert(___destroy_count < capacity)
    assert(___destroy_node != p)
    __node_ptr[p].__right_ = ___destroy_node
    __node_ptr[p].__left_ = p
    ___destroy_node = p
    ___destroy_count += 1
  }
  @inlinable
  func ___popDetroy() -> _NodePtr {
    assert(___destroy_count > 0)
    let p = __node_ptr[___destroy_node].__left_
    ___destroy_node = __node_ptr[p].__right_
    ___destroy_count -= 1
    return p
  }
  @inlinable
  func ___clearDestroy() {
    ___destroy_node = .nullptr
    ___destroy_count = 0
  }
  var ___destroyNodes: [_NodePtr] {
    if ___destroy_node == .nullptr {
      return []
    }
    var nodes: [_NodePtr] = [___destroy_node]
    while let l = nodes.last, self[l].__right_ != .nullptr {
      nodes.append(self[l].__right_)
    }
    return nodes
  }
  
  @inlinable
  func clear() {
    __begin_node = .nullptr
    __left_ = .nullptr
    ___clearDestroy()
  }
}

extension ___RedBlackTree.___Storage {
  
  @inlinable
  var count: Int {
    __header_ptr.pointee.___initialized_count - __header_ptr.pointee.___destroy_count
  }
  
  @inlinable
  var ___initialized_count: Int {
    get { __header_ptr.pointee.___initialized_count }
    _modify { yield &__header_ptr.pointee.___initialized_count }
  }
  
  @inlinable
  var ___destroy_count: Int {
    get { __header_ptr.pointee.___destroy_count }
    _modify { yield &__header_ptr.pointee.___destroy_count }
  }
  
  @inlinable
  var ___destroy_node: _NodePtr {
    get { __header_ptr.pointee.___destroy_node }
    _modify { yield &__header_ptr.pointee.___destroy_node }
  }
  
  @inlinable
  var size: Int {
    get { count }
    set { /* NOP */ }
  }
  
  @inlinable
  var __left_: _NodePtr {
    get { __header_ptr.pointee.__left_ }
    _modify { yield &__header_ptr.pointee.__left_ }
  }
  
  @inlinable
  var __begin_node: _NodePtr {
    get { __header_ptr.pointee.__begin_node }
    _modify { yield &__header_ptr.pointee.__begin_node }
  }
  
  @inlinable @inline(__always)
  func ___is_valid(_ p: _NodePtr) -> Bool {
    __node_ptr[p].__parent_ != .nullptr
  }
  
  @inlinable @inline(__always)
  func ___invalidate(_ p: _NodePtr) {
    __node_ptr[p].__parent_ = .nullptr
  }
}

extension ___RedBlackTree.___Storage {

  @inlinable
  func __construct_node(_ k: Element) -> _NodePtr {
    if ___destroy_count > 0 {
      return ___popDetroy()
    }
    let index = count
    (__node_ptr + index).initialize(to: .init(__value_: k))
    ___initialized_count += 1
    return index
  }
  
  @inlinable
  func destroy(_ p: _NodePtr) {
    ___invalidate(p)
    ___pushDestroy(p)
  }
}

extension ___RedBlackTree.___Storage {
  
  @inlinable @inline(__always)
  func __value_(_ p: _NodePtr) -> _Key {
    __value_(__node_ptr[p].__value_)
  }
}

extension ___RedBlackTree.___Storage: ___UnsafeHandleBase { }
extension ___RedBlackTree.___Storage: NodeFindProtocol & NodeFindEqualProtocol & FindLeafProtocol {}
extension ___RedBlackTree.___Storage: EqualProtocol {}
extension ___RedBlackTree.___Storage: InsertNodeAtProtocol {}
extension ___RedBlackTree.___Storage: RemoveProtocol {}
extension ___RedBlackTree.___Storage: StorageEraseProtocol {}
extension ___RedBlackTree.___Storage: InsertUniqueProtocol2 {
  @inlinable
  static func __key(_ e: VC.Element) -> VC._Key {
    VC.__key(e)
  }
}

extension ___RedBlackTree.___Storage: MemberProtocol & RootImpl & RefSetImpl & RootPtrImpl {
  @inlinable
  @inline(__always)
  func __parent_(_ p: _NodePtr) -> _NodePtr {
    __node_ptr[p].__parent_
  }
  @inlinable
  @inline(__always)
  func __left_(_ p: _NodePtr) -> _NodePtr {
    p == .end ? __left_ : __node_ptr[p].__left_
  }
  @inlinable
  @inline(__always)
  func __right_(_ p: _NodePtr) -> _NodePtr {
    __node_ptr[p].__right_
  }
  @inlinable
  @inline(__always)
  func __is_black_(_ p: _NodePtr) -> Bool {
    __node_ptr[p].__is_black_
  }
  @inlinable
  @inline(__always)
  func __parent_unsafe(_ p: _NodePtr) -> _NodePtr {
    __parent_(p)
  }
}

extension ___RedBlackTree.___Storage {
  
  @inlinable
  func __is_black_(_ lhs: _NodePtr, _ rhs: Bool) {
    __node_ptr[lhs].__is_black_ = rhs
  }
  @inlinable
  func __parent_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    __node_ptr[lhs].__parent_ = rhs
  }
  @inlinable
  func __left_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    if lhs == .end {
      __left_ = rhs
    } else {
      __node_ptr[lhs].__left_ = rhs
    }
  }
  @inlinable
  func __right_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    __node_ptr[lhs].__right_ = rhs
  }
}

extension ___RedBlackTree.___Storage {
  
  @inlinable
  func ___erase_unique(_ __k: VC._Key) -> Bool {
    let __i = find(__k)
    if __i == end() {
      return false
    }
    _ = erase(__i)
    return true
  }
}

extension ___RedBlackTree.___Storage {

  @inlinable @inline(__always)
  internal static func create(
    withCapacity capacity: Int
  ) -> Storage {

    let storage = Storage.create(minimumCapacity: capacity) { _ in
      Header(
        capacity: capacity,
        __left_: .nullptr,
        __begin_node: .end,
        __initialized_count: 0,
        __destroy_count: 0,
        __destroy_node: .nullptr)
    }

    return unsafeDowncast(storage, to: Storage.self)
  }

  @inlinable
  @inline(__always)
  internal func copy(newCapacity: Int? = nil) -> Storage {
    let capacity = newCapacity ?? self.header.capacity
    let __left_ = self.header.__left_
    let __begin_node = self.header.__begin_node
    let __initialized_count = self.header.___initialized_count
    let __destroy_count = self.header.___destroy_count
    let __destroy_node = self.header.___destroy_node

    let newStorage = Storage.create(withCapacity: capacity)

    newStorage.header.__left_ = __left_
    newStorage.header.__begin_node = __begin_node
    newStorage.header.___initialized_count = __initialized_count
    newStorage.header.___destroy_count = __destroy_count
    newStorage.header.___destroy_node = __destroy_node

    self.withUnsafeMutablePointerToElements { oldNodes in
      newStorage.withUnsafeMutablePointerToElements { newNodes in
        newNodes.initialize(from: oldNodes, count: __initialized_count)
      }
    }

    return newStorage
  }
}

#if false
extension ___RedBlackTree.___Storage {

  @usableFromInline
  internal struct UnsafeHandle {

    @inlinable
    @inline(__always)
    internal init(
      __header_ptr: UnsafeMutablePointer<Header>,
      __node_ptr: UnsafeMutablePointer<Component>
    ) {
      self.__header_ptr = __header_ptr
      self.__node_ptr = __node_ptr
    }

    @usableFromInline
    internal let __header_ptr: UnsafeMutablePointer<Header>

    @usableFromInline
    internal let __node_ptr: UnsafeMutablePointer<Component>
  }
}

extension ___RedBlackTree.___Storage.UnsafeHandle: ___UnsafeHandleBase {}
extension ___RedBlackTree.___Storage.UnsafeHandle: RefSetImpl & RootImpl & RootPtrImpl {}
extension ___RedBlackTree.___Storage.UnsafeHandle: NodeFindProtocol & NodeFindEqualProtocol & FindLeafProtocol {}
extension ___RedBlackTree.___Storage.UnsafeHandle: EqualProtocol {}
extension ___RedBlackTree.___Storage.UnsafeHandle: InsertNodeAtProtocol {}
extension ___RedBlackTree.___Storage.UnsafeHandle: RemoveProtocol {}
extension ___RedBlackTree.___Storage.UnsafeHandle: EraseProtocol {}

extension ___RedBlackTree.___Storage.UnsafeHandle {
  
  @inlinable @inline(__always)
  func __value_(_ p: _NodePtr) -> _Key {
    __value_(__node_ptr[p].__value_)
  }
}

extension ___RedBlackTree.___Storage.UnsafeHandle {
  
  @inlinable @inline(__always)
  func ___element(_ p: _NodePtr) -> Element {
    __node_ptr[p].__value_
  }
}

extension ___RedBlackTree.___Storage.UnsafeHandle {

  @inlinable
  var __left_: _NodePtr {
    @inline(__always) get { __header_ptr.pointee.__left_ }
    nonmutating set { __header_ptr.pointee.__left_ = newValue }
  }

  @inlinable
  var __begin_node: _NodePtr {
    @inline(__always) get { __header_ptr.pointee.__begin_node }
    nonmutating set { __header_ptr.pointee.__begin_node = newValue }
  }

  @inlinable
  var size: Int {
    @inline(__always) get { __header_ptr.pointee.count }
    nonmutating set { __header_ptr.pointee.count = newValue }
  }
}

extension ___RedBlackTree.___Storage.UnsafeHandle {

  @inlinable
  @inline(__always)
  func __parent_(_ p: _NodePtr) -> _NodePtr {
    __node_ptr[p].__parent_
  }
  @inlinable
  @inline(__always)
  func __left_(_ p: _NodePtr) -> _NodePtr {
    p == .end ? __left_ : __node_ptr[p].__left_
  }
  @inlinable
  @inline(__always)
  func __right_(_ p: _NodePtr) -> _NodePtr {
    __node_ptr[p].__right_
  }
  @inlinable
  @inline(__always)
  func __is_black_(_ p: _NodePtr) -> Bool {
    __node_ptr[p].__is_black_
  }
  @inlinable
  @inline(__always)
  func __parent_unsafe(_ p: _NodePtr) -> _NodePtr {
    __parent_(p)
  }
}

extension ___RedBlackTree.___Storage.UnsafeHandle {

  @inlinable
  func __is_black_(_ lhs: _NodePtr, _ rhs: Bool) {
    __node_ptr[lhs].__is_black_ = rhs
  }
  @inlinable
  func __parent_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    __node_ptr[lhs].__parent_ = rhs
  }
  @inlinable
  func __left_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    if lhs == .end {
      __left_ = rhs
    } else {
      __node_ptr[lhs].__left_ = rhs
    }
  }
  @inlinable
  func __right_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    __node_ptr[lhs].__right_ = rhs
  }
}
#endif
