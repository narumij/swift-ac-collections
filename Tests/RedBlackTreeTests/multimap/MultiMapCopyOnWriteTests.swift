import RedBlackTreeModule
import XCTest

#if AC_COLLECTIONS_INTERNAL_CHECKS
final class MultiMapCopyOnWriteTests: XCTestCase {
  
  typealias Target = RedBlackTreeMultiMap<Int,Int>

  let count = 2_000_000
  var tree: Target = .init()

  override func setUpWithError() throws {
    tree = .init(keysWithValues: (0 ..< 20).map{ ($0,$0) })
  }

  override func tearDownWithError() throws {
  }

  func testSet1() throws {
    var multiset = RedBlackTreeMultiMap<Int,Int>()
    XCTAssertEqual(multiset._copyCount, 0)
    multiset.insert(key: 0,value: 0)
    XCTAssertGreaterThanOrEqual(multiset._copyCount, 1) // 挿入に備え、かつ消費
    while multiset.count < multiset.capacity {
      multiset.insert(key: 0,value: 0)
      XCTAssertGreaterThanOrEqual(multiset._copyCount, 1) // capacityを消費仕切るまで変わらない
    }
    multiset.insert(key: 0,value: 0)
    XCTAssertGreaterThanOrEqual(multiset._copyCount, 2) // 挿入に備え、かつ消費
    while multiset.count < multiset.capacity {
      multiset.insert(key: 0,value: 0)
      XCTAssertGreaterThanOrEqual(multiset._copyCount, 1) // capacityを消費仕切るまで変わらない
    }
    multiset.insert(key: 0,value: 0)
    XCTAssertGreaterThanOrEqual(multiset._copyCount, 3) // 挿入に備え、かつ消費
  }

  func testSet2() throws {
    var set = RedBlackTreeMultiMap<Int,Int>(minimumCapacity: 1)
    XCTAssertEqual(set._copyCount, 0)
    set.insert(key: 0,value: 0)
    XCTAssertEqual(set._copyCount, 0)
    set.removeAll(forKey: 0)
    XCTAssertEqual(set._copyCount, 0)
    _ = set.lowerBound(0)
    _ = set.upperBound(0)
    for s in set {
      print(s)
    }
    set.forEach {
      print($0)
    }
    print(set.map{ $0 })
    print(set.filter{ $0 != (0,0) })
//    print(set.reduce(0, +))
    print(set.reduce(into: []) { $0.append($1) })
    XCTAssertEqual(set._copyCount, 0)
  }
  
  func testSet3() throws {
    tree._copyCount = 0
    for v in tree {
      tree.removeFirst(forKey: v.key) // strong ensure unique
    }
    XCTAssertEqual(tree.count, 0)
    XCTAssertEqual(tree._copyCount, 1) // multi setの場合、インデックスを破壊するので1とする
  }
  
  func testSet3_2() throws {
    tree._copyCount = 0
    for v in tree.map({ $0 }) {
      tree.removeFirst(forKey: v.key) // strong ensure unique
    }
    XCTAssertEqual(tree.count, 0)
    XCTAssertEqual(tree._copyCount, 0) // mapで操作が済んでいるので、インデックス破壊の心配がない
  }
  
  func testSet3_3() throws {
    tree._copyCount = 0
    for v in tree.map({ $0 }) {
      tree.removeFirst(_unsafeForKey: v.key) // strong ensure unique
    }
    XCTAssertEqual(tree.count, 0)
    XCTAssertEqual(tree._copyCount, 0) // mapで操作が済んでいるので、インデックス破壊の心配がない
  }

  func testSet4() throws {
    tree._copyCount = 0
    tree.forEach { v in
      tree.removeFirst(forKey: v.key)
    }
    XCTAssertEqual(tree.count, 0)
    XCTAssertEqual(tree._copyCount, 1)
  }

  func testSet5() throws {
    tree._copyCount = 0
    for v in tree.map({ $0}) {
      tree.removeFirst(forKey: v.key)
    }
    XCTAssertEqual(tree.count, 0)
    XCTAssertEqual(tree._copyCount, 0)
  }
  
  func testSet6() throws {
    tree._copyCount = 0
    for v in tree.filter({ _ in true }) {
      tree.removeAll(forKey: v.key)
    }
    XCTAssertEqual(tree.count, 0)
    XCTAssertEqual(tree._copyCount, 0)
  }
  
  func testSet7() throws {
    tree._copyCount = 0
    for v in tree {
      tree.removeAll(forKey: v.key)
    }
    XCTAssertEqual(tree.count, 0)
    XCTAssertEqual(tree._copyCount, 1) // multi setの場合、インデックスを破壊するので1とする
  }
  
  func testSet8() throws {
    tree._copyCount = 0
    for v in tree.map({ $0 }) {
      tree.removeAll(forKey: v.key)
    }
    XCTAssertEqual(tree.count, 0)
    XCTAssertEqual(tree._copyCount, 0) // mapで操作が済んでいるので、インデックス破壊の心配がない
  }

  func testSet9() throws {
    tree._copyCount = 0
    tree.forEach { v in
      tree.removeAll(forKey: v.key)
    }
    XCTAssertEqual(tree.count, 0)
    XCTAssertEqual(tree._copyCount, 1)
  }

  func testSet10() throws {
    tree._copyCount = 0
    for v in tree.map({ $0}) {
      tree.removeAll(forKey: v.key)
    }
    XCTAssertEqual(tree.count, 0)
    XCTAssertEqual(tree._copyCount, 0)
  }
  
  func testSet11() throws {
    tree._copyCount = 0
    for v in tree.filter({ _ in true }) {
      tree.removeAll(forKey: v.key)
    }
    XCTAssertEqual(tree.count, 0)
    XCTAssertEqual(tree._copyCount, 0)
  }
  
  func testSet12() throws {
    tree._copyCount = 0
    for v in tree.filter({ _ in true }) {
      tree.removeAll(_unsafeForKey: v.key)
    }
    XCTAssertEqual(tree.count, 0)
    XCTAssertEqual(tree._copyCount, 0)
  }


  func testSet3000() throws {
    let count = 1500
    var loopCount = 0
    var xy: [Int: RedBlackTreeMultiMap<Int,Int>] = [1: .init(keysWithValues: (0 ..< count).map{ ($0,$0) })]
    xy[1]?._copyCount = 0
    let N = 100
    for i in 0 ..< count / N {
      loopCount += 1
      if let lo = xy[1]?.lowerBound(i * N),
         let hi = xy[1]?.upperBound(i * N + N) {
        xy[1]?.removeSubrange(lo ..< hi)
      }
    }
    XCTAssertTrue(xy[1]!._checkUnique())
    XCTAssertEqual(xy[1]!.count, 0)
    XCTAssertEqual(xy[1]!._copyCount, 0)
    XCTAssertEqual(loopCount, count / N)
  }

  func testSet4000() throws {
    let count = 1500
    var xy: [Int: RedBlackTreeMultiMap<Int,Int>] = [1: .init(keysWithValues: (0 ..< count).map{ ($0,$0) })]
    xy[1]?._copyCount = 0
    let N = 100
    var loopCount = 0
    for i in 0 ..< count / N {
      loopCount += 1
      xy[1]?[(i * N) ..< (i * N + N)].enumerated().forEach { i, v in
        xy[1]?.remove(at: i)
      }
    }
    XCTAssertTrue(xy[1]!._checkUnique())
    XCTAssertEqual(xy[1]!.count, 0)
    XCTAssertEqual(xy[1]!._copyCount, 0)
    XCTAssertEqual(loopCount, count / N)
  }
}
#endif
