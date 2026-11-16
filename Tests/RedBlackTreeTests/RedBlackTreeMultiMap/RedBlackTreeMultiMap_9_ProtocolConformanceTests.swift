import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiMapProtocolConformanceTests: RedBlackTreeTestCase {}

// MARK: - ExpressibleByDictionaryLiteral
extension RedBlackTreeMultiMapProtocolConformanceTests {

  func test_expressibleByDictionaryLiteral() {
    let map: RedBlackTreeMultiMap<Int, String> = [1: "a", 2: "b"]
    XCTAssertEqual(map.count, 2)
  }
}

// MARK: - ExpressibleByArrayLiteral
extension RedBlackTreeMultiMapProtocolConformanceTests {

  func test_expressibleByArrayLiteral() {
    let map: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (1, "b"), (2, "c")]
    XCTAssertEqual(map.count, 3)
  }
}

// MARK: - CustomStringConvertible
extension RedBlackTreeMultiMapProtocolConformanceTests {

  func test_customStringConvertible_description() {
    let map: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (2, "b")]
    let description = map.description
    XCTAssertTrue(description.contains("1") && description.contains("a"))
  }
}

// MARK: - CustomDebugStringConvertible
extension RedBlackTreeMultiMapProtocolConformanceTests {

  func test_customDebugStringConvertible_debugDescription() {
    let map: RedBlackTreeMultiMap<Int, String> = [(1, "a")]
    let debugDescription = map.debugDescription
    XCTAssertTrue(debugDescription.contains(map.description))
  }
}

// MARK: - CustomReflectable
extension RedBlackTreeMultiMapProtocolConformanceTests {

  func test_customReflectable_mirrorContainsElements() {
    let map: RedBlackTreeMultiMap<Int, String> = [(2, "b"), (1, "a")]
    let mirror = map.customMirror

    XCTAssertEqual(mirror.displayStyle, .dictionary)
    XCTAssertEqual(mirror.children.count, map.count)
  }

  /// 同一キーの複数pairも、個別の子としてすべて反映され、
  /// 各子は`(key:value:)`タプルとしてcastできること
  func test_customReflectable_duplicateKeyPairsAreEachRepresentedAsKeyValueTuples() {
    let map: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (1, "b")]
    let mirror = map.customMirror

    XCTAssertTrue(mirror.children.allSatisfy { $0.label == nil })
    let pairs = mirror.children.compactMap { $0.value as? (key: Int, value: String) }
    XCTAssertEqual(pairs.count, map.count)
    XCTAssertEqual(pairs.map(\.key), [1, 1])
    XCTAssertEqual(Set(pairs.map(\.value)), ["a", "b"])
  }

  /// 空のMultiMapの子は0件であること
  func test_customReflectable_emptyMultiMapHasNoChildren() {
    let map = RedBlackTreeMultiMap<Int, String>()
    let mirror = map.customMirror

    XCTAssertEqual(mirror.children.count, 0)
  }
}

// MARK: - Is Trivially Identical
extension RedBlackTreeMultiMapProtocolConformanceTests {

  func test_isTriviallyIdentical_copyIsIdentical() {
    let a: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (2, "b")]
    let b = a
    XCTAssertTrue(a.isTriviallyIdentical(to: b))
  }

  func test_isTriviallyIdentical_mutationBreaksIdentity() {
    let a: RedBlackTreeMultiMap<Int, String> = [(1, "a")]
    var b = a
    b.insert(key: 2, value: "b")
    XCTAssertFalse(a.isTriviallyIdentical(to: b))
  }
}

// MARK: - Equatable
extension RedBlackTreeMultiMapProtocolConformanceTests {

  func test_equatable_mapsAreEqual() {
    let a: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (2, "b")]
    let b: RedBlackTreeMultiMap<Int, String> = [(2, "b"), (1, "a")]
    XCTAssertEqual(a, b)
  }

  func test_equatable_mapsAreNotEqual() {
    let a: RedBlackTreeMultiMap<Int, String> = [(1, "a")]
    let b: RedBlackTreeMultiMap<Int, String> = [(1, "b")]
    XCTAssertNotEqual(a, b)
  }

  func test_equatable_rangeViewsFromDifferentTreesCompareByElements() {
    let aa = RedBlackTreeMultiMap<Int, Int>(keysWithValues: (0...5).map { ($0, $0) })
    let bb = RedBlackTreeMultiMap<Int, Int>(keysWithValues: (3...8).map { ($0, $0) })

    XCTAssertEqual(aa[aa.lowerBound(3)..<aa.lowerBound(6)], bb[bb.lowerBound(3)..<bb.lowerBound(6)])
    XCTAssertNotEqual(
      aa[aa.lowerBound(2)..<aa.lowerBound(6)], bb[bb.lowerBound(3)..<bb.lowerBound(6)])
  }
}

// MARK: - Comparable
extension RedBlackTreeMultiMapProtocolConformanceTests {

  func test_comparable_ordersByElements() {
    let a: RedBlackTreeMultiMap<Int, String> = [(1, "a")]
    let b: RedBlackTreeMultiMap<Int, String> = [(1, "b")]

    XCTAssertTrue(a < b)
    XCTAssertFalse(b < a)
  }

  func test_comparable_rangeViewsFromDifferentTreesOrderByElements() {
    let aa = RedBlackTreeMultiMap<Int, Int>(keysWithValues: (0...5).map { ($0, $0) })
    let bb = RedBlackTreeMultiMap<Int, Int>(keysWithValues: (3...8).map { ($0, $0) })

    XCTAssertTrue(aa[aa.lowerBound(2)..<aa.lowerBound(6)] < bb[bb.lowerBound(3)..<bb.lowerBound(6)])
    XCTAssertFalse(bb[bb.lowerBound(3)..<bb.lowerBound(6)] < aa[aa.lowerBound(2)..<aa.lowerBound(6)])
  }
}

// MARK: - Hashable
extension RedBlackTreeMultiMapProtocolConformanceTests {

  func test_hashable_allowsSetOfMaps() {
    let a: RedBlackTreeMultiMap<Int, String> = [(1, "a")]
    let b: RedBlackTreeMultiMap<Int, String> = [(2, "b")]
    let c: RedBlackTreeMultiMap<Int, String> = [(1, "a")]

    let setOfMaps: Set<RedBlackTreeMultiMap<Int, String>> = [a, b]
    XCTAssertTrue(setOfMaps.contains(a))
    XCTAssertTrue(setOfMaps.contains(b))
    XCTAssertTrue(setOfMaps.contains(c))
    XCTAssertEqual(setOfMaps.count, 2)
  }
}

// MARK: - Sendable
#if swift(>=5.5)
extension RedBlackTreeMultiMapProtocolConformanceTests {

  func test_sendable_compiles() {
    func requiresSendable<T: Sendable>(_ value: T) {}
    let map: RedBlackTreeMultiMap<Int, String> = [(1, "a")]
    requiresSendable(map)
  }
}
#endif

// MARK: - elementsEqual / lexicographicallyPrecedes
extension RedBlackTreeMultiMapProtocolConformanceTests {

  func test_elementsEqual_trueForSameKeyValuePairsInKeyOrderIncludingDuplicateKeys() {
    let a: RedBlackTreeMultiMap = [(1, "a"), (1, "b"), (2, "c")]
    let b: RedBlackTreeMultiMap = [(2, "c"), (1, "a"), (1, "b")]
    XCTAssertTrue(a.elementsEqual(b, by: ==))
  }

  func test_elementsEqual_falseWhenValuesDiffer() {
    let a: RedBlackTreeMultiMap = [(1, "a"), (1, "b")]
    let b: RedBlackTreeMultiMap = [(1, "a"), (1, "z")]
    XCTAssertFalse(a.elementsEqual(b, by: ==))
  }

  func test_lexicographicallyPrecedes_trueWhenSmallerAtFirstDifference() {
    let a: RedBlackTreeMultiMap = [(1, "a"), (1, "b")]
    let b: RedBlackTreeMultiMap = [(1, "a"), (1, "c")]
    XCTAssertTrue(a.lexicographicallyPrecedes(b, by: <))
  }

  func test_lexicographicallyPrecedes_comparesLengthAfterCommonPrefix() {
    let shorter: RedBlackTreeMultiMap = [(1, "a")]
    let longer: RedBlackTreeMultiMap = [(1, "a"), (1, "b")]
    XCTAssertTrue(shorter.lexicographicallyPrecedes(longer, by: <))
    XCTAssertFalse(longer.lexicographicallyPrecedes(shorter, by: <))
  }
}
