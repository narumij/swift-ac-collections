//
//  MergeTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/01/04.
//

import RedBlackTreeModule
import XCTest

final class MergeTests: XCTestCase {

  func testSetAndSet() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3]
    var rhs: RedBlackTreeSet<Int> = [4, 5, 6]
    lhs.insert(contentsOf: rhs)
    XCTAssertEqual(lhs.map { $0 }, [1, 2, 3, 4, 5, 6])
    XCTAssertEqual(rhs.map { $0 }, [4, 5, 6])
  }
  
  func testSetAndMultiset() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3]
    let rhs: RedBlackTreeMultiset<Int> = [4, 4, 5, 5, 6, 6]
    lhs.insert(contentsOf: rhs)
    XCTAssertEqual(lhs.map { $0 }, [1, 2, 3, 4, 5, 6])
    XCTAssertEqual(rhs.map { $0 }, [4, 4, 5, 5, 6, 6])
  }

  func testMultietAndSet() throws {
    var lhs: RedBlackTreeMultiset<Int> = [1, 2, 3, 4, 5, 6]
    let rhs: RedBlackTreeSet<Int> = [4, 5, 6]
    lhs.insert(contentsOf: rhs)
    XCTAssertEqual(lhs.map { $0 }, [1, 2, 3, 4, 4, 5, 5, 6, 6])
    XCTAssertEqual(rhs.map { $0 }, [4, 5, 6])
  }

  func testMultietAndMultiet() throws {
    var lhs: RedBlackTreeMultiset<Int> = [1, 2, 3, 4, 5, 6]
    let rhs: RedBlackTreeMultiset<Int> = [4, 4, 5, 5, 6, 6]
    lhs.insert(contentsOf: rhs)
    XCTAssertEqual(lhs.map { $0 }, [1, 2, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6])
    XCTAssertEqual(rhs.map { $0 }, [4, 4, 5, 5, 6, 6])
  }
  
  func testDictionaryAndDictionary() throws {
    var lhs: RedBlackTreeDictionary<String,String> = ["イートハーブの香る":"なんとか"]
    let rhs: RedBlackTreeDictionary<String,String> = ["foo":"bar"]
    lhs.insert(contentsOf: rhs)
    XCTAssertEqual(lhs.dictionary, ["イートハーブの香る":"なんとか","foo":"bar"])
    XCTAssertEqual(rhs.dictionary, ["foo":"bar"])
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}

extension RedBlackTreeDictionary where Key: Hashable {
  var dictionary: [Key: Value] {
    .init(uniqueKeysWithValues: map { ($0.key, $0.value) })
  }
}
