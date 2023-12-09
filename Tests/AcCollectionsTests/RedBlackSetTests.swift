//
//  RedBlackSetTests.swift
//  
//
//  Created by narumij on 2023/12/10.
//

import XCTest
@testable import AcCollections

final class RedBlackSetTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testContains() throws {
        var s = RedBlackSet<Int>()
        s.insert(1)
        s.insert(2)
        s.insert(3)
        s.insert(4)
        XCTAssertFalse(s.contains(0))
        XCTAssertTrue(s.contains(1))
        XCTAssertTrue(s.contains(2))
        XCTAssertTrue(s.contains(3))
        XCTAssertTrue(s.contains(4))
        XCTAssertFalse(s.contains(5))
    }

    func testPrev() throws {
        var s = RedBlackSet<Int>()
        s.insert(1)
        s.insert(2)
        s.insert(3)
        s.insert(4)
        XCTAssertEqual(nil, s.prev(1))
        XCTAssertEqual(1, s.prev(2))
        XCTAssertEqual(2, s.prev(3))
        XCTAssertEqual(3, s.prev(4))
//        XCTAssertEqual(4, s.prev(5))
    }
    
    func testPrevNext() throws {
        var s = RedBlackSet<Int>()
        s.insert(0)
        s.insert(2)
        XCTAssertEqual(0, s.prev(1))
        XCTAssertEqual(2, s.next(1))
    }
    
    func testPrevNext2() throws {
        var s = RedBlackSet<Int>()
        s.insert(0)
        s.insert(2)
        s.insert(7)
        s.insert(9)
        s.insert(10)
        XCTAssertEqual(2, s.prev(3))
    }

    func testNext() throws {
        var s = RedBlackSet<Int>()
        s.insert(1)
        s.insert(2)
        s.insert(3)
        s.insert(4)
        XCTAssertEqual(1, s.next(0))
        XCTAssertEqual(2, s.next(1))
        XCTAssertEqual(3, s.next(2))
        XCTAssertEqual(4, s.next(3))
        XCTAssertEqual(nil, s.next(4))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
