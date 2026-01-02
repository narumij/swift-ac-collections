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
      end.deinitialize(count: 1)
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
    _read { yield _end_ptr.pointee }
    _modify { yield &_end_ptr.pointee }
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
    let storage = Tree.create(minimumCapacity: 1) { managedBuffer in
      return managedBuffer.withUnsafeMutablePointerToElements { _end_ptr in
        // endノード用に初期化する
        _end_ptr.initialize(to: UnsafeNode(___node_id_: .end))
        // ヘッダーを準備する
        var header = Header(_end_ptr: _end_ptr)
        // ノードを確保する
        if nodeCapacity > 0 {
          header.pushFreshBucket(capacity: nodeCapacity)
        }
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

        @inline(__always)
        func __node_ptr(_ index: Int) -> _NodePtr {
          index == .end ? _end_ptr : _header_ptr.pointee[index]
        }

        @inline(__always)
        func apply(_ d: inout UnsafeNode, _ s: inout UnsafeNode) {
          // endにも使うので___node_idには触らない
          if let l = s.__left_?.pointee.___node_id_ {
            assert(l != -2)
            d.__left_ = __node_ptr(l)
          }
          if let r = s.__right_?.pointee.___node_id_ {
            assert(r != -2)
            d.__right_ = __node_ptr(r)
          }
          if let p = s.__parent_?.pointee.___node_id_ {
            assert(p != -2)
            d.__parent_ = __node_ptr(p)
          }
          d.__is_black_ = s.__is_black_
          // 値は別途管理
        }

        var source_nodes = source_header.pointee.makeInitializedIterator()
        var ___node_id_ = 0

        while let s = source_nodes.next(), let d = _header_ptr.pointee.popFresh() {
          // メモリを連番で初期化
          d.initialize(to: UnsafeNode(___node_id_: ___node_id_))
          // 値を初期化
          UnsafePair<_Value>.__value_ptr(d)
            .initialize(to: UnsafePair<_Value>.__value_ptr(s).pointee)
          // 残りを初期化
          apply(&d.pointee, &s.pointee)

          ___node_id_ += 1
        }

        // 最終ノード番号が初期化済み数と一致すること
        assert(___node_id_ == source_header.pointee.initializedCount)

        // endノードを初期化
        apply(&_end_ptr.pointee, &source_end.pointee)

        // __begin_nodeを初期化
        if let b = source_header.pointee.__begin_node_?.pointee.___node_id_ {
          _header_ptr.pointee.__begin_node_ = __node_ptr(b)
        }

        // その他管理情報をコピー
        _header_ptr.pointee.initializedCount = source_header.pointee.initializedCount
        _header_ptr.pointee.destroyCount = source_header.pointee.destroyCount
        if let l = source_header.pointee.destroyNode?.pointee.___node_id_ {
          _header_ptr.pointee.destroyNode = __node_ptr(l)
        }

        #if AC_COLLECTIONS_INTERNAL_CHECKS
          _header_ptr.pointee.copyCount = source_header.pointee.copyCount &+ 1
        #endif
      }
    }

    assert(tree.__tree_invariant(tree.__root))
    assert(tree.count >= 0)
    assert(tree.count <= tree._header.initializedCount)
    assert(tree.count <= tree.freshPoolCapacity)
    assert(tree._header.initializedCount <= tree.freshPoolCapacity)

    assert(__root?.pointee.___node_id_ == tree.__root?.pointee.___node_id_)
    assert(__begin_node_?.pointee.___node_id_ == tree.__begin_node_?.pointee.___node_id_)
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
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>?
  public typealias _NodeRef = UnsafeMutablePointer<_NodePtr>
}

extension UnsafeTree {

  public struct Header: UnsafeNodeFreshPool, UnsafeNodeRecyclePool {
    public typealias _NodePtr = UnsafeTree._NodePtr
    public typealias _Value = UnsafeTree._Value
    @inlinable
    @inline(__always)
    internal init(_end_ptr: _NodePtr) {
      self.__begin_node_ = _end_ptr
      self.freshBucketDispose = Self.___disposeBucketFunc
    }
    public var __begin_node_: _NodePtr
    @usableFromInline var initializedCount: Int = 0
    @usableFromInline var destroyNode: _NodePtr = nil
    @usableFromInline var destroyCount: Int = 0
    @usableFromInline var freshBucketHead: ReserverHeaderPointer?
    @usableFromInline var freshBucketCurrent: ReserverHeaderPointer?
    @usableFromInline var freshBucketLast: ReserverHeaderPointer?
    @usableFromInline var freshBucketCount: Int = 0
    @usableFromInline var freshPoolCapacity: Int = 0
    @usableFromInline let freshBucketDispose: (ReserverHeaderPointer?) -> Void
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
  public var freshPoolCapacity: Int { _header.freshPoolCapacity }

  // これはinitializedCountと同一の内容だが計算量が異なるため代用はできない。
  @nonobjc
  @inlinable
  @inline(__always)
  public var freshPoolUsedCount: Int { _header.freshPoolUsedCount }
}

extension UnsafeTree {
  
  // _NodePtrがIntだった頃の名残
  @nonobjc
  @inlinable
  internal subscript(_ pointer: _NodePtr) -> _Value {
    @inline(__always) _read {
      assert(___initialized_contains(pointer))
      yield UnsafePair<_Value>.__value_ptr(pointer)!.pointee
    }
    @inline(__always) _modify {
      assert(___initialized_contains(pointer))
      yield &UnsafePair<_Value>.__value_ptr(pointer)!.pointee
    }
  }
}

extension UnsafeTree {

  // TODO: grow関連の名前が混乱気味なので整理する
  @nonobjc
  @inlinable
  @inline(__always)
  public func ensureCapacity(_ newCapacity: Int) {
    guard freshPoolCapacity < newCapacity else { return }
    _header.pushFreshBucket(capacity: newCapacity - freshPoolCapacity)
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
    _end.__left_ = nil
    _header.clear(_end_ptr: _end_ptr)
  }
}

extension UnsafeTree {

  // TODO: いろいろ試すための壁で、いまは余り意味が無いのでタイミングでインライン化する
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
}

// これを動かすとなぜかコンパイルエラーになる
extension UnsafeTree {

  @nonobjc
  @inlinable
  @inline(__always)
  public func __construct_node(_ k: _Value) -> _NodePtr {
    if _header.destroyCount > 0 {
      let p = _header.___popRecycle()
      UnsafePair<_Value>.__value_ptr(p)!.initialize(to: k)
      return p
    }
    assert(_header.initializedCount < freshPoolCapacity)
    let p = ___node_alloc()
    assert(p != nil)
    assert(p?.pointee.___node_id_ == -2)
    // ナンバリングとノード初期化の責務は移動できる(freshPoolUsedCountは使えない）
    p?.initialize(to: UnsafeNode(___node_id_: _header.initializedCount))
    UnsafePair<_Value>.__value_ptr(p)!.initialize(to: k)
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
    p != end && p?.pointee.__parent_ == nil
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
