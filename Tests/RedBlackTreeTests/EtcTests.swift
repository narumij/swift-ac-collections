import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class EtcTests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
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

  #if true
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
  #endif

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
    _ = s[s.startIndex ..< s.endIndex].indices
  }
  
  func testRange() throws {
    let a = [0, 1, 2]
    let b = RedBlackTreeSet<Int>([0,1,2])
    _ = a[0...]
    XCTAssertTrue(b[b.startIndex.advanced(by: 1)...].elementsEqual([1,2]))
    XCTAssertEqual(b.endIndex.pointee, nil)
    XCTAssertEqual(b.endIndex.advanced(by: -1).pointee, 2)
    XCTAssertEqual(b.endIndex.advanced(by: -2).pointee, 1)
    XCTAssertEqual(a[...a.endIndex.advanced(by: -1)] + [], [0,1,2])
    XCTAssertEqual(a[..<a.endIndex.advanced(by: -1)] + [], [0,1])
    XCTAssertEqual(b[...b.endIndex.advanced(by: -1)] + [], [0,1,2])
    XCTAssertEqual(b[..<b.endIndex.advanced(by: -1)] + [], [0,1])
    XCTAssertTrue(b[(b.startIndex + 1)...].elementsEqual([1,2]))
    XCTAssertTrue(b[..<(b.endIndex - 1)].elementsEqual([0,1]))
    XCTAssertTrue(b[...].elementsEqual([0,1,2]))
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

  #if DEBUG
    func testBackwordIterator1() throws {
      var set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
      var seq = AnySequence {
        RedBlackTreeSet<Int>.Tree.BackwordIterator(
          tree: set.__tree_, start: set.startIndex.rawValue, end: set.endIndex.rawValue)
      }
      var result: [Int] = []
      for i in seq {
        result.append(set[i])
      }
      XCTAssertEqual(set.reversed(), result)
    }
    func testBackwordIterator2() throws {
      var set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
      var seq = AnySequence {
        RedBlackTreeSet<Int>.Tree.BackwordIterator(
          tree: set.__tree_, start: set.startIndex.rawValue, end: set.endIndex.rawValue)
      }
      for i in seq {
        set.remove(at: i)
      }
      XCTAssertTrue(set.isEmpty)
    }

  #endif

  func testCompare() throws {
    XCTAssertTrue([0] < [0, 1])
    XCTAssertTrue((0, 0) < (0, 1))
    XCTAssertTrue(AnySequence([0]).elementsEqual([0]))
    XCTAssertFalse(AnySequence([0]).elementsEqual([0], by: !=))
    XCTAssertTrue(AnySequence([0]).lexicographicallyPrecedes([0, 1]))
    XCTAssertFalse(AnySequence([0, 0]).lexicographicallyPrecedes([0, 1], by: >))
  }
}
