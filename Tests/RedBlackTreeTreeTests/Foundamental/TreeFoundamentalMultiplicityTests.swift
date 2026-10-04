import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

/// `Implements/__tree/base/tree_base+compare.swift`(`__UniqueHelper`/`__MultiHelper`)のテスト。
/// 既存の`SetBaseTests`/`MultiSetBaseTests`は`___ptr_range_comp`の成功ケースしか踏んでいなかったため、
/// `TreeNodeOnlyFixture.UniqueSealKey`/`.MultiSealKey`(`___recycle_count`をキーに使う)で
/// `___ptr_comp`本体・失敗分岐・重複キー時の木構造タイブレークを検証する。
@available(anyAppleOS 26.0, *)
final class TreeFoundamentalMultiplicityTests: TreeTestCase, _UnsafeNodePtrType {

  typealias UniqueSUT = TreeNodeOnlyFixture.UniqueSealKey
  typealias MultiSUT = TreeNodeOnlyFixture.MultiSealKey

  func makeFixture() -> TreeNodeOnlyFixture { .makeEmpty() }

  /// `___tracking_tag`はスロット番号のまま(0始まり連番の不変条件があるため触らない)、
  /// キー値は`___recycle_count`に持たせてBST位置に挿入する。
  fileprivate func buildTree(
    _ fixture: inout TreeNodeOnlyFixture, end: _NodePtr, count: Int,
    keyOf: (Int) -> Int = { $0 }
  ) {
    for i in 0..<count {
      let newNode = fixture.node(i)
      newNode.pointee.___tracking_tag = _TrackingTag(i)
      newNode.pointee.___recycle_count = .init(keyOf(i))
      newNode.__left_ = .nullptr
      newNode.__right_ = .nullptr
      newNode.__is_black_ = false

      let key = keyOf(i)
      if end.__left_ == .nullptr {
        newNode.__parent_ = end
        end.__left_ = newNode
      } else {
        var cur = end.__left_
        while true {
          if key < Int(cur.pointee.___recycle_count) {
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
  }

  fileprivate func find(_ fixture: inout TreeNodeOnlyFixture, end: _NodePtr, key: Int) -> _NodePtr
  {
    var cur = end.__left_
    while cur != .nullptr {
      let v = Int(cur.pointee.___recycle_count)
      if key == v { return cur }
      cur = key < v ? cur.__left_ : cur.__right_
    }
    fatalError("key \(key) not found")
  }

  // MARK: - __UniqueHelper.___ptr_comp

  /// 同一ノード同士の比較は、実ノードでもendでも常にfalseになること。
  func testUniqueHelper_ptrComp_sameNodeIsAlwaysFalse() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    buildTree(&fixture, end: end, count: 5)
    let a = end.__left_
    XCTAssertFalse(UniqueSUT.___ptr_comp(a, a))
    XCTAssertFalse(UniqueSUT.___ptr_comp(end, end))
  }

  /// endは常に実ノードより「大きい」(実ノード<end、end<実ノードはfalse)こと。
  func testUniqueHelper_ptrComp_endIsGreaterThanAnyRealNode() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    buildTree(&fixture, end: end, count: 5)
    let real = end.__left_
    XCTAssertTrue(UniqueSUT.___ptr_comp(real, end), "実ノードはendより小さいはず")
    XCTAssertFalse(UniqueSUT.___ptr_comp(end, real), "endは実ノードより大きいはず")
  }

  /// 異なるキーを持つ実ノード同士の比較が、キーの大小関係と一致すること。
  func testUniqueHelper_ptrComp_matchesKeyOrdering() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    buildTree(&fixture, end: end, count: 10)
    let small = find(&fixture, end: end, key: 2)
    let large = find(&fixture, end: end, key: 8)
    XCTAssertTrue(UniqueSUT.___ptr_comp(small, large))
    XCTAssertFalse(UniqueSUT.___ptr_comp(large, small))
  }

  // MARK: - __UniqueHelper.___ptr_range_comp

  /// 下端・現在位置・上端の全てがendの場合、「空区間だがendで閉じている」として
  /// 有効(true)と判定されること。
  func testUniqueHelper_ptrRangeComp_allEndIsValid() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    buildTree(&fixture, end: end, count: 5)
    XCTAssertTrue(UniqueSUT.___ptr_range_comp(end, end, end))
  }

  /// 下端だけがendで、現在位置や上端が実ノードの場合は、
  /// 区間として矛盾しているため無効(false)と判定されること。
  func testUniqueHelper_ptrRangeComp_firstIsEndButOthersAreNot_isInvalid() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    buildTree(&fixture, end: end, count: 5)
    let real = end.__left_
    XCTAssertFalse(UniqueSUT.___ptr_range_comp(end, real, end))
    XCTAssertFalse(UniqueSUT.___ptr_range_comp(end, end, real))
  }

  /// 上端がendの場合(上限なしの半開区間)、下端との大小関係だけで
  /// 判定され、下端自体は含むこと。
  func testUniqueHelper_ptrRangeComp_lastIsEnd_checksLowerBoundOnly() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    buildTree(&fixture, end: end, count: 10)
    let first = find(&fixture, end: end, key: 3)
    let before = find(&fixture, end: end, key: 2)
    let after = find(&fixture, end: end, key: 5)

    XCTAssertTrue(UniqueSUT.___ptr_range_comp(first, first, end), "下端そのものは含む")
    XCTAssertTrue(UniqueSUT.___ptr_range_comp(first, after, end), "下端より後ろは含む")
    XCTAssertFalse(UniqueSUT.___ptr_range_comp(first, before, end), "下端より手前は含まない")
    XCTAssertTrue(UniqueSUT.___ptr_range_comp(first, end, end), "pがendなら常に含む(上限なし)")
  }

  /// 上下端とも実ノードの閉区間で、下端・上端自体を含み、範囲外は含まないこと。
  func testUniqueHelper_ptrRangeComp_closedRange() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    buildTree(&fixture, end: end, count: 10)
    let first = find(&fixture, end: end, key: 3)
    let last = find(&fixture, end: end, key: 7)
    let before = find(&fixture, end: end, key: 2)
    let inside = find(&fixture, end: end, key: 5)
    let after = find(&fixture, end: end, key: 8)

    XCTAssertTrue(UniqueSUT.___ptr_range_comp(first, first, last), "下端は含む")
    XCTAssertTrue(UniqueSUT.___ptr_range_comp(first, last, last), "上端は含む(閉区間)")
    XCTAssertTrue(UniqueSUT.___ptr_range_comp(first, inside, last))
    XCTAssertFalse(UniqueSUT.___ptr_range_comp(first, before, last))
    XCTAssertFalse(UniqueSUT.___ptr_range_comp(first, after, last))
  }

  // MARK: - __MultiHelper.___ptr_comp

  /// (Multi版) 同一ノード同士の比較は常にfalseになること。
  func testMultiHelper_ptrComp_sameNodeIsAlwaysFalse() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    buildTree(&fixture, end: end, count: 5)
    let a = end.__left_
    XCTAssertFalse(MultiSUT.___ptr_comp(a, a))
  }

  /// (Multi版) endは常に実ノードより「大きい」こと。
  func testMultiHelper_ptrComp_endIsGreaterThanAnyRealNode() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    buildTree(&fixture, end: end, count: 5)
    let real = end.__left_
    XCTAssertTrue(MultiSUT.___ptr_comp(real, end))
    XCTAssertFalse(MultiSUT.___ptr_comp(end, real))
  }

  /// (Multi版) 異なるキーを持つ実ノード同士の比較が、キーの大小関係と一致すること。
  func testMultiHelper_ptrComp_matchesKeyOrdering() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    buildTree(&fixture, end: end, count: 10)
    let small = find(&fixture, end: end, key: 2)
    let large = find(&fixture, end: end, key: 8)
    XCTAssertTrue(MultiSUT.___ptr_comp(small, large))
    XCTAssertFalse(MultiSUT.___ptr_comp(large, small))
  }

  /// キーが同値の場合(多重コンテナ相当)は、`___ptr_comp_multi`による木構造上の位置(左が先)で
  /// タイブレークされる。`___ptr_comp_unique`単独では判定できない(l<rもr<lもfalse)分岐を通す。
  func testMultiHelper_ptrComp_equalKeysFallBackToTreePosition() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    buildTree(&fixture, end: end, count: 3, keyOf: { _ in 100 })
    let root = end.__left_
    let left = root.__left_
    let right = root.__right_

    XCTAssertTrue(MultiSUT.___ptr_comp(left, right), "キーが同値なら木構造上の位置(左が先)で決まるはず")
    XCTAssertFalse(MultiSUT.___ptr_comp(right, left))
  }

  // MARK: - __MultiHelper.___ptr_range_comp

  /// (Multi版) 下端・現在位置・上端の全てがendの場合、有効(true)と判定されること。
  func testMultiHelper_ptrRangeComp_allEndIsValid() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    buildTree(&fixture, end: end, count: 5)
    XCTAssertTrue(MultiSUT.___ptr_range_comp(end, end, end))
  }

  /// (Multi版) 下端だけがendで他が実ノードの場合は、無効(false)と判定されること。
  func testMultiHelper_ptrRangeComp_firstIsEndButOthersAreNot_isInvalid() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    buildTree(&fixture, end: end, count: 5)
    let real = end.__left_
    XCTAssertFalse(MultiSUT.___ptr_range_comp(end, real, end))
    XCTAssertFalse(MultiSUT.___ptr_range_comp(end, end, real))
  }

  /// (Multi版) 上端がendの場合、下端との大小関係だけで判定され、下端自体は含むこと。
  func testMultiHelper_ptrRangeComp_lastIsEnd_checksLowerBoundOnly() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    buildTree(&fixture, end: end, count: 10)
    let first = find(&fixture, end: end, key: 3)
    let before = find(&fixture, end: end, key: 2)
    let after = find(&fixture, end: end, key: 5)

    XCTAssertTrue(MultiSUT.___ptr_range_comp(first, first, end))
    XCTAssertTrue(MultiSUT.___ptr_range_comp(first, after, end))
    XCTAssertFalse(MultiSUT.___ptr_range_comp(first, before, end))
  }

  /// `USE_INT128`無効時の通常経路(`___ptr_bitmap_64`)で、閉区間の包含判定を検証する。
  func testMultiHelper_ptrRangeComp_closedRangeViaBitmap() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    buildTree(&fixture, end: end, count: 10)
    let first = find(&fixture, end: end, key: 3)
    let last = find(&fixture, end: end, key: 7)
    let before = find(&fixture, end: end, key: 2)
    let inside = find(&fixture, end: end, key: 5)
    let after = find(&fixture, end: end, key: 8)

    XCTAssertTrue(MultiSUT.___ptr_range_comp(first, first, last))
    XCTAssertTrue(MultiSUT.___ptr_range_comp(first, last, last))
    XCTAssertTrue(MultiSUT.___ptr_range_comp(first, inside, last))
    XCTAssertFalse(MultiSUT.___ptr_range_comp(first, before, last))
    XCTAssertFalse(MultiSUT.___ptr_range_comp(first, after, last))
  }

  /// UInt128版のpath bitmapもroot・左子・右子を異なる辞書順bit列へ符号化すること。
  func testPointerBitmap128_encodesRootAndChildDirections() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    buildTree(&fixture, end: end, count: 3)
    let root = end.__left_
    let left = root.__left_
    let right = root.__right_
    let topBit = UInt128(1) << (UInt128.bitWidth - 1)

    XCTAssertEqual(root.___ptr_bitmap_128(), topBit)
    XCTAssertEqual(left.___ptr_bitmap_128(), topBit >> 1)
    XCTAssertEqual(right.___ptr_bitmap_128(), topBit | (topBit >> 1))
  }
}
