import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

/// `Implements/__tree/unsafe_node/Seal/_NodePathBitmap.swift`と`_NodeKey.swift`のテスト。
/// `TreeNodeOnlyFixture`で実ポインタの木を作り、`___recycle_count`をキー代わりに使う。
@available(anyAppleOS 26.0, *)
final class TreeFoundamentalSealTests: TreeTestCase, _UnsafeNodePtrType {
  
  typealias _SealTestBase = TreeNodeOnlyFixture.UniqueSealKey

  func makeFixture() -> TreeNodeOnlyFixture {
    .makeEmpty()
  }

  /// `nodeIndex`(保管スロット番号)を`___tracking_tag`に、キー値を`___recycle_count`に設定して、
  /// BST位置に挿入する。`insertOrder`で挿入順を、`keyOf`でキー値の割り当てを制御できる。
  /// 既定ではキー値もスロット番号と同じ(0..<count)になる。
  fileprivate func buildTree(
    _ fixture: inout TreeNodeOnlyFixture, end: _NodePtr, count: Int,
    insertOrder: [Int]? = nil,
    keyOf: (Int) -> Int = { $0 }
  ) {
    for i in insertOrder ?? Array(0..<count) {
      let newNode = fixture.node(i)
      // ___tracking_tagは.end以外は0始まりの連番(=スロット番号)という不変条件があるため、
      // テストの都合で書き換えない。キー値は___recycle_countの方に持たせる。
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

  // MARK: - _NodePathBitmap

  /// `_NodePathBitmap`がendは`.end`、実ノードは`.path`になり、実ノードは常にendより
  /// 「小さい」こと。また、全ノード間の大小関係が中間順走査(ground truth)と一致すること。
  func testNodePathBitmap_endCaseAndOrdering() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    buildTree(&fixture, end: end, count: 15)

    switch _NodePathBitmap(end) {
    case .end: break
    case .path: XCTFail("endは.endになるはず")
    }

    let root = end.__left_
    switch _NodePathBitmap(root) {
    case .path: break
    case .end: XCTFail("実ノードは.pathになるはず")
    }

    // 実ノードは常にendより「小さい」
    XCTAssertTrue(_NodePathBitmap(root) < _NodePathBitmap(end))
    XCTAssertFalse(_NodePathBitmap(end) < _NodePathBitmap(root))

    // 実際の中間順位置(ground truth)と、bitmapの大小関係が一致すること
    var position: [_NodePtr: Int] = [:]
    var p = fixture.__tree_min(root)
    var i = 0
    while p != end {
      position[p] = i
      i += 1
      p = fixture.__tree_next_iter(p)
    }
    let allNodes = Array(position.keys)
    for l in allNodes {
      for r in allNodes {
        let expected = position[l]! < position[r]!
        XCTAssertEqual(_NodePathBitmap(l) < _NodePathBitmap(r), expected)
      }
    }
  }

  /// `_NodePathBitmap.lessThan`が、bitmapを渡さない場合は内部で計算して返し、
  /// 既に計算済みのbitmapを渡した場合はそれをそのまま返すこと。
  func testNodePathBitmap_lessThanHelperReturnsConsistentBitmaps() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    buildTree(&fixture, end: end, count: 7)
    let root = end.__left_
    let a = fixture.__tree_min(root)
    let b = fixture.__tree_max(root)

    // bitmapを渡さない場合、内部で計算されて返る
    let r1 = _NodePathBitmap.lessThan(lhs: (a, nil), rhs: (b, nil))
    XCTAssertTrue(r1.result)
    XCTAssertEqual(r1.lhsBitmap, _NodePathBitmap(a))
    XCTAssertEqual(r1.rhsBitmap, _NodePathBitmap(b))

    // 既に計算済みのbitmapを渡した場合は、それがそのまま返る
    let precomputedA = _NodePathBitmap(a)
    let precomputedB = _NodePathBitmap(b)
    let r2 = _NodePathBitmap.lessThan(lhs: (a, precomputedA), rhs: (b, precomputedB))
    XCTAssertTrue(r2.result)
    XCTAssertEqual(r2.lhsBitmap, precomputedA)
    XCTAssertEqual(r2.rhsBitmap, precomputedB)

    // 逆方向はfalse
    let r3 = _NodePathBitmap.lessThan(lhs: (b, nil), rhs: (a, nil))
    XCTAssertFalse(r3.result)
  }

  // MARK: - _NodeKey<Base>

  /// `_NodeKey`がendは`.end`、実ノードは`.key`になり、キーの大小がそのまま
  /// `Comparable`の大小になること。また、実ノードは常にendより小さいこと。
  func testNodeKey_endCaseAndKeyOrdering() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    buildTree(&fixture, end: end, count: 10)
    let root = end.__left_

    switch _NodeKey<_SealTestBase>(end) {
    case .end: break
    case .key: XCTFail("endは.endになるはず")
    }

    switch _NodeKey<_SealTestBase>(root) {
    case .key(let k): XCTAssertEqual(k, _SealTestBase.__get_value(root))
    case .end: XCTFail("実ノードは.keyになるはず")
    }

    // キーの大小がそのままComparableの大小になる
    let small = find(&fixture, end: end, key: 2)
    let large = find(&fixture, end: end, key: 8)
    XCTAssertTrue(_NodeKey<_SealTestBase>(small) < _NodeKey<_SealTestBase>(large))
    XCTAssertFalse(_NodeKey<_SealTestBase>(large) < _NodeKey<_SealTestBase>(small))

    // 実ノードは常にendより小さい
    XCTAssertTrue(_NodeKey<_SealTestBase>(root) < _NodeKey<_SealTestBase>(end))
  }

  /// `_NodeKey.lessThan`が、同一ノードでは常にfalseを返し、キーが異なる場合は
  /// bitmapの計算に踏み込まず(nilのまま)キーだけで大小が決まること。
  func testNodeKey_lessThan_sameNodeAndDifferentKeys() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    buildTree(&fixture, end: end, count: 10)
    let a = find(&fixture, end: end, key: 2)
    let b = find(&fixture, end: end, key: 7)

    // 同一ノードは常にfalse
    let same = _NodeKey<_SealTestBase>.lessThan(lhs: (a, nil), rhs: (a, nil))
    XCTAssertFalse(same.result)

    // キーが異なる場合は、bitmapの計算に踏み込まず(nilのまま)キーだけで決まる
    let lt = _NodeKey<_SealTestBase>.lessThan(lhs: (a, nil), rhs: (b, nil))
    XCTAssertTrue(lt.result)
    XCTAssertNil(lt.lhsBitmap)
    XCTAssertNil(lt.rhsBitmap)

    let gt = _NodeKey<_SealTestBase>.lessThan(lhs: (b, nil), rhs: (a, nil))
    XCTAssertFalse(gt.result)
  }

  /// キーが同値の場合(多重コンテナ相当)は、bitmap(木構造上の位置)がタイブレークになる。
  /// キーの重複は___recycle_countの方で再現する(___tracking_tagは0始まり連番の不変条件があるため触らない)。
  func testNodeKey_lessThan_equalKeysFallBackToBitmapPosition() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    // 3要素とも同じキー(100)にして、左右の子だけがキー重複になる状況を作る
    buildTree(&fixture, end: end, count: 3, keyOf: { _ in 100 })
    let root = end.__left_
    let left = root.__left_
    let right = root.__right_

    let result = _NodeKey<_SealTestBase>.lessThan(lhs: (left, nil), rhs: (right, nil))
    XCTAssertTrue(result.result, "キーが同値なら木構造上の位置(左が先)で決まるはず")
    XCTAssertNotNil(result.lhsBitmap, "キー同値の場合はbitmapまで計算されるはず")
    XCTAssertNotNil(result.rhsBitmap)

    let reversed = _NodeKey<_SealTestBase>.lessThan(lhs: (right, nil), rhs: (left, nil))
    XCTAssertFalse(reversed.result)
  }

  /// `_NodeKey.isInHalfOpenRange`が半開区間(下端を含み上端を含まない)として
  /// 正しく範囲内外を判定すること。
  func testNodeKey_isInHalfOpenRange() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    buildTree(&fixture, end: end, count: 10)

    let first = find(&fixture, end: end, key: 3)
    let last = find(&fixture, end: end, key: 7)

    let before = find(&fixture, end: end, key: 2)
    let atFirst = first
    let inside = find(&fixture, end: end, key: 5)
    let atLast = last
    let after = find(&fixture, end: end, key: 8)

    XCTAssertFalse(
      _NodeKey<_SealTestBase>.isInHalfOpenRange(
        first: (first, nil), position: (before, nil), last: (last, nil)
      ).result, "範囲より手前")
    XCTAssertTrue(
      _NodeKey<_SealTestBase>.isInHalfOpenRange(
        first: (first, nil), position: (atFirst, nil), last: (last, nil)
      ).result, "下端は含む")
    XCTAssertTrue(
      _NodeKey<_SealTestBase>.isInHalfOpenRange(
        first: (first, nil), position: (inside, nil), last: (last, nil)
      ).result, "範囲内")
    XCTAssertFalse(
      _NodeKey<_SealTestBase>.isInHalfOpenRange(
        first: (first, nil), position: (atLast, nil), last: (last, nil)
      ).result, "上端は含まない(半開区間)")
    XCTAssertFalse(
      _NodeKey<_SealTestBase>.isInHalfOpenRange(
        first: (first, nil), position: (after, nil), last: (last, nil)
      ).result, "範囲より後ろ")
  }

  /// `_NodeKey.containsRange`が、内側区間が外側区間に完全に含まれるか
  /// (完全一致・手前から開始・後ろまで続く・逆転した区間を含む)を正しく判定すること。
  func testNodeKey_containsRange() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    buildTree(&fixture, end: end, count: 12)

    let outerFirst = find(&fixture, end: end, key: 2)
    let outerLast = find(&fixture, end: end, key: 9)

    func node(_ key: Int) -> _NodePtr { find(&fixture, end: end, key: key) }

    // innerがouterに完全に含まれる
    XCTAssertTrue(
      _NodeKey<_SealTestBase>.containsRange(
        outerFirst: (outerFirst, nil), outerLast: (outerLast, nil),
        innerFirst: (node(3), nil), innerLast: (node(8), nil)
      ).result)

    // innerがouterと完全一致
    XCTAssertTrue(
      _NodeKey<_SealTestBase>.containsRange(
        outerFirst: (outerFirst, nil), outerLast: (outerLast, nil),
        innerFirst: (node(2), nil), innerLast: (node(9), nil)
      ).result)

    // innerがouterより手前から始まる
    XCTAssertFalse(
      _NodeKey<_SealTestBase>.containsRange(
        outerFirst: (outerFirst, nil), outerLast: (outerLast, nil),
        innerFirst: (node(0), nil), innerLast: (node(8), nil)
      ).result)

    // innerがouterより後ろまで続く
    XCTAssertFalse(
      _NodeKey<_SealTestBase>.containsRange(
        outerFirst: (outerFirst, nil), outerLast: (outerLast, nil),
        innerFirst: (node(3), nil), innerLast: (node(11), nil)
      ).result)

    // innerが逆転している(innerLast < innerFirst)
    XCTAssertFalse(
      _NodeKey<_SealTestBase>.containsRange(
        outerFirst: (outerFirst, nil), outerLast: (outerLast, nil),
        innerFirst: (node(8), nil), innerLast: (node(3), nil)
      ).result)
  }
}
