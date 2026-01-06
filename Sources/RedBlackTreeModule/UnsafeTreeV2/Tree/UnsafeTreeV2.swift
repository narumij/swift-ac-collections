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

public struct UnsafeTreeV2<Base: ___TreeBase> {

  @inlinable
  internal init(
    _buffer: ManagedBufferPointer<Header, UnsafeNode>,
    isReadOnly: Bool = false
  ) {
    self._buffer = _buffer
    self.isReadOnly = isReadOnly
  }

  public typealias Base = Base
  public typealias Tree = UnsafeTreeV2<Base>
  public typealias Header = UnsafeTreeV2Buffer<Base._Value>.Header
  public typealias Buffer = ManagedBuffer<Header, UnsafeNode>
  public typealias BufferPointer = ManagedBufferPointer<Header, UnsafeNode>
  public typealias _Key = Base._Key
  public typealias _Value = Base._Value
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  public typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>

  @usableFromInline
  var _buffer: BufferPointer

  @usableFromInline
  let isReadOnly: Bool
}

extension UnsafeTreeV2 {

  @inlinable
  public var count: Int { _buffer.header.count }

  #if !DEBUG
    @inlinable
    public var capacity: Int { _buffer.header.freshPoolCapacity }

    @inlinable
    public var initializedCount: Int { _buffer.header.freshPoolUsedCount }
  #else
    @inlinable
    public var capacity: Int {
      get { _buffer.header.freshPoolCapacity }
      set { _buffer.header.freshPoolCapacity = newValue }
    }

    @inlinable
    public var initializedCount: Int {
      get { _buffer.header.freshPoolUsedCount }
      set { _buffer.header.freshPoolUsedCount = newValue }
    }
  #endif
}

// MARK: - 生成

extension UnsafeTreeV2 {

  /// 木の生成を行う
  ///
  /// サイズが0の場合に共有バッファを用いたインスタンスを返す。
  /// ensureUniqueが利用できない場面では他の生成メソッドを利用すること。
  @inlinable
  @inline(__always)
  internal static func create(
    minimumCapacity nodeCapacity: Int
  ) -> UnsafeTreeV2 {
    nodeCapacity == 0
      ? ___create()
      : ___create(minimumCapacity: nodeCapacity)
  }

  /// シングルトンバッファを用いて高速に生成する
  ///
  /// 直接呼ぶ必要はほとんど無い
  @inlinable
  @inline(__always)
  internal static func ___create() -> UnsafeTreeV2 {
    assert(_emptyTreeStorage.header.freshPoolCapacity == 0)
    return UnsafeTreeV2(
      _buffer:
        BufferPointer(
          unsafeBufferObject: _emptyTreeStorage),
      isReadOnly: true)
  }

  /// 通常の生成
  ///
  /// ensureUniqueが利用できない場面に限って直接呼ぶようにすること
  @inlinable
  @inline(__always)
  internal static func ___create(
    minimumCapacity nodeCapacity: Int
  ) -> UnsafeTreeV2 {
    create(
      unsafeBufferObject:
        UnsafeTreeV2Buffer<Base._Value>
        .create(minimumCapacity: nodeCapacity))
  }

  @inlinable
  @inline(__always)
  internal static func create(unsafeBufferObject buffer: AnyObject)
    -> UnsafeTreeV2
  {
    return UnsafeTreeV2(
      _buffer:
        BufferPointer(
          unsafeBufferObject: buffer))
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func copy(minimumCapacity: Int? = nil) -> UnsafeTreeV2 {
    assert(check())
    // 予定サイズを確定させる
    let newCapacity = max(minimumCapacity ?? 0, initializedCount)
    // 予定サイズの木を作成する
    let tree = UnsafeTreeV2.___create(minimumCapacity: newCapacity)
    // freshPool内のfreshBucketは0〜1個となる
    // CoW後の性能維持の為、freshBucket数は1を越えないこと
    // バケット数が1に保たれていると、フォールバックの___node_idによるアクセスがO(1)になる
    assert(tree._buffer.header.freshBucketCount <= 1)

    // 複数のバケットを新しい一つのバケットに連番通りにまとめ、その他管理情報をそのまま移す
    // アドレスやバケット配置は変化するがそれ以外は変わらない状態となる
    _buffer.withUnsafeMutablePointers { source_header, source_end in

      tree._buffer.withUnsafeMutablePointers { _header_ptr, _end_ptr in

        @inline(__always)
        func __ptr_(_ ptr: _NodePtr) -> _NodePtr {
          let index = ptr.pointee.___node_id_
          return switch index {
          case .nullptr:
            UnsafeNode.nullptr
          case .end:
            _end_ptr
          default:
            _header_ptr.pointee[index]
          }
        }

        @inline(__always)
        func node(_ s: UnsafeNode) -> UnsafeNode {
          // 値は別途管理
          return .init(
            ___node_id_: s.___node_id_,
            __left_: __ptr_(s.__left_),
            __right_: __ptr_(s.__right_),
            __parent_: __ptr_(s.__parent_),
            __is_black_: s.__is_black_,
            ___needs_deinitialize: s.___needs_deinitialize)
        }

        var source_nodes = source_header.pointee.makeFreshPoolIterator()

        while let s = source_nodes.next(), let d = _header_ptr.pointee.popFresh() {
          // ノードを初期化
          d.initialize(to: node(s.pointee))
          // 値を初期化
          UnsafeNode.initializeValue(d, to: UnsafeNode.value(s) as _Value)
        }

        // ルートノードを設定
        _end_ptr.pointee.__left_ = __ptr_(source_end.pointee.__left_)

        // __begin_nodeを初期化
        _header_ptr.pointee.__begin_node_ = __ptr_(source_header.pointee.__begin_node_)

        // その他管理情報をコピー
        _header_ptr.pointee.freshPoolUsedCount = source_header.pointee.freshPoolUsedCount
        _header_ptr.pointee.recycleCount = source_header.pointee.recycleCount
        _header_ptr.pointee.recycleHead = __ptr_(
          source_header.pointee.recycleHead)
        assert(
          _header_ptr.pointee.recycleHead.pointee.___node_id_
            == source_header.pointee.recycleHead.pointee.___node_id_)

        #if AC_COLLECTIONS_INTERNAL_CHECKS
          _header_ptr.pointee.copyCount = source_header.pointee.copyCount &+ 1
        #endif
      }
    }

    assert(equiv(with: tree))
    assert(tree.check())

    return tree
  }
}

extension UnsafeTreeV2 {

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

extension UnsafeTreeV2 {

  // TODO: grow関連の名前が混乱気味なので整理する
  @inlinable
  @inline(__always)
  public func ensureCapacity(_ newCapacity: Int) {
    guard capacity < newCapacity else { return }
    _buffer.withUnsafeMutablePointerToHeader {
      $0.pointee.pushFreshBucket(capacity: newCapacity - capacity)
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  func clear() {
    end.pointee.__left_ = nullptr
    _buffer.withUnsafeMutablePointerToHeader {
      $0.pointee.clear(_end_ptr: __end_node)
    }
  }
}

// TODO: ここに配置するのが適切には思えない。配置場所を再考する
extension UnsafeTreeV2 {

  /// O(1)
  @inlinable
  @inline(__always)
  internal func __eraseAll() {
    clear()
    _buffer.withUnsafeMutablePointerToHeader {
      $0.pointee.___flushRecyclePool()
    }
  }
}

// MARK: Predicate

extension UnsafeTreeV2 {

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

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal var ___is_empty: Bool {
    count == 0
  }
}

// MARK: Refresh Pool Iterator

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  func makeFreshPoolIterator() -> UnsafeNodeFreshPoolIterator<_Value> {
    return UnsafeNodeFreshPoolIterator<_Value>(bucket: _buffer.header.freshBucketHead)
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  func makeFreshBucketIterator() -> UnsafeNodeFreshBucketIterator<_Value> {
    return UnsafeNodeFreshBucketIterator<_Value>(bucket: _buffer.header.freshBucketHead)
  }
}

// MARK: Index Resolver

extension UnsafeTreeV2 {

  /// インデックスをポインタに解決する
  ///
  /// 木が同一の場合、インデックスが保持するポインタを返す。
  /// 木が異なる場合、インデックスが保持するノード番号に対応するポインタを返す。
  @inlinable
  @inline(__always)
  internal func ___node_ptr(_ index: Index) -> _NodePtr
  where Index.Tree == UnsafeTreeV2, Index._NodePtr == _NodePtr {
    #if true
      // .endが考慮されていないことがきになったが、テストが通ってしまっているので問題が見つかるまで保留
      // endはシングルトン的にしたい気持ちもある
      @inline(__always)
      func ___NodePtr(_ p: Int) -> _NodePtr {
        switch p {
        case .nullptr:
          return nullptr
        case .end:
          return end
        default:
          return _buffer.header[p]
        }
      }
      return self.isIdentical(to: index.__tree_) ? index.rawValue : ___NodePtr(index.___node_id_)
    #else
      self === index.__tree_ ? index.rawValue : (_header[index.___node_id_])
    #endif
  }
}

extension UnsafeTreeV2 {

  #if AC_COLLECTIONS_INTERNAL_CHECKS
    /// CoWの発火回数を観察するためのプロパティ
    @usableFromInline
    internal var copyCount: UInt {
      get { _buffer.header.copyCount }
      set { _buffer.header.copyCount = newValue }
    }
  #endif
}

// MARK: -

extension UnsafeTreeV2 {

  @inlinable
  func _nodeID(_ p: _NodePtr) -> Int? {
    return p.pointee.___node_id_
  }
}

extension UnsafeTreeV2 {

  func dumpTree(label: String = "") {
    print("==== UnsafeTree \(label) ====")
    print(" count:", count)
    print(" freshPool:", _buffer.header.freshPoolActualCount, "/", capacity)
    print(" destroyCount:", _buffer.header.recycleCount)
    print(" root:", __root.pointee.___node_id_ as Any)
    print(" begin:", __begin_node_.pointee.___node_id_ as Any)

    var it = makeFreshPoolIterator()
    while let p = it.next() {
      print(
        p.pointee.debugDescription { self._nodeID($0!) }
      )
    }
    print("============================")
  }
}
