//
//  NextPermutationTests.swift
//  
//
//  Created by narumij on 2023/12/03.
//

import XCTest
@testable import AcCollections
import Algorithms

final class NextPermutationTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPermutations() throws {
        let a = (0..<5) + []
        var b = (0..<5) + []
        b.sort()
        for a in a.permutations() {
            XCTAssertEqual(a, b)
            _ = b.nextPermutation()
        }
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
