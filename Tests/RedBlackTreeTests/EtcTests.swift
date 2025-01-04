//
//  EtcTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2024/12/15.
//

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

    XCTAssertEqual(b.map { $0 }, [2, 3])

    XCTAssertEqual(b.distance(from: b.lowerBound(2), to: b.lowerBound(3)), 1)
    XCTAssertEqual(b.distance(from: b.lowerBound(3), to: b.lowerBound(2)), -1)

//    let c: [Int:Int] = [1:1, 1:2]
//    let c: [Int:Int] = .init(uniqueKeysWithValues: [(1,1),(1,2)])
//    let d: RedBlackTreeDictionary<Int,Int> = .init(uniqueKeysWithValues: [(1,1),(1,2)])
//    let e: Set<Int> = .init()
  }

  func testExample2() throws {
    let b: RedBlackTreeMultiset<Int> = [1, 1, 2, 2, 2, 3]
    XCTAssertEqual(b.count, 6)
    XCTAssertEqual(b.count(1), 2)
    XCTAssertEqual(b.count(2), 3)
    XCTAssertEqual(b.count(3), 1)
  }

  func testExample3() throws {
    let b: Set<Int> = [1,2,3]
    XCTAssertEqual(b.distance(from: b.startIndex, to: b.endIndex), 3)
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
    let a = [1,2,3]
    XCTAssertEqual(a.index(before: a.startIndex), -1)
  }
  
  func testRemoving() throws {
    
    do {
      var b: RedBlackTreeSet<Int> = [0,1,2,3,4,5]
      for (i,_) in b[b.startIndex ..< b.endIndex].enumerated() {
        b.remove(at: i) // iはこの時点で無効になる
        XCTAssertFalse(b.isValid(index: i))
      }
      XCTAssertEqual(b.count, 0)
    }
    
    do {
      var b: RedBlackTreeSet<Int> = [0,1,2,3,4,5]
      var i = b.startIndex // 都度異なる値となる
      while i != b.endIndex { // endIndexは特殊な値なので、不変です。
        let j = i
        i = b.index(after: i)
        b.remove(at: j) // jはこの時点で無効になる
        XCTAssertFalse(b.isValid(index: j))
      }
      XCTAssertEqual(b.count, 0)
    }
    
    do {
      var b: RedBlackTreeSet<Int> = [0,1,2,3,4,5]
      b.removeSubrange(b.startIndex ..< b.endIndex) // startIndexからendIndex -1までが無効になる
      XCTAssertEqual(b.count, 0)
    }
    
    do {
      var b: RedBlackTreeSet<Int> = [0,1,2,3,4,5]
      var i = b.startIndex // 都度異なる値となる
      while i != b.endIndex { // endIndexは特殊な値なので、不変です。
        // extensionを書けばこのように利用可能
        i = b.erase(at: i)
        XCTAssertTrue(b.isValid(index: i)) // 次を指しているの有効
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
      (12 ..< 16).forEach {
        b.remove($0)
      }
      
      print("end")
    }
  }
  
  func testSome() throws {
    var set = RedBlackTreeSet<Int>((0 ..< 50).shuffled())
    print("!")
    _fixLifetime(set)
  }
  
  func loop(
    condition: @escaping () -> Bool,
    expression: @escaping () -> Void) -> UnfoldFirstSequence<Void> {
    Swift.sequence(first: (), next: { expression(); return condition() ? () : nil })
  }

  func loop(condition: @escaping () -> Bool) -> UnfoldFirstSequence<Void> {
    Swift.sequence(first: (), next: { condition() ? () : nil })
  }

  func forLoop<I>(initial: I, condition: (inout I) -> Bool, expression: (inout I) -> Void, body: (inout I) -> Void) {
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
      forLoop(initial: 0, condition: { $0 < 10 }, expression: { $0 += 1}) { i in
        a.append(i)
      }
//      forLoop(condition: { i < 10}, expression: { i += 1 }) {
//        a.append(i)
//      }
      XCTAssertEqual(a, (0 ..< 10) + [])
    }
    do {
      var a: [Int] = []
      var i = 0
      forLoop(condition: { i < 0}, expression: { i += 1 }) {
        a.append(i)
      }
      XCTAssertEqual(a, [])
    }
  }

#if false
  func testCapacity() throws {
    
    for i in 0 ..< 10 {
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
    
    for i in 2 ..< 4 {
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
  
  func testPerformanceSuffix1() throws {
    throw XCTSkip()
    let s: String = (0 ..< 10_000_000).map { _ in "a" }.joined()
    self.measure {
      _ = s.suffix(10)
    }
  }
  
  func testPerformanceSuffix2() throws {
    throw XCTSkip()
    let s: [Int] = (0 ..< 10_000_000).map { _ in 1 }
    self.measure {
      _ = s.suffix(10)
    }
  }

}
