import Foundation

extension ___RedBlackTree {

  @usableFromInline
  class ___Buffer<VC, Element>: ManagedBuffer<
    ___RedBlackTree.___Buffer<VC, Element>.Header,
    ___RedBlackTree.___Buffer<VC, Element>.Node
  >
  where Element: Comparable, VC: ValueComparer, Element == VC.Element
  {
    
    @usableFromInline
    static var empty: Buffer { create(withCapacity: 0) }

    @inlinable
    deinit {
      self.withUnsafeMutablePointers { header, elements in
        elements.deinitialize(count: header.pointee.initializedCount)
        header.deinitialize(count: 1)
      }
    }
  }
}

extension ___RedBlackTree.___Buffer {

  public struct Node {

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

extension ___RedBlackTree.___Buffer {

  @usableFromInline
  typealias Buffer = ___RedBlackTree.___Buffer<VC, Element>

  @usableFromInline
  typealias Manager = ManagedBufferPointer<Header, Node>
}

extension ___RedBlackTree.___Buffer {

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
      self.initializedCount = __initialized_count
      self.destroyCount = __destroy_count
      self.destroyNode = __destroy_node
    }

    @usableFromInline
    var capacity: Int

    @usableFromInline
    var __left_: _NodePtr = .nullptr

    @usableFromInline
    var __begin_node: _NodePtr = .end

    @usableFromInline
    var initializedCount: Int

    @usableFromInline
    var destroyCount: Int

    @usableFromInline
    var destroyNode: _NodePtr = .end
  }
}

extension ___RedBlackTree.___Buffer.Header {
}

extension ___RedBlackTree.___Buffer {

  @inlinable
  var __header_ptr: UnsafeMutablePointer<Header> {
    withUnsafeMutablePointerToHeader({ $0 })
  }

  @inlinable
  var __node_ptr: UnsafeMutablePointer<Node> {
    withUnsafeMutablePointerToElements({ $0 })
  }

  @inlinable
  subscript(pointer: _NodePtr) -> Node {
    get {
      assert(0 <= pointer && pointer < header.initializedCount)
      return __node_ptr[pointer]
    }
    _modify {
      assert(0 <= pointer && pointer < header.initializedCount)
      yield &__node_ptr[pointer]
    }
  }
}

extension ___RedBlackTree.___Buffer {
  /// O(1)
  @inlinable
  func ___pushDestroy(_ p: _NodePtr) {
    assert(header.destroyCount < capacity)
    assert(header.destroyNode != p)
    __node_ptr[p].__right_ = header.destroyNode
    __node_ptr[p].__left_ = p
    header.destroyNode = p
    header.destroyCount += 1
  }
  /// O(1)
  @inlinable
  func ___popDetroy() -> _NodePtr {
    assert(header.destroyCount > 0)
    let p = __node_ptr[header.destroyNode].__left_
    header.destroyNode = __node_ptr[p].__right_
    header.destroyCount -= 1
    return p
  }
  /// O(1)
  @inlinable
  func ___clearDestroy() {
    header.destroyNode = .nullptr
    header.destroyCount = 0
  }
  /// O(*k*)
  var ___destroyNodes: [_NodePtr] {
    if header.destroyNode == .nullptr {
      return []
    }
    var nodes: [_NodePtr] = [header.destroyNode]
    while let l = nodes.last, self[l].__right_ != .nullptr {
      nodes.append(self[l].__right_)
    }
    return nodes
  }
  /// O(1)
  @inlinable
  func __eraseAll() {
    __begin_node = .nullptr
    __left_ = .nullptr
    ___clearDestroy()
  }
}

extension ___RedBlackTree.___Buffer {

  @inlinable
  var count: Int {
    __header_ptr.pointee.initializedCount - __header_ptr.pointee.destroyCount
  }

  @inlinable
  var size: Int {
    get { count }
    set { /* NOP */  }
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

extension ___RedBlackTree.___Buffer {

  @inlinable
  func __construct_node(_ k: Element) -> _NodePtr {
    if header.destroyCount > 0 {
      return ___popDetroy()
    }
    let index = count
    (__node_ptr + index).initialize(to: .init(__value_: k))
    header.initializedCount += 1
    return index
  }

  @inlinable
  func destroy(_ p: _NodePtr) {
    ___invalidate(p)
    ___pushDestroy(p)
  }
}

extension ___RedBlackTree.___Buffer {

  @inlinable @inline(__always)
  func __value_(_ p: _NodePtr) -> _Key {
    __value_(__node_ptr[p].__value_)
  }
}

extension ___RedBlackTree.___Buffer {
  
  @inlinable @inline(__always)
  func ___element(_ p: _NodePtr) -> Element { self[p].__value_ }
}


extension ___RedBlackTree.___Buffer: ___UnsafeHandleBase {}
extension ___RedBlackTree.___Buffer: NodeFindProtocol & NodeFindEqualProtocol & FindLeafProtocol {}
extension ___RedBlackTree.___Buffer: EqualProtocol {}
extension ___RedBlackTree.___Buffer: InsertNodeAtProtocol {}
extension ___RedBlackTree.___Buffer: RemoveProtocol {}
extension ___RedBlackTree.___Buffer: StorageEraseProtocol {}
extension ___RedBlackTree.___Buffer: InsertUniqueProtocol2 {
  @inlinable
  static func __key(_ e: VC.Element) -> VC._Key {
    VC.__key(e)
  }
}

extension ___RedBlackTree.___Buffer: MemberProtocol & RootImpl & RefSetImpl & RootPtrImpl {
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

extension ___RedBlackTree.___Buffer {

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

extension ___RedBlackTree.___Buffer {

  @inlinable
  func ___erase_unique(_ __k: VC._Key) -> Bool {
    let __i = find(__k)
    if __i == end() {
      return false
    }
    _ = erase(__i)
    return true
  }

  @inlinable
  func
  ___erase(_ __f: _NodePtr,_ __l: _NodePtr,_ action: (Element) throws -> Void) rethrows
  {
    var __f = __f
    while __f != __l {
      try action(___element(__f))
      __f = erase(__f)
    }
  }
}

extension ___RedBlackTree.___Buffer {

  @inlinable @inline(__always)
  internal static func create(
    withCapacity capacity: Int
  ) -> Buffer {

    let storage = Buffer.create(minimumCapacity: capacity) { _ in
      Header(
        capacity: capacity,
        __left_: .nullptr,
        __begin_node: .end,
        __initialized_count: 0,
        __destroy_count: 0,
        __destroy_node: .nullptr)
    }

    return unsafeDowncast(storage, to: Buffer.self)
  }

  @inlinable
  @inline(__always)
  internal func copy(newCapacity: Int? = nil) -> Buffer {
    
    let capacity = newCapacity ?? self.header.capacity
    let __left_ = self.header.__left_
    let __begin_node = self.header.__begin_node
    let __initialized_count = self.header.initializedCount
    let __destroy_count = self.header.destroyCount
    let __destroy_node = self.header.destroyNode

    let newStorage = Buffer.create(withCapacity: capacity)

    newStorage.header.capacity = capacity
    newStorage.header.__left_ = __left_
    newStorage.header.__begin_node = __begin_node
    newStorage.header.initializedCount = __initialized_count
    newStorage.header.destroyCount = __destroy_count
    newStorage.header.destroyNode = __destroy_node

    self.withUnsafeMutablePointerToElements { oldNodes in
      newStorage.withUnsafeMutablePointerToElements { newNodes in
        newNodes.initialize(from: oldNodes, count: __initialized_count)
      }
    }

    return newStorage
  }
}
