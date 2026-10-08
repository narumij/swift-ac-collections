import Algorithms
import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if DEBUG
  /// Legacyテスト側にも同名protocolがあるため、原木側を完全修飾して既定実装を検証するfixture。
  private final class TreeFoundamentalBeginFixture: RedBlackTreeCollections.BeginProtocol {
    typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
    typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
    var __begin_node_: _NodePtr

    init(__begin_node_: _NodePtr) {
      self.__begin_node_ = __begin_node_
    }
  }
#endif

/// `TreeNodeOnlyFixture`を使った、現行の生木アルゴリズム(`_ptr`系プロトコル)への直接テスト。
/// `Legacy/ArrayBased`は`_std`系(独立した配列実装)であり、Sourcesが実際に使う`_ptr`系
/// プロトコルとは別物なので、この基本層の検証には使えない。
@available(anyAppleOS 26.0, *)
final class TreeFoundamentalTests: TreeTestCase, _UnsafeNodePtrType {

  func makeFixture() -> TreeNodeOnlyFixture {
    .makeEmpty()
  }

  /// 廃止予定の`begin()`も、現存する間は`__begin_node_`をそのまま返すこと。
  @available(*, deprecated)
  func testDeprecatedBegin_delegatesToBeginNode() {
    #if DEBUG
      let fixture = TreeFoundamentalBeginFixture(__begin_node_: UnsafeNode.template)
      XCTAssertEqual(fixture.begin(), UnsafeNode.template)
    #endif
  }

  /// 空のFixtureでも`invariant()`が不変条件を満たすこと
  /// (空の木は`__tree_invariant`の定義上、自明にtrueになる)。
  func testEmptyInvariant() {
    var fixture = makeFixture()
    XCTAssertEqual(fixture.invariant(), 1)
  }

  /// 単一要素を挿入した直後、rootは黒に補正されること
  /// (RBTの不変条件: rootは常に黒)。
  func testSingleInsertBecomesBlackRoot() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    let n0 = fixture.node(0)

    // n0をendの左(=root)として物理的にリンクする
    n0.__left_ = .nullptr
    n0.__right_ = .nullptr
    n0.__is_black_ = false
    n0.__parent_ = end
    end.__left_ = n0

    fixture._ptr__tree_balance_after_insert(end.__left_, n0)

    XCTAssertTrue(n0.__is_black_)
    XCTAssertTrue(fixture.__tree_invariant(end.__left_))
  }

  /// 3要素の正しいRBTは挿入順に関わらず一意の形(黒根=中央値、赤葉2つ=最小・最大値)になる。
  /// Legacy/ArrayBasedTests.testBalancing1と同じ考え方で、`_ptr`系の実アルゴリズムを検証する。
  func testThreeInsertsProduceTheUniqueShape() {
    // 挿入順: 値1→2→3をこの順で挿入した場合の木構造(手動リンク)を再現する。
    // ノード0=値1, ノード1=値2, ノード2=値3として、挿入順どおりに親子付けする。
    var fixture = makeFixture()
    let end = fixture.endPtr()
    let n0 = fixture.node(0)  // 1番目に挿入(値1)
    let n1 = fixture.node(1)  // 2番目に挿入(値2)
    let n2 = fixture.node(2)  // 3番目に挿入(値3)

    func resetLeaf(_ p: _NodePtr) {
      p.__left_ = .nullptr
      p.__right_ = .nullptr
      p.__is_black_ = false
    }

    // 1番目: 値1をrootとして挿入
    resetLeaf(n0)
    n0.__parent_ = end
    end.__left_ = n0
    fixture._ptr__tree_balance_after_insert(end.__left_, n0)

    // 2番目: 値2は値1より大きいので、値1の右に挿入
    resetLeaf(n1)
    n1.__parent_ = n0
    n0.__right_ = n1
    fixture._ptr__tree_balance_after_insert(end.__left_, n1)

    // 3番目: 値3は値1より大きく値2より大きいので、挿入時点での値2の右に挿入
    // (2番目挿入後の実木構造上の右端ノードに繋ぐ)
    let rightMost = fixture.__tree_max(end.__left_)
    resetLeaf(n2)
    n2.__parent_ = rightMost
    rightMost.__right_ = n2
    fixture._ptr__tree_balance_after_insert(end.__left_, n2)

    XCTAssertTrue(fixture.__tree_invariant(end.__left_))

    let root = end.__left_
    XCTAssertEqual(root, n1, "中央値(2番目に挿入した値2のノード)がrootになるはず")
    XCTAssertTrue(root.__is_black_)
    XCTAssertEqual(root.__left_, n0)
    XCTAssertEqual(root.__right_, n2)
    XCTAssertFalse(root.__left_.__is_black_)
    XCTAssertFalse(root.__right_.__is_black_)
    XCTAssertEqual(root.__left_.__left_, .nullptr)
    XCTAssertEqual(root.__left_.__right_, .nullptr)
    XCTAssertEqual(root.__right_.__left_, .nullptr)
    XCTAssertEqual(root.__right_.__right_, .nullptr)
  }

  // MARK: - Helpers for bulk insert/remove coverage

  /// BST比較挿入(+リバランス)を行う。値の対応は`values`辞書で管理する
  /// (`UnsafeNode`自体にはpayloadが無いため)。
  fileprivate func insert(
    _ fixture: inout TreeNodeOnlyFixture,
    values: inout [_NodePtr: Int],
    end: _NodePtr,
    nodeIndex: Int,
    value: Int
  ) {
    let newNode = fixture.node(nodeIndex)
    // ___is_null/___is_end/___is_rootはtracking_tagで判定するため、
    // nullptr初期値(.nullptr)のままだと実ノードなのに「null」と誤判定される。
    newNode.pointee.___tracking_tag = _TrackingTag(nodeIndex)
    newNode.__left_ = .nullptr
    newNode.__right_ = .nullptr
    newNode.__is_black_ = false
    values[newNode] = value

    if end.__left_ == .nullptr {
      newNode.__parent_ = end
      end.__left_ = newNode
    } else {
      var cur = end.__left_
      while true {
        if value < values[cur]! {
          if cur.__left_ == .nullptr {
            cur.__left_ = newNode
            newNode.__parent_ = cur
            break
          }
          cur = cur.__left_
        } else {
          if cur.__right_ == .nullptr {
            cur.__right_ = newNode
            newNode.__parent_ = cur
            break
          }
          cur = cur.__right_
        }
      }
    }
    fixture._ptr__tree_balance_after_insert(end.__left_, newNode)
  }

  fileprivate func find(
    values: [_NodePtr: Int], end: _NodePtr, target: Int
  ) -> _NodePtr {
    var cur = end.__left_
    while cur != .nullptr {
      let v = values[cur]!
      if target == v { return cur }
      cur = target < v ? cur.__left_ : cur.__right_
    }
    fatalError("value \(target) not found")
  }

  fileprivate func sortedValues(
    values: [_NodePtr: Int], end: _NodePtr
  ) -> [Int] {
    guard end.__left_ != .nullptr else { return [] }
    var result: [Int] = []
    var p = __tree_min(end.__left_)
    while p != end {
      result.append(values[p]!)
      p = __tree_next_iter(p)
    }
    return result
  }

  // MARK: - unsafe_node+pointer+algorithm.swift (free functions) coverage

  /// フィクスチャのメソッド越しではなく、`unsafe_node+pointer+algorithm.swift`の
  /// フリー関数(`__tree_min`/`__tree_max`/`__tree_next`/`__tree_next_iter`/`__tree_prev_iter`)を
  /// 直接呼んで検証する。
  func testFreeFunctionAlgorithms_traverseInSortedOrder() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    var values: [_NodePtr: Int] = [:]

    for (i, v) in [30, 10, 50, 20, 40].enumerated() {
      insert(&fixture, values: &values, end: end, nodeIndex: i, value: v)
    }

    let root = end.__left_
    XCTAssertTrue(__tree_invariant(root))

    XCTAssertEqual(values[__tree_min(root)], 10)
    XCTAssertEqual(values[__tree_max(root)], 50)

    // __tree_next / __tree_next_iterで昇順に走査できること
    var forward: [Int] = []
    var p = __tree_min(root)
    while true {
      forward.append(values[p]!)
      if p == __tree_max(root) { break }
      p = __tree_next(p)
    }
    XCTAssertEqual(forward, [10, 20, 30, 40, 50])

    var forwardIter: [Int] = []
    p = __tree_min(root)
    while p != end {
      forwardIter.append(values[p]!)
      p = __tree_next_iter(p)
    }
    XCTAssertEqual(forwardIter, [10, 20, 30, 40, 50])

    // __tree_prev_iterで降順に走査できること
    var backward: [Int] = []
    p = end
    repeat {
      p = __tree_prev_iter(p)
      backward.append(values[p]!)
    } while p != __tree_min(root)
    XCTAssertEqual(backward, [50, 40, 30, 20, 10])

    XCTAssertTrue(__tree_is_left_child(root.__left_))
    XCTAssertFalse(__tree_is_left_child(root.__right_))
  }

  // MARK: - unsafe_tree+algorithm.swift (protocol methods) coverage

  /// Legacy/ArrayBasedTests.testRotateと同じ5ノード構造で、`_ptr`系の
  /// `__tree_left_rotate`/`__tree_right_rotate`が正しく可逆な変形をすることを検証する。
  func testExplicitLeftAndRightRotateAreInverses() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    let n0 = fixture.node(0)
    let n1 = fixture.node(1)
    let n2 = fixture.node(2)
    let n3 = fixture.node(3)
    let n4 = fixture.node(4)

    // n0(黒, L=n1, R=n2), n1(赤,葉), n2(赤, L=n3, R=n4), n3(黒,葉), n4(黒,葉)
    n0.__is_black_ = true
    n0.__left_ = n1
    n0.__right_ = n2
    n0.__parent_ = end
    end.__left_ = n0

    n1.__is_black_ = false
    n1.__left_ = .nullptr
    n1.__right_ = .nullptr
    n1.__parent_ = n0

    n2.__is_black_ = false
    n2.__left_ = n3
    n2.__right_ = n4
    n2.__parent_ = n0

    n3.__is_black_ = true
    n3.__left_ = .nullptr
    n3.__right_ = .nullptr
    n3.__parent_ = n2

    n4.__is_black_ = true
    n4.__left_ = .nullptr
    n4.__right_ = .nullptr
    n4.__parent_ = n2

    fixture.__tree_left_rotate(n0)

    XCTAssertEqual(end.__left_, n2, "左回転後はn2がrootになる")
    XCTAssertEqual(n2.__left_, n0)
    XCTAssertEqual(n2.__right_, n4)
    XCTAssertEqual(n0.__left_, n1)
    XCTAssertEqual(n0.__right_, n3)
    XCTAssertEqual(n0.__parent_, n2)
    XCTAssertEqual(n3.__parent_, n0)

    fixture.__tree_right_rotate(n2)

    XCTAssertEqual(end.__left_, n0, "右回転で元の形に戻る")
    XCTAssertEqual(n0.__left_, n1)
    XCTAssertEqual(n0.__right_, n2)
    XCTAssertEqual(n2.__left_, n3)
    XCTAssertEqual(n2.__right_, n4)
  }

  /// 祖父(黒)-親(赤)-叔父(赤)という、いわゆる「叔父が赤」の再配色ケースを明示的に作る。
  /// このケースでは回転せず、親と叔父を黒、祖父を赤にして上に伝播する。
  func testBalanceAfterInsert_uncleRedRecolorsWithoutRotation() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    let grandparent = fixture.node(0)
    let parent = fixture.node(1)
    let uncle = fixture.node(2)
    let child = fixture.node(3)

    grandparent.__is_black_ = true
    grandparent.__left_ = parent
    grandparent.__right_ = uncle
    grandparent.__parent_ = end
    end.__left_ = grandparent

    parent.__is_black_ = false
    parent.__left_ = .nullptr
    parent.__right_ = .nullptr
    parent.__parent_ = grandparent

    uncle.__is_black_ = false
    uncle.__left_ = .nullptr
    uncle.__right_ = .nullptr
    uncle.__parent_ = grandparent

    // childをparentの左に新規挿入したことにする
    child.__is_black_ = false
    child.__left_ = .nullptr
    child.__right_ = .nullptr
    child.__parent_ = parent
    parent.__left_ = child

    fixture._ptr__tree_balance_after_insert(end.__left_, child)

    XCTAssertTrue(fixture.__tree_invariant(end.__left_))
    XCTAssertEqual(end.__left_, grandparent, "回転していないのでrootは変わらない")
    XCTAssertTrue(parent.__is_black_, "親は黒に再配色される")
    XCTAssertTrue(uncle.__is_black_, "叔父は黒に再配色される")
    XCTAssertTrue(grandparent.__is_black_, "祖父はrootなので黒のまま(伝播先が無い)")
    XCTAssertFalse(child.__is_black_)
  }

  // MARK: - Bulk stress coverage for rotate / balance / remove

  /// 昇順・降順・ジグザグの3通りの挿入順で31要素を挿入し、挿入のたびに
  /// `__tree_invariant`を満たし続けること(分岐を手で導出せず、多様な形を機械的に確認する)。
  func testBulkInsertVariousOrdersMaintainInvariant() {
    let orders: [[Int]] = [
      Array(0..<31),
      Array((0..<31).reversed()),
      (0..<31).map { $0 % 2 == 0 ? $0 : 30 - $0 },  // ジグザグ
    ]

    for order in orders {
      var fixture = makeFixture()
      let end = fixture.endPtr()
      var values: [_NodePtr: Int] = [:]

      for (i, v) in order.enumerated() {
        insert(&fixture, values: &values, end: end, nodeIndex: i, value: v)
        XCTAssertTrue(fixture.__tree_invariant(end.__left_), "order=\(order), i=\(i)")
      }

      XCTAssertEqual(
        sortedValues(values: values, end: end), Array(0..<31), "order=\(order)")
    }
  }

  /// 31要素を固定順(昇順)で挿入した後、昇順・降順・ジグザグの3通りの削除順で全削除し、
  /// 削除のたびに`__tree_invariant`を満たし続けること。
  func testBulkRemoveVariousOrdersMaintainInvariant() {
    let removalOrders: [[Int]] = [
      Array(0..<31),
      Array((0..<31).reversed()),
      (0..<31).map { $0 % 2 == 0 ? $0 : 30 - $0 },
    ]

    for removalOrder in removalOrders {
      var fixture = makeFixture()
      let end = fixture.endPtr()
      var values: [_NodePtr: Int] = [:]

      // 挿入順は固定(昇順)。削除順のほうをordersごとに変えて検証する。
      for (i, v) in (0..<31).enumerated() {
        insert(&fixture, values: &values, end: end, nodeIndex: i, value: v)
      }

      for target in removalOrder {
        let node = find(values: values, end: end, target: target)
        fixture._ptr__tree_remove(end.__left_, node)
        values.removeValue(forKey: node)

        XCTAssertTrue(fixture.__tree_invariant(end.__left_), "target=\(target)")
      }

      XCTAssertTrue(values.isEmpty)
      XCTAssertEqual(end.__left_, .nullptr)
    }
  }

  // MARK: - "細かいやつ"(ref / slow walk / プロトコル版next・prev・leaf)のカバレッジ

  /// `__left_ref`/`__right_ref`(`_NodeRef`経由の読み書き)と、
  /// `__slow_end()`/`__slow_begin()`(親を辿ってend/beginを求める経路)を検証する。
  func testNodeRefsAndSlowWalks() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    var values: [_NodePtr: Int] = [:]

    for (i, v) in [20, 10, 30].enumerated() {
      insert(&fixture, values: &values, end: end, nodeIndex: i, value: v)
    }
    let root = end.__left_

    // __left_ref / __right_ref: 参照経由の読み取りが実体と一致し、書き込みが反映される
    XCTAssertEqual(root.__left_ref.pointee, root.__left_)
    XCTAssertEqual(root.__right_ref.pointee, root.__right_)

    let originalLeft = root.__left_
    let placeholder = fixture.node(3)
    root.__left_ref.pointee = placeholder
    XCTAssertEqual(root.__left_, placeholder, "refへの書き込みが実体に反映されること")
    root.__left_ref.pointee = originalLeft
    XCTAssertEqual(root.__left_, originalLeft, "書き戻しでもとに戻ること")

    // __slow_end() / __slow_begin(): どのノードから辿っても同じend/beginに到達する
    XCTAssertEqual(root.__slow_end(), end)
    XCTAssertEqual(root.__left_.__slow_end(), end)
    XCTAssertEqual(root.__right_.__slow_end(), end)
    XCTAssertEqual(values[root.__slow_begin()], 10, "beginは最小値のノード")
  }

  /// プロトコル版(`fixture.__tree_next_iter`等)を、フリー関数版とは別に直接呼んで
  /// 網羅する。多段の親上りが発生する程度の大きさの木を使う。
  func testProtocolTraversalHelpers_nextIterPrevIterLeaf() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    var values: [_NodePtr: Int] = [:]

    for (i, v) in (0..<15).enumerated() {
      insert(&fixture, values: &values, end: end, nodeIndex: i, value: v)
    }
    let root = end.__left_

    var forward: [Int] = []
    var p = fixture.__tree_min(root)
    while p != end {
      forward.append(values[p]!)
      p = fixture.__tree_next_iter(p)
    }
    XCTAssertEqual(forward, Array(0..<15))

    var backward: [Int] = []
    p = end
    repeat {
      p = fixture.__tree_prev_iter(p)
      backward.append(values[p]!)
    } while p != fixture.__tree_min(root)
    XCTAssertEqual(backward, Array((0..<15).reversed()))

    // __tree_next: __tree_next_iterと同じ経路(複数階層の親上りを含む)を通る
    var forwardNext: [Int] = []
    p = fixture.__tree_min(root)
    while true {
      forwardNext.append(values[p]!)
      if p == fixture.__tree_max(root) { break }
      p = fixture.__tree_next(p)
    }
    XCTAssertEqual(forwardNext, Array(0..<15))

    let leaf = fixture.__tree_leaf(root)
    XCTAssertEqual(leaf.__left_, .nullptr)
    XCTAssertEqual(leaf.__right_, .nullptr)
  }

  // MARK: - balance/removeの全網羅を狙う順列総当たりテスト

  /// 6要素の挿入順を全順列(6! = 720通り)で試し、それぞれ4種類の削除順で全削除する。
  /// 個々の分岐を手で導出するのではなく、あらゆる木の形を総当たりすることで
  /// `_ptr__tree_balance_after_insert`/`_ptr__tree_remove`の分岐網羅を狙う。
  func testExhaustivePermutations_insertAndRemoveMaintainInvariant() {
    let n = 6
    let base = Array(0..<n)

    for insertOrder in base.permutations() {
      let removalOrders: [[Int]] = [
        Array(0..<n),
        Array((0..<n).reversed()),
        insertOrder,
        Array(insertOrder.reversed()),
      ]

      for removalOrder in removalOrders {
        var fixture = makeFixture()
        let end = fixture.endPtr()
        var values: [_NodePtr: Int] = [:]

        for (i, v) in insertOrder.enumerated() {
          insert(&fixture, values: &values, end: end, nodeIndex: i, value: v)
        }
        XCTAssertTrue(
          fixture.__tree_invariant(end.__left_),
          "insertOrder=\(insertOrder)")

        for target in removalOrder {
          let node = find(values: values, end: end, target: target)
          fixture._ptr__tree_remove(end.__left_, node)
          values.removeValue(forKey: node)
          XCTAssertTrue(
            fixture.__tree_invariant(end.__left_),
            "insertOrder=\(insertOrder), removalOrder=\(removalOrder), target=\(target)")
        }
        XCTAssertTrue(values.isEmpty)
      }
    }
  }

  // MARK: - unsafe_node+pointer+validation.swift

  /// `___is_null`/`___is_end`/`___is_root`が、nullptr・end・root・通常ノードそれぞれで
  /// 正しい真偽値を返すこと。
  func testValidation_isNullIsEndIsRoot() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    var values: [_NodePtr: Int] = [:]
    for (i, v) in [20, 10, 30].enumerated() {
      insert(&fixture, values: &values, end: end, nodeIndex: i, value: v)
    }
    let root = end.__left_

    XCTAssertTrue(UnsafeNode.nullptr.___is_null)
    XCTAssertFalse(UnsafeNode.nullptr.___is_end)
    XCTAssertFalse(UnsafeNode.nullptr.___is_root, "nullptr自身の親はnullptrなので、___is_end判定がfalseになりrootでもない")

    XCTAssertTrue(end.___is_end)
    XCTAssertFalse(end.___is_null)

    XCTAssertFalse(root.___is_null)
    XCTAssertFalse(root.___is_end)
    XCTAssertTrue(root.___is_root, "rootの親はendなので___is_rootはtrue")

    XCTAssertFalse(root.__left_.___is_null)
    XCTAssertFalse(root.__left_.___is_root, "rootの子はrootではない")
  }

  /// 赤黒木invariantが、壊れた親子関係・色・黒高さをそれぞれ拒否すること。
  func testInvariant_rejectsEachMalformedTreeCondition() {
    var fixture = TreeNodeOnlyFixture.makeEmpty()
    let end = fixture.endPtr()
    let root = fixture.node(0)
    let left = fixture.node(1)
    let right = fixture.node(2)
    let grandchild = fixture.node(3)

    func reset() {
      end.pointee = .create(tag: .end, nullptr: .nullptr)
      root.pointee = .create(tag: 0, nullptr: .nullptr)
      left.pointee = .create(tag: 1, nullptr: .nullptr)
      right.pointee = .create(tag: 2, nullptr: .nullptr)
      grandchild.pointee = .create(tag: 3, nullptr: .nullptr)
      root.__is_black_ = true
      left.__is_black_ = true
      right.__is_black_ = true
      grandchild.__is_black_ = true
      root.__parent_ = end
      end.__left_ = root
    }

    reset()
    root.__parent_ = .nullptr
    XCTAssertFalse(fixture.__tree_invariant(root))

    reset()
    end.__left_ = left
    XCTAssertFalse(fixture.__tree_invariant(root))

    reset()
    root.__is_black_ = false
    XCTAssertFalse(fixture.__tree_invariant(root))

    reset()
    root.__left_ = left
    left.__parent_ = end
    XCTAssertEqual(fixture.__tree_sub_invariant(root), 0)

    reset()
    root.__right_ = right
    right.__parent_ = end
    XCTAssertEqual(fixture.__tree_sub_invariant(root), 0)

    reset()
    root.__left_ = left
    root.__right_ = left
    left.__parent_ = root
    XCTAssertEqual(fixture.__tree_sub_invariant(root), 0)

    reset()
    root.__is_black_ = false
    root.__left_ = left
    left.__parent_ = root
    left.__is_black_ = false
    XCTAssertEqual(fixture.__tree_sub_invariant(root), 0)

    reset()
    root.__is_black_ = false
    root.__right_ = right
    right.__parent_ = root
    right.__is_black_ = false
    XCTAssertEqual(fixture.__tree_sub_invariant(root), 0)

    reset()
    root.__left_ = left
    left.__parent_ = root
    left.__left_ = grandchild
    grandchild.__parent_ = right
    XCTAssertEqual(fixture.__tree_sub_invariant(root), 0)

    reset()
    root.__left_ = left
    left.__parent_ = root
    XCTAssertEqual(fixture.__tree_sub_invariant(root), 0)

    reset()
    root.__right_ = right
    right.__parent_ = root
    XCTAssertEqual(fixture.__tree_leaf(root), right)
  }

  // MARK: - unsafe_node+pointer+compare.swift

  /// `___ptr_height`/`___ptr_comp_multi`/`___ptr_comp_bitmap`を、実際の中間順走査での
  /// 位置(ground truth)と比較して検証する。関数同士を比べるのではなく、走査で得た
  /// 実際の順序と比較することで、循環参照的な検証を避ける。
  func testCompare_heightAndOrderingMatchInOrderTraversal() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    var values: [_NodePtr: Int] = [:]
    for (i, v) in (0..<15).enumerated() {
      insert(&fixture, values: &values, end: end, nodeIndex: i, value: v)
    }
    let root = end.__left_

    // 中間順走査で「実際の順序」を position として記録する(endは全要素より後ろとする)
    var position: [_NodePtr: Int] = [:]
    var p = fixture.__tree_min(root)
    var i = 0
    while p != end {
      position[p] = i
      i += 1
      p = fixture.__tree_next_iter(p)
    }
    position[end] = i

    XCTAssertEqual(___ptr_height(root), 0)
    XCTAssertTrue(___ptr_height(root.__left_) > 0)
    XCTAssertTrue(___ptr_height(root.__right_) > 0)

    let allNodes = Array(position.keys)
    for l in allNodes {
      for r in allNodes {
        let expected = position[l]! < position[r]!
        XCTAssertEqual(
          ___ptr_comp_multi(l, r), expected,
          "___ptr_comp_multi: l=\(values[l] ?? -1), r=\(values[r] ?? -1)")
        XCTAssertEqual(
          ___ptr_comp_bitmap(l, r), expected,
          "___ptr_comp_bitmap: l=\(values[l] ?? -1), r=\(values[r] ?? -1)")
      }
    }
  }

  // MARK: - unsafe_node+pointer+advance.swift

  /// `___tree_next_iter`/`___tree_prev_iter`が、通常の1歩進む/戻るでは成功し、
  /// 木の下限/上限を超える操作では`.lowerOutOfBounds`/`.upperOutOfBounds`で失敗すること。
  func testAdvanceIter_successAndBoundaryFailures() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    var values: [_NodePtr: Int] = [:]
    for (i, v) in (0..<5).enumerated() {
      insert(&fixture, values: &values, end: end, nodeIndex: i, value: v)
    }
    let root = end.__left_
    let minNode = fixture.__tree_min(root)
    let maxNode = fixture.__tree_max(root)

    switch ___tree_next_iter(minNode) {
    case .success(let n): XCTAssertEqual(values[n], 1)
    case .failure: XCTFail("先頭から1つ進めるのは成功するはず")
    }

    switch ___tree_prev_iter(maxNode) {
    case .success(let n): XCTAssertEqual(values[n], 3)
    case .failure: XCTFail("末尾から1つ戻るのは成功するはず")
    }

    switch ___tree_next_iter(end) {
    case .success: XCTFail("endを進めるのは失敗するはず")
    case .failure(let e): XCTAssertEqual(e, .upperOutOfBounds)
    }

    switch ___tree_prev_iter(minNode) {
    case .success: XCTFail("先頭より前へ戻るのは失敗するはず")
    case .failure(let e): XCTAssertEqual(e, .lowerOutOfBounds)
    }
  }

  /// `___tree_adv_iter`が、正負両方向のN歩移動・0歩移動・limit到達時の`.limit`失敗
  /// (開始位置が既にlimit/移動中に正方向でlimitへ到達/移動中に負方向でlimitへ到達)・
  /// limitに到達せず完了する通常ケースを網羅すること。
  func testAdvIter_positiveNegativeAndLimit() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    var values: [_NodePtr: Int] = [:]
    for (i, v) in (0..<7).enumerated() {
      insert(&fixture, values: &values, end: end, nodeIndex: i, value: v)
    }
    let root = end.__left_
    let minNode = fixture.__tree_min(root)
    let maxNode = fixture.__tree_max(root)

    switch ___tree_adv_iter(minNode, 3) {
    case .success(let n): XCTAssertEqual(values[n], 3)
    case .failure: XCTFail()
    }
    switch ___tree_adv_iter(maxNode, -3) {
    case .success(let n): XCTAssertEqual(values[n], 3)
    case .failure: XCTFail()
    }
    switch ___tree_adv_iter(minNode, 0) {
    case .success(let n): XCTAssertEqual(n, minNode)
    case .failure: XCTFail()
    }

    // limit版: 開始位置が既にlimitなら即failure
    switch ___tree_adv_iter(minNode, 3, .success(minNode)) {
    case .success: XCTFail("開始位置がlimitと同じなら即failureのはず")
    case .failure(let e): XCTAssertEqual(e, .limit)
    }

    // limit版: 進行中にlimitへ到達したら、そこでfailure(正方向)
    switch ___tree_adv_iter(minNode, 10, .success(maxNode)) {
    case .success: XCTFail("木の範囲を超える前にlimitに到達するはず")
    case .failure(let e): XCTAssertEqual(e, .limit)
    }

    // limit版: 進行中にlimitへ到達したら、そこでfailure(負方向)
    switch ___tree_adv_iter(maxNode, -10, .success(minNode)) {
    case .success: XCTFail("木の範囲を超える前にlimitに到達するはず")
    case .failure(let e): XCTAssertEqual(e, .limit)
    }

    // limit版: limitに到達せずに完了した場合は、通常のsuccessを返す
    switch ___tree_adv_iter(minNode, 2, .success(maxNode)) {
    case .success(let n): XCTAssertEqual(values[n], 2)
    case .failure: XCTFail("limitに到達する前に完了するはず")
    }

    // limit版の負方向も、limitに到達せず正常にループを抜けること
    switch ___tree_adv_iter(maxNode, -2, .success(minNode)) {
    case .success(let n): XCTAssertEqual(values[n], 4)
    case .failure: XCTFail("負方向でもlimitに到達する前に完了するはず")
    }
  }

  // MARK: - unsafe_node+pointer+distance.swift

  /// `__distance`(素朴な前方カウント)と`___safe_distance`(Result版)が、
  /// 通常の前方距離・距離0・後ろ向き距離(失敗)を正しく処理すること。
  func testDistance_plainAndSafe() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    var values: [_NodePtr: Int] = [:]
    for (i, v) in (0..<6).enumerated() {
      insert(&fixture, values: &values, end: end, nodeIndex: i, value: v)
    }
    let root = end.__left_
    let minNode = fixture.__tree_min(root)
    let maxNode = fixture.__tree_max(root)

    XCTAssertEqual(__distance(minNode, maxNode), 5)
    XCTAssertEqual(__distance(minNode, minNode), 0)

    switch ___safe_distance(minNode, end) {
    case .success(let d): XCTAssertEqual(d, 6)
    case .failure: XCTFail()
    }
    switch ___safe_distance(minNode, minNode) {
    case .success(let d): XCTAssertEqual(d, 0)
    case .failure: XCTFail()
    }
    // 後ろ向き(last が first より手前)は、前方走査の末に end を超えて失敗する
    switch ___safe_distance(maxNode, minNode) {
    case .success: XCTFail("後ろ向きの距離は失敗するはず")
    case .failure(let e): XCTAssertEqual(e, .upperOutOfBounds)
    }
  }

  /// `_BaseNode_SignedDistanceProtocol`の既定実装が、同一点・昇順・降順で
  /// それぞれ0・正・負の距離を返すこと。
  func testSignedDistance_defaultImplementation() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    var values: [_NodePtr: Int] = [:]
    for value in 0..<6 {
      insert(&fixture, values: &values, end: end, nodeIndex: value, value: value)
    }

    let minNode = fixture.__tree_min(end.__left_)
    let maxNode = fixture.__tree_max(end.__left_)

    XCTAssertEqual(TreeNodeOnlyFixture.SignedTrackingTagKey.___signed_distance(minNode, minNode), 0)
    XCTAssertEqual(TreeNodeOnlyFixture.SignedTrackingTagKey.___signed_distance(minNode, maxNode), 5)
    XCTAssertEqual(TreeNodeOnlyFixture.SignedTrackingTagKey.___signed_distance(maxNode, minNode), -5)
    XCTAssertEqual(TreeNodeOnlyFixture.SignedTrackingTagKey.___signed_distance(minNode, end), 6)
    XCTAssertEqual(TreeNodeOnlyFixture.SignedTrackingTagKey.___signed_distance(end, minNode), -6)
  }
}
