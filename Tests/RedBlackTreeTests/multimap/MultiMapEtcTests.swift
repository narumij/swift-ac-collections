import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class MultiMapEtcTests: RedBlackTreeTestCase {

  typealias Target1 = RedBlackTreeMultiMap<Int, Int>

  var target1 = Target1()

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    try super.setUpWithError()
    target1 = [(0, 0), (0, 1), (0, 2), (1, 5), (1, 4), (1, 3), (2, 6), (2, 7), (2, 8)]
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    try super.tearDownWithError()
  }

  func testExample0() throws {
    for i in target1.indices {
      target1.remove(at: i)
    }
    XCTAssertTrue(target1.isEmpty)
  }

  func testExample1() throws {
    target1.indices.forEach { i in
      target1.remove(at: i)
    }
    XCTAssertTrue(target1.isEmpty)
  }

#if DEBUG
  func testExample___0() throws {
    for i in target1.___node_positions() {
      target1.___remove(at: i)
    }
    XCTAssertTrue(target1.isEmpty)
  }

  func testExample___1() throws {
    target1.___node_positions().forEach { i in
      target1.___remove(at: i)
    }
    XCTAssertTrue(target1.isEmpty)
  }
#endif

  #if false
    func testExample2() throws {
      for i in target1[target1.startIndex..<target1.endIndex].indices {
        target1.remove(at: i)
      }
      XCTAssertTrue(target1.isEmpty)
    }

    func testExample3() throws {
      for i in target1[target1.startIndex..<target1.endIndex].rawIndices {
        target1.remove(at: i)
      }
      XCTAssertTrue(target1.isEmpty)
    }
  #endif

  func testMultiMapAndMultiMap1() throws {
    var lhs: RedBlackTreeMultiMap<String, String> = ["イートハーブの香る": "なんとか"]
    let rhs: RedBlackTreeMultiMap<String, String> = ["foo": "bar"]
    lhs.insert(contentsOf: rhs)
    XCTAssertEqual(lhs, ["イートハーブの香る": "なんとか", "foo": "bar"])
    XCTAssertEqual(rhs, ["foo": "bar"])
  }

  func testMultiMapAndMultiMap2() throws {
    let lhs: RedBlackTreeMultiMap<String, String> = ["イートハーブの香る": "なんとか"]
    let rhs: RedBlackTreeMultiMap<String, String> = ["foo": "bar"]
    XCTAssertEqual(lhs.inserting(contentsOf: rhs), ["イートハーブの香る": "なんとか", "foo": "bar"])
    XCTAssertEqual(lhs, ["イートハーブの香る": "なんとか"])
    XCTAssertEqual(rhs, ["foo": "bar"])
  }

  func testMultiMapAndMultiMap3() throws {
    var lhs: RedBlackTreeMultiMap<String, String> = ["イートハーブの香る": "なんとか"]
    lhs.insert(contentsOf: [("foo", "bar")])
    XCTAssertEqual(lhs, ["イートハーブの香る": "なんとか", "foo": "bar"])
  }

  func testMultiMapAndMultiMap4() throws {
    let lhs: RedBlackTreeMultiMap<String, String> = ["イートハーブの香る": "なんとか"]
    XCTAssertEqual(
      lhs.inserting(contentsOf: AnySequence([("foo", "bar")])), ["イートハーブの香る": "なんとか", "foo": "bar"])
    XCTAssertEqual(lhs, ["イートハーブの香る": "なんとか"])
  }

  func testMultiMapAndMultiMap5() throws {
    var lhs: RedBlackTreeMultiMap<String, String> = ["イートハーブの香る": "なんとか"]
    let rhs: RedBlackTreeMultiMap<String, String> = ["foo": "bar"]
    lhs.insert(contentsOf: rhs.map { $0 })
    XCTAssertEqual(lhs, ["イートハーブの香る": "なんとか", "foo": "bar"])
    XCTAssertEqual(rhs, ["foo": "bar"])
  }

  func testMultiMapAndMultiMap6() throws {
    let lhs: RedBlackTreeMultiMap<String, String> = ["イートハーブの香る": "なんとか"]
    let rhs: RedBlackTreeMultiMap<String, String> = ["foo": "bar"]
    XCTAssertEqual(lhs.inserting(contentsOf: rhs.map { $0 }), ["イートハーブの香る": "なんとか", "foo": "bar"])
    XCTAssertEqual(lhs, ["イートハーブの香る": "なんとか"])
    XCTAssertEqual(rhs, ["foo": "bar"])
  }

  func testMultiMapAndDictionary1() throws {
    var lhs: RedBlackTreeMultiMap<String, String> = ["イートハーブの香る": "なんとか"]
    let rhs: RedBlackTreeDictionary<String, String> = ["foo": "bar"]
    lhs.insert(contentsOf: rhs.map { $0 })
    XCTAssertEqual(lhs, ["イートハーブの香る": "なんとか", "foo": "bar"])
    XCTAssertEqual(rhs, ["foo": "bar"])
  }

  func testMultiMapAndDictionary2() throws {
    let lhs: RedBlackTreeMultiMap<String, String> = ["イートハーブの香る": "なんとか"]
    let rhs: RedBlackTreeDictionary<String, String> = ["foo": "bar"]
    XCTAssertEqual(lhs.inserting(contentsOf: rhs.map { $0 }), ["イートハーブの香る": "なんとか", "foo": "bar"])
    XCTAssertEqual(lhs, ["イートハーブの香る": "なんとか"])
    XCTAssertEqual(rhs, ["foo": "bar"])
  }

  func testMapValue() throws {
    XCTAssertEqual(
      target1.mapValues { $0 * 2 },
      [(0, 0), (0, 2), (0, 4), (1, 10), (1, 8), (1, 6), (2, 12), (2, 14), (2, 16)])
  }

  func testCompactMapValue() throws {
    XCTAssertEqual(
      target1.compactMapValues { $0 >= 5 ? ($0 - 5) * 2 : nil },
      [(1, 0), (2, 2), (2, 4), (2, 6)])
  }

  func testPopFirst1() throws {
    let f = target1.popFirst()
    XCTAssertEqual(f?.key, 0)
    XCTAssertEqual(f?.value, 0)
  }

  func testPopFirst2() throws {
    var t = Target1()
    let f = t.popFirst()
    XCTAssertNil(f?.key)
    XCTAssertNil(f?.value)
  }

  func testRemoveFirst() throws {
#if !USE_OLD_FIND
    throw XCTSkip("挙動が変わるためスキップ")
#endif
    do {
      XCTAssertFalse(target1.removeFirst(forKey: 3))
      let expected = [(0, 0), (0, 1), (0, 2), (1, 5), (1, 4), (1, 3), (2, 6), (2, 7), (2, 8)]
      XCTAssertEqual(
        target1.map { __key($0) },
        expected.map { $0.0 })
      XCTAssertEqual(
        target1.map { __value($0) },
        expected.map { $0.1 })
    }
    do {
      XCTAssertTrue(target1.removeFirst(forKey: 1))
      let expected = [(0, 0), (0, 1), (0, 2), (1, 4), (1, 3), (2, 6), (2, 7), (2, 8)]
      XCTAssertEqual(
        target1.map { __key($0) },
        expected.map { $0.0 })
      XCTAssertEqual(
        target1.map { __value($0) },
        expected.map { $0.1 })
    }
    do {
      XCTAssertTrue(target1.removeFirst(forKey: 2))
      let expected = [(0, 0), (0, 1), (0, 2), (1, 4), (1, 3), (2, 7), (2, 8)]
      XCTAssertEqual(
        target1.map { __key($0) },
        expected.map { $0.0 })
      XCTAssertEqual(
        target1.map { __value($0) },
        expected.map { $0.1 })
    }
    do {
      XCTAssertTrue(target1.removeFirst(forKey: 0))
      XCTAssertTrue(target1.removeFirst(forKey: 0))
      let expected = [(0, 2), (1, 4), (1, 3), (2, 7), (2, 8)]
      XCTAssertEqual(
        target1.map { __key($0) },
        expected.map { $0.0 })
      XCTAssertEqual(
        target1.map { __value($0) },
        expected.map { $0.1 })
    }
    do {
      XCTAssertTrue(target1.removeFirst(forKey: 1))
      XCTAssertTrue(target1.removeFirst(forKey: 2))
      let expected = [(0, 2), (1, 3), (2, 8)]
      XCTAssertEqual(
        target1.map { __key($0) },
        expected.map { $0.0 })
      XCTAssertEqual(
        target1.map { __value($0) },
        expected.map { $0.1 })
    }
    do {
      XCTAssertTrue(target1.removeFirst(forKey: 0))
      XCTAssertTrue(target1.removeFirst(forKey: 1))
      XCTAssertTrue(target1.removeFirst(forKey: 2))
      let expected: [(Int, Int)] = []
      XCTAssertEqual(
        target1.map { __key($0) },
        expected.map { $0.0 })
      XCTAssertEqual(
        target1.map { __value($0) },
        expected.map { $0.1 })
    }
  }

  func testRemoveAll() throws {
    do {
      XCTAssertEqual(target1.removeAll(forKey: 3), 0)
      let expected = [(0, 0), (0, 1), (0, 2), (1, 5), (1, 4), (1, 3), (2, 6), (2, 7), (2, 8)]
      XCTAssertEqual(
        target1.map { __key($0) },
        expected.map { $0.0 })
      XCTAssertEqual(
        target1.map { __value($0) },
        expected.map { $0.1 })
    }
    do {
      XCTAssertEqual(target1.removeAll(forKey: 1), 3)
      let expected = [(0, 0), (0, 1), (0, 2), (2, 6), (2, 7), (2, 8)]
      XCTAssertEqual(
        target1.map { __key($0) },
        expected.map { $0.0 })
      XCTAssertEqual(
        target1.map { __value($0) },
        expected.map { $0.1 })
    }
    do {
      XCTAssertEqual(target1.removeAll(forKey: 2), 3)
      let expected = [(0, 0), (0, 1), (0, 2)]
      XCTAssertEqual(
        target1.map { __key($0) },
        expected.map { $0.0 })
      XCTAssertEqual(
        target1.map { __value($0) },
        expected.map { $0.1 })
    }
    do {
      XCTAssertEqual(target1.removeAll(forKey: 0), 3)
      let expected: [(Int, Int)] = []
      XCTAssertEqual(
        target1.map { __key($0) },
        expected.map { $0.0 })
      XCTAssertEqual(
        target1.map { __value($0) },
        expected.map { $0.1 })
    }
  }

  func testSome() throws {

    var hoge = Target1()

    for k in 0..<100_000 {
      hoge.insert(key: k / 100, value: k)
    }

    XCTAssertEqual(
      hoge.map { __key($0) },
      (0..<100_000).map { $0 / 100 })
    XCTAssertEqual(
      hoge.map { __value($0) },
      (0..<100_000).map { $0 })
  }

  func testComment() throws {
    /// `RedBlackTreeMultiMap` を使用する例
    var multimap = RedBlackTreeMultiMap<String, Int>()
    multimap.insert(key: "apple", value: 5)
    multimap.insert(key: "banana", value: 3)
    multimap.insert(key: "cherry", value: 7)

    // キーを使用して値にアクセス
    let values = multimap.values(forKey: "banana")

    values.forEach { value in
      print("banana の値は \(value) です。")  // 出力例: banana の値は 3 です。
    }

    // キーと値のペアを削除
    multimap.removeFirst(forKey: "apple")
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}
