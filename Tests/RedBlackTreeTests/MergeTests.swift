import RedBlackTreeModule
import XCTest

final class MergeTests: XCTestCase {

  func testSetAndSet() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3]
    let rhs: RedBlackTreeSet<Int> = [4, 5, 6]
    lhs.insert(contentsOf: rhs)
    XCTAssertEqual(lhs.map { $0 }, [1, 2, 3, 4, 5, 6])
    XCTAssertEqual(rhs.map { $0 }, [4, 5, 6])
  }

  func testSetAndSwiftSet() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3]
    let rhs: Set<Int> = [4, 5, 6]
    lhs.insert(contentsOf: rhs)
    XCTAssertEqual(lhs.map { $0 }, [1, 2, 3, 4, 5, 6])
    XCTAssertEqual(rhs.sorted().map { $0 }, [4, 5, 6])
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
}

extension RedBlackTreeDictionary where Key: Hashable {
  var dictionary: [Key: Value] {
    .init(uniqueKeysWithValues: map { ($0.key, $0.value) })
  }
}
