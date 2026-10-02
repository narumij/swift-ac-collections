import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections

  /// `Implements/__tree/unsafe_node/unsafe_node+pointer+algorithm.swift`の
  /// `__tree_invariant`/`__tree_sub_invariant`が、意図的に壊した木構造を
  /// きちんと検出して`false`/`0`を返すことを検証する。
  /// (正常な木を通すケースは`TreeFoundamentalTests`で検証済み)
  ///
  /// 併せて`unsafe_node+debug.swift`の`equiv`/`nullCheck`/`endCheck`
  /// (DEBUG限定の内部整合性チェッカー)も検証する。
  @available(anyAppleOS 26.0, *)
  final class TreeFoundamentalInvariantViolationTests: TreeTestCase, _UnsafeNodePtrType {

    func makeFixture() -> TreeNodeOnlyFixture {
      .makeEmpty()
    }

    // MARK: - __tree_invariant

    /// 空の木(`nullptr`)は常に妥当な木として`true`を返すこと。
    func testTreeInvariant_emptyTreeIsValid() {
      XCTAssertTrue(__tree_invariant(.nullptr))
    }

    /// rootの`__parent_`が`nullptr`の場合(本来はendを指すはず)、`false`になること。
    func testTreeInvariant_falseWhenRootParentIsNull() {
      var fixture = makeFixture()
      let root = fixture.node(0)
      root.pointee.___tracking_tag = 0
      root.__left_ = .nullptr
      root.__right_ = .nullptr
      root.__parent_ = .nullptr
      root.__is_black_ = true

      XCTAssertFalse(__tree_invariant(root))
    }

    /// rootがその親(end)の左の子になっていない場合、`false`になること。
    func testTreeInvariant_falseWhenRootIsNotLeftChildOfItsParent() {
      var fixture = makeFixture()
      let end = fixture.endPtr()
      let root = fixture.node(0)
      root.pointee.___tracking_tag = 0
      root.__left_ = .nullptr
      root.__right_ = .nullptr
      root.__parent_ = end
      root.__is_black_ = true
      // end.__left_ をrootに繋がないため、__tree_is_left_child(root)がfalseになる

      XCTAssertFalse(__tree_invariant(root))
    }

    /// rootが黒でない(赤)場合、`false`になること。
    func testTreeInvariant_falseWhenRootIsRed() {
      var fixture = makeFixture()
      let end = fixture.endPtr()
      let root = fixture.node(0)
      root.pointee.___tracking_tag = 0
      root.__left_ = .nullptr
      root.__right_ = .nullptr
      root.__parent_ = end
      end.__left_ = root
      root.__is_black_ = false

      XCTAssertFalse(__tree_invariant(root))
    }

    // MARK: - __tree_sub_invariant

    /// 左の子の`__parent_`がselfを指していない(親子リンク破損)場合、`0`になること。
    func testSubInvariant_falseWhenLeftChildParentLinkIsBroken() {
      var fixture = makeFixture()
      let root = fixture.node(0)
      let left = fixture.node(1)
      root.pointee.___tracking_tag = 0
      left.pointee.___tracking_tag = 1

      root.__left_ = left
      root.__right_ = .nullptr
      root.__is_black_ = true
      left.__left_ = .nullptr
      left.__right_ = .nullptr
      left.__is_black_ = true
      left.__parent_ = .nullptr  // 不正: 本来はrootを指すはず

      XCTAssertEqual(__tree_sub_invariant(root), 0)
    }

    /// 右の子の`__parent_`がselfを指していない場合も、同様に`0`になること。
    func testSubInvariant_falseWhenRightChildParentLinkIsBroken() {
      var fixture = makeFixture()
      let root = fixture.node(0)
      let right = fixture.node(1)
      root.pointee.___tracking_tag = 0
      right.pointee.___tracking_tag = 1

      root.__left_ = .nullptr
      root.__right_ = right
      root.__is_black_ = true
      right.__left_ = .nullptr
      right.__right_ = .nullptr
      right.__is_black_ = true
      right.__parent_ = .nullptr  // 不正: 本来はrootを指すはず

      XCTAssertEqual(__tree_sub_invariant(root), 0)
    }

    /// 左右の子が(非null同士で)同一ノードを指している場合、`0`になること。
    func testSubInvariant_falseWhenLeftAndRightChildAreTheSameNonNullNode() {
      var fixture = makeFixture()
      let root = fixture.node(0)
      let shared = fixture.node(1)
      root.pointee.___tracking_tag = 0
      shared.pointee.___tracking_tag = 1

      shared.__left_ = .nullptr
      shared.__right_ = .nullptr
      shared.__is_black_ = true
      shared.__parent_ = root
      root.__left_ = shared
      root.__right_ = shared
      root.__is_black_ = true

      XCTAssertEqual(__tree_sub_invariant(root), 0)
    }

    /// 赤ノードの左の子が赤(赤赤連続)の場合、`0`になること。
    func testSubInvariant_falseWhenRedNodeHasRedLeftChild() {
      var fixture = makeFixture()
      let root = fixture.node(0)
      let left = fixture.node(1)
      root.pointee.___tracking_tag = 0
      left.pointee.___tracking_tag = 1

      root.__left_ = left
      root.__right_ = .nullptr
      root.__is_black_ = false
      left.__parent_ = root
      left.__left_ = .nullptr
      left.__right_ = .nullptr
      left.__is_black_ = false

      XCTAssertEqual(__tree_sub_invariant(root), 0)
    }

    /// 赤ノードの右の子が赤(赤赤連続)の場合、`0`になること。
    func testSubInvariant_falseWhenRedNodeHasRedRightChild() {
      var fixture = makeFixture()
      let root = fixture.node(0)
      let right = fixture.node(1)
      root.pointee.___tracking_tag = 0
      right.pointee.___tracking_tag = 1

      root.__left_ = .nullptr
      root.__right_ = right
      root.__is_black_ = false
      right.__parent_ = root
      right.__left_ = .nullptr
      right.__right_ = .nullptr
      right.__is_black_ = false

      XCTAssertEqual(__tree_sub_invariant(root), 0)
    }

    /// 左の部分木自体が既に不正な場合、その不正がrootまで伝播して`0`になること。
    func testSubInvariant_falseWhenLeftSubtreeIsInvalid() {
      var fixture = makeFixture()
      let root = fixture.node(0)
      let left = fixture.node(1)
      let shared = fixture.node(2)
      root.pointee.___tracking_tag = 0
      left.pointee.___tracking_tag = 1
      shared.pointee.___tracking_tag = 2

      root.__left_ = left
      root.__right_ = .nullptr
      root.__is_black_ = true
      left.__parent_ = root
      left.__is_black_ = true
      shared.__parent_ = left
      shared.__left_ = .nullptr
      shared.__right_ = .nullptr
      shared.__is_black_ = true
      // leftの部分木自体を不正化(左右が同一ノード)
      left.__left_ = shared
      left.__right_ = shared

      XCTAssertEqual(__tree_sub_invariant(root), 0)
    }

    /// 左右の部分木の黒高さが異なる場合、`0`になること。
    func testSubInvariant_falseWhenLeftAndRightSubtreeHeightsDiffer() {
      var fixture = makeFixture()
      let root = fixture.node(0)
      let left = fixture.node(1)
      let right = fixture.node(2)
      let rightChild = fixture.node(3)
      root.pointee.___tracking_tag = 0
      left.pointee.___tracking_tag = 1
      right.pointee.___tracking_tag = 2
      rightChild.pointee.___tracking_tag = 3

      root.__is_black_ = true
      root.__left_ = left
      root.__right_ = right

      left.__parent_ = root
      left.__left_ = .nullptr
      left.__right_ = .nullptr
      left.__is_black_ = true

      right.__parent_ = root
      right.__is_black_ = true
      right.__left_ = .nullptr
      right.__right_ = rightChild

      rightChild.__parent_ = right
      rightChild.__left_ = .nullptr
      rightChild.__right_ = .nullptr
      rightChild.__is_black_ = true

      XCTAssertEqual(__tree_sub_invariant(root), 0)
    }

    // MARK: - unsafe_node+debug.swift

    // NOTE: 以前は各guardと同じ条件をassertでも先に検査していたが、falseを返す診断用途と
    // 両立せず、assert側は`#if false`で無効化された。true/falseの双方を通常テストで固定する。

    /// `equiv(with:)`が、追跡対象の全フィールド(tag・左右親の子のtag・色・payload有無)が
    /// 一致する場合に`true`を返すこと。
    func testEquiv_trueWhenAllTrackedFieldsMatch() {
      var fixture = makeFixture()
      let left = fixture.node(0)
      left.pointee.___tracking_tag = 10
      let right = fixture.node(1)
      right.pointee.___tracking_tag = 20
      let parent = fixture.node(2)
      parent.pointee.___tracking_tag = 30

      let a = UnsafeNode(
        ___tracking_tag: 1, __left_: left, __right_: right, __parent_: parent,
        __is_black_: true, ___has_payload_content: true)
      let b = UnsafeNode(
        ___tracking_tag: 1, __left_: left, __right_: right, __parent_: parent,
        __is_black_: true, ___has_payload_content: true)
      XCTAssertTrue(a.equiv(with: b))
    }

    /// `nullCheck()`が、正規のnullptr番兵(タグ`.nullptr`・全リンクnullptr・赤・payload無し)に
    /// 対して`true`を返すこと。
    func testNullCheck_trueForProperNullSentinel() {
      let properNull = UnsafeNode.nullptr.pointee
      XCTAssertTrue(properNull.nullCheck())
    }

    /// `endCheck()`が、正規のend番兵(タグ`.end`・右/親nullptr・黒でない・payload無し)に
    /// 対して`true`を返すこと。
    func testEndCheck_trueForProperEndSentinel() {
      var fixture = makeFixture()
      let end = fixture.endPtr()
      end.pointee.___has_payload_content = false
      XCTAssertTrue(end.pointee.endCheck())
    }

    /// 診断用checkが不一致をトラップせず、それぞれ`false`として報告すること。
    func testDebugChecks_falseForMismatchedMetadata() {
      var fixture = makeFixture()
      let node = fixture.node(0)

      let lhs = UnsafeNode.create(tag: 0, nullptr: .nullptr)
      let rhs = UnsafeNode.create(tag: 1, nullptr: .nullptr)
      XCTAssertFalse(lhs.equiv(with: rhs))

      var invalidNull = UnsafeNode.nullptr.pointee
      invalidNull.___tracking_tag = .end
      XCTAssertFalse(invalidNull.nullCheck())

      var invalidEnd = node.pointee
      invalidEnd.___tracking_tag = .nullptr
      XCTAssertFalse(invalidEnd.endCheck())
    }
  }
#endif
