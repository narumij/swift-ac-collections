//
//  EtcTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2024/12/15.
//

import RedBlackTreeModule
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

    XCTAssertEqual(b.index(b.startIndex, offsetBy: 3), nil)
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

  func testPerformanceDistanceFromTo() throws {
    let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
    self.measure {
      // BidirectionalCollectionの実装の場合、0.3sec
      // 木の場合、0.08sec
      // 片方がendIndexの場合、その部分だけO(1)となるよう修正
      XCTAssertEqual(s.distance(from: s.endIndex, to: s.startIndex), -1_000_000)
    }
  }

  func testPerformanceIndexOffsetBy1() throws {
    let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
    self.measure {
      XCTAssertEqual(s.index(s.startIndex, offsetBy: 1_000_000), s.endIndex)
    }
  }

  func testPerformanceIndexOffsetBy2() throws {
    let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
    self.measure {
      XCTAssertEqual(s.index(s.endIndex, offsetBy: -1_000_000), s.startIndex)
    }
  }

}
