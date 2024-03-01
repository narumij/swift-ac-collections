//
//  RedBlackDictionaryTests.swift
//  
//
//  Created by narumij on 2024/02/01.
//

import XCTest
@testable import AcCollections

final class RedBlackDictionaryTests: XCTestCase {

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
    
    func test0() throws {
        var d = RedBlackDictionary<Int,Int>()
        XCTAssertEqual(0, d.count)
    }

    func test1() throws {
        var d = RedBlackDictionary<Int,Int>()
        d[0] = 10
        XCTAssertEqual(1, d.count)
        XCTAssertEqual(10, d[0])
    }

    func test2() throws {
        var d = RedBlackDictionary<Int,Int>()
        d[0] = 10
        d[1] = 1
        XCTAssertEqual(2, d.count)
        XCTAssertEqual(10, d[0])
        XCTAssertEqual(1, d[1])
        XCTAssertEqual(10, d.first)
        XCTAssertEqual(1, d.last)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
