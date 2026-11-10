#if !COMPATIBLE_ATCODER_2025
  import RedBlackTreeCollections
  import XCTest

  private typealias BE = RedBlackTreeBoundExpression
  private var reversedBounds: RedBlackTreeBoundRangeExpression<BrokenOrderElement> {
    BE.lowerBound(BrokenOrderElement(1)) ..< BE.upperBound(BrokenOrderElement(2))
  }

  /// 指定した値で、推移律を満たさない要素の木を作る。既定は{0, 1, 5}。
  private func make(_ values: [Int] = [0, 1, 5]) -> RedBlackTreeSet<BrokenOrderElement> {
    var t = RedBlackTreeSet<BrokenOrderElement>()
    for v in values { t.insert(BrokenOrderElement(v)) }
    return t
  }

  /// 決まった種から作る、0...200の値の並び。
  private func seededValues(_ count: Int, seed: UInt64) -> [Int] {
    var g = SplitMix64(seed: seed)
    return (0 ..< count).map { _ in Int.random(in: 0 ... 200, using: &g) }
  }

  /// `<`が全順序にならない要素で、範囲が逆向きになる場合の振る舞い。
  final class RedBlackTreeSetBrokenOrderTests: RedBlackTreeTestCase {

    /// 逆向きの範囲のViewでも、`last`と`popLast()`は範囲外を読まずに`nil`を返し、要素を消さないこと。
    func test_reversedRange_lastAndPopLastReturnNil() {
      var tree = make()

      XCTAssertNil(tree[reversedBounds].last)

      var boundView = tree[reversedBounds]
      XCTAssertNil(boundView.popLast())

      let i = tree.lowerBound(BrokenOrderElement(1)), j = tree.upperBound(BrokenOrderElement(2))
      var indexView = tree[i ..< j]
      XCTAssertNil(indexView.popLast())

      var keyView = tree[BrokenOrderElement(1) ..< BrokenOrderElement(2)]
      XCTAssertNil(keyView.popLast())

      XCTAssertEqual(tree.count, 3)
    }

    /// 逆向きの範囲のViewでも、`first`・`count`・`isEmpty`は止まらずに返り、`first`は木の要素であること。
    func test_reversedRange_firstCountAndIsEmptyReturn() {
      let tree = make()
      let view = tree[reversedBounds]

      if let f = view.first { XCTAssertTrue(tree.contains(f)) }
      XCTAssertGreaterThanOrEqual(view.count, 0)
      _ = view.isEmpty
    }

    /// 逆向きの範囲のViewで`removeFirst()`を呼んでも、止まらずに要素を返し、木は壊れず走査できること。
    func test_reversedRange_removeFirstKeepsTreeTraversable() {
      let tree = make()
      var view = tree[reversedBounds]
      _ = view.removeFirst()
      XCTAssertEqual(Array(tree).count, tree.count)
    }

    /// 逆向きの範囲の境界式で`erase`を呼んでも、木は壊れず走査できること。
    func test_reversedBounds_eraseKeepsTreeTraversable() {
      var tree = make()
      tree.erase(reversedBounds)
      XCTAssertEqual(Array(tree).count, tree.count)
      XCTAssertEqual(tree.reversed().count, tree.count)

      tree = make()
      tree.erase(reversedBounds, where: { _ in true })
      XCTAssertEqual(Array(tree).count, tree.count)
    }

    /// 逆向きのIndex範囲でも、`containsSubrange`は止まらずに返ること。
    func test_reversedIndexRange_containsSubrangeReturns() {
      let tree = make()
      _ = tree.containsSubrange(tree.lowerBound(BrokenOrderElement(1)) ..< tree.upperBound(BrokenOrderElement(2)))
    }

    /// 片側だけのキー範囲のViewは、順序が壊れていても走査できること。
    func test_partialKeyRanges_traverse() {
      let tree = make()
      for x in tree[BrokenOrderElement(2)...] { _ = x.s.count }
      for x in tree[..<BrokenOrderElement(1)] { _ = x.s.count }
      for x in tree[...BrokenOrderElement(1)] { _ = x.s.count }
    }

    /// 範囲を使わない木全体の操作は、順序が壊れていても止まらず、走査した要素の数が`count`と一致すること。
    func test_wholeTreeOperations_keepCountConsistent() {
      func check(_ t: RedBlackTreeSet<BrokenOrderElement>, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(Array(t).count, t.count, file: file, line: line)
        XCTAssertEqual(t.reversed().count, t.count, file: file, line: line)
        _ = t.description
      }

      var t = make()
      for (k, v) in seededValues(3000, seed: 1).enumerated() {
        switch k % 4 {
        case 0: t.insert(BrokenOrderElement(v))
        case 1: if let i = t.firstIndex(of: BrokenOrderElement(v)) { t.remove(at: i) }
        case 2: _ = t.popFirst()
        default: _ = t.popLast()
        }
      }
      check(t)
      _ = Array(t.lazy.map { x in x.s.count }).count
      _ = t.lazy.filter { _ in true }.count
      _ = t.hashValue

      t = make(seededValues(60, seed: 2))
      for v in 0 ... 200 {
        _ = t.contains(BrokenOrderElement(v)); _ = t.firstIndex(of: BrokenOrderElement(v)); _ = t.lowerBound(BrokenOrderElement(v)); _ = t.upperBound(BrokenOrderElement(v)); _ = t.min(); _ = t.max()
        for x in t[t.equalRange(BrokenOrderElement(v))] { _ = x.s.count }
      }
      check(t)
      for v in seededValues(300, seed: 4) {
        let h = t.lowerBound(BrokenOrderElement((v * 7) % 201))
        _ = t.insert(BrokenOrderElement(v), hint: h)
      }
      check(t)

      let a = make(seededValues(60, seed: 5)), b = make(seededValues(60, seed: 6))
      check(a.union(b)); check(a.intersection(b)); check(a.difference(b)); check(a.symmetricDifference(b))
      var u = a; u.formUnion(b); check(u)
      var n = a; n.formIntersection(b); check(n)
      var d = a; d.formDifference(b); check(d)
      var s = a; s.formSymmetricDifference(b); check(s)
      var m = a; m.merge(b); check(m)
      var ms = a; ms.merge(seededValues(60, seed: 7).map(BrokenOrderElement.init)); check(ms)
      check(RedBlackTreeSet<BrokenOrderElement>(seededValues(200, seed: 8).map(BrokenOrderElement.init)))
      _ = a == b
    }

    /// 範囲を使わない木全体の走査は、すべての要素を訪れること。
    func test_wholeTreeIteration_visitsEveryElement() {
      XCTAssertEqual(Array(make()).count, 3)
      XCTAssertEqual(Array(make().reversed()).count, 3)
    }
  }
#endif
