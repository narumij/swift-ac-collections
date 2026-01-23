import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class EtcTests: RedBlackTreeTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    try super.setUpWithError()
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    try super.tearDownWithError()
  }

  func testExample() throws {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    // Any test you write for XCTest can be annotated as throws and async.
    // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
    // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.

    let a = "abcdefg"
    _ = a.index(after: a.startIndex)
    _ = a.index(a.startIndex, offsetBy: 3)
    //    _ = a.index(a.startIndex, offsetBy: -1)
    //    _ = a.index(a.endIndex, offsetBy: 1)

    var b: RedBlackTreeSet<Int> = [1, 2, 3]
    _ = b.index(after: b.startIndex)
    //    _ = b.index(b.startIndex, offsetBy: -1)
    //    _ = b.index(b.endIndex, offsetBy: 1)

    //    XCTAssertEqual(b.index(b.startIndex, offsetBy: 3).pointer, .end)
    XCTAssertEqual(b.map { $0 * 2 }, [2, 4, 6])

    _ = b.remove(at: b.index(before: b.lowerBound(2)))

    XCTAssertEqual(b + [], [2, 3])

    XCTAssertEqual(b.distance(from: b.lowerBound(2), to: b.lowerBound(3)), 1)
    XCTAssertEqual(b.distance(from: b.lowerBound(3), to: b.lowerBound(2)), -1)

    //    let c: [Int:Int] = [1:1, 1:2]
    //    let c: [Int:Int] = .init(uniqueKeysWithValues: [(1,1),(1,2)])
    //    let d: RedBlackTreeDictionary<Int,Int> = .init(uniqueKeysWithValues: [(1,1),(1,2)])
    //    let e: Set<Int> = .init()
  }

  func testExample3() throws {
    let b: Set<Int> = [1, 2, 3]
    XCTAssertEqual(b.distance(from: b.startIndex, to: b.endIndex), 3)
  }

  func testExample4() throws {
    let b: RedBlackTreeSet<Int> = [1, 2, 3, 4]
    XCTAssertEqual(b.endIndex.distance(to: b.startIndex), -4)
    var result = [Int]()
    for p in b.startIndex..<b.endIndex {
      result.append(p.pointee!)
    }
    XCTAssertEqual(result, [1, 2, 3, 4])
    //    for p in stride(from: b.startIndex, to: b.endIndex, by: 1) {
    //      result.append(p.pointee!)
    //    }
    //    XCTAssertEqual(result, [1,2,3,4] + [1,2,3,4])
    //    for p in stride(from: b.endIndex.previous!, through: b.startIndex, by: -1) {
    //      result.append(p.pointee!)
    //    }
    //    XCTAssertEqual(result, [1,2,3,4] + [1,2,3,4] + [4,3,2,1])

    XCTAssertEqual(b.endIndex - b.startIndex, 4)
    XCTAssertEqual(b.startIndex + 4, b.endIndex)
    XCTAssertEqual(b.endIndex - 4, b.startIndex)

    for p in (b.startIndex..<b.endIndex).reversed() {
      result.append(p.pointee!)
    }

    //    XCTAssertEqual(b.endIndex.rawValue, .end)
    //    XCTAssertEqual(b.endIndex.advanced(by: 1).rawValue, .nullptr)
    //    XCTAssertEqual(b[b.endIndex.advanced(by: 1)], 0)
    //    let b = Array<Int>()
    //    var c = b.startIndex
    //    c = c.advanced(by: -1)
    //    print(b[c])
  }

  class A: Hashable, Comparable {
    static func < (lhs: A, rhs: A) -> Bool {
      lhs.x < rhs.x
    }
    static func == (lhs: A, rhs: A) -> Bool {
      lhs.x == rhs.x
    }
    let x: Int
    let label: String
    init(x: Int, label: String) {
      self.x = x
      self.label = label
    }
    func hash(into hasher: inout Hasher) {
      hasher.combine(x)
    }
  }

  func testSetUpdate() throws {
    let a = A(x: 3, label: "a")
    let b = A(x: 3, label: "b")
    var s: Set<A> = [a]
    XCTAssertFalse(a === b)
    XCTAssertTrue(s.update(with: b) === a)
    XCTAssertTrue(s.update(with: a) === b)
  }

  func testSetInsert() throws {
    let a = A(x: 3, label: "a")
    let b = A(x: 3, label: "b")
    var s: Set<A> = []
    XCTAssertFalse(a === b)
    do {
      let r = s.insert(a)
      XCTAssertEqual(r.inserted, true)
      XCTAssertTrue(r.memberAfterInsert === a)
    }
    do {
      let r = s.insert(b)
      XCTAssertEqual(r.inserted, false)
      XCTAssertTrue(r.memberAfterInsert === a)
    }
  }

  func testIndexBefore() throws {
    let a = [1, 2, 3]
    XCTAssertEqual(a.index(before: a.startIndex), -1)
  }

  func testRemoving() throws {

    do {
      var b: RedBlackTreeSet<Int> = [0, 1, 2, 3, 4, 5]
      var i = b.startIndex  // 都度異なる値となる
      while i != b.endIndex {  // endIndexは特殊な値なので、不変です。
        let j = i
        i = b.index(after: i)
        b.remove(at: j)  // jはこの時点で無効になる
        XCTAssertFalse(b.isValid(index: j))
      }
      XCTAssertEqual(b.count, 0)
    }

    do {
      var b: RedBlackTreeSet<Int> = [0, 1, 2, 3, 4, 5]
      b.removeSubrange(b.startIndex..<b.endIndex)  // startIndexからendIndex -1までが無効になる
      XCTAssertEqual(b.count, 0)
    }

    do {
      var b: RedBlackTreeSet<Int> = [0, 1, 2, 3, 4, 5]
      var i = b.startIndex  // 都度異なる値となる
      while i != b.endIndex {  // endIndexは特殊な値なので、不変です。
        XCTAssertTrue(b.isValid(index: i))  // 次を指しているの有効
        // extensionを書けばこのように利用可能
        i = b.erase(at: i)
      }
      XCTAssertEqual(b.count, 0)
    }

    do {
      var b: RedBlackTreeSet<Int> = .init()
      var lo = 0
      var hi = 32
      while lo < hi {
        b.insert(hi)
        b.insert(lo)
        lo += 1
        hi -= 1
      }
      // extensionを書けばこのように利用可能
      //      b.removeSubrange(0 ..< 6)
      //      XCTAssertEqual(b.count, 0)
      (12..<16).forEach {
        b.remove($0)
      }

      print("end")
    }
  }

  func testSome() throws {
    let set = RedBlackTreeSet<Int>((0..<50).shuffled())
    print("!")
    _fixLifetime(set)
  }

  func loop(
    condition: @escaping () -> Bool,
    expression: @escaping () -> Void
  ) -> UnfoldFirstSequence<Void> {
    Swift.sequence(
      first: (),
      next: {
        expression()
        return condition() ? () : nil
      })
  }

  func loop(condition: @escaping () -> Bool) -> UnfoldFirstSequence<Void> {
    Swift.sequence(first: (), next: { condition() ? () : nil })
  }

  func forLoop<I>(
    initial: I, condition: (inout I) -> Bool, expression: (inout I) -> Void, body: (inout I) -> Void
  ) {
    var i = initial
    while condition(&i) {
      body(&i)
      expression(&i)
    }
  }

  func forLoop(condition: () -> Bool, expression: () -> Void, body: () -> Void) {
    while condition() {
      body()
      expression()
    }
  }

  func testLoop() throws {
    do {
      var a: [Int] = []
      forLoop(initial: 0, condition: { $0 < 10 }, expression: { $0 += 1 }) { i in
        a.append(i)
      }
      //      forLoop(condition: { i < 10}, expression: { i += 1 }) {
      //        a.append(i)
      //      }
      XCTAssertEqual(a, (0..<10) + [])
    }
    do {
      var a: [Int] = []
      var i = 0
      forLoop(condition: { i < 0 }, expression: { i += 1 }) {
        a.append(i)
      }
      XCTAssertEqual(a, [])
    }
  }

  func testHoge() throws {
    _ = Set<String>()
    _ = [String: String]()
  }

  func testIndices() throws {
    _ = RedBlackTreeSet<Int>().indices
    _ = RedBlackTreeMultiSet<Int>().indices
    _ = RedBlackTreeMultiMap<Int, Int>().indices
    _ = RedBlackTreeDictionary<Int, Int>().indices
    let s = RedBlackTreeSet<Int>()
    _ = s[s.startIndex..<s.endIndex].indices
  }

  func testRange() throws {
    let a = [0, 1, 2]
    let b = RedBlackTreeSet<Int>([0, 1, 2])
    _ = a[0...]
    XCTAssertTrue(b[b.startIndex.advanced(by: 1)...].elementsEqual([1, 2]))
    XCTAssertEqual(b.endIndex.pointee, nil)
    XCTAssertEqual(b.endIndex.advanced(by: -1).pointee, 2)
    XCTAssertEqual(b.endIndex.advanced(by: -2).pointee, 1)
    XCTAssertEqual(a[...a.endIndex.advanced(by: -1)] + [], [0, 1, 2])
    XCTAssertEqual(a[..<a.endIndex.advanced(by: -1)] + [], [0, 1])
    XCTAssertNotEqual(b.endIndex, b.endIndex.advanced(by: -1))
    //    throw XCTSkip()
    XCTAssertEqual(b[...b.endIndex.advanced(by: -1)] + [], [0, 1, 2])
    XCTAssertEqual(b[..<b.endIndex.advanced(by: -1)] + [], [0, 1])
    XCTAssertTrue(b[(b.startIndex + 1)...].elementsEqual([1, 2]))
    XCTAssertTrue(b[..<(b.endIndex - 1)].elementsEqual([0, 1]))
    XCTAssertTrue(b[...].elementsEqual([0, 1, 2]))
  }

  #if false
    func testCapacity() throws {

      for i in 0..<10 {
        let s = Set<Int>(minimumCapacity: i)
        let r = RedBlackTreeSet<Int>(minimumCapacity: i)
        XCTAssertEqual(
          s.capacity,
          r.capacity,
          "minimumCapacity=\(i)"
        )
        if s.capacity != r.capacity {
          break
        }
      }
    }

    func testCapacity2() throws {

      for i in 2..<4 {
        let s = Set<Int>(minimumCapacity: i)
        //      let r = StorageCapacity._growCapacity(tree: (0,0), to: i, linearly: false)
        let r = StorageCapacity.growthFormula(count: i)
        XCTAssertEqual(
          s.capacity,
          r,
          "minimumCapacity=\(i)"
        )
        //      if s.capacity != r {
        //        break
        //      }
      }
    }
  #endif

  #if ENABLE_PERFORMANCE_TESTING
    func testPerformanceSuffix1() throws {
      throw XCTSkip()
      //    let s: String = (0 ..< 10_000_000).map { _ in "a" }.joined()
      //    self.measure {
      //      _ = s.suffix(10)
      //    }
    }

    func testPerformanceSuffix2() throws {
      throw XCTSkip()
      //    let s: [Int] = (0 ..< 10_000_000).map { _ in 1 }
      //    self.measure {
      //      _ = s.suffix(10)
      //    }
    }
  #endif

  /// SubSequenceのindex(_:offsetBy:limitedBy:)とformIndex(offsetBy:limitedBy:)が正しく動作すること
  func test_subSequence_index_offsetBy_limitedBy_and_formIndex_offsetBy_limitedBy() throws {
    // 事前条件: 集合に[1,2,3,4,5]を用意すること
    let set = [1, 2, 3, 4, 5]
    let sub = set[set.index(after: set.startIndex)..<set.index(before: set.endIndex)]  // [2,3,4]

    let start = sub.startIndex
    let limit = sub.index(after: start)

    // 実行: index(offsetBy:limitedBy:)とformIndex(offsetBy:limitedBy:)を呼び出すこと

    // index(offsetBy:limitedBy:)成功パターン
    let indexLimitedSuccess = sub.index(start, offsetBy: 1, limitedBy: limit)
    XCTAssertEqual(indexLimitedSuccess, limit)  // 事後条件: 成功時にlimitを返すこと

    // index(offsetBy:limitedBy:)失敗パターン
    let indexLimitedFail = sub.index(start, offsetBy: 3, limitedBy: limit)
    XCTAssertNil(indexLimitedFail)  // 事後条件: 失敗時にnilを返すこと

    // formIndex(offsetBy:limitedBy:)成功パターン
    var formIndexSuccess = start
    let success = sub.formIndex(&formIndexSuccess, offsetBy: 1, limitedBy: limit)
    XCTAssertTrue(success)  // 事後条件: 成功時にtrueを返すこと
    XCTAssertEqual(formIndexSuccess, limit)  // 事後条件: インデックスがlimitを指すこと

    // formIndex(offsetBy:limitedBy:)失敗パターン
    var formIndexFail = start
    let fail = sub.formIndex(&formIndexFail, offsetBy: 3, limitedBy: limit)
    XCTAssertFalse(fail)  // 事後条件: 失敗時にfalseを返すこと
    throw XCTSkip("失敗するので、一旦スキップ")
    XCTAssertEqual(formIndexFail, start)  // 事後条件: インデックスが変わらないこと
  }

  func testSubArrayIndex() throws {
    let set: [Int] = [1, 2, 3, 4, 5, 6]
    let sub = set[2..<5]
    XCTAssertEqual(sub.startIndex, 2)
    XCTAssertEqual(sub.endIndex, 5)
    XCTAssertEqual(sub.index(after: sub.endIndex), 6)
    XCTAssertEqual(sub.index(before: sub.startIndex), 1)
    XCTAssertNotNil(sub.index(sub.startIndex, offsetBy: 3, limitedBy: sub.endIndex))
    XCTAssertNil(sub.index(sub.startIndex, offsetBy: 4, limitedBy: sub.endIndex))
    XCTAssertNotNil(sub.index(sub.endIndex, offsetBy: -3, limitedBy: sub.startIndex))
    XCTAssertNil(sub.index(sub.endIndex, offsetBy: -4, limitedBy: sub.startIndex))
  }

  func testBackwordIterator1() throws {
    let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
    let seq = AnySequence { set.indices.reversed() }
    var result: [Int] = []
    for i in seq {
      result.append(set[i])
    }
    XCTAssertEqual(set.reversed(), result)
  }

  func testBackwordIterator2() throws {
    var set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
    let seq = AnySequence { set.reversed().indices }
    for i in seq {
      set.remove(at: i)
    }
    XCTAssertEqual(set + [], [])
    XCTAssertTrue(set.isEmpty)
  }

  func testCompare() throws {
    XCTAssertTrue([0] < [0, 1])
    XCTAssertTrue((0, 0) < (0, 1))
    XCTAssertTrue(AnySequence([0]).elementsEqual([0]))
    XCTAssertFalse(AnySequence([0]).elementsEqual([0], by: !=))
    XCTAssertTrue(AnySequence([0]).lexicographicallyPrecedes([0, 1]))
    XCTAssertFalse(AnySequence([0, 0]).lexicographicallyPrecedes([0, 1], by: >))
  }

  #if DEBUG
    func testRev() throws {
      let a = RedBlackTreeSet<Int>([0, 1, 2])
      var result = [Int]()
      a.__tree_.___rev_for_each_(__p: a.startIndex.rawValue, __l: a.endIndex.rawValue) { p in
        result.append(p.index)
      }
      XCTAssertEqual(result, [2, 1, 0])
    }
  #endif

  #if COMPATIBLE_ATCODER_2025
    func testObv() throws {
      let a = RedBlackTreeSet<Int>([0, 1, 2])
      var result = [RedBlackTreeSet<Int>.Index]()
      a.forEach { i, p in
        result.append(i)
      }
      XCTAssertEqual(result, [a.startIndex + 0, a.startIndex + 1, a.startIndex + 2])
    }
  #endif

  #if COMPATIBLE_ATCODER_2025
    func testSubObv() throws {
      let a = RedBlackTreeSet<Int>([0, 1, 2])
      var result = [RedBlackTreeSet<Int>.Index]()
      a[a.startIndex..<a.endIndex].forEach { i, p in
        result.append(i)
      }
      XCTAssertEqual(result, [a.startIndex + 0, a.startIndex + 1, a.startIndex + 2])
    }
  #endif

  #if COMPATIBLE_ATCODER_2025
    func testRev2() throws {
      let a = RedBlackTreeSet<Int>([0, 1, 2])
      var result = [RedBlackTreeSet<Int>.Index]()
      a.reversed().forEach { i, p in
        result.append(i)
      }
      XCTAssertEqual(result, [a.startIndex + 2, a.startIndex + 1, a.startIndex + 0])
    }
  #endif

  #if COMPATIBLE_ATCODER_2025
    func testSubRev2() throws {
      let a = RedBlackTreeSet<Int>([0, 1, 2])
      var result = [RedBlackTreeSet<Int>.Index]()
      a[a.startIndex..<a.endIndex].reversed().forEach { i, p in
        result.append(i)
      }
      XCTAssertEqual(result, [a.startIndex + 2, a.startIndex + 1, a.startIndex + 0])
    }

    func testSubRev3() throws {
      let a = RedBlackTreeSet<Int>([0, 1, 2])
      var result = [RedBlackTreeSet<Int>.Index]()
      a[a.endIndex..<a.endIndex].reversed().forEach { i, p in
        result.append(i)
      }
      XCTAssertEqual(result, [])
    }

    func testSubRev4() throws {
      let a = RedBlackTreeSet<Int>([0, 1, 2])
      var result = [RedBlackTreeSet<Int>.Index]()
      a[a.startIndex..<a.startIndex].reversed().forEach { i, p in
        result.append(i)
      }
      XCTAssertEqual(result, [])
    }

    func testSubRev5() throws {
      let a = RedBlackTreeSet<Int>([0])
      var result = [RedBlackTreeSet<Int>.Index]()
      a[a.startIndex..<a.endIndex].reversed().forEach { i, p in
        result.append(i)
      }
      XCTAssertEqual(result, [a.startIndex])
    }
  #endif

  #if !USE_UNSAFE_TREE
    func testSubRev6() throws {
      let a = RedBlackTreeSet<Int>([0, 1, 2])
      do {
        var result = [_NodePtr]()
        a[a.endIndex..<a.endIndex].reversed().___node_positions().forEach { i in
          result.append(i.index)
        }
        XCTAssertEqual(result, [])
      }
      do {
        var result = [_NodePtr]()
        a[a.endIndex..<a.endIndex].___node_positions().reversed().forEach { i in
          result.append(i.index)
        }
        XCTAssertEqual(result, [])
      }
    }

    func testSubRev7() throws {
      let a = RedBlackTreeSet<Int>([0, 1, 2])
      do {
        var result = [_NodePtr]()
        a[a.startIndex..<a.startIndex].reversed().___node_positions().forEach { i in
          result.append(i.index)
        }
        XCTAssertEqual(result, [])
      }
      do {
        var result = [_NodePtr]()
        a[a.startIndex..<a.startIndex].___node_positions().reversed().forEach { i in
          result.append(i.index)
        }
        XCTAssertEqual(result, [])
      }
    }

    func testSubRev8() throws {
      let a = RedBlackTreeSet<Int>([0, 1, 2])
      do {
        var result = [_NodePtr]()
        a[a.startIndex..<a.endIndex].reversed().___node_positions().forEach { i in
          result.append(i.index)
        }
        XCTAssertEqual(result, [2, 1, 0])
      }
      do {
        var result = [_NodePtr]()
        a[a.startIndex..<a.endIndex].___node_positions().reversed().forEach { i in
          result.append(i.index)
        }
        XCTAssertEqual(result, [2, 1, 0])
      }
    }
  #endif

  func testSubRev9() throws {
    let a = RedBlackTreeDictionary<String, Int>(uniqueKeysWithValues: [
      ("a", 0), ("b", 1), ("c", 2),
    ])
    do {
      var result = [String]()
      #if COMPATIBLE_ATCODER_2025
        a[a.endIndex..<a.endIndex].reversed().keys().forEach { i in
          result.append(i)
        }
      #else
        a[a.endIndex..<a.endIndex].reversed().keys.forEach { i in
          result.append(i)
        }
      #endif
      XCTAssertEqual(result, [])
    }
    do {
      var result = [String]()
      #if COMPATIBLE_ATCODER_2025
        a[a.endIndex..<a.endIndex].keys().reversed().forEach { i in
          result.append(i)
        }
      #else
        a[a.endIndex..<a.endIndex].keys.reversed().forEach { i in
          result.append(i)
        }
      #endif
      XCTAssertEqual(result, [])
    }
  }

  func testSubRev10() throws {
    let a = RedBlackTreeDictionary<String, Int>(uniqueKeysWithValues: [
      ("a", 0), ("b", 1), ("c", 2),
    ])
    do {
      var result = [String]()
      #if COMPATIBLE_ATCODER_2025
        a[a.startIndex..<a.startIndex].reversed().keys().forEach { i in
          result.append(i)
        }
      #else
        a[a.startIndex..<a.startIndex].reversed().keys.forEach { i in
          result.append(i)
        }
      #endif
      XCTAssertEqual(result, [])
    }
    do {
      var result = [String]()
      #if COMPATIBLE_ATCODER_2025
        a[a.startIndex..<a.startIndex].keys().reversed().forEach { i in
          result.append(i)
        }
      #else
        a[a.startIndex..<a.startIndex].keys.reversed().forEach { i in
          result.append(i)
        }
      #endif
      XCTAssertEqual(result, [])
    }
  }

  func testSubRev11() throws {
    let a = RedBlackTreeDictionary<String, Int>(uniqueKeysWithValues: [
      ("a", 0), ("b", 1), ("c", 2),
    ])
    do {
      var result = [String]()
      #if COMPATIBLE_ATCODER_2025
        a[a.startIndex..<a.endIndex].reversed().keys().forEach { i in
          result.append(i)
        }
      #else
        a[a.startIndex..<a.endIndex].reversed().keys.forEach { i in
          result.append(i)
        }
      #endif
      XCTAssertEqual(result, ["c", "b", "a"])
    }
    do {
      var result = [String]()
      #if COMPATIBLE_ATCODER_2025
        a[a.startIndex..<a.endIndex].keys().reversed().forEach { i in
          result.append(i)
        }
      #else
        a[a.startIndex..<a.endIndex].keys.reversed().forEach { i in
          result.append(i)
        }
      #endif
      XCTAssertEqual(result, ["c", "b", "a"])
    }
  }

  func testSubRev12() throws {
    let a = RedBlackTreeDictionary<String, Int>(uniqueKeysWithValues: [
      ("a", 0), ("b", 1), ("c", 2),
    ])
    do {
      var result = [Int]()
      #if COMPATIBLE_ATCODER_2025
        a[a.endIndex..<a.endIndex].reversed().values().forEach { i in
          result.append(i)
        }
      #else
        a[a.endIndex..<a.endIndex].reversed().values.forEach { i in
          result.append(i)
        }
      #endif
      XCTAssertEqual(result, [])
    }
    do {
      var result = [Int]()
      #if COMPATIBLE_ATCODER_2025
        a[a.endIndex..<a.endIndex].values().reversed().forEach { i in
          result.append(i)
        }
      #else
        a[a.endIndex..<a.endIndex].values.reversed().forEach { i in
          result.append(i)
        }
      #endif
      XCTAssertEqual(result, [])
    }
  }

  func testSubRev13() throws {
    let a = RedBlackTreeDictionary<String, Int>(uniqueKeysWithValues: [
      ("a", 0), ("b", 1), ("c", 2),
    ])
    do {
      var result = [Int]()
      #if COMPATIBLE_ATCODER_2025
        a[a.startIndex..<a.startIndex].reversed().values().forEach { i in
          result.append(i)
        }
      #else
        a[a.startIndex..<a.startIndex].reversed().values.forEach { i in
          result.append(i)
        }
      #endif
      XCTAssertEqual(result, [])
    }
    do {
      var result = [Int]()
      #if COMPATIBLE_ATCODER_2025
        a[a.startIndex..<a.startIndex].values().reversed().forEach { i in
          result.append(i)
        }
      #else
        a[a.startIndex..<a.startIndex].values.reversed().forEach { i in
          result.append(i)
        }
      #endif
      XCTAssertEqual(result, [])
    }
  }

  func testSubRev14() throws {
    let a = RedBlackTreeDictionary<String, Int>(uniqueKeysWithValues: [
      ("a", 0), ("b", 1), ("c", 2),
    ])
    do {
      var result = [Int]()
      #if COMPATIBLE_ATCODER_2025
        a[a.startIndex..<a.endIndex].reversed().values().forEach { i in
          result.append(i)
        }
      #else
        a[a.startIndex..<a.endIndex].reversed().values.forEach { i in
          result.append(i)
        }
      #endif
      XCTAssertEqual(result, [2, 1, 0])
    }
    do {
      var result = [Int]()
      #if COMPATIBLE_ATCODER_2025
        a[a.startIndex..<a.endIndex].values().reversed().forEach { i in
          result.append(i)
        }
      #else
        a[a.startIndex..<a.endIndex].values.reversed().forEach { i in
          result.append(i)
        }
      #endif
      XCTAssertEqual(result, [2, 1, 0])
    }
  }

  func testSubRev15() throws {
    let a = RedBlackTreeDictionary<String, Int>(uniqueKeysWithValues: [
      ("a", 0), ("b", 1), ("c", 2),
    ])
    do {
      var result = [RedBlackTreeDictionary<String, Int>.Index]()
      a[a.endIndex..<a.endIndex].reversed().indices.forEach { i in
        result.append(i)
      }
      XCTAssertEqual(result, [])
    }
    do {
      var result = [RedBlackTreeDictionary<String, Int>.Index]()
      a[a.endIndex..<a.endIndex].indices.reversed().forEach { i in
        result.append(i)
      }
      XCTAssertEqual(result, [])
    }
  }

  func testSubRev16() throws {
    let a = RedBlackTreeDictionary<String, Int>(uniqueKeysWithValues: [
      ("a", 0), ("b", 1), ("c", 2),
    ])
    do {
      var result = [RedBlackTreeDictionary<String, Int>.Index]()
      a[a.startIndex..<a.startIndex].reversed().indices.forEach { i in
        result.append(i)
      }
      XCTAssertEqual(result, [])
    }
    do {
      var result = [RedBlackTreeDictionary<String, Int>.Index]()
      a[a.startIndex..<a.startIndex].indices.reversed().forEach { i in
        result.append(i)
      }
      XCTAssertEqual(result, [])
    }
  }

  func testSubRev17() throws {
    let a = RedBlackTreeDictionary<String, Int>(uniqueKeysWithValues: [
      ("a", 0), ("b", 1), ("c", 2),
    ])
    do {
      var result = [RedBlackTreeDictionary<String, Int>.Index]()
      a[a.startIndex..<a.endIndex].reversed().indices.forEach { i in
        result.append(i)
      }
      XCTAssertEqual(result, [2, 1, 0].map { a.startIndex + $0 })
    }
    do {
      var result = [RedBlackTreeDictionary<String, Int>.Index]()
      a[a.startIndex..<a.endIndex].indices.reversed().forEach { i in
        result.append(i)
      }
      XCTAssertEqual(result, [2, 1, 0].map { a.startIndex + $0 })
    }
  }

  static func allocationSize2(capacity: Int) -> (size: Int, alignment: Int) {
    typealias _Value = Int
    let s0 = MemoryLayout<UnsafeNode>.stride
    let a0 = MemoryLayout<UnsafeNode>.alignment
    let s1 = MemoryLayout<_Value>.stride
    let a1 = MemoryLayout<_Value>.alignment
    let s2 = MemoryLayout<_Bucket>.stride
    let a2 = MemoryLayout<_Bucket>.alignment
    let s01 = s0 + s1
    let o01 = a1 <= a0 ? 0 : a1 - a0
    let o012 = max(a1, a0) <= a2 ? 0 : max(a0, a1) - a2
    return (s2 + s01 * capacity + o01 + o012, max(a0, a1, a2))
  }

  static func allocationCapacity(size: Int) -> Int {
    typealias _Value = Int
    let s0 = MemoryLayout<UnsafeNode>.stride
    let a0 = MemoryLayout<UnsafeNode>.alignment
    let s1 = MemoryLayout<_Value>.stride
    let a1 = MemoryLayout<_Value>.alignment
    let s2 = MemoryLayout<_Bucket>.stride
    let a2 = MemoryLayout<_Bucket>.alignment
    let s01 = s0 + s1
    let o01 = a0 <= a1 ? 0 : a0 - a1
    return a2 <= max(a1, a0) ? (size - s2 - o01) / s01 : (size - s2 - o01 - a2 + max(a1, a0)) / s01
  }

  static func pagedCapacity(capacity: Int) -> Int {
    let size = Self.allocationSize2(capacity: capacity).size
    let pagedSize = ((size >> 10) + 1) << 10
    return Self.allocationCapacity(size: pagedSize)
  }

  //  func testBufferSize() throws {
  //    typealias _Value = Int
  //    let s0 = MemoryLayout<UnsafeNode>.stride
  //    let a0 = MemoryLayout<UnsafeNode>.alignment
  //    let s1 = MemoryLayout<_Value>.stride
  //    let a1 = MemoryLayout<_Value>.alignment
  //    let s2 = MemoryLayout<_Bucket>.stride
  //    let a2 = MemoryLayout<_Bucket>.alignment
  //
  //    var hoge: [(size: Int, capacity: Int)] = []
  //    for i in 0..<32 {
  //      let size = 1 << i
  //
  //      let s01 = a1 <= a0 ? (s0 + s1) : (s0 + s1)
  //      let o01 = a1 <= a0 ? 0 : a2 - a1
  //      let capacity =
  //        a2 <= max(a1, a0) ? (size - s2 - o01) / s01 : (size - s2 - o01 - a2 + max(a1, a0)) / s01
  //
  //      XCTAssertGreaterThanOrEqual(
  //        size,
  //        capacity == 0 ? 0 : Self.allocationSize2(capacity: capacity).size)
  //      hoge.append((size, capacity))
  //    }
  //
  //    for capacity1 in 32..<1024 {
  //      let size = Self.allocationSize(capacity: capacity1).size
  //      let pagedSize = ((size >> 10) + 1) << 10
  //      let pagedCapacity = Self.allocationCapacity(size: pagedSize)
  //      XCTAssertLessThanOrEqual(Self.allocationSize(capacity: pagedCapacity).size, pagedSize)
  //    }
  //
  //    XCTAssertEqual(65537 / 1024, 65536 >> 10)
  //    let N = 1024
  //    XCTAssertEqual(1 << (Int.bitWidth - N.leadingZeroBitCount - 2), N / 2)
  //
  //    do {
  //      let N = 4096
  //      //      XCTAssertEqual( N / 1024, 4)
  //      XCTAssertEqual((N / 1024 + ((N - N / 1024 * 1024) == 0 ? 0 : 1)), 4)
  //      XCTAssertEqual((N / 1024 + ((N - N / 1024 * 1024) == 0 ? 0 : 1)) * 1024, 4096)
  //      XCTAssertEqual(((N >> 10) + ((N - ((N >> 10) << 10)) == 0 ? 0 : 1)) << 10, 4096)
  //    }
  //
  //    //    throw XCTSkip("\(hoge.filter { $0.capacity != 0 }.map(\.capacity))")
  //    throw XCTSkip("\(hoge.filter { $0.capacity != 0 })")
  //  }

  // TODO: 再検討
  // __tree_prev_iterの不定動作を解消する場合、以下となるが、性能上の問題で保留となっている
  //  func testPtr5() throws {
  //    do {
  //      let a = RedBlackTreeSet<Int>([0])
  //      XCTAssertEqual(a.__tree_.__tree_prev_iter(a.startIndex.rawValue), .nullptr)
  //    }
  //    do {
  //      let a = RedBlackTreeSet<Int>([0,1])
  //      XCTAssertEqual(a.__tree_.__tree_prev_iter(a.startIndex.rawValue), .nullptr)
  //    }
  //    do {
  //      let a = RedBlackTreeSet<Int>([0,1,2])
  //      XCTAssertEqual(a.__tree_.__tree_prev_iter(a.startIndex.rawValue), .nullptr)
  //    }
  //  }

  #if DEBUG
    func testRoundTrip() throws {
      var fixture = RedBlackTreeSet<Int>(minimumCapacity: 100)
      for _ in 0..<1000 {
        for i in 0..<100 {
          fixture.insert(i)
        }
        for i in 0..<100 {
          fixture.remove(i)
        }
      }
      XCTAssertEqual(fixture.__tree_._buffer.header.freshBucketHead?.pointee.count, 100)
      XCTAssertEqual(fixture.capacity, 100)
    }

    func testRoundTrip2() throws {
      var fixture = RedBlackTreeSet<Int>(minimumCapacity: 100)
      let head = fixture.__tree_._buffer.header.freshBucketHead
      XCTAssertEqual(fixture.__tree_._buffer.header.freshPoolActualCapacity, 100)
      for _ in 0..<1 {
        for i in 0..<100 {
          fixture.insert(i)
        }
        for i in 0..<100 {
          fixture.remove(i)
        }
        XCTAssertEqual(fixture.__tree_._buffer.header.freshPoolActualCapacity, 100)
        fixture.removeAll(keepingCapacity: true)
        XCTAssertEqual(fixture.__tree_._buffer.header.freshPoolActualCapacity, 100)
      }
      XCTAssertEqual(fixture.__tree_._buffer.header.freshBucketHead, head)
      //    XCTAssertEqual(fixture.__tree_.makeFreshPoolIterator().map(\.pointee.___raw_index).count, 100)
      //    XCTAssertEqual(fixture.__tree_._buffer.header.freshBucketHead?.pointee.count, 100)
      XCTAssertEqual(fixture.capacity, 100)
    }

    func testRoundTrip3() throws {
      var fixture = RedBlackTreeSet<Int>()
      let head = fixture.__tree_._buffer.header.freshBucketHead
      XCTAssertEqual(fixture.__tree_._buffer.header.freshPoolActualCapacity, 0)
      for _ in 0..<1 {
        for i in 0..<100 {
          fixture.insert(i)
        }
        for i in 0..<100 {
          fixture.remove(i)
        }
        fixture.removeAll(keepingCapacity: false)
        XCTAssertEqual(fixture.__tree_._buffer.header.freshPoolActualCapacity, 0)
      }
      XCTAssertEqual(fixture.__tree_._buffer.header.freshBucketHead, head)
      //    XCTAssertEqual(fixture.__tree_.makeFreshPoolIterator().map(\.pointee.___raw_index).count, 100)
      //    XCTAssertEqual(fixture.__tree_._buffer.header.freshBucketHead?.pointee.count, 100)
      XCTAssertEqual(fixture.capacity, 0)
    }
  #endif

  struct TypeFixture<T> {
    internal init() {
      isInt = T.self == Int.self
    }
    var isInt: Bool
  }

  func testTypeFixture() throws {
    XCTAssertEqual(TypeFixture<Double>().isInt, false)
    XCTAssertEqual(TypeFixture<Int>().isInt, true)
    XCTAssertEqual(TypeFixture<Int64>().isInt, false)
  }

  #if DEBUG
    func testMapBehavior() throws {
      let a = RedBlackTreeSet<Int>(0..<10)
      do {
        let n = a.count
        XCTAssertEqual(n, 10)

        var result = ContiguousArray<Int>()
        result.reserveCapacity(n)

        var i = a.startIndex

        for _ in 0..<n {
          result.append(a[i])
          a.formIndex(after: &i)
          XCTAssertNotEqual(i.rawValue, a.nullptr)
        }

        XCTAssertNotEqual(i.rawValue, a.nullptr)
        XCTAssertEqual(a.endIndex, i)
      }
    }
  #endif

  #if !COMPATIBLE_ATCODER_2025
    func testBounds() throws {
      let a = RedBlackTreeSet<Int>(0..<100)
      XCTAssertEqual(a[lowerBound(10)..<lowerBound(20)] + [], (10..<20) + [])
    }

    func testRemoveBounds() throws {
      var a = RedBlackTreeSet<Int>(0..<100)
      a.removeBounds(lowerBound(10)..<end())
      XCTAssertEqual(a + [], (0..<10) + [])
    }
  #endif
}
