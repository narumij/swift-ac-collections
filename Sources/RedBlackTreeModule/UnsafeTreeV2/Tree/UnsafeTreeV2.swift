public typealias ___TreeBase = ValueComparer & CompareTrait & ThreeWayComparator

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
  public typealias _Key = Base._Key
  public typealias _Value = Base._Value
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  public typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>

  @usableFromInline
  var _buffer: ManagedBufferPointer<Header, UnsafeNode>

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
    public var initializedCount: Int { _buffer.header.initializedCount }
  #else
    @inlinable
    public var capacity: Int {
      get { _buffer.header.freshPoolCapacity }
      set { _buffer.header.freshPoolCapacity = newValue }
    }

    @inlinable
    public var initializedCount: Int {
      get { _buffer.header.initializedCount }
      set { _buffer.header.initializedCount = newValue }
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
    return .init(
      _buffer:
        .init(unsafeBufferObject: _emptyTreeStorage),
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
    return UnsafeTreeV2(
      _buffer:
        ManagedBufferPointer(
          unsafeBufferObject:
            UnsafeTreeV2Buffer<Base._Value>
            .create(minimumCapacity: nodeCapacity)))
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func copy(minimumCapacity: Int? = nil) -> UnsafeTreeV2 {
    assert(__tree_invariant(__root))
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
        func __node_ptr(_ index: Int) -> _NodePtr {
          switch index {
          case .nullptr:
            UnsafeNode.nullptr
          case .end:
            _end_ptr
          default:
            _header_ptr.pointee[index]
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
          d.initialize(to: UnsafeNode(___node_id_: ___node_id_))
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
        _header_ptr.pointee.__begin_node_ = __node_ptr(
          source_header.pointee.__begin_node_.pointee.___node_id_)

        // その他管理情報をコピー
        _header_ptr.pointee.initializedCount = source_header.pointee.initializedCount
        _header_ptr.pointee.destroyCount = source_header.pointee.destroyCount
        _header_ptr.pointee.destroyNode = __node_ptr(
          source_header.pointee.destroyNode.pointee.___node_id_)
        assert(
          _header_ptr.pointee.destroyNode.pointee.___node_id_
            == source_header.pointee.destroyNode.pointee.___node_id_)

        #if AC_COLLECTIONS_INTERNAL_CHECKS
          _header_ptr.pointee.copyCount = source_header.pointee.copyCount &+ 1
        #endif
      }
    }

    assert(tree.__tree_invariant(tree.__root))
    assert(tree.end.pointee.___needs_deinitialize == true)
    assert(tree.count >= 0)
    assert(tree.count <= tree.initializedCount)
    assert(tree.count <= tree.capacity)
    assert(tree.initializedCount <= tree.capacity)

    assert(__root.pointee.___node_id_ == tree.__root.pointee.___node_id_)
    assert(__begin_node_.pointee.___node_id_ == tree.__begin_node_.pointee.___node_id_)
    assert(_buffer.header.destroyCount == tree._buffer.header.destroyCount)
    assert(_buffer.header.___destroyNodes == tree._buffer.header.___destroyNodes)

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
    print(" destroyCount:", _buffer.header.destroyCount)
    print(" root:", __root.pointee.___node_id_ as Any)
    print(" begin:", __begin_node_.pointee.___node_id_ as Any)

    var it = _buffer.header.makeInitializedIterator()
    while let p = it.next() {
      print(
        p.pointee.debugDescription { self._nodeID($0!) }
      )
    }
    print("============================")
  }
}
