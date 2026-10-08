import RedBlackTreeCollections
import XCTest

final class RedBlackTreeDictionaryProtocolConformanceTests: RedBlackTreeTestCase {}

// MARK: - ExpressibleByDictionaryLiteral
extension RedBlackTreeDictionaryProtocolConformanceTests {

  func test_expressibleByDictionaryLiteral() {
    let dict: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b"]
    XCTAssertEqual(dict.count, 2)
    XCTAssertEqual(dict[1], "a")
  }
}

// MARK: - ExpressibleByArrayLiteral
extension RedBlackTreeDictionaryProtocolConformanceTests {

  func test_expressibleByArrayLiteral() {
    let dict: RedBlackTreeDictionary<Int, String> = [(1, "a"), (2, "b")]
    XCTAssertEqual(dict.count, 2)
    XCTAssertEqual(dict[2], "b")
  }
}

// MARK: - CustomStringConvertible
extension RedBlackTreeDictionaryProtocolConformanceTests {

  func test_customStringConvertible_description() {
    let dict: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b"]
    let description = dict.description
    XCTAssertTrue(description.contains("1") && description.contains("a"))
  }
}

// MARK: - CustomDebugStringConvertible
extension RedBlackTreeDictionaryProtocolConformanceTests {

  func test_customDebugStringConvertible_debugDescription() {
    let dict: RedBlackTreeDictionary<Int, String> = [1: "a"]
    let debugDescription = dict.debugDescription
    XCTAssertTrue(debugDescription.contains(dict.description))
  }
}

// MARK: - CustomReflectable
extension RedBlackTreeDictionaryProtocolConformanceTests {

  func test_customReflectable_mirrorContainsElements() {
    let dict: RedBlackTreeDictionary<Int, String> = [2: "b", 1: "a"]
    let mirror = dict.customMirror

    XCTAssertEqual(mirror.displayStyle, .dictionary)
    XCTAssertEqual(mirror.children.count, dict.count)
  }

  /// すべての子がラベル無し(unlabeled)で、`(key:value:)`タプルとしてcastできること
  func test_customReflectable_childrenAreUnlabeledKeyValueTuples() {
    let dict: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b"]
    let mirror = dict.customMirror

    XCTAssertTrue(mirror.children.allSatisfy { $0.label == nil })
    let pairs = mirror.children.compactMap { $0.value as? (key: Int, value: String) }
    XCTAssertEqual(pairs.count, dict.count)
    XCTAssertEqual(Set(pairs.map(\.key)), [1, 2])
    XCTAssertEqual(Set(pairs.map(\.value)), ["a", "b"])
  }

  /// 空のDictionaryの子は0件であること
  func test_customReflectable_emptyDictionaryHasNoChildren() {
    let dict = RedBlackTreeDictionary<Int, String>()
    let mirror = dict.customMirror

    XCTAssertEqual(mirror.children.count, 0)
  }
}

// MARK: - Is Trivially Identical
extension RedBlackTreeDictionaryProtocolConformanceTests {

  func test_isTriviallyIdentical_copyIsIdentical() {
    let a: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b"]
    let b = a
    XCTAssertTrue(a.isTriviallyIdentical(to: b))
  }

  func test_isTriviallyIdentical_mutationBreaksIdentity() {
    let a: RedBlackTreeDictionary<Int, String> = [1: "a"]
    var b = a
    b[2] = "b"
    XCTAssertFalse(a.isTriviallyIdentical(to: b))
  }
}

// MARK: - Equatable
extension RedBlackTreeDictionaryProtocolConformanceTests {

  func test_equatable_dictsAreEqual() {
    let a: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b"]
    let b: RedBlackTreeDictionary<Int, String> = [2: "b", 1: "a"]
    XCTAssertEqual(a, b)
  }

  func test_equatable_dictsAreNotEqual() {
    let a: RedBlackTreeDictionary<Int, String> = [1: "a"]
    let b: RedBlackTreeDictionary<Int, String> = [1: "b"]
    XCTAssertNotEqual(a, b)
  }

  func test_equatable_rangeViewsFromDifferentTreesCompareByElements() {
    let aa = RedBlackTreeDictionary<Int, Int>(uniqueKeysWithValues: (0...5).map { ($0, $0) })
    let bb = RedBlackTreeDictionary<Int, Int>(uniqueKeysWithValues: (3...8).map { ($0, $0) })

    XCTAssertEqual(aa[aa.lowerBound(3)..<aa.lowerBound(6)], bb[bb.lowerBound(3)..<bb.lowerBound(6)])
    XCTAssertNotEqual(
      aa[aa.lowerBound(2)..<aa.lowerBound(6)], bb[bb.lowerBound(3)..<bb.lowerBound(6)])
  }
}

// MARK: - Comparable
extension RedBlackTreeDictionaryProtocolConformanceTests {

  func test_comparable_ordersByElements() {
    let a: RedBlackTreeDictionary<Int, String> = [1: "a"]
    let b: RedBlackTreeDictionary<Int, String> = [1: "b"]

    XCTAssertTrue(a < b)
    XCTAssertFalse(b < a)
  }
}

// MARK: - Hashable
extension RedBlackTreeDictionaryProtocolConformanceTests {

  func test_hashable_allowsSetOfDictionaries() {
    let a: RedBlackTreeDictionary<Int, String> = [1: "a"]
    let b: RedBlackTreeDictionary<Int, String> = [2: "b"]
    let c: RedBlackTreeDictionary<Int, String> = [1: "a"]

    let setOfDicts: Set<RedBlackTreeDictionary<Int, String>> = [a, b]
    XCTAssertTrue(setOfDicts.contains(a))
    XCTAssertTrue(setOfDicts.contains(b))
    XCTAssertTrue(setOfDicts.contains(c))
    XCTAssertEqual(setOfDicts.count, 2)
  }
}

// MARK: - Sendable
#if swift(>=5.5)
extension RedBlackTreeDictionaryProtocolConformanceTests {

  func test_sendable_compiles() {
    func requiresSendable<T: Sendable>(_ value: T) {}
    let dict: RedBlackTreeDictionary<Int, String> = [1: "a"]
    requiresSendable(dict)
  }
}
#endif

// MARK: - elementsEqual / lexicographicallyPrecedes
extension RedBlackTreeDictionaryProtocolConformanceTests {

  func test_elementsEqual_trueForSameKeyValuePairsInKeyOrder() {
    let a: RedBlackTreeDictionary = [1: "a", 2: "b"]
    let b: RedBlackTreeDictionary = [2: "b", 1: "a"]
    XCTAssertTrue(a.elementsEqual(b, by: ==))
  }

  func test_elementsEqual_falseWhenValuesDiffer() {
    let a: RedBlackTreeDictionary = [1: "a", 2: "b"]
    let b: RedBlackTreeDictionary = [1: "a", 2: "z"]
    XCTAssertFalse(a.elementsEqual(b, by: ==))
  }

  func test_lexicographicallyPrecedes_trueWhenSmallerAtFirstDifference() {
    let a: RedBlackTreeDictionary = [1: "a", 2: "b"]
    let b: RedBlackTreeDictionary = [1: "a", 2: "c"]
    XCTAssertTrue(a.lexicographicallyPrecedes(b, by: <))
  }

  func test_lexicographicallyPrecedes_comparesLengthAfterCommonPrefix() {
    let shorter: RedBlackTreeDictionary = [1: "a"]
    let longer: RedBlackTreeDictionary = [1: "a", 2: "b"]
    XCTAssertTrue(shorter.lexicographicallyPrecedes(longer, by: <))
    XCTAssertFalse(longer.lexicographicallyPrecedes(shorter, by: <))
  }
}
