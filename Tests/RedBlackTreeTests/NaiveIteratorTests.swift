//
//  NaiveIteratorTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/15.
//

import XCTest
#if DEBUG
@testable import RedBlackTreeModule

final class NaiveIteratorTests: XCTestCase {

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
    }
  
  func testForward() throws {
    let a = RedBlackTreeSet<Int>(0..<5)
    let it = ___UnsafeNaiveIterator(nullptr: a.__tree_.nullptr,
                                    __first: a.__tree_.__begin_node_,
                                    __last: a.__tree_.__end_node)
    XCTAssertEqual(it.map { a.__tree_[$0] }, Array<Int>(0..<5))
  }
  
  func testReverse() throws {
    let a = RedBlackTreeSet<Int>(0..<5)
    let it = ___UnsafeNaiveRevIterator(nullptr: a.__tree_.nullptr,
                                       __first: a.__tree_.__begin_node_,
                                       __last: a.__tree_.__end_node)
    XCTAssertEqual(it.map { a.__tree_[$0] }, Array<Int>(0..<5).reversed())
  }


    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
#endif
