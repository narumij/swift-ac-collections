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

import Foundation

// TODO: テスト整備後internalにする
@_fixed_layout
@_objc_non_lazy_realization
public final class UnsafeTree<Base: ___TreeBase>:
  ManagedBuffer<UnsafeTree<Base>.Header, UnsafeNode>
{
  // MARK: - 解放処理
  @inlinable
  @inline(__always)
  deinit {
    withUnsafeMutablePointers { header, end in
      header.pointee.___disposeFreshPool()
      end.deinitialize(count: 2)
    }
  }
}

// MARK: - プリミティブメンバ

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  public var _header_ptr: UnsafeMutablePointer<Header> {
    withUnsafeMutablePointerToHeader { $0 }
  }

  @nonobjc
  @inlinable
  @inline(__always)
  public var _header: Header {
    _read { yield _header_ptr.pointee }
    _modify { yield &_header_ptr.pointee }
  }

  @nonobjc
  @inlinable
  @inline(__always)
  public var _end_ptr: UnsafeMutablePointer<UnsafeNode> {
    withUnsafeMutablePointerToElements { $0 }
  }

  @nonobjc
  @inlinable
  @inline(__always)
  public var _end: UnsafeNode {
    @inline(__always) get { withUnsafeMutablePointerToElements { $0.pointee } }
    _modify { yield &_end_ptr.pointee }
  }
  
  @nonobjc
  @inlinable
  @inline(__always)
  public var _nullptr: UnsafeMutablePointer<UnsafeNode> {
    withUnsafeMutablePointerToHeader {
      $0.pointee._nullptr
    }
  }
}

// MARK: - 生成

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal static func create(
    minimumCapacity nodeCapacity: Int
  ) -> Tree {

    // elementsはendにしか用いないのでManagerdBufferの要素数は常に1
    let storage = Tree.create(minimumCapacity: 2) { managedBuffer in
      return managedBuffer.withUnsafeMutablePointerToElements { _end_ptr in
        let _nullptr = _end_ptr + 1
        _nullptr.initialize(to: UnsafeNode(___node_id_: .nullptr,__left_: _nullptr,__right_: _nullptr,__parent_: _nullptr))
        // endノード用に初期化する
        _end_ptr.initialize(to: UnsafeNode(___node_id_: .end,__left_: _nullptr,__right_: _nullptr,__parent_: _nullptr))
        // ヘッダーを準備する
        var header = Header(_end_ptr: _end_ptr)
        // ノードを確保する
        if nodeCapacity > 0 {
          header.pushFreshBucket(capacity: nodeCapacity)
        }
        assert(_end_ptr.pointee.___needs_deinitialize == true)
        // ヘッダを返却して以後はManagerBufferさんがよしなにする
        return header
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
    let newCapacity = max(minimumCapacity ?? 0, _header.initializedCount)
    // 予定サイズの木を作成する
    let tree = UnsafeTree.create(minimumCapacity: newCapacity)
    // freshPool内のfreshBucketは0〜1個となる
    // CoW後の性能維持の為、freshBucket数は1を越えないこと
    // バケット数が1に保たれていると、フォールバックの___node_idによるアクセスがO(1)になる
    assert(tree._header.freshBucketCount <= 1)

    // 複数のバケットを新しい一つのバケットに連番通りにまとめ、その他管理情報をそのまま移す
    // アドレスやバケット配置は変化するがそれ以外は変わらない状態となる
    withUnsafeMutablePointers { source_header, source_end in

      tree.withUnsafeMutablePointers { _header_ptr, _end_ptr in

        let _nullptr = _header_ptr.pointee._nullptr
        assert(_nullptr.pointee.___node_id_ == .nullptr)

        @inline(__always)
        func __node_ptr(_ index: Int) -> _NodePtr {
          switch index {
          case .nullptr:
            _nullptr
          case .end:
            _end_ptr
          default:
            _header_ptr.pointee[index] ?? _nullptr
          }
        }

        @inline(__always)
        func apply(_ d: inout UnsafeNode, _ s: inout UnsafeNode) {
          // endにも使うので___node_idには触らない
          d.__left_ = __node_ptr(s.__left_.pointee.___node_id_)
          d.__right_ = __node_ptr(s.__right_.pointee.___node_id_)
          d.__parent_ = __node_ptr(s.__parent_.pointee.___node_id_)
          d.__is_black_ = s.__is_black_
          // 値は別途管理
        }

        var source_nodes = source_header.pointee.makeInitializedIterator()
        var ___node_id_ = 0

        while let s = source_nodes.next(), let d = _header_ptr.pointee.popFresh() {
          // メモリを連番で初期化
//          d.initialize(to: UnsafeNode(___node_id_: ___node_id_))
          d.initialize(to: UnsafeNode(___node_id_: ___node_id_,__left_: _nullptr,__right_: _nullptr,__parent_: _nullptr))
          // 値を初期化
          UnsafeNode.initializeValue(d, to: UnsafeNode.value(s) as _Value)
          // 残りを初期化
          apply(&d.pointee, &s.pointee)

          ___node_id_ += 1
        }

        // 最終ノード番号が初期化済み数と一致すること
        assert(___node_id_ == source_header.pointee.initializedCount)

        // endノードを初期化
        apply(&_end_ptr.pointee, &source_end.pointee)

        // __begin_nodeを初期化
        _header_ptr.pointee.__begin_node_ = __node_ptr(source_header.pointee.__begin_node_.pointee.___node_id_)

        // その他管理情報をコピー
        _header_ptr.pointee.initializedCount = source_header.pointee.initializedCount
        _header_ptr.pointee.destroyCount = source_header.pointee.destroyCount
        _header_ptr.pointee.destroyNode = __node_ptr(source_header.pointee.destroyNode.pointee.___node_id_)
        assert(_header_ptr.pointee.destroyNode.pointee.___node_id_
               == source_header.pointee.destroyNode.pointee.___node_id_)

        #if AC_COLLECTIONS_INTERNAL_CHECKS
          _header_ptr.pointee.copyCount = source_header.pointee.copyCount &+ 1
        #endif
      }
    }

    assert(tree.__tree_invariant(tree.__root))
    assert(tree._end_ptr.pointee.___needs_deinitialize == true)
    assert(tree.count >= 0)
    assert(tree.count <= tree._header.initializedCount)
    assert(tree.count <= tree.freshPoolCapacity)
    assert(tree._header.initializedCount <= tree.freshPoolCapacity)

    assert(__root.pointee.___node_id_ == tree.__root.pointee.___node_id_)
    assert(__begin_node_.pointee.___node_id_ == tree.__begin_node_.pointee.___node_id_)
    assert(_header.destroyCount == tree._header.destroyCount)
    assert(___destroyNodes == tree._header.___destroyNodes)

    return tree
  }
}

// MARK: -

extension UnsafeTree {

  public typealias Base = Base
  public typealias Tree = UnsafeTree<Base>
  public typealias _Key = Base._Key
  public typealias _Value = Base._Value
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  public typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
}

extension UnsafeTree {

  @frozen
  public struct Header: UnsafeNodeFreshPool, UnsafeNodeRecyclePool {
    public typealias _NodePtr = UnsafeTree._NodePtr
    public typealias _Value = UnsafeTree._Value
    @inlinable
    @inline(__always)
    internal init(_end_ptr: _NodePtr) {
      self._nullptr = _end_ptr + 1
      self.__begin_node_ = _end_ptr
      self.destroyNode = _end_ptr + 1
      //      self.freshBucketCreate = UnsafeNodeFreshBucket<_Value>.create
      //      self.freshBucketDispose = Self.___disposeBucketFunc
    }
    public var _nullptr: UnsafeMutablePointer<UnsafeNode>
    public var __begin_node_: UnsafeMutablePointer<UnsafeNode>
    @usableFromInline var initializedCount: Int = 0
    @usableFromInline var destroyNode: _NodePtr
    @usableFromInline var destroyCount: Int = 0
    @usableFromInline var freshBucketHead: ReserverHeaderPointer?
    @usableFromInline var freshBucketCurrent: ReserverHeaderPointer?
    @usableFromInline var freshBucketLast: ReserverHeaderPointer?
    @usableFromInline var freshBucketCount: Int = 0
    @usableFromInline var freshPoolCapacity: Int = 0
    //    @usableFromInline var freshBucketCreate: (Int) -> ReserverHeaderPointer
    //    @usableFromInline let freshBucketDispose: (ReserverHeaderPointer?) -> Void
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      /// CoWの発火回数を観察するためのプロパティ
      @usableFromInline internal var copyCount: UInt = 0
    #endif
    // TODO: removeAll(keepingCapacity:)対応
    @inlinable
    @inline(__always)
    internal mutating func clear(_end_ptr: _NodePtr) {
      ___clearFresh()
      ___clearRecycle()
      __begin_node_ = _end_ptr
      initializedCount = 0
    }
  }
}

extension UnsafeTree {

  #if AC_COLLECTIONS_INTERNAL_CHECKS
    /// CoWの発火回数を観察するためのプロパティ
    @usableFromInline
    internal var copyCount: UInt {
      get { _header_ptr.pointee.copyCount }
      set { _header_ptr.pointee.copyCount = newValue }
    }
  #endif
}

extension UnsafeTree {

  // capacityを上書きするとManagedBufferの挙動に影響があるので、異なる名前を維持すること
  @nonobjc
  @inlinable
  @inline(__always)
  public var freshPoolCapacity: Int {
    //    _header.freshPoolCapacity
    withUnsafeMutablePointerToHeader { $0.pointee.freshPoolCapacity }
  }

  // これはinitializedCountと同一の内容だが計算量が異なるため代用はできない。
  @nonobjc
  @inlinable
  @inline(__always)
  public var freshPoolUsedCount: Int {
    //    _header.freshPoolUsedCount
    withUnsafeMutablePointerToHeader { $0.pointee.freshPoolUsedCount }
  }
}

extension UnsafeTree {

  // _NodePtrがIntだった頃の名残
  @nonobjc
  @inlinable
  internal subscript(_ pointer: _NodePtr) -> _Value {
    @inline(__always) _read {
      assert(___initialized_contains(pointer))
      yield UnsafeNode.valuePointer(pointer).pointee
    }
    @inline(__always) _modify {
      assert(___initialized_contains(pointer))
      yield &UnsafeNode.valuePointer(pointer).pointee
    }
  }
}

extension UnsafeTree.Header {

  // TODO: grow関連の名前が混乱気味なので整理する
  @inlinable
  @inline(__always)
  public mutating func ensureCapacity(_ newCapacity: Int) {
    guard freshPoolCapacity < newCapacity else { return }
    pushFreshBucket(capacity: newCapacity - freshPoolCapacity)
  }
}

extension UnsafeTree {

  // TODO: grow関連の名前が混乱気味なので整理する
  @nonobjc
  @inlinable
  @inline(__always)
  public func ensureCapacity(_ newCapacity: Int) {
    withUnsafeMutablePointerToHeader {
      $0.pointee.ensureCapacity(newCapacity)
    }
  }
}

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  public var count: Int {
    withUnsafeMutablePointerToHeader { $0.pointee.count }
  }

  @nonobjc
  @inlinable
  @inline(__always)
  func clear() {
    _end.__left_ = _nullptr
    _header.clear(_end_ptr: _end_ptr)
  }
}

extension UnsafeTree.Header {

  @inlinable
  @inline(__always)
  public var count: Int {
    initializedCount - destroyCount
  }
}

extension UnsafeTree.Header {

  // TODO: いろいろ試すための壁で、いまは余り意味が無いのでタイミングでインライン化する
  @inlinable
  @inline(__always)
  mutating public
    func ___node_alloc() -> _NodePtr
  {
    let p = popFresh()
    assert(p != nil)
    assert(p?.pointee.___node_id_ == -2)
    return p!
  }
}

extension UnsafeTree.Header {

  @inlinable
  @inline(__always)
  public mutating func __construct_node(_ k: _Value) -> _NodePtr {
    if destroyCount > 0 {
      let p = ___popRecycle()
      UnsafeNode.initializeValue(p, to: k)
      p.pointee.___needs_deinitialize = true
      return p
    }
    assert(initializedCount < freshPoolCapacity)
    let p = ___node_alloc()
    assert(p != nil)
    assert(p.pointee.___node_id_ == -2)
    // ナンバリングとノード初期化の責務は移動できる(freshPoolUsedCountは使えない）
//    p?.initialize(to: UnsafeNode(___node_id_: initializedCount))
    p.initialize(to: UnsafeNode(___node_id_: initializedCount, __left_: _nullptr,__right_: _nullptr,__parent_: _nullptr))
    UnsafeNode.initializeValue(p, to: k)
    assert(p.pointee.___node_id_ >= 0)
    initializedCount += 1
    return p
  }
}

// TODO: ここに配置するのが適切には思えない。配置場所を再考する
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

// MARK: Predicate

extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___is_garbaged(_ p: _NodePtr) -> Bool {
    // TODO: 方式再検討
    //    p != end && p?.pointee.__parent_ == nil
    // これがなぜ動かないのかわからない
    // 再利用時のフラグ設定漏れだった
    p.pointee.___needs_deinitialize != true
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

// MARK: Index Resolver

extension UnsafeTree {

  /// インデックスをポインタに解決する
  ///
  /// 木が同一の場合、インデックスが保持するポインタを返す。
  /// 木が異なる場合、インデックスが保持するノード番号に対応するポインタを返す。
  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___node_ptr<Index: PointerResolvable>(_ index: Index) -> _NodePtr
  where Index.Tree == UnsafeTree, Index.Pointer == _NodePtr {
    self === index.__tree_ ? index.rawValue : (_header[index.___node_id_] ?? nullptr)
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

extension UnsafeNode {

  @inlinable
  func debugDescription(resolve: (Pointer?) -> Int?) -> String {
    let id = ___node_id_
    let l = resolve(__left_)
    let r = resolve(__right_)
    let p = resolve(__parent_)
    let color = __is_black_ ? "B" : "R"
    #if DEBUG
      let rc = ___recycle_count
    #else
      let rc = -1
    #endif

    return """
      node[\(id)] \(color)
        L: \(l.map(String.init) ?? "nil")
        R: \(r.map(String.init) ?? "nil")
        P: \(p.map(String.init) ?? "nil")
        needsDeinit: \(___needs_deinitialize)
        recycleCount: \(rc)
      """
  }
}

extension UnsafeTree {

  @inlinable
  func _nodeID(_ p: _NodePtr) -> Int? {
    return p.pointee.___node_id_
  }
}

extension UnsafeTree {

  func dumpTree(label: String = "") {
    print("==== UnsafeTree \(label) ====")
    print(" count:", count)
    print(" freshPool:", freshPoolUsedCount, "/", freshPoolCapacity)
    print(" destroyCount:", _header.destroyCount)
    print(" root:", __root.pointee.___node_id_ as Any)
    print(" begin:", __begin_node_.pointee.___node_id_ as Any)

    var it = _header.makeInitializedIterator()
    while let p = it.next() {
      print(
        p.pointee.debugDescription { self._nodeID($0!) }
      )
    }
    print("============================")
  }
}
