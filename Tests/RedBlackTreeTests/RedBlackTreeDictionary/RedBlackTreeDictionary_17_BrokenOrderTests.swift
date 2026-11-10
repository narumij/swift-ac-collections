#if !COMPATIBLE_ATCODER_2025
  import RedBlackTreeCollections
  import XCTest

  private typealias BE = RedBlackTreeBoundExpression
  private var reversedBounds: RedBlackTreeBoundRangeExpression<BrokenOrderElement> {
    BE.lowerBound(BrokenOrderElement(1)) ..< BE.upperBound(BrokenOrderElement(2))
  }

  /// 指定した値で、推移律を満たさない要素の木を作る。既定は{0, 1, 5}。
  private func make(_ values: [Int] = [0, 1, 5]) -> RedBlackTreeDictionary<BrokenOrderElement, String> {
    var t = RedBlackTreeDictionary<BrokenOrderElement, String>()
    for v in values { t[BrokenOrderElement(v)] = String(repeating: "x", count: 40) }
    return t
  }

  /// 決まった種から作る、0...200の値の並び。
  private func seededValues(_ count: Int, seed: UInt64) -> [Int] {
    var g = SplitMix64(seed: seed)
    return (0 ..< count).map { _ in Int.random(in: 0 ... 200, using: &g) }
  }

  /// `<`が全順序にならない要素で、範囲が逆向きになる場合の振る舞い。
  final class RedBlackTreeDictionaryBrokenOrderTests: RedBlackTreeTestCase {

    /// 逆向きの範囲のViewでも、`last`と`popLast()`は範囲外を読まずに`nil`を返し、要素を消さないこと。
    func test_reversedRange_lastAndPopLastReturnNil() {
      var tree = make()

      XCTAssertNil(tree[reversedBounds].last)

      var boundView = tree[reversedBounds]
      XCTAssertNil(boundView.popLast())

      let i = tree.lowerBound(BrokenOrderElement(1)), j = tree.upperBound(BrokenOrderElement(2))
      var indexView = tree[i ..< j]
      XCTAssertNil(indexView.popLast())

      var valuesView = tree[reversedBounds]
      XCTAssertNil(valuesView.values.popLast())

      XCTAssertEqual(tree.count, 3)
    }

    /// 逆向きの範囲のViewでも、`first`・`count`・`isEmpty`は止まらずに返り、`first`は木の要素であること。
    func test_reversedRange_firstCountAndIsEmptyReturn() {
      let tree = make()
      let view = tree[reversedBounds]

      if let f = view.first { XCTAssertTrue(tree.contains(key: f.key)) }
      XCTAssertGreaterThanOrEqual(view.count, 0)
      _ = view.isEmpty
      XCTAssertEqual(tree[reversedBounds].values.first, tree[reversedBounds].first?.value)
      XCTAssertNil(tree[reversedBounds].values.last)
      XCTAssertGreaterThanOrEqual(tree[reversedBounds].values.count, 0)
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

    /// 範囲を使わない木全体の操作は、順序が壊れていても止まらず、走査した要素の数が`count`と一致すること。
    func test_wholeTreeOperations_keepCountConsistent() {
      func check(_ t: RedBlackTreeDictionary<BrokenOrderElement, String>, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(Array(t).count, t.count, file: file, line: line)
        XCTAssertEqual(t.reversed().count, t.count, file: file, line: line)
        _ = t.description
      }

      var t = make()
      for (k, v) in seededValues(3000, seed: 1).enumerated() {
        switch k % 4 {
        case 0: t[BrokenOrderElement(v)] = "v"
        case 1: if let i = t.firstIndex(of: BrokenOrderElement(v)) { t.remove(at: i) }
        case 2: _ = t.popFirst()
        default: _ = t.popLast()
        }
      }
      check(t)
      _ = Array(t.lazy.map { x in x.key.s.count + x.value.count }).count
      _ = t.lazy.filter { _ in true }.count
      XCTAssertEqual(Array(t.keys).count, t.count)
      XCTAssertEqual(Array(t.values).count, t.count)
      XCTAssertEqual(t.mapValues { $0.count }.count, t.count)
      XCTAssertEqual(t.compactMapValues { $0 }.count, t.count)

      t = make(seededValues(60, seed: 2))
      for v in 0 ... 200 {
        _ = t.contains(key: BrokenOrderElement(v)); _ = t.lowerBound(BrokenOrderElement(v)); _ = t.upperBound(BrokenOrderElement(v))
        for x in t[t.equalRange(BrokenOrderElement(v))] { _ = x.key.s.count + x.value.count }
      }
      check(t)

      var a = make(seededValues(60, seed: 5))
      a.merge(make(seededValues(60, seed: 6))) { x, _ in x }
      check(a)
    }

    /// 範囲を使わない木全体の走査は、すべての要素を訪れること。
    func test_wholeTreeIteration_visitsEveryElement() {
      XCTAssertEqual(Array(make()).count, 3)
      XCTAssertEqual(Array(make().reversed()).count, 3)
    }
  }
#endif
