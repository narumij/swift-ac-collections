// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public final class UnsafeTree<Base>:
  ManagedBuffer<
    UnsafeTree<Base>.Header,
    UnsafeNode
  >
where Base: ___TreeBase {

  @inlinable
  @inline(__always)
  deinit {
    withUnsafeMutablePointers { h, e in
      h.pointee.___disposeFreshPool()
      e.deinitialize(count: 1)
    }
  }
}

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  public var __header_ptr: UnsafeMutablePointer<Header> {
    withUnsafeMutablePointerToHeader { $0 }
  }

  @nonobjc
  @inlinable
  @inline(__always)
  public var _header: Header {
    _read { yield __header_ptr.pointee }
    _modify { yield &__header_ptr.pointee }
  }
}

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal static func create(
    minimumCapacity nodeCapacity: Int
  ) -> Tree {

    assert(
      MemoryLayout<UnsafeNode>.stride
        % MemoryLayout<UInt>.stride == 0
    )

    let storage = Tree.create(
      minimumCapacity: 1
    ) { managedBuffer in

      return managedBuffer.withUnsafeMutablePointerToElements { _end in

        _end.initialize(to: .init(index: -1))

        var h = Header(end: _end)

        if nodeCapacity > 0 {
          h.pushBucket(capacity: nodeCapacity)
        }

        return h
      }
    }

    assert(nodeCapacity == storage.header.freshPoolCapacity)
    return unsafeDowncast(storage, to: Tree.self)
  }
}

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal func copy(minimumCapacity: Int? = nil) -> UnsafeTree {
    assert(__tree_invariant(__root))
    // 予定サイズを確定させる
    let newCapacity = max(minimumCapacity ?? _header.initializedCount, _header.initializedCount)
    // 空の木を作成する
    let result = UnsafeTree.create(minimumCapacity: newCapacity)
    // 予定サイズに変更する。freshPool内のfreshBucketは0〜1個となる
    // CoW後の性能維持の為、freshBucket数は1を越えないこと
    assert(result._header.freshBucketCount <= 1)

    withUnsafeMutablePointerToHeader { source_header in

      result.withUnsafeMutablePointers { h, e in

        @inline(__always)
        func resolved(_ index: Int) -> _NodePtr {
          if index == -1 {
            return h.pointee.end
          }
          return h.pointee[index]
        }

        var srcIter = source_header.pointee.makeNodeReserverIterator()
        var dstIter = h.pointee.makeConsumingIterator()
        var i = 0

        while let s = srcIter.next(), let d = dstIter.next() {

          d.initialize(to: UnsafeNode(index: i))
          UnsafePair<_Value>.__value_(d).initialize(to: UnsafePair<_Value>.__value_(s).pointee)

          d.pointee.__is_black_ = s.pointee.__is_black_

          if let l = s.pointee.__left_?.pointee.___node_id_ {
            assert(l != -2)
            d.pointee.__left_ = resolved(l)
          }

          if let r = s.pointee.__right_?.pointee.___node_id_ {
            assert(r != -2)
            d.pointee.__right_ = resolved(r)
          }

          if let p = s.pointee.__parent_?.pointee.___node_id_ {
            assert(p != -2)
            d.pointee.__parent_ = resolved(p)
          }

          i += 1
        }

        if let b = source_header.pointee.__begin_node_?.pointee.___node_id_ {
          h.pointee.__begin_node_ = resolved(b)
        }
        if let l = source_header.pointee.__left_?.pointee.___node_id_ {
          h.pointee.__left_ = resolved(l)
        }
        h.pointee.initializedCount = source_header.pointee.initializedCount
        h.pointee.destroyCount = source_header.pointee.destroyCount
        
        if let l = source_header.pointee.destroyNode?.pointee.___node_id_ {
          h.pointee.destroyNode = resolved(l)
        }

//        for i in source_header.pointee.___destroyNodes.reversed() {
//          h.pointee.___pushRecycle(resolved(i))
//        }
        
        assert(source_header.pointee.___destroyNodes.count == source_header.pointee.destroyCount)

        #if AC_COLLECTIONS_INTERNAL_CHECKS
          h.pointee.copyCount = source_header.pointee.copyCount &+ 1
        #endif
      }
    }

    assert(__tree_invariant(__root))
    assert(result.__tree_invariant(result.__root))
    assert(__root?.pointee.___node_id_ == result.__root?.pointee.___node_id_)
    assert(__begin_node_?.pointee.___node_id_ == result.__begin_node_?.pointee.___node_id_)
    assert(result._header.destroyCount == _header.destroyCount)
    assert(result.count >= 0)

    return result
  }
}

extension UnsafeTree {

  public typealias Base = Base
  public typealias Tree = UnsafeTree<Base>
  public typealias _Key = Base._Key
  public typealias _Value = Base._Value
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>?
  public typealias _NodeRef = UnsafeMutablePointer<_NodePtr>
}

extension UnsafeTree {

  public struct Header: UnsafeNodeFreshPool, UnsafeNodeRecyclePool {
    public typealias _Value = UnsafeTree._Value
    @inlinable
    @inline(__always)
    internal init(end: UnsafeTree._NodePtr = nil) {
      self.end = end
      self.__begin_node_ = end
      assert(__begin_node_ == end)
      assert(__left_ == nil)
    }
    public let end: _NodePtr
    public var __begin_node_: _NodePtr
    @usableFromInline var initializedCount: Int = 0
    @usableFromInline var destroyNode: _NodePtr = nil
    @usableFromInline var destroyCount: Int = 0
    @usableFromInline var freshBucketHead: ReserverHeaderPointer?
    @usableFromInline var freshBucketCurrent: ReserverHeaderPointer?
    @usableFromInline var freshBucketLast: ReserverHeaderPointer?
    @usableFromInline var freshBucketCount: Int = 0
    @usableFromInline var freshPoolCapacity: Int = 0
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      @usableFromInline internal var copyCount: UInt = 0
    #endif
    @inlinable
    public var __left_: _NodePtr {
      @inline(__always)
      _read { yield end!.pointee.__left_ }
      @inline(__always)
      _modify { yield &end!.pointee.__left_ }
    }
    @inlinable
    @inline(__always)
    internal mutating func clear() {
      ___clearFresh()
      ___clearRecycle()
      __begin_node_ = end
      __left_ = nil
      initializedCount = 0
    }
  }
}

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  public var end: _NodePtr {
    _read { yield __header_ptr.pointee.end }
  }

  @nonobjc
  @inlinable
  @inline(__always)
  public var __left_: _NodePtr {
    _read { yield end!.pointee.__left_ }
    _modify { yield &end!.pointee.__left_ }
  }

  @nonobjc
  @inlinable
  @inline(__always)
  public var __begin_node_: _NodePtr {
    _read { yield __header_ptr.pointee.__begin_node_ }
    _modify { yield &__header_ptr.pointee.__begin_node_ }
  }

  @nonobjc
  @inlinable
  @inline(__always)
  public var _end: UnsafeMutablePointer<UnsafeNode> {
    UnsafeMutableRawPointer(__header_ptr.advanced(by: 1))
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  // capacityを上書きするとManagedBufferの挙動に影響があるので、異なる名前を維持すること
  @nonobjc
  @inlinable
  @inline(__always)
  public var freshPoolCapacity: Int { _header.freshPoolCapacity }

  @nonobjc
  @inlinable
  @inline(__always)
  public var freshPoolUsedCount: Int { _header.freshPoolUsedCount }
}

extension UnsafeTree {

  @nonobjc
  @inlinable
  internal subscript(_ pointer: _NodePtr) -> _Value {
    @inline(__always) _read {
      assert(___initialized_contains(pointer))
      yield UnsafePair<_Value>.__value_(pointer)!.pointee
    }
    @inline(__always) _modify {
      assert(___initialized_contains(pointer))
      yield &UnsafePair<_Value>.__value_(pointer)!.pointee
    }
  }
}

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  public func ensureCapacity(_ newCapacity: Int) {
    guard freshPoolCapacity < newCapacity else { return }
    _header.pushBucket(capacity: newCapacity - freshPoolCapacity)
  }
}

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  public var count: Int {
    _header.initializedCount - _header.destroyCount
  }

  @nonobjc
  @inlinable
  @inline(__always)
  func clear() {
    _header.clear()
  }
}

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___is_garbaged(_ p: _NodePtr) -> Bool {
    // TODO: 方式再検討
    p != end && p?.pointee.__parent_ == nil
  }
}

extension UnsafeTree.Header {
  @nonobjc
  @inlinable
  @inline(__always)
  internal var ___destroyNodes: [Int] {
    var nodes: [Int] = []
    var last = destroyNode
    while let l = last {
      nodes.append(l.pointee.___node_id_)
      last = l.pointee.__left_
    }
    return nodes
  }
}

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal var ___destroyNodes: [Int] {
    var nodes: [Int] = []
    var last = _header.destroyNode
    while let l = last {
      nodes.append(l.pointee.___node_id_)
      last = __left_(l)
    }
    return nodes
  }
}

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  public
    func ___node_alloc() -> _NodePtr
  {
    let p = _header.popFresh()
    assert(p != nil)
    assert(p?.pointee.___node_id_ == -2)
    return p
  }

  @nonobjc
  @inlinable
  @inline(__always)
  public func __construct_node(_ k: _Value) -> _NodePtr {
    if _header.destroyCount > 0 {
      let p = _header.___popRecycle()
      UnsafePair<_Value>.__value_(p)!.initialize(to: k)
      return p
    }
    assert(_header.initializedCount < freshPoolCapacity)
    let p = ___node_alloc()
    assert(p != nil)
    assert(p?.pointee.___node_id_ == -2)
    p?.initialize(to: UnsafeNode(index: _header.initializedCount))
    UnsafePair<_Value>.__value_(p)!.initialize(to: k)
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

  /// O(1)
  @nonobjc
  @inlinable
  @inline(__always)
  internal func __eraseAll() {
    clear()
    _header.___clearRecycle()
  }
}

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal func
    sequence(_ __first: _NodePtr, _ __last: _NodePtr) -> ___SafePointersUnsafe<Base>
  {
    .init(tree: self, start: __first, end: __last)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func
    unsafeSequence(_ __first: _NodePtr, _ __last: _NodePtr)
    -> ___UnsafePointersUnsafe<Base>
  {
    .init(tree: self, __first: __first, __last: __last)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func
    unsafeValues(_ __first: _NodePtr, _ __last: _NodePtr)
    -> ___UnsafeValuesUnsafe<Base>
  {
    .init(tree: self, __first: __first, __last: __last)
  }
}

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal var ___is_empty: Bool {
    count == 0
  }
}

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___resolve_node_pointer<INDEX: PointerResolvable>(_ index: INDEX) -> _NodePtr
  where
    INDEX.Tree == UnsafeTree,
    INDEX.Pointer == _NodePtr
  {
    self === index.__tree_ ? index.rawValue : _header[index.___node_id_]
  }
}

@usableFromInline
protocol PointerResolvable {
  associatedtype Tree
  associatedtype Pointer
  var __tree_: Tree { get }
  var rawValue: Pointer { get }
  var ___node_id_: Int { get }
}

extension UnsafeTree {

  #if AC_COLLECTIONS_INTERNAL_CHECKS
    @usableFromInline
    internal var copyCount: UInt {
      get { __header_ptr.pointee.copyCount }
      set { __header_ptr.pointee.copyCount = newValue }
    }
  #endif
}
