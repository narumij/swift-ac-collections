#if DEBUG && false
  // これはつかわないこと
  @testable import RedBlackTreeCollections

  extension RedBlackTreeSet {

    @inlinable
    var __nodes: [___Node] {
      (0..<__tree_.initializedCount).map {
        .init(
          __is_black_: __tree_.__is_black_(_TrackingTag($0)),
          __left_: __tree_.__left_(_TrackingTag($0)),
          __right_: __tree_.__right_(_TrackingTag($0)),
          __parent_: __tree_.__parent_(_TrackingTag($0)))
      }
    }

    @inlinable
    var ___elements: [Element] {
      (0..<__tree_.initializedCount).map {
        __tree_.__value_(_TrackingTag($0))
      }
    }
    @inlinable
    var __begin_node_: _NodePtr {
      get { __tree_.__begin_node_ }
      set { __tree_.__begin_node_ = newValue }
    }
    @inlinable
    var ___header: Tree.Header {
      get { __tree_._buffer.header }
      set { __tree_._buffer.header = newValue }
    }
    @inlinable
    var _count: Int {
      var it = __tree_.__begin_node_
      if it == __tree_.end {
        return 0
      }
      var c = 0
      repeat {
        c += 1
        it = __tree_.__tree_next_iter(it)
      } while it != __tree_.end
      return c
    }
    @inlinable var __left_: _NodePtr {
      get { _end.pointee.__left_ }
      set { _end.pointee.__left_ = newValue }
    }
    // __left_(_:)/__right_(_:)/__root/__root(_:)/__tree_min/__tree_max/
    // __tree_left_rotate/__tree_right_rotate/__tree_balance_after_insertは
    // RedBlackTreeDebugFixture(4型共通)側の実装を利用する。
    @inlinable
    var nullptr: _NodePtr { __tree_.nullptr }
//    @inlinable
//    var end: _NodePtr { __tree_.end }

    /// `_TrackingTag`(配列時代の安定インデックス)から現行の実ポインタへ変換する
    @inlinable
    func ___NodePtr(_ tag: _TrackingTag) -> _NodePtr {
      try! __tree_.__retrieve_(tag).get()
    }

  }

  extension RedBlackTreeSet where Element == Int {

    /// 任意のノード形状(`___Node`配列)と値を、現行の実ポインタ木に直接反映する。
    /// `nodes[i]`/`elements[i]`は`_TrackingTag(i)`に対応する。
    /// 既存の要素数が不足する場合は、`elements`との衝突を避けるため負の番兵値で挿入して枠を確保し、
    /// その後で各ノードの色・左右・親・実際の値を上書きして目的の形状を作る。
    /// 複数のFixtureを同一インスタンスに連続適用する場合(値の重複がある場合)でも安全に動作する。
    @inlinable
    mutating func ___applyFixture(nodes: [___Node], elements: [Element]) {
      precondition(nodes.count == elements.count)
      while __tree_.initializedCount < nodes.count {
        let placeholder = Int.min + __tree_.initializedCount
        _ = __tree_.__insert_unique(placeholder)
      }
      for i in 0..<nodes.count {
        let tag = _TrackingTag(i)
        __tree_.__is_black_(tag, nodes[i].__is_black_)
        __tree_.__left_(tag, nodes[i].__left_)
        __tree_.__right_(tag, nodes[i].__right_)
        __tree_.__parent_(tag, nodes[i].__parent_)
        __tree_.___element(tag, elements[i])
      }
    }
  }
#endif
