//
//  MultiMapViewTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

import RedBlackTreeModule
import XCTest

#if !COMPATIBLE_ATCODER_2025

  final class MultiMapViewTests: RedBlackTreeTestCase {

    typealias SUT = RedBlackTreeMultiMap<Int, Int>

    var sut: SUT = .init()

    override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
      try super.setUpWithError()
      sut = .init(
        multiKeysWithValues: (0..<5).flatMap { repeatElement($0, count: 4) + [] }.enumerated().map {
          ($1, $0)
        })
    }

    override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      sut = .init()
      try super.tearDownWithError()
    }

    func testExample() throws {
      XCTAssertEqual(sut[0].map { $0.key }, [0, 0, 0, 0])
      XCTAssertEqual(sut[0].map { $0.value }, [0, 1, 2, 3])

      XCTAssertEqual(sut[1].map { $0.key }, [1, 1, 1, 1])
      XCTAssertEqual(sut[1].map { $0.value }, [4, 5, 6, 7])
      sut[1].popFirst()
      XCTAssertEqual(sut[1].map { $0.key }, [1, 1, 1])
      XCTAssertEqual(sut[1].map { $0.value }, [5, 6, 7])
      sut[1].popLast()
      XCTAssertEqual(sut[1].map { $0.key }, [1, 1])
      XCTAssertEqual(sut[1].map { $0.value }, [5, 6])
    }

    func testExample2() throws {
      XCTAssertEqual(sut.count, 20)
      var view = sut[...]
      while let _ = view.popFirst() {}
      sut = view.unranged()
      XCTAssertEqual(sut.count, 0)
    }

    func testExample3() throws {
      XCTAssertEqual(sut.count, 20)
      sut[...].popLast()
      XCTAssertEqual(sut.count, 19)
      sut[...].removeLast(10)
      XCTAssertEqual(sut.count, 9)
      sut[start().after...].popFirst()
      XCTAssertEqual(sut.count, 8)
      XCTAssertEqual(sut.map { $0.value }, [0, 2, 3, 4, 5, 6, 7, 8])
    }

    func testExample4() throws {
      XCTAssertEqual(sut.count, 20)
      sut[...].erase()
      XCTAssertEqual(sut.count, 0)
    }
  }
#endif
