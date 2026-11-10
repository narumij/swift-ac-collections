#if !COMPATIBLE_ATCODER_2025
  import RedBlackTreeCollections
  import XCTest

  private typealias BE = RedBlackTreeBoundExpression
  private var reversedBounds: RedBlackTreeBoundRangeExpression<BrokenOrderElement> {
    BE.lowerBound(BrokenOrderElement(1)) ..< BE.upperBound(BrokenOrderElement(2))
  }

  /// 指定した値で、推移律を満たさない要素の木を作る。既定は{0, 1, 5}。
  private func make(_ values: [Int] = [0, 1, 5]) -> RedBlackTreeMultiMap<BrokenOrderElement, String> {
    var t = RedBlackTreeMultiMap<BrokenOrderElement, String>()
    for v in values { t.insert(key: BrokenOrderElement(v), value: String(repeating: "x", count: 40)) }
    return t
  }

  /// 決まった種から作る、0...200の値の並び。
  private func seededValues(_ count: Int, seed: UInt64) -> [Int] {
    var g = SplitMix64(seed: seed)
    return (0 ..< count).map { _ in Int.random(in: 0 ... 200, using: &g) }
  }


  /// `<`が全順序にならない要素で、範囲が逆向きになる場合の振る舞い。
  final class RedBlackTreeMultiMapBrokenOrderTests: RedBlackTreeTestCase {

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

    /// 逆向きの範囲のViewで先頭から消し続けても、範囲外を読まずに`nil`で止まり、そのあとの`first`も`nil`になること。
    func test_reversedRange_popFirstEndsWithNil() {
      func drain(_ v: inout RedBlackTreeMultiMap<BrokenOrderElement, String>.View) -> Int? {
        var n = 0
        while let x = v.popFirst() { _ = x.key.s.count + x.value.count; n += 1; if n > 3 { return nil } }
        return v.popFirst() == nil ? n : nil
      }

      var tree = make()
      var view = tree[reversedBounds]
      XCTAssertNotNil(drain(&view))
      XCTAssertNil(view.first)

      tree = make()
      var alternating = tree[reversedBounds]
      for _ in 0 ..< 4 {
        _ = alternating.popLast()
        if let x = alternating.popFirst() { _ = x.key.s.count + x.value.count }
      }
      XCTAssertNil(alternating.popFirst())

      tree = make()
      let i = tree.lowerBound(BrokenOrderElement(1)), j = tree.upperBound(BrokenOrderElement(2))
      var indexView = tree[i ..< j]
      XCTAssertNotNil(drain(&indexView))

      tree = make()
      var keyView = tree[BrokenOrderElement(1) ..< BrokenOrderElement(2)]
      XCTAssertNotNil(drain(&keyView))

      tree = make()
      var valuesView = tree[reversedBounds]
      var popped = 0
      while valuesView.values.popFirst() != nil { popped += 1; if popped > 3 { break } }
      XCTAssertLessThanOrEqual(popped, 3)
      XCTAssertNil(valuesView.values.popFirst())

      XCTAssertEqual(Array(tree).count, tree.count)
    }

    /// 逆向きの範囲のViewで`removeFirst()`を呼んでも、止まらずに要素を返し、木は壊れず走査できること。
    func test_reversedRange_removeFirstKeepsTreeTraversable() {
      let tree = make()
      var view = tree[reversedBounds]
      _ = view.removeFirst()
      XCTAssertEqual(Array(tree).count, tree.count)
    }

    /// 逆向きの範囲のViewで`erase(where:)`・`removeAll(where:)`を呼んでも、止まらずに返り、木は壊れず走査できること。
    func test_reversedRange_eraseWhereKeepsTreeTraversable() {
      var tree = make()
      var erasing = tree[reversedBounds]
      erasing.erase(where: { _ in true })
      XCTAssertEqual(Array(tree).count, tree.count)

      tree = make()
      var removing = tree[reversedBounds]
      removing.removeAll(where: { _ in true })
      XCTAssertEqual(Array(tree).count, tree.count)

      var valuesErasing = make()[reversedBounds]
      valuesErasing.values.erase(where: { _ in true })
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
      func check(_ t: RedBlackTreeMultiMap<BrokenOrderElement, String>, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(Array(t).count, t.count, file: file, line: line)
        XCTAssertEqual(t.reversed().count, t.count, file: file, line: line)
        _ = t.description
      }

      var t = make()
      for (k, v) in seededValues(3000, seed: 1).enumerated() {
        switch k % 4 {
        case 0: t.insert(key: BrokenOrderElement(v), value: "v")
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

      t = make(seededValues(60, seed: 2))
      for v in 0 ... 200 {
        _ = t.contains(key: BrokenOrderElement(v)); _ = t.lowerBound(BrokenOrderElement(v)); _ = t.upperBound(BrokenOrderElement(v))
        for x in t[t.equalRange(BrokenOrderElement(v))] { _ = x.key.s.count + x.value.count }
      }
      check(t)

      var a = make(seededValues(60, seed: 5))
      a.insert(contentsOf: make(seededValues(60, seed: 6)))
      check(a)
    }

    /// 範囲を使わない木全体の走査は、すべての要素を訪れること。
    func test_wholeTreeIteration_visitsEveryElement() {
      XCTAssertEqual(Array(make()).count, 3)
      XCTAssertEqual(Array(make().reversed()).count, 3)
    }

    /// 順序が壊れた木でも、正しい向きの範囲ならViewと範囲の操作が止まらずに動き、数が合うこと（スモークテスト）。
    /// 範囲の端は、キーの比較と位置の前後が一致するもの（2番目の要素から終端まで）を使う。
    func test_forwardRange_sequenceOperationsSmoke() {
      let tree = make()
      let i0 = tree.index(after: tree.startIndex)
      let i2 = tree.endIndex
      let view = tree[i0 ..< i2]

      var visited = 0
      for x in view { _ = x.key.s.count + x.value.count; visited += 1 }
      XCTAssertEqual(visited, 2)
      XCTAssertEqual(Array(view).count, 2)
      XCTAssertEqual(view.map { x in x.key.s.count + x.value.count }.count, 2)
      XCTAssertEqual(view.reduce(0) { r, _ in r + 1 }, 2)
      XCTAssertEqual(Array(view.lazy.map { x in x.key.s.count + x.value.count }).count, 2)
      XCTAssertTrue(view.elementsEqual(Array(view)) { $0.key == $1.key })
      XCTAssertEqual(view.sorted().count, 2)
      XCTAssertEqual(view.reversed().count, 2)
      XCTAssertNotNil(view.first)
      XCTAssertNotNil(view.last)
      XCTAssertEqual(view.count, 2)
      XCTAssertFalse(view.isEmpty)
      XCTAssertEqual(Array(tree[...]).count, 3)
      XCTAssertEqual(Array(tree[tree.startIndex ..< tree.index(after: tree.startIndex)]).count, 1)

      XCTAssertEqual(Array(view.keys).count, 2)
      XCTAssertEqual(Array(view.values).count, 2)
      XCTAssertNotNil(view.values.first)
      XCTAssertNotNil(view.values.last)
      XCTAssertEqual(view.values.count, 2)

      var valuesPopping = tree[i0 ..< i2]
      var popped = 0
      while valuesPopping.values.popFirst() != nil { popped += 1 }
      XCTAssertEqual(popped, 2)
      valuesPopping = tree[i0 ..< i2]
      popped = 0
      while valuesPopping.values.popLast() != nil { popped += 1 }
      XCTAssertEqual(popped, 2)
      var valuesErasing = tree[i0 ..< i2]
      valuesErasing.values.erase(where: { _ in true })
      XCTAssertEqual(valuesErasing.count, 0)

      var popping = tree[i0 ..< i2]
      var n = 0
      while popping.popFirst() != nil { n += 1 }
      XCTAssertEqual(n, 2)
      popping = tree[i0 ..< i2]
      n = 0
      while popping.popLast() != nil { n += 1 }
      XCTAssertEqual(n, 2)
      var removing = tree[i0 ..< i2]
      _ = removing.removeFirst()
      _ = removing.removeLast()
      XCTAssertTrue(removing.isEmpty)
      removing = tree[i0 ..< i2]
      removing.removeFirst(1)
      removing.removeLast(1)
      XCTAssertTrue(removing.isEmpty)
      var erasing = tree[i0 ..< i2]
      _ = erasing.erase()
      XCTAssertTrue(erasing.isEmpty)
      erasing = tree[i0 ..< i2]
      erasing.erase(where: { _ in true })
      XCTAssertTrue(erasing.isEmpty)
      erasing = tree[i0 ..< i2]
      erasing.removeAll()
      XCTAssertTrue(erasing.isEmpty)
      erasing = tree[i0 ..< i2]
      erasing.removeAll(where: { _ in true })
      XCTAssertTrue(erasing.isEmpty)

      XCTAssertEqual(tree.distance(from: i0, to: i2), 2)
      XCTAssertEqual(tree.distance(from: i2, to: i0), -2)
      XCTAssertEqual(tree.index(i0, offsetBy: 2, limitedBy: tree.endIndex), i2)
      XCTAssertEqual(tree.index(i2, offsetBy: -2, limitedBy: i0), i0)
      XCTAssertTrue(tree.containsSubrange(i0 ..< i2))

      var erasingTree = make()
      _ = erasingTree.erase(erasingTree.startIndex ..< erasingTree.index(after: erasingTree.startIndex))
      XCTAssertEqual(erasingTree.count, 2)
      erasingTree = make()
      erasingTree.erase(erasingTree.startIndex ..< erasingTree.endIndex, where: { _ in true })
      XCTAssertEqual(erasingTree.count, 0)
    }
  }
#endif
