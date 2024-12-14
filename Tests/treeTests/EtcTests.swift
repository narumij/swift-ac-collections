//
//  EtcTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2024/12/15.
//

import XCTest
import RedBlackTreeModule

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
      
      var a = "abcdefg"
      a.index(after: a.startIndex)
      a.index(a.startIndex, offsetBy: 3)
      
      var b: RedBlackTreeSet<Int> = [1,2,3]
      b.index(after: b.startIndex)
      
      XCTAssertEqual(b.index(b.startIndex, offsetBy: 3), .end)
      XCTAssertEqual(b.map { $0 * 2 }, [2,4,6])
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
