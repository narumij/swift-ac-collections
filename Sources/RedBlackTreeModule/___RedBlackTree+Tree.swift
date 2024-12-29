// Copyright 2024 narumij
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
// Copyright © 2003-2024 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Foundation

extension ___RedBlackTree {

  public class ___Tree<VC>: ManagedBuffer<
    ___RedBlackTree.___Tree<VC>.Header,
    ___RedBlackTree.___Tree<VC>.Node
  >
  where VC: ValueComparer {

    @inlinable
    deinit {
      self.withUnsafeMutablePointers { header, elements in
        elements.deinitialize(count: header.pointee.initializedCount)
        header.deinitialize(count: 1)
      }
    }
  }
}

extension ___RedBlackTree.___Tree {

  @inlinable
  internal static func create(
    withCapacity capacity: Int
  ) -> Tree {

    let storage = Tree.create(minimumCapacity: capacity) { _ in
      Header(
        capacity: capacity,
        __left_: .nullptr,
        __begin_node: .end,
        __initialized_count: 0,
        __destroy_count: 0,
        __destroy_node: .nullptr)
    }

    return unsafeDowncast(storage, to: Tree.self)
  }

  @inlinable
  internal func copy(newCapacity: Int? = nil) -> Tree {

    let capacity = newCapacity ?? self.header.capacity
    let __left_ = self.header.__left_
    let __begin_node = self.header.__begin_node
    let __initialized_count = self.header.initializedCount
    let __destroy_count = self.header.destroyCount
    let __destroy_node = self.header.destroyNode

    let newStorage = Tree.create(withCapacity: capacity)

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

extension ___RedBlackTree.___Tree {

  @inlinable
  static func ensureUnique(tree: inout Tree) {
    if !isKnownUniquelyReferenced(&tree) {
      tree = tree.copy(newCapacity: tree.header.capacity)
    }
  }

  @inlinable
  static func ensureUniqueAndCapacity(tree: inout Tree) {
    ensureUniqueAndCapacity(tree: &tree, minimumCapacity: tree.count + 1)
  }

  @inlinable
  static func ensureUniqueAndCapacity(tree: inout Tree, minimumCapacity: Int) {
    let shouldExpand = tree.header.capacity < minimumCapacity
    if shouldExpand || !isKnownUniquelyReferenced(&tree) {
      tree = tree.copy(
        newCapacity: _growCapacity(tree: &tree, to: minimumCapacity, linearly: false))
    }
  }

  @inlinable
  static func ensureCapacity(tree: inout Tree, minimumCapacity: Int) {
    let shouldExpand = tree.header.capacity < minimumCapacity
    if shouldExpand {
      tree = tree.copy(
        newCapacity: _growCapacity(tree: &tree, to: minimumCapacity, linearly: false))
    }
  }

  @inlinable
  @inline(__always)
  internal static var growthFactor: Double { 1.75 }

  @inlinable
  internal static func _growCapacity(
    tree: inout Tree,
    to minimumCapacity: Int,
    linearly: Bool
  ) -> Int {
    if linearly { return Swift.max(tree.header.capacity, minimumCapacity) }
    return Swift.max(
      Int((Self.growthFactor * Double(tree.header.capacity)).rounded(.up)),
      minimumCapacity)
  }
}

extension ___RedBlackTree.___Tree {

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

extension ___RedBlackTree.___Tree {

  public
    typealias Tree = ___RedBlackTree.___Tree<VC>

  @usableFromInline
  typealias Manager = ManagedBufferPointer<Header, Node>
}

extension ___RedBlackTree.___Tree {

  public struct Header {

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

extension ___RedBlackTree.___Tree {

  @inlinable
  var __header_ptr: UnsafeMutablePointer<Header> {
    withUnsafeMutablePointerToHeader({ $0 })
  }

  @inlinable
  var __node_ptr: UnsafeMutablePointer<Node> {
    withUnsafeMutablePointerToElements({ $0 })
  }

  @inlinable
  subscript(node pointer: _NodePtr) -> Node {
    @inline(__always)
    get {
      assert(0 <= pointer && pointer < header.initializedCount)
      return __node_ptr[pointer]
    }
    @inline(__always)
    _modify {
      defer { _fixLifetime(self) }
      assert(0 <= pointer && pointer < header.initializedCount)
      yield &__node_ptr[pointer]
    }
  }

  @inlinable
  @inline(__always)
  subscript(key pointer: _NodePtr) -> _Key {
      assert(0 <= pointer && pointer < header.initializedCount)
      return __key(__node_ptr[pointer].__value_)
  }

  @inlinable
  public subscript(_ pointer: _NodePtr) -> Element {
    @inline(__always)
    get {
      assert(0 <= pointer && pointer < header.initializedCount)
      return __node_ptr[pointer].__value_
    }
    @inline(__always)
    _modify {
      defer { _fixLifetime(self) }
      assert(0 <= pointer && pointer < header.initializedCount)
      yield &__node_ptr[pointer].__value_
    }
  }

  @inlinable
  subscript(_ ref: _NodeRef) -> Element {
    @inline(__always)
    get {
      let pointer = __ref_(ref)
      assert(0 <= pointer && pointer < header.initializedCount)
      return __node_ptr[pointer].__value_
    }
    @inline(__always)
    _modify {
      defer { _fixLifetime(self) }
      let pointer = __ref_(ref)
      assert(0 <= pointer && pointer < header.initializedCount)
      yield &__node_ptr[pointer].__value_
    }
  }
}

extension ___RedBlackTree.___Tree {
  // コンスセルでイメージすると、右に伸ばしていく方がイメージ通りだったが、
  // leftを伸ばしていく方が意味が通じやすいので、そちらにした

  /// O(1)
  @inlinable
  @inline(__always)
  func ___pushDestroy(_ p: _NodePtr) {
    assert(header.destroyCount <= header.capacity)
    assert(header.destroyNode != p)
    __node_ptr[p].__left_ = header.destroyNode
    __node_ptr[p].__right_ = p
    header.destroyNode = p
    header.destroyCount += 1
  }
  /// O(1)
  @inlinable
  @inline(__always)
  func ___popDetroy() -> _NodePtr {
    assert(header.destroyCount > 0)
    let p = __node_ptr[header.destroyNode].__right_
    header.destroyNode = __node_ptr[p].__left_
    header.destroyCount -= 1
    return p
  }
  /// O(1)
  @inlinable
  func ___clearDestroy() {
    header.destroyNode = .nullptr
    header.destroyCount = 0
  }
}

#if DEBUG
  extension ___RedBlackTree.___Tree {

    /// O(*k*)
    var ___destroyNodes: [_NodePtr] {
      if header.destroyNode == .nullptr {
        return []
      }
      var nodes: [_NodePtr] = [header.destroyNode]
      while let l = nodes.last, self[node: l].__left_ != .nullptr {
        nodes.append(self[node: l].__left_)
      }
      return nodes
    }
  }
#endif

extension ___RedBlackTree.___Tree {

  @inlinable @inline(__always)
  func ___is_valid(_ p: _NodePtr) -> Bool {
    __node_ptr[p].__parent_ != .nullptr
  }

  @inlinable @inline(__always)
  func ___invalidate(_ p: _NodePtr) {
    __node_ptr[p].__parent_ = .nullptr
  }
}

extension ___RedBlackTree.___Tree {

  @inlinable
  func __construct_node(_ k: Element) -> _NodePtr {
    if header.destroyCount > 0 {
      let p = ___popDetroy()
      __node_ptr[p].__value_ = k
      return p
    }
    let index = count
    (__node_ptr + index).initialize(to: Node(__value_: k))
    header.initializedCount += 1
    return index
  }

  @inlinable
  func destroy(_ p: _NodePtr) {
    ___invalidate(p)
    ___pushDestroy(p)
  }
}

extension ___RedBlackTree.___Tree {

  @inlinable
  public var count: Int {
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
    _modify {
      defer { _fixLifetime(self) }
      yield &__header_ptr.pointee.__left_
    }
  }

  @inlinable
  var __begin_node: _NodePtr {
    get { __header_ptr.pointee.__begin_node }
    _modify {
      defer { _fixLifetime(self) }
      yield &__header_ptr.pointee.__begin_node
    }
  }
}

extension ___RedBlackTree.___Tree {

  @inlinable @inline(__always)
  func __value_(_ p: _NodePtr) -> _Key {
    __value_(__node_ptr[p].__value_)
  }
}

extension ___RedBlackTree.___Tree {

  @usableFromInline
  typealias _Key = VC._Key

  public
    typealias Element = VC.Element

  @inlinable @inline(__always)
  func __value_(_ e: VC.Element) -> _Key {
    VC.__key(e)
  }

  @inlinable @inline(__always)
  func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    VC.value_comp(a, b)
  }
}

extension ___RedBlackTree.___Tree: FindProtocol & FindEqualProtocol & FindLeafProtocol {}
extension ___RedBlackTree.___Tree: EqualProtocol {}
extension ___RedBlackTree.___Tree: InsertNodeAtProtocol {}
extension ___RedBlackTree.___Tree: InsertMultiProtocol {}
extension ___RedBlackTree.___Tree: RemoveProtocol {}
extension ___RedBlackTree.___Tree: StorageEraseProtocol {}
extension ___RedBlackTree.___Tree: InsertUniqueProtocol {
  @inlinable
  @inline(__always)
  func __key(_ e: VC.Element) -> VC._Key {
    VC.__key(e)
  }
}

extension ___RedBlackTree.___Tree: MemberProtocol & RootImpl & RefSetImpl & RootPtrImpl {
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

extension ___RedBlackTree.___Tree {

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

extension ___RedBlackTree.___Tree: DistanceProtocol & CountProtocol { }

extension ___RedBlackTree.___Tree {

//  @inlinable
//  @inline(__always)
//  func distance(__first: _NodePtr, __last: _NodePtr) -> Int {
//    var __first = __first
//    var __r = 0
//    while __first != __last {
//      __first = __tree_next(__first)
//      __r += 1
//    }
//    return __r
//  }

//  @inlinable
//  @inline(__always)
//  func distance(__l: _NodePtr, __r: _NodePtr) -> Int {
//    var __p = __begin_node
//    var (l, r): (Int?, Int?) = (nil, nil)
//    var __a = 0
//    while __p != __end_node(), l == nil || r == nil {
//      if __p == __l { l = __a }
//      if __p == __r { r = __a }
//      __p = __tree_next(__p)
//      __a += 1
//    }
//    if __p == __l { l = __a }
//    if __p == __r { r = __a }
//    return r! - l!
//  }

  @inlinable
  @inline(__always)
  public func ___for_each(__p: _NodePtr, __l: _NodePtr, body: (_NodePtr, inout Bool) throws -> Void)
    rethrows
  {
    var __p = __p
    var cont = true
    while cont, __p != __l {
      try body(__p, &cont)
      __p = __tree_next(__p)
    }
  }
}

extension ___RedBlackTree.___Tree {

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
  func ___erase_multi(_ __k: VC._Key) -> Int {
    var __p = __equal_range_multi(__k)
    var __r = 0
    while __p.0 != __p.1 {
      defer { __r += 1 }
      __p.0 = erase(__p.0)
    }
    return __r
  }
}

extension ___RedBlackTree.___Tree {

  @inlinable
  func
    ___erase(_ __f: _NodePtr, _ __l: _NodePtr, _ action: (Element) throws -> Void) rethrows
  {
    var __f = __f
    while __f != __l {
      try action(self[__f])
      __f = erase(__f)
    }
  }

  @inlinable
  func
    ___erase<Result>(
      _ __f: _NodePtr, _ __l: _NodePtr, _ initialResult: Result,
      _ nextPartialResult: (Result, Element) throws -> Result
    ) rethrows -> Result
  {
    var result = initialResult
    var __f = __f
    while __f != __l {
      result = try nextPartialResult(result, self[__f])
      __f = erase(__f)
    }
    return result
  }

  @inlinable
  func
    ___erase<Result>(
      _ __f: _NodePtr, _ __l: _NodePtr, into initialResult: Result,
      _ updateAccumulatingResult: (inout Result, Element) throws -> Void
    ) rethrows -> Result
  {
    var result = initialResult
    var __f = __f
    while __f != __l {
      try updateAccumulatingResult(&result, self[__f])
      __f = erase(__f)
    }
    return result
  }
}

extension ___RedBlackTree.___Tree {

  /// O(1)
  @inlinable
  func __eraseAll() {
    __begin_node = .end
    __left_ = .nullptr
    ___clearDestroy()
  }
}

extension ___RedBlackTree.___Tree {

  @inlinable @inline(__always)
  public var ___count: Int {
    count
  }

  @inlinable @inline(__always)
  public var ___isEmpty: Bool {
    count == 0
  }

  @inlinable @inline(__always)
  public var ___capacity: Int {
    header.capacity
  }

  @inlinable @inline(__always)
  public func ___begin() -> _NodePtr {
    header.__begin_node
  }

  @inlinable @inline(__always)
  public func ___end() -> _NodePtr {
    .end
  }
}

#if false
extension ___RedBlackTree.___Tree {

  // CoWがない時期はこちらが必要だった
  @usableFromInline
  typealias SafeSequenceState = (current: _NodePtr, next: _NodePtr, to: _NodePtr)
  // CoWがあるので、こちらで十分かもしれない
  @usableFromInline
  typealias UnsafeSequenceState = (current: _NodePtr, to: _NodePtr)

  @inlinable
  func ___next(_ ptr: _NodePtr, to: _NodePtr) -> _NodePtr {
    ptr == to ? ptr : __tree_next_iter(ptr)
  }

  @inlinable @inline(__always)
  func ___begin(_ from: _NodePtr, to: _NodePtr) -> SafeSequenceState {
    (from, ___next(from, to: to), to)
  }

  @inlinable @inline(__always)
  func ___next(_ state: inout SafeSequenceState) {
    state.current = state.next
    state.next = ___next(state.next, to: state.to)
  }

  @inlinable @inline(__always)
  func ___end(_ state: SafeSequenceState) -> Bool {
    state.current != state.to
  }

  @inlinable @inline(__always)
  func ___begin(_ from: _NodePtr, to: _NodePtr) -> UnsafeSequenceState {
    (from, to)
  }

  @inlinable @inline(__always)
  func ___next(_ state: inout UnsafeSequenceState) {
    state.current = ___next(state.current, to: state.to)
  }

  @inlinable @inline(__always)
  func ___end(_ state: UnsafeSequenceState) -> Bool {
    state.current != state.to
  }
}
#endif

extension ___RedBlackTree.___Tree: Sequence {
  
  public struct Iterator: IteratorProtocol {
    
    @inlinable
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.tree = tree
      self.current = start
      self.end = end
    }
    
    @usableFromInline
    unowned let tree: Tree
    
    @usableFromInline
    var current, end: _NodePtr
    
    @inlinable
    @inline(__always)
    public mutating func next() -> Element?
    {
      guard current != end else { return nil }
      defer { current = tree.__tree_next(current) }
      return tree[current]
    }
  }
  
  @inlinable
  public __consuming func makeIterator() -> Iterator {
    makeIterator(start: __begin_node, end: __end_node())
  }
  
  @inlinable
  public __consuming func makeIterator(start: _NodePtr, end: _NodePtr) -> Iterator {
    .init(tree: self, start: start, end: end)
  }
  
  public typealias Index = _NodePtr
  
  // この実装がないと、迷子になる
  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    ___signed_distance(start, end)
  }
  
  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    __tree_next(i)
  }
  
  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    i = __tree_next(i)
  }
  
  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    __tree_prev_iter(i)
  }
  
  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    i = __tree_prev_iter(i)
  }
  
  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    var distance = distance
    var i = i
    while distance != 0 {
      if 0 < distance {
        i = index(after: i)
        distance -= 1
      }
      else {
        i = index(before: i)
        distance += 1
      }
    }
    return i
  }
  
  @inlinable
  @inline(__always)
  internal func formIndex(_ i: inout Index, offsetBy distance: Int) {
    i = index(i, offsetBy: distance)
  }
  
  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    var distance = distance
    var i = i
    while distance != 0 {
      if i == limit {
        return nil
      }
      if 0 < distance {
        i = index(after: i)
        distance -= 1
      }
      else {
        i = index(before: i)
        distance += 1
      }
    }
    return i
  }
  
  @inlinable
  @inline(__always)
  internal func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index) -> Bool {
    if let ii = index(i, offsetBy: distance, limitedBy: limit) {
      i = ii
      return true
    }
    return false
  }
}

extension ___RedBlackTree.___Tree {

  public struct SubSequence: Sequence {

    public typealias Element = Tree.Element
    public typealias Index = _NodePtr

    @inlinable
    public init(tree: Tree, start: Index, end: Index) {
      self.base = tree
      self.startIndex = start
      self.endIndex = end
    }

    @usableFromInline
    unowned let base: Tree

    public
      var startIndex: Index
    
    public
      var endIndex: Index

    @inlinable
    public func makeIterator() -> Iterator {
      base.makeIterator(start: startIndex, end: endIndex)
    }
    
    @inlinable
    @inline(__always)
    var count: Int {
      base.distance(from: startIndex, to: endIndex)
    }
    
    // この実装がないと、迷子になる
    @inlinable
    @inline(__always)
    public func distance(from start: Index, to end: Index) -> Int {
      base.distance(from: start, to: end)
    }
    
    @inlinable
    @inline(__always)
    public func index(after i: Index) -> Index {
      base.index(after: i)
    }
    
    @inlinable
    @inline(__always)
    public func formIndex(after i: inout Index) {
      base.formIndex(after: &i)
    }
    
    @inlinable
    @inline(__always)
    public func index(before i: Index) -> Index {
      base.index(before: i)
    }
    
    @inlinable
    @inline(__always)
    public func formIndex(before i: inout Index) {
      base.formIndex(before: &i)
    }
    
    @inlinable
    @inline(__always)
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
      base.index(i, offsetBy: distance)
    }
    
    @inlinable
    @inline(__always)
    internal func formIndex(_ i: inout Index, offsetBy distance: Int) {
      base.formIndex(&i, offsetBy: distance)
    }
    
    @inlinable
    @inline(__always)
    public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
      base.index(i, offsetBy: distance, limitedBy: limit)
    }
    
    @inlinable
    @inline(__always)
    internal func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Self.Index) -> Bool {
      if let ii = index(i, offsetBy: distance, limitedBy: limit) {
        i = ii
        return true
      }
      return false
    }
    
    @inlinable
    @inline(__always)
    public subscript(position: Index) -> Element {
      base[position]
    }
    
    @inlinable
    public subscript(bounds: Range<TreePointer>) -> SubSequence {
      .init(tree: base, start: bounds.lowerBound.pointer, end: bounds.upperBound.pointer)
    }
  }
  
  func subsequence(from: _NodePtr, to: _NodePtr) -> SubSequence {
    .init(tree: self, start: from, end: to)
  }
}

extension ___RedBlackTree.___Tree {
  
  public struct EnumeratedIterator: IteratorProtocol {
    
    @inlinable
    internal init(tree: Tree) {
      self.init(tree: tree, start: tree.__begin_node, end: tree.__end_node())
    }
    
    @inlinable
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.tree = tree
      self.current = start
      self.end = end
    }
    
    @usableFromInline
    unowned let tree: Tree
    
    @usableFromInline
    var current, end: _NodePtr
    
    @inlinable
    @inline(__always)
    public mutating func next() -> (offset: TreePointer, element: Element)?
    {
      guard current != end else { return nil }
      defer { current = tree.__tree_next(current) }
      return (TreePointer(__tree: tree, pointer: current), tree[current])
    }
  }
  
  @inlinable
  public func makeEnumeratedIterator() -> EnumeratedIterator {
    makeEnumeratedIterator(start: __begin_node, end: __end_node())
  }
  
  @inlinable
  public func makeEnumeratedIterator(start: _NodePtr, end: _NodePtr) -> EnumeratedIterator {
    .init(tree: self, start: start, end: end)
  }
}

public
protocol __EnumerateSequence {
  associatedtype EnumerateIterator: IteratorProtocol
  func makeEnumerateIterator() -> EnumerateIterator
}

// MARK: -

extension ___RedBlackTree.___Tree {
  
  @frozen
  public struct EnumeratedSequence<Base: __EnumerateSequence> {
    @usableFromInline
    internal var _base: Base

    @inlinable
    internal init(_base: Base) {
      self._base = _base
    }
  }
}

extension ___RedBlackTree.___Tree.EnumeratedSequence: Sequence {
  
  @inlinable
  public __consuming func makeIterator() -> Base.EnumerateIterator {
    _base.makeEnumerateIterator()
  }
}
