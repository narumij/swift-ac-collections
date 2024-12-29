//
//  EtcTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2024/12/15.
//

@testable import RedBlackTreeModule
import XCTest

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

    XCTAssertEqual(b.index(b.startIndex, offsetBy: 3).pointer, .end)
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
  
  func testHoge() throws {
//    typealias A = RedBlackTreeSet<Int>.SubSequence
//    [1,2].enumerated().map {}
//    a.reserveCapacity(1)
//    a.withUnsafeMutableBufferPointer {
//      $0.initializeElement(at: 0, to: 3)
//    }
//    XCTAssertEqual(a[0], 3)
    let a = [1,2,3]
    
//    a.enumerated()
  }
  
//  func testIndexAfer() throws {
//    let a: Set<Int> = [1,2,3]
//    XCTAssertEqual(a.index(after: a.endIndex), a.endIndex)
//  }
}
