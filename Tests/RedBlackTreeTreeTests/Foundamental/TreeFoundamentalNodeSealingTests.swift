import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections

  /// `Implements/__tree/unsafe_node/Seal/_NodePtrSealing.swift`と`_SealedTag.swift`の
  /// テスト。ノードの世代管理(`___recycle_count`によるseal/unseal判定)を検証する。
  @available(anyAppleOS 26.0, *)
  final class TreeFoundamentalNodeSealingTests: TreeTestCase, _UnsafeNodePtrType {

    func makeFixture() -> TreeNodeOnlyFixture {
      .makeEmpty()
    }

    // MARK: - _NodePtrSealing

    /// `uncheckedSeal(_:_:)`(過去のseal値を明示するオーバーロード)で保持したsealが、
    /// 現在のノードの`___recycle_count`と一致するかどうかで`isUnsealed`が決まること。
    func testUncheckedSealWithExplicitSeal_matchesIsUnsealedSemantics() {
      var fixture = makeFixture()
      let node = fixture.node(0)
      node.pointee.___tracking_tag = 0
      node.pointee.___recycle_count = 5

      let staleSeal = _NodePtrSealing.uncheckedSeal(node, 3)
      XCTAssertTrue(staleSeal.isUnsealed, "保持したseal(3)と現在のrecycle count(5)が不一致なら封印は剥がれている")

      let freshSeal = _NodePtrSealing.uncheckedSeal(node, 5)
      XCTAssertFalse(freshSeal.isUnsealed, "保持したseal(5)と現在のrecycle count(5)が一致すれば封印は有効")
    }

    /// `purified`が、`isUnsealed`がfalse(現世)の間は`.success(self)`を返し、
    /// ノードが再利用されて世代が進むと`.failure(.unsealed)`を返すこと。
    func testPurified_succeedsWhileSealMatchesAndFailsOnceRecycled() {
      var fixture = makeFixture()
      let node = fixture.node(0)
      node.pointee.___tracking_tag = 0
      node.pointee.___recycle_count = 1

      let fresh = node.uncheckedSeal
      guard case .success(let freshSealing) = fresh else { XCTFail(); return }
      XCTAssertTrue(freshSealing.purified == .success(freshSealing))

      // 回収・再利用されて世代が進んだ状態を模す
      node.pointee.___recycle_count = 2
      XCTAssertTrue(freshSealing.purified == .failure(.unsealed))
    }

    /// `deepPurified`が、end/payload無し(garbaged)/世代不一致(unsealed)/正常の
    /// それぞれで正しい結果になること。
    #if ALLOW_CROSS_TREE_INDEX
      func testDeepPurified_coversEndGarbagedUnsealedAndNormalCases() {
        var fixture = makeFixture()

        let end = fixture.endPtr()
        guard case .success(let endSeal) = end.uncheckedSeal else { XCTFail(); return }
        XCTAssertTrue(endSeal.deepPurified == .success(endSeal), "endは常に成功")

        let node = fixture.node(0)
        node.pointee.___tracking_tag = 0
        node.pointee.___recycle_count = 1
        node.pointee.___has_payload_content = false
        guard case .success(let garbagedSeal) = node.uncheckedSeal else { XCTFail(); return }
        XCTAssertTrue(garbagedSeal.deepPurified == .failure(.garbaged), "payload無しはgarbaged")

        node.pointee.___has_payload_content = true
        guard case .success(let normalSeal) = node.uncheckedSeal else { XCTFail(); return }
        XCTAssertTrue(normalSeal.deepPurified == .success(normalSeal), "通常ノードは成功")

        node.pointee.___recycle_count = 2  // 世代を進めてunsealedにする
        XCTAssertTrue(normalSeal.deepPurified == .failure(.unsealed), "世代が進むとunsealed")
      }
    #endif

    /// `tag`が、通常ノードは`.tag(raw:seal:)`に、endノードは`.end`になること
    /// (`_TrackingTagSealing.seal(raw:seal:)`の2分岐に対応)。
    func testTag_mapsRegularNodeToTagAndEndNodeToEnd() {
      var fixture = makeFixture()

      let node = fixture.node(0)
      node.pointee.___tracking_tag = 3
      node.pointee.___recycle_count = 7
      guard case .success(let nodeSealing) = node.uncheckedSeal else { XCTFail(); return }
      guard case .success(let nodeTag) = nodeSealing.tag else { XCTFail(); return }
      XCTAssertEqual(nodeTag, .tag(raw: 3, seal: 7))

      let end = fixture.endPtr()
      guard case .success(let endSealing) = end.uncheckedSeal else { XCTFail(); return }
      guard case .success(let endTag) = endSealing.tag else { XCTFail(); return }
      XCTAssertEqual(endTag, .end)
    }

    /// `lessThanSlow`/`<`(Comparable、DEBUG限定)が、木構造上の位置関係
    /// (`___ptr_comp_bitmap`と同じ大小関係)を正しく返すこと。
    func testLessThanSlowAndComparable_matchTreePosition() {
      var fixture = makeFixture()
      let end = fixture.endPtr()

      // 3ノードの小さな木(b が根、a が左の子、c が右の子)
      let a = fixture.node(0)
      let b = fixture.node(1)
      let c = fixture.node(2)
      a.pointee.___tracking_tag = 0
      b.pointee.___tracking_tag = 1
      c.pointee.___tracking_tag = 2

      a.__left_ = .nullptr
      a.__right_ = .nullptr
      a.__is_black_ = true
      c.__left_ = .nullptr
      c.__right_ = .nullptr
      c.__is_black_ = true
      b.__left_ = a
      b.__right_ = c
      b.__is_black_ = true
      a.__parent_ = b
      c.__parent_ = b
      b.__parent_ = end
      end.__left_ = b

      guard case .success(let sa) = a.uncheckedSeal,
        case .success(let sb) = b.uncheckedSeal,
        case .success(let sc) = c.uncheckedSeal
      else {
        XCTFail()
        return
      }

      XCTAssertTrue(sa.lessThanSlow(sb))
      XCTAssertTrue(sa < sb)
      XCTAssertTrue(sb < sc)
      XCTAssertFalse(sc < sa)
      XCTAssertFalse(sb.lessThanSlow(sa))
    }

    /// 異なる木のseal同士では、各end nodeのアドレス順で全順序が決まること。
    func testLessThanSlow_ordersNodesFromDifferentTreesByEndAddress() {
      var lhsFixture = makeFixture()
      var rhsFixture = makeFixture()
      let lhsEnd = lhsFixture.endPtr()
      let rhsEnd = rhsFixture.endPtr()
      let lhs = lhsFixture.node(0)
      let rhs = rhsFixture.node(0)

      lhs.pointee.___tracking_tag = 0
      rhs.pointee.___tracking_tag = 0
      lhs.__parent_ = lhsEnd
      rhs.__parent_ = rhsEnd
      lhsEnd.__left_ = lhs
      rhsEnd.__left_ = rhs

      guard case .success(let lhsSeal) = lhs.uncheckedSeal,
        case .success(let rhsSeal) = rhs.uncheckedSeal
      else {
        XCTFail()
        return
      }

      let expected = Int(bitPattern: lhsEnd) < Int(bitPattern: rhsEnd)
      XCTAssertEqual(lhsSeal.lessThanSlow(rhsSeal), expected)
      XCTAssertEqual(rhsSeal.lessThanSlow(lhsSeal), !expected)
    }

    /// `Hashable`適合により、同一ノード・同一sealの`_NodePtrSealing`が同じhash値を
    /// 持つこと。
    func testHashable_sameNodeAndSealProduceSameHash() {
      var fixture = makeFixture()
      let node = fixture.node(0)
      node.pointee.___tracking_tag = 0
      node.pointee.___recycle_count = 9

      guard case .success(let a) = node.uncheckedSeal,
        case .success(let b) = node.uncheckedSeal
      else {
        XCTFail()
        return
      }
      XCTAssertEqual(a, b)
      XCTAssertEqual(a.hashValue, b.hashValue)
    }

    /// `description`/`debugDescription`が、型名を含む人間向け文字列を返し、
    /// 両者が一致すること。
    func testDescription_includesTypeNameAndMatchesDebugDescription() {
      var fixture = makeFixture()
      let node = fixture.node(0)
      node.pointee.___tracking_tag = 4
      node.pointee.___recycle_count = 2
      guard case .success(let sealing) = node.uncheckedSeal else {
        XCTFail()
        return
      }
      XCTAssertTrue(sealing.description.contains("_NodePtrSealing"))
      XCTAssertEqual(sealing.debugDescription, sealing.description)
    }
  }
#endif
