import RedBlackTreeModule
import XCTest

final class MergeTests: XCTestCase {

  func testSetAndSet() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3]
    let rhs: RedBlackTreeSet<Int> = [4, 5, 6]
    lhs.merge(rhs)
    XCTAssertEqual(lhs + [], [1, 2, 3, 4, 5, 6])
    XCTAssertEqual(rhs + [], [4, 5, 6])
  }

  func testSetAndSwiftSet() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3]
    let rhs: Set<Int> = [4, 5, 6]
    lhs.merge(rhs)
    XCTAssertEqual(lhs + [], [1, 2, 3, 4, 5, 6])
    XCTAssertEqual(rhs.sorted() + [], [4, 5, 6])
  }

  func testSetAndMultiset() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3]
    let rhs: RedBlackTreeMultiSet<Int> = [4, 4, 5, 5, 6, 6]
    lhs.merge(rhs)
    XCTAssertEqual(lhs + [], [1, 2, 3, 4, 5, 6])
    XCTAssertEqual(rhs + [], [4, 4, 5, 5, 6, 6])
  }

  func testMultietAndSet() throws {
    var lhs: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5, 6]
    let rhs: RedBlackTreeSet<Int> = [4, 5, 6]
    lhs.insert(contentsOf: rhs)
    XCTAssertEqual(lhs + [], [1, 2, 3, 4, 4, 5, 5, 6, 6])
    XCTAssertEqual(rhs + [], [4, 5, 6])
  }

  func testMultietAndMultiet() throws {
    var lhs: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5, 6]
    let rhs: RedBlackTreeMultiSet<Int> = [4, 4, 5, 5, 6, 6]
    lhs.insert(contentsOf: rhs)
    XCTAssertEqual(lhs + [], [1, 2, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6])
    XCTAssertEqual(rhs + [], [4, 4, 5, 5, 6, 6])
  }
  
  func testMultietAndSequence() throws {
    var lhs: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5, 6]
    let rhs: RedBlackTreeMultiSet<Int> = [4, 4, 5, 5, 6, 6]
    lhs.insert(contentsOf: rhs.makeIterator())
    XCTAssertEqual(lhs + [], [1, 2, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6])
    XCTAssertEqual(rhs + [], [4, 4, 5, 5, 6, 6])
  }

  
  func testMultietAndClosedRange() throws {
    var lhs: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5, 6]
    lhs.insert(contentsOf: 1 ... 6)
    XCTAssertEqual(lhs + [], [1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6])
  }
  
  func testDictionaryAndDictionary() throws {
    var lhs: RedBlackTreeDictionary<String,String> = ["イートハーブの香る":"なんとか","Hoge":"Hogehoge", "foo":"bar"]
    let rhs: RedBlackTreeDictionary<String,String> = ["イートハーブの香る":"香り", "Hoge":"Poge"]
    lhs.merge(rhs, uniquingKeysWith: { $1 })
    XCTAssertEqual(lhs.dictionary, ["イートハーブの香る":"香り","foo":"bar","Hoge":"Poge"])
    XCTAssertEqual(rhs.dictionary, ["イートハーブの香る":"香り","Hoge":"Poge"])
  }
  
  func testDictionaryAndDictionary2() throws {
    var lhs: RedBlackTreeDictionary<String,String> = ["イートハーブの香る":"なんとか","Hoge":"Hogehoge", "foo":"bar"]
    let rhs: RedBlackTreeDictionary<String,String> = ["イートハーブの香る":"香り", "Hoge":"Poge"]
    lhs.merge(rhs) { first,_ in first }
    XCTAssertEqual(lhs.dictionary, ["イートハーブの香る":"なんとか","foo":"bar","Hoge":"Hogehoge"])
    XCTAssertEqual(rhs.dictionary, ["イートハーブの香る":"香り", "Hoge":"Poge"])
  }
  
  func testDictionaryAndSequence() throws {
    var lhs: RedBlackTreeDictionary<String,String> = ["イートハーブの香る":"なんとか","Hoge":"Hogehoge", "foo":"bar"]
    lhs.merge( [("イートハーブの香る","香り"), ("Hoge","Poge")], uniquingKeysWith: { $1 })
    XCTAssertEqual(lhs.dictionary, ["イートハーブの香る":"香り","foo":"bar","Hoge":"Poge"])
  }

  func testDictionaryAndSequence2() throws {
    var lhs: RedBlackTreeDictionary<String,String> = ["イートハーブの香る":"なんとか","Hoge":"Hogehoge", "foo":"bar"]
    lhs.merge( [("イートハーブの香る","香り"), ("Hoge","Poge")]) { first,_ in first }
    XCTAssertEqual(lhs.dictionary, ["イートハーブの香る":"なんとか","foo":"bar","Hoge":"Hogehoge"])
  }
}

extension RedBlackTreeDictionary where Key: Hashable {
  var dictionary: [Key: Value] {
    .init(uniqueKeysWithValues: map { ($0.key, $0.value) })
  }
}
