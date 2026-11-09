import RedBlackTreeCollections
import XCTest

/// `RedBlackTreeMappedValuesView`(`Dictionary`/`MultiMap`の`.values`が返す型)の仕様。
/// ジェネリックな共有Viewのため、代表としてDictionaryのインスタンスで検証する。
#if !COMPATIBLE_ATCODER_2025
  final class RedBlackTreeMappedValuesViewTests: RedBlackTreeTestCase {

    private struct ComparisonCountingKey: Comparable {
      nonisolated(unsafe) static var comparisonCount = 0

      let value: Int

      static func < (lhs: Self, rhs: Self) -> Bool {
        comparisonCount += 1
        return lhs.value < rhs.value
      }
    }

    func test_valuesSwapAt_swapsValuesWithoutChangingKeys() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]
      let first = dictionary.startIndex
      let last = dictionary.index(before: dictionary.endIndex)

      dictionary.values.swapAt(first, last)

      XCTAssertEqual(dictionary.map(\.key), [1, 2, 3])
      XCTAssertEqual(dictionary.map(\.value), ["c", "b", "a"])
    }

    func test_valuesSwapAt_sameIndexDoesNothing() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b"]
      let index = dictionary.startIndex

      dictionary.values.swapAt(index, index)

      XCTAssertEqual(dictionary.map(\.value), ["a", "b"])
    }

    func test_valuesSwapAt_preservesValueSemanticsAfterCopy() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]
      let first = dictionary.startIndex
      let last = dictionary.index(before: dictionary.endIndex)
      let copy = dictionary

      dictionary.values.swapAt(first, last)

      XCTAssertEqual(dictionary.map(\.value), ["c", "b", "a"])
      XCTAssertEqual(copy.map(\.value), ["a", "b", "c"])
    }

    func test_subrangeValuesSwapAt_swapsValuesInsideExplicitIndexRange() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [
        1: "outside-before",
        2: "first",
        3: "middle",
        4: "last",
        5: "outside-after",
      ]
      let lower = dictionary.index(dictionary.startIndex, offsetBy: 1)
      let upper = dictionary.index(dictionary.startIndex, offsetBy: 4)
      let last = dictionary.index(before: upper)

      dictionary[lower..<upper].values.swapAt(lower, last)

      XCTAssertEqual(dictionary.map(\.key), [1, 2, 3, 4, 5])
      XCTAssertEqual(
        dictionary.map(\.value),
        ["outside-before", "last", "middle", "first", "outside-after"])
    }

    func test_subrangeValuesSwapAt_preservesValueSemanticsAfterCopy() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [
        1: "outside-before",
        2: "first",
        3: "last",
        4: "outside-after",
      ]
      let lower = dictionary.index(dictionary.startIndex, offsetBy: 1)
      let upper = dictionary.index(dictionary.startIndex, offsetBy: 3)
      let last = dictionary.index(before: upper)
      let copy = dictionary

      dictionary[lower..<upper].values.swapAt(lower, last)

      XCTAssertEqual(
        dictionary.map(\.value),
        ["outside-before", "last", "first", "outside-after"])
      XCTAssertEqual(
        copy.map(\.value),
        ["outside-before", "first", "last", "outside-after"])
    }

    func test_valuesSubscript_getReturnsValueAtPosition() {
      let dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c"]
      let index = dictionary.index(dictionary.startIndex, offsetBy: 1)
      XCTAssertEqual(dictionary.values[index], "b")
    }

    func test_valuesSubscript_setReplacesValueWithoutChangingKeys() {
      var dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c"]
      let index = dictionary.index(dictionary.startIndex, offsetBy: 1)

      dictionary.values[index] = "changed"

      XCTAssertEqual(dictionary.map(\.key), [1, 2, 3])
      XCTAssertEqual(dictionary.map(\.value), ["a", "changed", "c"])
    }

    func test_valuesSubscript_setPreservesValueSemanticsAfterCopy() {
      var dictionary: RedBlackTreeDictionary = [1: "a", 2: "b"]
      let copy = dictionary
      let index = dictionary.startIndex

      dictionary.values[index] = "changed"

      XCTAssertEqual(dictionary.map(\.value), ["changed", "b"])
      XCTAssertEqual(copy.map(\.value), ["a", "b"])
    }

    func test_subrangeValuesSingleIndexOperations_doNotCompareKeys() {
      var dictionary = RedBlackTreeDictionary<ComparisonCountingKey, String>(
        uniqueKeysWithValues: (0..<5).map { (ComparisonCountingKey(value: $0), "\($0)") })
      let lower = dictionary.index(after: dictionary.startIndex)
      // Keep the View end on a live base-tree element so an old range check must compare keys.
      let upper = dictionary.index(before: dictionary.endIndex)
      let first = lower
      let last = dictionary.index(before: upper)
      var values = dictionary[lower..<upper].values

      ComparisonCountingKey.comparisonCount = 0
      XCTAssertEqual(values[first], "1")
      XCTAssertEqual(ComparisonCountingKey.comparisonCount, 0)

      values[first] = "changed"
      XCTAssertEqual(ComparisonCountingKey.comparisonCount, 0)
      XCTAssertEqual(Array(values), ["changed", "2", "3"])
      XCTAssertEqual(dictionary.map(\.value), ["0", "1", "2", "3", "4"])

      values.swapAt(first, last)
      XCTAssertEqual(ComparisonCountingKey.comparisonCount, 0)
      XCTAssertEqual(Array(values), ["3", "2", "changed"])
      XCTAssertEqual(dictionary.map(\.value), ["0", "1", "2", "3", "4"])
    }

    func test_valuesCount_matchesDictionaryCount() {
      let dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c"]
      XCTAssertEqual(dictionary.values.count, 3)
      XCTAssertEqual(RedBlackTreeDictionary<Int, String>().values.count, 0)
    }

    func test_valuesFirstAndLast_followKeyOrder() {
      let dictionary: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b"]
      XCTAssertEqual(dictionary.values.first, "a")
      XCTAssertEqual(dictionary.values.last, "c")
      XCTAssertNil(RedBlackTreeDictionary<Int, String>().values.first)
      XCTAssertNil(RedBlackTreeDictionary<Int, String>().values.last)
    }

    func test_valuesPopFirstAndPopLast_removeEndpointsAndReturnRemovedValue() {
      var dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c"]

      XCTAssertEqual(dictionary.values.popFirst(), "a")
      XCTAssertEqual(dictionary.map(\.key), [2, 3])

      XCTAssertEqual(dictionary.values.popLast(), "c")
      XCTAssertEqual(dictionary.map(\.key), [2])

      var empty = RedBlackTreeDictionary<Int, String>()
      XCTAssertNil(empty.values.popFirst())
      XCTAssertNil(empty.values.popLast())
    }

    /// 空のビューに対する削除系操作は、トラップしない以上、無駄なCoW
    /// (共有される空シングルトンバッファからの退避)も発生させないこと。
    func test_valuesRemovalMethods_onEmptyView_doNotTriggerCopyOnWrite() {
      #if _TREE_COPY_COUNTER
        var empty = RedBlackTreeDictionary<Int, String>()
        XCTAssertEqual(empty._copyCount, 0)

        XCTAssertNil(empty.values.popFirst())
        XCTAssertEqual(empty._copyCount, 0)

        XCTAssertNil(empty.values.popLast())
        XCTAssertEqual(empty._copyCount, 0)

        empty.values.erase()
        XCTAssertEqual(empty._copyCount, 0)

        empty.values.erase(where: { _ in true })
        XCTAssertEqual(empty._copyCount, 0)
      #endif
    }

    func test_valuesRemoveFirstAndRemoveLast_removeEndpointsAndReturnRemovedValue() {
      var dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c"]

      XCTAssertEqual(dictionary.values.removeFirst(), "a")
      XCTAssertEqual(dictionary.map(\.key), [2, 3])

      XCTAssertEqual(dictionary.values.removeLast(), "c")
      XCTAssertEqual(dictionary.map(\.key), [2])
    }

    func test_valuesErase_removesAllElementsInView() {
      var dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c"]
      dictionary.values.erase()
      XCTAssertTrue(dictionary.isEmpty)
    }

    func test_valuesEraseWhere_removesOnlyMatchingElements() {
      var dictionary: RedBlackTreeDictionary = [1: "a", 2: "bb", 3: "ccc"]
      dictionary.values.erase(where: { $0.count >= 2 })
      XCTAssertEqual(dictionary.map(\.key), [1])
    }

    /// 部分範囲の`values`の`erase(where:)`は、述語のエラーをそのまま呼出元へ投げ、投げた後は述語を呼ばず、
    /// 範囲外のkey/valueに触れないこと。共有していた元の辞書のkey/valueは変わらないこと。変更側の途中状態は
    /// 契約がないため、範囲外のエントリが残り、元のエントリだけをkey順に持つことだけを確かめる（RBT-046 X2）
    func test_subrangeValuesEraseWhere_rethrowsPredicateErrorAndKeepsSharedOriginal() {
      struct StopError: Error, Equatable {}
      var dictionary: RedBlackTreeDictionary<Int, String> = [
        1: "outside-before", 2: "b", 3: "c", 4: "d", 5: "outside-after",
      ]
      let lower = dictionary.index(after: dictionary.startIndex)
      let upper = dictionary.index(dictionary.startIndex, offsetBy: 4)
      let original = dictionary
      var visited: [String] = []

      XCTAssertThrowsError(
        try dictionary[lower..<upper].values.erase(where: { value in
          visited.append(value)
          if value == "c" { throw StopError() }
          return value == "b"
        })
      ) { error in
        XCTAssertEqual(error as? StopError, StopError())
      }
      XCTAssertEqual(visited, ["b", "c"], "範囲内の先頭から順に呼ばれ、エラーの後は呼ばれないこと")
      XCTAssertEqual(original.map(\.key), [1, 2, 3, 4, 5])
      XCTAssertEqual(original.map(\.value), ["outside-before", "b", "c", "d", "outside-after"])
      XCTAssertEqual(dictionary[1], "outside-before", "範囲より前のエントリは残ること")
      XCTAssertEqual(dictionary[5], "outside-after", "範囲より後のエントリは残ること")
      XCTAssertEqual(dictionary.map(\.key), dictionary.map(\.key).sorted())
      XCTAssertTrue(dictionary.allSatisfy { original[$0.key] == $0.value })
    }

    func test_valuesIsElementAndIsEnd_describeIndexValidity() {
      let dictionary: RedBlackTreeDictionary = [1: "a", 2: "b"]
      let start = dictionary.startIndex
      let end = dictionary.endIndex

      XCTAssertTrue(dictionary.values.isElement(at: start))
      XCTAssertFalse(dictionary.values.isElement(at: end))
      XCTAssertTrue(dictionary.values.isEnd(end))
      XCTAssertFalse(dictionary.values.isEnd(start))
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMappedValuesViewTests {
    /// 範囲ビューの.valuesのerase(where:)でビューの先頭要素を消しても、残りの値はビューに残ること。
    func test_eraseWhere_removingFirstElement_keepsRest() {
      let dictionary = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0 * 10) })
      var values = dictionary[dictionary.lowerBound(3)..<dictionary.lowerBound(8)].values
      values.erase(where: { $0 == 30 })
      XCTAssertEqual(Array(values), [40, 50, 60, 70])
    }

    /// 共有中の空でない木で、範囲ビューの.values`erase(where:)`が何も消さないとき、木をコピーしないこと。述語は範囲内の各要素に1回ずつ順に呼ばれること（RBT-081）。
    func test_eraseWhere_nothingMatches_keepsSharedStorage() {
      let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
      var shared = original
      let lo = shared.index(after: shared.startIndex)
      let hi = shared.index(lo, offsetBy: 3)
      var visited: [String] = []

      shared[lo ..< hi].values.erase { visited.append($0); return false }

      XCTAssertEqual(visited, ["b", "c", "d"])
      XCTAssertEqual(shared.map(\.key), [1, 2, 3, 4, 5])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "何も消さないViewのerase(where:)で木がコピーされた")
    }

    /// 部分範囲の.valuesの`erase(where:)`が最初の一致より前で投げても、エラーをそのまま呼出元へ投げ、投げた後は述語を呼ばず、
    /// 範囲外のkey/valueに触れないこと。共有していた元の辞書のkey/valueは変わらないこと。変更側の途中状態は
    /// 契約がないため、範囲外のエントリが残り、元のエントリだけをkey順に持つことだけを確かめる（RBT-094）
    func test_subrangeValuesEraseWhere_throwsBeforeFirstMatchAndKeepsSharedOriginal() {
      struct StopError: Error, Equatable {}
      var dictionary: RedBlackTreeDictionary<Int, String> = [
        1: "outside-before", 2: "b", 3: "c", 4: "d", 5: "outside-after",
      ]
      let lower = dictionary.index(after: dictionary.startIndex)
      let upper = dictionary.index(dictionary.startIndex, offsetBy: 4)
      let original = dictionary
      var visited: [String] = []

      XCTAssertThrowsError(
        try dictionary[lower..<upper].values.erase(where: { value in
          visited.append(value)
          if value == "c" { throw StopError() }
          return false
        })
      ) { error in
        XCTAssertEqual(error as? StopError, StopError())
      }
      XCTAssertEqual(visited, ["b", "c"])
      XCTAssertEqual(original.map(\.key), [1, 2, 3, 4, 5])
      XCTAssertEqual(original.map(\.value), ["outside-before", "b", "c", "d", "outside-after"])
      XCTAssertEqual(dictionary[1], "outside-before")
      XCTAssertEqual(dictionary[5], "outside-after")
      XCTAssertEqual(dictionary.map(\.key), dictionary.map(\.key).sorted())
      XCTAssertTrue(dictionary.allSatisfy { original[$0.key] == $0.value })
    }

    /// 共有中の木から取り出した範囲ビューの.valuesで、`erase(where:)`がビューの先頭を含めて要素を消すとき、
    /// 述語は範囲内の各値に1回ずつ順に呼ばれ、ビューには残りの値が残り、元の辞書は変わらないこと（RBT-094）。
    func test_eraseWhere_onStandaloneViewOfSharedTree_keepsRestAndOriginal() {
      let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
      var values = original[original.lowerBound(2)..<original.lowerBound(5)].values
      var visited: [String] = []

      values.erase { visited.append($0); return $0 != "c" }

      XCTAssertEqual(visited, ["b", "c", "d"])
      XCTAssertEqual(Array(values), ["c"])
      XCTAssertEqual(values.count, 1)
      XCTAssertEqual(original.map(\.value), ["a", "b", "c", "d", "e"])
    }

    /// 共有中の木から取り出した範囲ビューの.valuesで、`erase(where:)`の述語がすべての値に一致するとき、
    /// ビューは空になってstartIndexとendIndexが一致し、元の辞書は変わらないこと（RBT-094）。
    func test_eraseWhere_allMatchOnStandaloneViewOfSharedTree_emptiesView() {
      let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
      var values = original[original.lowerBound(2)..<original.lowerBound(5)].values
      var visited: [String] = []

      values.erase { visited.append($0); return true }

      XCTAssertEqual(visited, ["b", "c", "d"])
      XCTAssertTrue(values.isEmpty)
      XCTAssertEqual(values.startIndex, values.endIndex)
      XCTAssertEqual(original.map(\.value), ["a", "b", "c", "d", "e"])
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMappedValuesViewTests {
    /// MultiMapでも、範囲ビューの.valuesのerase(where:)で先頭要素を消して残りが残ること。
    func test_eraseWhere_removingFirstElement_keepsRest_multiMap() {
      let multiMap = RedBlackTreeMultiMap(keysWithValues: (0..<10).map { ($0, $0 * 10) })
      var values = multiMap[multiMap.lowerBound(3)..<multiMap.lowerBound(8)].values
      values.erase(where: { $0 == 30 })
      XCTAssertEqual(Array(values), [40, 50, 60, 70])
    }
  }
#endif
