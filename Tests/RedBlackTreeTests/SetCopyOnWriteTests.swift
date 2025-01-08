import RedBlackTreeModule
import XCTest

#if AC_COLLECTIONS_INTERNAL_CHECKS
final class SetCopyOnWriteTests: XCTestCase {

  let count = 2_000_000

  func testSet1() throws {
    var set = RedBlackTreeSet<Int>()
    XCTAssertEqual(set._copyCount, 0)
    set.insert(0)
    XCTAssertEqual(set._copyCount, 1) // 挿入に備えた分増える
    while set.count < set.capacity {
      set.insert((2 ..< Int.max).randomElement()!)
      XCTAssertEqual(set._copyCount, 1) // 挿入に備えた分増える
    }
    set.insert(0)
    XCTAssertEqual(set._copyCount, 2) // 挿入に備えた分増えるが消費していない
    set.insert(0)
    XCTAssertEqual(set._copyCount, 2) // 挿入に備えた必要分をまだ消費していない
    set.insert(1)
    XCTAssertEqual(set._copyCount, 2) // 挿入に備えた必要分を消費したところ
  }

  func testSet2() throws {
    var set = RedBlackTreeSet<Int>(minimumCapacity: 1)
    XCTAssertEqual(set._copyCount, 0)
    set.insert(0)
    XCTAssertEqual(set._copyCount, 0)
    set.remove(0)
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
    print(set.filter{ $0 != 0 })
    print(set.reduce(0, +))
    print(set.reduce(into: []) { $0.append($1) })
    XCTAssertEqual(set._copyCount, 0)
  }
  
  func testSet3() throws {
    var tree = RedBlackTreeSet<Int>(0 ..< 20)
    tree._copyCount = 0
    for v in tree {
      tree.remove(v)
    }
    XCTAssertEqual(tree.count, 0)
    XCTAssertEqual(tree._copyCount, 0) // これが0になる挙動にするか、1になる挙動にするか、悩み
  }

  func testSet4() throws {
    var tree = RedBlackTreeSet<Int>(0 ..< 20)
    tree._copyCount = 0
    tree.forEach { v in
      tree.remove(v)
    }
    XCTAssertEqual(tree.count, 0)
    XCTAssertEqual(tree._copyCount, 1)
  }

  func testSet5() throws {
    var tree = RedBlackTreeSet<Int>(0 ..< 20)
    tree._copyCount = 0
    for v in tree.map({ $0}) {
      tree.remove(v)
    }
    XCTAssertEqual(tree.count, 0)
    XCTAssertEqual(tree._copyCount, 0)
  }
  
  func testSet6() throws {
    var tree = RedBlackTreeSet<Int>(0 ..< 20)
    tree._copyCount = 0
    for v in tree.filter({ _ in true }) {
      tree.remove(v)
    }
    XCTAssertEqual(tree.count, 0)
    XCTAssertEqual(tree._copyCount, 0)
  }

  func testSet3000() throws {
    let count = 1500
    var loopCount = 0
    var xy: [Int: RedBlackTreeSet<Int>] = [1: .init(0 ..< count)]
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
    var xy: [Int: RedBlackTreeSet<Int>] = [1: .init(0 ..< count)]
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
//    XCTAssertEqual(xy[1]!.copyCount, count / N)
    XCTAssertEqual(xy[1]!._copyCount, 0)
    XCTAssertEqual(loopCount, count / N)
  }
}
#endif
