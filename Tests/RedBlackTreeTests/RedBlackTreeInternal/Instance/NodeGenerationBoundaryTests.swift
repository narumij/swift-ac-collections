#if DEBUG && !COMPATIBLE_ATCODER_2025
import XCTest
@testable import RedBlackTreeCollections

final class NodeGenerationBoundaryTests: RedBlackTreeTestCase {
  func testRemoveWrapsGenerationAndRejectsRecycledNodeWithMatchingSeal() {
    var set = RedBlackTreeSet([1, 2, 3])
    let stale = set.firstIndex(of: 2)!
    XCTAssertEqual(NodeGenerationFixture.generation(at: stale), 0)
    NodeGenerationFixture.set(.max, at: stale)
    let beforeWrap = set.firstIndex(of: 2)!
    XCTAssertTrue(set.isElement(at: beforeWrap))

    XCTAssertEqual(set.remove(2), 2)
    XCTAssertEqual(NodeGenerationFixture.generation(at: stale), 0)
    // sealは再び一致する。それでも回収済みノードを移動経路へ通してはいけない。
    XCTAssertEqual(set.__tree_.__purified_(stale).error, .garbaged)
    XCTAssertFalse(set.isElement(at: stale))

    set.insert(4)
    let fresh = set.firstIndex(of: 4)!
    XCTAssertEqual(fresh.rawValue.pointer, stale.rawValue.pointer)
    XCTAssertEqual(NodeGenerationFixture.generation(at: fresh), 0)
    XCTAssertTrue(set.isElement(at: fresh))
    XCTAssertFalse(set.isElement(at: beforeWrap))
    XCTAssertEqual(set[fresh], 4)
    XCTAssertEqual(set.index(after: fresh), set.endIndex)
    XCTAssertEqual(Array(set), [1, 3, 4])
    // staleが新要素を指すかどうかは、過去の要素との同一性保証として固定しない。
  }

  func testGenerationContinuesThroughMaxAndZero() {
    var set = RedBlackTreeSet([1, 2, 3])
    let slot = set.firstIndex(of: 2)!
    NodeGenerationFixture.set(.max - 1, at: slot)
    for expected: UnsafeNode.Seal in [.max, 0, 1] {
      XCTAssertEqual(set.remove(2), 2)
      XCTAssertEqual(NodeGenerationFixture.generation(at: slot), expected)
      set.insert(2)
      let fresh = set.firstIndex(of: 2)!
      XCTAssertEqual(fresh.rawValue.pointer, slot.rawValue.pointer)
      XCTAssertTrue(set.isElement(at: fresh))
      XCTAssertEqual(set[fresh], 2)
    }
  }

  func testDictionaryModifyRemovalWrapsAndRejectsRecycledNode() {
    // inoutで添字の_modifyを通し、payload移動後のraw回収経路を使う。
    func clear(_ value: inout String?) { value = nil }
    var dictionary: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]
    let stale = dictionary.firstIndex(of: 2)!
    XCTAssertEqual(NodeGenerationFixture.generation(at: stale), 0)
    NodeGenerationFixture.set(.max, at: stale)
    clear(&dictionary[2])

    XCTAssertEqual(NodeGenerationFixture.generation(at: stale), 0)
    XCTAssertEqual(dictionary.__tree_.__purified_(stale).error, .garbaged)
    XCTAssertFalse(dictionary.isElement(at: stale))
    XCTAssertNil(dictionary[2])
    XCTAssertEqual(dictionary.count, 2)

    dictionary[4] = "d"
    let fresh = dictionary.firstIndex(of: 4)!
    XCTAssertEqual(fresh.rawValue.pointer, stale.rawValue.pointer)
    XCTAssertEqual(NodeGenerationFixture.generation(at: fresh), 0)
    XCTAssertTrue(dictionary.isElement(at: fresh))
    XCTAssertEqual(dictionary[4], "d")
    XCTAssertEqual(dictionary.index(after: fresh), dictionary.endIndex)
  }

  func testKeepingCapacityClearAtMaxRejectsOldIndexAndAllowsReuse() {
    var set = RedBlackTreeSet([1, 2, 3])
    let stale = set.firstIndex(of: 2)!
    NodeGenerationFixture.set(.max, at: stale)
    let capacity = set.capacity
    set.removeAll(keepingCapacity: true)

    XCTAssertEqual(set.capacity, capacity)
    XCTAssertTrue(set.isEmpty)
    XCTAssertEqual(set.startIndex, set.endIndex)
    XCTAssertFalse(set.isElement(at: stale))
    // 全削除後は古いノードを直接読まず、公開APIから再利用を確かめる。
    set.insert(4)
    let fresh = set.startIndex
    XCTAssertTrue(set.isElement(at: fresh))
    XCTAssertEqual(set[fresh], 4)
    XCTAssertEqual(set.index(after: fresh), set.endIndex)
    XCTAssertEqual(Array(set), [4])
  }
}
#endif
